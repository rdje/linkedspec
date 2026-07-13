# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.5.3.1` — copied harray transforms and receiver composition.
- latest_commit: `722ee8ff` — `LUA-BACKEND-PARITY.4.3.5.3.0 - revalidate harray transform contracts`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.5.3.1 - add Lua copied harray transforms`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.5.4`; add named harray mutation and direct-assignment coverage.
- next_action: implement `.4.3.5.4` only: statement `set_key`, direct key assignment, typed-store preservation,
  wrong-kind errors, and independent returned snapshots.
- current_proof: Lua `merge_hash`, value-form `set_key`, `rename_key`, `drop_keys`, and `pick_keys` now return
  deep-copied harray values and compose through receivers; later merge arguments override earlier keys. The Lua
  harness passes 102/102 on PUC Lua and LuaJIT. Rename collisions remain a known cross-backend difference:
  Perl/Julia preserve the renamed old value, Dart/Rust preserve the existing destination; backlog leaf `.5`
  owns normalization and portable specs currently rename only to absent keys.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: `.4.3.5.3.1` implementation, tests, KM fact, task-tree, live docs, and
  mdBook synchronization await their prepared commit. Oracle timeout calibration remains `.7.0`.
