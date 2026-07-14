# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.7.0` — audited and split Lua capture/cursor runtime mechanisms.
- latest_commit: `6e752117` — `LUA-BACKEND-PARITY.4.3.6.6 - close Lua block control callback parity`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.7.0 - split Lua capture cursor mechanisms`.
- active_work_unit: docs/KM/task-owned `.4.3.7.0` split; no parser/compiler/runtime behavior changed. Input/cursor
  `.4.3.7.1` is dependency-ready after the clean-pivot inventory finding is durably task-owned.
- next_action: finish and commit `.4.3.7.0`, verify a clean tree/zero-byte brief, create and commit the cross-backend
  task owner for the seven documented current mark helpers missing from all governed 239-name inventories, then
  return to Lua input/cursor implementation `.4.3.7.1`.
- current_proof: Source audit confirms immutable byte-offset registers plus Unicode projection seams, no Lua cursor
  stack/named-mark frame/helper execution, parsed-but-uncompiled split-marker nodes, and shipped `@move_pos` usage.
  The coverage checker is corpus-seeded in reverse, so seven symmetric current-mark omissions remain invisible.
  PUC Lua and LuaJIT remain 114/114; KM/memory/task/doctrine/book/whitespace checks pass; census remains 64/0/0.
- latest_bootstrap_read: 2026-07-13 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified planning-only `.4.3.7.0` task/book/KM/live split awaits its
  prepared commit. Oracle timeout calibration remains future backlog `.7.0`.
