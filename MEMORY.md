# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.8.2` — Rust exact aggregate-selector hard rejection.
- latest_commit: `ac217f6c` — `FUTURE-PARITY-BACKLOG.12.1.8.1 - hard-reject Perl aggregate selectors`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.8.2 - hard-reject Rust aggregate selectors`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.8.2`; verified and awaiting final governance/docs checks and
  commit. Dart `.12.1.8.3` is the recorded next frontier.
- next_action: finish governance/docs checks, commit `.12.1.8.2`, verify clean, then begin Dart `.12.1.8.3`.
- current_proof: Rust rejects all six neutral exact-selector cases across full compiled/generated state, including
  dead/nested code, deferred fluent arguments, and unused functions; eight retained classes pass. Focused proof is
  15/15, scanner 0 positive/13 classified, core 185+3+8, integration 197/197, interpreted/generated corpus 105,
  CLI 61x2, and canonical CI including Phase 0 `1..1031` pass. The 30-second-bound oracle emits 105 fixtures and
  the final post-rename generated full-manifest classifier passes in 329.32 seconds.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.8.2` implementation/tests/corpus rename/docs await final checks and
  commit. Oracle timeout-default calibration is durably deferred to `.7.0`; the
  documented 30-second override is sufficient now. Dart `.12.1.8.3` follows.
