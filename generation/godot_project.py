
# WorldSmith/generation/godot_project.py

"""Write model-generated Godot project files safely."""

from pathlib import Path
from typing import Any


class GodotGenerationError(ValueError):
    pass


def write_manifest(
    manifest: dict[str, Any],
    output_dir: str | Path,
) -> Path:
    if not isinstance(manifest, dict):
        raise GodotGenerationError("Manifest must be a dictionary.")

    files = manifest.get("files")
    if not isinstance(files, list) or not files:
        raise GodotGenerationError("Manifest has no generated files.")

    root = Path(output_dir).expanduser().resolve()
    prepared: list[tuple[str, str]] = []
    seen: set[str] = set()

    # Validate the entire file list before writing anything.
    for item in files:
        if not isinstance(item, dict):
            raise GodotGenerationError("Invalid file entry.")

        relative = item.get("path")
        content = item.get("content")

        if not isinstance(relative, str) or not isinstance(content, str):
            raise GodotGenerationError("Each file needs a path and text content.")

        relative = relative.replace("\\", "/")
        parts = relative.split("/")

        if (
            relative.startswith("/")
            or ":" in relative
            or any(part in ("", ".", "..") for part in parts)
        ):
            raise GodotGenerationError(f"Unsafe relative path: {relative!r}")

        if relative in seen:
            raise GodotGenerationError(f"Duplicate path: {relative!r}")

        if not (
            relative == "project.godot"
            or relative.endswith((
                ".gd", ".tscn", ".tres", ".godot", ".cfg",
                ".json", ".md", ".txt", ".shader",
            ))
        ):
            raise GodotGenerationError(
                f"Unsupported generated file type: {relative!r}"
            )

        seen.add(relative)
        prepared.append((relative, content))

    if "project.godot" not in seen:
        raise GodotGenerationError("Missing project.godot.")

    if not any(path.endswith(".tscn") for path, _ in prepared):
        raise GodotGenerationError("Missing Godot scene (.tscn).")

    # Prevent generated paths from escaping the project root.
    for relative, content in prepared:
        destination = (root / relative).resolve()

        if not destination.is_relative_to(root):
            raise GodotGenerationError(
                f"Generated path escapes project directory: {relative!r}"
            )

    for relative, content in prepared:
        destination = root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(content, encoding="utf-8")

    return root


def validate_project_files(project_dir: str | Path) -> list[str]:
    root = Path(project_dir).resolve()
    config = root / "project.godot"

    if not config.is_file():
        raise GodotGenerationError("project.godot is missing.")

    scene_paths = list(root.rglob("*.tscn"))
    script_paths = list(root.rglob("*.gd"))

    if not scene_paths:
        raise GodotGenerationError("No Godot scene files were generated.")

    config_text = config.read_text(encoding="utf-8")

    if "run/main_scene=" not in config_text:
        raise GodotGenerationError(
            "project.godot does not declare run/main_scene."
        )

    return [
        f"Project files found: {sum(1 for p in root.rglob('*') if p.is_file())}",
        f"Scenes found: {len(scene_paths)}",
        f"GDScript files found: {len(script_paths)}",
        "Basic structural validation passed; Godot compilation is not yet verified.",
    ]
