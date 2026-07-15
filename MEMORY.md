# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.4.0` — split Lua diagnostics and trace by dependency.
- latest_commit: `dcf2d89b` — `LUA-BACKEND-PARITY.4.4.0 - split Lua diagnostics trace controls`.
- prepared_commit: `LUA-BACKEND-PARITY.4.4.1 - add Lua runtime diagnostics`.
- active_work_unit: `.4.4.1` adds neutral typed runtime diagnostics with optional source identity, specific stages,
  deepest-rule/handler preservation, deterministic JSON, unchanged text/success, and 126/126 dual-ABI proof.
- next_action: commit and clean verified `.4.4.1`, then implement trace levels, controls, event primitives, and
  caller-owned sinks under `.4.4.2`.
- current_proof: PUC Lua and LuaJIT pass 126/126. Missing-rule exact JSON, nested child attribution, richer lookup
  preservation, empty-state selection, invalid UTF-8 input, optional spec identity, error JSON, and successful
  result identity pass. Public status is `runtime-structured-diagnostics`; coverage remains 246/105+1/122 and
  capability remains 64/0/0. Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 613 seconds. Full
  pipeline trace remains dependency-correct `.5.3`; diagnostic-output `.5.1` and logical `.5.2` stay
  dependency-gated.
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
- blockers: none. in_flight_uncommitted: `.4.4.1` runtime/API/tests plus task/book/KM/live sync pass 126/126 on both
  Lua ABIs and canonical local CI; commit is the only remaining step before the clean pivot to trace controls
  `.4.4.2`.
