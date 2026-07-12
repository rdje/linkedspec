# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.11.3.3.2` — Perl metadata-governed final-block normalization.
- latest_commit: `607ef365` — `FUTURE-PARITY-BACKLOG.11.3.3.1 - declare final codeblock parameters`.
- prepared_commit: `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks`.
- active_work_unit: `FUTURE-PARITY-BACKLOG.11.3.4`; close Perl callable diagnostics/docs/full-gate no-drift.
- next_action: after committing `.11.3.3.2`, audit remaining Perl diagnostics and raw/coderef/harray/name-gate
  residue, run the complete closeout gate, then route the unchanged contract to Rust `.11.4`.
- current_proof: Perl typed user/staged metadata, shared helper/receiver callable contracts, canonical zero-arg
  contextual `codeblock_argument`, explicit literal preservation, harray rejection, invalid declarations, and
  standalone generated execution pass focused proof. The strict checker remains green across all 46 cases and
  direct Phase 0 passes `1..1030` in 966 seconds. Canonical CI passes capability 60/0/0, CLI 61x2, and Phase 0
  `1..1030` in 916 seconds.
- latest_bootstrap_read: 2026-07-12 — full roadmap/codebase/mdBook continuity revalidated through the current delta;
  complete facade/lazy import tree and all active scalar-text runtime/test/doc surfaces inspected.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 10-minute timeout.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: parser+stimuli roundtrip `.8.1`; AND/OR edge defaults `.9.1`; semantic/MCP `.10.1`; lexical codeblock
  capture (new decision only if justified). After `.11.3.4`, prioritize `.12.1` removal of spec-facing
  `array(name)`/`hash(name)` namespace and mutation semantics before Rust codeblock or Lua work.
- blockers: none. in_flight_uncommitted: `.11.3.3.2` implementation/tests/docs are prepared for final gate and
  commit. Lua scalar numeric `.4.3.3.1.4` remains ready after the prioritized `.11` arc.
