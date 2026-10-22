
"""WorldSmith local AI adapter.

Uses a local Ollama model to transform natural-language game ideas
into structured game designs.
"""

import json
import os
import socket
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

REQUIRED_FIELDS = set(REQUIRED_STRINGS + REQUIRED_LISTS) | {
    "mechanics",
    "scenes",
}

MECHANIC_FIELDS = {"name", "description", "player_action"}
SCENE_FIELDS = {"name", "purpose", "objectives"}


SYSTEM_PROMPT = """
You are WorldSmith, an intelligent AI game-design system.

Your task is to understand the meaning and intent of a user's game idea
and transform it into a coherent, detailed game design.

Think through the game's intended experience, gameplay loop, mechanics,
scenes, player objectives, and dependencies before producing the result.

Preserve explicit user requirements. Do not silently replace them with
different mechanics or genres. When details are missing, make reasonable
assumptions and record them in the assumptions list.

Return exactly one JSON object with this structure:

{
  "title": "Game title",
  "genre": "Main genre",
  "perspective": "2D, 3D, first-person, third-person, or top-down",
  "target_engine": "Godot",
  "core_loop": "The main repeated gameplay activity",
  "player_goal": "The player's primary objective",
  "world_description": "Setting, atmosphere, and world rules",
  "features": [
    "Major game feature"
  ],
  "mechanics": [
    {
      "name": "Mechanic name",
      "description": "How the mechanic works",
      "player_action": "What the player does to use it"
    }
  ],
  "scenes": [
    {
      "name": "Scene name",
      "purpose": "What this scene is for",
      "objectives": [
        "An objective or event in this scene"
      ]
    }
  ],
  "assumptions": [
    "A reasonable design assumption"
  ],
  "open_questions": [
    "An important unresolved design question"
  ]
}

Requirements:
- Every required field must be present.
- All string fields must contain strings.
- All list fields must contain lists of the specified types.
- Each mechanic must contain name, description, and player_action.
- Each scene must contain name, purpose, and objectives.
- Make the design specific to the user's actual idea.
- Keep the scope internally consistent and reasonably achievable.
- Include enough detail to guide a later code-generation system.
- Do not claim that code, assets, or playable builds already exist.
- Do not include Markdown fences or text outside the JSON object.
"""


class ModelOutputError(RuntimeError):
    """Raised when the model produces an invalid game design."""


def _require_nonempty_string(value, field):
    if not isinstance(value, str):
        raise ModelOutputError(
            f"Field '{field}' must be a string."
        )

    if not value.strip():
        raise ModelOutputError(
            f"Field '{field}' cannot be empty."
        )

    if len(value) > 10_000:
        raise ModelOutputError(
            f"Field '{field}' is too long."
        )


def _validate_string_list(value, field):
    if not isinstance(value, list):
        raise ModelOutputError(
            f"Field '{field}' must be a list of strings."
        )

    if len(value) > 100:
        raise ModelOutputError(
            f"Field '{field}' contains too many items."
        )

    for index, item in enumerate(value):
        if not isinstance(item, str):
            raise ModelOutputError(
                f"Item {index} in '{field}' must be a string."
            )

        if len(item) > 2_000:
            raise ModelOutputError(
                f"Item {index} in '{field}' is too long."
            )


def _validate_object_list(value, field, required_fields):
    if not isinstance(value, list):
        raise ModelOutputError(
            f"Field '{field}' must be a list."
        )

    if len(value) > 100:
        raise ModelOutputError(
            f"Field '{field}' contains too many items."
        )

    for index, item in enumerate(value):
        if not isinstance(item, dict):
            raise ModelOutputError(
                f"Item {index} in '{field}' must be an object."
            )

        missing = required_fields - set(item)
        unexpected = set(item) - required_fields

        if missing:
            raise ModelOutputError(
                f"Item {index} in '{field}' is missing: "
                + ", ".join(sorted(missing))
            )

        if unexpected:
            raise ModelOutputError(
                f"Item {index} in '{field}' has unexpected fields: "
                + ", ".join(sorted(unexpected))
            )

        for key in required_fields:
            _require_nonempty_string(
                item[key],
                f"{field}[{index}].{key}",
            )


