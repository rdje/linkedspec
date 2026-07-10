# JULIA-BACKEND-PARITY: Julia LinkedSpec Backend Parity

## Metadata

- Tree ID: `JULIA-BACKEND-PARITY`
- Status: `active`
- Roadmap lane: `Overall roadmap - future backend parity (Julia second)`
- Created: `2026-07-09`
- Last updated: `2026-07-10`
- Owner: repo-local workflow

## Goal

Implement a Julia LinkedSpec backend that consumes the same `.spec` files as the Perl reference backend, the Rust
backend, and the scoped Dart backend, with full behavioral parity against the language-neutral corpus and the
mdBook contract. This tree is the Julia lane delegated by `FUTURE-PARITY-BACKLOG.1.2`.

## Non-Goals

- Do not implement Lua in this tree.
- Do not create Julia-only `.spec` syntax, helper names, runtime semantics, diagnostics, or corpus fixtures.
- Do not treat Perl plugin machinery as part of the backend-neutral contract.
- Do not start with generated Julia source as the primary parity strategy; Julia starts interpreter-first unless a
  future leaf explicitly supersedes that decision after toolchain/package preflight.
- Do not broaden the `.spec` language while implementing Julia parity; language changes need their own task-tree
  leaves and cross-backend locks.

## Acceptance Criteria

- A Julia workspace/package lives under repo ownership and can be built and tested locally.
- The Julia frontend parses the documented `.spec` grammar and validates the same source-shape contracts as Perl,
  Rust, and Dart.
- Helper/action language text is parsed into typed AST/IR nodes before lowering, interpretation, or code emission.
- Julia compiles parsed `.spec` input into a typed compiled-spec/interpreter model equivalent to the Rust and Dart
  compiled-state contracts and the mdBook compiled-state model.
- Runtime behavior matches the runtime-semantics appendix: parse modes, lifecycle order, accumulators, explicit
  cursor controls, boundary capture, dispatch, repetition bounds, output shape, diagnostics, and determinism.
- Regex matching provides position-tracked seek/consume matching, capture groups, named captures, and matched
  alternative identity without relying on host-language regex features that would create a Julia-only contract.
- Staged parser registry, user-function registry, function-body parse jobs, and trace controls match the documented
  external contracts.
- A Julia corpus runner consumes `rust/linkedspec-runtime/tests/corpus/manifest.json`, rejects manifest drift, and
  passes all current fixtures against the Perl/Rust/Dart expected values.
- Julia exposes its own distinct LinkedSpec CLI entrypoint; it must not rely on the Perl, Rust, or Dart CLI names as
  the only user-facing command.
- mdBook, live docs, task-tree status, and Knowledge Map cards stay aligned with the implemented Julia surface after
  every slice.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `JULIA-BACKEND-PARITY`
  Status: `active`
  Goal: Implement Julia as the second future full-parity LinkedSpec backend after Dart.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `JULIA-BACKEND-PARITY.1`
  Status: `done`
  Goal: Establish Julia toolchain, workspace, and parity harness foundations before parser code.
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `JULIA-BACKEND-PARITY.1.1`
  Status: `done`
  Goal: Verify local Julia toolchain availability and define the repository-owned Julia package layout.
  Acceptance: Record the exact Julia commands available locally, or record a real blocker if no Julia toolchain is
    available; define the intended `julia/` package layout, test command, formatter/linter command if available,
    package manager command, Julia-specific CLI entrypoint, and corpus-runner entrypoint before source
    implementation.
  Verification: `PASS` - Julia `1.12.6` is installed through Homebrew at `/opt/homebrew/bin/julia`; `Pkg` and
    `Test` import successfully when `JULIA_DEPOT_PATH` points to a writable depot; optional global
    `JuliaFormatter` and `JET` packages are not installed.
  Commit: `JULIA-BACKEND-PARITY.1.1 - verify Julia toolchain preflight`

