# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.3.1` — implemented inert Perl callable-codeblock literals.
- latest_commit: `5812d6f8` — `FUTURE-PARITY-BACKLOG.11.2 - adopt callable codeblock contract`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.3.1 - parse Perl callable codeblock literals`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.11.3.2`; execute Perl codeblock-variable calls dynamically.
- next_action: after committing `.11.3.1`, extend Perl call resolution after static/user-function lookup to
  recognize validated codeblock records, then implement ordered temporary bindings and dynamic body execution.
- current_proof: 126 focused assertions prove exact Perl brace/signature/body/span AST, all nine malformed codes,
  inert canonical JSON/ASCII-hex generated construction, assignment/copying, and user-function argument/results.
  Canonical CI passes 61x2 CLI plus Phase 0 `1..1030`/575s; `cb(args)` is intentionally not implemented yet.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: `.11.3.1` Perl parser/lowering/test/CI and synchronized durable docs are
  being prepared for commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the prioritized `.11` arc.
