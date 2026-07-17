# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.3.6` — one 14-role omission-sensitive consumer admits the
  complete Perl cursor projection at 2/6 and closes parent `.9.1.3` without runtime behavior changes.
- latest_commit: `b7c28156` — `FUTURE-PARITY-BACKLOG.9.1.3.5 - remove Perl cursor overrides`
  (ahead: 190; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.3.6 - admit Perl cursor projection`.
- active_work_unit: commit the fully verified composed Perl admission/parent closeout, clear/verify the brief, and
  establish a clean pivot boundary before Rust cursor rollout `.9.1.4`.
- next_action: commit `.9.1.3.6`, clear/verify `git_message_brief.txt`, confirm a clean tree, then activate
  `FUTURE-PARITY-BACKLOG.9.1.4`.
- current_proof: The contract-declared Perl consumer passes 288 tests and focused four-suite composition passes
  410. Neutral cursor passes 36/18/8/14/72 at 2/6 plus 29 mutations; generated/capability stay 80/0/0. Reference
  CLI passes 63/63 twice. Standalone Phase 0 passes 1,031/1,031 in 641 seconds. Canonical local CI runs the new
  consumer, passes CLI 63x2 and Phase 0 1,031/1,031 in 642 seconds, and exits 0. KM 584/4,126, mdBook, JSON,
  syntax, memory/task/doctrine/whitespace, and safe cleanup pass. No implementation mutation campaign.
- latest_bootstrap_read: 2026-07-17 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, and generated-source/live/descriptor seams reviewed before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.4-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: fully verified `.9.1.3.6` awaits commit; no background job. Parked mutation
  work and ignored `rgx/subs/pgen` work are untouched.
