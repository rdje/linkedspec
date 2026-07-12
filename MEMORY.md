# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.4.4` — closed four-backend no-drift and routed Lua variadic parity.
- latest_commit: `0d7627e2` — `FUTURE-PARITY-BACKLOG.4.3.2 - implement Julia variadic functions`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.4.4 - close variadic callable routing`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.3.1.4`; implement Lua scalar numeric v1 and admit six runtimes.
- next_action: after committing the clean callable-routing handoff, consume all 55 scalar numeric cases in one Lua
  evaluator on PUC Lua/LuaJIT and prove exact six-runtime results before alias/receiver work.
- current_proof: Perl/Rust/Dart/Julia exact v1 and variadic v2 native/generated paths consume one neutral contract.
  Lua native parity is durably routed to `.5.1`, descriptor admission to `.5.3`, and generated preservation,
  execution, proof, and capability retirement to `.8.1-.4`; no Lua behavior is claimed early.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: callable no-drift and Lua ownership routing are documentation-only,
  verified, and prepared for commit. Lua scalar numeric `.4.3.3.1.4` remains the executable frontier.
