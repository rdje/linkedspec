# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.2.2.2` — Lua pure split bridge.
- latest_commit: `55f5be0c` — `LUA-BACKEND-PARITY.4.3.2.2.1 - add Lua helper regex matches`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.2.2.2 - add Lua pure split bridge`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.2.2.3`; implement statement-context scalar regex substitution through
  four-argument `substr` and `regex_subst` without changing pure character slicing.
- next_action: add dropped-statement dispatch for a bare scalar target, operation-aware flags, global/first-only
  replacement, and `$0`/`$n` capture expansion with rule-attributed invalid-pattern diagnostics.
- current_proof: pure function/receiver split returns fresh typed arrays for literal, regex, Unicode empty-delimiter,
  and zero-width patterns; invalid/non-text inputs fail closed. PUC Lua and LuaJIT pass 74/74. Downstream array
  methods remain correctly owned by `.4.3.4`.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; generic final
  codeblock equivalence/`with` `.11.1`.
- blockers: none. in_flight_uncommitted: none after this planning commit; generated artifacts clean.
