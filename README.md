# LinkedSpec
LinkedSpec is a progressive extraction parser DSL for fast parser prototyping with strong support for recursion, nested constructs, and staged coarse-to-fine parsing.

This `README.md` is the **single entry point** to the project.

## Project Objective
- Provide a robust, trustworthy parser-prototyping platform that is intentionally different from strict EBNF-centric tooling.
- Preserve LinkedSpec strengths (recursive parsing + multi-pass extraction workflows).
- Evolve `.spec` toward language-agnostic action semantics over time.

## Fast Ramp-Up Documentation Map
Read these in order for fastest onboarding:

1. `README.md` (this file)
   - Project objective, navigation, and key paths.
2. `ROADMAP.md`
   - Strategy, phases, priorities, and current execution direction.
3. `USER_GUIDE.md`
   - How to write and use `.spec` grammars and parser workflows.
   - Includes the plain paragraph-based mental model for `.spec` file structure.
4. `DEVELOPMENT_NOTES.md`
   - Architecture rationale and implementation decisions.
5. `CHANGES.md`
   - Technical change history, validation records, and migration slices.
6. `MEMORY.md`
   - Interruption-safe continuation context and recent execution state.
7. `COMMIT.md`
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
- `plugin/`, `conf/`, `tablescript/`, `ebnf/`
  - Corpus and real-project inputs used in regression/integration flows.

Top-level project docs:
- `README.md`
- `ROADMAP.md`
- `USER_GUIDE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`
- `COMMIT.md`

## Local CI
- Run `bash tools/run_ci_local.sh` from the repo root to execute the same gate used by GitHub Actions.
- `.github/workflows/ci.yml` delegates to that shared script so local validation and GitHub CI stay aligned.

## Maintenance Policy for README
- `README.md` must remain the single project entry point.
- Update `README.md` whenever project objective, onboarding flow, key doc links, or key path layout changes.
- `README.md` does **not** need to be updated on every commit—only when such updates are needed.

## Git Version-Control Status
- `README.md` is intended to remain git-tracked at all times.
