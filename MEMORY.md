# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.5.2.8` — one omission-checked recurring driver composes the exact
  six-consumer native/generated topology, selected 5x2x1 primary case, support ledgers, and canonical registration;
  rollout is 7/1 with 22 rejected semantic/topology mutations.
- latest_commit: `53a108ea` — `FUTURE-PARITY-BACKLOG.5.2.7 - propagate logical generated projection`
  (ahead: 179; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.5.2.8 - add recurring logical-helper gate`.
- active_work_unit: verified recurring five-backend logical-helper gate `FUTURE-PARITY-BACKLOG.5.2.8` closing;
  public no-drift `.5.2.9` follows only after the clean commit, before cursor implementation `.9.1.2-.9`.
- next_action: run final governance/mdBook/diff checks, commit `.5.2.8`, verify clean, then activate `.5.2.9`.
- current_proof: direct and registered recurring drivers pass neutral logical 7/1 plus 22 semantic/topology
  mutations, Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT focused consumers, selected primary 5x2x1, and generated-source/
  capability 80/0/0 plus exhaustive 246/105+1/122 coverage. Unchanged full primary 5x2x63 passes. Canonical local
  CI passes reference CLI 63x2, Phase 0 `1..1031`/623s, and the registered logical leg. No runtime implementation
  or mutation campaign occurred.
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
- blockers: none. in_flight_uncommitted: verified `.5.2.8` recurring contract/checker/driver/local-CI registration
  and lockstep docs/KM await final governance checks and commit; no background job is running. Mutation campaigns remain parked;
  ignored `rgx/subs/pgen` work remains untouched.
