# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.17.5` — admit complete named-mark inventory.
- latest_commit: `2f951c6c` — `FUTURE-PARITY-BACKLOG.17.4 - align Lua complete named marks`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.17.5 - admit complete named mark inventory`.
- active_work_unit: `.17.5` is implemented, synchronized, and fully verified; only its prepared commit, brief
  cleanup, and clean-tree check remain. Parent `.17` closes with this leaf.
- next_action: commit `.17.5`, clear the brief, verify a clean tree, then pivot to active Lua
  `LUA-BACKEND-PARITY.4.3.7.3`.
- current_proof: Dart, Julia, and Lua share 246 current calls. Coverage uses the 105-case corpus plus the exact
  named-mark fixture, independently checks all 122 public identifier-shaped Perl contracts, and rejects the exact
  nine compatibility/legacy/internal exclusions. A simultaneous three-inventory `clear_mark` deletion triggers
  both exact-family and independent reverse checks. Exact neutral/Perl/Rust proofs and complete Dart 214,
  Julia 1,414, Lua 119/119 on both ABIs, and Rust package/CLI 61x2 gates pass. Canonical CI passes capability
  64/0/0, coverage 246/105+1/122, CLI 61x2, and Phase 0 `1..1031` in 633 seconds.
- latest_bootstrap_read: 2026-07-14 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: fully verified `.17.5` source/test/checker/docs/KM await the prepared
  commit only; do not pivot before it lands and the tree is clean. Oracle timeout calibration remains future
  `.7.0`.
