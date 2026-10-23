
# WorldSmith/tests/test_prompt_generation.py

import tempfile
import unittest
from pathlib import Path

from generation.godot_project import (
    GodotGenerationError,
    write_manifest,
    validate_project_files,
)


class PromptGenerationTests(unittest.TestCase):
    def make_manifest(self, title, script):
        return {
            "title": title,
            "engine": "Godot 4",
            "design_summary": "Test project",
            "files": [
                {
                    "path": "project.godot",
                    "content": (
                        'config_version=5\n\n'
                        '[application]\n'
                        'config/name="' + title + '"\n'
                        'run/main_scene="res://scenes/main.tscn"\n'
                    ),
                },
                {
                    "path": "scenes/main.tscn",
                    "content": (
                        '[gd_scene format=3]\n\n'
                        '[node name="Main" type="Node2D"]\n'
                    ),
                },
                {
                    "path": "scripts/main.gd",
                    "content": script,
                },
            ],
        }

    def test_writes_model_supplied_files(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "game"

            write_manifest(
                self.make_manifest("Puzzle World", "extends Node2D\n"),
                root,
            )

            script = (root / "scripts/main.gd").read_text(
                encoding="utf-8"
            )
            self.assertEqual(script, "extends Node2D\n")
            self.assertTrue((root / "scenes/main.tscn").exists())

    def test_different_games_can_have_different_scripts(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "game"

            manifest = self.make_manifest(
                "Gravity Puzzle",
                "extends Node2D\nvar gravity_reversed = false\n",
            )
            write_manifest(manifest, root)

            script = (root / "scripts/main.gd").read_text(
                encoding="utf-8"
            )
            self.assertIn("gravity_reversed", script)
            self.assertNotIn("YOU WIN! All gems collected!", script)

    def test_rejects_path_traversal(self):
        with tempfile.TemporaryDirectory() as temp:
            manifest = self.make_manifest("Test", "extends Node2D\n")
            manifest["files"].append({
                "path": "../outside.gd",
                "content": "bad",
            })

            with self.assertRaises(GodotGenerationError):
                write_manifest(manifest, Path(temp) / "game")

    def test_rejects_missing_scene(self):
        with tempfile.TemporaryDirectory() as temp:
            manifest = self.make_manifest("Test", "extends Node2D\n")
            manifest["files"] = [
                item for item in manifest["files"]
                if not item["path"].endswith(".tscn")
            ]

            with self.assertRaises(GodotGenerationError):
                write_manifest(manifest, Path(temp) / "game")

    def test_validates_generated_structure(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "game"
            write_manifest(
                self.make_manifest("Test Game", "extends Node2D\n"),
                root,
            )

            messages = validate_project_files(root)
            self.assertTrue(any("Scenes found: 1" in m for m in messages))


if __name__ == "__main__":
    unittest.main()
