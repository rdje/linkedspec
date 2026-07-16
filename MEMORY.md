# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.8.4` — Lua admitted as the fifth all-pass backend at 80/0/0.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.8.4 - admit Lua capability parity`.
- prepared_commit: `none`.
- active_work_unit: `LUA-BACKEND-PARITY.8.4` commit closeout; do not pivot until verified, committed, and clean.
- next_action: commit `.8.4`, clear the brief, verify a clean tree, then activate `FUTURE-PARITY-BACKLOG.5` / `.5.1`
  and audit the five-backend diagnostic-output contract through the Knowledge Map and TOOLBOX before behavior code.
- current_proof: focused Lua passes 177/177 on PUC Lua and LuaJIT, primary 61/61 under default and POSIX
  environments, complete corpus 105/105, and the warmed shared matrix 5x2x61. Capability and generated-source
  checkers report 16 capabilities / 80 pass / 0 partial / 0 gap. Callable signature/codeblock, native loading,
  and coverage 246/105+1/122 pass. Lua has deterministic exact v1/v2/v3 emission, valid/corrupt host isolation,
  ten-family execution/four rejections/portable trace, emitted variadic proof, and exact interpreter-first 8/105
  fresh-host proof. PUC Lua remains primary and LuaJIT the behavior-identical compatibility leg. Canonical local CI
  passes reference CLI 61x2 plus Phase 0 `1..1031` in 625 seconds.
- latest_bootstrap_read: 2026-07-16 — startup corpus plus generated-source v1, ADR 0023/0030/0041, exact v1/v2/v3
  descriptor, Lua compiled/spec-AST/JSON/runtime/trace seams, and completed Dart/Julia emitter/isolation precedents.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.8.4`; exact emission, isolation, families, portable trace, accepted subset, census, and
  shared CLI matrix are closed. in_flight_uncommitted: `.8.4` docs/manifest/checker closeout plus canonical gate;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
