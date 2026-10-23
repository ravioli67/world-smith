
# WorldSmith/tests/test_godot_project.py

import tempfile
import unittest
from pathlib import Path

from generation.godot_project import (
    GodotGenerationError,
    generate_godot_project,
    validate_generated_project,
)


class GodotProjectTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.output_dir = Path(self.temp_dir.name) / "CrystalQuest"

    def test_generates_required_files(self):
        generate_godot_project(
            {
                "title": "Crystal Quest",
                "player_goal": "Collect every gem.",
                "world_description": "Explore a mysterious crystal world.",
            },
            self.output_dir,
        )

        for relative in (
            "project.godot",
            "scenes/main.tscn",
            "scripts/main.gd",
            "README.md",
        ):
            with self.subTest(file=relative):
                self.assertTrue((self.output_dir / relative).is_file())

    def test_generates_playable_prototype_logic(self):
        generate_godot_project(
            {
                "title": "Crystal Quest",
                "player_goal": "Collect every gem.",
                "world_description": "A crystal world.",
            },
            self.output_dir,
        )

        script = (self.output_dir / "scripts/main.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn("KEY_W", script)
        self.assertIn("KEY_LEFT", script)
        self.assertIn("score += 1", script)
        self.assertIn("YOU WIN!", script)
        self.assertIn("func _process(delta: float)", script)

    def test_project_references_its_main_scene(self):
        generate_godot_project(
            {
                "title": "Test Game",
                "player_goal": "Reach the exit.",
            },
            self.output_dir,
        )

        config = (self.output_dir / "project.godot").read_text(
            encoding="utf-8"
        )
        scene = (self.output_dir / "scenes/main.tscn").read_text(
            encoding="utf-8"
        )

        self.assertIn("res://scenes/main.tscn", config)
        self.assertIn("res://scripts/main.gd", scene)

    def test_validator_accepts_generated_project(self):
        generate_godot_project(
            {
                "title": "Test Game",
                "player_goal": "Reach the exit.",
            },
            self.output_dir,
        )

        messages = validate_generated_project(self.output_dir)
        self.assertTrue(any("valid" in message.lower() for message in messages))

    def test_rejects_missing_title(self):
        with self.assertRaises(GodotGenerationError):
            generate_godot_project(
                {"player_goal": "Reach the exit."},
                self.output_dir,
            )


if __name__ == "__main__":
    unittest.main()
