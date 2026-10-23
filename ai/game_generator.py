
# WorldSmith/ai/game_generator.py

"""Prompt-driven Godot project generation through local Ollama."""

import json
import os
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from ai.tokenizer import inspect_prompt


OLLAMA_URL = os.getenv(
    "WORLDSMITH_OLLAMA_URL",
    "http://127.0.0.1:11434/api/chat",
)
MODEL_NAME = os.getenv("WORLDSMITH_MODEL", "qwen2.5:3b")


class GameGenerationError(RuntimeError):
    pass


SYSTEM_PROMPT = r"""
You are WorldSmith, an AI game-project generator.

Generate a Godot 4 project tailored to the user's exact game idea.
Do not reuse a fixed example game or assume that every game needs the
same mechanics, scenes, controls, characters, or win condition.

Reason about the requested genre, perspective, gameplay loop, mechanics,
scenes, UI, and win/lose conditions. Generate coherent, mutually compatible
project files. Use GDScript and valid Godot 4 text resource formats.

Return ONLY a JSON object with this structure:
{
  "title": "Game title",
  "engine": "Godot 4",
  "files": [
    {
      "path": "project.godot",
      "content": "complete file contents"
    }
  ],
  "design_summary": "Brief summary of the generated design"
}

Requirements:
- Include project.godot and a runnable main scene.
- Include every text file needed by the project you generate.
- Ensure scene references, script paths, node names, and resource references
  agree across files.
- Generate complete file contents, not pseudocode, TODOs, or placeholders.
- Do not claim to create binary assets. Prefer built-in shapes, materials,
  and generated procedural visuals when assets are unavailable.
- Keep the project appropriately scoped to the user's request.
- Do not add unrelated mechanics simply because they are common in games.
- Never include markdown fences around the JSON.
"""


def _decode_manifest(content: str) -> dict:
    try:
        result = json.loads(content)
    except json.JSONDecodeError as exc:
        raise GameGenerationError(
            f"The model did not return valid JSON: {exc}"
        ) from exc

    if not isinstance(result, dict):
        raise GameGenerationError("The model response must be a JSON object.")

    if not isinstance(result.get("title"), str) or not result["title"].strip():
        raise GameGenerationError("The model response needs a title.")

    if result.get("engine") != "Godot 4":
        raise GameGenerationError("The generated engine must be Godot 4.")

    files = result.get("files")
    if not isinstance(files, list) or not files:
        raise GameGenerationError("The model must return a non-empty files list.")

    seen = set()

    for item in files:
        if not isinstance(item, dict):
            raise GameGenerationError("Each file entry must be an object.")

        path = item.get("path")
        file_content = item.get("content")

        if not isinstance(path, str) or not path.strip():
            raise GameGenerationError("Every generated file needs a path.")

        if not isinstance(file_content, str):
            raise GameGenerationError(f"File {path!r} needs text content.")

        normalized = path.replace("\\", "/")

        if normalized.startswith("/") or ":" in normalized:
            raise GameGenerationError(f"Unsafe file path: {path!r}")

        parts = normalized.split("/")
        if any(part in ("", ".", "..") for part in parts):
            raise GameGenerationError(f"Unsafe file path: {path!r}")

        if normalized in seen:
            raise GameGenerationError(f"Duplicate generated path: {path!r}")

        if not (
            normalized == "project.godot"
            or normalized.endswith((
                ".gd", ".tscn", ".tres", ".godot", ".cfg",
                ".json", ".md", ".txt", ".shader",
            ))
        ):
            raise GameGenerationError(
                f"Unsupported generated text file type: {path!r}"
            )

        seen.add(normalized)
        item["path"] = normalized

    if "project.godot" not in seen:
        raise GameGenerationError("Generated project is missing project.godot.")

    if not any(path.endswith(".tscn") for path in seen):
        raise GameGenerationError("Generated project needs at least one .tscn scene.")

    return result


def generate_game_manifest(user_prompt: str) -> dict:
    """Tokenize the request, ask the local model, and validate its manifest."""

    if not isinstance(user_prompt, str) or not user_prompt.strip():
        raise GameGenerationError("Please describe the game you want to create.")

    prompt_info = inspect_prompt(user_prompt)

    request_body = {
        "model": MODEL_NAME,
        "stream": False,
        "format": "json",
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "user",
                "content": (
                    f"User game request:\n{user_prompt.strip()}\n\n"
                    f"Tokenizer estimate: {prompt_info['token_count']} tokens. "
                    "Generate the complete project manifest now."
                ),
            },
        ],
        "options": {
            "temperature": 0.3,
        },
    }

    request = Request(
        OLLAMA_URL,
        data=json.dumps(request_body).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urlopen(request, timeout=600) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except HTTPError as exc:
        raise GameGenerationError(
            f"Ollama returned HTTP {exc.code}. Check the model and API."
        ) from exc
    except (URLError, TimeoutError, OSError) as exc:
        raise GameGenerationError(
            "Could not reach Ollama. Ensure it is running on the local machine "
            "and the configured model is available."
        ) from exc
    except json.JSONDecodeError as exc:
        raise GameGenerationError("Ollama returned an invalid response.") from exc

    message = payload.get("message", {})
    content = message.get("content", "")

    if not isinstance(content, str) or not content.strip():
        raise GameGenerationError("The model returned an empty response.")

    manifest = _decode_manifest(content)
    manifest["prompt_token_count"] = prompt_info["token_count"]

    return manifest
