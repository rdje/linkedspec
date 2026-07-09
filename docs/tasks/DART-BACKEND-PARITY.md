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
  Status: `done`
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
  Status: `done`
  Goal: Add corpus-fixture IO scaffolding without executing parser semantics yet.
  Acceptance: Dart can load the manifest-backed corpus directory, validate manifest shape, and detect
    missing/stale fixture directories before any `.spec` runtime is implemented.
  Verification: **PASS 2026-07-09.** `loadCorpusFixtures(...)` loads the checked-in
    `rust/linkedspec-runtime/tests/corpus` manifest and 99 fixtures, validates manifest format/count/case
    names/duplicates, detects missing and stale fixture directories, requires `input.spec`, `input.txt`,
    and `expected.json`, and parses expected JSON without executing parser semantics. Dart format, analyze,
    tests, corpus-runner real-corpus load, and CLI help checks pass.
  Commit: `DART-BACKEND-PARITY.1.3 - add Dart corpus manifest IO scaffold`

- ID: `DART-BACKEND-PARITY.2`
  Status: `done`
  Goal: Implement the Dart `.spec` frontend.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `DART-BACKEND-PARITY.2.1`
  Status: `done`
  Goal: Define Dart AST/data types for `.spec` files, rules, modes, body elements, edges, lifecycles,
    source spans, parse jobs, and function definitions.
  Acceptance: Types round-trip through JSON where needed for diagnostics/corpus tooling, and field
    names match the mdBook/compiled-state contract.
  Verification: **PASS 2026-07-09.** `dart/lib/src/ast/spec_ast.dart` defines data-only types for
    `SpecFile`, `FunctionDefinition`, `SourceSpan`, `StagedParseJob`, `Rule`, `RuleHeader`, `RuleMode`,
    body-element variants, `EdgeTarget`, and `FluentCall`. `test/spec_ast_test.dart` proves JSON
    round-trips and Rust-equivalent `RuleMode` helper behavior. Dart format, analyze, tests, and CLI
    smoke checks pass.
  Commit: `DART-BACKEND-PARITY.2.1 - define Dart frontend AST data types`

- ID: `DART-BACKEND-PARITY.2.2`
  Status: `done`
  Goal: Parse `.spec` rule paragraphs, headers, regex slots, lifecycle blocks, action/blind-call edges,
    fluent continuations, markers, comments, and block boundaries.
  Acceptance: Parser fixtures cover the formal grammar and the shipped-spec shapes used by the corpus.
  Verification: **PASS 2026-07-09.** `dart/lib/src/parser/spec_parser.dart` implements `parseSpec(...)`
    and produces the source AST data types for rule paragraphs, headers/modes, header-rest bodies, regex
    literals, lifecycle blocks, action/blind-call edges, action-edge fluent continuations, receiver-fluent
    `when/otherwise` blocks, split/conditional markers, comments, raw fallback lines, and nested block
    boundaries. `test/spec_parser_test.dart` covers focused Rust-compatible parser seams, all checked-in
    `specs/*.spec`, and corpus `input.spec` files that do not start with top-level `fn` definitions.
    Strict validation remains `.2.3`; top-level function-shell integration remains `.2.4`.
  Commit: `DART-BACKEND-PARITY.2.2 - implement Dart spec parser`

- ID: `DART-BACKEND-PARITY.2.3`
  Status: `done`
  Goal: Implement frontend validation and strict syntax behavior.
  Acceptance: Validation rejects duplicate labels/functions, mixed edge families, undefined references,
    malformed regexes, malformed helper/function definitions, and strict-syntax warnings as documented.
  Verification: **PASS 2026-07-09.** `dart/lib/src/validation/spec_validator.dart` implements
    `validateSpec(...)` for parsed source ASTs. It rejects missing top rules, duplicate labels/functions,
    function registry collisions/invalid parameters, raw malformed body lines, mixed action/blind-call edge
    families, grouped action targets without a shared block, undefined targets, out-of-range regex slots, and
    lightweight regex structural errors. `strictSyntax: true` rejects unused rules. `test/spec_validator_test.dart`
    covers focused failures plus non-strict validation over all checked-in `specs/*.spec` and rule-only corpus
    `input.spec` files.
  Commit: `DART-BACKEND-PARITY.2.3 - add Dart frontend validation`

