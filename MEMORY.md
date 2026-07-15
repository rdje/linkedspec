# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.18.2` — selective end-to-end parser observability governance.
- latest_commit: `bb9c07f0` — `FUTURE-PARITY-BACKLOG.18.2 - govern selective parser observability`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.18.3 - plan optional native parser acceleration`.
- active_work_unit: planning-only `.18.3` is fully aligned and awaits verification/commit before the clean return
  to Lua fixed-v1 runtime `.5.1.2`.
- next_action: verify/commit/clean `.18.3`, then open a separate task-tree leaf to assess targeted Rust
  `cargo-mutants` adoption before resuming Lua registered fixed-v1 runtime `.5.1.2`.
- current_proof: ADR `0038` and `NATIVE-PARSER-ACCELERATOR` preserve immediate dynamic parsing as primary,
  oracle, and fallback. Generated-source v1 is a semantic foundation, not a speed claim. Any later native artifact
  must be a fingerprinted normalized-IR derivative with exact AST/diagnostic/Unicode/recovery/trace equivalence,
  explicit toolchain/trust boundaries, and objective build/load/break-even benefit. The horizon is non-blocking,
  backend-specific internally, and optional for Perl. No behavior, format support, or performance claim changes.
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
- blockers: none. in_flight_uncommitted: `.18.3` planning/docs/ADR/task/KM/book alignment awaits gates and its
  prepared commit; no code or runtime behavior changed.
