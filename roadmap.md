# WorldSmith
## Turning Ideas Into Worlds

WorldSmith is an AI-powered game-generation system designed to transform natural-language ideas into structured game designs, generated projects, and eventually complete playable games.

**Core architecture:** Mojo for the main application and planning system; Python for local AI inference, model training, and supporting machine-learning tools.

**Hardware target:** Local development and AI workloads on an NVIDIA RTX 5090.

**Primary AI direction:** Train and improve a local game-design model, starting with Qwen-compatible models and a reproducible fine-tuning pipeline.

---

## Roadmap Status Legend

- [x] Implementation drafted or written.
- [ ] Not yet implemented, executed, or verified.
- [ ] A written implementation is not considered verified until it has been tested.

> Important: Checked items represent code or documentation written during development. They do not imply successful compilation, execution, or integration unless explicitly stated.

---

# Phase 1 — Foundation and Project Structure

**Goal:** Establish the core architecture, shared data structures, AI interface, and project organization.

## 1.1 Project Structure

- [x] Establish the initial WorldSmith directory structure.
- [x] Create the main Mojo application entry point.
- [x] Create the shared configuration module.
- [x] Create the `core/` directory.
- [x] Create the `models/` directory.
- [x] Create the `generation/` directory.
- [x] Create the `assets/` directory.
- [x] Create the `validation/` directory.
- [x] Create the `schemas/` directory.
- [x] Create the `tests/` directory.
- [x] Create the `output/` directory.
- [x] Create `roadmap.md`.
- [ ] Audit the actual repository against the intended project tree.
- [ ] Confirm the project builds with the installed Mojo toolchain.

## 1.2 Core Data Structures

- [x] Draft `core/context.mojo`.
- [x] Define `GameSpec`.
- [x] Define `GamePlan`.
- [x] Add a game-specification summary function.
- [x] Extend `GameSpec` with gameplay-loop information.
- [x] Add fields for player goals and world descriptions.
- [x] Add fields for mechanics, scenes, assumptions, and open questions.
- [ ] Compile and verify the shared structures.
- [ ] Add typed structures for individual mechanics and scenes.
- [ ] Add structured error and diagnostic types.

## 1.3 Initial Planning System

- [x] Draft `core/planner.mojo`.
- [x] Implement the `create_plan(spec)` interface.
- [x] Generate an initial implementation plan.
- [x] Add perspective-aware planning logic.
- [x] Add initial feature-aware planning logic.
- [x] Include AI-generated design details in the plan.
- [ ] Compile and test the planner.
- [ ] Add unit tests for planning behavior.
- [ ] Verify that invalid or incomplete specifications are handled safely.

## 1.4 Application Pipeline

- [x] Draft `models/model.mojo`.
- [x] Draft `models/inference.mojo`.
- [x] Draft `core/orchestrator.mojo`.
- [x] Draft `main.mojo` to connect the application flow.
- [ ] Verify Mojo-to-Python interoperability.
- [ ] Verify the end-to-end application pipeline.
- [ ] Add structured logging and error reporting.

---

# Phase 2 — Planning Brain

**Goal:** Convert a natural-language idea into a coherent, structured game design and a valid implementation plan.

## 2.1 Game Specification Schema

- [x] Define `schemas/game_spec.schema.json`.
- [x] Require a title, genre, perspective, and target engine.
- [x] Add the core gameplay loop.
- [x] Add the player's primary goal.
- [x] Add the world description.
- [x] Define the features list.
- [x] Define the mechanics structure.
- [x] Define the scene and objective structure.
- [x] Include assumptions and open questions.
- [ ] Validate example specifications against the JSON Schema.
- [ ] Add schema-version tracking.
- [ ] Add compatibility rules for future schema changes.

## 2.2 Local AI Design Adapter

- [x] Draft `ai/local_model.py`.
- [x] Add configurable Ollama API URL.
- [x] Add configurable model name.
- [x] Request structured JSON from the local model.
- [x] Validate required fields and data types.
- [x] Reject malformed JSON.
- [x] Reject missing or unexpected fields.
- [x] Validate mechanics and scene structures.
- [x] Add basic response-size limits.
- [x] Add error handling for API failures and timeouts.
- [x] Add a bridge-friendly output format for Mojo.
- [ ] Run the adapter against the configured local model.
- [ ] Verify that the selected Qwen model supports the requested output format.
- [ ] Test long prompts, ambiguous ideas, and malformed model responses.
- [ ] Improve retry and recovery behavior.
- [ ] Add inference timing and token-usage measurements.

