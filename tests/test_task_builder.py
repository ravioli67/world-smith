
# WorldSmith/tests/test_task_builder.py

import json
import unittest

from ai.task_builder import build_task_graph, TaskBuilderError


def make_graph(mechanics, scenes):
    return build_task_graph(
        title="Crystal Quest",
        genre="adventure",
        core_loop="Explore, solve puzzles, collect crystals.",
        player_goal="Collect all crystals.",
        target_engine="Godot",
        mechanics_json=json.dumps(mechanics),
        scenes_json=json.dumps(scenes),
    )


class TaskBuilderTests(unittest.TestCase):
    def test_creates_foundation_and_build_tasks(self):
        tasks = make_graph([], [])
        ids = {task["id"] for task in tasks}

        self.assertIn("T01", ids)
        self.assertIn("T03", ids)
        self.assertIn("T09", ids)
        self.assertIn("M000", ids)
        self.assertIn("S000", ids)

    def test_creates_one_task_per_mechanic(self):
        mechanics = [
            {
                "name": "Dash",
                "description": "Move quickly for a short time.",
                "player_action": "Press the dash button.",
            },
            {
                "name": "Double Jump",
                "description": "Jump again in midair.",
                "player_action": "Press jump while airborne.",
            },
        ]

        tasks = make_graph(mechanics, [])
        names = [task["name"] for task in tasks]

        self.assertIn("Implement mechanic: Dash", names)
        self.assertIn("Implement mechanic: Double Jump", names)

    def test_creates_one_task_per_scene(self):
        scenes = [
            {
                "name": "Forest",
                "purpose": "Introduce exploration.",
                "objectives": ["Find the key"],
            },
            {
                "name": "Castle",
                "purpose": "Test the player's skills.",
                "objectives": ["Reach the tower"],
            },
        ]

        tasks = make_graph([], scenes)
        names = [task["name"] for task in tasks]

        self.assertIn("Build scene: Forest", names)
        self.assertIn("Build scene: Castle", names)

    def test_scene_waits_for_mechanics(self):
        mechanics = [
            {
                "name": "Dash",
                "description": "Move quickly.",
                "player_action": "Press dash.",
            }
        ]
        scenes = [
            {
                "name": "Forest",
                "purpose": "Explore.",
                "objectives": ["Reach the exit"],
            }
        ]

        tasks = make_graph(mechanics, scenes)
        scene = next(task for task in tasks if task["id"] == "S001")

        self.assertIn("M001", scene["depends_on"].split(","))

    def test_rejects_malformed_json(self):
        with self.assertRaises(TaskBuilderError):
            build_task_graph(
                "Game", "adventure", "Explore", "Win", "Godot", "{", "[]"
            )

    def test_rejects_invalid_mechanic(self):
        with self.assertRaises(TaskBuilderError):
            make_graph([{"name": "Dash"}], [])

    def test_rejects_invalid_scene_objectives(self):
        with self.assertRaises(TaskBuilderError):
            make_graph(
                [],
                [{
                    "name": "Forest",
                    "purpose": "Explore",
                    "objectives": "This should be a list",
                }],
            )


if __name__ == "__main__":
    unittest.main()
