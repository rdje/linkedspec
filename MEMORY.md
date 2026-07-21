# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.3.6` — composed Perl semantic admission in this commit.
- latest_commit: this commit — `FUTURE-PARITY-BACKLOG.10.3.6 - admit Perl semantic introspection` (ahead: 272).
- active_work_unit: none; `.10.3.6` and parent `.10.3` are closed at the pre-commit signoff boundary.
- next_action: after verifying the clean admission commit, activate Rust semantic adapter `.10.4` task-tree-first.
- current_semantic_introspection: `linkedspec-semantic-model-v1` / `linkedspec-semantic-query-v1` are executable as
  a neutral oracle: six fixture groups, six immutable policy/runtime snapshots, 20 digest-locked query responses,
  exact ids/order/shapes/source policies/pages/budgets/errors, and 65 rejected mutations. Static/generated facts
  cross-check admitted authority; spec names derive from caller logical identity. Coordinated model/hash drift
  fails. Perl is the first exact 12-role consumer; neutral rollout is 2 complete / 7 pending and native backend
  admission is 1 complete / 5 pending.
- staged_schema_correction: ADR `0050` amends v1 before backend implementation with explicit `staged_artifact`
  payload/parse-job/result records, fixed facts/status, consumes/produces direction, lowered/staged provenance, and
  a staged target shape. Parse jobs remain distinct from generated artifacts.
- current_mcp_boundary: planned MCP exposes only native capabilities/query calls over a caller-registered opaque
  handle. It cannot compile, read implicit paths, traverse backend objects, derive facts, invent explanations, or
  elevate source/cost ceilings. `.10.9` owns transport after six-runtime recurring admission.
- current_descriptor_boundary: current outward `spec/functions/dependency_regex_map/meta` is reusable derived
  compatibility state, not the semantic wire schema. TOOLBOX proof shows native Perl coderef/compiled-regex values
  and direct JSON failure; backend AST/IR/object identity is forbidden from semantic responses.
- current_perl_authority_map: decoded source/map plus descriptor order/topology, typed ActionIR calls/bindings,
  staged sidecars, shared generated-v2 identity, and runtime failures project private v1 facts. Query consumes only
  cloned plain projection data. Typed invocation-local slot/final events now derive an immutable runtime projection
  after execution, separately from trace/diagnostics. Function/ActionIR spans are characters.
- perl_split: `.10.3.1` source/map/outcome; `.2.0` static oracle correction; `.2.1` static projection; `.3.0`
  generated-plan correction; `.3.1.0` spec-name correction; `.3.1.1` calls/shapes/staged/generated; `.4`
  capabilities/query/privacy/budgets; `.5` runtime/direct/loaded/generated observations; `.6` exact admission.
- current_perl_foundation: `semantic_index` compiles in-memory decoded/strict-UTF-8 source once without execution;
  retains opaque source/map/outcome plus clone-safe static/call/staged/generated records; never reads a path.
  Public capabilities/query match all 19 static responses, and caller-captured runtime derivation matches the
  twentieth without query-side compile/execute/path/trace.
- current_closed_semantics: cursor is 75 files / 8+0 / 60 mutations; root is 7+0/54; duplicate slots are 7+0/59;
  repeated action is 8+0/54 and its closed next owner was `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.10.3.6` consumer 18; all semantic 149; broader adjacent 471 plus supplemental cursor/trace
  127; semantic governance 6/20/65; KM 659/4,867; mdBook/four doctrines; primary 66x2; complete local CI through
  Phase 0 1,031/1,031 in 633 seconds; exit 0.
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
- blockers: none. in_flight_uncommitted: signoff-complete `.10.3.6` admission closeout awaits only its commit.
