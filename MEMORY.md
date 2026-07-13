# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.7.2` — file-backed aggregate-selector migration.
- latest_commit: `65d8902d` — `FUTURE-PARITY-BACKLOG.12.1.7.1 - migrate shipped aggregate selectors`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.7.2 - migrate file-backed selector fixtures`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.7.3`; migrate embedded test/tool/backend source strings next.
- next_action: inventory exact selector-shaped executable source strings by owner, migrate only `.12.1.7.3`, and
  prove zero executable selector sources before activating hard rejection.
- current_proof: `.12.1.7.2` removes 390 exact forms from 67 file-backed capability/oracle/corpus specs; every
  tracked `*.spec` scans at zero and capability mirrors agree. Rust/Dart/Julia permanent uniform-binding tests and
  complete gates pass; Rust and Dart/Julia corpora pass 105/105, and Lua dual-ABI passes 85/85 while validating the
  manifest. Canonical doctrines/contracts, capability 60/0/0, CLI 61x2, and Phase 0 `1..1031`/574s pass.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); Rust/Dart/Julia codeblock parity and resumed Lua work follow `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.7.2` migration/runtime repairs/tests/docs passed all gates and await
  commit. Lua scalar numeric `.4.3.3.1.4` remains ready after selector retirement.
