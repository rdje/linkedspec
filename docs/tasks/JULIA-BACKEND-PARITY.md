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
- Julia exposes native in-memory parse/compile/execute APIs suitable for embedding in a Julia process; the CLI and
  corpus runner are thin adapters over that library surface, not the reason the backend exists (ADR `0022`).
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
  Status: `done`
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
  Status: `done`
  Goal: Implement frontend validation and strict syntax behavior.
  Acceptance: Validation rejects duplicate labels/functions, mixed edge families, undefined references, malformed
    regexes, malformed helper/function definitions, and strict-syntax warnings as documented.
  Verification: `PASS` - `Pkg.test()` covers top-rule presence, duplicate labels/functions, function registry
    collisions and reserved params, raw fallback lines, mixed edge families, grouped action targets, undefined
    references, regex slot bounds, regex structure, strict unused-rule behavior, all checked-in specs, and rule-only
    corpus specs.
  Commit: `JULIA-BACKEND-PARITY.2.3 - add Julia frontend validation`

- ID: `JULIA-BACKEND-PARITY.2.4`
  Status: `done`
  Goal: Integrate `specs/user_function_definition.spec` as the function-definition shell owner.
  Acceptance: Julia consumes the spec-defined `function_definition` / `function_definition_error` AST shape and
    does not maintain a competing host-language raw scanner as the semantic contract.
  Verification: `PASS` - `Pkg.test()` covers spec-shaped function-definition node projection, malformed
    `function_definition_error` handling, staged sidecar drift rejection, wrapper-shape normalization, stripped
    rule-source parsing, and validation of the resulting `SpecFile`.
  Commit: `JULIA-BACKEND-PARITY.2.4 - project Julia function-definition shells`

- ID: `JULIA-BACKEND-PARITY.3`
  Status: `done`
  Goal: Implement helper/action AST, contract resolution, user-function registry, and compiled-state construction.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

- ID: `JULIA-BACKEND-PARITY.3.1`
  Status: `done`
  Goal: Parse helper/action source into typed expression and statement AST nodes.
  Acceptance: Calls, literals, variables, direct/nested access, shape literals, assignments, block values,
    structured controls, receiver chains, trailing blocks, and standalone value-drop statements are structural AST
    nodes, not text rewrites.
  Verification: `PASS` - `Pkg.test()` covers 74 Action AST parser assertions over calls, literals, variables,
    direct/nested access, shape literals, assignments, block values, structured controls, receiver chains, trailing
    blocks, standalone value-drop statements, and raw fallback nodes; total Julia tests pass with 353 assertions.
  Commit: `JULIA-BACKEND-PARITY.3.1 - add Julia ActionIR AST parser`

- ID: `JULIA-BACKEND-PARITY.3.2`
  Status: `done`
  Goal: Map helper/action AST to canonical helper contracts and diagnostics.
  Acceptance: Current helper/control families resolve through typed nodes; non-current helper-looking calls
    diagnose generically instead of falling back to host-language calls or Julia spellings.
  Verification: `PASS` - `Pkg.test()` covers 39 Action contract resolver assertions over nested typed helper
    calls, receiver methods, structural assignment contracts, generic unknown-helper/raw diagnostics, canonical
    aliasing, and validator sharing of the current helper/control name table; total Julia tests pass with 392
    assertions.
  Commit: `JULIA-BACKEND-PARITY.3.2 - add Julia ActionIR contract resolver`

- ID: `JULIA-BACKEND-PARITY.3.3`
  Status: `done`
  Goal: Build the function registry and staged function-body parse-job records.
  Acceptance: Function definitions preserve params, arity, source/body spans, `body_payload`, `body_parse_job`, and
    stitched `body_ast`, with exact-arity resolution before helper fallback.
  Verification: `PASS` - `Pkg.test()` covers 23 user-function registry assertions over ordered entries, staged
    body parse-job exposure, `body_payload` / `body_ast` preservation, immutable body-AST stitching, duplicate
    rejection, exact match, wrong arity, missing names, and registry-aware ActionIR contract resolution; total Julia
    tests pass with 415 assertions.
  Commit: `JULIA-BACKEND-PARITY.3.3 - add Julia user-function registry`

- ID: `JULIA-BACKEND-PARITY.3.4`
  Status: `done`
  Goal: Compile parsed specs into a Julia compiled-spec/interpreter model.
  Acceptance: Compiled state has ordered rules, dependency-regex data, function registry, lifecycle/action AST
    payloads, mode metadata, and descriptor projection equivalent to the mdBook model.
  Verification: `PASS` - `Pkg.test()` covers 41 compiled-state assertions over rule order, mode metadata,
    dependency refs, dependency-regex derivation, descriptor projection, lifecycle/action payload ASTs,
    registry-aware contracts, last-definition-wins metadata when validation is skipped, validation reuse, and
    compiled-state diagnostics; total Julia tests pass with 456 assertions.
  Commit: `JULIA-BACKEND-PARITY.3.4 - add Julia compiled-spec state`

- ID: `JULIA-BACKEND-PARITY.4`
  Status: `active`
  Goal: Implement the Julia runtime interpreter and helper/value semantics.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`, `.4.5`

- ID: `JULIA-BACKEND-PARITY.4.1`
  Status: `done`
  Goal: Implement regex matching and match-state tracking.
  Acceptance: Seek/consume modes, alternative identity, capture groups, named captures, char offsets, cursor
    position, entry/local match separation, and zero-progress detection match the contract.
  Verification: `PASS` - `Pkg.test()` covers 60 runtime-matching assertions over parse modes, invalid-pattern
    diagnostics, seek/consume selection, stable alternative identity, compiled-rule patterns, compact/full/named
    captures, multibyte character offsets, line/column projection, cursor and entry/local registers, zero-width /
    zero-progress behavior, reindexing, immutable cursor/capture-start updates, and boundary/input guards; total
    Julia tests pass with 516 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.1 - add Julia runtime matching state`

- ID: `JULIA-BACKEND-PARITY.4.2`
  Status: `done`
  Goal: Implement first executable rule dispatch over compiled state.
  Acceptance: Default, AND, OR, and repetition modes execute with lifecycle order, action-edge/blind-call child
    dispatch, explicit return behavior, accumulators, recursion guards, and output shape parity.
  Verification: `PASS` - `Pkg.test()` covers 34 focused rule-interpreter assertions over default repetition,
    action-edge and blind-call child dispatch, explicit `call(...)` / returns, passive terminal children, AND/OR
    modes, bounded repetition, zero-progress cutoff, full lifecycle order, `retv`, accumulators, consume mode,
    nested output shapes, recursion cutoff, lower-bound errors, unsupported-helper errors, top-rule lookup, and
    safety-limit validation; total Julia tests pass with 550 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.2 - add Julia runtime rule interpreter`

- ID: `JULIA-BACKEND-PARITY.4.3`
  Status: `done`
  Goal: Implement helper/value runtime families in safe batches.
  Children: `.4.3.0`, `.4.3.1`, `.4.3.2`, `.4.3.3`, `.4.3.4`, `.4.3.5`, `.4.3.6`
  Acceptance: Core value/store/capture helpers, string/number helpers, array helpers, hash helpers,
    expression-valued blocks, structured controls, `with` trailing blocks, and tree traversal callbacks either pass
    focused tests or are split into narrower leaves before code.
  Verification: `PASS` - `.4.3.1` through `.4.3.5` implement the scoped value/helper/control/callback families;
    `.4.3.6` confirms focused runtime coverage, status, mdBook helper contracts, live docs, and Knowledge Map facts
    agree at 567 assertions before cursor-control work.
  Commit: closed by `JULIA-BACKEND-PARITY.4.3.6 - close Julia helper value no drift`

- ID: `JULIA-BACKEND-PARITY.4.3.0`
  Status: `done`
  Goal: Split the broad runtime value/helper-family leaf into signoff-sized implementation leaves before code.
  Acceptance: Helper/value work is divided by runtime surface area; the next executable frontier is explicit and
    can land without bundling the complete helper catalog in one commit.
  Verification: `PASS` - the helper/value surface is split into `.4.3.1` core values/stores/captures, `.4.3.2`
    string/numeric helpers, `.4.3.3` array helpers, `.4.3.4` hash helpers, `.4.3.5` value/control/block/callback
    execution, and `.4.3.6` no-drift closeout; memory, task-tree, doctrine, Knowledge Map, mdBook, and whitespace
    gates pass.
  Commit: `JULIA-BACKEND-PARITY.4.3.0 - split Julia runtime helper families`

- ID: `JULIA-BACKEND-PARITY.4.3.1`
  Status: `done`
  Goal: Centralize Julia runtime value/store behavior and capture helper reads.
  Acceptance: Runtime values preserve scalar/array/hash/null/boolean/number JSON shapes; typed wrappers, bare reads,
    assignments, nested access, `copy`, `array`, `hash`, and `entry_*` / `match_*` capture helpers have focused tests.
  Verification: `PASS` - four focused end-to-end runtime cases cover typed scalar/array/hash/null/boolean/number
    values, named and variable-held aggregate snapshots, direct/nested reads, hash and array mutation, checked
    no-autovivification nested assignment, positional/named capture reads, capture maps, character spans, and
    line/column helpers; full `Pkg.test()` passes with 554 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.3.1 - add Julia runtime value capture helpers`

- ID: `JULIA-BACKEND-PARITY.4.3.2`
  Status: `done`
  Goal: Implement string/scalar and numeric helper families, including compatible receiver chains.
  Acceptance: Current scalar/string helpers, explicit lexical comparisons, numeric arithmetic/reducers/comparisons,
    word/symbol aliases, and compatible receiver chains match helper-catalog examples.
  Verification: `PASS` - two focused end-to-end runtime cases cover current string/scalar transforms,
    predicates, regex flags, split/coalesce/definedness/emptiness, explicit lexical comparisons, numeric
    arithmetic/unary/reducer/comparison helpers, aliases and symbol callees, invalid-input `nothing`, and
    compatible string/number receiver chains; full `Pkg.test()` passes with 556 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.3.2 - add Julia runtime string numeric helpers`

- ID: `JULIA-BACKEND-PARITY.4.3.3`
  Status: `done`
  Goal: Implement array helper family and array receiver/mutation behavior.
  Acceptance: Array construction/flattening, copy, count/select/order/membership/join/split bridges, append/end
    mutation forms, and receiver chains match helper-catalog examples without mutating snapshots unexpectedly.
  Verification: `PASS` - two focused end-to-end runtime cases cover pure array selection/order/membership,
    transform/filter/split pipelines, delimiter-first joins, one-level flatten/concat and constructor splicing,
    numeric reducer terminals, explicit split replacement, named and scalar-held statement-only end mutations,
    value-position mutation no-ops, and tagged records; full `Pkg.test()` passes with 558 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.3.3 - add Julia runtime array helpers`

- ID: `JULIA-BACKEND-PARITY.4.3.4`
  Status: `done`
  Goal: Implement hash helper family and hash receiver/mutation behavior.
  Acceptance: Hash construction/flattening, copy, key/value views, merge/pick/drop/rename/set-key behavior, direct
    hash-index assignment values, and receiver chains match helper-catalog examples.
  Verification: `PASS` - one focused end-to-end runtime case covers copied key/value views, pure
    merge/pick/drop/rename/set-key transformations, statement-only named hash mutation, direct hash-index
    assignment values, explicit flat-style hash splicing, ordinary nested map preservation, merge-slot
    resolution, and compatible hash/array receiver chains; full `Pkg.test()` passes with 559 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.3.4 - add Julia runtime hash helpers`

- ID: `JULIA-BACKEND-PARITY.4.3.5`
  Status: `done`
  Goal: Implement value blocks, structured action controls, trailing-block execution, and tree callbacks.
  Acceptance: Expression-valued blocks, attached/inline controls, helper/receiver `with`, and `walk_leaves` /
    `map_leaves` / `reduce_leaves` traversal callbacks match current Perl/Rust/Dart contracts.
  Verification: `PASS` - eight focused runtime assertions cover expression-valued blocks with final values and
    block-local return/return-undef, attached and marker controls, lazy inline controls, deterministic while
    limits, helper/receiver `with`, hash/array tree walk/map/reduce callbacks, non-aggregate lazy failure, and
    scoped binding restoration plus unsupported trailing-block/arity fences; full `Pkg.test()` passes with 567 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.3.5 - add Julia runtime controls and tree callbacks`

- ID: `JULIA-BACKEND-PARITY.4.3.6`
  Status: `done`
  Goal: Close helper/value no-drift for the Julia runtime slice.
  Acceptance: mdBook helper examples, Julia focused runtime tests/status, live docs, and Knowledge Map facts agree
    on the helper/value boundary before `.4.4` cursor-control work starts.
  Verification: `PASS` - the audit confirms Julia already implements the final no-autovivification nested-write
    contract and current block/helper/tree semantics; full `Pkg.test()` passes with 567 assertions, CLI status
    remains `runtime-value-control-tree`, mdBook/KM/live-doc/governance gates pass, the stale `.3` container status
    is reconciled, and central helper-catalog examples use semicolons only as same-line separators.
  Commit: `JULIA-BACKEND-PARITY.4.3.6 - close Julia helper value no drift`

- ID: `JULIA-BACKEND-PARITY.4.4`
  Status: `done`
  Goal: Implement explicit cursor controls, boundary capture, parse-mode cursor behavior, and deterministic safety
    limits.
  Acceptance: `save_cursor()` / `restore_cursor()`, `rewind_match_start()` / `rewind_entry_start()`, and
    `capture_until_boundary(rule[, ...])` behave like Perl/Rust/Dart and affect only documented cursor state.
  Verification: `PASS` - Julia now keeps an explicit LIFO cursor stack, synchronizes the live cursor and immutable
    match-register cursor on restores/rewinds/boundary captures, exposes character-based cursor/input helpers,
    preserves entry/local matches and semantic stores across cursor movement, and selects the earliest usable
    named boundary without consuming it. Full `Pkg.test()` passes with 581 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.4 - add Julia runtime cursor controls`

- ID: `JULIA-BACKEND-PARITY.4.5`
  Status: `done`
  Goal: Implement runtime diagnostics and trace controls.
  Children: `.4.5.0`, `.4.5.1`, `.4.5.2`, `.4.5.3`, `.4.5.4`
  Acceptance: Julia exposes default-quiet trace controls, event classes, sink behavior, branch/lifecycle trace
    points, and structured errors equivalent to the documented cross-variant trace contract.
  Verification: `PASS` through `.4.5.4` - structured diagnostics, trace controls/events/sinks, and runtime
    interpreter instrumentation pass 631 assertions; README/CLI status, mdBook, Knowledge Map, roadmap/task/live
    docs, and architecture agree on the scoped `runtime-trace-events` boundary without claiming broader parity.
  Commit: `JULIA-BACKEND-PARITY.4.5.4 - close Julia diagnostics trace no drift`

- ID: `JULIA-BACKEND-PARITY.4.5.0`
  Status: `done`
  Goal: Split the broad runtime diagnostics/trace-controls leaf into signoff-sized implementation leaves before code.
  Acceptance: Diagnostic payloads, trace controls/sinks, runtime trace instrumentation, and closeout proof are
    separately owned so no code slice must carry the whole cross-variant trace contract at once.
  Verification: `PASS` - split `.4.5` into `.4.5.1` structured runtime diagnostics, `.4.5.2` trace
    levels/controls/event classes/sinks, `.4.5.3` runtime branch/lifecycle/cursor/source-boundary instrumentation,
    and `.4.5.4` no-drift closeout. No Julia runtime behavior changed.
  Commit: `JULIA-BACKEND-PARITY.4.5.0 - split Julia diagnostics trace controls`

- ID: `JULIA-BACKEND-PARITY.4.5.1`
  Status: `done`
  Goal: Add Julia runtime structured diagnostic payloads and diagnostic-carrying runtime exceptions.
  Acceptance: Runtime failures expose stable structured fields for type, stage, owner stage, summary, detail,
    top rule, rule label, and handler/source attribution without changing successful parse output.
  Verification: `PASS` - exported `RuntimeDiagnostic` carries the neutral diagnostic fields through
    `RuntimeInterpreterException.diagnostic`; engine spec identity, top/rule attribution, Julia handler labels,
    richer inner-payload preservation, JSON projection, unchanged textual errors, and successful-output
    preservation pass seven focused assertions. Full `Pkg.test()` passes with 588 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.5.1 - add Julia runtime diagnostics`

- ID: `JULIA-BACKEND-PARITY.4.5.2`
  Status: `done`
  Goal: Add Julia trace levels, controls, structured event classes, and stdout/routed-file/mirror sink behavior.
  Acceptance: Trace controls are default-quiet, available from normal Julia entrypoints, preserve successful parse
    results, support reset/truncate for routed files, and provide focused tests for level gating and sink routing.
  Verification: `PASS` - `julia/src/trace/Trace.jl` exports ordered levels, environment/config controls,
    structured event/scope/decision/log/dump primitives, stdout/routed-file/mirror sinks, reset behavior, and
    traced runtime entrypoints. Twenty-nine focused assertions prove control/sink/event behavior, default quiet,
    parse-scope routing, and output preservation; full `Pkg.test()` passes with 617 assertions.
  Commit: `JULIA-BACKEND-PARITY.4.5.2 - add Julia trace controls`

- ID: `JULIA-BACKEND-PARITY.4.5.3`
  Status: `done`
  Goal: Instrument the Julia runtime interpreter with branch, lifecycle, dispatch, cursor, and boundary events.
  Acceptance: Traced execution emits structured scopes and decisions for rule dispatch, regex/blind branches,
    lifecycle blocks, recursion cutoffs, cursor controls, and source boundaries while untraced output is unchanged.
  Verification: `PASS` - rule scopes, regex match/no-match decisions, action/blind child dispatch, lifecycle
    marks, recursion cutoffs, cursor controls, and source-boundary events are emitted only through an enabled
    trace emitter. Fourteen added trace assertions preserve traced/untraced output identity; full `Pkg.test()`
    passes with 631 assertions and status `runtime-trace-events`.
  Commit: `JULIA-BACKEND-PARITY.4.5.3 - add Julia runtime trace events`

- ID: `JULIA-BACKEND-PARITY.4.5.4`
  Status: `done`
  Goal: Close Julia runtime diagnostics/trace no-drift.
  Acceptance: Julia README/CLI status, mdBook trace/runtime/handoff pages, live docs, task-tree index, and
    Knowledge Map agree on the implemented diagnostics/trace boundary before `.5` staged runtime work begins.
  Verification: `PASS` - full `Pkg.test()` remains green with 631 assertions; CLI/package status is
    `runtime-trace-events`; Julia README, mdBook trace/status/handoff, Knowledge Map, task/index/roadmap/live docs,
    and architecture all describe the same implemented runtime diagnostics/trace boundary. `.5.1` becomes active.
  Commit: `JULIA-BACKEND-PARITY.4.5.4 - close Julia diagnostics trace no drift`

- ID: `JULIA-BACKEND-PARITY.5`
  Status: `done`
  Goal: Implement staged parser registry and user-function runtime parity.
  Children: `.5.1`, `.5.2`, `.5.3`

- ID: `JULIA-BACKEND-PARITY.5.1`
  Status: `done`
  Goal: Implement the minimal staged registry provider for function-body parse jobs.
  Acceptance: `actionir-body.spec` resolves deterministically, compiles top rule `action_block`, executes queued
    jobs in stable order, and stitches `body_ast`.
  Verification: `PASS` - Julia resolves `actionir-body.spec` to the fixed built-in provider, records the neutral
    digest/cache/compiled-parser shape, executes jobs in stable path/span/id order through `parse_action_block`,
    and immutably stitches JSON `action_block` results into `body_ast`. Thirty-one focused assertions cover
    ordering, wrapper composition, diagnostics, and contract drift; full `Pkg.test()` passes with 662 assertions.
  Commit: `JULIA-BACKEND-PARITY.5.1 - add Julia staged function-body registry`

- ID: `JULIA-BACKEND-PARITY.5.2`
  Status: `done`
  Goal: Execute registered user functions in value positions, receiver chains, and standalone discard.
  Acceptance: Exact-arity functions use fresh function-local stores, eager argument evaluation, compatible receiver
    continuation, standalone `VALUE_DROP`, and recursion diagnostics.
  Verification: `PASS` - Julia resolves registered calls before ordinary helper fallback, evaluates arguments in
    caller scope, executes cached ActionIR bodies with fresh scalar/array/hash stores, restores caller stores, and
    returns final expressions or local `return(...)` payloads. Nine focused assertions cover value/receiver/drop,
    eager arguments, local isolation, typed params, exact arity, and direct/mutual recursion diagnostics; full
    `Pkg.test()` passes with 671 assertions and package status `runtime-user-functions`.
  Commit: `JULIA-BACKEND-PARITY.5.2 - execute Julia user functions`

- ID: `JULIA-BACKEND-PARITY.5.3`
  Status: `done`
  Goal: Preserve staged parse-job and function-registry descriptor shapes.
  Acceptance: Descriptor/corpus fixtures can assert the neutral function-definition payload, parse-job, and
    stitched AST fields without Julia-specific field drift.
  Verification: `PASS` - one 20-assertion end-to-end fixture starts from two spec-returned function-definition
    nodes, dispatches/stitches their bodies, compiles the result, and proves ordered functions/jobs, neutral
    `body_payload` provenance, normalized `body_parse_job` ids/paths/policies, stitched `body_ast`, descriptor
    function order/count, and stable runtime output. Full `Pkg.test()` passes with 691 assertions; no descriptor
    projection correction was required and package status remains `runtime-user-functions`.
  Commit: `JULIA-BACKEND-PARITY.5.3 - preserve Julia staged descriptor shapes`

- ID: `JULIA-BACKEND-PARITY.6`
  Status: `done`
  Goal: Prove Julia parity against the corpus and cross-backend gates.
  Children: `.6.1`, `.6.2`, `.6.3`, `.6.4`

- ID: `JULIA-BACKEND-PARITY.6.1`
  Status: `done`
  Goal: Bring up controlled proof fixtures.
  Acceptance: Minimal authored fixtures prove scalar output, nested arrays/hashes, rule dispatch, lifecycle return
    shape, function calls, trace/diagnostic basics, and boundary capture before shipped-spec breadth.
  Verification: `PASS` - `execute_corpus_fixtures(...)` validates then executes every fixture through
    parse/compile/runtime, compares the one-level wrapped backend-neutral output structurally, captures optional
    trace lines and structured runtime diagnostics, and reports every failure without aborting. Twenty-four
    focused assertions cover six passing authored fixtures plus runtime-error/output-mismatch continuation; full
    `Pkg.test()` passes with 715 assertions and status `runtime-controlled-corpus`.
  Commit: `JULIA-BACKEND-PARITY.6.1 - add Julia controlled corpus execution`

- ID: `JULIA-BACKEND-PARITY.6.2`
  Status: `done`
  Goal: Expand to the current manifest in recoverable corpus batches.
  Children: `.6.2.0`, `.6.2.1`, `.6.2.2`, `.6.2.3`, `.6.2.4`, `.6.2.5`
  Acceptance: Each batch either passes on Julia or records a narrowly owned root-cause leaf with Perl/Rust/Dart
    oracle evidence; no fixture is weakened to fit Julia.
  Verification: `PASS` - bounded selection/reporting, starter 40/40, middle non-function 25/25, shipped-spec
    31/31, and the three spec-driven top-level function fixtures are permanently covered without weakening any
    fixture. Full tests pass with 827 assertions and status is `runtime-corpus-function-shells`.
  Commit: closed by `JULIA-BACKEND-PARITY.6.2.5 - execute Julia function shell corpus`

- ID: `JULIA-BACKEND-PARITY.6.2.0`
  Status: `done`
  Goal: Split shipped-corpus expansion into narrowly owned batches.
  Acceptance: `.6.2` has child leaves for bounded executable selection/reporting, starter fixtures, middle
    helper/control/runtime fixtures, shipped-spec/parser-smoke fixtures, and spec-defined top-level function shells
    before any parser/runtime behavior changes or broad diagnostic run.
  Verification: `PASS` - `.6.2` now has separate bounded execution/reporting, starter 0–39, middle non-function
    40–67, shipped-spec/parser-smoke 68–98, and spec-defined top-level function-shell owners before diagnostic or
    behavior changes. mdBook, memory, Knowledge Map, task metadata, doctrine, and whitespace gates pass; Julia
    source/runtime behavior remains the green 715-assertion `runtime-controlled-corpus` boundary.
  Commit: `JULIA-BACKEND-PARITY.6.2.0 - split Julia corpus expansion batches`

- ID: `JULIA-BACKEND-PARITY.6.2.1`
  Status: `done`
  Goal: Add opt-in executable corpus selection and reporting.
  Acceptance: Julia can execute named or safely bounded fixture subsets through the library and corpus runner,
    report pass/fail details for every selected fixture, and keep default validation-only behavior while full
    manifest parity remains incomplete.
  Verification: `PASS` - `execute_corpus_fixtures(...)` accepts ordered `case_names` or an `offset`/`limit`
    window with strict selection diagnostics. The corpus runner exposes bounded `--execute` through repeated
    `--case` or `--offset` plus `--limit`, reports every selected PASS/FAIL and summary, returns nonzero for fixture
    failures, rejects selectors without `--execute`, and rejects unbounded CLI execution. Thirty added assertions
    bring full `Pkg.test()` to 745 with status `runtime-corpus-selection`.
  Commit: `JULIA-BACKEND-PARITY.6.2.1 - add Julia executable corpus selection`

- ID: `JULIA-BACKEND-PARITY.6.2.2`
  Status: `done`
  Goal: Close the starter proof-edge, autoexist, and core terse runtime batch.
  Acceptance: Manifest fixtures `0..39` either pass unchanged on Julia or each mismatch is routed to a narrowly
    owned root-cause child with Perl/Rust/Dart oracle evidence.
  Verification: `PASS` - bounded runner execution over manifest offsets `0..39` reports 40 passed and 0 failed
    without parser/runtime or fixture changes. A permanent six-assertion package test locks manifest count, window
    endpoints, result count, passed count, and zero failures; full `Pkg.test()` passes with 751 assertions and
    status `runtime-corpus-starter`.
  Commit: `JULIA-BACKEND-PARITY.6.2.2 - close Julia starter corpus batch`

