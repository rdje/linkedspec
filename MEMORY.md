# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.4.2` — Rust semantic static projection is complete.
- latest_commit: this commit — `.10.4.2 - add Rust semantic static projection` (ahead: 277 after commit).
- active_work_unit: none — `.10.4.2` is signoff-complete and in its clean commit workflow.
- next_action: from the clean `.10.4.2` commit, activate `.10.4.3` task-tree-first and project exact Rust calls,
  bindings, staged payload/job/result, and generated provenance without exposing query or host state.
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
- current_rust_authority_map: `.10.4.1` privately retains copied strict source, exact byte/scalar mapping,
  parsed/validated/compiled-or-failed state, entry identity, and shared plan input. `.10.4.2` now composes parsed
  source plus typed compiled root/family/cursor/repetition/slot/edge/lifecycle authority into exact clone-safe
  private graph/privacy/failure/runtime-static v1 data. Public query and typed runtime observation remain absent.
- current_rule_label_contract: ADR `0051` pins nonempty Unicode 17 `XID_Continue` at every position with exact
  case-/normalization-sensitive identity and strict UTF-8. Generated Rust parsing/validation/routes are complete;
  Dart/Julia/Lua inherit alignment before their semantic admissions. No semantic rollout/admission promotion.
- current_perl_reference: admitted `semantic_index` composes strict source/descriptor/ActionIR/staged/generated/
  diagnostic/typed observation owners, matches all 20 answers, never reads a path, and query never executes.
- current_closed_semantics: cursor is 75 files / 8+0 / 60 mutations; root is 7+0/54; duplicate slots are 7+0/59;
  repeated action is 8+0/54 and its closed next owner was `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.10.4.2` focused static 5/foundation 6; complete Rust core 193/runtime 143/integration 197/exact
  105/full manifest/all packages/primary 66x2; semantic 6/20/65 at 2/9 + 1/6; KM 665/4,912; mdBook/memory/four
  doctrines; canonical restart primary 66x2 and Phase 0 1,031/1,031 in 609 seconds, exit 0. First run reproduced
  `.22` marker-anchor drift and was not credited; exact marker restored before the full restart.
- latest_bootstrap_read: 2026-07-21 — README, both roadmaps, memory/bootstrap/commit/task doctrines, complete
  codebase architecture, all 46 mdBook pages, relevant KM/Toolbox/ADRs, and exact Rust semantic authorities read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0; allow 30 minutes for canonical CI. Julia
  offline verification may stack a writable depot before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; inter-match gap/named-slot contract `.1-.7` has its cursor prerequisite
  but still requires explicit activation; inspector `.13.1`; authoring `.14`/`.15`;
  marker-anchor structural repair `.22`; startup mdBook drift repair `.23`; parenthesis-free conditions;
  lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.10.4.2` is verified and documented from clean `c92172b8`; only artifact
  cleanup and its mandated commit/brief verification remain. Startup book finding `.23` is queued, not active.
