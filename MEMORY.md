# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.4.3` — native runtime trace instrumentation.
- latest_commit: `4cd3347d` — `LUA-BACKEND-PARITY.4.4.3 - instrument Lua runtime trace`.
- prepared_commit: `LUA-BACKEND-PARITY.4.4.4 - close Lua diagnostics trace no drift`.
- active_work_unit: `.4.4.4` no-drift audit, public/durable alignment, focused proof, canonical verification, and
  parent `.4.4` closure are complete; its prepared commit remains before the clean pivot to `.5.1`.
- next_action: commit and clean `.4.4.4`, then pivot to staged-function/native-loading `.5.1`.
- current_proof: PUC Lua and LuaJIT pass 129/129. Exact API/source/test inventory covers diagnostics, ordered
  controls, environment mapping, event primitives, stdout/route/mirror/reset/append, result-neutral entrypoints,
  and parse/rule/regex/dispatch/recursion/lifecycle/cursor/boundary/mark-capture events. Public status remains
  `runtime-trace-events`; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
  CLI 61x2 and Phase 0 `1..1031` in 608 seconds. Full pipeline trace remains dependency-correct `.5.3`;
  diagnostic-output `.5.1` and logical `.5.2` stay dependency-gated.
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
- blockers: none. in_flight_uncommitted: `.4.4.4` no-drift records pass focused 129/129 on both Lua ABIs plus
  canonical CI; commit remains before the clean pivot to `.5.1`.
