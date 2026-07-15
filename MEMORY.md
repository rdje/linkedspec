# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.1.4.2` — contextual final-codeblock dynamic execution.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.1.4.2 - execute Lua contextual codeblocks`.
- prepared_commit: `none`.
- active_work_unit: clean handoff to staged-function no-drift `LUA-BACKEND-PARITY.5.1.5` after contextual final
  blocks close at 146/146 on both Lua ABIs.
- next_action: audit fixed-v1, variadic-v2, and contextual-codeblock runtime/API/status/docs/KM no-drift, close
  parent `.5.1`, and activate native loading `.5.2` without claiming descriptors/full trace `.5.3`, generated
  source `.8`, or explicit/dynamic codeblock values `.11.7`.
- current_proof: Lua copies normalized zero-positional contextual blocks into isolated user-function frames and
  invokes declared slots against current dynamic bindings. Nonparameter effects remain visible within the
  invocation, outer stores restore, results chain, and registered functions/governed helpers keep static
  precedence. Missing/harray/arity/recursion failures stay typed. Both Lua ABIs pass 146/146; callable signature/
  codeblock checkers pass 3/9/7 and 7/11/9/7/4/8; coverage is 246/105+1/122; capability is 64/0/0; status is
  `runtime-user-functions-contextual-codeblock-v1`; canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in
  622 seconds; descriptors/generated source remain `.5.3`/`.8`.
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
- blockers: none. in_flight_uncommitted: none after the `.5.1.4.2` commit; mutation campaigns remain parked
  and no mutant run belongs to ordinary commit/local-CI workflow.
