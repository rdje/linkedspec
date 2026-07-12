# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.3.0` — split Lua numeric helper mechanisms.
- latest_commit: `204c15d2` — `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.3.0 - split Lua numeric helper mechanisms`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.3.1`; implement strict scalar numeric helper evaluation and fences.
- next_action: add one canonical finite-decimal scalar evaluator for unary/arithmetic/clamp/min/max/comparison calls,
  lock invalid inputs and zero-divisor/modulo/bounds/non-finite results, then run the full dual-ABI Lua gate.
- current_proof: Lua scalar/string parity is closed at 76/76 on both ABIs. Numeric aliases/symbols already
  canonicalize; scalar execution `.1`, number receivers `.2`, aggregate reducers `.3`, and closeout `.4` are split.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`; uniform binding and temporary compatibility retirement `.12.1`.
- blockers: none. in_flight_uncommitted: numeric mechanism split prepared for commit; generated artifacts clean.