- ID: `JULIA-BACKEND-PARITY.6.2.3`
  Status: `done`
  Goal: Close the middle helper, control, receiver-chain, and tree traversal batch.
  Acceptance: Non-function manifest fixtures `40..67` covering value blocks, controls, helper composition,
    receivers, numeric/string/array/hash helpers, with-blocks, and tree traversal pass unchanged or are routed with
    oracle evidence; top-level `fn` fixtures remain owned by `.6.2.5`.
  Verification: `PASS` - bounded windows `40..56`, `58..59`, and `62..67` report 25 passed and 0 failed without
    parser/runtime or fixture changes. Six permanent assertions lock window sizes/endpoints, 25 results/passes,
    empty failures, and routed top-level `fn` offsets `57`, `60`, `61`; full `Pkg.test()` passes with 757 assertions
    and status `runtime-corpus-middle`.
  Commit: `JULIA-BACKEND-PARITY.6.2.3 - close Julia middle corpus batch`

- ID: `JULIA-BACKEND-PARITY.6.2.4`
  Status: `done`
  Goal: Close the shipped-spec and parser-smoke corpus batch.
  Children: `.6.2.4.0`, `.6.2.4.1`, `.6.2.4.2`, `.6.2.4.2.1`, `.6.2.4.2.2`, `.6.2.4.3`, `.6.2.4.4`,
    `.6.2.4.5`, `.6.2.4.6`
  Acceptance: Manifest fixtures `68..98` covering tclite, lispish, recursive top rules, hlink, portmap, EBNF,
    spec.spec, regdef, tablegrep, simenv, VHDL/library, history, and plugin smokes pass unchanged or each failure
    cluster is split before implementation with Perl/Rust/Dart oracle evidence.
  Verification: Initial bounded diagnostic reported 10 passed and 21 failed. The owned mechanism leaves close
    every residual. `.6.2.4.6` adds one permanent complete-window regression over offsets 68–98; all 31 fixtures
    pass exact checked-in output, full `Pkg.test()` passes with 816 assertions, and status is
    `runtime-corpus-shipped`.
  Commit: closed by `JULIA-BACKEND-PARITY.6.2.4.6 - close Julia shipped corpus no drift`

- ID: `JULIA-BACKEND-PARITY.6.2.4.0`
  Status: `done`
  Goal: Split the shipped-spec/parser-smoke batch after diagnostic execution.
  Acceptance: The 31-fixture window is measured, all failures are named and grouped by observed mechanism, and
    recoverable implementation children exist before Julia source behavior changes.
  Verification: `PASS` - bounded `--offset 68 --limit 31` execution reports 10 passed and 21 failed. The failures
    split into four capture-boundary helper cases, five logical-helper cases, two diagnostic-output helper cases,
    three recursive top-rule output mismatches, five EBNF/spec.spec structural-output mismatches, and two
    lib_reader quote-normalization mismatches. Checked-in Perl/Rust expected JSON plus the completed Dart shipped-
    smoke fact cards preserve the shared oracle boundary. No Julia source, test, or fixture behavior changed.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.0 - split Julia shipped corpus smoke batch`

- ID: `JULIA-BACKEND-PARITY.6.2.4.1`
  Status: `done`
  Goal: Add the missing anonymous capture-boundary helper family.
  Acceptance: `start_capture_slice`, `capture_slice`, and the directly related anonymous boundary helpers match
    the documented Perl/Rust contract; the three hlink delimiter fixtures and `ebnf_logging_annotation` either
    pass or every residual is split with direct oracle evidence.
  Verification: `PASS` - Julia executes the complete anonymous direct family: start, match-start/cursor/input-end
    text and character-length readers, position/line/column readers, and destructive take variants. Three focused
    Unicode/location/mutation assertions plus six permanent corpus assertions bring full `Pkg.test()` to 766.
    All three hlink delimiter fixtures pass; `ebnf_logging_annotation` advances from unsupported-helper failure to
    the same structural-item output mismatch as `ebnf_expression_rules` and is routed to `.6.2.4.4`. The complete
    window improves from 10/31 to 13/31 with no regression; status is `runtime-corpus-capture-boundaries`.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.1 - add Julia anonymous capture boundaries`

- ID: `JULIA-BACKEND-PARITY.6.2.4.2`
  Status: `done`
  Goal: Close logical and diagnostic-output helper gaps.
  Children: `.6.2.4.2.1`, `.6.2.4.2.2`, `.6.2.4.2.3`
  Acceptance: Current logical and diagnostic-output helpers execute with the documented portable contracts, with
    boolean and output behavior isolated into separate implementation leaves.
  Verification: `PASS` - `.6.2.4.2.1` adds eager boolean helpers, `.6.2.4.2.3` normalizes helper regex flags,
    and `.6.2.4.2.2` adds diagnostic output without changing parse results. All three owned helper mechanisms are
    covered by focused runtime and shipped-corpus regressions.
  Commit: closed by `JULIA-BACKEND-PARITY.6.2.4.2.2 - add Julia diagnostic output helpers`

- ID: `JULIA-BACKEND-PARITY.6.2.4.2.1`
  Status: `done`
  Goal: Add logical `and`/`or`/`not` helper execution.
  Acceptance: The four blocked portmap cases and `tablegrep_simple_term` no longer fail for unsupported logical
    helpers, with eager truthiness/value behavior matched to Perl/Rust or a narrower residual split.
  Verification: `PASS` - Julia evaluates all logical arguments eagerly, then returns boolean `and`/`or`/`not`
    results through the established runtime truthiness contract; empty `and`/`or`/`not` match Rust as
    false/false/true. `portmap_bare`, `portmap_bit`, `portmap_concatenation`, and `tablegrep_simple_term` pass.
    `portmap_constant` advances from unsupported `or` to `?bare:` versus expected `?constant:`; exact matching and
    capture probes show `matches(entry_group(0), /^\d/io)` fails only because Julia passes Perl's no-op `o` regex
    flag through to `Regex`. That residual is split to `.6.2.4.2.3`. Six permanent corpus assertions bring full
    `Pkg.test()` to 772, the complete window moves from 13/31 to 17/31, and status is
    `runtime-corpus-logical-helpers`.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.2.1 - add Julia logical helpers`

- ID: `JULIA-BACKEND-PARITY.6.2.4.2.2`
  Status: `done`
  Goal: Add diagnostic `print`/`print_each`/`say` helper execution.
  Acceptance: Diagnostic-output helpers preserve runtime output while matching the portable side-effect contract;
    `simenv_multiline_value` and `ds_vhistory_version_entry` advance past unsupported-helper failures.
  Verification: `PASS` - Julia eagerly evaluates all diagnostic arguments, emits `print`, `say`, and
    `print_each` messages through the configured low-level trace/diagnostic sink, returns `nothing`, and leaves
    parser output unchanged. Focused runtime coverage locks concatenation, newline/suffix behavior, array walking,
    and result neutrality. Both routed corpus cases advance past unsupported `print`: `simenv_multiline_value`
    now stops at unsupported `exit_now`, while `ds_vhistory_version_entry` reaches its already-known leading-trivia
    output mismatch. Seven permanent corpus-boundary assertions bring full `Pkg.test()` to 780. The complete
    shipped window remains 18/31 because this helper leaf advances failure mechanisms rather than closing either
    fixture; status is `runtime-corpus-diagnostic-output`, and `.6.2.4.3` becomes active.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.2.2 - add Julia diagnostic output helpers`

- ID: `JULIA-BACKEND-PARITY.6.2.4.2.3`
  Status: `done`
  Goal: Normalize portable no-op regex flags in Julia helper regex compilation.
  Acceptance: Julia helper regex paths preserve meaningful `i`/`m`/`s`/`x` behavior while treating Perl's
    compile-once `o` flag as a portable no-op; `portmap_constant` passes without weakening invalid-regex handling.
  Verification: `PASS` - `_runtime_compile_helper_regex(...)` centralizes helper regex compilation, preserves
    `i`/`m`/`s`/`x`, ignores execution-only `g` and Perl compile-once `o`, and returns failure for unknown flags or
    invalid patterns. Both `matches(...)` and regex `split(...)` use the seam. Focused helper coverage locks `igo`,
    regex split `go`, and unknown `q`; `portmap_constant` passes at exact expected output. Full tests remain 772,
    shipped smoke moves from 17/31 to 18/31, status is `runtime-corpus-helper-regex-flags`, and `.6.2.4.2.2` is next.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.2.3 - normalize Julia helper regex flags`

- ID: `JULIA-BACKEND-PARITY.6.2.4.3`
  Status: `done`
  Goal: Close recursive top-rule lifecycle and accumulator outputs.
  Acceptance: All three recursive top-rule fixtures match checked-in Perl/Rust outputs, with caller/child local
    state and LX result composition proven by focused Julia tests.
  Verification: `PASS` - Each rule invocation now owns a first-write snapshot map for explicit aggregate resets.
    `set(array(name), ...)`, `set(hash(name), ...)`, and explicit split-target replacement restore the caller's
    prior scalar/array/hash binding on rule exit, while ordinary undeclared child mutations remain caller-visible;
    user functions stay outside this tracker because they already swap complete stores. Focused array/hash reset
    and shared-mutation assertions plus three permanent recursive corpus assertions bring full `Pkg.test()` to
    785. All three recursive fixtures pass, the complete shipped window moves from 18/31 to 21/31, status is
    `runtime-corpus-recursive-rule-scope`, and `.6.2.4.4` becomes active.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.3 - scope Julia recursive rule resets`

- ID: `JULIA-BACKEND-PARITY.6.2.4.4`
  Status: `done`
  Goal: Close EBNF and spec.spec structural output mismatches.
  Acceptance: Both EBNF fixtures and the four spec.spec smoke fixtures preserve their expected structural records,
    or independent parser/runtime mechanisms are split again before implementation. `ebnf_logging_annotation`
    reaches structural execution after `.6.2.4.1`; it no longer belongs to the capture-helper leaf.
  Verification: `PASS/SPLIT` - Julia now recognizes action-edge `push(child)`, `push(child, target)`,
    `push(child, index)`, and `push(child, target, index)`, reuses the current edge's already-dispatched child
    result, and appends the whole/indexed value to the implicit or explicit accumulator. Focused coverage locks all
    four forms. All four spec.spec smokes pass. Both EBNF fixtures preserve every structural record and now differ
    only because statement-form `substr(...)` has not stripped quotes; that independent mutation/normalization
    mechanism is routed to `.6.2.4.5.2`. Seven permanent corpus assertions bring full `Pkg.test()` to 793. The
    complete window moves from 21/31 to 25/31, status is `runtime-corpus-action-edge-child-push`, and
    `.6.2.4.5.1` becomes active.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.4 - add Julia action-edge child push`

- ID: `JULIA-BACKEND-PARITY.6.2.4.5`
  Status: `done`
  Goal: Close the remaining non-final shipped-smoke mechanisms.
  Children: `.6.2.4.5.1`, `.6.2.4.5.2`, `.6.2.4.5.3`
  Acceptance: Fatal diagnostic control, statement mutation/quote normalization, and public-parser leading trivia
    each have an independent executable leaf; simenv, both EBNF cases, both lib_reader cases, and history either
    pass or expose a newly split mechanism before final 31/31 no-drift.
  Verification: `PASS` - `.5.1` adds fatal exit control, `.5.2` adds portable statement regex mutation, and
    `.5.3` mirrors public-parser leading trivia. All six routed fixtures pass, the shipped window is 31/31, and
    final no-drift advances independently to `.6`.
  Commit: `closed by JULIA-BACKEND-PARITY.6.2.4.5.3`

- ID: `JULIA-BACKEND-PARITY.6.2.4.5.1`
  Status: `done`
  Goal: Add terminating `exit_now(...)` runtime control.
  Acceptance: `simenv_multiline_value` advances past unsupported `exit_now` with the fatal-control contract locked
    independently from later statement mutation.
  Verification: `PASS` - Julia evaluates the optional first status expression, defaults absent/nonnumeric status
    to Rust-compatible `1`, and immediately throws `RuntimeInterpreterException` with rule attribution; the
    established wrapper retains structured top/rule/spec diagnostic fields. Focused coverage locks explicit
    `exit_now(7)`, default `exit_now(1)`, and an unreachable following return. Simenv advances from unsupported
    `exit_now` to deliberate `exit_now(1) in rule begin_end_blocks`, proving the helper while exposing its earlier
    statement-form `substr(...)` prerequisite under `.6.2.4.5.2`. Eight permanent boundary assertions and seven
    focused runtime assertions bring full `Pkg.test()` to 801; the shipped window remains 25/31 without regression,
    status is `runtime-corpus-exit-now`, and `.6.2.4.5.2` becomes active.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.5.1 - add Julia terminating exit control`

- ID: `JULIA-BACKEND-PARITY.6.2.4.5.2`
  Status: `done`
  Goal: Close statement-form scalar mutation and quote normalization.
  Acceptance: Both EBNF cases, both lib_reader cases, and the post-`exit_now` simenv boundary apply portable
    statement mutation without fixture-specific cleanup and match checked-in outputs or split a narrower residual;
    the exact single-quoted pattern spelling is locked across every current backend parser.
  Verification: `PASS` - In statement context only, four-argument `substr(...)` / `regex_subst(...)` with a bare
    scalar target now perform regex replacement before pure helper fallback. Julia preserves `i`/`m`/`s`/`x`,
    applies global `g`, accepts compatibility no-op `o`, expands `$n` captures, and fails invalid patterns/flags
    with rule attribution. Numeric value-form `substr(value, start, width)` stays pure, including a standalone
    discarded call. Six focused assertions lock mutation/global/single/case-insensitive/pure behavior. Both EBNF,
    both lib_reader, and simenv fixtures pass exact checked-in output; permanent corpus coverage brings full
    `Pkg.test()` to 808. The complete window moves from 25/31 to 30/31, status is
    `runtime-corpus-statement-mutation`, and `.6.2.4.5.3` becomes active for the sole history residual.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.5.2 - add Julia statement regex mutation`

- ID: `JULIA-BACKEND-PARITY.6.2.4.5.3`
  Status: `done`
  Goal: Mirror public-parser leading trivia for the history smoke.
  Acceptance: `ds_vhistory_version_entry` matches the checked-in public Perl/Rust output without weakening ordinary
    indexed variable reads or direct descriptor semantics.
  Verification: `PASS` - Julia now initializes the public `runtime_parse(...)` context after only leading blank
    lines and leading `#` comment lines, matching the Perl wrapper and completed Dart backend. A focused minimal
    locks the leading blank/comment boundary while a second assertion proves scalar-held `payload[1]` still
    returns the indexed value. `ds_vhistory_version_entry` passes exact checked-in output, the complete shipped
    window is 31/31, full `Pkg.test()` passes with 810 assertions, and status is
    `runtime-corpus-leading-trivia`. `.6.2.4.5` closes and `.6.2.4.6` becomes active for no-drift.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.5.3 - mirror Julia public parser leading trivia`

- ID: `JULIA-BACKEND-PARITY.6.2.4.6`
  Status: `done`
  Goal: Close final shipped-spec/parser-smoke no-drift.
  Acceptance: The complete offset-68/limit-31 window is 31/31 green, a permanent regression locks it, all residual
    mechanisms are explicitly owned, and package/docs/status surfaces agree before `.6.2.5` begins.
  Verification: `PASS` - a permanent test executes exactly offset `68`, limit `31`, and locks manifest count `99`,
    result count `31`, stable endpoints `tclite_command_subst` / `lib_reader_cattribute`, pass count `31`, empty
    failures, and exact expected-output equality for every result. Direct CLI execution reports 31 passed / 0
    failed. Full `Pkg.test()` passes with 816 assertions; CLI status reports `runtime-corpus-shipped`. Package,
    README, mdBook, roadmaps, Knowledge Map, task/index, architecture, live docs, and memory agree. No runtime
    semantic or corpus-fixture change was required.
  Commit: `JULIA-BACKEND-PARITY.6.2.4.6 - close Julia shipped corpus no drift`

- ID: `JULIA-BACKEND-PARITY.6.2.5`
  Status: `done`
  Goal: Execute top-level user-function corpus fixtures through the spec-defined shell.
  Acceptance: Julia obtains neutral `function_definition` nodes from `specs/user_function_definition.spec`, feeds
    them through staged body projection, and passes the routed `fn` fixtures without introducing a Julia raw
    function scanner or a fixture-only semantic shortcut.
  Verification: `PASS` - Julia now compiles and caches `specs/user_function_definition.spec`, executes it over
    top-level `fn` source, normalizes its neutral function-definition nodes, projects and strips exact source
    spans, dispatches body parse jobs through the existing ActionIR registry, and compiles the resulting rules and
    function registry. The default corpus path falls back to this staged parser only after rule-only
    `parse_spec(...)` reports a source parse error. Seven focused source-driven parser assertions and four
    permanent three-case corpus assertions pass. Direct CLI execution is 3 passed / 0 failed; full tests pass with
    827 assertions and status is `runtime-corpus-function-shells`. No Julia raw function scanner or fixture-only
    semantic branch was added.
  Commit: `JULIA-BACKEND-PARITY.6.2.5 - execute Julia function shell corpus`

- ID: `JULIA-BACKEND-PARITY.6.3`
  Status: `done`
  Goal: Finalize manifest drift guard and full Julia corpus gate.
  Acceptance: Julia runner rejects unsupported manifest format, mismatched counts, invalid/duplicate names, missing
    fixture dirs, stale extra dirs, and output mismatches; all current fixtures pass.
  Verification: `PASS` - the existing loader regressions reject unsupported format, count mismatch, invalid and
    duplicate names, missing and stale fixture directories, missing required files, malformed expected JSON, and
    output mismatch. One permanent complete-corpus regression now locks format `1`, manifest/result count `99`,
    exact manifest order and endpoints, 99 passes, zero failures, and exact expected output for every fixture.
    Unbounded CLI `--execute` runs the complete manifest; named, bounded, and offset-only diagnostics remain
    available. Direct full CLI execution is 99 passed / 0 failed; full tests pass with 840 assertions and status
    `runtime-corpus-full`.
  Commit: `JULIA-BACKEND-PARITY.6.3 - close full Julia corpus gate`

- ID: `JULIA-BACKEND-PARITY.6.4`
  Status: `done`
  Goal: Wire Julia parity into the local verification story.
  Acceptance: Focused Julia test commands are documented; broader local gate integration is added only when
    reliable and not dependent on absent local SDK state.
  Verification: `PASS` - `tools/run_julia_local.sh` provides one repo-owned focused gate over package tests,
    Julia CLI help/status, corpus-runner help, and full 99-fixture execution. The Julia command and depot are
    configurable through `LINKEDSPEC_JULIA_CMD` and `LINKEDSPEC_JULIA_DEPOT_PATH`; the default depot is outside
    the repository. `tools/run_ci_local.sh` stays core-only by default and includes Julia only when
    `LINKEDSPEC_RUN_JULIA=1`, so machines without Julia retain the canonical gate. The focused gate passes 840
    assertions and 99/99 corpus execution; shell syntax, default local CI, docs, and governance gates pass.
  Commit: `JULIA-BACKEND-PARITY.6.4 - wire Julia local verification`

- ID: `JULIA-BACKEND-PARITY.7`
  Status: `active`
  Goal: Close documentation, generated-source follow-up, and handoff alignment.
  Children: `.7.1`, `.7.2`, `.7.3`

- ID: `JULIA-BACKEND-PARITY.7.1`
  Status: `done`
  Goal: Document Julia backend usage, status, and parity boundaries in the mdBook.
  Acceptance: Book pages explain how to run Julia, what parity gate it satisfies, and any remaining limitations in
    variant-neutral terms.
  Verification: `PASS` - the backend handoff now presents Julia as a mature native in-memory backend rather than a
    scaffold, documents focused/direct/opt-in commands, gives self-contained rule-only and top-level-function
    embedding examples, names the 99/99 `runtime-corpus-full` boundary, and distinguishes interpreter parity from
    generated-source and compile/parser trace claims. The public API table/example, trace status, project status,
    local verification page, Julia README, and Knowledge Map agree. mdBook and governance checks pass.
  Commit: `JULIA-BACKEND-PARITY.7.1 - document Julia usage and parity boundary`

- ID: `JULIA-BACKEND-PARITY.7.2`
  Status: `active`
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
| 1 | `JULIA-BACKEND-PARITY.4.5.3` | `done` | Runtime mechanism instrumentation emits structured trace scopes, decisions, and marks. |
| 2 | `JULIA-BACKEND-PARITY.4.5.4` | `done` | Diagnostics/trace status, tests, book, KM, and live docs are no-drift. |
| 3 | `JULIA-BACKEND-PARITY.5.1` | `done` | Minimal staged registry dispatches function-body jobs and stitches `body_ast`. |
| 4 | `JULIA-BACKEND-PARITY.5.2` | `done` | Registered exact-arity functions execute through isolated runtime scopes. |
| 5 | `JULIA-BACKEND-PARITY.5.3` | `done` | Neutral function/parse-job/stitched-AST shapes are locked through runtime. |
| 6 | `JULIA-BACKEND-PARITY.6.1` | `done` | Controlled fixtures prove value, dispatch, lifecycle, function, trace, diagnostic, and boundary behavior. |
| 7 | `JULIA-BACKEND-PARITY.6.2.0` | `done` | Shipped-corpus rollout is split into recoverable execution and behavior batches before code. |
| 8 | `JULIA-BACKEND-PARITY.6.2.1` | `done` | Bounded library selection and opt-in corpus-runner reporting are green. |
| 9 | `JULIA-BACKEND-PARITY.6.2.2` | `done` | Starter manifest fixtures 0–39 pass unchanged at 40/40. |
| 10 | `JULIA-BACKEND-PARITY.6.2.3` | `done` | Non-function middle fixtures pass unchanged at 25/25; three `fn` cases remain routed. |
| 11 | `JULIA-BACKEND-PARITY.6.2.4.0` | `done` | Initial shipped-spec/parser-smoke boundary is 10/31 and split into owned failure families. |
| 12 | `JULIA-BACKEND-PARITY.6.2.4.1` | `done` | Anonymous capture boundaries close all three hlink delimiter cases; EBNF logging is structurally routed. |
| 13 | `JULIA-BACKEND-PARITY.6.2.4.2.1` | `done` | Eager logical helpers close four cases and isolate one helper-regex flag residual. |
| 14 | `JULIA-BACKEND-PARITY.6.2.4.2.3` | `done` | Shared helper regex compilation closes portmap constant while preserving invalid-flag failure. |
| 15 | `JULIA-BACKEND-PARITY.6.2.4.2.2` | `done` | Diagnostic output is trace-routed and parse-result neutral; both corpus cases advance to successor-owned mechanisms. |
| 16 | `JULIA-BACKEND-PARITY.6.2.4.3` | `done` | Rule-local aggregate reset snapshots close all three recursive top-rule fixtures. |
| 17 | `JULIA-BACKEND-PARITY.6.2.4.4` | `done` | Action-edge child-push forms close all four spec.spec smokes and route EBNF quote mutation. |
| 18 | `JULIA-BACKEND-PARITY.6.2.4.5.1` | `done` | Terminating explicit/default `exit_now(...)` control is diagnostic-attributed and immediate. |
| 19 | `JULIA-BACKEND-PARITY.6.2.4.5.2` | `done` | Statement regex mutation closes both EBNF, both lib_reader, and simenv fixtures. |
| 20 | `JULIA-BACKEND-PARITY.6.2.4.5.3` | `done` | Public-parser leading blank/comment skipping closes the sole history residual without weakening indexed reads. |
| 21 | `JULIA-BACKEND-PARITY.6.2.4.6` | `done` | Permanent full-window execution locks 31/31 exact output and closes shipped no-drift. |
| 22 | `JULIA-BACKEND-PARITY.6.2.5` | `done` | Spec-driven source parsing executes all three routed top-level function fixtures without a raw scanner. |
| 23 | `JULIA-BACKEND-PARITY.6.3` | `done` | Full manifest order/output is locked at 99/99 and unbounded CLI execution is enabled. |
| 24 | `JULIA-BACKEND-PARITY.6.4` | `done` | Focused Julia verification is repo-owned and optional shared-CI inclusion preserves SDK independence. |
| 25 | `JULIA-BACKEND-PARITY.7.1` | `done` | Public commands, embedding examples, 99/99 status, and limitations are explicit and aligned. |
| 26 | `JULIA-BACKEND-PARITY.7.2` | `active` | Decide generated Julia source as a separate post-interpreter proof lane. |

## `JULIA-BACKEND-PARITY.7.1` Public Documentation Result

Documentation evidence recorded on 2026-07-10:

- The mdBook backend handoff now calls the mature surface “Julia Backend Commands, Embedding, and Status,” lists
  the complete package layout, and documents focused/direct/optional-shared-CI commands.
- Public API examples show rule-only `parse_spec(...)` and source-driven
  `parse_spec_with_staged_user_function_definitions(...)` flowing through native compile/runtime APIs without a
  CLI, subprocess, temporary file, or raw Julia source scanner.
- Status text names the accepted interpreter-first boundary: 99/99 exact corpus outputs, 840 assertions, and
  `runtime-corpus-full`.
- Limitations are precise: generated Julia source is a separate `.7.2` decision; runtime tracing does not claim
  broader compile/parser trace parity; optional formatter/linter tools are not parity prerequisites.
- All new multiline `.spec` examples use newline statement separation with no trailing line-ending semicolons.

## `JULIA-BACKEND-PARITY.7.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The mdBook had correct mechanisms and commands but still labeled Julia a scaffold,
  showed one historical trace mechanism label as current package status, and lacked a self-contained native
  in-memory Julia example plus a concise limitations boundary.
- [x] **ROOT CAUSE (WHY + WHERE)** — Successive implementation leaves updated status fragments, while the original
  backend-handoff heading/layout and trace page retained their earlier lifecycle context.
