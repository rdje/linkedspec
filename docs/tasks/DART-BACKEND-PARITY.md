# DART-BACKEND-PARITY: Dart LinkedSpec Backend Parity

## Metadata

- Tree ID: `DART-BACKEND-PARITY`
- Status: `active`
- Roadmap lane: `Overall roadmap - future backend parity (Dart first)`
- Created: `2026-07-09`
- Last updated: `2026-07-09`
- Owner: repo-local workflow

## Goal

Implement a Dart LinkedSpec backend that consumes the same `.spec` files as the Perl
reference backend and the Rust backend, with full behavioral parity against the language-neutral
corpus and the mdBook contract. This tree is the Dart lane delegated by
`FUTURE-PARITY-BACKLOG.1.1`.

## Non-Goals

- Do not implement Julia or Lua in this tree.
- Do not create Dart-only `.spec` syntax, helper names, runtime semantics, or corpus fixtures.
- Do not copy the Perl plugin/runtime compatibility branch as part of the backend-neutral contract.
- Do not start with generated Dart source as the primary parity strategy; generated Dart source is a
  later proof lane after interpreter parity unless a future leaf explicitly supersedes that decision.
- Do not broaden the `.spec` language while implementing Dart parity; language changes need their own
  task-tree leaves and cross-backend locks.

## Acceptance Criteria

- A Dart workspace/package lives under repo ownership and can be built and tested locally.
- The Dart frontend parses the documented `.spec` grammar and validates the same source-shape
  contracts as the Perl and Rust backends.
- Helper/action language text is parsed into typed AST/IR nodes before lowering or interpretation.
- Dart compiles parsed `.spec` input into a typed compiled-spec/interpreter model equivalent to the
  Rust `CompiledSpec` contract and the mdBook compiled-state model.
- Runtime behavior matches the runtime-semantics appendix: parse modes, lifecycle order, accumulators,
  BACKTRACK, dispatch, repetition bounds, output shape, diagnostics, and determinism.
- The regex engine provides position-tracked seek/consume matching, capture groups, named captures,
  and matched-alternative identity without relying on Perl embedded-code regex behavior.
- Staged parser registry, user-function registry, function-body parse jobs, and trace controls match
  the documented external contracts.
- A Dart corpus runner consumes `rust/linkedspec-runtime/tests/corpus/manifest.json`, rejects manifest
  drift, and passes all current fixtures against the Perl-reference expected values.
- mdBook, live docs, task-tree status, and Knowledge Map cards stay aligned with the implemented Dart
  surface after every slice.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `DART-BACKEND-PARITY`
  Status: `active`
  Goal: Implement Dart as the first future full-parity LinkedSpec backend.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `DART-BACKEND-PARITY.1`
  Status: `active`
  Goal: Establish Dart toolchain, workspace, and parity harness foundations before parser code.
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `DART-BACKEND-PARITY.1.1`
  Status: `done`
  Goal: Verify local Dart toolchain availability and define the repository-owned Dart package layout.
  Acceptance: Record the exact Dart SDK/tool commands available locally, or record a real blocker if
    no Dart SDK is available; define the intended `dart/` package layout, test command, formatter
    command, and corpus-runner entrypoint before source implementation.
  Verification: **PASS 2026-07-09.** `/opt/homebrew/bin/dart` is available; `dart --version`
    reports Dart SDK `3.9.2 (stable)` on `macos_arm64`; `flutter` is not installed and is non-blocking
    for this CLI/library backend. `dart --disable-analytics` needed one approved user-home write because
    the SDK initializes `~/.dart-tool`; after that, `dart help format`, `dart help analyze`,
    `dart help test`, `dart pub --help`, and `dart create --help` run cleanly in the workspace.
    Package layout and commands are recorded below. No Dart package files were created.
  Commit: `DART-BACKEND-PARITY.1.1 - record Dart toolchain and layout`

- ID: `DART-BACKEND-PARITY.1.2`
  Status: `done`
  Goal: Create the minimal Dart package scaffold and CI-facing smoke test.
  Acceptance: `dart/` has package metadata, library/test entrypoints, a no-op smoke test, documented
    commands, and no dependency on unpublished local state.
  Verification: **PASS 2026-07-09.** `dart/` has package metadata, committed `pubspec.lock`, strict
    analyzer options, README, public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint,
    and a `package:test` smoke test. `dart pub get`, `dart format --set-exit-if-changed .`,
    `dart analyze --fatal-infos --fatal-warnings`, `dart test`, `dart run bin/linkedspec_dart.dart --help`,
    and `dart run bin/corpus_runner.dart --help` pass. Pub dependency download and analyzer state initialization
    required approved out-of-sandbox access. Repository gates pass after Knowledge Map regeneration.
    Parser/runtime/corpus semantics remain deferred.
  Commit: `DART-BACKEND-PARITY.1.2 - create Dart scaffold smoke package`

