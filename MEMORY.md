# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.7.6` — close native Lua capture/cursor parity.
- latest_commit: `5c73e59b` — `LUA-BACKEND-PARITY.4.3.7.6 - close Lua capture cursor parity`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.8 - add Lua diagnostic output events`.
- active_work_unit: `.4.3.8` adds eager `print`/`say`/`print_each` execution over an optional per-parse typed
  caller sink, retains quiet/parse-neutral defaults and immediate `exit_now`, and routes discovered cross-backend
  output drift to dependency-gated `FUTURE-PARITY-BACKLOG.5.1`.
- next_action: finish lockstep/checks, commit `.4.3.8`, clear the brief, confirm a clean tree, then audit and close
  exhaustive Lua helper/value/control/method no-drift under active `.4.3.9`.
- current_proof: PUC Lua and LuaJIT pass 122/122 with eager one-time order, Unicode, typed event JSON, quiet default,
  parse-result neutrality, sink/arity failures, and immediate exit. Canonical CI passes capability 64/0/0,
  coverage 246/105+1/122, CLI 61x2, and Phase 0 `1..1031` in 611 seconds; `.18.1+`, `.19.1+`, structured formats,
  and diagnostic normalization `.5.1` remain gated on complete current-backend parity.
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
- blockers: none. in_flight_uncommitted: `.4.3.8` runtime/test/docs/KM/task changes pass the dual-ABI gate and await
  governance/book/full relevant checks plus commit before the clean pivot to `.4.3.9`.
