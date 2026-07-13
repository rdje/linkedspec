# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.12.1.8.1` — Perl exact aggregate-selector hard rejection.
- latest_commit: `96179766` — `FUTURE-PARITY-BACKLOG.14.0 - capture structural progressive parsing doctrine`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.12.1.8.1 - hard-reject Perl aggregate selectors`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.12.1.8.1`; verified and awaiting canonical gate/commit.
- next_action: finish canonical local CI, commit `.12.1.8.1`, verify clean, then activate Rust rejection
  `.12.1.8.2` before returning to queued `.13`/`.14` side-band work.
- current_proof: Perl rejects all six neutral exact-selector cases before ActionIR lowering, including dead rule
  code and unused function bodies; retained constructors/literals pass. Focused Perl is 41 green, executable scan
  is 0 positive/19 classified, regenerated oracle is 105, Rust corpus replay is 3/3, and standalone/canonical
  Phase 0 are each `1..1031`/934s; canonical capability is 60/0/0 and CLI is 61x2.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; toolbox inspector
  repair `.13.1`; lexical codeblock capture (new decision only if justified); resumed Lua work follows `.12.1`.
- blockers: none. in_flight_uncommitted: `.12.1.8.1` implementation/tests/generated fixtures/docs await canonical
  gate and commit. Rust `.12.1.8.2` follows; Lua scalar numeric `.4.3.3.1.4` follows retirement.