## 2.3 Structured Design Transfer

- [x] Pass the title, genre, perspective, and engine into Mojo.
- [x] Pass the feature list into Mojo.
- [x] Add fields for the gameplay loop and player goal.
- [x] Pass mechanics and scenes as JSON strings.
- [x] Pass assumptions and open questions into Mojo.
- [x] Preserve the complete design JSON for later stages.
- [ ] Compile the expanded inference bridge.
- [ ] Verify all Python-to-Mojo field conversions.
- [ ] Add automated integration tests.

## 2.4 Planning and Dependencies

- [x] Expand the planner beyond its original generic stages.
- [x] Add perspective-aware planning.
- [x] Add feature-aware planning.
- [x] Include mechanics and scene specifications in the plan.
- [x] Draft `core/task_graph.mojo`.
- [x] Introduce a task representation.
- [x] Represent task dependencies.
- [x] Add duplicate task-ID validation.
- [x] Add missing-dependency validation.
- [x] Add an initial dependency graph.
- [x] Draft `tests/test_task_graph.mojo`.
- [ ] Compile and execute the task-graph test.
- [ ] Implement cycle detection.
- [ ] Implement topological sorting.
- [ ] Generate task nodes from actual AI-generated mechanics and scenes.
- [ ] Connect scene objectives to their required mechanics.
- [ ] Implement machine-readable task-graph serialization.
- [ ] Detect circular dependencies and report useful diagnostics.
- [ ] Identify independent tasks that can run in parallel.
- [ ] Add task priorities and estimated resource requirements.
- [ ] Generate an execution schedule from the validated graph.

---

# Phase 3 — Local AI and Model Training

**Goal:** Build a reproducible training pipeline and improve the model's ability to produce reliable, detailed game specifications.

**Priority:** High. Model training is a primary development objective.

## 3.1 Local Inference

- [x] Choose a local-model architecture using Ollama as the initial inference interface.
- [x] Add environment-variable configuration for the model and endpoint.
- [x] Select a Qwen-compatible model as the initial default.
- [ ] Confirm the actual installed model and Ollama configuration.
- [ ] Benchmark inference on the local RTX 5090.
- [ ] Measure response quality, latency, and memory usage.
- [ ] Evaluate larger model options where appropriate.
- [ ] Add repeatable inference benchmarks.
- [ ] Add configurable inference parameters.
- [ ] Document local model installation and startup instructions.

## 3.2 Training Environment

- [x] Create the proposed `training/` directory structure.
- [x] Draft `training/requirements.txt`.
- [x] Draft `training/train_lora.py`.
- [x] Configure an initial Hugging Face Qwen base-model identifier.
- [x] Add a CUDA availability check.
- [x] Configure LoRA-based fine-tuning.
- [x] Add separate training and validation datasets.
- [x] Configure checkpoint output.
- [ ] Verify Python package and library compatibility.
- [ ] Pin tested dependency versions.
- [ ] Run a minimal training smoke test.
- [ ] Confirm GPU memory usage and training stability.
- [ ] Verify checkpoint creation and recovery.
- [ ] Add training logs and evaluation metrics.
- [ ] Support resuming interrupted training.
- [ ] Compare training configurations and hyperparameters.

## 3.3 Training Data

- [x] Create `training/data/train.jsonl`.
- [x] Add initial game-design examples.
- [x] Create `training/data/validation.jsonl`.
- [x] Add initial validation examples.
- [ ] Expand the dataset substantially.
- [ ] Add examples covering diverse genres and perspectives.
- [ ] Include detailed mechanics and scene objectives.
- [ ] Include examples with dependencies and implementation constraints.
- [ ] Include difficult, ambiguous, and contradictory prompts.
- [ ] Validate all examples against the game-specification schema.
- [ ] Remove duplicates and malformed examples.
- [ ] Establish dataset versioning and provenance.
- [ ] Prevent validation data from leaking into training data.
- [ ] Create a repeatable dataset-generation workflow.

> The current example datasets are only starter fixtures. They are too small to demonstrate meaningful fine-tuning improvements.

## 3.4 Model Evaluation and Deployment

