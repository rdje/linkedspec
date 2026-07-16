# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.3` — permanently admitted full 105/105 interpreter execution.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.6.3 - close full Lua corpus gate`.
- prepared_commit: `none`.
- active_work_unit: primary parser CLI adapter `LUA-BACKEND-PARITY.7.1` after `.6.3` commits cleanly.
- next_action: commit verified `.6.3`; then inventory ADR `0023`, existing primary scaffold/native APIs, and the
  shared CLI adapter precedents before implementing only the exact argument/loading/execution surface.
- current_proof: One no-selector production-library regression and bare developer-runner `--execute` each validate
  and execute all 105 fixtures in manifest order with exact wrapped outputs, 105 passes, and zero failures.
  Validation-only default runner use remains; controlled mismatch and manifest drift prove exits 1 and 2. PUC Lua
  and LuaJIT pass 167/167 with status `runtime-corpus-full`. Parent `.6` closes and `.7.1` activates. The primary
  parser command remains an exit-2 scaffold; corpus/oracle data, generated source, coverage 246/105+1/122, and
  capability 64/0/0 remain unchanged. Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` in 621
  seconds.
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
- blockers: none for `.7.1`; full interpreter corpus and its developer runner are verified locally and through
  canonical CI. in_flight_uncommitted: verified `.6.3` library/runner/status changes and durable sync await commit;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
