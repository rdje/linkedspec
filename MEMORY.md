# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.1` — neutral selector-free uniform-binding contract.
- latest_commit: `fa99a244` — `FUTURE-PARITY-BACKLOG.12.1.0 - split aggregate selector retirement`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.1 - adopt uniform binding contract`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.2`; implement the unchanged contract on Perl.
- next_action: add focused Perl future-fixture/diagnostic probes, then make bare binding reads/mutations consume
  typed values with static-rule push precedence, mutable three-argument split, set/mutation results, and no public
  storage distinction; retain old selectors only until dependency-ordered source migration.
- current_proof: Strict `linkedspec-uniform-binding-v1` checks 11 migrations, seven execution cases, six invalid
  selectors, eight valid constructors/literals, and deterministic future source/results. It fixes storage-neutral
  one-binding semantics, post-assignment set, updated mutations, absent/wrong-kind behavior, static push precedence,
  pure/mutable split, `aggregate_selector_removed`, and `[value]` for one-element construction. Canonical CI passes
  capability 60/0/0, CLI 61x2, and Phase 0 `1..1030` in 875 seconds.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); Rust/Dart/Julia codeblock parity and resumed Lua work follow `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.1` contract/checker/CI/docs/Knowledge Map is prepared for full gate
  and commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the selector-retirement arc.
