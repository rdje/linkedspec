# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.1` — Perl core root precedence, markerless validation,
  authored descriptor identity, structured failures, and strict no-drift are canonically verified.
- latest_commit: `2e01e13b` — `FUTURE-PARITY-BACKLOG.9.1.1.2.1.0 - map Perl root selection`
  (ahead: 207; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.1 - implement Perl root resolution`.
- active_work_unit: Perl core root-selection leaf `.9.1.1.2.1.1` is complete, staged, and verified; clean commit is
  required before pivoting to loaded/generated/trace convergence `.1.2`.
- next_action: commit `.9.1.1.2.1.1`, clear/verify the brief and clean tree, then activate `.1.2` task-tree-first.
- current_proof: `EntryRuleSelection` implements explicit > first marker > first rule. Markerless validation,
  zero/unknown structured failures, native execution, descriptor contract/order/`is_top`, strict-unused no-drift,
  and native loading pass. Root checker is 8/3/3/5 at 1/6 plus 24 mutations; Knowledge Map 596/4,258; four
  doctrines/mdBook/whitespace pass. Canonical CI passes the new core consumer, cursor admission 288, primary
  63x2, and Phase 0 1,031/1,031 in 609 seconds. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.1.2-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed `.9.1.1.2.1.1` is staged for its verified clean commit.
  Parked ignored work is untouched.