- ID: `DART-BACKEND-PARITY.2.4`
  Status: `done`
  Goal: Integrate `specs/user_function_definition.spec` as the function-definition shell owner.
  Acceptance: Dart consumes the spec-defined function-definition AST shape and does not maintain a
    competing host-language raw scanner as the semantic contract.
  Verification: **PASS 2026-07-09.** `dart/lib/src/parser/user_function_definition_shell.dart`
    adds `projectUserFunctionDefinitionAsts(...)` and `parseSpecWithUserFunctionDefinitionAsts(...)`.
    These APIs consume the `function_definition` / `function_definition_error` node shape returned by
    `specs/user_function_definition.spec`, validate source/body spans and staged sidecars, normalize
    source-order `parent_ast_path` and deterministic `body_parse_job` ids, strip returned source spans
    while preserving line layout, and attach ordered `FunctionDefinition` records before rule parsing.
    `StagedParseJob` now preserves the function-body sidecar metadata (`version`, `function_name`,
    `params`, `arity`, `diagnostic_owner`) during JSON round-trips. The production Dart path still
    does not raw-scan `fn` source; it requires the spec-returned nodes as its semantic input.
    `test/user_function_definition_shell_test.dart` covers successful projection, no-raw-scanner fallback,
    malformed `function_definition_error` diagnostics, and sidecar drift rejection.
  Commit: `DART-BACKEND-PARITY.2.4 - integrate Dart function shell projection`

- ID: `DART-BACKEND-PARITY.3`
  Status: `done`
  Goal: Implement helper/action AST and compiled-state construction.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

- ID: `DART-BACKEND-PARITY.3.1`
  Status: `done`
  Goal: Parse helper/action source into typed expression and statement AST nodes.
  Acceptance: Calls, literals, variables, direct/nested access, shape literals, assignments, block
    values, attached control flow, receiver chains, and standalone value-drop statements are structural
    AST nodes, not text rewrites.
  Verification: **PASS 2026-07-09.** `dart/lib/src/action/action_ast.dart` defines typed ActionIR
    block, statement, expression, argument, access-segment, literal, assignment, receiver-chain, block-value,
    and structured-control data nodes with JSON projection. `dart/lib/src/action/action_parser.dart` adds
    `parseActionBlock(...)`, `parseActionStatement(...)`, and `parseActionExpression(...)`. The parser
    covers calls, positional/keyword arguments, primitive literals, regex literals, variables, indexed and
    nested access, array/hash shape literals, scalar assignment, array append, hash-index assignment,
    nested-access assignment, expression-valued blocks, attached `if`/`when`/`elseif`/`else`/`otherwise`,
    `while`, `switch`/`case`/`default`, receiver-dot fluent chains, trailing block arguments, and standalone
    expression statements with `drops_value = true`. Unsupported expressions stay structural as `raw_perl`
    nodes for later validation/diagnostics rather than being rewritten as host code. `test/action_ast_parser_test.dart`
    covers each accepted node family.
  Commit: `DART-BACKEND-PARITY.3.1 - add Dart ActionIR AST parser`

- ID: `DART-BACKEND-PARITY.3.2`
  Status: `done`
  Goal: Map helper/action AST to canonical helper contracts and diagnostics.
  Acceptance: Current helper/control families resolve through typed nodes; non-current helper-looking
    calls diagnose generically instead of falling back to host-language calls. The Dart variant must not
    encode non-current helper spelling tables or replacement maps.
  Verification: **PASS 2026-07-09.** `dart/lib/src/action/action_contracts.dart` resolves typed ActionIR
    calls, receiver methods, structural assignments, structured controls, nested arguments, block values,
    shapes, and access expressions into current canonical helper/control contracts. Function registry
    validation now shares the current helper/control name table through `isKnownActionIrCallName(...)`.
    Non-current helper-looking calls produce `unknown_helper`; `raw_perl` AST nodes stay diagnostic-only.
    A Dart-tree non-current-spelling scan is clean.
  Commit: `DART-BACKEND-PARITY.3.2 - add Dart ActionIR contract resolver`

