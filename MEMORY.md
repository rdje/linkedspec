# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.1.1` — deterministic staged ActionIR-body dispatch and stitching.
- latest_commit: `ded8654a` — `LUA-BACKEND-PARITY.5.1.1 - add Lua staged body dispatch`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.18.2 - govern selective parser observability`.
- active_work_unit: planning-only `.18.2` is fully aligned and verified; its prepared commit remains before the
  clean return to Lua fixed-v1 runtime `.5.1.2`.
- next_action: commit/clean `.18.2`, record the director's optional native-accelerator horizon in a separate
  planning leaf, commit/clean it, then resume Lua registered fixed-v1 runtime `.5.1.2`.
- current_proof: ADR `0037` and format-program `.2.7` require correlated construction/runtime trace, exact
  emission-only rule filters, bounded payloads, stable identity, and shared traced/untraced cross-backend proof.
  Existing six levels/sinks remain. Dart/Julia full pipeline is confirmed; stale Dart book drift is removed; Lua
  runtime trace is complete while `.5.3` retains full native-pipeline propagation. Knowledge Map, task metadata,
  doctrines, mdBook, memory architecture, and whitespace pass. No behavior changes.
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
- blockers: none. in_flight_uncommitted: `.18.2` planning/docs/ADR/KM plus the stale Dart trace-book repair are
  verified and await their prepared commit; no code or runtime behavior changed.
