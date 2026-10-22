
# WorldSmith/core/prompt.mojo
#
# Converts a natural-language game description into a basic GameSpec.
# This is a rule-based interpreter, not an AI model yet.

from core.context import GameSpec, add_feature


def contains(text: String, keyword: String) -> Bool:
    return text.find(keyword) != -1


def analyze_prompt(prompt: String) -> GameSpec:
    var spec = GameSpec()
    var text = prompt.lower()

    # Preserve the original prompt for later stages.
    spec.raw_prompt = prompt

    # --------------------------------------------------
    # 1. Detect the game genre
    # --------------------------------------------------

    if contains(text, "platformer") or contains(text, "platform game"):
        spec.genre = "platformer"
    elif contains(text, "survival"):
        spec.genre = "survival"
    elif contains(text, "horror"):
        spec.genre = "horror"
    elif contains(text, "role-playing") or contains(text, "rpg"):
        spec.genre = "RPG"
    elif contains(text, "shooter") or contains(text, "shooting game"):
        spec.genre = "shooter"
    elif contains(text, "puzzle"):
        spec.genre = "puzzle"
    elif contains(text, "racing") or contains(text, "race game"):
        spec.genre = "racing"
    elif contains(text, "strategy"):
        spec.genre = "strategy"
    elif contains(text, "adventure"):
        spec.genre = "adventure"

    # --------------------------------------------------
    # 2. Detect perspective and dimensionality
    # --------------------------------------------------

    if contains(text, "first-person") or contains(text, "first person"):
        spec.perspective = "first-person"
    elif contains(text, "third-person") or contains(text, "third person"):
        spec.perspective = "third-person"
    elif contains(text, "top-down") or contains(text, "top down"):
        spec.perspective = "top-down"
    elif contains(text, "side-scrolling") or contains(text, "side scrolling"):
        spec.perspective = "side-scrolling"
    elif contains(text, "2d") or contains(text, "two-dimensional"):
        spec.perspective = "2D"
    elif contains(text, "3d") or contains(text, "three-dimensional"):
        spec.perspective = "3D"

    # --------------------------------------------------
    # 3. Detect gameplay mechanics
    # --------------------------------------------------

    var features = ""

    if contains(text, "crafting") or contains(text, "craft items"):
        features = add_feature(features, "crafting")

    if contains(text, "enemy") or contains(text, "enemies") or contains(text, "monster"):
        features = add_feature(features, "enemies")

    if contains(text, "multiplayer") or contains(text, "co-op"):
        features = add_feature(features, "multiplayer")

    if contains(text, "open world") or contains(text, "open-world"):
        features = add_feature(features, "open world")

    if contains(text, "quest") or contains(text, "missions"):
        features = add_feature(features, "quests")

    if contains(text, "inventory") or contains(text, "items"):
        features = add_feature(features, "inventory")

    if contains(text, "boss fight") or contains(text, "boss battle"):
        features = add_feature(features, "boss fights")

    if contains(text, "building") or contains(text, "build structures"):
        features = add_feature(features, "building")

    if contains(text, "dialogue") or contains(text, "talk to characters"):
        features = add_feature(features, "dialogue")

    if contains(text, "stealth") or contains(text, "sneak"):
        features = add_feature(features, "stealth")

    if contains(text, "skill tree") or contains(text, "skill trees"):
        features = add_feature(features, "skill trees")

    if contains(text, "level up") or contains(text, "leveling"):
        features = add_feature(features, "level progression")

    if contains(text, "parkour"):
        features = add_feature(features, "parkour")

    if contains(text, "magic") or contains(text, "spells"):
        features = add_feature(features, "magic")

    if contains(text, "farming") or contains(text, "farm crops"):
        features = add_feature(features, "farming")

    if contains(text, "procedurally generated") or contains(text, "procedural generation"):
        features = add_feature(features, "procedural generation")

    if contains(text, "save system") or contains(text, "save progress"):
        features = add_feature(features, "save system")

    if contains(text, "dialogue choices") or contains(text, "branching story"):
        features = add_feature(features, "branching story")

    spec.features = features

    # --------------------------------------------------
    # 4. Choose a game engine
    # --------------------------------------------------

    # Godot is the default engine for the initial prototype.
    spec.target_engine = "Godot"

    if contains(text, "unreal engine") or contains(text, "unreal engine 5"):
        spec.target_engine = "Unreal Engine"
    elif contains(text, "unity engine") or contains(text, "unity"):
        spec.target_engine = "Unity"
    elif contains(text, "godot"):
        spec.target_engine = "Godot"

    return spec
