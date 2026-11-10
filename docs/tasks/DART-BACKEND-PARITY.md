# DART-BACKEND-PARITY: Dart LinkedSpec Backend Parity

## Metadata

- Tree ID: `DART-BACKEND-PARITY`
- Status: `done`
- Roadmap lane: `Overall roadmap - future backend parity (Dart first)`
- Created: `2026-07-09`
- Last updated: `2026-07-10` (`FUTURE-PARITY-BACKLOG.1.4` cross-tree native in-memory API audit; tree remains closed)
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
- Dart exposes native in-memory parse/compile/execute APIs suitable for embedding in a Dart process;
  `parseSpec(...)`, `compileSpec(...)`, and `LinkedSpecRuntimeEngine` are the primary product surface,
  while the CLI and corpus runner are thin adapters with no exclusive semantics (ADR `0022`).
- mdBook, live docs, task-tree status, and Knowledge Map cards stay aligned with the implemented Dart
  surface after every slice.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `DART-BACKEND-PARITY`
  Status: `done`
  Goal: Implement Dart as the first future full-parity LinkedSpec backend.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`
  Commit: `FUTURE-PARITY-BACKLOG.1.1 - scope Dart backend parity plan`; retained completion note: Tree created by the backlog scoping leaf; implementation commits use `DART-BACKEND-PARITY.*` leaf ids.

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
  Commit: `DART-BACKEND-PARITY.1.1 - record Dart toolchain and layout`; retained completion note: Toolchain/layout preflight; no package files.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.1.1`.

- ID: `DART-BACKEND-PARITY.1.2`
  Status: `done`
  Goal: Create the minimal Dart package scaffold and CI-facing smoke test.
  Acceptance: `dart/` has package metadata, library/test entrypoints, a no-op smoke test, documented
    commands, and no dependency on unpublished local state.
  Commit: `DART-BACKEND-PARITY.1.2 - create Dart scaffold smoke package`; retained completion note: Minimal package scaffold; no parser/runtime/corpus semantics.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.1.2`.

- ID: `DART-BACKEND-PARITY.1.3`
  Status: `done`
  Goal: Add corpus-fixture IO scaffolding without executing parser semantics yet.
  Acceptance: Dart can load the manifest-backed corpus directory, validate manifest shape, and detect
    missing/stale fixture directories before any `.spec` runtime is implemented.
  Commit: `DART-BACKEND-PARITY.1.3 - add Dart corpus manifest IO scaffold`; retained completion note: Manifest IO scaffold; `.1` foundation container closes.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.1.3`.

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
  Commit: `DART-BACKEND-PARITY.2.1 - define Dart frontend AST data types`; retained completion note: Source-level AST/data types; no parser behavior.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.2.1`.

- ID: `DART-BACKEND-PARITY.2.2`
  Status: `done`
  Goal: Parse `.spec` rule paragraphs, headers, regex slots, lifecycle blocks, action/blind-call edges,
    fluent continuations, markers, comments, and block boundaries.
  Acceptance: Parser fixtures cover the formal grammar and the shipped-spec shapes used by the corpus.
  Commit: `DART-BACKEND-PARITY.2.2 - implement Dart spec parser`; retained completion note: Core rule parser; validation/function-shell/runtime behavior deferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.2.2`.

- ID: `DART-BACKEND-PARITY.2.3`
  Status: `done`
  Goal: Implement frontend validation and strict syntax behavior.
  Acceptance: Validation rejects duplicate labels/functions, mixed edge families, undefined references,
    malformed regexes, malformed helper/function definitions, and strict-syntax warnings as documented.
  Commit: `DART-BACKEND-PARITY.2.3 - add Dart frontend validation`; retained completion note: Source-AST validation; function-shell/runtime behavior deferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.2.3`.

- ID: `DART-BACKEND-PARITY.2.4`
  Status: `done`
  Goal: Integrate `specs/user_function_definition.spec` as the function-definition shell owner.
  Acceptance: Dart consumes the spec-defined function-definition AST shape and does not maintain a
    competing host-language raw scanner as the semantic contract.
  Commit: `DART-BACKEND-PARITY.2.4 - integrate Dart function shell projection`; retained completion note: Spec-returned function-definition projection; `.2` frontend container closes.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.2.4`.

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
  Commit: `DART-BACKEND-PARITY.3.1 - add Dart ActionIR AST parser`; retained completion note: Typed helper/action AST parser; helper-contract mapping remains `.3.2`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.3.1`.

- ID: `DART-BACKEND-PARITY.3.2`
  Status: `done`
  Goal: Map helper/action AST to canonical helper contracts and diagnostics.
  Acceptance: Current helper/control families resolve through typed nodes; non-current helper-looking
    calls diagnose generically instead of falling back to host-language calls. The Dart variant must not
    encode non-current helper spelling tables or replacement maps.
  Commit: `DART-BACKEND-PARITY.3.2 - add Dart ActionIR contract resolver`; retained completion note: Current helper/control contract resolution; function registry uses the shared current-name table.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.3.2`.

- ID: `DART-BACKEND-PARITY.3.3`
  Status: `done`
  Goal: Build the function registry and staged function-body parse-job records.
  Acceptance: Function definitions preserve params, arity, source/body spans, `body_payload`,
    `body_parse_job`, and stitched `body_ast`, with exact-arity resolution before helper fallback.
  Commit: `DART-BACKEND-PARITY.3.3 - add Dart function registry`; retained completion note: Ordered user-function registry and exact-arity resolver; compiled state remains `.3.4`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.3.3`.

- ID: `DART-BACKEND-PARITY.3.4`
  Status: `done`
  Goal: Compile parsed specs into a Dart compiled-spec/interpreter model.
  Acceptance: Compiled state has ordered rules, dependency-regex data, function registry, lifecycle/action
    AST payloads, mode metadata, and descriptor projection equivalent to the mdBook model.
  Commit: `DART-BACKEND-PARITY.3.4 - add Dart compiled spec state`; retained completion note: Ordered compiled rule/dependency/descriptor state; runtime matching starts in `.4.1`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.3.4`.

- ID: `DART-BACKEND-PARITY.4`
  Status: `done`
  Goal: Implement the Dart runtime interpreter.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`, `.4.5`

- ID: `DART-BACKEND-PARITY.4.1`
  Status: `done`
  Goal: Implement regex matching and match-state tracking.
  Acceptance: Seek/consume modes, alternative identity, capture groups, named captures, char offsets,
    cursor position, entry/local match separation, and zero-progress detection match the contract.
  Commit: `DART-BACKEND-PARITY.4.1 - add Dart runtime matching state`; retained completion note: Seek/consume regex matching and match-state primitives; rule dispatch starts in `.4.2`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.1`.

