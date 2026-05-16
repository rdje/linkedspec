# LinkedSpec
LinkedSpec is a progressive extraction parser DSL for fast parser prototyping with strong support for recursion, nested constructs, and staged coarse-to-fine parsing.

This `README.md` is the **single entry point** to the project.

## Documentation Layers
- `docs/linkedspec-book/`
  - Public-facing book for the world outside the repo.
  - This is where LinkedSpec should explain what it does, how it works, and why it is designed the way it is.
- repo-root working docs
  - `USER_GUIDE.md`, `ARCHITECTURE_STATE.md`, `ROADMAP.md`, and related files remain valuable repo-native working references.
- task-tree tracking
  - `docs/TASK_TREE.md`, `docs/TASK_TREE_README.md`, and `docs/tasks/*.md` are the task-tree workflow: recursive decomposition, current frontier, PNT selection, blockers, decisions, and completion evidence for top-level tasks.
- continuity docs
  - `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `MEMORY.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `COMMIT.md` are internal execution/continuity docs.
  - They exist for crash recovery, session handoff, and implementation continuity, not as the main public narrative.

## Project Objective
- Provide a robust, trustworthy parser-prototyping platform that is intentionally different from strict EBNF-centric tooling.
- Preserve LinkedSpec strengths (recursive parsing + multi-pass extraction workflows).
- Evolve `.spec` toward language-agnostic action semantics over time.

## Fast Ramp-Up Documentation Map
Read these in order for fastest onboarding:

1. `README.md` (this file)
   - Project objective, navigation, and key paths.
2. `docs/linkedspec-book/`
   - Public-facing book for LinkedSpec.
   - Start here when you want the project explained as a coherent system rather than as a working repo.
3. `ROADMAP.md`
   - Strategy, phases, priorities, and current execution direction.
4. `docs/TASK_TREE.md`
   - Task-tree workflow: active trees, current frontier, PNT selection rules.
   - Read this when resuming work to see what was in flight and pick the next leaf.
5. `USER_GUIDE.md`
   - How to write and use `.spec` grammars and parser workflows.
   - Includes the plain paragraph-based mental model for `.spec` file structure.
6. `ARCHITECTURE_STATE.md`
   - Live architectural reading of the current codebase shape.
   - Use this to re-enter the project with the current implementation model and main hotspots in mind.
7. `DEVELOPMENT_NOTES.md`
   - Architecture rationale and implementation decisions.
8. `CHANGES.md`
   - Technical change history, validation records, and migration slices.
9. `MEMORY.md`
   - Interruption-safe continuation context and recent execution state.
10. `LIVE_ACHIEVEMENT_STATUS.md`
   - Current batch/workflow status and latest completed slice direction.
11. `COMMIT.md`
   - Commit workflow and commit hygiene conventions.

## Project File/Path Map
Top-level directories and files:

- `perl/`
  - Core implementation and runtime modules.
  - Primary core entrypoint: `perl/LinkedSpec.pm`
  - Supporting core modules include `perl/LinkedRE.pm` and `perl/PathSearch.pm`.
- `specs/`
  - LinkedSpec grammar/spec definitions (`*.spec`).
- `t/`
  - Test suites.
  - Primary regression gate: `t/phase0_regression.t`.
- `tools/`
  - Project tooling and diagnostics helpers.
  - Examples: `tools/inspect_spec_codegen.pl`, `tools/run_ci_local.sh`.
- `bin/`
  - Utility/command scripts.
- `.github/workflows/`
  - GitHub Actions automation.
  - Primary CI workflow: `.github/workflows/ci.yml`.
  - Hosted GitHub Actions CI is currently disabled to preserve account Actions minutes.
- `plugin/`, `conf/`, `tablescript/`, `ebnf/`
  - Corpus and real-project inputs used in regression/integration flows.

Top-level project docs:
- `README.md`
- `docs/linkedspec-book/`
- `ROADMAP.md`
- `USER_GUIDE.md`
- `ARCHITECTURE_STATE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`
- `LIVE_ACHIEVEMENT_STATUS.md`
- `COMMIT.md`

## Local CI
- Run `bash tools/run_ci_local.sh` from the repo root to execute the canonical regression gate.
- `.github/workflows/ci.yml` remains tracked and delegates to that shared script, but hosted automatic GitHub Actions runs are disabled until intentionally re-enabled.

## Maintenance Policy for README
- `README.md` must remain the single project entry point.
- Update `README.md` whenever project objective, onboarding flow, key doc links, or key path layout changes.
- `README.md` does **not** need to be updated on every commit—only when such updates are needed.
- Keep `ARCHITECTURE_STATE.md` in the doc map when it remains the live architecture snapshot for future sessions.

## Git Version-Control Status
- `README.md` is intended to remain git-tracked at all times.

Read SESSION_BOOTSTRAP.md and start from there.