- [ ] Establish a baseline using the unfine-tuned model.
- [ ] Measure schema validity and field completeness.
- [ ] Evaluate semantic accuracy against user requirements.
- [ ] Measure consistency between mechanics and scenes.
- [ ] Evaluate whether generated plans are achievable.
- [ ] Compare base-model and fine-tuned-model performance.
- [ ] Save evaluation results for each experiment.
- [ ] Export or merge the trained adapter when appropriate.
- [ ] Determine compatibility with the chosen inference runtime.
- [ ] Verify the deployed model produces valid WorldSmith specifications.
- [ ] Add a model-version and checkpoint registry.
- [ ] Document reproducible training and deployment procedures.

---

# Phase 4 — Game Generation Engine

**Goal:** Turn structured game specifications into real project files.

## 4.1 Code Generation

- [x] Create the `generation/` directory.
- [x] Establish the planned `generation/codegen.mojo` module.
- [ ] Implement the code-generation pipeline.
- [ ] Define templates and generation rules for supported engines.
- [ ] Generate project configuration files.
- [ ] Generate entry points and startup scenes.
- [ ] Generate player controllers and input handling.
- [ ] Generate gameplay mechanics.
- [ ] Generate scene-transition logic.
- [ ] Generate user-interface components.
- [ ] Generate reusable game systems.
- [ ] Track generated files and their dependencies.
- [ ] Ensure generated paths stay inside the selected output directory.
- [ ] Add deterministic generation options.

## 4.2 Scene Generation

- [x] Create the planned `generation/scene_gen.mojo` module.
- [ ] Translate AI-generated scene descriptions into concrete scene files.
- [ ] Generate scene hierarchies and object placement.
- [ ] Connect scene objectives to game mechanics.
- [ ] Generate scene transitions.
- [ ] Validate scene references and required resources.
- [ ] Support multiple interconnected scenes.
- [ ] Add scene-level generation tests.

## 4.3 Gameplay Mechanics

- [x] Create the planned `generation/mechanics.mojo` module.
- [ ] Convert mechanic specifications into implementation tasks.
- [ ] Generate player movement and interaction systems.
- [ ] Generate combat, inventory, dialogue, and quest systems as requested.
- [ ] Generate game-state management.
- [ ] Resolve mechanic dependencies.
- [ ] Reuse compatible generated systems where possible.
- [ ] Test interactions between generated mechanics.

## 4.4 Project Writer

- [x] Create the planned `generation/project_writer.mojo` module.
- [ ] Write generated source files to disk.
- [ ] Create project directories automatically.
- [ ] Generate required project manifests and configuration.
- [ ] Keep source files and generated assets organized.
- [ ] Avoid overwriting user files without explicit permission.
- [ ] Generate a project manifest and build instructions.
- [ ] Verify that a generated project can be opened by its target engine.

---

# Phase 5 — Assets and World Generation

**Goal:** Generate or integrate visual assets, audio, and other resources needed by a game.

## 5.1 Asset Management

- [x] Create the `assets/` directory.
- [x] Establish the planned asset-manager module.
- [ ] Implement asset registration and lookup.
- [ ] Track asset types, formats, and file paths.
- [ ] Validate asset references.
- [ ] Detect missing and incompatible resources.
- [ ] Prevent duplicate asset registrations.
- [ ] Connect assets to generated scenes and mechanics.

## 5.2 Image Generation

- [x] Establish the planned `assets/image_gen.mojo` module.
- [ ] Define the image-generation interface.
- [ ] Connect an appropriate image-generation backend.
- [ ] Generate assets based on scene and world descriptions.
- [ ] Support style consistency across a game.
- [ ] Record image prompts and generation metadata.
- [ ] Validate dimensions, formats, and file locations.
- [ ] Add fallback behavior when generation fails.

## 5.3 Audio Generation

- [x] Establish the planned `assets/audio_gen.mojo` module.
- [ ] Define the audio-generation interface.
- [ ] Connect an appropriate audio-generation backend.
- [ ] Generate or integrate music and sound effects.
- [ ] Match audio assets to scene events and mechanics.
- [ ] Validate audio formats and resource references.
- [ ] Add fallbacks for unavailable audio generation.

## 5.4 World Consistency

