# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.9.2` — close exhaustive Lua runtime helper no-drift.
- latest_commit: `7e91f857` — `LUA-BACKEND-PARITY.4.3.9.2 - close Lua runtime helper no drift`.
- prepared_commit: `LUA-BACKEND-PARITY.4.4.0 - split Lua diagnostics trace controls`.
- active_work_unit: planning-only `.4.4.0` splits structured runtime failures, trace controls/sinks, interpreter
  events, and closeout; full native-pipeline propagation stays dependent `.5.3`, and `.4.4.1` becomes active.
- next_action: finish `.4.4.0` task/KM/book/live-doc checks, commit and clean, then implement neutral structured
  runtime diagnostics under `.4.4.1`.
- current_proof: both Lua ABIs pass 125/125; every admitted name parses/compiles, exact unsupported function forms
  are the thirteen documented structural/receiver-only names, direct call result/`retv`/cursor are focused,
  coverage is 246/105+1/122, and capability is 64/0/0. Public status is `runtime-helper-value-control`; source
  history corrects the prior duplicate-`or` note. Canonical CI passes CLI 61x2 and Phase 0 `1..1031` in 608 seconds.
  Runtime behavior/capability is unchanged by `.4.4.0`; current seams and Dart/Julia evidence support the split.
  Diagnostic `.5.1` and logical `.5.2` stay dependency-gated.
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
- blockers: none. in_flight_uncommitted: planning-only `.4.4.0` task/KM/book/live-doc changes await governance and
  commit before the clean pivot to structured runtime diagnostic `.4.4.1`; no Lua behavior is modified.
