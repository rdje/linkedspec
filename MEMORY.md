# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.8.4` — Julia aggregate-selector hard rejection.
- latest_commit: `88fd9fad` — `FUTURE-PARITY-BACKLOG.12.1.8.3.2 - close Dart selector retirement`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.8.4 - hard-reject Julia aggregate selectors`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.8.4`; fully verified and awaiting final governance/commit.
- next_action: commit `.12.1.8.4`, verify clean, then begin Lua rejection `.12.1.8.5`.
- current_proof: six exact selector cases reject across complete native/generated compiled state; dead/fluent/unused
  and caller-constructed payloads are covered; runtime selector dispatch is deleted; all eight retained classes
  pass. Focused proof is 59/59; scan 0/15; Julia 1,339 assertions/61x2/105 and canonical Phase 0 `1..1031` pass.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.8.4` code/tests/docs await final governance and commit; Lua
  `.12.1.8.5` follows. Oracle timeout calibration remains deferred to `.7.0`.
