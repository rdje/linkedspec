# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-07-10` (`.10.0` captures semantic introspection/MCP as a parked direction; `.1.5.1.6` remains active).
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

- The ten backlog directions are represented as owned task-tree lanes.
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
- Deep semantic introspection is recorded as a first-class, backend-neutral in-memory API direction with a thin
  MCP projection; backend IR must not leak into or fragment the public semantic model.
- The central task-tree index points at the current frontier.
- ADR, roadmap, mdBook, Knowledge Map, and live docs no longer contradict the backend order or
  Lua adoption decision.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `FUTURE-PARITY-BACKLOG`
  Status: `active`
  Goal: Own the future parity backlog after the closed language-reference/terse-format trees.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`, `.10`

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
  Status: `active`
  Goal: Lock the language-neutral CLI fixtures and normalize the Perl reference command to ADR `0023`.
  Children: `.1.5.1.0`, `.1.5.1.1`, `.1.5.1.2`, `.1.5.1.3`, `.1.5.1.4`, `.1.5.1.5`, `.1.5.1.6`
  Acceptance: Checked-in fixture cases define help, success, usage, compile/input/runtime failure, trace routing,
    stdout/stderr, and exit behavior; Perl passes exactly and rejects undocumented primary-CLI surface.
  Verification: `pending` - six completed leaves establish the strict runner/help, arguments, success, failures,
    and canonical trace protocol at 53/53. Trace signoff exposed a pre-existing Unicode process-boundary mismatch:
    raw UTF-8 argv `xé` returned through `input_text()` serializes as the mojibake bytes for `xÃ©`. `.1.5.1.6`
    must define and lock the shared UTF-8 boundary before this parent or the Perl reference can close.
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.0`
  Status: `done`
  Goal: Audit and split the neutral fixture plus Perl-normalization work by observable mechanism before code.
  Acceptance: Inspect ADR `0023`, the Perl primary source/tests, relevant Knowledge Map/toolbox facts, and direct
    process behavior; record every observed contract gap; split a recoverable sequence before implementation.
  Verification: `PASS` - `bin/linkedspec`, `t/trace_cli.t`, ADR `0023`, the trace owner, and direct process probes
    show that the current trace smoke passes but the full contract does not. Perl accepts an ignored positional,
    uppercase long options, unique abbreviations, and undocumented `--no-trace-*` forms. `POSIXLY_CORRECT` changes
    abbreviation and argument-order behavior because `Getopt::Long` policy is implicit. Unknown options prepend an
    uncontrolled library warning. Compile and invocation failure correctly exit `1` but emit timestamped/source-
    located `DUMP_NONE` records to stdout before the normalized stderr. The work is split into harness/help,
    arguments, success/IO, operational failures, and trace/gate leaves; no implementation source changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.0 - split neutral CLI fixture work`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.1`
  Status: `done`
  Goal: Establish the language-neutral fixture schema/runner and exact help baseline.
  Acceptance: A checked-in manifest and backend-independent process runner validate schema, command arrays,
    executable-display substitution, isolated fixture workspaces, exact stdout/stderr bytes, and exit status; the
    first help fixture passes on Perl without weakening later four-backend reuse.
  Verification: `PASS` - `cli_conformance/manifest.json` and `tools/run_cli_conformance.pl` define a strict schema,
    arbitrary launch command after `--`, explicit placeholders, per-case canonicalized temp workspaces, exact raw
    stdout/stderr/exit and generated-file comparisons, safe relative paths, focused selection, and useful first-
    mismatch diagnostics. The exact help fixture passes Perl and uses backend-neutral wording plus the complete
    trace alias/help surface. Four runner subtests (13 assertions), the existing two trace CLI subtests, direct
    conformance execution, syntax, docs, Knowledge Map, governance, mdBook, and whitespace checks pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.1 - add neutral CLI fixture runner`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.2`
  Status: `done`
  Goal: Normalize and fixture-lock Perl's exact argument and usage-error surface.
  Acceptance: Only ADR `0023` options/spellings are accepted; case aliases, abbreviations, negated aliases,
    subcommands, positionals, missing values, invalid modes/levels, and selector conflicts produce deterministic
    fixture-owned stderr and exit `2`, independent of environment defaults.
  Verification: `PASS` - Perl now uses an explicit case-sensitive, non-abbreviating parser equivalent to the
    shared Julia model, with no `Getopt::Long`/environment policy. Twenty-two neutral cases pass with
    `POSIXLY_CORRECT` both unset and set: long/short help, selector requirements/conflicts, status/corpus/trailing
    positionals, `--`, unknown/case/abbreviation/negated aliases, missing values, flag values, invalid parse/trace
    modes/levels, and ordered multiple errors. Every usage failure has empty stdout, exact templated stderr, and
    exit `2`; four runner subtests and two trace CLI subtests remain green.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.2 - normalize Perl CLI arguments`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.3`
  Status: `done`
  Goal: Lock Perl source/input/parser controls and canonical successful output through neutral fixtures.
  Acceptance: Named/file/inline source, literal/file input, top-rule, seek/consume, nested canonical JSON, and one
    trailing newline are exact; source/input bytes and documented resolution have no backend-local side channel.
  Verification: `PASS` - seven backend-neutral success cases lock repository named resolution from an isolated
    workspace, exact file/inline source and literal/file input, explicit top rule, distinct seek/consume controls,
    recursively sorted nested JSON, preserved input-file newline bytes, empty stderr, exit `0`, and exactly one
    JSON-record newline. `LinkedSpec::Get`, `get_parser`, generated-source, and trace probes confirmed the portable
    action-edge return shape and ADR `0020`'s already-owned direct-default-rule `E` caveat before fixture authoring.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.3 - lock Perl CLI success behavior`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.4`
  Status: `done`
  Goal: Normalize and fixture-lock Perl compilation, input-load, and invocation failures.
  Acceptance: Phase order is compilation then input then invocation; each failure has backend-neutral stable stderr,
    empty stdout unless trace is explicitly selected, and exit `1`; paths and host exception text do not make the
    shared contract platform- or backend-specific.
  Verification: `PASS` - four exact neutral cases lock invalid/missing source compilation, compilation-before-input
    precedence, missing input, and missing-top-rule invocation. Untraced failures have empty stdout, one stable
    backend-neutral heading on stderr, exit `1`, and no files. The adapter suppresses backend trace environment
    state unless a CLI trace option is present; an ambient debug/file/reset regression proves no output or file.
    All 33 cases pass in default/POSIX environments; runner and three trace CLI subtests remain green.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.4 - normalize Perl CLI failures`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.5`
  Status: `done`
  Goal: Lock Perl canonical trace routing and integrate the reusable fixture runner into the local gate.
  Acceptance: Stdout/route/mirror, file/reset, quiet/none, and emoji behavior are represented deterministically in
    the neutral suite; Perl passes every help/success/usage/failure/trace fixture; focused/local gates and public
    docs invoke the reusable runner; later Rust/Dart/Julia leaves consume the same manifest without forked cases.
  Verification: `PASS` - ADR `0024` replaces the nondeterministic multi-megabyte Perl CLI projection with one
    concise canonical phase protocol while preserving native embedding trace. Twenty exact cases lock stdout,
    route, mirror, file reset/persistence/append, all levels/aliases, numeric thresholds, UTF-8 emoji, success,
    and every failure phase. All 53 cases pass twice;
    four runner plus three trace subtests and `tools/run_ci_local.sh` pass. The local gate now invokes the same
    manifest/runner in default and POSIX environments.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.5 - close canonical CLI trace`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.6`
  Status: `active`
  Goal: Define and fixture-lock the primary CLI UTF-8 process boundary before declaring Perl the reusable reference.
  Acceptance: Audit argv and file decoding for inline/file/named source and literal/file input, canonical JSON
    encoding, invalid UTF-8 handling, error phase/status, and trace byte counts; ratify one backend-neutral policy;
    split implementation if needed; add exact neutral fixtures that prevent mojibake or host-specific decoding.
  Verification: `pending` - the initiating separated-byte probe passed UTF-8 argv `xé` through `input_text()` and
    observed stdout `22 78 c3 83 c2 a9 22 0a` instead of UTF-8 JSON `22 78 c3 a9 22 0a`. This is a real Perl-versus-
    Unicode-host divergence risk, not a trace-only issue. No `.1.5.1.6` repair has started while `.1.5.1.5` is dirty.
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

