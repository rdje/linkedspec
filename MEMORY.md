# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `INTER-MATCH-GAP-CAPTURE.0` — historical “super split” is ratified as automatic
  inter-match gap capture on repeated OR/default action edges; no runtime behavior changed.
- latest_commit: `7caaf9ca` — `FUTURE-PARITY-BACKLOG.9.1.3.3 - project Perl cursor descriptors`
  (ahead: 187; push at threshold 300).
- prepared_commit: `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture`.
- active_work_unit: commit the fully verified documentation/decision leaf; implementation `.1-.7` is dependency-
  gated and inactive. The active roadmap returns to cursor generated-source v2 `.9.1.3.4` after the clean boundary.
- next_action: commit `.0`, clear/verify `git_message_brief.txt`, confirm a clean tree, then resume
  `FUTURE-PARITY-BACKLOG.9.1.3.4` unless the director selects another clean-boundary action.
- current_proof: Baseline `cf25bd37` and current RuleIR/runtime resolve each action edge from its target rule/slot,
  not regex adjacency. A live `Top::OR @move_pos` → `Document[0..2]` probe returned three exact
  `[prefix-or-interstitial-gap, Document lifecycle result]` pairs and no automatic tail. ADR `0045` accepts future
  `@capture_gaps` plus spacing-insensitive `name=/regex/` → `Rule[name]` stable slots; neither is implemented.
  Marker-member audit: Perl anonymous scope is rule-level, Lua is preceding-slot-local, and Rust/Dart/Julia do
  not execute markers natively; `.1` owns reconciliation. Knowledge Map is regenerated at 583 facts / 4,106
  keys; mdBook, memory architecture, doctrines, and whitespace checks pass.
- latest_bootstrap_read: 2026-07-17 — full roadmap, codebase, mdBook, active task, Knowledge Map, Toolbox, ADR, and
  historical/live action-edge capture seams reviewed before the decision slice.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; cursor `.9.1.3.4-.9`; inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: fully verified decision/docs leaf awaits commit; no background job. Parked
  mutation work and ignored `rgx/subs/pgen` work are untouched.
