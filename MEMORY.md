# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.16.4` — implemented zero-argument aliases on Dart.
- latest_commit: `2be3d826` — `FUTURE-PARITY-BACKLOG.16.3 - implement Rust zero-argument aliases`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.16.4 - implement Dart zero-argument aliases`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.16.5`; implement the unchanged alias surface on Julia/generated paths.
- next_action: inspect Julia's existing five-marker normalization, statement-context bare-next handling, terminal
  receiver parser, generated reconstruction, and neutral fixture before the smallest typed-parser change.
- current_proof: Dart maps six standalone and four terminal receiver aliases to parenthesized typed twins without
  broadening conditions/calls; native, generated-plan, emitted-state, and CLI fixture output is exact. Complete
  Dart gate passes format, strict analysis, 211 package tests, CLI 61x2, and corpus 105/105. Rust and Dart's
  pre-existing `.contains()` missing-argument outcomes are tracked under helper owner `.5`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua built-in final blocks `.4.3.6.4`; parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.16.4` Dart implementation/task/book/KM/live-doc synchronization
  awaits its prepared commit. Oracle timeout calibration remains `.7.0`.
