# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.1.2` — native fixed-v1 registered-function execution.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.1.2 - execute Lua fixed user functions`.
- prepared_commit: `none`.
- active_work_unit: clean handoff to variadic-v2 typed state `LUA-BACKEND-PARITY.5.1.3.1` after fixed-v1 execution
  closes at 133/133 on both Lua ABIs.
- next_action: preserve the exact fixed-v1/variadic-v2 callable-signature union through Lua shell, AST, staged
  records, registry, contracts, and compiled state under `.5.1.3.1`; do not begin rest-array execution `.5.1.3.2`.
- current_proof: registered Lua calls resolve before helpers, evaluate positional arguments once left-to-right,
  execute integrity-checked staged bodies through fresh copied stores, restore callers on success/failure, return
  local final/early values, compose nested/discard/receiver positions, and diagnose arity/keyword/recursion/body
  drift through typed function-owned failures. Both Lua ABIs pass 133/133; canonical local CI passes CLI 61x2 and
  Phase 0 `1..1031` in 605 seconds. Status is `runtime-user-functions-fixed-v1`; capability is 64/0/0.
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
