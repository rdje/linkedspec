# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.1.0` — measured and split controlled/core corpus admission.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.6.1.0 - split Lua controlled corpus admission`.
- prepared_commit: `none`.
- active_work_unit: nested assignment segment-kind repair `LUA-BACKEND-PARITY.6.1.1`.
- next_action: make `assign_nested_access` preserve parsed key/index container requirements, add exact wrong-shape/
  no-mutation tests, and pass unchanged corpus offset 20 on PUC Lua and LuaJIT before executor work `.6.1.2`.
- current_proof: `.6.1.0` defines exact owned windows at offsets 0-39 and 99-104. Disposable automatic parse/
  validate/compile/engine/runtime probes pass 45/46 identically on PUC Lua and LuaJIT: all six capability cases and
  39/40 core cases pass. Offset 20 alone mismatches because nested assignment erases key/index segment kinds and
  lets a numeric harray write create string key `"0"`; canonical semantics require null without mutation. Repair
  `.6.1.1`, executor `.6.1.2`, core `.6.1.3`, and capability/no-drift `.6.1.4` are split before code. Public status
  remains `native-full-pipeline-trace-v1`, focused tests remain 155/155 on both ABIs, and capability remains
  64/0/0. Canonical CI passes CLI 61x2 plus Phase 0 `1..1031` in 606 seconds. Mutation testing remains manual-only
  and was not run.
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
- blockers: none for `.6.1.1`; the exact sole residual and governed semantics are durable.
  in_flight_uncommitted: none after `.6.1.0`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
