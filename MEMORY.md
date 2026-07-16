# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.7.1` — implemented the exact thin Lua primary CLI adapter.
- latest_commit: `HEAD` — committed `LUA-BACKEND-PARITY.7.1 - implement Lua primary CLI adapter`.
- prepared_commit: `none`.
- active_work_unit: recurring primary CLI process/matrix admission `LUA-BACKEND-PARITY.7.2` after `.7.1` commits.
- next_action: commit verified `.7.1`; then wire the unchanged 61-case Lua command under default/POSIX into the
  focused local gate and shared primary CLI matrix without changing adapter behavior.
- current_proof: `primary_cli.lua` delegates exact source/input selection, staged/native compilation, engine/runtime
  execution, strict UTF-8, canonical JSON, stable failures/exits, and independent canonical phase trace to existing
  native seams. The real command resolves cwd without a subprocess. PUC Lua and LuaJIT pass 169/169; the unchanged
  neutral process manifest passes diagnostic 61/61 in default and POSIX environments. Public status remains
  `runtime-corpus-full` until `.7.2`; corpus 105/105, generated source, coverage 246/105+1/122, and capability
  64/0/0 are unchanged. Canonical local CI exits 0 with Phase 0 true reach `1..1031` in 606 seconds.
- latest_bootstrap_read: 2026-07-15 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.7.2`; the implemented adapter is already diagnostic-green across both process environments.
  in_flight_uncommitted: none after the atomic `.7.1` commit; `.7.2` is the clean next frontier;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