- ID: `DART-BACKEND-PARITY.4.2`
  Status: `done`
  Goal: Implement rule dispatch, rule modes, recursion guards, repetition bounds, and lifecycle order.
  Acceptance: Default/AND/OR/REP families, action and blind-call edges, `I/LS/LE/E/EX/IT/LX`, `retv`,
    accumulator collection, and explicit returns match Perl/Rust parity fixtures.
  Commit: `DART-BACKEND-PARITY.4.2 - add Dart runtime rule interpreter`; retained completion note: First executable compiled-rule interpreter; broader helper families remain `.4.3`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.2`.

- ID: `DART-BACKEND-PARITY.4.3`
  Status: `done`
  Goal: Implement runtime value model and helper families.
  Children: `.4.3.0`, `.4.3.1`, `.4.3.2`, `.4.3.3`, `.4.3.4`, `.4.3.5`, `.4.3.6`
  Acceptance: Scalars, arrays, hashes, booleans, numbers, null/undef, value blocks, mutation helpers,
    receiver chains, tree traversal helpers, capture/mark helpers, and string/number/hash/array families
    match the helper catalog.
  Commit: `DART-BACKEND-PARITY.4.3.6 - close Dart helper value no drift`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3`.

- ID: `DART-BACKEND-PARITY.4.3.0`
  Status: `done`
  Goal: Split the broad runtime value/helper-family leaf into signoff-sized implementation leaves before code.
  Acceptance: Helper/value work is divided by runtime surface area; the next executable frontier is explicit and
    can land without bundling the complete helper catalog in one commit.
  Verification: memory architecture; task-tree metadata; doctrine; `git diff --check`.
  Commit: `DART-BACKEND-PARITY.4.3.0 - split Dart runtime helper families`; retained completion note: Helper/value runtime work split before code.

- ID: `DART-BACKEND-PARITY.4.3.1`
  Status: `done`
  Goal: Centralize Dart runtime value/store behavior and capture helper reads.
  Acceptance: Runtime values preserve scalar/array/hash/null/boolean/number JSON shapes; typed array/hash
    wrappers and bare reads follow the helper catalog; scalar assignment, array append, hash-index assignment,
    nested access reads, `copy`, `array`, `hash`, `entry_*`, `match_*`, and capture position helpers have focused
    runtime tests.
  Commit: `DART-BACKEND-PARITY.4.3.1 - add Dart runtime value capture helpers`; retained completion note: Core value/store/capture helper subset.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3.1`.

- ID: `DART-BACKEND-PARITY.4.3.2`
  Status: `done`
  Goal: Implement string/scalar and numeric helper families, including compatible receiver chains.
  Acceptance: `cat`, trimming/case/substr/prefix/suffix/contains/matches/split scalar helpers, numeric arithmetic
    and comparison helpers/aliases/symbol callees, and simple scalar receiver chains match helper-catalog examples.
  Commit: `DART-BACKEND-PARITY.4.3.2 - add Dart runtime string numeric helpers`; retained completion note: String/scalar and numeric helper families.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3.2`.

- ID: `DART-BACKEND-PARITY.4.3.3`
  Status: `done`
  Goal: Implement array helper family and array receiver/mutation behavior.
  Acceptance: `array`, `flat_array`, `copy`, count/select/order/membership/join/split bridges, append and
    end-mutation forms, and array receiver chains match helper-catalog examples without mutating snapshots
    unexpectedly.
  Commit: `DART-BACKEND-PARITY.4.3.3 - add Dart runtime array helpers`; retained completion note: Array helper family and statement-only array end mutations.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3.3`.

- ID: `DART-BACKEND-PARITY.4.3.4`
  Status: `done`
  Goal: Implement hash helper family and hash receiver/mutation behavior.
  Acceptance: `hash`, `flat_hash`, `copy`, key/value views, sorted views, merge/pick/drop/rename/set-key
    behavior, direct hash-index assignment values, and hash receiver chains match helper-catalog examples.
  Commit: `DART-BACKEND-PARITY.4.3.4 - add Dart runtime hash helpers`; retained completion note: Hash helper family and statement/value mutation boundaries.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3.4`.

- ID: `DART-BACKEND-PARITY.4.3.5`
  Status: `done`
  Goal: Implement value blocks, structured action controls, and tree traversal callback helpers.
  Acceptance: Expression-valued blocks, attached/inline `if`/`when`/`switch`/`while` surfaces, receiver `.with`,
    and `walk_leaves` / `map_leaves` / `reduce_leaves` traversal helpers match current Perl/Rust contracts.
  Commit: `DART-BACKEND-PARITY.4.3.5 - add Dart runtime controls and tree callbacks`; retained completion note: Value blocks, structured controls, with-blocks, and tree traversal receiver callbacks.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3.5`.

- ID: `DART-BACKEND-PARITY.4.3.6`
  Status: `done`
  Goal: Close helper/value no-drift for the Dart runtime slice.
  Acceptance: mdBook helper examples, Dart focused runtime tests, corpus-runner status text, live docs, and
    Knowledge Map facts agree on the helper/value boundary before `.4.4` BACKTRACK work starts.
  Commit: `DART-BACKEND-PARITY.4.3.6 - close Dart helper value no drift`; retained completion note: Nested value-path assignment no-drift; `.4.3` helper/value container closes.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.3.6`.

- ID: `DART-BACKEND-PARITY.4.4`
  Status: `done`
  Goal: Implement cursor-rewind, parse-mode cursor behavior, and deterministic safety limits.
  Acceptance: Cursor rewinds affect only local cursor state, loops enforce documented safety, and
    deterministic order is maintained for hash views and dispatch decisions.
  Commit: `DART-BACKEND-PARITY.4.4 - add Dart backtrack cursor rewinds`; retained completion note: BACKTRACK/IBACKTRACK cursor rewinds and cursor/input helpers.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.4`.

- ID: `DART-BACKEND-PARITY.4.5`
  Status: `done`
  Goal: Implement runtime diagnostics and trace controls.
  Children: `.4.5.0`, `.4.5.1`, `.4.5.2`, `.4.5.3`, `.4.5.4`
  Acceptance: Dart exposes default-quiet trace controls, event classes, sink behavior, branch/lifecycle
    trace points, and structured errors equivalent to the documented cross-variant trace contract.
  Commit: `DART-BACKEND-PARITY.4.5.4 - close Dart diagnostics trace no drift`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.5`.

- ID: `DART-BACKEND-PARITY.4.5.0`
  Status: `done`
  Goal: Split the broad runtime diagnostics/trace-controls leaf into signoff-sized implementation leaves before code.
  Acceptance: Diagnostic payloads, trace controls/sinks, runtime trace instrumentation, and closeout proof are
    separately owned so no code slice must carry the whole cross-variant trace contract at once.
  Commit: `DART-BACKEND-PARITY.4.5.0 - split Dart diagnostics trace controls`; retained completion note: Diagnostics/trace leaf split before code.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.5.0`.

- ID: `DART-BACKEND-PARITY.4.5.1`
  Status: `done`
  Goal: Add Dart runtime structured diagnostic payloads and diagnostic-carrying runtime exceptions.
  Acceptance: Runtime failures expose stable structured fields for type, stage, owner stage, summary, detail,
    top rule, rule label, and handler/source attribution without changing successful parse output.
  Commit: `DART-BACKEND-PARITY.4.5.1 - add Dart runtime diagnostics`; retained completion note: Structured runtime diagnostics on Dart runtime exceptions.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.5.1`.

