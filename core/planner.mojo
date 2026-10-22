
# WorldSmith/core/planner.mojo
#
# Converts an AI-generated game design into an implementation plan.

from core.context import GameSpec, GamePlan, summarize_spec


def create_plan(spec: GameSpec) -> GamePlan:
    var summary = summarize_spec(spec)
    var stages = ""

    stages += "1. REQUIREMENTS AND DESIGN\n"
    stages += "   Genre: " + spec.genre + "\n"
    stages += "   Perspective: " + spec.perspective + "\n"
    stages += "   Engine: " + spec.target_engine + "\n\n"

    stages += "2. GAMEPLAY DESIGN\n"
    stages += "   Player goal: " + spec.player_goal + "\n"
    stages += "   Core gameplay loop: " + spec.core_loop + "\n\n"

    stages += "3. WORLD DESIGN\n"
    stages += "   " + spec.world_description + "\n\n"

    stages += "4. PROJECT FOUNDATION\n"
    stages += "   Create the " + spec.target_engine + " project.\n"
    stages += "   Establish project configuration and entry point.\n"
    stages += "   Set up the main scene and input handling.\n\n"

    stages += "5. MECHANIC IMPLEMENTATION\n"
    stages += "   Requested features: " + spec.features + "\n"
    stages += "   Mechanic specifications (JSON):\n"
    stages += spec.mechanics_json + "\n\n"

    stages += "6. SCENE IMPLEMENTATION\n"
    stages += "   Scene specifications and objectives (JSON):\n"
    stages += spec.scenes_json + "\n\n"

    stages += "7. GAMEPLAY INTEGRATION\n"
    stages += "   Connect player controls, mechanics, and scenes.\n"
    stages += "   Implement state transitions and progression.\n\n"

    stages += "8. ASSETS AND PRESENTATION\n"
    stages += "   Generate or source appropriate visual and audio assets.\n"
    stages += "   Integrate interface elements and resource references.\n\n"

    stages += "9. VALIDATION AND REPAIR\n"
    stages += "   Check generated files and project configuration.\n"
    stages += "   Run syntax checks and gameplay tests.\n"
    stages += "   Repair detected problems and retest.\n\n"

    stages += "10. FINAL BUILD PREPARATION\n"
    stages += "   Verify launch instructions and required resources.\n"
    stages += "   Prepare the project for local execution.\n\n"

    stages += "DESIGN ASSUMPTIONS\n"
    stages += spec.assumptions_json + "\n\n"

    stages += "OPEN DESIGN QUESTIONS\n"
    stages += spec.open_questions_json + "\n"

    return GamePlan(
        summary,
        stages,
        spec.target_engine
    )
