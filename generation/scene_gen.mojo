from core.context import GameSpec


def describe_initial_scene(spec: GameSpec) -> String:
    var description = "Initial scene for " + spec.genre + " game.\n"
    description += "Perspective: " + spec.perspective + "\n"
    description += "Start with a small test level and a clearly marked player spawn."
    return description
