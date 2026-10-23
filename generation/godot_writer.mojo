
# WorldSmith/generation/godot_writer.mojo
#
# Mojo-to-Python bridge for writing Godot projects.

from std.python import Python
from core.context import GameSpec


def write_godot_project(
    spec: GameSpec,
    output_dir: String,
) raises -> String:
    Python.add_to_path("generation")
    var generator = Python.import_module("godot_project")

    var result = generator.generate_godot_project_from_fields(
        spec.title,
        spec.player_goal,
        spec.world_description,
        output_dir,
    )

    return String(py=result)
