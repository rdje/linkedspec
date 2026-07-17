# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.3.0` — Perl's six rollout boundaries, bare-edge prerequisite,
  and gate-safe ten-file shared CLI ownership correction are verified without behavior change.
- latest_commit: `e7e9706b` — `FUTURE-PARITY-BACKLOG.9.1.2 - adopt rule-local cursor contract`
  (ahead: 183; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.3.0 - audit Perl cursor rollout boundaries`.
- active_work_unit: verified `.9.1.3.0` closeout at the commit boundary; normalization `.9.1.3.1` remains pending
  until this audit commits cleanly.
- next_action: run final contract/KM/governance/whitespace checks, stage and commit `.9.1.3.0`, clear the brief,
  verify clean, then activate family/bare-edge normalization `.9.1.3.1`.
- current_proof: Toolbox bootstrap output proves bare `Child` is dropped and bare fluent/block forms become
  arbitrary `ChildCODE`; exact source mapping records six implementation boundaries and all 14 original Perl token
  owners. CLI inspection partitions 35 affected mandatory cases into 2 help / 20 usage / 2 success / 11 trace;
  ten shared byte/manifest files now belong to `.9.1.3.5`, final symmetry/docs to `.9.1.8`. The unchanged checker
  passes 36/18/8/91 at 1/7 with 27 mutations; JSON/KM 580/4075/governance/mdBook/whitespace and reference CLI
  63/63 default plus 63/63 POSIX pass. No behavior changed.
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
- blockers: none. in_flight_uncommitted: verified `.9.1.3.0` contract ownership refinement, task split, fact card,
  and lockstep docs await final checks and commit. No background job or behavior change; mutation campaigns remain
  parked and ignored `rgx/subs/pgen` work is untouched.
