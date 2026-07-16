# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.1` — ADR `0043` plus
  `linkedspec-logical-helper-v1` ratify eager exact-arity boolean helpers over one typed truthiness seam.
- latest_commit: `38181c35` — `FUTURE-PARITY-BACKLOG.5.2.0 - split logical helper parity` (ahead: 169; push at
  the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.1 - ratify logical helper contract`; implementation/docs/
  verification are complete, and only commit, brief clear, and clean pivot remain.
- active_work_unit: Perl typed-AST/lowering rollout `FUTURE-PARITY-BACKLOG.5.2.2` activates after the prepared
  neutral-contract commit lands cleanly.
- next_action: commit `.5.2.1`, clear the brief, verify clean, then expand `.5.2.2` acceptance before Perl behavior
  changes.
- current_proof: the offline checker validates 17 truthiness rows, ten helper cases, three eager effect scenarios,
  receiver/lazy-control contrast, four pre-effect arity failures, deterministic fixtures, exact projections,
  0/8 rollout, and 15 mutations. Codeblock truth remains model/backend-unit evidence without activating `.11`
  literal syntax. Canonical CI passes reference CLI 62x2 and Phase 0 `1..1031`/639s. No parser/compiler/runtime/
  generated/primary/corpus/capability behavior or mutant run.
- latest_bootstrap_read: 2026-07-16 — full startup corpus plus logical audit/decision precedents, current five-
  backend mechanisms, helper book surfaces, callable-codeblock scope, and canonical CI registration.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR edge defaults `.9.1`;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: completed/verified `.5.2.1` awaits commit, brief clear, and clean pivot.
  Mutation campaigns remain parked; pre-existing ignored `rgx/subs/pgen` work remains untouched.
