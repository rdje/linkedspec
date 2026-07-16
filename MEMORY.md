# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.1` — ADR `0044` ratifies intrinsic AND consume and
  OR/default seek, child-owned policy, mode-sensitive bare edges, removal migration, derived descriptor facts,
  generated-source v2 family derivation, portable diagnostics, conformance, and implementation split.
- latest_commit: this decision commit — `FUTURE-PARITY-BACKLOG.9.1.1.1 - ratify rule-local cursor and bare edges`
  (resolve its hash with `git log -1`; expected ahead: 174; push at threshold 300).
- prepared_commit: none.
- active_work_unit: Rust native logical-helper rollout `FUTURE-PARITY-BACKLOG.5.2.3`; cursor implementation
  `.9.1.2-.9` is dependency-ordered but remains pending until explicitly reached after the logical program.
- next_action: retrieve the logical contract/KM/toolbox facts, run the Rust pre-change native/serialized/generated-
  plan/direct probes, then align exact eager arity, typed truthiness, booleans, receiver continuation, and lazy
  control sharing in `.5.2.3` only.
- current_proof: ADR `0044` is the exact future cursor authority. Bare targets normalize before typed validation;
  explicit cross-family edges remain legal; resolved ownership cannot mix; legacy global options fail rather than
  disappear; descriptors expose `cursor_policy`; generated-source v2 stores family only and derives policy.
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
- blockers: none. in_flight_uncommitted: none after this decision commit; no runtime behavior changed. Mutation
  campaigns remain parked; pre-existing ignored `rgx/subs/pgen` work remains untouched.
