# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.2` — executable neutral semantic-introspection contract is
  signoff-complete; its clean commit boundary is in flight.
- latest_commit: `056d413b` — `FUTURE-PARITY-BACKLOG.10.1 - design semantic introspection`
  (ahead: 261; push at threshold 300).
- active_work_unit: `FUTURE-PARITY-BACKLOG.10.2` — executable neutral semantic model/query contract, fixtures,
  evaluator, mutation gate, canonical registration, ADR correction, Knowledge Map, and mdBook are implemented and
  fully verified; only the per-leaf commit and brief clearing remain before `.10.3`.
- next_action: commit `.10.2` per `COMMIT.md`, clear and verify `git_message_brief.txt`, verify the clean boundary,
  then activate Perl reference leaf `.10.3` task-tree-first.
- current_semantic_introspection: `linkedspec-semantic-model-v1` / `linkedspec-semantic-query-v1` are executable as
  a neutral oracle: six fixture groups, six immutable policy/runtime snapshots, 20 digest-locked query responses,
  exact ids/order/shapes/source policies/pages/budgets/errors, and 50 rejected mutations. Neutral rollout is
  1 complete / 8 pending; native backend admission is 0 complete / 6 pending.
- staged_schema_correction: ADR `0050` amends v1 before backend implementation with explicit `staged_artifact`
  payload/parse-job/result records, fixed facts/status, consumes/produces direction, lowered/staged provenance, and
  a staged target shape. Parse jobs remain distinct from generated artifacts.
- current_mcp_boundary: planned MCP exposes only native capabilities/query calls over a caller-registered opaque
  handle. It cannot compile, read implicit paths, traverse backend objects, derive facts, invent explanations, or
  elevate source/cost ceilings. `.10.9` owns transport after six-runtime recurring admission.
- current_descriptor_boundary: current outward `spec/functions/dependency_regex_map/meta` is reusable derived
  compatibility state, not the semantic wire schema. TOOLBOX proof shows native Perl coderef/compiled-regex values
  and direct JSON failure; backend AST/IR/object identity is forbidden from semantic responses.
- implementation_split: `.10.2` neutral executable schema/checker; `.3` Perl; `.4` Rust; `.5` Dart; `.6` Julia;
  `.7` dual-ABI Lua; `.8` recurring six-runtime; `.9` MCP; `.10` public no-drift/closure.
- current_closed_semantics: cursor is 75 files / 8+0 / 60 mutations; root is 7+0/54; duplicate slots are 7+0/59;
  repeated action is 8+0/54. The first canonical design run caught/restored the repeated-action live marker.
- current_signoff: focused and canonical neutral checker pass 6 groups / 20 exact responses / 50 rejected
  mutations; primary CLI passes 66/66 twice; Phase 0 passes 1,031/1,031 in 612 seconds; mdBook, Knowledge Map at
  649/4,783, all four doctrines, adjacent no-drift contracts, and whitespace pass. No parser/compiler/runtime/
  descriptor/generated/CLI/trace/native semantic API/MCP behavior changes.
- latest_bootstrap_read: 2026-07-20 — README, memory architecture/resume pointer, roadmap, codebase, mdBook, active
  task, Knowledge Map, Toolbox, ADRs `0012`-`0016`, `0022`/`0023`, `0037`, `0042`, `0044`, `0047`-`0050`,
  descriptor/compiled/ActionIR/diagnostic/trace/generated/API authorities, and public precedents read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; inter-match gap/named-slot contract `.1-.7` has its cursor prerequisite
  but still requires explicit activation; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.10.2` is fully verified; only its clean commit and brief clearing remain
  before task-tree-first activation of `.10.3`.