- ID: `DART-BACKEND-PARITY.3.3`
  Status: `done`
  Goal: Build the function registry and staged function-body parse-job records.
  Acceptance: Function definitions preserve params, arity, source/body spans, `body_payload`,
    `body_parse_job`, and stitched `body_ast`, with exact-arity resolution before helper fallback.
  Verification: **PASS 2026-07-09.** Added `dart/lib/src/action/function_registry.dart` with
    `UserFunctionRegistry`, `UserFunctionEntry`, and exact-arity call resolution over ordered
    `FunctionDefinition` records. The registry preserves params, arity, source/body spans, `body_payload`,
    `body_parse_job`, and optional stitched `body_ast`, and exposes staged function-body parse jobs. The ActionIR
    contract resolver now accepts an optional registry and resolves exact-arity user calls before helper fallback;
    wrong-arity registered calls diagnose as `user_function_arity_mismatch`. Focused registry/contract tests,
    Dart format/analyze/test, corpus runner, CLI help, mdBook, memory, Knowledge Map, task-tree metadata, and
    doctrine checks pass.
  Acceptance Checklist:
    - [x] **REPRODUCE / ISSUE** — `.3.2` could validate function names and resolve helper contracts, but Dart had
      no reusable ordered user-function registry object and helper-contract resolution classified registered user
      calls as ordinary unknown helpers.
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `FunctionDefinition` already carried staged body sidecars in
      `dart/lib/src/ast/spec_ast.dart`, and `.2.4` projected them from spec-returned nodes, but no Dart module
      indexed those definitions or connected exact-arity user-call lookup to `action_contracts.dart`.
    - [x] **FIX** — Added the registry module, exported it from the public package, and threaded an optional
      `UserFunctionRegistry` through the ActionIR contract resolver entrypoints.
    - [x] **ADDRESSED (verified)** — `test/function_registry_test.dart` proves ordered entries, parse-job
      exposure, sidecar/body-AST preservation, duplicate-name rejection, exact matches, wrong arity, and missing
      names. `test/action_contracts_test.dart` proves exact-arity user calls classify before helper fallback.
    - [x] **NO REGRESSION** — Dart format/analyze/full tests, corpus runner, and CLI help pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `MEMORY.md`, roadmap tracker rows, architecture state, Knowledge Map facts,
      `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.3.3 - add Dart function registry`

- ID: `DART-BACKEND-PARITY.3.4`
  Status: `done`
  Goal: Compile parsed specs into a Dart compiled-spec/interpreter model.
  Acceptance: Compiled state has ordered rules, dependency-regex data, function registry, lifecycle/action
    AST payloads, mode metadata, and descriptor projection equivalent to the mdBook model.
  Verification: focused `dart test test/compiled_spec_test.dart`; `dart format --set-exit-if-changed .`;
    `dart analyze --fatal-infos --fatal-warnings`; full `dart test`;
    `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`;
    `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build;
    memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`.
  Findings:
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: Dart had parsed `SpecFile` / `Rule` / ActionIR / function
      registry records, but no owner under `dart/lib/src/compiler/` assembled them into the mdBook
      `compiled_spec_state` / `compiled_dependency_regex_state` / `compiled_descriptor_state` contract.
    - [x] **FIX** — Added `compileSpec(...)`, `CompiledSpec`, `CompiledRule`, `CompiledDependencyRegexState`,
      and `CompiledDescriptorState`, plus public exports.
    - [x] **ADDRESSED (verified)** — `test/compiled_spec_test.dart` proves ordered rule state, source validation
      reuse, redefinition metadata when validation is deliberately skipped, dependency-regex derivation, mode
      metadata, lifecycle/action `ActionBlock` payloads, registry-aware user-call contracts, and descriptor-shaped
      JSON projection.
    - [x] **NO REGRESSION** — Dart format/analyze/full tests, corpus runner, CLI help, and mdBook build pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, compiled-state model, `CHANGES.md`,
      `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker
      row, Knowledge Map facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.3.4 - add Dart compiled spec state`

