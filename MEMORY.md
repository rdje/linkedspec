# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.3` — Rust normal live, loaded, and ordinary reconstructed
  rules derive cursor policy from every entered family without parent/global propagation or mutable compiled state.
- latest_commit: `8780990a` — `FUTURE-PARITY-BACKLOG.9.1.4.2 - normalize Rust rule edges`
  (ahead: 194; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.3 - derive Rust rule-local cursor policy`.
- active_work_unit: finish the clean commit boundary for fully verified Rust live execution `.9.1.4.3`; do not
  activate descriptor `.9.1.4.4` while the tree is dirty.
- next_action: commit `.9.1.4.3`, clear/verify `git_message_brief.txt`, confirm a clean tree, and only then activate
  descriptor leaf `.9.1.4.4` before its first executable edit.
- current_proof: `CompiledRule` no longer stores mutable cursor policy; live, loaded, ordinary JSON-reconstructed,
  action, blind, direct-call, recursive, and traced execution derives exact AND consume versus default/OR seek from
  each entered rule. Descriptor/generated v1 retain one bounded adapter; the staged public option cannot override
  live behavior. Execution 6/6 covers 36 family + 8 parent/child + 2 structural rows; core passes 189/3/5/8;
  runtime passes 137, oracle 105/216.25s, diagnostics 7, classifier 105/243.60s, integrations 197, and all adjacent
  suites. Formatting and production-library Clippy pass. The focused gate reaches only the governed 51/63 `.6`
  CLI boundary. Neutral cursor passes 36/18/8/14/74 at 2/6 plus 29 mutations; Knowledge Map is 586/4,151; all
  governance/mdBook checks pass; canonical CI passes Perl consumer 288, CLI 63x2, and Phase 0 1,031/612s. No
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
- blockers: none. in_flight_uncommitted: verified `.9.1.4.3` code/tests/docs await only their clean commit; no
  background job. Parked mutation work and ignored `rgx/subs/pgen` work are untouched.
