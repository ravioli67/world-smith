
"""WorldSmith local AI adapter with strict output validation."""

import json
import os
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


OLLAMA_URL = os.getenv(
    "WORLDSMITH_OLLAMA_URL",
    "http://127.0.0.1:11434/api/chat",
)

MODEL_NAME = os.getenv(
    "WORLDSMITH_MODEL",
    "qwen2.5:3b",
)

REQUIRED_STRINGS = (
    "title",
    "genre",
    "perspective",
    "target_engine",
    "core_loop",
    "player_goal",
    "world_description",
)

REQUIRED_LISTS = (
    "features",
    "assumptions",
    "open_questions",
)

SYSTEM_PROMPT = """
You are WorldSmith, an AI game-design planning system.

Understand the meaning of the user's game idea, not just keywords.
Preserve explicit requirements and infer reasonable design details.

Return exactly one JSON object with these fields:
{
  "title": "short game title",
  "genre": "main genre",
  "perspective": "2D, 3D, first-person, third-person, or top-down",
  "target_engine": "Godot",
  "core_loop": "the main repeated gameplay activity",
  "features": ["feature 1", "feature 2"],
  "player_goal": "what the player is trying to accomplish",
  "world_description": "setting and atmosphere",
  "assumptions": ["reasonable assumptions"],
  "open_questions": ["important unresolved questions"]
}

Every string must be a string. Every list must contain only strings.
Do not include Markdown fences or explanatory text outside the JSON.
Do not claim that code or assets have already been generated.
"""


class ModelOutputError(RuntimeError):
    """Raised when the local model response cannot be safely used."""


def validate_game_spec(spec: object) -> dict:
    """Validate the decoded JSON object and return it."""

    if not isinstance(spec, dict):
        raise ModelOutputError(
            "The model response must be a JSON object."
        )

    required_fields = REQUIRED_STRINGS + REQUIRED_LISTS

    missing = [key for key in required_fields if key not in spec]
    if missing:
        raise ModelOutputError(
            "Missing required fields: " + ", ".join(missing)
        )

    for key in REQUIRED_STRINGS:
        value = spec[key]

        if not isinstance(value, str):
            raise ModelOutputError(
                f"Field '{key}' must be a string."
            )

        if not value.strip():
            raise ModelOutputError(
                f"Field '{key}' cannot be empty."
            )

    for key in REQUIRED_LISTS:
        value = spec[key]

        if not isinstance(value, list):
            raise ModelOutputError(
                f"Field '{key}' must be a list of strings."
            )

        if not all(isinstance(item, str) for item in value):
            raise ModelOutputError(
                f"Every item in '{key}' must be a string."
            )

    # Prevent excessively large individual responses from flowing
    # into later stages unchecked.
    for key in REQUIRED_STRINGS:
        if len(spec[key]) > 10_000:
            raise ModelOutputError(
                f"Field '{key}' is too long."
            )

    for key in REQUIRED_LISTS:
        if len(spec[key]) > 100:
            raise ModelOutputError(
                f"Field '{key}' contains too many items."
            )

        if any(len(item) > 2_000 for item in spec[key]):
            raise ModelOutputError(
                f"An item in '{key}' is too long."
            )

    return spec


def decode_model_json(content: str) -> dict:
    """Decode JSON strictly and validate the resulting object."""

    if not isinstance(content, str) or not content.strip():
        raise ModelOutputError("The model returned an empty response.")

    try:
        decoded = json.loads(content)
    except json.JSONDecodeError as exc:
        raise ModelOutputError(
            "The model returned malformed JSON "
            f"(line {exc.lineno}, column {exc.colno}): {exc.msg}"
        ) from exc

    return validate_game_spec(decoded)


def analyze_game_idea(prompt: str) -> dict:
    """Ask Ollama to interpret a game idea and validate its answer."""

    if not isinstance(prompt, str) or not prompt.strip():
        raise ValueError("The game description cannot be empty.")

    payload = {
        "model": MODEL_NAME,
        "stream": False,
        "format": "json",
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ],
        "options": {
            "temperature": 0.2,
        },
    }

    request = Request(
        OLLAMA_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urlopen(request, timeout=180) as response:
            raw_response = response.read().decode("utf-8")
    except HTTPError as exc:
        raise RuntimeError(
            f"Ollama returned HTTP {exc.code}."
        ) from exc
    except URLError as exc:
        raise RuntimeError(
            "Cannot reach Ollama. Check that the local server "
            "is running and the configured URL is correct."
        ) from exc
    except TimeoutError as exc:
        raise RuntimeError(
            "The local model request timed out."
        ) from exc

    try:
        envelope = json.loads(raw_response)
    except json.JSONDecodeError as exc:
        raise ModelOutputError(
            "Ollama returned an invalid API response."
        ) from exc

    if not isinstance(envelope, dict):
        raise ModelOutputError(
            "Ollama's API response must be a JSON object."
        )

    message = envelope.get("message")
    if not isinstance(message, dict):
        raise ModelOutputError(
            "Ollama's API response has no valid message object."
        )

    content = message.get("content")
    spec = decode_model_json(content)

    # Preserve the exact prompt after validating the model-generated data.
    spec["raw_prompt"] = prompt
    return spec


def analyze_game_idea_for_mojo(prompt: str) -> dict:
    """Return validated fields in a format compatible with GameSpec."""

    spec = analyze_game_idea(prompt)

    return {
        "raw_prompt": prompt,
        "title": spec["title"],
        "genre": spec["genre"],
        "perspective": spec["perspective"],
        "target_engine": spec["target_engine"],
        "features": ", ".join(spec["features"]),
        "details_json": json.dumps(
            spec,
            ensure_ascii=False,
        ),
    }


if __name__ == "__main__":
    try:
        idea = input("Describe your game: ")
        result = analyze_game_idea(idea)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except (ValueError, RuntimeError) as error:
        print(f"WorldSmith error: {error}")
