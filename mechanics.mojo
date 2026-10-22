from core.context import GameSpec


def describe_mechanics(spec: GameSpec) -> String:
    var result = "Core gameplay mechanics:\n"
    result += "- Player movement and input\n"
    result += "- Clear win, loss, or progression condition\n"
    result += "- Feedback for player actions\n"
    result += "- Genre-specific systems: " + spec.genre + "\n"
    result += "- Requested features: " + spec.features
    return result
