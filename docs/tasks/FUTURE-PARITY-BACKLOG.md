# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-07-10` (delegated Julia `.7.3.3` no-drift done; next PNT leaf is `.1.5.1`).
- Owner: repo-local workflow

## Goal

Own the deferred backlog surfaced after the language-reference closeout, with the first lane
driving new backend implementations toward full parity with the Perl reference backend and the
Rust backend. Backend rollout order is fixed by director directive and ADR `0021`: Dart first,
then Julia, then Lua. The backlog also parks later architecture arcs that need design ownership
before implementation.

## Non-Goals

- Do not implement backend code in the tracking slice `.0`.
- Do not weaken the universal `.spec` contract or create per-backend dialects.
- Do not treat Perl plugin machinery as part of the backend-neutral contract.
- Do not normalize documented behavior caveats until their own leaves are activated.

## Acceptance Criteria

- The nine backlog directions are represented as owned task-tree lanes.
- The backend lane schedules Dart, Julia, and Lua in that order, all with full parity goals.
- Every backend is primarily a native in-memory library for its host language. Variant CLIs are secondary thin
  adapters and may not become the only complete product surface or own CLI-only semantics.
- Each backend implementation track owns a distinct LinkedSpec executable name for that variant; every such
  executable exposes the identical command structure, options/meanings, positional arguments, outputs/errors, and
  exit semantics. No variant may substitute a backend-specific product interface.
- The spec-derived parser/stimuli roundtrip idea is recorded as future design work, with `.spec` kept as the
  sole semantic source of truth for both parser construction and generated stimuli.
- The director's AND/OR edge-default correction is recorded as future design work: AND rules should default bare
  entries to blind-call sequence semantics, while OR rules should default bare entries to action-edge regex
  dispatch semantics.
- The central task-tree index points at the current frontier.
- ADR, roadmap, mdBook, Knowledge Map, and live docs no longer contradict the backend order or
  Lua adoption decision.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `FUTURE-PARITY-BACKLOG`
  Status: `active`
  Goal: Own the future parity backlog after the closed language-reference/terse-format trees.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`

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
  Children: `.1.1`, `.1.2`, `.1.3`, `.1.4`, `.1.5`, `.1.6`
  Acceptance: Dart, Julia, and Lua each reach the same `.spec` language, helper/action AST,
    runtime semantics, staged parsing, diagnostics, and corpus parity contract as Perl5 and Rust; each exposes an
    idiomatic native in-memory library API, with its primary CLI exactly conforming to ADR `0023` and its corpus
    runner remaining a separate secondary adapter.

- ID: `FUTURE-PARITY-BACKLOG.1.1`
  Status: `done`
  Goal: Dart backend parity track - split/scaffold the Dart implementation path.
  Acceptance: Create or expand a dedicated Dart backend implementation plan before code, covering
    parser, helper/action AST, compiler/HandlerIR or interpreter strategy, runtime, regex engine,
    staged parser registry, corpus runner, docs, and parity gates against Perl5/Rust.
  Verification: **PASS 2026-07-09.** Created `docs/tasks/DART-BACKEND-PARITY.md` as the dedicated
    Dart backend plan. The plan covers parser/frontend, typed helper/action AST, interpreter-first
    compiled-state strategy, runtime, regex engine, staged parser registry, corpus runner, docs,
    trace/diagnostics, parity gates, and generated Dart source as a later proof lane. No backend code
    changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan`