def validate_game_spec(spec):
    """Validate the complete game-design structure."""

    if not isinstance(spec, dict):
        raise ModelOutputError(
            "The model response must be a JSON object."
        )

    missing = REQUIRED_FIELDS - set(spec)
    unexpected = set(spec) - REQUIRED_FIELDS

    if missing:
        raise ModelOutputError(
            "Missing required fields: "
            + ", ".join(sorted(missing))
        )

    if unexpected:
        raise ModelOutputError(
            "Unexpected fields: "
            + ", ".join(sorted(unexpected))
        )

    for field in REQUIRED_STRINGS:
        _require_nonempty_string(spec[field], field)

    for field in REQUIRED_LISTS:
        _validate_string_list(spec[field], field)

    _validate_object_list(
        spec["mechanics"],
        "mechanics",
        MECHANIC_FIELDS,
    )

    for index, scene in enumerate(spec["scenes"]):
        if not isinstance(scene, dict):
            raise ModelOutputError(
                f"Scene {index} must be an object."
            )

        missing = SCENE_FIELDS - set(scene)
        unexpected = set(scene) - SCENE_FIELDS

        if missing:
            raise ModelOutputError(
                f"Scene {index} is missing: "
                + ", ".join(sorted(missing))
            )

        if unexpected:
            raise ModelOutputError(
                f"Scene {index} has unexpected fields: "
                + ", ".join(sorted(unexpected))
            )

        _require_nonempty_string(
            scene["name"], f"scenes[{index}].name"
        )
        _require_nonempty_string(
            scene["purpose"], f"scenes[{index}].purpose"
        )
        _validate_string_list(
            scene["objectives"],
            f"scenes[{index}].objectives",
        )

    return spec


def decode_model_json(content):
    """Decode and validate the model's JSON output."""

    if not isinstance(content, str) or not content.strip():
        raise ModelOutputError(
            "The model returned an empty response."
        )

    try:
        decoded = json.loads(content)
    except json.JSONDecodeError as exc:
        raise ModelOutputError(
            "The model returned malformed JSON "
            f"(line {exc.lineno}, column {exc.colno}): {exc.msg}"
        ) from exc

    return validate_game_spec(decoded)

def analyze_game_idea_for_mojo(prompt):
    """Return the complete game design for the Mojo application."""

    result = analyze_game_idea(prompt)

    game_spec = {
        key: value
        for key, value in result.items()
        if key != "raw_prompt"
    }

    return {
        "raw_prompt": result["raw_prompt"],
        "title": result["title"],
        "genre": result["genre"],
        "perspective": result["perspective"],
        "target_engine": result["target_engine"],
        "features": ", ".join(result["features"]),

        # Detailed fields passed into Mojo.
        "core_loop": result["core_loop"],
        "player_goal": result["player_goal"],
        "world_description": result["world_description"],
        "mechanics_json": json.dumps(
            result["mechanics"],
            ensure_ascii=False,
        ),
        "scenes_json": json.dumps(
            result["scenes"],
            ensure_ascii=False,
        ),
        "assumptions_json": json.dumps(
            result["assumptions"],
            ensure_ascii=False,
        ),
        "open_questions_json": json.dumps(
            result["open_questions"],
            ensure_ascii=False,
        ),

        # Preserve the complete design for debugging and later stages.
        "details_json": json.dumps(
            game_spec,
            ensure_ascii=False,
            indent=2,
        ),
    }


def analyze_game_idea_for_mojo(prompt):
    """Return the fields currently consumed by the Mojo bridge."""

    result = analyze_game_idea(prompt)

    game_spec = {
        key: value
        for key, value in result.items()
        if key != "raw_prompt"
    }

    return {
        "raw_prompt": result["raw_prompt"],
        "title": result["title"],
        "genre": result["genre"],
        "perspective": result["perspective"],
        "target_engine": result["target_engine"],
        "features": ", ".join(result["features"]),
        "details_json": json.dumps(
            game_spec,
            ensure_ascii=False,
            indent=2,
        ),
    }


if __name__ == "__main__":
    try:
        idea = input("Describe your game: ")
        result = analyze_game_idea(idea)

        print(json.dumps(
            result,
            indent=2,
            ensure_ascii=False,
        ))

    except (ValueError, RuntimeError) as error:
        print(f"WorldSmith error: {error}")
