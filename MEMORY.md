# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.2.3` — spliced explicit flat arrays through hash construction.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.6.2.3 - splice Lua flat arrays into hashes`.
- prepared_commit: `none`.
- active_work_unit: public leading-trivia initialization `LUA-BACKEND-PARITY.6.2.4`.
- next_action: mirror the Perl public parser's leading blank/comment-line cursor initialization in Lua, lock the
  public boundary without weakening indexed reads, and close unchanged `ds_vhistory_version_entry` on both ABIs.
- current_proof: Lua hash construction now recognizes direct and terminal receiver `flat_array(...)` results as
  explicit ordered key/value splices for `hash(...)` and `harray(...)`. Focused direct/receiver, empty, positioned,
  alias, nested-copy, and ordinary-array boundary proof passes 164/164 on PUC Lua and LuaJIT. Unchanged
  `pplugin_empty` returns exact `[{}]` at endpoint 0; offsets 40-98 rise from 57/59 to 58/59 on both ABIs. Only
  history public leading-trivia initialization remains under `.6.2.4`; `.6.2.5` remeasures and `.6.2.6` admits
  exact 59/59. Corpus/oracle, public status/CLI, coverage 246/105+1/122, and capability 64/0/0 remain unchanged.
  Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 634 seconds.
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
  in_flight_uncommitted: none after `.6.2.3`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
