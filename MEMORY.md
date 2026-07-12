# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.4.2.1` — implemented neutral variadic functions on Perl.
- latest_commit: `7407a27e` — `FUTURE-PARITY-BACKLOG.4.1 - adopt variadic callable contract`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.4.2.1 - implement Perl variadic functions`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.4.2.2`; implement the unchanged contract in Rust.
- next_action: update Rust parsed/compiled/described signatures, registry-first min/exact call resolution, native
  and generated fresh rest binding, diagnostics, and contract-consuming proof without changing the neutral JSON.
- current_proof: Perl exact v1 and variadic v2 grammar/staged/outward/generated paths pass the unchanged neutral
  fixture plus 66 focused assertions, including both grammar owners, fresh arrays, and once-only evaluation. The fixture
  exposed and corrected Perl array `.length()` address-string drift; scalar length remains unchanged. Full canonical
  CI passes 61x2 CLI and Phase 0 `1..1030` in 710 seconds after migrating 13 measured stale source locks.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Perl variadic grammar/registry/lowering/test/docs prepared for verification
  and commit; generated artifacts clean. Lua scalar numeric `.4.3.3.1.4` remains ready after this activity.