- ID: `DART-BACKEND-PARITY.4.5.2`
  Status: `done`
  Goal: Add Dart trace levels, controls, structured event classes, and stdout/routed-file/mirror sink behavior.
  Acceptance: Trace controls are default-quiet, available from normal Dart entrypoints, preserve successful parse
    results, support reset/truncate for routed files, and provide focused tests for level gating and sink routing.
  Commit: `DART-BACKEND-PARITY.4.5.2 - add Dart trace controls`; retained completion note: Trace controls, event classes, sinks, and traced runtime entrypoints.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.5.2`.

- ID: `DART-BACKEND-PARITY.4.5.3`
  Status: `done`
  Goal: Instrument the Dart runtime interpreter with branch, lifecycle, dispatch, and source-boundary trace events.
  Acceptance: Traced runtime execution emits structured enter/exit scopes and decisions for rule dispatch,
    regex/blind branches, lifecycle blocks, cursor/source-boundary helpers where implemented, and dump/log events
    where relevant while untraced execution remains output-compatible.
  Commit: `DART-BACKEND-PARITY.4.5.3 - add Dart runtime trace events`; retained completion note: Runtime branch/lifecycle/source-boundary trace instrumentation.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.5.3`.

- ID: `DART-BACKEND-PARITY.4.5.4`
  Status: `done`
  Goal: Close Dart runtime diagnostics/trace no-drift.
  Acceptance: Dart README, CLI help/status text, mdBook trace/runtime/backend-handoff pages, live docs, task-tree
    index, and Knowledge Map agree on the implemented diagnostics/trace boundary before `.5` staged runtime work
    begins.
  Commit: `DART-BACKEND-PARITY.4.5.4 - close Dart diagnostics trace no drift`; retained completion note: Diagnostics/trace status no-drift closeout; `.4.5` container closes.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.4.5.4`.

- ID: `DART-BACKEND-PARITY.5`
  Status: `done`
  Goal: Implement staged parser registry and user-function runtime parity.
  Children: `.5.1`, `.5.2`, `.5.3`

- ID: `DART-BACKEND-PARITY.5.1`
  Status: `done`
  Goal: Implement minimal staged registry provider for function-body parse jobs.
  Acceptance: `actionir-body.spec` resolves deterministically, compiles top rule `action_block`, executes
    queued jobs in stable order, and stitches `body_ast`.
  Commit: `DART-BACKEND-PARITY.5.1 - add Dart staged function-body registry`; retained completion note: Minimal staged registry provider dispatches function-body parse jobs and stitches `body_ast`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.5.1`.

- ID: `DART-BACKEND-PARITY.5.2`
  Status: `done`
  Goal: Execute registered user functions in value positions, receiver chains, and standalone discard.
  Acceptance: Exact-arity functions use fresh function-local stores, eager argument evaluation, compatible
    receiver continuation, standalone `VALUE_DROP`, and recursion diagnostics.
  Commit: `DART-BACKEND-PARITY.5.2 - execute Dart user functions`; retained completion note: Registered exact-arity user functions execute at runtime.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.5.2`.

- ID: `DART-BACKEND-PARITY.5.3`
  Status: `done`
  Goal: Preserve staged parse-job and function-registry descriptor shapes.
  Acceptance: Descriptor/corpus fixtures can assert the neutral function-definition payload, parse-job,
    and stitched AST fields without Dart-specific field drift.
  Commit: `DART-BACKEND-PARITY.5.3 - preserve Dart staged descriptor shapes`; retained completion note: Neutral staged user-function descriptor shapes are asserted through runtime output.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.5.3`.

- ID: `DART-BACKEND-PARITY.6`
  Status: `done`
  Goal: Prove Dart parity against the corpus and cross-backend gates.
  Children: `.6.1`, `.6.2`, `.6.3`, `.6.4`

- ID: `DART-BACKEND-PARITY.6.1`
  Status: `done`
  Goal: Bring up controlled proof fixtures.
  Acceptance: Minimal authored fixtures prove scalar output, nested arrays/hashes, rule dispatch, and
    lifecycle return shape before shipped-spec breadth.
  Commit: `DART-BACKEND-PARITY.6.1 - add Dart controlled corpus execution`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.1`.

- ID: `DART-BACKEND-PARITY.6.2`
  Status: `done`
  Goal: Expand to the current 99-fixture manifest in safe batches.
  Children: `.6.2.0`, `.6.2.1`, `.6.2.2`, `.6.2.3`, `.6.2.4`, `.6.2.5`
  Acceptance: Each batch either passes on Dart or records a narrowly owned root-cause leaf with Perl/Rust
    oracle evidence; no fixture is weakened to fit Dart.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-BACKEND-PARITY.6.2.0`
  Status: `done`
  Goal: Split shipped-corpus expansion into narrowly owned batches.
  Acceptance: `.6.2` has child leaves for opt-in executable runner/reporting, starter corpus batches,
    helper/control/runtime batches, and shipped-spec batches before any behavior changes are made.
  Commit: `DART-BACKEND-PARITY.6.2.0 - split Dart corpus expansion batches`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.0`.

- ID: `DART-BACKEND-PARITY.6.2.1`
  Status: `done`
  Goal: Add opt-in executable corpus selection and reporting.
  Acceptance: Dart can execute named or safely bounded fixture subsets through the corpus runner/library, report
    pass/fail/mismatch details for every selected fixture, and keep the default 99-fixture command as a
    manifest-loader smoke while full parity is still incomplete.
  Commit: `DART-BACKEND-PARITY.6.2.1 - add Dart executable corpus selection`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.1`.

- ID: `DART-BACKEND-PARITY.6.2.2`
  Status: `done`
  Goal: Close the starter proof-edge, autoexist, and core terse runtime batch.
  Acceptance: The early manifest fixtures covering proof-edge returns, autoexist behavior, scalar/array/hash
    store reads, assignment/mutation, and primitive helper surfaces either pass on Dart or each blocked fixture is
    routed to a narrowly owned root-cause leaf with Perl/Rust oracle evidence.
  Commit: `DART-BACKEND-PARITY.6.2.2 - close Dart starter corpus batch`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.2`.

- ID: `DART-BACKEND-PARITY.6.2.3`
  Status: `done`
  Goal: Close the helper, control, receiver-chain, user-function, and tree traversal batch.
  Acceptance: The middle terse fixtures covering value blocks, attached/inline controls, helper composition,
    receiver chains, numeric/string/array/hash helpers, user-function runtime, with-blocks, and hash/array tree
    traversal either pass on Dart or each blocked fixture is routed to a narrowly owned root-cause leaf with
    Perl/Rust oracle evidence.
  Commit: `DART-BACKEND-PARITY.6.2.3 - close Dart middle corpus batch`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.3`.

