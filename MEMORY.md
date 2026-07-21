# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.4.0` — Rust semantic authority/split audit is done in this commit.
- latest_commit: `90e5e701` — `FUTURE-PARITY-BACKLOG.10.3.6 - admit Perl semantic introspection` (ahead: 272).
- active_work_unit: `FUTURE-PARITY-BACKLOG.10.4` — `.10.4.0` awaits commit; `.10.4.0.1` is next clean activation.
- next_action: complete `.10.4.0` commit workflow, then activate `.10.4.0.1` task-tree-first to repair/guard stale
  semantic TOOLBOX current state; `.10.4.0.2` then needs the director's label-contract decision.
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
- current_rust_authority_map: parsed/function-staged state, serde-safe `CompiledSpec`, ActionIR, diagnostic/loader/
  generated-v2 owners compose stable facts. Ordinary source metadata is line-only; exact spans need a new mapper.
  Direct/generated executors have parallel slot/result seams but only text trace, not typed semantic observation.
- rust_contract_blocker: neutral/admitted Perl privacy requires `Töp`; published grammar and current Rust parser are
  ASCII-label-only. `.10.4.0.2` must apply the director's Unicode-expansion or neutral-revision choice before
  `.10.4.1` construction. `.10.4.0.1` remains executable first and owns stale TOOLBOX 57/1+8 text plus checker guard.
- current_perl_reference: admitted `semantic_index` composes strict source/descriptor/ActionIR/staged/generated/
  diagnostic/typed observation owners, matches all 20 answers, never reads a path, and query never executes.
- current_closed_semantics: cursor is 75 files / 8+0 / 60 mutations; root is 7+0/54; duplicate slots are 7+0/59;
  repeated action is 8+0/54 and its closed next owner was `FUTURE-PARITY-BACKLOG.10.1`.
- current_signoff: `.10.4.0` neutral 6/20/65; Rust core 193/runtime 138/integration 197, exact corpus 105/full
  generated manifest, primary 66x2; KM 660/4,877; mdBook/four doctrines; canonical primary 66x2 and Phase 0
  1,031/1,031 in 617 seconds; exit 0. No Rust behavior/promotion; cleanup ends at 102 GiB free (27 GiB initial).
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
- blockers: `.10.4.0.2` needs the director's label-contract choice; `.10.4.0.1` can run first. in_flight_uncommitted:
  completed `.10.4.0` docs/task/KM audit awaits commit; no product code or background gate remains.