- ID: `JULIA-BACKEND-PARITY.1.2`
  Status: `done`
  Goal: Create the minimal Julia package scaffold and CI-facing smoke test.
  Acceptance: `julia/` has package metadata, library/test entrypoints, a no-op smoke test, documented commands,
    and no dependency on unpublished local state.
  Verification: `PASS` - `Pkg.instantiate()`, `Pkg.test()`, Julia-specific CLI help/status, and corpus-runner
    scaffold smoke commands pass with `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot`.
  Commit: `JULIA-BACKEND-PARITY.1.2 - scaffold Julia package`

- ID: `JULIA-BACKEND-PARITY.1.3`
  Status: `done`
  Goal: Add corpus-fixture IO scaffolding without executing parser semantics yet.
  Acceptance: Julia can load the manifest-backed corpus directory, validate manifest shape, and detect
    missing/stale fixture directories before any `.spec` runtime is implemented.
  Verification: `PASS` - Julia loads the checked-in 99-fixture manifest, validates required fixture files and
    expected JSON syntax, catches manifest shape/count/name/drift/file errors, and keeps `--execute` rejected.
  Commit: `JULIA-BACKEND-PARITY.1.3 - add Julia corpus manifest IO`

- ID: `JULIA-BACKEND-PARITY.2`
  Status: `active`
  Goal: Implement the Julia `.spec` frontend.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `JULIA-BACKEND-PARITY.2.1`
  Status: `done`
  Goal: Define Julia AST/data types for `.spec` files, rules, modes, body elements, edges, lifecycles, source spans,
    parse jobs, and function definitions.
  Acceptance: Types project to JSON where needed for diagnostics/corpus tooling, and field names match the
    Rust/Dart/mdBook contract.
  Verification: `PASS` - `Pkg.test()` covers JSON round-trip over source spans, staged parse jobs, function
    definitions, rule modes, body elements, action/blind edges, and spec files.
  Commit: `JULIA-BACKEND-PARITY.2.1 - define Julia frontend AST data types`

- ID: `JULIA-BACKEND-PARITY.2.2`
  Status: `done`
  Goal: Parse `.spec` rule paragraphs, headers, regex slots, lifecycle blocks, action/blind-call edges, fluent
    continuations, markers, comments, and block boundaries.
  Acceptance: Parser fixtures cover the formal grammar and the shipped-spec shapes used by the corpus.
  Verification: `PASS` - `Pkg.test()` covers focused parser fixtures, all 21 checked-in `specs/*.spec` files, and
    rule-only corpus `input.spec` files while skipping top-level function shells for `.2.4`.
  Commit: `JULIA-BACKEND-PARITY.2.2 - add Julia source spec parser`

- ID: `JULIA-BACKEND-PARITY.2.3`
  Status: `pending`
  Goal: Implement frontend validation and strict syntax behavior.
  Acceptance: Validation rejects duplicate labels/functions, mixed edge families, undefined references, malformed
    regexes, malformed helper/function definitions, and strict-syntax warnings as documented.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.2.4`
  Status: `pending`
  Goal: Integrate `specs/user_function_definition.spec` as the function-definition shell owner.
  Acceptance: Julia consumes the spec-defined `function_definition` / `function_definition_error` AST shape and
    does not maintain a competing host-language raw scanner as the semantic contract.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.3`
  Status: `pending`
  Goal: Implement helper/action AST, contract resolution, user-function registry, and compiled-state construction.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

