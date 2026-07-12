# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.4.3.1` — implemented neutral variadic functions on Dart.
- latest_commit: `582882e2` — `FUTURE-PARITY-BACKLOG.4.2.2 - implement Rust variadic functions`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.4.3.1 - implement Dart variadic functions`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.4.3.2`; implement the unchanged contract in Julia.
- next_action: after committing the clean Dart handoff, update Julia spec projection, registry/action contracts,
  descriptor, native/generated rest binding, diagnostics, and contract-consuming proof without host splat dispatch.
- current_proof: Dart exact v1 and variadic v2 spec/staged/registry/action/descriptor/native/generated paths pass six
  focused contract tests, including fresh arrays, ordered evaluation, invalid/keyword calls, normalized emitted
  state, generated execution, and reconstruction. The authoritative gate passes format/analyze, 190 package tests,
  both CLI matrices at 61/61, and all 105 corpus fixtures.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Dart variadic AST/staged/registry/action/descriptor/runtime/generated/test
  and docs are fully verified and prepared for commit. Lua scalar numeric `.4.3.3.1.4` remains ready afterward.
