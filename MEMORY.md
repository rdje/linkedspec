# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.3.0` — split Lua descriptor/trace/admission work after exact audit.
- latest_commit: `HEAD` — `LUA-BACKEND-PARITY.5.3.0 - split Lua descriptor trace admission`.
- prepared_commit: `none`.
- active_work_unit: descriptor-shape and census-timing decision `LUA-BACKEND-PARITY.5.3.0.1`.
- next_action: obtain the director's two policy choices, record them under `.5.3.0.1`, then implement exact outward
  descriptors `.5.3.1` before one-emitter full-pipeline trace `.5.3.2` and closeout/admission `.5.3.3`.
- current_proof: `.5.3.0` finds exact fixed-v1 and variadic-v2 outward schemas, but no neutral final-codeblock
  record shape for `parameter_kinds`; Lua retains its explicit descriptor fence. The original `.5.3` census
  sentence predates current completion-time Lua admission policy. Runtime alone accepts one caller emitter; every
  loading/frontend/validation/compiler/function/staged seam is inventoried. No source, behavior, status,
  descriptor, capability, or test expectation changed; Lua remains 153/153 on both ABIs and capability remains
  64/0/0; canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 605 seconds. Mutation testing remains
  manual-only and was not run.
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
- blockers: `.5.3.0.1` awaits director decisions on final-codeblock outward schema scope and Lua census timing.
  in_flight_uncommitted: none after the `.5.3.0` planning commit; mutation campaigns remain parked and no mutant
  run belongs to ordinary commit/local-CI workflow.
