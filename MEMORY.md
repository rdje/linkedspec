# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.3` — Rust native diagnostic helpers consume the neutral
  typed per-execution event contract without direct stderr, while preserving distinct runtime/sink/exit outcomes.
- latest_commit: `2aef726e` — `FUTURE-PARITY-BACKLOG.5.1.2 - add Perl diagnostic event seam` (ahead of origin: 161;
  push at documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.3 - add Rust diagnostic event seam` (source/tests/docs and all
  gates complete; commit workflow in flight).
- active_work_unit: commit the fully verified Rust native diagnostic-output event seam
  `FUTURE-PARITY-BACKLOG.5.1.3`; do not pivot while this tree is dirty.
- next_action: commit `.5.1.3`, clear the brief, verify clean, then implement Dart native diagnostic-output event
  seam `.5.1.4` test-first against the unchanged neutral fixture.
- current_proof: six-test neutral Rust consumer covers 11 render rows, five invalid arities, six scenarios, trace
  separation, concrete sink failure, and typed exit. Complete Rust gate passes 137 unit, 105 corpus, six
  diagnostic-output, 105 generated-classifier, 197 integration, existing source/diagnostic/trace suites, and CLI
  61x2. Offline checker reports 2 complete/6 pending and rejects eight mutations. Canonical local CI passes exact
  CLI 61x2 and Phase 0 `1..1031` in 611 seconds. Capability remains 80/0/0; generated/primary propagation stays
  `.5.1.7`. No mutation campaign ran.
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
- blockers: none for `.5.1.3`; neutral contract and Perl precedent are committed. in_flight_uncommitted: the
  complete verified Rust leaf source/tests/docs are staged for commit. Mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
