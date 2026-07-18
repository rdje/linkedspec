# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.0` — root selection is ratified as an executable neutral
  contract with exact five-backend audit and canonical signoff, without behavior changes.
- latest_commit: `82999046` — `FUTURE-PARITY-BACKLOG.9.1.5.5 - remove Dart global cursor overrides`
  (ahead: 205; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.0 - ratify root rule selection`.
- active_work_unit: root-selection `.9.1.1.2.0` is complete, verified, staged, and uncommitted; pivot is prohibited
  until its clean commit. Perl behavior remains frozen for `.9.1.1.2.1`.
- next_action: prepare the exact commit brief, commit `.9.1.1.2.0`, clear the brief, verify clean, then activate
  Perl implementation `.9.1.1.2.1` task-tree-first.
- current_proof: ADR `0046` fixes explicit selector > first authored `::` > first authored rule, optional marker,
  authored `is_top` identity, request-vs-runtime trace attribution, and unchanged strict-unused graph semantics.
  Audit finds current Perl row-zero default, Rust marker-only default/routes, and Dart/Julia/Lua fallback blocked by
  validation. Neutral JSON/checker passes 8 selections, 3 failures, 3 strict cases, 5 backend rows, 1 complete / 6
  pending rollout, and 24 mutations. Knowledge Map is 594/4,238; memory/task/four-doctrine/mdBook/whitespace pass.
  Canonical CI repeats Perl cursor admission 288, reference primary 63x2, and Phase 0 1,031/1,031 in 642 seconds,
  exit 0. No parser, validator, runtime, descriptor, generated-source, CLI, fixture, or shared conformance behavior
  changed. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.1-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.1.2.0` neutral decision/contract/checker/book/
  live-doc slice awaits only its commit. Parked ignored work is untouched.