- ID: `DART-BACKEND-PARITY.4`
  Status: `active`
  Goal: Implement the Dart runtime interpreter.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`, `.4.5`

- ID: `DART-BACKEND-PARITY.4.1`
  Status: `done`
  Goal: Implement regex matching and match-state tracking.
  Acceptance: Seek/consume modes, alternative identity, capture groups, named captures, char offsets,
    cursor position, entry/local match separation, and zero-progress detection match the contract.
  Verification: focused `dart test test/runtime_matching_test.dart`; `dart format --set-exit-if-changed .`;
    `dart analyze --fatal-infos --fatal-warnings`; full `dart test`;
    `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`;
    `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build;
    memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`.
  Findings:
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `.3.4` produced compiled rule regex lists and descriptor
      data, but Dart had no runtime owner for seek/consume matching, match registers, capture extraction, or
      cursor/progress state. Those semantics belong below `.4.2` rule dispatch.
    - [x] **FIX** — Added `dart/lib/src/runtime/matching.dart` with `RuntimeRegexAlternation`,
      `RuntimeRegexMatch`, `RuntimeMatchRegisters`, `LinkedSpecParseMode`, char/code-unit offset helpers, and
      line/column projection helpers.
    - [x] **ADDRESSED (verified)** — `test/runtime_matching_test.dart` proves seek and consume behavior, stable
      alternative identity, compiled-rule regex-list matching, compact capture-only groups, named captures,
      char-offset projections over Dart code-unit spans, entry/local match separation, cursor state, and
      zero-progress detection.
    - [x] **NO REGRESSION** — Dart format/analyze/full tests, corpus runner, CLI help, and mdBook build pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker row, Knowledge Map
      facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.4.1 - add Dart runtime matching state`

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
| 1 | `DART-BACKEND-PARITY.4.1` | `done` | Runtime regex matching and match-state primitives are built; rule dispatch is next. |
| 2 | `DART-BACKEND-PARITY.4.2` | `pending` | Implement rule dispatch, rule modes, recursion guards, repetition bounds, and lifecycle order. |

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

The `.1.3` corpus IO scaffold adds:

- `lib/src/corpus/manifest_runner.dart` with `loadCorpusFixtures(...)`.
- `test/corpus_manifest_test.dart` covering the real 99-fixture corpus and negative drift cases.
- `bin/corpus_runner.dart --corpus <path>` loading and reporting manifest-backed fixture count.
- Manifest validation for format `1`, `case_count`, case names, duplicates, missing/stale directories,
  required fixture files, and `expected.json` syntax.
- No parser execution, runtime execution, or output comparison yet.

The `.2.1` AST/data layer adds:

- `lib/src/ast/spec_ast.dart` with data-only source AST and staged parse-job types.
- `test/spec_ast_test.dart` for JSON round-trips and `RuleMode` helper parity.
- JSON field names aligned with Rust/mdBook contracts: `functions`, `rules`, `source_span`,
  `body_span`, `body_parse_job`, `line_start`, `line_end`, `parent_ast_path`, `result_policy`,
  and `failure_policy`.
- No parser, compiler, runtime, corpus output comparison, or helper/action lowering behavior.

The `.2.2` parser layer adds:

- `lib/src/parser/spec_parser.dart` with public `parseSpec(...)`.
- `test/spec_parser_test.dart` for focused parser fixtures, all shipped `specs/*.spec`, and rule-only
  corpus `input.spec` files.
- Parsing for rule paragraphs, headers/modes, header-rest body elements, regex literals, lifecycle
  blocks, action and blind-call edges, fluent continuations, split/conditional markers, comments, raw
  fallback lines, and nested block boundaries.
- No strict validation, top-level `fn` shell extraction/staging, compiler/runtime execution, or corpus
  output comparison yet.

