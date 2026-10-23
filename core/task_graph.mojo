# world-smith/core/task_graph.mojo
#
# Dependency graph with:
# - Unique task ID validation
# - Missing dependency validation
# - Circular dependency detection
# - Topological sorting
#
# Implementation draft: compile against the installed Mojo version
# before relying on this module in the generation pipeline.


struct Task:
    var id: String
    var name: String
    var depends_on: String

    def __init__(
        out self,
        id: String,
        name: String,
        depends_on: String = "",
    ):
        self.id = id
        self.name = name
        self.depends_on = depends_on


struct TaskGraph:
    var tasks: List[Task]

    def __init__(out self):
        self.tasks = List[Task]()

    def add_task(
        mut self,
        id: String,
        name: String,
        depends_on: String = "",
    ):
        self.tasks.append(Task(id, name, depends_on))

    def count(self) -> Int:
        return len(self.tasks)

    def has_task(self, id: String) -> Bool:
        for task in self.tasks:
            if task.id == id:
                return True
        return False

    def validate_unique_ids(self) -> Bool:
        for i in range(len(self.tasks)):
            for j in range(i + 1, len(self.tasks)):
                if self.tasks[i].id == self.tasks[j].id:
                    return False
        return True

    def dependencies_exist(self) -> Bool:
        for task in self.tasks:
            if task.depends_on == "":
                continue

            var parts = task.depends_on.split(",")

            for dependency in parts:
                var dep_id = dependency.strip()

                if dep_id == "":
                    return False

                if not self.has_task(dep_id):
                    return False

        return True

    def describe(self) -> String:
        var output = ""

        for task in self.tasks:
            output += task.id + " | " + task.name

            if task.depends_on == "":
                output += " | depends_on: none"
            else:
                output += " | depends_on: " + task.depends_on

            output += "\n"

        return output


def contains_id(ids: List[String], target: String) -> Bool:
    for id in ids:
        if id == target:
            return True

    return False


def dependencies_completed(
    task: Task,
    completed: List[String],
) -> Bool:
    if task.depends_on == "":
        return True

    var parts = task.depends_on.split(",")

    for dependency in parts:
        var dep_id = dependency.strip()

        if not contains_id(completed, dep_id):
            return False

    return True


def topological_sort(graph: TaskGraph) -> String:
    """Return tasks in dependency order, or an error message."""

    if not graph.validate_unique_ids():
        return "ERROR: Task IDs must be unique."

    if not graph.dependencies_exist():
        return "ERROR: A task references a missing or empty dependency."

    var completed = List[String]()
    var output = "=== EXECUTION ORDER ===\n"

    # Repeatedly select tasks whose prerequisites are complete.
    # If an entire pass makes no progress, a cycle exists.
    while len(completed) < graph.count():
        var previous_count = len(completed)

        for task in graph.tasks:
            if contains_id(completed, task.id):
                continue

            if dependencies_completed(task, completed):
                completed.append(task.id)

                output += String(len(completed))
                output += ". "
                output += task.id
                output += " - "
                output += task.name
                output += "\n"

        if len(completed) == previous_count:
            return (
                "ERROR: Circular dependency detected. "
                "The remaining tasks cannot be scheduled."
            )

    return output


def validate_graph(graph: TaskGraph) -> String:
    if not graph.validate_unique_ids():
        return "ERROR: Task IDs must be unique."

    if not graph.dependencies_exist():
        return "ERROR: A task references a missing or empty dependency."

    var sorted_output = topological_sort(graph)

    if sorted_output.find("ERROR:") != -1:
        return sorted_output

    return "Graph structure is valid. No dependency cycles detected."


def build_initial_graph() -> TaskGraph:
    var graph = TaskGraph()

    graph.add_task("T01", "Analyze requirements")
    graph.add_task("T02", "Design gameplay", "T01")
    graph.add_task("T03", "Set up engine project", "T01")
    graph.add_task("T04", "Implement player controls", "T03")
    graph.add_task("T05", "Implement core mechanics", "T02,T04")
    graph.add_task("T06", "Build game scenes", "T02,T03")
    graph.add_task("T07", "Integrate gameplay", "T05,T06")
    graph.add_task("T08", "Integrate assets", "T06")
    graph.add_task("T09", "Validate project", "T07,T08")
    graph.add_task("T10", "Repair detected issues", "T09")
    graph.add_task("T11", "Prepare playable build", "T10")

    return graph