- ID: `DART-BACKEND-PARITY.6.2.4`
  Status: `done`
  Goal: Close the shipped-spec and parser-smoke corpus batch.
  Children: `.6.2.4.0`, `.6.2.4.1`, `.6.2.4.2`, `.6.2.4.3`, `.6.2.4.4`, `.6.2.4.4.0`,
    `.6.2.4.4.1`, `.6.2.4.4.2`, `.6.2.4.4.3`, `.6.2.4.4.4`, `.6.2.4.4.5`,
    `.6.2.4.4.6`, `.6.2.4.5`, `.6.2.4.6`
  Acceptance: The tclite, lispish, recursive top-rule, hlink, portmap, ebnf, spec.spec, regdef, tablegrep,
    simenv, VHDL/library, history, and plugin smoke fixtures either pass on Dart or each blocked fixture is routed
    to a narrowly owned root-cause leaf with Perl/Rust oracle evidence.
  Commit: `DART-BACKEND-PARITY.6.2.4.6 - close Dart structural regex smoke`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4`.

- ID: `DART-BACKEND-PARITY.6.2.4.0`
  Status: `done`
  Goal: Split the shipped-spec/parser-smoke corpus batch after diagnostic execution.
  Acceptance: The 31-fixture window is measured, failure clusters are recorded, and implementation children are
    created before code changes; Dart frontier remains recoverable after the planning commit.
  Commit: `DART-BACKEND-PARITY.6.2.4.0 - split Dart shipped corpus smoke batch`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.0`.

- ID: `DART-BACKEND-PARITY.6.2.4.1`
  Status: `done`
  Goal: Add the Dart regex-dialect bridge needed by shipped-spec smoke fixtures.
  Acceptance: Dart parser/runtime regex compilation handles the shipped fixture patterns that currently fail
    before matching because of POSIX character classes, inline flag groups, and possessive quantifiers; any
    remaining recursive/DEFINE/`\K` PCRE structural-regex failures are routed to `.6.2.4.6`.
  Commit: `DART-BACKEND-PARITY.6.2.4.1 - bridge Dart shipped regex dialect`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.1`.

- ID: `DART-BACKEND-PARITY.6.2.4.2`
  Status: `done`
  Goal: Add missing parser-smoke runtime helper surfaces.
  Acceptance: The shipped-smoke fixtures no longer fail solely because Dart lacks `capture_slice`, diagnostic
    output helper behavior (`print`/`say`), logical `or`/`not`, `exit_now`, or typed parsing for current helper-form
    `print(...)` expressions; helper behavior matches the Perl/Rust contract or is routed to narrower follow-up
    evidence.
  Commit: `DART-BACKEND-PARITY.6.2.4.2 - bridge Dart helper action surfaces`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.2`.

- ID: `DART-BACKEND-PARITY.6.2.4.3`
  Status: `done`
  Goal: Close recursive/default-mode and empty child-output semantics for parser-smoke fixtures.
  Acceptance: Tclite, Lispish, recursive top-rule, delimiter/default-mode, and explicit diagnostic-branch fixtures
    either pass on Dart or each residual mismatch has a narrowly owned root-cause leaf with Perl/Rust oracle
    evidence.
  Commit: `DART-BACKEND-PARITY.6.2.4.3 - close Dart recursive dispatch semantics`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.3`.

- ID: `DART-BACKEND-PARITY.6.2.4.4`
  Status: `done`
  Goal: Close residual shipped-spec parser-smoke fixture output parity.
  Children: `.6.2.4.4.0`, `.6.2.4.4.1`, `.6.2.4.4.2`, `.6.2.4.4.3`, `.6.2.4.4.4`,
    `.6.2.4.4.5`, `.6.2.4.4.6`
  Acceptance: Hlink, portmap, regdef, tablegrep, simenv, VHDL/library, history, and plugin/library smoke fixtures
    pass or are routed with precise root-cause evidence after regex/helper/recursion blockers are removed,
    including any observable semantic mismatch from Dart's normalized regex dialect bridge. EBNF/spec.spec/Lispish
    PCRE structural blockers remain owned by `.6.2.4.6`.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.6 - mirror public parser leading trivia`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.0`
  Status: `done`
  Goal: Split residual parser-smoke parity after the recursive/default-mode bridge.
  Acceptance: The post-`.6.2.4.3` diagnostic window is classified into narrowly owned implementation leaves, with
    PCRE structural blockers left under `.6.2.4.6`.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.0 - split Dart residual parser-smoke parity`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.0`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.1`
  Status: `done`
  Goal: Close portmap/action-edge child result shape parity.
  Acceptance: `portmap_bare`, `portmap_bit`, `portmap_slice`, `portmap_constant`, and `portmap_concatenation`
    pass on Dart or remaining mismatches are routed with Perl/Rust oracle evidence. This leaf owns scoped
    action-edge child results, passive terminal child re-search behavior, and aggregate/bare result unwrapping
    exposed by those fixtures.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.1 - close Dart portmap result shapes`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.1`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.2`
  Status: `done`
  Goal: Close hlink delimiter/capture parser-smoke parity.
  Acceptance: `hlink_raw_string`, `hlink_raw_escaped_brackets`, `hlink_curly_brace`, `hlink_bracket_body`, and
    `hlink_mixed_bracket_brace` pass on Dart or remaining mismatches are routed with precise delimiter/capture
    evidence.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.2 - close Dart hlink delimiter captures`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.2`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.3`
  Status: `done`
  Goal: Close helper mutation and text-normalization parser-smoke surfaces.
  Acceptance: `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass on Dart or each
    residual is routed with root-cause evidence. This leaf owns missing helper surfaces such as `match_line`,
    statement-form scalar regex substitution, array split mutation, and quote/text normalization visible in those
    fixtures.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.3 - close Dart helper mutation surfaces`; retained completion note: Statement-form helper mutation, explicit split replacement, and entry/local line helpers close three parser-smoke fixtures.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.3`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.4`
  Status: `done`
  Goal: Close legacy structural smoke output parity.
  Acceptance: `regdef_nested_register_fields` and `ds_vhistory_version_entry` pass on Dart or residual mismatches
    are routed with precise structural evidence. `vhdl_library_use` passed under `.6.2.4.4.1` from the Dart
    `array(flat*)` list-context splice fix, and `tablegrep_simple_term` passed under `.6.2.4.4.2` from the
    scalar-held append fix. `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` passed
    under `.6.2.4.4.3` from statement helper mutation/text-normalization parity.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.4 - close Dart legacy accumulator smoke`; retained completion note: `push(Child)` current-rule accumulator semantics close `regdef_nested_register_fields`; `ds_vhistory_version_entry` is routed with direct-access/oracle evidence.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.4`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.5`
  Status: `done`
  Goal: Close residual parser-smoke parity after the focused output/helper leaves.
  Acceptance: The `.6.2.4.4` residual group is green or every remaining non-PCRE blocker is split with durable
    evidence before `.6.2.4.5` final no-drift closeout. First residual: decide `ds_vhistory_version_entry`
    object-name parity, where the checked oracle expects `null` for `cur_object[1]` but Dart follows the current
    scalar-held direct-access contract and returns `/proj/foo`.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.5 - split ds_vhistory oracle boundary`; retained completion note: Evidence-only split: public `ds_vhistory` parser leading-newline fixture returns null, direct descriptor handler returns `/proj/foo`, ordinary scalar-held indexed reads remain valid, and `.6.2.4.4.6` owns the boundary decision.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.5`.

- ID: `DART-BACKEND-PARITY.6.2.4.4.6`
  Status: `done`
  Goal: Resolve `ds_vhistory_version_entry` leading-newline public-parser/oracle boundary.
  Acceptance: Dart either matches the public Perl/Rust oracle for the leading-newline `ds_vhistory` fixture without
    weakening ordinary scalar-held direct access, or the corpus/oracle contract is corrected with Perl, Rust, Dart,
    mdBook, and Knowledge Map lockstep. The public-parser versus descriptor-handler discrepancy must have a durable
    decision or evidence record before `.6.2.4.5`.
  Commit: `DART-BACKEND-PARITY.6.2.4.4.6 - mirror public parser leading trivia`; retained completion note: Dart runtime parse entrypoint now skips leading blank/comment lines like the Perl public parser, closing `ds_vhistory_version_entry` and moving parser-smoke to 24/31 green.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.4.6`.

