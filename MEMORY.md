# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.3.3` — Perl descriptors publish rule-local cursor v1 identity,
  family-derived policy, and ordered resolved-edge facts while generated-source v1 remains staged.
- latest_commit: `2660de23` — `FUTURE-PARITY-BACKLOG.9.1.3.2 - execute Perl rule-local cursors`
  (ahead: 186; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.3.3 - project Perl cursor descriptors`.
- active_work_unit: commit fully verified descriptor leaf `FUTURE-PARITY-BACKLOG.9.1.3.3`; generated-source v2
  `.9.1.3.4` remains unactivated until the clean boundary.
- next_action: commit `.9.1.3.3`, clear/verify `git_message_brief.txt`, confirm a clean tree, then answer the queued
  read-only “super split” implementation question before selecting the next roadmap leaf.
- current_proof: Perl descriptors identify `linkedspec-rule-local-cursor-v1`, omit root global-mode metadata, and
  expose authored-family policy plus ordered ownership/target/index/block/fluent edge rows; source form is
  non-semantic. Live, in-memory descriptor, descriptor-handler, and file-oriented descriptor policies agree across
  all eight mechanisms and both structural replacements. Focused descriptor/normalization/live suites pass
  383/383; generated source remains v1. Neutral checker passes 36/18/8/90 at 1/7 plus 27 mutations after migrated
  CompilerState becomes token-free. Standalone Phase 0 passes 1,031/1,031 in 662 seconds; canonical CI passes all
  doctrines, capability 80/0/0, reference CLI 63x2, and Phase 0 1,031/1,031 in 634 seconds.
- latest_bootstrap_read: 2026-07-17 — full required roadmap, codebase ownership seams, mdBook, active task, Knowledge
  Map, Toolbox facts, and ADR context reviewed before the Perl implementation slice.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR implementation `.9.1.2-.9` after logical;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: fully verified `.9.1.3.3` implementation/tests/lockstep await only commit;
  no background job. Parked mutation work and ignored `rgx/subs/pgen` work are untouched.
