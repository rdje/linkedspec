# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.2.4` — mirrored Perl public leading-trivia initialization in Lua.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.6.2.4 - mirror Lua public leading trivia`.
- prepared_commit: `none`.
- active_work_unit: successor zero-residual measurement `LUA-BACKEND-PARITY.6.2.5` after `.6.2.4` commits cleanly.
- next_action: finish `.6.2.4` canonical local CI and commit; then remeasure exact offsets 40-98 on both Lua ABIs,
  record the zero-residual boundary without behavior changes, and hand permanent 59/59 admission to `.6.2.6`.
- current_proof: Lua public `runtime_parse(...)` now skips only complete leading blank/comment lines through its
  existing live cursor/register seam while leaving ordinary content, direct handlers, absolute offsets, and
  scalar-held indexed reads unchanged. Focused Unicode/EOF/boundary/history proof passes 165/165 on PUC Lua and
  LuaJIT. Unchanged `ds_vhistory_version_entry` passes at endpoint 62; exact offsets 40-98 rise from 58/59 to
  59/59 on both ABIs with no residual. Corpus/oracle data, public status/CLI, coverage 246/105+1/122, and
  capability 64/0/0 remain unchanged. Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 644 seconds.
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
- blockers: none for `.6.2`; controlled/core windows and public/census no-drift are verified locally.
  in_flight_uncommitted: `.6.2.4` implementation, proof, and durable sync await the full canonical gate and commit;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
