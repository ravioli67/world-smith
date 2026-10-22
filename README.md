# WorldSmith

**Turning Ideas Into Worlds.**

WorldSmith is an early-stage game-generation assistant. This starter repository accepts a game description, creates a simple structured plan, writes a project manifest, and provides clear interfaces for future model inference, asset generation, and validation.

## Current status

This is a **starter scaffold**, not a trained game-generating AI yet. The current planner uses simple keyword rules. Model training, inference, image generation, audio generation, and automatic repair are placeholders.

## Layout

- `main.mojo` — command-line entry point
- `config.mojo` — project metadata
- `core/` — prompt analysis and planning
- `models/` — model/tokenizer interfaces and training notes
- `generation/` — game project and asset-generation interfaces
- `assets/` — asset management interfaces
- `validation/` — checks and repair planning
- `schemas/` — JSON Schema definitions
- `tests/` — lightweight test programs
- `output/` — generated projects

## Run

Install Mojo using the official Modular documentation for your operating system. From the repository root, try:

```bash
mojo run main.mojo
```

Mojo is evolving quickly. If your installed version reports syntax or module-import errors, use the error message and your installed version to adapt the scaffold. This starter has not been compiled in this environment.

## Safety note

Generated code should be treated as untrusted. Do not automatically execute generated projects or shell commands. Review generated files and run them in a sandbox.
