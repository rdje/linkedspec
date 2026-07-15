# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.2.0` — dependency-correct native-loading split.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.2.0 - split Lua native spec loading`.
- prepared_commit: `none`.
- active_work_unit: portable native request/resolution/strict-UTF-8 loading `LUA-BACKEND-PARITY.5.2.1`.
- next_action: add public typed request/options/resolved/loaded/error values and consume every shared 14/9/4 case
  directly on both Lua ABIs, with no parse/compile work, recursive fallback, implicit root, or transcoding.
- current_proof: ADR `0026`, the executable contract, completed loaders, and current Lua seams are audited. A
  direct native probe parses/validates/compiles `specs/user_function_definition.spec`, executes it over real
  `fn zero()` source, and returns one exact typed node, so `.5.2.2` can later automate spec-owned shell parsing
  without a raw scanner. `.5.2.1` owns resolve/load, `.5.2.3` full composition, `.5.2.4` no-drift, and `.5.3`
  descriptors/full trace. Both ABIs remain 146/146; native contract checker passes 14/9/4; capability is 64/0/0;
  status remains `runtime-user-functions-contextual-codeblock-v1`; mutation testing remains manual-only.
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
- blockers: none. in_flight_uncommitted: none after the `.5.2.0` commit; mutation campaigns remain parked
  and no mutant run belongs to ordinary commit/local-CI workflow.
