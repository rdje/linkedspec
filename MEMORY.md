# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.7.3` — closed exact Lua primary/native/corpus usage no-drift.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.7.3 - close Lua primary usage no drift`.
- prepared_commit: `none`.
- active_work_unit: deterministic contract-v1 generated Lua emitter scaffold/isolation `LUA-BACKEND-PARITY.8.1`
  after `.7.3` commits.
- next_action: commit verified `.7.3`; then inspect the exact generated-source v1 contract, effective Lua compiled
  state, existing backend emitters, isolation/error/trace precedents, and split `.8.1` if one safe slice is too broad.
- current_proof: focused Lua passes 169/169 on PUC Lua and LuaJIT, the unchanged primary process manifest 61/61
  under default and POSIX environments, and complete corpus 105/105. The warmed shared matrix builds one disposable
  PUC native adapter and passes Perl/Rust/Dart/Julia/Lua at 5x2x61 exact cases. Status is
  `runtime-corpus-primary-cli`; primary semantics, generated source, coverage 246/105+1/122, and capability 64/0/0
  are unchanged. Canonical local CI exits 0 with reference CLI 61/61 in both environments and Phase 0 `1..1031`
  in 608 seconds. Checkout setup directly loads current status, runs help/inline parsing, validates 105 fixtures,
  and retains caller-built native modules until trap cleanup; no primary corpus/status extension exists.
- latest_bootstrap_read: 2026-07-15 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.8.1`; exact generated-source scope is already split under `.8.1-.8.4`.
  in_flight_uncommitted: `.7.3` public no-drift docs and exact canonical proof await commit;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
