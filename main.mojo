
# WorldSmith/main.mojo

from python import Python
from core.prompt import analyze_prompt
from core.planner import create_plan


def main():
    print("====================================")
    print("           WORLDSMITH AI")
    print("      Turning Ideas Into Worlds")
    print("====================================")
    print()

    var builtins = Python.import_module("builtins")
    var raw_prompt = builtins.input(
        "Describe the game you want to create: "
    )
    var prompt = String(raw_prompt)

    if prompt == "":
        print("Please enter a game description.")
        return

    var concept = analyze_prompt(prompt)
    var plan = create_plan(concept)

    print()
    print(plan)


