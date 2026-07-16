# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.2` — Perl native diagnostic helpers consume the neutral
  parse-scoped typed event contract without host output or host process-control coupling.
- latest_commit: `d72d279a` — `FUTURE-PARITY-BACKLOG.5.1.1 - ratify diagnostic output events` (ahead of origin: 160;
  push at documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.2 - add Perl diagnostic event seam` after final canonical gate.
- active_work_unit: verified Perl native diagnostic-output event seam `FUTURE-PARITY-BACKLOG.5.1.2`; source,
  tests, rollout ledger, task/index/roadmap/live docs, mdBook, and Knowledge Map are in flight for this commit.
- next_action: review staged scope, commit `.5.1.2`, clear the brief, verify a clean tree, then pivot to Rust native
  rollout `.5.1.3` and map its current stderr/control seams.
- current_proof: focused neutral Perl contract passes 16 top-level tests; combined contract/uniform-binding proof
  passes 28; generated-source contract and offline checker pass with 1 complete/7 pending rollout legs; Phase 0
  passes `1..1031` in 640 seconds; canonical CI repeats it in 637 seconds after exact CLI 61x2. Capability remains
  80/0/0; generated-entrypoint/primary admission and other
  backends remain later-owned. No mutation campaign ran.
- latest_bootstrap_read: 2026-07-16 — startup corpus, diagnostic Knowledge Map cards, TOOLBOX, ADR 0024, all five
  runtime/helper seams, generated entrypoints, primary adapters, current native tests, and public helper docs.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.5.1.2`. in_flight_uncommitted: complete verified Perl implementation/tests/docs staged for
  commit and clean-tree pivot; mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
