# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.18.0` — adopt structured-text requirements program.
- latest_commit: `35e4a55b` — `LUA-BACKEND-PARITY.4.3.7.3 - execute Lua named mark spans`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.18.0 - adopt structured text requirements program`.
- active_work_unit: `.18.0` planning is synchronized without behavior changes; final governance/book/count checks,
  prepared commit, brief cleanup, and clean-tree verification remain.
- next_action: verify and commit `.18.0`, clear the brief, confirm a clean tree, then return to active Lua
  placement-sensitive split/mark execution `LUA-BACKEND-PARITY.4.3.7.4`.
- current_proof: ADR `0034` and `STRUCTURED-TEXT-FORMAT-PROGRAM` map all 91 eligible catalog rows across seven
  seed formats, derived families, explicit profiles, and closeout. `.1+` is hard-gated on complete Perl/Rust/Dart/
  Julia/Lua parity. Each composed format `.spec` graph is the sole dynamically compiled parser source; generated
  host source/caches are derivative only. Format gaps drive reusable neutral all-backend features; hidden host
  parsers are forbidden; HTML is an independent WHATWG path; parsing is separate from evaluation/domain semantics;
  Unicode plus cold/warm/parse performance require executable evidence. No behavior changed.
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
- blockers: none. in_flight_uncommitted: planning-only `.18.0` ADR/task/roadmap/book/KM/live docs await verification
  and prepared commit; do not return to `.4.3.7.4` before it lands and the tree is clean. The structured-format
  execution tree remains dependency-gated on full current-backend parity.
