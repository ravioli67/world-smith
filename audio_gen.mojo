def audio_generation_status() -> String:
    return "Audio generation is not connected yet."


def audio_asset_prompt(game_description: String, sound_name: String) -> String:
    return "Describe an original game sound named " + sound_name + " for: " + game_description