- ID: `DART-BACKEND-PARITY.6.2.4.5`
  Status: `done`
  Goal: Finalize the shipped-spec/parser-smoke corpus batch no-drift closeout.
  Acceptance: The full `.6.2.4` 31-fixture window is green on Dart or all remaining blockers are split with
    durable evidence; README, mdBook, roadmap, Knowledge Map, live docs, and task-tree status match the measured
    boundary.
  Commit: `DART-BACKEND-PARITY.6.2.4.5 - close parser smoke no drift`; retained completion note: No-drift closeout confirms the non-PCRE parser-smoke residual group is complete and advances the frontier to `.6.2.4.6` for PCRE structural regex constructs.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.5`.

- ID: `DART-BACKEND-PARITY.6.2.4.6`
  Status: `done`
  Goal: Decide and implement or route unsupported PCRE structural regex constructs.
  Acceptance: EBNF and spec.spec smoke fixtures no longer fail merely because Dart `RegExp` rejects `\K`,
    recursive named subpatterns such as `(?&name)`, recursive whole-pattern forms such as Lispish `(?R)`,
    `(?(DEFINE)...)`, or related conditional/recursive constructs; the solution is explicitly bounded and
    documented, not an untracked broad regex-engine replacement.
  Commit: `DART-BACKEND-PARITY.6.2.4.6 - close Dart structural regex smoke`; retained completion note: Bounded structural regex matchers and `push(child, index)` action-edge payload extraction close the seven PCRE structural fixtures and the `.6.2.4` parser-smoke parent.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.4.6`.

- ID: `DART-BACKEND-PARITY.6.2.5`
  Status: `done`
  Goal: Route top-level `fn` corpus fixtures through the spec-defined function shell.
  Acceptance: Dart corpus execution obtains `function_definition` nodes from the owning spec-defined shell or a
    documented staged equivalent, feeds them through `parseSpecWithStagedUserFunctionDefinitionAsts(...)`, and
    passes the routed fixtures `terse_3_3_1_scalar_assignment_expressions`,
    `terse_3_3_4_assignment_expression_closure`, and `terse_4_3_2_user_function_runtime`; no Dart raw scanner may
    become the semantic source of truth for `fn` definitions.
  Commit: `DART-BACKEND-PARITY.6.2.5 - route Dart fn corpus through spec shell`; retained completion note: Corpus execution falls back from rule-only parsing to the spec-defined user-function shell for top-level `fn` fixtures; all three routed fixtures pass.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.2.5`.

- ID: `DART-BACKEND-PARITY.6.3`
  Status: `done`
  Goal: Finalize manifest drift guard and full Dart corpus gate.
  Acceptance: Dart runner rejects unsupported manifest format, mismatched counts, invalid/duplicate names,
    missing fixture dirs, stale extra dirs, and output mismatches; all current fixtures pass.
  Commit: `DART-BACKEND-PARITY.6.3 - close full Dart corpus gate`; retained completion note: Full Dart corpus execution is 99/99 green; CLI `--execute` without selectors runs the full manifest while drift guards remain strict.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.3`.

- ID: `DART-BACKEND-PARITY.6.4`
  Status: `done`
  Goal: Wire Dart parity into the local verification story.
  Acceptance: Focused Dart test commands are documented; broader local gate integration is added only when
    reliable and not dependent on absent local SDK state.
  Commit: `DART-BACKEND-PARITY.6.4 - wire Dart local verification`; retained completion note: `tools/run_dart_local.sh` owns the focused Dart gate; `tools/run_ci_local.sh` includes it only under `LINKEDSPEC_RUN_DART=1`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.6.4`.

- ID: `DART-BACKEND-PARITY.7`
  Status: `done`
  Goal: Close documentation, generated-source follow-up, and handoff alignment.
  Children: `.7.1`, `.7.2`, `.7.3`, `.7.4`, `.7.5`

- ID: `DART-BACKEND-PARITY.7.1`
  Status: `done`
  Goal: Document Dart backend usage, status, and parity boundaries in the mdBook.
  Acceptance: Book pages explain how to run Dart, what parity gate it satisfies, and any remaining
    limitations in variant-neutral terms.
  Commit: `DART-BACKEND-PARITY.7.1 - close Dart mdBook usage status`; retained completion note: mdBook command/status/handoff docs now match the 99/99 interpreter-first Dart parity boundary and follow-up lanes.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.7.1`.

- ID: `DART-BACKEND-PARITY.7.2`
  Status: `done`
  Goal: Decide and optionally implement generated Dart source as a post-interpreter proof.
  Acceptance: Generated Dart source is either implemented against the already-green interpreter model or
    deliberately deferred with clear blockers; it is not the primary parity gate.
  Commit: `DART-BACKEND-PARITY.7.2 - defer Dart generated source proof`; retained completion note: Generated Dart source is deferred to a future split source-emitter lane with explicit proof prerequisites.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.7.2`.

- ID: `DART-BACKEND-PARITY.7.3`
  Status: `done`
  Goal: Record the director directive that each LinkedSpec backend variant should have a distinct CLI.
  Acceptance: The Dart task tree and future-backlog tree record the per-variant CLI requirement, a future
    Dart-specific implementation leaf exists, and no CLI behavior changes are made in this planning slice.
  Commit: `DART-BACKEND-PARITY.7.3 - record variant-specific CLI requirement`; retained completion note: Docs-only split for per-variant LinkedSpec CLI productization.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.7.3`.