- ID: `FUTURE-PARITY-BACKLOG.10`
  Status: `active`
  Goal: Expose deep semantic introspection through one clean backend-neutral API and thin MCP projection.
  Children: `.10.0`, `.10.1`
  Acceptance: The direction is durable before design/code; native in-memory APIs own semantics; MCP is transport;
    every variant exposes equivalent versioned queries/results; stable ids/order/source provenance and exact
    conformance prevent backend IR or transport details from becoming the public contract.

- ID: `FUTURE-PARITY-BACKLOG.10.0`
  Status: `done`
  Goal: Capture the director's semantic-introspection API plus MCP direction without changing the active frontier.
  Acceptance: Task tree, roadmaps/live docs, mdBook, resume pointer, and Knowledge Map record the direction and its
    architectural boundary; no parser/compiler/runtime/MCP implementation changes; `.1.5.1.6` remains active.
  Verification: **PASS 2026-07-10.** Knowledge Map generation/check, memory architecture, task-tree metadata,
    doctrine, whitespace, and mdBook build pass. No implementation code or active frontier changed.
  Commit: `FUTURE-PARITY-BACKLOG.10.0 - capture semantic introspection MCP direction`

- ID: `FUTURE-PARITY-BACKLOG.10.1`
  Status: `pending`
  Goal: Design the semantic introspection schema, native query API, parity gate, and MCP projection before code.
  Acceptance: Inventory reusable semantic state and user questions; define versioned, deterministic read-only
    queries/results for rule/symbol/edge/call graphs, regex and lifecycle semantics, source spans/provenance,
    inferred value/target shapes, helper/function resolution, generated-source relationships, diagnostics, and
    explain-why paths; specify stable ids, ordering, pagination/cost limits, source/privacy controls, schema
    evolution, exact cross-backend fixtures, idiomatic host APIs, CLI relationship, and a thin MCP server that owns
    no semantic behavior. Explicitly prevent backend AST/IR layouts from becoming the public contract. Split later
    implementation by semantic model, per-backend adapters, conformance, and MCP transport before code.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `JULIA-BACKEND-PARITY.7.3.3` | `done` | Julia-local status is reconciled; its root remains active/delegated rather than falsely complete. |
