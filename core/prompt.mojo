# WorldSmith/core/prompt.mojo

def analyze_prompt(prompt: String) -> String:
    """Prepare a user-provided game idea for planning."""

    if prompt == "":
        return "Error: The game description cannot be empty."

    return "Game concept received: " + prompt
