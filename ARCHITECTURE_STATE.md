# ARCHITECTURE STATE
Live architecture snapshot for LinkedSpec.

This document is the current high-level technical reading of the project shape. It is meant to steer implementation, record important architectural judgments, and give future sessions a fast way to re-enter the codebase with the right mental model.

## Status
- Last refreshed: `2026-07-10`
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.2.3` centralizes strict helper regex compilation. Meaningful
  `i`/`m`/`s`/`x` reach Julia `Regex`; execution-only `g` and Perl compile-once `o` are accepted no-ops; unknown
  flags and invalid patterns remain failures. Predicate and split helpers share the seam. Portmap constant passes,
  full tests remain 772, shipped smoke is 18/31, status is `runtime-corpus-helper-regex-flags`, and `.6.2.4.2.2`
  is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.2.1` adds eager boolean `and`/`or`/`not` through the existing
  runtime truthiness contract, including Rust-compatible empty arities. Three portmap cases and tablegrep pass;
  direct compacted-capture and trace probes route `portmap_constant` to `.6.2.4.2.3` because Perl's no-op `o` flag
  currently invalidates Julia helper regex compilation. Full tests pass with 772, shipped smoke is 17/31, status is
  `runtime-corpus-logical-helpers` at that boundary; `.6.2.4.2.3` has since closed portmap constant and
  `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.1` executes the complete direct anonymous capture-boundary
  family over the existing rule-local register: start; match-start/cursor/input-end text and character lengths;
  origin position/line/column; and destructive take variants. Focused Unicode/location/mutation and corpus proofs
  bring full tests to 766, all three hlink delimiter fixtures pass, the shipped-smoke window is 13/31, and EBNF
  logging routes to structural output. Status is `runtime-corpus-capture-boundaries` at that boundary;
  `.6.2.4.2.1` has since moved the window to 17/31 and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.4.0` measures the complete shipped-spec/parser-smoke window at
  10 passed / 21 failed and decomposes it before behavior changes. Owned groups are anonymous capture boundaries,
  logical helpers, diagnostic-output helpers, recursive top-rule outputs, EBNF/spec.spec structural outputs,
  lib_reader quote normalization, and final 31/31 no-drift. Runtime status remains `runtime-corpus-middle` at 757
  assertions at that boundary; `.6.2.4.1` has since moved the window to 13/31 and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.3` proves the 25 non-function middle fixtures through bounded
  windows 40–56, 58–59, and 62–67 with no production or fixture correction. A permanent window/endpoint/count/
  failure regression also locks the exact top-level function offsets routed to `.6.2.5`. Full tests pass with 757
  assertions, status advances to `runtime-corpus-middle`, and shipped-spec/parser-smoke fixtures 68–98 are active
  under `.6.2.4`; `.6.2.4.0` has since split the 10/31 diagnostic boundary and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.2` proves manifest fixtures 0–39 green through bounded
  parse/compile/runtime execution with no production or fixture correction. A permanent endpoint/count/failure
  regression test brings the suite to 751 assertions and status `runtime-corpus-starter` at that boundary;
  `.6.2.3` has since closed 25/25 and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.1` adds ordered named and zero-based bounded corpus selection
  after complete manifest validation, plus opt-in runner PASS/FAIL reporting and stable exit codes. Validation-only
  default behavior remains; CLI execution requires a named case or positive limit until full parity. Thirty added
  assertions bring the suite to 745 and status `runtime-corpus-selection` at that boundary. `.6.2.2` and `.6.2.3`
  have since closed 40/40 and 25/25; `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.2.0` decomposes the 99-fixture Julia rollout before behavior
  changes into bounded selection/reporting, starter 0–39, middle non-function 40–67, shipped-spec/parser-smoke
  68–98, and spec-defined function-shell owners. The executable architecture remains the 715-assertion
  `runtime-controlled-corpus` `.6.1` boundary at that planning point; `.6.2.1` through `.6.2.4.2.3` have since landed
  and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.6.1` adds Julia's controlled corpus composition layer.
  `execute_corpus_fixtures(...)` reuses manifest validation, parses/compiles/executes every fixture, structurally
  compares one-level wrapped output, captures optional trace lines and structured runtime diagnostics, and reports
  every failure without aborting. Six passing authored fixtures plus diagnostic/mismatch continuation add 24
  assertions; full tests pass with 715, status advances to `runtime-controlled-corpus`, and `.6.2` manifest batches
  are active. CLI `--execute` remains later work.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.5.3` locks neutral staged function descriptor shape through one
  executable fixture. Spec-returned definition order, payload provenance, normalized job ids/paths/policies,
  stitched ActionIR bodies, compiled registry order, public descriptor function metadata, and runtime output agree.
  No projection correction was required; status remains `runtime-user-functions` at that boundary and full tests
  pass with 691 assertions. `.6.1` through `.6.2.4.2.3` have since landed; `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.5.2` adds registered exact-arity runtime calls before helper
  fallback. Arguments evaluate eagerly in caller scope; cached ActionIR bodies execute with fresh scalar/array/hash
  stores; caller stores restore exception-safely; final expressions/local returns feed value and receiver positions;
  standalone results drop; and direct/mutual recursion emits structured cycle diagnostics. Package status is
  `runtime-user-functions`, and the full suite passes with 671 assertions. `.5.3` has since closed `.5`, `.6.1`
  has since landed, `.6.2.0` has split the rollout, `.6.2.1` through `.6.2.4.2.3` have landed, and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.5.1` adds Julia's narrow staged function-body registry. It resolves
  the fixed built-in ActionIR adapter, orders jobs structurally, records portable cache/compiled/result metadata,
  parses typed ActionIR into neutral JSON, validates sidecars, and immutably stitches `body_ast`. Package status is
  `runtime-staged-registry` at that boundary, and the full suite passes with 662 assertions. `.5.2` and `.5.3` have
  since landed, `.5` is closed, `.6.1` through `.6.2.4.2.3` have since landed, and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.4` closes the scoped Julia diagnostics/trace container with no
  source correction. The 631-assertion suite, package/CLI `runtime-trace-events` status, book, KM, roadmap/task/live
  docs, and architecture agree on structured runtime diagnostics plus control/sink/event/runtime-instrumentation
  capabilities without overclaiming compile/parser tracing or staged/corpus parity. `.5.1` through `.5.3` have
  since landed, `.5` is closed, `.6.1` through `.6.2.4.2.3` have since landed, and `.6.2.4.2.2` is active.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.3` instruments the existing Julia runtime path with optional
  rule scopes, regex/action/blind/recursion decisions, lifecycle marks, cursor/stack transitions, and boundary
  events. Absent/disabled emitters remain no-ops; scope cleanup is exception-safe; traced and untraced action,
  blind, and recursion results agree. Package status is `runtime-trace-events`, the full suite passes with 631
  assertions, and final diagnostics/trace no-drift advances to `.4.5.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.2` adds Julia-native ordered trace levels,
  environment/config controls, structured event/scope/decision/log/dump primitives, stdout/route/mirror sinks
  with reset, optional runtime emitter injection, and output-preserving traced wrappers. Package status is
  `runtime-trace-controls`, the full suite passes with 617 assertions, and instrumentation advances to `.4.5.3`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.1` exports neutral-field `RuntimeDiagnostic` payloads on Julia
  runtime exceptions, carries optional spec identity plus top/rule/handler attribution through nested failures,
  preserves richer inner diagnostics, and leaves successful parse output/textual errors unchanged. Package status
  is `runtime-diagnostics`, the full suite passes with 588 assertions, and trace controls advance to `.4.5.2`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.5.0` splits Julia diagnostics/trace before code into stable
  structured runtime diagnostics, reusable trace levels/config/events/sinks, interpreter instrumentation, and
  final no-drift owners. Runtime behavior and `runtime-cursor-boundary` status are unchanged; `.4.5.1` is the sole
  active frontier.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.4` adds Julia's explicit LIFO cursor stack, synchronized
  live/register cursor updates, entry/local anchor rewinds, character-based cursor/input helper projection, and
  earliest usable non-consuming named-rule boundary capture. Cursor moves preserve match records and semantic
  stores; normal follow-on matching retains the configured seek/consume mode. Package status is
  `runtime-cursor-boundary`, the full suite passes with 581 assertions, and diagnostics/trace advances to `.4.5`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.6` closes Julia helper/value no-drift. The 567-assertion suite,
  `runtime-value-control-tree` package status, mdBook contracts, live docs, and Knowledge Map agree; `.4.3.1`
  already supplied the final checked no-autovivification nested-write contract, so no runtime correction was
  required. Stale `.3`/`.4.3` parent metadata and central helper-catalog line-ending semicolons are reconciled;
  `.4.4` owns cursor controls and boundary capture.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.5` separates Julia rule-level action flow from block-local
  value flow; adds attached and marker controls, lazy inline branches, deterministic while guards, immediate
  helper/receiver with-blocks, scoped binding snapshots, and hash/array tree walk/map/reduce callbacks. Hash
  traversal is sorted-key depth-first; array traversal is zero-based depth-first; non-aggregate receivers do not
  evaluate callbacks or reduce initializers. Package status is `runtime-value-control-tree`; `.4.3.6` owns final
  helper/value no-drift.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.4` adds copied Julia hash helper/receiver dispatch, pure
  merge/pick/drop/rename/set-key transformations, statement-only named typed set-key mutation, direct hash-index
  assignment integration, base/overlay-aware merge resolution, and explicit flat-style constructor splicing.
  Ordinary map values stay nested. At that leaf package status was `runtime-hash-helpers`; `.4.3.5` has since
  added value/control/block/callback execution.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.3` adds a copied Julia array helper/receiver dispatcher,
  string/regex split and filter bridges, explicit flatten/constructor-splice semantics, numeric reducer terminals,
  typed split replacement, and isolated statement-only end mutation for named and scalar-held arrays.
  Value-position end methods return `nothing` without mutation. At that leaf package status was
  `runtime-array-helpers`; `.4.3.4` has since added hashes.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.2` adds a canonical Julia runtime pure-helper dispatcher.
  Current string/scalar transforms, predicates, regex operations, coalescing, definedness/emptiness, explicit
  lexical comparisons, numeric arithmetic/unary/reducers/comparisons, aliases and symbol callees, JSON-number
  normalization, and compatible fluent chains now share one execution path. Package status is
  `runtime-string-numeric`; `.4.3.3` owns array-aware helper and mutation behavior.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.1` extends the Julia interpreter with its portable core value
  model. `_RuntimeExecutionContext` now owns scalar, array, and hash stores; the evaluator preserves JSON-safe
  shapes through typed/bare snapshots, literals, assignment, append, hash-index mutation, indexed/nested reads,
  and final checked no-autovivification nested writes. Entry/local capture helpers now expose names, maps,
  character spans, and line-column positions. At that leaf package status was `runtime-core-values`; `.4.3.2` has
  since advanced it to `runtime-string-numeric`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.3.0` splits the Julia helper/value runtime container before
  broader evaluator code. `.4.3.1` owns core JSON-shaped values, stores, assignments/access, snapshots, and
  `entry_*` / `match_*` capture helpers; `.4.3.2` owns string/numeric helpers; `.4.3.3` arrays; `.4.3.4` hashes;
  `.4.3.5` value/control/block/callback execution; `.4.3.6` final no-drift. The split mirrors the proven Dart
  rollout and changes no Julia runtime behavior.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.2` adds the first Julia compiled-rule interpreter.
  `julia/src/runtime/Interpreter.jl` defines `LinkedSpecRuntimeEngine`, `runtime_parse(...)`,
  `runtime_execute(...)`, `RuntimeParseResult`, `RuntimeLifecycleEvent`, and `RuntimeInterpreterException`.
  It executes default/AND/OR/repetition modes, action and blind-call children, `I/LS/LE/IT/EX/LX/E` lifecycle
  order, `retv`, explicit returns, narrow array accumulators/capture reads, seek/consume matching, bounded and
  zero-progress termination, and same-rule/slot/cursor recursion cutoffs. Its initial evaluator was deliberately
  dispatch-facing; `.4.3.1` has since added the core value/store/capture model.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.4.1` adds Julia runtime regex matching and match-state tracking.
  `julia/src/runtime/Matching.jl` defines seek/consume parse modes, compiled regex alternatives with stable
  zero-based identity, complete and compact capture projections, named captures, zero-based code-unit spans,
  public character offsets, line/column projection, cursor/capture anchors, separate entry/local match registers,
  and zero-width/zero-progress predicates. Julia's native PCRE integration accepts the currently required named
  capture, POSIX, flag, possessive, and recursive constructs directly, so this leaf needs no dialect-rewrite layer.
  First executable rule dispatch has since landed in `JULIA-BACKEND-PARITY.4.2`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.4` adds Julia compiled-spec state.
  `julia/src/compiler/CompiledSpec.jl` defines `compile_spec(...)`, `CompiledSpec`, `CompiledRule`,
  `CompiledRuleModeMetadata`, `DependencyRef`, action/blind edge records, `CompiledActionPayload`,
  `CompiledDependencyRegexState`, `CompiledDependencyRegexEntry`, and `CompiledDescriptorState`. The compiler reuses
  `validate_spec(...)` by default, records ordered rule/last-definition metadata, derives dependency-regex rows,
  parses lifecycle/action payloads into `ActionBlock` ASTs, resolves payload contracts with the user-function
  registry, carries function registry projection, and emits descriptor-shaped JSON with `julia_interpreter_rule`
  handlers marked `compiled_state_only`. Runtime regex matching has since landed in `JULIA-BACKEND-PARITY.4.1`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.3` adds the Julia user-function registry seam.
  `julia/src/action/FunctionRegistry.jl` defines `UserFunctionRegistry`, `UserFunctionEntry`, and
  `UserFunctionCallResolution`, builds ordered entries from `SpecFile.functions`, exposes staged
  `body_parse_job` records, preserves `body_payload` and optional `body_ast`, rejects duplicate names, and provides
  `stitch_function_body_ast(...)` for immutable staged body-AST replacement. `julia/src/action/ActionContracts.jl`
  now accepts `function_registry=...` so exact-arity registered calls classify as `user_function` before helper
  fallback, while wrong-arity registered calls diagnose as `user_function_arity_mismatch`. Function bodies are not
  executed yet. Compiled-spec state has since landed in `JULIA-BACKEND-PARITY.3.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.2` adds Julia ActionIR contract resolution.
  `julia/src/action/ActionContracts.jl` exposes `resolve_action_block_contracts(...)`,
  `resolve_action_statement_contracts(...)`, `resolve_action_expression_contracts(...)`,
  `canonical_action_helper_name(...)`, and `is_known_action_ir_call_name(...)`. The resolver walks typed
  ActionIR calls, receiver methods, structural assignments, structured controls, nested arguments, block values,
  shape literals, and access expressions, recording JSON-shaped contract and diagnostic records. Unknown
  helper-looking calls diagnose generically as `unknown_helper`, and `raw_perl` fallback nodes remain explicit
  diagnostics. `julia/src/spec/Validator.jl` now shares the resolver's current helper/control name predicate for
  user-function collision checks. Function-registry-aware exact-arity user-call classification, compiled state,
  and runtime execution remain later Julia leaves. Function-registry-aware classification has since landed in
  `JULIA-BACKEND-PARITY.3.3`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.3.1` adds Julia typed ActionIR parsing.
  `julia/src/action/ActionAst.jl` defines action blocks, value-drop statements, call/argument nodes, literals,
  variables, indexed/nested access, shape literals, assignments, receiver chains, trailing block payloads, block
  values, structured controls, and raw fallback nodes with JSON projection. `julia/src/action/ActionParser.jl`
  exposes `parse_action_block(...)`, `parse_action_statement(...)`, and `parse_action_expression(...)`. The parser
  is structural only; canonical helper-contract resolution has since landed in `JULIA-BACKEND-PARITY.3.2`, while
  compilation, runtime execution, staged body dispatch, diagnostics/trace, and corpus execution remain later Julia
  leaves.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.4` adds Julia function-definition shell projection.
  `julia/src/spec/UserFunctionDefinitionShell.jl` consumes `function_definition` / `function_definition_error`
  nodes shaped by `specs/user_function_definition.spec`, validates source/body spans and staged sidecars,
  normalizes `functions.<index>.body_source` parse-job paths, strips function-definition spans before rule parsing,
  and keeps direct `parse_spec(...)` rule-only. Typed helper/action AST parsing has since landed in
  `JULIA-BACKEND-PARITY.3.1`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.3` adds Julia frontend validation.
  `julia/src/spec/Validator.jl` exposes `validate_spec(spec; strict_syntax=false)` and
  `SpecValidationException`, checking top-rule presence, duplicate labels/functions, user-function registry shape,
  raw fallback lines, mixed edge families, grouped action blocks, undefined references, regex-slot bounds, regex
  structure, and strict unused-rule behavior. Tests validate all checked-in specs and rule-only corpus specs.
  Top-level `fn` shell projection has since landed in `JULIA-BACKEND-PARITY.2.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.2` adds Julia source parsing.
  `julia/src/spec/Parser.jl` exposes `parse_spec(source)` and `SpecParseException`, producing the `.2.1` source AST
  types for rule headers/modes, regex slots, lifecycle blocks, action/blind-call edges, fluent continuations,
  markers, comments, and block boundaries. Tests parse all 21 checked-in `specs/*.spec` files and rule-only corpus
  specs. Frontend validation has since landed in `JULIA-BACKEND-PARITY.2.3`; top-level `fn` shells remain
  rule-only for direct `parse_spec(...)`, with spec-shaped projection added in `JULIA-BACKEND-PARITY.2.4`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.2.1` adds Julia source AST/data types.
  `julia/src/spec/Ast.jl` defines data records and JSON projection for spec files, function definitions, source
  spans, staged parse jobs, rule headers/modes, body element variants, edge targets, and fluent calls. The field
  names mirror the Rust/Dart/mdBook source contract (`functions`, `rules`, `source_span`, `body_span`,
  `body_parse_job`, `line_start`, `line_end`, `parent_ast_path`, `result_policy`, `failure_policy`). This is still
  the data contract; parser behavior has since landed in `JULIA-BACKEND-PARITY.2.2`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.1.3` adds Julia corpus manifest IO.
  `julia/src/corpus/CorpusManifest.jl` now uses JSON3 to parse `manifest.json` and expected JSON, validates format
  `1`, case count, case names, duplicates, missing/stale fixture directories, required fixture files, and expected
  JSON syntax over the checked-in 99-fixture corpus. The Julia CLI/corpus runner report the validated fixture count
  in non-execute mode, and `--execute` still returns not implemented. The `.1` foundation container is closed; the
  source AST/data boundary has since landed in `JULIA-BACKEND-PARITY.2.1`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.1.2` creates the minimal Julia backend package scaffold.
  `julia/` now contains `Project.toml`, committed `Manifest.toml`, `src/LinkedSpecJulia.jl`, CLI/corpus modules,
  `bin/linkedspec_julia.jl`, `bin/corpus_runner.jl`, README commands, and a Julia `Test` smoke suite.
  `Pkg.instantiate()`, `Pkg.test()`, Julia CLI help/status, and corpus-runner scaffold commands pass with
  `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot`. At that leaf the scaffold intentionally had no `.spec`
  parser, manifest IO, runtime interpreter, or corpus execution semantics; manifest IO has since landed in `.1.3`.
- `2026-07-10` refresh: `JULIA-BACKEND-PARITY.1.1` completes Julia toolchain/package-layout preflight.
  The local backend toolchain is Homebrew-managed Julia 1.12.6 at `/opt/homebrew/bin/julia`, matching the official
  current stable release. `Pkg` and `Test` are usable with a writable Julia depot; the managed harness should set
  `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot` or equivalent when the default `~/.julia` depot is not
  writable. The planned repo-owned scaffold is `julia/` with `Project.toml`, `src/LinkedSpecJulia.jl`, CLI/corpus/
  spec/action/compiler/runtime subtrees, `bin/linkedspec_julia.jl`, `bin/corpus_runner.jl`, and `test/runtests.jl`.
  `JuliaFormatter` and `JET` are absent global optional tools. That planned scaffold has since landed in `.1.2`;
  no Julia parser semantics exist yet.
- `2026-07-09` refresh: `FUTURE-PARITY-BACKLOG.1.2` creates `docs/tasks/JULIA-BACKEND-PARITY.md` as the
  dedicated Julia backend plan. Julia follows Dart in the ADR `0021` rollout and starts interpreter-first:
  package/toolchain preflight, typed `.spec` frontend, typed helper/action AST, compiled state, runtime
  interpreter, staged user-function execution, diagnostics/trace, corpus parity, and mdBook/live-doc closeout.
  Generated Julia source is a later proof decision, not the initial gate. At creation time, the next frontier was
  `JULIA-BACKEND-PARITY.1.1` for toolchain/package-layout and variant-specific CLI preflight.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.5` closes the scoped Dart interpreter-first milestone.
  Dart now has a repo-owned package, typed frontend and ActionIR layers, compiled-spec state, runtime
  interpreter, staged user-function execution, diagnostics/trace controls, focused local verification,
  variant-specific CLI productization, and 99/99 corpus execution. Generated Dart source remains deferred to a
  future split source-emitter proof lane. No active Dart frontier remains; future backend rollout returns to
  `FUTURE-PARITY-BACKLOG.1.2` for Julia planning.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.4` productizes the Dart-specific LinkedSpec CLI.
  `dart/bin/linkedspec_dart.dart` now owns help text plus a `corpus` command that validates or executes the
  manifest-backed corpus through the Dart parser, compiler, and runtime. `dart/bin/corpus_runner.dart` remains a
  compatibility wrapper over the same command implementation. `.7.5` has since closed the Dart scoped
  interpreter-first milestone.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.1` closes Dart mdBook usage/status/handoff documentation.
  The book now names `bash tools/run_dart_local.sh`, opt-in `LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh`,
  direct `dart test`, and full corpus-runner execution as the Dart command surface. Current Dart parity is
  interpreter-first and 99/99 corpus-green; `.7.2` has since deferred generated Dart source to a future split
  source-emitter lane, Dart-specific CLI productization has since closed in `.7.4`, and `.7.5` has closed the
  scoped milestone.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.2` deliberately defers generated Dart source implementation.
  A future Dart source-emitter proof must be split like the Rust source-emitter lane: scaffold/compile-run harness,
  generated family-plan metadata, direct structural-family execution, and curated manifest-backed corpus subset.
  The current Dart conformance gate remains the interpreter-first 99/99 corpus run; the frontier later advanced
  through `.7.4`, and `.7.5` closed the scoped milestone.
- `2026-07-09` refresh: `BACKTRACK-SURFACE-RUST-ALIGNMENT` defines the current cross-variant cursor-control
  surface. Perl, Rust, and Dart expose `save_cursor()` / `restore_cursor()` for explicit cursor-stack semantics,
  `rewind_match_start()` / `rewind_entry_start()` for direct local-match or entry/initial-match anchor rewinds, and
  `capture_until_boundary(rule[, ...])` for non-consuming structural boundary capture. The old `BACKTRACK()` /
  `IBACKTRACK()` names and lowercase `backtrack(label)` / `ibacktrack(label)` forms are not current portable API.
  `specs/ebnf.spec` uses `capture_until_boundary(semantic_annotation, grammar_rule)` so semantic annotation bodies
  stop before the next annotation or grammar rule without consuming that boundary.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.4` first extended Dart runtime cursor semantics in
  `dart/lib/src/runtime/interpreter.dart` and `dart/lib/src/runtime/matching.dart`. That slice landed local
  cursor rewinds and char-based cursor/input helpers such as `cursor_pos`, `cursor_rest`, `input_slice`, and
  `input_end_pos`. `BACKTRACK-SURFACE-RUST-ALIGNMENT.1` has since renamed the current portable surface to
  `save_cursor()` / `restore_cursor()` and `rewind_match_start()` / `rewind_entry_start()`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.6` closed the Dart helper/value no-drift slice in
  `dart/lib/src/runtime/interpreter.dart`. Nested value-path assignment now matches the Perl/Rust contract:
  successful writes return the updated root aggregate, missing or wrong intermediate paths return `null` without
  mutation, final hash keys may be created, final array writes only replace or append exactly at `len`, and missing
  intermediate containers are not autovivified. Segment index expressions evaluate before the RHS value expression,
  matching the Rust/Perl lowering order. Direct hash-index assignment on scalar-held map/list roots now preserves
  root ownership before named hash fallback. Later Dart slices closed cursor-control alignment, diagnostics/trace,
  full corpus parity, local verification wiring, and mdBook usage/status documentation.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.5` extended Dart runtime ActionIR execution in
  `dart/lib/src/runtime/interpreter.dart`. `LinkedSpecRuntimeEngine` now evaluates expression-valued blocks with
  block-local `return(...)` / `return_undef()`, attached `if` / `elseif` / `else` and `when` / `otherwise`
  branch chains, attached `switch` / `case` / `default`, attached `while` with the deterministic iteration guard,
  inline lazy `if(...)` / `switch(...)`, helper-form `with(value) { ... }` / `with() { ... }`, receiver
  `.with() { ... }`, and hash/array `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver callbacks.
  Callback frames scope and restore `value`, `path`, `depth`, hash `key`, array `index`, and reduce-only `acc`;
  hash traversal is sorted-key depth-first and array traversal is zero-based depth-first. This fed the `.4.3.6`
  helper/value no-drift closeout, which has since landed.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.7.3` recorded the director directive that each LinkedSpec backend
  variant should have a distinct CLI. This is a planning/documentation slice only: Dart-specific CLI
  productization is now closed by `DART-BACKEND-PARITY.7.4`, the scoped Dart milestone is closed by `.7.5`, and Julia/Lua
  planning under `FUTURE-PARITY-BACKLOG` must include equivalent variant-specific CLI ownership. The runtime
  implementation frontier later advanced through `.4.3.5`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.4` extended Dart runtime hash helper execution in
  `dart/lib/src/runtime/interpreter.dart`. The evaluator now has hash-aware helper argument evaluation, bare hash
  working-variable receiver reads, pure hash receiver chains, key/value views, sorted key/value arrays, key
  predicates, `merge_hash`, `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `flat_hash`, statement-form
  `set_key(...)` mutation, direct hash-index assignment values, and explicit flat-style hash splicing inside
  `hash(...)`. Later Dart slices landed `.4.3.5`, BACKTRACK/cursor controls, tracing, corpus output parity, and
  local verification wiring, mdBook usage/status documentation, and per-variant CLI productization in `.7.4`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.3` extended Dart runtime array helper execution in
  `dart/lib/src/runtime/interpreter.dart`. The evaluator now has array-aware helper argument evaluation, bare array
  working-variable receiver reads, pure array receiver chains, regex split/filter bridges, delimiter-first
  `join_values`, `flat_array` / `concat_arrays`, `split_tagged_records`, terminal array numeric reducers, and
  statement-only array end mutations. Later Dart slices landed hash helpers, value-block/control/tree traversal
  helpers, BACKTRACK/cursor controls, tracing, corpus output parity, and local verification wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.2` extended Dart runtime helper execution in
  `dart/lib/src/runtime/interpreter.dart`. `LinkedSpecRuntimeEngine` now canonicalizes ActionIR helper names and
  executes current string/scalar helpers, explicit `str_*` lexical comparisons, numeric arithmetic/reducer/
  comparison helpers, numeric word aliases, arithmetic/comparison symbol callees, and compatible string/number
  receiver chains. Later Dart slices landed array/hash helpers, value-block/control/tree traversal helpers,
  BACKTRACK/cursor controls, tracing, corpus output parity, and local verification wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.1` extended Dart runtime core values and capture reads in
  `dart/lib/src/runtime/interpreter.dart`. The interpreter now preserves scalar, array, hash, null, boolean, and
  number shapes through assignment and wrapper snapshots; supports `hash(...)`, `set(hash(...), ...)`, hash-index
  mutation, nested reads, non-numeric map indexing, aggregate `copy(...)`, and the named/map/length/start/end
  `entry_*` / `match_*` helper family. Later Dart slices landed the broader helper families, value-block/control
  and tree traversal helpers, BACKTRACK/cursor controls, tracing, corpus output parity, and local verification
  wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.3.0` split the Dart runtime helper/value work before code.
  The first resulting frontier was `.4.3.1` for core runtime value/store behavior and capture helper reads,
  followed by string/number helpers, array helpers, hash helpers, value-block/control/tree traversal helpers, and
  a helper/value no-drift closeout before BACKTRACK work.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.2` added Dart's first runtime rule interpreter in
  `dart/lib/src/runtime/interpreter.dart`. `LinkedSpecRuntimeEngine` executes `CompiledSpec` rules over the
  `.4.1` matching layer and returns `RuntimeParseResult` with top-rule value, Rust-style one-element output,
  cursor offsets, and lifecycle events. It now covers default/AND/OR/repetition dispatch, action-edge and
  blind-call child execution, entry/local match handoff, explicit `return(...)` / `return_undef()`, `retv`,
  accumulator collection, bounded repetition, zero-progress cutoffs, and recursion cutoffs. Later Dart slices
  landed helper-family value semantics, BACKTRACK/cursor controls, diagnostics/tracing, corpus output parity, and
  local verification wiring.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.4.1` added Dart runtime regex/match-state primitives in
  `dart/lib/src/runtime/matching.dart`. `RuntimeRegexAlternation` consumes ordered compiled-rule regex lists and
  supports seek/consume matching with stable alternative identity. `RuntimeRegexMatch` records captures, named
  captures, code-unit spans, char offsets, line/column projection, and zero-progress helpers. `RuntimeMatchRegisters`
  keeps entry and local match registers separate for child dispatch and tracks cursor state. Rule dispatch
  landed on top of this state in `DART-BACKEND-PARITY.4.2`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.4` added Dart compiled-spec state in
  `dart/lib/src/compiler/compiled_spec.dart`. `compileSpec(...)` validates source ASTs by default, builds ordered
  `CompiledSpec` / `CompiledRule` state, carries `UserFunctionRegistry`, preserves rule redefinition metadata when
  validation is deliberately skipped, records mode metadata, regexes, dependency refs, edge and lifecycle ActionIR
  payloads, derives structured `CompiledDependencyRegexState`, and projects `CompiledDescriptorState` as
  `spec` / `functions` / `dependency_regex_map` / `meta`. Runtime match-state and interpreter execution now begin
  at `DART-BACKEND-PARITY.4.1`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.3` added Dart user-function registry infrastructure in
  `dart/lib/src/action/function_registry.dart`. `UserFunctionRegistry` preserves ordered `FunctionDefinition`
  records, staged `body_parse_job` records, `body_payload`, optional `body_ast`, params/arity, and source/body
  spans. `action_contracts.dart` can now resolve exact-arity user calls as `user_function` before helper fallback
  when passed a registry, and wrong-arity registered calls produce user-function arity diagnostics. Compiled-spec
  state remains `DART-BACKEND-PARITY.3.4`.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.5` closed the final no-drift audit for retired helper
  spellings in active Perl/Rust code/test/tool/spec surfaces. Exact retired-helper call-shape, label/tag, and
  `?concat:` scans are clean. The last active Rust runtime unit-test fixture that still used retired helper-call
  strings for generic unknown-helper coverage now uses invented unknown names instead. `NONCURRENT-HELPER-CODE-PURGE`
  is complete; the next PNT frontier is `DART-BACKEND-PARITY.3.3`.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.4` migrated active tests, tooling examples, generated Rust
  oracle corpus inputs, and checked-in `.spec` labels/source strings away from retired helper spellings. Generic
  unknown-helper regressions now use invented helper names. `ebnf.spec` and copied corpus inputs use
  `return_scalar_value` / `return_array_value`; `portmap.spec` and oracle/book examples use `?concatenation:` for
  concatenation nodes. Final no-drift closeout is `NONCURRENT-HELPER-CODE-PURGE.5`.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.3` removed Rust source recognition and name-specific
  diagnostic paths for the retired `SPEC-FORMAT-TERSE.8` helper spelling set. `linkedspec-core` no longer lists
  retired helper spellings as known ActionIR calls and no longer preserves `declare(...)` keyword-argument syntax
  for retired-helper diagnostics. `linkedspec-runtime` no longer has a `retired_helper_error(...)` branch ahead of
  generic helper dispatch; retired helper-looking calls now use the generic unknown-helper fallback. Runtime context
  internals use neutral append/snapshot names, and Rust hash-literal display emits current `{ key : value }`
  syntax. `NONCURRENT-HELPER-CODE-PURGE.4` later closed active test/tool/generated fixture and checked-in `.spec`
  migration.
- `2026-07-09` refresh: `NONCURRENT-HELPER-CODE-PURGE.2.4` closed the Perl source purge container for the
  retired `SPEC-FORMAT-TERSE.8` helper spelling set. Focused exact call-shape scans over `perl/LinkedSpec.pm`
  and `perl/LinkedSpec` are clean for retired helper recognition paths; remaining exact-name hits are raw-compat
  comments or ordinary implementation words, not helper-call source branches. Current `cat(...)`, `copy(...)`,
  `set(...)`, and `push(...)` lowering still works, while retired value-position helper-looking calls such as
  `concat(...)`, `a(...)`, and `scalaref(...)` lower through the same generic unsupported-helper sentinel path as
  invented unknown helpers. `NONCURRENT-HELPER-CODE-PURGE.3` owns the next Rust source cleanup.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.2` added Dart ActionIR contract resolution in
  `dart/lib/src/action/action_contracts.dart`. `resolveActionBlockContracts(...)`,
  `resolveActionStatementContracts(...)`, and `resolveActionExpressionContracts(...)` walk typed ActionIR
  calls, receiver methods, structural assignments, structured controls, nested arguments, block values,
  shapes, and access expressions, then record current canonical helper/control contracts or generic
  diagnostics. `dart/lib/src/validation/spec_validator.dart` now shares the current helper/control name
  table through `isKnownActionIrCallName(...)` for function-name collision checks. Function registry
  construction later landed in `.3.3`, and compiled-spec state landed in `.3.4`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.3.1` added the Dart ActionIR AST parser.
  `dart/lib/src/action/action_ast.dart` defines typed action blocks, statements, expressions, arguments,
  access segments, literals, assignments, receiver chains, block values, and structured-control nodes.
  `dart/lib/src/action/action_parser.dart` exposes `parseActionBlock(...)`, `parseActionStatement(...)`,
  and `parseActionExpression(...)`. The parser covers calls, positional/keyword arguments, primitive and
  regex literals, variables, indexed/nested access, array/hash literals, scalar/array/hash/nested assignments,
  expression-valued blocks, attached `if`/`when`/`elseif`/`else`/`otherwise`, `while`, `switch`/`case`/`default`,
  receiver-dot fluent chains, trailing block arguments, standalone value-drop statements, and structural
  `raw_perl` fallback for unsupported expressions.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.4` closed the Dart frontend container by
  adding `dart/lib/src/parser/user_function_definition_shell.dart`. Dart now consumes the
  `function_definition` / `function_definition_error` nodes returned by `specs/user_function_definition.spec`,
  validates source/body spans and staged `body_payload` / `body_parse_job` sidecars, normalizes source-order
  parent paths and deterministic parse-job ids, strips returned definition spans before rule parsing, and
  attaches ordered `FunctionDefinition` records. This is intentionally not a raw `fn` source scanner; later corpus
  execution obtains the spec-returned AST nodes by running `specs/user_function_definition.spec` through Dart
  runtime shell code before projecting staged function bodies.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.3` added Dart frontend validation in
  `dart/lib/src/validation/spec_validator.dart`. `validateSpec(...)` now checks top-rule presence,
  duplicate labels/functions, function registry collisions/parameters, raw malformed body lines, mixed edge
  families, grouped action targets without shared blocks, undefined targets, regex-slot index ranges, and
  lightweight regex structural errors; `strictSyntax: true` adds unused-rule rejection. Validation is still
  source-AST only. Helper/action compilation and runtime semantics remain later lanes.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.2` added the Dart core `.spec` rule parser in
  `dart/lib/src/parser/spec_parser.dart`. `parseSpec(...)` now produces the source AST for rule
  paragraphs, headers/modes, header-rest body elements, regex literals, lifecycle blocks, action and
  blind-call edges, fluent continuations, split/conditional markers, comments, raw fallback lines, and
  nested block boundaries. Tests cover focused Rust parser parity seams, all checked-in `specs/*.spec`,
  and rule-only corpus `input.spec` files. Strict validation remains `.2.3`; top-level function-shell
  extraction/staging remains `.2.4`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.2.1` added Dart source-level AST/data types in
  `dart/lib/src/ast/spec_ast.dart`. The types mirror the Rust parsed-AST and staged parse-job field names:
  `SpecFile`, `FunctionDefinition`, `SourceSpan`, `StagedParseJob`, `Rule`, `RuleHeader`, `RuleMode`,
  body element variants, `EdgeTarget`, and `FluentCall` all round-trip through JSON. This is still data-only;
  parser code starts in `.2.2`.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.1.3` added Dart corpus manifest IO scaffolding.
  `dart/lib/src/corpus/manifest_runner.dart` now loads `manifest.json`, validates format/case-count/case
  name shape, detects missing and stale fixture directories, requires `input.spec` / `input.txt` /
  `expected.json`, parses expected JSON, and reports the 99 checked-in fixtures without executing parser
  semantics. The `.1` toolchain/workspace/foundation container is closed; next frontier is `.2.1` AST/data types.
