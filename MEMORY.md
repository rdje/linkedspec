# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.8.5` — Lua aggregate-selector hard rejection.
- latest_commit: `da0a0032` — `FUTURE-PARITY-BACKLOG.12.1.8.4 - hard-reject Julia aggregate selectors`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.8.5 - hard-reject Lua aggregate selectors`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.8.5`; fully verified and awaiting docs/governance/commit.
- next_action: commit `.12.1.8.5`, verify clean, then begin cross-variant no-drift `.12.1.8.6`.
- current_proof: six exact cases reject across typed/deferred compiled state and caller-mutated engine input; runtime
  selector read/target/receiver/split/transform dispatch is deleted; all eight retained classes pass. PUC Lua and
  LuaJIT each pass 88/88; exact 105-manifest/CLI scaffold and executable scan 0/19 pass.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.8.5` code/tests/docs await governance and commit; cross-variant
  `.12.1.8.6` follows. Oracle timeout calibration remains deferred to `.7.0`.
