# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.6.6` — closed Lua block/control/callback parity and later routing.
- latest_commit: `b841c09a` — `LUA-BACKEND-PARITY.4.3.6.5.2 - execute Lua array callbacks`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.6.6 - close Lua block control callback parity`.
- active_work_unit: verified docs-only `.4.3.6.6` closeout; capture-slice/mark/input/cursor family `.4.3.7` is the
  prepared clean-pivot frontier.
- next_action: commit `.4.3.6.6`, verify a clean tree and zero-byte brief, then audit and split or implement the
  dependency-ready capture/cursor helper family under `.4.3.7`.
- current_proof: Eager blocks, inline/statement controls, metadata-governed `with`, and same-root-kind harray/array
  callbacks pass 114/114 on PUC Lua and LuaJIT. Callable-codeblock and punctuation-light checkers pass; capability
  census is 64/0/0; preceding full CI passes CLI 61/61 twice and phase0 `1..1031` in 987 seconds. `.5.1` explicitly
  owns final `callback: codeblock` user-function execution; explicit callable literals/dynamic calls remain `.11.7`.
- latest_bootstrap_read: 2026-07-13 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: docs-only `.4.3.6.6` task/book/KM/live closeout awaits its prepared commit
  before clean pivot to `.4.3.7`. Oracle timeout calibration remains `.7.0`.
