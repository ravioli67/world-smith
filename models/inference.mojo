# WorldSmith/models/inference.mojo

import os
from std.subprocess import run

from models.model import ModelRequest, ModelResponse


def escape_json(value: String) -> String:
    var result = String()

    for i in range(len(value)):
        var ch = value[i]

        if ch == "\\":
            result += "\\\\"
        elif ch == "\"":
            result += "\\\""
        elif ch == "\n":
            result += "\\n"
        elif ch == "\r":
            result += "\\r"
        elif ch == "\t":
            result += "\\t"
        else:
            result += ch

    return result


def build_chat_payload(request: ModelRequest) -> String:
    var payload = "{\"model\":\""
    payload += escape_json(request.model_name)
    payload += "\",\"stream\":false,\"temperature\":"
    payload += String(request.temperature)
    payload += ",\"max_tokens\":"
    payload += String(request.max_tokens)
    payload += ",\"response_format\":{\"type\":\"json_object\"}"
    payload += ",\"messages\":["
    payload += "{\"role\":\"system\",\"content\":\""
    payload += escape_json(request.system_prompt)
    payload += "\"},{\"role\":\"user\",\"content\":\""
    payload += escape_json(request.user_prompt)
    payload += "\"}]}"

    return payload


def request_local_model(
    request: ModelRequest,
    endpoint: String
) raises -> ModelResponse:
    if request.model_name == "":
        raise Error("Model ID cannot be empty")

    if endpoint == "":
        raise Error("LM Studio endpoint cannot be empty")

    var request_directory = "output/.worldsmith"
    var request_path = request_directory + "/request.json"
    var response_path = request_directory + "/response.json"

    os.makedirs(request_directory, exist_ok=True)

    var payload = build_chat_payload(request)

    with open(request_path, "w") as request_file:
        request_file.write(payload)

    # The endpoint should come from trusted local configuration,
    # never from model-generated output.
    var command = "curl --silent --show-error --fail "
    command += "--max-time 180 "
    command += "-X POST "
    command += "-H 'Content-Type: application/json' "
    command += "--data-binary '@" + request_path + "' "
    command += "'" + endpoint + "/chat/completions' "
    command += "-o '" + response_path + "'"

    try:
        var transport_output = run(command)

        # Extract choices[0].message.content from the OpenAI-style
        # response. jq must be installed on the host system.
        var parse_command = "jq -er '.choices[0].message.content' '"
        parse_command += response_path + "'"

        var content = run(parse_command)

        return ModelResponse(
            content,
            request.model_name,
            True,
            ""
        )
    except e:
        return ModelResponse(
            "",
            request.model_name,
            False,
            "LM Studio inference failed. Check the server, model ID, "
            "curl and jq installations, and the API response."
        )