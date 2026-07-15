# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.18.3` — optional native parser acceleration governance.
- latest_commit: `eab09b48` — `FUTURE-PARITY-BACKLOG.18.3 - plan optional native parser acceleration`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.20.0 - plan targeted Rust mutation testing`.
- active_work_unit: planning/list-only Rust mutation-testing `.20.0` is aligned and awaits gates/commit before the
  clean return to Lua fixed-v1 runtime `.5.1.2`.
- next_action: verify/commit/clean `.20.0`, then resume Lua registered fixed-v1 runtime `.5.1.2`; mutation
  configuration/pilot remains parked at `RUST-MUTATION-TESTING.1+` for an explicit later campaign.
- current_proof: ADR `0039` adopts cargo-mutants only for explicit on-demand or milestone/release campaigns, never
  per commit, pre-commit, or ordinary local CI. Installed 27.0.0 lists 3,333 candidates across 19 files (core
  1,217; runtime 2,116) without executing a mutant. Survivors/timeouts/unviable results require distinct durable
  dispositions; the generated Unicode table is the initial generator-backed exclusion. No score exists and no
  Rust code, test, CI behavior, or Lua priority changed.
- latest_bootstrap_read: 2026-07-14 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: `.20.0` task/ADR/KM/roadmap/book/live-doc planning plus list-only census
  awaits gates and its prepared commit; no mutant ran and no code/test/CI behavior changed.
