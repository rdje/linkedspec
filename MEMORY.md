# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.5.3` — Dart descriptor v1 projects normalized rule-local cursor
  facts across direct/reconstructed/loaded state; generated v1 stays staged; full canonical signoff passes.
- latest_commit: `7dea1f6b` — `FUTURE-PARITY-BACKLOG.9.1.5.2 - derive Dart rule-local cursor execution`
  (ahead: 202; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.5.3 - project Dart cursor descriptor v1`.
- active_work_unit: Dart `.9.1.5.3` implementation and full signoff are complete; commit workflow is in progress.
- next_action: prepare the brief, stage/commit `.9.1.5.3`, clear it, verify a clean tree, then activate generated-
  source v2 `.9.1.5.4` task-tree-first.
- current_proof: root descriptor metadata now carries the neutral cursor contract and no global mode; all 36
  families derive per-rule family/policy, every valid edge projects exact ordered ownership/target/index/block/
  fluent facts, and label/line/top/mode identity remains exact. Direct, normalized `SpecFile` JSON, and loaded
  descriptors agree; reconstructed invalid state preserves every portable edge failure; loaded execution is
  unchanged. New suite 4/4 and adjacent descriptor/normalization/execution suites 18/18 pass; strict analysis
  passes; complete package is 257/1 only at staged shared help; corpus 105/105 and primary 30/63x2 are unchanged.
  Neutral remains 68 files, 3/5 rollout, and 34 rejected mutations. Knowledge Map is 591/4,207; governance and
  mdBook pass; canonical CI repeats Perl admission 288, reference primary 63x2, and Phase 0 1,031/1,031 in 624
  seconds, then exits 0. No background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.6-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.5.3` descriptor projection, contract test/path
  swap, Knowledge Map, task/live docs, and mdBook await the commit workflow. Parked ignored work is untouched.
