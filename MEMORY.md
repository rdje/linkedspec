# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.1.1` — preserved typed nested paths and closed both owned windows.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.6.1.1 - preserve Lua nested path segment kinds`.
- prepared_commit: `none`.
- active_work_unit: reusable native library corpus executor/result records `LUA-BACKEND-PARITY.6.1.2`.
- next_action: add strict manifest selection plus automatic parse/validate/compile/source-identified engine/runtime
  execution as a reusable library surface, preserve per-case results/failures, and keep the corpus CLI validation-only.
- current_proof: Lua nested access preserves parser key/index kinds; key segments require harrays and normalized
  finite nonnegative index segments require arrays. Assignment evaluates all segment expressions then RHS before
  validation, mutates a deep copy, and stores only after full success. Exact unchanged offset 20 passes; disposable
  offsets 0-39 plus 99-104 pass 46/46 on PUC Lua and LuaJIT, and focused suites pass 157/157. Public status remains
  `native-full-pipeline-trace-v1`, capability remains 64/0/0, and no fixture/expected/parser/corpus boundary changed.
  Canonical CI passes CLI 61x2 plus Phase 0 `1..1031` in 619 seconds. `.6.1.2` precedes permanent core `.6.1.3`
  and capability/no-drift `.6.1.4`. Mutation testing remains manual-only.
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
- blockers: none for `.6.1.2`; typed nested-path repair and the exact owned-window proof are durable.
  in_flight_uncommitted: none after `.6.1.1`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
