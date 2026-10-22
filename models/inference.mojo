
# WorldSmith/models/inference.mojo

from std.python import Python

from core.context import GameSpec
from models.model import ModelResult


def analyze_with_local_model(prompt: String) raises -> ModelResult:
    """Interpret a game idea using the locally running AI model."""

    # Make the ai/ directory visible to Python.
    Python.add_to_path("ai")

    # Import our local model adapter.
    var adapter = Python.import_module("local_model")

    # Call the AI and receive a Python dictionary.
    var result = adapter.analyze_game_idea_for_mojo(prompt)

    # Convert the adapter response into our existing GameSpec.
    var spec = GameSpec()

    spec.raw_prompt = String(py=result["raw_prompt"])
    spec.title = String(py=result["title"])
    spec.genre = String(py=result["genre"])
    spec.perspective = String(py=result["perspective"])
    spec.target_engine = String(py=result["target_engine"])
    spec.features = String(py=result["features"])

    var details = String(py=result["details_json"])

    return ModelResult(spec, details)
