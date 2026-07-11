# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-07-10` (Dart exact empty-local-match positions closed; Julia `.1.6.1.2.2.2.3` active).
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

- The eleven backlog directions are represented as owned task-tree lanes.
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
- The central task-tree index points at the current frontier.
- ADR, roadmap, mdBook, Knowledge Map, and live docs no longer contradict the backend order or
  Lua adoption decision.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `FUTURE-PARITY-BACKLOG`
  Status: `active`
  Goal: Own the future parity backlog after the closed language-reference/terse-format trees.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`, `.10`, `.11`

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
  Status: `active`
  Goal: Prove complete user-observable feature/behavior parity beyond the 99-fixture interpreter corpus.
  Children: `.1.6.0`, `.1.6.1`, `.1.6.2`, `.1.6.3`, `.1.6.4`, `.1.6.5`, `.1.6.6`
  Acceptance: Build a machine-readable capability matrix from the mdBook, exported public APIs, Phase 0, and the
    language-neutral corpus; classify Perl/Rust/Dart/Julia gaps before implementation; split every gap into an
    owned parity leaf; do not call a backend full-parity while any user-visible capability differs.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Turn the complete current mdBook language/helper surface into neutral executable capability proof.
  Children: `.1.6.1.0`, `.1.6.1.1`, `.1.6.1.2`
  Acceptance: Map every current non-legacy language, rule, lifecycle, ActionIR, helper, method, value-kind, cursor,
    capture, function, and staged-body contract to an existing neutral fixture or add a backend-neutral fixture;
    run unchanged on Perl/Rust/Dart/Julia; split any behavioral mismatch by mechanism before repair.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Complete and run exhaustive current-call neutral coverage after newline separator repair.
  Children: `.1.6.1.2.0`, `.1.6.1.2.1`, `.1.6.1.2.2`
  Acceptance: Finish bounded pure/position/capture/mark/cursor/control fixtures, make the coverage checker require
    every current Dart/Julia ActionIR name in the mdBook and generated neutral corpus, regenerate Perl oracle bytes,
    run the unchanged corpus on Perl/Rust/Dart/Julia, split any residual behavioral mismatch, and close parent
    `.1.6.1` only when `language.current_mdbook_surface` can move from partial to pass.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Correct fixture timing, admit exhaustive current-call families, and close strict four-backend proof.
  Children: `.1.6.1.2.2.0`, `.1.6.1.2.2.1`, `.1.6.1.2.2.2`, `.1.6.1.2.2.3`,
    `.1.6.1.2.2.4`, `.1.6.1.2.2.5`
  Acceptance: Apply the proven three-slot capture/mark timing, use newline-only control source, register all six
    source fixtures in oracle generation, regenerate exact Perl values, make strict 237-name coverage pass, run the
    expanded corpus unchanged on Perl/Rust/Dart/Julia, update `language.current_mdbook_surface`, and close `.1.6.1`.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Align empty local-match position projection on Rust, Dart, and Julia.
  Children: `.1.6.1.2.2.2.1`, `.1.6.1.2.2.2.2`, `.1.6.1.2.2.2.3`
  Acceptance: Match Perl's exact null capture/length/position plus empty-map/list/has and 1-based line/column defaults
    after entry match without inventing a local match; close one backend per committed child.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Align Julia empty local-match position projection and close `.2`.
  Acceptance: Exact position fixture value and existing corpus pass.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3`
  Status: `pending`
  Goal: Align marker aliases and matched-case/default control semantics.
  Children: `.1.6.1.2.2.3.1`, `.1.6.1.2.2.3.2`, `.1.6.1.2.2.3.3`
  Acceptance: Newline `i`/`elif` executes like `if`/`elseif`; a matching case excludes default; end markers preserve
    exact control boundaries; close one backend per committed child.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1`
  Status: `pending`
  Goal: Align Rust marker aliases/control fixture.
  Acceptance: Remove unknown `i`/`elif` diagnostics and return `["elif","case-b"]` without regressing switch.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2`
  Status: `pending`
  Goal: Align Dart marker switch selection.
  Acceptance: Preserve alias behavior and exclude default after matching case; exact control fixture passes.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3`
  Status: `pending`
  Goal: Align Julia marker switch selection and close `.3`.
  Acceptance: Preserve alias behavior and exclude default after matching case; exact control fixture passes.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4`
  Status: `pending`
  Goal: Complete anonymous/named capture-mark executable semantics.
  Children: `.1.6.1.2.2.4.1`, `.1.6.1.2.2.4.2`, `.1.6.1.2.2.4.3`
  Acceptance: Exact anonymous and named hashes pass, including stable/advancing reads, bridge/reset, mark metadata,
    input boundary marks, copied marks, and two-mark advancing reads; close one backend per committed child.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1`
  Status: `pending`
  Goal: Complete Rust capture/mark fixture semantics.
  Acceptance: Both exact fixture hashes pass with no unknown-helper warning and existing corpus remains green.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2`
  Status: `pending`
  Goal: Complete Dart capture/mark fixture semantics.
  Acceptance: Both exact fixture hashes pass with no unsupported-helper failure and existing corpus remains green.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3`
  Status: `pending`
  Goal: Complete Julia capture/mark fixture semantics and close `.4`.
  Acceptance: Both exact fixture hashes pass with no unsupported-helper failure and existing corpus remains green.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5`
  Status: `pending`
  Goal: Admit all six fixtures and close strict current-call proof.
  Acceptance: Register governed `source_file` cases, regenerate 105 exact values, pass strict 237-name coverage,
    run 105/105 unchanged on Perl/Rust/Dart/Julia, promote all four `language.current_mdbook_surface` states to
    pass, close `.1.6.1.2`/`.1.6.1`, and advance to `.1.6.2`.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.2`
  Status: `pending`
  Goal: Add Rust's backend-neutral outward compiled-descriptor projection.
  Acceptance: Rust exposes the documented `spec`, `functions`, `dependency_regex_map`, and `meta` projection with
    stable field meanings/order and staged function metadata equivalent to Perl/Dart/Julia; focused neutral shape
    fixtures prove idiomatic Rust types/JSON without coupling callers to engine internals.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.3`
  Status: `pending`
  Goal: Add structured Rust runtime diagnostic context equivalent to the other native backends.
  Acceptance: Native Rust runtime failures expose stable type/stage/summary/detail plus available spec/top/rule/
    handler attribution as structured data rather than requiring string scraping; ordinary `Result` ergonomics,
    CLI phase projection, trace behavior, and successful results remain compatible.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.4`
  Status: `pending`
  Goal: Add idiomatic native named/file spec resolution to Rust, Dart, and Julia.
  Acceptance: Each non-Perl library exposes the book's file-oriented role with deterministic explicit-path and
    named-spec resolution/search precedence, strict text loading, parse/compile composition, and structured errors;
    shared path fixtures prove equivalent behavior without requiring the primary CLI or a subprocess.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.5`
  Status: `pending`
  Goal: Complete Dart native trace coverage across frontend, compiler, function-shell, and staged dispatch.
  Acceptance: One caller-owned Dart emitter propagates through parse, validation, compile, function-definition,
    staged-job, and runtime entrypoints with balanced scopes, decisions, failures, sinks, default quietness, and
    traced/untraced identity equivalent to Perl/Rust/Julia; focused and 99-corpus gates pass.
  Verification: `pending`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.1.6.6`
  Status: `pending`
  Goal: Close the non-codegen capability census and hand generated-source residuals to `.3` without overclaiming.
  Acceptance: The validated matrix contains no unowned gap/partial state; all `.1.6` implementation/proof leaves
    pass recurring checks; task/roadmap/live docs, mdBook, Knowledge Map, public APIs, and exact CLI agree; parent
    `.1.6` closes while complete backend parity remains blocked only by generated-source `.3` and later Lua.
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

- ID: `FUTURE-PARITY-BACKLOG.11`
  Status: `active`
  Goal: Correct trailing code blocks from the narrow `with` MVP to the language's generic final-codeblock argument model.
  Children: `.11.0`, `.11.1`
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
  Status: `pending`
  Goal: Design and split generic final-codeblock argument parity before implementation.
  Acceptance: Define the four value kinds precisely, including whether public terminology is `harray` or the
    current `hash`; define the callable-signature declaration for final `codeblock`; make attached and
    parenthesized forms one canonical AST/IR shape; specify evaluation timing, block-local return, lexical/runtime
    context, receiver behavior, arity and non-final diagnostics, and hash-literal disambiguation; decide whether
    `with` remains as an ordinary helper, is migrated, or is removed; inventory every existing block-taking helper
    and method; split reference plus Rust/Dart/Julia/Lua parity and neutral conformance fixtures before code.
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
| 37 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3` | `active` | Align Julia empty local-match projection. |
| 38 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1` | `pending` | Align Rust marker aliases/control. |
| 39 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2` | `pending` | Align Dart marker switch selection. |
| 40 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3` | `pending` | Align Julia marker switch selection. |
| 41 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1` | `pending` | Complete Rust capture/mark semantics. |
| 42 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2` | `pending` | Complete Dart capture/mark semantics. |
| 43 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3` | `pending` | Complete Julia capture/mark semantics. |
| 44 | `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5` | `pending` | Admit six fixtures and close strict 105-case proof. |
| 45 | `FUTURE-PARITY-BACKLOG.1.6.2` | `pending` | Add Rust's missing outward compiled-descriptor projection. |
| 46 | `FUTURE-PARITY-BACKLOG.1.6.3` | `pending` | Add structured Rust native runtime diagnostics. |
| 47 | `FUTURE-PARITY-BACKLOG.1.6.4` | `pending` | Add native named/file resolution to Rust, Dart, and Julia. |
| 48 | `FUTURE-PARITY-BACKLOG.1.6.5` | `pending` | Extend Dart native trace through frontend/compiler/function-shell/staged phases. |
| 49 | `FUTURE-PARITY-BACKLOG.1.6.6` | `pending` | Close non-codegen capability parity and hand only source generation to `.3`. |
| 50 | `FUTURE-PARITY-BACKLOG.3` | `pending` | Public generated-source capability must converge after the capability census/split. |
| 51 | `FUTURE-PARITY-BACKLOG.1.3` | `pending` | Lua inherits the complete capability and identical CLI gates after current backends converge. |
| 52 | `FUTURE-PARITY-BACKLOG.2` | `pending` | Staged parsing generalization follows unless the director explicitly pivots. |
| 53 | `FUTURE-PARITY-BACKLOG.4` | `pending` | Function extensions need explicit language decisions before code. |
| 54 | `FUTURE-PARITY-BACKLOG.5` | `pending` | Helper caveats are documented but not normalized. |
| 55 | `FUTURE-PARITY-BACKLOG.6` | `pending` | Plugin machinery fate is a Perl-reference facade decision. |
| 56 | `FUTURE-PARITY-BACKLOG.7` | `pending` | Richer oracle candidates need safe fixture triage. |
| 57 | `FUTURE-PARITY-BACKLOG.8.1` | `pending` | Director's single-source parser+stimuli roundtrip arc is parked for later design. |
| 58 | `FUTURE-PARITY-BACKLOG.9.1` | `pending` | Director's corrected AND/OR edge-default arc is parked for later design. |
| 59 | `FUTURE-PARITY-BACKLOG.10.1` | `pending` | Director's semantic-introspection API/MCP arc is parked behind the active backend frontier. |
| 60 | `FUTURE-PARITY-BACKLOG.11.1` | `pending` | Director's generic final-codeblock argument correction is parked behind the active UTF-8/CLI frontier. |

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

- None blocking `.1.6.1`: exact four-backend CLI parity is closed. Lua `.1.3` remains gated until implemented
  backends close capability convergence, including `.1.6`-split gaps and generated source under `.3`.
- Parked `.11.1` must decide public `harray` versus current `hash` terminology and retain/migrate/remove `with`;
  neither question blocks `.1.5.1.6.3` and neither is silently decided by capture leaf `.11.0`.

## Blockers

- None. Perl, Rust, Dart, and Julia are closed at the same 61 primary CLI cases in default/POSIX environments.
  Neutral mdBook capability proof `.1.6.1` is active; later residual repairs and generated-source `.3` precede Lua.

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

## Changelog

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
