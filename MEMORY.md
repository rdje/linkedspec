# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.6.2.0` — measured and split advanced/shipped offsets 40-98.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.6.2.0 - split Lua advanced corpus residuals`.
- prepared_commit: `none`.
- active_work_unit: action-edge child-call reuse `LUA-BACKEND-PARITY.6.2.1`.
- next_action: make `call(child)` reuse and mark the current action-edge child result exactly once; add focused
  self/non-self/passive/unrelated-call proof, then remeasure the six currently affected fixtures and offsets 40-98.
- current_proof: Exact offsets 40-98 produce the same 50/59 result on PUC Lua and LuaJIT. Nine residuals comprise
  hash receiver compare; three HLink execute; two EBNF compare; SimEnv execute; history compare; and PPlugin compare.
  Production debug trace plus canonical Perl generated source/descriptor probes prove four current mechanisms:
  `call(child)` bypasses the action-edge cache and triggers fallback double execution; receiver `.copy()` drops its
  value; `hash(flat_array(...))` misses a hash splice; public parse does not skip leading blank/comment lines.
  Repairs `.6.2.1-.4`, successor measurement `.6.2.5`, and permanent 59/59 admission `.6.2.6` are split. No runtime,
  tests, corpus/oracle, public status/CLI, coverage 246/105+1/122, or capability 64/0/0 changes in `.6.2.0`. Both
  Lua ABIs remain 162/162; canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 629 seconds.
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
  in_flight_uncommitted: none after `.6.1.4`; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