- ID: `DART-BACKEND-PARITY.1.3`
  Status: `pending`
  Goal: Add corpus-fixture IO scaffolding without executing parser semantics yet.
  Acceptance: Dart can load the manifest-backed corpus directory, validate manifest shape, and detect
    missing/stale fixture directories before any `.spec` runtime is implemented.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.2`
  Status: `pending`
  Goal: Implement the Dart `.spec` frontend.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `DART-BACKEND-PARITY.2.1`
  Status: `pending`
  Goal: Define Dart AST/data types for `.spec` files, rules, modes, body elements, edges, lifecycles,
    source spans, parse jobs, and function definitions.
  Acceptance: Types round-trip through JSON where needed for diagnostics/corpus tooling, and field
    names match the mdBook/compiled-state contract.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.2.2`
  Status: `pending`
  Goal: Parse `.spec` rule paragraphs, headers, regex slots, lifecycle blocks, action/blind-call edges,
    fluent continuations, markers, comments, and block boundaries.
  Acceptance: Parser fixtures cover the formal grammar and the shipped-spec shapes used by the corpus.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.2.3`
  Status: `pending`
  Goal: Implement frontend validation and strict syntax behavior.
  Acceptance: Validation rejects duplicate labels/functions, mixed edge families, undefined references,
    malformed regexes, malformed helper/function definitions, and strict-syntax warnings as documented.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.2.4`
  Status: `pending`
  Goal: Integrate `specs/user_function_definition.spec` as the function-definition shell owner.
  Acceptance: Dart consumes the spec-defined function-definition AST shape and does not maintain a
    competing host-language raw scanner as the semantic contract.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.3`
  Status: `pending`
  Goal: Implement helper/action AST and compiled-state construction.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

- ID: `DART-BACKEND-PARITY.3.1`
  Status: `pending`
  Goal: Parse helper/action source into typed expression and statement AST nodes.
  Acceptance: Calls, literals, variables, direct/nested access, shape literals, assignments, block
    values, attached control flow, receiver chains, and standalone value-drop statements are structural
    AST nodes, not text rewrites.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.3.2`
  Status: `pending`
  Goal: Map helper/action AST to canonical helper contracts and diagnostics.
  Acceptance: Supported helper families resolve through typed nodes; unknown/retired helpers diagnose
    instead of falling back to host-language calls.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.3.3`
  Status: `pending`
  Goal: Build the function registry and staged function-body parse-job records.
  Acceptance: Function definitions preserve params, arity, source/body spans, `body_payload`,
    `body_parse_job`, and stitched `body_ast`, with exact-arity resolution before helper fallback.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.3.4`
  Status: `pending`
  Goal: Compile parsed specs into a Dart compiled-spec/interpreter model.
  Acceptance: Compiled state has ordered rules, dependency-regex data, function registry, lifecycle/action
    AST payloads, mode metadata, and descriptor projection equivalent to the mdBook model.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.4`
  Status: `pending`
  Goal: Implement the Dart runtime interpreter.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`, `.4.5`

- ID: `DART-BACKEND-PARITY.4.1`
  Status: `pending`
  Goal: Implement regex matching and match-state tracking.
  Acceptance: Seek/consume modes, alternative identity, capture groups, named captures, char offsets,
    cursor position, entry/local match separation, and zero-progress detection match the contract.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.4.2`
  Status: `pending`
  Goal: Implement rule dispatch, rule modes, recursion guards, repetition bounds, and lifecycle order.
  Acceptance: Default/AND/OR/REP families, action and blind-call edges, `I/LS/LE/E/EX/IT/LX`, `retv`,
    accumulator collection, and explicit returns match Perl/Rust parity fixtures.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.4.3`
  Status: `pending`
  Goal: Implement runtime value model and helper families.
  Acceptance: Scalars, arrays, hashes, booleans, numbers, null/undef, value blocks, mutation helpers,
    receiver chains, tree traversal helpers, capture/mark helpers, and string/number/hash/array families
    match the helper catalog.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.4.4`
  Status: `pending`
  Goal: Implement BACKTRACK, parse-mode cursor behavior, and deterministic safety limits.
  Acceptance: BACKTRACK/IBACKTRACK rewinds only local cursor state, loops enforce documented safety, and
    deterministic order is maintained for hash views and dispatch decisions.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.4.5`
  Status: `pending`
  Goal: Implement runtime diagnostics and trace controls.
  Acceptance: Dart exposes default-quiet trace controls, event classes, sink behavior, branch/lifecycle
    trace points, and structured errors equivalent to the documented cross-variant trace contract.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.5`
  Status: `pending`
  Goal: Implement staged parser registry and user-function runtime parity.
  Children: `.5.1`, `.5.2`, `.5.3`

- ID: `DART-BACKEND-PARITY.5.1`
  Status: `pending`
  Goal: Implement minimal staged registry provider for function-body parse jobs.
  Acceptance: `actionir-body.spec` resolves deterministically, compiles top rule `action_block`, executes
    queued jobs in stable order, and stitches `body_ast`.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.5.2`
  Status: `pending`
  Goal: Execute registered user functions in value positions, receiver chains, and standalone discard.
  Acceptance: Exact-arity functions use fresh function-local stores, eager argument evaluation, compatible
    receiver continuation, standalone `VALUE_DROP`, and recursion diagnostics.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.5.3`
  Status: `pending`
  Goal: Preserve staged parse-job and function-registry descriptor shapes.
  Acceptance: Descriptor/corpus fixtures can assert the neutral function-definition payload, parse-job,
    and stitched AST fields without Dart-specific field drift.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.6`
  Status: `pending`
  Goal: Prove Dart parity against the corpus and cross-backend gates.
  Children: `.6.1`, `.6.2`, `.6.3`, `.6.4`

