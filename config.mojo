# WorldSmith/config.mojo

fn default_model() -> String:
    return "SET_TO_LOADED_LM_STUDIO_MODEL_ID"


fn default_model_endpoint() -> String:
    return "http://127.0.0.1:1235/v1"


fn default_target_engine() -> String:
    return "Godot"


fn default_output_directory() -> String:
    return "output"


fn default_temperature() -> Float32:
    return 0.2


fn default_max_tokens() -> Int:
    return 8192


fn default_request_timeout_seconds() -> Int:
    return 180


fn default_max_repair_attempts() -> Int:
    return 3


fn default_max_generated_files() -> Int:
    return 200


fn default_max_file_size_bytes() -> Int:
    return 1048576


fn default_system_prompt() -> String:
    return """
You are the development model for WorldSmith, an AI game-generation system.

Your job is to understand the user's actual game idea and turn it into
a coherent, implementable design.

Preserve the requested genre, perspective, tone, mechanics, and goals.
Invent supporting details when necessary, but do not replace the user's
idea with an unrelated template.

Separate game design from implementation planning.
Prefer modular systems with explicit dependencies.
Do not claim code was tested unless a test was actually run.
Return valid structured JSON whenever the caller requests JSON.
"""