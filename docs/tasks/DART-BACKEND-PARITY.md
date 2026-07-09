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
  Status: `done`
  Goal: Implement rule dispatch, rule modes, recursion guards, repetition bounds, and lifecycle order.
  Acceptance: Default/AND/OR/REP families, action and blind-call edges, `I/LS/LE/E/EX/IT/LX`, `retv`,
    accumulator collection, and explicit returns match Perl/Rust parity fixtures.
  Verification: focused `dart test test/runtime_interpreter_test.dart`; `dart format --set-exit-if-changed .`;
    `dart analyze --fatal-infos --fatal-warnings`; full `dart test`;
    `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`;
    `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build;
    memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`.
  Findings:
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `.4.1` could match regexes and track entry/local state, but
      Dart still had no runtime owner that consumed `CompiledSpec` rule families, dependency refs, lifecycle
      ActionIR payloads, child dispatch, `retv`, accumulator collection, repetition bounds, or recursion cutoffs.
    - [x] **FIX** — Added `dart/lib/src/runtime/interpreter.dart` with `LinkedSpecRuntimeEngine`,
      `RuntimeParseResult`, lifecycle events, runtime exceptions, compiled-rule dispatch, action-edge and
      blind-call execution, bounded/zero-progress repetition, explicit returns, and a small dispatch-facing
      ActionIR evaluator. Added `RuntimeRegexMatch.reindexed(...)` for single-slot AND dispatch identity and
      exported the interpreter API from `linkedspec_dart.dart`.
    - [x] **ADDRESSED (verified)** — `test/runtime_interpreter_test.dart` proves regex repetition with lifecycle
      accumulation, action-edge child entry handoff with fluent `.push`, blind AND sequence, OR miss through `LX`,
      bounded OR repetition, zero-progress cutoff, and lifecycle order.
    - [x] **NO REGRESSION** — Dart format/analyze/full tests, corpus runner, CLI help, and mdBook build pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker row, Knowledge Map
      facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.4.2 - add Dart runtime rule interpreter`

- ID: `DART-BACKEND-PARITY.4.3`
  Status: `done`
  Goal: Implement runtime value model and helper families.
  Children: `.4.3.0`, `.4.3.1`, `.4.3.2`, `.4.3.3`, `.4.3.4`, `.4.3.5`, `.4.3.6`
  Acceptance: Scalars, arrays, hashes, booleans, numbers, null/undef, value blocks, mutation helpers,
    receiver chains, tree traversal helpers, capture/mark helpers, and string/number/hash/array families
    match the helper catalog.
  Verification: `PASS 2026-07-09` through `.4.3.6`; focused Dart runtime/parser tests, Dart format/analyze/full
    tests, corpus-runner scaffold, CLI help, mdBook, memory architecture, Knowledge Map, task-tree metadata,
    doctrine, and whitespace checks pass.
  Commit: `DART-BACKEND-PARITY.4.3.6 - close Dart helper value no drift`

- ID: `DART-BACKEND-PARITY.4.3.0`
  Status: `done`
  Goal: Split the broad runtime value/helper-family leaf into signoff-sized implementation leaves before code.
  Acceptance: Helper/value work is divided by runtime surface area; the next executable frontier is explicit and
    can land without bundling the complete helper catalog in one commit.
  Verification: memory architecture; task-tree metadata; doctrine; `git diff --check`.
  Commit: `DART-BACKEND-PARITY.4.3.0 - split Dart runtime helper families`

- ID: `DART-BACKEND-PARITY.4.3.1`
  Status: `done`
  Goal: Centralize Dart runtime value/store behavior and capture helper reads.
  Acceptance: Runtime values preserve scalar/array/hash/null/boolean/number JSON shapes; typed array/hash
    wrappers and bare reads follow the helper catalog; scalar assignment, array append, hash-index assignment,
    nested access reads, `copy`, `array`, `hash`, `entry_*`, `match_*`, and capture position helpers have focused
    runtime tests.
  Verification: focused `dart test test/runtime_interpreter_test.dart`; `dart format --set-exit-if-changed .`;
    `dart analyze --fatal-infos --fatal-warnings`; full `dart test`;
    `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`;
    `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build;
    memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`.
  Findings:
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `.4.2` intentionally kept the embedded ActionIR evaluator
      dispatch-facing. It could return, push arrays, concatenate simple values, and read basic captures, but
      `dart/lib/src/runtime/interpreter.dart` did not yet own hash stores, direct map reads, aggregate wrapper
      snapshots, hash-index mutation, named-capture maps, or capture position helpers.
    - [x] **FIX** — Added runtime hash storage and `hash(...)` / `set(hash(...), ...)`, hash-index and nested
      assignment evaluation, map-aware indexed/nested reads, typed array/hash snapshot reads through `array(...)`,
      `hash(...)`, and `copy(...)`, regex-literal value evaluation, and the named/map/length/start/end
      `entry_*` / `match_*` helper family.
    - [x] **ADDRESSED (verified)** — `test/runtime_interpreter_test.dart` now proves scalar assignment, array
      append, hash reset/mutation, typed wrapper snapshots, variable-held array/hash reads, non-numeric map
      indexing, nested access reads, bare capture-name lookup, named capture maps, compact capture groups, and
      char-position helper values.
    - [x] **NO REGRESSION** — Dart format/analyze/full tests, corpus runner, CLI help, and mdBook build pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker rows, Knowledge Map
      facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.4.3.1 - add Dart runtime value capture helpers`