- ID: `DART-BACKEND-PARITY.7.4`
  Status: `done`
  Goal: Productize the Dart-specific LinkedSpec CLI entrypoint.
  Acceptance: The Dart backend exposes its own clearly named LinkedSpec CLI entrypoint, help text, argument
    contract, corpus/runtime invocation path, docs, and smoke tests without replacing or conflating the Perl and
    Rust variant CLIs. Naming must be consistent with the cross-variant requirement that each backend variant has
    a distinct CLI.
  Commit: `DART-BACKEND-PARITY.7.4 - productize Dart-specific CLI`; retained completion note: Dart-specific CLI help and corpus command route through the shared manifest-backed runtime command implementation; corpus runner remains a compatibility wrapper.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.7.4`.

- ID: `DART-BACKEND-PARITY.7.5`
  Status: `done`
  Goal: Final no-drift closeout for Dart parity.
  Acceptance: Roadmaps, task-tree index, live docs, mdBook, Knowledge Map, architecture snapshot, and
    verification commands agree that Dart reaches the accepted scoped milestone.
  Commit: `DART-BACKEND-PARITY.7.5 - close Dart parity milestone`; retained completion note: Final no-drift closeout marks the scoped interpreter-first Dart milestone complete and returns future backend rollout to the backlog tree.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.21`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree DART-BACKEND-PARITY --epoch TYPE-REFERENCE-BOOK.1.2.23.4.21 --id DART-BACKEND-PARITY.7.5`.

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
| 9 | `DART-BACKEND-PARITY.4.5.0` | `done` | Diagnostics/trace controls are split before code. |
| 10 | `DART-BACKEND-PARITY.4.5.1` | `done` | Structured runtime diagnostics are implemented. |
| 11 | `DART-BACKEND-PARITY.4.5.2` | `done` | Trace controls, levels, event classes, and sinks are implemented. |
| 12 | `DART-BACKEND-PARITY.4.5.3` | `done` | Runtime branch/lifecycle/source-boundary trace instrumentation is implemented. |
| 13 | `DART-BACKEND-PARITY.4.5.4` | `done` | Diagnostics/trace no-drift is closed. |
| 14 | `DART-BACKEND-PARITY.5.1` | `done` | Minimal staged registry provider dispatches function-body parse jobs and stitches `body_ast`. |
| 15 | `DART-BACKEND-PARITY.5.2` | `done` | Registered exact-arity user functions execute at runtime. |
| 16 | `DART-BACKEND-PARITY.5.3` | `done` | Staged parse-job and function-registry descriptor shapes are preserved. |
| 17 | `DART-BACKEND-PARITY.6` | `done` | Corpus parity is closed: `.6.2.4` shipped-spec/parser-smoke is 31/31 green, `.6.2.5` routes the top-level `fn` fixtures through the spec-defined shell, `.6.3` closes the full 99-fixture corpus gate, and `.6.4` wires the focused Dart gate into local verification. |
| 18 | `DART-BACKEND-PARITY.7.1` | `done` | mdBook usage/status/handoff documentation now matches the green `.6` corpus and verification boundary. |
| 19 | `DART-BACKEND-PARITY.7.2` | `done` | Generated Dart source is deferred to a future split source-emitter lane; the interpreter-first 99/99 corpus run remains the conformance gate. |
| 20 | `DART-BACKEND-PARITY.7.4` | `done` | Dart-specific CLI productization is complete; the command routes corpus validation/execution through the existing Dart runtime harness. |
| 21 | `DART-BACKEND-PARITY.7.5` | `done` | Final no-drift closeout confirms the Dart scoped interpreter-first milestone is complete; future generated-source proof and Julia/Lua rollout are separate backlog lanes. |

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

- `2026-07-10` cross-tree audit (`FUTURE-PARITY-BACKLOG.1.4`): Dart's implemented package already satisfies
  ADR `0022` structurally. `parseSpec(...)`, `compileSpec(...)`, and `LinkedSpecRuntimeEngine.parse(...)` are
  native in-process APIs; `executeCorpusFixtures(...)` composes them; the Dart-specific CLI delegates to that
  library/corpus implementation and owns no exclusive parser/compiler/runtime semantics. The closed Dart
  behavioral claim remains the existing 99/99 scoped interpreter milestone.
- `2026-07-09`: Dart starts interpreter-first. The primary parity path is
  `.spec` parser -> typed helper/action AST -> compiled-spec state -> Dart runtime interpreter -> manifest-backed
  corpus runner. Generated Dart source is deferred to `.7.2` after interpreter parity because the Rust interpreter
  is the current full-corpus gate, HandlerIR lifecycle slots still document Perl-string coupling, and text-to-AST
  is the conformance doctrine for new backends.
- `2026-07-09`: `.7.2` defers generated Dart source instead of implementing it as a one-slice proof. A future
  source-emitter lane must be split at least into emitter scaffold/compile-run harness, generated family-plan
  metadata, direct structural-family execution, and curated manifest-backed corpus proof. The Dart conformance
  gate remains interpreter-first 99/99 corpus execution.
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
- `2026-07-09`: Dart `.4.5.1` exposes structured runtime diagnostics through
  `RuntimeInterpreterException.diagnostic` rather than changing successful parse-result JSON or adding a Perl-style
  mutable `last_error` channel. Optional `specName` / `specPath` engine fields carry file identity when callers
  have it.
- `2026-07-09`: Dart `.4.5.2` adds trace controls and sinks without claiming full trace parity.
- `2026-07-09`: Dart `.4.5.3` adds runtime interpreter trace events for rule scopes, regex matching,
  action/blind child dispatch, lifecycle blocks, cursor controls, recursion cutoffs, and source-boundary capture.
- `2026-07-09`: Dart `.4.5.4` closes diagnostics/trace no-drift. Dart status surfaces agree that diagnostics,
  trace controls/sinks/events, and runtime trace events are implemented; staged registry/user-function runtime
  work remains `.5`.
- `2026-07-09`: Dart `.5.1` adds the minimal staged parser registry for function-body parse jobs. The Dart API
  now resolves `actionir-body.spec` deterministically, records the fixed adapter digest/cache key and compiled
  parser shape for top rule `action_block`, executes jobs in stable order, and stitches returned `action_block`
  JSON into `body_ast`. General public `parse_job(...)` authoring and recursive staged queues remain future work.
- `2026-07-09`: Dart `.5.2` executes registered exact-arity user functions at runtime before helper fallback.
  Arguments evaluate eagerly in the caller; params bind into fresh function-local scalar/array/hash stores; bodies
  return the final expression or local `return(...)`; returned values continue through receiver chains; standalone
  calls discard their results; wrong arity and direct/mutual recursion diagnose instead of falling to raw host code.
- `2026-07-09`: Dart `.5.3` closes the staged/user-function descriptor-shape proof. Dart now asserts neutral
  `body_payload`, normalized `body_parse_job`, stitched `body_ast`, `function_order`, and runtime output from the
  same compiled state, keeping the staged prototype shape aligned before corpus parity work starts.

## Open Questions

- None. Dart interpreter corpus parity, mdBook usage/status documentation, generated-source deferral, and
  Dart-specific CLI productization are closed; this tree has no remaining active frontier.

## Blockers

- None.

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
| `2026-07-09` | `DART-BACKEND-PARITY.4.5.0` | memory architecture; Knowledge Map generation/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Runtime diagnostics/trace controls are split into structured diagnostics, trace controls/sinks, runtime trace instrumentation, and no-drift closeout leaves; no source behavior changed. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.5.1` | Focused `dart test test/runtime_interpreter_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart runtime failures now carry structured `RuntimeDiagnostic` payloads through `RuntimeInterpreterException.diagnostic` without changing successful parse output; frontier advances to `.4.5.2` trace controls/sinks. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.5.2` | Focused `dart test test/trace_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart trace levels, config/env controls, event primitives, stdout/route/mirror sinks, reset/truncate, and traced parse entrypoints are implemented; frontier advances to `.4.5.3` runtime trace instrumentation. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.5.3` | Focused `dart test test/trace_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart runtime tracing emits parse/rule scopes, regex decisions, child-dispatch decisions, lifecycle marks, cursor-control marks, recursion-cutoff decisions, and source-boundary marks while preserving untraced parse output; frontier advances to `.4.5.4` diagnostics/trace no-drift. |
| `2026-07-09` | `DART-BACKEND-PARITY.4.5.4` | `dart run bin/linkedspec_dart.dart --help`; focused diagnostics/trace drift scans; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart diagnostics/trace status is aligned across README, CLI/scaffold, mdBook, live docs, roadmap, task tree, MEMORY, and Knowledge Map; `.4.5` closes and frontier advances to `.5.1` staged registry work. |
| `2026-07-09` | `DART-BACKEND-PARITY.5.1` | Focused `dart test test/staged_parser_registry_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart staged registry resolves `actionir-body.spec`, records staged cache/compiled-parser metadata, executes jobs in stable order, and stitches `body_ast`; frontier advances to `.5.2` user-function runtime execution. |
| `2026-07-09` | `DART-BACKEND-PARITY.5.2` | Focused `dart test test/runtime_interpreter_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart executes registered exact-arity user functions before helper fallback with eager caller-side args, fresh function-local stores, receiver continuation, standalone discard, arity diagnostics, and direct/mutual recursion diagnostics; frontier advances to `.5.3` descriptor-shape preservation. |
| `2026-07-09` | `DART-BACKEND-PARITY.5.3` | Focused `dart test test/compiled_spec_test.dart`; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`; `dart run bin/corpus_runner.dart --help`; `dart run bin/linkedspec_dart.dart --help`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart preserves neutral staged user-function descriptor shapes through parsed functions, compiled registry jobs, descriptor functions records, stitched `body_ast`, descriptor metadata, and runtime output; `.5` closes and frontier advances to `.6` corpus parity. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.4.4.3` | Focused `dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart`; focused helper/text-normalizing corpus run; diagnostic `--execute --offset 68 --limit 31` boundary measurement; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; CLI/help corpus-loader smokes; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart statement-form helper mutation, explicit split replacement, and entry/local line helpers close `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute`; the parser-smoke window moves from 19/31 to 22/31 green and frontier advances to `.6.2.4.4.4`. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.4.4.4` | Focused `dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart`; focused structural corpus run; diagnostic `--execute --offset 68 --limit 31` boundary measurement; `dart format --set-exit-if-changed .`; `dart analyze --fatal-infos --fatal-warnings`; `dart test`; CLI/help corpus-loader smokes; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart `push(Child)` current-rule accumulator semantics close `regdef_nested_register_fields`; `ds_vhistory_version_entry` is routed to `.6.2.4.4.5` with direct-access/oracle evidence; the parser-smoke window moves from 22/31 to 23/31 green. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.4.4.5` | Perl public-parser and descriptor-handler probes for `ds_vhistory`; `call_spec_handler_subst` direct-access lowering probe; minimal scalar-held `payload[1]` public-parser probe; minimal leading-newline action-edge reproduction; focused Dart `ds_vhistory_version_entry` corpus run; Rust `oracle_corpus_matches_perl_reference`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. The `ds_vhistory` residual is split with durable evidence: public Perl/Rust expect null for the leading-newline fixture, direct descriptor execution returns `/proj/foo`, ordinary scalar-held indexed access still works, and `.6.2.4.4.6` owns the actual boundary decision. No Dart runtime behavior changed. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.4.4.6` | Focused `dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart`; focused `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case ds_vhistory_version_entry`; diagnostic `--execute --offset 68 --limit 31`; `dart format --set-exit-if-changed .`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart now mirrors Perl public-parser leading blank/comment-line skipping before the top rule; `ds_vhistory_version_entry` passes, ordinary scalar-held indexed reads remain public, and the parser-smoke window moves from 23/31 to 24/31 green with only PCRE structural regex blockers remaining. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.4.5` | Diagnostic `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`; final parser-smoke no-drift scans across README, mdBook, roadmaps, live docs, task tree, and Knowledge Map; Dart format/analyze/full tests; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Final no-drift closeout confirms the shipped-spec/parser-smoke window is 24/31 green, all non-PCRE residual leaves are closed, and only the seven PCRE structural regex blockers remain under `.6.2.4.6`. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.4.6` | Focused `dart test test/runtime_matching_test.dart test/runtime_interpreter_test.dart test/corpus_manifest_test.dart`; diagnostic `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`; default 99-fixture corpus loader; Dart format/analyze/full tests; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Bounded Dart structural matchers close the exact shipped recursive/DEFINE/`\K` PCRE forms, action-edge `push(child, index)` preserves EBNF logging payloads, the parser-smoke window is 31/31 green, and the frontier advances to `.6.2.5`. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.2.5` | Focused `dart test test/user_function_definition_parser_test.dart test/corpus_manifest_test.dart test/runtime_interpreter_test.dart test/action_contracts_test.dart`; routed three-fixture corpus run; Dart format/analyze/full tests; default 99-fixture corpus loader; diagnostic `--execute --offset 68 --limit 31`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart corpus execution obtains spec-produced function-definition nodes from `specs/user_function_definition.spec`, feeds them through staged function-body projection, and closes the three top-level `fn` fixtures without adding a raw Dart scanner. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.3` | Full `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute`; focused `dart test test/corpus_manifest_test.dart`; Dart format/analyze/full tests; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Dart corpus execution runs the current 99-fixture manifest end to end with 99 passed / 0 failed; CLI full-run mode is enabled, and manifest format/name/count/drift/file/mismatch guards are test-covered. |
| `2026-07-09` | `DART-BACKEND-PARITY.6.4` | `bash tools/run_dart_local.sh`; default `bash tools/run_ci_local.sh` skip-path smoke; Dart format/analyze/full tests; full 99-fixture corpus execution; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; `git diff --check`. | PASS. Focused Dart verification is repo-owned and documented, and the canonical local gate can include it with `LINKEDSPEC_RUN_DART=1` without depending on Dart SDK availability by default. |
| `2026-07-09` | `DART-BACKEND-PARITY.7.1` | mdBook build; `bash tools/run_dart_local.sh`; default `bash tools/run_ci_local.sh`; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. Dart usage/status/handoff docs now describe the focused gate, optional local-CI inclusion, direct Dart commands, the interpreter-first 99/99 corpus boundary, and generated-source / Dart-specific CLI follow-ups. |
| `2026-07-09` | `DART-BACKEND-PARITY.7.2` | mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. Generated Dart source is deferred to a future split source-emitter lane; the interpreter-first 99/99 corpus run remains the Dart conformance gate. |
| `2026-07-09` | `DART-BACKEND-PARITY.7.4` | `bash tools/run_dart_local.sh`; `dart run bin/linkedspec_dart.dart --help`; `dart run bin/linkedspec_dart.dart corpus --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 1`; mdBook build; memory architecture; Knowledge Map regeneration/check; task-tree metadata; doctrine; stale-status scans; `git diff --check`. | PASS. Dart-specific CLI productization is complete: `bin/linkedspec_dart.dart` owns help text plus the corpus command, `bin/corpus_runner.dart` remains a compatibility wrapper, and the full focused Dart gate is green over 140 tests, bounded Dart-specific CLI corpus smoke, and the 99-fixture corpus. |
| `2026-07-09` | `DART-BACKEND-PARITY.7.5` | `bash tools/run_dart_local.sh`; `mdbook build docs/linkedspec-book`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_task_tree_metadata.sh`; `bash scripts/check_doctrines.sh`; default `bash tools/run_ci_local.sh`; stale-status scans; `git diff --check`. | PASS. Final no-drift closeout marks the Dart scoped interpreter-first milestone complete, keeps generated Dart source deferred to a future proof lane, and returns future backend rollout to `FUTURE-PARITY-BACKLOG.1.2` for Julia planning. Focused Dart gate passes 140 Dart tests and 99/99 corpus execution; default local CI passes phase0 `1..1028`. |

## Commit Log

Canonical task-node Commit fields retain every consolidated table label, reference and note. Exact source and
Git comparison are owned by `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6`; no acceptance or verification field changes.

## Changelog

- `2026-07-09`: Created the Dart backend parity task tree and selected an interpreter-first parity path.
- `2026-07-09`: Closed the Dart scoped interpreter-first milestone under `.7.5`; no active Dart frontier remains,
  generated Dart source stays deferred to a future split proof lane, and future backend rollout returns to
  `FUTURE-PARITY-BACKLOG.1.2` for Julia planning.
- `2026-07-09`: Productized the Dart-specific CLI under `.7.4`; frontier advanced to `.7.5` final no-drift closeout.
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
- `2026-07-09`: Split Dart runtime diagnostics/trace controls into `.4.5.1` structured diagnostics, `.4.5.2`
  trace controls/sinks, `.4.5.3` runtime trace instrumentation, and `.4.5.4` no-drift closeout.
- `2026-07-09`: Added Dart `RuntimeDiagnostic` payloads on `RuntimeInterpreterException.diagnostic`; frontier
  advances to `.4.5.2` for trace controls, event classes, and sink behavior.
- `2026-07-09`: Added Dart trace levels, controls, event primitives, stdout/routed-file/mirror sinks, and traced
  runtime entrypoints; frontier advances to `.4.5.3` for branch/lifecycle/source-boundary runtime trace events.
- `2026-07-09`: Added Dart runtime interpreter trace events for rule scopes, regex matching, action/blind child
  dispatch, lifecycle blocks, cursor controls, recursion cutoffs, and source-boundary capture; frontier advances to
  `.4.5.4` diagnostics/trace no-drift.
- `2026-07-09`: Closed Dart diagnostics/trace no-drift; `.4.5` closes and frontier advances to `.5.1` staged
  registry provider work.
- `2026-07-09`: Added Dart staged function-body registry dispatch; `actionir-body.spec` now resolves through the
  built-in provider, compiles top rule `action_block`, executes queued jobs in stable order, and stitches
  `body_ast`; frontier advances to `.5.2` user-function runtime execution.
- `2026-07-09`: Added Dart registered exact-arity user-function runtime execution; calls resolve before helper
  fallback, use eager caller-side args, fresh function-local stores, receiver-chain continuation, standalone
  discard, and recursion diagnostics; frontier advances to `.5.3` descriptor-shape preservation.
- `2026-07-09`: Added Dart staged user-function descriptor-shape proof; parsed, compiled, descriptor, and runtime
  layers preserve neutral `body_payload`, `body_parse_job`, `body_ast`, and function-order fields; `.5` closes and
  frontier advances to `.6` corpus parity.
- `2026-07-09`: Closed Dart helper mutation/text-normalization parser-smoke parity; statement-form
  `substr(...)` / `regex_subst(...)`, explicit `split(array(...), ...)` replacement, and entry/local line helpers
  make `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass, moving the diagnostic
  window to 22/31 green and frontier to `.6.2.4.4.4`.
