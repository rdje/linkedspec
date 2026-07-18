# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.7` — Rust composes 15 exact admission roles, advances only
  `rust_parity` to 3/5, and closes parent `.9.1.4` after complete Rust and canonical signoff.
- latest_commit: `2bba1e91` — `FUTURE-PARITY-BACKLOG.9.1.4.6 - remove Rust global cursor overrides`
  (ahead: 198; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.7 - admit Rust rule-local cursor contract`.
- active_work_unit: composed Rust admission/parent closeout `.9.1.4.7` is fully verified; Dart `.9.1.5` remains
  pending behind the fully verified clean commit.
- next_action: run final lightweight lockstep checks, commit `.9.1.4.7`, clear the brief, verify the clean boundary,
  reclaim safe generated artifacts, then activate Dart `.9.1.5` task-tree-first.
- current_proof: the neutral authority declares 15 exact Rust roles plus canonical/default-to-optional-Rust gate
  topology. One composed consumer executes native default/AND, ordinary serialized, loaded, descriptor-v1,
  emitted-v2, generated direct/trace, mixed/recursive, both structural replacements, static removal, primary, and
  all eight diagnostic/removal outcomes exactly once. The checker reports 36/18/8, Perl 14, Rust 15, inventory 68,
  rollout 3/5, and 34 rejected mutations. Pre-edit constituent proof was core normalization 5/5, descriptor 4/4,
  runtime execution 6/6, emitter 5/5, and primary 63x2. The complete post-edit Rust gate exits 0 with core
  189/4/5/8; runtime 137; oracle 3/205.40s; diagnostics 7; classifier 105/234.99s; integrations 197/75.60s; composed
  admission 1/23.79s; execution 6/59.58s; emitter 5/36.90s; every adjacent suite; and primary 63x2. Formatting
  and advisory Clippy are green for the new consumer. Canonical CI exits 0 with Perl admission 288, reference
  primary 63x2, and Phase 0 1,031/1,031 in 612 seconds; no background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, and generated-source/live/descriptor seams reviewed before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.5-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: fully verified `.9.1.4.7` contract/checker/consumer, canonical
  registration, and lockstep docs await the clean commit. Parked mutation work and ignored `rgx/subs/pgen` work
  are untouched.
