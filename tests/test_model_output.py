
"""Offline tests for WorldSmith model-output validation."""

import unittest

from ai.local_model import (
    ModelOutputError,
    decode_model_json,
)


VALID_SPEC = {
    "title": "Alien Outpost",
    "genre": "survival",
    "perspective": "third-person",
    "target_engine": "Godot",
    "core_loop": "Gather resources and defend a base.",
    "features": ["resource gathering", "base building"],
    "player_goal": "Survive on an alien planet.",
    "world_description": "A hostile alien wilderness.",
    "assumptions": ["Single-player"],
    "open_questions": ["Should there be multiplayer later?"],
}


class TestModelOutput(unittest.TestCase):

    def test_valid_json_is_accepted(self):
        import json

        result = decode_model_json(json.dumps(VALID_SPEC))
        self.assertEqual(result["genre"], "survival")

    def test_malformed_json_is_rejected(self):
        with self.assertRaises(ModelOutputError):
            decode_model_json('{"title": "Broken",}')

    def test_non_object_json_is_rejected(self):
        with self.assertRaises(ModelOutputError):
            decode_model_json('["not", "an", "object"]')

    def test_missing_field_is_rejected(self):
        import json

        spec = dict(VALID_SPEC)
        del spec["genre"]

        with self.assertRaises(ModelOutputError):
            decode_model_json(json.dumps(spec))

    def test_wrong_field_type_is_rejected(self):
        import json

        spec = dict(VALID_SPEC)
        spec["features"] = "crafting, combat"

        with self.assertRaises(ModelOutputError):
            decode_model_json(json.dumps(spec))

    def test_non_string_list_item_is_rejected(self):
        import json

        spec = dict(VALID_SPEC)
        spec["features"] = ["crafting", 42]

        with self.assertRaises(ModelOutputError):
            decode_model_json(json.dumps(spec))

    def test_empty_required_string_is_rejected(self):
        import json

        spec = dict(VALID_SPEC)
        spec["title"] = "   "

        with self.assertRaises(ModelOutputError):
            decode_model_json(json.dumps(spec))


if __name__ == "__main__":
    unittest.main()
