
from core.task_graph import (
    TaskGraph,
    build_initial_graph,
    topological_sort,
    validate_graph,
)


def main():
    print("TEST 1: Initial graph")

    var graph = build_initial_graph()

    print(validate_graph(graph))
    print(topological_sort(graph))

    print("\nTEST 2: Missing dependency")

    var missing = TaskGraph()
    missing.add_task("A", "First task", "UNKNOWN")

    print(validate_graph(missing))

    print("\nTEST 3: Circular dependency")

    var cyclic = TaskGraph()
    cyclic.add_task("A", "First task", "B")
    cyclic.add_task("B", "Second task", "A")

    print(validate_graph(cyclic))

    print("\nTEST 4: Duplicate task IDs")

    var duplicate = TaskGraph()
    duplicate.add_task("A", "First task")
    duplicate.add_task("A", "Second task")

    print(validate_graph(duplicate))


if __name__ == "__main__":
    main()
