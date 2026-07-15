# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.19.0` — plan write vivification and bang mutation after parity.
- latest_commit: `1d5a1577` — `FUTURE-PARITY-BACKLOG.19.0 - plan write vivification and bang mutation`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.7.6 - close Lua capture cursor parity`.
- active_work_unit: docs-only `.4.3.7.6` has exact 62-call/four-marker no-drift proof, closes parent `.4.3.7`,
  preserves generated Lua ownership under `.8.1-.8.4`, and activates diagnostic output helper `.4.3.8`.
- next_action: verify and commit `.4.3.7.6`, clear the brief, confirm a clean tree, then audit/split or implement
  caller-owned `print`/`say`/`print_each` output events and retained immediate `exit_now` semantics under `.4.3.8`.
- current_proof: Lua contracts/runtime/focused execution sources agree 62/62 with four marker spellings. PUC Lua
  and LuaJIT pass 121/121; complete marks, coverage 246/105+1/122, selector 57/27/0, punctuation-light, and
  capability 64/0/0 pass. `.19.1+` remains gated on complete current-backend parity.
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
- blockers: none. in_flight_uncommitted: docs-only `.4.3.7.6` closeout awaits governance/book checks and prepared
  commit before clean pivot to `.4.3.8`. `.19.1+` and structured-format execution remain parity-gated.
