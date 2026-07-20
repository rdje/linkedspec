# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.10.1` — semantic-introspection design is signoff-complete; its
  clean per-leaf commit is being prepared from base `f183e468`.
- latest_commit: `f183e468` — `FUTURE-PARITY-BACKLOG.9.1.10.7 - close repeated action result parity`
  (ahead: 260; push at threshold 300).
- active_work_unit: `FUTURE-PARITY-BACKLOG.10.1` — ADR/model/API/parity/MCP design is verified and cleaned; only
  the commit and brief clearing remain before any pivot.
- next_action: commit `.10.1`, clear/verify `git_message_brief.txt`, verify the clean boundary, then activate
  `FUTURE-PARITY-BACKLOG.10.2` task-tree-first for the executable neutral schema/checker.
- current_semantic_introspection: ADR `0049` fixes planned `linkedspec-semantic-model-v1` and
  `linkedspec-semantic-query-v1`: one immutable native index, snapshot-local ids/order, exact records/relations/
  facts/value and target shapes, request/response/source/span/diagnostic envelopes, deterministic page/budget
  accounting, source ceilings/redactions, schema evolution, portable evidence, failed-compile and optional
  caller-captured runtime snapshots, idiomatic host APIs, and unchanged primary CLI.
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
- current_signoff: KM 647/4,769, mdBook, memory, task metadata, four doctrines, adjacent contracts, whitespace,
  and cleanup pass. Canonical exits 0 with primary 66x2 and Phase 0 1,031/1,031 in 657 seconds. No current parser,
  compiler, runtime, descriptor, generated, CLI, trace, fixture, or MCP behavior changes.
- latest_bootstrap_read: 2026-07-20 — README, memory architecture/resume pointer, roadmap, codebase, mdBook, active
  task, Knowledge Map, Toolbox, ADRs `0012`-`0016`, `0022`/`0023`, `0037`, `0042`, `0044`, `0047`-`0049`,
  descriptor/compiled/ActionIR/diagnostic/trace/generated/API authorities, and public precedents read.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: generated parser+stimuli `.8.1`; inter-match gap/named-slot contract `.1-.7` has its cursor prerequisite
  but still requires explicit activation; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: `.10.1` is fully verified and cleaned; only the clean commit and brief
  clearing remain before task-tree-first activation of `.10.2`.
