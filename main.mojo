from core.prompt import analyze_prompt
from core.planner import create_plan
from generation.project_writer import write_manifest
from config import get_project_name, get_project_version


def main():
    print("====================================")
    print("             WORLDSMITH")
    print("       Turning Ideas Into Worlds")
    print("====================================")
    print("Version:", get_project_version())
    print()

    var prompt = input("Describe the game you want to create: ")

    if prompt == "":
        print("Please enter a game description.")
        return

    var spec = analyze_prompt(prompt)
    var plan = create_plan(spec)

    print()
    print("=== GAME SPECIFICATION ===")
    print("Title:", spec.title)
    print("Genre:", spec.genre)
    print("Perspective:", spec.perspective)
    print("Features:", spec.features)
    print()
    print(plan.summary)

    var result = write_manifest(spec, plan)
    print()
    print("Manifest status:", result)
    print("This prototype plans projects; it does not yet generate a complete playable game.")
