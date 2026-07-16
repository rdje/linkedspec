# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.1.0` — diagnostic-output drift is measured and split before code.
- latest_commit: `a4810484` — `LUA-BACKEND-PARITY.8.4 - admit Lua capability parity` (ahead of origin: 158;
  push at documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.1.0 - split diagnostic output parity`.
- active_work_unit: neutral executable diagnostic-output contract `FUTURE-PARITY-BACKLOG.5.1.1` after `.5.1.0`
  commits cleanly.
- next_action: ratify and encode exact neutral arity, once-only evaluation, scalar/message/event, quiet sink,
  failure/exit, generated propagation, and ADR-0024-primary-CLI projection fixtures before backend behavior code.
- current_proof: toolbox and exact native/process probes show Perl per-item `print_each` effects, raw invalid calls,
  invalid mixed-encoding primary output, and host-exit bypass; Rust direct stderr; Dart eager discard; Julia low-trace
  coupling/permissive arity/newline default; and Lua typed synchronous caller-owned events. Focused Rust/Dart tests,
  direct Julia trace, Lua quiet/sink-failure, and five-command arity/Unicode/exit captures pass. Capability stays
  80/0/0; no behavior changed. Governance, Knowledge Map, and mdBook pass; canonical local CI passes primary CLI
  61x2 plus Phase 0 true reach `1..1031` in 607 seconds.
- latest_bootstrap_read: 2026-07-16 — startup corpus, diagnostic Knowledge Map cards, TOOLBOX, ADR 0024, all five
  runtime/helper seams, generated entrypoints, primary adapters, current native tests, and public helper docs.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none for `.5.1.1`; parity dependency is closed. in_flight_uncommitted: `.5.1.0` planning/docs commit
  preparation only; no parser/compiler/runtime/generated/CLI behavior change exists;
  mutation campaigns remain parked and no mutant run belongs to
  ordinary commit/local-CI workflow. Pre-existing modified/untracked `rgx/subs/pgen` work is not
  LinkedSpec-owned and remains untouched; root `.gitmodules` intentionally ignores dirty `rgx` worktree state.
