# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.1.3.1` — exact variadic-v2 signature-state preservation.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.1.3.1 - preserve Lua variadic signatures`.
- prepared_commit: `none`.
- active_work_unit: clean handoff to fresh typed rest-array execution `LUA-BACKEND-PARITY.5.1.3.2` after exact
  variadic-v2 state closes at 136/136 on both Lua ABIs.
- next_action: bind ordered variadic extras into one fresh copied typed array, including the empty case, and execute
  the unchanged neutral callable fixture under `.5.1.3.2`; do not begin descriptor admission `.5.3` or generated
  preservation/execution `.8`.
- current_proof: Lua preserves the exclusive fixed-v1 params/arity versus variadic-v2 six-field signature union
  through shell, AST, staged jobs, registry, contracts, and compiled state; sidecar drift and seven invalid
  definitions fail typed; resolution accepts the fixed-prefix minimum through an unbounded maximum and carries
  `at least N` expectations; runtime and descriptors fail closed for their later owners. Both Lua ABIs pass
  136/136; callable signature/codeblock checkers pass 3/9/7 and 7/11/9/7/4/8; canonical local CI passes CLI 61x2
  and Phase 0 `1..1031` in 620 seconds. Status is `runtime-user-functions-variadic-v2-state`; capability is 64/0/0.
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
