# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.2.5` — independently confirmed the advanced window has no residual.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.6.2.5 - record Lua advanced zero residual`.
- prepared_commit: `none`.
- active_work_unit: permanent advanced/shipped admission `LUA-BACKEND-PARITY.6.2.6` after `.6.2.5` commits cleanly.
- next_action: commit verified `.6.2.5`; then add one recurring production-library test that
  locks exact ordered offsets 40-98, wrapped expected outputs, matches/endpoints, 59 passes, and zero failures.
- current_proof: Separately built PUC Lua and LuaJIT adapters each validate the complete 105-case manifest and
  execute exact offsets 40-98 through the production library path. Both preserve order from
  `terse_2_2_6_2_attached_while_blocks` through `lib_reader_cattribute`, report 59 passes, zero failures, and true
  aggregate status. The complete Lua gate passes 165/165 per ABI. Production source, tests, corpus/oracle data,
  expected JSON, public status/CLI, coverage 246/105+1/122, and capability 64/0/0 remain unchanged. Full canonical
  local CI passes CLI 61x2 and Phase 0 `1..1031` in 622 seconds.
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
  in_flight_uncommitted: verified `.6.2.5` zero-residual proof and durable sync await commit;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