The `.2.3` validation layer adds:

- `lib/src/validation/spec_validator.dart` with public `validateSpec(...)`.
- `test/spec_validator_test.dart` for hard-error and strict-mode validation cases.
- Non-strict validation coverage over all shipped `specs/*.spec` and rule-only corpus `input.spec` files.
- Validation for top rules, duplicates, function registry records, raw malformed body lines, edge family
  consistency, grouped action edges, target references/indexes, regex structure, and strict unused rules.
- No top-level `fn` shell extraction/staging, compiler/runtime execution, or corpus output comparison yet.

The `.2.4` function-shell projection layer adds:

- `lib/src/parser/user_function_definition_shell.dart` with public
  `projectUserFunctionDefinitionAsts(...)` and `parseSpecWithUserFunctionDefinitionAsts(...)`.
- `test/user_function_definition_shell_test.dart` for projection, malformed-node diagnostics, sidecar
  drift rejection, and the no-raw-scanner boundary.
- Validation and normalization for the `function_definition` / `function_definition_error` AST node shape
  returned by `specs/user_function_definition.spec`.
- Preservation of `body_payload` and `body_parse_job` sidecars, normalized `parent_ast_path` values,
  deterministic function-body parse-job ids, and stripped definition spans before rule parsing.
- No helper/action AST typing, compiler/runtime execution, or corpus output comparison yet.

The `.3.1` ActionIR AST parser layer adds:

- `lib/src/action/action_ast.dart` with typed ActionIR block, statement, expression, argument, access,
  literal, assignment, receiver-chain, block-value, and structured-control nodes.
- `lib/src/action/action_parser.dart` with public `parseActionBlock(...)`,
  `parseActionStatement(...)`, and `parseActionExpression(...)`.
- Parser coverage for calls, literals, variables, direct/nested access, shape literals, assignments,
  expression-valued blocks, attached control flow, receiver chains, trailing block arguments, and
  standalone value-drop statements.
- `test/action_ast_parser_test.dart` for accepted node families and `raw_perl` structural fallback.
- No helper-contract resolution, compiled-spec state, runtime execution, or corpus output comparison yet.

The `.3.2` ActionIR contract layer adds:

- `lib/src/action/action_contracts.dart` with public `resolveActionBlockContracts(...)`,
  `resolveActionStatementContracts(...)`, `resolveActionExpressionContracts(...)`,
  `canonicalActionHelperName(...)`, and `isKnownActionIrCallName(...)`.
- Resolution of typed helper/action AST nodes against current canonical helper/control contracts.
- Generic `unknown_helper` diagnostics for helper-looking calls outside the current contract table.
- Shared current-name validation for user-function collisions.
- No user-function call classification, compiled-spec state, runtime execution, or corpus output comparison yet.

The `.3.3` function-registry layer adds:

- `lib/src/action/function_registry.dart` with public `UserFunctionRegistry`, `UserFunctionEntry`, and
  `UserFunctionCallResolution`.
- Ordered registry entries built from `FunctionDefinition` records, with staged function-body parse jobs exposed
  for later compiled-state/staged-dispatch work.
- Preservation of params, arity, source/body spans, `body_payload`, `body_parse_job`, and optional stitched
  `body_ast`.
- Optional registry-aware ActionIR contract resolution: exact-arity user calls classify as `user_function` before
  helper fallback; wrong-arity registered calls report `user_function_arity_mismatch`.
- `test/function_registry_test.dart` plus resolver coverage in `test/action_contracts_test.dart`.
- No compiled-spec state, runtime execution, or corpus output comparison yet.

The `.3.4` compiled-state layer adds:

- `lib/src/compiler/compiled_spec.dart` with public `compileSpec(...)`, `CompiledSpec`, `CompiledRule`,
  `CompiledDependencyRegexState`, `CompiledDescriptorState`, rule mode metadata, dependency refs, and compiled
  action payload records.
- Default source validation reuse before compiled-state construction, with explicit `validateSource: false` support
  only for lower-level state tests such as last-definition metadata.
