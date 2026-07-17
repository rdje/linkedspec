# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.3.2` — normal live/loaded Perl handlers spend intrinsic
  per-rule cursor policy across all entry mechanisms while descriptor/generated-source v1 remains staged.
- latest_commit: `92cb3f5f` — `FUTURE-PARITY-BACKLOG.9.1.3.1 - normalize Perl rule edges`
  (ahead: 185; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.3.2 - execute Perl rule-local cursors`.
- active_work_unit: commit fully verified Perl live cursor slice `FUTURE-PARITY-BACKLOG.9.1.3.2`; descriptor v1,
  generated-source v2, and CLI/fixture migration remain separately gated under `.9.1.3.3-.5` and are unactivated.
- next_action: commit `.9.1.3.2`, clear/verify `git_message_brief.txt`, confirm a clean tree, then activate descriptor
  projection `.9.1.3.3` in a new task-tree-owned boundary.
- current_proof: Normal live/loaded Perl handlers spend intrinsic AND consume and default/OR seek policy across all
  eight parent/child mechanisms and both structural replacements; a separate artifact handler preserves descriptor/
  generated-source v1. Focused live 38/38, normalization 272/272, adjacent contracts, and three-module syntax pass.
  Phase 0 reaches 1,031/1,031 in 638 seconds after two exact seek-dependent fixture migrations. Toolbox trace also
  exposed identical dependency-regex index aliasing, now durably owned by `.9.1.8.1`; KM is 581/4082. The first
  exact 91-file inventory remains 1/7 with 27 mutations. Canonical local CI passes doctrines, capability 80/0/0,
  generated v1, logical/diagnostic 8/0, coverage 246/105+1/122, reference CLI 63x2, and Phase 0 1,031/1,031/629s.
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
- blockers: none. in_flight_uncommitted: fully verified/staged `.9.1.3.2` implementation, tests, lockstep, and
  tracked `.9.1.8.1` finding awaiting only commit; no background job. Parked mutation work and ignored
  `rgx/subs/pgen` work are untouched.
