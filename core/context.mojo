struct GameSpec:
    var raw_prompt: String
    var title: String
    var genre: String
    var perspective: String
    var features: String

    def __init__(out self):
        self.raw_prompt = ""
        self.title = "Untitled WorldSmith Game"
        self.genre = "adventure"
        self.perspective = "third-person"
        self.features = ""


def add_feature(existing: String, feature: String) -> String:
    if existing == "":
        return feature
    return existing + ", " + feature


def summarize_spec(spec: GameSpec) -> String:
    return "A " + spec.perspective + " " + spec.genre + " game featuring " + spec.features + "."
