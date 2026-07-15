# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.9.0` — split exhaustive Lua helper closeout.
- latest_commit: `29be5d72` — `LUA-BACKEND-PARITY.4.3.9.0 - split Lua exhaustive helper closeout`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.9.1 - execute Lua eager logical helpers`.
- active_work_unit: `.4.3.9.1` adds eager ordered boolean `and`/`or`/`not` over existing Lua truthiness and passes
  123/123 on PUC Lua and LuaJIT; exact recurring ownership/direct-call/inventory/status `.4.3.9.2` is next.
- next_action: finish `.4.3.9.1` lockstep/checks, commit and clean, then implement the permanent 246-name owner
  probe, direct `call(rule)` proof, duplicate inventory cleanup, status correction, and parent closure under `.2`.
- current_proof: dual-ABI Lua is 123/123 with all logical operands eager and ordered, empty false/false/true,
  governed zero/aggregate truthiness, boolean identity, and receiver continuation. Inventory remains 246 and
  capability 64/0/0; diagnostic `.5.1` and logical truthiness/Dart-evaluation/Perl-lowering `.5.2` stay gated.
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
- blockers: none. in_flight_uncommitted: `.4.3.9.1` runtime/test plus task/API/book/KM/live sync pass dual-ABI
  123/123 and await governance/book checks plus commit before the clean pivot to `.4.3.9.2`.
