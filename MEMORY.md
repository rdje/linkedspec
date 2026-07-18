# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.5.4` — Dart generated-source v2 retains a minimal family plan,
  derives rule-local cursor/structure, rejects v1 before payload decode, and passes full canonical signoff.
- latest_commit: `39338616` — `FUTURE-PARITY-BACKLOG.9.1.5.3 - project Dart cursor descriptor v1`
  (ahead: 203; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.5.4 - emit Dart generated-source v2`.
- active_work_unit: Dart `.9.1.5.4` is complete with full signoff; its commit workflow is the only remaining step
  before the clean pivot to `.9.1.5.5`.
- next_action: regenerate/check the Knowledge Map after final signoff text, run lightweight governance/mdBook
  checks, commit `.9.1.5.4`, clear the brief, verify clean, then activate option/CLI migration `.9.1.5.5`.
- current_proof: current Dart artifacts are generated-source v2/format 2 with deterministic cursor-free ordered
  label/family rows. All ten families derive cursor/structure at every generated rule entry; compact Pipe is OR.
  An isolated corrupt-payload host proves exact v1 expected/actual/regeneration rejection occurs before decode,
  while current v2 reaches a distinct compile/load failure. All 36 classifier spellings, eight parent/child cases,
  two structural replacements, direct/trace/subset and adjacent generated roles pass. Strict analysis and affected
  76/76 pass; complete package is 257/1 only at staged shared help; corpus 105/105; primary remains expected
  30/63x2 until `.5`; neutral is 68 files, 3/5 rollout, 34 mutations. Knowledge Map is 592/4,215; memory/task/all
  four doctrines/mdBook/whitespace pass. Canonical CI passes Perl admission 288, reference primary 63x2, and
  Phase 0 1,031/1,031 in 641 seconds; no background job is running.
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
- blockers: none. in_flight_uncommitted: `.9.1.5.4` generated-v2 code/tests/checkers/docs/KM card are fully signed
  off and await only the required commit workflow. Parked ignored work is untouched.
