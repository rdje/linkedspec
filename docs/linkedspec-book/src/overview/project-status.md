# Project Status

LinkedSpec is an actively evolving system. The current direction is not “freeze everything exactly as it once was.” The direction is to preserve the strengths that make LinkedSpec useful while modernizing the runtime, compiler, diagnostics, and documentation.

LinkedSpec is also a multi-backend system. The `.spec` language is the one universal contract; each backend is an execution platform that runs the same `.spec` files with identical semantics. The Perl implementation is the **reference backend** (the canonical behavioral oracle), and a Rust backend is the second execution platform. ADR 0021 schedules future full-parity backend work as Dart first, Julia second, and Lua third. ADR 0022 makes native in-memory host-language embedding the primary backend product surface; variant CLIs are thin adapters. ADR 0023 defines complete parity as identical user-observable capabilities/behavior and gives distinct backend executable names one exact primary CLI interface. Status below therefore distinguishes scoped milestones from complete parity.

## Completed phases

Phases 0–9 of the modernization roadmap are done:

- **Phase 0**: Regression safety net — `t/phase0_regression.t` covers all 21 shipped specs with a green `1028`-test baseline; every `.spec` compiles at `language_agnostic_ready_ratio == 1.0000` (zero compatibility-surface rules).
- **Phase 1**: Thin facade + owner dispatch — `LinkedSpec.pm` is a lazy public facade over owner modules that route through uniform `OwnerDispatch`; the former `ActionRewriter.pm` forwarding shim was deleted (118 lines).
- **Phase 1A**: Thin-façade modularization — `LinkedSpec.pm` delegated into focused owner modules (`Trace`, `Validation`, `Resolver`, `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `RuleIR`, `EmitContext`); the shared `OwnerDispatch` seam replaced per-owner lazy-loading wrappers.
- **Phase 2**: DSL frontend hardening — rule-label parsing, inside-block rejection, extra-colon rejection, fluent-continuation recognition, `strict_syntax` mode, construct-recognition alignment with bootstrap grammar.
- **Phase 3**: Execution semantics — seek/consume parse modes documented; explicit cursor controls are local cursor operations, not systemic backtracking; forward-moving non-backtracking model stated.
- **Phase 4**: Capture/mark API — 163 contracts across 6 families verified, compat aliases documented, mark-helper reference complete.
- **Phase 5**: Runtime diagnostics — structured last_error is the single diagnostics channel; handler compile warnings routed through trace instead of stderr; eval minimized to one handler compilation; trace bridging from compile scopes into runtime handler scopes.
- **Phase 6**: Documentation and adoption — the book you are reading. All identified documentation gaps closed (LinkedRE, Validation, public API, cross-linking, overviews, ActionIR lowering, per-spec walkthroughs).
- **Phase 7**: Self-hosted `spec.spec` grammar — LinkedSpec parses its own `.spec` language through the DSL itself. `spec.spec` compiles at `language_agnostic_ready_ratio == 1.0000` with regression coverage; it is the required change surface for `.spec` language evolution.
- **Phase 8**: Multi-backend specification and handoff — the `.spec` language, runtime semantics, helper contracts, and HandlerIR are specified backend-neutrally, so a backend can be built in any language without reading the reference source. The multi-backend vision — the same `.spec` files, the same semantics, and the same test corpus across all backends — is recorded in ADR 0006. This phase was specification-only (no behavioral code change).
- **Phase 9**: Rust variant — a second execution backend. The Rust workspace (`rust/`: `linkedspec-core` + `linkedspec-runtime`) carries its own `.spec` parser, compiler, runtime engine, and helper surface, and runs `.spec` files compiled from the same universal contract. It is operational in interpreted mode, and the current manifest-backed Rust oracle is green over 105 fixtures plus manifest drift guards. The generated-source path proves direct execution for the current structural families plus a curated manifest-backed corpus subset.

The active Dart backend follows the same interpreter-first path. It now has source parsing, validation,
compiled-spec state, runtime interpretation, staged user-function body parsing, exact-arity user-function runtime
execution, and a controlled executable corpus harness whose full checked-in 105-fixture manifest passes through Dart
execute mode. The final shipped-spec/parser-smoke
window is now 31/31 green after the structural regex closeout following the regex-dialect, helper/action,
recursion/default-mode, portmap result-shape, hlink delimiter/capture, helper mutation/text-normalization, and
legacy accumulator and public-parser leading-trivia bridges. Basic
Dart regex-dialect bridging is now in place for POSIX character classes, inline/scoped flags, possessive
quantifier markers, lower-bound `{,n}` quantifiers, and Python-style named captures. Scoped flag groups are accepted
by lifting their options to Dart `RegExp`. The missing helper/action bridge is also in place for direct
capture-slice helpers, diagnostic output helpers, logical helpers, `exit_now`, and quoted helper-call delimiter
parsing. Dart now also resolves tclite-style action-edge regex dispatch, scopes explicit aggregate resets per rule
invocation, refreshes `retv` from `call(...)`, and appends into scalar-held lists created by assignments such as
`items = []`. Statement-form `substr(...)` / `regex_subst(...)` mutations, explicit
`split(array(target), ...)` replacement, and entry/local line helpers are also implemented, and Dart mirrors the
Perl public parser's leading blank/comment-line skip before the top rule. The tclite, recursive top-rule, hlink,
tablegrep, simenv, `lib_reader`, `regdef`, `ds_vhistory`, Lispish, EBNF, and spec.spec parser-smoke fixtures now
pass. Bounded structural matchers handle the exact shipped recursive/DEFINE/`\K` PCRE forms, and action-edge
`push(child, index)` preserves EBNF logging payloads. Dart full-corpus parity is now 105/105 green, and the focused
Dart local gate is available through `tools/run_dart_local.sh` or opt-in `LINKEDSPEC_RUN_DART=1` local CI.

The Method-like DSL migration track is also complete: all 21 shipped specs are at zero compatibility-surface rules, 100+ helpers across 10 families are regression-locked, current helper names are the only documented helper surface, and fluent/block equivalence is verified. Current setup and read forms use direct assignments, `set(...)`, bare scalar reads, `array(...)`, `hash(...)`, `push(...)`, `copy(...)`, and `return(...)`. Unknown typed calls in return/value positions diagnose through the generic unknown-helper path instead of emitting generated host-language calls, while unregistered standalone function-shaped statements remain explicit raw compatibility debt. Top-level `fn name(args) { ... }` definition shells are parsed by `specs/user_function_definition.spec` and projected through the active user-function registry, with params, arity, source/body spans, body source, neutral `body_payload`, neutral `body_parse_job`, and body AST recorded. The parse-job sidecar now dispatches through the minimal staged registry provider for `actionir-body.spec` / `action_block`, and the returned `action_block` AST is stitched into `body_ast`; general public `parse_job(...)` authoring remains future work. On Perl, Rust, and Dart, registered exact-arity user-function calls now execute in value positions, compatible receiver chains, and standalone discard statements: arguments evaluate eagerly in the caller, params bind in a fresh function-local scope, and the result is the final expression or `return(expr)` payload. Recursive and unsupported function-body forms are fenced as diagnostics with zero raw fallback on the Perl reference; Rust and Dart directly diagnose recursive calls in their runtime resolvers. The accepted MVP surface is closed at explicit-paren, braced `fn` definitions; alternate spellings, omitted zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/currying, and function namespaces remain deferred extension topics.

## Backbone items

Three backbone items tracked major structural modernization — all done:

1. Declarative bootstrap grammar registry replacing positional bootstrap coupling (done)
2. Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases (done)
3. Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting (done)

## Ongoing

- **Documentation and book sync** — the book is kept aligned with the codebase as features land and surfaces evolve.
- **Variant-agnostic documentation** — this book is being aligned so it describes the `.spec` contract, DSL, and helper semantics backend-neutrally, with the Perl implementation shown as the reference backend rather than as "the" implementation.
- **Future backend parity backlog** - `FUTURE-PARITY-BACKLOG` owns deferred parity work. Exact CLI `.1.5`, all non-codegen capability work `.1.6`, and generated-source `.3` are closed at 60 pass / zero partial / zero gap for Perl, Rust, Dart, and Julia. Lua now has typed source/ActionIR/compiled state, exact 239-name and 105-fixture validation, dual-ABI native PCRE2 matching, and a first in-memory compiled-rule interpreter on PUC Lua and LuaJIT. Its runtime preserves four value kinds, isolated stores/snapshots, checked access/assignment, `retv`, complete entry/match reads, and deterministic non-case scalar/string helper/receiver execution; 70/70 tests pass on both runtimes. Unicode 17 full-default casing has verified official inputs, a generated neutral contract, 12 fixtures, and an offline CI checker. Perl/Rust/Dart/Julia generated-table consumption passes every scalar/receiver/array path and full backend gates; PUC Lua/LuaJIT and six-variant admission are active. Scalar-to-text normalization follows in `.1.3`, and regex/split/mutation remains `.4.3.2.2`. Staged execution, corpus execution, exact primary CLI, capability admission, and generated source remain open.
- **Semantic introspection / MCP direction** - parked `.10.1` will design one versioned, deterministic semantic
  query model exposed from every native backend. It covers rules/edges/calls, spans/provenance, inferred shapes,
  resolution, generated-source relationships, diagnostics, and explanations. MCP is a thin transport over that
  model; backend AST/IR layouts and transport-specific behavior are explicitly outside the public contract.
- **Generic trailing codeblock correction** - parked `.11.1` supersedes the narrow abstraction chosen by the
  closed `SPEC-FORMAT-TERSE.14` MVP. Current Perl/Rust/Dart/Julia implementations support named `with` and tree
  traversal block surfaces, not generic equivalence. The intended four-kind model is scalar, array, harray/hash,
  and codeblock; for a signature with a final codeblock, `call(args) { block }` and
  `call(args, { block })` must become the same call in every backend. The design will decide whether `with` remains
  an ordinary block-taking helper or is removed. Lua parses the generic shape but has no executable trailing-block
  helper semantics yet.
- **Dart backend parity** - `DART-BACKEND-PARITY` is complete only for the scoped interpreter-first Dart milestone. Its strategy is
  interpreter-first over typed `.spec` and helper/action AST plus compiled-spec state, with generated Dart source
  deferred to a future split source-emitter lane rather than required for the current conformance claim. The repo now has a `dart/` backend package with a Dart-specific CLI,
  manifest/corpus IO validation, source-level AST/data types with JSON round-trip coverage, a core `.spec` rule
  parser with shipped-spec plus rule-only corpus parser coverage, frontend validation/strict-syntax checks,
  spec-returned function-definition projection, typed ActionIR helper/action parsing, ActionIR contract
  resolution, a user-function registry seam, a compiled-spec state model, runtime matching primitives, and the
  first runtime rule interpreter. Dart ActionIR parsing covers calls, literals, access, shape literals,
  assignments, block values, attached controls, receiver chains, trailing blocks, and standalone value-drop
  statements; the resolver records current canonical helper/control contracts and generic diagnostics over those
  typed nodes. With a `UserFunctionRegistry`, exact-arity user calls classify before helper fallback while
  wrong-arity registered calls report user-function arity diagnostics. `compileSpec(...)` builds ordered
  `CompiledSpec` / `CompiledRule` state, structured dependency-regex data, mode metadata, lifecycle/action
  `ActionBlock` payloads, function projection, and descriptor-shaped `spec` / `functions` /
  `dependency_regex_map` / `meta` JSON. Runtime matching supports seek/consume modes, stable alternative identity,
  capture and named-capture records, char-offset projections, entry/local match registers, cursor state, and
  zero-progress detection. `LinkedSpecRuntimeEngine` now executes default/AND/OR/repetition rule families with
  action-edge and blind-call child dispatch, lifecycle blocks, explicit returns, `retv`, accumulators, bounded
  repetition, zero-progress cutoffs, and recursion cutoffs. Its evaluator now also preserves
  scalar/array/hash/null/boolean/number shapes through assignment and wrapper snapshots, supports `hash(...)`,
  `set(hash(...), ...)`, hash-index mutation, nested reads, non-numeric map keys, aggregate `copy(...)`,
  named/map/position capture helpers, string/scalar helpers, explicit `str_*` lexical comparisons, numeric helpers,
  numeric aliases/symbol callees, compatible string/number receiver chains, array helper family breadth, regex
  split/filter bridges, delimiter-first `join_values`, array numeric reducers, statement-only array end mutations,
  hash helper family breadth, hash receiver chains, statement/value mutation boundaries, nested value-path
  assignment with no-autovivification failure behavior, explicit flat-style hash splicing, expression-valued
  blocks with block-local return, attached and inline structured controls,
  helper/receiver `with` trailing blocks, hash/array tree traversal receiver callbacks, `save_cursor()` /
  `restore_cursor()` stack semantics, `rewind_match_start()` / `rewind_entry_start()` anchor rewinds, and
  char-based cursor/input helpers, `capture_until_boundary(rule[, ...])` non-consuming structural boundary
  capture. Runtime failures now expose structured Dart `RuntimeDiagnostic` payloads through
  `RuntimeInterpreterException.diagnostic` with stable owner/stage/rule/source attribution. Dart also has ordered
  trace levels, `LinkedSpecTraceConfig`, event/scope primitives, stdout/routed-file/mirror sinks with
  reset/truncate behavior, and traced runtime entrypoints that preserve parse output while emitting a parse-scope
  event. Dart runtime tracing now also emits rule scopes, regex match/no-match decisions, action/blind child
  dispatch decisions, lifecycle block marks, cursor-control marks, recursion-cutoff decisions, and
  `capture_until_boundary(...)` source-boundary marks. The diagnostics/trace no-drift sweep is closed. Dart now
  also has the minimal staged parser registry for function-body parse jobs: `actionir-body.spec` resolves to the
  built-in `action_block` provider, dispatch records carry the staged cache key and compiled parser shape, queued
  jobs execute in stable order, and the returned `action_block` JSON is stitched into `body_ast`. Dart registered
  exact-arity user-function calls now execute before helper fallback with eager caller-side arguments, fresh
  function-local scalar/array/hash stores, final-expression or local-return results, receiver-chain continuation,
  standalone discard, and direct/mutual recursion diagnostics. Dart now also preserves neutral staged function
  descriptor shapes through parsed functions, compiled registry jobs, descriptor `body_payload`,
  `body_parse_job`, stitched `body_ast`, function-order metadata, and runtime output. Dart now also treats empty
  array/hash returns as successful non-null rule matches, uses child-rule match bits for blind dispatch, and
  executes marker-form `if(...)` / `elseif(...)` / `else()` / `endif()` statement chains as grouped branches. It
  also preserves assignment expressions inside helper arguments, supports plain fallback values in inline
  `if(...)`, evaluates numeric aggregate reducers over bare arrays, and follows scalar-held list/map readback for
  `array(name)`, `hash(name)`, and `copy(name)`. Append-style mutations now update scalar-held lists before
  aggregate fallback, and `call(...)` refreshes the runtime `retv` channel. The full checked-in 105-fixture corpus
  passes through Dart execute mode. The top-level `fn` corpus
  function fixtures obtain `function_definition` nodes from `specs/user_function_definition.spec` and staged body
  projection rather than a Dart raw scanner. The final shipped-spec/parser-smoke window is split after a 2/31
  diagnostic run and is now 31/31 green. The basic regex-dialect bridge, helper/action bridge,
  recursive/default-mode bridge, portmap result-shape bridge, hlink delimiter/capture bridge, and helper
  mutation/text-normalization bridge are done, the legacy accumulator bridge closes `regdef`, and the public-parser
  leading-trivia bridge closes `ds_vhistory`; bounded structural matchers close the exact shipped PCRE structural
  forms. The green corpus gate is wired into a focused Dart local gate and optional local-CI path. Generated Dart
  source is explicitly deferred to a future source-emitter lane with scaffold, family-plan, direct-family execution,
  and curated-corpus proof prerequisites. Dart's backend-local corpus CLI implementation is complete:
  `bin/linkedspec_dart.dart` owns help text plus a `corpus` command that validates or executes the manifest-backed
  corpus through Dart parse/compile/runtime, while `bin/corpus_runner.dart` remains a compatibility wrapper. The
  strict-interface audit has since shown this is not yet the shared parser CLI contract. No active Dart frontier
  remains in its original scoped tree; global `.1.5.3`, `.1.6`, and `.3` own complete CLI/capability/codegen parity.
- **Julia backend parity** - `JULIA-BACKEND-PARITY` is the active second future-backend lane. It starts from the
  Dart lesson: interpreter-first over typed `.spec` and helper/action AST plus compiled-spec state, with generated
  Julia source left as a later proof decision. `JULIA-BACKEND-PARITY.1.1` verified Homebrew Julia 1.12.6 against the
  official current stable release. `JULIA-BACKEND-PARITY.1.2` created the repo-owned `julia/` package scaffold:
  package metadata, committed manifest, `LinkedSpecJulia` module, Julia-specific CLI, corpus-runner stub, README
  commands, and smoke tests. `JULIA-BACKEND-PARITY.1.3` adds JSON3-backed manifest IO and drift/file guards over
  the checked-in 99-fixture corpus while `--execute` still reports not implemented. `JULIA-BACKEND-PARITY.2.1`
  adds source AST/data types and JSON round-trip coverage for spec files, functions, source spans, staged parse
  jobs, rule modes, body elements, edges, and fluent calls. `JULIA-BACKEND-PARITY.2.2` adds `parse_spec(...)` for
  core rule paragraphs: headers/modes, regex slots, lifecycle blocks, action/blind-call edges, fluent
  continuations, markers, comments, and block boundaries. `JULIA-BACKEND-PARITY.2.3` adds `validate_spec(...)`
  for top-rule presence, duplicate labels/functions, function registry collisions, raw fallback rejection, edge
  consistency, undefined references, regex-slot bounds, regex structure, and strict unused-rule behavior.
  `JULIA-BACKEND-PARITY.2.4` consumes the neutral `function_definition` / `function_definition_error` node shape
  owned by `specs/user_function_definition.spec`, validates staged sidecars, strips function spans before rule
  parsing, and keeps direct `parse_spec(...)` rule-only. `JULIA-BACKEND-PARITY.3.1` adds typed ActionIR parsing
  for calls, literals, variables, direct/nested access, shape literals, assignments, block values, structured
  controls, receiver chains, trailing blocks, standalone value-drop statements, and raw fallback nodes.
  `JULIA-BACKEND-PARITY.3.2` adds `resolve_action_block_contracts(...)`,
  `resolve_action_statement_contracts(...)`, `resolve_action_expression_contracts(...)`,
  `canonical_action_helper_name(...)`, and `is_known_action_ir_call_name(...)` for canonical ActionIR
  helper/control contract records and generic unknown-helper/raw diagnostics. `JULIA-BACKEND-PARITY.3.3` adds
  `UserFunctionRegistry`, staged body parse-job queue projection, immutable `body_ast` stitching, and registry-aware
  exact-arity user-call classification before helper fallback. `JULIA-BACKEND-PARITY.3.4` adds
  `compile_spec(...)`, `CompiledSpec`, `CompiledRule`, `CompiledDependencyRegexState`, and
  `CompiledDescriptorState` for ordered compiled rules, dependency refs, dependency-regex rows, mode metadata,
  lifecycle/action payload ASTs with registry-aware contracts, function registry projection, and descriptor-shaped
  JSON. `JULIA-BACKEND-PARITY.4.1` adds stable native-PCRE alternatives, seek/consume selection, full and compact
  captures, named captures, character and line/column projection, cursor/capture anchors, separate entry/local
  match registers, and zero-progress detection. `JULIA-BACKEND-PARITY.4.2` adds first compiled-rule execution for
  default/AND/OR/repetition modes, lifecycle flow/events, action/blind children, `retv`, explicit returns, narrow
  accumulators/capture reads, output projection, repetition bounds, zero-progress termination, and recursion
  cutoffs. `JULIA-BACKEND-PARITY.4.3.0` splits the broader evaluator by mechanism: core stores/captures,
  string/numeric helpers, arrays, hashes, value/control/block/callback execution, and no-drift closeout.
  `JULIA-BACKEND-PARITY.4.3.1` adds scalar/array/hash stores, bare and typed snapshots, structural
  assignments/access, final checked no-autovivification nested writes, and entry/local capture maps and positions.
  `JULIA-BACKEND-PARITY.4.3.2` adds current string/scalar and numeric helpers, retained regex flags, word and
  symbol aliases, invalid-input boundaries, and compatible receiver chains through one canonical dispatcher.
  `JULIA-BACKEND-PARITY.4.3.3` adds copied array pipelines, string/regex/split bridges, flattening and numeric
  terminals, typed split replacement, and statement-only named/scalar-held end mutations.
  `JULIA-BACKEND-PARITY.4.3.4` adds copied hash views and pure transformations, compatible receiver chains,
  statement-only named set-key mutation, direct hash-index assignment, base/overlay-aware merge resolution, and
  explicit flat-style splicing while preserving ordinary nested maps.
  `JULIA-BACKEND-PARITY.4.3.5` adds expression-valued blocks with local returns, attached and marker controls,
  lazy inline branches, deterministic while guards, immediate helper/receiver with-blocks, and scoped hash/array
  walk/map/reduce callbacks with lazy non-aggregate failure.
  `JULIA-BACKEND-PARITY.4.3.6` confirms helper/value no-drift at 567 assertions without a runtime correction;
  package status remains `runtime-value-control-tree`, and central helper-catalog examples use semicolons only as
  same-line separators.
  `JULIA-BACKEND-PARITY.4.4` adds explicit LIFO cursor save/restore, entry/local anchor rewinds, synchronized
  live/register cursor updates, character-based cursor/input helpers, and earliest usable non-consuming
  named-rule boundary capture with EOF and unresolved-rule behavior.
  `JULIA-BACKEND-PARITY.4.5.0` splits diagnostics/trace into structured diagnostics, trace controls/events/sinks,
  runtime instrumentation, and no-drift closeout before implementation code.
  `JULIA-BACKEND-PARITY.4.5.1` exports neutral-field structured runtime diagnostics on exceptions, preserves
  optional spec identity and child rule/handler attribution, and leaves successful parse output unchanged.
  `JULIA-BACKEND-PARITY.4.5.2` adds ordered trace levels, environment/config controls, structured events/scopes/
  decisions/logs/dumps, stdout/route/mirror sinks with reset, and output-preserving traced runtime entrypoints.
  `Pkg.instantiate()`, `Pkg.test()`, CLI help/status, and corpus validation commands pass with a writable depot.
  `JULIA-BACKEND-PARITY.4.5.3` adds rule scopes, regex decisions, action/blind child dispatch, lifecycle marks,
  recursion cutoffs, cursor transitions, and source-boundary events while preserving untraced output. The full
  suite passes with 631 assertions and package status is `runtime-trace-events`. `.4.5.4` closes diagnostics/trace
  no-drift without a source correction. `.5.1` adds deterministic built-in ActionIR-body registry dispatch,
  portable cache/compiled/result records, immutable JSON `body_ast` stitching, and a composed staged shell API.
  `.5.2` resolves registered exact-arity functions before helper fallback, evaluates arguments in caller scope,
  executes cached ActionIR bodies with fresh scalar/array/hash stores, restores caller stores, returns final
  expressions or local-return payloads, composes receiver chains, discards standalone results, and diagnoses
  direct/mutual recursion. `.5.3` then locks neutral function payload provenance, normalized parse jobs, stitched
  ActionIR bodies, and descriptor function order/count through the same executable compiled state. `.6.1` now adds
  controlled library corpus execution with manifest-to-runtime composition, one-level wrapped structural output
  comparison, optional trace lines, structured diagnostic retention, and all-fixture reporting. The full suite
  passes with 715 assertions and package status `runtime-controlled-corpus` at that boundary. `.6.2.0` splits the
  rollout, and `.6.2.1` adds ordered named/offset/limit selection plus bounded runner PASS/FAIL reporting. `.6.2.2`
  proves starter fixtures 0–39 green at 40/40 without production or fixture changes. `.6.2.3` proves non-function
  windows 40–56, 58–59, and 62–67 green at 25/25 unchanged and routes offsets 57, 60, and 61 to `.6.2.5`. Full
  tests pass with 757 assertions and status `runtime-corpus-middle` at that boundary. `.6.2.4.0` measures and
  splits shipped-spec/parser-smoke fixtures 68–98 at 10/31. `.6.2.4.1` adds the complete direct anonymous capture
  family, closes three hlink delimiter cases, and routes EBNF logging to structural output. Full tests pass with
  766 assertions and status `runtime-corpus-capture-boundaries` at that boundary. `.6.2.4.2.1` adds eager logical
  helpers, closes three portmap cases plus tablegrep, and routes portmap constant's helper-regex `o` flag residual.
  `.6.2.4.2.3` then centralizes helper regex flags and closes portmap constant. `.6.2.4.2.2` adds trace-routed,
  parse-result-neutral diagnostic output and advances simenv/history beyond unsupported `print`. `.6.2.4.3`
  scopes explicit aggregate resets per recursive rule invocation and closes all three recursive top-rule cases.
  `.6.2.4.4` adds action-edge child-push result reuse/indexing, closes all four spec.spec smokes, and routes EBNF
  quote-only statement mutation. `.6.2.4.5.1` adds immediate explicit/default `exit_now(...)` termination and
  structured runtime attribution, advancing simenv to its earlier statement-form scalar-mutation prerequisite.
  `.6.2.4.5.2` then adds statement-context scalar regex mutation, closes both EBNF, both lib_reader, and simenv,
  and preserves pure numeric slicing. `.6.2.4.5.3` then mirrors public-parser leading blank/comment skipping and
  closes history without weakening indexed reads. `.6.2.4.6` adds one permanent full-window regression over
  offsets 68–98: 31/31 exact outputs with stable endpoints and zero failures. `.6.2.5` then executes the checked-in
  user-function definition spec over top-level `fn` source, normalizes its neutral nodes, and reuses existing staged
  body parsing. All three routed fixtures pass. `.6.3` then runs the complete validated manifest as one ordered
  library gate and enables unbounded CLI execution; both are 99/99 green with exact outputs. Full tests pass with
  840 assertions and status `runtime-corpus-full`. `.6.4` has since added focused optional-SDK verification, and
  `.7.1` has closed public commands, native examples, status, and limitation alignment. `.7.2` has since deferred
  the separate generated-source proof to `FUTURE-PARITY-BACKLOG.3`. `.7.3.0` split strict user-facing parity after proving current CLI drift;
  `.7.3.1` ratifies ADR `0023` and cross-backend routing. `.7.3.2.0` has since split Julia CLI work,
  `.7.3.2.1` closes optional shared-emitter trace coverage, and `.7.3.2.2` closes exact options, subcommand/
  positional rejection, named resolution, and source/input loading. `.7.3.2.3` now closes native rule/function
  primary execution and recursively key-sorted direct JSON. `.7.3.2.4` now closes phase-ordered failures, stable
  stderr/exit, and stdout/route/mirror/file/reset/emoji behavior with 75 focused assertions; 1,023 package
  assertions and 99/99 pass. `.7.3.2.5` now adds nine direct process families and focused-gate delegation; status
  is `runtime-corpus-primary-cli`, and `.7.3.3` closes honest local no-drift. The later exhaustive current-surface
  gate is now 239 names and 105/105 exact fixtures across all four variants. Public generated source remains
  deferred to `.3`; global CLI identity `.1.5` and language-surface `.1.6.1` are closed, while remaining outward
  API capability leaves under `.1.6` still block a complete Julia capability-parity claim.
- **Non-current helper code purge** - `NONCURRENT-HELPER-CODE-PURGE` is closed. Perl source cleanup, Rust source cleanup, active test/tool/generated fixture and checked-in `.spec` migration, and final no-drift scans are complete. Retired helper-looking calls use generic unknown-helper fallback behavior, active generic-unknown-helper tests use invented helper names, and active helper-call/label/tag scans are clean.
- **Generated-source convergence** — closed at 60/0/0. The interpreter oracle remains primary. Perl, Rust, Dart, and Julia pass contract v1. Rust's strict recurring classifier compiles/runs all 105 generated fixtures. Dart and Julia each have exact ten-family direct routing, four plan rejections, portable trace roles, isolated all-family proof, and contract-sourced interpreter-first 8/105 host admission. Julia additionally locks Unicode-safe strict-UTF-8/hex payloads and typed metadata/errors. Host-source bytes may differ; observations may not. Lua inherits the complete contract; its dependency-free native scaffold passes PUC/LuaJIT and typed JSON/corpus IO is active.
- **Lifecycle-family audit** — verified complete (2026-06-14). All 7 lifecycle markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`) have full semicolon-light structured authoring coverage. Newlines separate top-level helper statements; a semicolon separates adjacent statements on one physical line and is not required after the last statement. No lifecycle-specific semantic gaps found.
- **Terse `.spec` format evolution** — the active language-evolution track now supports auto-existing working variables, canonical helper renames (`set`, `cat`, `copy`), scalar/array/hash mutation operators, typed primitive literals, newline-or-semicolon statement separators, direct nested access such as `payload["children"][0]["name"]`, nested value-path assignment such as `payload["children"][0]["name"] = value`, attached-block `if`/`when`/`switch`/`while` control flow, inline value `if`/`switch` in `return(...)`, assignment RHS, and fluent `.return(...)`, deep pure-helper composition, array receiver-dot value chains such as `items.sorted().drop_front(2).first()` and `items.uniq().join_values(",")`, hash receiver-dot value chains such as `meta.set_key("stage", "normalized").sorted_keys().join_values(",")`, string receiver-dot value chains such as `raw.trim().lowercase().replace_substr("-", "_")` and `raw.trim().split("-").trim_each().join_values("|")`, number receiver-dot value chains such as `score.abs().ceil().add(2).clamp(0, 10)` and `count(array(parts)).gt(0)`, function-style numeric aliases such as `add(2, mul(3, 4))` and `gt(count(array(parts)), 0)`, arithmetic symbol callees such as `+(2, *(3,4))`, comparison symbol callees such as `>(count(array(parts)), 0)` and `==("2", "2")`, explicit string comparison helpers such as `str_eq(trim(kind), "word")` and `str_gt("2", "10")`, scalar assignment value expressions such as `return(name = "ok")`, `return(=(other, "ok"))`, and `=(raw, " text ").trim()`, aggregate assignment value expressions such as `return(items = [value])`, `return(set(meta, { key : value }))`, and `=(items, [value]).count()`, mutation assignment value expressions such as `return(items += value)`, `return(meta[key] = value)`, `(items += value).count()`, and `(meta[key] = value).count_keys()`, expression-valued block receivers such as `{ [3, 1, 2] }.sorted().join_values(",")`, `{ " a-b " }.trim().split("-").count()`, `{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`, helper-function form and receiver-method form trailing block arguments on Perl and Rust such as `with(value) { return(cat(value, "!")) }` and `" a-b ".trim().with() { return(value.split("-")) }.count()`, hash-tree receiver block traversal methods such as `tree.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) }`, `tree.walk_leaves() { paths += join_values("/", array(path)) }`, and `tree.reduce_leaves(0) { return(acc.add(1)) }`, array-tree receiver block traversal methods such as `items.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) }`, `items.walk_leaves() { paths += join_values("/", array(path)) }`, and `items.reduce_leaves(0) { return(acc.add(1)) }`, bare aggregate working-variable snapshots in supported hash- and array-consuming helper slots such as `merge_hash(copy(hash(base)), overlay)` and `count(drop_front(sorted(items)))`, and bare scalar reads in return/assignment source slots, mutation key/RHS slots, direct path atoms, direct shape-literal values such as `[value]` and `{ "kind" : value }`, `if`/`while` conditions, numeric/comparison helper args, and switch subjects. Switch case labels remain literal tag positions: `switch(kind)` reads scalar `kind`, while `case(word)` matches the literal `"word"`. It also supports exact-arity user functions such as `fn normalize(value) { return(trim(value)) }` and `fn no_args() { return("ok") }`, with calls usable as values, receiver-chain receivers, or standalone discarded statements on Perl, Rust, Dart, and Julia. Direct RHS shape literals bind typed values on bare assignment targets (`items = [value]`, `meta = { key : value }`); explicit `array(...)` and `hash(...)` targets preserve aggregate storage. Examples include `return(i)`, `set(out, if(is_nonempty(flag), "yes", else("no")))`, `out = switch(kind, case("word", "word"), default("other"))`, `return(name = "ok")`, `items += value`, `return(items += value)`, `items.sorted().first()`, `meta.set_key("stage", "normalized").count_keys()`, `raw.trim().split("-").lowercase_each().join_values("_")`, `score.abs().round().gt(3)`, `gt(count(array(parts)), 0)`, `+(2, *(3,4))`, `str_eq(lowercase(trim(kind)), "word")`, `meta[key] = value`, `return(meta[key] = value)`, `payload["children"][i]`, `return([value, { "key" : value }])`, `return(with("x") { return(cat(value, "!")) })`, `return(" x ".with() { return(cat(value, "!")) }.trim())`, `return({ "a" : "A", "b" : { "y" : "B" } }.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })`, `return(["a", ["b"]].map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })`, `return(normalize(" x "))`, `words(" go ").join_values("|")`, `switch(kind) { case("word") { return("word") } default { return("other") } }`, `items = [value]`, and `meta = { key : value }`. Function syntax remains the explicit-paren, braced `fn` MVP; alternate spellings, optional zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/currying, and namespaces are deferred. The comparison migration is complete through symbol callees: `str_*` is shipped and preferred for lexical string comparisons, while bare comparison words and comparison symbol callees are numeric aliases over `num_*`. Scalar, aggregate, array append, and hash-index mutation expression-valued assignment are shipped under `SPEC-FORMAT-TERSE.3.3.1` through `.3.3.3`, with legacy assignment spelling cleanup closed by `.3.3.4`; current cross-backend trailing block arguments are intentionally limited to immediate helper-function `with(...)`, receiver-method `.with()`, and tree traversal receiver methods `walk_leaves`, `map_leaves`, and `reduce_leaves`, not closures or delayed callbacks.
- **Shipped-spec terse-source migration** — complete. Current shipped specs, broader public examples, and checked-in corpus/test-spec examples prefer auto-existing working variables, operator assignment/reset forms, `set(...)`, `push(...)`, `copy(...)`, and `cat(...)`. Deleted helper spellings are no longer part of the current contract surface.

## What this means for readers

- Some older historical names appear in repo history and older notes. The active code path uses the current vocabulary.
- The current public and architectural explanations in this book prefer the active surfaces, not the oldest historical vocabulary.
- For the most current implementation status, the repo's `ROADMAP_V2.md` and `ARCHITECTURE_STATE.md` remain the fastest-changing references. This book absorbs that understanding over time in a more stable, explanatory form.

The project is healthy, actively maintained, and moving in a clear direction. Each phase leaves the codebase in a more explainable, more trustworthy state than it found it.
