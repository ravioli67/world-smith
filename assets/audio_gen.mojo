# WorldSmith/assets/audio_gen.mojo

from std.collections.list import List


struct AudioCue:
    var cue_id: String
    var event_name: String
    var sound_description: String
    var duration_seconds: Float32
    var loop: Bool
    var intensity: String
    var output_path: String

    def __init__(
        out self,
        cue_id: String,
        event_name: String,
        sound_description: String,
        duration_seconds: Float32,
        loop: Bool,
        intensity: String,
        output_path: String
    ):
        self.cue_id = cue_id
        self.event_name = event_name
        self.sound_description = sound_description
        self.duration_seconds = duration_seconds
        self.loop = loop
        self.intensity = intensity
        self.output_path = output_path


struct AudioPlan:
    var music_direction: String
    var ambience_direction: String
    var cues: List[AudioCue]

    def __init__(
        out self,
        music_direction: String,
        ambience_direction: String
    ):
        self.music_direction = music_direction
        self.ambience_direction = ambience_direction
        self.cues = List[AudioCue]()

    def add_cue(mut self, cue: AudioCue):
        self.cues.append(cue)

    def count(self) -> Int:
        return len(self.cues)


def describe_audio_plan(plan: AudioPlan) -> String:
    var result = "Music direction: " + plan.music_direction + "\n"
    result += "Ambience: " + plan.ambience_direction + "\n"
    result += "Sound cues: " + String(plan.count()) + "\n"

    for i in range(len(plan.cues)):
        var cue = plan.cues[i]
        result += "\nEvent: " + cue.event_name + "\n"
        result += "Sound: " + cue.sound_description + "\n"
        result += "Duration: " + String(cue.duration_seconds) + " seconds\n"
        result += "Output: " + cue.output_path + "\n"

    return result