- Ordered `definition_order` / `compiled_rule_order`, `rules_by_label`, `redefined_rule_labels`, and carried
  `UserFunctionRegistry` state.
- Per-rule regex lists, dependency refs, action/blind edges, mode metadata, lifecycle/plain/edge `ActionBlock`
  payloads, and registry-aware ActionIR contract results.
- Structured dependency-regex data derived from child rule regex slots.
- Descriptor projection with public `spec`, `functions`, `dependency_regex_map`, and `meta` keys.
- `test/compiled_spec_test.dart` for compiled-state shape, dependency-regex derivation, descriptor projection,
  source validation reuse, and redefinition metadata.
- No runtime execution, tracing, or corpus output comparison yet.

The `.4.1` runtime matching layer adds:

- `lib/src/runtime/matching.dart` with public `RuntimeRegexAlternation`, `RuntimeRegexMatch`,
  `RuntimeMatchRegisters`, `LinkedSpecParseMode`, `LineColumn`, and char/code-unit offset helpers.
- Seek and consume regex matching over ordered pattern lists, including `CompiledRule.regexPatterns`.
- Stable alternative indexes without relying on a backend-specific combined-regex branch side channel.
- Capture-only group compaction, named-capture maps, raw code-unit spans, char-offset projection, and line/column
  projection.
- Entry/local match-register separation for future child dispatch: child entry state is seeded from the caller's
  local match, while the child local match is independent.
- Cursor state and zero-progress detection helpers for later repetition/recursion guards.
- `test/runtime_matching_test.dart` for seek/consume behavior, compiled-rule regex-list integration, captures,
  named captures, UTF-16/code-point offset projection, entry/local separation, cursor state, and zero-progress
  candidates.
- No rule dispatch, lifecycle execution, helper runtime, tracing, or corpus output comparison yet.

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
- `2026-07-09`: Dart corpus IO starts by consuming the existing Rust-owned language-neutral corpus root
  under `rust/linkedspec-runtime/tests/corpus/`. Backend-neutral corpus relocation remains separate.
- `2026-07-09`: Dart source-level AST JSON names follow the existing Rust parsed-AST and staged parse-job
  contract. `body_ast` remains a neutral JSON sidecar until later helper/action AST leaves type it further.
- `2026-07-09`: Dart `.2.2` mirrors the Rust core parser boundary: parse rule paragraphs permissively into
  source AST, leave strict rejection to validation, and leave top-level function-definition shell extraction
  to the staged/function leaves.
- `2026-07-09`: Dart `.2.3` validation is source-AST validation only. It does not execute helper/action
  semantics and intentionally keeps top-level function shell extraction in `.2.4`.
- `2026-07-09`: Dart `.2.4` consumes the AST node shape returned by `specs/user_function_definition.spec`
  and does not raw-scan `fn` source. Executing that owning spec inside Dart remains a later runtime capability.
- `2026-07-09`: Dart `.3.1` adds typed helper/action AST parsing only. Canonical helper-family mapping,
  current-contract diagnostics, and compiled-state construction remain `.3.2` and later.
- `2026-07-09`: Dart `.3.2` resolves typed ActionIR calls and structural forms against the current
  helper/control contract table only. Non-current helper-looking calls diagnose as `unknown_helper`; Dart
  does not carry non-current helper spelling tables or replacement maps.
- `2026-07-09`: Dart `.3.3` builds user-function registry records from `FunctionDefinition` sidecars before
  compiled-state work. Registry-aware ActionIR contract resolution checks exact-arity user calls before helper
  fallback; wrong-arity registered calls produce user-function diagnostics.
- `2026-07-09`: Dart `.3.4` builds `CompiledSpec` / `CompiledRule` / dependency-regex / descriptor state over
  parsed `SpecFile`s. Dependency regexes are structured refs plus pattern strings until `.4` owns executable match
  dispatch.
- `2026-07-09`: Dart `.4.1` adds regex/match-state primitives only. Rule dispatch, lifecycle execution, and helper
  runtime remain `.4.2` and later.

## Open Questions

