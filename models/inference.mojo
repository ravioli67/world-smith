from models.model import ModelConfig, default_model_config


def model_is_configured(config: ModelConfig) -> Bool:
    return config.model_path != ""


def generate_text_placeholder(prompt: String) -> String:
    """Placeholder only: no model weights are loaded by this function."""
    return "Inference is not configured yet. Prompt received: " + prompt


def get_default_config() -> ModelConfig:
    return default_model_config()
