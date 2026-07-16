# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.6` — PUC Lua and LuaJIT consume the neutral typed diagnostic
  event contract with exact caller failure identity and distinct typed immediate exit.
- latest_commit: `38a42942` — current HEAD before the prepared Lua admission commit (ahead of origin: 164; push at
  the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.6 - admit Lua diagnostic events`; implementation, dual-ABI/full-Lua
  proof, canonical gate, contract ledger, and lockstep docs are complete and ready for the `COMMIT.md` workflow.
- active_work_unit: after the Lua commit is durable and the tree is clean, propagate diagnostic sinks through
  generated entrypoints and lock exact quiet primary projection under `FUTURE-PARITY-BACKLOG.5.1.7`.
- next_action: finish the `.5.1.6` commit workflow, clear
  `git_message_brief.txt`, verify a clean tree, then retrieve generated-entrypoint facts for `.5.1.7`.
- current_proof: the unchanged Lua baseline passed 105/109 neutral assertions and isolated only caller-thrown
  interpreter-error identity plus ordinary-error exit classification. After the two exact repairs, focused 109
  and existing 177 tests pass on both ABIs; complete Lua gate passes primary CLI 61x2 and corpus 105/105. Offline
  checker reports 5 complete/3 pending and rejects eight mutations; Knowledge Map, mdBook, task metadata, shell,
  Python, whitespace, and canonical CLI 61x2 plus Phase 0 `1..1031`/656s pass. Capability stays 80/0/0;
  generated/primary remains `.5.1.7`; no mutation campaign ran.
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
- blockers: none for `.5.1.6`.
  in_flight_uncommitted: complete verified Lua native admission slice awaiting commit. Mutation campaigns
  remain parked and no mutant run belongs to ordinary commit/local-CI workflow. Pre-existing modified/untracked
  `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
