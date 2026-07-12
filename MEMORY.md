# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.4.3.2` — implemented neutral variadic functions on Julia.
- latest_commit: `a5fff011` — `FUTURE-PARITY-BACKLOG.4.3.1 - implement Dart variadic functions`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.4.3.2 - implement Julia variadic functions`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.4.4`; close no-drift and route Lua variadic parity.
- next_action: after committing the clean Julia handoff, audit the four admitted backend/public surfaces for drift,
  then add Lua frontend/runtime/generated obligations to its first dependency-complete user-function owner.
- current_proof: Julia exact v1 and variadic v2 spec/staged/registry/action/descriptor/native/generated paths pass 55
  neutral assertions, including fresh arrays, ordered evaluation, invalid/keyword calls, canonical emitted hex
  state, generated execution, and reconstruction. The authoritative gate passes all package tests, both CLI
  matrices at 61/61, and all 105 corpus fixtures.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Julia variadic AST/staged/registry/action/descriptor/runtime/generated/test
  and docs are fully verified and prepared for commit. No-drift/Lua routing `.4.4` is next.
