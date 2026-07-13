# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.8.6` — five-backend selector-retirement no-drift.
- latest_commit: `0331638a` — `FUTURE-PARITY-BACKLOG.12.1.8.5 - hard-reject Lua aggregate selectors`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.8.6 - enforce selector retirement no-drift`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.9`; active after the prepared `.12.1.8.6` commit, not yet started.
- next_action: execute final public docs/examples/capability/no-drift admission `.12.1.9`.
- current_proof: canonical checker requires all five six-case/portable-field suites and compiled-state boundaries,
  eight retained classes, zero known runtime compatibility, and the composed executable-source scan. Perl 11,
  Rust 15/15, Dart 15/15, Julia 59/59, and dual-ABI Lua 88/88 pass; checker reports 0 runtime/0 positive/19 classified.
  Canonical CI passes capability 60/0/0, CLI 61x2, and Phase 0 `1..1031`/616s.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: none after the prepared `.12.1.8.6` commit. Final public admission
  `.12.1.9` is next. Oracle timeout calibration remains deferred to `.7.0`.