- None blocking `.4.2`. Runtime matching primitives are available; rule dispatch and lifecycle order are next.

## Blockers

- None known before `.4.2` rule-dispatch work.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `DART-BACKEND-PARITY` | Plan created under `FUTURE-PARITY-BACKLOG.1.1`; `git diff --check`; memory architecture; Knowledge Map; doctrine; task-tree metadata; mdBook build; local CI. | PASS. Local CI includes phase0 `1..1028`; no Dart code yet. |
| `2026-07-09` | `DART-BACKEND-PARITY.1.1` | `command -v dart`; `dart --version`; `command -v flutter`; approved `dart --disable-analytics`; `dart help format`; `dart help analyze`; `dart help test`; `dart pub --help`; `dart create --help`; `git diff --check`; memory architecture; Knowledge Map; task-tree metadata; doctrine; mdBook build. | PASS. Dart SDK `3.9.2` is available; Flutter absent/non-blocking; layout and commands recorded; no Dart package files created. |
| `2026-07-09` | `DART-BACKEND-PARITY.1.2` | approved `dart pub get`; `dart format --set-exit-if-changed .`; approved `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. Scaffold package, lockfile, CLI stubs, corpus-runner stub, and smoke test are green; no parser/runtime/corpus semantics yet. |
| `2026-07-09` | `DART-BACKEND-PARITY.1.3` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. Manifest IO loads 99 fixtures and catches missing/stale/malformed corpus state without parser execution. |
| `2026-07-09` | `DART-BACKEND-PARITY.2.1` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. AST/data types round-trip through JSON; no parser/runtime behavior yet. |
| `2026-07-09` | `DART-BACKEND-PARITY.2.2` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. Parser fixtures cover Rust-compatible seams, all checked-in `specs/*.spec`, and rule-only corpus `input.spec` files. |
| `2026-07-09` | `DART-BACKEND-PARITY.2.3` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. Validator tests cover focused failures plus shipped specs and rule-only corpus specs. |
| `2026-07-09` | `DART-BACKEND-PARITY.2.4` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. Function-shell projection consumes spec-returned nodes, preserves staged sidecars, and does not raw-scan `fn` source. |
| `2026-07-09` | `DART-BACKEND-PARITY.3.1` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. ActionIR parser tests cover typed helper/action AST node families and structural `raw_perl` fallback. |
| `2026-07-09` | `DART-BACKEND-PARITY.3.2` | `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; Dart-tree non-current-spelling scan; `git diff --check`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; mdBook build. | PASS. ActionIR contract resolver records current canonical helper/control contracts and generic diagnostics without non-current spelling tables. |
| `2026-07-09` | `DART-BACKEND-PARITY.3.3` | Focused `dart test test/function_registry_test.dart test/action_contracts_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart preserves staged function sidecars in an ordered registry and resolves exact-arity user calls before helper fallback. |
| `2026-07-09` | `DART-BACKEND-PARITY.3.4` | Focused `dart test test/compiled_spec_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart compiles parsed specs into ordered compiled rule/dependency/descriptor state with ActionIR payloads and function registry projection. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.1` | Focused `dart test test/runtime_matching_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart runtime matching supports seek/consume, stable alternative identity, capture/named-capture records, char offsets, entry/local match separation, cursor state, and zero-progress detection. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DART-BACKEND-PARITY` | `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan` | Tree created by the backlog scoping leaf; implementation commits use `DART-BACKEND-PARITY.*` leaf ids. |
| `DART-BACKEND-PARITY.1.1` | `DART-BACKEND-PARITY.1.1 - record Dart toolchain and layout` | Toolchain/layout preflight; no package files. |
| `DART-BACKEND-PARITY.1.2` | `DART-BACKEND-PARITY.1.2 - create Dart scaffold smoke package` | Minimal package scaffold; no parser/runtime/corpus semantics. |
| `DART-BACKEND-PARITY.1.3` | `DART-BACKEND-PARITY.1.3 - add Dart corpus manifest IO scaffold` | Manifest IO scaffold; `.1` foundation container closes. |
| `DART-BACKEND-PARITY.2.1` | `DART-BACKEND-PARITY.2.1 - define Dart frontend AST data types` | Source-level AST/data types; no parser behavior. |
| `DART-BACKEND-PARITY.2.2` | `DART-BACKEND-PARITY.2.2 - implement Dart spec parser` | Core rule parser; validation/function-shell/runtime behavior deferred. |
| `DART-BACKEND-PARITY.2.3` | `DART-BACKEND-PARITY.2.3 - add Dart frontend validation` | Source-AST validation; function-shell/runtime behavior deferred. |
| `DART-BACKEND-PARITY.2.4` | `DART-BACKEND-PARITY.2.4 - integrate Dart function shell projection` | Spec-returned function-definition projection; `.2` frontend container closes. |
| `DART-BACKEND-PARITY.3.1` | `DART-BACKEND-PARITY.3.1 - add Dart ActionIR AST parser` | Typed helper/action AST parser; helper-contract mapping remains `.3.2`. |
| `DART-BACKEND-PARITY.3.2` | `DART-BACKEND-PARITY.3.2 - add Dart ActionIR contract resolver` | Current helper/control contract resolution; function registry uses the shared current-name table. |
| `DART-BACKEND-PARITY.3.3` | `DART-BACKEND-PARITY.3.3 - add Dart function registry` | Ordered user-function registry and exact-arity resolver; compiled state remains `.3.4`. |
| `DART-BACKEND-PARITY.3.4` | `DART-BACKEND-PARITY.3.4 - add Dart compiled spec state` | Ordered compiled rule/dependency/descriptor state; runtime matching starts in `.4.1`. |
| `DART-BACKEND-PARITY.4.1` | `DART-BACKEND-PARITY.4.1 - add Dart runtime matching state` | Seek/consume regex matching and match-state primitives; rule dispatch starts in `.4.2`. |

## Changelog

- `2026-07-09`: Created the Dart backend parity task tree and selected an interpreter-first parity path.
- `2026-07-09`: Recorded Dart SDK `3.9.2`, CLI/library package layout, and planned commands; frontier advances
  to `.1.2` for scaffold creation.
- `2026-07-09`: Created the `dart/` scaffold package and smoke test; frontier advances to `.1.3` for
  corpus-fixture IO scaffolding.
- `2026-07-09`: Added Dart corpus manifest IO and drift tests; `.1` foundation closes and frontier advances
  to `.2.1` for frontend AST/data types.
- `2026-07-09`: Added Dart source-level AST/data types and JSON round-trip tests; frontier advances to `.2.2`
  for parser implementation.
- `2026-07-09`: Added Dart core `.spec` parser and parser fixtures; frontier advances to `.2.3` for
  validation and strict syntax behavior.
- `2026-07-09`: Added Dart frontend validation and strict syntax tests; frontier advances to `.2.4` for
  function-definition shell integration.
- `2026-07-09`: Added Dart function-definition shell projection for spec-returned AST nodes; `.2` closes
  and frontier advances to `.3.1` for helper/action AST parsing.
- `2026-07-09`: Added Dart ActionIR AST node types and parser for helper/action source; frontier advances
  to `.3.2` for canonical helper-contract mapping and diagnostics.
- `2026-07-09`: Added Dart ActionIR contract resolution over typed helper/action AST nodes; frontier
  advances to `.3.3` for function registry and staged function-body parse jobs.
- `2026-07-09`: Added Dart user-function registry and exact-arity resolver over staged function sidecars;
  frontier advances to `.3.4` for compiled-spec/interpreter state.
- `2026-07-09`: Added Dart compiled rule/dependency/descriptor state with lifecycle/action ActionIR payloads and
  function registry projection; `.3` compiler-state container closes and frontier advances to `.4.1` for runtime
  matching and match-state tracking.
- `2026-07-09`: Added Dart runtime regex/match-state primitives over compiled rule regex lists; frontier advances
  to `.4.2` for rule dispatch, rule modes, recursion guards, repetition bounds, and lifecycle order.
