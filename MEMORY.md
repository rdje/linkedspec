# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.1.2` — added reusable typed non-aborting corpus execution records.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.6.1.2 - add Lua library corpus execution`.
- prepared_commit: `none`.
- active_work_unit: permanent ordered 40-case core corpus prefix `LUA-BACKEND-PARITY.6.1.3`.
- next_action: add permanent library-executor assertions for exact manifest offsets 0-39 on PUC Lua and LuaJIT,
  locking order, boundary names, zero failures, exact wrapped outputs, and unchanged endpoints.
- current_proof: The Lua executor validates the full strict manifest before named/offset/limit selection, composes
  automatic function-aware parse, explicit validation/compile, exact source-identified engine/runtime execution,
  and structurally compares one wrapped typed-JSON value. Typed records retain copied observations, match,
  byte/character endpoints, trace, diagnostic, failure stage/text; every selected fixture runs after failures.
  Controlled scalar/aggregate/dispatch/lifecycle/function/boundary/failure/selection proof passes 160/160 on PUC
  Lua and LuaJIT. CLI remains validation-only; status is `native-full-pipeline-trace-v1`, capability is 64/0/0,
  and fixtures/permanent windows are unchanged. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in
  623 seconds; `.6.1.3` precedes capability/no-drift `.6.1.4`. Mutation testing remains manual-only.
- latest_bootstrap_read: 2026-07-15 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.6.1.3`; controlled corpus execution and typed nested-path repair are durable.
  in_flight_uncommitted: none after `.6.1.2`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
