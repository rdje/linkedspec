# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.2.2` — automatic cached spec-defined function parsing.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.2.2 - automate Lua function parsing`.
- prepared_commit: `none`.
- active_work_unit: loaded-source parse/validate/compile and identity-bearing engine composition
  `LUA-BACKEND-PARITY.5.2.3`.
- next_action: add `load_and_compile_spec(...)` and an identity-preserving loaded/compiled result, map frontend
  pipeline stages/codes exactly, create source-identified runtime engines, and prove top-level function execution
  without changing inline APIs or claiming CLI/descriptor/full-trace behavior.
- current_proof: `.5.2.1` provides deterministic typed native resolve/load and exact strict UTF-8. `.5.2.2` now
  resolves the bundled `user_function_definition.spec` through one exact module-relative owner, validates and
  compiles it once, executes it in process, and composes typed fixed/variadic/final-codeblock nodes through the
  existing Unicode projector/body dispatcher without a raw scanner. PUC Lua and LuaJIT pass 151/151 with status
  `native-spec-defined-functions-v1`; capability is 64/0/0. Canonical local CI passes CLI 61x2 plus Phase 0
  `1..1031` in 631 seconds. `.5.2.3` owns loaded-source full composition, `.5.2.4` no-drift, and `.5.3`
  descriptors/full trace; mutation testing remains manual-only.
- latest_bootstrap_read: 2026-07-15 — complete README/roadmaps, memory architecture, resume/task/decision records,
  Knowledge Map, toolbox, commit workflow, active Lua code/runtime/test surfaces, and every mdBook source file read
  and understood before implementation.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: `.5.2.2` is fully verified and awaiting commit;
  mutation campaigns remain parked and no mutant run belongs to ordinary commit/local-CI workflow.