- [x] **FIX** — Reframed the backend page, completed the package layout, added native examples, and separated the
  accepted interpreter gate from generated-source/trace/tooling non-claims.
- [x] **ADDRESSED (verified)** — Book searches and rendered mdBook prove commands, examples, current status, and
  remaining limitations are present and consistent.
- [x] **NO REGRESSION** — No parser/compiler/runtime behavior changed; the focused Julia gate remains 840 + 99/99.
- [x] **LOCKSTEP** — mdBook, Julia README, project status, roadmaps, task/index, Knowledge Map, live docs, and
  `MEMORY.md` agree; `.7.2` is the sole active Julia frontier.

## `JULIA-BACKEND-PARITY.6.4` Local Verification Result

Verification evidence recorded on 2026-07-10:

- `tools/run_julia_local.sh` runs Julia `Pkg.test()`, both Julia CLI help/status surfaces, corpus-runner help, and
  the complete 99-fixture corpus gate from the repository root.
- `LINKEDSPEC_JULIA_CMD` selects a non-default Julia executable.
  `LINKEDSPEC_JULIA_DEPOT_PATH` selects a dedicated writable depot; otherwise the script respects
  `JULIA_DEPOT_PATH` or uses a temp-root depot outside the repository.
- `tools/run_ci_local.sh` runs the Julia gate only under `LINKEDSPEC_RUN_JULIA=1`; default local CI emits an
  explicit skip message and has no Julia SDK dependency.
- The focused gate passes all 840 package assertions and the direct 99/99 corpus run. The default canonical local
  gate passes its core suite while skipping both optional backend gates.

## `JULIA-BACKEND-PARITY.6.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia had documented individual commands but no repo-owned focused gate or shared-CI
  opt-in equivalent to the completed Dart backend.
- [x] **ROOT CAUSE (WHY + WHERE)** — `tools/` contained only the Dart backend wrapper, and
  `tools/run_ci_local.sh` had no optional Julia branch; documentation therefore could not point to one canonical
  Julia verification command.
- [x] **FIX** — Added the configurable focused Julia gate, optional `LINKEDSPEC_RUN_JULIA=1` integration, and
  aligned root/backend/book usage docs.
- [x] **ADDRESSED (verified)** — The focused script passes 840 package assertions, CLI checks, and 99/99 corpus.
- [x] **NO REGRESSION** — Shell syntax checks pass; default local CI remains core-only and passes without opting
  into either backend SDK.
- [x] **LOCKSTEP** — Root/Julia READMEs, public book, task/index, Knowledge Map, live docs, and `MEMORY.md` agree;
  `.7.1` is the sole active Julia frontier.

## `JULIA-BACKEND-PARITY.6.3` Full Corpus Result

Aggregate evidence recorded on 2026-07-10:

- `load_corpus_fixtures(...)` validates the complete manifest before selection or execution. Existing focused
  tests reject unsupported format, count mismatch, invalid/duplicate names, missing/stale directories, missing
  files, malformed JSON, and output mismatches.
- One permanent complete-corpus test executes all 99 fixtures in manifest order and locks format `1`, manifest and
  result count `99`, first/last endpoints, pass count `99`, an empty failure ledger, and exact expected output for
  every result.
- Julia CLI `--execute` without selectors now runs the complete validated manifest. Named, offset, and limit
  selectors remain available for diagnostics; offset-only execution runs from that offset through the manifest end.
- Direct CLI execution prints every fixture as `PASS` and finishes `99 passed, 0 failed`. Full Julia tests pass
  with 840 assertions and package/CLI status `runtime-corpus-full`.

## `JULIA-BACKEND-PARITY.6.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — All bounded batches were green, but the CLI still rejected unbounded execution and
  no permanent regression executed the 99-fixture manifest as one atomic ordered gate.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/corpus/CorpusManifest.jl` retained the temporary `.6.2.1` rollout
  fence, while `julia/test/runtests.jl` proved only disjoint windows and routed groups.
- [x] **FIX** — Removed only the rollout fence, updated help/status text, and added full/offset-only CLI coverage
  plus one complete-corpus regression. Manifest validation and per-fixture result handling remain unchanged.
- [x] **ADDRESSED (verified)** — The permanent library gate and direct unbounded CLI both execute 99/99 green.
- [x] **NO REGRESSION** — Full Julia tests pass with 840 assertions; mismatch execution still exits `1`, invalid
  arguments/manifest state still exit `2`, and named/bounded selection remains green.
- [x] **LOCKSTEP** — Package/CLI status, Julia README, public book, roadmaps, task/index, architecture, live docs,
  Knowledge Map, and `MEMORY.md` agree; `.6.4` is the sole active Julia frontier.

## `JULIA-BACKEND-PARITY.6.2.5` Function-Shell Corpus Result

Source-driven evidence recorded on 2026-07-10:

- The original default corpus path reproduced a `SpecParseException` at the first top-level `fn` because it sent
  the complete source directly to the deliberately rule-only `parse_spec(...)` entrypoint.
- Julia now compiles and caches `specs/user_function_definition.spec`, executes that spec over the source in
  memory, normalizes the returned neutral function-definition nodes, and composes them with the existing staged
  body parser and user-function registry. No raw Julia source scanner or fixture-name branch was added.
- The ordinary rule-only parser remains first choice. Corpus execution uses the staged function-shell path only
  after `parse_spec(...)` reports a source parse error, preserving the direct path for rule-only specs.
- Direct CLI execution reports the three routed fixtures as `PASS` and finishes 3 passed / 0 failed. Full Julia
  tests pass with 827 assertions and status `runtime-corpus-function-shells`.
- Full 99/99 manifest parity is not claimed by this leaf; the independent complete-manifest drift/execution gate
  is active under `.6.3`.

## `JULIA-BACKEND-PARITY.6.2.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Rule-only `parse_spec(...)` fails at the first top-level `fn` in each routed source.
- [x] **ROOT CAUSE (WHY + WHERE)** — Julia already had neutral function projection, staged body parsing, and
  runtime registry execution, but `julia/src/corpus/CorpusManifest.jl` had no source-driven composition step.
- [x] **FIX** — Added a cached spec-driven function-definition parser and used it as the corpus fallback after a
  rule-only source parse error; the existing projection/staging/compiler/runtime path does the remaining work.
- [x] **ADDRESSED (verified)** — The three exact routed fixtures pass checked-in expected output through both the
  permanent package regression and direct corpus CLI execution.
- [x] **NO REGRESSION** — Full Julia tests pass with 827 assertions; rule-only parsing remains the primary path.
- [x] **LOCKSTEP** — Package/CLI status, Julia README, public book, roadmaps, task/index, architecture, live docs,
  Knowledge Map, and `MEMORY.md` agree; `.6.3` is the sole active Julia frontier.

## `JULIA-BACKEND-PARITY.6.2.4.6` Complete Shipped-Window Result

No-drift evidence recorded on 2026-07-10:

- The permanent Julia test runs the exact manifest window `offset = 68`, `limit = 31`; this is the same bounded
  command used for the initial 10/31 diagnosis and every intervening mechanism check.
- The regression locks manifest count `99`, result count `31`, first case `tclite_command_subst`, last case
  `lib_reader_cattribute`, pass count `31`, zero failure records, and `actual_output == Any[expected_json]` for
  every fixture.
- Direct Julia corpus-runner execution reports all 31 fixture names as `PASS` and finishes `31 passed, 0 failed`.
- Full `Pkg.test()` passes with 816 assertions. The package and CLI status is `runtime-corpus-shipped`.
- No runtime, parser, compiler, spec, manifest, input, or expected-output behavior changed in this closeout. The
  next active leaf is `.6.2.5` for the three deliberately routed top-level function fixtures.

## `JULIA-BACKEND-PARITY.6.2.4.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The complete window already measured 31/31 after `.6.2.4.5.3`, but only smaller
  mechanism-group regressions existed; no single permanent test owned the bounded window and its endpoints.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/test/runtests.jl` had starter, middle, and mechanism-specific shipped
  corpus testsets but no full `68/31` testset, leaving the final no-drift claim dependent on manual commands.
- [x] **FIX** — Added one complete-window test with manifest/count/endpoint/pass/failure/exact-output locks and
  advanced the package status from the last mechanism name to `runtime-corpus-shipped`.
- [x] **ADDRESSED (verified)** — The permanent test and direct CLI command both execute 31 fixtures with 31 passes
  and zero failures.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 816 assertions; no runtime or fixture changed.
- [x] **LOCKSTEP** — Julia README, public book, roadmaps, task/index, architecture, live docs, Knowledge Map,
  package/CLI status, and `MEMORY.md` agree; `.6.2.5` is the sole active Julia frontier.

## `JULIA-BACKEND-PARITY.6.2.4.5.3` Public-Parser Leading Trivia Result

Public-entry evidence recorded on 2026-07-10:

- The Perl public parser wrapper resets its input position and skips only leading `[ \t]*\n` blank lines and
  `[ \t]*#...` comment lines. Direct generated descriptor handlers bypass that wrapper, explaining the historical
  `null` versus `/proj/foo` discrepancy without making indexed reads context-dependent.
- Julia now computes the same public start cursor before entering the top rule. The cursor update flows through
  the existing match-register seam; rule dispatch, regex selection, and direct access remain unchanged.
- A focused runtime minimal combines a blank line and an indented comment before `object:` and proves that the
  leading `\nobject:` action edge is skipped while the later version edge still runs. A separate scalar-held
  `payload[1]` assertion returns `"name"`, locking the non-regression side of the boundary.
- `ds_vhistory_version_entry` passes its checked-in Perl/Rust oracle output. Full `Pkg.test()` passes with 810
  assertions, status is `runtime-corpus-leading-trivia`, and the complete offset-68/limit-31 window is 31/31.
  `.6.2.4.6` owns the separate permanent window/no-drift closeout.

## `JULIA-BACKEND-PARITY.6.2.4.5.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Focused Julia corpus execution failed only at history object name: expected `null`,
  actual `/proj/foo`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Julia `runtime_parse(...)` constructed its public context at cursor zero;
  Perl `Runtime.pm` and Dart begin the top rule after leading blank/comment lines. Direct descriptor handlers
  intentionally bypass the public wrapper, so the mismatch was not an indexed-access defect.
- [x] **FIX** — Added a byte-safe public start-cursor scan and initialized Julia's existing cursor/register seam
  before top-rule execution.
- [x] **ADDRESSED (verified)** — Focused leading-trivia and ordinary indexed-read assertions pass;
  `ds_vhistory_version_entry` and the complete 31-case shipped window pass.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 810 assertions; CLI status/help and documentation/
  governance gates pass.
- [x] **LOCKSTEP** — Package status, Julia README, roadmaps/live docs, task tree, mdBook, and Knowledge Map agree;
  `.6.2.4.6` owns final no-drift.

## `JULIA-BACKEND-PARITY.6.2.4.5.2` Statement Regex Mutation Result

Mutation evidence recorded on 2026-07-10:

- Julia now distinguishes statement regex substitution from pure string slicing before pure-helper evaluation.
  A dropped four-argument `substr(...)` / `regex_subst(...)` call with a bare scalar first argument mutates that
  scalar; shorter/numeric `substr(value, start, width)` calls keep their existing pure value behavior.
- Regex literals and string patterns reuse the strict helper compiler. `i`/`m`/`s`/`x` compile, `g` replaces all
  matches, `o` is an accepted compatibility no-op, unknown flags/patterns fail with rule attribution, and `$n`
  replacement placeholders expand from the current match.
- Focused coverage locks global quote removal, global and first-only capture substitution, case-insensitive global
  replacement, unchanged standalone numeric slicing, and unchanged value-form slicing. The quote-removal pattern
  uses the variant-agnostic single-quoted string form shared by Perl, Rust, Dart, and Julia; exact parser locks in
  all four current backends preserve the embedded double quote and `\s` regex escape. All authored multiline
  statements use newline separators without trailing semicolons.
- `ebnf_expression_rules`, `ebnf_logging_annotation`, `simenv_multiline_value`, `lib_reader_sattribute`, and
  `lib_reader_cattribute` now pass their checked-in Perl/Rust oracle output. The existing explicit split-target
  mutation composes with scalar cleanup for lib_reader and simenv.
- Full `Pkg.test()` passes with 808 assertions. The shipped window is 30/31; only
  `ds_vhistory_version_entry` remains, already owned by `.6.2.4.5.3`. Status is
  `runtime-corpus-statement-mutation`.
- The touched mdBook mutation example now uses newline separators without trailing semicolons. A focused scan also
  found broader historical line-ending semicolons elsewhere on that page; a clean-tree reactivation of
  `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT` must own that separate sweep rather than expanding this runtime leaf.

## `JULIA-BACKEND-PARITY.6.2.4.5.1` Terminating Exit Control Result

Runtime-control evidence recorded on 2026-07-10:

- Julia now recognizes `exit_now(...)` before generic helper fallback, evaluates the optional first status
  expression, and throws immediately. Explicit numeric status is preserved; absent or nonnumeric status uses the
  Rust-compatible default `1`.
- The exception message includes the current rule, and the existing rule/runtime wrappers attach structured
  `runtime_execution` diagnostics with top-rule, rule, spec-name, and spec-path attribution where available.
- Focused runtime coverage proves `exit_now(7)`, default `exit_now(1)`, and that a following return is unreachable.
- `simenv_multiline_value` no longer reports unsupported `exit_now`; it deliberately terminates as
  `exit_now(1) in rule begin_end_blocks`. The fatal branch is reached because the preceding statement-form
  `substr(...)` has not yet mutated the block-name scalar, so `.6.2.4.5.2` owns that independent prerequisite.
- The complete shipped window remains 25/31: two EBNF quote residuals, simenv mutation, history leading trivia,
  and two lib_reader quote residuals. Full `Pkg.test()` passes with 801 assertions and status
  `runtime-corpus-exit-now`.

## `JULIA-BACKEND-PARITY.6.2.4.4` Action-Edge Child Push Result

Structural-output evidence recorded on 2026-07-10:

- Julia debug traces showed EBNF and spec.spec child rules returning correct structures through the current action
  edge, while the parent action block treated `push(child, target)` as ordinary target/value append and lost them.
- Julia now gives compiled-rule first arguments the documented child-call precedence for one to three arguments.
  The current edge's cached child result is reused; other child labels execute normally. A literal nonnegative
  final index selects from the child array before append.
- Focused runtime coverage locks implicit whole, explicit whole, implicit indexed, and explicit indexed forms.
  All four spec.spec smokes pass unchanged.
- Both EBNF fixtures now retain complete rule/token/logging structures. Their only residual is quoted string text:
  statement-form regex `substr(...)` currently does not mutate its scalar target. That independent mechanism is
  routed with lib_reader to `.6.2.4.5.2`.
- Full `Pkg.test()` passes with 793 assertions; the complete shipped window moves from 21/31 to 25/31, and status
  is `runtime-corpus-action-edge-child-push`.

## `JULIA-BACKEND-PARITY.6.2.4.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Child rules returned correct structures, but EBNF/spec.spec parent arrays lost every
  action-edge child payload.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_call_runtime_push!` handled two arguments only as `(target, value)` and had
  no all-bare child/target or literal child/index precedence.
- [x] **FIX / SPLIT** — Added all four documented action-edge child-push forms and routed the newly exposed EBNF
  statement-mutation residual to `.6.2.4.5.2`.
- [x] **ADDRESSED (verified)** — Four spec.spec fixtures pass; both EBNF fixtures preserve their complete
  structures and are locked at quote-only mismatches.
- [x] **NO REGRESSION** — Full `Pkg.test()` passes with 793 assertions; shipped smoke is 25/31.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, child-push mdBook handoff, Knowledge Map,
  architecture/live docs, package status, and `MEMORY.md` advance to `.6.2.4.5.1`.

## `JULIA-BACKEND-PARITY.6.2.4.3` Recursive Rule Scope Result

Recursive-rule evidence recorded on 2026-07-10:

- Julia trace showed every recursive `sexpr` frame executing its `I` reset against one shared `items` store. The
  deepest frame therefore overwrote the parent's accumulator, producing `b`-rooted and duplicated LX outputs.
- Each rule invocation now pushes an empty binding-snapshot map. The first explicit array/hash reset captures all
  existing scalar/array/hash representations for that name; rule exit removes the local value and restores the
  captured caller binding. Explicit split-target replacement spends the same reset seam.
- Ordinary `push(...)`/append mutation without an explicit reset does not create a snapshot and remains
  caller-visible. Registered user functions suppress rule-local tracking because their established execution path
  swaps and restores the complete typed stores independently.
- Focused runtime tests lock nested array/hash reset restoration and undeclared child mutation visibility. The
  three recursive top-rule corpus fixtures pass unchanged, the full window moves from 18/31 to 21/31, full
  `Pkg.test()` passes with 785 assertions, and status is `runtime-corpus-recursive-rule-scope`.

## `JULIA-BACKEND-PARITY.6.2.4.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — All three recursive fixtures executed but leaked the deepest `items` accumulator
  into caller frames, corrupting body-recursive and top-LX values.
- [x] **ROOT CAUSE (WHY + WHERE)** — Julia scoped match registers per `_execute_runtime_rule!` call but shared
  typed stores globally; `_call_runtime_set!` overwrote array/hash bindings without a per-rule snapshot.
- [x] **FIX** — Added first-reset rule-local binding snapshots/restoration for explicit array/hash replacement,
  with ordinary mutations shared and user-function store isolation preserved.
- [x] **ADDRESSED (verified)** — Focused trace/mechanism tests pass and all three checked-in recursive fixtures are
  exact oracle matches.
- [x] **NO REGRESSION** — Full `Pkg.test()` passes with 785 assertions; shipped smoke is 21/31 with no new failure.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, runtime-scope mdBook handoff, Knowledge Map,
  architecture/live docs, package status, and `MEMORY.md` advance to `.6.2.4.4`.

## `JULIA-BACKEND-PARITY.6.2.4.2.2` Diagnostic Output Result

Diagnostic-output evidence recorded on 2026-07-10:

- `print(...)` concatenates evaluated arguments, `say(...)` adds a newline, and `print_each(...)` walks an array
  with optional prefix/suffix text. All return `nothing`, so diagnostic side effects never enter parser output.
- Julia routes diagnostic messages through the configured `LinkedSpecTraceEmitter` at low level. With tracing
  absent or disabled the helpers remain quiet, preserving default execution and corpus-runner output.
- `simenv_multiline_value` advances from unsupported `print` to unsupported `exit_now`; that control helper and
  later statement-mutation behavior remain outside this leaf. `ds_vhistory_version_entry` advances to the exact
  expected-null versus actual-`/proj/foo` output boundary already documented for the public-parser leading-newline
  wrapper. The later structural/parity leaves own those mechanisms.
- The permanent regression locks both advanced failure classes and explicitly rejects renewed unsupported-`print`
  failures. Full `Pkg.test()` passes with 780 assertions; the complete shipped window remains 18/31 with no
  regression, and status is `runtime-corpus-diagnostic-output`.

## `JULIA-BACKEND-PARITY.6.2.4.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Both routed fixtures stopped on unsupported runtime helper `print`.
- [x] **ROOT CAUSE (WHY + WHERE)** — ActionIR already parsed and classified the helper calls, but the Julia
  interpreter had no diagnostic-output dispatcher or sink integration.
- [x] **FIX** — Added eager diagnostic helper dispatch and low-level trace-sink emission with parse-result-neutral
  return behavior.
- [x] **ADDRESSED (verified)** — Focused runtime output is correct, and both shipped fixtures advance beyond
  unsupported `print` to precise successor-owned mechanisms.
- [x] **NO REGRESSION** — Full `Pkg.test()` passes with 780 assertions; shipped smoke remains 18/31.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, debug-output mdBook contract, Knowledge Map,
  architecture/live docs, package status, and `MEMORY.md` advance to `.6.2.4.3`.

## `JULIA-BACKEND-PARITY.6.2.4.2.3` Helper Regex Flag Result

Helper-regex evidence recorded on 2026-07-10:

- Julia helper regex compilation now keeps meaningful `i`, `m`, `s`, and `x` flags, treats execution-only `g` and
  Perl compile-once `o` as compile-time no-ops, and still rejects any unknown flag or invalid pattern.
- `matches(...)` and regex-delimiter `split(...)` spend the same normalization seam; focused runtime coverage locks
  case-insensitive `igo`, delimiter `go`, and invalid `q` behavior.
- `portmap_constant` now returns the exact expected `[["?constant:",["0x1f"]]]`. The permanent logical corpus
  regression advances from a routed residual to all five logical/portmap/tablegrep cases passing.
- The complete shipped-spec/parser-smoke window moves from 17/31 to 18/31 with 13 remaining failures unchanged.
  Full `Pkg.test()` remains green with 772 assertions and status `runtime-corpus-helper-regex-flags`.

## `JULIA-BACKEND-PARITY.6.2.4.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `matches("0x1f", /^\d/io)` returned false because Julia rejected flag `o`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Both pure `matches` and regex `split` passed raw DSL flags directly to
  `Regex`; helper execution flags and Perl compatibility flags were not separated from compile flags.
- [x] **FIX** — Added one strict helper-regex compiler that keeps `imsx`, ignores `go`, and rejects everything else.
- [x] **ADDRESSED (verified)** — Focused `igo`/`go`/invalid-`q` coverage passes and `portmap_constant` matches the
  checked-in Perl/Rust expected JSON exactly.
- [x] **NO REGRESSION** — Full `Pkg.test()` passes with 772 assertions; shipped smoke is 18/31 with no new failure.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, helper mdBook contract, Knowledge Map, architecture/live
  docs, package status, and `MEMORY.md` advance to `.6.2.4.2.2`.

## `JULIA-BACKEND-PARITY.6.2.4.2.1` Logical Helper Result

Logical-helper evidence recorded on 2026-07-10:

- `and`, `or`, and `not` are normal eager value helpers, matching Perl call evaluation and the Rust runtime.
  Julia evaluates every argument first, applies the existing scalar/number/string/aggregate truthiness contract,
  and returns booleans. Empty `and`, `or`, and `not` return false, false, and true respectively.
- Focused runtime coverage locks ordinary truthiness, empty arities, and eager assignment side effects.
- A permanent corpus regression locks `portmap_bare`, `portmap_bit`, `portmap_concatenation`, and
  `tablegrep_simple_term` at 4/4 and proves `portmap_constant` no longer fails on unsupported `or`.
- The remaining constant mismatch is not logical: a direct compiled-rule match returns compacted capture
  `["0x1f"]`, but helper `matches(..., /^\d/io)` passes `io` to Julia `Regex`; the unsupported no-op `o` causes
  compilation to fail and the predicate to return false. `.6.2.4.2.3` owns that exact flag bridge.
- The full shipped-smoke window moves from 13/31 to 17/31 with 14 unchanged failures. Full tests pass with 772
  assertions and status `runtime-corpus-logical-helpers`.

## `JULIA-BACKEND-PARITY.6.2.4.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Four portmap cases and tablegrep initially stopped on unsupported `or` / `not`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Action contracts already recognized the calls, but the Julia pure-helper set
  and dispatcher omitted them. The portmap constant residual is independently caused by helper regex flag `o`.
- [x] **FIX / SPLIT** — Added eager boolean composition through `_runtime_truthy`; split the exact no-op regex flag
  residual to `.6.2.4.2.3` rather than broadening the logical-helper change.
- [x] **ADDRESSED (verified)** — Focused truthiness/eagerness coverage passes, four corpus cases pass, and the fifth
  is an output mismatch with direct capture/regex evidence instead of an unsupported logical helper.
- [x] **NO REGRESSION** — Full `Pkg.test()` passes with 772 assertions; shipped smoke is 17/31 with no new failure.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, boolean-helper mdBook contract, Knowledge Map,
  architecture/live docs, package status, and `MEMORY.md` advance to `.6.2.4.2.3`.

## `JULIA-BACKEND-PARITY.6.2.4.1` Anonymous Capture Boundary Result

Capture-boundary evidence recorded on 2026-07-10:

- Julia now executes `start_capture_slice`, match-start readers `capture_slice` / `capture_slice_len`, cursor
  readers `capture_slice_until_cursor` / `_len`, input-end readers `capture_rest` / `_len`, origin location readers
  `capture_slice_pos` / `_line` / `_col`, and all direct destructive `capture_take*` variants.
- Text slicing is code-unit safe and reported lengths/positions are character-based. Focused runtime coverage uses
  `é` plus a newline to lock Unicode length, character offset, line/column, match-start versus cursor endpoints,
  and destructive origin movement through cursor and end-of-input.
- A permanent corpus regression locks `hlink_curly_brace`, `hlink_bracket_body`, and
  `hlink_mixed_bracket_brace` at 3/3. They previously stopped on unsupported `capture_slice`.
- `ebnf_logging_annotation` no longer stops on `start_capture_slice`; it now produces the same missing structural
  item class as `ebnf_expression_rules` and is routed to `.6.2.4.4` rather than overclaimed as capture parity.
- The full shipped-spec/parser-smoke window moves from 10/31 to 13/31. The remaining 18 failures are unchanged:
  five logical helpers, two diagnostic-output helpers, three recursive outputs, six structural outputs, and two
  lib_reader quote-normalization cases.

## `JULIA-BACKEND-PARITY.6.2.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Three hlink cases failed on unsupported `capture_slice`; EBNF logging failed on
  unsupported `start_capture_slice`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Action contracts recognized the anonymous helpers and runtime registers
  already carried the rule-local capture origin, but `julia/src/runtime/Interpreter.jl` had no execution dispatch.
- [x] **FIX** — Added one direct anonymous-family dispatcher over existing match registers, preserving distinct
  match-start, live-cursor, and end-of-input endpoints plus destructive take semantics.
- [x] **ADDRESSED (verified)** — Focused runtime tests lock Unicode-safe values, lengths, locations, and mutations;
  three hlink cases pass, and EBNF logging is no longer blocked by a capture helper.
