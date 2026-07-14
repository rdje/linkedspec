# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.7.1` — add Lua input cursor controls.
- latest_commit: `6b243820` — `FUTURE-PARITY-BACKLOG.17.0 - split complete named mark parity`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.7.1 - add Lua input cursor controls`.
- active_work_unit: verified `.4.3.7.1` implements all whole-input/live-cursor projections and parse-scoped LIFO
  save/restore plus entry/local rewinds over the byte-safe Lua runtime seam.
- next_action: run final docs/doctrine/full local gates, commit `.4.3.7.1`, clear the brief, verify a clean tree,
  then implement anonymous capture-boundary helpers `.4.3.7.2`.
- current_proof: Multibyte coverage locks character-unit input/cursor positions, lengths, slices, lines/columns,
  receiver continuation, invalid/past-end spans, nested/empty restore, distinct entry/local rewinds, typed arity,
  and consume continuation. `tools/run_lua_local.sh` passes 115/115 on PUC Lua and LuaJIT plus syntax/process/
  manifest checks. Full CI passes capability 64/0/0, CLI 61/61 twice, phase0 `1..1031` in 918 seconds, and all
  doctrine/contract/book gates. No named-mark, marker, generated-source, inventory, corpus, or capability changed.
- latest_bootstrap_read: 2026-07-13 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.4.3.7.1` runtime/test/docs await final gates and prepared
  commit. Oracle timeout calibration remains future backlog `.7.0`.
