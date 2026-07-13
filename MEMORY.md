# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.6.1` — eager expression blocks and block-local return.
- latest_commit: `a3c7e71f` — `LUA-BACKEND-PARITY.4.3.6.0 - split Lua block control callback mechanisms`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.6.1 - execute Lua eager block values`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.6.2`; execute lazy inline value controls.
- next_action: inventory exact inline if/switch AST shapes and backend truth/branch contracts, then implement lazy
  selected-branch evaluation over the eager block seam with focused dual-ABI proof.
- current_proof: ordinary no-pair braces execute once, yield last/local-return values, preserve dropped mutation,
  harray precedence, and receiver dispatch at 104/104 on both ABIs. Earlier inert assignment scaffold drift is
  corrected; contextual blocks stay structural and explicit callable values stay future `.11.7`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: `.4.3.6.1` runtime/test, historical correction, KM fact, task/live docs,
  and mdBook synchronization await their prepared commit. Oracle timeout calibration remains `.7.0`.
