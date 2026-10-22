
# WorldSmith/core/planner.mojo
#
# Creates an implementation plan with explicit task dependencies.
#
# This version produces a readable dependency graph.
# Automatic scheduling and execution will be added later.

from core.context import GameSpec, GamePlan, summarize_spec


def contains_keyword(text: String, keyword: String) -> Bool:
    return text.lower().find(keyword) != -1


def build_dependency_plan(spec: GameSpec) -> String:
    var plan = ""

    # T01: Requirements are the root dependency.
    plan += "T01 | Analyze requirements | depends_on: none\n"

    # Design can begin after requirements are understood.
    plan += "T02 | Finalize gameplay design | depends_on: T01\n"

    # Project setup needs the requirements, but not finished mechanics.
    plan += "T03 | Set up engine project | depends_on: T01\n"

    # Controls require a functioning project.
    plan += "T04 | Implement player controls | depends_on: T03\n"

    # Core mechanics require both design and working controls.
    plan += "T05 | Implement core mechanics | depends_on: T02, T04\n"

    # Scene construction needs the design and project foundation.
    plan += "T06 | Implement game scenes | depends_on: T02, T03\n"

    # Feature-specific work can be planned from the requested features.
    var features = spec.features

    if contains_keyword(features, "combat"):
        plan += "T07 | Implement combat | depends_on: T05\n"

    if contains_keyword(features, "inventory"):
        plan += "T08 | Implement inventory | depends_on: T05\n"

    if contains_keyword(features, "dialogue"):
        plan += "T09 | Implement dialogue | depends_on: T05, T06\n"

    if contains_keyword(features, "quest"):
        plan += "T10 | Implement quest progression | depends_on: T05, T06\n"

    # Integrate the completed mechanics and scenes.
    plan += "T11 | Integrate gameplay | depends_on: T05, T06\n"

    # Asset integration depends on the scenes it serves.
    plan += "T12 | Integrate assets and presentation | depends_on: T06\n"

    # Test only after integration and asset references are available.
    plan += "T13 | Validate project | depends_on: T11, T12\n"

    # Repairs depend on validation findings.
    plan += "T14 | Repair detected issues | depends_on: T13\n"

    # The final project depends on successful repair and revalidation.
    plan += "T15 | Prepare playable build | depends_on: T14\n"

    return plan


def create_plan(spec: GameSpec) -> GamePlan:
    var summary = summarize_spec(spec)
    var stages = ""

    stages += "=== GAME DESIGN ===\n"
    stages += "Title: " + spec.title + "\n"
    stages += "Goal: " + spec.player_goal + "\n"
    stages += "Gameplay loop: " + spec.core_loop + "\n"
    stages += "World: " + spec.world_description + "\n\n"

    stages += "=== IMPLEMENTATION ORDER ===\n"
    stages += "1. Analyze requirements and finalize the design.\n"
    stages += "2. Set up the engine project.\n"
    stages += "3. Implement player controls.\n"
    stages += "4. Implement core mechanics.\n"
    stages += "5. Build the scenes.\n"
    stages += "6. Integrate gameplay and assets.\n"
    stages += "7. Validate, repair, and prepare the build.\n\n"

    stages += "=== MECHANIC SPECIFICATIONS ===\n"
    stages += spec.mechanics_json + "\n\n"

    stages += "=== SCENE SPECIFICATIONS ===\n"
    stages += spec.scenes_json + "\n\n"

    stages += "=== DEPENDENCY GRAPH ===\n"
    stages += build_dependency_plan(spec) + "\n"

    stages += "=== ASSUMPTIONS ===\n"
    stages += spec.assumptions_json + "\n\n"

    stages += "=== OPEN QUESTIONS ===\n"
    stages += spec.open_questions_json + "\n"

    return GamePlan(
        summary,
        stages,
        spec.target_engine
    )
