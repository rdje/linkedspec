# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.7.4` — execute Lua rule-slot markers.
- latest_commit: `04d0ffdd` — `LUA-BACKEND-PARITY.4.3.7.4 - execute Lua rule slot markers`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.18.1 - govern expressive spec authoring`.
- active_work_unit: `.18.1` has captured ADR `0035`'s terse/readable/highly-expressive authoring doctrine across
  task trees, roadmap, architecture, public book, Knowledge Map source, and live docs. Focused governance/book
  verification, commit, brief cleanup, and clean-tree verification remain.
- next_action: verify and commit `.18.1`, clear the brief, confirm a clean tree, then create the separate task-tree
  owner for explicit nested-write autovivification and receiver-mutating `!` design before any such design/docs
  change. After that planning slice, return to Lua exhaustive capture/cursor no-drift `.4.3.7.6`.
- current_proof: ADR `0035` defines terseness as removing redundant ceremony, readability as local predictability,
  and expressiveness as small typed orthogonal composition. Uniform binding is the precedent. Recursive
  `walk_leaves`/`map_leaves`/`reduce_leaves` retain semantic names; no short aliases or behavior are added.
- latest_bootstrap_read: 2026-07-14 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: `.18.1` planning/docs/KM source await focused verification and prepared
  commit. Do not open the autovivification/`!` design owner or resume `.4.3.7.6` before this lands and the tree is
  clean. The structured-format execution tree remains dependency-gated on full parity.
