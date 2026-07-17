# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.4` — Dart now consumes ADR `0043` through one typed
  helper/control truth seam, pre-effect logical arity, eager booleans, exact structured fields, and native/
  normalized/generated-plan/compiled-emitted/primary proof; rollout is 3 complete / 5 pending.
- latest_commit: `8905e9f5` — `FUTURE-PARITY-BACKLOG.5.2.3 - align Rust logical helpers`
  (ahead: 175; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.4 - align Dart logical helpers`.
- active_work_unit: closing Dart logical-helper rollout `FUTURE-PARITY-BACKLOG.5.2.4`; cursor implementation
  `.9.1.2-.9` is dependency-ordered but remains pending until explicitly reached after the logical program.
- next_action: after this verified `.5.2.4` slice commits cleanly, activate Julia logical rollout
  `FUTURE-PARITY-BACKLOG.5.2.5`; preserve pending cursor implementation `.9.1.2-.9` until logical rollout closes.
- current_proof: Perl, Rust, and Dart consume ADR `0043` at 3 complete / 5 pending. Dart's 24-case neutral consumer,
  all 245 tests, analyzer/format, CLI 62x2, corpus 105/105, compiled emitted package, and checker mutations are green.
  Canonical local CI passes reference CLI 62x2, Phase 0 `1..1031`, and optional Dart. ADR `0044` remains the exact
  pending future cursor authority.
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
- blockers: none. in_flight_uncommitted: verified `.5.2.4` implementation/docs await their owning commit; no
  background job remains. Mutation campaigns remain parked; ignored `rgx/subs/pgen` work remains untouched.
