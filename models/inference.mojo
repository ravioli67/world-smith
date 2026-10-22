
# WorldSmith/models/inference.mojo
#
# Connects the Mojo core to the local Python AI adapter.

from std.python import Python

from core.context import GameSpec
from models.model import ModelResult


def analyze_with_local_model(prompt: String) raises -> ModelResult:
    Python.add_to_path("ai")
    var adapter = Python.import_module("local_model")
    var result = adapter.analyze_game_idea_for_mojo(prompt)

    var spec = GameSpec()

    spec.raw_prompt = String(py=result["raw_prompt"])
    spec.title = String(py=result["title"])
    spec.genre = String(py=result["genre"])
    spec.perspective = String(py=result["perspective"])
    spec.target_engine = String(py=result["target_engine"])
    spec.features = String(py=result["features"])

    spec.core_loop = String(py=result["core_loop"])
    spec.player_goal = String(py=result["player_goal"])
    spec.world_description = String(py=result["world_description"])

    spec.mechanics_json = String(py=result["mechanics_json"])
    spec.scenes_json = String(py=result["scenes_json"])
    spec.assumptions_json = String(py=result["assumptions_json"])
    spec.open_questions_json = String(py=result["open_questions_json"])

    var details = String(py=result["details_json"])

    return ModelResult(spec, details)
