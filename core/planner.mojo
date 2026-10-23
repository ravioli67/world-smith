# WorldSmith/core/planner.mojo

from core.context import GameSpec, GamePlan, summarize_spec


def build_design_request(
    spec: GameSpec,
    target_engine: String
) -> String:
    var prompt = """
Design a game from the user's description.

Return one valid JSON object with these top-level fields:

{
  "title": "Game title",
  "engine": "Target engine and version",
  "design_summary": "Short design overview",
  "genre": "Game genre",
  "perspective": "Camera and player perspective",
  "player_goal": "Main player objective",
  "core_loop": "Main gameplay loop",
  "world_description": "Description of the world",
  "mechanics": [
    {
      "id": "stable_identifier",
      "name": "Mechanic name",
      "description": "How it works",
      "dependencies": []
    }
  ],
  "scenes": [
    {
      "id": "stable_identifier",
      "name": "Scene name",
      "purpose": "What this scene does",
      "mechanics": []
    }
  ],
  "assumptions": [],
  "open_questions": []
}

Design rules:
- The user's description is the source of truth.
- Do not add unrelated mechanics just to fill the response.
- Include the systems necessary to make the requested game coherent.
- Represent real dependencies between mechanics.
- Keep identifiers unique and stable.
- Prefer a playable, focused first version over an enormous unfinished game.
- Do not generate project files in this planning stage.
- Return valid JSON only.
"""

    prompt += "\n\nTarget engine: " + target_engine
    prompt += "\n\nOriginal user request:\n" + spec.raw_prompt

    return prompt


def create_plan(
    spec: GameSpec,
    target_engine: String
) -> GamePlan:
    var summary = summarize_spec(spec)

    var stages = """
1. Interpret and validate the game design.
2. Build a dependency graph from the planned mechanics and scenes.
3. Generate project files for each required task.
4. Validate file structure and engine compatibility.
5. Repair failed validation stages within the configured retry limit.
6. Report the generated project and any unresolved issues.
"""

    return GamePlan(summary, stages, target_engine)