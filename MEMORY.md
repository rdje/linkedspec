# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.3.1.0` — split scalar numeric contract alignment.
- latest_commit: `c9b74339` — `LUA-BACKEND-PARITY.4.3.3.0 - split Lua numeric helper mechanisms`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.3.1.0 - split scalar numeric contract alignment`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.3.1.1`; adopt a neutral executable scalar numeric helper contract.
- next_action: write the ADR and machine-readable strict finite-decimal/arity/invalid/round/modulo contract plus an
  offline schema/value checker before changing any backend runtime.
- current_proof: Perl/Rust/Dart/Julia disagree on boolean input, invalid results, arity, numeric strings, and signed
  modulo. Lua remains 76/76 on both ABIs; no numeric behavior is admitted until the neutral contract lands.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: scalar numeric contract-alignment split prepared for commit; artifacts clean.
