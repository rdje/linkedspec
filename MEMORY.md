# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.2.6` — permanently admitted exact advanced offsets 40-98.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.6.2.6 - admit Lua advanced corpus window`.
- prepared_commit: `none`.
- active_work_unit: complete-manifest recurring admission `LUA-BACKEND-PARITY.6.3` after `.6.2.6` commits cleanly.
- next_action: commit verified `.6.2.6`; then inventory the current executor/tests and make complete ordered
  105/105 exact execution recurring without changing the validation-only CLI boundary.
- current_proof: One production-library test validates all 105 manifest entries and selects exact offsets 40-98.
  Its independent literal ledger locks all 59 names, byte/character endpoints, matches, absent failures, and one
  wrapping of each unchanged expected JSON value. PUC Lua and LuaJIT report 59 passes, zero failures, true
  aggregate status, and 166/166 complete suites. Parent `.6.2` closes; `.6.3` activates. Production source,
  corpus/oracle data, public status/CLI, generated-source state, coverage 246/105+1/122, and capability 64/0/0
  remain unchanged. Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 621 seconds.
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
- blockers: none for `.6.3`; all three corpus windows and public/census no-drift are verified locally.
  in_flight_uncommitted: verified `.6.2.6` permanent test, durable sync, and canonical CI await commit;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
