# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.18.1` — govern expressive universal `.spec` authoring.
- latest_commit: `1e8a1d1f` — `FUTURE-PARITY-BACKLOG.18.1 - govern expressive spec authoring`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.19.0 - plan write vivification and bang mutation`.
- active_work_unit: `.19.0` has audited current five-backend nested writes, traversal callbacks/paths, and method
  grammar; ADR `0036` plus task/roadmap/book/KM/live synchronization are drafted. Final focused governance/book
  checks, commit, brief cleanup, and clean-tree verification remain.
- next_action: verify and commit `.19.0`, clear the brief, confirm a clean tree, then resume executable Lua
  exhaustive capture/cursor/public-surface no-drift `LUA-BACKEND-PARITY.4.3.7.6`. Keep `.19.1+` pending until
  complete current-backend parity.
- current_proof: current nested writes do not vivify intermediates; Perl direct, Rust 3/3, Dart focused, Julia
  complete stacked-depot, and Lua 121/121 dual-ABI proof pass. Current method tokens exclude `!`. ADR `0036`
  accepts write-only deterministic creation, dense arrays, no coercion, atomic commit, and only named-receiver
  `map_leaves!` v1; callback result replaces leaves through stable paths and `value` remains non-aliased.
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
- blockers: none. in_flight_uncommitted: `.19.0` planning/audit/docs/KM source await focused verification and
  prepared commit. Do not resume `.4.3.7.6` before this lands and the tree is clean. `.19.1+` and the structured-
  format execution tree remain dependency-gated on complete current parity.
