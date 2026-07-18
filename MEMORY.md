# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.3` — composed Perl root-selection admission and parent
  `.9.1.1.2.1` are canonically verified; only the clean commit boundary remains.
- latest_commit: `2e175103` — `FUTURE-PARITY-BACKLOG.9.1.1.2.1.2 - converge Perl root execution`
  (ahead: 209; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.3 - admit Perl root selection`.
- active_work_unit: `.9.1.1.2.1.3` is complete, staged, and awaiting its per-slice commit; do not activate Rust `.2`
  until this commit leaves the tree clean.
- next_action: rebuild/check the mdBook and continuity/doctrine layers after final status edits, clean artifacts,
  commit `.1.3`, clear/verify the brief, and verify a clean tree; only then activate Rust root-selection `.2`.
- current_proof: Shared primary adds exact first-marker and markerless defaults; Perl passes 65/65 twice. Focused
  root/generated/CLI proof is 5 files / 27 tests. Root checker is 8/3/3/5 at 2/5 plus 24 mutations; Knowledge Map
  598/4,277. Canonical CI passes root core 7, routes 5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 611
  seconds; all four doctrines pass. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.2-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.1.2.1.3` is staged pending book/continuity rerun,
  cleanup, and commit. Parked ignored work is untouched.