- `2026-07-09` refresh: `DART-BACKEND-PARITY.1.2` created the repo-owned Dart package scaffold
  under `dart/`. The package has `pubspec.yaml`, committed `pubspec.lock`, analyzer options, README,
  public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint, and a `package:test`
  smoke test. `.dart_tool/` and build outputs are ignored. This is scaffold only: manifest IO starts
  in `.1.3`, and parser/compiler/runtime semantics remain later leaves.
- `2026-07-09` refresh: `FUTURE-PARITY-BACKLOG.1.1` scoped the Dart lane into
  `docs/tasks/DART-BACKEND-PARITY.md`. Dart parity starts interpreter-first: `.spec` parser, typed
  helper/action AST, compiled-spec state, Dart runtime interpreter, then manifest-backed corpus parity.
  Generated Dart source was later deferred by `DART-BACKEND-PARITY.7.2`, not made the primary gate. No
  backend implementation code changed in this scoping slice.
- `2026-07-09` refresh: `FUTURE-PARITY-BACKLOG.0` created the active future parity backlog and ADR
  `0021` accepted Lua as a scheduled future backend target. Future full-parity backend rollout is now Dart
  first, Julia second, and Lua third, all under the same `.spec`, text-to-AST, staged parsing, runtime,
  diagnostics, and corpus parity contracts as Perl5 and Rust. No parser/runtime/backend code changed in this
  tracking slice.
