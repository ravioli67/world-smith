
# WorldSmith/core/planner.mojo

def create_plan(concept: String) -> String:
    """Create an initial plan for a generated game."""

    var plan = "WORLD SMITH GAME PLAN\n"
    plan = plan + "=====================\n"
    plan = plan + concept + "\n\n"

    plan = plan + "Generation stages:\n"
    plan = plan + "1. Define the game genre\n"
    plan = plan + "2. Select the game perspective\n"
    plan = plan + "3. Design gameplay mechanics\n"
    plan = plan + "4. Create the game world\n"
    plan = plan + "5. Generate game code\n"
    plan = plan + "6. Validate the generated project\n"

    return plan