| 2 | `FUTURE-PARITY-BACKLOG.1.5.1.0` | `done` | Perl/fixture source and process audit is split before implementation. |
| 3 | `FUTURE-PARITY-BACKLOG.1.5.1.1` | `done` | Neutral manifest/runner, exact help bytes, workspaces, and output-file proof are locked. |
| 4 | `FUTURE-PARITY-BACKLOG.1.5.1.2` | `done` | Twenty-two cases lock exact case-sensitive arguments and usage bytes in both POSIX environments. |
| 5 | `FUTURE-PARITY-BACKLOG.1.5.1.3` | `done` | Seven success cases lock source/input/parser controls and canonical bytes. |
| 6 | `FUTURE-PARITY-BACKLOG.1.5.1.4` | `done` | Four cases lock phase-ordered operational failures and stdout purity. |
| 7 | `FUTURE-PARITY-BACKLOG.1.5.1.5` | `done` | Twenty trace cases and the local gate close canonical trace at 53/53. |
| 8 | `FUTURE-PARITY-BACKLOG.1.5.1.6` | `active` | Define/lock UTF-8 argv/file/JSON behavior before Perl becomes the reusable reference. |
| 9 | `FUTURE-PARITY-BACKLOG.1.5.2` | `pending` | Add the missing Rust primary CLI against the completed Perl/shared fixtures. |
| 10 | `FUTURE-PARITY-BACKLOG.1.5.3` | `pending` | Replace Dart's corpus-oriented primary command with the shared parser interface. |
| 11 | `FUTURE-PARITY-BACKLOG.1.5.4` | `pending` | Make four-backend CLI identity a recurring gate. |
| 12 | `FUTURE-PARITY-BACKLOG.1.6` | `pending` | Census every documented/exported user capability and split all residual parity gaps. |
| 13 | `FUTURE-PARITY-BACKLOG.3` | `pending` | Public generated-source capability must converge after the capability census/split. |
| 14 | `FUTURE-PARITY-BACKLOG.1.3` | `pending` | Lua inherits the complete capability and identical CLI gates after current backends converge. |
| 15 | `FUTURE-PARITY-BACKLOG.2` | `pending` | Staged parsing generalization follows unless the director explicitly pivots. |
| 16 | `FUTURE-PARITY-BACKLOG.4` | `pending` | Function extensions need explicit language decisions before code. |
| 17 | `FUTURE-PARITY-BACKLOG.5` | `pending` | Helper caveats are documented but not normalized. |
| 18 | `FUTURE-PARITY-BACKLOG.6` | `pending` | Plugin machinery fate is a Perl-reference facade decision. |
| 19 | `FUTURE-PARITY-BACKLOG.7` | `pending` | Richer oracle candidates need safe fixture triage. |
| 20 | `FUTURE-PARITY-BACKLOG.8.1` | `pending` | Director's single-source parser+stimuli roundtrip arc is parked for later design. |
| 21 | `FUTURE-PARITY-BACKLOG.9.1` | `pending` | Director's corrected AND/OR edge-default arc is parked for later design. |
| 22 | `FUTURE-PARITY-BACKLOG.10.1` | `pending` | Director's semantic-introspection API/MCP arc is parked behind the active backend frontier. |

## `FUTURE-PARITY-BACKLOG.1.5.1.5` Canonical Trace Protocol and Final Perl Gate

Implementation evidence recorded on 2026-07-10:

- Exact pre-change probes showed that one-token parsing emitted about 1.7 MB at `low` and 6.8 MB at `high`, with
  timestamps, Perl module/function/line locations, and backend-internal compiler events. Emoji file routing also
  leaked host `Wide character in print` warnings to stderr. Those bytes could not be deterministic or portable.
- ADR `0024` defines the primary-command/native-embedding boundary. The CLI now emits exact UTF-8
  `[linkedspec][LEVEL] EVENT` records for portable compile/input/invoke phases. Low owns phase start/outcome,
  medium request controls, high byte counts, full JSON length, and debug protocol version. Native `LinkedSpec::Trace`
  remains unchanged and richer for in-memory users; the primary adapter suppresses its backend-specific stream.
- The initial seven-case matrix covered stdout low, routed reset+emoji, mirrored reset, stdout with a selected file
  left unchanged, none+reset, quiet stdout, and routed compilation failure. Signoff review then found the manifest
  did not yet byte-lock the ADR's medium/high/full/debug records, aliases/numeric thresholds, default route, append,
  or input/invocation error outcomes. Eleven additional cases close that latent cross-backend divergence risk.
  A final byte-representation probe then found raw UTF-8 arguments were double-counted and arbitrary top-rule
  control bytes could forge extra records. Two more fixtures lock process-boundary byte counts and percent-escaped
  field data. The resulting 20 neutral trace cases extend the manifest from 33 to 53 and exact raw channels/files
  prove every declared threshold/event, route/mirror identity, persistence/truncation/append, UTF-8 emoji and byte
  counts, single-line field safety, JSON suffix, and all three failure-phase stderr/exit contracts.
- `tools/run_ci_local.sh` now requires and syntax-checks the primary command, neutral runner/manifest, runner tests,
  and trace tests. It runs the focused runner/trace suites and all 53 cases under both default and POSIX option
  environments before the heavy Phase 0 gate. Untracked CLI fixture inputs are rejected.
- Exact help and usage output identify the portable phase protocol and direct users to native embedding for richer
  backend-internal trace events.

## `FUTURE-PARITY-BACKLOG.1.5.1.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct stdout/route/mirror/none/emoji probes measured multi-megabyte nondeterministic
  native output and captured emoji encoding warnings before the adapter change.
- [x] **ROOT CAUSE (WHY + WHERE)** — `bin/linkedspec` passed primary trace flags directly into the native Perl
  compiler/runtime stream, whose timestamps, source locations, recursive bootstrap events, and host IO encoding are
  correct backend diagnostics but cannot be an identical multi-backend CLI protocol.
- [x] **FIX** — Add ADR `0024`, canonical phase tracing with raw UTF-8 sink handling, 20 exact fixtures, updated
  focused assertions/help/docs, and one reusable-runner integration in the canonical local gate.
