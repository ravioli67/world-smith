
# WorldSmith/ai/task_builder.py

"""Convert a WorldSmith game specification into executable task definitions."""

import json
import re


class TaskBuilderError(ValueError):
    """Raised when a game specification cannot produce a valid task graph."""


def _load_array(raw_json: str, field_name: str) -> list:
    try:
        value = json.loads(raw_json)
    except (json.JSONDecodeError, TypeError) as exc:
        raise TaskBuilderError(
            f"{field_name} must contain valid JSON."
        ) from exc

    if not isinstance(value, list):
        raise TaskBuilderError(f"{field_name} must be a JSON array.")

    return value


def _slug(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "unnamed"


def build_task_graph(
    title: str,
    genre: str,
    core_loop: str,
    player_goal: str,
    target_engine: str,
    mechanics_json: str,
    scenes_json: str,
) -> list[dict]:
    """Build a dependency graph from the AI-generated design."""

    mechanics = _load_array(mechanics_json, "mechanics")
    scenes = _load_array(scenes_json, "scenes")

    if not title.strip():
        raise TaskBuilderError("Game title cannot be empty.")

    if not target_engine.strip():
        raise TaskBuilderError("Target engine cannot be empty.")

    for index, mechanic in enumerate(mechanics):
        if not isinstance(mechanic, dict):
            raise TaskBuilderError(f"Mechanic {index} must be an object.")
        for field in ("name", "description", "player_action"):
            if not isinstance(mechanic.get(field), str) or not mechanic[field].strip():
                raise TaskBuilderError(
                    f"Mechanic {index} requires a non-empty '{field}'."
                )

    for index, scene in enumerate(scenes):
        if not isinstance(scene, dict):
            raise TaskBuilderError(f"Scene {index} must be an object.")
        for field in ("name", "purpose", "objectives"):
            if field not in scene:
                raise TaskBuilderError(
                    f"Scene {index} is missing '{field}'."
                )
        if not isinstance(scene["name"], str) or not scene["name"].strip():
            raise TaskBuilderError(f"Scene {index} has an invalid name.")
        if not isinstance(scene["purpose"], str):
            raise TaskBuilderError(f"Scene {index} has an invalid purpose.")
        if not isinstance(scene["objectives"], list) or not all(
            isinstance(item, str) for item in scene["objectives"]
        ):
            raise TaskBuilderError(
                f"Scene {index} objectives must be a list of strings."
            )

    tasks: list[dict] = []

    def add(task_id: str, name: str, dependencies: list[str] | None = None):
        if any(task["id"] == task_id for task in tasks):
            raise TaskBuilderError(f"Duplicate generated task ID: {task_id}")

        tasks.append({
            "id": task_id,
            "name": name,
            "depends_on": ",".join(dependencies or []),
        })

    # Shared foundation.
    add("T01", f"Analyze requirements for {title}")
    add("T02", f"Finalize {genre} gameplay design", ["T01"])
    add("T03", f"Create {target_engine} project", ["T01"])
    add("T04", "Implement player controls", ["T03"])

    mechanic_ids = []

    for index, mechanic in enumerate(mechanics, start=1):
        task_id = f"M{index:03}"
        mechanic_ids.append(task_id)
        add(
            task_id,
            f"Implement mechanic: {mechanic['name']}",
            ["T02", "T04"],
        )

    scene_ids = []

    for index, scene in enumerate(scenes, start=1):
        task_id = f"S{index:03}"
        scene_ids.append(task_id)

        # Scenes require the project and gameplay design. Mechanics are
        # dependencies too, so scenes won't be integrated before gameplay
        # systems are available.
        dependencies = ["T02", "T03"] + mechanic_ids
        add(
            task_id,
            f"Build scene: {scene['name']}",
            dependencies,
        )

    if not mechanic_ids:
        add("M000", "Implement core gameplay loop", ["T02", "T04"])
        mechanic_ids.append("M000")

    if not scene_ids:
        add("S000", "Create initial playable scene", ["T02", "T03"])

    gameplay_ids = mechanic_ids + scene_ids

    add("T05", "Integrate gameplay systems", gameplay_ids)
    add("T06", "Integrate assets and scene resources", scene_ids or ["T03"])
    add("T07", "Validate generated project", ["T05", "T06"])
    add("T08", "Repair detected issues", ["T07"])
    add("T09", "Prepare playable build", ["T08"])

    return tasks


def build_task_graph_json(*args) -> str:
    """JSON bridge for Mojo's Python interop."""
    return json.dumps(build_task_graph(*args), ensure_ascii=False)
