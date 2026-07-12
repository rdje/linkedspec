# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.3.3.0` — audited and split missing final-codeblock declaration.
- latest_commit: `b2e998e9` — `FUTURE-PARITY-BACKLOG.11.3.2 - execute Perl callable codeblocks`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.3.3.0 - split final codeblock signature declaration`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.11.3.3.1`; define the contextual final-codeblock declaration/schema.
- next_action: obtain the director's choice for source/schema declaration of a final contextual codeblock parameter
  and its callback fixed/rest params; then update ADR 0031 and the neutral contract before Perl behavior `.2`.
- current_proof: attached and parenthesized forms already carry equivalent final `block_value` payloads, but only
  attached syntax is flagged. User functions expose names/arity/rest only, helper contracts are lowering-local,
  and receiver parsing is name-gated; no schema declares contextual acceptance or callback params. Read-only
  toolbox/ActionIR/descriptor/source probes establish the gap; `.11.3.2` canonical CI remains authoritative.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified); uniform binding and temporary compatibility retirement `.12.1`.
- blockers: director decision required by `.11.3.3.1`; in_flight_uncommitted: `.11.3.3.0` read-only audit/split and
  synchronized durable docs await commit. Lua scalar numeric `.4.3.3.1.4` remains ready after prioritized `.11`.
