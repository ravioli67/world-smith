
import json
import unittest

from ai.local_model import (
    ModelOutputError,
    decode_model_json,
    validate_game_spec,
)


def valid_spec():
    return {
        "title": "Moonlit Valley",
        "genre": "adventure",
        "perspective": "top-down 2D",
        "target_engine": "Godot",
        "core_loop": "Explore, gather resources, and solve puzzles.",
        "player_goal": "Restore the valley's ancient lighthouse.",
        "world_description": "A mysterious coastal valley at night.",
        "features": ["Exploration", "Puzzle solving"],
        "mechanics": [
            {
                "name": "Lantern",
                "description": "Reveals hidden markings.",
                "player_action": "Press the lantern key.",
            }
        ],
        "scenes": [
            {
                "name": "Coastal Village",
                "purpose": "Introduce the world and its mystery.",
                "objectives": ["Find the lighthouse key."],
            }
        ],
        "assumptions": ["The game is single-player."],
        "open_questions": ["Should the game include combat?"],
    }


class TestModelOutput(unittest.TestCase):
    def test_valid_design_is_accepted(self):
        spec = valid_spec()
        self.assertEqual(validate_game_spec(spec), spec)

    def test_valid_json_is_decoded(self):
        spec = valid_spec()
        result = decode_model_json(json.dumps(spec))
        self.assertEqual(result["title"], "Moonlit Valley")

    def test_malformed_json_is_rejected(self):
        with self.assertRaises(ModelOutputError):
            decode_model_json('{"title":')

    def test_non_object_json_is_rejected(self):
        with self.assertRaises(ModelOutputError):
            decode_model_json("[]")

    def test_missing_field_is_rejected(self):
        spec = valid_spec()
        del spec["scenes"]

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)

    def test_unexpected_field_is_rejected(self):
        spec = valid_spec()
        spec["made_up_field"] = "unexpected"

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)

    def test_wrong_field_type_is_rejected(self):
        spec = valid_spec()
        spec["title"] = 123

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)

    def test_non_string_feature_is_rejected(self):
        spec = valid_spec()
        spec["features"] = ["Exploration", 42]

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)

    def test_invalid_mechanic_is_rejected(self):
        spec = valid_spec()
        spec["mechanics"][0].pop("player_action")

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)

    def test_invalid_scene_objectives_are_rejected(self):
        spec = valid_spec()
        spec["scenes"][0]["objectives"] = "Find the key"

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)

    def test_empty_required_string_is_rejected(self):
        spec = valid_spec()
        spec["core_loop"] = "   "

        with self.assertRaises(ModelOutputError):
            validate_game_spec(spec)


if __name__ == "__main__":
    unittest.main()
