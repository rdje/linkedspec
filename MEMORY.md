# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.2` — adopted neutral callable-codeblock contract and fixture.
- latest_commit: `f3c3d116` — `FUTURE-PARITY-BACKLOG.11.1 - design callable codeblock literals`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.2 - adopt callable codeblock contract`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.11.3.1`; parse/lower typed deferred literals on Perl.
- next_action: after committing `.11.2`, use the Knowledge Map/toolbox to locate Perl ActionIR brace parsing and
  value-preservation seams, then add exact `{|...|...}` typed parsing without invocation behavior.
- current_proof: `linkedspec-callable-codeblock-v1` independently checks 7 literals, 11 calls, 9 malformed
  literals, 7 invalid calls, 4 contextual forms, exact brace classification/AST fields, and a deterministic future
  fixture under dynamic caller context. Canonical CI passes 61x2 CLI plus Phase 0 `1..1030`/716s; no backend
  behavior is claimed yet.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: `.11.2` neutral JSON/checker, CI wiring, and synchronized durable docs are
  being prepared for commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the prioritized `.11` arc.
