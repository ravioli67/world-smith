struct ModelConfig:
    var name: String
    var provider: String
    var model_path: String

    def __init__(out self, name: String, provider: String, model_path: String):
        self.name = name
        self.provider = provider
        self.model_path = model_path


def default_model_config() -> ModelConfig:
    return ModelConfig("worldsmith-base", "not-configured", "")
