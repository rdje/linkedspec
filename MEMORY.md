# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.5.0` — exact Dart cursor preflight, baseline, and dependency-
  safe `.1-.6` split pass signoff without executable behavior changes.
- latest_commit: `288da21a` — `FUTURE-PARITY-BACKLOG.9.1.4.7 - admit Rust rule-local cursor contract`
  (ahead: 199; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.5.0 - audit and split Dart cursor rollout`.
- active_work_unit: Dart preflight/split `.9.1.5.0` is fully verified; no Dart/shared executable behavior or fixture
  changed. Normalization `.9.1.5.1` remains pending behind this leaf's clean commit.
- next_action: commit `.9.1.5.0`, clear/verify the brief and clean tree, then activate `.9.1.5.1` task-tree-first.
- current_proof: Knowledge Map/toolbox-first audit accounts for eleven governed Dart paths and all non-token seams.
  Compact `|` alone is misclassified as AND; bare edges fail as generic raw syntax; engine-global `parseMode`
  propagates through children; descriptor root retains `parse_mode: seek`; generated source remains v1/format 1.
  `tools/run_dart_local.sh` passes format/analyze and reaches 244 package passes plus the one expected migrated-
  help failure. Focused non-primary tests pass 104/104; corpus passes 105/105; exact primary is 30/63 in both
  default and POSIX environments (22 help/usage plus 11 trace migration failures). Neutral checker is 36/18/8,
  Perl 14, Rust 15, inventory 68, rollout 3/5, and 34 rejected mutations. No background job is running.
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
- blockers: none. in_flight_uncommitted: Dart `.9.1.5.0` preflight evidence, child split, Knowledge card, and
  verified lockstep docs await only commit; no executable edit exists. Parked mutation and ignored `rgx/subs/pgen`
  work are untouched.
