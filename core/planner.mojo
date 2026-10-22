
# WorldSmith/core/planner.mojo

from core.context import GameSpec, GamePlan, summarize_spec


def create_plan(spec: GameSpec) -> GamePlan:
    var summary = summarize_spec(spec)

    var stages = "1. Analyze game requirements\n"
    stages += "2. Design the gameplay loop\n"
    stages += "3. Create the initial game scene\n"
    stages += "4. Implement player controls\n"
    stages += "5. Implement requested mechanics\n"
    stages += "6. Add game assets\n"
    stages += "7. Validate the generated project\n"
    stages += "8. Prepare the playable build\n"

    return GamePlan(
        summary,
        stages,
        spec.target_engine
    )
