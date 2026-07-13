# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.11` — align array-end updated results across behavior/docs.
- latest_commit: `c71cd9be` — `LUA-BACKEND-PARITY.4.3.4.0 - split Lua array helper mechanisms`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.11 - align array end mutation results`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.4.1`; copied array construction/splicing.
- next_action: audit the existing Lua constructor/flat/concat seams, then implement only `.4.3.4.1`.
- current_proof: all four array-end mutations return independent updated arrays across Perl/Rust/Dart/Julia/Lua;
  Perl value positions and compatible continuations are fixed and a 48-file public/KM checker passes. Lua remains
  91/91 on both ABIs before copied construction begins.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: none after the prepared `.12.1.11` commit. Lua array construction
  `.4.3.4.1` is next. Oracle timeout calibration remains deferred to `.7.0`.
