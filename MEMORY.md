# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.3.1.2` — aligned Perl/Rust scalar numeric helper values with v1.
- latest_commit: `09f0012b` — `LUA-BACKEND-PARITY.4.3.3.1.1 - adopt scalar numeric helper contract`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.3.1.2 - align Perl Rust scalar numeric helpers`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.3.1.3`; align Dart and Julia scalar numeric helpers with v1.
- next_action: make Dart/Julia consume all 55 unchanged cases through direct canonical calls, repairing strict
  numeric parsing, exact arities, invalid/null results, half-away rounding, and signed floor modulo.
- current_proof: Perl/Rust use narrow strict adapters and pass all 55 cases. Canonical local CI passes Perl CLI
  61x2 plus phase0 `1..1030`; the Rust local gate passes its complete package and CLI 61x2; rustfmt/clippy pass.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Perl/Rust scalar numeric v1 alignment prepared for commit; generated
  artifacts clean.
