# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.1.3.2` — fresh typed variadic-v2 runtime execution.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.1.3.2 - execute Lua variadic functions`.
- prepared_commit: `none`.
- active_work_unit: clean handoff to contextual final-codeblock metadata
  `LUA-BACKEND-PARITY.5.1.4.1` after native variadic-v2 execution closes at 139/139 on both Lua ABIs.
- next_action: preserve final-only `callback: codeblock` parameter metadata through Lua shell/staged/registry/call
  normalization and reject invalid declarations under `.5.1.4.1`; do not begin contextual execution `.5.1.4.2`.
- current_proof: Lua evaluates variadic positional arguments once in caller order, copies the complete invocation
  frame, binds fixed prefixes normally, and copies extras into one fresh typed rest array. The unchanged neutral
  fixture passes; empty/repeated arrays and nested array/harray/null/boolean/codeblock values remain isolated;
  receiver chains work; minimum/keyword failures stay typed. Both Lua ABIs pass 139/139; callable signature/
  codeblock checkers pass 3/9/7 and 7/11/9/7/4/8; canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 621
  seconds. Status is `runtime-user-functions-variadic-v2`; capability is 64/0/0; descriptors/generated source
  remain `.5.3`/`.8`.
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
- blockers: none. in_flight_uncommitted: none after the prepared `.5.1.2` commit; mutation campaigns remain parked
  and no mutant run belongs to ordinary commit/local-CI workflow.
