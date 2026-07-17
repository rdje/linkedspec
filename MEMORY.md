# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.3` — Rust now consumes ADR `0043` through one typed
  helper/control truth seam, pre-effect logical arity, eager booleans, exact structured fields, and native/
  serialized/direct/generated-plan/compiled-emitted proof; rollout is 2 complete / 6 pending.
- latest_commit: `ea189973` — `FUTURE-PARITY-BACKLOG.9.1.1.1 - ratify rule-local cursor and bare edges`
  (ahead: 174; push at threshold 300).
- prepared_commit: none.
- active_work_unit: closing Rust logical-helper rollout `FUTURE-PARITY-BACKLOG.5.2.3`; cursor implementation
  `.9.1.2-.9` is dependency-ordered but remains pending until explicitly reached after the logical program.
- next_action: after this verified `.5.2.3` slice commits cleanly, activate Dart logical rollout
  `FUTURE-PARITY-BACKLOG.5.2.4`; preserve the pending cursor program `.9.1.2-.9` until the logical program closes.
- current_proof: `RuntimeValue::as_bool` is Rust's one typed truth seam; logical arity validates before eager
  collection; native structured errors expose the neutral fields; complete Rust/oracle/generated/emitted/primary
  proof passes. ADR `0044` remains the exact pending future cursor authority.
- latest_bootstrap_read: 2026-07-17 — full required roadmap, codebase ownership seams, mdBook, active task, Knowledge
  Map, TOOLBOX-relevant audit facts, and ADR context reviewed before the decision-only slice.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli roundtrip backlog `.8.1`; AND/OR implementation `.9.1.2-.9` after logical;
  semantic/MCP `.10.1`; toolbox inspector `.13.1`; structural/progressive authoring `.14`; rule-level lifecycle
  shorthand `.15`; parenthesis-free condition headers; lexical codeblock capture only if later justified.
- blockers: none. in_flight_uncommitted: verified `.5.2.3` implementation/docs await their owning commit; no
  background job remains. Mutation campaigns remain parked; ignored `rgx/subs/pgen` work remains untouched.
