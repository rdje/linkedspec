# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.17.2` — align Dart complete named marks.
- latest_commit: `6708485c` — `FUTURE-PARITY-BACKLOG.17.1 - align Perl Rust complete named marks`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.17.2 - align Dart complete named marks`.
- active_work_unit: `.17.2` is fully implemented, synchronized, and verified; it awaits only the prepared commit,
  brief cleanup, and clean-tree check. Julia complete named marks `.17.3` is the recorded next frontier.
- next_action: commit `.17.2`, clear `git_message_brief.txt`, verify a clean tree, then inspect Julia `.17.3` from
  its existing rule-local/code-unit mark seam before any implementation change.
- current_proof: The unchanged `é\nAβ\nZ` fixture passes Dart native, generated-plan, emitted-state reconstruction,
  and primary-CLI execution. All seven calls use the existing rule-local code-unit store with character public
  positions/locations; absent `mark_pos` stays undef. Exact staged inventory, strict analysis, focused 68, all 214
  package tests, CLI 61/61 twice, and corpus 105/105 pass. Canonical CI passes capability 64/0/0, unchanged shared
  coverage 239/105, CLI 61/61 twice, and Phase 0 `1..1031` in 1,061 seconds.
- latest_bootstrap_read: 2026-07-13 — README, roadmap, full codebase, mdBook, memory architecture, task-tree,
  decisions, Knowledge Map, and relevant Dart capture/mark/runtime/inventory surfaces read and understood.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: fully verified `.17.2` source/test/docs/KM await the prepared commit only;
  do not pivot before it lands and the tree is clean. Oracle timeout calibration remains future backlog `.7.0`.
