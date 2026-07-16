# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.5` — Julia native diagnostic helpers consume the neutral typed
  per-invocation event contract with exact caller failure, structured runtime, trace, and exit separation.
- latest_commit: `f4d0d61d` — current HEAD before the prepared Julia commit (ahead of origin: 163; push at the
  documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.5 - add Julia diagnostic event seam`; implementation, proof, and
  lockstep docs are complete and ready for the `COMMIT.md` workflow.
- active_work_unit: after the Julia commit is durable and the tree is clean, admit Lua's existing native event
  design against the neutral fixture under `FUTURE-PARITY-BACKLOG.5.1.6`; no Lua work has started.
- next_action: finish the Julia commit workflow, clear `git_message_brief.txt`, verify a clean tree, then retrieve
  the Lua diagnostic-event fact card and add the unchanged neutral-fixture consumer before changing Lua behavior.
- current_proof: the neutral Julia consumer passes 74 assertions over 11 render rows, five invalid arities, six
  scenarios, all four native aliases, trace separation, exact arbitrary sink-failure identity, and typed exit.
  Complete Julia gate passes package tests, primary CLI 61x2, and corpus 105/105. Capability remains 80/0/0;
  generated/primary propagation stays `.5.1.7`. Offline checker reports 4 complete/4 pending and rejects eight
  mutations; Knowledge Map, doctrines, mdBook, whitespace, and canonical CLI 61x2 plus Phase 0 `1..1031`/616s pass.
  No mutation campaign ran.
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
- blockers: none for `.5.1.6`; neutral contract plus Perl/Rust/Dart/Julia native precedents are complete.
  in_flight_uncommitted: the verified Julia `.5.1.5` slice awaits only its commit workflow. Mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
