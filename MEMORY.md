# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.2.2` — preserved receiver copy values and typed continuations.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.6.2.2 - preserve Lua receiver copy values`.
- prepared_commit: `none`.
- active_work_unit: flat-array hash splicing `LUA-BACKEND-PARITY.6.2.3`.
- next_action: classify `flat_array(...)` as an explicit hash-constructor key/value splice, add empty/nested/
  ordinary-boundary proof, and close unchanged `pplugin_empty` on both ABIs.
- current_proof: Receiver `.copy()` now deep-copies the fluent chain's one evaluated current value and retains its
  runtime kind. Focused nested isolation, harray/derived-harray/array/string continuations, scalar one-time
  evaluation, missing values, and unchanged function forms pass 164/164 on PUC Lua and LuaJIT. Exact hash-receiver
  offset 48 returns wrapped `[["a,b,c",9,2,0,2,2,0]]` at endpoint 1; offsets 40-98 rise from 56/59 to 57/59 on both
  ABIs. Only PPlugin `hash(flat_array(...))` splicing and history public leading-trivia initialization remain under
  `.6.2.3-.4`; `.6.2.5` remeasures and `.6.2.6` admits exact 59/59. Corpus/oracle, public status/CLI, coverage
  246/105+1/122, and capability 64/0/0 remain unchanged. Canonical local CI passes CLI 61x2 and Phase 0
  `1..1031` in 628 seconds.
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
  in_flight_uncommitted: none after `.6.2.2`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
