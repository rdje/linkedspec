# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.8.2` — exact generated Lua family plans and authoritative execution.
- latest_commit: `HEAD` — prepared `LUA-BACKEND-PARITY.8.2 - execute generated Lua families`.
- prepared_commit: `none`.
- active_work_unit: contract-sourced interpreter-first accepted-subset admission `LUA-BACKEND-PARITY.8.3` after
  `.8.2` commits.
- next_action: consume the exact contract-owned accepted-subset names and order from JSON, prove interpreter values
  first, then emit/load independent generated modules in fresh PUC Lua and LuaJIT hosts with exact metadata, plan,
  trace, callable-signature, path/order/no-skip, and cleanup assertions owned by the checker.
- current_proof: focused Lua passes 176/176 on PUC Lua and LuaJIT, the unchanged primary process manifest 61/61
  under default and POSIX environments, and complete corpus 105/105. The warmed shared matrix builds one disposable
  PUC native adapter and passes Perl/Rust/Dart/Julia/Lua at 5x2x61 exact cases. Status is
  `runtime-corpus-primary-cli`; coverage 246/105+1/122 and capability 64/0/0 are unchanged. Generated Lua now emits
  exact v1/v2/v3 effective state, survives valid/corrupt fresh-host isolation, and exposes typed source-ordered
  ten-family plans with four pre-execution rejections. The validated map authoritatively controls root/nested
  regex-versus-blind dispatch and portable generated enter/decision/exit trace; one 26-row all-family matrix and
  emitted neutral variadic fixture pass in fresh dual-ABI hosts with cleanup. Canonical local CI exits 0 with
  reference CLI 61/61 in both environments and Phase 0 `1..1031` in 626 seconds. Accepted-subset proof is active
  under `.8.3`.
- latest_bootstrap_read: 2026-07-16 — startup corpus plus generated-source v1, ADR 0023/0030/0041, exact v1/v2/v3
  descriptor, Lua compiled/spec-AST/JSON/runtime/trace seams, and completed Dart/Julia emitter/isolation precedents.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua census admission `.8.4` after active subset `.8.3`;
  generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.8.3`; exact emission, isolation, plans, family execution, and portable trace are closed.
  in_flight_uncommitted: none after the prepared `.8.2` commit;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
