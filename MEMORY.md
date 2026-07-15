# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.3.3` — exact descriptor/full-trace no-drift and parent closure.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.3.3 - close Lua descriptor trace no drift`.
- prepared_commit: `none`.
- active_work_unit: controlled/core corpus admission `LUA-BACKEND-PARITY.6.1`.
- next_action: run ordered controlled/core and governed-capability corpus subsets, classify every failure by
  mechanism, and split repairs into new owned children before changing runtime behavior or expected fixtures.
- current_proof: exact API/status/test/contract/book/KM inventory closes descriptor/full-trace parents `.5.3`/`.5`
  without source/status/behavior/test/manifest change. PUC Lua and LuaJIT pass 155/155 with status
  `native-full-pipeline-trace-v1`; signature/codeblock checks pass 3/9/7 and 7/11/9/7/4/8; native loading is
  14/9/4; coverage is 246/105+1/122; public surface is 58/27/0; capability remains four-backend 64/0/0 until
  `.8.4`. Closeout canonical CI passes CLI 61x2 plus Phase 0 `1..1031` in 611 seconds. Mutation testing remains
  manual-only and was not run.
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
- blockers: none for `.6.1`; ordered corpus measurement and failure classification precede any repair split.
  in_flight_uncommitted: none after `.5.3.3`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
