# WorldSmith/assets/asset_manager.mojo

from std.collections.list import List


struct AssetSpec:
    var asset_id: String
    var asset_type: String
    var relative_path: String
    var description: String
    var style: String
    var source_prompt: String
    var status: String

    def __init__(
        out self,
        asset_id: String,
        asset_type: String,
        relative_path: String,
        description: String,
        style: String,
        source_prompt: String
    ):
        self.asset_id = asset_id
        self.asset_type = asset_type
        self.relative_path = relative_path
        self.description = description
        self.style = style
        self.source_prompt = source_prompt
        self.status = "planned"


struct AssetPlan:
    var game_title: String
    var visual_style: String
    var audio_style: String
    var assets: List[AssetSpec]

    def __init__(
        out self,
        game_title: String,
        visual_style: String,
        audio_style: String
    ):
        self.game_title = game_title
        self.visual_style = visual_style
        self.audio_style = audio_style
        self.assets = List[AssetSpec]()

    def add_asset(mut self, asset: AssetSpec):
        self.assets.append(asset)

    def count(self) -> Int:
        return len(self.assets)


def describe_asset_plan(plan: AssetPlan) -> String:
    var result = "Game: " + plan.game_title + "\n"
    result += "Visual style: " + plan.visual_style + "\n"
    result += "Audio style: " + plan.audio_style + "\n"
    result += "Asset count: " + String(plan.count()) + "\n"

    for i in range(len(plan.assets)):
        var asset = plan.assets[i]
        result += "\n[" + asset.asset_type + "] "
        result += asset.asset_id + "\n"
        result += "Path: " + asset.relative_path + "\n"
        result += "Description: " + asset.description + "\n"
        result += "Status: " + asset.status + "\n"

    return result