
"""Initial WorldSmith LoRA fine-tuning script.

Run from the WorldSmith project root in a configured Python environment.
This script trains an adapter; it does not automatically install or
export the model into Ollama.
"""

import os
import torch

from datasets import load_dataset
from peft import LoraConfig
from transformers import AutoTokenizer
from trl import SFTConfig, SFTTrainer


BASE_MODEL = os.getenv(
    "WORLDSMITH_BASE_MODEL",
    "Qwen/Qwen2.5-0.5B-Instruct",
)

TRAIN_FILE = "training/data/train.jsonl"
VALIDATION_FILE = "training/data/validation.jsonl"
OUTPUT_DIR = "models/checkpoints/worldsmith-lora"


def main():
    if not os.path.exists(TRAIN_FILE):
        raise FileNotFoundError(f"Training data not found: {TRAIN_FILE}")

    if not os.path.exists(VALIDATION_FILE):
        raise FileNotFoundError(
            f"Validation data not found: {VALIDATION_FILE}"
        )

    # Fail early rather than silently attempting to train on CPU.
    if not torch.cuda.is_available():
        raise RuntimeError(
            "CUDA was not detected. Configure a compatible GPU-enabled "
            "PyTorch environment before running this training script."
        )

    dataset = load_dataset(
        "json",
        data_files={
            "train": TRAIN_FILE,
            "validation": VALIDATION_FILE,
        },
    )

    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

    training_args = SFTConfig(
        output_dir=OUTPUT_DIR,
        num_train_epochs=3,
        per_device_train_batch_size=1,
        per_device_eval_batch_size=1,
        gradient_accumulation_steps=8,
        learning_rate=1e-4,
        logging_steps=1,
        save_strategy="epoch",
        eval_strategy="epoch",
        report_to="none",
        max_length=1024,
        gradient_checkpointing=True,
        fp16=True,
        seed=42,
    )

    adapter_config = LoraConfig(
        r=8,
        lora_alpha=16,
        lora_dropout=0.05,
        bias="none",
        task_type="CAUSAL_LM",
        target_modules="all-linear",
    )

    trainer = SFTTrainer(
        model=BASE_MODEL,
        args=training_args,
        train_dataset=dataset["train"],
        eval_dataset=dataset["validation"],
        processing_class=tokenizer,
        peft_config=adapter_config,
    )

    trainer.train()

    trainer.save_model(OUTPUT_DIR)
    tokenizer.save_pretrained(OUTPUT_DIR)

    print(f"Training finished. Adapter saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