- [x] **ADDRESSED (verified)** — Stdout/route/mirror, default file routing, reset/no-reset/append, every named level
  and alias, numeric threshold projection, emoji at all event levels, exact UTF-8 byte counts, percent-escaped
  user fields, all failure phases, JSON/channel separation, deterministic records, and native-versus-CLI ownership
  are locked.
- [x] **NO REGRESSION** — All 53 cases pass in default/POSIX environments; four runner and three trace subtests,
  full `tools/run_ci_local.sh` including Phase 0 `1..1028`, Knowledge Map, governance, mdBook, whitespace, and
  cleanup pass.
- [x] **LOCKSTEP** — The trace leaf is done and runner/local gate/docs/KM/ADR surfaces use one 53-case trace-aware
  contract. Signoff's pre-existing Unicode finding is owned by active `.1.5.1.6`; Rust `.1.5.2` remains pending
  so it cannot consume a mojibake-prone reference boundary.

## `FUTURE-PARITY-BACKLOG.1.5.1.4` Perl Operational Failures and Stdout Purity

Implementation evidence recorded on 2026-07-10:

- Four shared failure cases extend the manifest from 29 to 33 cases: invalid inline source with a simultaneously
  missing input, a missing spec file, a missing input file after valid compilation, and invocation with a missing
  explicit top rule. The first proves compilation wins before deferred input loading.
- Each operational family now emits exactly one stable line: `linkedspec: parser compilation failed`,
  `linkedspec: input load failed`, or `linkedspec: parser invocation failed`. Stdout is empty, stderr ends in one
  newline, exit is `1`, and no unexpected files appear. Host paths, OS `$!`, Perl exceptions, owner-stage names,
  timestamps, source filenames, and runtime-context wording are not part of the cross-backend command contract.
- Exact help and usage snapshots now document the stable operational heading/exit `1` and usage help/exit `2`
  behavior, so users do not need implementation knowledge to interpret the three status classes.
- With no primary-CLI trace option, the adapter clears backend-specific trace environment inputs and configures an
  internal below-`none` level with an empty route sink. This suppresses the general library's intentionally visible
  `DUMP_NONE` diagnostics without changing `LinkedSpec::Trace`. Any explicit CLI trace option retains the normal
  trace pipeline and remains `.1.5.1.5`'s deterministic matrix/final-gate responsibility.
- `t/trace_cli.t` locks a debug/file/reset ambient environment around the compile-before-input case: exit/stderr
  remain exact, stdout stays empty, and no ambient trace file is created or reset.

## `FUTURE-PARITY-BACKLOG.1.5.1.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Separated direct processes captured 755/240 bytes of timestamped `DUMP_NONE` stdout
  on compile/invocation failures plus platform paths, `$!`, internal fields, and raw exceptions on stderr.
- [x] **ROOT CAUSE (WHY + WHERE)** — `LinkedSpec::Trace::log_output` deliberately exposes level-zero diagnostics
  at default verbosity, while `bin/linkedspec::_runtime_error` projected runtime context and raw host errors. The
  general library is correct for embedding/debugging; the primary adapter lacked a deterministic untraced boundary.
- [x] **FIX** — Add four exact failure fixtures, make untraced CLI calls use a below-`none` discard configuration,
  and reduce operational stderr to one shared phase heading. The following `.1.5.1.5` slice then projected explicit
  primary-CLI tracing onto the canonical portable phase protocol while preserving the rich native embedding trace.
- [x] **ADDRESSED (verified)** — Compile/source-load, input-load, invocation, phase precedence, paths, host wording,
  ambient trace state, stdout/stderr, exit `1`, and generated-file absence are byte-locked.
- [x] **NO REGRESSION** — All 33 cases pass twice; CLI/test syntax, four runner subtests, all three trace CLI
  subtests, Knowledge Map, governance, mdBook, whitespace, and cleanup gates pass.
- [x] **LOCKSTEP** — Manifest/docs/book/task/KM surfaces report 2 help + 20 usage + 7 success + 4 failure cases;
  `.1.5.1.5` became active there and has since closed explicit trace plus reusable-runner local-gate integration.

## `FUTURE-PARITY-BACKLOG.1.5.1.3` Perl Source, Input, Parser Controls, and Success Bytes

Implementation evidence recorded on 2026-07-10:

- Seven shared success cases extend the manifest from 22 to 29 cases. They cover the repository `Lispish` named
  spec from the runner's isolated working directory, file source plus file input, inline source plus literal input,
  explicit `--top-rule`, explicit seek and consume modes, and exact file-input byte preservation.
- The file-backed grammar returns a deliberately unsorted nested hash. Perl's canonical JSON writer emits
  `{"a":{"b":2,"d":4},"z":0}` with recursive lexical key ordering. Every success writes empty stderr,
  exits `0`, creates no unexpected files, and terminates the one JSON value with exactly one newline.
- `cli_conformance/cases/success/input.txt` contains `x` plus a newline. The `input_text()` case emits `"x\\n"` plus the JSON
  record newline, proving `_slurp` does not trim or normalize file input before parser invocation.
- Toolbox `LinkedSpec::Get`, `get_parser`, generated-source, and debug-trace probes were used before choosing the
  grammar. They reverified ADR `0020`'s known Perl direct-default-rule `E` omission. The fixtures therefore use the
  established action-edge return shape already present in the cross-variant corpus; lifecycle normalization stays
  outside this CLI-only leaf and remains a later complete-capability parity obligation.

## `FUTURE-PARITY-BACKLOG.1.5.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct CLI probes established exact named/file/inline, literal/file, top-rule,
  seek/consume, nested JSON, stderr, exit, and newline behavior before fixtures were written.
