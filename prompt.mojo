from core.context import GameSpec, add_feature


def contains(text: String, needle: String) -> Bool:
    return text.find(needle) != -1


def analyze_prompt(prompt: String) -> GameSpec:
    """Turn a plain-text idea into a simple, rule-based game specification."""
    var spec = GameSpec()
    spec.raw_prompt = prompt
    spec.title = "Untitled WorldSmith Game"
    spec.genre = "adventure"
    spec.perspective = "third-person"
    spec.features = ""

    if contains(prompt, "platform") or contains(prompt, "jump"):
        spec.genre = "platformer"
    elif contains(prompt, "survival") or contains(prompt, "craft"):
        spec.genre = "survival"
    elif contains(prompt, "rpg") or contains(prompt, "role-playing"):
        spec.genre = "RPG"
    elif contains(prompt, "shooter") or contains(prompt, "shoot"):
        spec.genre = "shooter"
    elif contains(prompt, "puzzle"):
        spec.genre = "puzzle"
    elif contains(prompt, "racing") or contains(prompt, "race"):
        spec.genre = "racing"

    if contains(prompt, "first-person") or contains(prompt, "first person"):
        spec.perspective = "first-person"
    elif contains(prompt, "top-down") or contains(prompt, "top down"):
        spec.perspective = "top-down"
    elif contains(prompt, "2d") or contains(prompt, "2D"):
        spec.perspective = "2D"
    elif contains(prompt, "3d") or contains(prompt, "3D"):
        spec.perspective = "3D"

    if contains(prompt, "craft"):
        spec.features = add_feature(spec.features, "crafting")
    if contains(prompt, "monster") or contains(prompt, "enemy"):
        spec.features = add_feature(spec.features, "enemies")
    if contains(prompt, "multiplayer"):
        spec.features = add_feature(spec.features, "multiplayer")
    if contains(prompt, "open world") or contains(prompt, "open-world"):
        spec.features = add_feature(spec.features, "open world")
    if contains(prompt, "quest") or contains(prompt, "mission"):
        spec.features = add_feature(spec.features, "quests")
    if contains(prompt, "inventory"):
        spec.features = add_feature(spec.features, "inventory")
    if contains(prompt, "boss"):
        spec.features = add_feature(spec.features, "boss fights")

    if spec.features == "":
        spec.features = "exploration"

    return spec