- `2026-07-08` refresh: `ROADMAP-DRIFT-RECONCILE.2` refreshed the dated status/count layer after
  the terse-format and Rust-oracle follow-ons; `SPEC-FORMAT-TERSE.12.2` later raised the phase0 lock count with
  the Perl hash-tree traversal regression, `.12.3` raised the Rust oracle with hash-tree traversal parity, `.12.4`
  closed docs/KM/live no-drift alignment for that hash-tree traversal lane, `SPEC-FORMAT-TERSE.13.3` added
  Rust/oracle parity for array-tree traversal receiver blocks, `.13.4` closed the array-tree docs/KM/live
  no-drift alignment, `.13.5` reconciled the parent terse-format task tree closed, and
  `SPEC-SOURCE-TERSE-CLOSEOUT.1` completed the root-spec source-format closeout. The Rust variant now has a
  green 99-fixture
  manifest-backed interpreter oracle with missing/stale fixture drift guards. The generated Rust-source path
  emits a module with embedded `CompiledSpec`, validated generated-family plan, and `parse(input)` entry point;
  it directly executes every currently supported structural family (`Default`, OR/AND acode, AND/OR bcode, and
  the four explicit REP subfamilies) and is proven by an all-family compile/run matrix plus a curated
  manifest-backed corpus subset. The full 99-fixture corpus remains the interpreter oracle gate;
  generated-source corpus coverage is intentionally a subset until a future leaf broadens it. Current phase0 is
  `PASS 1..1028` over 21 shipped `.spec` files with `PERL5LIB=` cleared after the non-consuming boundary helper
  regression landed.
