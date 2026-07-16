# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.9` — public no-drift closes diagnostic-output parent `.5.1`
  at 8 complete / 0 pending; logical truthiness/arity/lowering `.5.2` follows after a clean commit.
- latest_commit: `18c21090` — `FUTURE-PARITY-BACKLOG.5.1.8 - add recurring diagnostic-output gate` (ahead: 167;
  push at the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.9 - close diagnostic-output public no-drift` after final lightweight
  checks; do not begin `.5.2` until this commit lands and the tree is clean.
- active_work_unit: `.5.1.9` implementation, documentation, and complete verification are finished; only final
  lightweight checks, commit, brief clearing, and clean-pivot verification remain.
- next_action: run the final KM/mdBook/governance/contract/whitespace checks, commit `.5.1.9`, clear the brief,
  verify a clean tree, then retrieve and split active logical-contract leaf `.5.2` before behavior changes.
- current_proof: checker reports 8/0 across 16 authoritative documents, nine stale-claim guards, and 20 mutations.
  Complete Rust/Dart/Julia/dual-ABI-Lua gates, recurring Perl 16/Rust 7/Dart 7/Julia 82/PUC Lua 119/LuaJIT 119,
  selected CLI 5x2x1, unchanged 5x2x62, generated-source/capability 80/0/0, and exhaustive coverage pass.
  Canonical local CI passes reference CLI 62x2, Phase 0 `1..1031`, and the registered driver. No runtime semantics
  changed and no mutation campaign ran.
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
- blockers: none for `.5.1.9` closeout or `.5.2` retrieval.
  in_flight_uncommitted: completed and verified `.5.1.9` awaiting final lightweight checks and commit. Mutation campaigns remain
  parked and no mutant run belongs to ordinary commit/local-CI workflow. Pre-existing dirty `rgx/subs/pgen`
  work is not LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx`
  worktree state.