- [x] **NO REGRESSION** — Full `Pkg.test()` passes with 766 assertions; the 31-fixture window is 13/31 with no new
  failure, and the EBNF residual is routed to `.6.2.4.4`.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, mdBook, Knowledge Map, architecture/live docs, package
  status, and `MEMORY.md` record capture-boundary parity and advance to `.6.2.4.2.1`.

## `JULIA-BACKEND-PARITY.6.2.4.0` Shipped Corpus Smoke Split

Planning evidence recorded on 2026-07-10:

- `julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`
  reports 10 passed and 21 failed.
- Passing fixtures are both tclite cases, `lispish_x_y`, both raw hlink cases, `portmap_slice`,
  `regdef_nested_register_fields`, `vhdl_library_use`, `pplugin_empty`, and `tkgui_empty`.
- Unsupported capture-boundary helpers block three hlink delimiter cases plus `ebnf_logging_annotation`; `.6.2.4.1`
  owns the shared anonymous boundary family.
- Unsupported `or`/`not` blocks four portmap cases and `tablegrep_simple_term`; `.6.2.4.2.1` owns logical helpers.
  Unsupported `print` blocks simenv and history cases; `.6.2.4.2.2` owns diagnostic-output helpers.
- Three recursive top-rule cases produce incorrect nested/caller values and are isolated under `.6.2.4.3`.
- `ebnf_expression_rules` plus four spec.spec smokes execute but lose structural records; `.6.2.4.4` owns that
  output-shape group and must split again if it contains independent parser/runtime mechanisms.
- Two lib_reader cases retain source quotes in group/value payloads; `.6.2.4.5` owns statement mutation and quote
  normalization. `.6.2.4.6` owns final 31/31 regression and no-drift closeout.
- Checked-in expected JSON is the Perl/Rust oracle. Completed Dart shipped-smoke facts provide the cross-backend
  mechanism reference without assuming that Julia shares Dart's historical implementation causes.

## `JULIA-BACKEND-PARITY.6.2.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The full bounded 31-fixture window was executed before any `.6.2.4` source change.
- [x] **ROOT CAUSE (WHY + WHERE)** — The diagnostic distinguishes explicit unsupported-helper failures from
  already-executing recursive, structural-output, and quote-normalization mismatches; deeper causes remain owned by
  the corresponding implementation leaves rather than guessed in this planning slice.
- [x] **FIX / SPLIT** — Created recoverable owners for capture boundaries, logical/output helpers, recursion,
  structural output, quote normalization, and final no-drift; logical and output helpers are separate children.
- [x] **ADDRESSED (verified)** — All 21 failures and all 10 passing fixtures are accounted for exactly once.
- [x] **NO REGRESSION** — No Julia source, tests, fixtures, package status, or runtime behavior changed.
- [x] **LOCKSTEP** — Task/index/roadmaps, live docs, mdBook, Knowledge Map, architecture, and `MEMORY.md` record the
  10/31 boundary and `.6.2.4.1` frontier.

## `JULIA-BACKEND-PARITY.6.2.3` Middle Corpus Batch Result

Middle-batch evidence recorded on 2026-07-10:

- Bounded runner windows `--offset 40 --limit 17`, `--offset 58 --limit 2`, and `--offset 62 --limit 6` report
  17/17, 2/2, and 6/6 passing respectively, for 25 non-function fixtures and zero failures.
- The windows cover attached while, deep helper composition, bare aggregate args, inline if/switch values, bare
  values/case labels, array/hash/string/number receiver chains, numeric reducers, word/symbol arithmetic and
  comparison aliases, aggregate and mutation assignment expressions, block-valued receiver chains, helper and
  receiver `with` blocks, hash/array tree traversal, and quoted typed-wrapper names.
- No Julia parser/runtime correction and no fixture change was required; existing helper/control/callback semantics
  already match all checked-in expected JSON in these windows.
- Manifest offsets `57`, `60`, and `61` are explicitly excluded and locked as
  `terse_3_3_1_scalar_assignment_expressions`, `terse_3_3_4_assignment_expression_closure`, and
  `terse_4_3_2_user_function_runtime`. They contain top-level `fn` source and remain owned by `.6.2.5`.
- `julia/test/runtests.jl` permanently executes all three non-function windows and asserts sizes, endpoints,
  25 results/passes, empty failures, and exact routed function cases.

## `JULIA-BACKEND-PARITY.6.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.6.2.3` required all non-function middle fixtures 40–67 to pass unchanged or route
  each Julia mismatch with shared oracle evidence, while preserving the separate function-shell owner.
- [x] **ROOT CAUSE (WHY + WHERE)** — No non-function mismatch exists: all three bounded windows were green before
  source edits. The only omitted offsets are the three pre-owned top-level function fixtures.
- [x] **FIX** — Added only a permanent three-window regression test and advanced status to
  `runtime-corpus-middle`; production parser/runtime and fixtures remain unchanged.
- [x] **ADDRESSED (verified)** — Direct bounded runs total 25 passed / 0 failed, and six focused assertions lock the
  windows, endpoints, counts, empty failure ledger, and exact `.6.2.5` routes.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 757 assertions; starter 40/40, selection/reporting,
  controlled execution, and all earlier frontend/runtime tests remain green.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, mdBook corpus/status/check pages, Knowledge Map,
  architecture/live docs, and `MEMORY.md` record 25/25 and advance to shipped-spec fixtures 68–98.

## `JULIA-BACKEND-PARITY.6.2.2` Starter Corpus Batch Result

Starter-batch evidence recorded on 2026-07-10:

- `julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 0 --limit 40`
  reports 40 `PASS` rows, 0 `FAIL` rows, and exits `0`.
- The window begins at `proof_edge_array_literal` and ends at `terse_2_2_5_2_attached_switch_blocks`, matching
  manifest offsets 0 through 39 exactly.
- The green batch covers proof-edge scalar/array returns, declared/undeclared autoexist behavior, bare scalar/array/
  hash reads, copy/wrapper behavior, return/assignment/mutation reads, shape literals, duck-typed replacement,
  nested mixed-path assignment, `set`/`cat`/`copy`, push/set-key/assignment operators, primitive booleans/null,
  call spacing, newline statement separation, direct nested access, array-end mutation, expression-valued blocks,
  early block returns, attached if/when/otherwise, and attached switch.
- No Julia parser/runtime correction and no fixture change was required. The existing `.4`/`.5` implementation
  already matched the Perl/Rust expected JSON for every starter case.
- `julia/test/runtests.jl` now permanently executes this bounded window and asserts manifest count, exact endpoints,
  40 results, 40 passes, and an empty failure ledger.

## `JULIA-BACKEND-PARITY.6.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.6.2.2` required the first 40 shipped fixtures to execute through Julia or route
  every mismatch with shared oracle evidence.
- [x] **ROOT CAUSE (WHY + WHERE)** — No mismatch exists in this window: the bounded runner produced 40/40 before
  any source edit, so there is no runtime root cause to classify or fix.
- [x] **FIX** — Added only a permanent bounded corpus regression test and advanced package status to
  `runtime-corpus-starter`; production parser/runtime and fixtures remain unchanged.
- [x] **ADDRESSED (verified)** — Direct runner output is 40 passed / 0 failed, and six focused assertions lock the
  exact window and empty failure ledger in `Pkg.test()`.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 751 assertions; controlled execution, selection,
  validation-only loading, diagnostics, trace, functions, and earlier frontend/runtime suites remain green.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, mdBook corpus/status/check pages, Knowledge Map,
  architecture/live docs, and `MEMORY.md` record 40/40 and advance to middle non-function fixtures 40–67.

## `JULIA-BACKEND-PARITY.6.2.1` Executable Corpus Selection Result

Selection/reporting evidence recorded on 2026-07-10:

- `execute_corpus_fixtures(...)` now accepts ordered `case_names` or zero-based `offset` plus optional positive
  `limit`. Named order is preserved; oversized limits cap at the manifest end.
- Library selection rejects negative/non-integer offsets, non-positive/non-integer limits, out-of-range offsets,
  missing names, duplicate names, and named-plus-window combinations with `CorpusManifestException`.
- `run_corpus_runner(...)` and the Julia-specific `corpus` command accept separate or `--flag=value` forms for
  `--corpus`, repeated `--case`, `--offset`, and `--limit`.
- Bounded execute mode prints `PASS <name>` or `FAIL <name>: <detail>` for every selected fixture, prints a stable
  passed/failed summary, returns `0` for all-pass, and returns `1` for fixture failures.
- Selection flags without `--execute`, invalid numeric flags, and mixed named/window selectors return usage error
  `2`. While full parity is incomplete, CLI execution must include `--case` or `--limit`; an unbounded request and
  offset-only request are rejected before loading/executing fixtures.
- Validation-only default behavior remains unchanged and still validates the complete 99-fixture manifest.

## `JULIA-BACKEND-PARITY.6.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.6.1` could execute only the complete loaded fixture list from library code, while
  the corpus runner rejected every `--execute` request and provided no recoverable shipped-batch command.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/corpus/CorpusManifest.jl` had no fixture selector, selection
  validation, execute-mode argument parser, per-fixture reporting loop, or incomplete-parity unbounded guard.
- [x] **FIX** — Added library `case_names`/`offset`/`limit` selection, strict diagnostics, bounded runner execution,
  stable PASS/FAIL summaries and exit codes, expanded Julia-specific CLI help, and status
  `runtime-corpus-selection`.
- [x] **ADDRESSED (verified)** — Thirty added assertions prove named order, bounded/capped windows, all selection
  errors, named/bounded CLI success, mismatch reporting/exit, selector fences, unbounded rejection, and help/status.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 745 assertions; validation-only 99-fixture loading is
  unchanged and unbounded execution remains unavailable until the later full-gate leaf.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, mdBook command/API/status pages, Knowledge Map,
  architecture/live docs, and `MEMORY.md` advance the frontier to starter fixtures 0–39 under `.6.2.2`.

## `JULIA-BACKEND-PARITY.6.2.0` Corpus Expansion Split Result

Planning evidence recorded on 2026-07-10:

- `.6.2.1` owns named/offset/limit library selection plus bounded opt-in corpus-runner execution/reporting while
  validation-only default behavior remains intact.
- `.6.2.2` owns manifest fixtures 0–39: proof-edge, autoexist, core store/mutation, primitive helper, and early terse
  runtime behavior.
- `.6.2.3` owns non-function fixtures 40–67: value blocks, controls, helper composition, receivers, helper-family
  breadth, with-blocks, and tree traversal.
- `.6.2.4` owns fixtures 68–98: shipped-spec and parser-smoke behavior. It must run a diagnostic window and split
  observed Julia failure clusters before implementation if the window is not already green.
- `.6.2.5` owns top-level `fn` fixtures through `specs/user_function_definition.spec` and staged body projection;
  no Julia raw scanner or fixture-specific semantic shortcut is allowed.
- These ranges reuse the proven Dart rollout only as stable workload boundaries. Julia behavior changes require a
  reproduced Julia failure and shared oracle evidence; Dart-specific fixes are not assumed to apply.

## `JULIA-BACKEND-PARITY.6.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.6.2` originally represented the full 99-fixture rollout as one leaf, too broad for
  per-slice commits and recoverable root-cause ownership.
- [x] **ROOT CAUSE (WHY + WHERE)** — The task tree lacked a selection/reporting prerequisite and separate owners
  for early terse, middle helper/control, shipped-spec smoke, and spec-defined function-shell mechanisms.
- [x] **FIX** — Added `.6.2.1` through `.6.2.5` with explicit ranges, behavior boundaries, and oracle/no-weakening
  constraints before any parser/runtime change or broad diagnostic execution.
- [x] **ADDRESSED (verified)** — The current frontier is the single safe prerequisite `.6.2.1`; every subsequent
  manifest family has one durable owner and can split again from measured Julia evidence.
- [x] **NO REGRESSION** — Planning/docs only; Julia source, fixtures, runtime output, and the green 715-assertion
  `runtime-controlled-corpus` implementation are unchanged.
- [x] **LOCKSTEP** — Task/index/roadmaps, Julia README, mdBook status/handoff, Knowledge Map, architecture/live docs,
  and `MEMORY.md` agree that `.6.2.1` bounded selection/reporting is next.

## `JULIA-BACKEND-PARITY.6.1` Controlled Corpus Execution Result

Controlled execution evidence recorded on 2026-07-10:

- `julia/src/corpus/CorpusManifest.jl` now exports `CorpusExecutionResult`,
  `CorpusFixtureExecutionResult`, `execute_corpus_fixtures(...)`, and focused result-query helpers.
- The executor reuses manifest validation, runs each fixture through parse, validation/compile, and
  `LinkedSpecRuntimeEngine`, and compares runtime `output` to `[expected.json]` using structural equality.
- Every manifest fixture receives a result even when an earlier fixture fails. Failure text distinguishes parse,
  validate, compile, execute, no-match, output-mismatch, and unexpected boundaries.
- Results preserve the actual value/output, match/cursor state, captured trace lines, and structured runtime
  diagnostic when present. Engine identity points diagnostics at the fixture name and `input.spec` path.
- An optional `spec_parser` callback is the controlled seam for already-projected staged function shells. The
  default remains direct `parse_spec(...)`; raw/source-driven function-shell execution belongs to shipped-corpus
  expansion rather than being overclaimed here.
- Authored fixtures prove scalar output, nested hash/array/null/boolean shape, blind AND dispatch, lifecycle return
  shape, earliest boundary capture with debug trace evidence, and an exact-arity staged function call. A second
  corpus proves runtime diagnostic preservation, output mismatch reporting, and continued execution afterward.
- Multiline action blocks use newline separators and no trailing semicolons. The fixture style therefore matches
  the canonical language rule that semicolons only separate adjacent same-line statements.

## `JULIA-BACKEND-PARITY.6.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia could validate the 99-fixture manifest but exposed no library execution result,
  wrapped-output comparator, or per-fixture failure accumulator for controlled proofs.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/corpus/CorpusManifest.jl` stopped after loading fixtures, while the
  already-green parser/compiler/runtime/trace/diagnostic layers had no corpus owner composing them.
- [x] **FIX** — Added public execution/result/query APIs, structural wrapped-output comparison, trace/diagnostic
  retention, failure-stage attribution, and all-fixture continuation. Advanced status to
  `runtime-controlled-corpus` while leaving CLI `--execute` deliberately unavailable.
- [x] **ADDRESSED (verified)** — Twenty-four focused assertions prove six passing controlled fixtures plus
  diagnostic/mismatch continuation, including functions, boundary trace lines, and structured diagnostic identity.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 715 assertions; manifest-only CLI validation remains
  green and `--execute` stays explicitly rejected until the later corpus command leaf.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, mdBook API/status/handoff/check pages, Knowledge Map,
  architecture/live docs, and `MEMORY.md` close `.6.1` and advance to `.6.2` batch decomposition/execution.

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
  src/action/ActionAst.jl
  src/action/ActionParser.jl
  src/action/FunctionRegistry.jl
  src/action/ActionContracts.jl
  src/compiler/CompiledSpec.jl
  bin/linkedspec_julia.jl
  bin/corpus_runner.jl
  test/runtests.jl
```

Implemented frontend/action/compiler subtrees are `src/spec/`, `src/action/`, and `src/compiler/`. Planned future
implementation subtree remains deferred to later leaves: `src/runtime/`.

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

## `JULIA-BACKEND-PARITY.2.3` Source Validation Result

Source validation evidence recorded on 2026-07-10:

- `julia/src/spec/Validator.jl` adds `validate_spec(spec; strict_syntax=false)` and
  `SpecValidationException`.
- The validator checks top-rule presence, duplicate rule labels, duplicate user function names, user-function
  registry collisions with rule labels / runtime symbols / lifecycle markers / ActionIR helper-control names, invalid
  function names and params, parameter duplicates, arity mismatches, raw fallback lines, mixed action/blind-call edge
  families, grouped action-edge targets without a shared block, undefined edge targets, target regex-slot bounds,
  structural regex errors, and strict unused-rule behavior.
- Focused tests mirror the Dart frontend validation cases and add coverage for Julia arity mismatch handling.
- Validation smoke tests cover all 21 checked-in `specs/*.spec` files and rule-only corpus `input.spec` files while
  top-level `fn` corpus shells remain intentionally skipped until `.2.4`.

## `JULIA-BACKEND-PARITY.2.4` Function-Definition Shell Projection Result

Function-shell projection evidence recorded on 2026-07-10:

- `julia/src/spec/UserFunctionDefinitionShell.jl` adds `project_user_function_definition_asts(source, nodes)`,
  `parse_spec_with_user_function_definition_asts(source, nodes)`, and
  `definition_nodes_from_user_function_definition_output(output)`.
- Julia consumes the neutral `function_definition` / `function_definition_error` AST shape owned by
  `specs/user_function_definition.spec`; it does not add a competing host-language scanner for top-level `fn`
  shells.
- Projection validates name/params/arity, source and body spans, `body_payload`, `body_parse_job`, parser/top-rule
  sidecar identity, result/failure policies, and diagnostic owner, then normalizes parent AST paths and body-parse
  job IDs to `functions.<index>.body_source`.
- Function-definition source spans are replaced with spaces while preserving newlines before rule parsing, so
  `parse_spec(...)` remains rule-only and callers with spec-returned function nodes use
  `parse_spec_with_user_function_definition_asts(...)`.
- Focused tests cover successful projection, malformed error nodes, sidecar drift rejection, output wrapper
  normalization, stripped rule parsing, and validation of the resulting `SpecFile`.

## `JULIA-BACKEND-PARITY.3.1` ActionIR AST Parser Result

ActionIR parser evidence recorded on 2026-07-10:

- `julia/src/action/ActionAst.jl` adds typed Julia records and JSON projection for `action_block`,
  `action_stmt`, call/argument nodes, variables, indexed/nested access segments, array/hash literals, block values,
  string/number/boolean/regex/undef literals, scalar/array/hash/nested assignment nodes, receiver fluent chains,
  structured control nodes, and `raw_perl` fallback nodes.
- `julia/src/action/ActionParser.jl` exposes `parse_action_block(...)`, `parse_action_statement(...)`, and
  `parse_action_expression(...)`.
- The parser splits top-level value-drop statements, protects delimiters inside strings/regex literals and nested
  delimiters, parses helper and receiver trailing-block arguments, preserves receiver chains as `fluent_chain`
  nodes, and keeps unsupported expressions structural as `raw_perl` rather than rewriting text.
- Focused tests mirror the Dart ActionIR parser contract for calls, literals, nested access, shape literals,
  assignments, assignment receiver chains, receiver chains, trailing blocks, quoted delimiter arguments, block
  values, attached if/elseif/else/while/switch controls, and unsupported raw fallback expressions.
- The package parity status is now `action-ast-parser`. Contract resolution, user-function resolution,
  compilation, runtime behavior, staged parser execution, diagnostics/trace, and corpus execution remain later
  leaves.

## `JULIA-BACKEND-PARITY.3.2` ActionIR Contract Resolver Result

ActionIR contract resolver evidence recorded on 2026-07-10:

- `julia/src/action/ActionContracts.jl` adds JSON-shaped `ActionResolvedContract`,
  `ActionContractDiagnostic`, and `ActionContractResolution` records plus public
  `resolve_action_block_contracts(...)`, `resolve_action_statement_contracts(...)`,
  `resolve_action_expression_contracts(...)`, `canonical_action_helper_name(...)`, and
  `is_known_action_ir_call_name(...)`.
- The resolver walks typed calls, receiver methods, structural assignment nodes, structured controls, nested
  arguments, block values, shape literals, indexed/nested access expressions, and raw fallback expressions.
- Current aliases canonicalize through the same contract table as Dart: numeric aliases and symbols resolve to
  `num_*`; `when`/`i` resolve to `if`; `elif` resolves to `elseif`; `otherwise` resolves to `else`; `=` resolves
  to `set`.
- Helper-looking calls outside the current canonical contract table produce generic `unknown_helper` diagnostics,
  and `raw_perl` fallback nodes produce explicit `raw_perl` diagnostics. Julia does not carry a non-current helper
  spelling table or a host-language fallback call path.
- `julia/src/spec/Validator.jl` now shares `is_known_action_ir_call_name(...)` for user-function collision checks
  instead of maintaining a second helper/control name list.
- The package parity status is now `action-contracts`. Function-registry-aware exact-arity user-call
  classification, compiled state, runtime behavior, staged parser execution, diagnostics/trace, and corpus
  execution remain later leaves.

## `JULIA-BACKEND-PARITY.3.3` User-Function Registry Result

User-function registry evidence recorded on 2026-07-10:

- `julia/src/action/FunctionRegistry.jl` adds `UserFunctionRegistry`, `UserFunctionEntry`,
  `UserFunctionCallResolution`, and `UserFunctionRegistryException`.
- `user_function_registry_from_spec(...)` and `user_function_registry_from_functions(...)` build ordered entries
  from parsed `FunctionDefinition` records and reject duplicate user-function names before compiled-state work.
- Registry entries preserve params, arity, source/body spans, `body_payload`, `body_parse_job`, and optional
  `body_ast`; `body_parse_jobs(...)` exposes the stable staged function-body parse-job queue.
- `stitch_function_body_ast(...)` returns an updated immutable `SpecFile` with a staged job result installed into
  `body_ast` when the parse job's `replace_field` / `body_ast` policy matches.
- `resolve_action_block_contracts(...)`, `resolve_action_statement_contracts(...)`, and
  `resolve_action_expression_contracts(...)` now accept `function_registry=...`. Exact-arity registered user calls
  classify as `family = user_function` before helper fallback; wrong-arity registered calls produce
  `user_function_arity_mismatch`.
- The package parity status is now `function-registry`. Compiled state, runtime behavior, staged parser execution,
  diagnostics/trace, and corpus execution remain later leaves.

## `JULIA-BACKEND-PARITY.3.4` Compiled-Spec State Result

Compiled-state evidence recorded on 2026-07-10:

- `julia/src/compiler/CompiledSpec.jl` adds `CompiledSpecException`, `CompiledSpec`, `CompiledRule`,
  `CompiledRuleModeMetadata`, `DependencyRef`, `CompiledActionEdge`, `CompiledBlindEdge`,
  `CompiledActionPayload`, `CompiledDependencyRegexState`, `CompiledDependencyRegexEntry`, and
  `CompiledDescriptorState`.
- `compile_spec(spec; validate_source=true, strict_syntax=false)` reuses `validate_spec(...)` by default, builds the
  ordered `UserFunctionRegistry`, records `definition_order`, `compiled_rule_order`, `rules_by_label`, and
  `redefined_rule_labels`, and keeps last-definition-wins metadata available only when validation is deliberately
  skipped.
- Each compiled rule preserves source header/mode metadata, regex slots, dependency refs, action/blind edges,
  lifecycle/plain action payloads, and original body elements. Action payloads parse through `parse_action_block(...)`
  and resolve contracts with the compiled function registry, so exact-arity user calls remain classified before
  helper fallback inside compiled state.
- Dependency-regex state derives child-rule regex patterns into `CompiledDependencyRegexEntry` rows with dependency
  refs, pattern lists, and combined pattern strings; executable regex matching has since landed in `.4.1`.
- `to_json(compiled)` exposes the internal compiled-spec model; `to_descriptor_json(compiled)` projects the public
  descriptor-shaped `spec`, `functions`, `dependency_regex_map`, and `meta` shape with
  `julia_interpreter_rule` handlers marked `compiled_state_only`.
- At this leaf the package parity status was `compiled-state`; `.4.1` has since advanced it to `runtime-matching`.
  Executable rule dispatch, staged parser execution, diagnostics/trace, and corpus execution remain later leaves.

## `JULIA-BACKEND-PARITY.4.1` Runtime Matching Result

Runtime matching evidence recorded on 2026-07-10:

- `julia/src/runtime/Matching.jl` adds `LinkedSpecParseMode`, `RuntimeRegexAlternative`,
  `RuntimeRegexAlternation`, `RuntimeRegexMatch`, `RuntimeLineColumn`, `RuntimeMatchRegisters`, and
  `RuntimeRegexException`.
- `runtime_match(...)`, `seek_match(...)`, and `consume_match(...)` preserve stable zero-based alternative identity;
  seek mode selects the earliest match and breaks same-position ties by lower source alternative, while consume
  mode accepts only a match beginning at the cursor.
- Match records preserve the full group-slot vector with empty placeholders, the compact participating-capture
  vector, named captures, zero-based Julia code-unit spans, public character offsets, and line/column projection.
- `RuntimeMatchRegisters` tracks the code-unit cursor and capture start, separates rule-entry and current-local
  matches across child entry, and exposes immutable updates plus zero-width/zero-progress predicates.
- Native Julia `Regex`/PCRE probes cover Python-style and angle-bracket named captures, POSIX classes,
  inline/scoped flags, possessive quantifiers, and recursive `(?R)` directly; Julia therefore needs no Dart-like
  regex-dialect normalization at this boundary.
- At this leaf the package parity status was `runtime-matching`; `.4.2` has since advanced it to
  `runtime-dispatch`. Broader helper/value semantics, staged parser execution, diagnostics/trace, and corpus
  execution remain later leaves.

## `JULIA-BACKEND-PARITY.4.3.0` Helper/Value Split Result

Helper/value planning evidence recorded on 2026-07-10:

- The completed Dart helper rollout in `docs/tasks/DART-BACKEND-PARITY.md` was reused as sequencing evidence rather
  than rediscovering or bundling the complete helper catalog.
- `.4.3.1` owns scalar/array/hash/null/boolean/number value shape, store mutation/read semantics, direct/nested
  access, snapshots, and the `entry_*` / `match_*` capture families.
- `.4.3.2` owns current string/scalar and numeric pure helpers, lexical comparisons, numeric aliases/symbols, and
  compatible receiver chains.
- `.4.3.3` owns array-aware construction/flattening, snapshots, selection/order/membership/join/split bridges,
  end mutations, reducers, and receiver chains.
- `.4.3.4` owns hash-aware construction/flattening, snapshots, key/value views, merge/pick/drop/rename/set-key
  behavior, direct hash-index assignment, and receiver chains.