- [ ] Maintain consistent names and properties for characters and objects.
- [ ] Track locations, events, and world rules across scenes.
- [ ] Check continuity between scenes.
- [ ] Ensure assets match the intended setting and art direction.
- [ ] Validate that required gameplay objects exist.
- [ ] Detect contradictions between the specification and generated content.

---

# Phase 6 — Validation, Testing, and Automatic Repair

**Goal:** Detect problems in generated projects, repair them where possible, and verify that the resulting game works.

## 6.1 Specification and Output Validation

- [x] Create the `validation/` directory.
- [x] Draft strict validation for the Python model output.
- [x] Draft `tests/test_model_output.py`.
- [x] Add tests for malformed JSON and missing fields.
- [x] Add tests for invalid mechanics and scene structures.
- [ ] Execute the Python unit tests.
- [ ] Add schema-validation tests.
- [ ] Validate generated files against their intended formats.
- [ ] Check for missing dependencies and assets.
- [ ] Add validation summaries and structured diagnostics.

## 6.2 Syntax and Project Checks

- [x] Establish the planned `validation/syntax_check.mojo` module.
- [ ] Implement syntax checking for supported output languages.
- [ ] Check generated project configuration.
- [ ] Check imports, references, and required files.
- [ ] Verify scene connections.
- [ ] Report errors with file paths and actionable details.
- [ ] Integrate checks into the generation pipeline.

## 6.3 Game Testing

- [x] Establish the planned `validation/game_test.mojo` module.
- [ ] Define automated project-launch tests.
- [ ] Test core gameplay loops.
- [ ] Test scene transitions.
- [ ] Test important mechanics and game-state changes.
- [ ] Detect startup crashes and missing resources.
- [ ] Add regression tests for repaired bugs.
- [ ] Verify the final build can launch successfully.

## 6.4 Automatic Repair

- [x] Establish the planned `validation/repair.mojo` module.
- [ ] Convert validation failures into structured repair tasks.
- [ ] Provide relevant errors and source context to the AI.
- [ ] Generate targeted repairs instead of regenerating the whole project.
- [ ] Revalidate files after each repair.
- [ ] Limit repair attempts and prevent infinite loops.
- [ ] Preserve known-good files and working states.
- [ ] Record changes made during repair.
- [ ] Stop and report errors that cannot be repaired safely.

---

# Phase 7 — Orchestration and Parallel Execution

**Goal:** Coordinate the model, planner, code generator, asset systems, and validators into a reliable workflow.

## 7.1 Orchestrator

- [x] Establish the planned `core/orchestrator.mojo` module.
- [x] Draft the initial model-to-planner workflow.
- [ ] Execute the full pipeline successfully.
- [ ] Connect planning to code generation.
- [ ] Connect code generation to asset integration.
- [ ] Connect generation to validation and repair.
- [ ] Produce structured progress and error reports.
- [ ] Support cancellation and recovery from failures.

## 7.2 Task Scheduling

- [x] Draft an initial task graph.
- [x] Represent task dependencies.
- [x] Add basic dependency validation.
- [ ] Implement cycle detection.
- [ ] Implement topological scheduling.
- [ ] Identify independent tasks.
- [ ] Run independent generation tasks concurrently when safe.
- [ ] Track task status, duration, and failure details.
- [ ] Prevent tasks from running before prerequisites are satisfied.
- [ ] Add retry policies for transient failures.

## 7.3 Resource Management

- [ ] Track GPU and system-memory usage.
- [ ] Coordinate inference and training workloads.
- [ ] Avoid unnecessary simultaneous memory-intensive jobs.
- [ ] Support configurable concurrency limits.
- [ ] Track output storage and generated asset sizes.
- [ ] Add resource-aware scheduling.

---

# Phase 8 — User Experience and Project Management

**Goal:** Make WorldSmith usable as a complete local development tool.

## 8.1 Command-Line Interface

- [x] Draft an interactive `main.mojo` entry point.
- [ ] Verify the command-line interface.
- [ ] Add project creation options.
- [ ] Add model and engine selection.
- [ ] Add project-output path configuration.
- [ ] Add verbose logging and diagnostic modes.
- [ ] Add clear setup and runtime errors.
- [ ] Support noninteractive operation for automation.

## 8.2 Project Configuration

