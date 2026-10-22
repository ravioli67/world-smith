from core.context import GameSpec
from core.planner import GamePlan
from python import Python


def write_manifest(spec: GameSpec, plan: GamePlan) -> String:
    """Write a JSON manifest through Python's standard library."""
    var json = Python.import_module("json")
    var pathlib = Python.import_module("pathlib")
    var os = Python.import_module("os")

    var output_root = pathlib.Path("output")
    output_root.mkdir(parents=True, exist_ok=True)
    var project_dir = output_root / "generated_game"
    project_dir.mkdir(parents=True, exist_ok=True)

    var data = json.loads("{}")
    data["project_name"] = "WorldSmith Generated Game"
    data["engine"] = plan.engine
    data["prompt"] = spec.raw_prompt
    data["genre"] = spec.genre
    data["perspective"] = spec.perspective
    data["features"] = spec.features
    data["plan"] = plan.summary
    data["status"] = "planning-prototype"

    var manifest_path = project_dir / "project.json"
    var file_handle = builtins_open(manifest_path)
    file_handle.write(json.dumps(data, indent=2))
    file_handle.close()
    return "Wrote " + String(manifest_path)


def builtins_open(path) :
    var builtins = Python.import_module("builtins")
    return builtins.open(path, "w")
