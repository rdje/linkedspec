# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-07-09`
- Owner: repo-local workflow

## Goal

Own the deferred backlog surfaced after the language-reference closeout, with the first lane
driving new backend implementations toward full parity with the Perl reference backend and the
Rust backend. Backend rollout order is fixed by director directive and ADR `0021`: Dart first,
then Julia, then Lua.

## Non-Goals

- Do not implement backend code in the tracking slice `.0`.
- Do not weaken the universal `.spec` contract or create per-backend dialects.
- Do not treat Perl plugin machinery as part of the backend-neutral contract.
- Do not normalize documented behavior caveats until their own leaves are activated.

## Acceptance Criteria

- The seven backlog directions are represented as owned task-tree lanes.
- The backend lane schedules Dart, Julia, and Lua in that order, all with full parity goals.
- The central task-tree index points at the current frontier.
- ADR, roadmap, mdBook, Knowledge Map, and live docs no longer contradict the backend order or
  Lua adoption decision.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `FUTURE-PARITY-BACKLOG`
  Status: `active`
  Goal: Own the future parity backlog after the closed language-reference/terse-format trees.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `FUTURE-PARITY-BACKLOG.0`
  Status: `done`
  Goal: Create and register the future parity backlog tree.
  Acceptance: The task tree exists, the central index points at it, ADR `0021` records the
    backend rollout order, and roadmap/book/KM/live docs agree. No implementation code changes.
  Verification: **PASS 2026-07-09.** `git diff --check`, memory architecture, Knowledge Map,
    doctrine, task-tree metadata, mdBook build, and local CI pass; local CI includes phase0
    `1..1028`. No implementation code changed.
  Commit: `FUTURE-PARITY-BACKLOG.0 - create future parity backlog`

- ID: `FUTURE-PARITY-BACKLOG.1`
  Status: `active`
  Goal: Add future backend implementations in full parity with Perl5 and Rust.
  Children: `.1.1`, `.1.2`, `.1.3`
  Acceptance: Dart, Julia, and Lua each reach the same `.spec` language, helper/action AST,
    runtime semantics, staged parsing, diagnostics, and corpus parity contract as Perl5 and Rust.

- ID: `FUTURE-PARITY-BACKLOG.1.1`
  Status: `pending`
  Goal: Dart backend parity track - split/scaffold the Dart implementation path.
  Acceptance: Create or expand a dedicated Dart backend implementation plan before code, covering
    parser, helper/action AST, compiler/HandlerIR or interpreter strategy, runtime, regex engine,
    staged parser registry, corpus runner, docs, and parity gates against Perl5/Rust.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.2`
  Status: `pending`
  Goal: Julia backend parity track - split/scaffold after Dart reaches its scoped parity milestone.
  Acceptance: Create or expand a dedicated Julia backend implementation plan with the same full-parity
    obligations as Dart, reusing lessons from Dart without changing `.spec` semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.3`
  Status: `pending`
  Goal: Lua backend parity track - split/scaffold after Julia reaches its scoped parity milestone.
  Acceptance: Create or expand a dedicated Lua backend implementation plan with the same universal
    `.spec`, helper/action AST, runtime, staged parsing, diagnostics, and corpus parity obligations.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.2`
  Status: `pending`
  Goal: Generalize staged linked parsing beyond the current function-body prototype.
  Acceptance: Public `parse_job(...)` authoring, import/provider search roots, multiple payload
    parser families, recursive staged queues, cycle diagnostics, docs, and corpus fixtures are
    split before implementation and kept implementation-language neutral.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.3`
  Status: `pending`
  Goal: Broaden Rust generated-source proof from curated subset to full manifest parity.
  Acceptance: The generated-source path either covers the full 99-fixture manifest or records
    narrowly owned blockers; interpreter parity remains the primary gate until this leaf closes.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.4`
  Status: `pending`
  Goal: Decide and implement user-function extension topics beyond the MVP.
  Acceptance: Recursive functions, closures/lambdas/currying, namespaces, alternate spellings,
    optional zero-arg parens, brace-less bodies, and caller-mutating forms are each accepted,
    rejected, or split with explicit `.spec` contract and parity obligations before code.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.5`
  Status: `pending`
  Goal: Normalize or permanently document helper caveats.
  Acceptance: Own the array split/pipeline return-shape caveats (`SPEC-LANG-REFERENCE.5.3.1`) and
    odd-arity `hash(...)` behavior (`SPEC-LANG-REFERENCE.5.4.1`) as explicit keep-or-normalize
    decisions, with Perl/Rust locks and mdBook/KM updates.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.6`
  Status: `pending`
  Goal: Decide the fate of Perl legacy plugin machinery.
  Acceptance: Scope whether `PPlugin`, `PluginBridge`, `PluginRegistry`, and deprecated facade stubs
    are retired, relocated, or retained as Perl-reference-only transition machinery; update tests,
    docs, and public API guidance accordingly.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.7`
  Status: `pending`
  Goal: Promote richer legacy/shipped-spec Rust oracle candidates safely.
  Acceptance: Triage richer `pplugin`, `tkgui`, `sdce`, recursive `tablegrep`, single-line `simenv`,
    VHDL port-clause, `ds_vhistory` branch, and placeholder `verilog` candidates; promote only
    JSON-safe, portable fixtures or split root-cause leaves.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `FUTURE-PARITY-BACKLOG.1.1` | `pending` | Director chose backend rollout first and ordered Dart before Julia and Lua. |
| 2 | `FUTURE-PARITY-BACKLOG.1.2` | `pending` | Julia follows Dart after the Dart parity track reaches its scoped milestone. |
| 3 | `FUTURE-PARITY-BACKLOG.1.3` | `pending` | Lua is now adopted as a future backend by ADR `0021`, scheduled after Julia. |
| 4 | `FUTURE-PARITY-BACKLOG.2` | `pending` | Staged parsing generalization follows unless the director explicitly pivots. |
| 5 | `FUTURE-PARITY-BACKLOG.3` | `pending` | Rust generated-source breadth is independent follow-up after backend scheduling. |
| 6 | `FUTURE-PARITY-BACKLOG.4` | `pending` | Function extensions need explicit language decisions before code. |
| 7 | `FUTURE-PARITY-BACKLOG.5` | `pending` | Helper caveats are documented but not normalized. |
| 8 | `FUTURE-PARITY-BACKLOG.6` | `pending` | Plugin machinery fate is a Perl-reference facade decision. |
| 9 | `FUTURE-PARITY-BACKLOG.7` | `pending` | Richer oracle candidates need safe fixture triage. |

## Decisions

- `2026-07-09`: Director directive schedules future backend parity as Dart first, then Julia,
  then Lua, with the goal of full parity with Perl5 and Rust. ADR `0021` records the durable
  scope change and supersedes the earlier "Lua blocked pending decision" wording.
- `2026-07-09`: The tracking slice `.0` is documentation/task ownership only. No backend scaffold
  or runtime code is created until `.1.1` is selected and split.

## Open Questions

- None blocking `.1.1`. Dart implementation strategy must still choose interpretation versus generated
  code during the Dart scoping leaf, using the same `.spec` and corpus parity obligations.

## Blockers

- None for `.1.1`.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FUTURE-PARITY-BACKLOG.0` | `FUTURE-PARITY-BACKLOG.0 - create future parity backlog` | Tracking/decision/doc sync; no implementation code. |

## Changelog

- `2026-07-09`: Created the future parity backlog tree with seven owned lanes and Dart -> Julia -> Lua
  backend rollout order.