- ID: `JULIA-BACKEND-PARITY.3.1`
  Status: `pending`
  Goal: Parse helper/action source into typed expression and statement AST nodes.
  Acceptance: Calls, literals, variables, direct/nested access, shape literals, assignments, block values,
    structured controls, receiver chains, trailing blocks, and standalone value-drop statements are structural AST
    nodes, not text rewrites.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.3.2`
  Status: `pending`
  Goal: Map helper/action AST to canonical helper contracts and diagnostics.
  Acceptance: Current helper/control families resolve through typed nodes; non-current helper-looking calls
    diagnose generically instead of falling back to host-language calls or Julia spellings.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.3.3`
  Status: `pending`
  Goal: Build the function registry and staged function-body parse-job records.
  Acceptance: Function definitions preserve params, arity, source/body spans, `body_payload`, `body_parse_job`, and
    stitched `body_ast`, with exact-arity resolution before helper fallback.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.3.4`
  Status: `pending`
  Goal: Compile parsed specs into a Julia compiled-spec/interpreter model.
  Acceptance: Compiled state has ordered rules, dependency-regex data, function registry, lifecycle/action AST
    payloads, mode metadata, and descriptor projection equivalent to the mdBook model.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4`
  Status: `pending`
  Goal: Implement the Julia runtime interpreter and helper/value semantics.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`, `.4.5`

- ID: `JULIA-BACKEND-PARITY.4.1`
  Status: `pending`
  Goal: Implement regex matching and match-state tracking.
  Acceptance: Seek/consume modes, alternative identity, capture groups, named captures, char offsets, cursor
    position, entry/local match separation, and zero-progress detection match the contract.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.2`
  Status: `pending`
  Goal: Implement first executable rule dispatch over compiled state.
  Acceptance: Default, AND, OR, and repetition modes execute with lifecycle order, action-edge/blind-call child
    dispatch, explicit return behavior, accumulators, recursion guards, and output shape parity.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.3`
  Status: `pending`
  Goal: Implement helper/value runtime families in safe batches.
  Acceptance: Core value/store/capture helpers, string/number helpers, array helpers, hash helpers,
    expression-valued blocks, structured controls, `with` trailing blocks, and tree traversal callbacks either pass
    focused tests or are split into narrower leaves before code.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.4`
  Status: `pending`
  Goal: Implement explicit cursor controls, boundary capture, parse-mode cursor behavior, and deterministic safety
    limits.
  Acceptance: `save_cursor()` / `restore_cursor()`, `rewind_match_start()` / `rewind_entry_start()`, and
    `capture_until_boundary(rule[, ...])` behave like Perl/Rust/Dart and affect only documented cursor state.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.5`
  Status: `pending`
  Goal: Implement runtime diagnostics and trace controls.
  Acceptance: Julia exposes default-quiet trace controls, event classes, sink behavior, branch/lifecycle trace
    points, and structured errors equivalent to the documented cross-variant trace contract.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.5`
  Status: `pending`
  Goal: Implement staged parser registry and user-function runtime parity.
  Children: `.5.1`, `.5.2`, `.5.3`