- ID: `DART-BACKEND-PARITY.4.3.2`
  Status: `done`
  Goal: Implement string/scalar and numeric helper families, including compatible receiver chains.
  Acceptance: `cat`, trimming/case/substr/prefix/suffix/contains/matches/split scalar helpers, numeric arithmetic
    and comparison helpers/aliases/symbol callees, and simple scalar receiver chains match helper-catalog examples.
  Verification: **PASS 2026-07-09.**
    - [x] **ROOT CAUSE** — `.4.3.1` left the Dart runtime with only dispatch-facing helper execution. Parser and
      ActionIR contracts recognized current string/scalar helpers, numeric aliases, symbol callees, and receiver
      chains, but `LinkedSpecRuntimeEngine` still returned `null` for most of that pure helper surface.
    - [x] **FIX** — `dart/lib/src/runtime/interpreter.dart` now canonicalizes helper names through
      `canonicalActionHelperName(...)` and dispatches a shared pure-helper table for string/scalar helpers,
      explicit `str_*` lexical comparisons, numeric arithmetic/reducers/comparisons, numeric word aliases,
      arithmetic/comparison symbol callees, and compatible receiver-chain calls.
    - [x] **ADDRESSED** — Focused runtime tests cover `trim`, `lowercase`, `replace_substr`, `rm_suffix`,
      `substr`, `contains_substr`, `starts_with`, `ends_with`, `matches`, `split`, `coalesce`,
      `coalesce_nonempty`, `is_defined`, `is_undefined`, `is_empty`, `is_nonempty`, `str_eq`, `str_lt`,
      `+(...)`, `*(...)`, `num_div`, receiver `mod`, `num_clamp`, `gt`, `<=(...)`, receiver `round`,
      `num_range`, `avg`, `median`, `min`, divide-by-zero, and non-numeric failure-to-null behavior.
    - [x] **NO REGRESSION** — `dart format --set-exit-if-changed .`, focused runtime interpreter tests,
      `dart analyze --fatal-infos --fatal-warnings`, full `dart test`, the manifest-backed corpus runner,
      CLI help checks, mdBook build, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis
      evidence, and `git diff --check` pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker rows, Knowledge Map
      facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.4.3.2 - add Dart runtime string numeric helpers`

- ID: `DART-BACKEND-PARITY.4.3.3`
  Status: `done`
  Goal: Implement array helper family and array receiver/mutation behavior.
  Acceptance: `array`, `flat_array`, `copy`, count/select/order/membership/join/split bridges, append and
    end-mutation forms, and array receiver chains match helper-catalog examples without mutating snapshots
    unexpectedly.
  Verification: **PASS 2026-07-09.**
    - [x] **ROOT CAUSE** — `.4.3.2` executed string/scalar and numeric helpers, but array helper calls still
      fell through the generic pure-helper dispatcher or unsupported fluent-method path. Bare array working
      variables in receiver chains also evaluated as scalar variables, so `items.sorted()` could not read the
      aggregate store.
    - [x] **FIX** — `dart/lib/src/runtime/interpreter.dart` now routes array helpers through an array-aware
      dispatcher, reads bare array stores in array-consuming helper slots and compatible receiver chains,
      preserves regex delimiter/filter arguments, implements `split(array(target), ...)`, array pipelines,
      delimiter-first `join_values`, `flat_array` / `concat_arrays`, `split_tagged_records`, and statement-only
      `push_back` / `push_front` / `pop_back` / `pop_front`.
    - [x] **ADDRESSED** — Focused runtime tests cover sorted/drop/first chains, reversed/take/last, contains,
      index, drop/join, uniq/join, regex `filter_match`, `split_each`, trim/filter/lowercase pipelines,
      `take_last`, `slice`, `flat_array`, `concat_arrays`, array numeric reducers, missing-array emptiness,
      regex `split` bridges, statement-only end mutations, value-slot end-mutation no-op behavior, and tagged
      record splitting. Contract tests confirm `push_back` is recognized as a current helper name.
    - [x] **NO REGRESSION** — `dart format --set-exit-if-changed .`, focused runtime/contract tests,
      `dart analyze --fatal-infos --fatal-warnings`, full `dart test`, the manifest-backed corpus runner,
      CLI help checks, mdBook build, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis
      evidence, and `git diff --check` pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker rows, Knowledge Map
      facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.4.3.3 - add Dart runtime array helpers`

