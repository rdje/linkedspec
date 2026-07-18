# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.5` — Rust generated-source v2 emits only ordered
  label/family rows, derives all ten cursor policies, and rejects v1 before reconstruction.
- latest_commit: `d7b1a5e7` — `FUTURE-PARITY-BACKLOG.9.1.4.4 - project Rust cursor descriptor v1`
  (ahead: 196; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.5 - emit Rust generated-source v2`.
- active_work_unit: generated-source v2 `.9.1.4.5` is fully verified and uncommitted; do not activate public
  option/CLI removal `.9.1.4.6` until the `.5` commit leaves the tree clean.
- next_action: regenerate/check the Knowledge Map after final live-doc edits, rerun neutral/memory/task/doctrine/
  mdBook/JSON/format/whitespace checks, remove only safe generated artifacts/logs, review/stage, commit `.9.1.4.5`,
  clear `git_message_brief.txt`, verify clean, then activate `.9.1.4.6`.
- current_proof: New Rust artifacts identify generated-source v2/format 2, embed cursor-free ordinary CompiledSpec
  JSON plus one ordered label/family plan, derive seek for five default/OR families and consume for five AND
  families, and reject v1 before decode with exact expected/actual/regeneration fields. Core passes 189/4/5/8;
  runtime 137; oracle 105/205.58s; diagnostics 7; classifier 105/234.84s; integrations 197; emitter 5/37.16s;
  execution 6/59.37s; all adjacent suites, formatting, and production-library Clippy pass. Focused gate reaches
  only exact `.6` CLI boundary 51/63. Neutral cursor passes 36/18/8/14/71 at 2/6 plus 29 mutations; logical-helper
  topology passes 8/0 plus 26 mutations; Knowledge Map passes at 587/4,165. Canonical CI passes Perl cursor 288,
  reference CLI 63x2, and Phase 0 1,031/1,031 in 609 seconds, then exits 0; no background job is running.
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
- blockers: none. in_flight_uncommitted: fully verified `.9.1.4.5` implementation/docs awaiting its clean commit;
  no background job. Parked mutation work and ignored `rgx/subs/pgen` work are untouched.
