# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.14.0` — structural/progressive/staged authoring-doctrine capture.
- latest_commit: `3326ae17` — `FUTURE-PARITY-BACKLOG.12.1.7.3 - migrate embedded selector sources`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.14.0 - capture structural progressive parsing doctrine`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.8.1`; hard-reject exact selectors on Perl after this commit.
- next_action: commit `.12.1.7.3`, verify the tree clean, then activate `.12.1.8.1` and replace Perl selector
  recognition/dispatch with the adopted portable rejection diagnostic.
- current_proof: `.14.0` extends ADR 0012 with simple boundary-regex/linked-rule recursion and distinguishes
  progressive in-parse composition from returned-AST staged enrichment. The function-body `body_parse_job` is the
  current narrow prototype; `.14.1-.14.4` own public guidance and general implementation proof. No behavior changed.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: `.14.0` planning/docs/KM alignment awaits governance checks and commit;
  `.12.1.8.1` remains the immediate implementation frontier. Lua scalar numeric `.4.3.3.1.4` follows retirement.