- ID: `FUTURE-PARITY-BACKLOG.1.2`
  Status: `done`
  Goal: Julia backend parity track - split/scaffold now that Dart has reached its scoped parity milestone.
  Acceptance: Create or expand a dedicated Julia backend implementation plan with the same full-parity
    obligations as Dart, reusing lessons from Dart without changing `.spec` semantics.
  Verification: **PASS 2026-07-09.** Created `docs/tasks/JULIA-BACKEND-PARITY.md` as the dedicated Julia backend
    plan. The plan schedules interpreter-first parity, Julia-specific CLI ownership, typed `.spec` frontend,
    typed helper/action AST, compiled state, runtime interpreter, regex/match state, staged parser registry,
    user-function runtime, diagnostics/trace, corpus runner, local verification, mdBook alignment, and generated
    Julia source as a later proof decision. No Julia package or implementation code changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan`

- ID: `FUTURE-PARITY-BACKLOG.1.3`
  Status: `pending`
  Goal: Lua backend parity track - split/scaffold after Julia reaches its scoped parity milestone.
  Acceptance: Create or expand a dedicated Lua backend implementation plan with the same universal
    `.spec`, helper/action AST, runtime, staged parsing, diagnostics, and corpus parity obligations; define an
    idiomatic native Lua module that parses/compiles/executes in memory, direct library-level embedding tests,
    and a distinct Lua-specific executable token that implements ADR `0023`'s exact primary CLI interface.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.4`
  Status: `done`
  Goal: Ratify native in-memory embedding as the primary multi-backend product contract.
  Acceptance: Audit the current Perl, Rust, Dart, and Julia public library surfaces; record a durable decision that
    each backend must compile/parse/execute in the host process without requiring a CLI, subprocess, or serialized
    file handoff; require Lua and future backend plans to expose equivalent native library APIs; define CLIs and
    corpus runners as thin adapters with no exclusive semantics; align roadmap, mdBook public API/handoff,
    Knowledge Map, live docs, and backend task acceptance; make no parser/runtime behavior change.
  Verification: **PASS 2026-07-10.** Audited the native Perl `Get`/`get_parser`, Rust core parser/compiler plus
    runtime `Engine`, Dart package parse/compile/runtime exports and CLI adapter, and Julia module
    parse/compile/runtime exports and CLI adapter. ADR `0022`, roadmaps, mdBook public API/handoff, backend task
    acceptance, Knowledge Map, live docs, and Lua/future acceptance now agree. Direct Perl coderef construction,
    50 focused Dart runtime tests, direct Julia parse/compile/execute, mdBook build, Knowledge Map, memory,
    task-tree, doctrine, and whitespace gates pass. No parser/compiler/runtime source changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.4 - ratify native in-memory backend contract`

- ID: `FUTURE-PARITY-BACKLOG.1.5`
  Status: `active`
  Goal: Make every implemented backend's primary CLI conform to one byte-testable user interface.
  Children: `.1.5.0`, `.1.5.1`, `.1.5.2`, `.1.5.3`, `.1.5.4`

- ID: `FUTURE-PARITY-BACKLOG.1.5.0`
  Status: `done`
  Goal: Ratify and route the exact cross-backend CLI contract before implementation.
  Acceptance: ADR `0023` defines the canonical option/argument/output/error/exit contract, current gaps are
    source-backed, and every implemented backend repair plus the language-neutral conformance gate has an owner.
  Verification: `PASS` - delegated `JULIA-BACKEND-PARITY.7.3.1` records ADR `0023`, the Perl reference command
    schema, zero positional arguments/subcommands, normalized output/error/exit rules, current gaps, and the
    `.1.5.1` through `.1.5.4` repair sequence. No implementation behavior changed.
  Commit: `JULIA-BACKEND-PARITY.7.3.1 - ratify exact backend interface parity`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1`
  Status: `pending`
  Goal: Lock the language-neutral CLI fixtures and normalize the Perl reference command to ADR `0023`.
  Acceptance: Checked-in fixture cases define help, success, usage, compile/input/runtime failure, trace routing,
    stdout/stderr, and exit behavior; Perl passes exactly and rejects undocumented primary-CLI surface.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2`
  Status: `pending`
  Goal: Add the Rust primary CLI against the shared fixture contract.
  Acceptance: A Rust binary delegates to native core/runtime APIs and passes the same CLI fixtures as Perl.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3`
  Status: `pending`
  Goal: Replace Dart's primary corpus command with the shared parser CLI contract.
  Acceptance: Dart's primary executable passes the same fixtures; corpus execution remains a separate developer
    runner and owns no primary-CLI-only semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.5.4`
  Status: `pending`
  Goal: Close current Perl/Rust/Dart/Julia CLI parity and make the conformance matrix a recurring gate.
  Acceptance: One driver runs identical fixtures against all four implemented primary commands and proves
    normalized stdout, stderr, and exit-code identity after substituting only the executable token.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6`
  Status: `pending`
  Goal: Prove complete user-observable feature/behavior parity beyond the 99-fixture interpreter corpus.
  Acceptance: Build a machine-readable capability matrix from the mdBook, exported public APIs, Phase 0, and the
    language-neutral corpus; classify Perl/Rust/Dart/Julia gaps before implementation; split every gap into an
    owned parity leaf; do not call a backend full-parity while any user-visible capability differs.
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
  Goal: Close generated-source capability parity beyond the current interpreter-first correctness gates.
  Acceptance: Split Rust full-manifest breadth and separate Dart/Julia source-emitter proofs before code. Each
    non-Rust emitter lane must own a minimal emitter scaffold plus compile/run harness, typed generated-family plan,
    direct structural-family execution, and curated manifest-backed corpus subset. Rust exports source emission as
    a public runtime-crate capability, so ADR `0023` makes equivalent capability mandatory before Dart/Julia/Lua can
    claim complete user-visible parity; interpreter parity remains the primary correctness gate.
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

