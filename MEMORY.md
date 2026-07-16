# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.0` — director confirms that parent OR/AND mode never
  propagates to or overrides child mode; OR children remain seek and AND children remain consume.
- latest_commit: `6f37e063` — `FUTURE-PARITY-BACKLOG.9.1.0 - audit cursor semantic ownership` (ahead: 172; push at
  the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.0 - capture rule-local cursor ownership`; decision capture and
  fresh-session handoff docs are complete and verified.
- active_work_unit: exact AND/OR edge/cursor/migration ratification `FUTURE-PARITY-BACKLOG.9.1.1.1` is next. Rust
  logical `.5.2.3` remains pending until the AND/OR design is committed and implementation is separately split.
- next_action: ratify the backend-neutral bare/explicit edge, indexed/grouped/fluent, nested-call, intrinsic cursor,
  API/CLI/descriptor/generated/diagnostic/conformance contract; split implementation without changing behavior.
- current_proof: exact default `Top::AND` over `prefix x` returns `"hit"` on Perl/Dart/Julia/Lua and null on Rust;
  explicit seek hits and explicit consume returns null on all five. Perl toolbox/source plus five-backend engine,
  compiled-state, API, CLI, generated, descriptor, test, and doc tracing root-causes global ownership versus Rust's
  derived mode. AND+seek ordered-landmark and OR+consume anchored-choice probes are real matcher objectives, not a
  justification for rewriting every nested rule from a caller.
- latest_bootstrap_read: 2026-07-17 — startup corpus plus cursor audit, rule/edge book, current task, Knowledge Map,
  relevant ADRs, and child-owned cursor decision refreshed for a clean handoff.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR implementation after active `.9.1` design;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: completed/verified `.9.1.1.0` awaits commit, brief clear, and clean
  fresh-session handoff; no runtime behavior changed. Mutation campaigns remain parked; pre-existing ignored
  `rgx/subs/pgen` work remains untouched.
