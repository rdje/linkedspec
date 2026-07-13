# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.16.0` — exact zero-argument syntax audit and ADR 0033 ratification.
- latest_commit: `67e423ad` — `LUA-BACKEND-PARITY.4.3.6.3.3 - execute Lua attached while controls`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.16.0 - ratify zero-argument call aliases`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.16.1`; define the reusable neutral positive/negative contract.
- next_action: encode the six standalone aliases, final generic receiver alias, retained parenthesized forms, and
  excluded condition-header/argument/intermediate-receiver cases in one backend-neutral contract before parsers.
- current_proof: all rule/lifecycle suffix parsers already preserve bare zero-argument suffixes; typed ActionIR
  support differs, no backend recognizes bare `next`, and only Lua accepts generic bare receiver segments. ADR
  0033 keeps this a narrow exception and defers parenthesis-free `if`/`while` condition headers.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua built-in final blocks `.4.3.6.4`; parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: `.16.0` ADR/task/roadmap/book/KM/live-doc planning synchronization awaits
  its prepared commit; no parser/compiler/runtime behavior changed. Oracle timeout calibration remains `.7.0`.