- ID: `JULIA-BACKEND-PARITY.5.1`
  Status: `pending`
  Goal: Implement the minimal staged registry provider for function-body parse jobs.
  Acceptance: `actionir-body.spec` resolves deterministically, compiles top rule `action_block`, executes queued
    jobs in stable order, and stitches `body_ast`.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.5.2`
  Status: `pending`
  Goal: Execute registered user functions in value positions, receiver chains, and standalone discard.
  Acceptance: Exact-arity functions use fresh function-local stores, eager argument evaluation, compatible receiver
    continuation, standalone `VALUE_DROP`, and recursion diagnostics.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.5.3`
  Status: `pending`
  Goal: Preserve staged parse-job and function-registry descriptor shapes.
  Acceptance: Descriptor/corpus fixtures can assert the neutral function-definition payload, parse-job, and
    stitched AST fields without Julia-specific field drift.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.6`
  Status: `pending`
  Goal: Prove Julia parity against the corpus and cross-backend gates.
  Children: `.6.1`, `.6.2`, `.6.3`, `.6.4`

- ID: `JULIA-BACKEND-PARITY.6.1`
  Status: `pending`
  Goal: Bring up controlled proof fixtures.
  Acceptance: Minimal authored fixtures prove scalar output, nested arrays/hashes, rule dispatch, lifecycle return
    shape, function calls, trace/diagnostic basics, and boundary capture before shipped-spec breadth.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.6.2`
  Status: `pending`
  Goal: Expand to the current manifest in recoverable corpus batches.
  Acceptance: Each batch either passes on Julia or records a narrowly owned root-cause leaf with Perl/Rust/Dart
    oracle evidence; no fixture is weakened to fit Julia.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.6.3`
  Status: `pending`
  Goal: Finalize manifest drift guard and full Julia corpus gate.
  Acceptance: Julia runner rejects unsupported manifest format, mismatched counts, invalid/duplicate names, missing
    fixture dirs, stale extra dirs, and output mismatches; all current fixtures pass.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.6.4`
  Status: `pending`
  Goal: Wire Julia parity into the local verification story.
  Acceptance: Focused Julia test commands are documented; broader local gate integration is added only when
    reliable and not dependent on absent local SDK state.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.7`
  Status: `pending`
  Goal: Close documentation, generated-source follow-up, and handoff alignment.
  Children: `.7.1`, `.7.2`, `.7.3`

- ID: `JULIA-BACKEND-PARITY.7.1`
  Status: `pending`
  Goal: Document Julia backend usage, status, and parity boundaries in the mdBook.
  Acceptance: Book pages explain how to run Julia, what parity gate it satisfies, and any remaining limitations in
    variant-neutral terms.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.7.2`
  Status: `pending`
  Goal: Decide generated Julia source as a post-interpreter proof lane.
  Acceptance: Generated Julia source is either implemented against the already-green interpreter model or
    deliberately deferred with clear prerequisites; it is not the primary parity gate.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.7.3`
  Status: `pending`
  Goal: Final no-drift closeout for Julia parity.
  Acceptance: Roadmaps, task-tree index, live docs, mdBook, Knowledge Map, architecture snapshot, and verification
    commands agree that Julia reaches the accepted scoped milestone.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `JULIA-BACKEND-PARITY.2.3` | `pending` | Validate parsed source ASTs before helper/action lowering or runtime behavior. |

## `JULIA-BACKEND-PARITY.1.1` Preflight Result

Toolchain evidence recorded on 2026-07-10:

- `command -v julia` -> `/opt/homebrew/bin/julia`
- `julia --version` -> `julia version 1.12.6`
- Official Julia manual downloads page current stable release: `v1.12.6 (April 9, 2026)`.
- `brew list --versions julia` -> `julia 1.12.6`
- `brew list --cask --versions julia` -> no installed cask entry.
- `/opt/homebrew/bin/julia` is a Homebrew symlink to `../Cellar/julia/1.12.6/bin/julia`.
- `command -v juliaup` -> absent locally.
- `command -v julia-lsp` -> absent locally.
- Plain `import Pkg` / `import Test` tried to precompile into `~/.julia/compiled/v1.12` and failed under the
  managed harness with `EPERM`. With a writable depot, the same standard-library imports pass:
  `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --startup-file=no --history-file=no
  -e 'import Pkg; import Test; println("Pkg+Test available")'`.
- `JuliaFormatter` is not installed in the current global Julia environment.
- `JET` is not installed in the current global Julia environment.

Repository-owned package scaffold created in `.1.2`:

```text
julia/
  Project.toml
  Manifest.toml
  README.md
  src/LinkedSpecJulia.jl
  src/cli/LinkedSpecJuliaCli.jl
  src/corpus/CorpusManifest.jl
  bin/linkedspec_julia.jl
  bin/corpus_runner.jl
  test/runtests.jl
