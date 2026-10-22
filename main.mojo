
# WorldSmith/main.mojo
#
# Main entry point for WorldSmith.
# Turns a natural-language game idea into an AI-assisted game plan.

from core.orchestrator import orchestrate


def main() raises:
    print("======================================")
    print("       WORLDSMITH")
    print("       Turning Ideas Into Worlds")
    print("======================================")
    print()

    print("Describe the game you want to create.")
    print("Be as detailed as you like.")
    print()

    var prompt = input("Game idea > ")

    if prompt.strip() == "":
        print("Error: Please enter a game description.")
        return

    print()
    print("WorldSmith is analyzing your idea...")
    print("Contacting the local AI model...")
    print()

    try:
        var result = orchestrate(prompt)
        print(result)
    except e:
        print("WorldSmith could not complete the request.")
        print("Check that your local AI service is running")
        print("and that the model and Python environment are configured.")
        print("Technical error:")
        print(e)

    print()
    print("WorldSmith session finished.")


if __name__ == "__main__":
    main()
