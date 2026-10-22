
# WorldSmith/core/context.mojo
#
# Shared game-design data structures.

struct GameSpec:
    var raw_prompt: String
    var title: String
    var genre: String
    var perspective: String
    var features: String
    var target_engine: String

    # Expanded AI-generated design.
    var core_loop: String
    var player_goal: String
    var world_description: String
    var mechanics_json: String
    var scenes_json: String
    var assumptions_json: String
    var open_questions_json: String

    def __init__(out self):
        self.raw_prompt = ""
        self.title = "Untitled WorldSmith Game"
        self.genre = "adventure"
        self.perspective = "third-person"
        self.features = ""
        self.target_engine = "Godot"

        self.core_loop = ""
        self.player_goal = ""
        self.world_description = ""
        self.mechanics_json = "[]"
        self.scenes_json = "[]"
        self.assumptions_json = "[]"
        self.open_questions_json = "[]"


struct GamePlan:
    var summary: String
    var stages: String
    var engine: String

    def __init__(
        out self,
        summary: String,
        stages: String,
        engine: String
    ):
        self.summary = summary
        self.stages = stages
        self.engine = engine


def add_feature(existing: String, feature: String) -> String:
    if existing == "":
        return feature

    return existing + ", " + feature


def summarize_spec(spec: GameSpec) -> String:
    var result = "Title: " + spec.title + "\n"
    result += "Genre: " + spec.genre + "\n"
    result += "Perspective: " + spec.perspective + "\n"
    result += "Engine: " + spec.target_engine + "\n"
    result += "Player goal: " + spec.player_goal + "\n"
    result += "Gameplay loop: " + spec.core_loop + "\n"
    result += "World: " + spec.world_description + "\n"
    result += "Features: " + spec.features + "\n"

    return result