```

Planned future implementation subtrees remain deferred to later leaves: `src/spec/`, `src/action/`, `src/compiler/`,
and `src/runtime/`.

Current command surface:

- Package manager / dependency setup: `julia --project=julia -e 'import Pkg; Pkg.instantiate()'`
- Tests: `julia --project=julia -e 'import Pkg; Pkg.test()'`
- Julia-specific CLI: `julia --project=julia julia/bin/linkedspec_julia.jl --help`
- Julia-specific CLI status: `julia --project=julia julia/bin/linkedspec_julia.jl status`
- Julia-specific CLI corpus validation: `julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus
  rust/linkedspec-runtime/tests/corpus`
- Corpus runner validation: `julia --project=julia julia/bin/corpus_runner.jl --corpus
  rust/linkedspec-runtime/tests/corpus`
- Future executable corpus command: `julia --project=julia julia/bin/corpus_runner.jl --corpus
  rust/linkedspec-runtime/tests/corpus --execute`
- Formatter, if `JuliaFormatter` becomes a committed dev dependency or local tool: `julia --project=julia -e
  'using JuliaFormatter; format("julia")'`
- Static analysis, if `JET` becomes a committed dev dependency or local tool: `julia --project=julia -e
  'using JET; JET.test_package("LinkedSpecJulia")'`

The harness-friendly form of Julia commands can set `JULIA_DEPOT_PATH` to a writable directory such as
`/private/tmp/linkedspec-julia-depot` when the default home depot is not writable. That is a local execution
constraint, not a project dependency or a checked-in artifact.

## `JULIA-BACKEND-PARITY.1.3` Corpus Manifest IO Result

Corpus IO evidence recorded on 2026-07-10:

- `julia/Project.toml` now depends on `JSON3 = "1.14.3"` for manifest and expected-JSON parsing; the committed
  `julia/Manifest.toml` locks JSON3 and transitive dependencies.
- `load_corpus_fixtures(path)` checks that the corpus directory exists, loads `manifest.json`, requires format `1`,
  verifies `case_count`, validates case names, rejects duplicates, detects missing/stale fixture directories, and
  loads each fixture's `input.spec`, `input.txt`, and `expected.json`.
- Expected JSON is decoded into plain Julia arrays/dictionaries/scalars for later parser/runtime comparison.
- `julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus` and
  `julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus` now report format `1` and `99`
  fixtures after validation.
- `--execute` remains deliberately rejected until later parser/runtime leaves implement execution.

## `JULIA-BACKEND-PARITY.2.1` Source AST Data Result

Source AST evidence recorded on 2026-07-10:

- `julia/src/spec/Ast.jl` defines the Julia data model for parsed `.spec` source: `SpecFile`,
  `FunctionDefinition`, `SourceSpan`, `StagedSourceSpan`, `StagedParseJob`, `Rule`, `RuleHeader`, `RuleMode`,
  body element variants, `EdgeTarget`, and `FluentCall`.
- The JSON projection uses the same neutral field names used by Rust, Dart, and the mdBook contract, including
  `functions`, `rules`, `source_span`, `body_span`, `body_parse_job`, `line_start`, `line_end`,
  `parent_ast_path`, `result_policy`, and `failure_policy`.
- `RuleMode` helpers cover default, bounded AND, and bounded OR modes with repetition metadata accessors.
- `top_rule(spec)` and `find_rule(spec, label)` provide data-only AST lookup helpers for later parser/compiler
  leaves.
- Parser behavior is still deliberately absent. `.2.2` owns parsing `.spec` rule paragraphs into these types.

## `JULIA-BACKEND-PARITY.2.2` Source Parser Result

Source parser evidence recorded on 2026-07-10:

- `julia/src/spec/Parser.jl` adds `parse_spec(source)` and `SpecParseException`.
- The parser produces the `.2.1` source AST types for rule headers/modes, inline and body regex slots, lifecycle
  blocks, action edges, blind-call edges, fluent chains, split markers, conditional markers, plain blocks, raw
  fallback lines, and nested block boundaries.
- Action-edge fluent continuation lines are attached to the preceding action edge, matching the Dart parser
  boundary.
- Focused tests cover mode suffixes, bounded modes, inline body elements, regex literals, action/blind edges,
  grouped/indexed targets, attached `when`/`otherwise` blocks, compact lifecycle fluent chains, multiline fluent
  arguments, quoted braces inside code blocks, raw fallback lines, and pre-rule function definition rejection.
- Parser smoke tests cover all 21 checked-in `specs/*.spec` files plus rule-only corpus `input.spec` files. Top-level
  `fn` corpus shells remain intentionally skipped until `.2.4` consumes `specs/user_function_definition.spec`.

## Decisions

- `2026-07-09`: Julia follows Dart in the ADR `0021` backend rollout order. `FUTURE-PARITY-BACKLOG.1.2`
  delegates executable Julia work to this tree after `DART-BACKEND-PARITY.7.5` closes the scoped Dart milestone.
- `2026-07-09`: Julia starts interpreter-first, reusing the Dart lesson that generated source is a proof lane after
  typed frontend, compiled state, runtime interpreter, and corpus parity are green.
- `2026-07-09`: Julia must own a distinct variant-specific CLI entrypoint from the beginning of package planning.
  The `.1.1` preflight selects `julia/bin/linkedspec_julia.jl` as the Julia-specific LinkedSpec CLI and
  `julia/bin/corpus_runner.jl` as the corpus-runner entrypoint.
- `2026-07-09`: The Rust corpus under `rust/linkedspec-runtime/tests/corpus/` remains the checked-in
  language-neutral corpus root until a separate backend-neutral corpus relocation is adopted.
- `2026-07-10`: Julia `1.12.6` is both the locally installed Homebrew version and the current stable release listed
  on the official Julia manual downloads page. No Julia installation or upgrade is needed for `.1.2`.
- `2026-07-10`: `.1.2` commits `julia/Manifest.toml` because `Pkg.instantiate()` writes it and the tiny manifest
  records only the local `LinkedSpecJulia` package with no external dependency state. This avoids unpublished local
  state while the package has only the stdlib `Test` target.
- `2026-07-10`: `.1.3` adds the committed JSON dependency `JSON3` instead of hand-rolling JSON parsing. Manifest
  IO must validate the shared corpus format and expected JSON syntax before parser/runtime semantics exist.
- `2026-07-10`: `.2.1` mirrors the Rust/Dart/mdBook parsed-source contract in Julia data types and JSON field
  names before implementing any text parser. The parser leaf `.2.2` must produce this data model rather than
  introducing a competing Julia-only AST shape.
- `2026-07-10`: `.2.2` follows the Dart source-parser boundary for core rule parsing. It deliberately does not add
  frontend validation, function-shell projection, helper/action parsing, compilation, runtime execution, or corpus
  `--execute`.

## Open Questions

- Whether `JuliaFormatter` and `JET` should be committed as Julia dev dependencies is left to a future scaffold or
  verification leaf. They are not available globally in the local Julia environment today.
- Whether generated Julia source is useful remains deferred to `.7.2`; it is not a blocker for interpreter-first
  parity.

## Blockers

- None for `.2.3`. Julia now parses source into the AST model; frontend validation is the next owned boundary.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `JULIA-BACKEND-PARITY` | Created under `FUTURE-PARITY-BACKLOG.1.2`; parent leaf ran mdBook, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, stale handoff/frontier scan, and `git diff --check`. | PASS. Planning only; no Julia package or implementation code exists yet. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.1.1` | `command -v julia`; `julia --version`; official Julia downloads page stable-release check; `brew list --versions julia`; `brew list --cask --versions julia`; `/opt/homebrew/bin/julia --startup-file=no --history-file=no -e 'println(VERSION)'`; `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --startup-file=no --history-file=no -e 'import Pkg; import Test; println("Pkg+Test available")'`; optional `JuliaFormatter` and `JET` import probes. | PASS for Julia/Homebrew version, `Pkg`, and `Test`; `JuliaFormatter` and `JET` are absent optional tools. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.1.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.instantiate()'`; `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; `julia --project=julia julia/bin/linkedspec_julia.jl --help`; `julia --project=julia julia/bin/linkedspec_julia.jl status`; `julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus`; `julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus`; `git diff --check`; memory architecture, task-tree metadata, Knowledge Map, doctrine, and mdBook checks. | PASS. Initial fresh-depot registry access needed approved network once; the committed manifest records only the local package, and the scaffold still deliberately rejects `--execute`. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.1.3` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.instantiate()'`; `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; `julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus`; `julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus`; `julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute` returns code `2`; `git diff --check`; memory architecture, task-tree metadata, Knowledge Map, doctrine, and mdBook checks. | PASS. Julia validates the 99-fixture manifest and drift/file/JSON guards without parser/runtime execution; `--execute` remains unavailable. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.2.1` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia source AST/data types round-trip through JSON over spec files, function definitions, staged parse jobs, rule modes, body elements, edges, and fluent calls. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.2.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia source parser tests cover focused syntax fixtures, all 21 checked-in specs, and rule-only corpus specs; total Julia tests pass. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `JULIA-BACKEND-PARITY` | `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan` | Tree created by the backlog scoping leaf; implementation commits use `JULIA-BACKEND-PARITY.*` leaf ids. |
| `JULIA-BACKEND-PARITY.1.1` | `JULIA-BACKEND-PARITY.1.1 - verify Julia toolchain preflight` | Toolchain/package-layout preflight; no Julia source scaffold yet. |
| `JULIA-BACKEND-PARITY.1.2` | `JULIA-BACKEND-PARITY.1.2 - scaffold Julia package` | Minimal Julia package, command stubs, scaffold tests, and docs; no parser/runtime semantics yet. |
| `JULIA-BACKEND-PARITY.1.3` | `JULIA-BACKEND-PARITY.1.3 - add Julia corpus manifest IO` | Manifest IO/drift guard scaffold; `.1` foundation container closes. |
| `JULIA-BACKEND-PARITY.2.1` | `JULIA-BACKEND-PARITY.2.1 - define Julia frontend AST data types` | Source AST/data model and JSON projection; parser implementation advances to `.2.2`. |
| `JULIA-BACKEND-PARITY.2.2` | `JULIA-BACKEND-PARITY.2.2 - add Julia source spec parser` | Source parser for rule paragraphs and shipped-spec/corpus parser smoke; validation advances to `.2.3`. |

## Changelog

- `2026-07-10`: Completed `.2.2` source parser. `julia/src/spec/Parser.jl` now parses core `.spec` rule
  paragraphs into the `.2.1` AST types, including headers/modes, regex slots, lifecycle blocks, action/blind-call
  edges, fluent continuations, markers, comments, and block boundaries. `Pkg.test()` covers focused parser fixtures,
  all checked-in specs, and rule-only corpus specs. `.2.3` owns validation and strict syntax behavior.
- `2026-07-10`: Completed `.2.1` source AST/data types. `julia/src/spec/Ast.jl` now defines Julia data records
  and JSON projection for spec files, functions, source spans, staged parse jobs, rule headers/modes, body element
  variants, edge targets, and fluent calls. `Pkg.test()` covers the JSON round-trip; `.2.2` owns parsing `.spec`
  text into these types.
- `2026-07-10`: Completed `.1.3` manifest IO. Julia now uses JSON3 to load the manifest-backed 99-fixture corpus,
  validate manifest shape, detect missing/stale fixture directories, require `input.spec` / `input.txt` /
  `expected.json`, decode expected JSON, and report validated fixture count through the CLI/corpus runner. `.1`
  foundation is closed; active frontier advances to `.2.1` AST/data types.
- `2026-07-10`: Completed `.1.2` scaffold. `julia/` now has `Project.toml`, committed `Manifest.toml`,
  `src/LinkedSpecJulia.jl`, CLI/corpus modules, `bin/linkedspec_julia.jl`, `bin/corpus_runner.jl`, README
  commands, and a smoke test. `Pkg.instantiate()`, `Pkg.test()`, Julia-specific CLI help/status, and corpus-runner
  scaffold commands pass with a writable depot. `.1.3` owns manifest-backed corpus IO and drift detection.
- `2026-07-10`: Completed `.1.1` preflight. Julia `1.12.6` is available through Homebrew and matches the official
  current stable release; the repo-owned `julia/` package layout, package/test commands, Julia-specific CLI,
  corpus-runner entrypoint, optional formatter/linter commands, and writable-depot harness note are recorded.
- `2026-07-09`: Created the Julia backend parity task tree and selected an interpreter-first parity path after the
  closed Dart scoped milestone.
