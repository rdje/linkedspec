# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.7.3` — execute governed Lua named writers, spans, and bridges.
- latest_commit: `8adf47f8` — `FUTURE-PARITY-BACKLOG.17.5 - admit complete named mark inventory`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.7.3 - execute Lua named mark spans`.
- active_work_unit: `.4.3.7.3` is implemented, synchronized, and fully verified; only its prepared commit, brief
  cleanup, and clean-tree check remain.
- next_action: run final memory/doctrine/book/staged checks, commit `.4.3.7.3`, clear the brief, verify a clean tree,
  then durably capture the agreed parity-gated structured-format direction before resuming active `.4.3.7.4`.
- current_proof: the unchanged governed named-capture fixture returns its exact native and reconstructed values.
  A supplemental multibyte case locks current/input/anonymous/copy writers, both anonymous/named bridges,
  stable and advancing spans, missing/reversed neutral reads, valid-only mutation, Unicode-character public
  positions, and typed one-/two-argument arity. `capture_take()` remains anonymous while `capture_take(name)` is
  named. The complete Lua gate passes 120/120 on PUC Lua and LuaJIT plus syntax, CLI-scaffold, and 105 manifests.
  Canonical CI passes capability 64/0/0, coverage 246/105+1/122, CLI 61x2, and Phase 0 `1..1031` in 637 seconds.
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
- blockers: none. in_flight_uncommitted: fully verified `.4.3.7.3` runtime/tests/docs/KM await the prepared commit
  only; do not pivot before it lands and the tree is clean. Oracle timeout calibration remains future `.7.0`.