- ID: `DART-BACKEND-PARITY.4.3.4`
  Status: `done`
  Goal: Implement hash helper family and hash receiver/mutation behavior.
  Acceptance: `hash`, `flat_hash`, `copy`, key/value views, sorted views, merge/pick/drop/rename/set-key
    behavior, direct hash-index assignment values, and hash receiver chains match helper-catalog examples.
  Verification: **PASS 2026-07-09.**
    - [x] **ROOT CAUSE** — `.4.3.3` executed array helpers, but hash helper calls still fell through the
      generic pure-helper dispatcher or unsupported fluent-method path. Bare hash working variables in receiver
      chains also evaluated as scalar variables, so `meta.sorted_keys()` could not read the aggregate store.
    - [x] **FIX** — `dart/lib/src/runtime/interpreter.dart` now routes hash helpers through a hash-aware
      dispatcher, reads bare hash stores in supported hash-consuming helper slots and compatible receiver chains,
      implements key/value views, sorted key/value arrays, key predicates, `merge_hash`, `set_key`, `rename_key`,
      `drop_keys`, `pick_keys`, `flat_hash`, statement-form `set_key(...)`, and explicit flat-style hash
      splicing inside `hash(...)`.
    - [x] **ADDRESSED** — Focused runtime tests cover `sorted_keys`, `sorted_values`, `count_keys`, `has_key`,
      `drop_keys`, `pick_keys`, `rename_key`, `set_key`, `merge_hash`, `flat_hash`, hash receiver chains,
      direct hash-index assignment values, pure value/receiver `set_key(...)` no-mutation behavior, statement
      mutation, the bare-overlay merge boundary, and ordinary map field values not being flattened into
      `hash(...)`. Contract tests confirm `sorted_keys` is recognized as a current helper name.
    - [x] **NO REGRESSION** — `dart format --set-exit-if-changed .`, focused runtime/contract tests,
      `dart analyze --fatal-infos --fatal-warnings`, full `dart test`, the manifest-backed corpus runner,
      CLI help checks, mdBook build, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis
      evidence, and `git diff --check` pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart handoff/status text, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
      `LIVE_ACHIEVEMENT_STATUS.md`, `ARCHITECTURE_STATE.md`, `MEMORY.md`, roadmap tracker rows, Knowledge Map
      facts, `docs/TASK_TREE.md`, and this task tree are updated.
  Commit: `DART-BACKEND-PARITY.4.3.4 - add Dart runtime hash helpers`

