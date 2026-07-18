# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.5.1` — exact Dart family/bare-edge normalization, portable
  diagnostics, compiled ownership, staged runtime boundary, and canonical signoff pass.
- latest_commit: `b700c11a` — `FUTURE-PARITY-BACKLOG.9.1.5.0 - audit and split Dart cursor rollout`
  (ahead: 200; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.5.1 - normalize Dart rule edges`.
- active_work_unit: Dart `.9.1.5.1` is fully verified and awaits its clean commit; live cursor execution and
  generated v2 remain explicitly staged for `.2` and `.4`.
- next_action: commit `.9.1.5.1`, clear/verify the brief and clean tree, then activate execution `.9.1.5.2`
  task-tree-first.
- current_proof: typed `BareEdge` AST/nullable indices, exact compact-pipe identity, six portable diagnostics, and
  family-derived compiled action/blind tables consume all 36 family, 18 edge, and six ownership-set rows. A named
  runtime adapter and exact v1 classifier freeze later leaves. New suite passes 5/5; parser/validator/compiler
  26/26; focused eight suites 109/109; corpus 105/105; strict analysis passes. Complete driver reaches 249 passes
  plus only the staged shared-help failure; primary remains exact 30/63 twice. Neutral checker remains 68 files,
  3/5 rollout, and 34 rejected mutations. Knowledge Map is 589/4,188; canonical CI passes reference primary
  63x2 and Phase 0 1,031/1,031 in 610 seconds. No background job is running.
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
- blockers: none. in_flight_uncommitted: `.9.1.5.1` is fully verified and awaits only commit/clean-boundary
  checks. Parked mutation and ignored `rgx/subs/pgen` work are untouched.
