# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.4` — Rust descriptor v1 projects normalized authored family,
  derived cursor policy, ownership, and ordered resolved edges without root/rule global cursor fields.
- latest_commit: `9fffe9bd` — `FUTURE-PARITY-BACKLOG.9.1.4.3 - derive Rust rule-local cursor policy`
  (ahead: 195; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.4 - project Rust cursor descriptor v1`.
- active_work_unit: clean commit boundary for fully verified Rust descriptor projection `.9.1.4.4`; do not activate
  generated-source `.9.1.4.5` while the tree is dirty.
- next_action: run final short governance checks, commit `.4`, clear/verify `git_message_brief.txt`, verify the root
  tree is clean, and only then activate generated-source `.9.1.4.5`.
- current_proof: Rust descriptor v1 removes root/rule global cursor fields and publishes the neutral identity plus
  normalized family, derived policy, aggregate ownership, and ordered ownership/target/child-index/block/fluent
  rows. All 36 families and every valid neutral edge pass exact schema/order, direct/CompiledSpec-JSON identity,
  loaded projection, and live agreement; generated v1 stays staged. Core passes 189/4/5/8; runtime 137;
  execution 6; oracle 105/206.35s; diagnostics 7; classifier 105/235.29s; integrations 197; all adjacent suites,
  formatting, and production-library Clippy pass. Focused gate reaches only exact `.6` CLI boundary 51/63.
  Neutral cursor passes 36/18/8/14/73 at 2/6 plus 29 mutations; Knowledge Map passes at 586/4,155. Memory/task/
  four-doctrine/mdBook/JSON/formatting/whitespace/cleanup checks pass. Canonical CI passes the Perl consumer 288,
  reference CLI 63x2, and Phase 0 1,031/1,031 in 610 seconds, then exits 0; no background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, and generated-source/live/descriptor seams reviewed before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.4-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: fully verified `.9.1.4.4` code/tests/docs await the clean commit only; no
  background job. Parked mutation work and ignored `rgx/subs/pgen` work are untouched.