- ID: `DART-BACKEND-PARITY.6.1`
  Status: `pending`
  Goal: Bring up controlled proof fixtures.
  Acceptance: Minimal authored fixtures prove scalar output, nested arrays/hashes, rule dispatch, and
    lifecycle return shape before shipped-spec breadth.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.6.2`
  Status: `pending`
  Goal: Expand to the current 99-fixture manifest in safe batches.
  Acceptance: Each batch either passes on Dart or records a narrowly owned root-cause leaf with Perl/Rust
    oracle evidence; no fixture is weakened to fit Dart.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.6.3`
  Status: `pending`
  Goal: Finalize manifest drift guard and full Dart corpus gate.
  Acceptance: Dart runner rejects unsupported manifest format, mismatched counts, invalid/duplicate names,
    missing fixture dirs, stale extra dirs, and output mismatches; all current fixtures pass.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.6.4`
  Status: `pending`
  Goal: Wire Dart parity into the local verification story.
  Acceptance: Focused Dart test commands are documented; broader local gate integration is added only when
    reliable and not dependent on absent local SDK state.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.7`
  Status: `pending`
  Goal: Close documentation, generated-source follow-up, and handoff alignment.
  Children: `.7.1`, `.7.2`, `.7.3`

- ID: `DART-BACKEND-PARITY.7.1`
  Status: `pending`
  Goal: Document Dart backend usage, status, and parity boundaries in the mdBook.
  Acceptance: Book pages explain how to run Dart, what parity gate it satisfies, and any remaining
    limitations in variant-neutral terms.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.7.2`
  Status: `pending`
  Goal: Decide and optionally implement generated Dart source as a post-interpreter proof.
  Acceptance: Generated Dart source is either implemented against the already-green interpreter model or
    deliberately deferred with clear blockers; it is not the primary parity gate.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.7.3`
  Status: `pending`
  Goal: Final no-drift closeout for Dart parity.
  Acceptance: Roadmaps, task-tree index, live docs, mdBook, Knowledge Map, architecture snapshot, and
    verification commands agree that Dart reaches the accepted scoped milestone.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DART-BACKEND-PARITY.1.3` | `pending` | Package scaffold exists; add manifest/corpus IO scaffolding before parser semantics. |

## Dart Toolchain And Package Layout

- SDK command: `/opt/homebrew/bin/dart`
- SDK version: `Dart SDK version: 3.9.2 (stable) (Wed Aug 27 03:49:40 2025 -0700) on "macos_arm64"`
- Flutter: not installed; non-blocking because this backend starts as a Dart CLI/library backend, not a
  Flutter/mobile integration.
- One-time local SDK initialization: `dart --disable-analytics` creates user-level SDK analytics config.
  This required approved execution outside the workspace sandbox because the SDK writes `~/.dart-tool`.

Package root: `dart/` (created by `DART-BACKEND-PARITY.1.2`)

```text
dart/
  pubspec.yaml
  analysis_options.yaml
  README.md
  bin/
    linkedspec_dart.dart
    corpus_runner.dart
  lib/
    linkedspec_dart.dart
    src/
      ast/
        spec_ast.dart
        action_ast.dart
      compiler/
        compiled_spec.dart
        compiler.dart
      corpus/
        manifest_runner.dart
      parser/
        spec_parser.dart
        action_parser.dart
      runtime/
        engine.dart
        helpers.dart
        regex_engine.dart
        staged_parser_registry.dart
        values.dart
      trace/
        trace.dart
  test/
    smoke_test.dart
    corpus_manifest_test.dart
