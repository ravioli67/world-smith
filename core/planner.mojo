
# WorldSmith/core/planner.mojo
#
# Converts the interpreted game specification into an
# ordered implementation plan.
#
# This planner currently uses the fields available in GameSpec.
# Detailed mechanics and scenes will be connected in a later step.

from core.context import GameSpec, GamePlan, summarize_spec


def contains_keyword(text: String, keyword: String) -> Bool:
    return text.lower().find(keyword) != -1


def create_plan(spec: GameSpec) -> GamePlan:
    var summary = summarize_spec(spec)

    var stages = ""
    var step = 1

    # Stage 1: establish the project requirements.
    stages += String(step) + ". Analyze game requirements\n"
    stages += "   - Confirm the genre and player perspective\n"
    stages += "   - Identify the requested engine and features\n"
    step += 1

    # Stage 2: design the gameplay.
    stages += String(step) + ". Design the gameplay loop\n"
    stages += "   - Define the player's repeated actions\n"
    stages += "   - Establish the main objective and progression\n"
    step += 1

    # Stage 3: establish the game world.
    stages += String(step) + ". Design the game world\n"
    stages += "   - Define the world and scene structure\n"
    stages += "   - Identify the starting scene and transitions\n"
    step += 1

    # Stage 4: establish the technical foundation.
    stages += String(step) + ". Set up the " + spec.target_engine + " project\n"
    stages += "   - Create the project configuration\n"
    stages += "   - Establish the main entry point\n"
    step += 1

    # Stage 5: implement perspective-specific controls.
    stages += String(step) + ". Implement player controls\n"

    if contains_keyword(spec.perspective, "2d"):
        stages += "   - Implement two-dimensional movement\n"
        stages += "   - Configure collision and movement boundaries\n"
    elif contains_keyword(spec.perspective, "first-person"):
        stages += "   - Implement first-person movement and camera control\n"
        stages += "   - Configure interaction and collision\n"
    elif contains_keyword(spec.perspective, "top-down"):
        stages += "   - Implement top-down movement and navigation\n"
        stages += "   - Configure collision and interaction\n"
    else:
        stages += "   - Implement movement appropriate to the perspective\n"
        stages += "   - Configure the camera and collision system\n"

    step += 1

    # Stage 6: build requested features.
    stages += String(step) + ". Implement requested game features\n"

    var features = spec.features.lower()

    if contains_keyword(features, "combat") or contains_keyword(features, "weapon"):
        stages += "   - Implement combat and attack behavior\n"

    if contains_keyword(features, "inventory") or contains_keyword(features, "item"):
        stages += "   - Implement item storage and item interactions\n"

    if contains_keyword(features, "enemy") or contains_keyword(features, "ai"):
        stages += "   - Implement enemy behavior and decision logic\n"

    if contains_keyword(features, "dialogue") or contains_keyword(features, "npc"):
        stages += "   - Implement character interactions and dialogue\n"

    if contains_keyword(features, "quest") or contains_keyword(features, "mission"):
        stages += "   - Implement objectives and quest progression\n"

    if contains_keyword(features, "multiplayer"):
        stages += "   - Design multiplayer architecture and synchronization\n"

    stages += "   - Implement remaining features from the game specification\n"
    step += 1

    # Stage 7: connect scenes and progression.
    stages += String(step) + ". Connect scenes and game progression\n"
    stages += "   - Connect scene transitions\n"
    stages += "   - Track game state and player progress\n"
    step += 1

    # Stage 8: assets and presentation.
    stages += String(step) + ". Integrate game assets and presentation\n"
    stages += "   - Add appropriate visuals, audio, and interface elements\n"
    stages += "   - Verify asset references and resource loading\n"
    step += 1

    # Stage 9: validate the result.
    stages += String(step) + ". Validate the generated project\n"
    stages += "   - Check generated files and project structure\n"
    stages += "   - Check syntax and engine compatibility\n"
    stages += "   - Test core gameplay and important transitions\n"
    step += 1

    # Stage 10: repair and package.
    stages += String(step) + ". Repair issues and prepare the playable build\n"
    stages += "   - Fix detected generation and validation errors\n"
    stages += "   - Confirm launch instructions and required assets\n"

    return GamePlan(
        summary,
        stages,
        spec.target_engine
    )