- ID: `DART-BACKEND-PARITY.4.3.5`
  Status: `done`
  Goal: Implement value blocks, structured action controls, and tree traversal callback helpers.
  Acceptance: Expression-valued blocks, attached/inline `if`/`when`/`switch`/`while` surfaces, receiver `.with`,
    and `walk_leaves` / `map_leaves` / `reduce_leaves` traversal helpers match current Perl/Rust contracts.
  Verification: **PASS 2026-07-09.** Dart runtime execution now supports expression-valued blocks with
    block-local `return(...)` / `return_undef()`, final-expression yields, and nested statement side effects;
    attached `if` / `elseif` / `else` and `when` / `otherwise` branch chains; attached `switch` / `case` /
    `default`; attached `while` with the deterministic iteration guard; inline lazy `if(...)` / `switch(...)`;
    helper-form `with(value) { ... }` / `with() { ... }`; receiver `.with() { ... }` continuations; and
    hash/array `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver callbacks. Callback frames bind
    scoped scalar `value`, `path`, `depth`, plus hash `key`, array `index`, and reduce-only `acc`, and restore
    any outer scalar/array/hash bindings afterward. Hash traversal is sorted-key depth-first with nested hashes as
    interiors and arrays as leaves; array traversal is depth-first by zero-based index with nested arrays as
    interiors and hashes as leaves. Focused parser/runtime tests cover branch splitting, block-local vs rule-level
    returns, with-block binding restoration, traversal return shapes, non-aggregate receivers, and callback-scope
    restoration. Dart format, analyze, full test suite, corpus-loader, CLI help, mdBook, memory architecture,
    Knowledge Map, task-tree metadata, doctrine, and whitespace checks pass.
  Acceptance Checklist:
    - [x] **REPRODUCE / ISSUE** — `.4.3.4` executed hash helpers but value blocks used the surrounding
      action-block return channel, attached branch chains had no runtime gating, `with(...)` and receiver `.with()`
      were parsed but unsupported at runtime, and tree traversal receiver callbacks had no Dart execution path.
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `dart/lib/src/runtime/interpreter.dart` evaluated every
      `ActionBlockValueExpr` through `_executeActionBlock(...)`, so `return(...)` could not be block-local.
      `_evaluateExpression(...)` had no cases for structured control nodes or trailing-block callback helpers, and
      `dart/lib/src/action/action_parser.dart` did not split adjacent attached branch continuations into sibling
      statements.
    - [x] **FIXED** — Added branch-continuation statement splitting, value-block flow evaluation, attached/inline
      control execution, scoped `with` / receiver `.with` execution, hash/array tree traversal callbacks, scoped
      callback variable snapshots/restoration, and targeted parser/runtime coverage.
    - [x] **NO REGRESSION** — Focused parser/runtime tests, `dart format --set-exit-if-changed`, Dart analyze,
      full `dart test`, corpus-loader, CLI help checks, mdBook, memory architecture, Knowledge Map, task-tree
      metadata, doctrine, and `git diff --check` pass.
    - [x] **LOCKSTEP** — Dart README/CLI help, mdBook Dart handoff/status text, live docs, task-tree index,
      roadmap trackers, Knowledge Map facts, and `MEMORY.md` are updated.
  Commit: `DART-BACKEND-PARITY.4.3.5 - add Dart runtime controls and tree callbacks`

- ID: `DART-BACKEND-PARITY.4.3.6`
  Status: `done`
  Goal: Close helper/value no-drift for the Dart runtime slice.
  Acceptance: mdBook helper examples, Dart focused runtime tests, corpus-runner status text, live docs, and
    Knowledge Map facts agree on the helper/value boundary before `.4.4` BACKTRACK work starts.
  Verification: **PASS 2026-07-09.** The closeout audited mdBook helper/runtime/status text, Dart package status
    text, Knowledge Map facts, and focused Dart runtime coverage. It found and fixed one real Dart drift:
    nested value-path assignment in `dart/lib/src/runtime/interpreter.dart` was autovivifying missing
    intermediate containers and returning the assigned leaf value, while the Perl/Rust/helper-catalog contract
    requires successful expression values to return the updated root and failed missing/wrong paths to return
    `null` without mutation. Focused runtime coverage now mirrors the Rust `terse_11_4` proof: successful
    nested writes, append-at-len, scalar-held array root assignment, gap failure, missing-intermediate failure,
    wrong-shape failure, and unchanged roots after failure.
  Acceptance Checklist:
    - [x] **REPRODUCE / ISSUE** — Helper/value status was expected to be no-drift after `.4.3.5`, but the
      Dart runtime still diverged from the documented nested value-path assignment contract.
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `dart/lib/src/runtime/interpreter.dart` routed
      `ActionAssignNestedAccessExpr` through `_rootForWrite(...)` / `_writeNested(...)`, which created missing
      hash/list intermediates and padded array gaps. `ActionAssignHashIndexExpr` always mutated named hash
      storage, so scalar-held array roots did not get the single-segment append/replace behavior that Rust and
      the helper catalog define.
    - [x] **FIXED** — Replaced the autovivifying path with checked root storage and explicit
      no-autovivification assignment. Successful nested assignments return the updated root; missing/wrong
      intermediate paths return `null` without mutation; final hash keys may be created; final array indexes may
      replace or append exactly at len; segment index expressions evaluate before the RHS value expression; and
      scalar-held array/hash roots are handled before named-hash fallback.
    - [x] **ADDRESSED** — `test/runtime_interpreter_test.dart` adds
      `executes nested value-path assignment without autovivification`, covering updated-root returns, path
      failures, no mutation on failure, scalar-held array root writes, and quoted-key rejection on scalar-held
      arrays.
    - [x] **NO REGRESSION** — Focused parser/runtime tests, `dart format --set-exit-if-changed .`, Dart analyze,
      full `dart test`, corpus-runner scaffold, CLI help checks, mdBook, memory architecture, Knowledge Map,
      task-tree metadata, doctrine, and `git diff --check` pass.
    - [x] **LOCKSTEP** — Dart README, mdBook Dart status/handoff text, live docs, task-tree index, roadmap
      trackers, architecture state, Knowledge Map facts, and `MEMORY.md` are updated.
  Commit: `DART-BACKEND-PARITY.4.3.6 - close Dart helper value no drift`

- ID: `DART-BACKEND-PARITY.4.4`
  Status: `done`
  Goal: Implement cursor-rewind, parse-mode cursor behavior, and deterministic safety limits.
  Acceptance: Cursor rewinds affect only local cursor state, loops enforce documented safety, and
    deterministic order is maintained for hash views and dispatch decisions.
  Verification: **PASS 2026-07-09, superseded by `BACKTRACK-SURFACE-RUST-ALIGNMENT` for public names and boundary
    capture.**
    Dart runtime execution first landed local-match and entry/initial-match cursor rewinds plus char-based
    cursor/input helpers (`cursor_pos`, `cursor_line`,
    `cursor_col`, `cursor_rest`, `cursor_rest_len`, `input_text`, `input_len`, `input_slice`, `input_end_pos`,
    `input_end_line`, `input_end_col`). Existing zero-progress loop guards and deterministic sorted hash/tree
    behavior remain covered by the runtime suite. Current public helper names are `save_cursor()` /
    `restore_cursor()`, `rewind_match_start()` / `rewind_entry_start()`, and
    `capture_until_boundary(rule[, ...])`.
  Acceptance Checklist:
    - [x] **REPRODUCE / ISSUE** — Dart ActionIR contracts recognized `BACKTRACK`, `IBACKTRACK`, and cursor/input
      helper names, but runtime evaluation still returned `null` for those helper calls and could not update the
      live cursor from action code.
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `dart/lib/src/runtime/interpreter.dart` dispatched capture,
      string, number, array, hash, control, and traversal helpers, but `_evaluateCall(...)` had no cursor/input
      helper branch and `_RuntimeExecutionContext` had no cursor-rewind operation. `dart/lib/src/runtime/matching.dart`
      tracked entry and local match registers but lacked a cursor-only update method that preserved those registers
      while moving the live cursor.
    - [x] **FIXED** — Added `RuntimeMatchRegisters.withCursorCodeUnit(...)`, runtime context cursor projection and
      rewind methods, and char-based whole-input/current-cursor helper execution. The current public surface now
      lives in `BACKTRACK-SURFACE-RUST-ALIGNMENT`: `save_cursor()` / `restore_cursor()`,
      `rewind_match_start()` / `rewind_entry_start()`, and `capture_until_boundary(rule[, ...])`.
    - [x] **ADDRESSED** — `test/runtime_interpreter_test.dart` proves direct cursor anchor rewinds, explicit
      cursor-stack save/restore, consume-mode matching from a rewound cursor, and char-based cursor/input helper
      values while internal Dart cursors remain code-unit based.
    - [x] **NO REGRESSION** — Focused runtime tests, Dart format/analyze/full tests, corpus-runner scaffold,
      CLI help checks, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
      `git diff --check` pass.
    - [x] **LOCKSTEP** — Dart README/CLI help, mdBook runtime/status/handoff text, live docs, task-tree index,
      roadmap trackers, architecture state, Knowledge Map facts, and `MEMORY.md` are updated.
  Commit: `DART-BACKEND-PARITY.4.4 - add Dart backtrack cursor rewinds`

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
  Children: `.7.1`, `.7.2`, `.7.3`, `.7.4`, `.7.5`

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
  Status: `done`
  Goal: Record the director directive that each LinkedSpec backend variant should have a distinct CLI.
  Acceptance: The Dart task tree and future-backlog tree record the per-variant CLI requirement, a future
    Dart-specific implementation leaf exists, and no CLI behavior changes are made in this planning slice.
  Verification: **PASS 2026-07-09.** Added this directive record, split Dart CLI productization to `.7.4`,
    moved final Dart no-drift closeout to `.7.5`, recorded the cross-variant obligation in
    `FUTURE-PARITY-BACKLOG`, and added a Knowledge Map card. Memory architecture, Knowledge Map, task-tree
    metadata, doctrine checks, mdBook build, and `git diff --check` pass. No source behavior changed.
  Commit: `DART-BACKEND-PARITY.7.3 - record variant-specific CLI requirement`

- ID: `DART-BACKEND-PARITY.7.4`
  Status: `pending`
  Goal: Productize the Dart-specific LinkedSpec CLI entrypoint.
  Acceptance: The Dart backend exposes its own clearly named LinkedSpec CLI entrypoint, help text, argument
    contract, corpus/runtime invocation path, docs, and smoke tests without replacing or conflating the Perl and
    Rust variant CLIs. Naming must be consistent with the cross-variant requirement that each backend variant has
    a distinct CLI.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.7.5`
  Status: `pending`
  Goal: Final no-drift closeout for Dart parity.
  Acceptance: Roadmaps, task-tree index, live docs, mdBook, Knowledge Map, architecture snapshot, and
    verification commands agree that Dart reaches the accepted scoped milestone.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DART-BACKEND-PARITY.4.3.0` | `done` | Broad helper/value runtime work is split before code. |
| 2 | `DART-BACKEND-PARITY.4.3.1` | `done` | Core runtime value/store behavior and capture helper reads are implemented. |
| 3 | `DART-BACKEND-PARITY.4.3.2` | `done` | String/scalar and numeric helper families are implemented. |
| 4 | `DART-BACKEND-PARITY.4.3.3` | `done` | Array helper family and array receiver/mutation behavior are implemented. |
| 5 | `DART-BACKEND-PARITY.4.3.4` | `done` | Hash helper family and hash receiver/mutation behavior are implemented. |
| 6 | `DART-BACKEND-PARITY.4.3.5` | `done` | Value blocks, structured controls, with-blocks, and tree traversal callbacks are implemented. |
| 7 | `DART-BACKEND-PARITY.4.3.6` | `done` | Helper/value no-drift closeout fixed nested value-path assignment drift. |
| 8 | `DART-BACKEND-PARITY.4.4` | `done` | BACKTRACK/IBACKTRACK cursor rewinds and cursor/input helpers are implemented. |
| 9 | `DART-BACKEND-PARITY.4.5` | `pending` | Implement runtime diagnostics and trace controls next. |

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
- `2026-07-09`: Dart `.4.4` first landed cursor-rewind runtime mechanics. `BACKTRACK-SURFACE-RUST-ALIGNMENT.1`
  supersedes those short-lived public names with `save_cursor()` / `restore_cursor()` stack semantics and
  `rewind_match_start()` / `rewind_entry_start()` anchor rewinds.
- `2026-07-09`: `BACKTRACK-SURFACE-RUST-ALIGNMENT.2` added Dart runtime support for
  `capture_until_boundary(rule[, ...])`, matching Perl/Rust non-consuming structural boundary semantics.

## Open Questions

- None blocking `.4.5`. Cursor-control, boundary-capture, and cursor/input helper execution are implemented; runtime
  diagnostics and trace controls are next.

## Blockers

- None known before `.4.5` diagnostics/trace work.

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
| `2026-07-09` | `DART-BACKEND-PARITY.4.3.4` | Focused `dart test test/runtime_interpreter_test.dart`; focused `dart test test/action_contracts_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; diagnosis evidence; `git diff --check`. | PASS. Dart executes hash helper family breadth, hash receiver chains, statement/value `set_key` boundaries, direct hash-index assignment values, bare-overlay merge behavior, and explicit flat-style hash splicing. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.3.5` | Focused `dart test test/action_ast_parser_test.dart`; focused `dart test test/runtime_interpreter_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart executes expression-valued blocks, attached/inline controls, helper/receiver `with` trailing blocks, and hash/array tree traversal receiver callbacks with scoped binding restoration. |
| `2026-07-09` | `DART-BACKEND-PARITY.7.3` | mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Director's per-variant CLI directive is recorded; Dart CLI productization is split to `.7.4`; final closeout shifts to `.7.5`; no source behavior changed. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.3.6` | Focused `dart test test/action_ast_parser_test.dart`; focused `dart test test/runtime_interpreter_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Helper/value no-drift fixed Dart nested value-path assignment to match the Perl/Rust no-autovivification and updated-root/null contract; frontier advances to `.4.4` BACKTRACK. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.4` | Focused `dart test test/runtime_interpreter_test.dart test/runtime_matching_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart executes `BACKTRACK()` local cursor rewinds, `IBACKTRACK()` initial/entry cursor rewinds, char-based cursor/input helpers, and consume-mode matching from a rewound cursor; frontier advances to `.4.5` diagnostics/trace controls. |

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
| `DART-BACKEND-PARITY.4.2` | `DART-BACKEND-PARITY.4.2 - add Dart runtime rule interpreter` | First executable compiled-rule interpreter; broader helper families remain `.4.3`. |
| `DART-BACKEND-PARITY.4.3.0` | `DART-BACKEND-PARITY.4.3.0 - split Dart runtime helper families` | Helper/value runtime work split before code. |
| `DART-BACKEND-PARITY.4.3.1` | `DART-BACKEND-PARITY.4.3.1 - add Dart runtime value capture helpers` | Core value/store/capture helper subset. |
| `DART-BACKEND-PARITY.4.3.2` | `DART-BACKEND-PARITY.4.3.2 - add Dart runtime string numeric helpers` | String/scalar and numeric helper families. |
| `DART-BACKEND-PARITY.4.3.3` | `DART-BACKEND-PARITY.4.3.3 - add Dart runtime array helpers` | Array helper family and statement-only array end mutations. |
| `DART-BACKEND-PARITY.4.3.4` | `DART-BACKEND-PARITY.4.3.4 - add Dart runtime hash helpers` | Hash helper family and statement/value mutation boundaries. |
| `DART-BACKEND-PARITY.4.3.5` | `DART-BACKEND-PARITY.4.3.5 - add Dart runtime controls and tree callbacks` | Value blocks, structured controls, with-blocks, and tree traversal receiver callbacks. |
| `DART-BACKEND-PARITY.4.3.6` | `DART-BACKEND-PARITY.4.3.6 - close Dart helper value no drift` | Nested value-path assignment no-drift; `.4.3` helper/value container closes. |
| `DART-BACKEND-PARITY.4.4` | `DART-BACKEND-PARITY.4.4 - add Dart backtrack cursor rewinds` | BACKTRACK/IBACKTRACK cursor rewinds and cursor/input helpers. |
| `DART-BACKEND-PARITY.7.3` | `DART-BACKEND-PARITY.7.3 - record variant-specific CLI requirement` | Docs-only split for per-variant LinkedSpec CLI productization. |

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
- `2026-07-09`: Added Dart runtime rule dispatch/interpreter execution; frontier advances to `.4.3` for broader
  helper/value semantics.