- [x] **ROOT CAUSE (WHY + WHERE)** — `bin/linkedspec` already forwards exact loaded bytes and parser controls to
  `get_parser`/`Get`; its canonical `JSON::PP` writer sorts keys and appends one newline. No success-path code gap
  existed. ADR `0020` explains why direct default-rule `E` is not a portable fixture shape.
- [x] **FIX** — Add seven language-neutral success cases and two raw checked-in source/input files; no backend
  implementation change or expected-output normalization was necessary.
- [x] **ADDRESSED (verified)** — All acceptance dimensions are independently represented, including isolated named
  resolution, nested recursive key ordering, and an input newline visible inside the returned JSON string.
- [x] **NO REGRESSION** — The complete 29-case suite passes in default and POSIX environments; runner/trace focused
  tests, syntax, governance, Knowledge Map, mdBook, whitespace, and cleanup gates pass.
- [x] **LOCKSTEP** — Manifest/docs/book/task/KM surfaces report exactly 2 help + 20 usage + 7 success cases;
  `.1.5.1.4` became active there and has since closed operational failures; `.1.5.1.5` retains trace/final ownership.

## `FUTURE-PARITY-BACKLOG.1.5.1.2` Strict Perl Arguments and Usage Bytes

Implementation evidence recorded on 2026-07-10:

- `bin/linkedspec` no longer delegates public syntax to ambient `Getopt::Long` configuration. One explicit parser
  recognizes only ADR `0023`'s exact case-sensitive long options plus `-h`, supports separate/`--option=value`
  value forms, treats repeated value options as last-wins, and accumulates ordered lexical errors before selector/
  value validation. Help remains an early successful result only after lexical errors are clear.
- No positional or subcommand surface exists. `status`, `corpus`, a trailing word, and literal `--` are usage
  errors. Uppercase and unique-abbreviation long options plus `--no-trace-reset` / `--no-trace-emoji` are unknown;
  boolean flags reject inline values. Missing values, source/input cardinality, seek/consume, all documented
  numeric/named trace levels, and stdout/route/mirror are validated explicitly.
- `cases/usage/stderr.txt` is one exact backend-neutral error-plus-help template. Schema channel variables insert
  only manifest-owned `{{ERROR}}` text and may not override the four reserved runner placeholders. This avoids 20
  duplicated help snapshots without introducing backend-conditioned expected output.
- The manifest now has 22 exact cases: two help forms and 20 usage cases. Every failure requires empty stdout,
  byte-exact stderr, no generated files, and exit `2`. The complete suite passes both with `POSIXLY_CORRECT` unset
  and with `POSIXLY_CORRECT=1`, proving ambient option-parser policy no longer changes the command.

## `FUTURE-PARITY-BACKLOG.1.5.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.1.5.1.0` directly proved ignored positionals, case/abbreviation/negation aliases,
  environment drift, and uncontrolled option-parser warnings.
- [x] **ROOT CAUSE (WHY + WHERE)** — Public syntax inherited `Getopt::Long` defaults, used negatable `!` flags,
  never inspected residual arguments, and let the library write its own warning before CLI-owned usage output.
- [x] **FIX** — Replace that boundary with one explicit ordered parser and add 20 exact shared usage cases plus
  reusable channel-template variables.
- [x] **ADDRESSED (verified)** — Required/help/value/flag/unknown/positional/selector/mode/level/multi-error families
  are byte-locked, case-sensitive, non-abbreviating, non-negatable, and environment-independent.
- [x] **NO REGRESSION** — CLI/runner/test syntax passes; 22/22 cases pass twice (default and POSIX), four runner
  subtests and two trace CLI subtests remain green; parser/compiler/runtime behavior is unchanged.
- [x] **LOCKSTEP** — Manifest/README/TOOLBOX/mdBook/task/live/KM surfaces report exact help+usage scope only;
  `.1.5.1.3` became active there and has since closed success bytes, while failures/trace retain later owners.

## `FUTURE-PARITY-BACKLOG.1.5.1.1` Neutral Fixture Runner and Help Baseline

Implementation evidence recorded on 2026-07-10:

- `cli_conformance/manifest.json` is the language-neutral ordered case inventory. Schema version 1 strictly rejects
  unknown keys, duplicate/invalid ids and output paths, unsafe relative paths, absent fixture/expected files,
  malformed placeholders, invalid channel definitions, and exit statuses outside 0–255.
- `tools/run_cli_conformance.pl` accepts any backend launch array after an explicit `--`; no backend name or
  implementation is embedded in fixture cases. It expands `{{REPO_ROOT}}` for launch, `{{COMMAND}}` for the allowed
  user-facing executable/wrapper difference, and exact `{{WORKSPACE}}`/`{{CASE_ID}}` runner inputs.
- Each case receives a canonicalized private temporary working directory. Checked-in input files are copied as raw
  bytes. `IO::Select` drains child stdout/stderr concurrently as separate raw byte streams, and the runner compares
  exit status, both channels, and expected generated workspace files byte-for-byte.
- A mismatch reports its first byte offset, expected/actual lengths, and escaped excerpts. Runner/schema misuse is
  exit `2`; conformance mismatch is `1`; a completely green selected set is `0`. `--case` can select focused ids.
- The first public case locks complete help stdout, empty stderr, and exit `0`. Its wording is backend-neutral (no
  Perl `Get`/`get_parser` names), documents numeric plus all named trace aliases and `--help`/`-h`, and substitutes
  only `{{COMMAND}}`. Perl passes it exactly.
