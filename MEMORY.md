# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.16.2.0` — calibrated neutral receiver-arity example.
- latest_commit: `1b87445f` — `FUTURE-PARITY-BACKLOG.16.1 - adopt zero-argument syntax contract`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.16.2.0 - calibrate receiver arity fixture`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.16.2.1`; implement the unchanged contract on the Perl reference.
- next_action: use LinkedSpec toolbox probes, then align Perl statement/control/next and final-only receiver parsing;
  regression-lock neutral AST, generated source, execution, arity, and excluded-syntax behavior.
- current_proof: toolbox and canonical arity table prove drop_front receiver arity `[0,1]` and contains `[1,1]`;
  corrected strict contract passes unchanged, capability stays 60/0/0, CLI passes 61x2, and Phase 0
  `1..1031`/605s. No backend behavior changed; `if(condition)`/`while(condition)` retain parentheses.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua built-in final blocks `.4.3.6.4`; parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: `.16.2.0` contract-calibration/task/book/KM/live-doc synchronization
  awaits its prepared commit; no parser/compiler/runtime behavior changed. Oracle timeout calibration remains `.7.0`.