- `2026-07-09`: Split Dart runtime helper/value semantics into focused leaves `.4.3.1` through `.4.3.6`.
- `2026-07-09`: Added Dart core runtime value/store behavior and capture helper reads; frontier advances to
  `.4.3.2` for string/scalar and numeric helper families.
- `2026-07-09`: Added Dart string/scalar and numeric helper execution; frontier advances to `.4.3.3` for array
  helper family and array receiver/mutation behavior.
- `2026-07-09`: Added Dart array helper family execution and statement-only array end mutations; frontier advances
  to `.4.3.4` for hash helper family and hash receiver/mutation behavior.
- `2026-07-09`: Added Dart hash helper family execution, hash receiver chains, and statement/value mutation
  boundaries; frontier advances to `.4.3.5` for value blocks, structured controls, and tree traversal helpers.
- `2026-07-09`: Recorded the director directive that each LinkedSpec backend variant should have its own CLI;
  Dart-specific CLI productization is now `DART-BACKEND-PARITY.7.4`, and final closeout shifts to `.7.5`.
- `2026-07-09`: Added Dart expression-valued block execution, structured attached/inline controls, helper/receiver
  `with` trailing blocks, and hash/array tree traversal receiver callbacks; frontier advances to `.4.3.6` for
  helper/value no-drift closeout before BACKTRACK work.
- `2026-07-09`: Closed Dart helper/value no-drift by fixing nested value-path assignment to return the updated
  root on success, return `null` without mutation on missing/wrong paths, and avoid autovivifying intermediate
  containers; `.4.3` closes and frontier advances to `.4.4` for BACKTRACK behavior.
- `2026-07-09`: Added Dart `BACKTRACK()` local cursor rewinds, `IBACKTRACK()` initial/entry cursor rewinds, and
  char-based cursor/input helper execution; frontier advances to `.4.5` for runtime diagnostics and trace controls.
