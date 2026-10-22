
"""WorldSmith local language-model adapter.

Requires a locally running Ollama server and a model installed there.
This file does not download a model automatically.
"""

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


SYSTEM_PROMPT = """
You are WorldSmith, an AI game-design planning system.

Interpret the user's game idea semantically. Do not merely classify
keywords. Infer reasonable gameplay systems, identify constraints,
and preserve the user's intent.

Return only a JSON object with these fields:
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

Use concise, concrete values.
Keep the user's explicit requirements.
Do not claim that code or assets have already been generated.
If a detail is unclear, make a reasonable assumption or list a
question rather than inventing a user requirement.
"""


def analyze_game_idea(prompt: str) -> dict:
    """Ask the local model to interpret a game description."""

    if not prompt.strip():
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
            result = json.loads(response.read().decode("utf-8"))
    except HTTPError as exc:
        raise RuntimeError(
            f"Ollama returned HTTP {exc.code}."
        ) from exc
    except URLError as exc:
        raise RuntimeError(
            "Cannot reach the local Ollama server. "
            "Check that Ollama is installed and running."
        ) from exc
    except TimeoutError as exc:
        raise RuntimeError(
            "The local model request timed out."
        ) from exc

    content = result.get("message", {}).get("content", "")
    if not content:
        raise RuntimeError("The local model returned an empty response.")

    try:
        spec = json.loads(content)
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            "The model did not return valid JSON."
        ) from exc

    required_fields = (
        "title",
        "genre",
        "perspective",
        "target_engine",
        "core_loop",
        "features",
        "player_goal",
        "world_description",
        "assumptions",
        "open_questions",
    )

    missing = [key for key in required_fields if key not in spec]
    if missing:
        raise RuntimeError(
            "The model response is missing fields: "
            + ", ".join(missing)
        )

    if not isinstance(spec["features"], list):
        raise RuntimeError("'features' must be a JSON array.")

    if not isinstance(spec["assumptions"], list):
        raise RuntimeError("'assumptions' must be a JSON array.")

    if not isinstance(spec["open_questions"], list):
        raise RuntimeError("'open_questions' must be a JSON array.")

    # Keep the exact original prompt available for later stages.
    spec["raw_prompt"] = prompt
    return spec


if __name__ == "__main__":
    idea = input("Describe your game: ")

    try:
        result = analyze_game_idea(idea)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except (ValueError, RuntimeError) as error:
        print(f"WorldSmith error: {error}")


def analyze_game_idea_for_mojo(prompt: str) -> dict:
    """Return a Mojo-friendly version of the AI result."""

    spec = analyze_game_idea(prompt)

    return {
        "raw_prompt": prompt,
        "title": str(spec["title"]),
        "genre": str(spec["genre"]),
        "perspective": str(spec["perspective"]),
        "target_engine": str(spec["target_engine"]),
        "features": ", ".join(str(item) for item in spec["features"]),
        "details_json": json.dumps(
            spec,
            ensure_ascii=False,
        ),
    }