- `.4.3.5` owns expression-valued blocks, structured controls, helper/receiver trailing blocks, and hash/array tree
  traversal callbacks with scoped bindings.
- `.4.3.6` owns final helper/value no-drift against mdBook examples, focused Julia runtime coverage/status, live
  docs, and Knowledge Map facts before `.4.4` cursor-control work.

## `JULIA-BACKEND-PARITY.4.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3` named every runtime helper/value family in one broad leaf and explicitly
  required safe splitting before code if the surface could not land as one signoff-sized unit.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/runtime/Interpreter.jl` now has a deliberately narrow
  dispatch-facing evaluator, while `docs/tasks/DART-BACKEND-PARITY.md` proves that core stores/captures,
  string/numeric helpers, arrays, hashes, controls/blocks/callbacks, and no-drift each have distinct mechanisms and
  regression surfaces.
- [x] **FIX** — Converted `.4.3` into an active container with children `.4.3.0` through `.4.3.6`, matching those
  mechanism boundaries and making `.4.3.1` the single executable frontier.
- [x] **ADDRESSED (verified)** — Task-tree and roadmap state now identify one next code slice rather than a broad
  helper catalog; no Julia implementation behavior changed in this planning leaf.
- [x] **NO REGRESSION** — The committed `.4.2` `Pkg.test()` result remains 550 assertions; planning verification
  runs mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and whitespace gates.
- [x] **LOCKSTEP** — Task tree/index, roadmaps, README, mdBook status/handoff, Knowledge Map pointer, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` updated for the split.

## `JULIA-BACKEND-PARITY.4.3.1` Core Value/Store/Capture Result

Core runtime value evidence recorded on 2026-07-10:

- `_RuntimeExecutionContext` now separates scalar, array, and hash stores while bare reads and `copy(...)` resolve
  all three with copied JSON-safe values. Typed `array(name)` / `hash(name)` wrappers also read compatible
  variable-held aggregate shapes.
- The evaluator executes array/hash literals, scalar assignment, array append, hash-index assignment, indexed and
  nested reads, and checked nested value-path writes. Nested writes evaluate path expressions before the RHS,
  mutate a copied root only after the whole path validates, never autovivify intermediates, permit final hash-key
  creation and array replace/append-at-length, and return the updated root or `nothing` on failure.
- `set(...)`, `array(...)`, `hash(...)`, and `copy(...)` preserve scalar, array, hash, null, boolean, integer, and
  floating-point shapes. Named aggregate resets remove conflicting typed bindings, while direct scalar-held arrays
  and hashes remain readable and mutable through the same value model.
- Capture execution now covers entry/local text, compact groups, indexed groups, bare-name named reads and
  existence tests, named maps, character lengths/spans, and start/end line-column helpers.
- Package status advances to `runtime-core-values`; later pure helper and receiver families remain owned by
  `.4.3.2` through `.4.3.5`.

## `JULIA-BACKEND-PARITY.4.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.2` intentionally supported only dispatch-facing arrays and basic captures; it
  lacked general scalar/hash stores, typed wrapper reads, structural assignments/access, capture maps, and source
  position helpers.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/runtime/Interpreter.jl` had only an `arrays` store and rejected
  non-`retv` variables, hash literals, assignment/access nodes, `hash(...)`, and the broader `entry_*` / `match_*`
  family. The final Perl/Rust/Dart no-autovivification write contract was already durable in the Knowledge Map.
- [x] **FIX** — Added the shared value/store model, typed aggregate wrappers and snapshots, indexed/nested
  reads/writes, final checked nested-assignment semantics, and complete core entry/local capture readers.
- [x] **ADDRESSED (verified)** — Four focused end-to-end runtime cases cover typed stores, variable-held shapes,
  failed/successful nested writes, named capture maps, multibyte character positions, and line-column helpers.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 554 assertions; CLI status reports
  `runtime-core-values`; commit-time docs/governance gates cover mdBook, memory, Knowledge Map, task metadata,
  doctrine, and whitespace.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff, Knowledge Map, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` advance the frontier
  to `.4.3.2`.

## `JULIA-BACKEND-PARITY.4.3.2` String/Scalar/Numeric Helper Result

Pure helper evidence recorded on 2026-07-10:

- The Julia interpreter canonicalizes word and symbol aliases through `canonical_action_helper_name(...)` before
  dispatching one pure-helper table. Function-form and receiver-form calls therefore share the same value rules.
- String/scalar execution covers `cat`, trimming/case/length, literal prefix/suffix/substring predicates and
  transforms, character-based `substr`, literal/regex `split`, regex-aware `matches`, lazy `coalesce` variants,
  definedness/emptiness predicates, and explicit `str_*` lexical comparisons.
- Regex ActionIR values retain pattern flags internally, so `/.../i` helper arguments compile through Julia's
  native PCRE engine without leaking a host regex wrapper into JSON results.
- Numeric execution covers arithmetic folds, integer modulo, absolute/floor/ceil/half-away-from-zero round,
  min/max/clamp, sum/average/median/range reducers, comparisons, terse word aliases, and arithmetic/comparison
  symbol callees. Non-numeric, non-finite, invalid-bound, non-integer modulo, and zero-divisor cases return
  `nothing`.
- Fluent chains prepend the current receiver to the same helper call and support lazy receiver coalescing;
  string/number chains compose while unsupported later-family methods remain explicit runtime errors.
- Package status advances to `runtime-string-numeric`; array-aware helper breadth advances to `.4.3.3`.

## `JULIA-BACKEND-PARITY.4.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3.1` established portable values/stores but ordinary string/numeric helpers and
  all non-empty fluent chains still fell through `unsupported runtime helper/method` errors.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/runtime/Interpreter.jl` had no canonical pure-helper dispatcher,
  regex-value flag carrier, numeric conversion/normalization path, lazy coalesce evaluator, or fluent-call loop,
  even though ActionIR contracts already recognized current aliases and symbol callees.
- [x] **FIX** — Added the shared string/numeric dispatcher, lazy coalescing, regex-aware operations, JSON-number
  normalization/failure boundaries, and compatible receiver-chain evaluation.
- [x] **ADDRESSED (verified)** — Two focused end-to-end cases exercise string transforms/predicates/comparisons,
  Unicode length/substr behavior, regex flags, coalescing, numeric arithmetic/reducers/comparisons, word and symbol
  aliases, string/number receivers, and invalid-input `nothing` behavior.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 556 assertions; CLI status reports
  `runtime-string-numeric`; commit-time docs/governance gates cover mdBook, memory, Knowledge Map, task metadata,
  doctrine, and whitespace.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff, Knowledge Map, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` advance the frontier
  to `.4.3.3`.

## `JULIA-BACKEND-PARITY.4.3.3` Array Helper Result

Array helper evidence recorded on 2026-07-10:

- Function and receiver array calls route through a dedicated dispatcher over copied values. Supported pure
  operations cover count/first/last, take/drop/slice, lexical sort/reverse, membership/index, string transforms,
  empty filtering, stable uniqueness, regex filtering, split/flatten pipelines, delimiter-first joins,
  one-level flatten/concat, and tagged-record construction.
- `array(...)` splices only explicit `flat(...)` / `flat_array(...)` results; ordinary nested arrays and
  `copy(array(...))` remain one array element, preserving the documented shape boundary.
- Numeric reducer methods such as `.sum()` / `.avg()` reuse the `.4.3.2` numeric dispatcher as terminal array
  consumers, while string `.split(...)` bridges into later array receiver links.
- `split(array(target), source, delimiter)` replaces named typed storage and preserves empty fields plus regex
  flags. Other array transforms are pure snapshots unless their result is assigned explicitly.
- Single-call statement forms of `push_back`, `push_front`, `pop_back`, and `pop_front` mutate named or
  scalar-held arrays. The same methods in value positions return `nothing` and do not evaluate/mutate their target.
- Package status advances to `runtime-array-helpers`; hash-aware helper breadth advances to `.4.3.4`.

## `JULIA-BACKEND-PARITY.4.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3.2` supported scalar and numeric receiver calls, but array helper names still
  produced unsupported helper/method errors and statement-only end methods had no mutation path.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/runtime/Interpreter.jl` had no array helper dispatcher,
  delimiter-first receiver rewrite, explicit flatten-splice marker, split-to-target path, or statement-context
  receiver mutation gate.
- [x] **FIX** — Added copied array helper execution, string/regex bridges, flatten/concat/splice behavior, numeric
  terminal reuse, typed split replacement, and isolated statement-only end mutation for named/scalar-held arrays.
- [x] **ADDRESSED (verified)** — Two focused end-to-end cases cover pure chains and source immutability, regex and
  split bridges, transforms/filters, flattening/constructor shape, reducer terminals, typed/scalar mutations,
  value-position no-op behavior, and tagged records.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 558 assertions; CLI status reports
  `runtime-array-helpers`; commit-time docs/governance gates cover mdBook, memory, Knowledge Map, task metadata,
  doctrine, and whitespace.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff, Knowledge Map, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` advance the frontier
  to `.4.3.4`.

## `JULIA-BACKEND-PARITY.4.3.4` Hash Helper Result

Hash helper evidence recorded on 2026-07-10:

- Function and receiver hash calls share a copied-value dispatcher for `count_keys`, sorted key/value views,
  membership, merge, pick/drop, rename, pure `set_key`, and `flat_hash`.
- A single statement-form `set_key(target, key, value)` mutates named typed hash storage. Function/receiver
  value forms return changed copies and leave the source hash untouched.
- `merge_hash` preserves the portable slot boundary: its base is an ordinary value expression, while later
  overlay slots may resolve bare named hashes. Callers can make a typed base explicit with `copy(hash(name))`.
- `hash(...)` splices maps only when an argument is explicitly marked by `flat(...)` or `flat_hash(...)`;
  ordinary nested map values remain nested. Explicit map flattening into `array(...)` emits key/value pairs.
- Direct `meta[key] = value` remains expression-valued and mutates the named hash through the `.4.3.1` checked
  assignment path. Hash receiver chains can continue into compatible array helpers over copied views.
- Package status advances to `runtime-hash-helpers`; value/control/block/callback execution advances to `.4.3.5`.

## `JULIA-BACKEND-PARITY.4.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3.3` supported array helper breadth, but hash helper names and hash receiver
  methods still produced unsupported helper/method errors and statement-form `set_key` had no mutation path.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/runtime/Interpreter.jl` had no hash helper dispatcher, hash
  receiver routing, typed statement mutation gate, merge-slot argument policy, or explicit hash-splice handling.
- [x] **FIX** — Added copied hash helper execution, compatible receiver chains, isolated statement-only named
  mutation, base/overlay-aware merge evaluation, explicit flat/flat-hash constructor splicing, and map-to-array
  flattening.
- [x] **ADDRESSED (verified)** — One focused end-to-end case covers views, pure transforms, source immutability,
  statement mutation, merge slot resolution, direct assignment, explicit splicing, and nested-map preservation.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 559 assertions; CLI status reports
  `runtime-hash-helpers`; commit-time docs/governance gates cover mdBook, memory, Knowledge Map, task metadata,
  doctrine, and whitespace.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff, Knowledge Map, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` advance the frontier
  to `.4.3.5`.

## `JULIA-BACKEND-PARITY.4.3.5` Value, Control, and Tree Callback Result

Value/control/callback evidence recorded on 2026-07-10:

- Non-empty expression-valued blocks execute statements in order and yield the final expression. Block-local
  `return(...)` / `return_undef()` skips later block statements without setting the surrounding rule return.
- Action blocks execute attached `if` / `elseif` / `else`, `when` / `otherwise`, switch/case/default, and while
  controls; marker-form if/elseif/else/endif chains are grouped. While loops use the runtime iteration guard, and
  returns outside value blocks remain rule-level.
- Inline `if(...)` and `switch(...)` evaluate only the selected value branch. Helper `with(value) { ... }`,
  `with() { ... }`, and receiver `.with() { ... }` bind scoped `value`, restore any prior scalar/array/hash
  binding, and allow compatible receiver continuation.
- Hash tree traversal is sorted-key depth-first with nested hashes as interiors and arrays/scalars as leaves.
  Array traversal is zero-based depth-first with nested arrays as interiors and hashes/scalars as leaves.
- `walk_leaves` returns the copied source tree, `map_leaves` preserves structure with callback results, and
  `reduce_leaves(initial)` returns the final accumulator. Non-aggregate receivers return `nothing` without running
  the callback or evaluating the reduce initial expression.
- Callback frames restore prior bindings after exposing `value`, `path`, `depth`, hash `key`, array `index`, and
  reduce-only `acc`. Other working-variable side effects persist in the caller context.
- Package status advances to `runtime-value-control-tree`; final helper/value no-drift advances to `.4.3.6`.

## `JULIA-BACKEND-PARITY.4.3.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3.4` executed core helper families, but block values used the surrounding
  return channel, control nodes had no runtime gating, trailing blocks were unsupported, and tree receiver methods
  had no callback execution path.
