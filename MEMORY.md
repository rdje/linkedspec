# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.6` — Lua aligns its typed helper/control truth, pre-effect
  logical arity, exact optional structured fields, and native/reconstructed/generated-plan/loaded-emitted/primary
  proof on PUC Lua and LuaJIT; rollout is 5 complete / 3 pending.
- latest_commit: `c6e39861` — `FUTURE-PARITY-BACKLOG.5.2.5 - align Julia logical helpers`
  (ahead: 177; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.6 - align Lua logical helpers` after canonical closeout.
- active_work_unit: verified dual-ABI Lua logical-helper rollout `FUTURE-PARITY-BACKLOG.5.2.6` closing in its
  exact commit; cursor implementation
  `.9.1.2-.9` is dependency-ordered but remains pending until explicitly reached after the logical program.
- next_action: run final governance/mdBook/whitespace checks, commit `.5.2.6`, clear the message file, verify the
  repo clean, then activate generated/primary logical projection `.5.2.7` as the next task-owned PNT slice.
- current_proof: Lua's unchanged consumer moved from identical 51/238 baselines to 238/238 on PUC Lua and LuaJIT
  across typed truth, native/reconstructed/generated-plan/loaded-emitted/primary values/effects/controls and four
  pre-effect arities. The authoritative dual-ABI gate passes diagnostic 119, logical 238, full 177, shared CLI
  62x2, and corpus 105/105. The neutral checker is 5 complete / 3 pending with 15 mutations. Canonical local CI
  passes reference CLI 62x2 and Phase 0 `1..1031` in 609 seconds. ADR `0044` remains the exact pending future cursor authority.
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
- blockers: none. in_flight_uncommitted: verified Lua `.5.2.6` implementation/tests/docs/ledger await final
  governance/mdBook checks and the exact prepared commit; no background job remains. Mutation campaigns remain parked;
  ignored `rgx/subs/pgen` work remains untouched.
