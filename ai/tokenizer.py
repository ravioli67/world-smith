
# WorldSmith/ai/tokenizer.py

"""Tokenize user prompts and measure their size before inference."""

import os
from functools import lru_cache


class TokenizerError(RuntimeError):
    pass


@lru_cache(maxsize=1)
def _load_tokenizer():
    try:
        from transformers import AutoTokenizer

        tokenizer_name = os.getenv(
            "WORLDSMITH_TOKENIZER",
            "Qwen/Qwen2.5-3B-Instruct",
        )

        return AutoTokenizer.from_pretrained(tokenizer_name)

    except Exception as exc:
        raise TokenizerError(
            "Could not load the configured tokenizer. Install transformers "
            "and verify WORLDSMITH_TOKENIZER. The first load may need "
            "internet access unless the tokenizer is cached locally."
        ) from exc


def tokenize_prompt(text: str) -> list[int]:
    """Return token IDs for a prompt using the configured tokenizer."""
    if not isinstance(text, str) or not text.strip():
        raise TokenizerError("The user prompt cannot be empty.")

    tokenizer = _load_tokenizer()
    return tokenizer.encode(text, add_special_tokens=True)


def count_tokens(text: str) -> int:
    return len(tokenize_prompt(text))


def inspect_prompt(text: str) -> dict:
    """Return prompt metadata without logging the user's prompt."""
    token_ids = tokenize_prompt(text)

    return {
        "token_count": len(token_ids),
        "character_count": len(text),
        "is_empty": len(token_ids) == 0,
    }
