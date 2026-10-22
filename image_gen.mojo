def image_generation_status() -> String:
    return "Image generation is not connected yet."


def image_asset_prompt(game_description: String, asset_name: String) -> String:
    return "Create a game asset named " + asset_name + " for this game: " + game_description