- Four runner subtests (13 assertions) lock the checked-in Perl case, schema rejection before launch, command/
  workspace/case substitution with input and generated-file bytes, and first-byte mismatch reporting. The existing
  two trace CLI subtests remain green.

## `FUTURE-PARITY-BACKLOG.1.5.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The split proved there was no checked-in backend-neutral case schema or arbitrary-
  command byte runner; only Perl-specific trace smokes existed.
- [x] **ROOT CAUSE (WHY + WHERE)** — Existing tests owned one command directly and used regex/inline expectations,
  so later backends had no common data model, isolated workspace, generated-file contract, or byte diagnostics.
- [x] **FIX** — Add the strict manifest, arbitrary command-array runner, raw channel/file comparison, exact help
  case, runner tests, backend-neutral help text, and public/toolbox documentation.
- [x] **ADDRESSED (verified)** — Schema, path safety, command/display substitution, macOS canonical workspace
  identity, file materialization/output, stdout/stderr/exit exactness, and mismatch behavior are locked.
- [x] **NO REGRESSION** — `perl -c` passes for CLI/runner/test; four runner subtests and two trace CLI subtests pass;
  direct `help` conformance passes. No parser/compiler/runtime semantics changed.
- [x] **LOCKSTEP** — README, TOOLBOX, mdBook, task/live/roadmap docs, and Knowledge Map describe one reusable suite;
  `.1.5.1.2` became active there and has since closed strict arguments; no later backend has a forked manifest.

## `FUTURE-PARITY-BACKLOG.1.5.1.0` Neutral CLI / Perl Audit and Split

Read-only evidence recorded on 2026-07-10:

- ADR `0023` requires exact option spellings/meanings, no positionals/subcommands, canonical success bytes, stable
  errors and 0/1/2 exits, deterministic trace routing, and one language-neutral fixture suite reused by every
  backend. `bin/linkedspec` is the current parser-oriented reference; `t/trace_cli.t` covers only help flag presence
  plus one routed-trace success.
- Direct process probes prove undocumented surface. An extra positional is ignored and the command exits `0`;
  uppercase long options, unique abbreviations such as `--inl`, and `--no-trace-reset` / `--no-trace-emoji` are
  accepted. `POSIXLY_CORRECT=1` changes abbreviation and option-order behavior, so the public API depends on ambient
  process state. Unknown options also prepend `Getopt::Long`'s uncontrolled warning before the owned usage text.
- Compilation-before-input ordering already holds, and usage/operational statuses are correctly `2`/`1`. However,
  compilation and missing-top-rule probes capture timestamped/source-located `DUMP_NONE` trace records on stdout
  while normalized diagnostics go to stderr. This violates machine-readable failure stdout and cannot be an exact
  cross-backend fixture. Input failures also expose host `$!` text unless normalized.
- The existing trace owner deliberately treats `DUMP_NONE` events as visible at verbosity zero; the CLI adapter,
  not the trace library's general diagnostics contract, must own primary-command stdout purity and deterministic
  projection. Trace fixtures therefore remain a separate final mechanism rather than being folded into argument
  parsing.

## `FUTURE-PARITY-BACKLOG.1.5.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the existing trace CLI test plus direct help/positional/case/abbreviation/
  negation/environment/unknown/compile/input/invocation process probes with stdout and stderr captured separately.
- [x] **ROOT CAUSE (WHY + WHERE)** — `bin/linkedspec` inherits `Getopt::Long` defaults, never rejects residual
  `@ARGV`, declares boolean flags with `!`, lets `GetOptions` print its own warning, and invokes a library whose
  level-zero diagnostic trace is intentionally visible on stdout.
- [x] **FIX / SPLIT** — Split neutral harness/help (`.1`), strict arguments (`.2`), successful source/input/parser
  behavior (`.3`), operational errors/stdout purity (`.4`), and deterministic trace plus final gate (`.5`).
- [x] **ADDRESSED (verified)** — Every observed gap and every ADR `0023` required fixture family has one ordered
  leaf before code changes.
- [x] **NO REGRESSION** — `prove -v -Iperl t/trace_cli.t` passes; this slice changes no CLI/parser/runtime source.
- [x] **LOCKSTEP** — Task index, roadmap/live/book status, Knowledge Map, and resume pointer advance only to
  `.1.5.1.1`; Rust/Dart/Julia remain later consumers of the same not-yet-created fixture manifest.

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
- `2026-07-10`: `.1.5.1.0` proves Perl's primary adapter is parser-oriented but not strict/deterministic enough to
  be the neutral executable reference. Fixture infrastructure, arguments, success/IO, failures, and trace/gate are
  separate leaves; `.1.5.1.1` became active there and has since closed the runner/help baseline. No behavior changed
  in the split.
- `2026-07-10`: `.1.5.1.1` adopts `cli_conformance/manifest.json` plus one arbitrary-command Perl runner as the
  reusable cross-backend fixture architecture. Explicit placeholders represent command/runner inputs; they do not
  authorize backend-specific expected outputs. Exact generated workspace files are part of schema version 1 so
  later trace cases do not require a schema fork. `.1.5.1.2` became active there and has since closed strict Perl
  arguments.
- `2026-07-10`: `.1.5.1.2` removes ambient option-parser policy from Perl's public command. Exact shared parsing is
  manual and case-sensitive; usage-template variables are manifest data and cannot override reserved runner inputs.
  Twenty-two cases pass under both default and POSIX environments; `.1.5.1.3` has since closed successful IO/control.
