# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.6.0` — block/control/callback mechanism and dependency split.
- latest_commit: `da2311d4` — `LUA-BACKEND-PARITY.4.3.5.5 - close Lua harray helper parity`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.6.0 - split Lua block control callback mechanisms`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.6.1`; execute eager expression blocks and block-local return.
- next_action: implement one eager block executor in Lua, keep contextual trailing block arguments inert until
  consumed, add focused last-value/empty/local-return/harray-boundary proof, and run dual-ABI plus doc gates.
- current_proof: parser/resolver already preserve block/control/final-argument structure; interpreter returns inert
  block copies and has no control/callback dispatch. `.4.3.6` is split by runtime mechanism. General user-function
  final blocks stay `.5.1`; explicit callable values stay future `.11.7`. Existing dual-ABI behavior is 103/103.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: `.4.3.6.0` task split, dependency routing, KM fact, live docs, and mdBook
  synchronization await their prepared commit. Oracle timeout calibration remains `.7.0`.
