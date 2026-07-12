# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.4.1` — adopted the neutral variadic callable contract.
- latest_commit: `8f326e22` — `FUTURE-PARITY-BACKLOG.4.0 - split variadic callable signatures`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.4.1 - adopt variadic callable contract`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.4.2.1`; implement the unchanged contract in the Perl reference.
- next_action: make the spec-owned shell return version-2 signatures, preserve them through staged/descriptor
  records, resolve positional minimum arity, eagerly bind extras as a fresh array, and run direct/generated proof.
- current_proof: ADR 0030 plus the offline checker pass 3 definitions, 9 calls, 7 invalid signatures, deterministic
  source/expected result, v1/v2 descriptor roles, and helper/method purpose; current census remains 60/0/0; full
  canonical CI passes Perl CLI 61x2 and Phase 0 `1..1030` in 668 seconds.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: neutral variadic contract/ADR/checker/CI integration prepared for commit;
  generated artifacts clean. Lua scalar numeric `.4.3.3.1.4` remains ready after this prioritized activity.
