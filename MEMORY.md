# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.4.2.2` — implemented neutral variadic functions on Rust.
- latest_commit: `e8f8fd23` — `FUTURE-PARITY-BACKLOG.4.2.1 - implement Perl variadic functions`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.4.2.2 - implement Rust variadic functions`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.4.3.1`; implement the unchanged contract in Dart.
- next_action: after committing the clean Rust handoff, update Dart spec projection, registry/action contracts,
  descriptor, native/generated rest binding, diagnostics, and contract-consuming proof without host rest semantics.
- current_proof: Rust exact v1 and variadic v2 parsed/compiled/staged/outward/generated paths pass all seven focused
  contract tests, including fresh arrays, once-only ordered evaluation, invalid forms, and native/generated results.
  Core verification passes 185 unit + 3 descriptor + 8 type assertions. The fixture corrected Rust array `length`
  from zero to cardinality while preserving scalar Unicode character count. The authoritative Rust gate passes
  137 runtime units, interpreter/generated 105-case proofs, 197 integration tests, and both CLI matrices at 61/61.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Rust variadic AST/compiler/descriptor/runtime/test/docs are fully verified
  and prepared for commit. Lua scalar numeric `.4.3.3.1.4` remains ready after this activity.
