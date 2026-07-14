# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.6.5.1.2` — executed deterministic scoped Lua harray callbacks.
- latest_commit: `56d0b073` — `LUA-BACKEND-PARITY.4.3.6.5.1.1 - preserve authored callback values`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.6.5.1.2 - execute Lua harray callbacks`.
- active_work_unit: verified harray callback execution; array-root and mixed-tree traversal `.4.3.6.5.2` is the
  prepared clean-pivot frontier.
- next_action: commit `.4.3.6.5.1.2`, verify a clean tree and zero-byte brief, then extend the atomic callback frame
  through zero-based array roots and mixed harray/array recursion under `.4.3.6.5.2`.
- current_proof: Atomic frames copy and restore `value`/`key`/`path`/`depth`/`acc`; lexical harray recursion keeps
  arrays as leaves, root depth 1, copied sources/results, walk/map continuation, terminal reduce, lazy empty/
  invalid receivers, and typed malformed calls. Direct Perl/Lua outputs agree. PUC Lua and LuaJIT pass 113/113;
  the current mandatory full local CI exits 0 with capability 64/0/0, CLI 61/61 twice, and phase0 `1..1031` in
  983 seconds.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.4.3.6.5.1.2` Lua runtime/test/book/KM/live-doc closeout awaits
  its prepared commit before clean pivot to array/mixed `.4.3.6.5.2`. Oracle timeout calibration remains `.7.0`.
