from core.prompt import analyze_prompt
from generation.codegen import generate_code_plan
from generation.scene_gen import describe_initial_scene
from generation.mechanics import describe_mechanics


def main():
    var spec = analyze_prompt("Make a top-down puzzle game")
    print(generate_code_plan(spec))
    print(describe_initial_scene(spec))
    print(describe_mechanics(spec))
