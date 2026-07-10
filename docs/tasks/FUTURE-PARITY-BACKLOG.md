# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-07-10` (`.1.5.1.6.3` closes the 61-case Perl reference; `.1.5.2` active for Rust; `.11.1` parked).
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
  Status: `active`
  Goal: Add the Rust primary CLI against the shared fixture contract.
  Children: `.1.5.2.0`, `.1.5.2.1`, `.1.5.2.2`, `.1.5.2.3`, `.1.5.2.4`
  Acceptance: A Rust binary delegates to native core/runtime APIs and passes the same CLI fixtures as Perl. The
    binary may project portable argument/loading/diagnostic/trace policy, but it may not duplicate `.spec` parsing,
    compilation, matching, lifecycle, helper, or result semantics owned by the Rust libraries.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Close Rust primary-command conformance and recurring focused verification.
  Acceptance: The built Rust command passes all 61 unchanged neutral cases in default and POSIX environments;
    focused Rust tests and the broader local gate pass; the Rust primary command is wired into relevant local
    checks; task/roadmap/live docs, mdBook, Knowledge Map, help, and artifact cleanup agree before Dart `.1.5.3`.
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
| 16 | `FUTURE-PARITY-BACKLOG.1.5.2.4` | `active` | Prove default/POSIX identity, gate Rust, and close no-drift. |
| 17 | `FUTURE-PARITY-BACKLOG.1.5.3` | `pending` | Replace Dart's corpus-oriented primary command with the shared parser interface. |
| 18 | `FUTURE-PARITY-BACKLOG.1.5.4` | `pending` | Make four-backend CLI identity a recurring gate. |
| 19 | `FUTURE-PARITY-BACKLOG.1.6` | `pending` | Census every documented/exported user capability and split all residual parity gaps. |
| 20 | `FUTURE-PARITY-BACKLOG.3` | `pending` | Public generated-source capability must converge after the capability census/split. |
| 21 | `FUTURE-PARITY-BACKLOG.1.3` | `pending` | Lua inherits the complete capability and identical CLI gates after current backends converge. |
| 22 | `FUTURE-PARITY-BACKLOG.2` | `pending` | Staged parsing generalization follows unless the director explicitly pivots. |
| 23 | `FUTURE-PARITY-BACKLOG.4` | `pending` | Function extensions need explicit language decisions before code. |
| 24 | `FUTURE-PARITY-BACKLOG.5` | `pending` | Helper caveats are documented but not normalized. |
| 25 | `FUTURE-PARITY-BACKLOG.6` | `pending` | Plugin machinery fate is a Perl-reference facade decision. |
| 26 | `FUTURE-PARITY-BACKLOG.7` | `pending` | Richer oracle candidates need safe fixture triage. |
| 27 | `FUTURE-PARITY-BACKLOG.8.1` | `pending` | Director's single-source parser+stimuli roundtrip arc is parked for later design. |
| 28 | `FUTURE-PARITY-BACKLOG.9.1` | `pending` | Director's corrected AND/OR edge-default arc is parked for later design. |
| 29 | `FUTURE-PARITY-BACKLOG.10.1` | `pending` | Director's semantic-introspection API/MCP arc is parked behind the active backend frontier. |
| 30 | `FUTURE-PARITY-BACKLOG.11.1` | `pending` | Director's generic final-codeblock argument correction is parked behind the active UTF-8/CLI frontier. |

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

- None blocking `.1.5.1.6.2`: ADR `0025` fixes the text policy and `.6.1` now supplies exact invalid bytes. Lua
  `.1.3` remains gated until implemented
  backends close CLI/capability convergence, including `.1.6`-split gaps and generated source under `.3`.
- Parked `.11.1` must decide public `harray` versus current `hash` terminology and retain/migrate/remove `with`;
  neither question blocks `.1.5.1.6.3` and neither is silently decided by capture leaf `.11.0`.

## Blockers

- None. Perl `.1.5.1` is closed at 61 cases; Rust `.1.5.2.3` is done at 61/61 and `.1.5.2.4` is active for
  recurring-gate and no-drift closeout.
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

## Changelog

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
