# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.0` — exact Perl/toolbox and five-backend native/generated
  audit records three truthiness profiles, two Perl mechanisms, and the dependency-correct `.5.2.1-.9` split.
- latest_commit: `b86f5754` — `FUTURE-PARITY-BACKLOG.5.1.9 - close diagnostic-output public no-drift` (ahead: 168;
  push at the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.0 - split logical helper parity`; implementation/docs/verification
  are complete, and the commit/brief-clear/clean-pivot check remain.
- active_work_unit: executable backend-neutral logical evaluation/arity/truthiness contract
  `FUTURE-PARITY-BACKLOG.5.2.1` is active after the prepared planning commit lands cleanly.
- next_action: commit `.5.2.0`, clear the brief, verify the tree clean, then retrieve applicable decision precedent
  and expand `.5.2.1` acceptance before authoring the neutral decision, fixture, and checker.
- current_proof: exact toolbox/live/emitted Perl probes distinguish lazy condition lowering, raw/broken direct
  values, and the `not(false,true)` optional-scope collision. Primary side effects prove eager Rust/Julia versus
  short-circuit Dart; generated probes match native Rust/Dart/Julia/PUC-Lua/LuaJIT. Three truthiness profiles are
  durable in the task/KM/book, and `.5.2.1-.9` are dependency-ordered. Focused Perl 4/Rust 137/Dart 60/complete
  Julia/Lua 177x2 and canonical CLI 62x2/Phase 0 `1..1031` pass; no behavior or mutant run.
- latest_bootstrap_read: 2026-07-16 — startup corpus, logical Knowledge Map/toolbox, all five helper/truthiness/
  generated seams, exact current probes, relevant tests, and public helper docs.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for neutral contract `.5.2.1` after the prepared commit lands.
  in_flight_uncommitted: completed and verified `.5.2.0` awaiting commit/brief clear/clean pivot only. Mutation campaigns remain
  parked and no mutant run belongs to ordinary commit/local-CI workflow. Pre-existing dirty `rgx/subs/pgen`
  work is not LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx`
  worktree state.
