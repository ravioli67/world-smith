
# WorldSmith/core/dynamic_task_graph.mojo

from std.python import Python
from core.context import GameSpec
from core.task_graph import (
    TaskGraph,
    topological_sort,
    validate_graph,
)


def build_dynamic_graph(spec: GameSpec) raises -> TaskGraph:
    Python.add_to_path("ai")

    var builder = Python.import_module("task_builder")

    var tasks_json = builder.build_task_graph_json(
        spec.title,
        spec.genre,
        spec.core_loop,
        spec.player_goal,
        spec.target_engine,
        spec.mechanics_json,
        spec.scenes_json,
    )

    var json_module = Python.import_module("json")
    var tasks = json_module.loads(tasks_json)

    var graph = TaskGraph()

    for item in tasks:
        var task_id = String(py=item["id"])
        var task_name = String(py=item["name"])
        var dependencies = String(py=item["depends_on"])

        graph.add_task(task_id, task_name, dependencies)

    return graph


def describe_dynamic_graph(spec: GameSpec) raises -> String:
    var graph = build_dynamic_graph(spec)

    var output = "=== GENERATED TASK GRAPH ===\n"
    output += graph.describe()
    output += "\n=== GRAPH VALIDATION ===\n"
    output += validate_graph(graph)
    output += "\n\n"
    output += topological_sort(graph)

    return output
