from core.context import GameSpec


def generate_code_plan(spec: GameSpec) -> String:
    """Describe code files to create; does not emit executable game code yet."""
    var plan = "Planned code files:\n"
    plan += "- project configuration\n"
    plan += "- main scene and game loop\n"
    plan += "- player controller\n"
    plan += "- gameplay systems for " + spec.genre + "\n"
    plan += "- UI and input handling\n"
    return plan