- `2026-07-09`: Closed Dart legacy accumulator parser-smoke parity; one-argument action-edge `push(Child)` now
  appends child returns to the current rule accumulator, making `regdef_nested_register_fields` pass. The
  diagnostic window is 23/31 green, and `ds_vhistory_version_entry` is routed to `.6.2.4.4.5` for direct-access
  oracle/contract closeout.
- `2026-07-09`: Split the `ds_vhistory_version_entry` residual again after public-parser and descriptor-handler
  probes showed a leading-newline public-parser/oracle boundary, not a safe global direct-access weakening. The
  next frontier is `.6.2.4.4.6` for the actual boundary decision before final parser-smoke no-drift closeout.
- `2026-07-09`: Resolved the `ds_vhistory_version_entry` leading-newline boundary by mirroring the Perl public
  parser's leading blank/comment-line skip in Dart. The fixture now passes, the non-PCRE residual group is green,
  the shipped-smoke window is 24/31, and the frontier advances to `.6.2.4.5` for final no-drift closeout.
- `2026-07-09`: Closed final shipped-spec/parser-smoke no-drift for the non-PCRE residual group. The measured
  window remains 24/31 green, current docs and Knowledge Map agree, and the frontier advances to `.6.2.4.6` for
  the seven PCRE structural regex blockers.
