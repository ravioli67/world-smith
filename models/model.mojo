
# WorldSmith/models/model.mojo

from core.context import GameSpec


struct ModelResult:
    var spec: GameSpec
    var details_json: String

    def __init__(
        out self,
        spec: GameSpec,
        details_json: String
    ):
        self.spec = spec
        self.details_json = details_json
