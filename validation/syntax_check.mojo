def syntax_check_status() -> String:
    return "Syntax checking is not connected to a game engine yet."


def should_review_before_running() -> Bool:
    return True


def safety_message() -> String:
    return "Treat generated source as untrusted. Review it and test it in a sandbox before execution."
