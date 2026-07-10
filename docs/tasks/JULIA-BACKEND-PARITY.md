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
  Status: `active`
  Goal: Implement runtime diagnostics and trace controls.
  Children: `.4.5.0`, `.4.5.1`, `.4.5.2`, `.4.5.3`, `.4.5.4`
  Acceptance: Julia exposes default-quiet trace controls, event classes, sink behavior, branch/lifecycle trace
    points, and structured errors equivalent to the documented cross-variant trace contract.
  Verification: `pending`
  Commit: `pending`

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
  Status: `active`
  Goal: Add Julia runtime structured diagnostic payloads and diagnostic-carrying runtime exceptions.
  Acceptance: Runtime failures expose stable structured fields for type, stage, owner stage, summary, detail,
    top rule, rule label, and handler/source attribution without changing successful parse output.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.5.2`
  Status: `pending`
  Goal: Add Julia trace levels, controls, structured event classes, and stdout/routed-file/mirror sink behavior.
  Acceptance: Trace controls are default-quiet, available from normal Julia entrypoints, preserve successful parse
    results, support reset/truncate for routed files, and provide focused tests for level gating and sink routing.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.5.3`
  Status: `pending`
  Goal: Instrument the Julia runtime interpreter with branch, lifecycle, dispatch, cursor, and boundary events.
  Acceptance: Traced execution emits structured scopes and decisions for rule dispatch, regex/blind branches,
    lifecycle blocks, recursion cutoffs, cursor controls, and source boundaries while untraced output is unchanged.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-BACKEND-PARITY.4.5.4`
  Status: `pending`
  Goal: Close Julia runtime diagnostics/trace no-drift.
  Acceptance: Julia README/CLI status, mdBook trace/runtime/handoff pages, live docs, task-tree index, and
    Knowledge Map agree on the implemented diagnostics/trace boundary before `.5` staged runtime work begins.
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
| 1 | `JULIA-BACKEND-PARITY.4.5.1` | `active` | Add stable structured runtime diagnostic payloads before trace controls or runtime event instrumentation. |

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

## Open Questions

- Whether `JuliaFormatter` and `JET` should be committed as Julia dev dependencies is left to a future scaffold or
  verification leaf. They are not available globally in the local Julia environment today.
- Whether generated Julia source is useful remains deferred to `.7.2`; it is not a blocker for interpreter-first
  parity.

## Blockers

- None for `.4.5.1`. The diagnostics/trace container is split; stable structured runtime diagnostics are the next
  owned implementation boundary.

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

## Changelog

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
