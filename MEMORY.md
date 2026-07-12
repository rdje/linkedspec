# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.1` — designed callable codeblock literals and backend rollout.
- latest_commit: `571de2ab` — `FUTURE-PARITY-BACKLOG.4.4 - close variadic callable routing`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.1 - design callable codeblock literals`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.11.2`; adopt neutral callable-codeblock schema and fixtures.
- next_action: after committing the design handoff, create the machine-readable `{|args| ...}` syntax/AST/runtime
  contract, deterministic fixture, and independent checker before any backend parser/runtime behavior changes.
- current_proof: ADR 0031 records director agreement on exact `{|` literals, `{||}` zero params, final `...rest`,
  `cb(args)`, dynamic caller context, temporary copied params, block-local return, static name precedence, retained
  `with`, no lexical capture, and deterministic separation from harrays/eager blocks. Behavior is not yet claimed.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: callable-codeblock design/ADR/task split is documentation-only and being
  prepared for commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the director-prioritized `.11` arc.
