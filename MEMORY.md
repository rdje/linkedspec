# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.7` — every available generated direct/traced role propagates
  the neutral diagnostic sink, while all five primary commands remain exactly quiet and canonical.
- latest_commit: `92e3d36e` — `FUTURE-PARITY-BACKLOG.5.1.6 - admit Lua diagnostic events` (ahead of origin: 165;
  push at the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.7 - propagate generated diagnostic events`; the completed and
  verified `.5.1.7` worktree is awaiting its commit and brief cleanup.
- active_work_unit: finish the `.5.1.7` commit workflow; do not begin active recurring-gate leaf
  `FUTURE-PARITY-BACKLOG.5.1.8` until the repository is clean.
- next_action: stage and commit `.5.1.7`, clear the brief, verify a clean tree, then retrieve recurring-gate facts
  and add `.5.1.8`'s detailed checklist before changing behavior.
- current_proof: focused generated sink/value/event/trace/failure/exit consumers pass on Perl, Rust, Dart, Julia,
  PUC Lua, and LuaJIT. Complete Rust/Dart/Julia/Lua gates and the corrected shared 5x2x62 CLI matrix pass; offline
  diagnostic checker reports 6 complete/2 pending and rejects eight mutations; generated-source and capability
  checks pass at 80/0/0. Canonical local CI passes primary CLI 62x2 plus Phase 0 `1..1031` in 623 seconds. An
  initial direct-`E` fixture reproduced the known Perl lifecycle drift; toolbox probes isolated it and the final
  portable action-edge fixture passes. No mutation campaign ran.
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
- blockers: none for `.5.1.7` or the `.5.1.8` handoff.
  in_flight_uncommitted: complete, verified, documented `.5.1.7` implementation awaiting commit. Mutation
  campaigns remain parked and no mutant run belongs to ordinary commit/local-CI workflow. Pre-existing dirty
  `rgx/subs/pgen` work is not LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores
  dirty `rgx` worktree state.
