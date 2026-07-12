# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.3.4` — Perl callable-codeblock no-drift closeout.
- latest_commit: `51532e79` — `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1`; split and execute uniform binding plus spec-facing aggregate-
  selector retirement.
- next_action: inventory every `.spec`, parser/lowering, fixture, test, and public-doc use of
  `array(IDENTIFIER)` / `hash(IDENTIFIER)`; split migration, diagnostics, per-backend removal, and hard-retirement
  leaves before behavior code. Selector survival is not open; classify ordinary non-selector constructors apart.
- current_proof: Perl closeout toolbox probes show byte-equivalent contextual forms and typed descriptors; source
  and telemetry scans find zero raw-host/fallback/compatibility/unresolved residue, stored coderef/capture, parser
  allowlist, or harray drift. Four focused suites pass 100 tests. The strict checker, capability 60/0/0, CLI 61x2,
  and Phase 0 `1..1030`/916s are green on the exact committed behavior.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); Rust/Dart/Julia codeblock parity and resumed Lua work follow `.12.1`.
- blockers: none. in_flight_uncommitted: `.11.3.4` docs/no-drift closeout is prepared for gates and commit.
  Lua scalar numeric `.4.3.3.1.4` remains ready after the prioritized selector-retirement arc.
