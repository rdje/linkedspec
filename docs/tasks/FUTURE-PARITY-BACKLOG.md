# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-07-12` (backend README follow-up `.12.1.10` re-closes selector-retirement public no-drift).
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

- The fifteen backlog directions are represented as owned task-tree lanes, including compatibility retirement,
  repair of the codegen-inspector toolbox regression discovered while proving selector-source migration, and the
  director's structural linked-rule plus progressive/staged parser-composition authoring model and rule-level bare
  lifecycle-block shorthand.
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
- The trailing-codeblock correction records `codeblock` alongside scalar, array, and harray as a language value
  kind; for callables whose signature accepts a final codeblock, `call(args) { ... }` and
  `call(args, { ... })` must be equivalent on helper, user-function, and receiver-method surfaces in every variant.
- The director's variadic-callable direction is recorded: callable purpose governs exact versus unbounded arity,
  and user-defined functions gain one explicit grammar-owned definition-time variadic signature after audit.
- The director's parser-authoring doctrine is recorded: simple zero/one/two-regex rules form a linked structural
  graph; recursion belongs in rule connections rather than recursive regexes; cursor-relative extraction enables
  in-parse parser composition; and returned AST fields may be parsed again by later spec-driven stages.
- The central task-tree index points at the current frontier.
- ADR, roadmap, mdBook, Knowledge Map, and live docs no longer contradict the backend order or
  Lua adoption decision.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `FUTURE-PARITY-BACKLOG`
  Status: `active`
  Goal: Own the future parity backlog after the closed language-reference/terse-format trees.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`, `.10`, `.11`, `.12`, `.13`, `.14`

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
  Status: `done`
  Goal: Lua backend parity track - split/scaffold after Julia reaches its scoped parity milestone.
  Acceptance: Create or expand a dedicated Lua backend implementation plan with the same universal
    `.spec`, helper/action AST, runtime, staged parsing, diagnostics, and corpus parity obligations; define an
    idiomatic native Lua module that parses/compiles/executes in memory, direct library-level embedding tests,
    and a distinct Lua-specific executable token that implements ADR `0023`'s exact primary CLI interface.
  Verification: **PASS 2026-07-11.** Created `docs/tasks/LUA-BACKEND-PARITY.md` as the dedicated full-parity Lua
    plan. It fixes PUC Lua 5.4 primary/LuaJIT secondary roles, records installed Lua/LPeg and absent LuaRocks/test/
    lint/format tools, and splits module/harness, frontend, ActionIR/compiler, matching/runtime, staged/loading/
    capabilities, 105-case corpus, exact CLI, generated source, docs/gates, and final admission. Native in-memory
    APIs, exact 61x2 CLI, four value kinds, generic final-codeblock syntax, newline/semicolon and quote semantics,
    strict UTF-8 boundaries, 15-capability expansion, and generated-source v1 are explicit. No Lua code changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.3 - scope Lua backend parity plan`

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
  Status: `done`
  Goal: Make every implemented backend's primary CLI conform to one byte-testable user interface.
  Children: `.1.5.0`, `.1.5.1`, `.1.5.2`, `.1.5.3`, `.1.5.4`
  Verification: **PASS 2026-07-10.** Perl, Rust, Dart, and Julia expose the same strict 61-case primary CLI under
    default and POSIX option environments. One recurring driver owns all eight legs, backend-focused gates pass,
    and the broader core gate passes through Phase 0 `1..1028`.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.4.3 - close exact primary CLI parity`

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
  Status: `done`
  Goal: Lock the language-neutral CLI fixtures and normalize the Perl reference command to ADR `0023`.
  Children: `.1.5.1.0`, `.1.5.1.1`, `.1.5.1.2`, `.1.5.1.3`, `.1.5.1.4`, `.1.5.1.5`, `.1.5.1.6`
  Acceptance: Checked-in fixture cases define help, success, usage, compile/input/runtime failure, trace routing,
    stdout/stderr, and exit behavior; Perl passes exactly and rejects undocumented primary-CLI surface.
  Verification: **PASS 2026-07-10.** Seven completed implementation/no-drift leaves establish strict help/usage,
    source/input/parser controls, operational failures, canonical trace, preserved strict UTF-8, recursive JSON,
    and stable invalid-byte phases. Perl passes all 61 shared cases under default/POSIX environments; focused
    runner/trace tests and full local CI through Phase 0 pass. The neutral manifest is now the reusable reference.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.6.3 - close Perl CLI reference`

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
  Status: `done`
  Goal: Define and fixture-lock the primary CLI UTF-8 process boundary before declaring Perl the reusable reference.
  Children: `.1.5.1.6.0`, `.1.5.1.6.1`, `.1.5.1.6.2`, `.1.5.1.6.3`
  Acceptance: Audit argv and file decoding for inline/file/named source and literal/file input, canonical JSON
    encoding, invalid UTF-8 handling, error phase/status, and trace byte counts; ratify one backend-neutral policy;
    split implementation if needed; add exact neutral fixtures that prevent mojibake or host-specific decoding.
  Verification: **PASS 2026-07-10.** `.6.0` ratifies ADR `0025`, `.6.1` makes invalid bytes fixtureable, `.6.2`
    fixes strict Perl decoding/recursive UTF-8 JSON and adds eight exact behavior cases, and `.6.3` closes no-drift.
    The initiating mojibake is resolved; Perl passes 61/61 twice and the full local gate reaches Phase 0 `1..1028`.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.6.3 - close Perl CLI reference`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.6.0`
  Status: `done`
  Goal: Audit, ratify, and split the exact primary CLI UTF-8 text boundary before implementation.
  Acceptance: Use Knowledge Map/toolbox facts and direct native/process probes; inspect Perl, Julia, Rust, runner,
    and public docs; decide argv/file/JSON/trace encoding, normalization/BOM/newline behavior, invalid-byte phase,
    and contract exclusions; split runner, adapter/fixtures, and no-drift work before code.
  Verification: `PASS` - ADR `0025` defines strict UTF-8 text with no normalization, BOM stripping, newline
    conversion, or trimming; valid argv is the interface precondition; invalid source/input file bytes project to
    compilation/input-load failures. Perl `Get` probes prove decoded `xé` and `/é/` execute and serialize as exact
    `c3 a9`, isolating mojibake to adapter decoding. Julia uses `String` argv/files, Rust APIs use `&str` and
    `read_to_string`, and the neutral runner lacks invalid-byte materialization. Three implementation leaves own
    runner hex bytes, Perl boundary/fixtures, and final closeout; no behavior code changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.6.0 - split primary CLI UTF-8 boundary`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.6.1`
  Status: `done`
  Goal: Let the neutral runner materialize exact invalid/non-text fixture bytes without checked-in binary blobs.
  Acceptance: Extend schema version 1 input-file records with one validated mutually exclusive lowercase-even
    hex byte source beside checked-in `source`; preserve safe paths/workspaces/raw comparison; add focused schema,
    materialization, and malformed-hex tests; document the portable mechanism without backend-specific cases.
  Verification: `PASS` - schema-v1 input-file records accept exactly one of checked-in `source` or non-empty
    lowercase even-length `bytes_hex`; materialization uses raw `pack` bytes and preserves safe-path/workspace
    handling. Six runner subtests cover exact `00 c3 28 ff 0a` bytes plus both/neither/empty/uppercase/odd/non-hex
    rejection before backend launch. Syntax, checked-in help, full local gate, docs/KM/governance/book pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.6.1 - add neutral hex byte fixtures`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.6.2`
  Status: `done`
  Goal: Implement Perl strict UTF-8 process/file decoding and add exact valid/invalid neutral fixtures.
  Acceptance: Decode valid option values at the correct phase, decode source/input files strictly, preserve code
    points/BOM/newlines without normalization/trimming, emit canonical UTF-8 JSON, keep trace byte counts exact,
    map invalid source/input bytes to stable compilation/input-load failures, and cover literal/file Unicode plus
    invalid files in the shared manifest under default/POSIX environments.
  Verification: **PASS 2026-07-10.** `bin/linkedspec` strictly decodes valid UTF-8 argv and raw source/input files,
    preserves code points/BOM/newlines, emits recursive canonical JSON as UTF-8 once, and retains stable invalid
    source/input phase failures. Eight exact neutral cases cover inline/file Unicode, composed/decomposed text,
    input BOM/CRLF/LF, source BOM preservation, invalid files, and trace input/result byte counts. Focused suites,
    61/61 default and POSIX runs, full local CI/Phase 0, docs/KM/governance/mdBook/whitespace/cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.6.2 - enforce Perl CLI UTF-8 text`

- ID: `FUTURE-PARITY-BACKLOG.1.5.1.6.3`
  Status: `done`
  Goal: Close Perl UTF-8/reference conformance and advance to the Rust primary command no-drift.
  Acceptance: Re-audit all task/roadmap/KM/book/help/fixture/gate surfaces; run focused suites, both full neutral
    environments, mdBook/governance, and full local CI; mark `.1.5.1` done only if no stale byte-oriented or
    mojibake claim remains; activate `.1.5.2` without changing the shared contract.
  Verification: **PASS 2026-07-10.** Current-state searches find no unresolved Perl mojibake/active-repair claim;
    historical 53-case and initiating-gap evidence remains clearly dated. Help, task/roadmap/live docs, mdBook,
    Knowledge Map, and fixture counts agree on strict UTF-8 and the 61-case Perl reference. Focused suites, 61/61
    default/POSIX, full local CI/Phase 0, mdBook/governance/whitespace, and generated-artifact cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.1.6.3 - close Perl CLI reference`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2`
  Status: `done`
  Goal: Add the Rust primary CLI against the shared fixture contract.
  Children: `.1.5.2.0`, `.1.5.2.1`, `.1.5.2.2`, `.1.5.2.3`, `.1.5.2.4`
  Acceptance: A Rust binary delegates to native core/runtime APIs and passes the same CLI fixtures as Perl. The
    binary may project portable argument/loading/diagnostic/trace policy, but it may not duplicate `.spec` parsing,
    compilation, matching, lifecycle, helper, or result semantics owned by the Rust libraries.
  Verification: **PASS 2026-07-10.** Children `.0`-`.4` add the exact Rust process boundary, reusable native
    entry/mode/direct-value execution, strict preserved UTF-8 loading, canonical JSON/failures, ADR `0024` trace,
    and recurring local verification. The built command passes all 61 unchanged fixtures in default and POSIX
    environments without duplicating runtime language semantics.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.2.4 - close Rust primary CLI`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2.0`
  Status: `done`
  Goal: Audit and split the Rust primary-command work by observable mechanism before implementation.
  Acceptance: Inspect the Rust workspace, parser/compiler/validation/runtime/trace APIs, named-spec and fixture
    resolution, ADRs `0023`-`0025`, and the unchanged 61-case manifest; record exact reusable seams and gaps; split
    recoverable implementation leaves before adding a binary or changing runtime behavior.
  Verification: **PASS 2026-07-10.** Source audit confirms a two-library workspace with no binary target; native
    full-spec parsing, validation, compilation, execution, structured JSON values, and rich trace already exist.
    The runtime currently enters only the compiled `Top` rule and consumes each compiled rule's own parse mode, so
    reusable entry-rule/global-mode controls need a native execution seam rather than CLI-only semantics. Rust
    strict UTF-8 file reads, named resolution, exact option/help handling, canonical JSON bytes, stable phase
    failures, and canonical CLI trace projection remain adapter work. Governance, book, and Knowledge Map checks
    pass; no Rust source or fixture behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.2.0 - split Rust primary CLI work`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2.1`
  Status: `done`
  Goal: Add the Rust binary boundary with exact arguments, help, strict UTF-8 loading, and deterministic resolution.
  Acceptance: A `linkedspec-rust` binary exposes only ADR `0023`'s case-sensitive, non-abbreviating options; exact
    help/usage and exit `2` match shared bytes; named/file/inline source plus literal/file input preparation obeys
    compile-before-input ordering, repository fallback rules, and ADR `0025` strict preserved UTF-8 without owning
    parser/runtime semantics.
  Verification: **PASS 2026-07-10.** `linkedspec-runtime::primary_cli` and the `linkedspec-rust` binary now share
    one exact manual parser, fixture-derived help, deterministic current-directory/repository named resolution,
    deferred input loading, strict `String::from_utf8` file decoding, stable phase headings, and raw process-channel
    bytes. Four focused unit tests pass. The built binary passes all 22 shared help/usage cases byte-for-byte and
    the full manifest baseline passes 29/61: the other seven passes are all three invalid-UTF-8 phase cases and all
    four operational failures. The full runtime package passes 133 unit, 99 oracle, 190 integration, three source-
    emitter, and 10 trace-control tests. The 32 expected residuals are exactly 11 direct top-value result cases (the
    existing documented Rust accumulator wrapper) plus 21 canonical-trace cases owned by `.2`/`.3`. Formatting,
    build, runtime tests, default/POSIX argument fixtures, governance, mdBook, and cleanup pass. Strict Clippy on
    the touched crate remains obstructed only by pre-existing core/runtime lints; the new module's large-enum lint
    was fixed; formatting and `cargo build` are green.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.2.1 - add Rust CLI boundary`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2.2`
  Status: `done`
  Goal: Expose native Rust entry-rule/parse-mode controls and complete primary execution/result/failure projection.
  Acceptance: The native runtime provides idiomatic reusable controls for optional entry rule and global parse
    mode; the CLI composes full-spec parse, validation, compile, and `Engine` execution through public APIs; nested
    values emit recursively canonical compact UTF-8 JSON plus one newline; compile/input/invoke failures and exits
    match the shared phase contract without backend exception leakage.
  Verification: **PASS 2026-07-10.** `ExecutionOptions` plus `Engine::execute_value` and traced variants expose
    per-invocation entry-rule/global-mode selection and the direct rule value without mutating compiled state;
    legacy `Engine::execute` retains its accumulator wrapper. Runtime matching consumes the effective override in
    interpreted and generated-plan paths. The CLI now uses this API instead of compiled-field mutation. A nested
    shared object exposed Rust `hash(...)` implicitly splicing every hash argument; Rust now matches the existing
    cross-backend/book contract by preserving ordinary hash values and splicing only explicit `flat`/`flat_hash`.
    Three focused native/hash tests and all 11 direct result cases pass; the unchanged suite advances 29 -> 41/61,
    leaving only 20 non-quiet trace cases under `.3`. Full runtime package, formatting/build, governance, mdBook,
    Knowledge Map, whitespace, and regenerated-cache cleanup pass. Strict Clippy remains blocked only by the same
    pre-existing runtime/core lint backlog; no new touched-code diagnostic remains.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.2.2 - add Rust direct execution API`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2.3`
  Status: `done`
  Goal: Implement the canonical primary CLI trace projection and exact sink behavior in Rust.
  Acceptance: Rust emits ADR `0024`'s deterministic phase records, thresholds/aliases, percent escaping, UTF-8
    byte counts, emoji, stdout/route/mirror defaults, reset/append/persistence, and failure events while keeping the
    rich native trace API independent and suppressing ambient backend-specific trace configuration.
  Verification: **PASS 2026-07-10.** `linkedspec_runtime::primary_cli` now owns a backend-neutral canonical
    trace adapter separate from `linkedspec_core::trace`: exact 100/200/300/400/500 thresholds and aliases,
    portable compile/input/invoke phase records, UTF-8 byte counts, uppercase percent escaping, optional emoji,
    stdout/route/mirror sinks, default routing, reset/truncate, append/persistence, and stable failure records.
    Trace-file setup/write failures remain stable compilation failures, and quiet/none reset without emitting.
    Six focused adapter tests pass; the full runtime package passes 137 unit, 99 oracle, 190 integration, three
    source-emitter, and 10 native trace-control tests. Strict Clippy reports no touched-file diagnostic beyond the
    pre-existing runtime/core backlog, formatting passes, and all 61 unchanged neutral cases pass exactly for the
    built Rust command. Governance, mdBook, Knowledge Map, whitespace, and regenerated-cache cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.2.3 - add canonical Rust CLI trace`

- ID: `FUTURE-PARITY-BACKLOG.1.5.2.4`
  Status: `done`
  Goal: Close Rust primary-command conformance and recurring focused verification.
  Acceptance: The built Rust command passes all 61 unchanged neutral cases in default and POSIX environments;
    focused Rust tests and the broader local gate pass; the Rust primary command is wired into relevant local
    checks; task/roadmap/live docs, mdBook, Knowledge Map, help, and artifact cleanup agree before Dart `.1.5.3`.
  Verification: **PASS 2026-07-10.** Added `tools/run_rust_local.sh`: it checks formatting, runs the full Rust
    runtime package (137 unit, 99-fixture oracle, 190 integration, three source-emitter, and 10 native trace-
    control tests), builds `linkedspec-rust`, then runs all 61 unchanged primary-command cases with
    `POSIXLY_CORRECT` unset and set. `tools/run_ci_local.sh` exposes this gate through explicit
    `LINKEDSPEC_RUN_RUST=1`, preserving a toolchain-independent default like Dart/Julia. The focused Rust gate
    passes end to end. The broader default local gate passes all doctrines/syntax, 22 ActionIR checks, nine
    runner/trace checks, both Perl 61-case environments, and Phase 0 `1..1028`. Help/fixtures are unchanged;
    task/roadmap/live docs, mdBook, Knowledge Map, whitespace, and safe generated-cache cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.2.4 - close Rust primary CLI`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3`
  Status: `done`
  Goal: Replace Dart's primary corpus command with the shared parser CLI contract.
  Children: `.1.5.3.0`, `.1.5.3.1`, `.1.5.3.2`, `.1.5.3.3`, `.1.5.3.4`
  Acceptance: Dart's primary executable passes the same fixtures; corpus execution remains a separate developer
    runner and owns no primary-CLI-only semantics.
  Verification: **PASS 2026-07-10.** Children `.0`-`.4` replace only the primary process boundary, correct the
    reusable no-function staged seam, compose native direct execution/canonical JSON, add independent canonical
    trace, and wire recurring verification. Dart passes all 61 unchanged cases default/POSIX while the separate
    corpus runner remains 99/99 green.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.3.4 - close Dart primary CLI`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3.0`
  Status: `done`
  Goal: Audit and split the Dart primary-command work by observable mechanism before implementation.
  Acceptance: Inspect the primary/corpus entrypoints, parser/compiler/validation/runtime/trace APIs, source and
    input loading, canonical JSON support, ADRs `0023`-`0025`, and the unchanged 61-case manifest; record exact
    reusable seams and gaps; split recoverable implementation leaves before changing Dart behavior.
  Verification: **PASS 2026-07-10.** The current corpus-oriented primary command is measured at 0/61 unchanged
    cases. Source/API inspection confirms reusable staged parsing, validation/compilation, constructor-level global
    mode, call-level top rule, direct result value, rich trace, and canonical-JSON logic. Boundary/loading,
    execution/results/failures, trace, and closeout are separate leaves; corpus-runner behavior is preserved.
    Memory, Knowledge Map, task metadata, doctrine, whitespace, and mdBook checks pass; no Dart behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.3.0 - split Dart primary CLI work`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3.1`
  Status: `done`
  Goal: Replace the Dart primary process boundary with exact arguments, help, strict UTF-8 loading, and resolution.
  Acceptance: `dart/bin/linkedspec_dart.dart` exposes only ADR `0023`'s case-sensitive, non-abbreviating options;
    exact help/usage and exits match shared bytes; named/file/inline source plus literal/file input preparation
    obeys compile-before-input ordering, repository fallback, and ADR `0025` strict preserved UTF-8. The separate
    `dart/bin/corpus_runner.dart` retains corpus-only options and behavior.
  Verification: **PASS 2026-07-10.** The primary binary now uses an exact manual option parser and shared help,
    rejects old corpus/positional/alias surfaces, resolves named/current/repository source deterministically,
    loads raw source before deferred input with strict preserved UTF-8, keeps leading source BOM visible to phase
    policy, and emits raw stable usage/phase bytes. The reusable staged function parser now treats no definitions
    as an empty list, allowing ordinary specs through the same API. Six focused boundary tests, the staged-parser
    regression, analyzer, all 147 Dart tests, 99/99 corpus, and the exact 29-case boundary/failure subset in default
    and POSIX environments pass. The remaining 32 cases are exactly 11 results plus 21 trace cases under `.2`/`.3`.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.3.1 - add Dart CLI boundary`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3.2`
  Status: `done`
  Goal: Complete Dart primary execution, direct canonical JSON results, and stable operational failures.
  Acceptance: The adapter composes exported staged full-spec parsing, validation/compilation, and
    `LinkedSpecRuntimeEngine` execution; entry rule and global parse mode remain reusable native controls; direct
    values emit recursively key-sorted compact UTF-8 JSON plus one newline; compile/input/invoke failures and exits
    match the shared phase contract without leaking backend exceptions.
  Verification: **PASS 2026-07-10.** The adapter retains compiled state, loads input only after compilation,
    constructs `LinkedSpecRuntimeEngine` with native global mode, passes optional top rule, and serializes direct
    `RuntimeParseResult.value` through recursive map-key sorting, compact UTF-8 JSON, and one newline. Backend/JSON
    errors retain stable invocation failure. A focused nested/top/mode test and all 11 unchanged result cases pass
    in default/POSIX environments; quiet trace also passes, advancing the full baseline 29 -> 41/61. Analyzer,
    all Dart tests, 99/99 corpus, docs/KM/governance/mdBook/cleanup pass. Only 20 trace cases remain under `.3`.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.3.2 - add Dart primary execution`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3.3`
  Status: `done`
  Goal: Implement the canonical primary CLI trace projection and exact sink behavior in Dart.
  Acceptance: Dart emits ADR `0024`'s deterministic phase records, thresholds/aliases, percent escaping, UTF-8
    byte counts, emoji, stdout/route/mirror defaults, reset/append/persistence, and failure events while keeping
    its rich native trace API independent and suppressing ambient backend-specific trace configuration.
  Verification: **PASS 2026-07-10.** `primary_cli.dart` now owns an ADR `0024` adapter trace independent of
    `LinkedSpecTraceEmitter`: exact aliases/thresholds, UTF-8 byte counts, percent escaping, emoji, phase events,
    stdout/route/mirror defaults, reset/append/persistence, and traced failures. Trace setup/write errors remain
    stable compilation failures. Three focused trace tests, analyzer, full Dart suite, 99/99 corpus, and all 61
    unchanged shared cases pass in default and POSIX environments. Docs/KM/governance/mdBook/cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.3.3 - add canonical Dart CLI trace`

- ID: `FUTURE-PARITY-BACKLOG.1.5.3.4`
  Status: `done`
  Goal: Close Dart primary-command conformance and recurring focused verification.
  Acceptance: Dart passes all 61 unchanged cases in default and POSIX environments; the Dart local gate preserves
    the separate full 99-fixture corpus runner; focused/full checks pass; task/roadmap/live docs, mdBook, Knowledge
    Map, help, and artifact cleanup agree before global CLI identity `.1.5.4`.
  Verification: **PASS 2026-07-10.** `tools/run_dart_local.sh` now runs format, analyzer, all 151 Dart tests,
    primary help, bounded corpus smoke, all 61 unchanged cases in default and POSIX environments, and the full
    99/99 corpus. The focused gate passes end to end. The broader core gate passes doctrines/syntax, 22 ActionIR,
    nine runner/trace checks, both Perl 61-case legs, and Phase 0 `1..1028` in 527 seconds. Task/roadmap/live docs,
    README, mdBook, Knowledge Map, help, whitespace, and generated-artifact cleanup agree.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.3.4 - close Dart primary CLI`

- ID: `FUTURE-PARITY-BACKLOG.1.5.4`
  Status: `done`
  Goal: Close current Perl/Rust/Dart/Julia CLI parity and make the conformance matrix a recurring gate.
  Children: `.1.5.4.0`, `.1.5.4.1`, `.1.5.4.2`, `.1.5.4.3`
  Acceptance: One driver runs identical fixtures against all four implemented primary commands and proves
    normalized stdout, stderr, and exit-code identity after substituting only the executable token.
  Verification: **PASS 2026-07-10.** Julia progresses 13 -> 42 -> 61/61 through exact boundary and independent
    trace leaves. `tools/run_primary_cli_matrix.sh` then proves all four commands under both option environments
    with unchanged fixtures and explicit Julia warmup; the recurring opt-in CI hook is installed.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.4.3 - close exact primary CLI parity`

- ID: `FUTURE-PARITY-BACKLOG.1.5.4.0`
  Status: `done`
  Goal: Audit Julia against the unchanged 61-case global contract and split exact repair/driver mechanisms.
  Acceptance: Run the shared process suite after a Julia warmup; classify every residual against help/usage,
    strict UTF-8/loading/failure projection, canonical trace, or driver policy; inspect native/public seams and the
    existing nine-family checker; split recoverable leaves before Julia or global-driver code changes.
  Verification: **PASS 2026-07-10.** After Julia project/depot warmup, the unchanged suite baseline is 13/61:
    all 11 ordinary success/result cases plus `none`/`quiet` trace pass. The 48 failures partition into exact shared
    help/usage bytes; malformed-UTF-8 acceptance and backend-detail error suffixes; and rich native trace bytes in
    place of canonical trace. Existing native parse/compile/execute/canonical JSON controls remain reusable. Cold
    first-process precompile progress is Julia toolchain ambient output; the existing local checker already warms
    the project, and the final global driver must do likewise. No Julia behavior changed in this audit/split.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.4.0 - split Julia global CLI repair`

- ID: `FUTURE-PARITY-BACKLOG.1.5.4.1`
  Status: `done`
  Goal: Align Julia shared help, strict UTF-8 file loading, and stable phase-only failures.
  Acceptance: Julia renders the exact shared help/usage template for its executable token, rejects malformed UTF-8
    source/input while preserving valid text/BOM/newlines, and emits only the stable compile/input/invoke heading
    on primary stderr; rich diagnostics remain available through native APIs and native trace. Ordinary success
    behavior stays native and unchanged.
  Verification: **PASS 2026-07-10.** `_primary_cli_usage()` is byte-identical to the shared template for
    `linkedspec_julia`; `_read_primary_cli_file(...)` validates raw file bytes as UTF-8 without normalization,
    BOM, or newline conversion; primary operational stderr contains exactly one phase heading. The package passes
    1,019 assertions, the updated nine-family process checker, and 99/99 corpus fixtures. The unchanged suite
    advances 13 -> 42/61 in both default and `POSIXLY_CORRECT=1` environments; all 19 residuals are canonical-trace
    cases owned by `.2`.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.4.1 - align Julia CLI boundary`

- ID: `FUTURE-PARITY-BACKLOG.1.5.4.2`
  Status: `done`
  Goal: Replace Julia primary rich trace output with the independent canonical CLI trace projection.
  Acceptance: Julia emits ADR `0024`'s exact levels/events, UTF-8 byte counts, escaping, emoji, stdout/route/mirror,
    reset/append/persistence, and traced failures while keeping its rich native trace emitter independent; all 61
    unchanged cases pass in default and POSIX environments.
  Verification: **PASS 2026-07-10.** Julia's primary command owns an independent canonical phase recorder with
    exact named/numeric thresholds, UTF-8 byte counts, percent escaping, emoji, stdout/route/mirror defaults,
    reset/append/persistence, result framing, and compile/input/invoke failure records. The rich native emitter
    remains unchanged and directly tested. The package passes 1,019 assertions, nine real-process families and
    99/99 corpus; all 61 unchanged cases pass in default and POSIX environments.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.4.2 - add canonical Julia CLI trace`

- ID: `FUTURE-PARITY-BACKLOG.1.5.4.3`
  Status: `done`
  Goal: Add one recurring four-backend identity driver and close the exact CLI parity lane.
  Acceptance: One repo-owned command warms toolchains where required and runs the same unchanged manifest against
    Perl, built Rust, Dart, and Julia in default/POSIX environments; each focused backend gate and the broader core
    gate pass; task/roadmap/live docs, mdBook, Knowledge Map, help, fixtures, and cleanup agree before `.1.6`.
  Verification: **PASS 2026-07-10.** `tools/run_primary_cli_matrix.sh` builds Rust, prepares/warmups Dart, warms
    Julia, and passes 4 backends x 2 environments x 61 unchanged cases. It is available to the core gate through
    `LINKEDSPEC_RUN_CLI_MATRIX=1`; all backend scripts are tracked/syntax-checked CI inputs. Rust focused proof
    passes 137 unit/99 oracle/190 integration/3 emitter/10 trace plus 61x2; Dart passes format/analyzer/151 tests/
    61x2/99 corpus; Julia passes 1,019 assertions/nine process families/99 corpus. The broader gate passes
    doctrines, syntax, 22 ActionIR, nine runner/trace, Perl 61x2, and Phase 0 `1..1028` in 499 seconds. Safe cleanup
    removes 1.6 GB Rust target, 143 MB Julia depot, and 30 MB Dart cache after their results are consumed.
  Commit: `FUTURE-PARITY-BACKLOG.1.5.4.3 - close exact primary CLI parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6`
  Status: `done`
  Goal: Prove complete user-observable feature/behavior parity beyond the 99-fixture interpreter corpus.
  Children: `.1.6.0`, `.1.6.1`, `.1.6.2`, `.1.6.3`, `.1.6.4`, `.1.6.5`, `.1.6.6`
  Acceptance: Build a machine-readable capability matrix from the mdBook, exported public APIs, Phase 0, and the
    language-neutral corpus; classify Perl/Rust/Dart/Julia gaps before implementation; split every gap into an
    owned parity leaf; do not call a backend full-parity while any user-visible capability differs.
  Verification: `.0`–`.6` establish a validated 15x4 census, exhaustive 239-name/105-fixture current-language proof,
    exact outward descriptors, four-backend structured diagnostics, exact native named/file resolution, complete
    Dart full-pipeline trace, and final owner/no-drift closeout. The final matrix is 57 pass, one partial, two gaps;
    its only non-pass capability is generated parser source (Rust partial; Dart/Julia gaps), all owned by `.3`.
    Canonical core CI immediately prior passes 61x2 CLI and Phase 0 `1..1030`; recent complete backend gates remain
    adjacent and green. Non-codegen capability parity is closed without claiming complete generated-source parity.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.6 - close non-codegen capability parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.0`
  Status: `done`
  Goal: Audit and classify the complete user-observable capability surface before parity implementation.
  Acceptance: Define a machine-readable capability schema; inventory canonical mdBook behavior, exported native
    APIs, Phase 0, the 99-case interpreter corpus, exact primary CLI, trace, and generated-source boundaries;
    record evidence and current Perl/Rust/Dart/Julia status without re-deriving logged facts; validate the inventory;
    split every concrete residual mechanism into ordered owned leaves before changing backend behavior.
  Verification: **PASS 2026-07-10.** A strict checker validates 15 capability rows x four exact backends, 47 pass/
    five partial/eight gap states, every evidence path, and every residual/exclusion owner. The core gate runs the
    checker and passes 22 ActionIR, nine runner/trace, Perl 61x2, and Phase 0 `1..1028` in 496 seconds. mdBook,
    Knowledge Map, governance, whitespace, and cleanup pass; no parser/compiler/runtime behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.1.6.0 - audit backend capability parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1`
  Status: `done`
  Goal: Turn the complete current mdBook language/helper surface into neutral executable capability proof.
  Children: `.1.6.1.0`, `.1.6.1.1`, `.1.6.1.2`
  Acceptance: Map every current non-legacy language, rule, lifecycle, ActionIR, helper, method, value-kind, cursor,
    capture, function, and staged-body contract to an existing neutral fixture or add a backend-neutral fixture;
    run unchanged on Perl/Rust/Dart/Julia; split any behavioral mismatch by mechanism before repair.
  Verification: The corrected Dart/Julia inventories contain 239 current call names and match exactly. The strict
    checker proves every name appears in the mdBook and 105-case neutral corpus, and reverse-checks every current
    Perl contract call used by that corpus against both inventories. Perl generates all 105 exact values; Rust,
    Dart, and Julia execute the unchanged manifest 105/105. `language.current_mdbook_surface` is pass on all four
    backends, and the strict checker is part of the recurring local CI gate.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 - admit exhaustive capability corpus`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.0`
  Status: `done`
  Goal: Audit exhaustive current-call documentation/corpus coverage and split every observed mismatch before code.
  Acceptance: Derive the shared Dart/Julia current ActionIR call-name inventory, require exact set identity, audit
    every name against the mdBook and neutral corpus source (including canonical parser-produced markers), seed
    bounded Perl-oracle fixtures by semantic family, capture toolbox source/runtime evidence for each blocker, and
    split rather than repair every mismatch found; do not require the incomplete fixtures to join the manifest yet.
  Acceptance Checklist:
    - REPRODUCE: run the inventory auditor in report mode and execute the bounded fixture families against Perl.
    - ROOT CAUSE: use `TOOLBOX.md` probes to identify whether failures are inventory, documentation, parser,
      statement-splitting, lowering, or runtime seams rather than classifying them from fixture output alone.
    - FIX: install the reusable strict/report auditor, canonical neutral fixture sources, and exact repair/closeout
      child leaves; do not change runtime behavior in this audit slice.
    - ADDRESSED: record every discovered mismatch in a durable fact card and an owning child acceptance contract.
    - NO REGRESSION: syntax-check the auditor and run the existing focused separator locks plus governance gates.
    - LOCKSTEP: update the roadmap/task frontier, live docs, MEMORY resume pointer, mdBook limitation note, and
      generated Knowledge Map in the same commit.
  Verification: `perl -c tools/check_language_capability_coverage.pl` passes; report mode derives 237 identical
    Dart/Julia current call names, zero missing mdBook names, and 98 names absent from the 99-fixture corpus.
    Direct Perl execution passes pure-helper, position-helper, and one-line separator-explicit control fixtures;
    toolbox probes reproduce missing generated boundaries/raw targets for capture, cursor, and newline marker
    families. `PERL5LIB= prove -v -Iperl t/phase0_regression.t` passes `1..1028` in 501 seconds.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.0 - audit neutral language coverage`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.1`
  Status: `done`
  Goal: Make physical newlines universally separate ActionIR statements without requiring trailing semicolons.
  Acceptance: Root-cause and repair Perl reference splitting/lowering so consecutive ordinary helpers, assignments,
    cursor/capture calls, and `if/i`/`elseif/elif`/`else`/`endif` plus switch markers separated by physical newlines
    lower equivalently to same-line semicolon-separated statements; preserve nested strings/regexes/blocks; add
    focused source/runtime locks and unchanged Rust/Dart/Julia neutral proof before resuming coverage closeout.
  Acceptance Checklist:
    - REPRODUCE: use `call_spec_handler_subst` to lock the capture/cursor raw-target and marker-chain failures.
    - ROOT CAUSE: prove the depth-zero splitter recognizes only complete call statements, so assignment lines absorb
      their successors even though nesting/quote state already protects payload newlines.
    - FIX: consume every unquoted depth-zero LF/CRLF/CR as a boundary, including a completed line comment, without
      weakening same-line adjacency or attached-continuation rules.
    - ADDRESSED: lock assignment/cursor/marker splits and exact lowering plus cursor/control runtime execution.
    - NO REGRESSION: protect multiline parentheses, blocks, quotes, regex substitutions, comments, CRLF, and the
      unchanged 99-fixture Perl/Rust/Dart/Julia corpus.
    - LOCKSTEP: remove the mdBook limitation, resolve the Knowledge Map gap, update live docs/frontier, and clean
      every generated backend cache after verification.
  Verification: toolbox lowering now emits independent `$` targets and generated Perl terminators for capture and
    cursor sequences, and fully lowers newline if/switch marker chains. The new 17-assertion Phase 0 subtest covers universal
    LF/CRLF/CR boundaries, nesting/quote/regex/comment protection, exact lowering, and cursor/control runtime;
    `PERL5LIB= prove -v -Iperl t/phase0_regression.t` passes `1..1029` in 490 wall-clock seconds. Perl regeneration produces
    the unchanged 99 fixtures; Rust, Dart, and Julia each pass 99/99. Four stale empty corpus artifact directories
    were removed after their manifest-guard failure; 1.4 GB Rust, 86 MB Julia, and 20 KB Dart caches were removed
    after all results were consumed.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.1 - enforce universal newline separators`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2`
  Status: `done`
  Goal: Complete and run exhaustive current-call neutral coverage after newline separator repair.
  Children: `.1.6.1.2.0`, `.1.6.1.2.1`, `.1.6.1.2.2`
  Acceptance: Finish bounded pure/position/capture/mark/cursor/control fixtures, make the coverage checker require
    every current Dart/Julia ActionIR name in the mdBook and generated neutral corpus, regenerate Perl oracle bytes,
    run the unchanged corpus on Perl/Rust/Dart/Julia, split any residual behavioral mismatch, and close parent
    `.1.6.1` only when `language.current_mdbook_surface` can move from partial to pass.
  Verification: Universal newline separation, contract-aware switch closure, all exact-value repair children,
    reconciled call inventories, and final 105-case admission are complete on all four implemented backends.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 - admit exhaustive capability corpus`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.0`
  Status: `done`
  Goal: Correct capture fixture timing and split the residual newline control-close terminator mismatch before code.
  Acceptance Checklist:
    - REPRODUCE: execute all six seeded fixtures after the splitter repair and inspect any failure with toolbox APIs.
    - ROOT CAUSE: distinguish fixture action timing from canonical lowering and isolate invalid generated Perl after
      a newline-separated `endswitch()` followed by another statement.
    - FIX: define separate repair and final-coverage leaves; make no compiler/runtime change in this audit slice.
    - ADDRESSED: route control-close termination to `.2.1` and corrected fixture/oracle admission to `.2.2`.
    - NO REGRESSION: preserve the committed 99-case corpus and green `.1.6.1.1` Phase 0 boundary.
    - LOCKSTEP: record the temporary mdBook qualification, fact card, task frontier, and live resume pointer.
  Verification: corrected in-memory capture probes using `Top::AND => Value`, three regex slots, and action indexes
    `0`/`2` return exact anonymous/named hashes. The multiline combined control fixture compiles to invalid Perl:
    `call_spec_handler_subst` emits the closing switch `} }` followed directly by `return [...]`; the earlier
    `if/endif` block followed by assignment is valid. Source inspection maps this to the generic leading-`}`
    terminator suppression in `RewritePipeline::_lowered_statement_needs_terminator`.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.0 - split control-close terminator residual`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.1`
  Status: `done`
  Goal: Insert the implicit newline terminator after switch-control closure without weakening block continuations.
  Acceptance: Make newline-separated `endswitch()` followed by any ordinary statement lower equivalently to the
    semicolon-separated same-line form; key the terminator decision to the actual control contract/lowered shape so
    `if`/`elseif`/`else`, `while`, attached continuations, and nested block payloads remain valid; add focused source
    and runtime locks plus Phase 0 before returning to coverage.
  Verification: `RewritePipeline` now records `contract_id` with each pending lowered statement and requires a
    generated terminator specifically for newline-separated `endswitch_flow` before generic leading-`}` block
    suppression. Five focused assertions lock exact `};\nreturn`, absence of the invalid adjacency, unchanged
    `endif` closure output, successful multiline compilation, and runtime `["elif","case-b"]`.
    `perl -c perl/LinkedSpec.pm` and `perl -c -Iperl t/phase0_regression.t` pass;
    `PERL5LIB= prove -v -Iperl t/phase0_regression.t` passes `1..1030` in 491 wall-clock seconds.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.1 - terminate newline switch closure`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2`
  Status: `done`
  Goal: Correct fixture timing, admit exhaustive current-call families, and close strict four-backend proof.
  Children: `.1.6.1.2.2.0`, `.1.6.1.2.2.1`, `.1.6.1.2.2.2`, `.1.6.1.2.2.3`,
    `.1.6.1.2.2.4`, `.1.6.1.2.2.5`
  Acceptance: Apply the proven three-slot capture/mark timing, use newline-only control source, register all six
    source fixtures in oracle generation, regenerate exact Perl values, reconcile the provisional 237-name inventory
    against the current Perl registry and make strict corrected-name coverage pass, run the
    expanded corpus unchanged on Perl/Rust/Dart/Julia, update `language.current_mdbook_surface`, and close `.1.6.1`.
  Verification: Corrected pure, position, marker-control, and capture/mark fixtures match exactly on every
    backend. Final admission reconciles the two omitted bridge helpers, generates all 105 reference values, passes
    strict 239-name coverage, and runs 105/105 on Perl, Rust, Dart, and Julia.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 - admit exhaustive capability corpus`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.0`
  Status: `done`
  Goal: Execute the corrected exhaustive fixtures, root-cause the advertised-call/runtime gap, and split repair.
  Acceptance Checklist:
    - REPRODUCE: run all six corrected fixture families directly on Perl and diagnostically in a generated 105-case
      corpus on Rust, Dart, and Julia.
    - ROOT CAUSE: distinguish call-name inventory coverage from executable semantics and classify every mismatch
      by value, position, control, or capture/mark mechanism.
    - FIX: define backend-specific children for each mechanism before changing backend code.
    - ADDRESSED: retain corrected governed sources and reusable repo-relative `source_file` generator support while
      keeping the mandatory manifest at the last green 99-case boundary.
    - NO REGRESSION: prove the original 99 cases still pass on every backend during the diagnostic 105-case run.
    - LOCKSTEP: update task/live/book/Knowledge Map surfaces with exact counts and owners.
  Verification: Perl produces exact values for all six fixtures and regenerates 105/105. Strict source-name
    coverage reaches 237/237. Rust, Dart, and Julia each pass the original 99 plus cursor control and fail the same
    five new families (100/105), with backend-specific details: common pure-value mismatch; empty local-match
    projection mismatch; Rust missing `i`/`elif` while Dart/Julia select marker default after a matching case; and
    incomplete capture/mark helper execution on all three. The diagnostic six directories and manifest entries
    were removed after evidence capture so the mandatory corpus stays green at 99 until repair closes.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.0 - split executable capability residuals`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1`
  Status: `done`
  Goal: Align exhaustive pure/aggregate helper values with the Perl reference.
  Children: `.1.6.1.2.2.1.1`, `.1.6.1.2.2.1.2`, `.1.6.1.2.2.1.3`
  Acceptance: Close exact predicate/comparison `1`/`0`, direct-literal `flat` splicing, and statement-form
    `uppercase_each` mutation without weakening typed literal booleans or value-form array transformations.
  Verification: Perl, Rust, Dart, and Julia now return the same governed exact hash. Each non-reference backend
    preserves typed booleans and pure value/receiver transforms while projecting the historical predicate family
    as numeric `1`/`0`, splicing explicit direct-literal `flat`, and mutating explicit working-array transforms
    only in statement context. Recorded backend-focused suites and unchanged 99-case corpora pass.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.3 - align Julia pure helper values`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1`
  Status: `done`
  Goal: Align Rust pure/aggregate helper value semantics.
  Acceptance: The pure fixture returns the exact Perl hash; focused Rust locks distinguish numeric predicate results,
    direct-literal flat splicing, and mutation-vs-value `uppercase_each`; existing 99-case corpus remains green.
  Verification: Rust now returns numeric `1`/`0` for the fixture's string/array/hash/numeric predicates while
    preserving typed literal booleans; direct array literals splice explicit `flat` calls; standalone
    `trim_each`/`lowercase_each`/`uppercase_each(array(name))` mutate the named working array while value/receiver
    forms remain pure. The governed exact-value integration lock passes. Stale internal helper-result expectations
    were aligned without changing string-comparison or literal-boolean expectations. `cargo fmt --all -- --check`,
    focused fixture, full 191-test integration, and unchanged 99-case oracle (three harness tests) pass.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1 - align Rust pure helper values`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.2`
  Status: `done`
  Goal: Align Dart pure/aggregate helper value semantics under the same exact fixture.
  Acceptance: Match the repaired Rust/Perl value without backend-specific source or CLI behavior.
  Verification: Dart now returns numeric `1`/`0` for the fixture's string/array/hash/numeric predicates while
    preserving typed literal booleans; direct array literals splice explicit `flat` calls; standalone
    `trim_each`/`lowercase_each`/`uppercase_each(array(name))` mutate the named working array while value/receiver
    forms remain pure. The governed exact-value runtime lock passes. Twelve stale serialized fields across four
    existing helper tests were aligned without changing regex-match, string-comparison, definedness, or
    literal-boolean results.
    `dart format`, fatal analyzer, all 152 package tests, both 61-case CLI environments, and the unchanged 99-case
    corpus pass through `tools/run_dart_local.sh`.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.2 - align Dart pure helper values`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.3`
  Status: `done`
  Goal: Align Julia pure/aggregate helper value semantics under the same exact fixture.
  Acceptance: Match the repaired Rust/Perl/Dart value without backend-specific source or CLI behavior and close `.1`.
  Verification: Julia now returns numeric `1`/`0` for the fixture's string/array/hash/numeric predicates while
    preserving typed literal booleans; direct array literals reuse explicit array-splice classification; standalone
    `trim_each`/`lowercase_each`/`uppercase_each(array(name))` mutate the named working array while value/receiver
    forms remain pure. The governed exact source lock passes. Twelve stale serialized fields across four existing
    helper tests were aligned without changing regex-match, string-comparison, definedness, logical, or literal
    boolean results. The offline package entrypoint passes 1,020 assertions, both shared 61-case CLI environments
    pass, and the unchanged corpus passes 99/99.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.3 - align Julia pure helper values`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2`
  Status: `done`
  Goal: Align empty local-match position projection on Rust, Dart, and Julia.
  Children: `.1.6.1.2.2.2.1`, `.1.6.1.2.2.2.2`, `.1.6.1.2.2.2.3`
  Acceptance: Match Perl's exact null capture/length/position plus empty-map/list/has and 1-based line/column defaults
    after entry match without inventing a local match; close one backend per committed child.
  Verification: Rust, Dart, and Julia now return the exact Perl position fixture value and independently preserve
    a real zero-width match at offset zero. Each backend projects absent local capture/length/position as null,
    containers as empty, named presence as numeric `0`, and diagnostic line/column defaults as 1. The unchanged
    99-case corpus remains green on every backend.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3 - align Julia empty-match positions`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.1`
  Status: `done`
  Goal: Align Rust empty local-match position projection.
  Acceptance: Exact position fixture value and existing corpus pass.
  Verification: Explicit entry/local presence bits now travel with every saved rule match frame, so initialized
    zero offsets no longer invent a local match and a real zero-width match at offset zero remains present. With no
    local match, text/group/length/start/end positions are `undef`; group/map containers are empty; `match_has` is
    numeric `0`; line/column defaults remain 1. Entry/local named-presence helpers return numeric `1`/`0`. The
    exact governed fixture and an independent zero-width regression pass. `cargo fmt --all -- --check`, 137
    library tests, 193 integration tests, and the unchanged 99-case oracle (three harness tests) pass. Strict
    no-dependency clippy was attempted but remains red on 12 pre-existing unrelated lints; none names changed lines.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.1 - align Rust empty-match positions`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.2`
  Status: `done`
  Goal: Align Dart empty local-match position projection.
  Acceptance: Exact position fixture value and existing corpus pass.
  Verification: Dart's nullable `RuntimeRegexMatch` already distinguishes absence from a real zero-width match,
    so helper projection now preserves that state: absent capture/length/start/end values are `null`, group/map
    containers are empty, `match_has` is numeric `0`, and line/column diagnostics default to 1. Entry/local
    named-presence helpers return numeric `1`/`0`. The exact governed fixture and an independent zero-width-at-zero
    regression pass. `tools/run_dart_local.sh` passes formatting, fatal analysis, all 154 package tests, both
    61-case CLI environments, and the unchanged 99-case corpus.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.2 - align Dart empty-match positions`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3`
  Status: `done`
  Goal: Align Julia empty local-match position projection and close `.2`.
  Acceptance: Exact position fixture value and existing corpus pass.
  Verification: Julia's nullable `RuntimeMatchRegisters.local_match` already distinguishes absence from a real
    zero-width match, so helper projection now returns numeric named presence and 1-based line/column defaults
    without changing null capture/length/start/end or empty group/map values. The governed exact fixture and an
    independent zero-width-at-zero regression pass. The offline package suite passes 1,022 assertions, both shared
    61-case CLI environments pass, and the unchanged corpus passes 99/99. The disposable 122 MB verification depot
    was removed after its result was consumed.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3 - align Julia empty-match positions`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3`
  Status: `done`
  Goal: Align marker aliases and matched-case/default control semantics.
  Children: `.1.6.1.2.2.3.1`, `.1.6.1.2.2.3.2`, `.1.6.1.2.2.3.3`
  Acceptance: Newline `i`/`elif` executes like `if`/`elseif`; a matching case excludes default; end markers preserve
    exact control boundaries; close one backend per committed child.
  Verification: Rust, Dart, and Julia return exact `["elif","case-b"]`: short aliases execute as canonical
    if/elseif controls and a matched switch case excludes default. The unchanged 99-case corpus remains green on
    every backend.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3 - align Julia marker control`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1`
  Status: `done`
  Goal: Align Rust marker aliases/control fixture.
  Acceptance: Remove unknown `i`/`elif` diagnostics and return `["elif","case-b"]` without regressing switch.
  Verification: Rust's known-call registry and statement-if gate now recognize `i` as `if` and `elif` as
    `elseif`; existing switch frames already suppress `default` after a matched case. The exact governed fixture
    returns `["elif","case-b"]`. `tools/run_rust_local.sh` passes formatting, 137 library tests, the unchanged
    99-case oracle, 194 integration tests, three source-emitter tests, ten trace tests, and both 61-case CLI
    environments. The 1.6 GB reproducible target directory was removed after verification.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1 - align Rust marker control`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2`
  Status: `done`
  Goal: Align Dart marker switch selection.
  Acceptance: Preserve alias behavior and exclude default after matching case; exact control fixture passes.
  Verification: Dart now groups marker-form `switch`/`case`/`default`/`endcase`/`endswitch` statements into one
    selectable chain in both action and value blocks. It evaluates the subject once, executes only the first
    matching case or otherwise default, and handles nested marker switches. Existing typed `i`/`elif` alias
    normalization is unchanged. The governed fixture returns `["elif","case-b"]`; formatting, fatal analysis,
    all 155 package tests, both 61-case CLI environments, and the unchanged 99-case corpus pass.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2 - align Dart marker control`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3`
  Status: `done`
  Goal: Align Julia marker switch selection and close `.3`.
  Acceptance: Preserve alias behavior and exclude default after matching case; exact control fixture passes.
  Verification: Julia groups marker-form switch siblings into one nesting-aware selectable chain in action and
    value blocks, evaluates the subject once, and executes only the first matching case or otherwise default.
    Existing typed `i`/`elif` normalization remains unchanged. The governed fixture returns `["elif","case-b"]`;
    the offline package suite passes 1,023 assertions, both shared 61-case CLI environments pass, and the unchanged
    corpus passes 99/99. The disposable 122 MB depot was removed after verification.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3 - align Julia marker control`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4`
  Status: `done`
  Goal: Complete anonymous/named capture-mark executable semantics.
  Children: `.1.6.1.2.2.4.1`, `.1.6.1.2.2.4.2`, `.1.6.1.2.2.4.3`
  Acceptance: Exact anonymous and named hashes pass, including stable/advancing reads, bridge/reset, mark metadata,
    input boundary marks, copied marks, and two-mark advancing reads; close one backend per committed child.
  Verification: Rust, Dart, and Julia now return both exact governed capture hashes. Each preserves symbolic bare
    mark names, rule-local named anchors, character-based public positions/lengths over host-safe internal
    offsets, stable and advancing anonymous/named reads, bridge/reset helpers, input-boundary/copy marks, and
    two-mark reads. Non-repeated `AND` blind-call wrappers retain ordered child values unless explicitly
    overridden. Each backend's recurring package, CLI, and unchanged 99-case corpus gate passes.
  Commit: completed by children `.4.1` through `.4.3`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1`
  Status: `done`
  Goal: Complete Rust capture/mark fixture semantics.
  Acceptance: Both exact fixture hashes pass with no unknown-helper warning and existing corpus remains green.
  Verification: Rust now preserves bare mark identifiers symbolically, implements the missing anonymous/named
    bridge, column, copied-slice, and two-mark advancing helpers, and projects `mark_exists` as numeric `1`/`0`.
    The governed anonymous and named hashes match Perl exactly. The capture sources also exposed and closed Rust's
    non-repeated `AND` blind-call default-result gap in both interpreted and generated-plan execution: absent an
    explicit parent return, the parent surfaces the ordered child-return array. `tools/run_rust_local.sh` passes
    formatting, 137 library tests, the unchanged 99-case oracle, 196 integration tests, three source-emitter
    tests, ten trace tests, and both 61-case CLI environments.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1 - complete Rust capture marks`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2`
  Status: `done`
  Goal: Complete Dart capture/mark fixture semantics.
  Acceptance: Both exact fixture hashes pass with no unsupported-helper failure and existing corpus remains green.
  Verification: Dart now owns a rule-local code-unit named-mark store with character-based public positions and lengths,
    executes all stable/advancing anonymous and named reads, preserves bare symbolic mark names, bridges the
    anonymous start to/from named marks, and implements input-boundary/copy/two-mark operations. Non-repeated
    `AND` blind-call parents surface ordered child returns unless explicitly overridden. Both governed hashes plus
    independent implicit-result and rule-local-mark locks pass. `tools/run_dart_local.sh` passes formatting, fatal
    analysis, all 160
    package tests, both 61-case CLI environments, and the unchanged 99-case corpus. The reproducible 30 MB Dart
    cache was removed after verification.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2 - complete Dart capture marks`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3`
  Status: `done`
  Goal: Complete Julia capture/mark fixture semantics and close `.4`.
  Acceptance: Both exact fixture hashes pass with no unsupported-helper failure and existing corpus remains green.
  Verification: Julia now stores named marks as rule-local input code-unit offsets and exposes character-based
    positions and captured lengths. It executes the full governed stable/advancing anonymous and named families,
    anonymous/named bridge operations, current/input-boundary/copied marks, and two-mark reads while preserving
    bare symbolic mark names. Non-repeated `AND` blind-call parents surface ordered child returns unless an
    explicit return overrides them. Both exact governed hashes plus independent implicit-result, rule-local-mark,
    and multibyte locks pass. `tools/run_julia_local.sh` passes 1,028 package assertions, primary CLI conformance,
    and the unchanged 99/99 corpus. The disposable 70 MB depot was removed after verification; `.4` closes.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3 - complete Julia capture marks`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5`
  Status: `done`
  Goal: Admit all six fixtures and close strict current-call proof.
  Acceptance: Register governed `source_file` cases, regenerate 105 exact values, pass strict reconciled-name
    coverage (the earlier 237-name count is provisional),
    run 105/105 unchanged on Perl/Rust/Dart/Julia, promote all four `language.current_mdbook_surface` states to
    pass, close `.1.6.1.2`/`.1.6.1`, and advance to `.1.6.2`. Before claiming the strict count, reconcile the
    governed capture sources against the shared current-call inventories: `start_capture_slice_from` and
    `mark_capture_slice` are current Perl contracts used by those sources but are absent from the aligned
    Dart/Julia 237-name sets, so the final count is provisional until that omission is corrected atomically.
  Verification: `mark_capture_slice` and `start_capture_slice_from` now belong to both Dart and Julia known-call
    and capture-family tables, raising the exact shared inventory from provisional 237 to corrected 239. The
    coverage checker now also derives current non-compatibility Perl contract names and rejects any such neutral
    corpus call absent from both backend inventories. All six governed `source_file` cases are byte-identical in
    the generated corpus; Perl regenerates 105 exact values and strict coverage reports 239 names/105 fixtures,
    zero book gaps, zero corpus gaps, and zero missing Perl contract calls. Recurring gates pass: Rust 137 library,
    105 oracle, 196 integration, three emitter, ten trace, and 61x2 CLI; Dart formatting/analyzer, 160 tests,
    61x2 CLI, and 105 corpus; Julia 1,036 assertions, primary CLI, and 105 corpus. The strengthened core gate passes
    22 ActionIR tests, nine CLI/trace tests, Perl 61x2, and Phase 0 `1..1030` in 490 seconds. The local gate now
    runs strict language coverage permanently. Generated 1.6 GB Rust, 30 MB Dart, and 122 MB Julia caches were
    removed after verification.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 - admit exhaustive capability corpus`

- ID: `FUTURE-PARITY-BACKLOG.1.6.2`
  Status: `done`
  Goal: Add Rust's backend-neutral outward compiled-descriptor projection.
  Children: `.1.6.2.0`, `.1.6.2.1`, `.1.6.2.2`, `.1.6.2.3`
  Acceptance: Rust exposes the documented `spec`, `functions`, `dependency_regex_map`, and `meta` projection with
    stable field meanings/order and staged function metadata equivalent to Perl/Dart/Julia; focused neutral shape
    fixtures prove idiomatic Rust types/JSON without coupling callers to engine internals.
  Verification: The canonical descriptor contract is consumed by focused tests in all four variants. Exact outer
    function fields, metadata identities/order, rule/dependency semantics, and staged function values pass; the
    complete relevant backend gates pass and the capability state is promoted to pass.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.2.3 - admit exact descriptor parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.2.0`
  Status: `done`
  Goal: Audit the outward descriptor contract and split implementation without copying an existing drift.
  Acceptance: Use the Perl `return_descriptor` toolbox probe plus Rust/Dart/Julia source and focused tests to
    identify the canonical public shape, record any cross-variant mismatch durably, and split bounded repair,
    Rust-projection, and final-admission leaves before production changes.
  Verification: The reference probe returns exactly `spec`, `functions`, `dependency_regex_map`, and `meta`, but
    exposes `meta.descriptor_model = compiled_spec_state_v1`; `CompilerState.pm` proves the actual composing owner
    is `kind = compiled_descriptor_state`. The mdBook plus Dart and Julia instead expose the semantically correct
    wrapper identity `compiled_descriptor_state`; Phase 0 contains two explicit locks for the stale Perl tag. Rust
    has no descriptor projection, explicit dependency-ref state, or descriptor-focused tests. The implementation
    is split into public metadata reconciliation `.1`, Rust projection `.2`, and four-backend admission `.3`.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.2.0 - split outward descriptor parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.2.1`
  Status: `done`
  Goal: Reconcile the canonical outward descriptor-model identity before adding Rust.
  Acceptance: Perl reports the documented composing descriptor-state identity and explicit nested model identities
    without changing rule/function/dependency payloads, parser behavior, or Dart/Julia values; focused descriptor
    locks, Phase 0, mdBook, census, and Knowledge Map agree.
  Verification: `compiled_spec_state_meta(...)` now reports `descriptor_model = compiled_descriptor_state` and
    explicit `compiled_spec_model = compiled_spec_state` / `compiled_dependency_regex_model =
    compiled_dependency_regex_state`. The focused `return_descriptor` probe preserves exactly the four top-level
    keys and verifies all three identities. Both former Phase 0 stale-tag locks now assert the composing identity
    plus nested models; the complete Phase 0 suite passes `1..1030` in 509 seconds. Dart/Julia already expose the
    same three values and were not changed.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.2.1 - reconcile descriptor model identity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.2.2`
  Status: `done`
  Goal: Add an idiomatic Rust outward descriptor projection over existing compiled state.
  Acceptance: Public Rust APIs project deterministic `spec`, `functions`, `dependency_regex_map`, and `meta`
    values, including rule dependency refs and preserved staged function metadata, without coupling callers to the
    runtime engine or changing execution/serialization compatibility; focused shape/round-trip tests pass.
  Verification: `linkedspec-core::descriptor` exports typed serializable descriptor, rule, dependency-regex,
    function, mode, handler, and metadata records. `CompiledSpec::descriptor_state()` and
    `to_descriptor_json()` project the four public keys without a runtime-engine dependency. Compilation now
    preserves ordered `DependencyRef` values on `CompiledRule`; old serialized state remains readable through the
    default plus dispatch-derived fallback. Three focused tests prove exact shape/staged metadata, compiled-state
    JSON round-trip identity, and deterministic last-definition projection. The full core package passes. The full
    Rust gate passes formatting, 137 runtime, 105 oracle, 196 integration, three generated-source, ten trace, and
    61x2 CLI cases. Strict clippy reports only 14 pre-existing errors in untouched files and none in this leaf.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.2.2 - expose Rust compiled descriptors`

- ID: `FUTURE-PARITY-BACKLOG.1.6.2.3`
  Status: `done`
  Goal: Admit and close four-backend outward descriptor parity.
  Acceptance: Focused neutral shape evidence proves the documented top-level keys, metadata identities/order,
    rule/dependency semantics, and staged function fields across Perl/Rust/Dart/Julia; update the census from
    partial/gap to pass, synchronize public/live docs, run recurring gates, and advance to `.1.6.3`.
    The final comparison must also resolve the outer function-record convention exposed by `.2`: Perl uses
    `kind`/`version`/`source_text` without `index`, Dart/Julia use `index`/`source` without `kind`/`version`, and
    Rust currently publishes the neutral-definition identity plus `index`. Nested `body_payload`,
    `body_parse_job`, and `body_ast` semantics are already aligned.
  Verification: `capability_conformance/outward_descriptor_contract.json` defines the exact four top-level keys,
    required model/order metadata, and canonical outer function record: `index`, `kind`, `version`, `name`,
    `params`, `arity`, `source_text`, source/body spans and source, plus `body_payload`, `body_parse_job`, and
    `body_ast`. Perl adds the source-order index; Dart and Julia use descriptor-specific projections that add the
    neutral identity/source fields without changing their internal AST serialization; Rust already matches the
    convention. Focused contract tests pass on all four variants. Complete Dart passes formatting, analysis, 160
    tests, 61x2 CLI, and 105 corpus cases; Julia passes 1,040 assertions, its primary CLI process suite, and 105
    corpus cases; Rust's focused three tests pass after the prior full Rust gate; complete Perl Phase 0 passes
    `1..1030` in 775 wallclock seconds. The capability census is 52 pass / one partial / seven gap.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.2.3 - admit exact descriptor parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.3`
  Status: `done`
  Goal: Add structured Rust runtime diagnostic context equivalent to the other native backends.
  Children: `.1.6.3.0`, `.1.6.3.1`, `.1.6.3.2`
  Acceptance: Native Rust runtime failures expose stable type/stage/summary/detail plus available spec/top/rule/
    handler attribution as structured data rather than requiring string scraping; ordinary `Result` ergonomics,
    CLI phase projection, trace behavior, and successful results remain compatible.
  Verification: Typed/JSON diagnostic implementation, exact focused evidence, complete runtime package, complete
    recurring Rust gate, and both CLI environments pass. Existing success/string/trace/CLI behavior stays exact;
    the capability row is pass for all four variants.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.3.2 - admit Rust runtime diagnostics`

- ID: `FUTURE-PARITY-BACKLOG.1.6.3.0`
  Status: `done`
  Goal: Audit the real Rust runtime failure boundary and split implementation before behavior code.
  Acceptance: Knowledge Map and source/toolbox evidence identify the public execution result types, error
    propagation/unwind seam, source-identity availability, CLI adapter boundary, and every compatibility surface;
    record any mismatch in prior durable wording and create bounded implementation/admission owners.
  Verification: `rust/linkedspec-runtime::Engine` public execution methods and all internal runtime frames return
    `Result<_, String>`. The similarly named core `LinkedSpecError::Runtime(String)` is unused by the runtime crate,
    so the mdBook/census wording pointed at the wrong type. `execute_rule(...)` is the singular interpreted rule
    wrapper and observes a child error before its own frame unwinds, but `RuntimeContext` stores neither top/rule
    identity nor a last diagnostic. `Engine` stores only `CompiledSpec`; the primary CLI deliberately collapses
    any execution failure to its canonical `invoke:error` / `parser invocation failed` projection. `.1` owns typed
    records, source identity, diagnostic-aware native execution, and compatibility adapters; `.2` owns full
    no-drift proof, public docs, census promotion, and parent closeout.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.3.0 - split Rust runtime diagnostics`

- ID: `FUTURE-PARITY-BACKLOG.1.6.3.1`
  Status: `done`
  Goal: Add typed structured diagnostics to Rust native interpreted execution.
  Acceptance: Export serializable neutral diagnostic/error records; let callers optionally attach spec identity;
    expose diagnostic-aware accumulator/direct-value methods; preserve a failing child rule before unwind; keep
    existing string-returning methods, successful values, trace methods, and primary CLI behavior compatible.
  Verification: `linkedspec-runtime::diagnostic` exports serializable `RuntimeDiagnostic` and compact
    `RuntimeExecutionError`. `Engine` accepts optional spec name/path and exposes `execute_with_diagnostics(...)`
    plus `execute_value_with_diagnostics(...)`; existing string methods delegate through the typed path and recover
    the original message. `RuntimeContext` retains first/deepest failure context, and interpreted `execute_rule`
    captures it before variable/recursion unwind. Five focused tests prove exact JSON/source identity, deepest
    child rule, missing-entry `rule_lookup`, unavailable-field omission/top selection, success equality, and string
    compatibility. The complete runtime package passes 137 unit, 105 oracle, 196 integration, five diagnostic,
    three generated-source, and ten trace tests. Strict Clippy initially found two new large-error findings; boxing
    the nested diagnostic removes both, leaving exactly 14 pre-existing errors in untouched runtime/core files.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.3.1 - add Rust runtime diagnostics`

- ID: `FUTURE-PARITY-BACKLOG.1.6.3.2`
  Status: `done`
  Goal: Admit and close structured Rust runtime diagnostic parity.
  Acceptance: Focused error-shape/source/top/child-rule/success/string-compatibility tests and complete Rust/CLI
    gates pass; mdBook/live docs/capability census agree; promote the Rust state to pass and advance to `.1.6.4`.
  Verification: `tools/run_rust_local.sh` passes formatting, 137 unit, 105 oracle, 196 integration, five focused
    diagnostic, three generated-source, and ten trace tests, then exact 61/61 primary CLI conformance under both
    default and POSIX option environments. The capability checker promotes structured runtime diagnostics to pass
    and reports 53 pass / one partial / six gap. Generated Rust artifacts (2.0 GB) are removed after verification.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.3.2 - admit Rust runtime diagnostics`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4`
  Status: `done`
  Goal: Add and exactly admit idiomatic native named/file spec resolution across all four current backends.
  Children: `.1.6.4.0`, `.1.6.4.1`, `.1.6.4.2`, `.1.6.4.3`, `.1.6.4.4`, `.1.6.4.5`
  Acceptance: Each library exposes the book's portable file-oriented role with deterministic explicit-path and
    named-spec resolution/search precedence, strict text loading, parse/compile composition, and structured errors;
    shared path fixtures prove equivalent behavior without requiring the primary CLI or a subprocess. Perl's
    legacy `get_parser` compatibility discovery remains separately available.
  Verification: ADR `0026` and its 14/9/4 fixture are consumed directly by Perl, Rust, Dart, and Julia native
    libraries. Each exposes separate portable name/exact-path intent, ordered direct roots, first-regular-file
    resolution, strict preserved UTF-8, retained source identity, progressive composition, structured stages/codes,
    and a backend-native compiled value. The final Perl facade leaves legacy `get_parser`/`PathSearch` untouched.
    Prior committed Rust/Dart/Julia complete recurring and 61x2 CLI gates remain green; final admission adds Perl
    direct proof to the canonical gate, which passes 239-name coverage, focused suites, 61x2 Perl CLI, and Phase 0
    `1..1030` in 556 seconds. Capability state remains 56/1/3 because this row was already promoted backend by
    backend; the parent is now exactly admitted.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.5 - admit native spec resolution parity`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4.0`
  Status: `done`
  Goal: Audit the real four-backend resolution mechanisms and split implementation before behavior code.
  Acceptance: Source/tests establish validation, candidate precedence, fallback discovery, file-kind checks,
    strict-decoding ownership, parse/compile composition, and error seams; any process/native or cross-variant
    drift is durable; bounded neutral-contract, backend, and admission owners exist before implementation.
  Verification: Perl `LinkedSpec::Resolver` checks exact cwd, cwd `<name>.spec`, and module-root `specs/` before
    delegating a bare miss to `PathSearch`; that legacy fallback recursively caches cwd plus the repository tree,
    deduplicates through a hash, and selects the first hash-key match, so duplicate-name precedence is not
    deterministic or portable. Rust and Dart primary adapters stop after the first three candidates; Julia alone
    adds a sorted/pruned recursive repository fallback. All three non-Perl mechanisms are process-adapter-only.
    Rust/Julia require regular files and all three adapters decode strictly as UTF-8; Dart resolution currently
    tests existence before its later file read. `.1` owns one explicit ordered-root contract and fixture; `.2`,
    `.3`, and `.4` own Rust, Dart, and Julia native APIs; `.5` owns exact four-backend admission and CLI no-drift.
    No parser/compiler/runtime behavior changed.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.0 - split native spec resolution`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4.1`
  Status: `done`
  Goal: Define the executable backend-neutral named/file resolution contract.
  Acceptance: A checked-in schema/fixture defines name validation, explicit-path handling, deterministic candidate
    order over explicit ordered search roots, regular-file requirements, strict preserved UTF-8, source identity,
    parse/compile phase order, and structured failure stages; Perl's implicit recursive `PathSearch` remains a
    compatibility extension outside this portable API rather than silently defining duplicate-name precedence.
  Verification: ADR `0026` fixes separate named/path requests, portable traversal-safe names, cwd/suffix/declared-
    root candidate order, direct non-recursive roots, first-regular-file selection, strict preserved UTF-8, exact
    source identity, pipeline order, and neutral typed error stages/codes. The original JSON contained 13 name,
    nine resolution/file-kind, and four text cases. Its independent Perl checker validates schema, task ownership,
    declared semantics, every expected outcome, Unicode/BOM/normalization preservation, malformed UTF-8, and no
    UTF-16 autodetection. The checker is wired into the canonical local gate. The complete gate passes the checker,
    239-name coverage, focused suites, exact Perl CLI 61/61 under default and POSIX environments, and Phase 0
    `1..1030` in 502 wallclock seconds. No backend behavior changed.
    Rust implementation `.2` subsequently adds the missing Windows-drive absolute-name rejection case, bringing
    the same versioned fixture to 14 name cases without changing the ratified policy.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.1 - define native spec resolution contract`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4.2`
  Status: `done`
  Goal: Add Rust native named/file resolution and compilation.
  Acceptance: Public typed Rust APIs consume the neutral fixture without CLI/subprocess ownership, compose strict
    loading through parse/validate/compile, retain requested/resolved source identity, return structured errors,
    and let the primary CLI delegate without changing its exact contract.
  Verification: Public `spec_loader` exports typed name/path requests, cwd plus ordered direct roots, deterministic
    resolution origins, regular-file selection, strict byte read/UTF-8 decode, loaded/compiled source identity,
    serializable stage/code errors, and `LoadedCompiledSpec::into_engine()` attribution. It composes the full staged
    user-function parser, core validation, and compiler. Rust consumes all 14 name, nine resolution/file-kind, and
    four text cases directly; five focused tests also prove full function execution, parse/validation failures, and
    exact error JSON. The primary CLI delegates named/file requests to the native API while inline behavior stays
    unchanged. Full Rust gate passes 137 unit, 105 oracle, 196 integration, five runtime diagnostic, three generated-
    source, five loader, ten trace, and 61x2 CLI cases. Strict Clippy finds no new loader/CLI issue and stops on the
    same 14 pre-existing untouched runtime findings. The Rust capability state is pass; census is 54/1/5.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.2 - add Rust native spec resolution`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4.3`
  Status: `done`
  Goal: Add Dart native named/file resolution and compilation.
  Acceptance: Public typed Dart APIs consume the neutral fixture without CLI/subprocess ownership, require regular
    files, compose strict loading through parse/compile, retain source identity, return structured exceptions, and
    let the primary CLI delegate without changing its exact contract.
  Verification: Public `src/io/spec_loader.dart`, re-exported from `linkedspec_dart.dart`, provides typed name/path
    requests, cwd plus ordered direct roots, deterministic candidate origins, regular-file selection, strict
    preserved UTF-8 loading, exact source identity, progressive resolve/load/compile results, neutral structured
    exceptions, and `LoadedCompiledSpec.createEngine()` attribution. The full composition uses the staged user-
    function parser, explicit validation, and compiler. Five direct-library tests consume all 14 name, nine
    resolution/file-kind, and four text cases, then prove staged-function execution, parse/validation separation,
    engine identity, and exact missing-name JSON. The primary CLI delegates named/file sources while inline source
    stays on its existing in-memory path. Format and strict analysis pass; the complete Dart gate passes 165 tests,
    exact 61/61 CLI cases under default and POSIX environments, and all 105 corpus fixtures. Dart promotes to pass;
    census is 55/1/4.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.3 - add Dart native spec resolution`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4.4`
  Status: `done`
  Goal: Add Julia native named/file resolution and compilation.
  Acceptance: Public Julia APIs consume the neutral fixture without CLI/subprocess ownership, replace the CLI-only
    recursive fallback with the portable ordered-root policy, compose strict loading through staged parse/compile,
    retain source identity, return structured exceptions, and preserve exact primary CLI behavior.
  Verification: Public `src/io/SpecLoader.jl`, included and exported by `LinkedSpecJulia`, provides typed name/path
    requests, cwd plus ordered direct roots, deterministic candidate origins, regular-file selection, strict
    preserved UTF-8 loading, exact source identity, progressive resolve/load/compile results, typed stages/codes,
    structured JSON exceptions, and `create_engine(...)` attribution. The full composition uses the staged user-
    function parser, explicit validation, and compiler. Five direct-library testsets consume all 14 name, nine
    resolution/file-kind, and four text cases with 82 assertions, then prove staged-function execution, parse/
    validation separation, engine identity, and exact missing-name JSON. The primary CLI delegates named/file
    sources, removes its non-portable recursive repository fallback, retains deferred input loading, and keeps
    exact process behavior. The complete package passes 1,110 assertions; focused process checks, exact 61/61 CLI
    cases under default and POSIX environments, and all 105 corpus fixtures pass. Julia promotes to pass; census is
    56/1/3.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.4 - add Julia native spec resolution`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4.5`
  Status: `done`
  Goal: Admit and close exact native named/file resolution parity.
  Acceptance: All four variants pass the shared direct-library fixture and their complete recurring/CLI gates;
    public docs and the capability census promote the role only after adapter no-drift; `.1.6.4` closes and the
    frontier advances to Dart full-pipeline trace `.1.6.5`.
  Verification: Added public `LinkedSpec::SpecLoader` with blessed name/path request, options, resolved/loaded/
    compiled result, and structured error types. It accepts cwd plus ordered direct roots, distinguishes exact
    paths, chooses regular files, decodes raw bytes with strict UTF-8, retains source/request/path identity, composes
    through `LinkedSpec::Get`, and projects the reference compiler's raw validation-before-bootstrap seam into the
    neutral parse/validate/compile error stages. `t/native_spec_resolution.t` directly consumes every 14/9/4 case
    and proves staged user-function execution plus exact errors. The test is a required canonical CI input. Focused
    proof and the complete core gate pass, including 61x2 CLI and Phase 0 `1..1030` in 556 seconds. Prior adjacent
    Rust, Dart, and Julia direct-library/full-gate commits supply the other three exact admission legs. Generated
    LinkedSpec artifacts are absent; active external mutation-test temp trees were identified and left untouched.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.4.5 - admit native spec resolution parity`

## `FUTURE-PARITY-BACKLOG.1.6.4.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Knowledge Map/source audit plus `rg -n 'get_parser|PathSearch|SpecLoader' perl t`
  proved Rust/Dart/Julia consumed the 14/9/4 fixture directly while Perl exposed only legacy `get_parser` resolution;
  the first `prove -v -Iperl t/native_spec_resolution.t` run reproduced the missing portable facade and exposed the
  correct top-rule action-edge execution shape before passing.
- [x] **ROOT CAUSE (WHY + WHERE)** — `perl/LinkedSpec/Resolver.pm:63` owns legacy local plus `PathSearch` discovery,
  while `perl/LinkedSpec/ParserFactory.pm:89` owns compatibility compilation. Neither accepts separate name/path
  request types or caller-ordered roots; raw `LinkedSpec::Get` validation also reports “must start with a rule” at
  `last_error.stage=validate_spec_content`, requiring neutral parse-stage projection in the portable facade.
- [x] **FIX** — Added `LinkedSpec::SpecLoader` as a separate typed portable request/options/result/error facade over
  ordered direct resolution, strict raw-byte UTF-8 decoding, retained identity, and `LinkedSpec::Get` composition;
  legacy `get_parser` and `PathSearch` remain untouched. Added direct fixture/pipeline proof and canonical-gate wiring.
- [x] **ADDRESSED (verified)** — `PERL5LIB= prove -v -Iperl t/native_spec_resolution.t` passes all five subtests:
  every 14/9/4 contract family, staged user-function compilation/execution, name/path identity, parse/validation
  separation, and exact missing-name error hash.
- [x] **NO REGRESSION** — `bash tools/run_ci_local.sh` passes the required Perl loader test, 239-name coverage,
  focused suites, 61x2 CLI, and Phase 0 `1..1030` in 556 seconds; prior committed Rust, Dart, and Julia loader plus
  complete recurring/61x2 CLI gates remain green.
- [x] **LOCKSTEP** — The same JSON contract remains the single fixture; this leaf synchronizes capability evidence,
  `tools/run_ci_local.sh`, mdBook/API examples, task/live/roadmap docs, and Knowledge Map before parent admission.

- ID: `FUTURE-PARITY-BACKLOG.1.6.5`
  Status: `done`
  Goal: Complete Dart native trace coverage across frontend, compiler, function-shell, and staged dispatch.
  Children: `.1.6.5.0`, `.1.6.5.1`, `.1.6.5.2`, `.1.6.5.3`
  Acceptance: One caller-owned Dart emitter propagates through parse, validation, compile, function-definition,
    staged-job, and runtime entrypoints with balanced scopes, decisions, failures, sinks, default quietness, and
    traced/untraced identity equivalent to Perl/Rust/Julia; focused and 99-corpus gates pass.
  Verification: Closed by `.0`–`.3`: exact audit/split, core frontend/compiler propagation, function/staged
    propagation, and public native composition/admission. One caller-owned emitter now spans file loading,
    parser-spec construction/runtime, AST projection, staged jobs, validation, compilation, registry construction,
    and final runtime execution with balanced scopes/failures, complete sinks, default quietness, and exact result/
    diagnostic identity. Full Dart gate passes 175 tests, 61x2 CLI, and 105 corpus; capability promotes to pass at
    census 57/1/2.
  Commit: closed by `FUTURE-PARITY-BACKLOG.1.6.5.3 - admit Dart full-pipeline trace`

- ID: `FUTURE-PARITY-BACKLOG.1.6.5.0`
  Status: `done`
  Goal: Audit and split Dart full-pipeline native trace before behavior changes.
  Acceptance: Establish the exact current emitter boundary, compare the established Julia/Rust portable proof,
    name every Dart propagation seam, and split implementation from final admission without overclaiming runtime-
    only trace as full-pipeline trace.
  Verification: Source and Knowledge Map audit confirms `LinkedSpecTraceEmitter` is public and complete for levels,
    events, sinks, and runtime interpreter entrypoints, but is imported only by `runtime/interpreter.dart` among the
    native pipeline owners. `parseSpec`, `validateSpec`, `compileSpec`, `UserFunctionRegistry`, function-definition
    parsing/projection, staged registry dispatch, and `loadAndCompileSpec` have no optional emitter. Julia's admitted
    implementation establishes the applicable optional caller-owned propagation pattern and balanced failure exits.
    No Dart behavior changed. `.1` owns frontend/compiler, `.2` owns function-shell/staged dispatch, and `.3` owns
    public loader composition, full proof, census promotion, and parent closeout.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.5.0 - split Dart full-pipeline trace`

## `FUTURE-PARITY-BACKLOG.1.6.5.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `rg` across Dart native owners proves trace injection begins at
  `LinkedSpecRuntimeEngine.parse/execute`; the capability manifest therefore correctly keeps Dart at `gap` for the
  separate frontend/compiler/function/staged row.
- [x] **ROOT CAUSE (WHY + WHERE)** — Public operations in `parser/spec_parser.dart`, `validation/spec_validator.dart`,
  `compiler/compiled_spec.dart`, `action/function_registry.dart`, the two function-definition owners,
  `parser/staged_parser_registry.dart`, and `io/spec_loader.dart` have no emitter parameter or propagation path.
- [x] **FIX** — Split the active parent into bounded frontend/compiler `.1`, function-shell/staged `.2`, and composed
  native admission `.3` leaves; recorded the exact boundary in a Knowledge Map fact card and public/live docs.
- [x] **ADDRESSED (verified)** — Task-tree metadata, Knowledge Map generation/check, memory architecture, doctrines,
  whitespace, and mdBook build pass for the audit-only slice.
- [x] **NO REGRESSION** — No Dart parser/compiler/runtime/API behavior or capability state changed; the already-green
  165-test, 105-corpus, and 61x2 CLI baseline remains the implementation starting point.
- [x] **LOCKSTEP** — The split follows the admitted portable contract and Julia/Rust evidence while leaving Dart at
  `gap` until `.3` proves the complete caller-owned path and promotes all synchronized docs/metadata.

- ID: `FUTURE-PARITY-BACKLOG.1.6.5.1`
  Status: `done`
  Goal: Propagate one optional Dart trace emitter through source parsing, validation, and compilation.
  Acceptance: Existing public entrypoints remain source-compatible while emitting balanced `dart_frontend:*` and
    `dart_compiler:*` scopes, stable decisions, and failure exits through the caller's emitter; disabled/omitted
    tracing is quiet and parsed/compiled JSON is identical.
  Verification: `parseSpec`, `validateSpec`, `compileSpec`, and both `UserFunctionRegistry` factories now accept
    the same optional `LinkedSpecTraceEmitter` without changing existing calls. High-level balanced scopes cover
    parse, validation, compilation, and registry construction; medium decisions cover parsed rule counts,
    validation completion/skips, function definitions, compiled rules, and dependency-regex construction. All
    failure paths exit emitted scopes and rethrow the original object. Three focused tests prove exact event order,
    disabled quietness, parsed/compiled JSON identity, parse failure, and nested validation/compile failure. The six
    affected suites pass 38 tests; sequential strict analysis is clean. The complete Dart gate passes formatting,
    analysis, 168 tests, exact 61/61 CLI in default/POSIX environments, and all 105 corpus fixtures. Census remains
    56/1/3 until full function/staged/native admission.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.5.1 - trace Dart frontend and compiler`

## `FUTURE-PARITY-BACKLOG.1.6.5.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit `.0` proved core public frontend/compiler entrypoints could not receive the
  already-public emitter; focused tests now directly exercise those previously missing injection seams.
- [x] **ROOT CAUSE (WHY + WHERE)** — Parser, validator, compiler, and function-registry APIs had no optional trace
  dependency, so compilation could not preserve one caller-owned event order/sink/indent state.
- [x] **FIX** — Added source-compatible optional named emitter parameters, nested balanced scopes, medium decisions,
  validation propagation, and unchanged exception rethrows to the four owning modules.
- [x] **ADDRESSED (verified)** — Three focused tests compare traced/untraced `SpecFile` and `CompiledSpec` JSON,
  assert exact structured event order, prove disabled quietness, and lock parse plus validation failure exits.
- [x] **NO REGRESSION** — Format and strict analysis pass; six affected suites pass 38 tests; complete Dart gate
  passes 168 tests, 61x2 CLI, and 105/105 corpus.
- [x] **LOCKSTEP** — Public trace docs and durable facts describe the new partial boundary while the capability row
  remains `gap`; `.2` is active for function/staged propagation and `.3` alone owns promotion.

- ID: `FUTURE-PARITY-BACKLOG.1.6.5.2`
  Status: `done`
  Goal: Propagate the caller-owned Dart emitter through function-definition shell and staged parse dispatch.
  Acceptance: Parser-spec construction/execution, AST projection, job normalization/order, resolve/load/compile/
    execute, body stitching, and failures emit balanced function/staged events without changing ASTs or job results.
  Verification: Optional `trace:` now propagates through parser-spec construction/cache selection, definition-shell
    execution, AST projection, stripped-source parsing, staged function-body composition, single/batch queue
    execution, function-body dispatch, and stitching. One emitter retains nested ordering and sinks. Balanced high-
    level scopes cover function parsing/projection and staged queues/jobs; medium decisions cover definition counts,
    parser cache, projected definitions, normalized/sorted queues, each resolve/load/compile/execute phase, and body
    stitching. Four focused tests prove full topic coverage, scope balance, exact AST identity, disabled quietness,
    unchanged resolve failures, and preserved function-projection diagnostics. Strict analysis and the complete Dart
    gate pass formatting, 172 tests, exact 61/61 CLI in default/POSIX environments, and all 105 corpus fixtures.
    Census remains 56/1/3 until native composition/admission `.3`.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.5.2 - trace Dart function staging`

## `FUTURE-PARITY-BACKLOG.1.6.5.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Completed `.1` left function parser/shell and staged registry APIs without emitter
  parameters, so caller-owned ordering stopped before user-function extraction and resumed only at runtime.
- [x] **ROOT CAUSE (WHY + WHERE)** — `user_function_definition_parser.dart`,
  `user_function_definition_shell.dart`, and `staged_parser_registry.dart` independently called parser/compiler/
  runtime/staged phases without forwarding a trace dependency.
- [x] **FIX** — Added optional source-compatible propagation, balanced function/staged scopes, cache/definition/
  queue/phase/stitch decisions, runtime forwarding, and unchanged failure rethrows through all owning entrypoints.
- [x] **ADDRESSED (verified)** — Four focused tests prove end-to-end topics and balance, traced/untraced AST identity,
  disabled quietness, unchanged staged resolve failure, and original projection diagnostic classification.
- [x] **NO REGRESSION** — Format and strict analysis pass; complete Dart gate passes 172 tests, 61x2 CLI, and
  105/105 corpus.
- [x] **LOCKSTEP** — Public trace docs and Knowledge Map now describe frontend/compiler/function/staged/runtime
  coverage while leaving capability `gap`; `.3` alone owns loader composition, sink/failure admission, and promotion.

- ID: `FUTURE-PARITY-BACKLOG.1.6.5.3`
  Status: `done`
  Goal: Admit and close Dart full-pipeline native trace parity.
  Acceptance: `loadAndCompileSpec` accepts one caller-owned emitter and composes it through every frontend/function/
    staged/compiler phase into an engine using the same emitter at execution; focused failure/sink/identity proof,
    complete Dart/105-corpus/61x2 CLI gates, docs, and census all pass before parent closeout.
  Verification: `loadAndCompileSpec(..., trace:)` adds a balanced `dart_io:load_and_compile_spec` scope and loaded-
    source decision, then forwards the caller's emitter through staged function parsing, explicit validation, and
    compilation. The ordinary result does not retain mutable trace state; the caller passes the same emitter to
    `createEngine().execute(...)`. Three direct native tests prove one routed file contains IO/frontend/function/
    staged/compiler/runtime topics in balanced order with exact compiled/result identity, disabled tracing is empty,
    and validation failure JSON is unchanged with balanced failure exits. The initial focused compile caught and
    corrected `SpecCandidateOrigin.name` to its portable `contractName`. Format, strict analysis, 22 affected tests,
    and the full Dart gate pass 175 tests, 61x2 CLI, and 105 corpus. Canonical core CI passes 61x2 Perl CLI and
    Phase 0 `1..1030` in 514 seconds. The capability row promotes to pass, census is 57/1/2, `.1.6.5` closes, and
    `.1.6.6` becomes active.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.5.3 - admit Dart full-pipeline trace`

## `FUTURE-PARITY-BACKLOG.1.6.5.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.1`/`.2` proved every inner phase but `loadAndCompileSpec` still created the staged
  parser/validator/compiler path without accepting the caller's emitter, preventing one native composition proof.
- [x] **ROOT CAUSE (WHY + WHERE)** — `dart/lib/src/io/spec_loader.dart` called `_parseLoadedSpec`, `validateSpec`,
  and `compileSpec` without trace forwarding; final runtime already accepted the emitter separately.
- [x] **FIX** — Added source-compatible optional loader injection, balanced IO scope/loaded decision, forwarding
  through every compiled phase, and caller-explicit reuse at runtime without retaining mutable emitter state.
- [x] **ADDRESSED (verified)** — Three direct tests prove routed all-phase events and balance, compiled/result/source
  identity, disabled quietness, and exact structured validation failures.
- [x] **NO REGRESSION** — Format, strict analysis, 22 affected tests, complete 175-test Dart suite, exact 61x2 CLI,
  105/105 corpus, and the canonical core gate pass.
- [x] **LOCKSTEP** — Capability manifest, public trace API/book, roadmaps, task/live docs, and Knowledge Map promote
  together to 57/1/2; `.1.6.5` closes and non-codegen closeout `.1.6.6` is active.

- ID: `FUTURE-PARITY-BACKLOG.1.6.6`
  Status: `done`
  Goal: Close the non-codegen capability census and hand generated-source residuals to `.3` without overclaiming.
  Acceptance: The validated matrix contains no unowned gap/partial state; all `.1.6` implementation/proof leaves
    pass recurring checks; task/roadmap/live docs, mdBook, Knowledge Map, public APIs, and exact CLI agree; parent
    `.1.6` closes while complete backend parity remains blocked only by generated-source `.3` and later Lua.
  Verification: A direct manifest projection enumerates exactly three non-pass states: Rust `partial`, Dart `gap`,
    and Julia `gap`, all under `codegen.generated_parser_source` and all owned by `FUTURE-PARITY-BACKLOG.3`. The
    strict checker passes 57/1/2, proving no missing evidence path, invalid state, or unowned residual. Immediately
    prior `.1.6.5.3` passes 175 Dart tests, 61x2 Dart CLI, 105 corpus, canonical 61x2 Perl CLI, and Phase 0 `1..1030`
    in 514 seconds; adjacent Rust/Julia/full-matrix proofs remain the durable other legs. Public/task/live/roadmap/
    Knowledge Map surfaces now state that all non-codegen rows pass and complete parity is blocked only by `.3` plus
    the later Lua implementation. No parser/compiler/runtime behavior or manifest status changed in this closeout.
  Commit: prepared in `FUTURE-PARITY-BACKLOG.1.6.6 - close non-codegen capability parity`

## `FUTURE-PARITY-BACKLOG.1.6.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct machine-readable enumeration proves the 57/1/2 census contains exactly three
  non-pass states rather than treating a green interpreter/CLI subset as complete backend parity.
- [x] **ROOT CAUSE (WHY + WHERE)** — Every residual is confined to `codegen.generated_parser_source`: Rust proof is
  curated (`partial`), while Dart and Julia emit no parser source (`gap`); top-level `.3` owns all three.
- [x] **FIX** — Closed the non-codegen `.1.6` parent, activated `.3`, and synchronized task/roadmap/live/public/KM
  wording without changing capability data or backend behavior.
- [x] **ADDRESSED (verified)** — `perl tools/check_capability_conformance.pl` passes at 57/1/2; direct projection
  prints only the three generated-source states with the same `.3` owner.
- [x] **NO REGRESSION** — Immediately prior complete Dart and canonical core gates pass, including 175 tests,
  61x2 Dart, 105 corpus, 61x2 Perl, and Phase 0 `1..1030`; docs/KM/governance/whitespace/mdBook pass here.
- [x] **LOCKSTEP** — All codebase/book/continuity status surfaces distinguish closed non-codegen capability parity
  from still-open generated-source parity and later Lua; no complete-parity claim is made early.

- ID: `FUTURE-PARITY-BACKLOG.2`
  Status: `pending`
  Goal: Generalize staged linked parsing beyond the current function-body prototype.
  Acceptance: Public `parse_job(...)` authoring, import/provider search roots, multiple payload
    parser families, recursive staged queues, cycle diagnostics, docs, and corpus fixtures are
    split before implementation and kept implementation-language neutral.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.3`
  Status: `done`
  Goal: Close generated-source capability parity beyond the current interpreter-first correctness gates.
  Children: `.3.0`, `.3.1`, `.3.2`, `.3.3`, `.3.4`, `.3.5`
  Acceptance: Split Rust full-manifest breadth and separate Dart/Julia source-emitter proofs before code. Each
    non-Rust emitter lane must own a minimal emitter scaffold plus compile/run harness, typed generated-family plan,
    direct structural-family execution, and curated manifest-backed corpus subset. Rust exports source emission as
    a public runtime-crate capability, so ADR `0023` makes equivalent capability mandatory before Dart/Julia/Lua can
    claim complete user-visible parity; interpreter parity remains the primary correctness gate.
  Verification: **PASS 2026-07-11.** Contract-first Perl repair/admission, strict Rust 105/105 breadth, and
    deterministic Dart/Julia scaffold, exact ten-family direct execution, and accepted 8/105 admission all pass.
    Contract/capability census is 60/0/0 and final `.3.5` reverified every focused backend proof plus adjacent
    complete backend gates, governance, public docs, and cleanup. Lua `.1.3` activates only after this closeout.
  Commit: `FUTURE-PARITY-BACKLOG.3.5 - close generated-source parity`

- ID: `FUTURE-PARITY-BACKLOG.3.0`
  Status: `done`
  Goal: Audit and split generated-source parity before implementation.
  Acceptance: Read the canonical Knowledge Map facts first; inspect Perl reference generation, the public Rust
    emitter/export, its isolated compile/run harness and exact manifest subset, and Dart/Julia source trees; record
    the current 105-fixture boundary; create separate neutral-contract, Rust-breadth, Dart-emitter, Julia-emitter,
    and final-admission owners without changing parser/compiler/runtime behavior or capability status.
  Verification: **PASS 2026-07-11.** The then-current census classified Perl pass; Rust publicly emits a standalone module,
    validates a typed family plan, directly runs all current structural families, and compile/runs only eight named
    manifest fixtures; Dart and Julia expose no source emitter. `.3.1.0` later added the missing standalone Perl
    execution probe and corrected that classification. Knowledge Map, task/live/roadmap/book, governance,
    whitespace, and mdBook checks passed; generated artifacts were removed.
  Commit: `FUTURE-PARITY-BACKLOG.3.0 - split generated-source parity`

- ID: `FUTURE-PARITY-BACKLOG.3.1`
  Status: `done`
  Goal: Define the executable backend-neutral generated-source contract and correct the Perl reference boundary.
  Children: `.3.1.0`, `.3.1.1`, `.3.1.2`, `.3.1.3`
  Acceptance: Ratify a versioned contract and neutral fixtures for source emission from a compiled `.spec`,
    host-language compile/load, direct generated execution, exact canonical result and diagnostic/source identity,
    trace entry, structural-family metadata, malformed-plan rejection, and manifest-backed proof. Host APIs and
    emitted bytes may remain idiomatic/backend-native under ADR `0023`; observable capability and behavior may not
    differ. Keep the 105-case interpreter corpus as the primary oracle; correct and repair Perl's independently
    compiled-source boundary before treating the reference as a pass baseline.
  Verification: **PASS 2026-07-11.** Contract v1, corrected independently loadable Perl generation, Rust typed
    identity/metadata/errors, exact neutral plan/rejections/direct result/trace roles, and explicit admission are
    complete. Focused Perl proof passes 69 assertions; focused Rust source-emitter passes 5/5. Complete canonical
    Perl CI passes 61x2 CLI and Phase 0 `1..1030` in 652 seconds; complete Rust passes
    137/105/196/5/5/5/10 plus 61x2 CLI. Census promotes to 57/1/2: Perl pass, Rust partial solely for 8/105 breadth,
    Dart/Julia gap. Docs/KM/governance/mdBook/cleanup pass; `.3.2` is active.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.3.3 - admit Perl Rust generated baseline`

- ID: `FUTURE-PARITY-BACKLOG.3.1.0`
  Status: `done`
  Goal: Root-cause the Perl standalone generated-source failure and split correction before code.
  Acceptance: Use `LinkedSpec::Get` plus `generate_only`/`dump_parser_source`/`parser_source_ref` to compare the
    normal parser with independently compiled captured source; reduce any mismatch to the exact source mechanism;
    correct the capability census and every public/continuity claim; create separate contract, Perl repair, and
    admission leaves before behavior changes.
  Verification: **PASS 2026-07-11.** A minimal action-edge parser returns `"ok"` normally; captured source compiles
    under an isolated package but returns `undef`. Debug trace proves regex match succeeds while the expected action
    index is skipped. The dump stringifies `LinkedRE::oredRE` into `qr/...(?{$pos=N}).../`; recompilation detaches
    that marker from `LinkedRE::or`'s lexical index, yielding wrong/undefined `match_index`. Capability checker,
    docs/KM/governance/whitespace/mdBook/cleanup pass at corrected census 56/2/2; no behavior code changed.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.0 - correct Perl generated-source status`

- ID: `FUTURE-PARITY-BACKLOG.3.1.1`
  Status: `done`
  Goal: Define the versioned executable neutral generated-source contract and fixtures.
  Acceptance: Add a strictly checked schema/fixture set for host-source emission, independent compile/load, direct
    result, trace, diagnostic/source identity, exact family-plan validation/rejection, and the accepted manifest
    subset. Define semantic entrypoint roles rather than identical host-language names or source bytes. Wire the
    checker into canonical local CI before changing Perl generation.
  Verification: **PASS 2026-07-11.** Strict checker validates v1 schema, ownership, semantic/API boundary,
    deterministic markers, pipeline, ten families, plan rejection, errors, direct fixture, exact eight-case subset,
    live 105-case manifest, and current 56/2/2 states. Checker syntax/focused execution, capability, Knowledge Map,
    canonical local CI through Phase 0 `1..1030`, docs/governance/whitespace/mdBook, and cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.1 - define generated-source contract`

- ID: `FUTURE-PARITY-BACKLOG.3.1.2`
  Status: `done`
  Goal: Make Perl's public captured/generated source independently compile and execute equivalently.
  Acceptance: Preserve normal parser behavior while emitting dependency-regex reconstruction that retains exact
    alternative indexes after independent compilation; add direct result/trace/source-identity and malformed-plan
    locks over the neutral fixtures; keep diagnostic capture compatibility explicit and avoid host-package binding.
  Verification: **PASS 2026-07-11.** Public emitter and legacy capture are byte-identical/deterministic; isolated
    arbitrary-package execution returns the exact neutral result; reconstructed `LinkedRE::oredRE` alternatives
    retain indexes zero/one including slash-bearing regex; metadata/identity, ordinary/traced execution, all four
    plan rejections, and structured emission/execution errors pass 69 focused assertions. Existing generated branch
    suites pass. Phase 0 first reached its true stop with exactly two stale direct-Get source locks, then passes
    `1..1030` in 546 seconds after they require validated `Get -> Execute`; canonical CI, docs/KM/governance/mdBook,
    and cleanup pass. Capability remains partial until admission `.3.1.3`.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.2 - repair Perl generated source`

## `FUTURE-PARITY-BACKLOG.3.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `LinkedSpec::Get` normal execution returned `"ok"`, while independently evaluated
  `generate_only`/`dump_parser_source` text consumed the regex with the wrong index and returned `undef`.
- [x] **ROOT CAUSE (WHY + WHERE)** — debug `generated_handler_branch` trace and reduced `LinkedRE::oredRE` probes
  located `Compiler.pm` stringification of `qr/...(?{$pos=N}).../`, which detached markers from `LinkedRE::or`'s
  lexical index on recompilation.
- [x] **FIX** — `Compiler.pm` reconstructs dependency alternatives from compiled rule refs, emits v1 metadata/plan/
  wrappers, and `LinkedSpec::GeneratedSource` owns public emission, validation, trace roles, and structured errors.
- [x] **ADDRESSED (verified)** — `t/generated_source_contract.t` passes direct/trace/identity/error/plan/index/slash
  locks; public and legacy source are identical; arbitrary packages return exact results.
- [x] **NO REGRESSION** — four focused generated trace suites pass; full Phase 0 reaches `1..1030` after exactly two
  measured stale wrapper-shape locks are migrated; canonical local CI passes.
- [x] **LOCKSTEP** — API/book/USER_GUIDE/TOOLBOX, task/roadmap/live docs, Knowledge Map, capability note, checks, and
  generated artifact cleanup agree; census remains 56/2/2 pending `.3.1.3` admission.

- ID: `FUTURE-PARITY-BACKLOG.3.1.3`
  Status: `done`
  Goal: Admit the neutral contract baseline and corrected Perl generated-source pass.
  Children: `.3.1.3.0`, `.3.1.3.1`, `.3.1.3.2`, `.3.1.3.3`
  Acceptance: Perl and existing Rust source emission consume the same contract roles; focused and full Perl/Rust
    gates pass; capability checker returns Perl to pass with only Rust breadth partial plus Dart/Julia gaps; docs,
    book, Knowledge Map, roadmap, artifact cleanup, and parent `.3.1` closeout agree before `.3.2` starts.
  Verification: **PASS 2026-07-11.** Rust's audited v1 gaps are closed through typed identity/metadata/errors,
    exact ten-family plan and four rejections, direct result, portable trace roles, and compatibility adapters.
    Focused and full Perl/Rust gates pass under `.3.1.3.3`; capability checker reports 57 pass / one partial / two
    gap states. Perl is admitted pass; Rust's only partial boundary is generated breadth 8/105. `.3.1` closes.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.3.3 - admit Perl Rust generated baseline`

- ID: `FUTURE-PARITY-BACKLOG.3.1.3.0`
  Status: `done`
  Goal: Audit Rust against every generated-source v1 role and split admission before behavior code.
  Acceptance: Inspect the public emitter, emitted markers/entrypoints, plan representation and rejection surface,
    trace events, error types, isolated compile/run harness, and neutral fixture; record every exact v1 mismatch;
    create bounded metadata/error, plan/trace, and final-admission leaves without changing runtime behavior or
    capability status.
  Verification: **PASS 2026-07-11.** Knowledge Map and source audit proves the compatibility emitter accepts only
    `CompiledSpec`, emits only a format marker, returns raw strings, validates a private typed-enum plan without an
    unknown-family value, and exposes rich native `rust_runtime:generated_plan:*` trace topics rather than the
    three neutral roles. Its existing isolated proof remains green: all ten families, legacy repetition, and the
    eight-case subset pass three focused tests in 35.69 seconds. Metadata/error `.1`, plan/trace `.2`, and admission
    `.3` are split before behavior code; census remains 56/2/2. Docs/KM/governance/mdBook/cleanup pass.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.3.0 - split Rust generated-source v1 alignment`

## `FUTURE-PARITY-BACKLOG.3.1.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — direct source/API scans show no contract-id/source-identity marker, no typed
  `generated_source_error`, no unknown-family rejection code, and no neutral generated trace-role names.
- [x] **ROOT CAUSE (WHY + WHERE)** — `source_emitter.rs` predates contract v1: its compatibility API was designed
  around `CompiledSpec`, a Rust enum family table, native `String` errors, and native generated-plan trace topics.
- [x] **FIX** — no behavior fix belongs in this audit leaf; `.1` owns typed identity/metadata/errors, `.2` owns the
  exact neutral plan/trace roles, and `.3` owns gates/status admission.
- [x] **ADDRESSED (verified)** — the exact gaps and still-green all-family/legacy/eight-case baseline are durable in
  the task tree, capability evidence, public book/status, and Knowledge Map.
- [x] **NO REGRESSION** — existing `source_emitter` integration test passes 3/3, including independently compiled
  temporary crates; no parser/compiler/runtime behavior source changed.
- [x] **LOCKSTEP** — task/roadmap/live/book/capability/KM state remains at 56/2/2 and activates `.3.1.3.1`.

- ID: `FUTURE-PARITY-BACKLOG.3.1.3.1`
  Status: `done`
  Goal: Align Rust emission metadata, source identity, and generated-source errors with contract v1.
  Acceptance: Add an idiomatic typed public request/error surface while preserving the compatibility emitter;
    emit deterministic contract/version/source-identity metadata; map emission, generated load/compile harness,
    plan validation, and execution failures to the stable contract fields/stages/codes with exact focused tests.
  Verification: **PASS 2026-07-11.** Rust now exposes `emit_rust_source_v1(compiled, source_identity)` with
    deterministic contract/version/identity metadata and typed `GeneratedSourceError` stages/codes while the
    original `emit_rust_source(compiled) -> Result<String, String>` and emitted `parse` adapters retain their exact
    compatibility behavior. Focused source-emitter proof passes 4/4, including exact metadata JSON, empty-identity
    emission failure, caller projection of compile/load failure, malformed embedded-spec validation, row-count
    plan validation, attributed execution failure, deterministic identity behavior, and independently compiled
    generated modules. The complete Rust gate passes 137 unit, 105 corpus, 196 integration, 5 diagnostics,
    4 source-emitter, 5 spec-loader, 10 trace tests, doc/build checks, and 61/61 CLI cases in default and POSIX
    environments. Strict Clippy reports only 14 pre-existing findings in untouched owners. Docs/KM/governance/
    mdBook/cleanup pass; census remains 56/2/2 pending exact plan/trace `.2` and admission `.3`.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.3.1 - add Rust generated-source v1 metadata`

## `FUTURE-PARITY-BACKLOG.3.1.3.1` Acceptance Checklist

- [x] **PUBLIC TYPED SURFACE** — callers can supply source identity and receive structured emission errors through
  `emit_rust_source_v1`; `GeneratedSourceError::compile_failed` projects the host compile/load boundary.
- [x] **DETERMINISTIC METADATA** — emitted modules expose exact contract id, format version, source identity, and
  `metadata()`; identical compiled input/identity emits identical source and changing identity changes source.
- [x] **STABLE ERRORS** — emission, compile/load, plan-validation, and execution failure paths carry the contract
  type, stage, code, summary, source identity, and available rule/family/detail attribution.
- [x] **COMPATIBILITY** — the original string-returning emitter delegates with `<inline>` identity, while generated
  `parse` and `parse_with_trace` continue to return the original raw string diagnostics and exact results.
- [x] **NO REGRESSION** — focused 4/4 plus the complete 137/105/196/5/4/5/10 and 61x2 Rust gate pass.
- [x] **LOCKSTEP** — Rust API/docs/book/task/live/capability/KM state records metadata/error completion without
  claiming exact neutral plan/trace roles or capability admission; `.3.1.3.2` becomes active.

- ID: `FUTURE-PARITY-BACKLOG.3.1.3.2`
  Status: `done`
  Goal: Align Rust generated-plan rejection and neutral trace roles with contract v1.
  Acceptance: Validate exact ordered label/family rows using the ten neutral family names; reject row count, label,
    family mismatch, and unknown family before execution with exact codes; expose generated-rule enter, family
    decision, and exit roles while retaining richer native trace; pass the neutral result/trace/identity fixture and
    existing all-family isolated compile/run matrix.
  Verification: **PASS 2026-07-11.** Emitted Rust modules now expose an exact neutral `GeneratedPlanRow` table,
    `plan()`, and `validate_plan(...)`; typed execution rejects row count, label, known-family mismatch, and arbitrary
    unknown-family values before runtime with the four stable codes. The exact neutral fixture initially exposed
    Rust's historical generated accumulator envelope (`["ok"]`) versus v1 direct result (`"ok"`): root cause was
    that generated execution had not mirrored the already-adopted `Engine::execute_value`/legacy `execute` split.
    Typed v1 `execute` now uses a generated-plan-aware direct-value seam; compatibility `parse` keeps the envelope.
    Traced v1 execution emits `generated_rule_enter`, `generated_family_decision`, and `generated_rule_exit` with
    identity/rule/family beside rich native topics. A first full gate correctly caught and repaired accidental
    legacy traced projection drift; focused trace 10/10 and source-emitter 5/5 then pass. The clean rerun passes
    137 unit, 105 corpus, 196 integration, 5 diagnostics, 5 source-emitter, 5 loader, 10 trace, docs/build, and
    61/61 CLI in default and POSIX environments. Strict Clippy retains exactly 14 pre-existing untouched findings.
    Docs/KM/governance/mdBook/cleanup pass; census remains 56/2/2 for explicit admission `.3`.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.3.2 - align Rust generated plans and trace`

## `FUTURE-PARITY-BACKLOG.3.1.3.2` Acceptance Checklist

- [x] **EXACT PLAN** — emitted `GeneratedPlanRow` values use exactly the ten neutral family names in source rule
  order; `Repetition` remains only a legacy enum marker and has no contract name.
- [x] **FOUR REJECTIONS** — count, label, known-family mismatch, and arbitrary unknown-family mutations fail before
  execution with exact v1 stages/codes/source identity and available label/family attribution.
- [x] **DIRECT RESULT** — typed v1 generated `execute` returns the portable top-rule value while legacy `parse`
  retains its historical accumulator envelope; interpreter-first direct and compatibility projections are proven.
- [x] **PORTABLE TRACE** — traced v1 execution carries the three neutral role names plus identity/rule/family while
  retaining all richer `rust_runtime:generated_plan:*` events and exact legacy traced results.
- [x] **NO REGRESSION** — focused 5/5 source-emitter and 10/10 trace-control proof plus the complete
  137/105/196/5/5/5/10 and 61x2 Rust gate pass after the compatibility correction.
- [x] **LOCKSTEP** — API/book/task/live/capability/KM state records a green Perl/Rust v1 baseline without promotion;
  explicit admission `.3.1.3.3` becomes active.

- ID: `FUTURE-PARITY-BACKLOG.3.1.3.3`
  Status: `done`
  Goal: Admit the corrected Perl/Rust generated-source v1 baseline.
  Acceptance: Run focused and complete Perl/Rust gates, promote Perl generated source to pass while Rust remains
    partial only for 8/105 breadth, close `.3.1`, synchronize all public/continuity/capability records, clean safe
    generated artifacts, and activate `.3.2`.
  Verification: **PASS 2026-07-11.** Contract checker and focused Perl generated-source proof pass 69 assertions;
    focused Rust passes 5/5. `PERL5LIB= bash tools/run_ci_local.sh` passes contract/native/239-name/AST/trace gates,
    61/61 CLI in default and POSIX environments, and Phase 0 `1..1030` in 652 seconds. A fresh
    `bash tools/run_rust_local.sh` passes formatting, 137 unit, 105 corpus, 196 integration, 5 diagnostics,
    5 source-emitter, 5 loader, 10 trace, docs/build, and 61/61 CLI default/POSIX. Capability and contract state
    advance from 56/2/2 to 57/1/2: Perl pass, Rust partial only for 8/105 breadth, Dart/Julia gap. Docs/KM/
    governance/mdBook/cleanup pass; `.3.1` closes and `.3.2.0` becomes active.
  Commit: `FUTURE-PARITY-BACKLOG.3.1.3.3 - admit Perl Rust generated baseline`

## `FUTURE-PARITY-BACKLOG.3.1.3.3` Acceptance Checklist

- [x] **FOCUSED PROOF** — Perl contract checker + 69 assertions and Rust source-emitter 5/5 pass independently.
- [x] **COMPLETE PERL** — canonical CI passes 61x2 CLI and Phase 0 `1..1030` in 652 seconds.
- [x] **COMPLETE RUST** — fresh 137/105/196/5/5/5/10, docs/build, and 61x2 CLI gate passes.
- [x] **EXACT ADMISSION** — Perl promotes partial→pass; Rust stays partial only for named 8/105 breadth; Dart and
  Julia remain gap, yielding exactly 57 pass / one partial / two gap states.
- [x] **CLOSEOUT** — `.3.1.3` and `.3.1` close; task/roadmap/live/book/capability/KM/checkers agree; `.3.2.0` active.

- ID: `FUTURE-PARITY-BACKLOG.3.2`
  Status: `done`
  Goal: Expand Rust generated-source proof from eight curated fixtures to the complete 105-case manifest.
  Children: `.3.2.0`, `.3.2.1`, `.3.2.2`
  Acceptance: Reuse the neutral contract and existing public emitter/family-plan path; do not weaken or replace the
    interpreter oracle. Classify the full manifest first, recursively split every discovered failure by mechanism
    before repair code, then compile/run generated Rust source for all 105 fixtures with exact expected values.
  Verification: **PASS 2026-07-11.** `.3.2.0` adds exact staged all-105 classification, `.3.2.1` proves all
    requested repair inventories empty, and `.3.2.2` makes the classifier unconditional/recurring and admits it.
    Independent strict classification passes 105/105 in 186.42 seconds. The canonical complete Rust gate runs the
    same test automatically and passes 137 unit, 105 interpreter corpus, 105 generated-source breadth in 189.42s,
    196 integration, 5 diagnostics, 5 source-emitter, 5 loader, 10 trace, docs/build, and 61x2 CLI. Strict Clippy
    still names the 14 pre-existing runtime findings; exempting only their six classes passes the changed test.
    Contract and
    capability checkers report 58 pass / zero partial / two gaps. Rust promotes to pass; `.3.3.1` is active for Dart.
  Commit: `FUTURE-PARITY-BACKLOG.3.2.2 - admit Rust generated-source breadth`

- ID: `FUTURE-PARITY-BACKLOG.3.2.0`
  Status: `done`
  Goal: Add a scalable full-manifest Rust generated-source classifier.
  Acceptance: Drive all 105 checked-in fixtures through parse/validate/compile/interpreter-oracle/emit/isolated
    compile/run; report deterministic per-case stages without silently skipping failures; retain the existing
    synthetic all-family matrix and eight-case proof while classification is active.
  Verification: **PASS 2026-07-11.** Added an explicitly invoked full-manifest classifier that validates exact
    105-case manifest accounting, prepares every fixture through strict-UTF-8 read, parse, validate, compile,
    legacy/direct interpreter oracle, and v1 emission, then writes separate generated modules into one isolated
    temporary Cargo crate for one host compile and 105 named host tests. The first per-case prototype proved exact
    staging but measured roughly ten seconds per fixture; it was stopped after eight green cases and replaced by
    the shared-crate design. The scalable run classifies all 105 fixtures PASS across all eight stages in 184.46
    seconds with zero skips/failures and removes its temporary crate on drop. Existing all-family and eight-case
    tests pass 5/5 in 36.66 seconds. Strict Clippy reports the same 14 pre-existing runtime findings; rerunning with
    only their six known lint classes exempted passes the new test cleanly under `-D warnings`. No emitter/runtime
    behavior changed. `.3.2.1` is active to close the zero-failure classification before strict recurring admission.
  Commit: `FUTURE-PARITY-BACKLOG.3.2.0 - classify all Rust generated fixtures`

## `FUTURE-PARITY-BACKLOG.3.2.0` Acceptance Checklist

- [x] **COMPLETE INPUT** — manifest format/count/uniqueness are checked and exactly 105 ordered fixture names are
  processed; terminal pass/failure accounting must total 105.
- [x] **EXACT STAGES** — every case reaches or is attributed to read, parse, validate, compile, interpreter oracle,
  emit source, isolated host compile, or host run; failures do not silently disappear.
- [x] **SCALABLE HOST** — one temporary crate contains separate per-case modules/tests, one host compile, and one
  serial host run; all dependency/build output is caller-owned and removed on drop.
- [x] **CLASSIFICATION** — explicit run passes 105/105 in 184.46 seconds with zero failure mechanisms to split.
- [x] **NO REGRESSION** — the existing synthetic ten-family matrix and admitted eight-case test remain untouched;
  the classifier is explicit/ignored until `.3.2.2` recurring-gate admission.
- [x] **LOCKSTEP** — task/public/live/KM state records green classification without prematurely promoting Rust;
  zero-failure closeout `.3.2.1` becomes active.

- ID: `FUTURE-PARITY-BACKLOG.3.2.1`
  Status: `done`
  Goal: Own classification and recursive repair splitting, not unsplit fixes.
  Acceptance: Classify every `.3.2.0` failure by exact source-emitter, generated-plan, generated-executor,
    dependency/build, or fixture-contract mechanism. Add bounded child leaves before changing behavior; if no
    failures exist, record that result and close without behavior code.
  Verification: **PASS 2026-07-11.** Reviewed the complete `.3.2.0` terminal report: all 105 fixtures pass all
    eight stages, so the source-emitter, generated-plan, generated-executor, dependency/build, and fixture-contract
    failure inventories are each empty. No recursive repair child and no behavior change are justified. The exact
    zero-failure result is durable in the classifier test, `.3.2.0` verification, capability note, public book, and
    Knowledge Map fact. `.3.2.1` closes as required and activates only strict recurring admission `.3.2.2`.
  Commit: `FUTURE-PARITY-BACKLOG.3.2.1 - close zero-failure Rust classification`

## `FUTURE-PARITY-BACKLOG.3.2.1` Acceptance Checklist

- [x] **COMPLETE REPORT** — the classifier accounts for exactly 105 pass + failure terminal records.
- [x] **MECHANISM INVENTORY** — emitter, plan, executor, dependency/build, and fixture-contract failure sets are
  all empty; no failure is left unsplit.
- [x] **NO INVENTED REPAIR** — no child leaf or behavior change is created for a mechanism the evidence did not
  find.
- [x] **DURABLE RESULT** — source test, task verification, capability note, mdBook, and Knowledge Map all preserve
  the 105/105 zero-failure conclusion.
- [x] **NEXT BOUNDARY** — Rust remains partial; strict recurring admission `.3.2.2` alone becomes active.

- ID: `FUTURE-PARITY-BACKLOG.3.2.2`
  Status: `done`
  Goal: Admit complete Rust generated-source manifest breadth.
  Acceptance: Every recursively split repair is closed; all 105 fixtures compile and run generated Rust source with
    exact oracle values; the synthetic family matrix, full interpreter gate, trace/source identity, complete Rust
    local gate, docs, Knowledge Map, and artifact cleanup pass before Rust promotes from partial to pass.
  Verification: **PASS 2026-07-11.** Removed the classifier ignore marker and conditional strictness escape hatch;
    any classified failure now fails ordinary `cargo test -p linkedspec-runtime`. Contract v1 names the exact test
    and its checker rejects a missing/non-file path, case count other than 105, any ignore attribute, or absence of
    unconditional `failures.is_empty()` enforcement. Independent strict 105/105 passes in 186.42 seconds. The full
    Rust gate repeats it in 189.42 seconds and passes all adjacent counts: 137/105/105-generated/196/5/5/5/10 plus
    61x2 CLI. Strict Clippy retains only 14 pre-existing runtime findings and the changed test passes when their six
    known classes are exempted. Rust generated source promotes partial→pass; census is 58/0/2; parent `.3.2` closes and Dart `.3.3.1`
    becomes active after docs/KM/governance/mdBook/cleanup agree.
  Commit: `FUTURE-PARITY-BACKLOG.3.2.2 - admit Rust generated-source breadth`

## `FUTURE-PARITY-BACKLOG.3.2.2` Acceptance Checklist

- [x] **STRICT RECURRING TEST** — no ignore/conditional bypass remains; ordinary runtime-package tests execute the
  all-105 classifier and any failure fails the test.
- [x] **CONTRACT ENFORCEMENT** — generated-source contract/checker locks the exact test path, 105 count, no ignore,
  unconditional failure rejection, and Rust pass state.
- [x] **INDEPENDENT PROOF** — strict classifier passes 105/105 in 186.42 seconds with exact staged accounting.
- [x] **COMPLETE RUST** — canonical gate passes 137 unit, 105 interpreter, 105 generated, 196 integration,
  5 diagnostics, 5 emitter, 5 loader, 10 trace, docs/build, and 61x2 CLI.
- [x] **EXACT PROMOTION** — Rust promotes partial→pass; census becomes exactly 58 pass / zero partial / two gaps.
- [x] **CLOSEOUT** — `.3.2` closes; task/roadmap/live/book/capability/KM/cleanup agree; Dart `.3.3.1` becomes active.

- ID: `FUTURE-PARITY-BACKLOG.3.3`
  Status: `done`
  Goal: Add public generated Dart source with direct structural execution and proof.
  Children: `.3.3.1`, `.3.3.2`, `.3.3.3`
  Acceptance: Implement only after `.3.1`; preserve native interpreter behavior and exact CLI parity while exposing
    an idiomatic Dart API equivalent to the neutral generated-source contract.
  Verification: `.3.3.1-.3` complete; deterministic emitter, ten-family direct matrix, exact accepted subset,
    complete 181-test/61x2/105 Dart gate, contract/capability 59/0/1, docs/KM/no-drift/cleanup.
  Commit: closed by `FUTURE-PARITY-BACKLOG.3.3.3 - admit generated Dart source`

- ID: `FUTURE-PARITY-BACKLOG.3.3.1`
  Status: `done`
  Goal: Add the public Dart emitter scaffold and isolated compile/run harness.
  Acceptance: Emit deterministic Dart source from compiled state, load/compile it in a caller-owned temporary
    package without repository build leakage, execute a minimal parser entrypoint, prove stable format/version and
    failures, and clean generated packages/caches.
  Verification: focused format/analyze/source-emitter 3/3; isolated offline pub/analyze/run; complete Dart gate
    178 tests, 61/61 default, 61/61 POSIX, and 105/105 corpus.
  Commit: `FUTURE-PARITY-BACKLOG.3.3.1 - add Dart generated-source scaffold`

### `FUTURE-PARITY-BACKLOG.3.3.1` outcome

- [x] **PUBLIC SCAFFOLD** — Dart exports deterministic compatibility and contract-v1 emitters plus typed metadata
  and portable stage/code/source-attribution failures.
- [x] **COMPILED INPUT** — emission consumes effective ordered `CompiledSpec` functions/rules and reconstructs a
  normalized specification inside the generated library without retaining repository build state.
- [x] **TEXT BOUNDARY** — generated Dart is Unicode source; its embedded normalized payload is strict UTF-8 encoded
  as deterministic Base64, keeping Unicode distinct from the selected persisted encoding and avoiding interpolation.
- [x] **ISOLATED HOST PROOF** — a caller-owned temporary package and private `PUB_CACHE` resolve offline, analyze,
  execute the direct value, project attributed runtime failure, and are deleted recursively in `finally`.
- [x] **EXACT SCAFFOLD CONTRACT** — contract id, format 1, source identity, deterministic bytes, emit/compile-load/
  execution failures, and ordinary/traced entrypoint roles are locked; family-plan semantics remain `.3.3.2`.
- [x] **COMPLETE DART** — canonical gate passes 178 package tests, 61x2 CLI, and 105/105 interpreter corpus.
- [x] **HONEST STATUS** — capability census stays 58/0/2; Dart remains gap until `.3.3.2` and `.3.3.3` admission.

- ID: `FUTURE-PARITY-BACKLOG.3.3.2`
  Status: `done`
  Goal: Add Dart typed family-plan metadata and direct generated structural execution.
  Acceptance: Cover every current default/OR/AND/repetition acode/bcode family, validate label/family plans before
    execution, retain trace and diagnostic/source identity, and compile/run a synthetic all-family matrix.
  Verification: focused format/analyze/source-emitter 5/5; isolated ten-family package analyze/run; four exact
    rejections; portable trace roles; complete Dart gate 180 tests, 61x2 CLI, and 105/105 corpus.
  Commit: `FUTURE-PARITY-BACKLOG.3.3.2 - add Dart generated family execution`

### `FUTURE-PARITY-BACKLOG.3.3.2` outcome

- [x] **EXACT PLAN** — emitted libraries expose ordered `GeneratedPlanRow { label, family }` rows using all ten
  neutral default/OR/AND/repetition acode/bcode family strings.
- [x] **FOUR REJECTIONS** — count, label, known-family mismatch, and arbitrary unknown-family inputs fail before
  execution with distinct contract-v1 stage/code/source/rule/family/detail records.
- [x] **DIRECT STRUCTURAL ROUTING** — validated typed families are passed into the native engine and select regex/
  acode versus blind/bcode dispatch on every generated rule entry instead of serving as decorative metadata.
- [x] **TRACE/DIAGNOSTIC IDENTITY** — traced generated execution emits `generated_rule_enter`,
  `generated_family_decision`, and `generated_rule_exit`; failures preserve source and available rule/family.
- [x] **ALL-FAMILY HOST PROOF** — one caller-owned offline temporary Dart package analyzes and runs generated
  libraries for every ten-family case against direct interpreter values, then recursively deletes package/cache.
- [x] **COMPLETE DART** — canonical gate passes 180 package tests, 61x2 CLI, and 105/105 interpreter corpus.
- [x] **HONEST STATUS** — census stays 58/0/2; curated interpreter-first generated admission remains `.3.3.3`.

- ID: `FUTURE-PARITY-BACKLOG.3.3.3`
  Status: `done`
  Goal: Admit generated Dart source against manifest-backed oracle fixtures.
  Acceptance: Run the neutral curated subset through interpreter-first exact comparison, emitted-source
    compile/run, complete Dart gates, docs/KM/no-drift, and cleanup; promote Dart's generated-source gap only after
    all contract families pass.
  Verification: exact contract-sourced 8/105 interpreter-first subset; one isolated offline host analyze/run;
    direct result/metadata/plan/trace identity; complete Dart 181 tests, 61x2 CLI, 105 corpus; checkers 59/0/1.
  Commit: `FUTURE-PARITY-BACKLOG.3.3.3 - admit generated Dart source`

### `FUTURE-PARITY-BACKLOG.3.3.3` outcome

- [x] **EXECUTABLE SOURCE LIST** — the test reads `corpus_proof.accepted_subset` directly from contract v1 and
  locks its exact eight-case count and membership in the 105-case interpreter manifest.
- [x] **INTERPRETER FIRST** — every fixture parses through ordinary or staged-function frontend, compiles, and
  equals checked-in `expected.json` through native direct execution before source emission.
- [x] **INDEPENDENT GENERATED PROOF** — eight emitted libraries analyze and run in one caller-owned offline package;
  values, contract/version/identity metadata, ordered plans, and portable trace identity are exact.
- [x] **RECURRING ENFORCEMENT** — contract names the Dart test path; checker locks count, contract consumption,
  interpreter-first order, v1 emission, host analyze/run, trace roles/identity, cleanup, and no skip.
- [x] **COMPLETE DART** — canonical gate passes 181 tests, 61x2 CLI, and 105/105 interpreter corpus.
- [x] **PROMOTION** — Dart generated source moves gap→pass; census is exactly 59/0/1 with Julia the sole gap.
- [x] **CLOSEOUT** — `.3.3` closes; Julia scaffold `.3.4.1` becomes active after clean commit.

- ID: `FUTURE-PARITY-BACKLOG.3.4`
  Status: `done`
  Goal: Add public generated Julia source with direct structural execution and proof.
  Children: `.3.4.1`, `.3.4.2`, `.3.4.3`
  Acceptance: Implement only after `.3.1`; preserve native interpreter behavior and exact CLI parity while exposing
    an idiomatic Julia API equivalent to the neutral generated-source contract.
  Verification: **PASS 2026-07-11.** Deterministic scaffold, exact family/direct execution, and contract-sourced
    interpreter-first manifest admission are all complete through `.3.4.1`-`.3.4.3`. Julia generated source passes.
  Commit: `FUTURE-PARITY-BACKLOG.3.4.3 - admit generated Julia source`

- ID: `FUTURE-PARITY-BACKLOG.3.4.1`
  Status: `done`
  Goal: Add the public Julia emitter scaffold and isolated include/compile-run harness.
  Acceptance: Emit deterministic Julia source from compiled state, include/load it in caller-owned isolation,
    execute a minimal parser entrypoint, prove stable format/version and failures, respect depot/artifact boundaries,
    and clean only generated task-owned files.
  Verification: **PASS 2026-07-11.** Public compatibility/v1 Julia emitters reconstruct deterministic effective
    AST state, serialize canonical JSON, and embed strict-UTF-8 payload/identity bytes as ASCII hex. Generated
    modules expose exact contract/version/identity metadata plus direct/traced execution and typed emission,
    compile/load, and execution failures. An 18-assertion proof runs valid and corrupt modules in fresh offline
    Julia processes from a caller-owned temporary project with compiled modules disabled and a private writable
    depot layer; Unicode/`$` result and cleanup are exact. Focused 18/18 and package 1,128 assertions pass without
    native interpreter or CLI changes. Complete Julia gate result is recorded in the verification log below.
  Commit: `FUTURE-PARITY-BACKLOG.3.4.1 - add Julia generated-source scaffold`

- ID: `FUTURE-PARITY-BACKLOG.3.4.2`
  Status: `done`
  Goal: Add Julia typed family-plan metadata and direct generated structural execution.
  Acceptance: Cover every current default/OR/AND/repetition acode/bcode family, validate label/family plans before
    execution, retain trace and diagnostic/source identity, and run a synthetic all-family matrix directly.
  Verification: **PASS 2026-07-11.** Julia exposes the exact ten typed contract families, ordered plan rows,
    compiled-state classification, and four distinct pre-execution rejection codes. A validated family map is
    authoritative on every generated root/nested rule entry and selects regex/acode versus blind/bcode dispatch;
    native calls retain structure-derived behavior. Generated trace adds portable enter/decision/exit roles with
    source/rule/family identity beside native trace. One emitted all-family module runs in a fresh caller-owned
    offline project and equals ten native interpreter values. Focused family 27/27 plus scaffold 18/18 and package
    1,155 assertions pass; complete Julia gate result is recorded below. Census remains 59/0/1 until `.3.4.3`.
  Commit: `FUTURE-PARITY-BACKLOG.3.4.2 - add Julia generated family execution`

- ID: `FUTURE-PARITY-BACKLOG.3.4.3`
  Status: `done`
  Goal: Admit generated Julia source against manifest-backed oracle fixtures.
  Acceptance: Run the neutral curated subset through interpreter-first exact comparison, emitted-source
    include/compile-run, complete Julia gates, docs/KM/no-drift, and cleanup; promote Julia's generated-source gap
    only after all contract families pass.
  Verification: **PASS 2026-07-11.** The test reads the exact eight names from contract v1 and verifies membership
    in the 105-case manifest. Each ordinary/staged spec compiles and equals checked-in expected JSON through the
    native interpreter before emission. One fresh caller-owned offline host loads eight emitted modules in separate
    namespaces and verifies exact values, metadata, ordered plans, portable trace roles, and source identity, then
    recursively deletes project/depot state. The checker locks count, contract consumption, interpreter-first
    ordering, v1 emission, independent include, trace/identity, cleanup, and no skip. Focused 13+27+18 and package
    1,168 assertions pass; complete Julia gate is 61x2 CLI and 105/105 corpus. Julia promotes gap to pass; capability
    and generated-source census is 60/0/0, `.3.4` closes, and exact final admission `.3.5` activates.
  Commit: `FUTURE-PARITY-BACKLOG.3.4.3 - admit generated Julia source`

- ID: `FUTURE-PARITY-BACKLOG.3.5`
  Status: `done`
  Goal: Admit exact generated-source parity across all four implemented backends.
  Acceptance: Perl, Rust, Dart, and Julia satisfy the same versioned neutral contract; Rust proves all 105 manifest
    fixtures and Dart/Julia prove the accepted manifest subset plus all structural families; full backend gates,
    capability checker, docs/book/KM/roadmap, and artifact cleanup pass; promote the census to 60/0/0, close `.3`,
    and only then activate Lua `.1.3`.
  Verification: **PASS 2026-07-11.** Executable contract/capability checkers report 60/0/0. Focused generated-
    source proof passes Perl 69 assertions, Rust 5/5, Dart 6/6, and Julia 58/58. The immediately adjacent complete
    gates pass Perl Phase 0 `1..1030` plus 61x2 CLI, strict recurring Rust 105/105 generated breadth plus complete
    runtime/CLI suites, Dart 181/61x2/105, and Julia 1,168/61x2/105. Roadmaps, mdBook, KM, task/live docs, memory,
    doctrines, whitespace, and artifact cleanup pass. Removed 1.17 GB Rust debug deps/incremental plus Dart/Julia
    caches. No behavior code changed. `.3` closes and Lua parity plan `.1.3` becomes active after this commit.
  Commit: `FUTURE-PARITY-BACKLOG.3.5 - close generated-source parity`

- ID: `FUTURE-PARITY-BACKLOG.4`
  Status: `done`
  Goal: Decide and implement user-function and callable-signature extension topics beyond the MVP.
  Children: `.4.0`, `.4.1`, `.4.2`, `.4.3`, `.4.4`
  Acceptance: Fixed versus semantically variadic helper/method/function signatures are explicit; user-defined
    functions have one unambiguous definition-time variadic parameter form and deterministic runtime binding.
    Recursive functions, closures/lambdas/currying, namespaces, alternate spellings, optional zero-arg parens,
    brace-less bodies, and caller-mutating forms are each accepted, rejected, or split with explicit `.spec`
    contract and parity obligations before code.
  Verification: **PASS 2026-07-12.** ADR 0030 and one recurring neutral contract define the final `...rest`
    syntax, exact-v1/variadic-v2 records, positional eager evaluation, fresh typed rest arrays, and purpose-specific
    callable bounds. Perl, Rust, Dart, and Julia pass the unchanged native/generated fixture. `.4.4` reconciles
    capability/roadmap/book/KM/live state and routes Lua native execution to `.5.1`, descriptor admission to `.5.3`,
    and generated preservation/execution/admission to `.8` without claiming Lua behavior early.
  Commit: closed by `.4.1`, backend child commits, and `.4.4`

- ID: `FUTURE-PARITY-BACKLOG.4.0`
  Status: `done`
  Goal: Audit callable arity ownership and split variadic user-function design before behavior code.
  Acceptance: Inspect the `.spec` function-definition grammar, neutral descriptor/body-job shape, callable
    contract registries, call validation, and runtime binding in Perl/Rust/Dart/Julia plus the Lua parity plan;
    distinguish purposefully unbounded helpers/methods from exact-arity operations; record the director's
    2026-07-12 directive durably; split neutral syntax/semantics, admitted-backend rollout, and Lua parity without
    choosing syntax from one host language by accident.
  Verification: **PASS 2026-07-12.** Knowledge Map retrieval, ADRs `0017`/`0023`, direct
    `LinkedSpec::Get(..., return_descriptor => 1)` plus `runtime_ctx_ref` probes, and source inspection across the
    grammar, staged shell/payload/job, exact outward descriptor contract, registries, validators, compiled records,
    native/generated runtimes, and Lua invocation-frame seam located every arity owner. Purposefully unbounded
    built-ins already use minimum/open-maximum contracts; receiver methods inject the receiver into the same
    helper contract. User functions alone hard-code exact `arity` at every layer and reject duplicate names, so
    this is one signature evolution rather than overload resolution. Unrecognized rest syntax returns `undef` with
    structured `compiler_pipeline:function_registry` detail, not a swallowed error. Neutral contract `.4.1`,
    Perl/Rust `.4.2.1-.2`, Dart/Julia `.4.3.1-.2`, and final Lua/no-drift routing `.4.4` are mechanism-sized.
  Commit: `FUTURE-PARITY-BACKLOG.4.0 - split variadic callable signatures`

- ID: `FUTURE-PARITY-BACKLOG.4.1`
  Status: `done`
  Goal: Adopt a backend-neutral variadic callable and user-function definition contract.
  Dependencies: `.4.0`
  Acceptance: One grammar-owned definition syntax marks at most one final variadic parameter; descriptors preserve
    fixed parameters plus the rest binding; call validation defines minimum arity, eager ordered evaluation, empty
    rest values, recursion/diagnostics, method receiver interaction, and collision behavior through executable
    neutral fixtures before runtime changes.
  Verification: **PASS 2026-07-12.** ADR `0030` adopts `fn name(fixed, ...rest) { ... }` with one final marker/name
    token, positional eager calls, a fresh typed rest array, exact version-1 fixed functions, and version-2
    variadic `callable_signature` records. The neutral JSON contract covers three definitions, nine valid/invalid
    calls, seven malformed signatures, purpose-specific helper/method bounds, descriptor/staged evolution, mixed
    value preservation, empty rest, and result receiver chaining. Its independent Python checker validates and
    deterministically renders the future `.spec` fixture and is required by canonical local CI. Capability census
    keeps current exact functions at pass and owns variadic behavior as future until backend rollout.
    Canonical local CI passes the new recurring checker, both Perl CLI environments at 61/61, and Phase 0
    `1..1030` in 668 wallclock seconds.
  Commit: `FUTURE-PARITY-BACKLOG.4.1 - adopt variadic callable contract`

- ID: `FUTURE-PARITY-BACKLOG.4.2`
  Status: `done`
  Goal: Implement variadic user-function signatures on Perl and Rust.
  Children: `.4.2.1`, `.4.2.2`
  Dependencies: `.4.1`
  Acceptance: Both frontends, registries, staged descriptors, runtimes, generated-source paths, and diagnostics
    consume the unchanged neutral contract while preserving exact-arity fixed functions and purpose-specific
    helper/method arities; focused and complete gates pass.
  Verification: **PASS 2026-07-12.** Perl `.4.2.1` and Rust `.4.2.2` consume the unchanged neutral contract from
    their spec-owned frontend through staged/public descriptors and native/generated execution. Fixed v1 exact
    arity and v2 fixed-prefix/rest semantics, fresh arrays, ordered evaluation, mixed values, receiver chaining,
    invalid definitions, and diagnostics are recurring-gate covered on both reference variants.
  Commit: closed by child commits `.4.2.1` and `.4.2.2`

- ID: `FUTURE-PARITY-BACKLOG.4.2.1`
  Status: `done`
  Goal: Implement the neutral variadic signature in the Perl reference frontend, descriptor, and generated calls.
  Dependencies: `.4.1`
  Acceptance: The spec-owned shell, registry normalization, staged records, ActionIR resolution, eager call
    lowering, fresh local binding, exact fixed-function diagnostics, public descriptor, and generated source pass
    every neutral case without broad host-Perl fallback or caller capture.
  Verification: **PASS 2026-07-12.** The spec-owned shell emits version-2 function/signature records while fixed
    version-1 records remain exact. Registry validation preserves the same signature through staged payload/job
    and outward descriptor fields. Generated Perl evaluates every argument once left-to-right, binds fixed values,
    and allocates one fresh rest array per invocation. The 66-assertion contract-consuming test passes both grammar
    owners and all valid
    neutral results, descriptor/source roles, seven malformed definitions, fixed-extra/variadic-minimum diagnostics,
    empty/mixed rest values, fresh identity, and receiver chaining. The fixture exposed and this leaf corrected a
    pre-existing Perl drift: documented array `.length()` used scalar address-string length; the shared lowerer now
    returns array cardinality while preserving scalar length. The first complete Phase 0 run measured only 13
    stale exact-source assertions in one outer subtest; after migrating those locks, canonical local CI passes the
    recurring 66 assertions, both 61-case CLI environments, and Phase 0 `1..1030` in 710 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.4.2.1 - implement Perl variadic functions`

- ID: `FUTURE-PARITY-BACKLOG.4.2.2`
  Status: `done`
  Goal: Implement the unchanged neutral variadic signature in Rust native and generated execution.
  Dependencies: `.4.2.1`
  Acceptance: Parsed/compiled/described signature fields, registry-first call resolution, eager evaluation, typed
    rest-array binding, exact fixed-function diagnostics, recursion fences, receiver continuation, source emission,
    and oracle/full gates match the Perl reference and neutral fixture.
  Verification: **PASS 2026-07-12.** Rust carries one typed `CallableSignature` through parsed and compiled
    function records, exact v2 staged sidecars, public descriptor projection, serialized compiled state, emitted
    source, and generated-plan execution. Registered variadic calls enforce the fixed-prefix minimum, eagerly
    evaluate authored arguments once left-to-right, bind fixed values in fresh local stores, and bind every extra
    value into a new typed rest array. The contract-consuming seven-test suite passes exact v1/v2 shapes, all
    neutral results, mixed/empty/fresh rest values, receiver continuation, seven invalid definitions, fixed/minimum
    arity diagnostics, compiled round-trip, emitted signature text, and generated execution. The fixture exposed a
    pre-existing Rust drift: generic `length` stringified array values to empty text and returned zero; the shared
    helper now returns array cardinality while retaining Unicode character count for scalar text. Core tests pass
    185 + 3 descriptor + 8 type assertions. The authoritative Rust gate passes 137 runtime units, the 105-fixture
    interpreter oracle, the isolated all-105 generated-source proof, 197 integration tests, all focused runtime
    suites including 7/7 variadic cases, a fresh primary build, and both CLI environments at 61/61.
  Commit: `FUTURE-PARITY-BACKLOG.4.2.2 - implement Rust variadic functions`

- ID: `FUTURE-PARITY-BACKLOG.4.3`
  Status: `done`
  Goal: Implement variadic user-function signatures on Dart and Julia.
  Children: `.4.3.1`, `.4.3.2`
  Dependencies: `.4.1`, `.4.2`
  Acceptance: Both native and generated paths consume the unchanged neutral contract, preserve fixed-function
    diagnostics, and pass package/CLI/corpus/source-emitter gates without host-language rest-argument drift.
  Verification: **PASS 2026-07-12.** Dart `.4.3.1` and Julia `.4.3.2` preserve the unchanged exact-v1/variadic-v2
    union through typed spec/staged records, registry/action resolution, public descriptors, native runtimes,
    normalized generated state, and generated-plan execution. Both reject keyword arguments for registered
    functions, bind fresh rest arrays after ordered evaluation, and pass complete package/CLI/corpus gates.
  Commit: closed by child commits `.4.3.1` and `.4.3.2`

- ID: `FUTURE-PARITY-BACKLOG.4.3.1`
  Status: `done`
  Goal: Implement the unchanged neutral variadic signature in Dart native and generated execution.
  Dependencies: `.4.2`
  Acceptance: Spec projection, registry/action contracts, runtime rest binding, descriptors, generated source,
    exact fixed-function diagnostics, and complete Dart gates consume the shared contract without Dart-specific
    optional/named/rest behavior.
  Verification: **PASS 2026-07-12.** Dart carries a typed `CallableSignature` through spec-owned shell projection,
    `FunctionDefinition`, `StagedParseJob`, registry/action resolution, public descriptor projection, normalized
    emitted state, generated-plan execution, and generated JSON reconstruction. Registered calls reject keyword
    arguments, preserve exact v1 diagnostics, enforce v2 minimum arity, eagerly evaluate values once left-to-right,
    and bind a fresh copied list of extras in the existing function-local store swap. Six contract tests cover
    exact v1/v2 records and staged copies, every neutral result, receiver continuation, mixed/empty/fresh arrays,
    seven invalid definitions, keyword rejection, fixed/minimum arity diagnostics, emitted Base64 state, direct
    generated execution, and round-trip reconstruction. The authoritative Dart gate passes strict format/analyze,
    190 package tests, both CLI environments at 61/61, and all 105 corpus fixtures.
  Commit: `FUTURE-PARITY-BACKLOG.4.3.1 - implement Dart variadic functions`

- ID: `FUTURE-PARITY-BACKLOG.4.3.2`
  Status: `done`
  Goal: Implement the unchanged neutral variadic signature in Julia native and generated execution.
  Dependencies: `.4.3.1`
  Acceptance: Spec projection, registry/action contracts, runtime rest binding, descriptors, generated source,
    exact fixed-function diagnostics, and complete Julia gates consume the shared contract without Julia splat or
    dispatch behavior leaking into `.spec` semantics.
  Verification: **PASS 2026-07-12.** Julia carries a typed `CallableSignature` through `FunctionDefinition`,
    `StagedParseJob`, exact shell and staged validation, registry/action resolution, public descriptor projection,
    normalized emitted JSON, generated-plan execution, and generated-state reconstruction. Registered calls reject
    keyword arguments, retain exact v1 arity, enforce the v2 fixed-prefix minimum, evaluate positional arguments
    once left-to-right, and bind a fresh typed vector of extras into fresh function-local scalar/array stores.
    The 55-assertion neutral suite covers exact v1/v2 records, every result, mixed/empty/fresh rest arrays, receiver
    continuation, seven invalid definitions, keyword rejection, fixed/minimum diagnostics, emitted hex state,
    direct generated execution, and round-trip reconstruction. The authoritative Julia gate passes all package
    tests, the exact 61x2 primary CLI matrix, and all 105 corpus fixtures.
  Commit: `FUTURE-PARITY-BACKLOG.4.3.2 - implement Julia variadic functions`

- ID: `FUTURE-PARITY-BACKLOG.4.4`
  Status: `done`
  Goal: Close callable-arity no-drift and route Lua variadic parity to its dependency-complete owner.
  Dependencies: `.4.2`, `.4.3`
  Acceptance: Public docs, mdBook, Knowledge Map, neutral capability data, and four admitted backends agree on
    exact versus unbounded signatures; Lua's frontend/runtime/generated-source obligations are added to the
    existing Lua task tree at the first dependency-complete function leaf rather than claimed prematurely.
  Verification: **PASS 2026-07-12.** Current source/tests/descriptors and the callable checker prove exact v1 and
    variadic v2 behavior across Perl, Rust, Dart, and Julia native/generated paths. Stale capability README/manifest,
    roadmap, mdBook, Knowledge Map, live status, and task/index rollout text now name those four implementations.
    Lua already owns the spec shell, exact registry, isolated invocation frame, and compiled descriptor but does not
    dispatch function bodies; therefore `.5.1` is the first dependency-complete native variadic owner. `.5.3`
    explicitly owns descriptor admission, `.8.1` normalized generated-state preservation, `.8.2` independent
    generated execution of the neutral fixture, `.8.3` recurring proof, and `.8.4` capability retirement. The
    capability checker now discovers owners from both the future and Lua task trees, so the future manifest points
    directly at `.5.1`. The callable/capability/KM/memory/doctrine/task/whitespace/mdBook checks and unchanged
    dual-ABI Lua gate pass.
  Commit: `FUTURE-PARITY-BACKLOG.4.4 - close variadic callable routing`

### `FUTURE-PARITY-BACKLOG.4.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The four admitted implementations were green, but capability and roadmap surfaces
  still described Rust/Dart/Julia as rollout work and Lua had no explicit variadic obligations in its later leaves.
- [x] **ROOT CAUSE (WHY + WHERE)** — Lua's existing `.2.4` shell and `.3.3` registry deliberately stop before body
  dispatch; routing variadic behavior there retroactively would bypass its helper/value/control dependencies.
- [x] **FIX** — Keep Lua capability future and route native callable execution to `.5.1`, exact descriptors to
  `.5.3`, generated preservation/execution to `.8.1-.3`, and final capability retirement to `.8.4`; let the
  capability checker validate owner IDs from both task trees.
- [x] **ADDRESSED (verified)** — Four backend contract tests/gates remain authoritative; the neutral checker and
  no-drift scans agree, and every remaining Lua signature/native/generated/admission obligation has one owner.
- [x] **NO REGRESSION** — Planning/no-drift only: no parser, registry, runtime, descriptor, fixture, or generated-
  source behavior changed; Lua's current scalar numeric frontier and dual-ABI proof remain unchanged.
- [x] **LOCKSTEP** — Capability data, roadmap, task trees/index, README/book, Knowledge Map, changes/notes/live,
  and bounded memory close `.4` and return PNT to Lua `.4.3.3.1.4`.

### `FUTURE-PARITY-BACKLOG.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct descriptor and malformed-signature probes show fixed functions expose exact
  `arity`, while unrecognized rest spellings fail in the spec-owned definition shell.
- [x] **ROOT CAUSE (WHY + WHERE)** — Exact arity is copied through the grammar AST, staged payload/job, outward
  descriptor schema, every backend AST/compiled registry, call resolver, runtime frame, and generated-source state;
  loosening one runtime length check would create descriptor/compiler/runtime drift.
- [x] **FIX** — No behavior fix belongs in this audit. Split one neutral versioned signature/fixture owner, then
  Perl, Rust, Dart, and Julia implementation leaves, followed by Lua dependency routing and final no-drift.
- [x] **ADDRESSED (verified)** — Existing built-in `min,max` arity tables prove purpose-specific open maxima already
  exist; receiver methods use effective helper arguments. User functions are unique-name, non-overloaded calls and
  therefore need one optional final rest binding rather than host overload/splat semantics.
- [x] **NO REGRESSION** — Read-only LinkedSpec probes and source/contract inspection only; no grammar, descriptor,
  parser, runtime, generated-source, fixture, capability, or backend-status behavior changed.
- [x] **LOCKSTEP** — Task/index, roadmaps, architecture/live docs, mdBook status, Knowledge Map, changes/notes, and
  memory identify neutral contract `.4.1` as the sole active variadic frontier.

### `FUTURE-PARITY-BACKLOG.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.0` proves no neutral representation can express a fixed prefix plus unbounded
  rest without reinterpreting exact version-1 `arity`.
- [x] **ROOT CAUSE (WHY + WHERE)** — The staged/public/backend contract modeled only `params`/`arity`; helper open
  maxima existed separately and could not safely define user-function syntax or binding.
- [x] **FIX** — ADR 0030 plus `linkedspec-callable-signature-v1` select final `...IDENTIFIER`, version-2 signature
  records, eager positional calls, typed rest arrays, exact fixed functions, and stable diagnostics.
- [x] **ADDRESSED (verified)** — Independent checker validates three definitions, nine calls, seven invalid
  definitions, v1/v2 descriptor roles, representative helper/method purpose, exact expected bindings, and rendered
  `.spec` source; the checker and contract are recurring canonical-CI inputs.
- [x] **NO REGRESSION** — No backend parser/compiler/runtime behavior changed; current exact-function capability
  remains pass at census 60/0/0, canonical CI passes 61x2 CLI plus Phase 0 `1..1030` in 668 seconds, and variadic
  behavior is explicitly future/owned during rollout.
- [x] **LOCKSTEP** — ADR/index, task/index/roadmaps, README/TOOLBOX, capability data, mdBook, Knowledge Map,
  architecture/live docs, changes/notes, memory, checker, and CI agree; Perl reference `.4.2.1` is active.

### `FUTURE-PARITY-BACKLOG.4.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The unchanged neutral fixture initially produced correct rest arrays but
  `all_values(1, 2, 3).length()` returned Perl's array-reference address-string length (`18`) instead of `3`.
- [x] **ROOT CAUSE (WHY + WHERE)** — The function shell/registry/lowerer knew only v1 `params`/`arity`; additionally,
  the shared Perl `length` lowerer ignored the documented array value case and always invoked scalar `length`.
- [x] **FIX** — Parse final `...rest` into v2 signatures, validate/preserve them through staged/outward records,
  enforce min/exact arity, lower arguments to ordered temporaries, bind a fresh array from extras, and make the
  common length helper dispatch arrays to cardinality.
- [x] **ADDRESSED (verified)** — `t/variadic_user_function_contract.t` consumes the adopted JSON contract and passes
  66 assertions covering both grammar owners, exact v1/v2 keys, staged signatures, generated source, valid results, fresh identity,
  left-to-right single evaluation, seven invalid signatures, and fixed/variadic wrong-arity diagnostics.
- [x] **NO REGRESSION** — Fixed function records retain the exact outward v1 keys and diagnostics; scalar length is
  unchanged; canonical CI passes 66 focused assertions, 61x2 CLI, and Phase 0 `1..1030` in 710 seconds; no
  Rust/Dart/Julia/Lua behavior or capability census status changes in this backend-local leaf.
- [x] **LOCKSTEP** — Grammar/runtime/test/CI, task/index/roadmaps, README/TOOLBOX, mdBook, Knowledge Map, live docs,
  changes/notes, and memory agree that Perl is implemented and Rust `.4.2.2` is active.

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
  Children: `.7.0`
  Acceptance: Triage richer `pplugin`, `tkgui`, `sdce`, recursive `tablegrep`, single-line `simenv`,
    VHDL port-clause, `ds_vhistory` branch, and placeholder `verilog` candidates; promote only
    JSON-safe, portable fixtures or split root-cause leaves.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.7.0`
  Status: `pending`
  Goal: Calibrate the oracle generator's default process timeout to current shipped-spec parser-build costs.
  Acceptance: Measure the slowest current shipped-spec parser construction separately from input parsing; select
    a documented default with bounded headroom so the complete 105-case generator succeeds without an environment
    override; retain the per-case fork plus `SIGKILL` guard and the `ORACLE_TIMEOUT=0` hard-kill proof; update the
    Knowledge Map, generator usage, corpus documentation, and recurring verification command together.
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

- ID: `FUTURE-PARITY-BACKLOG.11`
  Status: `active`
  Goal: Make codeblock a first-class callable value and correct trailing blocks to the generic final-codeblock model.
  Children: `.11.0`, `.11.1`, `.11.2`, `.11.3`, `.11.4`, `.11.5`, `.11.6`, `.11.7`
  Acceptance: The director's four-kind model—scalar, array, harray, and codeblock—is durable; a callable signature,
    not a parser hard-code for a particular helper name, decides whether its final argument may be a codeblock;
    `call(args) { block }` is semantically equivalent to `call(args, { block })`, including receiver methods and
    user/helper functions; every implemented and future variant exposes identical parsing, validation, evaluation,
    diagnostics, and API behavior.

- ID: `FUTURE-PARITY-BACKLOG.11.0`
  Status: `done`
  Goal: Audit and capture the director's generic final-codeblock argument correction without changing behavior or
    pivoting from `.1.5.1.6.2`.
  Acceptance: Record current Perl/Rust/Dart/Julia behavior, the absent Lua implementation, the contradiction in
    closed `SPEC-FORMAT-TERSE.14`, the required syntax equivalence, and the explicit design question of retaining
    `with` as an ordinary block-taking helper versus removing it. Update roadmap/live docs, mdBook, resume pointer,
    and Knowledge Map; make no parser/runtime code change; keep `.1.5.1.6.2` active.
  Verification: **PASS 2026-07-10.** Knowledge Map generation/check, memory architecture, task-tree metadata,
    doctrine, whitespace, mdBook build, and generated-book cleanup pass. LinkedSpec lowering probes plus current
    task/source/test facts establish the narrow existing surface and parenthesized-form rejection. No parser,
    compiler, runtime, fixture, or backend behavior changed; `.1.5.1.6.2` remains active.
  Commit: `FUTURE-PARITY-BACKLOG.11.0 - capture generic trailing codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.1`
  Status: `done`
  Goal: Design and split generic final-codeblock argument parity before implementation.
  Acceptance: Define the four value kinds precisely, including whether public terminology is `harray` or the
    current `hash`; define the callable-signature declaration for final `codeblock`; make attached and
    parenthesized forms one canonical AST/IR shape; specify evaluation timing, block-local return, lexical/runtime
    context, receiver behavior, arity and non-final diagnostics, and hash-literal disambiguation; decide whether
    `with` remains as an ordinary helper, is migrated, or is removed; inventory every existing block-taking helper
    and method; split reference plus Rust/Dart/Julia/Lua parity and neutral conformance fixtures before code.
  Verification: **PASS 2026-07-12.** The director selected `{|args| ...}` over constructor/arrow/fn alternatives
    and selected dynamic caller context without lexical capture for the initial contract. ADR 0031 fixes exact
    `{|` prefix disambiguation from `{}`/`{ key : value }` harrays and `{ statements }` immediate blocks; `{|| ...}`
    is the zero-parameter literal and final `...rest` reuses ADR 0030. Codeblock construction stores typed
    signature/body/source only and executes nothing. `cb(args)` evaluates positional arguments once left-to-right,
    installs copied parameter/rest values as temporary bindings, executes against the caller's current nonparameter
    stores, restores parameter names, returns the block-local result, and rejects keyword calls, non-codeblock
    values, and recursion. Static helpers/controls/user functions retain resolution precedence over variable calls.
    `with` remains an ordinary block-taking helper. Neutral contract, Perl, Rust, Dart, Julia, and Lua-routing/
    closeout leaves are split before behavior code; callable checker, governance checks, and mdBook build pass.
  Later correction 2026-07-12 (`.11.3.3.0`/`.1`): this design fixed the semantic requirement but did not define
    the source/schema declaration for a final contextual codeblock parameter. ADR 0032 now selects final-only
    `name: codeblock`; it deliberately does not duplicate the supplied value's own signature.
  Commit: `FUTURE-PARITY-BACKLOG.11.1 - design callable codeblock literals`

- ID: `FUTURE-PARITY-BACKLOG.11.2`
  Status: `done`
  Goal: Adopt a backend-neutral callable-codeblock syntax, AST/signature schema, and executable fixture.
  Dependencies: `.11.1`
  Acceptance: ADR 0031's `{|params| body }` / `{|| body }` syntax, final `...rest`, exact prefix disambiguation,
    deferred construction, dynamic caller context, temporary copied params, ordered positional calls, block-local
    return, result chaining/discard, recursion/non-callable/keyword diagnostics, static-name precedence, contextual
    final-block sugar, and retained `with` behavior are machine-readable and independently checked before runtime
    changes. The contract distinguishes explicit callable literals from harrays and immediate block expressions and
    defines canonical AST/descriptor/generated-state fields without host closure/function objects.
  Verification: **PASS 2026-07-12.** `linkedspec-callable-codeblock-v1` contains seven canonical literals, eleven
    call cases, nine invalid literals, seven invalid calls, four contextual final-block cases, exact brace
    classification, typed AST fields, and one deterministic future `.spec`/result fixture. Its independent checker
    reuses the adopted signature parser, models dynamic stores/temporary restoration without a host closure,
    reproduces fixture source/results, and is wired into canonical local CI. The complete gate passes both 61-case
    CLI environments and Phase 0 `1..1030` in 716 seconds. Capability remains future-owned.
  Commit: `FUTURE-PARITY-BACKLOG.11.2 - adopt callable codeblock contract`

- ID: `FUTURE-PARITY-BACKLOG.11.3`
  Status: `done`
  Goal: Implement callable codeblock literals and generic final-codeblock calls on the Perl reference.
  Children: `.11.3.1`, `.11.3.2`, `.11.3.3`, `.11.3.4`
  Dependencies: `.11.2`
  Acceptance: Perl consumes the unchanged neutral contract without broad host coderef fallback or lexical capture;
    current hash/immediate-block semantics, user functions, helpers, receiver calls, and generated-source behavior
    remain stable.
  Verification: **PASS 2026-07-12.** Leaves `.11.3.1` through `.11.3.4` parse, preserve, invoke, normalize, and
    close callable codeblocks on the Perl reference without raw-host fallback, unresolved helpers, stored coderefs,
    lexical capture, parser method allowlists, or brace-classification drift. The final canonical proof passes the
    60/0/0 capability census, both 61-case CLI environments, and Phase 0 `1..1030`.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.1`
  Status: `done`
  Goal: Parse and lower typed callable-codeblock literal/signature values on Perl.
  Acceptance: `{|...|...}` is a dedicated typed AST value with exact spans/body/signature; assignment, copying,
    function arguments/results, and generated state preserve it without executing its body or confusing brace forms.
  Verification: **PASS 2026-07-12.** Exact `{|` recognition precedes current harray/eager-block classification.
    Valid literals expose only the neutral eight fields with typed body/signature and containing-expression spans;
    all nine malformed contract forms retain their exact codes. Canonical UTF-8 JSON serialized as ASCII hex
    reconstructs inert plain data in generated Perl, avoiding host closures, interpolation, and later rewrite
    mutation. Assignment/copy and user-function argument/result round trips pass 126 focused assertions; existing
    ActionIR parser tests remain green. Canonical CI passes 61x2 CLI and Phase 0 `1..1030`/575s. `cb(args)` remains
    intentionally owned by `.11.3.2`.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.1 - parse Perl callable codeblock literals`

- ID: `FUTURE-PARITY-BACKLOG.11.3.2`
  Status: `done`
  Goal: Execute Perl codeblock-variable calls with dynamic caller context.
  Acceptance: `cb(args)` resolution, ordered evaluation, copied temporary params/rest, restoration, caller-visible
    nonparameter mutation, block-local return, chain/discard, recursion and typed failures match the neutral fixture.
  Verification: **PASS 2026-07-12.** The unchanged neutral fixture passes in live and independently loaded
    generated execution. Static helper/user-function precedence, canonical value-drop classification, receiver
    continuation, copied fixed/rest arguments, restoration on success/failure, caller-visible mutation, local
    return, and typed arity/keyword/not-callable/recursion/body-call errors are locked. Focused callable/ActionIR/
    variadic/generated-source proof passes 97 top-level tests; canonical CI passes the 60/0/0 capability census,
    both 61-case CLI environments, and Phase 0 `1..1030` in 815 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.2 - execute Perl callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3`
  Status: `done`
  Goal: Generalize Perl final-codeblock call syntax through callable signatures.
  Children: `.11.3.3.0`, `.11.3.3.1`, `.11.3.3.2`
  Acceptance: Attached and parenthesized contextual final blocks normalize to the same callable-codeblock AST;
    helper/user-function/receiver signatures—not `with` name checks—govern acceptance, while `with` remains ordinary.
  Verification: **PASS 2026-07-12.** ADR 0032's final-only `name: codeblock` declaration is preserved through
    grammar, registry, descriptors, ActionIR normalization, runtime execution, and independently loaded generated
    source. Attached and parenthesized helper/user-function/receiver forms share one canonical argument shape.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3.0`
  Status: `done`
  Goal: Audit and split the missing final-codeblock signature-declaration contract before behavior code.
  Acceptance: LinkedSpec probes establish whether helpers, user functions, and receiver methods expose a typed
    final-codeblock declaration; any missing design choice is durably isolated before parser/lowering changes.
  Verification: **PASS 2026-07-12.** Attached and parenthesized `with` already parse to the same final `block_value`
    payload, but only the attached form is flagged. Fixed user-function records expose names/arity only, helper
    arities live in lowering tables, and receiver parsing is explicitly name-gated. No schema declares that a final
    parameter accepts contextual codeblock sugar. The audit initially overreached by also requesting a nested
    callback signature; director clarification in `.1` correctly leaves that signature on the value. Design leaf `.1`
    and implementation leaf `.2` are split; no behavior code changed.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.0 - split final codeblock signature declaration`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3.1`
  Status: `done`
  Goal: Define the callable declaration for a final contextual codeblock parameter.
  Acceptance: One backend-neutral declaration/schema covers helpers, user functions, and receiver methods; it
    leaves the callback's own parameter signature on the supplied codeblock value, remains compatible with
    duck-typed runtime values, rejects non-final declarations, and updates ADR/neutral contract before behavior.
  Verification: **PASS 2026-07-12.** Director clarification selects exact `callback: codeblock` with no nested
    argument list. ADR 0032 makes it final-only, keeps ordinary parameters duck-typed, leaves `{|params| ...}` as
    the sole owner of an explicit value's invocation signature, and defines contextual blocks as zero-positional
    dynamic-context values. The strict neutral checker passes 7 literals, 11 calls, 9 malformed literals, 7 invalid
    calls, 4 invalid declarations, and 8 helper/user-function/receiver contextual forms.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.1 - declare final codeblock parameters`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3.2`
  Status: `done`
  Goal: Implement signature-governed attached/parenthesized final-codeblock normalization on Perl.
  Acceptance: Perl consumes `.1` without name-gated parser exceptions; equivalent helper/user-function/receiver
    spellings share canonical AST/IR, preserve harray/immediate blocks, execute through generated source, and
    produce typed declaration/arity/final-argument diagnostics.
  Verification: **PASS 2026-07-12.** The wrapper-free grammar emits fixed parameters plus the final codeblock name;
    registry validation projects exact ordered `params`/`arity`, and typed definitions plus both staged records
    preserve final `parameter_kinds`. `LinkedSpec::CallableContract` declares helper/receiver/user-function acceptance, generic
    receiver parsing no longer grants semantics by method name, and lowering gives attached/parenthesized
    contextual blocks one zero-positional `codeblock_argument`. Helper, typed user-function, receiver `with`, tree
    traversal, explicit literals, harray rejection, four declaration failures, and standalone generated execution
    pass focused proof; adjacent ActionIR/variadic/generated-source tests remain green.
    During implementation, director clarification reaffirmed that `set(target, value)` must evaluate to the
    target's post-assignment typed value for method chaining. Existing assignment-value probes agree, while the
    remaining `.spec`-facing `array(name)` / `hash(name)` namespace and mutation forms are scheduled for removal
    under `.12.1`; this leaf does not broaden into that public-surface migration.
    Direct Phase 0 passes all `1..1030` in 966 seconds after the wrapper-free grammar and immediate-`with`
    full-breadth preservation repairs. Canonical CI passes capability 60/0/0, CLI 61x2, and Phase 0 `1..1030` in
    916 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.4`
  Status: `done`
  Goal: Close Perl callable-codeblock diagnostics, docs, and full-gate no-drift.
  Acceptance: Neutral/focused/Phase-0/CLI gates pass; no raw Perl, coderef leakage, harray drift, or undocumented
    compatibility remains before Rust parity.
  Verification: **PASS 2026-07-12.** Toolbox probes produce byte-equivalent lowering for attached and
    parenthesized helper/receiver forms, reject unknown receiver semantics after generic structural parsing, and
    expose the typed final parameter in user-function descriptors. Descriptor telemetry reports zero raw-host
    dependencies, fallbacks, compatibility rewrites, and unresolved helpers. Source scans find no parser method
    allowlist, captured environment, or stored coderef field. The four focused suites pass 100 tests; the neutral
    checker, 60/0/0 capability census, both 61-case CLI environments, Phase 0 `1..1030` in 916 seconds, doctrines,
    Knowledge Map, whitespace, and mdBook all pass on the committed Perl behavior.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.4`
  Status: `pending`
  Goal: Implement the unchanged callable-codeblock contract on Rust native and generated execution.
  Children: `.11.4.1`, `.11.4.2`, `.11.4.3`
  Dependencies: `.11.3`

- ID: `FUTURE-PARITY-BACKLOG.11.4.1`
  Status: `pending`
  Goal: Add typed Rust callable-codeblock AST/signature/compiled/serialized state.
  Acceptance: Exact brace disambiguation, spans, signature/body data, validation, descriptors, and source emission
    round-trip without evaluating or encoding a Rust closure.

- ID: `FUTURE-PARITY-BACKLOG.11.4.2`
  Status: `pending`
  Goal: Execute Rust codeblock-variable calls with neutral dynamic context and diagnostics.
  Acceptance: Ordered values, temporary copied bindings/rest, caller nonparameter stores, results, recursion,
    static-name precedence, and failures match Perl and the neutral fixture.

- ID: `FUTURE-PARITY-BACKLOG.11.4.3`
  Status: `pending`
  Goal: Close Rust generic final-block equivalence, generated execution, oracle, docs, and full gates.
  Acceptance: Signature-governed attached/contextual forms and retained `with` pass native/generated/oracle paths.

- ID: `FUTURE-PARITY-BACKLOG.11.5`
  Status: `pending`
  Goal: Implement the unchanged callable-codeblock contract on Dart native and generated execution.
  Children: `.11.5.1`, `.11.5.2`, `.11.5.3`
  Dependencies: `.11.4`

- ID: `FUTURE-PARITY-BACKLOG.11.5.1`
  Status: `pending`
  Goal: Add typed Dart callable-codeblock AST/signature/serialized state and brace disambiguation.

- ID: `FUTURE-PARITY-BACKLOG.11.5.2`
  Status: `pending`
  Goal: Execute Dart codeblock-variable calls with neutral dynamic context and diagnostics.

- ID: `FUTURE-PARITY-BACKLOG.11.5.3`
  Status: `pending`
  Goal: Close Dart generic final-block equivalence, generated execution, docs, and full gates.

- ID: `FUTURE-PARITY-BACKLOG.11.6`
  Status: `pending`
  Goal: Implement the unchanged callable-codeblock contract on Julia native and generated execution.
  Children: `.11.6.1`, `.11.6.2`, `.11.6.3`
  Dependencies: `.11.5`

- ID: `FUTURE-PARITY-BACKLOG.11.6.1`
  Status: `pending`
  Goal: Add typed Julia callable-codeblock AST/signature/serialized state and brace disambiguation.

- ID: `FUTURE-PARITY-BACKLOG.11.6.2`
  Status: `pending`
  Goal: Execute Julia codeblock-variable calls with neutral dynamic context and diagnostics.

- ID: `FUTURE-PARITY-BACKLOG.11.6.3`
  Status: `pending`
  Goal: Close Julia generic final-block equivalence, generated execution, docs, and full gates.

- ID: `FUTURE-PARITY-BACKLOG.11.7`
  Status: `pending`
  Goal: Close four-backend callable-codeblock no-drift and route Lua to dependency-complete owners.
  Dependencies: `.11.3`, `.11.4`, `.11.5`, `.11.6`
  Acceptance: Neutral capability data, docs/book/KM, native/generated proofs, and four admitted backends agree;
    Lua parser/value/control/function/generated obligations are added to its task tree without premature behavior
    claims. Lexical capture remains explicitly deferred and requires a new decision/task if later justified.

### `FUTURE-PARITY-BACKLOG.11.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Current braces distinguish harrays and eager block expressions, but no portable
  initializer creates a callable codeblock variable and `cb()` cannot resolve a stored block value.
- [x] **ROOT CAUSE (WHY + WHERE)** — Current codeblocks are immediate/contextual AST payloads with name-gated
  runtime consumers; no literal signature, deferred body value, dynamic variable-call resolver, or capture policy
  crosses the spec grammar, ActionIR, descriptors, native runtimes, and generated source.
- [x] **FIX** — ADR 0031 adopts exact `{|params| body }`, `{|| body }`, optional final `...rest`, dynamic caller
  context, temporary copied parameter bindings, block-local return, static-name precedence, and retained `with`.
- [x] **ADDRESSED (verified)** — Neutral contract, four admitted backend rollouts, and Lua routing/no-drift have
  explicit dependency-ordered leaves before code; lexical capture is explicitly excluded from version 1.
- [x] **NO REGRESSION** — Planning only: no parser, runtime, descriptor, fixture, or generated behavior changed;
  current harray, eager block, `with`, traversal, function, CLI, corpus, and Lua numeric proofs remain authoritative.
- [x] **LOCKSTEP** — ADR/index, task tree/index, roadmaps, README/book, Knowledge Map, changes/notes/live, and memory
  agree that `.11.2` is the first executable-contract leaf.

### `FUTURE-PARITY-BACKLOG.11.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — ADR 0031 had no executable neutral artifact to prevent parser/runtime interpretation
  drift before five backend implementations.
- [x] **ROOT CAUSE (WHY + WHERE)** — Prose alone could not enforce exact brace classification, typed AST fields,
  signature reuse, dynamic invocation/restoration, diagnostic codes, or deterministic fixture bytes/results.
- [x] **FIX** — Add strict `linkedspec-callable-codeblock-v1` JSON plus an independent parser/classifier,
  invocation model, diagnostic validator, and fixture renderer/evaluator in canonical CI.
- [x] **ADDRESSED (verified)** — Seven literals, eleven calls, nine malformed literals, seven invalid calls, four
  contextual forms, three brace kinds, and the future source/result fixture pass the checker.
- [x] **NO REGRESSION** — This leaf admits no backend behavior; the capability remains future-owned by Perl parser
  leaf `.11.3.1`, and current harray/eager-block/named-immediate behavior remains authoritative.
- [x] **LOCKSTEP** — Contract README, capability owner, task/index, roadmaps, README/book, KM, live docs, and memory
  identify the adopted contract and active Perl implementation frontier.

### `FUTURE-PARITY-BACKLOG.11.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct ActionIR parsing classified `{|...|...}` as an immediate block and generated
  lowering had no inert typed value representation.
- [x] **ROOT CAUSE (WHY + WHERE)** — `AST/Parser.pm::_parse_brace_expr` only chose harray versus `block_value`, and
  `MethodLowering.pm` had no pure-data `codeblock_literal` branch. A first Data::Dumper prototype also proved unsafe:
  later rewrite/interpolation changed embedded source strings, so generated source could not preserve exact data.
- [x] **FIX** — Parse exact `{|` first into the neutral eight-field AST/signature record; preserve containing spans;
  emit canonical UTF-8 JSON as ASCII hex and decode to plain data at runtime; retain typed invalid-literal nodes.
- [x] **ADDRESSED (verified)** — The unchanged neutral contract drives 7 valid literals, 9 malformed forms, brace
  classification, inert construction, assignment/copy, and user-function argument/result checks (126 assertions).
- [x] **NO REGRESSION** — Existing ActionIR parser plus the new focused suite pass 26 top-level tests; harray and
  eager block cases retain their kinds; no variable-call invocation or dynamic execution is admitted in this leaf.
- [x] **LOCKSTEP** — Capability owner, task/index, roadmaps, README/book, KM, changes/notes/live, and memory route
  the remaining Perl invocation semantics to active `.11.3.2`.

### `FUTURE-PARITY-BACKLOG.11.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `LinkedSpec::call_spec_handler_subst(...)` lowers a bound `cb(args)` call to
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:cb`, and the unchanged neutral fixture cannot execute on Perl.
- [x] **ROOT CAUSE (WHY + WHERE)** — `ActionIR::MethodLowering` resolves governed helpers and registered user
  functions only; `RuleIR::EmitContext` does not expose scalar working bindings to a typed codeblock executor or
  traverse deferred codeblock bodies when collecting caller slots.
- [x] **FIX** — Add typed record invocation, deterministic ActionIR-body execution over explicit caller binding
  references, static-name precedence, copied temporary fixed/rest bindings, restoration, result/drop/chaining,
  and typed arity/not-callable/recursion failures without storing a Perl coderef in the record.
- [x] **ADDRESSED (verified)** — The contract-sourced Perl fixture and focused invalid-call probes reproduce the
  neutral results, visible nonparameter mutation, parameter restoration, and diagnostic payloads.
- [x] **NO REGRESSION** — Existing callable-literal, ActionIR, user-function, CLI, and Phase-0 gates reach their
  true stops with no new failure set; generated source remains independently executable.
- [x] **LOCKSTEP** — Task/index, capability state, roadmaps, README/book, Knowledge Map, changes/notes/live, and
  bounded memory state describe Perl invocation as current while final-block generalization remains `.11.3.3`.

### `FUTURE-PARITY-BACKLOG.11.3.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Toolbox lowering proves attached `with("x") { ... }` works while the structurally
  equivalent parenthesized `with("x", { ... })` still lowers to an unsupported-helper sentinel.
- [x] **ROOT CAUSE (WHY + WHERE)** — The AST payloads are already equivalent, but no callable schema declares a
  final contextual codeblock parameter: user functions carry only names/arity/rest,
  helpers carry lowering-local arity tables, and receiver parsing hard-codes four method names.
- [x] **FIX** — Split declaration design `.1` from Perl normalization/execution `.2`; do not infer callback intent
  from a body call, ordinary final parameter, parser callee name, or brace contents.
- [x] **ADDRESSED (verified)** — Durable task/KM records enumerate the missing call-parameter kind and route the
  required director choice to `.1`; `.1` corrects the audit's unnecessary nested-signature proposal.
- [x] **NO REGRESSION** — Read-only ActionIR/descriptor/lowering probes only; parser, registry, runtime, generated
  source, neutral fixtures, and current `with`/tree traversal behavior are unchanged.
- [x] **LOCKSTEP** — Task/index, capability owner, roadmaps, README/book, architecture/live docs, Knowledge Map,
  and bounded memory point to active declaration leaf `.11.3.3.1`.

### `FUTURE-PARITY-BACKLOG.11.3.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.0` proves arity alone cannot authorize attached braces and the accepted design had
  no source/schema declaration for the final contextual-codeblock value kind.
- [x] **ROOT CAUSE (WHY + WHERE)** — The first proposal incorrectly duplicated a callback argument signature in
  the receiving slot even though explicit `{|params| ...}` values already own and enforce that signature.
- [x] **FIX** — ADR 0032 selects final-only `name: codeblock`, no nested argument list, zero-positional contextual
  blocks with dynamic caller context, and callable-registry metadata shared by helpers/functions/receiver methods.
- [x] **ADDRESSED (verified)** — The neutral checker locks the exact declaration, four invalid declarations, and
  eight equivalent/helper/user-function/receiver contextual cases while retaining literal-owned signatures.
- [x] **NO REGRESSION** — This is contract/docs/checker only: existing function grammar, descriptors, ActionIR,
  runtime, generated source, current `with`/traversal behavior, and all prior literal/call fixtures are unchanged.
- [x] **LOCKSTEP** — ADR/index, contract/README, task/index, roadmaps, README/book, KM, changes/notes/live, and
  memory agree that Perl behavior `.11.3.3.2` consumes the adopted declaration next.

### `FUTURE-PARITY-BACKLOG.11.3.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Toolbox lowering accepts attached `with(args) { ... }` but rejects its parenthesized
  equivalent; typed user-function syntax is not parsed, and receiver attached blocks are parser name-gated.
- [x] **ROOT CAUSE (WHY + WHERE)** — Function grammar/registry/descriptors lack final parameter kinds, ActionIR
  leaves contextual braces as `block_value`, and helper/receiver lowering dispatches directly on method names.
- [x] **FIX** — Preserve final `name: codeblock` metadata, normalize attached/parenthesized blocks to one typed
  `codeblock_argument`, move helper/receiver acceptance behind callable contracts, and execute contextual user
  callbacks as zero-positional dynamic-context codeblocks through generated source.
- [x] **ADDRESSED (verified)** — Focused helper/user-function/receiver probes cover equivalent AST, values,
  descriptors, explicit literals, harray rejection, typed declaration failures, and standalone generated execution.
- [x] **NO REGRESSION** — Existing fixed/variadic functions, `with`, hash/array traversal, literal invocation,
  ActionIR, CLI, and Phase-0 gates reach their true stops without raw Perl or name-gated parser residue.
- [x] **LOCKSTEP** — Task/index, capability state, roadmaps, README/book, Knowledge Map, changes/notes/live, and
  memory describe generic Perl final-block behavior as current before closeout `.11.3.4`.

### `FUTURE-PARITY-BACKLOG.11.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit the committed Perl callable-codeblock surface for raw host code/coderef
  leakage, harray promotion, parser method-name gates, untyped final-argument failures, and stale public caveats.
- [x] **ROOT CAUSE (WHY + WHERE)** — Classify any residue by grammar, callable metadata, normalization, runtime,
  generated-source, diagnostic, or documentation owner before changing behavior.
- [x] **FIX** — Repair only verified Perl closeout residue; do not expand the accepted neutral contract or begin
  Rust parity, Lua work, or spec-facing aggregate-wrapper retirement inside this leaf.
- [x] **ADDRESSED (verified)** — Neutral/focused/generated/CLI/Phase-0 proof and source scans cover declarations,
  contextual/explicit forms, harray rejection, closure-free records, generic parsing, and standalone generation.
- [x] **NO REGRESSION** — Canonical capability 60/0/0, CLI 61x2, Phase 0 `1..1030`, doctrines, Knowledge Map,
  whitespace, and mdBook reach their true stops on the final committed Perl state.
- [x] **LOCKSTEP** — Close `.11.3` as current Perl behavior, retain overall capability future ownership, and route
  the director-prioritized removal of `.spec` `array(name)` / `hash(name)` semantics to `.12.1` before Rust/Lua.

- ID: `FUTURE-PARITY-BACKLOG.12`
  Status: `done`
  Goal: Retire transitional compatibility surfaces after uniform expression and duck-typed binding semantics settle.
  Children: `.12.0`, `.12.1`
  Acceptance: Backward compatibility is temporary migration scaffolding, never a permanent language constraint;
    every retained compatibility surface has an explicit removal condition and owner. Bare variables carry one of
    scalar/array/harray/codeblock, calls and controls are expressions, runtime value type drives dispatch, and
    `array(name)`/`hash(name)` may not survive as alternate namespaces, type assertions, or mutation authority.
  Verification: **PASS 2026-07-12.** `.12.1.10` closes the only later-found admission omission: all immediate
    component READMEs are now discovered and current selector guidance is zero across 56 public files.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.10 - close backend README selector drift`

- ID: `FUTURE-PARITY-BACKLOG.12.0`
  Status: `done`
  Goal: Capture the director's uniform-expression, duck-typing, and compatibility-retirement doctrine.
  Acceptance: Record the doctrine and current wrapper/storage contradiction without changing active runtime
    behavior or pivoting mid-slice; keep Lua string closeout `.4.3.2.2.5.1` as the execution frontier.
  Verification: **PASS 2026-07-12.** Existing records already own expression-valued assignment, inline if/switch,
    user/helper calls, value-drop, and generic final-codeblock design. Audit confirms the remaining contradiction is
    spec-facing `array(name)`/`hash(name)` selecting alternate read and mutation semantics beside one duck-typed
    binding. This planning slice creates the missing retirement owner; no runtime behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.12.0 - capture compatibility retirement doctrine`

- ID: `FUTURE-PARITY-BACKLOG.12.1`
  Status: `done`
  Goal: Split and execute uniform binding plus spec-facing aggregate-selector retirement.
  Children: `.12.1.0`, `.12.1.1`, `.12.1.2`, `.12.1.3`, `.12.1.4`, `.12.1.5`, `.12.1.6`, `.12.1.7`,
    `.12.1.8`, `.12.1.9`, `.12.1.10`
  Acceptance: Inventory every public and implementation compatibility surface and classify temporary migration
    versus current language; define one variable binding with runtime scalar/array/harray/codeblock identity; make
    pure and mutable helper/method dispatch consume that value without wrapper-selected storage;
    `array(IDENTIFIER)` and `hash(IDENTIFIER)` may not survive as namespace selectors, typed reads, mutation targets,
    or mutation authority; separately classify whether non-selector constructor calls remain or literals replace
    them; migrate wrapper-based targets such as `split(array(parts),...)` to unambiguous bare-target semantics;
    specify expression-valued if/switch/calls and silent value drop as universal invariants; assign
    Perl/Rust/Dart/Julia/Lua, corpus, mdBook, diagnostics, hard-retirement, and final no-drift leaves before behavior
    code.
  Verification: **PASS 2026-07-12.** `.12.1.0-.9` retain their recorded behavior/source/mdBook/capability proof.
    Follow-up `.12.1.10` removes 14 backend-README positives and expands recurring public coverage from 47 to 56
    files with stable inventory and backend bare-binding anchors.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.10 - close backend README selector drift`

- ID: `FUTURE-PARITY-BACKLOG.12.1.0`
  Status: `done`
  Goal: Inventory and split exact spec-facing aggregate-selector retirement before behavior code.
  Acceptance: Count exact selector-shaped source uses separately from constructors; prove current selector-free
    read/mutation gaps with LinkedSpec tools; locate every backend recognition/dispatch seam; split neutral contract,
    five backend enablement leaves, source migration, hard retirement, and final no-drift before implementation.
  Verification: **PASS 2026-07-12; count corrected by `.12.1.7.1`.** There are 600 exact `array(IDENTIFIER)` /
    `hash(IDENTIFIER)` occurrences in 82 tracked `.spec` files, including 210 across 15 shipped specs. The original
    boundary-less scan reported 651/227 because it included 51/17 `flat_array(name)` suffixes. Immediate parents include 172
    `copy`, 158 `push`, 72 `set`, 50 `is_nonempty`, 13 `split`, and smaller mutation/read/helper families; 17 forms
    are receiver expressions. Toolbox lowering proves bare read/method forms already exist on Perl, while
    `push(items, value)` still selects child-rule semantics and `split(parts, source, delimiter)` is unsupported.
    Perl owns selector recognition through `ValueExpr`/`MethodLowering`/`EmitContext`; Rust through
    `resolve_array_target`/`resolve_hash_target` and constructor branches; Dart/Julia through their target-name
    helpers; Lua through `target_descriptor` and constructor branches. No behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.0 - split aggregate selector retirement`

- ID: `FUTURE-PARITY-BACKLOG.12.1.1`
  Status: `done`
  Goal: Adopt a neutral one-binding and aggregate-selector retirement contract before backend changes.
  Acceptance: Fix bare identifier read/write/mutation dispatch by runtime value, absent-binding auto-creation,
    static-rule precedence for ambiguous `push(name, value)`, three-argument mutable `split`, expression-valued
    mutation, and exact `set(target, value)` post-assignment target return. Reject exact selector-shaped calls as
    the future contract while separately classifying zero/multi/quoted/computed array/hash constructors. Provide a
    checked migration table and executable future fixtures without changing current backend behavior.
  Verification: **PASS 2026-07-12.** `linkedspec-uniform-binding-v1` plus its independent checker validate 11
    migration mappings, seven execution cases, six exact invalid selectors, eight retained constructor/literal
    classifications, and deterministic future fixture source/results. The contract fixes one observable typed
    binding, storage neutrality, post-assignment `set` results, updated mutation results, absent-target creation,
    wrong-kind diagnostics, static-rule push precedence, pure/mutable split arities, exact selector rejection, and
    `[value]` for the ambiguous one-element constructor. Canonical CI passes capability 60/0/0, both 61-case CLI
    environments, and Phase 0 `1..1030` in 875 seconds; no backend behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.1 - adopt uniform binding contract`

- ID: `FUTURE-PARITY-BACKLOG.12.1.2`
  Status: `done`
  Goal: Make the Perl reference execute the neutral selector-free binding and mutation contract.
  Acceptance: Bare reads, receivers, set, push/append, hash mutation, split, in-place collection helpers, copy,
    controls, calls, and chaining operate on one observable typed binding; static child-rule push keeps precedence;
    internal host storage layout remains unobservable. Old selectors stay temporary only until source migration.
  Verification: **PASS 2026-07-12.** `LinkedSpec::BindingRuntime` provides copy-on-write typed mutations, absent-
    target creation, and stable mismatch fields. Live and standalone generated fixtures cover set chaining, saved
    mutation results, push/append, mutable/pure split, hash/index updates, collection transforms, static-rule
    precedence, wrong-kind failure, and temporary wrapper compatibility. Focused ActionIR/contract proof passes 38
    tests; the neutral checker passes 11/7/6/8 cases; canonical CI passes doctrines, capability 60/0/0, both 61-case
    CLI environments, and Phase 0 `1..1030` in 821 seconds. No tracked selector source migrates in this leaf.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.2 - enable Perl uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.3`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Rust.
  Acceptance: Native/generated execution and diagnostics match the neutral fixture and Perl without exposing
    `resolve_array_target`/`resolve_hash_target` storage selection as public semantics.
  Verification: **PASS 2026-07-12.** `RuntimeContext` now owns narrow kind-checked bare array/harray mutation
    seams; native and generated-plan execution pass the future fixture, all seven neutral cases, saved independent
    updates, append, array-end result chaining/collection rebinding, static-rule precedence, and stable wrong-kind
    fields in 9 integration tests. Baseline proof found `undef` push results, missing collection rebinding, and
    silent wrong-kind retagging. The first full oracle then localized a statement-only append bypass; routing it
    through the same typed value seam restores the existing `["a", "b"]` fixture. The broad suite then exposed
    exactly one superseded statement-only array-end result lock, now migrated to the adopted updated-value contract.
    Complete Rust gates pass 137 unit, 105/105 oracle, 105/105 generated classification, 197 integration, focused
    suites/build, and CLI 61x2; strict Clippy has 16 pre-existing findings outside changed hunks. Canonical CI passes
    doctrines/contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0 `1..1030` in 786 seconds. Knowledge Map,
    mdBook, continuity, and whitespace checks pass. No selector source migrates; Dart `.12.1.4` activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.3 - enable Rust uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.4`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Dart.
  Acceptance: Bare `ActionVariableExpr` reads and all mutable/pure helper paths observe the same typed binding;
    native/generated/current corpus proof matches the neutral contract.
  Verification: **PASS 2026-07-12.** Dart bare reads now resolve the current typed value across private migration
    stores; kind-checked array/harray seams own push/append, mutable split, hash/index, array-end, and collection
    mutations with independent updated results, absent creation, stable mismatch fields, `set`/mutation chaining,
    and static-rule precedence. Native/generated proof passes the future fixture, seven neutral cases, and two
    extension cases in 9 tests. The first full gate exposed exactly two old boundaries: value-position array-end
    mutation expected `null`, and mixed wrapper/bare hash mutation hid the binding from bare merge. Both locks now
    assert the adopted value/alias semantics. Format/analyze, all 199 tests, generated packages, 105/105 corpus, and
    CLI 61x2 pass. Canonical CI passes doctrines/contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0
    `1..1030` in 892 seconds; docs/KM/governance/whitespace pass. No selector source migrates; Julia `.12.1.5`
    activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.4 - enable Dart uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.5`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Julia.
  Acceptance: `_read_runtime_store` remains the public read model while target/mutation paths converge on the same
    binding; native/generated/current corpus proof matches the neutral contract.
  Verification: **PASS 2026-07-12.** Julia now routes bare assignment, set, push/append, mutable split, hash/index,
    array-end, set-key, and standalone collection mutation through one typed binding seam while retaining private
    migration maps. Missing targets create only the required array/harray kind; incompatible values fail with stable
    `binding_kind_mismatch` fields; mutations return independent updated values and continue through receiver chains;
    static rules retain ambiguous-push precedence. The permanent 9-subtest native/generated suite passes 27/27
    assertions. Its unchanged baseline passed 11 and failed eight exact assertions covering array-end results,
    mutable split, collection rebinding, and wrong-kind rejection. The first full package runs exposed two stale
    locks: value-position `push_back` expected no update, and bare-first hash merge expected only the overlay after
    wrapper/bare mutations. Both now assert the adopted one-binding behavior. The complete Julia gate passes 1,311
    package assertions, CLI 61x2, and 105/105 corpus fixtures. Canonical CI passes doctrines and
    contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0 `1..1030` in 865 seconds. No selector source migrates;
    Lua `.12.1.6` activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.5 - enable Julia uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.6`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Lua before resuming feature parity.
  Acceptance: Existing `lookup_binding` semantics extend through every admitted mutation/helper path; dual-ABI
    focused proof passes without keeping selector forms as a Lua compatibility requirement.
  Verification: **PASS 2026-07-12.** Lua now uses `lookup_binding` plus kind-checked array mutation seams for bare
    push/append, three-argument mutable split, array-end methods, and standalone collection rebinding; hash-index
    mutation rejects incompatible existing values, missing targets create only the required kind, and every mutation
    returns a copied updated binding. Static compiled rules retain ambiguous-push precedence. Minimal pure array
    dispatch supplies the unchanged fixture's `count`/`sorted`/`first`/`trim_each`/`filter_nonempty` continuations.
    Baseline dual-ABI proof passed two and failed seven of the nine exact cases; after repair all nine pass. The first
    full gate exposed one stale lock that required `array(target)` for statement split; it now asserts bare
    three-argument mutation while two-argument split remains pure. PUC Lua and LuaJIT each pass 85/85, the 105-case
    manifest remains exact, the CLI remains explicitly scaffolded, and backend status is
    `runtime-uniform-bindings`. The immediately prior canonical gate passes doctrines/contracts, capability 60/0/0,
    Perl CLI 61x2, and Phase 0 `1..1030` in 865 seconds. No selector source migrates in this leaf; `.12.1.7.1`
    activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.6 - enable Lua uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7`
  Status: `done`
  Goal: Migrate every tracked `.spec` and embedded source away from exact aggregate selectors.
  Children: `.12.1.7.1`, `.12.1.7.2`, `.12.1.7.3`
  Dependencies: `.12.1.2`, `.12.1.3`, `.12.1.4`, `.12.1.5`, `.12.1.6`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7.1`
  Status: `done`
  Goal: Migrate the 15 affected shipped specs and prove their reference/generated behavior.
  Verification: **PASS 2026-07-12.** Boundary-correct baseline is 210 exact occurrences, not the earlier
    boundary-less 227; all 15 shipped specs now scan at zero. Perl pure collection reads were harmonized with the
    scalar-held typed mutation binding after the migrated Lispish CLI exposed legacy `@name` reads. Focused
    live/generated uniform-binding proof passes; all 21 shipped descriptors compile at zero blocker/compatibility
    rules; default/POSIX CLI pass 61/61; mdBook/KM/doctrines pass; canonical Phase 0 passes `1..1031` in 573 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.7.1 - migrate shipped aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7.2`
  Status: `done`
  Goal: Migrate neutral/oracle/corpus `.spec` fixtures and regenerate only derived expectations.
  Verification: **PASS 2026-07-12.** The boundary-correct 390 occurrences in 67 files are removed: five in two
    capability fixtures, 366 in 62 Rust-oracle inputs, and 19 in three legacy corpus inputs. All tracked `*.spec`
    files now scan at zero exact selectors, capability mirrors are byte-identical, and the three intended
    one-element constructions use `[undef]`. Full migration exposed and repaired rule-local `I` initializer scope
    and empty implicit rule accumulators on Rust/Dart/Julia, plus Rust fluent action push and explicit-binding versus
    descriptor-alias behavior; permanent uniform-binding tests lock those seams. Perl live probes preserve the
    EBNF, recursive, and traversal values; Rust passes 105/105 interpreted and 105/105 generated corpus cases plus
    its full package gate; Dart and Julia pass their complete gates and 105/105 corpora; PUC Lua and LuaJIT each
    pass 85/85 while validating the exact 105-case manifest. Canonical doctrines/contracts, capability 60/0/0,
    CLI 61x2, and Phase 0 `1..1031` pass in 574 seconds; mdBook/KM/whitespace pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.7.2 - migrate file-backed selector fixtures`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7.3`
  Status: `done`
  Goal: Migrate embedded test/tool/backend source strings and verify zero executable selector-shaped sources.
  Verification: **PASS 2026-07-12.** All 1,356 positive exact occurrences are removed from 25 embedded
    test/tool/backend source owners. The recurring executable-source checker reports zero positives and 25
    mechanically classified implementation/recognition occurrences reserved for hard retirement. Complete
    Rust, Dart, Julia, and dual-ABI Lua gates pass; focused Perl contracts and generated user-function probes
    pass; the regenerated oracle corpus contains all 105 fixtures. Standalone Phase 0 passes `1..1031` in 920
    seconds, and the canonical local gate passes capability 60/0/0, CLI 61x2, and Phase 0 `1..1031` in 918
    seconds. Knowledge Map, doctrines, task metadata, mdBook, and whitespace checks pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.7.3 - migrate embedded selector sources`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8`
  Status: `done`
  Goal: Hard-retire exact aggregate-selector syntax with one portable diagnostic.
  Children: `.12.1.8.1`, `.12.1.8.2`, `.12.1.8.3`, `.12.1.8.4`, `.12.1.8.5`, `.12.1.8.6`
  Dependencies: `.12.1.7`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.1`
  Status: `done`
  Goal: Reject exact selector-shaped calls at the Perl `.spec` boundary and remove public compatibility dispatch.
  Verification: **PASS 2026-07-12.** The canonical Perl ActionIR boundary now rejects every exact one-bare-
    identifier `array(...)` / `hash(...)` node with `aggregate_selector_removed surface=<...>
    identifier=<...> replacement=<...>` before lowering, including nested/dead rule code and unused user-function
    bodies. Live compilation reports compiler-pipeline failure; generated-source emission preserves the same
    detail. Zero/multi/quoted/computed constructors and direct literals remain valid. Focused Perl proof passes 41
    tests; the whitespace-aware executable-source scanner reports zero positives/19 classified recognizers; the
    regenerated 105-case oracle and Rust corpus replay pass; standalone and canonical Phase 0 each pass `1..1031`
    in 934 seconds, with canonical capability 60/0/0 and CLI 61x2.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.1 - hard-reject Perl aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.2`
  Status: `done`
  Goal: Reject exact selector-shaped calls at the Rust `.spec` boundary and remove public compatibility dispatch.
  Verification: **PASS 2026-07-12.** Recursive typed-AST detection plus whole-`CompiledSpec` validation rejects
    all six neutral exact-selector cases through ordinary/traced compilation, native execution, generated-source
    emission, v1 decode, and legacy generated adapters. Coverage includes dead/nested blocks, unused functions,
    and deferred edge-fluent arguments. The 15-case focused suite preserves all eight constructor/literal classes;
    the executable-source scanner reports zero positives/13 classified rejection sites. Full core/runtime/CLI,
    105 interpreted corpus, final 105 generated classification in 329.32 seconds, integration 197/197, canonical doctrines/capability/
    CLI/Phase 0, Knowledge Map, mdBook, formatting, and whitespace gates pass. Selector-specific Rust runtime
    read/target/assignment/receiver dispatch is gone, and wrapper-era test/corpus terminology is retired.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.2 - hard-reject Rust aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.3`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Dart and close the complete Dart no-drift gate.
  Children: `.12.1.8.3.1`, `.12.1.8.3.2`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.3.1`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Dart and delete selector-specific recognition/dispatch.
  Verification: Focused implementation proof passes 15/15; strict analysis is clean; the executable-source scan
    is zero-positive/14 classified. The complete Dart test leg reaches 203 passes with only two pre-existing
    `spec_spec_*` aggregate failures: shipped variadic `blkVFN` structural regex is not recognized by the Dart
    bridge that handles fixed `blkFN`. No selector test or changed runtime path fails. `.12.1.8.3.2` owns that
    independently bounded full-gate prerequisite before the parent closes.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.3.1 - hard-reject Dart aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.3.2`
  Status: `done`
  Goal: Restore Dart `spec.spec` variadic function-definition structural matching and close the complete gate.
  Acceptance: Extend the existing bounded shipped-pattern bridge from fixed `blkFN` to the exact variadic
    `blkVFN` family, preserving capture/named-capture shape; add focused matching proof; pass all four
    `spec_spec_*` smokes, the full Dart test/CLI/105-corpus gate, and selector retirement no-drift without adding a
    general recursive-regex claim.
  Verification: **PASS 2026-07-12.** The real four-case runner reproduced `blkVFN` as the sole invalid group.
    The bounded bridge now recognizes fixed `blkFN` and exact variadic `blkVFN`, uses separate fixed/variadic
    prefixes, returns name/fixed/rest/body captures, materializes empty optional-parameter slots so indices do not
    shift for zero/rest-only definitions, and exposes the matching named block. Focused matching plus
    selector tests pass 22; all four `spec_spec_*` cases pass. The authoritative Dart gate passes format, strict
    analysis, all 205 package tests, CLI 61x2, and all 105 corpus cases. Neutral/source checks remain green.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.3.2 - close Dart selector retirement`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.4`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Julia and delete selector-specific recognition/dispatch.
  Acceptance: Reject all six neutral exact-selector cases with the portable diagnostic at the complete compiled
    ActionIR boundary, including dead control bodies, deferred fluent calls, and unused user-function bodies;
    repeat validation at generated emission and plan/execution boundaries so caller-constructed compiled payloads
    cannot bypass it; retain all eight neutral constructor/literal classes; delete selector-only runtime reads,
    targets, receiver recognition, and split/transform dispatch; pass focused, source-scan, package, CLI, corpus,
    canonical local-CI, docs/Knowledge Map/doctrine, mdBook, cleanup, and whitespace gates.
  Verification: **PASS 2026-07-12.** All six neutral exact cases move from compiling to portable compile-time
    rejection. Recursive typed-ActionIR inspection covers every expression family; whole-compiled-state validation
    also parses valid deferred function bodies and fluent calls while preserving unrelated parse-failure timing.
    Native compile, generated emission, and generated plan/execution boundaries validate independently, including
    caller-constructed payloads. Selector-specific runtime reads, set/push/receiver targets, split/transform
    wrappers, and target recognizers are deleted. Focused proof passes 59/59 with all eight retained classes;
    executable scan is zero-positive/15 classified. The authoritative Julia gate passes 1,339 package assertions,
    CLI 61x2, and all 105 corpus fixtures; canonical local CI passes Phase 0 `1..1031` in 601 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.4 - hard-reject Julia aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.5`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Lua and delete selector-specific recognition/dispatch.
  Acceptance: Reject all six neutral exact-selector cases with portable code/surface/identifier/replacement fields
    across complete compiled state, including dead control bodies, valid deferred fluent calls, and any registered
    unused user-function bodies; revalidate runtime-engine input so caller-mutated compiled tables cannot bypass
    rejection; retain all eight neutral constructor/literal classes; delete selector-only read, set/push/receiver,
    split/transform, and target-descriptor recognition; pass PUC Lua and LuaJIT focused/full suites, executable
    source scan, exact 105-manifest validation, docs/Knowledge Map/doctrine, mdBook, cleanup, and whitespace gates.
  Verification: **PASS 2026-07-12.** All six neutral exact cases move from compiling to portable typed rejection.
    Recursive ActionIR inspection covers every expression family; whole-compiled-state validation also parses valid
    deferred user-function bodies and fluent calls without changing unrelated parse failures. Compile and runtime-
    engine boundaries both validate, including caller-mutated compiled payloads. Selector-only array/hash reads,
    set/push/receiver targets, mutable split/transform wrappers, and descriptor branches are deleted. Both PUC Lua
    and LuaJIT pass 88/88 with all eight retained classes; the exact 105-manifest and CLI-scaffold checks pass;
    executable scan is zero-positive/19 classified.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.5 - hard-reject Lua aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.6`
  Status: `done`
  Goal: Prove the portable diagnostic and zero selector recognizers/sources across all variants.
  Acceptance: Add a deterministic cross-variant checker that requires all five contract-driven six-case rejection
    suites, portable diagnostic/boundary anchors, and zero known selector runtime-dispatch symbols/patterns; compose
    the existing executable-source scan; register the checker in canonical local CI; remove stale compatibility
    comments; pass the checker, all five focused rejection suites (including dual Lua ABIs), docs/Knowledge Map/
    doctrine, mdBook, cleanup, and whitespace gates before closing hard-retirement parent `.12.1.8`.
  Verification: **PASS 2026-07-12.** One deterministic canonical checker requires all five backends to consume the
    same six invalid-selector cases and portable diagnostic fields, verifies each compiled-state admission
    boundary, forbids the known selector-only runtime symbols/patterns, and composes the executable-source scan.
    The audit found and removed one stale Perl compatibility comment. The checker passes with five backends, six
    rejected cases, eight retained constructor/literal classes, zero runtime compatibility paths, and zero
    executable positives/19 classified rejection occurrences. Focused proof passes Perl 11, Rust 15/15, Dart
    15/15, Julia 59/59, and Lua 88/88 on both PUC Lua and LuaJIT; the canonical local gate passes capability
    60/0/0, CLI 61x2, and Phase 0 `1..1031` in 616 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.6 - enforce selector retirement no-drift`

- ID: `FUTURE-PARITY-BACKLOG.12.1.9`
  Status: `done`
  Goal: Close uniform-binding docs, mdBook examples, Knowledge Map, capability, and complete no-drift gates.
  Acceptance: Public docs teach bare typed bindings and literals/retained constructors only; no compatibility
    caveat, current-facing example, positive executable test/source, diagnostic ambiguity, or backend admits
    selector semantics. Add a deterministic public-surface checker that distinguishes current normative guidance
    from durable historical/rejection evidence; retire the capability future exclusion; run the uniform-binding,
    aggregate-retirement, capability, docs/Knowledge Map/doctrine, mdBook, cleanup, whitespace, and canonical local
    gates; then close `.12.1` and activate the next roadmap-aligned PNT frontier.
  Verification: **PASS 2026-07-12.** The canonical public checker scans 47 root/capability/mdBook files, classifies
    31 exact mentions only as removed/rejected/migrated history, reports zero current examples, requires current
    bare set/push/copy guidance, forbids stale future/remaining-backend status, composes the five-backend runtime/
    source checker, and proves the capability future exclusion is absent. Capability remains 60/0/0; mdBook,
    Knowledge Map, doctrine, memory/task, cleanup, and whitespace gates pass. Canonical CI passes CLI 61x2 and
    Phase 0 `1..1031` in 626 seconds. Existing active Lua scalar-numeric leaf `.4.3.3.1.4` resumes.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.9 - admit selector-free public surface`

- ID: `FUTURE-PARITY-BACKLOG.12.1.10`
  Status: `done`
  Goal: Remove selector syntax from backend READMEs and close the public-checker coverage omission.
  Dependencies: `.12.1.9`
  Acceptance: Inventory every tracked backend README for exact selector-shaped guidance; classify history versus
    current examples; migrate current Rust/Dart/Julia/Lua authoring prose and snippets to bare typed bindings;
    expand the canonical public checker to discover backend READMEs from the repository rather than relying on a
    root/capability/mdBook-only list; require the expanded file count and zero current examples; preserve legitimate
    removed/rejected history; pass the composed selector/runtime/capability gate, relevant backend docs/tests,
    mdBook/Knowledge Map/doctrines/cleanup/whitespace, then re-close `.12.1`/`.12` and resume Lua numeric `.4.3.3.2`.
  Verification: **PASS 2026-07-12.** A commit-baseline scan found 14 exact positive forms across Rust, Dart,
    Julia, and Lua READMEs. Their runtime descriptions and examples now use bare typed set/copy/push/set-key/split
    forms. The canonical checker discovers all immediate component READMEs, asserts 56 public files and 31
    classified removed/history references, requires bare-binding anchors in all four backend documents, and
    reports zero current examples. It composes five-backend six-invalid/eight-retained/zero-runtime and zero-
    executable-positive/19-classified proof plus capability 60/0/0; docs/KM/doctrines/mdBook pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.10 - close backend README selector drift`

- ID: `FUTURE-PARITY-BACKLOG.13`
  Status: `pending`
  Goal: Restore the codegen-inspector toolbox to the current thin-facade owner architecture.
  Children: `.13.1`
  Dependencies: `.12.1`
  Acceptance: `tools/inspect_spec_codegen.pl` invokes explicit owner APIs rather than facade AUTOLOAD/plugin
    fallback, all four documented snippet forms execute, and a recurring smoke test prevents owner extraction from
    silently breaking the inspector again.

- ID: `FUTURE-PARITY-BACKLOG.13.1`
  Status: `pending`
  Goal: Rewire and regression-lock `tools/inspect_spec_codegen.pl` after the Phase 1A facade extraction.
  Dependencies: `.12.1`

- ID: `FUTURE-PARITY-BACKLOG.14`
  Status: `pending`
  Goal: Ratify, document, and implementation-audit LinkedSpec's structural linked-rule and progressive/staged
    parser-composition authoring model.
  Children: `.14.0`, `.14.1`, `.14.2`, `.14.3`, `.14.4`
  Acceptance: Public guidance teaches small readable boundary regexes and connected recursive rule structure;
    progressive parsing composes dynamically loaded spec parsers over cursor-relative extracted text; staged
    parsing can enrich selected returned-AST fields with later spec-driven parses; examples and implementation
    claims remain proof-backed rather than aspirationally overstated.

- ID: `FUTURE-PARITY-BACKLOG.14.0`
  Status: `done`
  Goal: Capture the director's complete authoring model and split doctrine, progressive composition, staged AST
    enrichment, and implementation/no-drift audit before changing behavior or public claims.
  Verification: **PASS 2026-07-12.** ADR 0012 and the closed `STAGED-LINKED-PARSING` tree already own neutral
    parse jobs, many-next-spec dispatch design, and one narrow function-body prototype. In that prototype the
    user-function `.spec` owns the outer definition and bounded body extraction, while the `actionir-body.spec`
    job identity resolves to a built-in backend-native ActionIR parser adapter rather than an owning `.spec` file;
    it is staged parsing, not evidence that one `.spec` loads another. The director's clarification
    adds the missing simple-regex/linked-rule authoring doctrine and distinguishes active in-parse progressive
    composition from later returned-AST staged enrichment. Current public `parse_job(...)`, multiple parser
    families, arbitrary in-parse composition, and recursive queues remain unimplemented/future. The mdBook's
    portmap praise for one complex regex and EBNF recursive-regex description are explicit `.14.1/.14.4` audit
    evidence rather than silently accepted target idioms. No parser/runtime behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.14.0 - capture structural progressive parsing doctrine`

- ID: `FUTURE-PARITY-BACKLOG.14.1`
  Status: `pending`
  Goal: Ratify and teach simple-regex linked-rule structure, including zero/one/two-regex authoring roles and
    recursion through action-edge OR dispatch plus blind-call AND composition.

- ID: `FUTURE-PARITY-BACKLOG.14.2`
  Status: `pending`
  Goal: Specify and audit progressive in-parse extraction plus dynamic multi-spec parser invocation over captured
    text at arbitrary safe parsing points.

- ID: `FUTURE-PARITY-BACKLOG.14.3`
  Status: `pending`
  Goal: Specify and audit staged AST enrichment where later loaded specs parse selected extracted fields returned
    by an earlier AST level.

- ID: `FUTURE-PARITY-BACKLOG.14.4`
  Status: `pending`
  Goal: Close examples, implementation gaps, mdBook/Knowledge Map/tooling alignment, and complete no-drift proof
    for the structural/progressive/staged authoring model.

- ID: `FUTURE-PARITY-BACKLOG.15`
  Status: `pending`
  Goal: Make any standalone/dangling rule-level `{ ... }` block exact syntax sugar for `I { ... }`.
  Children: `.15.0`, `.15.1`, `.15.2`
  Acceptance: At top-level rule-body item parsing, accept a standalone `{ ... }` anywhere an item may occur and
    normalize it to the existing `I` lifecycle AST rather than adding runtime semantics. Action-edge and blind-call
    blocks remain owned by their preceding edge productions and therefore are not standalone/dangling; nested
    expression/callable blocks remain owned after entering code parsing. Apply the same rule to OR, AND, zero-regex,
    one-regex, and two-regex rules; preserve explicit `I { ... }`; inherit its ordering/duplicate behavior; align
    all admitted backends, source generation, diagnostics, examples, and complete gates.

- ID: `FUTURE-PARITY-BACKLOG.15.0`
  Status: `pending`
  Goal: Audit and ratify the anywhere-in-rule standalone-block normalization contract before behavior code.
  Acceptance: Use parser/toolbox evidence to confirm there is currently no dangling `{ ... }` rule-body form and
    enumerate the non-dangling brace owners: action-edge/blind-call suffix blocks and nested code/callable blocks.
    Record direct normalization to `I`, inherited duplicate/order behavior, source spans, and malformed forms.

- ID: `FUTURE-PARITY-BACKLOG.15.1`
  Status: `pending`
  Goal: Implement the ratified bare rule-level lifecycle shorthand on the Perl reference and Rust backend.

- ID: `FUTURE-PARITY-BACKLOG.15.2`
  Status: `pending`
  Goal: Align Dart, Julia, Lua, generated paths, public examples, Knowledge Map, and complete no-drift proof.

### `FUTURE-PARITY-BACKLOG.14.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve the director's exact distinction between linked-rule structural recursion,
  progressive in-parse parser composition, and staged post-AST enrichment without collapsing them into regex work.
- [x] **ROOT CAUSE (WHY + WHERE)** — Locate current canonical architecture, mdBook, toolbox, capture/extraction,
  spec-loading/invocation, and staged-dispatch evidence before making implementation-completeness claims.
- [x] **FIX** — Create ordered doctrine, progressive-composition, staged-enrichment, and final audit leaves; make
  explicit that later behavior or public examples require proof against the current implementation.
- [x] **ADDRESSED (verified)** — The task tree preserves simple zero/one/two-regex roles, graph-owned recursion,
  cursor-relative extraction, any-number spec composition as the intended contract, and multi-level AST parsing.
- [x] **NO REGRESSION** — Planning only: no parser, runtime, grammar, fixture, or accepted behavior changes.
- [x] **LOCKSTEP** — Task/index, roadmap, Knowledge Map/live docs, memory, and mdBook status point at the durable
  future owner; the arc remains queued behind selector retirement while Dart `.12.1.8.3` is active.

### `FUTURE-PARITY-BACKLOG.12.1.8.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — With all positive executable sources migrated, prove exact one-bare-identifier
  `array(name)` / `hash(name)` calls still enter Perl compatibility recognition and can still execute as selectors.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use the Knowledge Map and LinkedSpec toolbox/tests to identify every Perl
  parser/scanner/lowering/runtime recognition and diagnostic seam that distinguishes selector calls from retained
  constructors; do not confuse generated Perl sigils with `.spec` language surface.
- [x] **FIX** — Emit the adopted `aggregate_selector_removed` diagnostic for both exact forms and delete public
  selector acceptance/dispatch while retaining non-selector constructors, literals, bare typed bindings,
  `flat_array(...)`, `flat_hash(...)`, and ordinary private host-language storage/normalization.
- [x] **ADDRESSED (verified)** — Exact selector calls fail deterministically through live and generated Perl paths;
  no authored selector node crosses the canonical lowering boundary, and retained constructor/control cases still
  execute. Private generated-Perl storage machinery is not a `.spec` surface and remains separately classified.
- [x] **NO REGRESSION** — Neutral uniform-binding and executable-source checkers, focused parser/ActionIR/runtime/
  generated-source suites, capability contracts, CLI 61x2, Phase 0, doctrines/KM/mdBook/whitespace, and artifact
  cleanup pass at their true stopping points.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  identify Perl hard rejection complete and Rust `.12.1.8.2` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Consume the neutral six invalid-selector cases and prove Rust still parses/executes
  exact one-bare-identifier `array(...)` / `hash(...)` calls after all executable sources migrated.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify the typed AST/compiler/runtime/generated-plan seams that distinguish
  exact selectors from retained zero/multi/quoted/computed constructors; keep private runtime maps out of the
  public-language decision.
- [x] **FIX** — Reject exact selector nodes with `aggregate_selector_removed` plus portable surface/identifier/
  replacement fields before native or generated execution, and remove public selector dispatch while retaining
  bare bindings, constructors, literals, `flat_array(...)`, `flat_hash(...)`, and private host storage.
- [x] **ADDRESSED (verified)** — Direct parser/compiler, native execution, serialized/generated-plan, dead/nested,
  and unused-function paths reject deterministically; the eight retained constructor/literal classes still pass.
- [x] **NO REGRESSION** — Neutral/executable checkers, focused core/runtime/generated suites, complete Rust package,
  105 interpreted/generated corpus, CLI 61x2 where warranted, docs/KM/doctrines/mdBook/whitespace, and artifact
  cleanup pass at their true stopping points.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  identify Rust hard rejection complete and Dart `.12.1.8.3` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Consume all six neutral invalid-selector cases and prove exact one-bare-identifier
  `array(name)` / `hash(name)` calls still survive Dart parsed/compiled/native/generated paths after migration.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use the Knowledge Map, focused contract test, typed frontend/compiler models,
  runtime interpreter, and generated adapter to locate every selector recognition and trust boundary; distinguish
  exact selectors from retained zero/multi/quoted/computed constructors and direct literals.
- [x] **FIX** — Reject exact selector nodes with `aggregate_selector_removed` plus portable surface/identifier/
  replacement fields before native or generated execution, and delete selector-specific Dart dispatch while
  preserving bare typed bindings, retained constructors/literals, and private host storage.
- [x] **ADDRESSED (verified)** — Direct compile/native/generated paths, nested/dead code, unused functions, and
  decoded/emitted compiled state reject deterministically; all eight retained constructor/literal classes execute.
- [x] **NO REGRESSION** — Neutral/executable checkers, 15 focused tests, format, strict analysis, docs/KM/doctrines/
  mdBook/whitespace, and artifact cleanup pass. The complete package leg reaches 203 passes; its only two failures
  are the independently root-caused variadic `spec.spec` bridge drift owned by `.12.1.8.3.2`, not selector code.
- [x] **LOCKSTEP** — Task/index, live docs, Knowledge Map, changes/notes, and memory identify selector implementation
  complete, full Dart no-drift pending `.12.1.8.3.2`, and Julia `.12.1.8.4` only after the parent closes.

### `FUTURE-PARITY-BACKLOG.12.1.8.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Reproduce all four `spec_spec_*` failures through the real Dart corpus runner and
  capture the exact invalid recursive group after the shipped function-definition pattern became variadic.
- [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve the bounded structural-regex bridge fact and prove its detector,
  prefix matcher, capture list, and named-capture map know fixed `blkFN` only while `spec.spec` now emits `blkVFN`.
- [x] **FIX** — Extend only the exact shipped variadic family with fixed/rest captures and `blkVFN` named block;
  preserve the existing fixed family and avoid claiming general recursive-PCRE support.
- [x] **ADDRESSED (verified)** — Focused runtime matching locks fixed and variadic definitions, and all four
  `spec_spec_*` corpus cases execute with unchanged expected outputs.
- [x] **NO REGRESSION** — Format/analyze, complete Dart tests, CLI 61x2, all 105 corpus cases, selector focused/
  neutral/source gates, docs/KM/doctrines/mdBook/whitespace, and cleanup pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  close Dart `.12.1.8.3` and identify Julia `.12.1.8.4` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove all six exact selector-shaped neutral cases still compile on Julia, including
  whitespace, nested, target, and receiver shapes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve the Julia uniform-binding fact and trace selector compatibility
  through typed ActionIR, deferred user-function/fluent sources, generated boundaries, and runtime dispatch.
- [x] **FIX** — Add recursive whole-compiled-state rejection with the portable diagnostic at native and generated
  boundaries, then delete every selector-only runtime recognition/dispatch branch.
- [x] **ADDRESSED (verified)** — Lock all six neutral cases, dead/fluent/unused-function coverage, caller-constructed
  generated payload rejection, and all eight retained constructor/literal classes.
- [x] **NO REGRESSION** — Focused Julia proof, zero-positive executable scan, 1,339 package assertions, CLI 61x2,
  105 corpus, canonical local CI, docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, live docs, roadmaps, README/book, architecture, Knowledge Map, changes/notes, and
  memory close Julia and identify Lua `.12.1.8.5` as next.

### `FUTURE-PARITY-BACKLOG.12.1.8.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove all six exact selector-shaped neutral cases still compile on Lua, including
  whitespace, nested, target, and receiver shapes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve the Lua uniform-binding fact and trace compatibility through typed
  ActionIR, deferred function/fluent source, runtime-engine admission, and every wrapper dispatch branch.
- [x] **FIX** — Add recursive whole-compiled-state rejection at compile/runtime-engine boundaries and delete every
  selector-only runtime recognition/dispatch branch.
- [x] **ADDRESSED (verified)** — Lock all six neutral cases, dead/fluent/function and caller-mutation coverage, and
  all eight retained constructor/literal classes on both PUC Lua and LuaJIT.
- [x] **NO REGRESSION** — Dual-ABI 88/88 full tests, zero-positive executable scan, exact 105-manifest/CLI scaffold,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, live docs, roadmaps, README/book, architecture, Knowledge Map, changes/notes, and
  memory close Lua and activate cross-variant no-drift `.12.1.8.6`.

### `FUTURE-PARITY-BACKLOG.12.1.8.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit all five backend validators/tests/runtime sources and identify any remaining
  unguarded drift or stale selector-compatibility statement.
- [x] **ROOT CAUSE (WHY + WHERE)** — Prove existing backend tests are individually strong but no single recurring
  gate requires their shared contract consumption, portable fields, validation boundaries, and runtime deletions.
- [x] **FIX** — Add and register the cross-variant retirement checker; remove stale compatibility commentary.
- [x] **ADDRESSED (verified)** — Checker requires all five contract-driven rejection suites/boundaries and forbids
  known runtime selector symbols/patterns while composing the executable-source scan.
- [x] **NO REGRESSION** — Cross-variant checker, all five focused/dual-ABI rejection suites, canonical registration,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, live docs, roadmaps, README/book, architecture, Knowledge Map, changes/notes, and
  memory close `.12.1.8` and activate final public admission `.12.1.9`.

### `FUTURE-PARITY-BACKLOG.12.1.9` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit all current public docs, mdBook examples, capability status, diagnostics, tests,
  and executable sources after hard retirement; distinguish normative drift from historical/rejection evidence.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify why implementation/source no-drift alone cannot prevent a stale public
  compatibility statement, positive authoring example, or future-capability exclusion from surviving admission.
- [x] **FIX** — Add/register a deterministic public-surface retirement checker; remove every current-facing caveat
  or positive selector example; retire the capability future exclusion and align public/live status.
- [x] **ADDRESSED (verified)** — Public guidance teaches bare typed bindings and literals/retained constructors only;
  removed exact selectors appear solely in classified rejection, migration-history, or durable fact evidence.
- [x] **NO REGRESSION** — Public-surface, uniform-binding, aggregate-retirement, capability, canonical local CI,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, architecture, Knowledge Map, changes/notes/live, and memory
  close `.12.1` and point at the next dependency-correct PNT leaf.

### `FUTURE-PARITY-BACKLOG.12.1.10` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Scan every backend README and prove current positive selector examples survived the
  admitted 47-file public gate while executable sources and the root/capability/mdBook set remain clean.
- [x] **ROOT CAUSE (WHY + WHERE)** — Show that `check_public_aggregate_selector_surface.py` enumerates a curated
  root/capability/mdBook set but does not discover tracked backend READMEs, allowing public language drift.
- [x] **FIX** — Migrate current backend README prose/snippets and extend the checker with deterministic backend
  README discovery plus stable classification/count assertions.
- [x] **ADDRESSED (verified)** — Every backend README teaches bare typed bindings and exact selectors occur only in
  explicit removed/rejected/history evidence accepted by the canonical classifier.
- [x] **NO REGRESSION** — Expanded public/runtime/capability checker, relevant backend gates, docs/KM/doctrines,
  mdBook, artifact cleanup, and whitespace all pass with no runtime or fixture behavior change.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/backend README/book, architecture, Knowledge Map, changes/notes/live,
  and memory re-close `.12.1`/`.12` and resume Lua numeric alias/receiver `.4.3.3.2`.

### `FUTURE-PARITY-BACKLOG.12.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Count exact selector-shaped calls and prove that current bare alternatives are not
  yet uniformly executable, rather than assuming source replacement is mechanical.
- [x] **ROOT CAUSE (WHY + WHERE)** — Locate public ambiguity and each backend's selector recognition, target
  extraction, constructor special case, store lookup, and mutation dispatch seams.
- [x] **FIX** — Split neutral semantics, Perl/Rust/Dart/Julia/Lua enablement, three source-migration surfaces, five
  hard-retirement backends plus no-drift, and final public documentation before behavior code.
- [x] **ADDRESSED (verified)** — Boundary-correct inventory covers 600 calls/82 specs, 210 calls/15 shipped specs,
  parent-helper and
  receiver categories, toolbox lowering, and concrete backend owner locations.
- [x] **NO REGRESSION** — Read-only inventory and task/docs/KM updates only; no grammar, lowering, runtime,
  generated-source, fixture, or accepted `.spec` behavior changes.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, Knowledge Map, changes/notes/live, and bounded memory route
  exact selector removal through neutral contract `.12.1.1`; selector survival is not an open question.

### `FUTURE-PARITY-BACKLOG.12.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Encode the concrete bare push/split ambiguity and selector-shaped constructor/read/
  target problem as neutral cases before any backend changes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Define one observable typed binding independently of backend host storage;
  callable purpose, arity, static rule registry, and runtime value—not wrapper syntax—must govern dispatch.
- [x] **FIX** — Add a strict versioned contract/checker with canonical migration mappings, valid binding/mutation/
  constructor cases, exact future selector diagnostics, deterministic future fixture source/results, and CI wiring.
- [x] **ADDRESSED (verified)** — Independent evaluation checks set/push/split/hash mutation/copy/read/chaining,
  absent binding creation, static rule precedence, silent drop, result values, and invalid selectors.
- [x] **NO REGRESSION** — Contract/docs/checker only: current Perl/Rust/Dart/Julia/Lua parsing, lowering, runtime,
  generated source, shipped specs, corpus fixtures, and current capability census remain unchanged.
- [x] **LOCKSTEP** — Contract README, task/index, roadmaps, README/book, Knowledge Map, changes/notes/live, memory,
  and canonical CI identify Perl `.12.1.2` as the first behavior consumer.

### `FUTURE-PARITY-BACKLOG.12.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Consume the neutral future fixture and focused bare set/push/split/hash/read/chaining/
  static-precedence/wrong-kind cases on live and standalone generated Perl, preserving measured failure evidence.
- [x] **ROOT CAUSE (WHY + WHERE)** — Remove observable bare-target dependence across `MethodLowering`,
  `ArrayPipeline`, `Contracts`, `ControlFlow`, `FlowExpr`, and `EmitContext` type/declaration memory while preserving
  static child-rule push precedence and temporary wrapper compatibility.
- [x] **FIX** — Lower bare typed mutations through one scalar-held value binding (or an observationally identical
  private representation), return post-operation values, auto-create absent required kinds, reject wrong kinds,
  and make three-argument bare split mutate without changing pure two-argument split.
- [x] **ADDRESSED (verified)** — Neutral checker plus focused live/generated proof cover all seven execution cases,
  deterministic fixture, expression chaining/drop, static precedence, diagnostics, compatibility selectors, and
  current constructor classification.
- [x] **NO REGRESSION** — Shipped specs, wrapper-era Phase-0 locks, ActionIR, generated source, CLI, capability,
  doctrines, Knowledge Map, whitespace, and mdBook reach their true stops before source migration.
- [x] **LOCKSTEP** — Code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory describe Perl
  selector-free enablement as current while exact selector rejection remains deferred until `.12.1.8.1`.

### `FUTURE-PARITY-BACKLOG.12.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and the seven binding/mutation cases through Rust
  native and generated execution, retaining exact failures for bare push, mutable split, hash update, chaining,
  static precedence, or wrong-kind diagnostics.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace bare reads and mutation ownership through parsed ActionIR,
  `RuntimeContext`, `execute_call`, receiver dispatch, target resolvers, generated plans, and diagnostic projection;
  distinguish public binding semantics from private scalar/array/hash stores.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/collection mutations observe and return one
  `RuntimeValue`, auto-create only missing required kinds, reject incompatible existing kinds, preserve static-rule
  push precedence, and retain selectors solely as migration compatibility.
- [x] **ADDRESSED (verified)** — Focused Rust native/generated fixtures match the neutral expected values and error
  fields, including saved mutation results, `set(...).sorted().first()`, array-end result continuation, pure versus
  mutable split, and silent drop.
- [x] **NO REGRESSION** — Core/runtime/integration/oracle/generated-source/CLI/capability/doctrine/Knowledge Map/
  whitespace/mdBook gates reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Rust code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  Rust as the second enabled backend and Dart `.12.1.4` as next.

### `FUTURE-PARITY-BACKLOG.12.1.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and all seven binding/mutation cases through Dart
  native and generated-plan execution, preserving exact push/split/hash/result/chaining/precedence/wrong-kind gaps.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace `ActionVariableExpr`, statement interception, `_RuntimeExecutionContext`
  variable/array/hash stores, target-name helpers, fluent dispatch, generated plans, and diagnostic projection;
  separate one public typed binding from private migration storage.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/array-end/collection mutations read, validate,
  update, and return one typed value; auto-create only absent required kinds; preserve static-rule push precedence;
  keep exact selectors solely as temporary migration input.
- [x] **ADDRESSED (verified)** — Native/generated fixtures match the neutral result/error fields, saved snapshots,
  `set(...).sorted().first()`, mutation continuation, pure/mutable split, collection rebinding, and silent drop.
- [x] **NO REGRESSION** — Dart format/analyze/unit/corpus/generated/CLI plus neutral/capability/doctrine/KM/mdBook/
  whitespace gates reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Dart code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  Dart as the third enabled backend and Julia `.12.1.5` as next.

### `FUTURE-PARITY-BACKLOG.12.1.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and all seven binding/mutation cases through Julia
  native and generated execution, preserving exact push/split/hash/result/chaining/precedence/wrong-kind gaps.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace `ActionVariableExpr`, statement interception, `_read_runtime_store`,
  private variable/array/hash stores, target-name helpers, fluent dispatch, generated execution, and diagnostic
  projection; separate one public typed binding from private migration storage.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/array-end/collection mutations read, validate,
  update, and return one typed value; auto-create only absent required kinds; preserve static-rule push precedence;
  keep exact selectors solely as temporary migration input.
- [x] **ADDRESSED (verified)** — Native/generated fixtures match the neutral result/error fields, saved snapshots,
  `set(...).sorted().first()`, mutation continuation, pure/mutable split, collection rebinding, and silent drop.
- [x] **NO REGRESSION** — Julia formatting/package/corpus/generated/CLI plus neutral/capability/doctrine/KM/mdBook/
  whitespace gates reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Julia code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  Julia as the fourth enabled backend and Lua `.12.1.6` as next.

### `FUTURE-PARITY-BACKLOG.12.1.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral future fixture and all seven binding/mutation cases through PUC Lua
  and LuaJIT, preserving exact push/split/hash/result/chaining/precedence/wrong-kind gaps.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace variable reads, `lookup_binding`, scalar/array/harray stores,
  `target_descriptor`, call/statement interception, fluent dispatch, and diagnostic projection; separate one public
  typed binding from private migration storage.
- [x] **FIX** — Make bare set/push/append/mutable split/hash/index/array-end/collection mutations read, validate,
  update, and return one typed value; auto-create only absent required kinds; preserve static-rule push precedence;
  keep exact selectors solely as temporary migration input.
- [x] **ADDRESSED (verified)** — Both Lua ABIs match neutral result/error fields, saved snapshots,
  `set(...).sorted().first()`, mutation continuation, pure/mutable split, collection rebinding, and silent drop.
- [x] **NO REGRESSION** — Dual-ABI Lua package/corpus/CLI plus neutral/capability/doctrine/KM/mdBook/whitespace gates
  reach their true stops without migrating or rejecting tracked selector sources.
- [x] **LOCKSTEP** — Lua code/tests/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify all
  five enabled backends and source migration `.12.1.7.1` as next.

### `FUTURE-PARITY-BACKLOG.12.1.7.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Recount exact selector-shaped calls in the 15 affected shipped `specs/*.spec` files,
  classify every occurrence as typed read/target/receiver versus intended one-element construction, and preserve a
  file-by-file baseline before editing. Require a left identifier boundary so `flat_array(name)` is not counted.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use the recorded parent-call/receiver inventory plus parser/runtime proof to
  select bare bindings for reads and mutation targets, `[value]` for intended one-element arrays, and ordinary
  retained constructors only where the neutral contract permits them. The first migrated Lispish CLI proof also
  exposed a Perl-only lowering split: uniform mutations write scalar-held typed values (`$name`), while legacy
  read-only array/hash helper fast paths still read `@name` / `%name`; repair that bounded read seam in this leaf.
- [x] **FIX** — Remove every exact `array(IDENTIFIER)` / `hash(IDENTIFIER)` occurrence from shipped specs without
  changing unrelated syntax, helper choice, or rule behavior; make Perl pure collection helpers consume the same
  scalar-held bare typed binding that mutation helpers update.
- [x] **ADDRESSED (verified)** — Shipped source scan is zero and reference/generated descriptors/execution preserve
  the intended values for every affected spec and shipped proof fixture.
- [x] **NO REGRESSION** — Focused shipped-spec, generated-source, backend corpus, capability/doctrine/KM/mdBook/
  whitespace gates reach their true stops; derived expectations change only when selector-free syntax requires it.
- [x] **LOCKSTEP** — Shipped specs/task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify
  shipped migration complete and neutral/oracle/corpus migration `.12.1.7.2` as next.

### `FUTURE-PARITY-BACKLOG.12.1.7.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve the boundary-correct 390-occurrence/67-file baseline: five occurrences in
  two capability fixtures, 366 in 62 neutral Rust-oracle inputs, and 19 in three legacy corpus inputs; identify
  intended `[undef]` one-element construction separately from binding selectors.
- [x] **ROOT CAUSE (WHY + WHERE)** — Treat capability fixtures and their mirrored oracle inputs as one source
  contract, preserve quoted/multi/computed constructors, and distinguish scalar-held typed array/harray reads from
  explicit construction before mechanical replacement.
- [x] **FIX** — Remove every exact selector from file-backed capability/oracle/corpus `.spec` inputs, using bare
  bindings for reads/targets/receivers and `[undef]` for the three intended one-element arrays; regenerate only
  expectations or classifications whose derived bytes genuinely change.
- [x] **ADDRESSED (verified)** — All tracked file-backed `.spec` inputs scan at zero exact selectors; capability
  mirrors agree; Perl/Rust/Dart/Julia/Lua corpus results preserve their expected values.
- [x] **NO REGRESSION** — Strict uniform/capability/generated/native contracts, full corpus and generated-source
  breadth, CLI, doctrines/KM/mdBook/whitespace, and the canonical local gate reach their true stops.
- [x] **LOCKSTEP** — Corpus inputs/derived expectations/task/index, roadmaps, README/book, KM, changes/notes/live,
  and memory identify file-backed migration complete and embedded source-string migration `.12.1.7.3` as next.

### `FUTURE-PARITY-BACKLOG.12.1.7.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Preserve the boundary-correct baseline of 1,356 positive exact occurrences across 25
  test/tool/backend files or test-only source sections, separated from 28 implementation/neutral-contract
  occurrences in recognizers, diagnostics, comments, two explicit compatibility-path tests, and the removed-syntax
  checker; exclude four dotted Lua host `json.array(...)` calls, documentation/history, and ordinary constructors.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify tests and tools that still compile or execute legacy selector source,
  distinguish source assertions from host implementation text, and preserve the hard-rejection evidence owned by
  `.12.1.8` without allowing compatibility syntax to remain an executable positive fixture.
- [x] **FIX** — Migrate every positive embedded test/tool/backend spec source to bare typed bindings and literals;
  update derived AST/source expectations only where those embedded inputs genuinely change.
- [x] **ADDRESSED (verified)** — A boundary-correct executable-source scan reaches zero positive selector inputs;
  any remaining exact spellings are mechanically classified as implementation recognition/diagnostic text,
  neutral rejection/migration contract data, or non-executable historical documentation.
- [x] **NO REGRESSION** — Focused Perl/Rust/Dart/Julia/Lua parser/runtime/generated-source tests, complete backend
  gates, uniform/capability contracts, canonical CI, doctrines/KM/mdBook/whitespace, and artifact cleanup pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, KM, changes/notes/live, and memory identify all source
  migration complete and Perl hard rejection `.12.1.8.1` as next.

### `FUTURE-PARITY-BACKLOG.13.1` Acceptance Checklist

- [ ] **REPRODUCE / ISSUE** — Preserve exact raw-expression and lifecycle/action-chain inspector failures showing
  plugin AUTOLOAD receives `_rewrite_action_code_with_diagnostics` and `_render_method_call_chain`.
- [ ] **ROOT CAUSE (WHY + WHERE)** — Confirm current implementations/ownership, thin-facade history, tool callers,
  and whether any supported public probe seam should replace direct private-owner calls.
- [ ] **FIX** — Route all four documented snippet forms through explicit current owners or one deliberate stable
  inspection API; do not expose unrelated internals through the public facade.
- [ ] **ADDRESSED (verified)** — Raw helper, lifecycle block, lifecycle chain, and action-edge block/chain examples
  print generated Perl plus canonical diagnostics without plugin dispatch.
- [ ] **NO REGRESSION** — Add a recurring smoke test and pass focused tool/ActionIR, Phase-0, doctrine/KM/mdBook,
  whitespace, and canonical local gates.
- [ ] **LOCKSTEP** — Task/index, TOOLBOX/README, Knowledge Map, changes/notes/live, and memory identify the restored
  inspector contract and next PNT frontier.

### `FUTURE-PARITY-BACKLOG.12.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Duck-typed values coexist with legacy wrapper-selected scalar/aggregate namespaces,
  while earlier expression and trailing-codeblock doctrine was distributed across several completed trees.
- [x] **ROOT CAUSE (WHY + WHERE)** — The `.spec` language retained `array(name)` / `hash(name)` selector and
  mutation forms after bare assignments became typed value bindings, leaving two public ways to identify storage.
- [x] **FIX** — Capture one uniform-expression doctrine and create `.12.1` to design/split removal of temporary
  compatibility, especially `array(name)`/`hash(name)` as type or mutation authority.
- [x] **ADDRESSED (verified)** — Existing records prove assignment, inline if/switch, user/helper calls, VALUE_DROP,
  and generic trailing-codeblock ownership; the new card joins them and states the missing retirement contract.
- [x] **NO REGRESSION** — Planning-only: no parser, compiler, runtime, fixture, or active Lua frontier changed.
- [x] **LOCKSTEP** — Future task, index, roadmaps, mdBook status, KM, changes/notes/live, and memory agree.

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
| 8 | `FUTURE-PARITY-BACKLOG.1.5.1.6.0` | `done` | ADR 0025 and probes isolate/split the strict UTF-8 text boundary before code. |
| 9 | `FUTURE-PARITY-BACKLOG.1.5.1.6.1` | `done` | Exact hex-byte inputs and validation are reusable in the neutral runner. |
| 10 | `FUTURE-PARITY-BACKLOG.1.5.1.6.2` | `done` | Strict Perl argv/files/JSON and eight Unicode/invalid cases bring the shared suite to 61. |
| 11 | `FUTURE-PARITY-BACKLOG.1.5.1.6.3` | `done` | Perl task/book/KM/help/fixtures agree on the 61-case strict UTF-8 reference. |
| 12 | `FUTURE-PARITY-BACKLOG.1.5.2.0` | `done` | Rust native/adapter seams are audited and implementation is split before code. |
| 13 | `FUTURE-PARITY-BACKLOG.1.5.2.1` | `done` | Exact Rust binary arguments/help/UTF-8 loading and named resolution pass their shared cases. |
| 14 | `FUTURE-PARITY-BACKLOG.1.5.2.2` | `done` | Native direct-result/entry/mode execution closes all 11 result cases; Rust is 41/61. |
| 15 | `FUTURE-PARITY-BACKLOG.1.5.2.3` | `done` | Canonical levels/events/sinks/failures close the unchanged Rust suite at 61/61. |
| 16 | `FUTURE-PARITY-BACKLOG.1.5.2.4` | `done` | Default/POSIX plus recurring Rust and broader local gates close the Rust primary command. |
| 17 | `FUTURE-PARITY-BACKLOG.1.5.3.0` | `done` | Dart's 0/61 corpus-oriented primary boundary and reusable native seams are audited/split. |
| 18 | `FUTURE-PARITY-BACKLOG.1.5.3.1` | `done` | Exact arguments/help/loading plus staged no-function repair pass the 29-case boundary subset. |
| 19 | `FUTURE-PARITY-BACKLOG.1.5.3.2` | `done` | Native direct execution/canonical JSON close all results at 41/61. |
| 20 | `FUTURE-PARITY-BACKLOG.1.5.3.3` | `done` | Independent canonical trace closes all 20 residuals at 61/61. |
| 21 | `FUTURE-PARITY-BACKLOG.1.5.3.4` | `done` | Recurring 151-test/61x2/99 gate and broader no-drift close Dart. |
| 22 | `FUTURE-PARITY-BACKLOG.1.5.4.0` | `done` | Julia's 13/61 baseline is classified and split before repair. |
| 23 | `FUTURE-PARITY-BACKLOG.1.5.4.1` | `done` | Shared help, strict UTF-8, and phase-only errors advance Julia to 42/61. |
| 24 | `FUTURE-PARITY-BACKLOG.1.5.4.2` | `done` | Independent canonical trace closes Julia at 61/61 default/POSIX. |
| 25 | `FUTURE-PARITY-BACKLOG.1.5.4.3` | `done` | Recurring 4x2x61 driver and all focused/broader gates close exact CLI parity. |
| 26 | `FUTURE-PARITY-BACKLOG.1.6.0` | `done` | Validated 15-capability census classifies and owns all current gaps before behavior changes. |
| 27 | `FUTURE-PARITY-BACKLOG.1.6.1.0` | `done` | 237 names documented; 98 corpus gaps audited; canonical fixture families and shared separator blocker split. |
| 28 | `FUTURE-PARITY-BACKLOG.1.6.1.1` | `done` | Universal top-level newline separation repaired; Phase 0 1029 and four-backend 99/99 pass. |
| 29 | `FUTURE-PARITY-BACKLOG.1.6.1.2.0` | `done` | Capture timing proven; residual newline `endswitch` terminator seam split before code. |
| 30 | `FUTURE-PARITY-BACKLOG.1.6.1.2.1` | `done` | Contract-aware generated terminator repaired; Phase 0 passes 1030. |
| 31 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.0` | `done` | Corrected fixtures expose 100/105 on every non-reference backend; repair is split. |
| 32 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1` | `done` | Rust exact pure fixture, 191 integration, and 99 oracle pass. |
| 33 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.2` | `done` | Dart exact pure fixture, 152 tests, 61x2 CLI, and 99 corpus pass. |
| 34 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.3` | `done` | Julia exact pure fixture, 1,020 assertions, 61x2 CLI, and 99 corpus pass; pure parent closes. |
| 35 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.1` | `done` | Rust exact position fixture, zero-width distinction, 137 library, 193 integration, and 99 oracle pass. |
| 36 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.2` | `done` | Dart exact position fixture, nullable absence, zero-width distinction, 154 tests, 61x2 CLI, and 99 corpus pass. |
| 37 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3` | `done` | Julia exact position fixture, nullable absence, zero-width distinction, 1,022 assertions, 61x2 CLI, and 99 corpus pass; position parent closes. |
| 38 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1` | `done` | Rust short aliases and existing switch exclusion return exact `["elif","case-b"]`; 137 library, 194 integration, 99 oracle, and 61x2 CLI pass. |
| 39 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2` | `done` | Dart marker switch grouping returns exact `["elif","case-b"]`; 155 tests, 61x2 CLI, and 99 corpus pass. |
| 40 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3` | `done` | Julia marker switch grouping returns exact `["elif","case-b"]`; 1,023 assertions, 61x2 CLI, and 99 corpus pass; control parent closes. |
| 41 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1` | `done` | Exact Rust anonymous/named capture values, symbolic marks, implicit AND blind-call result, 196 integration, and full recurring gate pass. |
| 42 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2` | `done` | Exact Dart anonymous/named capture values, rule-local code-unit marks with character projections, implicit AND result, 160 tests, 61x2 CLI, and 99 corpus pass. |
| 43 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3` | `done` | Exact Julia anonymous/named capture values, rule-local code-unit marks with character projections, implicit AND result, 1,028 assertions, primary CLI, and 99 corpus pass; capture parent closes. |
| 44 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5` | `done` | Corrected 239-name inventory, Perl-contract reverse check, six governed admissions, and exact 105/105 four-backend proof; `.1.6.1` closes. |
| 45 | `FUTURE-PARITY-BACKLOG.1.6.2.0` | `done` | Toolbox/source audit found stale Perl descriptor-model identity and split reconciliation, Rust projection, and final admission. |
| 46 | `FUTURE-PARITY-BACKLOG.1.6.2.1` | `done` | Perl now reports the composing descriptor state plus explicit nested model identities; Phase 0 `1..1030` passes. |
| 47 | `FUTURE-PARITY-BACKLOG.1.6.2.2` | `done` | Typed Rust descriptor state/JSON, ordered dependency refs, staged metadata, round trips, and full Rust gate pass. |
| 48 | `FUTURE-PARITY-BACKLOG.1.6.2.3` | `done` | Exact shared descriptor/function-record contract passes all four variants; `.1.6.2` closes. |
| 49 | `FUTURE-PARITY-BACKLOG.1.6.3.0` | `done` | Audit found raw runtime `Result<_, String>` APIs and split typed implementation from admission. |
| 50 | `FUTURE-PARITY-BACKLOG.1.6.3.1` | `done` | Typed/JSON errors, source/top/child attribution, five focused tests, and full runtime package pass. |
| 51 | `FUTURE-PARITY-BACKLOG.1.6.3.2` | `done` | Full Rust/CLI gate passes; diagnostics promote to pass at census 53/1/6; `.1.6.3` closes. |
| 52 | `FUTURE-PARITY-BACKLOG.1.6.4` | `done` | All four native libraries consume exact portable resolution/loading semantics; parent admitted and closed. |
| 53 | `FUTURE-PARITY-BACKLOG.1.6.5.0` | `done` | Audit proves injection begins at runtime and splits three bounded implementation/admission leaves. |
| 54 | `FUTURE-PARITY-BACKLOG.1.6.5.1` | `done` | Optional emitter, balanced scopes/failures, exact identity, 168 tests, 61x2 CLI, and 105 corpus pass. |
| 55 | `FUTURE-PARITY-BACKLOG.1.6.5.2` | `done` | Function parser/shell and staged queue/job/phase/stitch trace pass 172 tests, 61x2 CLI, and 105 corpus. |
| 56 | `FUTURE-PARITY-BACKLOG.1.6.5.3` | `done` | Native IO-through-runtime routed proof passes; Dart trace promotes to pass at census 57/1/2; parent closes. |
| 57 | `FUTURE-PARITY-BACKLOG.1.6.6` | `done` | Exactly three generated-source states remain at 57/1/2; non-codegen `.1.6` closes and `.3` activates. |
| 58 | `FUTURE-PARITY-BACKLOG.3.0` | `done` | Perl/Rust/Dart/Julia source evidence is audited and five implementation/admission lanes are split. |
| 59 | `FUTURE-PARITY-BACKLOG.3.1.0` | `done` | Standalone Perl source recompiles but loses dependency alternative indexes; census corrects to 56/2/2. |
| 60 | `FUTURE-PARITY-BACKLOG.3.1.1` | `done` | Contract v1 fixes semantic roles, ten families, rejections, errors, direct fixture, and 8/105 proof. |
| 61 | `FUTURE-PARITY-BACKLOG.3.1.2` | `done` | Perl public/legacy emission, reconstruction, plan/trace/errors, and exact independent execution pass. |
| 62 | `FUTURE-PARITY-BACKLOG.3.1.3` | `done` | Perl/Rust v1 baseline admitted; Perl pass and Rust partial only for 8/105 breadth. |
| 63 | `FUTURE-PARITY-BACKLOG.3.1.3.0` | `done` | Rust's green pre-v1 scaffold gaps are exact and three bounded alignment/admission leaves exist. |
| 64 | `FUTURE-PARITY-BACKLOG.3.1.3.1` | `done` | Typed v1 identity/metadata/errors, compatibility adapters, focused 4/4, and full Rust gate pass. |
| 65 | `FUTURE-PARITY-BACKLOG.3.1.3.2` | `done` | Exact ten-family plan/four rejections/direct v1 result/three trace roles and full Rust gate pass. |
| 66 | `FUTURE-PARITY-BACKLOG.3.1.3.3` | `done` | Focused/full Perl/Rust gates pass; census 57/1/2; `.3.1` closes. |
| 67 | `FUTURE-PARITY-BACKLOG.3.2` | `done` | Strict recurring all-105 generated proof passes; Rust promotes at census 58/0/2. |
| 68 | `FUTURE-PARITY-BACKLOG.3.2.0` | `done` | Scalable staged classifier passes all 105 generated fixtures in one isolated crate. |
| 69 | `FUTURE-PARITY-BACKLOG.3.2.1` | `done` | All five failure-mechanism inventories are empty; no repair child or behavior change exists. |
| 70 | `FUTURE-PARITY-BACKLOG.3.2.2` | `done` | Unconditional recurring 105/105 plus full Rust gate admit generated-source breadth. |
| 71 | `FUTURE-PARITY-BACKLOG.3.3` | `done` | Dart passes deterministic emission, ten-family direct execution, and eight-case admission. |
| 72 | `FUTURE-PARITY-BACKLOG.3.3.1` | `done` | Dart emits deterministic v1 source and passes isolated compile/run plus complete Dart gates. |
| 73 | `FUTURE-PARITY-BACKLOG.3.3.2` | `done` | Exact ten-family plan/direct dispatch/four rejections/trace pass in isolated host package. |
| 74 | `FUTURE-PARITY-BACKLOG.3.3.3` | `done` | Exact 8/105 generated proof and complete gates promote Dart at census 59/0/1. |
| 75 | `FUTURE-PARITY-BACKLOG.3.4` | `done` | Julia deterministic emission, family/direct execution, and exact admission pass. |
| 76 | `FUTURE-PARITY-BACKLOG.3.4.1` | `done` | Deterministic v1 emission and isolated 18-assertion include/run/failure proof pass. |
| 77 | `FUTURE-PARITY-BACKLOG.3.4.2` | `done` | Exact ten-family direct plan, four rejections, trace, and isolated matrix pass. |
| 78 | `FUTURE-PARITY-BACKLOG.3.4.3` | `done` | Exact 8/105 interpreter-first host proof promotes Julia at census 60/0/0. |
| 79 | `FUTURE-PARITY-BACKLOG.3.5` | `done` | Four focused/complete backend proofs and 60/0/0 close generated-source parity. |
| 80 | `FUTURE-PARITY-BACKLOG.1.3` | `done` | Dedicated complete Lua parity plan exists; no implementation code changed. |
| 81 | `LUA-BACKEND-PARITY.1.1` | `active` | Lock Lua runtime/tooling/package/test/cache choices before code. |
| 65 | `FUTURE-PARITY-BACKLOG.2` | `pending` | Staged parsing generalization follows unless the director explicitly pivots. |
| 66 | `FUTURE-PARITY-BACKLOG.4.0` | `done` | Exact arity owners and existing open-bound helpers are audited; rollout is split by neutral/backend mechanism. |
| 67 | `FUTURE-PARITY-BACKLOG.4.1` | `done` | ADR 0030 and a gated neutral contract adopt final `...rest`, typed-array binding, and versioned records. |
| 68 | `FUTURE-PARITY-BACKLOG.4.2.1` | `done` | Perl preserves v1 fixed records and executes v2 fixed-prefix/rest signatures through generated source. |
| 69 | `FUTURE-PARITY-BACKLOG.4.2.2` | `done` | Rust v1/v2 parsed/compiled/described signatures and native/generated rest binding pass the unchanged fixture. |
| 70 | `FUTURE-PARITY-BACKLOG.4.3.1` | `done` | Dart v1/v2 spec/staged/descriptor/native/generated paths pass six neutral contract tests and complete gates. |
| 71 | `FUTURE-PARITY-BACKLOG.4.3.2` | `done` | Julia typed v1/v2 native/generated execution passes 55 neutral assertions and complete gates. |
| 72 | `FUTURE-PARITY-BACKLOG.4.4` | `done` | Four-backend no-drift closes; Lua native `.5.1`, descriptor `.5.3`, and generated `.8` obligations are explicit. |
| 73 | `LUA-BACKEND-PARITY.4.3.3.1.4` | `done` | Lua scalar numeric v1 and exact six-runtime admission are complete. |
| 74 | `FUTURE-PARITY-BACKLOG.11.1` | `done` | ADR 0031 selects `{|args| ...}`, dynamic caller context, and a backend-neutral rollout split. |
| 75 | `FUTURE-PARITY-BACKLOG.11.2` | `done` | Exact syntax/AST/dynamic-context cases and future fixture are independently checked in canonical CI. |
| 76 | `FUTURE-PARITY-BACKLOG.11.3.1` | `done` | Perl parses/preserves inert eight-field codeblock records through generated source and user functions. |
| 77 | `FUTURE-PARITY-BACKLOG.11.3.2` | `done` | Dynamic caller-context invocation, restoration, results, precedence, and typed failures pass on Perl. |
| 78 | `FUTURE-PARITY-BACKLOG.11.3.3.0` | `done` | Audit proves the required final-codeblock declaration is absent and splits design from behavior. |
| 79 | `FUTURE-PARITY-BACKLOG.11.3.3.1` | `done` | ADR 0032 adopts final-only `name: codeblock`; values retain their own invocation signatures. |
| 80 | `FUTURE-PARITY-BACKLOG.11.3.3.2` | `done` | Perl preserves final codeblock metadata and normalizes attached/parenthesized helper/user-function/receiver forms. |
| 81 | `FUTURE-PARITY-BACKLOG.11.3.4` | `done` | Perl callable-codeblock diagnostics, docs, and full-gate no-drift are closed. |
| 82 | `FUTURE-PARITY-BACKLOG.12.1` | `done` | Uniform binding, source migration, five-backend rejection, and public/capability admission are complete. |
| 83 | `FUTURE-PARITY-BACKLOG.12.1.0` | `done` | Exact source counts, toolbox gaps, backend owners, and the complete retirement sequence are durable. |
| 84 | `FUTURE-PARITY-BACKLOG.12.1.1` | `done` | Neutral selector-free binding, mutation, result, precedence, diagnostic, and migration semantics are executable. |
| 85 | `FUTURE-PARITY-BACKLOG.12.1.2` | `done` | Perl live/generated execution consumes the selector-free contract without source migration. |
| 86 | `FUTURE-PARITY-BACKLOG.12.1.3` | `done` | Rust native/generated execution consumes the one-binding contract. |
| 87 | `FUTURE-PARITY-BACKLOG.12.1.4` | `done` | Dart native/generated execution consumes the one-binding contract. |
| 88 | `FUTURE-PARITY-BACKLOG.12.1.5` | `done` | Julia native/generated execution consumes the one-binding contract. |
| 89 | `FUTURE-PARITY-BACKLOG.12.1.6` | `done` | Both Lua ABIs consume the one-binding contract before tracked source migration. |
| 90 | `FUTURE-PARITY-BACKLOG.12.1.7` | `done` | All 1,956 tracked selector-shaped sources are migrated; hard rejection is next. |
| 91 | `FUTURE-PARITY-BACKLOG.12.1.7.1` | `done` | All 210 exact shipped occurrences are removed; reference/generated behavior and full canonical gates pass. |
| 92 | `FUTURE-PARITY-BACKLOG.12.1.7.2` | `done` | All 390 exact file-backed occurrences are removed from 67 capability/oracle/corpus specs; all tracked `.spec` files scan at zero. |
| 93 | `FUTURE-PARITY-BACKLOG.12.1.7.3` | `done` | All 1,356 positive embedded occurrences are removed; recurring scan reports zero positives and 25 classified recognizer occurrences. |
| 94 | `FUTURE-PARITY-BACKLOG.12.1.8.1` | `done` | Perl rejects authored exact selectors before lowering; live/generated diagnostics and retained constructors are locked. |
| 95 | `FUTURE-PARITY-BACKLOG.13.1` | `pending` | Restore the codegen inspector after selector retirement. |
| 96 | `FUTURE-PARITY-BACKLOG.14` | `pending` | Extend the existing staged architecture with structural authoring and complete progressive/staged composition audits. |
| 97 | `FUTURE-PARITY-BACKLOG.14.0` | `done` | Director doctrine, existing ADR/prototype, present implementation gaps, and contradictory walkthrough evidence are durably split. |
| 98 | `FUTURE-PARITY-BACKLOG.14.1` | `pending` | Ratify and teach simple-regex linked-rule structural recursion. |
| 99 | `FUTURE-PARITY-BACKLOG.14.2` | `pending` | Audit and implement intended in-parse progressive multi-spec composition. |
| 100 | `FUTURE-PARITY-BACKLOG.14.3` | `pending` | Audit and implement later-stage AST-field enrichment. |
| 101 | `FUTURE-PARITY-BACKLOG.14.4` | `pending` | Close examples, implementation gaps, tooling, and no-drift. |
| 102 | `FUTURE-PARITY-BACKLOG.12.1.8.2` | `done` | Rust rejects exact selectors across compiled/generated boundaries and has no selector runtime dispatch. |
| 103 | `FUTURE-PARITY-BACKLOG.12.1.8.3` | `done` | Dart exact-selector rejection and complete bounded-bridge no-drift are closed. |
| 104 | `FUTURE-PARITY-BACKLOG.7.0` | `pending` | Recalibrate the oracle generator's default hard timeout from measured shipped-spec build costs. |
| 105 | `FUTURE-PARITY-BACKLOG.15` | `pending` | Normalize any standalone/dangling rule-level block to the existing `I` lifecycle. |
| 106 | `FUTURE-PARITY-BACKLOG.15.0` | `pending` | Confirm the currently unused dangling-brace slot and ratify anywhere-in-rule normalization. |
| 107 | `FUTURE-PARITY-BACKLOG.15.1` | `pending` | Implement the shorthand on Perl and Rust after design ratification. |
| 108 | `FUTURE-PARITY-BACKLOG.15.2` | `pending` | Align remaining backends, generated paths, docs, and no-drift proof. |
| 109 | `FUTURE-PARITY-BACKLOG.12.1.8.3.1` | `done` | Exact selectors fail across Dart compiled/generated boundaries; runtime dispatch is deleted. |
| 110 | `FUTURE-PARITY-BACKLOG.12.1.8.3.2` | `done` | Exact variadic `blkVFN` capture parity restores the 205-test/61x2/105 Dart gate. |
| 111 | `FUTURE-PARITY-BACKLOG.12.1.8.4` | `done` | Julia rejects exact selectors across native/generated boundaries and has no selector runtime dispatch. |
| 112 | `FUTURE-PARITY-BACKLOG.12.1.8.5` | `done` | Lua rejects exact selectors at compile/runtime-engine admission and has no selector runtime dispatch. |
| 113 | `FUTURE-PARITY-BACKLOG.12.1.8.6` | `done` | One canonical checker locks all five diagnostics/boundaries and zero runtime selector compatibility. |
| 114 | `FUTURE-PARITY-BACKLOG.12.1.9` | `done` | Public checker locks 47 files at zero current examples and capability admission. |
| 115 | `FUTURE-PARITY-BACKLOG.12.1.10` | `done` | All 56 public files are gated and backend READMEs teach only bare typed bindings. |
| 116 | `LUA-BACKEND-PARITY.4.3.3.2` | `done` | Lua numeric aliases, symbol callees, and number receiver chains pass both ABIs. |
| 117 | `LUA-BACKEND-PARITY.4.3.3.3` | `active` | Implement aggregate numeric reducers and array receiver terminals. |
| 69 | `FUTURE-PARITY-BACKLOG.5` | `pending` | Helper caveats are documented but not normalized. |
| 70 | `FUTURE-PARITY-BACKLOG.6` | `pending` | Plugin machinery fate is a Perl-reference facade decision. |
| 71 | `FUTURE-PARITY-BACKLOG.7` | `pending` | Richer oracle candidates need safe fixture triage. |
| 72 | `FUTURE-PARITY-BACKLOG.8.1` | `pending` | Director's single-source parser+stimuli roundtrip arc is parked for later design. |
| 73 | `FUTURE-PARITY-BACKLOG.9.1` | `pending` | Director's corrected AND/OR edge-default arc is parked for later design. |
| 74 | `FUTURE-PARITY-BACKLOG.10.1` | `pending` | Director's semantic-introspection API/MCP arc is parked behind the active backend frontier. |

## `FUTURE-PARITY-BACKLOG.1.5.1.6.1` Neutral Hex-Byte Fixture Materialization

Implementation evidence recorded on 2026-07-10:

- Schema version 1 input workspace records now require `path` plus exactly one of checked-in `source` or inline
  `bytes_hex`. Existing source-backed cases are unchanged and later backends consume the same manifest.
- `bytes_hex` is validated as a non-empty lowercase even-length sequence of byte pairs. Both/neither source forms,
  empty values, uppercase, odd length, and non-hex text fail manifest validation before command launch.
- Materialization uses `pack('H*', ...)` and the existing raw writer. A focused fake backend reads the generated
  file and proves exact bytes `00 c3 28 ff 0a`, including NUL and invalid UTF-8, inside the canonical workspace.
- `cli_conformance/README.md` documents the portable mechanism and why explicit bytes avoid opaque binary blobs.
  The process suite remained 53 cases until `.6.2` added eight valid/preserved/invalid UTF-8 behavior families.

## `FUTURE-PARITY-BACKLOG.1.5.1.6.2` Strict Perl UTF-8 Adapter Boundary

Implementation evidence recorded on 2026-07-10:

- `bin/linkedspec` decodes every valid raw argument with `Encode::decode(..., FB_CROAK)` before exact option
  parsing. Source/input files are read as raw bytes and strictly decoded at their compilation/input-load phases.
- Raw stdout/stderr remain explicit. Usage/error text is encoded once, and `JSON::PP->utf8(1)` recursively emits
  canonical UTF-8 bytes without the previous byte-string double encoding.
- No normalization, BOM removal, newline conversion, or trimming occurs. An input fixture preserves U+FEFF,
  composed `é`, CRLF, decomposed `e` + U+0301, and LF exactly. A leading spec BOM reaches grammar compilation and
  fails rather than being stripped. Invalid spec/input byte sequences retain compilation/input-load failures.
- Eight shared cases raise the manifest from 53 to 61. Full-level trace proves `xé` is three input bytes and its
  JSON string is five bytes. Nested Unicode object/array output proves recursive JSON encoding.

## `FUTURE-PARITY-BACKLOG.1.5.1.6.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.6.0` proved invalid source/input bytes are required but the runner only copied
  checked-in files, forcing an opaque binary blob without a schema mechanism.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_validate_manifest` and `_materialize_case_files` required `source` for every
  `files` record; no exact inline byte representation existed.
- [x] **FIX** — Add mutually exclusive validated `bytes_hex`, raw `pack` materialization, focused tests, and docs.
- [x] **ADDRESSED (verified)** — Exact non-text bytes, both/neither/empty/case/length/character validation,
  pre-launch failure, source compatibility, safe paths, and workspace behavior are locked.
- [x] **NO REGRESSION** — Six runner subtests, syntax, checked-in help, full local CI, Knowledge Map, governance,
  mdBook, whitespace, and cleanup pass.
- [x] **LOCKSTEP** — Runner/docs/task/KM/book surfaces expose one neutral mechanism; `.6.2` is active for behavior.

## `FUTURE-PARITY-BACKLOG.1.5.1.6.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec process probe returns UTF-8 argv `xé` as mojibake JSON bytes
  `22 78 c3 83 c2 a9 22 0a`; strict invalid source/input fixture bytes are not rejected by UTF-8 decoding.
- [x] **ROOT CAUSE (WHY + WHERE)** — `bin/linkedspec` parses raw `@ARGV`, `_slurp` returns raw bytes, and
  `JSON::PP` is not in UTF-8 byte mode; decoded native `LinkedSpec::Get` probes already return exact Unicode.
- [x] **FIX** — Strictly decode valid argv and raw source/input files at the adapter boundary, emit canonical JSON
  UTF-8 once, preserve BOM/code points/newlines, and add shared literal/file/invalid/trace fixtures.
- [x] **ADDRESSED (verified)** — Exact neutral cases prove composed/decomposed text, UTF-8 BOM/newlines, Unicode
  source/input/result, phase-stable invalid bytes, and trace input/result byte counts in default/POSIX environments.
- [x] **NO REGRESSION** — CLI/runner/trace syntax and focused suites, complete neutral manifest twice, full local
  CI through Phase 0, Knowledge Map, governance, mdBook, whitespace, and safe generated-artifact cleanup pass.
- [x] **LOCKSTEP** — Adapter/fixtures/task/roadmaps/live docs/book/KM agree on Unicode scalar text encoded as UTF-8;
  UTF-16/UTF-32 remain outside the primary command unless a future explicit encoding contract adopts them.

## `FUTURE-PARITY-BACKLOG.1.5.1.6.3` Reference Closeout Evidence

- Current-state searches separate dated pre-fix/53-case history from live claims. Live surfaces consistently state
  that Perl passes 61 cases, the UTF-8 adapter gap is resolved, and Rust `.1.5.2` is next.
- The exact help snapshot discloses strict UTF-8, preservation, and no implicit UTF-16/UTF-32 detection. The
  mdBook describes Unicode as logical text and UTF-8 as the selected wire encoding.
- No implementation, manifest, expected byte, or shared CLI contract changes in this closeout leaf. It only
  reconciles task parents, current status, retrieval facts, and the next frontier.

## `FUTURE-PARITY-BACKLOG.1.5.1.6.0` Strict UTF-8 Policy Audit and Split

Implementation evidence recorded on 2026-07-10:

- A separated process probe passed UTF-8 argv `xé` through `input_text()`. Perl emitted JSON hex
  `22 78 c3 83 c2 a9 22 0a` (`"xÃ©"`) instead of `22 78 c3 a9 22 0a` (`"xé"`). Isolated `JSON::PP`
  probing showed byte strings `c3 a9` become two code points before UTF-8 output.
- Toolbox-style direct `LinkedSpec::Get` probes passed decoded strings with native trace suppressed. A decoded
  `input_text()` result and a Unicode `/é/` regex both compiled/executed and serialized as exact `c3 a9`. The engine
  already supports this boundary; the primary adapter's missing decode is the root cause.
- Source audit found Julia primary argv/file state is `String` and Rust native boundaries are `&str`/`String` plus
  `read_to_string`. Keeping Perl byte-oriented would guarantee backend drift. Dart will inherit the same explicit
  contract when its primary CLI is repaired.
- ADR `0025` defines strict UTF-8 text, no normalization/BOM removal/newline conversion/trimming, UTF-8 JSON and
  trace byte counts, stable invalid-source/input phase projection, valid argv as interface precondition, and an
  explicit exclusion for accidental binary input.
- The neutral runner can only copy checked-in source files today. `.6.1` adds validated hex-byte materialization,
  `.6.2` implements Perl decode plus valid/invalid shared fixtures, and `.6.3` closes the reference/no-drift gate.

## `FUTURE-PARITY-BACKLOG.1.5.1.6.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Exact separated bytes prove UTF-8 argv is currently double-encoded in successful JSON.
- [x] **ROOT CAUSE (WHY + WHERE)** — Raw `@ARGV`/ordinary reads remain byte strings at `bin/linkedspec`; native
  decoded `Get`/regex probes are correct, so the defect is isolated to the CLI process adapter.
- [x] **FIX** — Ratify ADR `0025` and split hex fixture materialization, Perl decode/fixtures, and final closeout
  before changing runner or adapter behavior.
- [x] **ADDRESSED (verified)** — Arg/file/source/input/JSON/trace encoding, preservation, invalid phases, binary
  exclusion, other-backend alignment, and runner capability gap each have an explicit contract/owner.
- [x] **NO REGRESSION** — Read-only probes plus Knowledge Map, governance, mdBook, whitespace, and cleanup pass;
  no implementation source changed.
- [x] **LOCKSTEP** — Roadmap/live/task/KM/book/ADR surfaces identify `.6.1` as the next leaf and keep Rust gated.

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

## `FUTURE-PARITY-BACKLOG.1.5.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The shared runner establishes the old Dart primary at 0/61; direct staged API
  regression reproduces an ordinary no-`fn` spec failing with `cursor_code_unit=0`.
- [x] **ROOT CAUSE (WHY + WHERE)** — `bin/linkedspec_dart.dart` routed to the corpus command, while
  `UserFunctionDefinitionAstParser.parse(...)` interpreted a no-match extraction as an error instead of the valid
  empty-definition case. Dart `String.trim()` also erases leading U+FEFF unless the adapter preserves policy first.
- [x] **FIX** — Added the exact raw-byte primary adapter, strict manual arguments/help, deterministic resolution,
  compile-before-input UTF-8 loading, source-BOM guard, and empty-definition staged result; kept corpus options only
  in `bin/corpus_runner.dart`.
- [x] **ADDRESSED (verified)** — Six direct adapter tests, the staged ordinary-spec regression, and 29 exact shared
  cases cover every boundary/loading/phase behavior owned by this leaf in default and POSIX environments.
- [x] **NO REGRESSION** — Analyzer, all 147 Dart tests, and the independent 99/99 corpus gate pass.
- [x] **LOCKSTEP** — README, mdBook, Knowledge Map, task/roadmap/live docs, and local gate distinguish the shared
  primary boundary from the separate corpus runner; `.1.5.3.2` owns only native execution/results/failures.

## `FUTURE-PARITY-BACKLOG.1.5.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The `.1` baseline passes 29/61 and every one of the 11 successful result cases fails
  only because the prepared request deliberately stops at the invocation boundary.
- [x] **ROOT CAUSE (WHY + WHERE)** — `runLinkedSpecDartPrimaryCli(...)` discarded `CompiledSpec`, loaded input only
  for phase proof, and returned the stable invocation failure without calling the existing native engine.
- [x] **FIX** — Retain compiled state, compose `LinkedSpecRuntimeEngine` with native parse-mode/top-rule controls,
  serialize `RuntimeParseResult.value`, recursively sort map keys, encode compact UTF-8 JSON, and append one newline.
- [x] **ADDRESSED (verified)** — Focused nested/top/mode coverage and all 11 unchanged result cases pass in default
  and POSIX environments; quiet trace also passes without trace machinery.
- [x] **NO REGRESSION** — Analyzer, the complete Dart suite, and separate 99/99 corpus gate remain green.
- [x] **LOCKSTEP** — Task/roadmap/live docs, README, mdBook, and Knowledge Map advance to 41/61 and identify exactly
  20 canonical-trace residuals under `.1.5.3.3`.

## `FUTURE-PARITY-BACKLOG.1.5.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The `.2` full classification is 41/61; all 20 failures are exact trace records,
  routing/reset/append, emoji/escaping/byte counts, or traced phase failures.
- [x] **ROOT CAUSE (WHY + WHERE)** — The primary adapter parsed trace options but intentionally ignored them;
  Dart's existing rich `LinkedSpecTraceEmitter` is backend-specific and cannot satisfy ADR `0024` byte identity.
- [x] **FIX** — Added an adapter-local canonical phase trace with exact thresholds/aliases, UTF-8 byte accounting,
  field escaping, emoji, stdout/route/mirror, reset/append, persistence, failures, and stable IO-error projection.
- [x] **ADDRESSED (verified)** — Focused stdout, routed emoji/reset, and setup-failure tests pass; all 20 previously
  failing trace cases now pass unchanged.
- [x] **NO REGRESSION** — Analyzer, full Dart tests, separate 99/99 corpus, and all 61 shared cases pass in both
  default and POSIX environments; native rich trace remains independent.
- [x] **LOCKSTEP** — README, mdBook, Knowledge Map, task/roadmap/live docs identify Dart at 61/61 and advance only
  to recurring-gate/no-drift `.1.5.3.4`.

## `FUTURE-PARITY-BACKLOG.1.5.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Dart passes 61/61 manually, but `tools/run_dart_local.sh` did not yet make either
  default/POSIX shared leg recurring and the parent status still advertised active rollout work.
- [x] **ROOT CAUSE (WHY + WHERE)** — The focused gate retained only primary help plus corpus checks from the old
  scoped milestone; global task/roadmap/book/KM/live status had not consumed `.1`-`.3` completion.
- [x] **FIX** — Added both exact shared legs to the focused Dart gate and reconciled every live/public continuity
  surface; closed `.1.5.3` without changing fixtures/help/runtime behavior.
- [x] **ADDRESSED (verified)** — The focused gate passes 151 tests, 61/61 default, 61/61 POSIX, and 99/99 corpus;
  shared help/manifest bytes remain unchanged.
- [x] **NO REGRESSION** — The broader local gate passes doctrines/syntax, 22 ActionIR, nine runner/trace, both Perl
  61-case legs, and Phase 0 `1..1028` in 527 seconds.
- [x] **LOCKSTEP** — Task parents, task index, roadmaps, README, mdBook, Knowledge Map, and live docs close Dart and
  advance only to global four-backend identity `.1.5.4`.

## `FUTURE-PARITY-BACKLOG.1.5.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run all 61 unchanged cases against the Julia project command after using its existing
  warmup convention; baseline is 13/61, with 48 exact failures.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_primary_cli_usage()` is a local template; `_read_primary_cli_file` accepts
  Julia invalid strings; `_print_primary_cli_runtime_error` appends backend detail; `_primary_cli_trace_emitter`
  routes rich native events. Cold first load may also emit Julia precompile progress before project warmup.
- [x] **FIX / SPLIT** — `.1` owns help/UTF-8/stable errors, `.2` owns independent canonical trace, and `.3` owns
  warmup plus one recurring four-command driver and final lane closeout.
- [x] **ADDRESSED (verified)** — Every one of the 48 failures maps to one ordered leaf; all 11 native result cases
  already pass unchanged and need no semantic rewrite.
- [x] **NO REGRESSION** — This slice changes no Julia, fixture, help, or driver behavior.
- [x] **LOCKSTEP** — Task/roadmap/live/book/KM surfaces advance only to `.1.5.4.1`; `.1.6` remains behind exact CLI.

## `FUTURE-PARITY-BACKLOG.1.5.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The warmed 13/61 audit identifies shorter help, malformed-file acceptance, and
  backend-detail stderr independently of canonical trace.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_primary_cli_usage()` was Julia-local; `read(path, String)` creates an
  invalid Julia string without rejecting malformed bytes; `_print_primary_cli_runtime_error(...)` projected rich
  native diagnostics onto the portable process surface.
- [x] **FIX** — Render the exact shared command help, read raw bytes and require `isvalid`, and keep primary stderr
  to its one phase heading. Native structured exceptions and rich trace APIs remain below the adapter.
- [x] **ADDRESSED (verified)** — Focused tests lock exact help, malformed spec/input rejection, and exact errors;
  the package passes 1,019 assertions, the updated nine-family real-process checker passes, and corpus is 99/99.
- [x] **NO REGRESSION** — All non-trace shared cases pass in default and POSIX environments. Julia advances to
  42/61; the 19 failures are exactly the canonical-trace inventory already owned by `.1.5.4.2`.
- [x] **LOCKSTEP** — Task/roadmap/live/book/KM surfaces advance only to `.1.5.4.2`; fixtures and native rich
  diagnostics/trace remain unchanged.

## `FUTURE-PARITY-BACKLOG.1.5.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — After `.1`, exactly 19/61 failures remain in both environments; every mismatch is
  rich Julia trace instead of ADR `0024` bytes.
- [x] **ROOT CAUSE (WHY + WHERE)** — `run_cli(...)` passed `_primary_cli_trace_emitter(...)` through native
  frontend/compiler/runtime operations, coupling the portable command to backend-internal scopes and events.
- [x] **FIX** — Add an adapter-local canonical recorder and emit compile/input/invoke phases around the unchanged
  native parse/compile/execute calls. Normalize optional-minus ASCII numeric thresholds with arbitrary precision.
- [x] **ADDRESSED (verified)** — Exact tests lock records, UTF-8 counts, percent escaping, huge numeric levels,
  sinks/reset/emoji, and native-trace independence; package/process/corpus gates all pass.
- [x] **NO REGRESSION** — The unchanged suite passes 61/61 default and POSIX; Julia local proof remains 1,019
  assertions, nine direct process families, and 99/99 corpus.
- [x] **LOCKSTEP** — Task/roadmap/README/live/book/KM surfaces report Julia 61/61 and activate only the recurring
  four-command driver `.1.5.4.3`; shared fixtures and native trace APIs are unchanged.

## `FUTURE-PARITY-BACKLOG.1.5.4.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Four commands individually pass the shared suite, but no single recurring owner
  builds/prepares/warms and invokes all four under both option environments.
- [x] **ROOT CAUSE (WHY + WHERE)** — Backend-focused scripts duplicate single-backend invocations; Julia requires
  explicit normal-project warmup, and the core gate intentionally avoids mandatory non-Perl toolchains.
- [x] **FIX** — Add `tools/run_primary_cli_matrix.sh` and an opt-in `LINKEDSPEC_RUN_CLI_MATRIX=1` core-gate hook;
  track every backend script as a protected CI input and syntax-check them together.
- [x] **ADDRESSED (verified)** — The new driver passes 4 backends x 2 environments x 61 unchanged cases after
  building Rust, preparing Dart, and explicitly warming Dart/Julia.
- [x] **NO REGRESSION** — Rust, Dart, and Julia focused gates pass completely after the 4x2x61 matrix; the broader
  core gate also passes doctrines/syntax, 22 ActionIR, nine runner/trace checks, Perl 61x2, and Phase 0 `1..1028`.
- [x] **LOCKSTEP** — Task/roadmap/live/book/KM surfaces close `.1.5` and activate only capability census `.1.6`;
  safe post-verification cleanup removes reproducible Rust, Julia, and Dart caches without retaining in-flight work.

## `FUTURE-PARITY-BACKLOG.1.6.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The 99-case corpus and 61-case CLI suite are green on all four backends, but neither
  is an exhaustive machine-readable inventory of current mdBook and exported native API capabilities.
- [x] **ROOT CAUSE (WHY + WHERE)** — Capability claims were distributed across the mdBook, public exports, Phase 0,
  backend tests, corpus, trace facts, and codegen facts; no validated row mapped every backend state to evidence and
  a residual owner.
- [x] **FIX** — Add `capability_conformance/manifest.json`, a strict repo-path/owner/schema checker, core-gate
  integration, public documentation, a retrieval fact, and exact `.1.6.1`–`.1.6.6` mechanism leaves.
- [x] **ADDRESSED (verified)** — Fifteen capabilities x four backends classify 47 pass, five partial-proof, and
  eight gap states; every non-pass state and every explicit future/legacy exclusion has a tracked owner.
- [x] **NO REGRESSION** — Checker syntax/self-validation, core gate through Phase 0, docs/KM/governance, mdBook,
  whitespace, and generated-artifact cleanup pass; no parser/compiler/runtime behavior changes.
- [x] **LOCKSTEP** — Matrix/task/roadmaps/README/live docs/book/KM agree; `.1.6.1` becomes the sole active next leaf
  while codegen remains top-level `.3` and no backend is called complete.

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
- `2026-07-10`: `.1.5.3.0` proves Dart's 0/61 primary-command gap is an adapter replacement, not a missing
  language pipeline. `bin/corpus_runner.dart` retains the corpus workflow. The primary command will reuse staged
  full-spec parsing, validation/compilation, direct-value execution, top-rule/global-mode controls, and rich native
  trace, while exact process/loading, results/failures, portable trace, and closeout remain separate leaves.
- `2026-07-10`: `.1.5.3.1` replaces the corpus primary with exact arguments/help/resolution/strict UTF-8 and stable
  phase bytes, reaching 29/61 in both option environments. A native probe exposed the staged extractor's no-`fn`
  no-match as an erroneous failure; no definitions now correctly returns an empty list. Source U+FEFF is preserved
  and rejected before Dart frontend trimming can erase it. `.2` owns the 11 direct results; `.3` owns 21 trace cases.
- `2026-07-10`: `.1.5.3.2` spends Dart's existing native engine controls and direct `value`, not the corpus
  `[value]` wrapper. Recursive key sorting plus compact UTF-8 JSON closes all 11 success results; quiet trace also
  passes without records, producing a 41/61 baseline whose 20 residuals are exclusively canonical trace.
- `2026-07-10`: `.1.5.3.3` adds the ADR `0024` adapter trace independently of rich native Dart trace. Exact levels,
  records, UTF-8 counts, escaping, emoji, sinks, reset/append, persistence, and failure projection close all 20
  residuals; Dart reaches 61/61 default/POSIX and `.4` owns recurring verification/no-drift only.
- `2026-07-10`: `.1.5.3.4` makes both 61-case environments part of the focused Dart gate alongside 151 tests and
  99/99 corpus. The broader gate passes through Phase 0 `1..1028`; parent `.1.5.3` closes and global four-backend
  identity `.1.5.4` becomes active without changing help, fixture, or runtime semantics.
- `2026-07-10`: `.1.5.4.0` measures warmed Julia at 13/61: all ordinary results plus silent trace pass. The 48
  residuals are shared help, strict invalid UTF-8 plus phase-only stderr, and canonical trace. Cold precompile
  progress is toolchain ambient and must be handled by driver warmup. `.1`/`.2` repair Julia; `.3` owns one matrix.
- `2026-07-10`: `.1.5.4.1` makes the Julia primary boundary exact without changing native semantics: shared help,
  raw-byte strict UTF-8 file validation, and phase-only stderr advance both option environments from 13 to 42/61.
  The remaining 19 cases are exclusively canonical trace under active `.1.5.4.2`.
- `2026-07-10`: `.1.5.4.2` replaces only Julia primary trace projection with ADR `0024`'s deterministic phases.
  Native rich trace remains intact. Julia reaches 61/61 default/POSIX, and `.1.5.4.3` becomes the sole active leaf
  for warmup plus a recurring four-command identity gate.
- `2026-07-10`: `.1.5.4.3` installs `tools/run_primary_cli_matrix.sh` as the single recurring 4x2x61 proof, including
  Rust build, Dart preparation/warmup, and Julia project warmup. Focused Rust/Dart/Julia gates and the broader
  Phase 0 gate pass; exact CLI parent `.1.5` closes and capability census `.1.6` becomes active.
- `2026-07-10`: `.1.6.0` separates complete capability parity from green CLI/corpus subsets. A validated
  15-capability/60-state matrix owns language-proof coverage, Rust descriptor/diagnostics, native named/file
  resolution, Dart full-pipeline trace, and generated-source residuals without treating future/legacy surfaces as
  accidental current requirements.
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
- `2026-07-10`: `.1.5.1.6.2` strictly decodes Perl argv/source/input, preserves normalization/BOM/newlines,
  recursively emits UTF-8 JSON once, and keeps invalid files in compilation/input-load phases. Eight exact
  Unicode/invalid families raise the shared suite to 61/61 in default/POSIX environments. `.6.3` becomes active
  for final reference no-drift; Unicode is the logical model and UTF-8 the selected boundary encoding.
- `2026-07-10`: `.1.5.1.6.3` reconciles every live reference surface at 61 cases, keeps pre-fix/53-case evidence
  explicitly historical, closes parents `.1.5.1.6` and `.1.5.1`, and activates Rust `.1.5.2` against the unchanged
  manifest. No implementation or expected bytes change in this closeout.
- `2026-07-10`: Director clarification corrects the closed `.14` abstraction: scalar, array, harray, and codeblock
  are the four object/value kinds, and a signature accepting a final codeblock must make `call(args) { block }`
  equivalent to `call(args, { block })` across helper/user-function/receiver surfaces and all variants. Current
  Perl/Rust/Dart/Julia behavior remains name-specific; Lua is absent. `.11.0` captures this without pivoting, and
  `.11.1` owns canonical design, parity splitting, terminology, and whether `with` remains or is removed.

## Open Questions

- None blocking `.3.1`: exact CLI and non-codegen parity are closed. Lua `.1.3` remains gated until the neutral
  generated-source contract, Rust full-manifest breadth, Dart/Julia emitters, and exact `.3.5` admission close.
- ADR 0031 uses semantic term `harray` while current helper spellings may still say `hash`, and retains `with` as
  an ordinary block-taking helper. ADR 0032 defines final-only `name: codeblock`; Perl closeout is complete.
- No decision remains about spec-facing `array(IDENTIFIER)` / `hash(IDENTIFIER)` selectors: `.12.1` must remove
  them. That leaf separately classifies only non-selector constructor spellings.

## Blockers

- None. Perl callable-codeblock construction, invocation, normalization, and closeout `.11.3` are complete.
  `.12.1` now owns the director-prioritized removal of spec-facing aggregate selectors before Rust codeblock or
  Lua work. Lua variadic work remains explicitly owned by `.5.1`/`.5.3`/`.8`, and scalar numeric `.4.3.3.1.4`
  remains ready afterward.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.1.1` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | PASS. Local CI includes phase0 `1..1028`; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.1.2` | `git diff --check`; stale handoff/frontier `rg` scan; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_task_tree_metadata.sh`; `bash scripts/check_doctrines.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning only; created `JULIA-BACKEND-PARITY` and no Julia package or implementation code. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.8.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning capture only; no implementation code changed. |
| `2026-07-09` | `FUTURE-PARITY-BACKLOG.9.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `mdbook build docs/linkedspec-book` | PASS. Planning capture only; no implementation code changed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.10.0` | `git diff --check`; `bash scripts/check_memory_architecture.sh`; Knowledge Map generation/check; doctrine; task-tree metadata; `mdbook build docs/linkedspec-book`; cleanup | PASS. Semantic introspection/MCP is durably parked with native-API ownership and transport separation; no implementation or active-frontier change. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.11.0` | Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; whitespace; `mdbook build docs/linkedspec-book`; generated-book cleanup; LinkedSpec lowering probes | PASS. Four-kind generic final-codeblock correction is parked with `with` disposition undecided; no behavior or active-frontier change. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.0` | Existing expression/duck-typing/KM audit; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; whitespace; mdBook build | PASS. Temporary-only compatibility and uniform four-kind expression doctrine are durable; `.12.1` owns later design/retirement; no behavior or active-frontier change. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.4` | Perl direct `LinkedSpec::Get` coderef probe; focused Dart runtime tests (50); direct Julia parse/compile/execute probe; static Rust core/runtime API and Dart/Julia CLI-adapter audit; `mdbook build docs/linkedspec-book`; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check` | PASS. ADR `0022` makes native in-memory embedding primary and CLIs secondary; current/future backend acceptance and public docs agree; no parser/compiler/runtime source changed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.0` | Delegated Julia `.7.3.1`: ADR `0023`; Perl CLI/trace contract and Rust public source-emitter audit; global task routing; mdBook build; Knowledge Map generation/check; memory/task/doctrine/whitespace gates. | PASS. Exact primary CLI and public-capability parity are durable; `.1.5.1`–`.1.5.4`, `.1.6`, and `.3` own convergence; no implementation behavior changed. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.7.3.3` | Delegated current-surface audit; stale mdBook provenance/correction; exact owner routing; prior `431f0472` Julia proof; docs/KM/governance/whitespace and mdBook. | PASS. Julia's local audit is done while its root remains active/delegated; `.1.5.1` became next and `.1.5.1.0` has since split it. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.0` | ADR/KM/toolbox and Perl source/test audit; existing trace test; direct argument/environment/failure probes with separated stdout/stderr; docs/KM/governance/whitespace/mdBook. | PASS. Five implementation mechanisms are split; no behavior source changed; `.1.5.1.1` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.1` | CLI/runner/test syntax; 4 runner subtests/13 assertions; 2 trace CLI subtests; direct neutral help execution; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Schema/runner/workspace/channels/generated files and exact help are locked; `.1.5.1.2` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.2` | CLI/runner/test syntax; 22/22 exact cases under default and `POSIXLY_CORRECT=1`; 4 runner subtests; 2 trace CLI subtests; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Exact arguments/usage are environment-independent; `.1.5.1.3` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.3` | Toolbox Get/get_parser/generated-source/trace probes; 29/29 exact cases under default and `POSIXLY_CORRECT=1`; runner/trace tests; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Seven success cases lock exact source/input/parser/JSON behavior; `.1.5.1.4` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.4` | Direct separated failure probes; 33/33 exact cases under default and `POSIXLY_CORRECT=1`; ambient trace isolation; 4 runner + 3 trace subtests; docs/KM/governance/whitespace/mdBook and cleanup. | PASS. Operational phases/channels/exit are stable; `.1.5.1.5` became active and has since closed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.5` | Raw old-trace size/byte probes; signoff coverage/UTF-8/control-field audit; 53/53 exact cases under default and POSIX; 4 runner + 3 trace subtests; full local gate/Phase 0; docs/KM/ADR/governance/whitespace/mdBook and cleanup. | PASS. Canonical primary trace is closed; the surfaced pre-existing argv/JSON mojibake is owned by active `.1.5.1.6` before Rust. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.6.0` | Separated argv/JSON and isolated `JSON::PP` bytes; decoded `LinkedSpec::Get` input/Unicode-regex probes; Perl/Julia/Rust/runner/doc audit; ADR 0025; Knowledge Map; memory/task/doctrine/whitespace/mdBook/cleanup | PASS. Strict UTF-8 is ratified and split without implementation change; `.6.1` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.6.1` | Runner/test syntax; 6 runner subtests including exact `00c328ff0a` materialization and six invalid schema forms; checked-in help case; full local gate/Phase 0; docs/KM/governance/whitespace/mdBook/cleanup | PASS. Reusable hex bytes are locked; `.6.2` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.6.2` | Adapter/runner syntax; LinkedSpec before/after process probe; 8 selected UTF-8 cases; 9 runner/trace subtests; 61/61 default/POSIX; full local gate/Phase 0; docs/KM/governance/whitespace/mdBook/cleanup | PASS. Perl strictly enforces preserved UTF-8 text; `.6.3` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.1.6.3` | Current-state gap/count/frontier scans; focused runner/trace suites; 61/61 default/POSIX; full local gate/Phase 0; docs/KM/governance/whitespace/mdBook/cleanup | PASS. Perl reference closed; Rust `.1.5.2` active; no behavior change. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.2.0` | Rust workspace/native seam audit; unchanged 61-case classification; docs/KM/governance/whitespace/mdBook/cleanup. | PASS. Exact adapter/runtime work split before code. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.2.1` | Four focused tests; full runtime package; 22 help/usage plus UTF-8/failure cases; 29/61 baseline; format/build/Clippy classification; docs/KM/governance/mdBook/cleanup. | PASS. Exact binary/loading boundary landed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.2.2` | Direct execution/hash tests; 11 result cases; full runtime package; 41/61 baseline; format/build/Clippy classification; docs/KM/governance/mdBook/cleanup. | PASS. Reusable direct result/entry/mode execution landed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.2.3` | Six focused adapter tests; full runtime package; 61/61 unchanged suite; formatting/touched-file Clippy; docs/KM/governance/mdBook/cleanup. | PASS. Canonical Rust CLI trace landed. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.2.4` | `tools/run_rust_local.sh`; 137 unit/99 oracle/190 integration/3 emitter/10 native trace; 61/61 default/POSIX; full local gate through Phase 0 `1..1028`; docs/KM/governance/mdBook/cleanup. | PASS. Rust primary CLI closed; Dart `.1.5.3` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.3.0` | Dart CLI/native/API/manifest audit; unchanged 0/61 baseline; memory architecture; Knowledge Map; task metadata; doctrine; whitespace; mdBook; cleanup. | PASS. Four implementation/closeout mechanisms split before Dart behavior changes; `.1.5.3.1` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.3.1` | Six boundary tests; staged ordinary-spec regression; analyzer; 147 Dart tests; 99/99 corpus; 29/29 selected shared cases default/POSIX; docs/KM/governance/mdBook/cleanup. | PASS. Exact Dart process/loading boundary landed; `.1.5.3.2` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.3.2` | Focused native result test; analyzer/full Dart suite; 99/99 corpus; 12/12 result/quiet cases default/POSIX; full 41/61 classification; docs/KM/governance/mdBook/cleanup. | PASS. Direct canonical results landed; exactly 20 trace residuals remain under `.1.5.3.3`. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.3.3` | Three focused trace tests; analyzer/full Dart suite; 99/99 corpus; 61/61 default/POSIX; docs/KM/governance/mdBook/cleanup. | PASS. Canonical Dart trace closes all residuals; `.1.5.3.4` active for recurring gate/no-drift. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.3.4` | `tools/run_dart_local.sh`: 151 tests, 61/61 default/POSIX, 99/99 corpus; broader local gate through Phase 0 `1..1028` in 527s; docs/KM/governance/mdBook/cleanup. | PASS. Dart parent closed; global `.1.5.4` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.4.0` | Julia source/local-checker audit; warmed unchanged 13/61 baseline; docs/KM/governance/mdBook/cleanup. | PASS. Help/UTF-8/errors, canonical trace, and final matrix are separately owned; `.1.5.4.1` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.4.1` | Exact-help and malformed-file tests; complete Julia local gate: 1,019 assertions/nine process families/99 corpus; unchanged suite 42/61 default/POSIX; docs/KM/governance/mdBook/cleanup. | PASS. All 19 residuals are canonical trace; `.1.5.4.2` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.4.2` | Canonical trace unit/process proof; complete Julia local gate: 1,019 assertions/nine process families/99 corpus; unchanged suite 61/61 default/POSIX; docs/KM/governance/mdBook/cleanup. | PASS. Julia exact CLI is implemented; recurring four-command gate `.1.5.4.3` active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.5.4.3` | `tools/run_primary_cli_matrix.sh`: four backends x two environments x 61 cases; complete Rust/Dart/Julia focused gates; broader local gate through Phase 0 `1..1028`; docs/KM/governance/mdBook/cleanup. | PASS. Exact primary CLI parent `.1.5` closes; capability census `.1.6` is active. |
| `2026-07-10` | `FUTURE-PARITY-BACKLOG.1.6.0` | Capability checker syntax/self-validation; 15x4 evidence/owner census; local gate through Phase 0 `1..1028` in 496s; docs/KM/governance/mdBook/cleanup. | PASS. Five exact residual mechanisms plus generated-source `.3` are owned; neutral language proof `.1.6.1` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.2.3` | Shared schema; focused four-backend descriptor tests; complete Dart/Julia gates; complete Perl Phase 0; prior full Rust gate; capability/KM/memory/doctrine/whitespace/mdBook/cleanup. | PASS. Exact outward descriptor parity closes at 52 pass / one partial / seven gap; Rust diagnostics `.1.6.3` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.3.0` | Knowledge Map/toolbox/source audit of Rust error types, Engine methods, rule unwind, context, CLI, tests, and parity references; docs/KM/governance/whitespace/mdBook. | PASS. Corrected the actual raw-string boundary and split typed implementation `.1` from admission `.2`; no runtime code changed. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.3.1` | Format/check; five focused diagnostic tests; complete runtime package (137/105/196/5/3/10); strict Clippy classification; docs/KM/governance/whitespace/mdBook. | PASS. Typed/source/top/deepest-rule diagnostics and string/success compatibility land; `.1.6.3.2` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.3.2` | Complete `tools/run_rust_local.sh` (format, 137/105/196/5/3/10, 61x2 CLI); capability/KM/memory/doctrine/whitespace/mdBook; 2.0 GB cleanup. | PASS. Structured diagnostics promote to pass at census 53/1/6; `.1.6.3` closes and native resolution `.1.6.4` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.4.0` | Resolver/PathSearch/adapter source and test audit; capability/KM/memory/doctrine/whitespace/mdBook; generated-book cleanup. | PASS. Nondeterministic Perl and divergent Julia fallback are durable; six bounded leaves exist before behavior code. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.4.1` | ADR 0026; executable 13/9/4 contract/checker; complete local gate with 61x2 Perl CLI and Phase 0 `1..1030`; capability/KM/memory/doctrine/mdBook/cleanup. | PASS. Portable resolution/loading semantics are fixed before backend implementation. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.4.2` | Expanded 14/9/4 contract; five direct Rust loader tests; full Rust gate 137/105/196/5/3/5/10 plus 61x2 CLI; strict Clippy classification; capability/KM/memory/doctrine/whitespace/mdBook; 2.0 GB cleanup. | PASS. Rust native file role and CLI delegation pass; census 54/1/5; Dart `.3` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.4.3` | Public progressive Dart loader; five direct 14/9/4 plus pipeline tests; format/analyze; full Dart gate 165 tests, 61x2 CLI, and 105 corpus; capability/KM/memory/doctrine/whitespace/mdBook/cleanup. | PASS. Dart native file role and CLI delegation pass; census 55/1/4; Julia `.4` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.4.4` | Public progressive Julia loader; 82 direct 14/9/4 plus pipeline assertions; complete 1,110-assertion package; focused process check; 61x2 CLI; 105 corpus; capability/KM/memory/doctrine/whitespace/mdBook/cleanup. | PASS. Julia native file role and CLI delegation pass; recursive fallback removed; census 56/1/3; admission `.5` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.4.5` | Public Perl portable loader; direct 14/9/4 plus pipeline proof; canonical-gate wiring; 239-name coverage; focused suites; 61x2 CLI; Phase 0 `1..1030` in 556s; prior adjacent backend gates; capability/KM/memory/doctrine/whitespace/mdBook. | PASS. Exact four-backend native resolution admitted; `.1.6.4` closes and Dart trace `.1.6.5` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.5.0` | Knowledge Map/source audit across Dart emitter/runtime/parser/validator/compiler/function/staged/loader owners; Julia/Rust contract comparison; capability/KM/memory/doctrine/whitespace/mdBook. | PASS. Runtime-only boundary is exact; three bounded leaves exist before trace behavior changes; `.1` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.5.1` | Three focused identity/order/failure tests; six affected suites/38 tests; format; strict analysis; complete Dart gate with 168 tests, 61x2 CLI, and 105 corpus; docs/KM/governance/whitespace/mdBook/cleanup. | PASS. Core frontend/compiler trace lands without behavior drift; `.2` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.5.2` | Four focused full-topic/balance/identity/quiet/failure tests; strict analysis; complete Dart gate with 172 tests, 61x2 CLI, and 105 corpus; docs/KM/governance/whitespace/mdBook/cleanup. | PASS. Function/staged trace lands without diagnostic drift; admission `.3` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.5.3` | Three direct routed/quiet/failure native tests; 22 affected tests; format; strict analysis; complete Dart gate with 175 tests, 61x2 CLI, and 105 corpus; canonical core 61x2 CLI plus Phase 0 `1..1030` in 514s; capability/KM/memory/doctrine/whitespace/mdBook/cleanup. | PASS. Dart full-pipeline trace promotes to pass at 57/1/2; parent closes; `.1.6.6` active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.6.6` | Direct non-pass projection; 57/1/2 checker; immediately prior complete Dart/core gates; capability/KM/memory/doctrine/whitespace/mdBook/cleanup. | PASS. Only Rust/Dart/Julia generated-source states remain, all owned by `.3`; non-codegen `.1.6` closes and `.3` activates. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.0` | Knowledge Map-first source audit of Perl reference emission, public Rust emitter/family plan/isolated crate/eight-case subset, Dart/Julia source absence, 105-case manifest boundary; docs/KM/governance/whitespace/mdBook/cleanup. | PASS. Neutral contract, Rust breadth, Dart, Julia, and admission lanes are split before behavior code; census remains 57/1/2 and `.3.1` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.0` | Toolbox `LinkedSpec::Get` normal/captured-source comparison; isolated eval/load; debug generated-branch trace; reduced `LinkedRE::oredRE` serialization/package-binding probes; source audit; 56/2/2 capability/KM/governance/whitespace/mdBook/cleanup. | PASS. Captured Perl source is not standalone-equivalent; contract, repair, and admission are split before code and `.3.1.1` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.1` | Strict v1 schema/fixture checker; 10 families/4 rejections/error contract/direct trace+identity fixture/8-of-105 subset/live-state cross-check; canonical CI through Phase 0 `1..1030`; docs/KM/governance/whitespace/mdBook/cleanup. | PASS. Contract is canonically gated without backend behavior changes; Perl repair `.3.1.2` is active at 56/2/2. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.2` | Public/legacy deterministic source; isolated result/trace/identity/plan/error fixture; index 0/1 plus slash regex; four existing generated trace suites; measured Phase 0 FAIL 2/1030 stale locks -> PASS `1..1030` in 546s; canonical CI/docs/KM/governance/mdBook/cleanup. | PASS. Perl behavior repair is complete; capability stays partial until explicit `.3.1.3` admission. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.3.0` | Knowledge Map/source audit of Rust emitter API, markers, plan/error/trace roles, isolated harness, and exact subset; focused `source_emitter` 3/3 in 35.69s; capability/KM/governance/whitespace/mdBook/cleanup. | PASS. Four pre-v1 contract gaps are split into metadata/error `.1`, plan/trace `.2`, and admission `.3`; no behavior/status change. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.3.1` | Typed v1 emitter/metadata/errors and compatibility adapters; focused `source_emitter` 4/4; complete Rust gate 137/105/196/5/4/5/10 plus 61x2 CLI; strict-Clippy classification; docs/KM/governance/mdBook/cleanup. | PASS. Rust identity/metadata/error roles align without compatibility drift; census stays 56/2/2 and exact plan/trace `.2` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.3.2` | Exact ten-family plan/four rejections; neutral fixture exposed and fixed direct-result projection; three portable trace roles; focused 5/5 + 10/10; clean full Rust 137/105/196/5/5/5/10 plus 61x2; strict-Clippy classification; docs/KM/governance/mdBook/cleanup. | PASS. Rust v1 baseline roles are green with legacy result/trace adapters preserved; census stays 56/2/2 and admission `.3` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.1.3.3` | Contract checker; focused Perl 69 assertions and Rust 5/5; complete Perl 61x2 + Phase 0 `1..1030`/652s; fresh Rust 137/105/196/5/5/5/10 + 61x2; 57/1/2 capability/contract state; docs/KM/governance/mdBook/cleanup. | PASS. Perl promotes to pass; Rust remains partial solely for 8/105 breadth; `.3.1` closes and `.3.2.0` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.2.0` | New complete-manifest staged classifier; measured/stopped eight-case per-crate prototype; one-crate 105-module replacement; format/compile; explicit isolated run 105/105 in 184.46s; existing source-emitter 5/5 in 36.66s; strict-Clippy classification/new-test pass; docs/KM/governance/mdBook/cleanup. | PASS. No emitter/runtime failure mechanism exists in the current 105-case corpus; `.3.2.1` owns zero-failure closeout before strict admission. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.2.1` | Exact `.3.2.0` terminal report and five requested mechanism inventories; capability/public/task/KM continuity review; governance/whitespace/mdBook/cleanup. | PASS. All failure inventories are empty; no repair child or behavior code is justified; strict recurring admission `.3.2.2` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.2.2` | Unconditional ordinary classifier; contract/checker path/count/no-ignore/strict enforcement; independent 105/105/186.42s; complete Rust 137/105/105-generated/196/5/5/5/10 + 61x2; strict-Clippy classification/changed-test pass; 58/0/2 capability; docs/KM/governance/mdBook/cleanup. | PASS. Rust generated source promotes to pass; `.3.2` closes and Dart scaffold `.3.3.1` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.3.1` | Public compatibility/v1 Dart emitters; exact metadata/errors/determinism; isolated private-cache offline pub/analyze/run/cleanup; focused 3/3; complete Dart 178 tests + 61x2 + 105 corpus; docs/KM/governance/mdBook/cleanup. | PASS. Dart scaffold is green without census promotion; exact family-plan/direct execution `.3.3.2` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.3.2` | Exact ten-family plan/four rejections/direct per-rule family dispatch/three trace roles; isolated all-family package; focused 5/5; complete Dart 180 tests + 61x2 + 105 corpus; docs/KM/governance/mdBook/cleanup. | PASS. Dart implementation roles are green; curated manifest admission `.3.3.3` is active without premature census promotion. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.3.3` | Contract-sourced exact eight-case interpreter-first subset; isolated offline host analyze/run; exact values/metadata/plans/trace; checker path/order/no-skip/cleanup enforcement; complete Dart 181 + 61x2 + 105; 59/0/1; docs/KM/governance/mdBook/cleanup. | PASS. Dart promotes gap→pass; `.3.3` closes and Julia scaffold `.3.4.1` is next. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.4.1` | Public compatibility/v1 Julia emitters; canonical effective-AST serialization; strict-UTF-8/ASCII-hex payload and identity; typed metadata/errors; valid/corrupt caller-owned isolated host proof; focused 18/18; package 1,128; complete Julia gate; docs/KM/governance/mdBook/cleanup. | PASS. Julia scaffold is green without census promotion; exact family-plan/direct execution `.3.4.2` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.4.2` | Exact ten typed families/ordered plan/four rejections; family-authoritative per-rule direct dispatch; portable enter/decision/exit trace; one isolated all-family module; focused 27+18; package 1,155; complete Julia gate; docs/KM/governance/mdBook/cleanup. | PASS. Julia implementation roles are green without promotion; exact contract-sourced manifest admission `.3.4.3` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.4.3` | Exact contract-sourced eight-case interpreter-first subset; eight namespaces in one offline host; exact values/metadata/plans/trace identity; checker path/order/no-skip/cleanup; focused 13+27+18; package 1,168 + 61x2 + 105; capability 60/0/0; docs/KM/governance/mdBook/cleanup. | PASS. Julia promotes gap→pass; `.3.4` closes and exact four-backend admission `.3.5` is active. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.3.5` | Contract/capability 60/0/0; focused Perl 69, Rust 5/5, Dart 6/6, Julia 58/58; adjacent complete backend gates; docs/KM/governance/mdBook; 1.23+ GB cache cleanup. | PASS. Exact four-backend generated-source parity closes without behavior change; `.3` is done and Lua plan `.1.3` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.3.2` | 55 focused callable assertions; complete Julia package tests; 61x2 primary CLI; 105 corpus; memory/Knowledge Map/doctrine/task-tree/whitespace/mdBook checks. | PASS. Julia exact v1/v2 spec/staged/descriptor/native/generated execution closes parent `.4.3`; no-drift/Lua routing `.4.4` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.4` | Four-backend source/test/public scan; callable/capability checkers; dual-ABI Lua gate; memory/Knowledge Map/doctrine/task-tree/whitespace/mdBook checks. | PASS. Callable extension `.4` closes; Lua native `.5.1`, descriptor `.5.3`, generated `.8.1-.3`, and admission `.8.4` own all remaining work. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.1` | Knowledge Map/ActionIR source audit; director syntax/scope agreement; ADR 0031; backend rollout split; memory/Knowledge Map/doctrine/task-tree/whitespace/mdBook checks. | PASS. `{|args| ...}` and dynamic caller context are designed before behavior code; neutral contract `.11.2` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.2` | Strict callable-codeblock JSON/checker; 7 literals/11 calls/9 malformed literals/7 invalid calls/4 contextual forms; independent fixture rendering/evaluation; full local gate with 61x2 CLI and Phase 0 `1..1030`/716s; capability/KM/governance/whitespace/mdBook. | PASS. Neutral syntax, typed AST, dynamic context, restoration, diagnostics, precedence, and future fixture are locked before behavior; Perl `.11.3.1` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.3.1` | Exact Perl brace/signature/body/span AST; canonical JSON/ASCII-hex generated state; 126 focused assertions; existing ActionIR parser; full local gate with 61x2 CLI and Phase 0 `1..1030`/575s; contract/capability/governance/whitespace/mdBook. | PASS. Inert construction, assignment/copy, malformed codes, and user-function argument/results preserve typed data without closures; invocation `.11.3.2` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.3.2` | Exact neutral live/standalone execution; static precedence; result chaining/drop; typed invalid-call probes; focused 97 top-level tests; canonical 60/0/0 capability, 61x2 CLI, and Phase 0 `1..1030`/815s; governance/whitespace/mdBook. | PASS. Perl executes closure-free typed records through explicit dynamic caller slots with copied/restored parameters and persistent nonparameter mutation; final-block normalization `.11.3.3` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.3.3.0` | Toolbox `call_spec_handler_subst`; exact ActionIR JSON for attached/parenthesized/explicit/helper/user/receiver forms; user-function descriptor; parser/registry/lowering source-location audit; governance/whitespace/mdBook. | PASS. Payload normalization exists, declaration ownership does not. Design `.1` is active before behavior `.2`; no behavior code changed. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.3.3.1` | Director clarification; ADR 0032/index; strict declaration schema and four invalid forms; 8 contextual helper/user-function/receiver cases; callable-codeblock checker; governance/whitespace/mdBook. | PASS. Final-only `name: codeblock` is adopted without nested signature typing; explicit values own `{|params| ...}` signatures and Perl behavior `.2` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.3.3.2` | Touched Perl syntax; strict callable checker; focused callable 10 subtests; adjacent ActionIR/variadic/generated-source 90 tests; capability 60/0/0; direct Phase 0; canonical 61x2 CLI plus Phase 0; Knowledge Map/memory/task/doctrine/whitespace/mdBook. | PASS. Wrapper-free typed components canonicalize to ordered public params; declared helper/user/receiver contextual forms normalize equivalently; explicit values retain signatures; harrays reject typed; immediate `with` breadth remains intact; direct Phase 0 `1..1030` passes in 966 seconds and canonical Phase 0 in 916 seconds. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.11.3.4` | Toolbox attached/parenthesized helper and receiver lowering; typed descriptor; parser/runtime/generated-source residue scans; four focused suites/100 tests; strict callable checker; capability 60/0/0; immediately prior canonical 61x2 CLI plus Phase 0 `1..1030`/916s; governance/whitespace/mdBook. | PASS. Perl callable codeblocks close without raw-host fallback, stored coderef/capture, parser method allowlist, harray drift, compatibility rewrite, or unresolved helper; `.12.1` activates spec-facing selector removal before Rust/Lua. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.0` | Knowledge Map first; tracked/shipped selector inventory; direct-parent/receiver classification; backend owner scans. | PASS, count corrected by `.12.1.7.1`: 600 exact calls/82 specs include 210/15 shipped; the original boundary-less scan's extra 51/17 were `flat_array(name)` suffixes. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.1` | Strict uniform-binding JSON/checker; 11 migrations; seven execution cases; six invalid selectors; eight valid constructors/literals; deterministic future fixture; capability future owner; canonical CI with 60/0/0, 61x2 CLI, and Phase 0 `1..1030`/875s; governance/whitespace/mdBook. | PASS. One observable typed binding, storage neutrality, set/mutation results, absent/wrong-kind behavior, static push precedence, pure/mutable split, exact future rejection, and constructor classification are adopted before Perl behavior `.12.1.2`. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.2` | Perl typed-binding runtime; live/standalone future fixture; 38 focused tests; neutral 11/7/6/8 checker; canonical doctrines, capability 60/0/0, 61x2 CLI, and Phase 0 `1..1030`/821s; Knowledge Map/whitespace/mdBook. | PASS. Bare mutations, reads, receivers, results, chaining, diagnostics, and static precedence share one observable binding; compatibility wrappers remain only until migration; Rust `.12.1.3` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.5` | Permanent native/generated 27-assertion contract; complete Julia 1,311 assertions, CLI 61x2, and 105 corpus; canonical doctrines/contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0 `1..1030`/865s; KM/governance/whitespace/mdBook. | PASS. Julia mutations use one typed binding, return updated values, preserve static precedence, and reject wrong kinds; Lua `.12.1.6` activates without selector migration. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.6` | Nine exact uniform-binding cases; complete PUC Lua and LuaJIT 85/85; exact 105-case manifest/scaffold CLI; immediately prior canonical doctrines/contracts, 60/0/0, Perl CLI 61x2, and Phase 0 `1..1030`/865s; KM/governance/whitespace/mdBook. | PASS. Lua is the fifth enabled backend; bare mutations/results, precedence, diagnostics, and chaining pass before shipped-source migration `.12.1.7.1`. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.7.1` | Boundary-correct inventory; 15 shipped specs; Perl pure-helper read seam; focused live/generated contract; all descriptors; CLI 61x2; canonical doctrines/contracts/capability and Phase 0 `1..1031`/573s; mdBook/KM/whitespace. | PASS. Shipped exact selectors fall 210 to zero; 390 tracked occurrences remain for `.12.1.7.2-.3`. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.7.2` | 390 exact forms/67 file-backed specs; three `[undef]` constructions; Perl live EBNF/recursive/traversal probes; Rust native/generated 105 corpora and full gate; Dart/Julia full gates and 105 corpora; Lua dual-ABI 85/85 plus 105-manifest validation; canonical 60/0/0, CLI 61x2, Phase 0 `1..1031`/574s; docs/KM/governance. | PASS. Every tracked `.spec` file is selector-free; exposed initializer/accumulator/fluent-push/descriptor seams are permanently locked and embedded-source `.12.1.7.3` is active. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.7.3` | 1,356 exact positive forms/25 embedded source owners; recurring executable-source classifier at 0 positive/25 recognition; focused Perl generated/function/runtime proof; complete Rust/Dart/Julia/Lua gates; regenerated 105-fixture oracle; standalone Phase 0 `1..1031`/920s; canonical capability 60/0/0, CLI 61x2, Phase 0 `1..1031`/918s; docs/KM/governance/mdBook/whitespace. | PASS. All tracked source migration is complete; implementation recognition remains only for dependency-ordered hard rejection beginning with Perl `.12.1.8.1`. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.1` | Exact six-case compile/generated/direct rejection; unused-function and dead-code coverage; eight retained constructors/literals; focused Perl 41 tests; whitespace-aware executable scan 0/19; regenerated 105 fixtures; Rust corpus replay 3/3; standalone Phase 0 `1..1031`/934s; docs/KM/governance/mdBook/whitespace. | PASS. Perl rejects exact aggregate selectors at the canonical ActionIR boundary with portable fields before lowering, while constructor/literal behavior remains; Rust `.12.1.8.2` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.2` | Exact six-case typed-AST/whole-compiled-state rejection; dead/nested/unused-function/deferred-fluent coverage; native/generated/decoded-plan boundaries; eight retained classes; focused 15/15; executable scan 0/13; complete Rust core/runtime/CLI, 105 interpreted corpus, post-rename 105 generated classifier/329.32s, integration 197/197; canonical local CI including Phase 0 `1..1031`; docs/KM/governance/mdBook/whitespace. | PASS. Rust selector dispatch is deleted and every compiled/generated entry rejects the neutral diagnostic shape; Dart `.12.1.8.3` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.3.1` | Six neutral exact cases; recursive typed ActionIR/whole-compiled-state validation; dead/unused-function/deferred-fluent coverage; generated emission/plan boundaries; eight retained classes; focused 15/15; strict analysis; executable scan 0/14; complete package leg 203 pass/two aggregate failures. | PASS for selector implementation. All selector paths pass and dispatch is deleted. The only full-gate failures are four `spec_spec_*` smokes root-caused to fixed `blkFN` versus shipped variadic `blkVFN`; `.12.1.8.3.2` activates before parent closeout. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.3.2` | Real four-case FAIL reproduction; Knowledge Map bounded-bridge retrieval; exact fixed/variadic detector and prefix/capture/named-block proof; focused matching+selector 22; four `spec_spec_*` PASS; complete format/analyze/205 tests/61x2 CLI/105 corpus. | PASS. `blkVFN` is supported without general recursive-PCRE claims; Dart `.12.1.8.3` closes and Julia `.12.1.8.4` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.4` | Six neutral FAIL-before/PASS-after compile cases; recursive typed ActionIR and complete compiled-state validation; dead/deferred-fluent/unused-function coverage; caller-constructed generated emission/plan rejection; eight retained classes; focused 59/59; executable scan 0/15; complete 1,339 package assertions/61x2 CLI/105 corpus; canonical local CI including Phase 0 `1..1031`/601s; docs/KM/governance/mdBook/whitespace. | PASS. Julia selector runtime dispatch is deleted and every native/generated compiled boundary rejects the portable diagnostic shape; Lua `.12.1.8.5` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.5` | Six neutral FAIL-before/PASS-after compile cases; recursive ActionIR/whole-compiled-state validation; dead/deferred-fluent/unused-function coverage; caller-mutated runtime-engine rejection; eight retained classes; PUC Lua 88/88; LuaJIT 88/88; executable scan 0/19; exact 105-manifest and CLI-scaffold checks; docs/KM/governance/mdBook/whitespace. | PASS. Lua selector dispatch is deleted and compile/runtime-engine admission rejects the portable typed fields; cross-variant no-drift `.12.1.8.6` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.8.6` | Cross-variant retirement checker; exact six-case/eight-retained-class neutral contract; five focused suites (Perl 11, Rust 15/15, Dart 15/15, Julia 59/59, Lua 88/88 on both ABIs); executable scan 0/19; runtime-compatibility scan 0; canonical capability 60/0/0, CLI 61x2, Phase 0 `1..1031`/616s; docs/KM/governance/mdBook/whitespace. | PASS. One recurring gate now locks all five diagnostic and compiled-state boundaries and forbids known selector-only runtime dispatch; `.12.1.8` closes and final public admission `.12.1.9` activates. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.9` | Public checker over 47 files/31 classified removed-history references/0 current examples; capability future exclusion absent and 60/0/0; composed five-backend six-case/eight-retained/0-runtime/0-positive-19-classified checks; canonical CLI 61x2 and Phase 0 `1..1031`/626s; mdBook/KM/governance/cleanup/whitespace. | PASS. Selector retirement `.12.1` and compatibility parent `.12` close; existing active Lua scalar-numeric `.4.3.3.1.4` resumes. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.12.1.10` | Baseline 14 positive forms/four backend READMEs; migrated bare-binding prose/snippets; expanded 56-file/31-classified/0-current public checker; composed five-backend 6-invalid/8-retained/0-runtime/0-positive-19-classified and capability 60/0/0; mdBook/KM/governance/cleanup/whitespace. | PASS. Public checker omission is closed; `.12.1`/`.12` re-close and Lua numeric `.4.3.3.2` resumes. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.14.0` | Director clarification; Knowledge Map retrieval; ADR 0012 and closed staged tree; mdBook design/pipeline/walkthrough audit; new canonical doctrine card; task split; governance/mdBook/whitespace. | PASS. Structural recursion belongs in linked rules with simple boundary regexes; progressive in-parse composition and post-AST staged enrichment are distinct; the narrow function-body prototype is current while general composition remains explicitly future-owned. No behavior changed; Perl `.12.1.8.1` resumes. |
| `2026-07-11` | `FUTURE-PARITY-BACKLOG.1.3` | Lua/LuaJIT/LPeg/tooling source audit; complete eight-lane Lua task split; native API/exact CLI/four values/generic blocks/105 corpus/capability/codegen obligations; docs/KM/governance/mdBook/cleanup. | PASS. Lua parity is fully planned before code; delegated `LUA-BACKEND-PARITY.1.1` is active. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.0` | Knowledge Map and ADR 0017/0023 retrieval; `LinkedSpec::Get` descriptor plus `runtime_ctx_ref` malformed-signature probes; grammar/staged/descriptor/registry/compiler/native/generated/Lua source audit; docs/KM/governance/whitespace/mdBook. | PASS. Exact arity ownership is complete, open-bound helpers are distinct, rollout is mechanism-sized, and no behavior code changed; `.4.1` is active. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.1` | ADR 0030; strict callable-signature JSON/checker; three definitions/nine calls/seven invalid signatures; deterministic future spec/expected values; canonical-CI integration; 60/0/0 census; docs/KM/governance/whitespace/mdBook. | PASS. Final `...rest`, v1 fixed/v2 variadic records, typed rest arrays, positional diagnostics, and backend rollout are locked before behavior code; Perl `.4.2.1` is active. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.2.1` | Permanent/focused v2 grammar; registry/staged/outward signatures; generated eager/fresh rest binding; array-aware length; 66 focused assertions; measured Phase 0 source-lock migration; canonical 61x2 CLI plus `1..1030`; docs/KM/governance/mdBook. | PASS. First Phase 0 measured only 13 stale strings in one subtest; after exact migration, the complete gate passes in 710 seconds, fixed v1 shape/diagnostics remain stable, and Rust `.4.2.2` is active. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.2.2` | Typed parsed/compiled/staged/outward signature; native/generated minimum-arity and fresh-rest binding; array-aware length; 196 core tests; 7 focused contract tests; complete Rust 137/105 interpreter/105 generated/197 integration plus focused suites and 61x2 CLI; docs/KM/governance/mdBook. | PASS. Rust consumes the unchanged fixture through native, serialized, emitted, and generated-plan paths; fixed v1 stays exact, parent `.4.2` closes, and Dart `.4.3.1` is active. |
| `2026-07-12` | `FUTURE-PARITY-BACKLOG.4.3.1` | Typed spec/staged/registry/action/descriptor signature; native/generated minimum-arity and fresh-rest binding; six focused contract tests; complete Dart format/analyze/190 package/61x2 CLI/105 corpus; docs/KM/governance/mdBook. | PASS. Dart consumes the unchanged fixture through native, normalized emitted, generated-plan, and reconstructed paths without optional/named/rest leakage; Julia `.4.3.2` is active. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FUTURE-PARITY-BACKLOG.0` | `FUTURE-PARITY-BACKLOG.0 - create future parity backlog` | Tracking/decision/doc sync; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.1` | `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan` | Creates `DART-BACKEND-PARITY`; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.2` | `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan` | Creates `JULIA-BACKEND-PARITY`; no implementation code. |
| `FUTURE-PARITY-BACKLOG.8.0` | `FUTURE-PARITY-BACKLOG.8.0 - capture spec-derived roundtrip idea` | Captures future `foo.spec` parser/stimuli closed-loop validation arc; no implementation code. |
| `FUTURE-PARITY-BACKLOG.9.0` | `FUTURE-PARITY-BACKLOG.9.0 - capture AND OR edge default correction` | Captures future AND/OR mode-sensitive edge-default design arc; no implementation code. |
| `FUTURE-PARITY-BACKLOG.10.0` | `FUTURE-PARITY-BACKLOG.10.0 - capture semantic introspection MCP direction` | Captures a backend-neutral native semantic API plus thin MCP projection; no implementation code. |
| `FUTURE-PARITY-BACKLOG.11.0` | `FUTURE-PARITY-BACKLOG.11.0 - capture generic trailing codeblocks` | Captures four-kind final-codeblock equivalence and parks `with` disposition; no behavior code. |
| `FUTURE-PARITY-BACKLOG.12.0` | `FUTURE-PARITY-BACKLOG.12.0 - capture compatibility retirement doctrine` | Captures uniform expressions, one duck-typed binding, and temporary-only compatibility; no behavior code. |
| `FUTURE-PARITY-BACKLOG.4.0` | `FUTURE-PARITY-BACKLOG.4.0 - split variadic callable signatures` | Read-only exact-arity seam audit, open-bound helper distinction, and neutral/Perl/Rust/Dart/Julia/Lua rollout split. |
| `FUTURE-PARITY-BACKLOG.4.1` | `FUTURE-PARITY-BACKLOG.4.1 - adopt variadic callable contract` | ADR 0030, final `...rest`, v1/v2 schema, nine call cases, deterministic fixture/checker, and recurring CI gate. |
| `FUTURE-PARITY-BACKLOG.4.2.1` | `FUTURE-PARITY-BACKLOG.4.2.1 - implement Perl variadic functions` | Perl v2 grammar/registry/staged/descriptor/generated execution, exact neutral fixture, and array-aware result chaining. |
| `FUTURE-PARITY-BACKLOG.4.2.2` | `FUTURE-PARITY-BACKLOG.4.2.2 - implement Rust variadic functions` | Rust typed v2 parsed/compiled/staged/descriptor/native/generated execution, exact neutral fixture, and array-aware result chaining. |
| `FUTURE-PARITY-BACKLOG.4.3.1` | `FUTURE-PARITY-BACKLOG.4.3.1 - implement Dart variadic functions` | Dart typed v2 spec/staged/registry/action/descriptor/native/generated execution with positional-only calls. |
| `FUTURE-PARITY-BACKLOG.4.3.2` | `FUTURE-PARITY-BACKLOG.4.3.2 - implement Julia variadic functions` | Julia typed v2 spec/staged/registry/action/descriptor/native/generated execution with positional-only calls. |
| `FUTURE-PARITY-BACKLOG.4.4` | `FUTURE-PARITY-BACKLOG.4.4 - close variadic callable routing` | Four-backend no-drift and explicit Lua native/descriptor/generated/admission ownership. |
| `FUTURE-PARITY-BACKLOG.11.1` | `FUTURE-PARITY-BACKLOG.11.1 - design callable codeblock literals` | ADR 0031, brace-pipe literal, dynamic caller context, static resolution precedence, and backend rollout split. |
| `FUTURE-PARITY-BACKLOG.11.2` | `FUTURE-PARITY-BACKLOG.11.2 - adopt callable codeblock contract` | Strict schema/checker, neutral parser and invocation model, diagnostics, contextual forms, and future fixture. |
| `FUTURE-PARITY-BACKLOG.11.3.1` | `FUTURE-PARITY-BACKLOG.11.3.1 - parse Perl callable codeblock literals` | Exact Perl AST/spans/signatures, inert generated data, malformed codes, assignment/copy/function preservation. |
| `FUTURE-PARITY-BACKLOG.11.3.2` | `FUTURE-PARITY-BACKLOG.11.3.2 - execute Perl callable codeblocks` | Dynamic caller slots, copied/restored parameters, typed errors, precedence, result chaining/drop, and independent generated execution. |
| `FUTURE-PARITY-BACKLOG.11.3.3.0` | `FUTURE-PARITY-BACKLOG.11.3.3.0 - split final codeblock signature declaration` | Read-only proof of the missing declaration/callback-signature schema and design/behavior split. |
| `FUTURE-PARITY-BACKLOG.11.3.3.1` | `FUTURE-PARITY-BACKLOG.11.3.3.1 - declare final codeblock parameters` | ADR 0032, final-only `name: codeblock`, value-owned signatures, invalid declarations, and eight contextual cases. |
| `FUTURE-PARITY-BACKLOG.11.3.3.2` | `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks` | Typed callable metadata, canonical contextual arguments, generic receiver parsing, generated execution, and typed rejection. |
| `FUTURE-PARITY-BACKLOG.11.3.4` | `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks` | Residue audit, focused and canonical no-drift proof, Perl parent closeout, and `.12.1` selector-removal activation. |
| `FUTURE-PARITY-BACKLOG.12.1.0` | `FUTURE-PARITY-BACKLOG.12.1.0 - split aggregate selector retirement` | Exact inventory, concrete selector-free gaps, backend ownership, and dependency-ordered removal plan. |
| `FUTURE-PARITY-BACKLOG.12.1.1` | `FUTURE-PARITY-BACKLOG.12.1.1 - adopt uniform binding contract` | Strict neutral schema/checker, migration table, execution/results, diagnostics, constructor classification, and fixture. |
| `FUTURE-PARITY-BACKLOG.12.1.2` | `FUTURE-PARITY-BACKLOG.12.1.2 - enable Perl uniform bindings` | Typed bare mutations/results, static precedence, mutable split, diagnostics, wrapper compatibility, and full-gate proof. |
| `FUTURE-PARITY-BACKLOG.12.1.3` | `FUTURE-PARITY-BACKLOG.12.1.3 - enable Rust uniform bindings` | Native/generated typed bare mutations/results, static precedence, diagnostics, oracle bridge, and full-gate proof. |
| `FUTURE-PARITY-BACKLOG.12.1.4` | `FUTURE-PARITY-BACKLOG.12.1.4 - enable Dart uniform bindings` | Native/generated typed bare mutations/results, wrapper bridge, diagnostics, corpus, and full-gate proof. |
| `FUTURE-PARITY-BACKLOG.12.1.5` | `FUTURE-PARITY-BACKLOG.12.1.5 - enable Julia uniform bindings` | Native/generated typed mutations/results, wrapper bridge, diagnostics, package/corpus/CLI, and full-gate proof. |
| `FUTURE-PARITY-BACKLOG.12.1.6` | `FUTURE-PARITY-BACKLOG.12.1.6 - enable Lua uniform bindings` | Dual-ABI typed mutations/results, static precedence, diagnostics, minimal array continuations, and full-gate proof. |
| `FUTURE-PARITY-BACKLOG.12.1.7.1` | `FUTURE-PARITY-BACKLOG.12.1.7.1 - migrate shipped aggregate selectors` | Removes 210 shipped exact selectors and preserves reference/generated behavior. |
| `FUTURE-PARITY-BACKLOG.12.1.7.2` | `FUTURE-PARITY-BACKLOG.12.1.7.2 - migrate file-backed selector fixtures` | Removes 390 exact selectors from 67 capability/oracle/corpus specs. |
| `FUTURE-PARITY-BACKLOG.12.1.7.3` | `FUTURE-PARITY-BACKLOG.12.1.7.3 - migrate embedded selector sources` | Removes 1,356 embedded positives and adds the recurring executable-source classifier. |
| `FUTURE-PARITY-BACKLOG.12.1.8.1` | `FUTURE-PARITY-BACKLOG.12.1.8.1 - hard-reject Perl aggregate selectors` | Compile-time portable rejection, retained constructors/literals, and full Perl/corpus proof. |
| `FUTURE-PARITY-BACKLOG.12.1.8.2` | `FUTURE-PARITY-BACKLOG.12.1.8.2 - hard-reject Rust aggregate selectors` | Whole-compiled-state native/generated rejection, selector-dispatch deletion, retained constructors/literals, and full Rust/corpus proof. |
| `FUTURE-PARITY-BACKLOG.12.1.8.3.1` | `FUTURE-PARITY-BACKLOG.12.1.8.3.1 - hard-reject Dart aggregate selectors` | Whole-compiled-state/generated rejection, runtime-dispatch deletion, retained values, and explicit full-gate bridge handoff. |
| `FUTURE-PARITY-BACKLOG.12.1.8.3.2` | `FUTURE-PARITY-BACKLOG.12.1.8.3.2 - close Dart selector retirement` | Exact variadic `blkVFN` bridge parity, complete Dart gate, parent closeout, and Julia handoff. |
| `FUTURE-PARITY-BACKLOG.12.1.8.4` | `FUTURE-PARITY-BACKLOG.12.1.8.4 - hard-reject Julia aggregate selectors` | Whole-compiled-state/generated rejection, runtime-dispatch deletion, retained values, and complete Julia proof. |
| `FUTURE-PARITY-BACKLOG.12.1.8.5` | `FUTURE-PARITY-BACKLOG.12.1.8.5 - hard-reject Lua aggregate selectors` | Whole-compiled-state/runtime-engine rejection, runtime-dispatch deletion, retained values, and dual-ABI proof. |
| `FUTURE-PARITY-BACKLOG.1.4` | `FUTURE-PARITY-BACKLOG.1.4 - ratify native in-memory backend contract` | ADR `0022` and public/backend planning surfaces make native host-process embedding primary; no implementation code. |
| `FUTURE-PARITY-BACKLOG.1.5.0` | `JULIA-BACKEND-PARITY.7.3.1 - ratify exact backend interface parity` | Delegated ADR `0023` contract/routing; global implementation follows after Julia's active repair leaf. |
| `JULIA-BACKEND-PARITY.7.3.3` | `JULIA-BACKEND-PARITY.7.3.3 - reconcile Julia scoped parity status` | Delegated local audit done; Julia root remains active through global `.1.5`, `.1.6`, and `.3`. |
| `FUTURE-PARITY-BACKLOG.1.5.1.0` | `FUTURE-PARITY-BACKLOG.1.5.1.0 - split neutral CLI fixture work` | Read-only Perl/process audit and five-leaf implementation split. |
| `FUTURE-PARITY-BACKLOG.1.5.1.1` | `FUTURE-PARITY-BACKLOG.1.5.1.1 - add neutral CLI fixture runner` | Strict schema, arbitrary command runner, exact help case, output-file support, and focused tests. |
| `FUTURE-PARITY-BACKLOG.1.5.1.2` | `FUTURE-PARITY-BACKLOG.1.5.1.2 - normalize Perl CLI arguments` | Explicit parser plus 20 exact usage cases; 22/22 green in default/POSIX environments. |
| `FUTURE-PARITY-BACKLOG.1.5.1.3` | `FUTURE-PARITY-BACKLOG.1.5.1.3 - lock Perl CLI success behavior` | Seven exact success cases; source/input/parser controls and canonical JSON locked. |
| `FUTURE-PARITY-BACKLOG.1.5.1.4` | `FUTURE-PARITY-BACKLOG.1.5.1.4 - normalize Perl CLI failures` | Four failures; phase order, stable stderr, stdout purity, and exit `1` locked. |
| `FUTURE-PARITY-BACKLOG.1.5.1.5` | `FUTURE-PARITY-BACKLOG.1.5.1.5 - close canonical CLI trace` | ADR 0024, 20 trace cases, 53-case suite, and canonical local gate. |
| `FUTURE-PARITY-BACKLOG.1.5.1.6.0` | `FUTURE-PARITY-BACKLOG.1.5.1.6.0 - split primary CLI UTF-8 boundary` | ADR 0025, root-cause probes, and three implementation/no-drift owners; no behavior code. |
| `FUTURE-PARITY-BACKLOG.1.5.1.6.1` | `FUTURE-PARITY-BACKLOG.1.5.1.6.1 - add neutral hex byte fixtures` | Schema-v1 exact non-text input materialization with focused validation/proof. |
| `FUTURE-PARITY-BACKLOG.1.5.1.6.2` | `FUTURE-PARITY-BACKLOG.1.5.1.6.2 - enforce Perl CLI UTF-8 text` | Strict argv/file decoding, recursive UTF-8 JSON, and eight exact behavior families for 61 cases. |
| `FUTURE-PARITY-BACKLOG.1.5.1.6.3` | `FUTURE-PARITY-BACKLOG.1.5.1.6.3 - close Perl CLI reference` | No-drift closeout; closes parents and activates Rust without behavior change. |
| `FUTURE-PARITY-BACKLOG.1.5.2.0` | `FUTURE-PARITY-BACKLOG.1.5.2.0 - split Rust primary CLI work` | Audits native/adapter seams and splits implementation before code. |
| `FUTURE-PARITY-BACKLOG.1.5.2.1` | `FUTURE-PARITY-BACKLOG.1.5.2.1 - add Rust CLI boundary` | Exact arguments/help/loading, strict UTF-8, named resolution, stable failures, and binary. |
| `FUTURE-PARITY-BACKLOG.1.5.2.2` | `FUTURE-PARITY-BACKLOG.1.5.2.2 - add Rust direct execution API` | Reusable entry/mode/direct result plus nested-hash preservation. |
| `FUTURE-PARITY-BACKLOG.1.5.2.3` | `FUTURE-PARITY-BACKLOG.1.5.2.3 - add canonical Rust CLI trace` | Exact portable trace events/levels/sinks/failures; 61/61 baseline. |
| `FUTURE-PARITY-BACKLOG.1.5.2.4` | `FUTURE-PARITY-BACKLOG.1.5.2.4 - close Rust primary CLI` | Recurring Rust gate, default/POSIX proof, full local gate, parent closeout. |
| `FUTURE-PARITY-BACKLOG.1.5.3.0` | `FUTURE-PARITY-BACKLOG.1.5.3.0 - split Dart primary CLI work` | Audits 0/61 primary drift, reusable native seams, separate corpus ownership, and four ordered leaves. |
| `FUTURE-PARITY-BACKLOG.1.5.3.1` | `FUTURE-PARITY-BACKLOG.1.5.3.1 - add Dart CLI boundary` | Exact arguments/help/resolution/UTF-8/phase bytes plus staged no-function correction; 29/61. |
| `FUTURE-PARITY-BACKLOG.1.5.3.2` | `FUTURE-PARITY-BACKLOG.1.5.3.2 - add Dart primary execution` | Native entry/mode/direct value plus recursive canonical JSON; 41/61. |
| `FUTURE-PARITY-BACKLOG.1.5.3.3` | `FUTURE-PARITY-BACKLOG.1.5.3.3 - add canonical Dart CLI trace` | Independent ADR 0024 levels/events/sinks/failures; 61/61. |
| `FUTURE-PARITY-BACKLOG.1.5.3.4` | `FUTURE-PARITY-BACKLOG.1.5.3.4 - close Dart primary CLI` | Recurring 151-test/61x2/99 gate, broader no-drift, parent closeout. |
| `FUTURE-PARITY-BACKLOG.1.5.4.0` | `FUTURE-PARITY-BACKLOG.1.5.4.0 - split Julia global CLI repair` | Audits 13/61 Julia baseline and splits three exact repair/driver mechanisms. |
| `FUTURE-PARITY-BACKLOG.1.5.4.1` | `FUTURE-PARITY-BACKLOG.1.5.4.1 - align Julia CLI boundary` | Exact shared help, strict UTF-8 file decoding, and phase-only primary stderr; 42/61. |
| `FUTURE-PARITY-BACKLOG.1.5.4.2` | `FUTURE-PARITY-BACKLOG.1.5.4.2 - add canonical Julia CLI trace` | Independent ADR 0024 levels/events/sinks/failures; 61/61 default/POSIX. |
| `FUTURE-PARITY-BACKLOG.1.5.4.3` | `FUTURE-PARITY-BACKLOG.1.5.4.3 - close exact primary CLI parity` | Recurring warmed 4x2x61 matrix, focused backend gates, broader Phase 0 gate, and exact CLI parent closeout. |
| `FUTURE-PARITY-BACKLOG.1.6.0` | `FUTURE-PARITY-BACKLOG.1.6.0 - audit backend capability parity` | Validated 15x4 census, strict evidence/owner gate, exact residual split, and no-behavior-change closeout. |
| `FUTURE-PARITY-BACKLOG.1.6.2.3` | `FUTURE-PARITY-BACKLOG.1.6.2.3 - admit exact descriptor parity` | Shared schema, canonical outer function records, exact four-backend tests, capability pass, parent closeout. |
| `FUTURE-PARITY-BACKLOG.1.6.3.0` | `FUTURE-PARITY-BACKLOG.1.6.3.0 - split Rust runtime diagnostics` | Corrects the real error boundary and creates typed implementation/admission owners; no behavior code. |
| `FUTURE-PARITY-BACKLOG.1.6.3.1` | `FUTURE-PARITY-BACKLOG.1.6.3.1 - add Rust runtime diagnostics` | Typed/JSON errors, source/top/deepest-rule attribution, compatibility adapters, and full runtime proof. |
| `FUTURE-PARITY-BACKLOG.1.6.3.2` | `FUTURE-PARITY-BACKLOG.1.6.3.2 - admit Rust runtime diagnostics` | Full recurring Rust/CLI proof, capability pass, parent closeout, and cache cleanup. |
| `FUTURE-PARITY-BACKLOG.1.6.4.0` | `FUTURE-PARITY-BACKLOG.1.6.4.0 - split native spec resolution` | Source-backed fallback drift, durable fact, and six-leaf split; no behavior code. |
| `FUTURE-PARITY-BACKLOG.1.6.4.1` | `FUTURE-PARITY-BACKLOG.1.6.4.1 - define native spec resolution contract` | ADR 0026, executable fixture/checker, canonical-gate integration, and public docs. |
| `FUTURE-PARITY-BACKLOG.1.6.4.2` | `FUTURE-PARITY-BACKLOG.1.6.4.2 - add Rust native spec resolution` | Public progressive loader/compiler, typed errors/identity, direct fixture proof, and CLI delegation. |
| `FUTURE-PARITY-BACKLOG.1.6.4.3` | `FUTURE-PARITY-BACKLOG.1.6.4.3 - add Dart native spec resolution` | Public progressive loader/compiler, structured exceptions/identity, direct 14/9/4 proof, and CLI delegation. |
| `FUTURE-PARITY-BACKLOG.1.6.4.4` | `FUTURE-PARITY-BACKLOG.1.6.4.4 - add Julia native spec resolution` | Public progressive loader/compiler, typed exceptions/identity, direct 14/9/4 proof, CLI delegation, and recursive-fallback removal. |
| `FUTURE-PARITY-BACKLOG.1.6.4.5` | `FUTURE-PARITY-BACKLOG.1.6.4.5 - admit native spec resolution parity` | Perl portable facade/direct fixture, canonical-gate wiring, exact four-backend admission, and parent closeout. |
| `FUTURE-PARITY-BACKLOG.1.6.5.0` | `FUTURE-PARITY-BACKLOG.1.6.5.0 - split Dart full-pipeline trace` | Exact runtime-only boundary, portable comparison, three-leaf implementation/admission split, no behavior code. |
| `FUTURE-PARITY-BACKLOG.1.6.5.1` | `FUTURE-PARITY-BACKLOG.1.6.5.1 - trace Dart frontend and compiler` | Optional caller emitter, balanced parse/validate/compile/registry events, failures, identity, and full Dart proof. |
| `FUTURE-PARITY-BACKLOG.1.6.5.2` | `FUTURE-PARITY-BACKLOG.1.6.5.2 - trace Dart function staging` | Caller emitter through parser shell/runtime, projection, staged queue/jobs/phases/stitching, failures, and full proof. |
| `FUTURE-PARITY-BACKLOG.1.6.5.3` | `FUTURE-PARITY-BACKLOG.1.6.5.3 - admit Dart full-pipeline trace` | Native IO-to-runtime routed/quiet/failure identity, full gates, capability promotion, and parent closeout. |
| `FUTURE-PARITY-BACKLOG.1.6.6` | `FUTURE-PARITY-BACKLOG.1.6.6 - close non-codegen capability parity` | Exact residual projection, generated-source-only handoff, parent closeout, no behavior change. |
| `FUTURE-PARITY-BACKLOG.3.0` | `FUTURE-PARITY-BACKLOG.3.0 - split generated-source parity` | Source-backed current boundary and contract/Rust/Dart/Julia/admission split; no behavior code. |
| `FUTURE-PARITY-BACKLOG.3.1.0` | `FUTURE-PARITY-BACKLOG.3.1.0 - correct Perl generated-source status` | Root-cause of dependency-regex index loss, corrected census, and contract/repair/admission split; no behavior code. |
| `FUTURE-PARITY-BACKLOG.3.1.1` | `FUTURE-PARITY-BACKLOG.3.1.1 - define generated-source contract` | Strict semantic schema/checker, neutral direct fixture, canonical CI integration, and public docs; no backend behavior change. |
| `FUTURE-PARITY-BACKLOG.3.1.2` | `FUTURE-PARITY-BACKLOG.3.1.2 - repair Perl generated source` | Public emitter, dependency reconstruction, metadata/plan/trace/errors, independent exact execution, and gates. |
| `FUTURE-PARITY-BACKLOG.3.1.3.0` | `FUTURE-PARITY-BACKLOG.3.1.3.0 - split Rust generated-source v1 alignment` | Preserves the green pre-v1 baseline while splitting identity/errors, exact plan/trace, and admission. |
| `FUTURE-PARITY-BACKLOG.3.1.3.1` | `FUTURE-PARITY-BACKLOG.3.1.3.1 - add Rust generated-source v1 metadata` | Typed identity/metadata/errors and host compile/load projection beside exact compatibility adapters. |
| `FUTURE-PARITY-BACKLOG.3.1.3.2` | `FUTURE-PARITY-BACKLOG.3.1.3.2 - align Rust generated plans and trace` | Exact neutral plan/rejections, direct v1 result, portable trace roles, and preserved legacy envelope/trace. |
| `FUTURE-PARITY-BACKLOG.3.1.3.3` | `FUTURE-PARITY-BACKLOG.3.1.3.3 - admit Perl Rust generated baseline` | Full Perl/Rust signoff, 57/1/2 promotion, `.3.1` closeout, and Rust breadth activation. |
| `FUTURE-PARITY-BACKLOG.3.2.0` | `FUTURE-PARITY-BACKLOG.3.2.0 - classify all Rust generated fixtures` | Scalable per-stage all-105 classifier, exact accounting, isolated shared host crate, and zero failures. |
| `FUTURE-PARITY-BACKLOG.3.2.1` | `FUTURE-PARITY-BACKLOG.3.2.1 - close zero-failure Rust classification` | Empty five-mechanism repair inventory and strict-admission handoff; no behavior code. |
| `FUTURE-PARITY-BACKLOG.3.2.2` | `FUTURE-PARITY-BACKLOG.3.2.2 - admit Rust generated-source breadth` | Unconditional recurring all-105 proof, complete Rust gates, 58/0/2 promotion, and Dart handoff. |
| `FUTURE-PARITY-BACKLOG.3.3.1` | `FUTURE-PARITY-BACKLOG.3.3.1 - add Dart generated-source scaffold` | Deterministic v1 emitter, typed scaffold errors, isolated caller-package compile/run, and `.3.3.2` handoff. |
| `FUTURE-PARITY-BACKLOG.3.3.2` | `FUTURE-PARITY-BACKLOG.3.3.2 - add Dart generated family execution` | Exact ten-family direct routing, four plan rejections, portable trace, isolated matrix, and `.3.3.3` handoff. |
| `FUTURE-PARITY-BACKLOG.3.3.3` | `FUTURE-PARITY-BACKLOG.3.3.3 - admit generated Dart source` | Exact accepted-subset admission, complete Dart gate, 59/0/1 promotion, and Julia handoff. |
| `FUTURE-PARITY-BACKLOG.3.4.1` | `FUTURE-PARITY-BACKLOG.3.4.1 - add Julia generated-source scaffold` | Deterministic v1 emitter, Unicode-safe hex payload, typed errors, isolated include/run, and `.3.4.2` handoff. |
| `FUTURE-PARITY-BACKLOG.3.4.2` | `FUTURE-PARITY-BACKLOG.3.4.2 - add Julia generated family execution` | Exact ten-family routing, four rejections, portable trace, isolated matrix, and `.3.4.3` handoff. |
| `FUTURE-PARITY-BACKLOG.3.4.3` | `FUTURE-PARITY-BACKLOG.3.4.3 - admit generated Julia source` | Exact accepted-subset admission, complete Julia gate, 60/0/0 promotion, and `.3.5` handoff. |
| `FUTURE-PARITY-BACKLOG.3.5` | `FUTURE-PARITY-BACKLOG.3.5 - close generated-source parity` | Exact 60/0/0 four-backend signoff, `.3` closeout, and Lua activation. |
| `FUTURE-PARITY-BACKLOG.12.1.8.6` | `FUTURE-PARITY-BACKLOG.12.1.8.6 - enforce selector retirement no-drift` | Five-backend recurring contract/boundary/runtime-deletion lock and `.12.1.9` handoff. |
| `FUTURE-PARITY-BACKLOG.12.1.9` | `FUTURE-PARITY-BACKLOG.12.1.9 - admit selector-free public surface` | 47-file public/capability admission, `.12.1` closeout, and Lua resume. |
| `FUTURE-PARITY-BACKLOG.12.1.10` | `FUTURE-PARITY-BACKLOG.12.1.10 - close backend README selector drift` | Four backend README migrations and deterministic 56-file public no-drift coverage. |
| `FUTURE-PARITY-BACKLOG.1.3` | `FUTURE-PARITY-BACKLOG.1.3 - scope Lua backend parity plan` | Complete Lua parity task tree and `.1.1` handoff; no implementation code. |

## Changelog

- `2026-07-12`: `.12.1.10` corrects the public-admission omission left by `.12.1.9`. Rust, Dart, Julia, and Lua
  READMEs contained 14 current positive selector forms because the curated 47-file checker did not include backend
  entry docs. All four now teach bare typed bindings. Immediate component README discovery, exact 56-file and
  31-classified-reference inventories, and backend anchor requirements make the zero-current-example claim
  recurring. Selector-retirement `.12.1` and compatibility parent `.12` re-close; Lua numeric `.4.3.3.2` resumes.
- `2026-07-12`: `.12.1.9` admits the selector-free public surface and closes `.12.1` plus compatibility parent
  `.12`. One canonical checker scans 47 public root/capability/mdBook files, classifies 31 exact mentions only as
  removed/rejected/migrated history, requires bare set/push/copy guidance, and reports zero current examples. It
  composes the five-backend runtime/source checks; the capability future exclusion is removed at 60/0/0. Canonical
  CI passes CLI 61x2 and Phase 0 `1..1031`/626s. Existing active Lua scalar-numeric `.4.3.3.1.4` resumes.
- `2026-07-12`: `.12.1.8.6` closes aggregate-selector hard retirement across all five backends. A deterministic
  canonical checker requires the six shared invalid cases, portable diagnostic fields, each compiled-state
  admission boundary, all eight retained classes, and zero known selector-only runtime dispatch; it composes the
  executable-source scan. The audit removed one stale compatibility comment. Perl 11, Rust 15/15, Dart 15/15,
  Julia 59/59, and Lua 88/88 on both ABIs pass; the checker reports zero runtime compatibility and zero executable
  positives/19 classified rejection occurrences. Final public admission `.12.1.9` activates.
- `2026-07-12`: `.12.1.8.5` hard-retires exact aggregate selectors on Lua. Recursive ActionIR inspection and
  whole-compiled-state validation cover rule payloads, valid deferred fluent calls, unused function bodies, and
  caller-mutated compiled tables at runtime-engine admission. Selector-only reads, set/push/receiver targets,
  mutable split/transform wrappers, and descriptor branches are deleted while all eight retained classes pass.
  PUC Lua and LuaJIT each pass 88/88; the exact 105-manifest/CLI scaffold and zero-positive/19-classified scan pass.
  Cross-variant no-drift `.12.1.8.6` activates.
- `2026-07-12`: `.12.1.8.4` hard-retires exact aggregate selectors on Julia. Recursive typed-ActionIR inspection
  and whole-compiled-state validation cover all rule payloads, valid deferred fluent calls, unused function bodies,
  generated emission, and generated plan/execution entry. Selector-only runtime reads, set/push/receiver targets,
  split/transform wrappers, and recognizers are deleted while all eight retained constructor/literal classes pass.
  Focused proof is 59/59, the executable scan is zero-positive/15 classified, and the authoritative Julia gate
  passes 1,339 assertions, CLI 61x2, and 105/105 corpus. Lua `.12.1.8.5` activates.
- `2026-07-12`: `.12.1.8.3.2` closes Dart selector retirement by repairing the independently exposed bounded
  `spec.spec` bridge. The matcher retains fixed `blkFN` and adds exact variadic `blkVFN` detection, prefix parsing,
  name/fixed/rest/body captures, and named-block identity. Focused matching+selector proof passes 22, all four
  `spec_spec_*` smokes pass, and the authoritative Dart gate passes format, strict analysis, 205 tests, CLI 61x2,
  and 105/105 corpus. Parent `.12.1.8.3` closes; Julia `.12.1.8.4` activates.
- `2026-07-12`: `.12.1.8.3.1` hard-retires exact aggregate selectors on Dart. Typed recursive detection covers
  every rule payload, unused function body, and deferred edge fluent; generated emission/plan validation repeats
  the boundary. Runtime selector dispatch is deleted while eight retained classes pass. Focused proof is 15/15,
  strict analysis is clean, and the scan is zero-positive/14 classified. The complete package leg reaches 203
  passes and isolates only the existing fixed-`blkFN` versus variadic-`blkVFN` bounded bridge drift;
  `.12.1.8.3.2` owns that repair and complete Dart no-drift before Julia.
- `2026-07-12`: `.12.1.8.2` hard-retires exact aggregate selectors on Rust. Recursive typed-AST detection and
  whole-`CompiledSpec` validation cover ordinary/traced compilation, dead and unused code, deferred edge-fluent
  arguments, generated emission, decoded v1 plans, and legacy generated adapters. Selector-specific runtime read,
  target, assignment, and receiver dispatch is deleted; eight retained constructor/literal classes pass. Focused
  proof is 15/15, the source scan is zero-positive/13 classified, complete Rust/native/generated/CLI/corpus gates
  and canonical CI pass, and Dart `.12.1.8.3` activates. A separately owned `.7.0` follow-up will recalibrate the
  oracle generator's 15-second default after VHDL parser construction measured 19.627 seconds while parsing took
  0.001 seconds; current complete regeneration uses the documented `ORACLE_TIMEOUT=30` override.
- `2026-07-12`: `.12.1.8.1` hard-retires exact aggregate selectors on Perl. Canonical ActionIR validation rejects
  direct, nested, dead, and unused-function occurrences before lowering with the neutral diagnostic fields; live
  compilation and generated-source emission fail deterministically. Valid constructors/literals remain. The
  embedded-source scanner now recognizes whitespace before `(` and caught/migrated three spaced fixture/generator
  residues. Focused Perl 41, regenerated oracle 105, Rust corpus 3/3, and Phase 0 `1..1031`/934s pass; Rust
  `.12.1.8.2` activates.
- `2026-07-12`: `.12.1.6` makes Lua the fifth executable uniform-binding backend on both ABIs. Bare typed
  push/append, mutable split, hash update, array-end methods, collection rebinding, results/chaining, static
  precedence, and wrong-kind fields pass all nine exact cases. PUC Lua and LuaJIT each pass 85/85; selector sources
  remain unchanged here, and shipped migration `.12.1.7.1` activates immediately.
- `2026-07-12`: `.12.1.5` makes Julia the fourth executable uniform-binding backend. `_read_runtime_store` remains
  the public read seam while kind-checked mutations update and return one typed value across native/generated paths.
  The 27-assertion focused contract, 1,311 package assertions, CLI 61x2, 105 corpus fixtures, and canonical
  Phase 0 `1..1030`/865s pass. Two stale array-end/hash-namespace locks now assert the adopted behavior. No selector
  source migrates; the Lua handoff later completed.
- `2026-07-12`: `.12.1.4` makes Dart the third executable uniform-binding backend. Bare reads and kind-checked
  mutations share one typed value across native/generated paths, including saved results and continuation. Mixed
  wrapper/bare mutations bridge the same binding only for migration. Format/analyze, 199 tests, generated packages,
  105 corpus fixtures, and CLI 61x2 pass without migrating selector sources; the Julia handoff later completed.
- `2026-07-12`: `.12.1.3` makes Rust the second executable uniform-binding backend. Native/generated execution
  passes the future fixture and all seven neutral cases plus bare append and collection rebinding. Private runtime
  stores remain internal; bare mutations validate and return the current typed value, static rules keep push
  precedence, and wrong kinds expose stable fields. The first full oracle caught a statement-append bypass and the
  shared mutation seam repaired it. Complete gates pass without migrating selector sources; Dart `.12.1.4` is active.
- `2026-07-12`: `.12.1.2` makes Perl the first executable uniform-binding backend. Bare push/append, mutable split,
  hash/index updates, array end/collection mutations, reads, copies, receivers, controls, calls, and chains use one
  typed binding and return independent updated values; `set` chains from its assignment value. Registered rules
  keep ambiguous-push precedence; absent targets auto-create; wrong kinds report stable fields. Canonical CI passes
  60/0/0 capability, 61x2 CLI, and Phase 0 `1..1030`/821s. Compatibility selectors remain only until migration;
  Rust `.12.1.3` is active.
- `2026-07-12`: `.12.1.1` adopts `linkedspec-uniform-binding-v1`. Eleven migration mappings, seven independent
  execution cases, six exact invalid selectors, eight valid constructor/literal classifications, and deterministic
  future fixture bytes fix bare typed reads/mutations, post-assignment `set`, updated mutation results, absent/
  wrong-kind behavior, static-rule push precedence, pure/mutable split, and `aggregate_selector_removed`.
  `[value]` replaces selector-shaped one-element construction; non-selector constructors remain in v1. Canonical
  CI owns the checker, current backend behavior stays unchanged, and Perl `.12.1.2` activates.
- `2026-07-12`: `.12.1.0` turns the settled selector-removal directive into an executable retirement tree. Exact
  boundary-correct scans find 600 `array(IDENTIFIER)` / `hash(IDENTIFIER)` calls in 82 tracked specs, including 210 in 15 shipped
  specs. Toolbox probes show bare reads/receivers but expose child-rule ambiguity for `push(items, value)` and an
  unsupported bare mutable `split`. Neutral contract `.1`, five backend enablement leaves, three migration slices,
  five hard-rejection leaves plus no-drift, and final docs/gates are ordered before Rust codeblock or Lua work.
- `2026-07-12`: `.11.3.4` closes Perl callable codeblocks after toolbox equivalence probes, typed-descriptor
  inspection, source-residue scans, 100 focused tests, and the immediately prior canonical 60/0/0 capability,
  61x2 CLI, and Phase 0 `1..1030` proof. No behavior repair was needed. The director-settled removal of spec-facing
  `array(IDENTIFIER)` / `hash(IDENTIFIER)` selectors is now active under `.12.1` before Rust codeblocks or Lua;
  only ordinary non-selector constructor classification remains a separate question.
- `2026-07-12`: `.11.3.3.2` preserves final kind metadata in typed user/staged records, introduces one helper/
  receiver/user-function callable-contract seam, removes receiver parser name gating, and normalizes contextual
  attached/parenthesized blocks to one zero-positional `codeblock_argument`. Focused live/standalone generated
  execution, explicit literals, harray rejection, and typed declaration failures pass; `.11.3.4` has since closed.
- `2026-07-12`: Director clarification closes `.11.3.3.1` with exact final-only `name: codeblock`. The receiving
  parameter carries only the codeblock value kind; it has no nested argument list, and explicit `{|params| ...}`
  values retain their own signatures. ADR 0032 and the strict checker lock four invalid declarations plus eight
  helper/user-function/receiver contextual forms; no backend behavior changed in that design slice.
- `2026-07-12`: `.11.3.3.0` stops behavior work at a real contract gap. Attached and parenthesized blocks already
  have equivalent `block_value` payloads, but no helper/user-function/receiver signature declares contextual
  codeblock acceptance or the callback's own params. Design `.1` is active before Perl implementation `.2`; no
  parser, registry, lowering, runtime, fixture, or generated behavior changed.
- `2026-07-12`: `.11.3.2` adds closure-free Perl invocation for typed codeblock records. Static helpers/functions
  retain precedence; explicit caller binding references provide dynamic reads and persistent nonparameter writes;
  fixed/rest params copy and restore; results chain or drop canonically; typed failures are stable. Exact neutral
  live/standalone execution, 97 focused top-level tests, 61x2 CLI, and Phase 0 `1..1030`/815s pass; `.11.3.3` is active.
- `2026-07-11`: `.1.6.5.0` confirms Dart's public emitter/levels/events/sinks and runtime injection pass while
  parser, validator, compiler, function shell, staged registry, and native loader lack propagation. It splits
  frontend/compiler `.1`, function/staged `.2`, and composed admission `.3`; no behavior or census state changes.
- `2026-07-11`: `.1.6.5.1` adds source-compatible optional emitter injection to Dart parsing, validation,
  compilation, and function-registry construction. Balanced success/failure scopes and stable decisions preserve
  exact JSON and default quietness; 168 tests, 61x2 CLI, and 105 corpus pass. `.2` is active; census stays 56/1/3.
- `2026-07-11`: `.1.6.5.2` carries that emitter through function parser construction/execution, projection, stripped
  parsing, staged queue ordering, resolve/load/compile/execute, and body stitching. Four focused tests plus the full
  172-test/61x2/105 gate pass; `.3` is active for native composition/admission and census remains 56/1/3.
- `2026-07-11`: `.1.6.5.3` composes one routed caller emitter from native loading through every compiled phase and
  final runtime without retaining it in results. Three direct tests plus 22 affected and full 175-test/61x2/105
  gates pass; Dart trace promotes to pass at 57/1/2, `.1.6.5` closes, and `.1.6.6` is active.
- `2026-07-11`: `.1.6.6` projects exactly three non-pass states, all generated source and all owned by `.3`. The
  strict 57/1/2 checker and adjacent full gates pass; no behavior/status value changes. Non-codegen `.1.6` closes
  without overclaiming complete parity, and generated-source `.3` becomes active.
- `2026-07-11`: `.3.0` records the source-backed boundary inherited from the then-current census: Perl was classified
  pass; Rust exposes a versioned standalone module emitter, validated family plan, direct all-family execution, and
  isolated compile/run, but its manifest proof names only eight of 105 cases; Dart and Julia contain no emitter.
  `.3.1.0` immediately afterward added independent Perl execution and corrected that pass assumption to partial.
- `2026-07-11`: `.3.1.0` adds the missing independent-execution probe and corrects `.3.0`'s inherited Perl pass
  assumption. Normal generated execution returns `"ok"`, but captured source recompiles and returns `undef` because
  stringified `LinkedRE::oredRE` alternative markers no longer update `LinkedRE::or`'s lexical index. Census is
  corrected to 56/2/2; `.3.1.1` contract, `.3.1.2` repair, and `.3.1.3` admission are split before behavior code.
- `2026-07-11`: `.3.1.1` defines generated-source contract v1 and a strict canonical checker. Semantic roles fix
  compiled-spec-plus-identity emission, independent load, direct/traced execution, ten families, four plan
  rejections, stable errors, one direct fixture, and interpreter-first 8/105 proof while host APIs/source remain
  idiomatic. No backend behavior changes; census remains 56/2/2 and Perl repair `.3.1.2` is active.
- `2026-07-11`: `.3.1.2` adds public `emit_generated_source`, reconstructs dependency alternatives from compiled
  refs, and emits deterministic v1 identity/plan/Execute/trace/error roles. Independent packages return exact
  results for indexes zero/one and slash regexes; all four plan rejections pass. Phase 0 moves from exactly two
  stale wrapper locks to `1..1030` green. Census stays 56/2/2 until admission `.3.1.3`.
- `2026-07-11`: `.3.1.3.0` audits Rust against the concrete v1 contract before admission. The existing all-family,
  legacy-repetition, isolated-crate, and eight-case proof stays green, but the pre-contract API has no source
  identity/contract marker, structured error, unknown-family rejection, or neutral generated trace roles.
  `.3.1.3.1-.3` own those mechanisms and admission; census remains 56/2/2 and `.1` becomes active.
- `2026-07-11`: `.3.1.3.1` adds Rust's typed `emit_rust_source_v1` identity/error surface, deterministic contract/
  version/identity metadata, typed emitted execution entrypoints, and caller projection for host compile/load
  failures. The original string emitter and generated `parse` adapters preserve exact compatibility. Focused 4/4
  and the complete 137/105/196/5/4/5/10 plus 61x2 gate pass; census remains 56/2/2 and exact plan/trace `.2` is active.
- `2026-07-11`: `.3.1.3.2` emits the exact ten neutral plan strings and independently rejects count, label, known-
  family mismatch, and unknown family. The neutral fixture found typed generated execution still returned Rust's
  legacy accumulator envelope; a generated-plan-aware direct-result seam now mirrors native `execute_value`, while
  legacy `parse`/traced paths retain their envelope. The three portable trace roles appear beside native detail.
  Focused 5/5 + 10/10 and the clean 137/105/196/5/5/5/10 plus 61x2 gate pass; admission `.3` is active at 56/2/2.
- `2026-07-11`: `.3.1.3.3` reruns focused Perl (69 assertions) and Rust (5/5), complete canonical Perl 61x2 plus
  Phase 0 `1..1030` in 652 seconds, and a fresh complete Rust 137/105/196/5/5/5/10 plus 61x2 gate. Contract/census
  advance to 57/1/2: Perl passes; Rust is partial solely for the named eight of 105 generated fixtures; Dart/Julia
  remain gaps. `.3.1.3` and `.3.1` close; scalable Rust full-manifest classifier `.3.2.0` becomes active.
- `2026-07-11`: `.3.2.0` adds a complete-manifest staged Rust generated-source classifier. A first exact per-case
  Cargo design measured about ten seconds per fixture and was stopped after eight passes; the final scalable design
  prepares all cases independently, writes 105 separate generated modules/tests into one isolated crate, then runs
  one host compile and one serial host test pass. Every case passes read/parse/validate/compile/interpreter-oracle/
  emission/host-compile/host-run in 184.46 seconds; no repair mechanism exists. Rust stays partial until `.3.2.1`
  records the zero-failure closeout and `.3.2.2` makes breadth a strict recurring admission gate.
- `2026-07-11`: `.3.2.1` classifies the exact zero-failure result against every requested repair category. The
  source-emitter, generated-plan, generated-executor, dependency/build, and fixture-contract inventories are all
  empty, so the leaf closes without inventing a child or changing behavior. Rust remains partial and `.3.2.2`
  becomes the sole active Rust breadth leaf for strict recurring admission.
- `2026-07-11`: `.3.2.2` removes the all-105 classifier's ignore/conditional bypass and extends contract checking
  to lock its path, 105 count, ordinary execution, and unconditional failure rejection. Independent strict proof
  passes 105/105 in 186.42 seconds; the complete Rust gate repeats it in 189.42 seconds alongside
  137/105-interpreter/196/5/5/5/10 and 61x2 CLI. Rust promotes to pass at census 58/0/2, `.3.2` closes, and Dart
  emitter scaffold `.3.3.1` becomes active.
- `2026-07-11`: `.3.3.1` adds Dart compatibility/v1 generated-source emission from effective ordered compiled
  state, stable contract/format/identity metadata, portable emit/compile-load/execution errors, and ordinary/traced
  direct-value entrypoints. Unicode native source embeds normalized spec JSON as strict UTF-8 then Base64. A
  caller-owned temporary package/private cache resolves offline, analyzes, runs Unicode/`$` output, attributes a
  missing-rule failure, and deletes itself. Focused 3/3 and complete Dart 178/61x2/105 pass. Census remains 58/0/2;
  exact family-plan/direct structural execution `.3.3.2` becomes active before manifest admission `.3.3.3`.
- `2026-07-11`: `.3.3.2` adds the exact ten-family Dart plan and validates row count, ordered label, known-family
  mismatch, and unknown family before execution with distinct portable codes. Validated typed families select
  regex/acode versus blind/bcode structural dispatch on every generated rule entry. Portable enter/decision/exit
  trace roles retain source/rule/family identity. One isolated package analyzes/runs all ten generated libraries
  against interpreter values. Focused 5/5 and complete Dart 180/61x2/105 pass; census remains 58/0/2 and curated
  interpreter-first admission `.3.3.3` becomes active.
- `2026-07-11`: `.3.3.3` reads the exact eight accepted names from contract v1, proves each checked-in expected
  result through the interpreter first, then analyzes/runs all eight emitted libraries in one isolated offline
  package with exact values, metadata, plans, and portable trace identity. The checker locks this path/count/order/
  host proof/cleanup/no-skip contract. Focused 6/6 and complete Dart 181/61x2/105 pass. Dart promotes gap→pass at
  census 59/0/1, `.3.3` closes, and Julia scaffold `.3.4.1` becomes next after the clean commit.
- `2026-07-11`: `.1.6.4.5` adds Perl's separate portable `SpecLoader` facade and direct 14/9/4 plus pipeline proof
  without changing legacy `get_parser`/`PathSearch`. The canonical core gate passes the required new test, 239-name
  coverage, focused suites, 61x2 CLI, and Phase 0 `1..1030` in 556 seconds. Combined with immediately prior full
  Rust/Dart/Julia proof, exact native resolution is admitted, `.1.6.4` closes, and Dart trace `.1.6.5` is active.
- `2026-07-11`: `.1.6.4.4` adds Julia's public progressive resolver/loader/compiler, 82-assertion direct 14/9/4
  fixture proof, exact source identity, structured typed exceptions, attributed-engine construction, and primary
  CLI delegation while removing recursive fallback. The full Julia gate passes 1,110 assertions, 61x2 CLI, and 105
  corpus fixtures; census advances to 56/1/3 and final admission `.5` is active.
- `2026-07-11`: `.1.6.4.3` adds Dart's public progressive resolver/loader/compiler, direct 14/9/4 fixture proof,
  exact source identity, structured exceptions, attributed-engine construction, and primary CLI delegation. The
  full Dart gate passes 165 tests, 61x2 CLI, and 105 corpus fixtures; census advances to 55/1/4 and Julia `.4` is
  active.
- `2026-07-10`: `.1.6.0` adds a strict machine-readable capability census beyond the green CLI/corpus subsets.
  Fifteen rows classify 47 pass, five partial-proof, and eight gap backend states; all non-pass states and explicit
  future/legacy exclusions have task owners. The checker joins core CI, Phase 0 `1..1028` passes, and `.1.6.1`
  becomes active for exhaustive neutral mdBook language/helper proof before implementation repairs.
- `2026-07-10`: `.1.5.4.3` adds one executable matrix that prepares all four implemented commands and runs the
  unchanged 61-case manifest under default and POSIX option environments. All 488 command cases, focused backend
  gates, and broader Phase 0 pass. Exact CLI parent `.1.5` closes; capability census `.1.6` becomes active. Safe
  cleanup removes 1.6 GB Rust target, 143 MB Julia depot, and 30 MB Dart cache after verification is consumed.
- `2026-07-10`: `.1.5.3.0` measures Dart's corpus-oriented primary executable at 0/61, confirms reusable staged
  parse/compile/direct-execute/mode/top-rule/trace/JSON seams, and splits exact boundary, execution, trace, and
  closeout. The corpus runner remains separate; no Dart behavior or shared fixture bytes change.
- `2026-07-10`: `.1.5.3.1` replaces the primary process boundary, preserves the corpus runner, corrects ordinary
  no-function staged parsing, and locks strict raw UTF-8/BOM/newline behavior plus phase order. The exact subset is
  29/29 default/POSIX; all 147 Dart tests and 99/99 corpus pass; `.2` is active for 11 direct result cases.
- `2026-07-10`: `.1.5.3.2` composes the native engine, top rule, global mode, direct result, and recursive canonical
  JSON. All 11 success cases plus silent quiet trace pass default/POSIX; Dart advances 29 -> 41/61 with only 20
  trace cases remaining under active `.3`.
- `2026-07-10`: `.1.5.3.3` implements the independent canonical phase trace and closes all 20 residuals. Focused
  sink/setup tests, full Dart/corpus gates, and the unchanged 61-case suite pass default/POSIX; `.4` is active for
  recurring integration and no-drift closeout.
- `2026-07-10`: `.1.5.3.4` adds both shared environments to `tools/run_dart_local.sh`, proves the focused and
  broader gates, closes parent `.1.5.3`, and activates four-backend identity `.1.5.4`. No behavior/fixture changes.
- `2026-07-10`: `.1.5.4.0` classifies Julia's 13/61 warmed baseline. Shared help/strict UTF-8/stable errors,
  canonical trace, and the final four-backend driver become `.1`-`.3`; no Julia behavior changes in the split.
- `2026-07-10`: `.1.5.4.1` aligns exact help/usage, validates raw file bytes as strict UTF-8, and removes native
  diagnostic detail from primary stderr while preserving native exceptions. Package/process checks pass and the
  unchanged suite reaches 42/61 default/POSIX; `.2` owns the 19 trace-only residuals.
- `2026-07-10`: `.1.5.4.2` adds Julia's independent canonical phase recorder with exact levels, byte counts,
  escaping, emoji, sinks, file lifecycle, failures, and result framing. Native rich trace stays intact; all 61
  shared cases pass default/POSIX and `.3` is active for recurring matrix integration.
- `2026-07-10`: `.1.5.2.4` adds the recurring Rust gate, proves 61/61 in default/POSIX environments plus the full
  runtime package and broader local gate through Phase 0 `1..1028`, closes parent `.1.5.2`, and activates Dart
  `.1.5.3`. Help and fixture bytes remain unchanged.
- `2026-07-10`: `.1.5.2.3` adds ADR `0024`'s canonical trace projection independently of native Rust trace and
  advances the unchanged suite from 41/61 to 61/61.
- `2026-07-10`: `.1.5.2.2` adds reusable per-invocation entry/mode/direct-value execution and corrects ordinary
  nested-hash preservation versus explicit flat splicing, advancing the suite from 29/61 to 41/61.
- `2026-07-10`: `.1.5.2.1` adds `linkedspec-rust` with exact arguments/help, deterministic loading, strict UTF-8,
  and stable phase failures, establishing a 29/61 boundary baseline.
- `2026-07-10`: `.1.5.2.0` audits the Rust native/adapter seams and splits binary/loading, direct execution,
  canonical trace, and closeout before implementation.
- `2026-07-10`: `.1.5.1.6.3` closes the Perl CLI reference after current-state scans find no unresolved encoding,
  count, or frontier drift. Parent `.1.5.1`/`.6` are done at 61 cases; Rust `.1.5.2` is active. Historical 53-case
  and initiating mojibake records remain explicitly dated; no behavior or fixture bytes change.
- `2026-07-10`: `.1.5.1.6.2` fixes the Perl adapter's byte/string boundary. Strict argv and raw-file decoding,
  preserved code points/BOM/newlines/normalization, recursive UTF-8 JSON, and stable invalid phases are locked by
  eight exact new families. Both environments pass 61/61; `.6.3` is active for final reference no-drift.
- `2026-07-10`: `.11.0` audits the current trailing-block surface and captures the director's correction. Four
  implemented backends support narrow named `with`/traversal blocks, Lua is absent, and the old contract rejects
  the parenthesized equivalent. Parked `.11.1` will make callable signatures own final codeblock acceptance,
  canonicalize attached/parenthesized spellings, split every-backend parity, and decide `with`; the then-active
  `.6.2` frontier was unchanged by that capture and has since closed.
- `2026-07-10`: `.1.5.1.6.1` adds `bytes_hex` as a mutually exclusive schema-v1 input-file source. Raw
  materialization and six runner subtests lock exact invalid bytes plus both/neither/empty/case/length/character
  validation before launch. `.6.2` can now express strict UTF-8 failures without checked-in binary blobs.
- `2026-07-10`: `.1.5.1.6.0` proves Perl mojibake is an adapter decode defect, not a native parser limitation.
  ADR `0025` ratifies strict preserved UTF-8 text across args/files/JSON/trace, stable invalid-file phase projection,
  and no accidental binary-input contract. Runner hex materialization (`.6.1`), Perl decode/fixtures (`.6.2`), and
  final no-drift (`.6.3`) are separate; Rust remains pending.
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
