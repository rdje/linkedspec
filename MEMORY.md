# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.3.2` — one caller-owned emitter through the full native pipeline.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.3.2 - propagate Lua full-pipeline trace`.
- prepared_commit: `none`.
- active_work_unit: descriptor/full-pipeline-trace no-drift `LUA-BACKEND-PARITY.5.3.3`.
- next_action: inventory the exact source exports/status, dual-ABI trace/descriptor proof, neutral fixtures and
  checkers, public docs/book, task/index/roadmaps/live/KM, and capability census; then close parent `.5.3` without
  changing behavior or admitting Lua before sole expansion owner `.8.4`.
- current_proof: Lua passes one caller emitter through IO, frontend/compiler/function/staged phases, engine
  construction, and runtime without hidden construction or retained state. Ordered sinks/filters/balanced failures
  and traced/untraced descriptor/runtime identity pass 155/155 on PUC Lua and LuaJIT with status
  `native-full-pipeline-trace-v1`; signature/codeblock checkers remain 3/9/7 and 7/11/9/7/4/8; native loading is
  14/9/4; capability remains four-backend 64/0/0 until `.8.4`. Canonical local CI passes CLI 61x2 plus Phase 0
  `1..1031` in 608 seconds. Mutation testing remains manual-only and was not run.
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
- blockers: none for `.5.3.3`; its exact no-drift inventory precedes parent closeout.
  in_flight_uncommitted: none after `.5.3.2`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
