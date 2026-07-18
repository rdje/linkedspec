# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.2` — Perl loaded/generated direct/traced/Get,
  runtime-context, effective diagnostics/trace, and generated entry metadata are canonically verified.
- latest_commit: `f33d6d24` — `FUTURE-PARITY-BACKLOG.9.1.1.2.1.1 - implement Perl root resolution`
  (ahead: 208; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.2 - converge Perl root execution`.
- active_work_unit: Perl loaded/generated/runtime-context/trace convergence leaf `.9.1.1.2.1.2` is complete,
  documented, and verified; clean commit is required before composed admission `.1.3`.
- next_action: stage/inspect the exact `.1.2` diff, commit per `COMMIT.md`, clear/verify the brief and clean tree,
  then activate `.9.1.1.2.1.3` task-tree-first.
- current_proof: Loaded and generated direct/traced/Get roles share explicit > first marker > first rule;
  generated metadata retains ordered authored identity beside the minimal family plan. Focused proof is 8 files /
  49 tests. Root checker is 8/3/3/5 at 1/6 plus 24 mutations; generated census is 80/0/0; Knowledge Map 597/4,269;
  four doctrines/mdBook/whitespace pass. Canonical CI passes route 5, cursor 288, primary 63x2, and Phase 0
  1,031/1,031 in 610 seconds. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.1.3-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.1.2.1.2` awaits its clean commit boundary.
  Parked ignored work is untouched.
