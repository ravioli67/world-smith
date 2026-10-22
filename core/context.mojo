
# WorldSmith/core/context.mojo
#
# Shared data structures used throughout WorldSmith.

struct GameSpec:
    var raw_prompt: String
    var title: String
    var genre: String
    var perspective: String
    var features: String
    var target_engine: String

    def __init__(out self):
        self.raw_prompt = ""
        self.title = "Untitled WorldSmith Game"
        self.genre = "adventure"
        self.perspective = "third-person"
        self.features = ""
        self.target_engine = "Godot"


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
    var result = "Genre: " + spec.genre + "\n"
    result += "Perspective: " + spec.perspective + "\n"
    result += "Engine: " + spec.target_engine + "\n"
    result += "Features: " + spec.features

    return result
