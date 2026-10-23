from core.prompt import analyze_prompt
from core.planner import create_plan
from core.planner import create_dynamic_plan

def plan_from_prompt(prompt: String) -> String:
    """Coordinate prompt analysis and planning."""
    var spec = analyze_prompt(prompt)
    var plan = create_dynamic_plan(spec)
    var output = "WORLD SMITH PLAN\n"
    output += "Genre: " + spec.genre + "\n"
    output += "Perspective: " + spec.perspective + "\n"
    output += "Features: " + spec.features + "\n"
    output += "Summary: " + plan.summary + "\n"
    output += "Stages:\n" + plan.stages
    return output
