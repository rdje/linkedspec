# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.3.1.4` — Lua scalar numeric v1 and six-runtime admission.
- latest_commit: `93c44af9` — `FUTURE-PARITY-BACKLOG.12.1.9 - admit selector-free public surface`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.3.1.4 - implement Lua scalar numeric helpers`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.3.2`; numeric alias/symbol/number-receiver admission after commit.
- next_action: audit and admit Lua numeric word aliases, symbol callees, and first-argument number receiver chains.
- current_proof: the unchanged 55-case scalar numeric v1 fixture matches exactly through Perl, Rust, Dart, Julia,
  PUC Lua, and LuaJIT. Both Lua ABIs pass 89/89 plus the exact 105-manifest/CLI scaffold; neutral scalar numeric
  checker reports 55 cases/18 canonical helpers.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: none after the prepared `.4.3.3.1.4` commit. Numeric aliases/receivers
  `.4.3.3.2` are next. Oracle timeout calibration remains deferred to `.7.0`.