- [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/runtime/Interpreter.jl` executed action blocks as an undifferentiated
  statement loop and had no value-block flow record, structured-control dispatcher, scoped binding snapshot, or
  receiver trailing-block traversal path.
- [x] **FIX** — Added distinct action/value block flow, attached and marker statement controls, lazy inline
  controls, deterministic while guards, helper/receiver `with`, scoped binding restoration, and hash/array
  walk/map/reduce traversal callbacks.
- [x] **ADDRESSED (verified)** — Focused cases cover final-expression yields, local and rule returns, aliases,
  marker branches, switches, with binding restoration, continuation, traversal order/shapes, callback variables,
  non-aggregate lazy failure, and caller-side effects.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 567 assertions; CLI status reports
  `runtime-value-control-tree`; commit-time docs/governance gates cover mdBook, memory, Knowledge Map, task
  metadata, doctrine, and whitespace.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff, Knowledge Map, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` advance the frontier
  to `.4.3.6`.

## `JULIA-BACKEND-PARITY.4.3.6` Helper/Value No-Drift Result

No-drift evidence recorded on 2026-07-10:

- Focused Julia runtime coverage and the canonical helper catalog agree on typed values/stores, checked nested
  assignment, capture reads, string/numeric helpers, arrays, hashes, expression-valued blocks, controls,
  immediate with-blocks, and hash/array tree callbacks.
- The Dart closeout's behavioral correction is already present from Julia `.4.3.1`: nested writes validate the
  complete path before mutation, never autovivify intermediates, return the updated root on success, return
  `nothing` on failure, and allow array replacement or append exactly at length.
- Package/CLI status remains `runtime-value-control-tree`, accurately naming the last implemented family rather
  than claiming later cursor, trace, staged-function, or corpus work.
- The audit found no runtime semantic correction. It reconciled the stale `.3` parent container to `done` and
  removed redundant line-ending semicolons from central helper-catalog `.spec` examples; semicolons remain only
  where they separate adjacent statements on one physical line.
- The `.4.3` helper/value container is closed; explicit cursor controls and boundary capture advance to `.4.4`.

## `JULIA-BACKEND-PARITY.4.3.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The scoped runtime families were green, but their final no-drift agreement had not
  been audited and the task metadata still marked the exhausted `.3` container active. Central helper-catalog
  examples also retained redundant end-of-line semicolons after the separator contract was clarified.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.4.3.1` through `.4.3.5` landed behavior one mechanism at a time; no final
  slice had yet compared their tests/status/facts to mdBook contracts or reconciled parent metadata and example
  authoring style.
- [x] **FIX** — Confirmed the final nested-write and helper/control/callback contracts against focused tests,
  retained the accurate package status, closed `.3` and `.4.3`, normalized central helper-catalog examples, and
  advanced the single frontier to `.4.4`.
- [x] **ADDRESSED (verified)** — Full Julia tests, CLI status, mdBook build, Knowledge Map generation/check,
  memory architecture, task-tree metadata, doctrine, and whitespace gates pass with no runtime behavior change.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` remains green with 567 assertions; CLI status remains
  `runtime-value-control-tree` and no later runtime family is overclaimed.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff/catalog, Knowledge Map,
  architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md`
  advance the frontier to `.4.4`.

## `JULIA-BACKEND-PARITY.4.4` Cursor Controls and Boundary Capture Result

Cursor/boundary evidence recorded on 2026-07-10:

- `save_cursor()` pushes the live internal code-unit cursor onto an explicit LIFO stack. `restore_cursor()` pops
  and restores it; an empty stack is a no-op.
- `rewind_match_start()` moves to the current local-match start, while `rewind_entry_start()` moves to the
  initial/entry-match start for the current context. Both leave the match records themselves intact.
- Every explicit cursor move updates both `_RuntimeExecutionContext.cursor_codeunit` and the immutable
  `RuntimeMatchRegisters.cursor_codeunit`; variables, arrays, hashes, lifecycle effects, and branch history are
  not rolled back.
- The next regex attempt still uses the engine's configured seek/consume mode. Focused consume-mode coverage
  proves a rewound match is consumed contiguously from its restored position.
- `cursor_pos/line/col/rest/rest_len` and `input_text/len/slice/end_pos/end_line/end_col` expose public
  character-based positions, lengths, and slices over Julia's internal UTF-8 code-unit cursor.
- `capture_until_boundary(rule[, ...])` seeks every usable named rule from the live cursor, selects the earliest
  match without consuming it, captures to EOF when valid rules have no later match, and returns `nothing` without
  cursor movement when no requested rule resolves to usable regex patterns.
- Package/CLI status advances to `runtime-cursor-boundary`; runtime diagnostics and trace controls advance to `.4.5`.

## `JULIA-BACKEND-PARITY.4.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3.6` closed helper/value execution, but known cursor/input/control calls still
  fell through to unsupported-helper diagnostics and Julia could not express portable non-consuming structural
  boundary capture.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_RuntimeExecutionContext` had one live cursor and immutable match registers,
  but no explicit cursor stack, centralized cursor/register update path, cursor/input helper dispatch, or compiled
  boundary-rule lookup in `julia/src/runtime/Interpreter.jl`.
- [x] **FIX** — Added the cursor stack and synchronized update helper; explicit save/restore and anchor rewinds;
  character-based cursor/input reads and overflow-safe slicing; and earliest usable boundary capture with EOF and
  unresolved-rule behavior matching Perl/Rust/Dart.
- [x] **ADDRESSED (verified)** — Fourteen focused assertions cover LIFO restoration, empty restore, persistent
  semantic state, entry/local anchor preservation, consume mode after rewind, multibyte public offsets/slices,
  earliest-of-multiple boundaries, non-consumption, EOF fallback, and unresolved-boundary no-op behavior.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 581 assertions; CLI status reports
  `runtime-cursor-boundary`; commit-time docs/governance gates cover mdBook, memory, Knowledge Map, task metadata,
  doctrine, and whitespace.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook status/handoff, Knowledge Map, architecture
  snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `MEMORY.md` advance the frontier
  to `.4.5`.

## `JULIA-BACKEND-PARITY.4.5.0` Diagnostics/Trace Split Result

Planning evidence recorded on 2026-07-10:

- The mdBook trace capability contract requires ordered levels, default-quiet normal entrypoints, structured
  scopes/decisions/marks/logs/dumps, stdout/routed-file/mirror sinks, routed-file reset, and output preservation.
- Stable runtime diagnostic payloads are independent of optional trace routing and land first in `.4.5.1`.
- Trace levels, environment/config controls, event primitives, sinks, and traced entrypoints form one reusable
  control layer in `.4.5.2`.
- Runtime rule/regex/dispatch/lifecycle/recursion/cursor/boundary instrumentation depends on that control layer and
  lands separately in `.4.5.3`.
- `.4.5.4` owns the final status/mdBook/live-doc/Knowledge Map no-drift proof before staged runtime work.
- This mirrors the completed Dart split while retaining Julia-native types and I/O ownership; no Julia source or
  runtime behavior changes in `.4.5.0`.

## `JULIA-BACKEND-PARITY.4.5.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The original `.4.5` acceptance combined stable runtime error payloads, trace
  controls, sink routing, entrypoint plumbing, runtime branch instrumentation, and final parity documentation in
  one executable leaf.
- [x] **ROOT CAUSE (WHY + WHERE)** — Structured errors belong at runtime exception boundaries, trace controls own
  reusable configuration/events/I/O, instrumentation consumes those controls inside interpreter mechanisms, and
  no-drift can only run after all three implementation boundaries are green.
- [x] **FIX** — Converted `.4.5` into a container with `.4.5.1` diagnostics, `.4.5.2` controls/sinks,
  `.4.5.3` runtime events, and `.4.5.4` closeout; selected `.4.5.1` as the sole active frontier.
- [x] **ADDRESSED (verified)** — The split maps every parent acceptance item and the mdBook future-variant trace
  checklist to one implementation or closeout owner without overlap.
- [x] **NO REGRESSION** — Planning only: no Julia source, package status, or runtime behavior changed; mdBook,
  memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the split.
- [x] **LOCKSTEP** — Task tree/index, roadmaps, README, mdBook status/handoff, Knowledge Map, architecture/live
  docs, and `MEMORY.md` advance the precise frontier to `.4.5.1`.

## `JULIA-BACKEND-PARITY.4.5.1` Structured Runtime Diagnostics Result

Diagnostic evidence recorded on 2026-07-10:

- Exported `RuntimeDiagnostic` owns the neutral `type`, `stage`, `owner_stage`, `summary`, `detail`, `spec_name`,
  `spec_path`, `top_rule`, `rule_label`, and `handler_source_label` fields with deterministic JSON projection.
- `RuntimeInterpreterException` keeps its existing message/showerror behavior and adds an optional `diagnostic`
  field plus JSON projection.
- `LinkedSpecRuntimeEngine` accepts optional `spec_name` / `spec_path`; ordinary successful parse JSON is
  identical whether or not source identity is configured.
- Missing compiled rules receive a direct `rule_lookup` diagnostic. Rule execution attaches
  `runtime_execution` attribution before context unwind, so a child helper failure remains attributed to the child
  rule and `julia_runtime:rule:<label>` handler.
- Parent-rule and parse-boundary wrappers preserve an existing richer diagnostic instead of replacing it with a
  generic outer payload.
- Package/CLI status advances to `runtime-diagnostics`; trace controls/events/sinks advance to `.4.5.2`.

## `JULIA-BACKEND-PARITY.4.5.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia runtime failures exposed only `RuntimeInterpreterException.message`, leaving
  callers without the stable structured fields documented by the backend-neutral diagnostic contract.
- [x] **ROOT CAUSE (WHY + WHERE)** — The exception carried one string, the engine had no optional spec identity,
  and rule/parse boundaries rethrew failures without attaching top-rule, current-rule, or handler ownership.
- [x] **FIX** — Added exported diagnostic records/JSON, diagnostic-carrying exceptions, engine spec identity,
  context top-rule identity, direct lookup diagnostics, rule-boundary attribution, and fallback-preserving parse
  wrapping.
- [x] **ADDRESSED (verified)** — Seven focused assertions prove successful-output preservation, exact missing-rule
  field shape, child-rule attribution through parent unwind, richer-payload preservation, and unchanged textual
  exception display.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 588 assertions; CLI status reports
  `runtime-diagnostics`; mdBook, memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the slice.
- [x] **LOCKSTEP** — Public exports, Julia README, task tree/index, roadmaps, mdBook diagnostics/runtime/trace/
  status/handoff pages, Knowledge Map, architecture/live docs, and `MEMORY.md` advance to `.4.5.2`.

## `JULIA-BACKEND-PARITY.4.5.2` Trace Controls, Events, and Sinks Result

Trace-control evidence recorded on 2026-07-10:

- `julia/src/trace/Trace.jl` exports ordered `none`/`low`/`medium`/`high`/`full`/`debug` levels, aliases and
  numeric thresholds, level gating, and stable bucket names.
- `LinkedSpecTraceConfig` supports default-disabled and enabled construction, immutable update helpers, and the
  documented `LINKEDSPEC_TRACE_*` / `LINKEDSPEC_DUMP_VERBOSITY` environment controls.
- `LinkedSpecTraceEmitter` records structured enter/exit/decision/mark/dump/log events and rendered lines, with
  scope indentation plus decision/log/dump convenience primitives.
- Sinks support stdout, routed file, or mirror output. Routed files can be reset/truncated at emitter creation and
  parent directories are created deterministically.
- `runtime_parse` / `runtime_execute` accept an optional emitter; `runtime_parse_with_trace` /
  `runtime_execute_with_trace` construct one from config. This leaf emits the parse scope only; internal runtime
  instrumentation remains exclusively `.4.5.3`.
- Disabled tracing remains quiet, traced results equal untraced results, package/CLI status advances to
  `runtime-trace-controls`, and runtime event instrumentation advances to `.4.5.3`.

## `JULIA-BACKEND-PARITY.4.5.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.5.1` supplied structured diagnostics, but Julia had no trace level/config model,
  event primitives, sink routing, environment controls, or opt-in traced runtime entrypoint.
- [x] **ROOT CAUSE (WHY + WHERE)** — No Julia trace owner existed, and the runtime context/entrypoint had no
  optional emitter seam through which later rule/branch instrumentation could remain default-quiet.
- [x] **FIX** — Added the exported trace module, config/environment parsing, structured events/scopes/decisions/
  logs/dumps, stdout/route/mirror sinks with reset, runtime emitter plumbing, and traced entrypoint wrappers.
- [x] **ADDRESSED (verified)** — Twenty-nine focused assertions prove names/aliases/numeric levels, gating,
  environment mapping, route reset, mirror output, event JSON/rendering, scope indentation, decision/log/dump
  primitives, default quiet, parse-scope routing, and successful-output preservation.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 617 assertions; CLI status reports
  `runtime-trace-controls`; mdBook, memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the slice.
- [x] **LOCKSTEP** — Public exports, Julia README, task tree/index, roadmaps, mdBook trace/status/handoff pages,
  Knowledge Map, architecture/live docs, and `MEMORY.md` advance to `.4.5.3`.

## `JULIA-BACKEND-PARITY.4.5.3` Runtime Trace Instrumentation Result

Runtime trace evidence recorded on 2026-07-10:

- Every runtime rule dispatch enters/exits a `julia_runtime:rule` scope with rule, entry-regex, mode, and cursor
  attribution; same-rule/same-slot/same-cursor recursion cutoffs emit explicit decisions.
- Regex matching emits debug decisions for empty plans, AND-slot match/no-match, and ordinary entry selection with
  stable alternative/start/end/cursor fields.
- Action and blind child dispatch emit debug decisions with edge family, target slot, match result, and cursor
  movement. Passive terminals are identified without changing their existing no-dispatch behavior.
- Lifecycle blocks emit high-level marks before action execution. `save_cursor`, `restore_cursor`,
  `rewind_match_start`, and `rewind_entry_start` emit cursor/stack transition marks.
- `capture_until_boundary(...)` emits successful boundary marks and explicit false decisions for empty or wholly
  unusable boundary sets; boundary capture behavior remains unchanged.
- Fourteen added assertions cover all event families plus traced/untraced identity across action, blind, and
  recursion paths. The full suite passes with 631 assertions and package/CLI status `runtime-trace-events`.

## `JULIA-BACKEND-PARITY.4.5.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.5.2` supplied controls, sinks, and a parse scope, but internal interpreter
  decisions were opaque even at debug level.
- [x] **ROOT CAUSE (WHY + WHERE)** — Rule, regex, dispatch, lifecycle, recursion, cursor, and boundary owners in
  `julia/src/runtime/Interpreter.jl` did not consume the optional emitter seam.
- [x] **FIX** — Added default-no-op runtime trace helpers and instrumented each accepted mechanism with structured
  scopes, decisions, or marks at high/debug levels.
- [x] **ADDRESSED (verified)** — Focused tests prove every required topic/detail family and output identity for
  traced and untraced execution; test fixtures follow newline-only multiline statement separation.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 631 assertions; CLI status reports
  `runtime-trace-events`; mdBook, memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the slice.
- [x] **LOCKSTEP** — Julia README, task tree/index, roadmaps, mdBook trace/status/handoff pages, Knowledge Map,
  architecture/live docs, and `MEMORY.md` advance to `.4.5.4` no-drift.

## `JULIA-BACKEND-PARITY.4.5.4` Diagnostics/Trace No-Drift Result

Closeout evidence recorded on 2026-07-10:

- Full Julia `Pkg.test()` remains green with 631 assertions, including 43 trace assertions and seven structured
  diagnostic assertions; CLI/package status remains `runtime-trace-events`.
- README and Julia README, mdBook trace/status/handoff pages, task tree/index, roadmaps, live docs, architecture,
  and Knowledge Map agree that structured runtime diagnostics, trace controls/events/sinks, and runtime mechanism
  instrumentation are implemented.
- The closeout deliberately keeps the scoped status name: this runtime milestone does not overclaim complete
  compile/parser trace parity or later staged runtime/corpus parity.
- No runtime/source correction was required. The `.4.5` container is closed and `.5.1` staged registry provider
  execution becomes the sole active frontier.

## `JULIA-BACKEND-PARITY.4.5.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.5.3` completed runtime instrumentation, but parent/status/book/KM/live surfaces
  still intentionally described `.4.5.4` as pending.
- [x] **ROOT CAUSE (WHY + WHERE)** — This was planned closeout state, not runtime drift; current-facing metadata
  had not yet reconciled the completed diagnostics, controls, sinks, and event families into one boundary.
- [x] **FIX** — Closed `.4.5`/`.4.5.4`, retained the accurate `runtime-trace-events` status, synchronized durable
  and public documentation, and advanced the active frontier to `.5.1`.
- [x] **ADDRESSED (verified)** — Status/help probes and stale-frontier scans agree with the task tree and mdBook;
  the dedicated boundary fact records what is implemented and what remains outside the claim.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` remains green with 631 assertions; CLI status, mdBook, memory,
  Knowledge Map, task-tree, doctrine, and whitespace gates cover the closeout.
- [x] **LOCKSTEP** — README, Julia README, task/index/roadmaps, mdBook, Knowledge Map, architecture/live docs, and
  `MEMORY.md` advance together to `.5.1`.

## `JULIA-BACKEND-PARITY.5.1` Staged Function-Body Registry Result

Staged registry evidence recorded on 2026-07-10:

- `julia/src/parser/StagedParserRegistry.jl` exports the narrow provider API, staged result/dispatch records, and
  source-aware `StagedParserRegistryException` diagnostics.
- `actionir-body.spec` resolves to `builtin:actionir-body.spec`; load records the portable fixed adapter digest;
  compile selects `action_block` and records the neutral cache fingerprint/version/capability fields.
- Jobs execute in deterministic parent-path, source-span, then job-id order. Execute parses exact body text through
  Julia's typed `parse_action_block(...)` adapter and stores neutral JSON `action_block` results.
- Function dispatch validates sidecar/path/name/params/arity/text/parser/top/result/failure contracts and
  immutably stitches each result into `body_ast` while preserving `body_parse_job` and the original `SpecFile`.
- `parse_spec_with_staged_user_function_definition_asts(...)` composes the existing spec-returned function shell
  projection with staged body dispatch. General provider search, recursive staged queues, and public
  `parse_job(...)` authoring remain outside this narrow leaf.
- Thirty-one focused assertions cover ordering, cache/compiled/result shape, stitching, wrapper parsing, resolve
  diagnostics, compile diagnostics, and result-field drift; full tests pass with 662 assertions and package status
  `runtime-staged-registry`.

## `JULIA-BACKEND-PARITY.5.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia preserved function `body_parse_job` records and had a one-job manual stitch
  helper, but had no deterministic provider dispatch that resolved, compiled, executed, and stitched the queue.
- [x] **ROOT CAUSE (WHY + WHERE)** — No Julia owner implemented the accepted staged registry phases over
  `StagedParseJob`; function-shell projection therefore stopped before `body_ast` population.
- [x] **FIX** — Added the built-in ActionIR-body provider, stable queue, portable cache/compiled/result records,
  contextual diagnostics, immutable function-body dispatch/stitch APIs, and the composed shell+staged parser API.
- [x] **ADDRESSED (verified)** — Focused tests prove stable reversed-input ordering, exact adapter identity,
  stitched immutability, wrapper composition, unsupported parser/top-rule diagnostics, and stitching-policy fences.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 662 assertions; CLI status reports
  `runtime-staged-registry`; mdBook, memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the slice.
- [x] **LOCKSTEP** — Public exports, Julia README, task/index/roadmaps, mdBook staged/status/handoff pages,
  Knowledge Map, architecture/live docs, and `MEMORY.md` advance to `.5.2` user-function runtime execution.

## `JULIA-BACKEND-PARITY.5.2` User-Function Runtime Result

Runtime evidence recorded on 2026-07-10:

- `julia/src/runtime/Interpreter.jl` resolves registered exact-arity calls before ordinary helper fallback and
  evaluates every argument eagerly against the caller stores.
- Each invocation replaces scalar/array/hash stores with fresh function-local stores, binds aggregate params into
  both scalar and typed local views, executes the cached ActionIR body as a value block, copies the final expression
  or first local `return(...)` payload, and restores caller stores in `finally`.
- Function results compose as ordinary values, including compatible receiver chains. Standalone calls run through
  the existing dropped-value statement path, so their result is discarded without skipping eager argument effects.
- Active-call tracking rejects direct and mutual recursion with a structured `user_function_call` diagnostic and
  a deterministic cycle path. Registered wrong arities diagnose before unknown-helper fallback.
- Nine focused assertions cover caller/local isolation, eager arguments, final-expression and local-return results,
  array/hash param bindings, receiver continuation, standalone discard, exact arity, and recursion cycles. Full
  tests pass with 671 assertions and package status `runtime-user-functions`.

## `JULIA-BACKEND-PARITY.5.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.5.1` populated staged function bodies and the registry already resolved exact calls,
  but the runtime still fell through registered calls to unsupported-helper behavior.
- [x] **ROOT CAUSE (WHY + WHERE)** — `Interpreter.jl` had no registered-call branch, function-local store boundary,
  body cache, or active-function recursion tracker.
- [x] **FIX** — Added eager call execution, cached body parsing, isolated typed stores, value-block return flow,
  caller restoration, receiver/drop compatibility, exact-arity handling, and structured cycle diagnostics.
- [x] **ADDRESSED (verified)** — Focused tests exercise value, receiver, and standalone positions plus eager args,
  no caller capture, local mutation isolation, aggregate params, direct/mutual recursion, and wrong arity.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 671 assertions; CLI status reports
  `runtime-user-functions`; mdBook, memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the slice.
- [x] **LOCKSTEP** — Julia README/status, task/index/roadmaps, mdBook compiled-state/status/handoff pages,
  Knowledge Map, architecture/live docs, and `MEMORY.md` advance to `.5.3` descriptor-shape parity.

## `JULIA-BACKEND-PARITY.5.3` Staged Descriptor-Shape Result

Descriptor evidence recorded on 2026-07-10:

- A focused fixture begins with two neutral `function_definition` nodes from the spec-defined shell, then runs
  `parse_spec_with_staged_user_function_definition_asts(...)`, `compile_spec(...)`, descriptor projection, and the
  Julia runtime over that same state.
- Parsed source order, compiled registry `body_parse_jobs`, normalized zero-based parent paths and deterministic job
  ids, complete parse-job policies, neutral `body_payload` source-slice provenance, and stitched ActionIR `body_ast`
  all survive without Julia-specific field names.
- Descriptor `functions` records preserve entry indices and the function fields, while
  `meta.function_order` / `meta.function_count` match the compiled registry. Runtime output proves the descriptor
  assertions cover executable compiled state rather than a disconnected serialization fixture.
- Twenty focused assertions pass; full tests pass with 691 assertions. The existing projection was conforming, so
  this leaf adds a regression lock and durable proof without production-source correction or a new status claim.

## `JULIA-BACKEND-PARITY.5.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia had individual frontend, staged-registry, compiled-descriptor, and runtime tests,
  but no one fixture proved neutral function shape through all four layers.
- [x] **ROOT CAUSE (WHY + WHERE)** — This was a proof-coverage gap in `julia/test/runtests.jl`, not measured
  descriptor drift; existing `to_json(...)` and `to_descriptor_json(...)` paths already retained the fields.
- [x] **FIX** — Added one end-to-end descriptor/runtime fixture over two source-ordered definitions and their
  normalized staged payloads/jobs/ASTs.
- [x] **ADDRESSED (verified)** — The fixture asserts payload provenance, job identity/path/policies, stitched AST,
  registry/descriptor function order and count, and runtime output from the same compiled state.
- [x] **NO REGRESSION** — Full Julia `Pkg.test()` passes with 691 assertions; package/CLI status remains the honest
  `runtime-user-functions`; mdBook, memory, Knowledge Map, task-tree, doctrine, and whitespace gates cover the slice.
- [x] **LOCKSTEP** — Julia README, task/index/roadmaps, mdBook descriptor/status/handoff pages, Knowledge Map,
  architecture/live docs, and `MEMORY.md` close `.5` and advance to `.6.1` controlled corpus execution.

## `JULIA-BACKEND-PARITY.4.2` Runtime Rule Interpreter Result

Rule-interpreter evidence recorded on 2026-07-10:

- `julia/src/runtime/Interpreter.jl` adds `LinkedSpecRuntimeEngine`, `RuntimeParseResult`,
  `RuntimeLifecycleEvent`, `RuntimeInterpreterException`, `runtime_parse(...)`, and `runtime_execute(...)`.
- The engine consumes `CompiledSpec` plus `.4.1` match registers to execute default, AND, OR, and bounded/unbounded
  repetition families in seek or consume mode, with same-rule/same-slot/same-cursor recursion cutoffs and
  zero-progress termination.
- Action and blind-call edges hand entry/local match state into child rules, carry child results through `retv`,
  avoid double-running passive regex-only terminal children, and support explicit `call(...)`, `return(...)`,
  `return_undef()`, `next()`, and rule/explicit-array accumulator `push(...)` at the dispatch boundary.
- Lifecycle payloads run in `I`, `LS`, `LE`, `IT`, `EX`, `LX`, `E` order as applicable and emit stable
  `RuntimeLifecycleEvent` records. `RuntimeParseResult` preserves matched/value state, the backend-neutral
  one-element output wrapper, final code-unit/character cursors, and lifecycle events.
- The embedded ActionIR evaluator is deliberately dispatch-facing: literals, `retv`, explicit arrays,
  `set(array(...), ...)`, `push(...)`, `copy(...)`, `call(...)`, and entry/local capture reads are present;
  general variables/stores, scalar/string/number/array/hash helper families, controls, blocks, and callbacks remain
  owned by `.4.3`.
- At this leaf the package parity status was `runtime-dispatch`; `.4.3.1` has since advanced it to
  `runtime-core-values`.

## `JULIA-BACKEND-PARITY.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.2` acceptance required executable default/AND/OR/repetition families,
  action/blind edges, lifecycle order, `retv`, accumulators, explicit returns, output shape, and recursion/progress
  guards; the canonical Dart parity boundary was inspected in `dart/lib/src/runtime/interpreter.dart`,
  `dart/test/runtime_interpreter_test.dart`, `docs/tasks/DART-BACKEND-PARITY.md`, and
  `docs/knowledge/dart-runtime-rule-interpreter.md` before Julia implementation.
- [x] **ROOT CAUSE (WHY + WHERE)** — After `.4.1`, Julia could compile and select regex alternatives and preserve
  match registers, but no `julia/src/runtime/` owner consumed `CompiledSpec` rule modes, lifecycle ActionIR,
  dependency edges, `retv`, accumulators, repetition bounds, or recursion cutoffs.
- [x] **FIX** — Added `julia/src/runtime/Interpreter.jl`, exported its engine/result/event/exception and execution
  APIs from `julia/src/LinkedSpecJulia.jl`, advanced status to `runtime-dispatch`, and kept the embedded evaluator
  explicitly narrow so `.4.3` retains helper/value ownership.
- [x] **ADDRESSED (verified)** — `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia
  --project=julia -e 'using Pkg; Pkg.test()'` passes with 34 focused runtime-interpreter assertions.
- [x] **NO REGRESSION** — The same `Pkg.test()` run passes scaffold, frontend, ActionIR, registry, compiled-state,
  runtime-matching, and corpus-IO coverage for 550 total assertions.
- [x] **LOCKSTEP** — README, task tree, live docs, roadmaps, mdBook handoff/status/check pages, Knowledge Map fact
  card, architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` updated for the `.4.2`
  boundary.

## `JULIA-BACKEND-PARITY.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.1` acceptance required Julia seek/consume selection, stable alternative identity,
  capture/named-capture state, public character offsets, cursor position, entry/local separation, and zero-progress
  detection; the Dart parity target was inspected in `dart/lib/src/runtime/matching.dart` and
  `dart/test/runtime_matching_test.dart`, with the Perl/Rust cursor and capture owners checked through the linked
  Knowledge Map records.
- [x] **ROOT CAUSE (WHY + WHERE)** — After `.3.4`, `julia/src/compiler/CompiledSpec.jl` carried ordered regex
  strings but the package had no `julia/src/runtime/` owner to compile alternatives, select matches, preserve
  capture identity, translate Julia code-unit offsets to public character offsets, or carry interpreter match
  registers. Direct Julia native-regex probes established the backend-specific PCRE behavior before code.
- [x] **FIX** — Added `julia/src/runtime/Matching.jl`, exported the matching/register API from
  `julia/src/LinkedSpecJulia.jl`, advanced package status to `runtime-matching`, and added focused parity tests.
- [x] **ADDRESSED (verified)** — `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia
  --project=julia -e 'using Pkg; Pkg.test()'` passes with 60 focused runtime-matching assertions.
- [x] **NO REGRESSION** — The same `Pkg.test()` run passes scaffold, frontend, ActionIR, registry, compiled-state,
  and corpus-IO coverage for 516 total assertions.
- [x] **LOCKSTEP** — README, task tree, live docs, roadmaps, mdBook handoff/status/check pages, Knowledge Map fact
  card, architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` updated for the `.4.1`
  boundary.

## `JULIA-BACKEND-PARITY.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `JULIA-BACKEND-PARITY.3.4` acceptance required Julia to compile parsed specs into
  descriptor-shaped state equivalent to the mdBook/Dart model; Dart parity target inspected in
  `dart/lib/src/compiler/compiled_spec.dart`, `dart/test/compiled_spec_test.dart`, and
  `docs/knowledge/dart-compiled-spec-state.md`.
- [x] **ROOT CAUSE (WHY + WHERE)** — After `.3.3`, Julia had parsed source, typed ActionIR contracts, and a
  function registry, but no `src/compiler/` model for ordered rules, dependency refs, dependency-regex state,
  action payload ASTs, mode metadata, or descriptor projection.
- [x] **FIX** — Added `julia/src/compiler/CompiledSpec.jl`, exported compiled-state APIs from
  `julia/src/LinkedSpecJulia.jl`, advanced package status to `compiled-state`, and added focused compiled-state tests.
- [x] **ADDRESSED (verified)** — `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia
  --project=julia -e 'using Pkg; Pkg.test()'` passes with 41 compiled-state assertions.
- [x] **NO REGRESSION** — The same `Pkg.test()` run passes the scaffold, Action AST parser, Action contract resolver,
  user-function registry, source parser, validation, function-shell projection, corpus IO, and source AST JSON
  contract tests for 456 total assertions.
- [x] **LOCKSTEP** — README, task tree, live docs, roadmaps, mdBook handoff/status pages, Knowledge Map fact card,
  architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` updated for the `.3.4` boundary.

## `JULIA-BACKEND-PARITY.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `JULIA-BACKEND-PARITY.3.3` acceptance required Julia function definitions to
  preserve staged sidecars and optional stitched `body_ast`, and required exact-arity user-call resolution before
  helper fallback; Dart parity target inspected in `dart/lib/src/action/function_registry.dart`,
  `dart/test/function_registry_test.dart`, `dart/test/action_contracts_test.dart`, and
  `docs/knowledge/dart-function-registry.md`.
- [x] **ROOT CAUSE (WHY + WHERE)** — After `.3.2`, Julia had typed ActionIR contract resolution but no ordered
  `UserFunctionRegistry`, no registry-level body parse-job queue, no body-AST stitching helper, and no optional
  registry input on `julia/src/action/ActionContracts.jl`.
- [x] **FIX** — Added `julia/src/action/FunctionRegistry.jl`, exported registry APIs from
  `julia/src/LinkedSpecJulia.jl`, advanced package status to `function-registry`, and threaded
  `function_registry=...` through ActionIR contract resolution.
- [x] **ADDRESSED (verified)** — `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia
  --project=julia -e 'using Pkg; Pkg.test()'` passes with 23 user-function registry assertions.
- [x] **NO REGRESSION** — The same `Pkg.test()` run passes the existing scaffold, Action AST parser, Action
  contract resolver, source parser, validation, function-shell projection, corpus IO, and source AST JSON contract
  tests for 415 total assertions.
- [x] **LOCKSTEP** — README, task tree, live docs, roadmaps, mdBook handoff/status pages, Knowledge Map fact card,
  architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` updated for the `.3.3` boundary.

## `JULIA-BACKEND-PARITY.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `JULIA-BACKEND-PARITY.3.2` acceptance required Julia typed ActionIR nodes to map to
  canonical helper/control contracts and diagnostics before registry/compiled-state work; Dart parity target
  inspected in `dart/lib/src/action/action_contracts.dart`, `dart/test/action_contracts_test.dart`, and
  `docs/knowledge/dart-actionir-contract-resolver.md`.
- [x] **ROOT CAUSE (WHY + WHERE)** — After `.3.1`, Julia could parse ActionIR structurally but had no
  contract-resolution layer, no JSON-shaped contract/diagnostic records, and a duplicated validator helper-name
  table in `julia/src/spec/Validator.jl`.
- [x] **FIX** — Added `julia/src/action/ActionContracts.jl`, exported resolver APIs from
  `julia/src/LinkedSpecJulia.jl`, advanced package status to `action-contracts`, and changed
  `julia/src/spec/Validator.jl` to share `is_known_action_ir_call_name(...)`.
- [x] **ADDRESSED (verified)** — `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia
  --project=julia -e 'using Pkg; Pkg.test()'` passes with 39 Action contract resolver assertions.
- [x] **NO REGRESSION** — The same `Pkg.test()` run passes the existing scaffold, Action AST parser, source parser,
  validation, function-shell projection, corpus IO, and source AST JSON contract tests for 392 total assertions.
- [x] **LOCKSTEP** — README, task tree, live docs, roadmaps, mdBook handoff/status pages, Knowledge Map fact card,
  architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` updated for the `.3.2` boundary.

## `JULIA-BACKEND-PARITY.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `JULIA-BACKEND-PARITY.3.1` acceptance required Julia helper/action source to become
  typed AST nodes before contract resolution; Dart parity target inspected in `dart/lib/src/action/action_ast.dart`,
  `dart/lib/src/action/action_parser.dart`, and `dart/test/action_ast_parser_test.dart`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Julia had no `src/action/` typed AST/parser surface after `.2.4`; helper/action
  text could only remain raw source until `.3.1` added structural parsing.
- [x] **FIX** — Added `julia/src/action/ActionAst.jl` and `julia/src/action/ActionParser.jl`, exported the typed
  ActionIR API from `julia/src/LinkedSpecJulia.jl`, and advanced package status to `action-ast-parser`.
- [x] **ADDRESSED (verified)** — `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia
  --project=julia -e 'using Pkg; Pkg.test()'` passes with 74 Action AST parser assertions.
- [x] **NO REGRESSION** — The same `Pkg.test()` run passes the existing scaffold, source parser, validation,
  function-shell projection, corpus IO, and source AST JSON contract tests for 353 total assertions.
- [x] **LOCKSTEP** — README, task tree, live docs, roadmaps, mdBook handoff/status pages, Knowledge Map fact card,
  architecture snapshot, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` updated for the `.3.1` boundary.

## Decisions

- `2026-07-09`: Julia follows Dart in the ADR `0021` backend rollout order. `FUTURE-PARITY-BACKLOG.1.2`
  delegates executable Julia work to this tree after `DART-BACKEND-PARITY.7.5` closes the scoped Dart milestone.
- `2026-07-09`: Julia starts interpreter-first, reusing the Dart lesson that generated source is a proof lane after
  typed frontend, compiled state, runtime interpreter, and corpus parity are green.
- `2026-07-09`: Julia must own a distinct variant-specific CLI entrypoint from the beginning of package planning.
  The `.1.1` preflight selects `julia/bin/linkedspec_julia.jl` as the Julia-specific LinkedSpec CLI and
  `julia/bin/corpus_runner.jl` as the corpus-runner entrypoint.
- `2026-07-10`: Director clarification: multi-backend LinkedSpec exists primarily so applications can use the
  engine in memory through each host language's native library API—Rust, Dart, Julia, Lua, and future backends.
  Variant-specific CLIs remain useful but secondary thin adapters. This Julia tree must preserve library-first
  architecture. `FUTURE-PARITY-BACKLOG.1.4` has now ratified that contract in ADR `0022` and aligned the global
  architecture/docs; Julia's exported parse/compile/runtime functions already satisfy the structural gate.
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
- `2026-07-10`: `.2.3` follows the Dart frontend-validator boundary for parsed source ASTs. It deliberately does
  not parse top-level `fn` shells, lower helper/action code, compile specs, execute runtime behavior, or enable
  corpus `--execute`.
- `2026-07-10`: `.2.4` follows the spec-defined top-level user-function shell boundary. Julia consumes
  `function_definition` nodes produced by `specs/user_function_definition.spec` and keeps `parse_spec(...)`
  rule-only; executing that shell spec in Julia remains a later runtime/staged-registry concern.
- `2026-07-10`: `.3.1` follows the Dart ActionIR parser boundary. Julia parses helper/action text into typed
  structural nodes and preserves unsupported expressions as `raw_perl`; helper-contract resolution, registry
  resolution, compilation, and execution are deliberately deferred to later leaves.
- `2026-07-10`: `.3.2` follows the Dart ActionIR contract resolver boundary without importing Dart runtime
  behavior. Julia records current canonical helper/control contracts and generic diagnostics over typed ActionIR
  nodes, and function-registry-aware user-call classification remains deferred to `.3.3`.
- `2026-07-10`: `.3.3` follows the Dart user-function registry boundary as a data/contract seam. Julia preserves
  staged sidecars and optional stitched `body_ast`, and classifies exact-arity user calls before helper fallback;
  execution of user-function bodies remains deferred to runtime leaves.
- `2026-07-10`: `.3.4` follows the Dart compiled-spec state boundary without importing runtime execution. Julia now
  records compiled rules, dependency refs, dependency-regex rows, action payload ASTs/contracts, function registry
  data, and descriptor metadata; executable regex matching has since landed in `.4.1`.
- `2026-07-10`: `.4.1` follows the Dart runtime matching contract while using Julia's native PCRE engine directly.
  Match state keeps stable alternative indexes, full/compact/named captures, character projections, distinct
  entry/local registers, and zero-progress detection; executable rule dispatch has since landed in `.4.2`.
- `2026-07-10`: `.4.2` follows the Dart first-interpreter boundary with a dispatch-facing ActionIR evaluator.
  Julia executes compiled rule families, lifecycle order, action/blind children, `retv`, explicit returns,
  accumulators, repetition bounds, and recursion/progress guards while leaving broader helper/value semantics to
  `.4.3`.
- `2026-07-10`: `.4.3.0` splits helper/value work by runtime mechanism before code, mirroring the proven Dart
  rollout: core stores/captures, string/numeric helpers, arrays, hashes, value/control/block/callback execution, and
  final no-drift.
- `2026-07-10`: `.4.3.1` implements the final cross-backend core value contract directly, including checked
  no-autovivification nested writes, rather than reproducing the transient Dart behavior later corrected by its
  no-drift leaf.
- `2026-07-10`: `.4.3.2` routes function and receiver string/numeric calls through one canonical helper dispatcher;
  regex values retain flags internally, numeric failures return `nothing`, and array-aware continuation remains
  owned by `.4.3.3`.
- `2026-07-10`: `.4.3.3` preserves the statement/value boundary for destructive array end methods and uses
  explicit flat-result detection for constructor splicing; ordinary copied arrays remain nested values.
- `2026-07-10`: `.4.3.4` preserves copied/pure hash helper semantics and isolates named typed mutation to
  statement-form `set_key`. `merge_hash` resolves its base as an ordinary value expression and later overlays as
  maybe-hash arguments; constructor splicing remains explicitly marked by `flat` / `flat_hash` syntax.
- `2026-07-10`: `.4.3.5` separates block-local value flow from rule-level returns, restores every shadowed store
  category after immediate callbacks, and preserves lazy failure: non-aggregate tree receivers do not run callback
  blocks or evaluate reduce initial expressions.
- `2026-07-10`: `.4.3.6` confirms the Julia helper/value runtime already follows the final nested-write contract
  and retains `runtime-value-control-tree` as an intentionally scoped status; the closeout corrects metadata and
  mdBook example style without changing runtime behavior.
- `2026-07-10`: `.4.4` centralizes live/register cursor updates while keeping match anchors and semantic stores
  intact, exposes character-based cursor/input helpers over the UTF-8 code-unit cursor, and seeks named structural
  boundaries without consuming them. The cursor stack remains separate from direct match/entry anchor rewinds.
- `2026-07-10`: `.4.5.0` splits diagnostics/trace before code: `.4.5.1` owns stable structured diagnostics,
  `.4.5.2` trace controls/events/sinks, `.4.5.3` runtime instrumentation, and `.4.5.4` no-drift closeout.
- `2026-07-10`: `.4.5.1` keeps structured failure data on `RuntimeInterpreterException` rather than changing
  successful result shape. Rule boundaries attach attribution before unwind, outer wrappers preserve richer inner
  payloads, and Julia handler identity uses `julia_runtime:rule:<label>`.
- `2026-07-10`: `.4.5.2` owns a reusable Julia trace module and optional runtime emitter seam. Traced wrappers
  construct emitters from config, ordinary entrypoints remain default-quiet, and only the parse scope lands here;
  interpreter mechanism events remain `.4.5.3` so control/sink proof is independently recoverable.
- `2026-07-10`: `.4.5.3` instruments the existing interpreter ownership boundaries instead of adding a parallel
  tracing execution path. High-level rule/lifecycle events remain readable at `high`; branch, dispatch, recursion,
  cursor, and boundary details are `debug`. Disabled or absent emitters remain no-ops and cannot affect results.
- `2026-07-10`: `.4.5.4` retains package status `runtime-trace-events`. The scoped runtime diagnostics/trace
  milestone is no-drift, but it does not claim later staged runtime/corpus parity or invent compile/parser events
  beyond the implemented Julia surface. `.5.1` is the next executable boundary.
- `2026-07-10`: `.5.1` mirrors the accepted Perl/Rust/Dart minimal provider contract rather than generalizing it:
  one built-in `actionir-body.spec` identity/digest/capability set, stable queue order, typed ActionIR parsing with
  neutral JSON stitching, and hard contextual diagnostics. General registry search/recursion stays deferred.

## Open Questions

- Whether `JuliaFormatter` and `JET` should be committed as Julia dev dependencies is left to a future scaffold or
  verification leaf. They are not available globally in the local Julia environment today.
- Whether generated Julia source is useful remains deferred to `.7.2`; it is not a blocker for interpreter-first
  parity.

## Blockers

- None for `.6.1`. Staged/user-function descriptor shape is locked; controlled executable corpus proof is the next
  owned boundary.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `JULIA-BACKEND-PARITY` | Created under `FUTURE-PARITY-BACKLOG.1.2`; parent leaf ran mdBook, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, stale handoff/frontier scan, and `git diff --check`. | PASS. Planning only; no Julia package or implementation code exists yet. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.1.1` | `command -v julia`; `julia --version`; official Julia downloads page stable-release check; `brew list --versions julia`; `brew list --cask --versions julia`; `/opt/homebrew/bin/julia --startup-file=no --history-file=no -e 'println(VERSION)'`; `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --startup-file=no --history-file=no -e 'import Pkg; import Test; println("Pkg+Test available")'`; optional `JuliaFormatter` and `JET` import probes. | PASS for Julia/Homebrew version, `Pkg`, and `Test`; `JuliaFormatter` and `JET` are absent optional tools. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.1.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.instantiate()'`; `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; `julia --project=julia julia/bin/linkedspec_julia.jl --help`; `julia --project=julia julia/bin/linkedspec_julia.jl status`; `julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus`; `julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus`; `git diff --check`; memory architecture, task-tree metadata, Knowledge Map, doctrine, and mdBook checks. | PASS. Initial fresh-depot registry access needed approved network once; the committed manifest records only the local package, and the scaffold still deliberately rejects `--execute`. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.1.3` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.instantiate()'`; `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; `julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus`; `julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus`; `julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute` returns code `2`; `git diff --check`; memory architecture, task-tree metadata, Knowledge Map, doctrine, and mdBook checks. | PASS. Julia validates the 99-fixture manifest and drift/file/JSON guards without parser/runtime execution; `--execute` remains unavailable. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.2.1` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia source AST/data types round-trip through JSON over spec files, function definitions, staged parse jobs, rule modes, body elements, edges, and fluent calls. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.2.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia source parser tests cover focused syntax fixtures, all 21 checked-in specs, and rule-only corpus specs; total Julia tests pass. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.2.3` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia source validation tests cover Dart parity validator cases, all 21 checked-in specs, and rule-only corpus specs; total Julia tests pass. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.2.4` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia function-shell projection tests cover spec-shaped nodes, staged sidecar validation, stripped source parsing, and output-shape normalization; total Julia tests pass. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.3.1` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia Action AST parser tests cover typed structural parsing for calls, literals, access, shapes, assignments, receiver chains, trailing blocks, block values, controls, value-drop statements, and raw fallback; total Julia tests pass with 353 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.3.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia Action contract resolver tests cover canonical helper/control contracts, aliases, structural assignment contracts, receiver methods, generic unknown-helper/raw diagnostics, and validation sharing of the current helper table; total Julia tests pass with 392 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.3.3` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia user-function registry tests cover ordered entries, staged body parse jobs, sidecar/body-AST preservation, immutable body-AST stitching, duplicate rejection, exact match, wrong arity, missing names, and registry-aware ActionIR contract resolution; total Julia tests pass with 415 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.3.4` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; docs/governance checks at commit time. | PASS. Julia compiled-state tests cover ordered rules, dependency refs, dependency-regex rows, descriptor projection, lifecycle/action payload ASTs, registry-aware contracts, last-definition-wins metadata when validation is skipped, validation reuse, and compiled-state diagnostics; total Julia tests pass with 456 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.1` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. Julia runtime-matching tests cover seek/consume modes, stable alternative identity, compiled-rule pattern input, full/compact/named captures, multibyte character offsets, line/column projection, entry/local registers, cursor state, immutable updates, native PCRE dialect forms, zero-width/progress detection, and boundary/input guards; total Julia tests pass with 516 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. Julia rule-interpreter tests cover default repetition, action/blind children, explicit call/returns, passive terminals, current-edge `retv`, AND/OR modes, bounded and zero-progress repetition, lifecycle order/events, accumulators, consume mode, nested output shapes, recursion cutoff, and runtime errors; total Julia tests pass with 550 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.0` | No implementation behavior change; mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, stale-frontier scans, and `git diff --check`. | PASS. Julia helper/value work is split into six mechanism-sized implementation/closeout leaves; `.4.3.1` is the next executable frontier. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.1` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. Four focused core-value cases prove typed stores and snapshots, variable-held aggregates, checked nested assignment, and capture maps/positions; total Julia tests pass with 554 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.2` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. Two focused pure-helper cases prove string/scalar and numeric families, regex flags, aliases/symbol callees, failure-to-nothing, and receiver chains; total Julia tests pass with 556 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.3` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. Two focused array cases prove pure pipelines, string/regex bridges, flatten/splice shape, numeric terminals, split replacement, statement-only mutations, and tagged records; total Julia tests pass with 558 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.4` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. One focused hash case proves copied views/transforms, pure and statement mutation boundaries, merge-slot resolution, direct assignment, explicit flatten splicing, and nested-map preservation; total Julia tests pass with 559 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.5` | `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'`; Julia CLI status; docs/governance checks at commit time. | PASS. Eight focused assertions prove expression-valued blocks, local/rule return boundaries, attached/marker/inline controls, while limits, helper/receiver with-blocks and arity fences, hash/array traversal callbacks, lazy non-aggregate failure, and scoped restoration; total Julia tests pass with 567 assertions. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.3.6` | No runtime behavior change; full Julia `Pkg.test()`; Julia CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Helper/value tests, status, mdBook contracts, live docs, and fact cards agree at 567 assertions; `.3`/`.4.3` metadata and helper-catalog separator style are reconciled, and `.4.4` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.4` | Full Julia `Pkg.test()`; Julia CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Fourteen focused assertions prove explicit save/restore, entry/local rewinds, consume continuation, character-based cursor/input helpers, earliest non-consuming boundary selection, EOF fallback, and unresolved-rule no-op behavior; total Julia tests pass with 581 assertions and `.4.5` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.5.0` | No Julia runtime behavior change; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Structured diagnostics, trace controls/events/sinks, runtime instrumentation, and no-drift closeout have separate owners; `.4.5.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.5.1` | Full Julia `Pkg.test()`; Julia CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Seven focused assertions prove stable diagnostic fields/JSON, spec/top/rule/handler attribution, richer-payload preservation, successful-output compatibility, and unchanged textual errors; total Julia tests pass with 588 assertions and `.4.5.2` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.5.2` | Full Julia `Pkg.test()`; Julia CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Twenty-nine focused assertions prove trace levels/environment config, structured events/scopes/decisions/logs/dumps, stdout/route/mirror sinks, reset behavior, default quiet, parse-scope routing, and output preservation; total Julia tests pass with 617 assertions and `.4.5.3` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.5.3` | Full Julia `Pkg.test()`; Julia CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Fourteen added trace assertions prove rule scopes, regex decisions, action/blind dispatch, lifecycle marks, recursion cutoffs, cursor transitions, source boundaries, and traced/untraced identity; total Julia tests pass with 631 assertions and `.4.5.4` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.4.5.4` | Full Julia `Pkg.test()`; Julia CLI status/help; stale status/frontier scans; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Runtime diagnostics/trace tests and all public/durable status surfaces agree at 631 assertions and `runtime-trace-events`; `.4.5` closes and `.5.1` becomes active without a source correction. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.5.1` | Full Julia `Pkg.test()`; Julia CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Thirty-one focused assertions prove stable staged queue order, provider/digest/cache/compiled/result shape, immutable `body_ast` stitching, wrapper composition, resolve/compile diagnostics, and policy fences; total Julia tests pass with 662 assertions and `.5.2` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.5.2` | Full Julia `Pkg.test()`; Julia CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Nine focused assertions prove eager args, fresh typed stores, final/local returns, value/receiver/drop positions, exact arity, and direct/mutual recursion diagnostics; total Julia tests pass with 671 assertions and `.5.3` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.5.3` | Full Julia `Pkg.test()`; Julia CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Twenty focused assertions prove neutral staged function fields through parsed source order, compiled jobs, descriptor payload/job/AST records, metadata order/count, and runtime output; total Julia tests pass with 691 assertions, `.5` closes, and `.6.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.1` | Full Julia `Pkg.test()`; Julia CLI status/help and manifest validation; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Twenty-four focused assertions prove controlled scalar/nested/dispatch/lifecycle/function/boundary execution, trace/diagnostic retention, wrapped output comparison, mismatch reporting, and continuation; total Julia tests pass with 715 assertions and `.6.2` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.0` | Planning-only task decomposition; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. The 99-fixture rollout is split into bounded execution/reporting, starter 0–39, middle non-function 40–67, shipped-spec 68–98, and spec-defined function-shell owners; source behavior remains unchanged and `.6.2.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.1` | Full Julia `Pkg.test()`; Julia CLI status/help, validation-only manifest load, named/bounded execute and unbounded rejection; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Thirty added assertions prove library/CLI selection, validation, reporting, exit codes, and rollout guards; total Julia tests pass with 745 assertions, status is `runtime-corpus-selection`, and `.6.2.2` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.2` | Bounded runner offsets 0–39; full Julia `Pkg.test()`; Julia CLI status/help and validation-only load; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. The starter window is 40/40 green without parser/runtime or fixture changes; six permanent assertions bring total Julia tests to 751, status is `runtime-corpus-starter`, and `.6.2.3` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.3` | Bounded runner windows 40–56, 58–59, and 62–67; full Julia `Pkg.test()`; Julia CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. The 25 non-function middle fixtures pass unchanged, six permanent assertions lock the windows and routed `fn` offsets, total Julia tests pass with 757 assertions, status is `runtime-corpus-middle`, and `.6.2.4` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.0` | Bounded runner offsets 68–98; planning-only task decomposition; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. The shipped-spec/parser-smoke window starts at 10 passed / 21 failed, every fixture is accounted for under a recoverable mechanism owner, runtime behavior remains unchanged at 757 assertions and `runtime-corpus-middle`, and `.6.2.4.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.1` | Focused anonymous capture runtime tests; hlink/EBNF focused corpus run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. The complete direct anonymous capture family is Unicode/location/mutation safe; all three hlink delimiter fixtures pass, EBNF logging reaches its structural residual, the window improves to 13/31, full tests pass with 766 assertions, status is `runtime-corpus-capture-boundaries`, and `.6.2.4.2.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.2.1` | Focused eager logical-helper runtime proof; portmap/tablegrep focused corpus run; direct compiled-regex capture probe; traced portmap constant run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Eager `and`/`or`/`not` closes four corpus cases and advances portmap constant to a no-op helper-regex flag residual under `.6.2.4.2.3`; shipped smoke is 17/31, full tests pass with 772 assertions, status is `runtime-corpus-logical-helpers`. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.2.3` | Focused helper regex `igo`/split `go`/invalid `q` tests; focused portmap constant run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Strict shared helper-regex flag normalization closes portmap constant, shipped smoke is 18/31, full tests pass with 772 assertions, status is `runtime-corpus-helper-regex-flags`, and `.6.2.4.2.2` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.2.2` | Focused diagnostic-output runtime proof; focused simenv/history corpus run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Trace-routed `print`/`print_each`/`say` preserve parser output and advance both corpus cases past unsupported `print`; exact successor failures are locked, shipped smoke remains 18/31, full tests pass with 780 assertions, status is `runtime-corpus-diagnostic-output`, and `.6.2.4.3` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.3` | Julia debug trace on recursive nested fixture; focused rule-local array/hash reset and shared-mutation tests; three-case recursive corpus run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. First-reset rule-local snapshots preserve caller stores while ordinary child mutations remain visible; all three recursive fixtures pass, shipped smoke is 21/31, full tests pass with 785 assertions, status is `runtime-corpus-recursive-rule-scope`, and `.6.2.4.4` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.4` | Julia debug traces on EBNF logging and spec.spec minimal fixtures; focused four-form action-edge child-push test; six-case structural corpus run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS/SPLIT. All four spec.spec smokes pass; both EBNF cases retain complete structures and route quote-only statement mutation to `.6.2.4.5.2`; shipped smoke is 25/31, full tests pass with 793 assertions, status is `runtime-corpus-action-edge-child-push`, and `.6.2.4.5.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.5.1` | Focused explicit/default `exit_now(...)` runtime and structured-diagnostic proof; simenv/history boundary regression; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Immediate fatal control preserves explicit status, defaults to `1`, and retains structured attribution. Simenv advances from unsupported helper to `exit_now(1) in rule begin_end_blocks`, routing the earlier scalar-mutation prerequisite to `.6.2.4.5.2`; shipped smoke remains 25/31, full tests pass with 801 assertions, status is `runtime-corpus-exit-now`, and `.6.2.4.5.2` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.5.2` | Focused statement regex mutation/pure-slice proof using the single-quoted pattern; five-case EBNF/simenv/lib_reader corpus run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; Perl `actionir_ast_parser.t`; Rust `parse_string_literal_single_quotes`; Dart `action_ast_parser_test.dart`; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Statement-context four-argument regex substitution mutates bare scalar targets with strict flags and `$n` expansion while numeric slicing stays pure. Exact parser locks preserve single-quoted action strings as the shared Perl/Rust/Dart/Julia language contract. Both EBNF, both lib_reader, and simenv pass; shipped smoke is 30/31, full tests pass with 808 assertions, status is `runtime-corpus-statement-mutation`, and `.6.2.4.5.3` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.5.3` | Knowledge Map public-parser fact; Perl `Runtime.pm` and Dart cursor seam; focused Julia leading-trivia/indexed-read proof; focused history corpus run; bounded offsets 68–98; full Julia `Pkg.test()`; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; `git diff --check`. | PASS. Julia's public in-memory runtime entrypoint skips only leading blank/comment lines through the existing cursor/register seam. History passes without weakening indexed reads, shipped smoke is 31/31, full tests pass with 810 assertions, status is `runtime-corpus-leading-trivia`, `.5` closes, and `.6` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.4.6` | Permanent offset-68/limit-31 regression; direct 31-case corpus CLI; full Julia `Pkg.test()`; CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. The full shipped window is permanently locked at 31/31 with stable endpoints and exact outputs; full tests pass with 816 assertions, status is `runtime-corpus-shipped`, `.6.2.4` closes, and `.6.2.5` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.2.5` | Rule-only failure reproduction; direct `user_function_definition.spec` execution; seven source-driven parser assertions; permanent three-case corpus regression; direct three-case corpus CLI; full Julia tests; CLI status; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. Spec-driven source parsing returns neutral function nodes and composes existing staging/runtime paths; all three routed fixtures pass exact output, full tests pass with 827 assertions, status is `runtime-corpus-function-shells`, and `.6.3` becomes active without a raw Julia scanner. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.3` | Existing focused manifest/drift/mismatch guards; permanent complete 99-fixture regression; full unbounded corpus CLI; offset-only CLI regression; full Julia tests; CLI status/help; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. The atomic library gate and direct CLI both execute all 99 fixtures in order with exact outputs and zero failures; full tests pass with 840 assertions, status is `runtime-corpus-full`, and `.6.4` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.6.4` | `bash -n tools/run_julia_local.sh tools/run_ci_local.sh`; focused `tools/run_julia_local.sh` with explicit Julia/depot overrides; default `tools/run_ci_local.sh`; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. The focused gate passes 840 package assertions, Julia CLI checks, and 99/99 corpus execution; default shared CI remains core-only unless `LINKEDSPEC_RUN_JULIA=1`, and `.7.1` becomes active. |
| `2026-07-10` | `JULIA-BACKEND-PARITY.7.1` | Direct execution assertions for both mdBook native examples; mdBook Julia usage/status/limitation searches; focused Julia gate status retained from `.6.4`; mdBook build; Knowledge Map generation/check; memory architecture; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. Native in-memory rule/function examples execute exact output; focused/direct/opt-in commands, 99/99 interpreter status, and generated-source/trace/tooling limitations are explicit; `.7.2` becomes active. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `JULIA-BACKEND-PARITY` | `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan` | Tree created by the backlog scoping leaf; implementation commits use `JULIA-BACKEND-PARITY.*` leaf ids. |
| `JULIA-BACKEND-PARITY.1.1` | `JULIA-BACKEND-PARITY.1.1 - verify Julia toolchain preflight` | Toolchain/package-layout preflight; no Julia source scaffold yet. |
| `JULIA-BACKEND-PARITY.1.2` | `JULIA-BACKEND-PARITY.1.2 - scaffold Julia package` | Minimal Julia package, command stubs, scaffold tests, and docs; no parser/runtime semantics yet. |
| `JULIA-BACKEND-PARITY.1.3` | `JULIA-BACKEND-PARITY.1.3 - add Julia corpus manifest IO` | Manifest IO/drift guard scaffold; `.1` foundation container closes. |
| `JULIA-BACKEND-PARITY.2.1` | `JULIA-BACKEND-PARITY.2.1 - define Julia frontend AST data types` | Source AST/data model and JSON projection; parser implementation advances to `.2.2`. |
| `JULIA-BACKEND-PARITY.2.2` | `JULIA-BACKEND-PARITY.2.2 - add Julia source spec parser` | Source parser for rule paragraphs and shipped-spec/corpus parser smoke; validation advances to `.2.3`. |
| `JULIA-BACKEND-PARITY.2.3` | `JULIA-BACKEND-PARITY.2.3 - add Julia frontend validation` | Source AST validation and strict-syntax checks; function-shell projection advances to `.2.4`. |
| `JULIA-BACKEND-PARITY.2.4` | `JULIA-BACKEND-PARITY.2.4 - project Julia function-definition shells` | Spec-defined function-shell AST projection; frontend container closes and ActionIR parsing advances to `.3.1`. |
| `JULIA-BACKEND-PARITY.3.1` | `JULIA-BACKEND-PARITY.3.1 - add Julia ActionIR AST parser` | Typed helper/action AST parser; contract resolution advances to `.3.2`. |
| `JULIA-BACKEND-PARITY.3.2` | `JULIA-BACKEND-PARITY.3.2 - add Julia ActionIR contract resolver` | Current helper/control contract resolution; user-function registry advances to `.3.3`. |
| `JULIA-BACKEND-PARITY.3.3` | `JULIA-BACKEND-PARITY.3.3 - add Julia user-function registry` | Ordered user-function registry, staged body parse-job queue, body-AST stitching helper, and registry-aware ActionIR contracts; compiled state advances to `.3.4`. |
| `JULIA-BACKEND-PARITY.3.4` | `JULIA-BACKEND-PARITY.3.4 - add Julia compiled-spec state` | Compiled-spec/interpreter-state records, dependency-regex state, action payload contracts, and descriptor projection; runtime matching advances to `.4.1`. |
| `JULIA-BACKEND-PARITY.4.1` | `JULIA-BACKEND-PARITY.4.1 - add Julia runtime matching state` | Seek/consume regex alternatives, capture/offset projection, cursor and entry/local match registers, and zero-progress detection; executable rule dispatch advances to `.4.2`. |
| `JULIA-BACKEND-PARITY.4.2` | `JULIA-BACKEND-PARITY.4.2 - add Julia runtime rule interpreter` | First compiled-rule interpreter, lifecycle/edge dispatch, narrow accumulator actions, and recursion/progress guards; broader helper/value semantics advance to `.4.3`. |
| `JULIA-BACKEND-PARITY.4.3.0` | `JULIA-BACKEND-PARITY.4.3.0 - split Julia runtime helper families` | Planning-only split into core stores/captures, string/numeric, array, hash, value/control/block/callback, and no-drift leaves; `.4.3.1` becomes active. |
| `JULIA-BACKEND-PARITY.4.3.1` | `JULIA-BACKEND-PARITY.4.3.1 - add Julia runtime value capture helpers` | Core typed stores, structural assignment/access, snapshots, and entry/local capture helpers; string/numeric helpers advance to `.4.3.2`. |
| `JULIA-BACKEND-PARITY.4.3.2` | `JULIA-BACKEND-PARITY.4.3.2 - add Julia runtime string numeric helpers` | Canonical string/scalar and numeric pure helpers plus compatible receiver chains; array-aware behavior advances to `.4.3.3`. |
| `JULIA-BACKEND-PARITY.4.3.3` | `JULIA-BACKEND-PARITY.4.3.3 - add Julia runtime array helpers` | Pure array helper/receiver pipelines, flatten/splice and split bridges, reducer terminals, and statement-only end mutations; hashes advance to `.4.3.4`. |
| `JULIA-BACKEND-PARITY.4.3.4` | `JULIA-BACKEND-PARITY.4.3.4 - add Julia runtime hash helpers` | Copied hash helper/receiver views and transformations, statement-only named set-key mutation, direct assignment integration, merge-slot resolution, and explicit hash splicing; controls/blocks/callbacks advance to `.4.3.5`. |
| `JULIA-BACKEND-PARITY.4.3.5` | `JULIA-BACKEND-PARITY.4.3.5 - add Julia runtime controls and tree callbacks` | Expression-valued blocks, attached/marker/inline controls, helper/receiver with-blocks, and scoped hash/array tree traversal callbacks; no-drift advances to `.4.3.6`. |
| `JULIA-BACKEND-PARITY.4.3.6` | `JULIA-BACKEND-PARITY.4.3.6 - close Julia helper value no drift` | Runtime/status/docs/KM no-drift closeout, parent metadata reconciliation, and helper-catalog separator alignment; cursor controls advance to `.4.4`. |
| `JULIA-BACKEND-PARITY.4.4` | `JULIA-BACKEND-PARITY.4.4 - add Julia runtime cursor controls` | Explicit cursor stack and anchor rewinds, character-based cursor/input helpers, and non-consuming earliest-boundary capture; diagnostics/trace advances to `.4.5`. |
| `JULIA-BACKEND-PARITY.4.5.0` | `JULIA-BACKEND-PARITY.4.5.0 - split Julia diagnostics trace controls` | Planning-only split into structured diagnostics, trace controls/events/sinks, runtime instrumentation, and no-drift; `.4.5.1` becomes active. |
| `JULIA-BACKEND-PARITY.4.5.1` | `JULIA-BACKEND-PARITY.4.5.1 - add Julia runtime diagnostics` | Exported structured runtime diagnostic payloads on exceptions with spec/top/rule/handler attribution; trace controls advance to `.4.5.2`. |
| `JULIA-BACKEND-PARITY.4.5.2` | `JULIA-BACKEND-PARITY.4.5.2 - add Julia trace controls` | Ordered levels, environment/config controls, event primitives, stdout/route/mirror sinks, and traced runtime entrypoints; instrumentation advances to `.4.5.3`. |
| `JULIA-BACKEND-PARITY.4.5.3` | `JULIA-BACKEND-PARITY.4.5.3 - add Julia runtime trace events` | Rule/regex/dispatch/lifecycle/recursion/cursor/boundary instrumentation; no-drift advances to `.4.5.4`. |
| `JULIA-BACKEND-PARITY.4.5.4` | `JULIA-BACKEND-PARITY.4.5.4 - close Julia diagnostics trace no drift` | Scoped runtime diagnostics/trace no-drift; `.4.5` closes and staged registry work advances to `.5.1`. |
| `JULIA-BACKEND-PARITY.5.1` | `JULIA-BACKEND-PARITY.5.1 - add Julia staged function-body registry` | Minimal staged provider dispatch, stable queue, and immutable `body_ast` stitching; runtime calls advance to `.5.2`. |
| `JULIA-BACKEND-PARITY.5.2` | `JULIA-BACKEND-PARITY.5.2 - execute Julia user functions` | Exact-arity registered value/receiver/drop execution with isolated typed stores and recursion diagnostics; descriptor parity advances to `.5.3`. |
| `JULIA-BACKEND-PARITY.5.3` | `JULIA-BACKEND-PARITY.5.3 - preserve Julia staged descriptor shapes` | End-to-end neutral staged function descriptor/runtime proof; `.5` closes and corpus execution advances to `.6.1`. |
| `JULIA-BACKEND-PARITY.6.1` | `JULIA-BACKEND-PARITY.6.1 - add Julia controlled corpus execution` | Library corpus composition, result/query records, wrapped comparison, trace/diagnostic retention, and all-fixture reporting; manifest batches advance to `.6.2`. |
| `JULIA-BACKEND-PARITY.6.2.0` | `JULIA-BACKEND-PARITY.6.2.0 - split Julia corpus expansion batches` | Planning-only split into selection/reporting, starter, middle, shipped-spec, and function-shell owners; `.6.2.1` becomes active. |
| `JULIA-BACKEND-PARITY.6.2.1` | `JULIA-BACKEND-PARITY.6.2.1 - add Julia executable corpus selection` | Named/bounded library selection plus opt-in runner PASS/FAIL reporting and unbounded guard; starter fixtures advance to `.6.2.2`. |
| `JULIA-BACKEND-PARITY.6.2.2` | `JULIA-BACKEND-PARITY.6.2.2 - close Julia starter corpus batch` | Permanent 40/40 starter-window regression proof with no production correction; middle fixtures advance to `.6.2.3`. |
| `JULIA-BACKEND-PARITY.6.2.3` | `JULIA-BACKEND-PARITY.6.2.3 - close Julia middle corpus batch` | Permanent 25/25 non-function middle-window proof with exact `fn` routes; shipped-spec fixtures advance to `.6.2.4`. |
| `JULIA-BACKEND-PARITY.6.2.4.0` | `JULIA-BACKEND-PARITY.6.2.4.0 - split Julia shipped corpus smoke batch` | Planning-only 10/31 shipped-smoke diagnostic split into capture, logical/output helper, recursion, structural-output, quote-normalization, and final no-drift owners. |
| `JULIA-BACKEND-PARITY.6.2.4.1` | `JULIA-BACKEND-PARITY.6.2.4.1 - add Julia anonymous capture boundaries` | Full direct anonymous capture family closes three hlink cases and routes the EBNF structural residual; logical helpers advance to `.6.2.4.2.1`. |
| `JULIA-BACKEND-PARITY.6.2.4.2.1` | `JULIA-BACKEND-PARITY.6.2.4.2.1 - add Julia logical helpers` | Eager boolean composition closes four corpus cases and splits portmap constant's helper-regex `o` flag residual to `.6.2.4.2.3`. |
| `JULIA-BACKEND-PARITY.6.2.4.2.3` | `JULIA-BACKEND-PARITY.6.2.4.2.3 - normalize Julia helper regex flags` | Shared strict helper regex flag normalization closes portmap constant and advances diagnostic-output helpers to `.6.2.4.2.2`. |
| `JULIA-BACKEND-PARITY.6.2.4.2.2` | `JULIA-BACKEND-PARITY.6.2.4.2.2 - add Julia diagnostic output helpers` | Trace-routed, parse-result-neutral diagnostic output advances both routed fixtures to successor-owned mechanisms; recursive top-rule parity advances to `.6.2.4.3`. |
| `JULIA-BACKEND-PARITY.6.2.4.3` | `JULIA-BACKEND-PARITY.6.2.4.3 - scope Julia recursive rule resets` | Rule-local explicit aggregate reset snapshots close all three recursive top-rule fixtures; structural outputs advance to `.6.2.4.4`. |
| `JULIA-BACKEND-PARITY.6.2.4.4` | `JULIA-BACKEND-PARITY.6.2.4.4 - add Julia action-edge child push` | Four child-push forms close all four spec.spec smokes and route EBNF quote mutation to `.6.2.4.5.2`. |
| `JULIA-BACKEND-PARITY.6.2.4.5.1` | `JULIA-BACKEND-PARITY.6.2.4.5.1 - add Julia terminating exit control` | Immediate explicit/default fatal control advances simenv to its statement-mutation prerequisite; `.6.2.4.5.2` becomes active. |
| `JULIA-BACKEND-PARITY.6.2.4.5.2` | `JULIA-BACKEND-PARITY.6.2.4.5.2 - add Julia statement regex mutation` | Portable scalar substitution closes both EBNF, both lib_reader, and simenv; history advances alone to `.6.2.4.5.3`. |
| `JULIA-BACKEND-PARITY.6.2.4.5.3` | `JULIA-BACKEND-PARITY.6.2.4.5.3 - mirror Julia public parser leading trivia` | Public-entry cursor parity closes history and `.5`; final 31/31 no-drift advances to `.6`. |
| `JULIA-BACKEND-PARITY.6.2.4.6` | `JULIA-BACKEND-PARITY.6.2.4.6 - close Julia shipped corpus no drift` | Permanent complete 31/31 shipped-window regression; `.6.2.4` closes and function-shell fixtures advance to `.6.2.5`. |
| `JULIA-BACKEND-PARITY.6.2.5` | `JULIA-BACKEND-PARITY.6.2.5 - execute Julia function shell corpus` | Spec-driven function-definition parsing closes all three routed top-level `fn` fixtures; full-manifest gate advances to `.6.3`. |
| `JULIA-BACKEND-PARITY.6.3` | `JULIA-BACKEND-PARITY.6.3 - close full Julia corpus gate` | Full ordered library/CLI corpus execution is 99/99 green; verification wiring advances to `.6.4`. |
| `JULIA-BACKEND-PARITY.6.4` | `JULIA-BACKEND-PARITY.6.4 - wire Julia local verification` | Focused package/CLI/99-fixture gate plus optional shared-CI integration; documentation advances to `.7.1`. |
| `JULIA-BACKEND-PARITY.7.1` | `JULIA-BACKEND-PARITY.7.1 - document Julia usage and parity boundary` | Public commands, native examples, current 99/99 status, and precise limitations; generated-source decision advances to `.7.2`. |

## Changelog

- `2026-07-10`: Completed `.7.1` public Julia documentation. The mdBook now presents the mature native in-memory
  backend with self-contained rule-only/function examples, focused/direct/opt-in commands, full package layout,
  99/99 `runtime-corpus-full` status, and explicit generated-source/trace/tooling non-claims. No behavior changed;
  `.7.2` is active for the separate generated-source decision.
- `2026-07-10`: Completed `.6.4` local verification wiring. Added configurable `tools/run_julia_local.sh` over
  package tests, Julia CLI checks, and full 99-fixture execution. `tools/run_ci_local.sh` remains core-only by
  default and includes Julia only under `LINKEDSPEC_RUN_JULIA=1`. Focused verification passes 840 assertions and
  99/99; root/backend/book docs name the focused, direct, and opt-in commands; `.7.1` is active.
- `2026-07-10`: Completed `.6.3` full Julia corpus gate. The temporary unbounded CLI rollout fence is removed;
  bare `--execute` runs the complete validated manifest, while named, bounded, and offset-only diagnostics remain.
  A permanent regression locks manifest/result count `99`, exact order/endpoints, 99 passes, zero failures, and
  exact output for every fixture. Direct CLI execution is 99/99, full tests pass with 840 assertions, status is
  `runtime-corpus-full`, and `.6.4` is active for local verification wiring.
- `2026-07-10`: Completed `.6.2.5` function-shell corpus execution. Julia compiles and caches
  `specs/user_function_definition.spec`, executes it over top-level `fn` source, normalizes neutral definition
  nodes, and reuses existing staged body parsing, registry compilation, and runtime execution. The rule-only parser
  remains the primary corpus path and falls back only on a source parse error. All three routed fixtures pass exact
  output, full tests pass with 827 assertions, status is `runtime-corpus-function-shells`, and `.6.3` is active for
  the independent full 99-fixture gate. No raw Julia scanner or fixture shortcut was added.
- `2026-07-10`: Completed `.6.2.4.6` shipped-window no-drift. One permanent regression now executes exact offset
  68 / limit 31, locks manifest/result counts, endpoints, zero failures, and every exact output. Direct CLI is
  31/31, full tests pass with 816 assertions, status is `runtime-corpus-shipped`, `.6.2.4` closes, and `.6.2.5`
  becomes active for the three routed top-level function fixtures. No runtime or fixture changed.
- `2026-07-10`: Completed `.6.2.4.5.3` public-parser leading trivia. Julia's in-memory `runtime_parse(...)`
  entrypoint now begins after leading blank and `#` comment lines through the existing cursor/register seam.
  Focused coverage preserves ordinary scalar-held indexed reads. History passes, full tests pass with 810
  assertions, shipped smoke is 31/31, status is `runtime-corpus-leading-trivia`, `.5` closes, and `.6` is active.
- `2026-07-10`: Completed `.6.2.4.5.2` statement regex mutation. Dropped four-argument `substr(...)` and
  `regex_subst(...)` calls now mutate bare scalar targets with strict helper flags, global/first-only behavior, and
  `$n` expansion; numeric slicing remains pure. Both EBNF, both lib_reader, and simenv pass exact oracle output.
  Full tests pass with 808 assertions, shipped smoke is 30/31, status is
  `runtime-corpus-statement-mutation`, and `.6.2.4.5.3` is active for history leading trivia.
- `2026-07-10`: Completed `.6.2.4.5.1` terminating exit control. Julia evaluates the optional status expression,
  defaults absent/nonnumeric status to `1`, throws immediately with rule attribution, and retains the existing
  structured runtime diagnostic. Simenv advances from unsupported `exit_now` to deliberate `exit_now(1) in rule
  begin_end_blocks`, exposing the earlier statement-form scalar mutation under `.6.2.4.5.2`. Full tests pass with
  801 assertions, shipped smoke remains 25/31, status is `runtime-corpus-exit-now`, and `.6.2.4.5.2` is active.
- `2026-07-10`: Completed `.6.2.4.4` action-edge child push. Julia now reuses edge-scoped child results for
  implicit/explicit whole and indexed append forms. All four spec.spec smokes pass; both EBNF cases preserve full
  structures and route quote-only statement mutation to `.6.2.4.5.2`. Full tests pass with 793 assertions, shipped
  smoke is 25/31, status is `runtime-corpus-action-edge-child-push`, and `.6.2.4.5.1` is active.
- `2026-07-10`: Completed `.6.2.4.3` recursive rule scope. Explicit array/hash resets now snapshot and restore the
  caller binding per rule invocation, while ordinary undeclared child mutations remain visible and user functions
  retain independent whole-store isolation. All three recursive fixtures pass; full tests pass with 785 assertions,
  shipped smoke moves to 21/31, status is `runtime-corpus-recursive-rule-scope`, and `.6.2.4.4` is active.
- `2026-07-10`: Completed `.6.2.4.2.2` diagnostic output. Eager `print`/`say` concatenation and `print_each` array
  walking emit through Julia's low-level trace sink and remain parse-result neutral. Simenv advances to unsupported
  `exit_now`; history advances to its leading-trivia output mismatch. Full tests pass with 780 assertions, shipped
  smoke remains 18/31, status is `runtime-corpus-diagnostic-output`, `.6.2.4.2` closes, and `.6.2.4.3` is next.
- `2026-07-10`: Completed `.6.2.4.2.3` helper regex flags. Shared `matches`/regex-`split` compilation preserves
  `imsx`, ignores runtime-only `g` and Perl no-op `o`, and rejects unknown flags. Portmap constant passes, full tests
  remain 772, shipped smoke is 18/31, status is `runtime-corpus-helper-regex-flags`, and `.6.2.4.2.2` is next.
- `2026-07-10`: Completed `.6.2.4.2.1` logical helpers. Eager `and`/`or`/`not` matches Perl/Rust truthiness and
  empty arities, closes three portmap cases plus tablegrep, and routes portmap constant's independently proven
  helper-regex `o` flag residual to `.6.2.4.2.3`. Full tests pass with 772 assertions, shipped smoke is 17/31, and
  status is `runtime-corpus-logical-helpers`.
- `2026-07-10`: Completed `.6.2.4.1` anonymous capture boundaries. Julia now executes start/read/location/take
  variants across match-start, cursor, and input-end endpoints with character-based Unicode semantics. Three hlink
  delimiter fixtures pass; EBNF logging is structurally routed; full tests pass with 766 assertions, the window is
  13/31, status is `runtime-corpus-capture-boundaries`, and `.6.2.4.2.1` is active.
- `2026-07-10`: Completed `.6.2.4.0` planning split. The complete shipped-spec/parser-smoke window starts at
  10 passed / 21 failed; every failure is routed to a capture-boundary, logical/output helper, recursive top-rule,
  EBNF/spec.spec structural-output, lib_reader quote-normalization, or final no-drift leaf before source changes.
  Status remains `runtime-corpus-middle` at 757 assertions, and `.6.2.4.1` is active.
- `2026-07-10`: Completed `.6.2.3` middle corpus batch. Non-function windows 40–56, 58–59, and 62–67 pass 25/25
  unchanged across helper/control/receiver/assignment/with/tree behavior. Six permanent assertions bring
  `Pkg.test()` to 757 and status `runtime-corpus-middle`; the three top-level `fn` offsets remain routed to `.6.2.5`,
  and `.6.2.4` shipped-spec/parser-smoke fixtures 68–98 are active.
- `2026-07-10`: Completed `.6.2.2` starter corpus batch. The bounded 0–39 runner window passes 40/40 unchanged,
  covering proof-edge, autoexist, core value/store/mutation, primitive, block, and attached-control fixtures. Six
  permanent assertions bring `Pkg.test()` to 751 and status `runtime-corpus-starter`; `.6.2.3` middle non-function
  fixtures 40–67 are active.
- `2026-07-10`: Completed `.6.2.1` executable corpus selection. Julia library execution accepts named or bounded
  fixture subsets with strict selection diagnostics; the runner reports every selected PASS/FAIL and summary,
  returns nonzero for mismatches, preserves validation-only default behavior, and rejects unbounded execution while
  parity is incomplete. Thirty added assertions bring `Pkg.test()` to 745 and status `runtime-corpus-selection`;
  starter fixtures 0–39 are active under `.6.2.2`.
- `2026-07-10`: Completed `.6.2.0` corpus rollout decomposition. The 99-fixture manifest now has bounded
  selection/reporting, starter 0–39, middle non-function 40–67, shipped-spec/parser-smoke 68–98, and spec-defined
  top-level function-shell owners. No behavior changed; the executable boundary remains 715 assertions at
  `runtime-controlled-corpus`, and `.6.2.1` is active.
- `2026-07-10`: Completed `.6.1` controlled corpus execution. Julia now validates then executes every fixture
  through parse/compile/runtime, compares the expected value after one backend-neutral output wrap, captures
  optional trace lines and structured runtime diagnostics, and records failures without aborting later fixtures.
  Twenty-four focused assertions bring full `Pkg.test()` to 715 and status `runtime-controlled-corpus`; CLI
  `--execute` remains later work; `.6.2.0` has since split the rollout and `.6.2.1` is active.
- `2026-07-10`: Completed `.5.3` staged descriptor-shape proof. A 20-assertion fixture preserves two spec-returned
  functions through normalized staged payload/jobs, immutable body-AST stitching, compiled registry and descriptor
  metadata, then executes the same state. `Pkg.test()` passes with 691 assertions; no production correction was
  required, status remains `runtime-user-functions`, `.5` closes, and `.6.1` controlled corpus execution is active.
- `2026-07-10`: Completed `.5.2` user-function runtime execution. Julia resolves registered exact-arity calls
  before helper fallback, evaluates args eagerly, runs cached ActionIR bodies with fresh scalar/array/hash stores,
  restores caller state, composes returned values into receiver chains, discards standalone results, and diagnoses
  direct/mutual recursion. `Pkg.test()` passes with 671 assertions; package status is `runtime-user-functions` at
  that boundary. `.5.3` has since closed `.5`, and `.6.1` is active.
- `2026-07-10`: Completed `.5.1` staged function-body registry. Julia now resolves the built-in ActionIR body
  provider, records portable cache/compiled/result metadata, executes jobs in stable order, stitches neutral
  `action_block` JSON into `body_ast`, and diagnoses resolution/compile/policy drift. `Pkg.test()` passes with 662
  assertions; package status was `runtime-staged-registry` at that boundary. `.5.2` and `.5.3` have since completed,
  `.5` is closed, and `.6.1` is active.
- `2026-07-10`: Completed `.4.5.4` diagnostics/trace no-drift. Full tests remain green with 631 assertions and
  package status `runtime-trace-events`; README/CLI, mdBook, KM, task/index/roadmaps, architecture, and live docs
  agree on the scoped runtime boundary. `.4.5` closes without source correction and `.5.1` becomes active.
- `2026-07-10`: Completed `.4.5.3` runtime trace instrumentation. Julia now emits rule scopes, regex decisions,
  action/blind child dispatch, lifecycle marks, recursion-cutoff decisions, cursor-control transitions, and
  source-boundary events through the optional emitter. `Pkg.test()` passes with 631 assertions; package status is
  `runtime-trace-events`, and `.4.5.4` owns final diagnostics/trace no-drift.
- `2026-07-10`: Completed `.4.5.2` trace controls/events/sinks. Julia now exports ordered levels,
  environment/config parsing, structured event/scope/decision/log/dump primitives, stdout/routed-file/mirror
  sinks with reset, optional runtime emitter injection, and traced wrappers that preserve output. `Pkg.test()`
  passes with 617 assertions; package status is `runtime-trace-controls`, and `.4.5.3` owns runtime instrumentation.
- `2026-07-10`: Completed `.4.5.1` structured runtime diagnostics. Julia runtime exceptions now carry exported
  neutral-field diagnostic payloads with deterministic JSON, optional spec identity, top/rule/handler attribution,
  and richer-inner-payload preservation without changing successful parse results or textual errors. `Pkg.test()`
  passes with 588 assertions; package status is `runtime-diagnostics`, and `.4.5.2` owns trace controls/events/sinks.
- `2026-07-10`: Completed `.4.5.0` diagnostics/trace decomposition before implementation code. `.4.5.1` owns
  stable runtime diagnostic payloads, `.4.5.2` trace levels/config/events/sinks, `.4.5.3` runtime branch/lifecycle/
  cursor/boundary instrumentation, and `.4.5.4` final no-drift. Runtime behavior and the
  `runtime-cursor-boundary` package status are unchanged.
- `2026-07-10`: Completed `.4.4` cursor controls and boundary capture. Julia now supports explicit LIFO
  save/restore, entry/local anchor rewinds, character-based cursor/input helpers, consume-mode continuation from
  rewound positions, and earliest usable non-consuming boundary capture with EOF/unresolved-rule behavior.
  `Pkg.test()` passes with 581 assertions; package status is `runtime-cursor-boundary`, and `.4.5` owns runtime
  diagnostics and trace controls.
- `2026-07-10`: Completed `.4.3.6` helper/value no-drift. Julia's 567-assertion suite already proves the final
  checked nested-write contract and scoped helper/control/callback behavior; package status remains
  `runtime-value-control-tree`. The closeout reconciles stale `.3`/`.4.3` metadata and central helper-catalog
  line-ending semicolons, closes `.4.3`, and advances cursor controls to `.4.4` without runtime behavior change.
- `2026-07-10`: Completed `.4.3.5` value/control/block/callback execution. Julia now supports expression-valued
  blocks with local return flow, attached and marker structured controls, lazy inline branches, deterministic
  while limits, helper/receiver with-blocks, and scoped hash/array walk/map/reduce callbacks with lazy
  non-aggregate failure. `Pkg.test()` passes with 567 assertions; `.4.3.6` owns final helper/value no-drift.
- `2026-07-10`: Completed `.4.3.4` hash helper execution. Julia now supports copied hash views and pure
  merge/pick/drop/rename/set-key transformations, statement-form named typed set-key mutation, direct hash-index
  assignment values, base/overlay-aware merge resolution, explicit flat-style hash splicing, ordinary nested-map
  preservation, and compatible hash-to-array receiver chains. `Pkg.test()` passes with 559 assertions; `.4.3.5`
  owns value/control/block/callback behavior.
- `2026-07-10`: Completed `.4.3.3` array helper execution. Julia now supports copied array pipelines and receiver
  chains, string/regex/split bridges, flatten/concat and explicit constructor splicing, numeric reducer terminals,
  typed split replacement, and statement-only end mutations with value-position no-op behavior. `Pkg.test()`
  passes with 558 assertions; `.4.3.4` owns hash-aware helper and mutation behavior.
- `2026-07-10`: Completed `.4.3.2` string/scalar and numeric helper execution. Julia now canonicalizes aliases and
  symbol callees through one pure-helper path, preserves regex flags, returns `nothing` for invalid numeric work,
  and composes compatible string/number receiver chains. `Pkg.test()` passes with 556 assertions; `.4.3.3` owns
  array-aware helper and mutation behavior.
- `2026-07-10`: Completed `.4.3.1` core runtime values/stores/captures. Julia now preserves scalar and aggregate
  JSON shapes, executes typed wrappers/snapshots plus direct/nested reads and assignments, applies final checked
  no-autovivification nested writes, and exposes entry/local named maps and position helpers. `Pkg.test()` passes
  with 554 assertions; `.4.3.2` owns string/scalar and numeric helper families.
- `2026-07-10`: Completed `.4.3.0` helper/value decomposition before broader evaluator code. `.4.3` is now an
  active container with six implementation/closeout children; `.4.3.1` became the first core value/store/capture
  frontier and has since landed. No Julia runtime behavior changed in `.4.3.0`; the `.4.2` 550-assertion result was
  its baseline.
- `2026-07-10`: Completed `.4.2` first executable rule dispatch. `julia/src/runtime/Interpreter.jl` now executes
  compiled default/AND/OR/repetition families with lifecycle events, action/blind children, `retv`, explicit
  returns, narrow accumulators/capture reads, bounded and zero-progress termination, recursion cutoffs, seek/consume
  modes, and one-element output projection. `Pkg.test()` passes with 550 total assertions; `.4.3.0` has since split
  broader helper/value semantics into safe batches beginning at `.4.3.1`.
- `2026-07-10`: Completed `.4.1` runtime regex matching and match-state tracking.
  `julia/src/runtime/Matching.jl` now compiles stable indexed alternatives, selects seek/consume matches, records
  full/compact/named capture state, projects code-unit spans to character and line/column positions, keeps cursor
  and entry/local registers separate, and detects zero progress. `Pkg.test()` passes with 516 total assertions;
  `.4.2` owns first executable rule dispatch.
- `2026-07-10`: Completed `.3.4` compiled-spec state. `julia/src/compiler/CompiledSpec.jl` now builds ordered
  compiled rule records, dependency refs, dependency-regex rows, lifecycle/action payload ASTs with registry-aware
  contracts, mode metadata, function-registry descriptor records, and descriptor-shaped JSON. `Pkg.test()` passes
  with 456 total assertions; `.4.1` owns regex matching and match-state tracking.
- `2026-07-10`: Completed `.3.3` user-function registry. `julia/src/action/FunctionRegistry.jl` now builds
  ordered user-function entries, exposes body parse jobs, preserves staged sidecars and optional `body_ast`, stitches
  body ASTs immutably, rejects duplicates, and lets ActionIR contract resolution classify exact-arity user calls
  before helper fallback. `Pkg.test()` passes with 415 total assertions; `.3.4` owns compiled-state construction.
- `2026-07-10`: Completed `.3.2` ActionIR contract resolver. `julia/src/action/ActionContracts.jl` now resolves
  typed ActionIR calls, receiver methods, structural assignments, controls, nested arguments, block values, shapes,
  access expressions, and raw fallback nodes into canonical contract/diagnostic records. Validation shares the
  current helper/control name predicate. `Pkg.test()` passes with 392 total assertions; `.3.3` owns the
  user-function registry and staged function-body parse-job records.
- `2026-07-10`: Completed `.3.1` ActionIR AST parser. `julia/src/action/ActionAst.jl` and
  `julia/src/action/ActionParser.jl` now parse helper/action source into typed blocks, statements, calls, literals,
  access paths, shape literals, assignments, receiver chains, trailing blocks, block values, structured controls,
  and raw fallback nodes. `Pkg.test()` passes with 353 total assertions; `.3.2` owns helper-contract resolution.
- `2026-07-10`: Completed `.2.4` function-definition shell projection. Julia now consumes the spec-defined
  `function_definition` / `function_definition_error` node shape, validates source/body spans and staged sidecars,
  normalizes function body parse-job paths, strips function spans before rule parsing, and keeps direct
  `parse_spec(...)` rule-only. `Pkg.test()` covers the projection path and the `.2` frontend container is closed;
  `.3.1` owns typed helper/action AST parsing.
- `2026-07-10`: Completed `.2.3` frontend validation. `julia/src/spec/Validator.jl` now validates parsed source
  ASTs for top-rule presence, duplicate labels/functions, function registry collisions, malformed raw/body regex
  structure, edge family consistency, undefined references, target slot bounds, and strict unused-rule behavior.
  `Pkg.test()` covers focused validation fixtures, all checked-in specs, and rule-only corpus specs. `.2.4` owns
  top-level `fn` shell projection through `specs/user_function_definition.spec`.
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
