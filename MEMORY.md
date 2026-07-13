# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.8.3.1` — Dart exact aggregate-selector rejection implementation.
- latest_commit: `055ab378` — `FUTURE-PARITY-BACKLOG.12.1.8.2 - hard-reject Rust aggregate selectors`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.8.3.1 - hard-reject Dart aggregate selectors`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.8.3.1`; focused-verified and awaiting docs/governance/commit.
- next_action: commit `.12.1.8.3.1`, verify clean, then activate `.12.1.8.3.2` to add exact variadic `blkVFN`
  structural matching and rerun the complete Dart gate before Julia.
- current_proof: Dart rejects all six exact-selector cases across complete compiled/generated state, including dead
  code, deferred fluent calls, unused functions, and caller-constructed payloads; eight retained classes pass.
  Focused proof is 15/15, strict analysis clean, and scanner 0 positive/14 classified. The complete package leg
  reaches 203 passes; only two aggregated `spec_spec_*` failures remain from fixed-`blkFN` bridge drift.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.8.3.1` implementation/tests/docs await governance and commit;
  `.12.1.8.3.2` is the exact full-gate prerequisite. Oracle timeout calibration remains deferred to `.7.0`.
