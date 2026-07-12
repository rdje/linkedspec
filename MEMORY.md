# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.2.4` — Lua explicit array split mutation.
- latest_commit: `ae340db6` — `LUA-BACKEND-PARITY.4.3.2.2.3 - add Lua scalar regex mutation`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.2.2.4 - add Lua array split mutation`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.2.2.5`; close regex/split/mutation corpus and public no-drift.
- next_action: run the owned shipped-corpus cases through Lua execution, compare exact checked-in results, repair any
  bounded drift, and reconcile public helper/status surfaces before closing `.4.3.2.2`.
- current_proof: dropped `split(array(target), source, delimiter)` replaces only the explicit typed array store via
  copied pure literal/regex split semantics; scalar-held and source values stay unchanged. PUC Lua and LuaJIT pass
  76/76 with scalar regex mutation and pure split still green.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`.
- blockers: none. in_flight_uncommitted: array split mutation implementation/docs prepared for commit; generated
  artifacts clean.
