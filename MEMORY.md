# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.2.4` — close portable native loading no drift.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.2.4 - close Lua native loading no drift`.
- prepared_commit: `none`.
- active_work_unit: exact outward descriptors and one-emitter full-pipeline trace `LUA-BACKEND-PARITY.5.3`.
- next_action: audit the shared descriptor/trace contracts and every Lua loading/frontend/validation/compiler/
  function/staged/runtime seam, then split `.5.3` by dependency before changing behavior.
- current_proof: `.5.2.4` inventories the complete native loading chain and finds no unowned source/export/test/
  public-doc/KM seam. Typed `LoadedCompiledSpec`, exact parse/validate/compile errors, option-copying named/path-
  identified engines, loaded fixed functions, inline no-drift, runtime identity, and missing-name JSON remain
  153/153 on PUC Lua/LuaJIT;
  native 14/9/4, capability 64/0/0, coverage 246/105+1/122, public 58/27/0, CLI 61x2, and Phase 0 `1..1031` in
  607 seconds are green. Parent `.5.2` is closed; `.5.3` is active for descriptors/full trace. ADR `0040` and
  `BACKEND-COMPANION-BOOKS` adopt one neutral book plus five
  linked implementation companions; implementation starts only after full current-backend parity and no scaffold
  or content migration exists yet. Mutation testing remains manual-only.
- latest_bootstrap_read: 2026-07-15 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: `.5.2.4` no-drift docs pass focused/canonical gates and await commit;
  mutation campaigns remain parked and no mutant run belongs to ordinary commit/local-CI workflow.
