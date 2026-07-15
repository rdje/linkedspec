# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.4.4` — native runtime diagnostics/trace no-drift.
- latest_commit: `70f35dce` — `LUA-BACKEND-PARITY.4.4.4 - close Lua diagnostics trace no drift`.
- prepared_commit: `LUA-BACKEND-PARITY.5.1.0 - split Lua staged function execution`.
- active_work_unit: planning `.5.1.0` split, durable alignment, focused baseline, neutral contract, book, Knowledge
  Map, and doctrine verification are complete; its prepared commit remains before `.5.1.1` code.
- next_action: commit and clean `.5.1.0`, then implement minimal staged action-body dispatch `.5.1.1`.
- current_proof: Lua already owns exact-v1 function projection, staged sidecars, registry-first contracts, isolated
  pre-execution frames, compiled records, generic trailing-block AST, and built-in contextual blocks; it lacks body-
  job dispatch and registered-call runtime. `.5.1.1` owns dispatch first. Baseline stays PUC Lua/LuaJIT 129/129,
  coverage 246/105+1/122, capability 64/0/0, and public status `runtime-trace-events`. Descriptors/full trace remain
  `.5.3`, generated source `.8`, and explicit callable literals/bound calls `.11.7`.
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
- blockers: none. in_flight_uncommitted: `.5.1.0` planning/task/book/KM/live alignment passes focused 129/129 on
  both Lua ABIs, neutral callable contracts, and governance gates; commit remains before `.5.1.1` code.
