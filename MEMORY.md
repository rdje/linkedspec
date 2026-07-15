# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.2.1` — portable native resolution and strict-UTF-8 loading.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.2.1 - add Lua native spec loading`.
- prepared_commit: `none`.
- active_work_unit: automatic spec-owned top-level function-shell parsing `LUA-BACKEND-PARITY.5.2.2`.
- next_action: resolve the bundled `specs/user_function_definition.spec`, compile it once through current native
  APIs, execute it over caller source, normalize only typed output, and feed the existing Unicode projector/body
  dispatcher without a raw `fn` scanner.
- current_proof: `.5.2.1` exports typed named/path requests, load options, resolved/loaded/error values,
  deterministic cwd/suffix/direct-root selection, a minimal dual-ABI native file inspector, in-process byte reads,
  strict UTF-8 preservation, and exact error JSON. PUC Lua and LuaJIT consume all shared 14/9/4 cases directly at
  149/149 with status `native-spec-resolution-loading-v1`; capability is 64/0/0. The `.5.2.0` native probe already
  proves current Lua can compile and execute the spec-owned function parser. Canonical CI passes CLI 61x2 plus
  Phase 0 `1..1031` in 1,265 seconds. `.5.2.3` owns full composition,
  `.5.2.4` no-drift, `.5.3` descriptors/full trace; mutation testing remains manual-only.
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
- blockers: none. in_flight_uncommitted: `.5.2.1` is fully verified and awaiting commit;
  mutation campaigns remain parked and no mutant run belongs to ordinary commit/local-CI workflow.
