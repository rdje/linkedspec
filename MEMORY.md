# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.3.2` — implemented dynamic Perl callable-codeblock invocation.
- latest_commit: `cb7981bc` — `FUTURE-PARITY-BACKLOG.11.3.1 - parse Perl callable codeblock literals`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.3.2 - execute Perl callable codeblocks`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.11.3.3`; generalize Perl final-codeblock syntax by callable signature.
- next_action: after committing `.11.3.2`, inspect callable signature ownership and normalize attached plus
  parenthesized contextual final blocks without helper-name special cases; retain `with` as ordinary.
- current_proof: exact neutral live and standalone generated execution passes dynamic reads, persistent mutation,
  copied/restored fixed/rest params, local return, receiver continuation, result drop, static precedence, and typed
  failures. Focused callable/ActionIR/variadic/generated-source proof passes 97 top-level tests; canonical CI
  passes the 60/0/0 capability census, both 61-case CLI environments, and Phase 0 `1..1030` in 815 seconds.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: `.11.3.2` Perl runtime/lowering/test/docs and canonical proof are complete
  and awaiting commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the prioritized `.11` arc.
