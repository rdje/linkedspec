# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.7` — every available generated direct/traced role preserves
  logical values, eager effects, exact failure/source metadata, and role-local result shape; shared primary case
  `success_logical_helpers_eager` passes five commands in both environments and rollout is 6/2.
- latest_commit: `3196dc60` — `FUTURE-PARITY-BACKLOG.5.2.6 - align Lua logical helpers`
  (ahead: 178; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.7 - propagate logical generated projection` after exact closeout.
- active_work_unit: verified generated/primary logical projection `FUTURE-PARITY-BACKLOG.5.2.7` closing in its
  exact commit; recurring gate `.5.2.8` follows only after the clean boundary. Cursor implementation `.9.1.2-.9`
  remains pending behind the logical program.
- next_action: run final post-edit memory/task/doctrine/KM/mdBook/whitespace checks, commit `.5.2.7`, clear the
  message file, verify the repo clean, then activate recurring logical gate `.5.2.8` as the next task-owned slice.
- current_proof: focused generated consumers pass Perl 8, Rust 4, Dart 24, Julia 232, and PUC Lua/LuaJIT 359;
  complete Rust/Dart/Julia/Lua gates and exact primary 5x2x63 pass. Neutral logical 6/2 plus 15 mutations,
  diagnostic 8/0 plus 20, generated-source/capability 80/0/0, exhaustive 246/105+1/122 coverage, and canonical
  reference CLI 63x2 plus Phase 0 `1..1031`/618s pass. No runtime implementation or mutation campaign occurred.
- latest_bootstrap_read: 2026-07-17 — full required roadmap, codebase ownership seams, mdBook, active task, Knowledge
  Map, TOOLBOX-relevant audit facts, and ADR context reviewed before the decision-only slice.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR implementation `.9.1.2-.9` after logical;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.5.2.7` tests/manifest/ledgers/docs await final governance and
  the exact prepared commit; no background job remains. Mutation campaigns remain parked;
  ignored `rgx/subs/pgen` work remains untouched.
