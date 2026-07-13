# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.5` — Julia selector-free uniform-binding execution.
- latest_commit: `5c17f67e` — `FUTURE-PARITY-BACKLOG.12.1.4 - enable Dart uniform bindings`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.5 - enable Julia uniform bindings`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.6`; implement the unchanged contract on Lua after this commit.
- next_action: consume the neutral fixture on both Lua ABIs; unify bare push/append/mutable split/hash/index/
  collection mutation/results while preserving static precedence and temporary selector input.
- current_proof: Julia focused native/generated contract passes 27/27; complete package passes 1,311 assertions,
  CLI 61x2, and 105/105 corpus. Canonical CI passes doctrines/contracts, capability 60/0/0, Perl
  CLI 61x2, and Phase 0 `1..1030` in 865 seconds; docs/KM/governance pass.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); Rust/Dart/Julia codeblock parity and resumed Lua work follow `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.5` Julia code/tests/docs/Knowledge Map passed final gates and awaits
  commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the selector-retirement arc.