- ID: `FUTURE-PARITY-BACKLOG.8`
  Status: `active`
  Goal: Explore spec-derived parser/stimuli closed-loop validation.
  Children: `.8.0`, `.8.1`
  Acceptance: The director's `foo.spec` idea is durable, design work is split before implementation, and any
    later prototype derives both the parser and the stimuli generator solely from the normalized `.spec` contract.
    No second hidden grammar or backend-specific fixture generator may become a competing source of truth.

- ID: `FUTURE-PARITY-BACKLOG.8.0`
  Status: `done`
  Goal: Capture the director's single-source `foo.spec` parser/stimuli roundtrip idea.
  Acceptance: The task tree, index, roadmap/live docs, mdBook, resume pointer, and Knowledge Map record the future
    arc without changing active parser/runtime behavior or pivoting away from the Dart frontier.
  Verification: **PASS 2026-07-09.** `git diff --check`, memory architecture, Knowledge Map generation/check,
    task-tree metadata, doctrine, and mdBook build pass. No implementation code changed.
  Commit: `FUTURE-PARITY-BACKLOG.8.0 - capture spec-derived roundtrip idea`

- ID: `FUTURE-PARITY-BACKLOG.8.1`
  Status: `pending`
  Goal: Design the `.spec`-derived parser/stimuli roundtrip contract before code.
  Acceptance: Define the normalized grammar/semantic metadata needed to construct a parser and a stimuli generator
    from one `.spec`; specify bounded generation, termination/progress guards, expected-output oracles,
    shrink/minimize behavior, negative-case handling, staged parser composition, and cross-backend parity checks;
    explicitly reject any generator rule language that duplicates or drifts from `.spec`.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.9`
  Status: `active`
  Goal: Revisit AND/OR edge defaults and top-rule ceremony as future `.spec` language design.
  Children: `.9.0`, `.9.1`
  Acceptance: The director's correction to edge defaults is durable, design work is split before implementation,
    and any later implementation keeps Perl/Rust/Dart semantics aligned instead of silently changing one backend.

- ID: `FUTURE-PARITY-BACKLOG.9.0`
  Status: `done`
  Goal: Capture the director's corrected AND/OR edge-default model.
  Acceptance: The task tree, index, roadmap/live docs, mdBook, resume pointer, and Knowledge Map record the future
    arc without changing parser/runtime behavior or pivoting away from the Dart frontier.
  Verification: **PASS 2026-07-09.** `git diff --check`, memory architecture, Knowledge Map generation/check,
    task-tree metadata, doctrine, and mdBook build pass. No implementation code changed.
  Commit: `FUTURE-PARITY-BACKLOG.9.0 - capture AND OR edge default correction`

- ID: `FUTURE-PARITY-BACKLOG.9.1`
  Status: `pending`
  Goal: Design the corrected AND/OR edge-default contract before code.
  Acceptance: Specify grammar and runtime semantics for mode-sensitive bare edge lines. In AND rules (`:&`, `::&`,
    `:AND`, `::AND`, and bounded/repeated variants), a bare `entry { ... }` line should mean an explicit
    blind-call `=> entry { ... }`; in OR/default rules, a bare `entry { ... }` line should mean an explicit
    action-edge `-> entry { ... }`. Decide whether explicit `->` action-edges remain legal in AND rules, whether
    explicit `=>` blind-calls remain legal in OR rules, how this composes with `entry[k]`, fluent `.push` /
    `.return(...)` continuations, grouped/shared blocks, and diagnostics for ambiguous cases. Keep the boundary
    clear: blind-call means the parent does not preselect by the child rule's regex; the called child rule still
    owns its own parser/matching semantics unless this design explicitly creates a separate bypass. Treat
    first-rule-as-top instead of `::` and optional OR pipe sugar as separate decisions under this design leaf.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `JULIA-BACKEND-PARITY.7.3.3` | `done` | Julia-local status is reconciled; its root remains active/delegated rather than falsely complete. |
| 2 | `FUTURE-PARITY-BACKLOG.1.5.1` | `pending` | Next PNT: lock neutral CLI fixtures and normalize the Perl reference. |
| 3 | `FUTURE-PARITY-BACKLOG.1.5.2` | `pending` | Add the missing Rust primary CLI against the shared fixtures. |
| 4 | `FUTURE-PARITY-BACKLOG.1.5.3` | `pending` | Replace Dart's corpus-oriented primary command with the shared parser interface. |
| 5 | `FUTURE-PARITY-BACKLOG.1.5.4` | `pending` | Make four-backend CLI identity a recurring gate. |
| 6 | `FUTURE-PARITY-BACKLOG.1.6` | `pending` | Census every documented/exported user capability and split all residual parity gaps. |
| 7 | `FUTURE-PARITY-BACKLOG.3` | `pending` | Public generated-source capability must converge after the capability census/split. |
| 8 | `FUTURE-PARITY-BACKLOG.1.3` | `pending` | Lua inherits the complete capability and identical CLI gates after current backends converge. |
| 9 | `FUTURE-PARITY-BACKLOG.2` | `pending` | Staged parsing generalization follows unless the director explicitly pivots. |
| 10 | `FUTURE-PARITY-BACKLOG.4` | `pending` | Function extensions need explicit language decisions before code. |
| 11 | `FUTURE-PARITY-BACKLOG.5` | `pending` | Helper caveats are documented but not normalized. |
| 12 | `FUTURE-PARITY-BACKLOG.6` | `pending` | Plugin machinery fate is a Perl-reference facade decision. |
| 13 | `FUTURE-PARITY-BACKLOG.7` | `pending` | Richer oracle candidates need safe fixture triage. |
| 14 | `FUTURE-PARITY-BACKLOG.8.1` | `pending` | Director's single-source parser/stimuli roundtrip arc is parked for later design. |
| 15 | `FUTURE-PARITY-BACKLOG.9.1` | `pending` | Director's corrected AND/OR edge-default arc is parked for later design. |

## Decisions

- `2026-07-09`: Director directive schedules future backend parity as Dart first, then Julia,
  then Lua, with the goal of full parity with Perl5 and Rust. ADR `0021` records the durable
  scope change and supersedes the earlier "Lua blocked pending decision" wording.
- `2026-07-09`: The tracking slice `.0` is documentation/task ownership only. No backend scaffold
  or runtime code is created until `.1.1` is selected and split.
- `2026-07-09`: `.1.1` selects an interpreter-first Dart parity strategy and delegates executable Dart
  work to `docs/tasks/DART-BACKEND-PARITY.md`. Generated Dart source is a later proof lane after
  interpreter/corpus parity, not the primary gate.
- `2026-07-09`: Director directive: each LinkedSpec backend variant should have a distinct CLI. Dart records
  this as `DART-BACKEND-PARITY.7.3` / `.7.4`; Julia and Lua planning leaves must include equivalent
  variant-specific CLI ownership when activated. The 2026-07-10 clarification preserves distinct executable names
  but requires their complete user-facing interfaces to be identical.
- `2026-07-09`: `DART-BACKEND-PARITY.7.5` closes the scoped interpreter-first Dart milestone. Future backend
  rollout returned to this backlog tree; `FUTURE-PARITY-BACKLOG.1.2` then split/scaffolded Julia planning.
  No Julia or Lua code changes were made in the Dart closeout.
- `2026-07-09`: `.1.2` creates `docs/tasks/JULIA-BACKEND-PARITY.md` and selects an interpreter-first Julia
  parity strategy. Generated Julia source is a later proof decision, not the primary gate. Executable Julia work
  starts with `JULIA-BACKEND-PARITY.1.1` toolchain/package-layout preflight.
- `2026-07-09`: Director brainstorm captured: a future closed-loop validation arc should explore deriving both
  a parser for `foo` and a stimuli generator for that parser solely from `foo.spec`, making `.spec` the sole source
  of truth. This is parked under `.8.1` and is not the current Julia rollout pivot.
- `2026-07-09`: Director correction captured: future `.spec` design should swap the earlier optional-marker idea.
  AND rules should default bare entries to blind-call sequence semantics, while OR/default rules should default
  bare entries to action-edge regex dispatch semantics. This is parked under `.9.1` and is not the current Julia
  rollout pivot.
- `2026-07-10`: Director clarification: the reason for multiple LinkedSpec backends is native in-memory use from
  Rust, Dart, Julia, Lua, and later host languages. ADR `0022` makes host-process parse/compile/execute APIs the
  primary backend completion gate. Distinct CLIs remain useful thin adapters and may not own exclusive semantics.
- `2026-07-10`: `JULIA-BACKEND-PARITY.7.2` defers generated Julia source to this tree's `.3` generated-source
  breadth lane. `.3` now explicitly owns separate Rust breadth and Dart/Julia emitter splits with scaffold/harness,
  family-plan, direct structural-family, and curated corpus proof prerequisites. Current Julia conformance remains
  the native in-memory interpreter's 99/99 gate.
- `2026-07-10`: Director clarification: distinct backend executable names must expose the exact same user-facing
  CLI API, including command structure, option names/meanings, positional arguments, outputs/errors, and exit
  semantics; every variant must have the same user-observable feature set and behavior. Julia `.7.3.0` proves the
  current surfaces drift and splits contract/routing, Julia repair, and honest no-drift work.
- `2026-07-10`: ADR `0023` ratifies exact user-observable capability/behavior and primary-CLI identity. Delegated
  `.1.5.0` closes through `JULIA-BACKEND-PARITY.7.3.1`; `.1.5.1`–`.1.5.4` own the current-backend CLI repairs,
  `.1.6` owns the full public capability census, and `.3` is mandatory for complete parity because Rust exports
  source emission publicly. Julia `.7.3.2` remains first to preserve the current task-tree sequence.
- `2026-07-10`: Julia `.7.3.2.0` splits primary CLI alignment after source audit found five mechanisms: compile/
  parser/staged trace coverage, exact arguments and source/input resolution, execution/canonical JSON, normalized
  errors/trace routing, and direct-command conformance. `.7.3.2.1` is active; no implementation changed.
- `2026-07-10`: Delegated Julia `.7.3.2.1` closes compile/parser/function-shell/staged trace propagation through
  the existing emitter and sinks. The 868-assertion package suite, CLI smokes, and 99/99 corpus gate pass;
  `.7.3.2.2` is active for exact arguments and source/input loading.
- `2026-07-10`: Delegated Julia `.7.3.2.2` replaces the rollout primary commands with exact ADR `0023` options,
  positional/subcommand rejection, deterministic named resolution, and exact source/input loading. `.7.3.2.3`
  now executes rule/function source through the native pipeline and emits recursively key-sorted direct JSON;
  `.7.3.2.4` locks stable phase-ordered failures plus the trace sink/reset/emoji matrix. `.7.3.2.5` now locks nine
  direct process families and `runtime-corpus-primary-cli`; 1,017 assertions and 99/99 pass. `.7.3.3` then closes
  the outer audit without declaring complete parity. Julia remains active/delegated to `.1.5`, `.1.6`, and `.3`.
- `2026-07-10`: Delegated Julia `.7.3.3` corrects a stale mdBook limitation sentence and proves current surfaces
  agree on the exact local milestone and remaining global obligations. PNT now advances to `.1.5.1`; Lua remains
  gated behind current-backend CLI/capability/generated-source convergence.

## Open Questions

- None blocking the global CLI frontier. Lua `.1.3` is intentionally gated until current implemented backends close
  ADR `0023` CLI/capability convergence, including any `.1.6`-split gaps and public generated source under `.3`.

## Blockers

- None. Delegated Julia `.7.3.3` is done; `.1.5.1` is the next PNT leaf. Global CLI/capability convergence precedes
  Lua `.1.3`.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.1.1` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.1.2` | `git diff --check`; stale handoff/frontier `rg` scan; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_task_tree_metadata.sh`; `bash scripts/check_doctrines.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning only; created `JULIA-BACKEND-PARITY` and no Julia package or implementation code. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.8.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning capture only; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.9.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning capture only; no implementation code changed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.4` | Perl direct `LinkedSpec::Get` coderef probe; focused Dart runtime tests (50); direct Julia parse/compile/execute probe; static Rust core/runtime API and Dart/Julia CLI-adapter audit; `mdbook build docs/linkedspec-book`; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check` | PASS. ADR `0022` makes native in-memory embedding primary and CLIs secondary; current/future backend acceptance and public docs agree; no parser/compiler/runtime source changed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.0` | Delegated Julia `.7.3.1`: ADR `0023`; Perl CLI/trace contract and Rust public source-emitter audit; global task routing; mdBook build; Knowledge Map generation/check; memory/task/doctrine/whitespace gates. | PASS. Exact primary CLI and public-capability parity are durable; `.1.5.1`–`.1.5.4`, `.1.6`, and `.3` own convergence; no implementation behavior changed. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.7.3.3` | Delegated current-surface audit; stale mdBook provenance/correction; exact owner routing; prior `431f0472` Julia proof; docs/KM/governance/whitespace and mdBook. | PASS. Julia's local audit is done while its root remains active/delegated; `.1.5.1` is next. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FUTURE-PARITY-BACKLOG.0` | `FUTURE-PARITY-BACKLOG.0 - create future parity backlog` | Tracking/decision/doc sync; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.1` | `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan` | Creates `DART-BACKEND-PARITY`; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.2` | `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan` | Creates `JULIA-BACKEND-PARITY`; no implementation code. |
