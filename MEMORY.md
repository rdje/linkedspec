# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.17.1` — align Perl/Rust complete named marks.
- latest_commit: `bb4fa9ee` — `LUA-BACKEND-PARITY.4.3.7.5 - add Lua boundary capture`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.17.1 - align Perl Rust complete named marks`.
- active_work_unit: `.17.1` is fully implemented and verified; its exact seven-helper contract aligns Perl
  live/generated and Rust native/serialized/emitted-plan/generated execution and awaits only the prepared commit.
- next_action: commit `.17.1`, clear the brief, verify clean, then activate and implement Dart named marks `.17.2`.
- current_proof: The unchanged `é\nAβ\nZ` fixture proves entry/local edge writers, character positions, 1-based
  line/column reads, absent undef, clear/existence, symbolic bare names, and same-name parent/child isolation. The
  neutral checker passes 7 helpers plus 3 rejection mutations; Perl live/standalone-generated and the focused Rust
  contract pass. The complete Rust core/runtime package gate passes 188 core, 137 runtime, 105 oracle, 105
  generated-corpus, 197 integration, and all focused suites. After a measured 19-string Phase-0 source-lock
  migration, canonical CI passes capability 64/0/0, CLI 61/61 twice, and Phase 0 `1..1031` in 983 seconds.
- latest_bootstrap_read: 2026-07-13 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: Lua generated parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: fully verified `.17.1` source/tests/docs await the prepared commit only;
  do not pivot before it lands and the tree is clean. Oracle timeout calibration remains future backlog `.7.0`.
