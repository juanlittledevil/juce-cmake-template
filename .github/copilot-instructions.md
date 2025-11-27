# Copilot Instructions for <REPO_NAME>

## User-Specific Instructions

- When I ask you to **implement a solution**:
  1. Start by presenting a **clear, detailed plan** of what you intend to do.
     - Break the plan into steps or sections.
     - Include alternatives or trade-offs when relevant.
  2. **Wait for my explicit approval** before modifying any files.
  3. Only after approval, implement *exactly* the agreed plan.
  4. If the plan needs to change after approval, request **re-confirmation**.

- Whenever asked to create or modify code or documentation:
  - Ensure **no broken links**, **no lint violations**, and **no missing files**.
  - Validate that updated Markdown files remain structurally consistent.
  - Prefer Mermaid diagrams for graphs.

- When creating GitHub tickets or issues, **always ask me for the milestone name**, every time.

- For any `gh` CLI command that lists or prints output, **pipe through `cat`**  
  (`gh issue list | cat`)  
  to avoid the editor buffer hang.

- **PIT (Point in Time)**:  
  Each PIT is a “safe commit snapshot.” All work must progress through small, atomic commits between PITs to maintain stable rollback points.

- Always answer any **conceptual question** *before* suggesting or writing code.

- Keep responses **short, direct, and task-focused** unless I explicitly ask for deep elaboration.

## AI Behavior Guardrails

- **Never invent new architecture**, subsystems, folder structures, or workflows.  
  If something is unclear or ambiguous, **ask first**.

- Follow the existing architecture (`docs/architecture/`) literally unless I instruct otherwise.

- If multiple patterns or designs are possible:
  - State your *opinion*, label it clearly,  
  - Then provide at least one valid alternative path.

- If unsure **why** something exists, ask instead of guessing.

## Project Overview

- **Type:** JUCE-based audio plugin (C++/CMake)
- **Purpose:**  <TBD>
- **Code style:** Modern C++ (C++20), maintainable, readable, modular.
- **Documentation:** Markdown with Mermaid diagrams.  
- **Architecture Docs:** Entry point at `docs/architecture/ARCHITECTURE.md`.

## Coding Standards

- Use JUCE best practices and idioms.
- Use modern C++20 features where appropriate (but avoid cleverness).
- Keep classes and functions **focused and minimal**.
- Variable and function names should be clear and intention-revealing.
- Add comments for non-obvious logic and architectural decisions.
- All code must fit within the existing structure (`src/`, `include/`, `tests/`, etc.)
- Use MVVM for UI components; separate model, view, and controller logic.

### Extra Guardrails

- Always check if a class, function, or module **already exists** before proposing or adding a new one.
- When modifying code that touches multiple subsystems:
  - Provide a dependency impact summary in the plan.
- Avoid any refactor larger than the immediate task unless explicitly approved.

## Testing & Debugging

- All executables and utility scripts live in `scripts/`, and are in `$PATH`.
- Do **not** rely on VS Code tasks for builds/tests during development.
- Refer to `scripts/README.md` for the authoritative list of build/test/debug commands (for example `build.sh`, `run-tests.sh`, `clean.sh`).

- All new features **must** include unit tests using JUCE’s UnitTest framework.
- Prefer small, narrow tests over monolithic ones.

### Additional Testing Guidance

- If adding a new architectural unit (like a state-machine or subsystem), generate the test skeleton **first**.
- Avoid adding mocks unless absolutely necessary — prefer real JUCE constructs when possible.

## Documentation

- Every new feature or architectural change must update/add the corresponding Markdown doc under `docs/`.
- Ensure all Markdown is lint-compliant.
- Mermaid diagrams should be used when helpful.
- Keep `docs/index.md` as the unified entry point.

### Additional Documentation Rules

- When modifying architecture, update `ARCHITECTURE.md` *before* implementing changes.
- When adding high-level behaviors or state machines, include:
  - A Mermaid flowchart
  - A short explanation of the intent

## Doxygen and Comments

- Use Doxygen for every public class, struct, and method.
- Update comments when modifying existing code.
- Purpose, parameters, return values, and any unique behavior must be documented.

### Additional Comment Rules

- Add a “Reasoning” note for code with non-obvious constraints (timing, DSP behavior, JUCE quirks).

## Issues & Pull Requests

- Issues should be small and scoped to one feature.
- Every issue corresponds to a local document in `docs/issues/ISSUE-XX.md`.
- Do not begin implementation until the issue document is reviewed and approved.
- PRs should reference related docs, tests, and architecture notes.

### Additional PR Workflow

- Every PR must contain:
  - A summary of changes
  - A recap of the approved plan
  - A checklist verifying tests, docs, and architecture updates
- PRs must never introduce undocumented architecture changes.

## Naming Conventions

- Classes use PascalCase: `TurnTabbyAudioProcessor`
- Files use PascalCase: `PluginProcessor.cpp`
- Tests use PascalCase: `PluginTests.cpp`
- Scripts use kebab-case: `run-tests.sh`

### Additional Naming Rules

- Avoid abbreviations unless already used in the project.
- Avoid overly-generic names (`Manager`, `Helper`, `Util`); be explicit.

## Special Instructions

- Never copy any copyrighted material directly.
- All notation must be original and visually distinct.
- New features must align with `strategy.md`.
- Check existing docs and tests before adding new code.

### Additional Special Notes

- When something feels like it “should be refactored,” ask before doing it.
- Generated UI code must respect MVVM and never mix model/view logic.