| `FUTURE-PARITY-BACKLOG.8.0` | `FUTURE-PARITY-BACKLOG.8.0 - capture spec-derived roundtrip idea` | Captures future `foo.spec` parser/stimuli closed-loop validation arc; no implementation code. |
| `FUTURE-PARITY-BACKLOG.9.0` | `FUTURE-PARITY-BACKLOG.9.0 - capture AND OR edge default correction` | Captures future AND/OR mode-sensitive edge-default design arc; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.4` | `FUTURE-PARITY-BACKLOG.1.4 - ratify native in-memory backend contract` | ADR `0022` and public/backend planning surfaces make native host-process embedding primary; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.5.0` | `JULIA-BACKEND-PARITY.7.3.1 - ratify exact backend interface parity` | Delegated ADR `0023` contract/routing; global implementation follows after Julia's active repair leaf. |
| `JULIA-BACKEND-PARITY.7.3.3` | `JULIA-BACKEND-PARITY.7.3.3 - reconcile Julia scoped parity status` | Delegated local audit done; Julia root remains active through global `.1.5`, `.1.6`, and `.3`. |

## Changelog

- `2026-07-10`: Delegated Julia `.7.3.3` closes the local no-drift audit at
  `runtime-corpus-primary-cli` while preserving the active/delegated full-parity boundary. `.1.5.1` becomes the
  next PNT leaf; `.1.6`, `.3`, and then Lua remain ordered behind it.
