# WorldSmith/models/model.mojo

from std.collections.list import List
from core.context import GameSpec


struct ModelRequest:
    var system_prompt: String
    var user_prompt: String
    var model_name: String
    var temperature: Float32
    var max_tokens: Int
    var response_format: String

    def __init__(
        out self,
        system_prompt: String,
        user_prompt: String,
        model_name: String,
        temperature: Float32,
        max_tokens: Int,
        response_format: String = "json"
    ):
        self.system_prompt = system_prompt
        self.user_prompt = user_prompt
        self.model_name = model_name
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.response_format = response_format


struct ModelResponse:
    var content: String
    var model_name: String
    var succeeded: Bool
    var error_message: String

    def __init__(
        out self,
        content: String,
        model_name: String,
        succeeded: Bool,
        error_message: String = ""
    ):
        self.content = content
        self.model_name = model_name
        self.succeeded = succeeded
        self.error_message = error_message


struct ModelResult:
    # Keep GameSpec compatible with the existing project.
    var spec: GameSpec

    # Full model-produced JSON, preserved for later stages.
    var details_json: String

    def __init__(
        out self,
        spec: GameSpec,
        details_json: String
    ):
        self.spec = spec
        self.details_json = details_json


struct ProjectFile:
    var path: String
    var content: String

    def __init__(
        out self,
        path: String,
        content: String
    ):
        self.path = path
        self.content = content


struct ProjectManifest:
    var title: String
    var engine: String
    var design_summary: String
    var files: List[ProjectFile]

    def __init__(
        out self,
        title: String,
        engine: String,
        design_summary: String
    ):
        self.title = title
        self.engine = engine
        self.design_summary = design_summary
        self.files = List[ProjectFile]()

    def add_file(mut self, path: String, content: String):
        self.files.append(ProjectFile(path, content))

    def file_count(self) -> Int:
        return len(self.files)