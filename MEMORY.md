# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `LUA-BACKEND-PARITY.4.3.8` — add Lua diagnostic output events.
- latest_commit: `9e49ba7a` — `LUA-BACKEND-PARITY.4.3.8 - add Lua diagnostic output events`.
- prepared_commit: `LUA-BACKEND-PARITY.4.3.9.0 - split Lua exhaustive helper closeout`.
- active_work_unit: `.4.3.9.0` records the exact 246-name Lua runtime audit: 230 handled, thirteen intentional
  statement/receiver-only owners, and missing eager `and`/`or`/`not`; `.4.3.9.1` is the next behavior leaf.
- next_action: finish planning lockstep/checks, commit `.4.3.9.0`, clear the brief, confirm a clean tree, then
  implement eager Lua logical helpers under `.4.3.9.1` before final recurring admission/status `.4.3.9.2`.
- current_proof: generated PUC Lua probes cover 246/246 names as 230 runtime-owned + 13 intentional non-function +
  3 missing logical helpers. The prior dual-ABI gate is 122/122 and canonical CI is 64/0/0, 246/105+1/122, CLI
  61x2, Phase 0 `1..1031`/611s. Diagnostic `.5.1` and logical truthiness/Perl-lowering `.5.2` stay parity-gated.
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
- blockers: none. in_flight_uncommitted: `.4.3.9.0` task split, future owner, fact cards, and lockstep docs await
  governance/book checks plus commit before the clean pivot to logical implementation `.4.3.9.1`.
