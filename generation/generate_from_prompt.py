
# WorldSmith/generation/generate_from_prompt.py

"""End-to-end prompt-to-Godot-project entry point."""

from pathlib import Path

from ai.game_generator import generate_game_manifest
from generation.godot_project import (
    write_manifest,
    validate_project_files,
)


def generate_from_prompt(
    prompt: str,
    output_dir: str | Path,
) -> dict:
    manifest = generate_game_manifest(prompt)

    project_path = write_manifest(manifest, output_dir)
    validation = validate_project_files(project_path)

    return {
        "title": manifest["title"],
        "engine": manifest["engine"],
        "project_path": str(project_path),
        "design_summary": manifest.get("design_summary", ""),
        "prompt_token_count": manifest["prompt_token_count"],
        "validation": validation,
    }


if __name__ == "__main__":
    request = input("Describe the game you want WorldSmith to create: ").strip()

    if not request:
        raise SystemExit("No game prompt supplied.")

    result = generate_from_prompt(request, "output/generated_game")

    print(f"\nGenerated: {result['title']}")
    print(f"Project: {result['project_path']}")
    print(f"Prompt tokens: {result['prompt_token_count']}")

    for message in result["validation"]:
        print(f"- {message}")