- `2026-07-04` refresh: RUST-PARITY follow-on closed. The Rust variant then had a green 88-fixture
  manifest-backed interpreter oracle with missing/stale fixture drift guards, and the generated Rust-source path
  emitted the first validated generated-family module/corpus proof.
- `2026-06-14` refresh: COMPAT-ALIAS-RETIREMENT-V2.2 removed 5 legacy return helpers (return_a, return_m, return_ma, return_imatch, return_im) from all 7 implementation files. LIFECYCLE-FAMILY-AUDIT tree completed — all 7 lifecycle markers verified. ROADMAP-V2-TRACKER-SYNC tree completed — trackers synchronized. DOC-BOOK-SYNC tree active for documentation/book sync.
- `2026-06-13` refresh: MEDIUM-IMPACT task tree substantially advanced. HandlerVariantEmitter now has structured HandlerIR (10 variant builders → IR hashrefs → dispatched emitter templates), a backend dispatch table (`%BACKEND_EMITTERS` with `perl` default), and a JSON/AST diagnostic backend (`_emit_handler_json` via `JSON::PP`). Validation.pm fuzzing harness (`t/phase0_validation_fuzz.t`) covers 5 surfaces with 168+ combinatorial cases across rule labels, edge scanning, and DSL syntax. BootstrapSpec.pm now has dual-path parse: `_build_spec_spec_parser()` lazily builds spec.spec parser via bootstrap seed and caches it; `run_bootstrap_parse()` runs spec.spec alongside bootstrap as a diagnostic side channel (bootstrap always primary; recursion guard active). Cross-check at 2/20 exact match (tablegrep, verilog); remaining 18 specs tracked in .3.4 parity gap. AND handler MIXED_ACTIONS conflict resolved (.3.4.4): RuleIR routes AND I-blocks to `and_icode_entries`, EmitContext processes them, HandlerVariantEmitter prepends assignment for result capture. Comment/blank-line skip in Runtime.pm wrapper. RuntimeContext reusable via populated scalar-slot contract.
- `2026-06-04` refresh: removed two stale references that still presented the deleted `perl/LinkedSpec/ActionRewriter.pm` module as a live owner-dispatch participant. That module was deleted in Phase 1 (`PHASE1-PARSER-CORE-ISOLATION.2`, commit `4f8e0b6`); the focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)`, reachable through the façade helper `LinkedSpec::call_spec_handler_subst(...)`.
- Scope of this snapshot:
  - `perl/LinkedSpec.pm`
  - the main owner modules it dispatches into
  - the ActionIR lowering subtree
  - the current legacy plugin/runtime branch
  - current Rust variant architecture (`rust/` workspace, interpreter oracle, generated-source emitter)
  - new: `LinkedSpec::HandlerVariantEmitter` (HandlerIR + backend dispatch + JSON/AST backend)
  - new: `t/phase0_validation_fuzz.t` (Validation.pm systematic fuzzing harness, 5 surfaces)
  - new: `tools/cross_check_spec_parsers.pl` (oracle vs candidate cross-check harness)

## Maintenance Policy
- Treat this as a live document, not a one-off memo.
- Refresh it at the start of a new session when the current architectural reading has changed materially or when a new deep codebase pass produces a better model.
- Update it when package ownership, major runtime boundaries, compile/lowering seams, or strategic judgments shift.
- Keep it aligned with:
  - `README.md` for discoverability,
  - `ROADMAP.md` for execution direction,
  - `DEVELOPMENT_NOTES.md` for rationale,
  - `MEMORY.md` for interruption-safe continuity.

## Executive Summary
- `perl/LinkedSpec.pm` is now a deliberately thin lazy facade rather than the real implementation center.
- Its static import tree is intentionally shallow; the real architecture is the lazy owner tree it dispatches into.
- In practice that static tree is now almost just `File::Basename` plus `LinkedSpec::OwnerDispatch`; even the public trace globals are simple aliases into `LinkedSpec::Trace`.
- `LinkedSpec::OwnerDispatch` is now the small shared seam for thin-wrapper lazy loading, callback/value lookup, and delegated owner calls.
- `LinkedSpec::OwnerDispatch` now also anchors lazy owner loading to an absolute repo `perl` path at module load time, so later `chdir(...)` does not strand the file-oriented parser/runtime owner tree on stale relative `@INC` entries.
- `Runtime`, `BootstrapSpec`, and `ParserFactory` no longer keep one-shot local `OwnerDispatch` callback-loader or `$@`-preservation wrappers either; the live compile/bootstrap/parser-factory orchestration bodies now spend the shared seam directly where those pass-through helpers were the only consumer.
- `Runtime` no longer keeps a one-shot runtime-owner generated-handler label wrapper either; fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot generated-handler label wrapper either; parser-factory fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot top-rule generated-handler label wrapper either; top-rule-only fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot rule-or-top generated-handler label wrapper either; rule-attributed diagnostics ask `RuntimeContext` for concrete-rule-or-selected-top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot parser-source flush wrapper either; final parser-source output asks `RuntimeContext` to flush captured parser-source text directly through the owner-dispatch seam.
- `Compiler` no longer keeps one-shot runtime-context last-error read wrappers either; parser invocation asks `RuntimeContext` for last-error type/detail reads directly through the owner-dispatch seam when preserving deeper runtime-handler context.
- `Compiler` no longer keeps a one-shot runtime-context top-rule setter wrapper either; selected-top-rule writes ask `RuntimeContext` to update shared top-rule state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot runtime-context top-rule reader wrapper either; parser-source emission, final descriptor tracing, parser-ready trace metadata, and parser closure capture ask `RuntimeContext` for selected top-rule state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot runtime-context last-error clear wrapper either; operation-boundary and parser-invocation stale-error cleanup asks `RuntimeContext` to clear `last_error` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a parser-source emission pass-through wrapper either; parser-source line emission asks `RuntimeContext` to append captured source text directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot low-level rule-table runtime-context preparation wrapper either; `build_compiled_rule_table(...)` now inlines its small `top_rule` selection before asking `RuntimeContext` to prepare shared rule-table state.
- `Compiler` no longer keeps a one-shot validation callback availability wrapper either; `run_get_pipeline(...)` checks `Validation::validate_spec_content(...)` availability directly through the owner-dispatch seam.
- `Compiler` no longer keeps a Trace loader wrapper either; its trace helper bodies load `LinkedSpec::Trace` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a pass-through compiler-pipeline last-error setter wrapper either; compiler error boundaries ask `RuntimeContext` to write structured error state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot active dependency-regex rule-label reader wrapper either; final-descriptor failure attribution reads that active label directly at the diagnostic boundary.
- `Compiler` no longer keeps a one-shot active dependency-regex rule-label clearer wrapper either; dependency-regex boundaries reset that transient diagnostic label directly.
- `Compiler` no longer keeps a scalar-position reset wrapper either; `run_get_pipeline(...)` resets the spec-content scalar position directly at validation and bootstrap-parse boundaries.
- `Compiler` no longer keeps a first parsed-rule label wrapper either; rule-table preparation and final top-rule selection derive the first label directly at each decision point.
- `Compiler` no longer keeps a one-shot final-descriptor error-detail normalizer wrapper either; that trapped error detail is normalized directly at the structured last-error write.
- `Compiler` no longer keeps a one-shot parser-input ref describer wrapper either; top-level parser invocation builds invalid-input diagnostics directly at the runtime-parser last-error write.
- `Compiler` no longer keeps a one-shot bootstrap-parse result detail wrapper either; invalid intermediate-representation diagnostics are built directly at the structured last-error write.
- `Compiler` no longer keeps a one-shot rule-table failure-detail reader wrapper either; the pipeline fallback reads retained rule-table failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table failure-detail clearer wrapper either; rule-table and pipeline boundaries reset retained failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table failure-detail setter wrapper either; rule-table failure sites write retained failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table entries-result describer wrapper either; invalid parsed-entry-list diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot rule-table entry-result describer wrapper either; invalid per-entry diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot compile-spec-entry tuple describer wrapper either; invalid tuple diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot final-descriptor state-result describer wrapper either; invalid descriptor-state diagnostics are built directly at the final descriptor boundary.
- `Compiler` no longer keeps a one-shot final-descriptor dependency-regex describer wrapper either; invalid normalization diagnostics are built directly inside the CompilerState callback.
- `Compiler` no longer keeps a one-shot dependency-regex map spec-result describer wrapper either; invalid compiled-spec input diagnostics are built directly inside the CompilerState callback.
- `Compiler` no longer keeps a one-shot dependency-regex map rule-info describer wrapper either; invalid rule-info diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map `dependency_refs` describer wrapper either; invalid dependency-list diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-ref describer wrapper either; invalid dependency-ref diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-label describer wrapper either; invalid dependency-label diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-index describer wrapper either; invalid dependency-index diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map missing-rule describer wrapper either; missing dependency-rule diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-rule-info describer wrapper either; invalid referenced dependency-rule info diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency regex-list describer wrapper either; invalid referenced regex-list diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a compiled-spec state constructor pass-through wrapper either; rule-table build asks `CompilerState` for new state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec state predicate pass-through wrapper either; compiler-pipeline validation asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec rule-count pass-through wrapper either; trace and parser-generation counts ask `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps the unused compiled-spec rules-by-label pass-through wrapper either; rules-by-label map access stays owned by `CompilerState` without a compiler-local mirror.
- `Compiler` no longer keeps a compiled-spec has-rule pass-through wrapper either; dependency-regex validation asks `CompilerState` directly whether referenced dependency rules exist.
- `Compiler` no longer keeps a compiled-spec rule-info pass-through wrapper either; dependency-regex validation retrieves referenced dependency-rule metadata directly from `CompilerState`.
- `Compiler` no longer keeps the unused compiled-rule-order pass-through wrapper either; compiled-rule ordering remains a `CompilerState` concern without a compiler-local mirror.
- `Compiler` no longer keeps a compiled-spec rule-rows pass-through wrapper either; dependency-regex map iteration asks `CompilerState` directly for compiled rule rows.
- `Compiler` no longer keeps a compiled-spec definition-order pass-through wrapper either; compiled-state trace output asks `CompilerState` directly for definition order.
- `Compiler` no longer keeps a compiled-spec redefined-labels pass-through wrapper either; compiled-state trace reporting asks `CompilerState` directly for redefined rule labels.
- `Compiler` no longer keeps a compiled-spec legacy projection pass-through wrapper either; legacy spec-hash projection asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec record-rule pass-through wrapper either; rule-table construction records compiled rules by asking `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor legacy projection pass-through wrapper either; final descriptor projection asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps the unused `_build_final_descriptor(...)` legacy projection helper either; the active path builds descriptor state with `_build_final_descriptor_state(...)` and projects through `CompilerState` at the boundary that needs the compatibility descriptor.
- `Compiler` no longer keeps a compiled-descriptor metadata pass-through wrapper either; final-descriptor assembly asks `CompilerState` to build descriptor metadata directly through the shared owner seam.
- `Compiler` now uses full `final_descriptor` local naming and `FINAL_DESCRIPTOR` trace banners on the active path instead of compressed `final_descr` wording.
- `Compiler` no longer keeps a compiled dependency-regex state constructor pass-through wrapper either; dependency-regex enrichment asks `CompilerState` to construct the state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor state constructor pass-through wrapper either; final descriptor assembly asks `CompilerState` to construct the state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor state predicate pass-through wrapper either; final descriptor assembly asks `CompilerState` to validate the state shape directly through the shared owner seam.
- `Compiler` no longer keeps the unused compiled descriptor metadata pass-through wrapper either; descriptor metadata reads stay owned by `CompilerState` without a compiler-local mirror.
- `SpecEntry` no longer keeps a one-shot runtime-context top-rule setter wrapper either; discovered top-rule writes ask `RuntimeContext` to update shared top-rule state directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a parser-source emission pass-through wrapper either; generated-handler source emission asks `RuntimeContext` to append captured source text directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a pass-through runtime-handler last-error setter wrapper either; rule-handler compile/eval errors ask `RuntimeContext` to write runtime-handler error state directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a one-shot runtime-context dependency-reader wrapper either; `compile_spec_entry(...)` reads the optional `runtime_ctx` dependency inline beside RuleIR setup.
- `SpecEntry` no longer keeps a one-shot RuleIR callback availability wrapper either; `compile_spec_entry(...)` checks `RuleIR::_collect_rule_ir(...)` availability directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a one-shot emit-context callback availability wrapper either; `compile_spec_entry(...)` checks `RuleIR::EmitContext::build_rule_ir_emit_context(...)` availability directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a Trace loader wrapper either; its trace wrapper bodies load `LinkedSpec::Trace` directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot runtime-context preparation wrapper either; `run_get_parser(...)` asks `RuntimeContext` to prepare file-oriented parser state directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot runtime-context spec-path setter wrapper either; resolved-spec-path writes ask `RuntimeContext` to update shared file identity directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a pass-through preserve-existing last-error setter wrapper either; compile-stage fallback writes ask `RuntimeContext` to preserve deeper compile errors directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a pass-through direct last-error setter wrapper either; setup, validation, resolution, and load errors ask `RuntimeContext` to write parser-factory error state directly through the owner-dispatch seam.
- `Runtime` no longer keeps a one-shot runtime-context preparation wrapper either; `run_get(...)` asks `RuntimeContext` to prepare inline runtime state directly through the owner-dispatch seam.
- `Runtime` no longer keeps an unused direct last-error setter wrapper either; runtime-owner fallback writes stay on the preserve-existing `last_error` path.
- `Runtime` no longer keeps a pass-through preserve-existing last-error setter wrapper either; fallback writes ask `RuntimeContext` to preserve deeper error state directly through the owner-dispatch seam.
- `Runtime` no longer keeps a one-shot compiler callback-loader wrapper either; `run_get(...)` resolves `Compiler::run_get_pipeline(...)` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_require_runtime_ctx(...)` and `run_get_pipeline(...)`, and those now validate the required runtime/pipeline dependencies inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ValueExpr` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the value-expression lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::FlowExpr` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the flow-expression lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ControlFlow` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the control-flow lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::MethodLowering` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the method/value/assignment/return lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::DeclareMethod` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the declare/assign lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ParserFactory` no longer keeps second top-level dependency-validator wrappers either; its meaningful local setup seam is still `run_get_parser(...)`, and that setup path now validates the required trace/resolve/compile callbacks plus trace-level values inline instead of bouncing through separate `_require_dep(...)` or `_require_value_dep(...)` subdefs.
- `PPlugin` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local compatibility seam is still `_load_legacy_registry(...)`, and that loader now validates the required parser/discovery/registry callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `Resolver` no longer keeps local Trace-loader or `$@`-preservation wrappers either; its live trace helper bodies now spend `OwnerDispatch` directly in the same way `Validation` already did.
- `ActionIR::Scanner` no longer keeps local callback-loader or `$@`-preservation wrappers either; its live owner helper bodies now spend `OwnerDispatch` directly while still keeping `_require_scanner_core_pkg(...)` as the meaningful local scanner-core seam.
- `Compiler`, `SpecEntry`, and `RuleIR` no longer keep generic package-loader wrappers either; their Trace / `Data::Dumper` / `LinkedRE` helper seams now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a local `_require_pkg(...)` pass-through.
- `Compiler` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `SpecEntry` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `SpecEntry` no longer keeps a one-shot generated-handler label wrapper either; runtime-handler construction now asks `RuntimeContext` for rule-metadata generated-handler source labels through the existing owner-dispatch seam.
- `RuleIR` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `Compiler` no longer keeps a separate `LinkedRE` loader wrapper either; its meaningful local regex seam is still `_ored_re(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `Compiler` and `SpecEntry` no longer keep generic callback-loader wrappers either; their named bootstrap/spec-entry/validation and RuleIR/emit-context helper seams now spend `OwnerDispatch::require_pkg_cb(...)` directly instead of bouncing through a local `_require_pkg_cb(...)` pass-through.
- `BootstrapSpec` no longer keeps a separate bootstrap-core loader wrapper either; its meaningful local bootstrap grammar seam is still `build_bootstrap_spec(...)`, and that helper now spends `OwnerDispatch::require_pkg_cb(...)` directly inside its `$@`-preserving body.
- `RuleIR::EmitContext` no longer keeps a generic package-loader wrapper either; its meaningful local seam is `_actionir_owner_package(...)`, and that owner-key registry now spends `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a second local `_require_pkg(...)` layer.
- `ActionIR::StatementSplit::Core` no longer keeps a generic package-loader wrapper either; its meaningful local seams are the statement-split-mode and `MethodExpr` loader helpers, and both now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a second local `_require_pkg(...)` layer.
- `BootstrapSpec::Core` no longer keeps a separate `LinkedRE` loader wrapper either; its meaningful local bootstrap regex seams are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::require_pkg(...)` directly inside their `$@`-preserving bodies.
- `BootstrapSpec::Core` no longer keeps a single-use `$@`-preservation wrapper either; its meaningful local seams are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `PluginBridge` no longer keeps a local `$@`-preservation wrapper either; its meaningful compatibility seams are still `_exec_legacy_plugin(...)`, `_get_legacy_plugin(...)`, `_lookup_plugin_name(...)`, and `_dispatch_plugin_name(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `PluginBridge` no longer keeps a second top-level dependency-validator wrapper either; its meaningful compatibility seams are still `_lookup_plugin_name(...)` and `_dispatch_plugin_name(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `Compiler` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `SpecEntry` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_dump_value(...)`, and `_trace_runtime_mark_event(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `RuleIR` no longer keeps a local `$@`-preservation wrapper either; its meaningful local trace/dump seams are still `_trace_should_dump(...)`, `_trace_log_output(...)`, `_trace_decision(...)`, `_trace_rule_ir_decision(...)`, and `_dump_value(...)`, and owner delegation now spends `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `RuleIR::EmitContext` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_actionir_owner_default_deps(...)`, `_call_actionir_owner(...)`, `_call_actionir_owner_with_deps(...)`, `_accumulate_action_rewrite_diagnostics(...)`, and `rewrite_action_code_for_compat(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `ActionIR::Contracts` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_require_lowering_deps(...)`, and that helper now validates required lowering callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ScannerCore` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_scanner_rule_dep_bindings(...)`, and that helper now validates required scanner callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::StatementSplit` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_split_action_ir_statements(...)`, and that helper now validates the required `trim_action_ir_value` callback inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::StatementSplit` no longer keeps a single-use `StatementSplit::Core` loader wrapper either; `_split_action_ir_statements(...)` now lazy-loads the core owner directly through `OwnerDispatch::require_pkg(...)` inside its live `$@`-preserving delegation body.
- `ActionIR::CanonicalEvents` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_build_canonical_action_ir_events(...)`, and that helper now validates the required trim/split callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::CanonicalEvents` no longer keeps a single-use `CanonicalEvents::Core` loader wrapper either; `_canonicalize_helper_action_ir_event(...)` now lazy-loads the core owner directly through `OwnerDispatch::require_pkg(...)` inside its live `$@`-preserving delegation body.
- `ActionIR::Diagnostics` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_find_unresolved_action_helpers(...)` and `_collect_action_helper_ir_nodes(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::RewritePipeline` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_build_action_rewrite_rules(...)` and `_rewrite_action_code_with_diagnostics(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ArrayPipeline` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_normalize_split_delimiter_expr(...)` and `_build_array_pipeline_plan_from_expr(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `BootstrapSpec::Core`, `ActionIR::ScannerCore`, and `LinkedSpec::PluginBridge` no longer keep single-use generic package-loader wrappers either; their remaining LinkedRE, scanner-rule-family, and legacy-`PPlugin` helper seams now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through local `_require_pkg(...)` pass-throughs.
- `LinkedSpec.pm` and `LinkedSpec::ParserFactory` no longer keep dead local pass-throughs around that seam; once the active facade/parser-factory paths spent `OwnerDispatch` directly, the shadow `_require_pkg(...)`, `_call_preserving_err(...)`, `_require_pkg_cb(...)`, and `_require_pkg_value(...)` wrappers became removable compatibility debris rather than real architecture.
- The dep-map-only ActionIR owners no longer keep dead local `_require_pkg(...)` or `_call_preserving_err(...)` wrappers around that seam either; once `default_deps_for_package(...)` moved to `OwnerDispatch::build_dep_map(...)`, those local pass-through bodies stopped being part of the real lowering path.
- `Runtime`, `BootstrapSpec`, and `ActionIR::Scanner` no longer keep dead local package-loader wrappers either, and `RuleIR::EmitContext` no longer keeps a dead local Trace-loader wrapper; the active runtime/bootstrap/scanner/emit-context paths now make their remaining callback-loader and owner-registry seams explicit instead of keeping zero-call helper shadows around them.
- `Trace`, `Validation`, `ActionIR::CanonicalEvents`, and `ActionIR::StatementSplit` now also spend `OwnerDispatch` directly inside their live helper bodies instead of keeping one-shot local wrappers for a single Data::Dumper/Trace/core-owner load or `$@`-preservation call.
- Delegated owner calls now resolve their target callbacks through the same `OwnerDispatch::require_pkg_cb(...)` loader path used by dependency maps and thin wrappers, so `dispatch_owner_call(...)` no longer carries a second symbol-call route internally.
- Thin wrapper callback lookup now routes through that seam for `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `ActionIR::Scanner`, and `RuleIR::EmitContext`'s ActionIR owner dispatch; direct callback probing is reserved for `OwnerDispatch` itself.
- `LinkedSpec::OwnerDispatch` now also owns shared dependency-map assembly for active ActionIR owners and a mixed callback/value bundle builder for the parser-factory path, so owner-side dependency wiring is centralizing instead of drifting back into local registries.
- `LinkedSpec::PluginBridge` now also spends that same owner-dispatch seam for its default compatibility plumbing: lazy `PPlugin` loading, registered-plugin lookup through `PluginRegistry`, successful `$@` preservation, and default callback-map assembly no longer require bridge-local eval/restore branches or a hand-built dependency hash.
- The former Perl-only legacy domain-utility owners and the `.plg` plugin corpus are no longer part of the active `perl/` tree; two retirement passes resolved them, and `t/phase0_regression.t` is green (`PASS 1..1028`) without any of them.
  - **Deleted** (`LEGACY-VHDL-RETIRE`, the Perl-only non-portable VHDL/RTL/FSM-generation subsystem with no Rust/Dart/Julia/Lua counterpart): `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them (`fsmgen`/`lte_digital_rf`/`mbist`/`msword`/`regtest`/`rtl`). The stale `generic_fake_memory_module.plg` / `wrapgen.plg` / `get_log2`->`ceil_log2` prose carried here described files already deleted earlier; it is gone with the subsystem.
  - **Relocated to `noncore/`** (`NONCORE-QUARANTINE`, proven unreachable from the `LinkedSpec.pm` union shipped-`specs/*.spec` closure): the remaining non-core domain owners — `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend` (plus the flat domain `.pm`) — and the 13 surviving `.plg`, all `git mv`'d into `noncore/` with layout preserved (`noncore/README.md` is the parked-fate ledger). The root `plugin/` directory no longer exists; `perl/` is now core-only.
- A fresh 2026-04-11 bootstrap pass confirmed that the recent compiler naming cleanup is now on the active facade/compiler path: `LinkedSpec.pm` exposes `build_compiled_rule_table(...)`, `Compiler.pm` / `CompilerState.pm` speak in terms of compiled-spec / compiled dependency-regex / compiled-descriptor state, and the former bootstrap-local `spec_descr` / `gdata` vocabulary has now been renamed to rule-descriptor / dispatch-state terminology.
- The legacy `ActionRewriter` compatibility module has now been deleted entirely (Phase 1 / `PHASE1-PARSER-CORE-ISOLATION.2`): it had become a pure forwarding shim over `RuleIR::EmitContext`, so the focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)` and there is no separate `ActionRewriter` surface to keep thin.
- The practical core path is:
  - `ParserFactory -> Runtime -> Compiler`
- The frontend syntax/bootstrapping truth still concentrates in:
  - `BootstrapSpec::Core`
  - `Validation`
- Rule compilation and emitted runtime behavior still concentrate in:
  - `SpecEntry`
  - `RuleIR`
  - `RuleIR::EmitContext`
- Backend-neutral action semantics now largely live in:
  - `LinkedSpec::ActionIR::*`
- `RuntimeContext` is one of the cleanest and most important boundaries in the tree.
- `Compiler.pm` now also has one explicit internal compiled-spec state model, so descriptor assembly no longer treats loose parallel compiled-rule-table / `build_dependency_regex_map` hashes as its own source of truth.
- Dynamic plugin loading is still present in the public facade, but current project direction treats it as legacy-removal territory rather than a feature family to preserve.
- The Rust variant's production path is still an interpreter over `CompiledSpec`/`CompiledRule`, but it is now
  parity-tested through a checked-in 99-fixture oracle corpus generated from the Perl reference and guarded against
  manifest drift.
- The Rust generated-source path is no longer just a scaffold: `linkedspec_runtime::source_emitter` emits
  compilable Rust modules with a generated family plan, and the plan-aware executor directly handles every current
  non-REP and REP structural family. Its corpus proof is deliberately curated rather than exhaustive.

## LinkedSpec Facade Reading
`perl/LinkedSpec.pm` does almost no real work itself. Its main roles are:

- expose the public API,
- lazily load owner modules,
- preserve `$@` across owner dispatch through `LinkedSpec::OwnerDispatch`,
- no longer carry dead local `_require_pkg(...)` / `_call_preserving_err(...)` pass-through helpers now that the shared owner-dispatch seam is the real implementation,
- normalize flat option pairs,
- re-export trace-oriented globals from `LinkedSpec::Trace`.

Its direct static imports are intentionally narrow:
- `File::Basename` at `BEGIN` time for local path setup,
- `LinkedSpec::OwnerDispatch` for shared lazy owner dispatch.

That means the important import tree is the runtime owner tree, not the `use` list in `LinkedSpec.pm` itself.

The facade surface currently falls into four bands.

### Trace Surface
- `configure_trace`
- `trace_enter`
- `trace_exit`
- `trace_decision`
- `log_output`
- `log_dump`
- `should_dump`

### Compile/Runtime Surface
- `Get`
- `build_compiled_rule_table`
- `call_spec_handler_subst`
- `get_parser`

### Registry Maintenance Surface
- `register_plugin`
- `register_plugins`
- `clear_registered_plugins`

### Legacy Transition Surface
- `run_plugin`
- `get_plugin`
- `dispatch_plugin_autoload_name`
- `AUTOLOAD`

The important conclusion is that `LinkedSpec.pm` should be read as a facade and routing layer, not as the place where most semantics live anymore.

One supporting detail matters now: the repeated thin-wrapper plumbing for lazy package loading, callback/value lookup, delegated owner calls, and `$@` preservation is no longer reimplemented separately in each owner. `LinkedSpec.pm`, `LinkedSpec::Trace`, `Runtime.pm`, `ParserFactory.pm`, `BootstrapSpec.pm`, `BootstrapSpec::Core`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR.pm`, `RuleIR::EmitContext.pm`, `Resolver.pm`, and `Validation.pm` now share that seam through `LinkedSpec::OwnerDispatch` (the former `ActionRewriter.pm` listed here was deleted in Phase 1), and the same seam is now also being spent inside active ActionIR owners such as `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::StatementSplit::Core`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ControlFlow`, `LinkedSpec::ActionIR::Contracts`, `LinkedSpec::ActionIR::MethodLowering`, and `LinkedSpec::ActionIR::DeclareMethod`.
One more concrete consequence of that shift is now visible on the parser-factory path too: `ParserFactory.pm` no longer hand-builds its mixed trace/resolve/compile callback plus trace-verbosity value bundle locally, because `LinkedSpec::OwnerDispatch` now owns a shared mixed dependency-bundle builder for that active compile-path surface.

## Current Owner Tree
The current practical owner tree is:

```text
LinkedSpec
├─ LinkedSpec::OwnerDispatch
├─ LinkedSpec::Trace
├─ LinkedSpec::Runtime
│  ├─ LinkedSpec::RuntimeContext
│  └─ LinkedSpec::Compiler
│     ├─ LinkedSpec::Trace
│     ├─ LinkedRE
│     ├─ LinkedSpec::BootstrapSpec
│     │  └─ LinkedSpec::BootstrapSpec::Core
│     │     └─ LinkedRE
│     ├─ LinkedSpec::SpecEntry
│     │  ├─ LinkedSpec::RuleIR
│     │  ├─ LinkedSpec::RuleIR::EmitContext
│     │  │  ├─ LinkedSpec::ActionIR::RewritePipeline
│     │  │  ├─ LinkedSpec::ActionIR::MethodExpr
│     │  │  ├─ LinkedSpec::ActionIR::Scanner
│     │  │  │  └─ LinkedSpec::ActionIR::ScannerCore
│     │  │  │     ├─ Scanner::PrimitiveBasicRules
│     │  │  │     ├─ Scanner::PrimitivePipelineRules
│     │  │  │     ├─ Scanner::FlowRules
│     │  │  │     └─ Scanner::LegacyRules
│     │  │  ├─ LinkedSpec::ActionIR::CanonicalEvents
│     │  │  │  └─ CanonicalEvents::Core
│     │  │  ├─ LinkedSpec::ActionIR::Diagnostics
│     │  │  ├─ LinkedSpec::ActionIR::StatementSplit
│     │  │  │  └─ StatementSplit::Core
│     │  │  │     └─ StatementSplit::Mode
│     │  │  ├─ LinkedSpec::ActionIR::Contracts
│     │  │  ├─ LinkedSpec::ActionIR::FlowExpr
│     │  │  ├─ LinkedSpec::ActionIR::ArrayPipeline
│     │  │  ├─ LinkedSpec::ActionIR::ControlFlow
│     │  │  ├─ LinkedSpec::ActionIR::MethodLowering
│     │  │  ├─ LinkedSpec::ActionIR::DeclareMethod
│     │  │  ├─ LinkedSpec::ActionIR::ValueExpr
│     │  │  └─ LinkedSpec::Trace
│     │  ├─ LinkedSpec::Trace
│     │  └─ LinkedSpec::RuntimeContext
│     ├─ LinkedSpec::Validation
│     ├─ LinkedSpec::CompilerState
│     └─ LinkedSpec::RuntimeContext
├─ LinkedSpec::ParserFactory
│  ├─ LinkedSpec::RuntimeContext
│  ├─ LinkedSpec::Trace
│  ├─ LinkedSpec::Resolver
│  └─ LinkedSpec::Runtime
├─ LinkedSpec::PluginRegistry
└─ LinkedSpec::PluginBridge
   ├─ LinkedSpec::PluginRegistry
   └─ PPlugin
      └─ LinkedSpec
Project/domain utility owners - removed from core (`perl/` is now core-only)
  - Deleted   (LEGACY-VHDL-RETIRE):  RTLUtils, FSMGen, VHDL::ConstantEval
  - Relocated (NONCORE-QUARANTINE):  HTTP::FileAccess, HTML::PathLinks, InteractivePrompt,
                                     Text::VariableSubstitution, MSOffice::Excel, QC::Flow,
                                     QC::Summary, QC::TclInterconn, Table::GenericFilter,
                                     Timing::SetupHold, Timing::StanBackend,
                                     Timing::StanOmap2430cBackend (+ the flat domain .pm)
                                     -> noncore/  (parked-fate ledger: noncore/README.md)
```

## What the Main Owners Do
### `LinkedSpec::Trace`
- owns trace state, indentation, formatting, verbosity, and output routing,
- lazily uses `Data::Dumper` only when needed,
- now also owns richer trace rendering such as mark-position pointer excerpts.

### `LinkedSpec::Runtime`
- owns the small orchestration layer around the compile pipeline,
- builds or normalizes runtime context,
- delegates into `Compiler`,
- writes fallback runtime-owner errors only when deeper owners did not already write a structured failure.

### `LinkedSpec::RuntimeContext`
- owns shared runtime state and structured error payload helpers,
- owns parser-source chunk capture and capture-reset helpers,
- normalizes `runtime_ctx_ref` for direct hashrefs plus scalar slots, including reuse after a scalar slot already contains the shared context hashref,
- carries `spec_name`, `spec_path`, `top_rule`, and `last_error`,
- now clears stale `last_error` during `run_get(...)`, `get_parser(...)`, and low-level rule-table preparation so reused contexts begin each boundary with a failure-only diagnostics channel,
- now also keeps `last_error` more self-contained by copying the known `top_rule` into the structured payload alongside `spec_name` and `spec_path`,
- now also owns top-rule generated-handler source-label construction for runtime/parser-factory/compiler diagnostics, including parser-invocation labels that know the selected handler variant,
- now also owns compiler-style rule-or-top generated-handler source-label fallback, where a concrete rule label wins and selected `top_rule` is the fallback,
- now also owns rule-metadata generated-handler source-label construction for `SpecEntry`, including selected handler variants stored in compiled rule metadata,
- now also seeds an explicitly requested `top_rule` during both inline and file-oriented preparation, so earlier parser-factory/compiler failures can still report the caller’s intended entrypoint before final parser selection happens,
- now also owns the paired stale `spec_name` / `spec_path` reset as a distinct helper from `top_rule` selection, so file identity cleanup and selected-entrypoint continuity stay separate,
- now also owns the low-level `build_compiled_rule_table(...)` runtime-context preparation path, so compiler-side rule-table diagnostics no longer hand-normalize `runtime_ctx_ref` or hand-clear stale context identity/parser-source capture state in `Compiler.pm`,
- is now reached through one shared `OwnerDispatch::dispatch_owner_call(...)` delegation shape across the active runtime/compile owners instead of one dispatch style in `ParserFactory.pm` and another in `Runtime.pm` / `Compiler.pm` / `SpecEntry.pm`,
- is one of the cleanest and highest-value seams in the project.

### `LinkedSpec::ParserFactory`
- owns `get_parser(...)`,
- validates the requested spec name,
- resolves the target `.spec`,
- loads file content,
- prepares trace/runtime context,
- now assembles its default trace/resolve/compile callback dependencies plus trace dump-level values through one shared `OwnerDispatch` bundle helper instead of another owner-local registry,
- no longer keeps dead local `_require_pkg(...)`, `_require_pkg_cb(...)`, or `_require_pkg_value(...)` pass-through wrappers around that now-shared dependency/owner-dispatch path,
- delegates actual compilation to the runtime/compiler path.

### `LinkedSpec::Resolver`
- is the real owner of named spec lookup,
- resolves direct paths first,
- tries module-relative spec paths next,
- falls back to `PathSearch` last.

This module, not the plugin branch, is the real home of the "ask for `foo`, get `foo.spec`" behavior.

### `LinkedSpec::Compiler`
- is the main compile pipeline coordinator,
- owns validation/bootstrap/descriptor-build orchestration,
- now treats `_require_runtime_ctx(...)` and `run_get_pipeline(...)` as its direct runtime/pipeline dependency-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them,
- now coordinates one explicit internal compiled-state model first and treats that as the source of truth for later descriptor assembly,
- now emits the outward descriptor `{ spec => ..., dependency_regex_map => ... }` at the outer boundary, but that is now a projection of the compiled-spec state rather than the compiler's own working model,
- carries much of the compile-stage structured-diagnostics normalization,
- is one of the project's main implementation centers.

One concrete architectural consequence matters now:

- `build_compiled_rule_table(...)` is now the active low-level seam and still exposes the historical rule-label => info hash by default,
- but internally it first builds a `compiled_spec_state` record with:
  - `definition_order`
  - `compiled_rule_order`
  - `rules_by_label`
  - `redefined_rule_labels`
- default `build_dependency_regex_map(...)` now consumes that state directly and, on the active path, first builds an explicit internal `compiled_dependency_regex_state` record,
- final descriptor assembly now first builds an explicit internal `compiled_descriptor_state` record that composes compiled-spec state plus dependency-regex state, generated-descriptor validation now consumes that state directly, and only then does the compiler project outward `spec` / `dependency_regex_map` hashes while also exposing state-derived metadata such as `meta.descriptor_model`, `meta.definition_order`, `meta.compiled_rule_order`, and `meta.redefined_rule_labels`,
- generated-descriptor validation now also walks that descriptor state directly instead of routing back through the historical legacy `validate_dependency_regex_references(...)` entrypoint, so compatibility descriptor projection is fully deferred until after descriptor-state validation succeeds,
- and descriptor-level migration summary generation now also consumes compiled-spec state directly, so even that metadata no longer needs to bounce back through a legacy spec-hash working model.

That is a real structural improvement, not only a diagnostics tweak:

- the compiler now has one explicit internal state-model owner behind its descriptor model,
- derived dependency regexes now also have one explicit internal state model,
- final descriptor assembly now also has one explicit internal descriptor-state model,
- generated-descriptor validation now also consumes that same descriptor-state model directly on the active path,
- the last legacy compatibility-shape normalization seams for compiled spec and compiled dependency-regex maps now also route through that same owner instead of living as local compiler glue,
- and read-side compiled-state access for definition-order, duplicate-label, and descriptor-to-rule-map reads now also routes through that same owner instead of peeking raw state fields directly,
- while compiled-rule recording during rule-table construction now also routes through that same owner instead of a compiler-local mutation pass-through,
- while ordered compiled-rule iteration now also comes from one owner-provided `rule_rows` view instead of being rebuilt ad hoc from `compiled_rule_order + rules_by_label` in compiler consumers,
- and compiled-spec dependency existence / rule-info lookup now also routes through that same owner instead of direct compiler-side map probing during `build_dependency_regex_map(...)`,
- while compiled-descriptor metadata assembly now also routes through that same owner instead of `Compiler.pm` mutating owner metadata locally,
- and descriptor migration-summary shaping now also routes through that same owner instead of being computed as a large compiler-local reduction over compiled rules,
- ordering is first-class instead of incidental,
- duplicate-label tracking is first-class instead of ad hoc,
- and `build_dependency_regex_map(...)` is now clearly a derived-enrichment phase over compiled-spec state rather than a peer loose hash the compiler happens to juggle beside `spec`, while the outward descriptor now calls that derived payload `dependency_regex_map`.

### `LinkedSpec::CompilerState`
- owns the internal compiled-spec, dependency-regex, and compiled-descriptor state records,
- owns normalization of legacy compatibility hashes into those explicit state records,
- owns the preferred read-side accessors for that state as well,
- owns the preferred ordered-rule iteration view for compiled-spec state as well,
- owns the preferred by-label compiled-rule lookup helpers as well,
- owns compiled-descriptor metadata assembly over compiled-spec state as well,
- owns migration-summary shaping over compiled-spec state as well,
- owns the preferred descriptor-state validation views as well,
- owns validation-friendly shape checks for those records,
- owns projection back to outward `spec` / `dependency_regex_map` hashes,
- is now the one place where the compiler's state model is defined instead of splitting that logic between `Compiler.pm` and `Validation.pm`,
- which means `Compiler.pm` and `Validation.pm` no longer need to carry raw-state field reads, local ordered-rule reconstruction, direct rule-map probing, migration-summary reduction, descriptor-meta mutation, repeated descriptor-validation owner dispatch inside validation loops, descriptor-validation map flattening, or leftover local “accept legacy hash or compiled-state record” conversion seams beside the state owner.

One more boundary is now tighter too:

- malformed compiled dependency-regex-map callback output is rejected directly at final descriptor assembly,
- instead of being allowed to drift into later generated-descriptor validation before the contract problem is identified.

### `LinkedSpec::BootstrapSpec` and `LinkedSpec::BootstrapSpec::Core`
- own the hardcoded bootstrap grammar,
- parse `.spec` syntax before self-hosting is fully realized,
- also carry bootstrap-side parsing/rendering intelligence for method-chain and attached control-flow syntax normalization,
- remain a major syntax and safety hotspot,
- now use explicit `rule_descriptors` and `dispatch_state` naming for bootstrap parser handler plumbing. The old `spec_descr` / `gdata` words should be read as history/compatibility context, not active compiler descriptor/dependency-regex terminology,
- **new in MEDIUM-IMPACT.3.5**: `BootstrapSpec.pm` now has `_build_spec_spec_parser()` which lazily builds the spec.spec-generated parser via the bootstrap seed path (BootstrapSpec::Core → Compiler → spec.spec → parser) and caches the result. `run_bootstrap_parse()` runs the spec.spec parser alongside the bootstrap parser as a **diagnostic side channel** — bootstrap output is always primary for format compatibility. A recursion guard (`$BUILDING_SPEC_SPEC_PARSER` package variable) prevents infinite loop when spec.spec tries to parse itself. The cross-check harness (`tools/cross_check_spec_parsers.pl`) compares oracle (bootstrap) vs candidate (spec.spec) output: currently 2/20 exact match (tablegrep, verilog); remaining 18 specs have inflated candidate counts due to spec.spec `rule_paragraph:AND` handler lacking E-block body collection (MEDIUM-IMPACT.3.4 parity gap).

### `LinkedSpec::Validation`
- is the front-end DSL validation owner (1,368 lines, 30+ subs),
- provides three public entry points that gate the compile pipeline:

  **`validate_spec_content($spec_content, $option)`** — envelope validation:
  - checks the input is a SCALAR ref with non-empty content,
  - verifies the first non-comment/non-blank line starts with a valid rule label,
  - requires at least one top rule (`RuleName::`) as the parser entry point,
  - rejects malformed rule label syntax (extra colons, invalid mode suffixes),

  **`validate_dsl_syntax($spec_content, $option)`** — full paragraph-level validation:
  - parses rule labels (label, colon vs double-colon, mode suffix, RHS),
  - detects duplicate rule definitions,
  - rejects rule definitions inside still-open `{ }` blocks,
  - scans action edges (`->`) and blind-call edges (`=>`) with block-depth tracking,
  - rejects mixed action/blind-call code blocks within a single rule,
  - validates regex literals (`/pattern/`) for Perl compile-ability,
  - validates rule-header RHS start (regex cluster then valid paragraph member content),
  - checks split-marker syntax (`@capture_slice`, `@mark(name)`, etc.),
  - reports unused and undefined rule references,
  - when `strict_syntax => 1` is set, promotes reference warnings to hard errors,

  **`validate_dependency_regex_references($dependency_regex_map, $spec, $option)`** — cross-reference validation:
  - checks every dependency-regex entry references an existing rule,
  - verifies every rule reference targets a valid regex index within the referenced rule's `re` array,
  - validates each rule definition's `dependency_refs` entries have `label` and `idx` keys,

  plus two shared back-end validation entry points:
  - `validate_compiled_descriptor_state($descriptor_state, $option)` — validates compiled descriptor state shape and cross-references via the `CompilerState` validation-view seam,
  - `validate_rule_definition($rule_name, $rule_def)` — validates a single rule's handler field, `re` array, and regex syntax,

- error reporting routes through `_report_dsl_validation_failure` which passes structured `summary`/`detail`/`rule_label` info to the `on_failure` callback and logs via `_trace_log_output`,
- `get_dsl_context($spec_content, $position)` provides line-number/context extraction for error messages,
- `_parse_rule_label_line($line)` is the single rule-label parser used across Validation, Compiler, and BootstrapSpec — it recognizes all supported label forms (`:`, `::`, `:AND+`, `:OR{2,4}`, etc.) and flags invalid modes,
- `_scan_rule_edges_in_fragment($fragment, $start_depth)` is the edge scanner that tracks block depth across `{ }`, `( )`, `[ ]`, string literals, and regex literals while extracting action/blind-call target labels — it powers both same-line validation and cross-line paragraph-member validation,
- for debugging validation failures: look at `_trace_log_output` messages (logged at `DUMP_NONE` for errors, `DUMP_LOW` for warnings), check the `on_failure` callback for structured payloads, and use `get_dsl_context` to correlate line numbers in error messages with source content.

### `LinkedSpec::SpecEntry`
- compiles parsed rule entries into generated runtime handler code,
- still assembles Perl source strings and `eval`s them,
- remains the clearest backend-portability ceiling in the current implementation,
- **new in MEDIUM-IMPACT.1**: handler-variant building is now delegated to `LinkedSpec::HandlerVariantEmitter` which provides:
  - a structured **HandlerIR** (hashref-based AST with `kind`/`label`/`parse_mode`/lifecycle slots / dispatch refs) — each of the 10 variant builders returns an IR node instead of raw Perl source,
  - `_emit_handler($ir, %opts)` dispatches through a `%BACKEND_EMITTERS` table (default: `perl` backend → `_emit_handler_perl`),
  - a JSON/AST diagnostic backend (`_emit_handler_json`) that serializes HandlerIR as canonical pretty-printed JSON via `JSON::PP`, proving backend pluggability,
  - `$BACKEND` package variable + `$deps->{backend}` threading so callers can request alternative backends per compilation.

### `LinkedRE`
- is a small (56-line) regex composition utility living at `perl/LinkedRE.pm`,
- provides two functions: `or(...)` and `oredRE(...)`,
- `oredRE(@regexes)` joins an array of regex references into a single compiled regex via `(?{$pos=N})` position-tracking alternation (`qr/$re0(?{$pos=0})|$re1(?{$pos=1})|.../`),
- `or($stref, $oredRE, $mode_or_parent, $parent_info)` executes the compiled alternation against a scalar ref in seek mode (ungrounded `//gcp`, matches anywhere) or consume mode (`\G`-anchored `//gcp`, contiguously from `pos()`), and returns a match-info hash with `index`, `match`, `match_list`, `match_hash`, and optional `marks`,
- the position-tracking `(?{$pos=N})` embedded in each alternation branch lets callers identify which regex alternative matched via the returned `index` field,
- consumers:
  - `Compiler.pm` (via `_ored_re`): builds compiled regex alternative tables for the dependency-regex map,
  - `SpecEntry.pm`: generates `LinkedRE::or(...)` calls in handler source strings for rule dispatch at runtime,
  - `BootstrapSpec::Core.pm` (via `_linkedre_or` and `_linkedre_ored_re`): uses both functions for bootstrap grammar matching without any `eval`,
- all three consumers load LinkedRE through `OwnerDispatch::require_pkg(...)` rather than direct `use` or local loader wrappers,
- `use re 'eval'` is required for the `(?{...})` embedded code blocks in the compiled regex alternation.

### `LinkedSpec::RuleIR`
- owns rule-level intermediate structure and metadata planning,
- drives handler-variant selection and rule execution metadata.

### `LinkedSpec::RuleIR::EmitContext`
- is the bridge from rule IR into ActionIR scanning and lowering,
- is the main gateway into backend-neutral action rewriting,
- now also centralizes its internal ActionIR owner package registry and owner default-dependency lookup instead of hardwiring those contracts separately across dozens of local wrappers,
- now emits debug-level trace scopes and `emit_context:<phase>:<label>:<decision>` decisions for owner package/callback
  resolution, default dependency bundles, function-registry and bare-symbol-kind injection, top-level rewrite
  fallback/orchestration, and rule emit-context build boundaries while staying lazy for require-only consumers that
  have not loaded `LinkedSpec::Trace`,
- and now treats that owner-key registry plus shared owner dispatcher as the only package/callback-loading seams on the bridge instead of keeping a second layer of owner-specific `_require_*_pkg(...)` shims.

## ActionIR Reading
The ActionIR subtree is now large, but structurally it is much healthier than the older monolithic style.

Current reading:

- `MethodExpr`
  - parses method-like expressions.
- `Scanner` and `ScannerCore`
  - find helper-like and compatibility-like surfaces.
- scanner rule families are split deliberately:
  - `PrimitiveBasicRules`
  - `PrimitivePipelineRules`
  - `FlowRules`
  - `LegacyRules`
- `CanonicalEvents`
  - turns scanned helper hits into canonical event forms.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
  - now lazy-loads `CanonicalEvents::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside `_canonicalize_helper_action_ir_event(...)` instead of keeping a second single-use core-loader wrapper.
- `Diagnostics`
  - tracks unresolved helpers, readiness, and compatibility-surface telemetry.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
- `Diagnostics`, `StatementSplit`, `CanonicalEvents`, `ArrayPipeline`, `ControlFlow`, `Contracts`, `RewritePipeline`, and `Scanner`
  - now also assemble their default callback maps through the shared `OwnerDispatch::build_dep_map(...)` seam instead of hand-building those maps inline.
  - dep-map-only owners no longer keep local `_require_pkg_cb(...)` wrapper bodies around that shared seam; `Scanner` still has one because it directly resolves `ScannerCore`.
- `StatementSplit`
  - owns safe statement splitting.
  - now lazy-loads `StatementSplit::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside `_split_action_ir_statements(...)` instead of keeping a second single-use core-loader wrapper.
- `StatementSplit::Core`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy package loading of statement-split helper packages.
- `ScannerCore`
  - now lazy-loads scanner-rule families directly through `LinkedSpec::OwnerDispatch` inside the shared family-registry loop instead of through a single-use local generic package-loader wrapper.
  - now also centralizes the scanner-rule family registry, and the remaining helper rebinding symbols are derived straight from `_scanner_dep_specs()` instead of living in a second hardwired registry.
  - now also centralizes the scanner dependency contract consumed by `Scanner::default_deps_for_package(...)`, so dependency assembly and dependency rebinding both spend that same dep-spec table instead of drifting in parallel.
- `Contracts`
  - is the contract catalog for supported helper surfaces and how they lower.
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, `DeclareMethod`, and `ValueExpr`
  - make up the main lowering families.
- core lowering owners such as `FlowExpr`, `ValueExpr`, `MethodLowering`, and `DeclareMethod` now also assemble their default callback maps through one shared `OwnerDispatch::build_dep_map(...)` helper instead of hand-building those callback registries inline.
  - those dep-map-only lowering owners no longer keep dead local `_require_pkg(...)`, `_call_preserving_err(...)`, or `_require_pkg_cb(...)` wrappers once `build_dep_map(...)` owns dependency callback resolution.
- `FlowExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_looks_like_array_value_expr(...)`, `_looks_like_hash_value_expr(...)`, `_lower_is_empty_expr(...)`, `_lower_defined_target_expr(...)`, and `_lower_flow_composite_expr(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `ArrayPipeline`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `ControlFlow`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_lower_control_flow_value_expr(...)`, `_lower_switch_case_value_expr(...)`, `_normalize_bare_zero_arg_flow_marker_expr(...)`, `_lower_if_flow_statement(...)`, `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`, `_lower_endif_flow_statement(...)`, `_expand_flow_branch_action_exprs(...)`, `_parse_method_expr_with_optional_attached_block(...)`, `_lower_flow_branch_single_statement(...)`, `_lower_inline_if_branch_expr(...)`, `_lower_inline_switch_branch_expr(...)`, `_lower_switch_flow_statement(...)`, `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`, `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`, `_lower_say_statement(...)`, `_lower_print_statement(...)`, and `_lower_print_each_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `MethodLowering`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, `_lower_return_general_statement(...)`, `_lower_assign_statement(...)`, `_lower_regex_subst_statement(...)`, and `_lower_return_undef_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them. The old `push_value(...)` / `push_nonempty(...)` statement-specific seams have since been removed from the current helper surface.
- `DeclareMethod`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`, `_lower_declare_initializer_expr(...)`, and `_lower_assign_method_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them. The removed declaration helper statement extractor/lowerer no longer belongs to the active source-owner path.
- `ValueExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_split_nested_access_path_segments(...)`, `_lower_nested_access_segment_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, and `_strip_literal_delimiters(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `RewritePipeline`
  - glues the scan, classify, and lower pipeline together.

The important judgment here is:
- the language-neutral `.spec` story does not live in `LinkedSpec.pm`,
- it lives mostly in `RuleIR::EmitContext` and the `ActionIR::*` subtree.

## Legacy Plugin Branch Reading
The current public facade still exposes a plugin/runtime branch, but the architecture direction has shifted.

### `LinkedSpec::PluginRegistry`
- owns the clean explicit in-memory registry surface.

### `LinkedSpec::PluginBridge`
- is the transition bridge,
- checks explicit registration first,
- falls back to legacy behavior only when needed,
- assembles its default dependency callback map through `LinkedSpec::OwnerDispatch::build_dep_map(...)`,
- routes its default registered-plugin lookup and legacy runtime load through `LinkedSpec::OwnerDispatch`,
- spends that legacy runtime load directly inside `_load_legacy_plugin_runtime(...)` instead of through a single-use local generic package-loader wrapper,
- and does not own discovery itself; it is a registry-first dispatch shim over the older `.plg` runtime.

### `PPlugin`
- owns legacy `.plg` discovery,
- reads legacy `.plg` files through explicit file IO rather than global diamond-reader state,
- parses `.plg` files through the `pplugin` parser,
- caches discovered handlers,
- executes them dynamically,
- lazy-loads its default `pplugin` parser callback through `LinkedSpec::OwnerDispatch` rather than a local `require LinkedSpec` branch,
- now also treats `_load_legacy_registry(...)` as its direct parser/discovery/registry dependency-validation seam instead of keeping a second top-level `_require_dep(...)` wrapper above it,
- is treated as an internal compatibility adapter reachable only through the deprecated `LinkedSpec` plugin-bridge stubs; the legacy `.plg` corpus it used to discover has been relocated to `noncore/plugin/`, so the active `perl/` tree no longer ships any `.plg` file for it to load,
- and still closes the remaining lazy compatibility cycle:
  - `LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`

Current project direction does not treat that branch as a target architecture.

### Retired and quarantined domain owners

The project's former domain-utility owners — the RTL/VHDL/FSM generation helpers, the QC and timing report backends, the HTTP/HTML/text/Office/table helpers — and the legacy `.plg` plugin corpus they came from are **no longer part of the active `perl/` tree**. They were the Perl reference backend's legacy island, not part of the backend-neutral `.spec` contract, and two retirement passes resolved them once `t/phase0_regression.t` confirmed the `.spec` engine has zero functional dependency on any of them:

- **Deleted** (`LEGACY-VHDL-RETIRE`): the Perl-only, non-portable VHDL/RTL/FSM-generation subsystem — `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them — has no Rust/Dart/Julia/Lua counterpart, so it was removed rather than ported (which also cleared a catastrophic-backtracking regex hang that used to block the regression gate). The earlier `generic_fake_memory_module.plg` / `wrapgen.plg` / `get_log2`->`ceil_log2` prose described files that had already been deleted; it is gone with the subsystem.
- **Relocated to `noncore/`** (`NONCORE-QUARANTINE`): every remaining non-core domain owner — `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, plus the flat domain `.pm` — and the 13 surviving `.plg` were `git mv`'d into `noncore/` with layout preserved. `noncore/README.md` is the parked-fate ledger (refactor / port / publish / delete each on its own merits later), and the root `plugin/` directory no longer exists.

The historical narrative — how each helper family graduated out of `.plg` plugin subdefs into a package owner — lived here as a faithful record of the reference backend's plugin-retirement work. That work is now moot: the code itself has left the core. `git log` for `LEGACY-VHDL-RETIRE` and `NONCORE-QUARANTINE` preserves the detail.

The current intended direction is:
- keep deterministic named `.spec` resolution,
- treat dynamic `.plg` loading and plugin execution as legacy-removal territory,
- move executable helper logic into explicit package ownership outside `LinkedSpec::*`,
- keep LinkedSpec focused on parser/spec/runtime responsibilities.

## Strongest Current Boundaries
These are the seams that currently look healthiest and most worth preserving.

### 1. Thin `LinkedSpec.pm` facade
This is good architectural movement. The public entrypoint is no longer trying to own everything itself.

### 2. `ParserFactory -> Runtime -> Compiler`
This is the practical core spine of the system and gives a readable ownership model to parser construction.

### 3. `RuntimeContext`
This is one of the best extractions in the project so far. It reduced drift and made structured diagnostics much more coherent.

### 4. Compiler-owned compiled-spec state
This is now one of the healthiest improvements in the compile path. The compiler no longer has to reason about “legacy spec hash” as its own internal truth; it has one explicit compiled-spec state model and emits legacy compatibility shapes only at the edges.

### 5. ActionIR modularization
The lowering stack is big, but it now has real sub-owners instead of one giant mixed-semantics file.

## Main Hotspots and Risks
### `BootstrapSpec::Core`
- dense syntax hotspot,
- difficult to change safely,
- still central until self-hosting is stronger,
- the former bootstrap-only `spec_descr` / `gdata` vocabulary has been renamed to `rule_descriptors` / `dispatch_state`, so the remaining risk is the density of the bootstrap syntax logic rather than a known active naming island.

### `SpecEntry`
- still relies on generated Perl source plus `eval`,
- strongest backend-portability ceiling,
- still a likely long-term refactor target.

### Public visibility of legacy plugin surface
- `run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`, and `AUTOLOAD` still sit in `LinkedSpec.pm`,
- even though the project direction now says dynamic plugin loading is not a core target to preserve.

### Remaining compatibility drag
- the broad owner-dispatch cleanup has paid off and Backbone Item 3 is much thinner now than it was,
- but the public plugin compatibility surface still over-advertises a branch the docs already treat as transition/removal machinery,
- and future effort should bias back toward semantic/runtime/self-hosting milestones unless fresh duplication is clearly material.

## Current Strategic Judgments
### 1. LinkedSpec is no longer best understood as a plugin-hosting framework
The clearer core story is:
- named `.spec` lookup,
- parser compilation,
- parser runtime,
- action lowering,
- diagnostics.

Dynamic plugin loading was historically useful, but it is not the architectural center anymore.

### 2. Spec/resource lookup and plugin loading should stay separate in our thinking
The justified behavior to preserve is:
- `get_parser('foo')` should locate `foo.spec` without path burden.

That does not imply that LinkedSpec must keep a dynamic plugin system.

### 3. Future portability still runs through `SpecEntry`
Even with a much stronger ActionIR story, runtime handler generation still bottoms out in emitted Perl and `eval`.

### 4. ActionIR maturity is now more about semantics and architecture than helper count
The helper family is much richer than it used to be. The bigger future wins are now around:
- cleaner semantics,
- lowering discipline,
- validation,
- self-hosting,
- and eventual backend decoupling.

As of the 2026-05-11 phase0 guard, every discovered target `.spec` must compile to descriptor metadata with `language_agnostic_ready_ratio == 1.0000`, no language-agnostic blocked rules, and no compatibility-surface rules. That makes future DSL migration work a matter of preserving the all-target ActionIR-ready contract while improving semantics and architecture.

### 5. `build_compiled_rule_table` / `build_dependency_regex_map` should now be read as phases, not as the ideal long-term data model
The information they represent is still needed. What changed is the ownership model:
- `build_compiled_rule_table(...)` is now best read as "build compiled-spec state",
- `build_dependency_regex_map(...)` is now best read as "build compiled dependency-regex state from compiled-spec state and project the outward dependency_regex_map hash when a caller wants the normal descriptor surface",
- and the legacy hash forms are compatibility outputs rather than the compiler's own preferred representation.

## Suggested Session-Start Refresh Checklist
At the start of a future session, this document should be re-read and adjusted if any of the following changed:

- the public API surface of `LinkedSpec.pm`,
- the practical compile spine,
- the role of `RuntimeContext`,
- the biggest architectural hotspots,
- the status of `SpecEntry` code generation,
- the status of bootstrap/self-hosting,
- the status of the legacy plugin-removal track,
- or the project's own understanding of what LinkedSpec should and should not own.

## Bottom Line
Current best reading:

- `LinkedSpec.pm` is a facade,
- `ParserFactory`, `Runtime`, and `Compiler` are the practical parser-build spine,
- `BootstrapSpec::Core` and `Validation` still define much of the frontend truth,
- `Compiler.pm` now has one explicit compiled-spec state model internally and only emits outward `spec` / `dependency_regex_map` hashes at descriptor boundaries,
- `SpecEntry` remains the biggest portability hotspot, though `HandlerVariantEmitter` now isolates the 10 variant builders into their own module (first step toward HandlerIR and backend pluggability),
- `RuleIR` plus `ActionIR::*` are where backend-neutral action semantics really live,
- `RuntimeContext` is one of the strongest architectural boundaries in the project,
- and the legacy plugin branch should be treated as transition/removal machinery, not as the future identity of LinkedSpec.