- `2026-07-10`: Delegated `.1.5.0` closes through Julia `.7.3.1`. ADR `0023` defines one exact parser-oriented
  primary CLI and complete public capability/behavior parity; `.1.5.1`–`.1.5.4`, `.1.6`, and `.3` own convergence.
- `2026-07-09`: Created the future parity backlog tree with seven initial owned lanes and Dart -> Julia -> Lua
  backend rollout order.
- `2026-07-09`: Scoped the Dart backend lane into `docs/tasks/DART-BACKEND-PARITY.md` and selected
  interpreter-first parity before generated Dart source.
- `2026-07-09`: Scoped the Julia backend lane into `docs/tasks/JULIA-BACKEND-PARITY.md`, selected
  interpreter-first parity, required Julia-specific CLI ownership, and delegated the next active leaf to
  `JULIA-BACKEND-PARITY.1.1`.
- `2026-07-09`: Captured the director's single-source `foo.spec` parser/stimuli generator roundtrip idea as a
  low-priority future design lane.
- `2026-07-09`: Captured the director's corrected AND/OR edge-default model as a future design lane: AND defaults
  to blind-call sequence entries, OR/default rules default to action-edge regex-dispatch entries, and top-rule
  marker reduction plus OR pipe sugar are parked as related design questions.
- `2026-07-09`: Dart's scoped interpreter-first milestone closed in `DART-BACKEND-PARITY.7.5`; Julia planning
  completed in `.1.2`, with active executable Julia work delegated to `JULIA-BACKEND-PARITY.1.1`. Lua remains
  scheduled after Julia.
- `2026-07-10`: Ratified native in-memory host-language embedding as the primary multi-backend product contract
  in ADR `0022`. Perl/Rust/Dart/Julia library surfaces satisfy the structural requirement; CLIs remain thin
  adapters, and Lua/future plans must expose native modules plus direct library tests.
