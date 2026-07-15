# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.5.1.0` — dependency-correct staged-function split.
- latest_commit: `7579bade` — `LUA-BACKEND-PARITY.5.1.0 - split Lua staged function execution`.
- prepared_commit: `LUA-BACKEND-PARITY.5.1.1 - add Lua staged body dispatch`.
- active_work_unit: `.5.1.1` implementation, durable alignment, focused proof, governance, book, and canonical
  verification are complete; its prepared commit remains before the clean `.5.1.2` pivot.
- next_action: commit and clean `.5.1.1`, then implement fixed-v1 registered calls `.5.1.2`.
- current_proof: Lua now validates/normalizes/stable-sorts exact staged jobs, resolves the sole governed ActionIR-body
  provider and digest/cache/compiled identity, parses exact body text, immutably stitches `body_ast`, composes the
  spec-owned shell, and rejects provider/sidecar/duplicate-job drift. PUC Lua and LuaJIT pass 130/130; coverage
  remains 246/105+1/122, capability 64/0/0, and public status is `runtime-staged-registry`. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 622 seconds. Registered fixed-v1 runtime remains `.5.1.2`; descriptors/full
  trace `.5.3`; generated source `.8`; callable literals `.11.7`.
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
- blockers: none. in_flight_uncommitted: `.5.1.1` source/API/test/docs/KM pass focused 130/130 on both Lua ABIs,
  capability/book/governance gates, and canonical CI; commit remains before the clean `.5.1.2` pivot.
