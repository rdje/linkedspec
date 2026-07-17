# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.4.0` — exact Rust cursor preflight maps current drift and
  splits gate-safe `.1-.7` implementation leaves without executable behavior changes.
- latest_commit: `c35755f7` — `FUTURE-PARITY-BACKLOG.9.1.3.6 - admit Perl cursor projection`
  (ahead: 191; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.4.0 - audit Rust cursor rollout boundaries`.
- active_work_unit: finish documentation/governance/canonical verification for Rust preflight `.9.1.4.0`, commit,
  clear/verify the brief, and establish the clean boundary before gate-hardening child `.9.1.4.1`.
- next_action: commit `.9.1.4.0`, clear/verify `git_message_brief.txt`, confirm a clean tree, then activate
  `FUTURE-PARITY-BACKLOG.9.1.4.1` and add complete `linkedspec-core` tests to `tools/run_rust_local.sh`.
- current_proof: Full Rust runtime package passes, including 137 unit, 197 integration, and exhaustive generated
  suites. Independent core passes 188 unit + 3 descriptor + 8 type tests. Rust primary is exactly 51/63 in both
  environments (one retired flag + eleven trace bytes); Perl remains 63/63 twice. Neutral cursor remains
  36/18/8/14/72 at 2/6 plus 29 mutations. The focused Rust gate's omitted-core risk is durable in task/KM/book;
  `.9.1.4.1` repairs it before behavior. Canonical CI repeats the 288-test Perl consumer and 63x2 reference CLI,
  passes Phase 0 1,031/1,031 in 640 seconds, and exits 0. KM is 584/4,129; mdBook/governance pass. No executable
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
- blockers: none. in_flight_uncommitted: documentation-only `.9.1.4.0` preflight awaits final gates and commit; no
  background job. Parked mutation work and ignored `rgx/subs/pgen` work are untouched.
