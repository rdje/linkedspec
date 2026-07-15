# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.3.1` — exact outward v1/v2/v3 descriptor union and Lua emission.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.3.1 - admit Lua function descriptors`.
- prepared_commit: `none`.
- active_work_unit: one-emitter full native-pipeline trace `LUA-BACKEND-PARITY.5.3.2`.
- next_action: inventory the exact optional-emitter propagation signatures/events from native loading through
  frontend, validation, compile, function-shell, staged dispatch, engine construction, and runtime before editing.
- current_proof: the executable outward contract now locks fixed-v1, variadic-v2, and final-codeblock-v3 records.
  Lua emits all three with identical staged metadata and exact order/count; Perl's existing final-codeblock outward
  projection is v3 without runtime change. PUC Lua and LuaJIT pass 153/153; signature/codeblock checkers pass
  3/9/7 and 7/11/9/7/4/8; focused Perl suites pass 76; capability remains four-backend 64/0/0 until `.8.4`.
  Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 616 seconds. Mutation testing remains manual-only
  and was not run.
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
- blockers: none for `.5.3.2`; the exact one-emitter seam inventory precedes source edits.
  in_flight_uncommitted: none after `.5.3.1`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
