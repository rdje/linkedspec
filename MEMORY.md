# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.0` — behavior-free Rust root-selection preflight maps
  every seam, exact current failure, and dependency-safe `.2.1-.3` order; commit closeout is in flight.
- latest_commit: `7029624d` — `FUTURE-PARITY-BACKLOG.9.1.1.2.1.3 - admit Perl root selection`
  (ahead: 210; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.0 - map Rust root selection`.
- active_work_unit: Rust parent `.9.1.1.2.2` remains active; preflight `.2.0` is fully verified and awaits only its
  clean commit. Core implementation `.2.1`, composed routes `.2.2`, and admission `.2.3` remain pending.
- next_action: commit `.2.0`, clear/verify the brief and clean tree, then activate `.2.1` task-tree-first for
  marker-optional validation and one ordered compiled-state resolver.
- current_proof: Rust shared primary is exactly 64/65 twice; only markerless compilation fails. Focused existing
  validation/strict 18, descriptor 4, types 8, explicit entry 1, diagnostics 5, loader 5, trace 10, and generated
  1+1 pass. Knowledge Map is 599/4,291. Canonical CI passes root 7+5, cursor 288, Perl primary 65x2, and Phase 0
  1,031/1,031 in 627 seconds. Root rollout remains 2/7. No background job runs.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0046`, neutral/Perl root precedent, exact Rust owners/tests/routes, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.2-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: Rust `.2.0` durable causal map/task/live/book docs await only commit;
  gates and cleanup pass. No Rust behavior file changed or background job runs.
  Cleanup removed 3.3 GiB Cargo output plus generated book/bytecode. Parked ignored work is untouched.
