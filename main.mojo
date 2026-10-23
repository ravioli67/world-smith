# WorldSmith/main.mojo

from config import default_output_directory
from config import default_target_engine
from core.orchestrator import generate_game_design
from core.orchestrator import save_design


def main() raises:
    print("================================")
    print("         WORLDSMITH")
    print("      AI Game Generator")
    print("================================")
    print()
    print("Describe the game you want to create.")
    print("Examples: a stealth game, a farming RPG,")
    print("a physics platformer, or something original.")
    print()

    var user_prompt = input("Game idea > ")

    if user_prompt == "":
        print("No game description provided.")
        return

    var engine = default_target_engine()

    print()
    print("Target engine: " + engine)
    print("Connecting to your local LM Studio model...")
    print("Generating game design...")

    try:
        var response = generate_game_design(
            user_prompt,
            engine
        )

        print()
        print("Game design generated successfully.")
        print("Model: " + response.model_name)
        print()
        print(response.content)

        save_design(
            response,
            default_output_directory()
        )

    except e:
        print()
        print("WorldSmith encountered an error:")
        print(e)
        print()
        print("Check that LM Studio's server is running")
        print("and that the configured model is loaded.")