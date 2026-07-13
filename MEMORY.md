# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.5.3.0` — revalidate current harray transform contracts.
- latest_commit: `5be724de` — `LUA-BACKEND-PARITY.4.3.5.2 - add Lua deterministic harray views`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.5.3.0 - revalidate harray transform contracts`.
- active_work_unit: `LUA-BACKEND-PARITY.4.3.5.3.1`; implement copied Lua harray transforms/receiver chains.
- next_action: implement `.4.3.5.3.1` only: merge/set/rename/drop/pick copied values and receiver composition.
- current_proof: July 12 uniform binding supersedes the old bare-first merge exception. Perl returns `2` for
  `merge_hash(base, overlay)` and `merge_hash(copy(base), overlay)`; exact `hash(base)` rejects. The bare-first
  neutral case passes Dart/Julia selection and Rust's 105-case oracle. Current KM/runtime facts and mdBook agree.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle shorthand `.15`; lexical codeblock
  capture (new decision only if justified).
- blockers: none. in_flight_uncommitted: `.4.3.5.3.0` contract/doc correction awaiting its prepared commit; no
  runtime behavior changed. Lua implementation `.4.3.5.3.1` is next. Oracle timeout calibration remains `.7.0`.
