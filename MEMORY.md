# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.6.5.1.0` — split callback append scope repair from Lua traversal.
- latest_commit: `ce310aed` — `LUA-BACKEND-PARITY.4.3.6.4 - execute Lua built-in final blocks`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.6.5.1.0 - split callback append scope repair`.
- active_work_unit: verified planning/root-cause split; reference repair `.4.3.6.5.1.1` is the prepared clean-pivot
  frontier before Lua harray execution `.4.3.6.5.1.2`.
- next_action: commit `.4.3.6.5.1.0`, verify a clean tree and zero-byte brief, then stop `cat(key, ...)` callback
  append RHS values from being consumed as optional scope labels under `.4.3.6.5.1.1`.
- current_proof: Typed AST preserves `seen += cat(key,"@",depth)`; Perl lowering drops `key` only when `cat`'s
  shared optional-scope normalizer can remove a bare first argument without violating arity. Two-argument `cat`
  retains it. Tree callback `depth` is `count(path)` (root 1), not zero-based. No runtime changed; committed Lua
  PUC/LuaJIT proof remains 112/112 and capability 64/0/0.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.4.3.6.5.1.0` task split/KM/live-doc closeout awaits its prepared
  commit before the required clean pivot to reference repair `.4.3.6.5.1.1`. Oracle timeout calibration remains `.7.0`.
