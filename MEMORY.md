# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.3.1` — opaque Perl semantic source/map/compiled-or-failed
  foundation is clean at `0558c65a` without records, query, observation, rollout, or admission.
- latest_commit: `0558c65a` — `FUTURE-PARITY-BACKLOG.10.3.1 - add Perl semantic source foundation`
  (ahead: 264; push at threshold 300).
- active_work_unit: `FUTURE-PARITY-BACKLOG.10.3.2.0` — correct and independently gate neutral static rule facts
  before adapter projection. Default rules are now neutral `or`/`seek`, compiled no-edge rules are `none`, and the
  failed default-family bare edge is `action`; signoff is complete but uncommitted and no backend behavior changed.
- next_action: run final lightweight checks/cleanup, commit and clear the brief, verify clean, then activate
  corrected Perl static projection `.10.3.2.1` task-tree-first.
- current_semantic_introspection: `linkedspec-semantic-model-v1` / `linkedspec-semantic-query-v1` are executable as
  a neutral oracle: six fixture groups, six immutable policy/runtime snapshots, 20 digest-locked query responses,
  exact ids/order/shapes/source policies/pages/budgets/errors, and 53 rejected mutations. Static rules cross-check
  `linkedspec-rule-local-cursor-v1`, including three coordinated model-plus-hash mutations. Neutral rollout is
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
- current_perl_authority_map: strict decoded source plus canonical bytes owns text/spans; descriptor owns stable
  graph/function/staged facts; typed ActionIR owns nested call/binding spans; runtime context owns compile failure;
  generated v2 owns plan metadata only. Rule/edge/lifecycle source mapping and typed invocation-local execution
  observations are absent/new work. Raw UTF-8 bytes must be strictly decoded before character-oriented `Get`.
- perl_split: `.10.3.1` source/map/outcome; `.2.0` oracle correction; `.2.1` static graph/diagnostic; `.3` calls/shapes/staged/generated; `.4`
  capabilities/query/privacy/budgets; `.5` runtime/direct/loaded/generated observations; `.6` exact admission.
- current_perl_foundation: `LinkedSpec::semantic_index` takes only an in-memory scalar reference, required logical
  name/source ceiling, and optional top rule; normalizes decoded or strict-UTF-8 input, never reads a path, compiles
  once without execution, and retains opaque source-map plus compiled/failed authority. Public query is absent.
- current_closed_semantics: cursor is 75 files / 8+0 / 60 mutations; root is 7+0/54; duplicate slots are 7+0/59;
  repeated action is 8+0/54 and its closed next owner was `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.10.3.2.0` semantic 6/20/53, rule-local 36/18/8/60, foundation 5, capability 80/0/0,
  selector 59/27/0, primary 66x2, KM 652/4,805, Phase 0 1,031/1,031/612s, mdBook/doctrines, canonical exit 0.
- latest_bootstrap_read: 2026-07-21 — README, memory architecture/resume pointer, roadmap, codebase, mdBook, active
  task, Knowledge Map, Toolbox, ADRs `0012`-`0016`, `0022`/`0023`, `0037`, `0042`, `0044`, `0047`-`0050`,
  descriptor/compiled/ActionIR/diagnostic/trace/generated/API authorities, and public precedents read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30 minutes for canonical CI. Julia
  offline verification may stack a writable depot before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; inter-match gap/named-slot contract `.1-.7` has its cursor prerequisite
  but still requires explicit activation; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.10.3.2.0` neutral model/checker/contract and lockstep correction are
  fully verified but uncommitted; final cleanup, commit/brief clearing, then `.10.3.2.1` activation remain.