- `2026-07-09`: Closed the seven PCRE structural regex blockers with bounded Dart structural matchers and
  action-edge `push(child, index)` parity. The shipped-spec/parser-smoke window is 31/31 green, `.6.2.4` is
  closed, and the frontier advances to `.6.2.5`.
- `2026-07-09`: Closed Dart top-level `fn` corpus routing by executing `specs/user_function_definition.spec` in
  Dart, feeding returned `function_definition` nodes through staged function-body projection, and passing the three
  routed terse user-function fixtures. Frontier advances to `.6.3`.
- `2026-07-09`: Closed the full Dart corpus gate at 99/99 green, enabled unbounded CLI `--execute`, and locked
  manifest format/name/count/drift/file/mismatch guards in focused tests. Frontier advances to `.6.4`.
- `2026-07-09`: Closed Dart local verification wiring with `tools/run_dart_local.sh` and optional
  `LINKEDSPEC_RUN_DART=1` integration in `tools/run_ci_local.sh`. Frontier advances to `.7.1`.
- `2026-07-09`: Closed Dart mdBook usage/status/handoff documentation. The book now names the focused Dart gate,
  optional local-CI inclusion, direct Dart test/full-corpus commands, the 99/99 interpreter-first parity boundary,
  and generated-source / Dart-specific CLI follow-ups. Frontier advances to `.7.2`.
- `2026-07-09`: Deferred generated Dart source to a future split source-emitter lane. The current Dart conformance
  gate remains the interpreter-first 99/99 corpus run; future generated-source proof must own emitter scaffold,
  family-plan metadata, direct structural-family execution, and curated corpus subset evidence. Frontier advances
  to `.7.4`.
