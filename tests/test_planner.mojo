from core.prompt import analyze_prompt
from core.planner import create_plan


def main():
    var spec = analyze_prompt("Make an RPG with quests")
    var plan = create_plan(spec)
    print(plan.summary)
    print(plan.stages)