```

Planned commands:

- Create scaffold: `dart create --template package --no-pub dart` or an equivalent hand-curated package
  layout that avoids generated noise.
- Fetch dependencies after the package exists: `cd dart && dart pub get`.
- Format check: `cd dart && dart format --set-exit-if-changed .`.
- Analyze: `cd dart && dart analyze --fatal-infos --fatal-warnings`.
- Test: `cd dart && dart test`.
- Corpus runner entrypoint: `cd dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`.
- CLI smoke entrypoint: `cd dart && dart run bin/linkedspec_dart.dart --help`.

The package name should be `linkedspec_dart`. Initial dependencies should stay minimal:
`args` for CLI parsing if needed, `test` as a dev dependency, and a lints package only if the scaffold
requires one. Any dependency download belongs to `.1.2`, not this preflight leaf.

The `.1.2` scaffold intentionally implements no parser, runtime, or corpus semantics yet. It includes:

- `pubspec.yaml` with the hosted `test` dev dependency only.
- Committed `pubspec.lock` for reproducible local package checks.
- `analysis_options.yaml` with strict analyzer language settings and generated-output excludes.
- `README.md` documenting local Dart commands and current boundaries.
- `lib/linkedspec_dart.dart` plus `lib/src/scaffold.dart` as the public scaffold API.
- `bin/linkedspec_dart.dart` and `bin/corpus_runner.dart` as help-capable scaffold entrypoints.
- `test/smoke_test.dart` as the first CI-facing Dart smoke test.
- Root `.gitignore` entries for `dart/.dart_tool/`, `dart/.packages`, and `dart/build/`.

## Decisions

- `2026-07-09`: Dart starts interpreter-first. The primary parity path is
  `.spec` parser -> typed helper/action AST -> compiled-spec state -> Dart runtime interpreter -> manifest-backed
  corpus runner. Generated Dart source is deferred to `.7.2` after interpreter parity because the Rust interpreter
  is the current full-corpus gate, HandlerIR lifecycle slots still document Perl-string coupling, and text-to-AST
  is the conformance doctrine for new backends.
- `2026-07-09`: The Rust corpus under `rust/linkedspec-runtime/tests/corpus/` remains the source of language-neutral
  fixture truth until a backend-neutral corpus directory is separately adopted.
- `2026-07-09`: Dart package layout starts as a CLI/library package under `dart/`; Flutter is not required for
  the backend implementation path.
- `2026-07-09`: The initial Dart package commits `pubspec.lock` because this repo owns a non-published
  CLI/library backend package. Generated Dart tool state stays ignored under `dart/.dart_tool/`.

## Open Questions

- None blocking `.1.3`. The package scaffold is green; manifest IO is next.

## Blockers

- None known before `.1.3` manifest IO scaffolding.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `DART-BACKEND-PARITY` | Plan created under `FUTURE-PARITY-BACKLOG.1.1`; `git diff --check`; memory architecture; Knowledge Map; doctrine; task-tree metadata; mdBook build; local CI. | PASS. Local CI includes phase0 `1..1028`; no Dart code yet. |
| `2026-07-09` | `DART-BACKEND-PARITY.1.1` | `command -v dart`; `dart --version`; `command -v flutter`; approved `dart --disable-analytics`; `dart help format`; `dart help analyze`; `dart help test`; `dart pub --help`; `dart create --help`; `git diff --check`; memory architecture; Knowledge Map; task-tree metadata; doctrine; mdBook build. | PASS. Dart SDK `3.9.2` is available; Flutter absent/non-blocking; layout and commands recorded; no Dart package files created. |
| `2026-07-09` | `DART-BACKEND-PARITY.1.2` | approved `dart pub get`; `dart format --set-exit-if-changed .`; approved `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. Scaffold package, lockfile, CLI stubs, corpus-runner stub, and smoke test are green; no parser/runtime/corpus semantics yet. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DART-BACKEND-PARITY` | `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan` | Tree created by the backlog scoping leaf; implementation commits use `DART-BACKEND-PARITY.*` leaf ids. |
| `DART-BACKEND-PARITY.1.1` | `DART-BACKEND-PARITY.1.1 - record Dart toolchain and layout` | Toolchain/layout preflight; no package files. |
| `DART-BACKEND-PARITY.1.2` | `DART-BACKEND-PARITY.1.2 - create Dart scaffold smoke package` | Minimal package scaffold; no parser/runtime/corpus semantics. |

## Changelog

- `2026-07-09`: Created the Dart backend parity task tree and selected an interpreter-first parity path.
- `2026-07-09`: Recorded Dart SDK `3.9.2`, CLI/library package layout, and planned commands; frontier advances
  to `.1.2` for scaffold creation.
- `2026-07-09`: Created the `dart/` scaffold package and smoke test; frontier advances to `.1.3` for
  corpus-fixture IO scaffolding.
