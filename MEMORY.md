# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.5.2` — add deterministic Lua harray views and membership.
- latest_commit: `bb444bc1` — `LUA-BACKEND-PARITY.4.3.5.1 - add Lua harray construction splicing`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.5.2 - add Lua deterministic harray views`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.5.3`; copied harray transforms and compatible receiver chains.
- next_action: implement `.4.3.5.3` only: merge/set/rename/drop/pick copied values and receiver composition.
- current_proof: lexical `sorted_keys`, copied values in the same order, count, and null-aware membership work in
  function/receiver forms; sorted arrays bridge onward while count/membership terminate. Missing/wrong-kind inputs
  return `0`/`[]`; PUC Lua and LuaJIT pass 101/101. Perl toolbox proof corrected a stale catalog `undef` claim.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: none after the prepared `.4.3.5.2` commit. Lua copied harray transforms/
  receiver chains `.4.3.5.3` are next. Oracle timeout calibration remains deferred to `.7.0`.
