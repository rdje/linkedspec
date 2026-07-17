# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.2` — executable neutral rule-local cursor/edge contract and
  exact 91-file dependency-ordered migration inventory are verified at 1 complete / 7 pending.
- latest_commit: `6df03e1f` — `REPO-HYGIENE.5 - clean recurring generated artifacts`
  (ahead: 182; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.2 - adopt rule-local cursor contract`.
- active_work_unit: verified `.9.1.2` closeout at the commit boundary; Perl reference behavior `.9.1.3` remains
  dependency-gated until this candidate commits cleanly.
- next_action: run final governance/whitespace checks, stage the closeout docs, commit `.9.1.2`, clear the brief,
  verify a clean tree, then activate and execute Perl rollout `.9.1.3`.
- current_proof: `linkedspec-rule-local-cursor-v1` independently checks 36 exact family spellings, 18 edge cases,
  six normalized ownership sets, eight parent/child mechanisms, two structural replacements, API/CLI retirement,
  descriptor/generated-v2 rules, eight diagnostics, and exact 91-file dependency-ordered migration ownership. It
  passes at 1/7 and rejects 27 mutations; capability remains 80/0/0, generated v1 remains 80/0/0, exhaustive
  coverage remains 246/105+1/122, and descriptor/schema/syntax/governance/KM/mdBook pass. Canonical local CI passes
  reference CLI 63x2 and Phase 0 `1..1031` in 634 seconds. No backend behavior changed.
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
- blockers: none. in_flight_uncommitted: verified `.9.1.2` contract/checker, exact inventory, CI registration, and
  lockstep sources await final closeout checks and commit. No background job remains; no backend behavior changed;
  mutation campaigns remain parked and ignored `rgx/subs/pgen` work is untouched.