- [x] Establish the planned `config.mojo` module.
- [ ] Define a stable configuration format.
- [ ] Configure default engine and project settings.
- [ ] Configure model endpoint and model selection.
- [ ] Configure generation and validation limits.
- [ ] Validate configuration before execution.
- [ ] Document configuration options.

## 8.3 Output and Reproducibility

- [x] Create the `output/` directory.
- [ ] Generate a separate project directory for each game.
- [ ] Save the original prompt and final specification.
- [ ] Save the task graph and execution results.
- [ ] Record model and configuration versions.
- [ ] Record generated files and asset references.
- [ ] Support reproducible regeneration.
- [ ] Generate a final project report.

---

# Phase 9 — Quality, Performance, and Reliability

**Goal:** Make WorldSmith dependable across increasingly complex game ideas.

- [ ] Add unit tests for core data structures.
- [ ] Add tests for planning and dependency resolution.
- [ ] Add tests for code generation and project writing.
- [ ] Add end-to-end tests for the complete pipeline.
- [ ] Benchmark inference and generation performance.
- [ ] Evaluate increasingly complex game specifications.
- [ ] Test recovery from model and generation failures.
- [ ] Improve diagnostics and error messages.
- [ ] Add regression tests for previously fixed defects.
- [ ] Document supported game types and known limitations.
- [ ] Establish quality criteria for generated games.
- [ ] Verify that each supported engine can open and run generated projects.

---

# Phase 10 — Advanced WorldSmith Capabilities

**Goal:** Evolve WorldSmith from a structured generator into an adaptive AI game-development system.

## 10.1 Advanced Planning

- [ ] Plan large games as interconnected subsystems.
- [ ] Break complex objectives into smaller implementation tasks.
- [ ] Resolve conflicts between design requirements.
- [ ] Estimate task complexity and resource needs.
- [ ] Adapt the plan when implementation tasks fail.
- [ ] Learn from validation results and previous generation attempts.

## 10.2 Advanced Model Training

- [ ] Build a large, high-quality game-design dataset.
- [ ] Evaluate alternative model architectures.
- [ ] Improve structured-output reliability.
- [ ] Train models for code generation and repair where appropriate.
- [ ] Measure improvements using repeatable benchmarks.
- [ ] Explore preference-based optimization using reviewed outputs.
- [ ] Keep model quality evaluation separate from training loss.

## 10.3 Expanded Game Support

- [ ] Improve support for complex 2D games.
- [ ] Improve support for 3D environments.
- [ ] Add more advanced NPC behavior.
- [ ] Add procedural world-generation systems.
- [ ] Support complex quests and branching progression.
- [ ] Support richer physics and interaction systems.
- [ ] Explore multiplayer project generation.
- [ ] Add engine-specific capabilities without breaking the shared architecture.

---

# Current Development Snapshot

## Written or drafted

- Initial project structure and roadmap.
- Shared Mojo game-specification and planning structures.
- Local Python model adapter with structured-output validation.
- Initial LoRA training script and starter datasets.
- Mojo inference bridge and orchestration drafts.
- Expanded game-specification schema.
- Mechanics and scenes in the structured model output.
- Initial dependency graph and dependency checks.
- Python validation tests and a Mojo task-graph test draft.

## Not yet verified

- Mojo compilation.
- Python unit-test execution.
- Local model connectivity and response validity.
- CUDA training and checkpoint creation.
- Python–Mojo interoperability.
- Task-graph cycle detection and scheduling.
- End-to-end generation of a playable game.

## Immediate Next Steps

1. Compile and verify `core/task_graph.mojo`.
2. Add cycle detection and topological sorting.
3. Generate dependency tasks from actual AI-produced mechanics and scenes.
4. Run the Python model-output tests.
5. Verify local inference with the configured Qwen model.
6. Verify the Mojo-to-Python bridge.
7. Connect the validated task graph to actual project generation.
8. Run the first end-to-end WorldSmith test.

---

# Long-Term Vision

WorldSmith should accept a natural-language game idea and autonomously:

1. Understand the user's intent.
2. Produce a structured game design.
3. Construct a dependency-aware implementation plan.
4. Generate project code, scenes, and assets.
5. Validate the project and detect failures.
6. Repair errors and rerun validation.
7. Produce a playable project with clear launch instructions.
8. Improve over time through measured evaluation and model training.

**Guiding principle:** Build incrementally, test each subsystem, preserve the existing architecture, and never mark an unverified implementation as working.