- `2026-07-10`: `.1.5.1.3` adds seven portable success cases without changing Perl behavior. Named/file/inline
  source, literal/file input, top-rule, seek/consume, nested canonical JSON, exact input newline bytes, empty
  stderr, exit `0`, and one record newline are locked. `.1.5.1.4` has since closed operational failures/stdout purity.
- `2026-07-10`: `.1.5.1.4` adds four exact phase-ordered failures and normalizes the untraced adapter boundary.
  Compilation precedes input; compile/input/invocation emit one shared heading, empty stdout, exit `1`, and no
  files. Ambient backend trace state cannot opt the primary command in; `.1.5.1.5` has since closed explicit trace.
- `2026-07-10`: `.1.5.1.5` adopts ADR `0024` and closes canonical trace at 20 exact trace / 53 total cases. The
  timestamped multi-megabyte backend stream becomes a concise portable phase protocol while native tracing remains
  rich. Signoff also exposes a pre-existing UTF-8 argv-to-JSON mojibake boundary, now owned by active `.1.5.1.6`;
  Rust `.1.5.2` stays pending until the Perl/shared reference boundary is exact.

## Open Questions

- `.1.5.1.6` must decide and lock the backend-neutral UTF-8 argv/file/JSON and invalid-input policy. The observed
  Perl mojibake mechanism is known; source/file breadth and the exact rejection phase still require the owned audit.
  Lua `.1.3` remains gated until current implemented backends close ADR `0023` CLI/capability convergence,
  including any `.1.6`-split gaps and public generated source under `.3`.

## Blockers

- None. `.1.5.1.6` is the active, source-backed UTF-8 reference-boundary leaf; `.1.5.2` is deliberately pending.
  Global CLI/capability convergence precedes Lua `.1.3`.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.1.1` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.1.2` | `git diff --check`; stale handoff/frontier `rg` scan; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_task_tree_metadata.sh`; `bash scripts/check_doctrines.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning only; created `JULIA-BACKEND-PARITY` and no Julia package or implementation code. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.8.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning capture only; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.9.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning capture only; no implementation code changed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.10.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; Knowledge Map generation/check; doctrine; task-tree metadata; `mdbook build docs/linkedspec-book`; cleanup | PASS. Semantic introspection/MCP is durably parked with native-API ownership and transport separation; no implementation or active-frontier change. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.4` | Perl direct `LinkedSpec::Get` coderef probe; focused Dart runtime tests (50); direct Julia parse/compile/execute probe; static Rust core/runtime API and Dart/Julia CLI-adapter audit; `mdbook build docs/linkedspec-book`; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check` | PASS. ADR `0022` makes native in-memory embedding primary and CLIs secondary; current/future backend acceptance and public docs agree; no parser/compiler/runtime source changed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.0` | Delegated Julia `.7.3.1`: ADR `0023`; Perl CLI/trace contract and Rust public source-emitter audit; global task routing; mdBook build; Knowledge Map generation/check; memory/task/doctrine/whitespace gates. | PASS. Exact primary CLI and public-capability parity are durable; `.1.5.1`–`.1.5.4`, `.1.6`, and `.3` own convergence; no implementation behavior changed. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.7.3.3` | Delegated current-surface audit; stale mdBook provenance/correction; exact owner routing; prior `431f0472` Julia proof; docs/KM/governance/whitespace and mdBook. | PASS. Julia's local audit is done while its root remains active/delegated; `.1.5.1` became next and `.1.5.1.0` has since split it. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.0` | ADR/KM/toolbox and Perl source/test audit; existing trace test; direct argument/environment/failure probes with separated stdout/stderr; docs/KM/governance/whitespace/mdBook. | PASS. Five implementation mechanisms are split; no behavior source changed; `.1.5.1.1` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.1` | CLI/runner/test syntax; 4 runner subtests/13 assertions; 2 trace CLI subtests; direct neutral help execution; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Schema/runner/workspace/channels/generated files and exact help are locked; `.1.5.1.2` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.2` | CLI/runner/test syntax; 22/22 exact cases under default and `POSIXLY_CORRECT=1`; 4 runner subtests; 2 trace CLI subtests; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Exact arguments/usage are environment-independent; `.1.5.1.3` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.3` | Toolbox Get/get_parser/generated-source/trace probes; 29/29 exact cases under default and `POSIXLY_CORRECT=1`; runner/trace tests; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Seven success cases lock exact source/input/parser/JSON behavior; `.1.5.1.4` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.4` | Direct separated failure probes; 33/33 exact cases under default and `POSIXLY_CORRECT=1`; ambient trace isolation; 4 runner + 3 trace subtests; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Operational phases/channels/exit are stable; `.1.5.1.5` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.5` | Raw old-trace size/byte probes; signoff coverage/UTF-8/control-field audit; 53/53 exact cases under default and POSIX; 4 runner + 3 trace subtests; full local gate/Phase 0; docs/KM/ADR/governance/whitespace/mdBook and cleanup. | PASS. Canonical primary trace is closed; the surfaced pre-existing argv/JSON mojibake is owned by active `.1.5.1.6` before Rust. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FUTURE-PARITY-BACKLOG.0` | `FUTURE-PARITY-BACKLOG.0 - create future parity backlog` | Tracking/decision/doc sync; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.1` | `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan` | Creates `DART-BACKEND-PARITY`; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.2` | `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan` | Creates `JULIA-BACKEND-PARITY`; no implementation code. |
