# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.3` — exact 15-role topology, 29 mutations, Rust-local
  and canonical 65x2 proof, public/book/KM lockstep, and cleanup admit Rust root selection at 3/7; commit pending.
- latest_commit: `1b57294d` — `FUTURE-PARITY-BACKLOG.9.1.1.2.2.2 - converge Rust root routes`
  (ahead: 213; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.3 - admit Rust root selection`.
- active_work_unit: Rust admission `.9.1.1.2.2.3` and parent `.2.2` are fully signed off; their prepared commit is
  the only in-flight boundary. Dart `.9.1.1.2.3` is not active and must wait for a clean tree.
- next_action: commit `.2.3`, clear `git_message_brief.txt`, prove the tree clean, then activate and safely split
  Dart root selection `.9.1.1.2.3` task-tree-first before any Dart change.
- current_proof: One omission-sensitive Rust consumer executes all 15 declared roles exactly once; governance
  locks six primary cases and 29 mutations. Focused admission/core/routes/emitter passes 1+6+6+6. Full Rust-local
  passes core 193+4+5+8, runtime 137, oracle 105/215.90s, classifier 105/249.47s, integration 197, admission
  1/16.89s, emitter 6/49.64s, and primary 65x2. Canonical passes all four doctrines, root governance, Perl root
  7+5, cursor 288, reference primary 65x2, and Phase 0 1,031/1,031 in 627s. Public/book/capability/live records
  agree at 3 complete / 4 pending; KM is 603/4,328. Cleanup removes 10,626 Cargo dependency/incremental files,
  reducing `rust/target` from 2.4 GiB to 99 MiB, plus generated book/cache/logs. No background job runs.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0046`, neutral/Perl root precedent, exact Rust owners/tests/routes, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.3-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed `.2.3` admission closeout awaits its prepared commit only;
  Dart is not activated. No background job runs. Parked ignored work is untouched.
