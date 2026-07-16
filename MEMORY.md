# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.2` — Perl typed ActionIR/runtime logical values now consume
  `linkedspec-logical-helper-v1` across native/live/standalone-emitted roles at 1/7 rollout.
- latest_commit: `62619940` — `FUTURE-PARITY-BACKLOG.5.2.1 - ratify logical helper contract` (ahead: 170; push at
  the documented threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.2 - repair Perl logical lowering`; implementation/docs/
  verification are complete, and only commit, brief clear, and clean pivot remain.
- active_work_unit: Rust logical native alignment `FUTURE-PARITY-BACKLOG.5.2.3` is the roadmap frontier after the
  prepared Perl commit lands cleanly; do not begin it before the director's cursor-semantics insight is given a
  dedicated task-tree-owned audit by expanding existing design leaf `FUTURE-PARITY-BACKLOG.9.1` at that clean
  pivot.
- next_action: commit `.5.2.2`, clear the brief, verify clean, then activate/expand `.9.1` to investigate whether
  OR must intrinsically seek and AND intrinsically consume with no public `parse_mode` override; audit every
  caller/compatibility consequence before code changes, then return to `.5.2.3`.
- current_proof: focused Perl neutral/live/emitted/typed-site/host-scalar tests pass; shared numeric zero and false
  comparison stay false while string `"0"` stays true; the canonical hash-tree callback preserves A/B leaves.
  Neutral checker passes 1/7 with 15 mutations; focused ActionIR/codeblock/generated/diagnostic tests and Phase 0
  `1..1031` pass. Codeblock truth remains model/backend-unit evidence without activating `.11` literal syntax.
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
- blockers: none. in_flight_uncommitted: completed/verified `.5.2.2` awaits commit, brief clear, and clean pivot.
  Mutation campaigns remain parked; pre-existing ignored `rgx/subs/pgen` work remains untouched.
