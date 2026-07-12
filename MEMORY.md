# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.2.5.1` — closed Lua string helper parity.
- latest_commit: `7459e777` — `FUTURE-PARITY-BACKLOG.12.0 - capture compatibility retirement doctrine`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.3`; implement numeric helpers, aliases, reducers, and receiver chains.
- next_action: audit the neutral numeric contract and existing Lua ActionIR/runtime value seams, split `.4.3.3`
  before code if the arithmetic/comparison/reducer/receiver surface is too broad for one signoff slice.
- current_proof: Lua scalar/string parity is closed: deterministic/Unicode/coercion/regex/split/mutation and public
  no-drift pass 76/76 on both ABIs. Uniform expression and temporary-compatibility retirement doctrine is durable
  under `FUTURE-PARITY-BACKLOG.12`; exact broader shipped string cases remain owned by Lua `.6.2`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: Lua string parity closeout prepared for commit; generated artifacts clean.
