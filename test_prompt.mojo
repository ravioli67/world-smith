from core.prompt import analyze_prompt


def main():
    var spec = analyze_prompt("Make a 3D survival game with crafting and monsters")
    print("Genre should be survival:", spec.genre)
    print("Perspective should be 3D:", spec.perspective)
    print("Features:", spec.features)