| `FUTURE-PARITY-BACKLOG.8.0` | `FUTURE-PARITY-BACKLOG.8.0 - capture spec-derived roundtrip idea` | Captures future `foo.spec` parser/stimuli closed-loop validation arc; no implementation code. |
| `FUTURE-PARITY-BACKLOG.9.0` | `FUTURE-PARITY-BACKLOG.9.0 - capture AND OR edge default correction` | Captures future AND/OR mode-sensitive edge-default design arc; no implementation code. |
| `FUTURE-PARITY-BACKLOG.10.0` | `FUTURE-PARITY-BACKLOG.10.0 - capture semantic introspection MCP direction` | Captures a backend-neutral native semantic API plus thin MCP projection; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.4` | `FUTURE-PARITY-BACKLOG.1.4 - ratify native in-memory backend contract` | ADR `0022` and public/backend planning surfaces make native host-process embedding primary; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.5.0` | `JULIA-BACKEND-PARITY.7.3.1 - ratify exact backend interface parity` | Delegated ADR `0023` contract/routing; global implementation follows after Julia's active repair leaf. |
| `JULIA-BACKEND-PARITY.7.3.3` | `JULIA-BACKEND-PARITY.7.3.3 - reconcile Julia scoped parity status` | Delegated local audit done; Julia root remains active through global `.1.5`, `.1.6`, and `.3`. |
| `FUTURE-PARITY-BACKLOG.1.5.1.0` | `FUTURE-PARITY-BACKLOG.1.5.1.0 - split neutral CLI fixture work` | Read-only Perl/process audit and five-leaf implementation split. |
| `FUTURE-PARITY-BACKLOG.1.5.1.1` | `FUTURE-PARITY-BACKLOG.1.5.1.1 - add neutral CLI fixture runner` | Strict schema, arbitrary command runner, exact help case, output-file support, and focused tests. |
| `FUTURE-PARITY-BACKLOG.1.5.1.2` | `FUTURE-PARITY-BACKLOG.1.5.1.2 - normalize Perl CLI arguments` | Explicit parser plus 20 exact usage cases; 22/22 green in default/POSIX environments. |
| `FUTURE-PARITY-BACKLOG.1.5.1.3` | `FUTURE-PARITY-BACKLOG.1.5.1.3 - lock Perl CLI success behavior` | Seven exact success cases; source/input/parser controls and canonical JSON locked. |
| `FUTURE-PARITY-BACKLOG.1.5.1.4` | `FUTURE-PARITY-BACKLOG.1.5.1.4 - normalize Perl CLI failures` | Four failures; phase order, stable stderr, stdout purity, and exit `1` locked. |
| `FUTURE-PARITY-BACKLOG.1.5.1.5` | `FUTURE-PARITY-BACKLOG.1.5.1.5 - close canonical CLI trace` | ADR 0024, 20 trace cases, 53-case suite, and canonical local gate. |

## Changelog

- `2026-07-10`: `.10.0` captures the director's deep semantic-introspection/API/MCP direction without pivoting
  from `.1.5.1.6`. The parked design requires a versioned backend-neutral semantic model, deterministic stable ids
  and provenance, exact cross-variant query fixtures, idiomatic in-memory APIs, and MCP as a thin transport with no
  semantic ownership. `.10.1` owns design before any implementation.
- `2026-07-10`: `.1.5.1.5` closes canonical primary trace at 20 trace / 53 total exact cases. ADR `0024` separates
  the concise deterministic CLI phase protocol from rich native embedding trace. The matrix locks levels/aliases,
  thresholds, sinks/reset/append, emoji, byte counts, field escaping, and all failure phases; the local gate runs
  the suite twice. A signoff probe exposed raw UTF-8 argv mojibake in successful JSON, now owned by `.1.5.1.6`.
- `2026-07-10`: `.1.5.1.4` extends the suite to 33 exact cases with invalid/missing source compilation,
  compilation-before-input, missing input, and missing-top-rule invocation. Untraced failures now emit empty
  stdout, one backend-neutral stderr heading, exit `1`, and no files. The adapter ignores ambient backend trace
  state unless a CLI trace option is present; explicit trace remains `.1.5.1.5` work.
- `2026-07-10`: `.1.5.1.3` extends the neutral suite to 29 cases with seven successful process families. Isolated
  named resolution, file/inline source, literal/file input, explicit top rule, seek/consume, recursively sorted
  nested JSON, exact input newline bytes, empty stderr, exit `0`, and one output newline are byte-locked. Existing
  ADR `0020` direct-`E` drift was reverified with the toolbox, so portable action-edge sources own these fixtures.
- `2026-07-10`: `.1.5.1.2` replaces Perl's ambient `Getopt::Long` boundary with an explicit exact parser. The
  shared manifest now has two help plus 20 usage cases covering positionals/subcommands, `--`, unknown/case/
  abbreviation/negation aliases, required/flag values, selector conflicts, modes/levels, and ordered multi-error
  text. All 22 pass with and without `POSIXLY_CORRECT`; `.1.5.1.3` subsequently closed successful IO/control bytes.
- `2026-07-10`: `.1.5.1.1` adds the backend-neutral CLI fixture architecture. A strict manifest and arbitrary
  command runner own private workspaces, raw stdout/stderr, exit status, generated files, safe paths, explicit
  placeholders, and byte diagnostics. Perl passes the exact backend-neutral help case; 13 runner assertions and
  the existing trace tests pass. `.1.5.1.2` became active there and has since closed strict argument/usage cases.
- `2026-07-10`: `.1.5.1.0` audits the Perl reference adapter and splits neutral CLI work. Direct probes find
  ignored positionals, case/abbreviation/negated aliases, environment-dependent `Getopt::Long` behavior,
  uncontrolled option warnings, and level-zero timestamped failure trace on stdout. Harness/help, arguments,
  success/IO, failures, and trace/gate now have ordered owners; `.1.5.1.1` became active there and has since closed.
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
