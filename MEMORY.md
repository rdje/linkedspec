# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.1` — the focused Rust gate now runs complete core tests
  before complete runtime tests, closing the preflight's verification-topology gap without behavior changes.
- latest_commit: `1ea716ce` — `FUTURE-PARITY-BACKLOG.9.1.4.0 - audit Rust cursor rollout boundaries`
  (ahead: 192; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.1 - run Rust core tests in local gate`.
- active_work_unit: finish the commit workflow for verified Rust gate-hardening `.9.1.4.1`, clear/verify the brief,
  and establish the clean boundary before typed normalization `.9.1.4.2`.
- next_action: commit `.9.1.4.1`, clear/verify `git_message_brief.txt`, confirm a clean tree, then activate
  `FUTURE-PARITY-BACKLOG.9.1.4.2` for exact family classification and typed bare-edge normalization.
- current_proof: Actual `tools/run_rust_local.sh` passes core 188 unit + 3 descriptor + 8 type tests before the
  complete runtime package (137 unit, 105 oracle, 105 classifier, 197 integration, all adjacent suites), then
  builds the command and reaches exactly the expected default 51/63 boundary. Preflight proves POSIX 51/63.
  Neutral cursor remains 36/18/8/14/72 at 2/6 plus 29 mutations. No Rust behavior changes; operational docs/KM
  are aligned. Canonical CI passes the 288-test Perl consumer, CLI 63x2, and Phase 0 1,031/1,031 in 646 seconds,
  then exits 0. Its first attempt correctly caught and drove repair of a dropped governed task-index marker. No
  mutation campaign.
- latest_bootstrap_read: 2026-07-17 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, and generated-source/live/descriptor seams reviewed before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.4-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: verified `.9.1.4.1` gate/docs await commit; no background job. Parked
  mutation work and ignored `rgx/subs/pgen` work are untouched.
