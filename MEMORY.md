# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.2.3` — Lua scalar regex mutation.
- latest_commit: `33880c3d` — `LUA-BACKEND-PARITY.4.3.2.2.2 - add Lua pure split bridge`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.2.2.3 - add Lua scalar regex mutation`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.2.2.4`; implement dropped explicit array-target split replacement
  without crossing the pure split value boundary.
- next_action: dispatch `split(array(target), source, delimiter)` in statement context, replace the named aggregate
  store with copied literal/regex fields, and lock scalar-held versus explicit-array behavior on both Lua ABIs.
- current_proof: dropped four-argument `substr`/`regex_subst` mutate bare scalars with strict PCRE2 flags,
  first/global replacement, `$0`/`$n`, Unicode-safe zero-width progress, and rule-attributed invalid diagnostics;
  discarded numeric substr remains pure. PUC Lua and LuaJIT pass 75/75.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`.
- blockers: none. in_flight_uncommitted: scalar regex mutation implementation/docs prepared for commit; generated
  artifacts clean.
