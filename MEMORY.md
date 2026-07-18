# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.6` — Rust removes static/runtime global cursor ownership,
  retains entry selection plus rule-derived policy, and passes exact primary 63x2.
- latest_commit: `727cccc3` — `FUTURE-PARITY-BACKLOG.9.1.4.5 - emit Rust generated-source v2`
  (ahead: 197; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.6 - remove Rust global cursor overrides`.
- active_work_unit: public option/CLI removal `.9.1.4.6` is fully verified and awaiting its clean commit; composed
  Rust admission `.9.1.4.7` remains pending and must not activate before that commit.
- next_action: perform final lightweight checks, safe artifact cleanup, staged review, and commit `.9.1.4.6`; only
  from the clean commit activate composed Rust admission `.9.1.4.7` task-tree-first.
- current_proof: `ExecutionOptions` retains only `entry_rule`; runtime-context global override/effective-mode
  state is deleted; normal execution still derives policy per entered rule. Rust primary recognizes retired
  `--parse-mode` only for the exact usage failure, and request trace has no global mode field. Exact pre-edit
  default/POSIX baselines were 51/63; post-edit both are 63/63. Rule-local execution passes 6/6 (59.31s), primary
  units 6/6, complete runtime 137 plus oracle 3/205.39s, diagnostics 7, classifier 105/235.07s, integrations 197,
  emitter 5/37.10s, execution 6/59.57s, and adjacent suites. The complete focused gate independently exits 0 with
  core 189/4/5/8, runtime 137, oracle 3/205.44s, diagnostics 7, classifier 105/235.42s, integrations 197/75.12s,
  execution 6/59.52s, emitter 5/37.18s, adjacent suites, and primary 63x2. Formatting, production-library Clippy,
  neutral 36/18/8/14/68 at 2/6 plus 29 mutations, logical topology plus 26 mutations, doctrines, and mdBook pass.
  Canonical CI exits 0 with Perl cursor 288, reference primary 63x2, and Phase 0 1,031/1,031 in 611 seconds; no
  background job is running.
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
- blockers: none. in_flight_uncommitted: fully verified `.9.1.4.6` implementation and durable lockstep await final
  cleanup/review/commit; no background job. Parked mutation work and ignored `rgx/subs/pgen` work are untouched.
