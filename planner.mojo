from core.context import GameSpec, summarize_spec


struct GamePlan:
    var summary: String
    var stages: String
    var engine: String

    def __init__(out self, summary: String, stages: String, engine: String):
        self.summary = summary
        self.stages = stages
        self.engine = engine


def create_plan(spec: GameSpec) -> GamePlan:
    var summary = summarize_spec(spec)
    var stages = "1. Confirm requirements\n"
    stages += "2. Design core gameplay loop\n"
    stages += "3. Create a minimal playable scene\n"
    stages += "4. Add controls and mechanics\n"
    stages += "5. Add art and audio assets\n"
    stages += "6. Validate and package the project\n"
    return GamePlan(summary, stages, "Godot")
