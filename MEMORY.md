# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.3.1.3` — aligned Dart/Julia scalar numeric helpers with v1.
- latest_commit: `a66d8432` — `LUA-BACKEND-PARITY.4.3.3.1.2 - align Perl Rust scalar numeric helpers`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.3.1.3 - align Dart Julia scalar numeric helpers`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.4.0`; audit and split purpose-specific callable arity plus explicit
  variadic user-defined function signatures before behavior code, per the director's 2026-07-12 directive.
- next_action: after committing/cleaning `.1.3`, inspect the grammar, descriptor/staged-job contracts, call
  validators, native/generated runtimes, and Lua plan; then split neutral syntax and backend rollout under `.4`.
- current_proof: Perl/Rust/Dart/Julia all consume the unchanged 55-case scalar numeric v1 fixture. Dart passes
  format/analyzer/184 tests/61x2 CLI/105 corpus; Julia passes its complete package, primary CLI, and 105 corpus.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Dart/Julia scalar numeric v1 alignment prepared for commit; generated
  artifacts clean. Lua scalar numeric `.4.3.3.1.4` remains ready after the director-prioritized variadic audit.
