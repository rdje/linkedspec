# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.3.4` — new Perl generated source is v2, derives intrinsic
  five-seek/five-consume policy from the exact ten families, and rejects v1 reconstruction with `.spec` regeneration.
- latest_commit: `ccf4cad7` — `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture`
  (ahead: 188; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.3.4 - emit Perl generated-source v2`.
- active_work_unit: commit the fully verified generated-source-v2 slice, clear/verify the brief, and establish a
  clean pivot boundary. API/CLI and reference-fixture migration `.9.1.3.5` remains inactive until that boundary.
- next_action: commit `.9.1.3.4`, clear/verify `git_message_brief.txt`, confirm a clean tree, then activate
  `FUTURE-PARITY-BACKLOG.9.1.3.5`.
- current_proof: Focused generated/cursor/trace 400 plus adjacent 92 pass; touched Perl modules compile. Neutral
  cursor passes 36/18/8/87 at 1/7 plus 27 mutations; shared generated/capability truth stays 80/0/0. Standalone
  Phase 0 passes 1,031/1,031. Canonical local CI passes reference CLI 63/63 twice and Phase 0 1,031/1,031 in 619
  seconds. Fresh v2 emission/load/direct/trace/source identity, option-independent bytes, all ten families, explicit
  and inferred-caller v1 rejection, mdBook/KM/governance/whitespace, and safe artifact cleanup pass. `ccf4cad7`'s
  missed token-inventory update is root-caused and durably reconciled at 87 files.
- latest_bootstrap_read: 2026-07-17 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, and generated-source/live/descriptor seams reviewed before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.3.4-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: fully verified `.9.1.3.4` awaits commit; no background job. Parked mutation
  work and ignored `rgx/subs/pgen` work are untouched.
