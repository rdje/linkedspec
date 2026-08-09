  `.return(array_copy(...))`, `.return(hash_copy(...))`, and `.return(copy(...))` are general payload returns and
  must not get label-injected. On Rust action edges, `call(child)` may need the child return before an attached
  block runs, but publishing `retv`/descriptor tags must wait until the block completes normally; otherwise EBNF
  action blocks observe the current header as `retv` too early. Descriptor scalar bare reads may coexist with a
  same-name aggregate accumulator: bare `rule` can read the descriptor scalar while `array(rule)` and
  `flat_array(rule)` still consume aggregate storage. Finally, `array(retv)` is an aggregate wrapper/read; use
  `[retv]` for a one-element scalar array.

- 2026-07-06 (REPO-HYGIENE.2 — `.gitignore` cannot hide a tracked gitlink):
  `.claude/projects/` was straightforward untracked local agent state, but `rgx` was a tracked `160000` gitlink in
  the parent repo. A `.gitignore` entry does not apply to tracked paths and should not be used for real
  submodules. Keep the submodule declared in `.gitmodules`; when parent status should ignore local worktree dirt
  inside the submodule, use the submodule ignore policy (`ignore = dirty`) instead.

- 2026-07-06 (SPEC-FORMAT-TERSE.15.2.3 — parity work can expose reference-side drift too):
  Rust already read bare `Expr::Variable` values in ordinary value positions, but switch case labels needed a
  deliberate exception to match the Perl reference: `switch(kind)` is a variable read; `case(foo)` is a literal
  tag. The robust shape is a small case-value helper shared by attached/statement switch and inline lazy
  `switch(...)`, rather than relying on general expression evaluation at each case site. The `.15.2.3` oracle also
  found the mirrored Perl bug: inline `case(foo, body)` still used branch-payload lowering and read `$foo`, unlike
  attached `case(foo)`. Case labels are label/key positions, so both engines now treat bare case labels literally
  and reserve evaluated labels for quoted/helper/scalar-slot expressions. A separate oracle surprise came from
  `specs/spec.spec`: after duck-typed assignment, `paragraphs = []` creates a scalar-held arrayref, but the grammar
  mutates aggregate `@paragraphs` / `@current` through `push(...)`. When a shipped spec intentionally uses
  aggregate mutation later, initialize it with explicit `array(...)` targets; do not let direct-shape assignment
  silently stand in for aggregate storage.

- 2026-07-05 (SPEC-FORMAT-TERSE.15.2.2 — the fix was one branch, plus one compensating exemption):
  The `.15.2.1` prediction held: because `ControlFlow::_lower_control_flow_value_expr` delegates to
  `FlowExpr::_lower_flow_composite_expr`, and the switch selector funnels through the same function, a single guarded
  branch at the `passthrough_no_call` site (bare identifier → `$name`) closed the switch/num/if gaps together. The
  non-obvious part was the SIDE EFFECT: `ControlFlow::_lower_switch_case_value_expr` detected a literal case label by
  checking `$lowered eq $trimmed` — i.e. it *relied on the composite lowerer returning bare words verbatim*. The
  moment bare words became `$name`, `case(foo)` silently became `eq $foo`, breaking the switch/case regex lock
  (phase0 test 377/10). Lesson: any consumer that used composite passthrough as a "is this a plain word" oracle is a
  latent break site. The fix is the hash-key-analogous exemption from ADR `0019`: a case LABEL is a key/label
  position, not a value-read position, so it stays a literal — decided on the source token directly, independent of
  what the composite lowerer now returns. Two environmental gotchas cost real time and are now in MEMORY: (1) the
  full phase0 needs `PERL5LIB=` cleared or the pplugin subprocess subtests fail against the stale `pgen/fx/perl`
  checkout (a spurious `not ok 102` that looks like a regression but is not); (2) the suite takes long enough that a
  background run or the default 2-min foreground timeout caps it mid-run (exit 144/143) — use the 10-min foreground
  timeout and always check the REACH (`ok 1022`, plan `1..1022`) before trusting any count.

- 2026-07-05 (SPEC-FORMAT-TERSE.15.2.1 — where bare reads fail, and the ONE seam that fixes most of it):
  The bare-vs-`:name` value-position gap is narrower and more localized than the `.15.2` re-scope note implied.
  Discriminating reference-engine probes (a bare-fallback must yield a *different* result than a real read, else the
  probe proves nothing — my first probe used `n=3`/`c=1` and falsely showed "no gap") confirm exactly three failing
  value positions: the `switch(...)` selector, `num_*(...)` callee args, and `if(...)`/`while(...)`/logical
  conditions. Plain `return(name)`, assignment RHS, and receiver positions ALREADY read bare — so the terse
  read-side is mostly done; the gap is confined to condition/selector/logical-arg lowering. On Perl, that lowering
  funnels through ONE function: `ActionIR::FlowExpr::_lower_flow_composite_expr`
  (`perl/LinkedSpec/ActionIR/FlowExpr.pm:319`). It maps `:name`→`$name` at `:364` but has no bare-identifier arm,
  so a bare atom falls through to a literal (a bareword → numeric 0 in `num_*`, or a truthy string in `if`). The
  same function handles `num_*` args (helper names matched at `:374`, args recursed at `:422`), so closing the
  `switch`/`num`/`if` gap is largely one guarded branch here (plus the switch selector path in
  `ActionIR::ControlFlow._control_ast_value_source_expr:332`). The hard constraint for `.15.2.2`: the new
  bare→scalar-read branch must NOT swallow helper-call names (still matched by the `:374` regex) and must respect
  the value-position-is-variable policy — bare is a variable read ONLY in value positions; rule references live in
  edge/dispatch positions, which is why the real shipped-spec risk is `spec.spec`/`ebnf.spec` rule-name collisions,
  not the synthetic `switch(` fixtures (`switch(` appears in no shipped spec). On Rust the mirror is `Expr::Variable`
  (bare, `rust/linkedspec-core/src/expr.rs:1350`) vs `Expr::ScalarSlot`→`ctx.get_scalar`
  (`rust/linkedspec-runtime/src/engine.rs:3287`). This composes with `.11`: the *type* of a bare name is set at
  assignment by the RHS shape; `.15` only settles that a bare *read* returns that bound typed value.

- 2026-07-05 (SPEC-FORMAT-TERSE.15.2 — `:name` removal is ENGINE-FIRST, not source-first):
  The `.15.1` audit assumed migrating `:name`→bare is a spelling swap. It is not. At `104088e5`, bare identifiers
  are NOT read as the bound variable value in every value position `:name` serves — proven by the oracle
  byte-identity gate and a direct reference-engine probe (`switch(:kind)`→`'good'` vs `switch(kind)`→`'def'`; same
  for `num_lt`/`num_gt`, `if(...)` conditions, and the second arg of all-bare `push(A,B)`). In `spec.spec`/
  `ebnf.spec`, a bare name colliding with a rule/token name (`started`, `top`, `rule`, `on`) resolves as a RULE
  reference, not a variable read. `:name` was doing disambiguation work. So the order MUST be engine-first:
  `.15.2.2`/`.15.2.3` make value-position bare reads honor the bound variable on Perl+Rust (policy: value position
  = variable read; rule references only in edge/dispatch positions), `.15.2.4` migrates sources (now
  output-preserving), then `.15.3`/`.15.4` remove `:name` entirely. Practical debugging aids for this lane: the
  oracle regen (`tools/gen_oracle_corpus.pl`) is slow (~90 fixtures, build-per-fixture) and must run in the
  BACKGROUND (foreground times out); a changed `expected.json` after a bare migration is the signal a slot is
  load-bearing (bare≠colon). Recovery of the prior dirty tree lives on `recovery/terse-15-uncommitted-20260705`.
  See ADR `0019` and KM card `terse-bare-read-value-position-gap`.

- 2026-07-05 (SPEC-FORMAT-TERSE.15.1 — colon scalar-slot removal split):
  Do not try to remove `:name` in one parser/runtime slice. The audit found it in current shipped/root specs,
  generated oracle inputs, mdBook guidance, Knowledge Map facts, trace/phase0 tests, oracle generation sources,
  Perl scalar-slot lowering/extraction, and Rust `Expr::ScalarSlot` parser/runtime support. Keep `.15.2` focused
  on current-facing migration to bare value reads while compatibility still exists; only after that should `.15.3`
  and `.15.4` retire Perl and Rust parser/runtime support. Hash-literal key positions are a separate grammar
  boundary and must not be accidentally reinterpreted as value reads.

- 2026-07-05 (SPEC-FORMAT-TERSE.11.5 — duck-typed assignment alignment):
  Treat `.1.2.3.5.2` / `.1.2.3.5.4` RHS target-kind inference as historical only. Current-facing docs, fact cards,
  tests, and roadmap text must say that direct RHS shapes bind typed values: `name = [value]` stores an array value
  in `name`, not `@name`, and `name = { key => value }` stores a hash value in `name`, not `%name`. Explicit
  `array(name)` / `hash(name)` targets remain the aggregate-storage mutation boundary. When updating older
  migration notes, preserve history only with an immediate supersession pointer to the `.11` duck-typed contract.

- 2026-07-05 (SPEC-FORMAT-TERSE.11.4 — nested value-path assignment):
  Nested direct-access lvalues now have explicit duck-typed value-tree semantics. Keep `assign_nested_access`
  lowering/runtime code guarded: every intermediate segment must check both existence and container shape, final
  hash segments may create/replace entries, final array segments may only replace an existing element or append at
  exactly `len`, and failed path checks return `undef`/`RuntimeValue::Undef` without mutating the root. Do not use
  Perl autovivification as language semantics. Single-segment `name[index] = value` must route through scalar-held
  array/hash mutation when type memory/runtime `bare_kind(name)` says the name is scalar-bound; only then should it
  fall back to named hash storage. Generated Perl should avoid private `->$idx =` assignment forms inside lowered
  path helpers, because readiness diagnostics can mistake them for unresolved DSL lvalues; use guarded `splice`
  for in-range array replacement.

- 2026-07-05 (SPEC-FORMAT-TERSE.11.3 — Rust duck-typed assignment parity):
  Rust `Engine` now treats bare assignment as typed value binding. `Expr::AssignScalar`,
  `execute_scalar_assignment_operator_statement`, and `set`/`=` helper execution evaluate the RHS and store the
  resulting `RuntimeValue` in the scalar slot without direct RHS-shape retagging. Keep explicit aggregate mutation
  boundaries deliberate: only raw `array(name)` / `hash(name)` targets should route to `RuntimeContext::set_array`
  / `set_hash`; bare `set(name, [value])`, `name = [value]`, and `=(name, [value])` must remain scalar-held typed
  values. Scalar-held `array(name)` / `hash(name)` views are guarded by `bare_kind(name) == Scalar`, so later
  aggregate mutations such as `items += value` or `set(array(items), ...)` can retag the name back to aggregate
  storage. Future nested-path work in `.11.4` must preserve that value-binding contract instead of reviving the
  old `.1.2.3.5.4` target-kind inference branch. The oracle run also exposed and closed the matching Perl
  reference readback gap: scalar-held `copy(name)` and bare array receiver chains must consult the remembered
  scalar-held array/hash value before falling back to aggregate storage, and `RuleIR::EmitContext` must auto-declare
  the scalar slot for remembered-scalar `copy(name)` rather than reviving `my @name` / `my %name`.

- 2026-07-05 (SPEC-FORMAT-TERSE.11.2 — Perl duck-typed assignment):
  Perl bare assignment now binds typed RHS values through scalar storage. The key seams are
  `ActionIR::MethodLowering::_lower_value_binding_source_expr`, bare-target branches in assignment/set lowering,
  expression-valued assignment lowering, and `RuleIR::EmitContext` type/declaration collection. Direct shape RHS no
  longer decides `@name`/`%name`; explicit `array(...)`/`hash(...)` assignment targets still own aggregate mutation
  storage. Scalar-bound `array(name)`/`hash(name)` views must bypass aggregate-storage fast paths and lower through
  guarded `$name` snapshots. Rust still needs equivalent runtime value binding in `.11.3`; do not let Rust tests or
  corpus expectations keep the old direct-shape retagging contract.

- 2026-07-05 (SPEC-FORMAT-TERSE.11.1 — split/probe):
  Current implementation still has two target-kind inference seams that conflict with duck-typed assignment:
  Perl `MethodLowering`/`RuleIR::EmitContext` lower and declare bare direct-shape assignments as `@name` or
  `%name`, and Rust `engine.rs` retags bare `AssignScalar` / `set` direct-shape RHS values through
  `set_array`/`set_hash`. Keep `.11.2` focused on the Perl reference change first; do not stage unrelated
  pre-existing `.8` helper-removal edits from the dirty worktree into the `.11.2` commit.

- 2026-07-05 (SPEC-FORMAT-TERSE.15 — colon scalar-reference removal):
  Duck typing removes the reason for `:name` as scalar-slot syntax. The future current-facing surface should read
  variables and parameters as bare names in value positions. Preserve the grammar distinction that bare names in
  hash-literal key position are stringified keys, while bare names in value position are value reads. Typed
  aggregate views should remain explicit (`array(value)`, `hash(value)`) rather than punctuation-driven.

- 2026-07-05 (SPEC-FORMAT-TERSE.14 — trailing block arguments):
  Future attached-block generalization should be a block-argument type, not full closures. Keep the block final in
  the call signature and prefer `fn(args) { ... }` / grammar-safe zero-arg `fn { ... }` over inline
  `fn(args, { ... })` until the parser can distinguish code blocks from hash literals without guessing. A
  block-taking helper or receiver method also needs an explicit invocation contract: how it calls the block, what
  context values it passes, what the block returns, and what diagnostics are produced for missing/non-callable
  block arguments. Do not make blocks assignable, returnable, or caller-state-capturing under this leaf.

- 2026-07-05 (SPEC-FORMAT-TERSE.12/.13 — tree traversal backlog):
  Future hash-tree traversal should be specified as receiver methods with attached blocks over a value tree whose
  root and interior nodes are hashes and whose leaves are scalars or arrays. Before implementation, define method
  names, block attachment syntax, callback context (`value`, `key`, `path`, `depth`, accumulator if needed),
  deterministic traversal order, array-leaf treatment, and pure-vs-mutating return policy. The analogous array-tree
  traversal idea is tracked separately as lower-priority backlog and should not be inferred from the hash-tree
  design without its own array-tree definition.

- 2026-07-05 (SPEC-FORMAT-TERSE.11 — nested typed-value paths):
  Duck-typed assignment must include nested reads and writes through mixed array/hash value trees in arbitrary
  combinations. Do not let Perl autovivification semantics define the language accidentally; the implementation
  needs explicit behavior and tests for missing intermediate containers, array/hash segment transitions, and both
  statement-form and expression-valued nested assignment where assignment expressions are supported.

- 2026-07-05 (SPEC-FORMAT-TERSE.11 — duck-typed assignment semantics):
  The active assignment direction is now duck-typed value binding, not Perl storage-class inference. Treat
  `name = value` as binding the variable to the RHS typed value at runtime: strings/numbers/scalars, arrays from
  `[...]`, and hashes from `{...}`. Later assignments may change the value shape. `array(name)` and `hash(name)`
  should be modeled as explicit typed reads/snapshots/guards, not declarations. The `.11` MVP deliberately keeps
  aggregate RHS values delimiter-explicit; do not make `name = a, b` equivalent to `name = [a, b]` or `name = k : v`
  equivalent to `name = { k : v }` without a later task-tree leaf that specifies precedence, diagnostics, and
  recovery.

- 2026-07-04 (TRACE-OBSERVABILITY.4.5 — trace parity proof):
  Rust may now claim trace parity for the mdBook-documented external capability contract. The claim is behavioral:
  ordered levels, normal-entrypoint controls, stdout/routed-file/mirror sinks, routed-file reset, default-quiet
  behavior, structured compile/spec-parser/runtime scopes, decision/branch events, mark/capture/source-boundary
  events where implemented, and dump/log diagnostics. It does not require Rust to reuse Perl package names or every
  Perl-internal event namespace. Future variants must satisfy the mdBook checklist and commit task-tree/Knowledge
  Map proof before claiming parity.

- 2026-07-04 (TRACE-OBSERVABILITY.4.4 — Rust runtime trace events):
  Rust runtime trace events are now emitted through the same shared `linkedspec-core::trace` sink as `.4.2`/`.4.3`.
  The runtime context records structured execution events only when a traced entrypoint enables recording, then
  replays them through the caller-owned `TraceEmitter`; existing `Engine::execute(...)`,
  `Engine::execute_generated_with_plan(...)`, and generated `parse(...)` defaults remain quiet and output-compatible.
  Interpreted runtime traces now cover rule entry/exit, recursion cutoffs, regex match/no-match choices, acode/bcode
  child dispatch, lifecycle block execution, statement-form `if`/`switch` decisions, helper `call(child)` dispatch,
  and mark/capture helper operations. Generated-plan traces additionally report top-rule selection, generated family
  dispatch, direct acode/bcode rule scopes, and generated child/regex/acode/bcode decisions. Rust still does not
  claim trace parity until `.4.5` proves the variant-agnostic contract and future-variant checklist.

- 2026-07-04 (TRACE-OBSERVABILITY.4.3 — Rust compile/spec-parser trace events):
  Rust trace emission now spends the shared `linkedspec-core::trace` emitter across the compile/spec-parser owner
  boundaries instead of adding a second runtime-only observability path. Core traced APIs emit stable owner
  namespaces: `rust_core:parse_spec`, `rust_core:validate:*`, `rust_core:compile:*`, and
  `rust_core:compile:dependency_regex_map`. Runtime full-spec parsing threads the same caller-owned emitter into
  user-function-definition parsing and neutral `body_parse_job` dispatch, so staged parse-job traces follow the
  implementation-language-neutral sidecar rather than a Rust-only shortcut. Staged registry traced entrypoints
  report normalize, queue-sort, resolve, load, compile, and execute phase decisions while preserving exact untraced
  result records. Runtime branch, generated-plan, and mark/capture work has since landed under `.4.4`; parity-proof
  work remains separate under `.4.5`; do not claim Rust trace parity from `.4.3` alone.

- 2026-07-04 (TRACE-OBSERVABILITY.4.2 — Rust trace controls):
  Rust now has the shared trace control layer, but not trace event parity. Use `linkedspec_core::trace` for
  `TraceLevel`, `TraceConfig`, `TraceSinkMode`, `TraceEmitter`, the `DUMP_*` constants, environment-derived config,
  stdout/route/mirror sinks, file reset, and event primitives. Runtime users and generated modules should import
  the same surface through `linkedspec_runtime::trace`.

  Existing quiet entrypoints remain the compatibility default. New traced variants validate trace setup and sink
  routing beside core parse/validate/compile, full-spec user-function parsing, staged parse jobs, `Engine::execute`,
  generated-plan execution, generated parser execution, and emitted generated module `parse_with_trace(...)`.
  `.4.3` has since wired compile/spec-parser/staged-dispatch events, and `.4.4` has since wired runtime branch events.
  Do not claim Rust trace parity until `.4.5` parity proof is complete.

- 2026-07-04 (TRACE-OBSERVABILITY.4.1 — Rust trace parity design):
  The Rust trace surface must be designed from the mdBook external contract, not from Perl package names. Because
  `linkedspec-core` owns `parse_spec`, `validate`, `compile`, dependency-regex resolution, and the shared
  `CompiledSpec`/`CompiledRule` contract, shared Rust trace primitives should be core-visible. Keep the existing
  `parse_spec(...)`, `compile(...)`, `Engine::execute(...)`, and generated parser `parse(...)` defaults quiet and
  output-compatible; add explicit traced configuration/plumbing beside them. Runtime instrumentation then belongs
  in `linkedspec-runtime` around `parse_spec_with_user_functions`, staged parser dispatch, interpreter rule
  execution, generated-plan execution, lifecycle block execution, statement-form `if`/`switch`, acode/bcode child
  dispatch, repetition/AND/OR branch choices, and mark/capture helper operations. Rust could not claim trace parity
  until `.4.2` controls/sinks, `.4.3` compile/spec-parser events, `.4.4` runtime branch events, and `.4.5` parity
  proof were complete; `.4.2` through `.4.5` have since landed, and Rust can now claim parity for the documented
  external capability contract.

- 2026-07-04 (TRACE-OBSERVABILITY.3.5 — trace contract/parity split):
  The external trace contract is the mdBook-documented behavior, not Perl package names. A variant claiming trace
  parity must expose equivalent ordered levels, normal-entrypoint controls, stdout/routed-file/mirror sinks, routed
  file reset, structured enter/exit events, decision/branch events, mark/capture events where applicable, dump/log
  events, and default quiet behavior. The Perl reference trace suite is green across CLI, generated handler branch
  helper, non-REP/REP generated dispatch, RuleIR, EmitContext, ActionIR pipeline, compact lowerers, and
  MethodLowering. Rust currently has no trace API/control hits outside corpus fixture text, so `.4.1` owns the Rust
  design inventory before any Rust trace code.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4.6 — compile/ActionIR trace closeout):
  The planned Perl reference compile/ActionIR trace namespaces are covered through MethodLowering. A normal
  descriptor compile with routed debug trace now emits `rule_ir`, `emit_context`, `actionir:scanner`,
  `actionir:rewrite_pipeline`, `actionir:control_flow`, and `actionir:method_lowering` decisions together while
  the descriptor remains language-agnostic ready (`ready=1 raw=0 unresolved=0`). Treat `.3.5` as the global trace
  no-drift/example closeout and backend-parity split leaf, not another compile/ActionIR owner-instrumentation leaf.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4.5 — MethodLowering trace):
  `ActionIR::MethodLowering` now uses the same lazy `LinkedSpec::ActionIR::Trace` seam and
  `actionir:method_lowering:<phase>:<label>:<decision>` namespace as the other ActionIR owners. Current covered
  decisions include helper-family classification (`helper_family_string`, `helper_family_array`, etc.),
  AST-vs-compat fallback/bypass choices, unsupported-helper sentinel exits, receiver-chain family transitions for
  string/number/hash/array chains, AST fluent-chain family lowering, scalar/array/hash assignment and mutation
  operator paths, mutation-slot source classification, return-payload fallback choices, and the scoped
  `_lower_assign_statement` enter/exit boundary. Keep MethodLowering trace additions on this owner namespace rather
  than ad hoc strings, and preserve the lazy invariant: requiring `MethodLowering.pm` or calling it through
  `EmitContext` without explicit trace configuration must not load `LinkedSpec::Trace`.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4.4 — compact ActionIR lowerer trace):
  Compact lowerer decisions use the same debug-level `actionir:<owner>:<phase>:<label>:<decision>` namespace as
  `.3.4.3`. Owners covered here are `flow_expr`, `value_expr`, `array_pipeline`, `declare_method`, and
  `control_flow`; `method_lowering` remains deferred to `.3.4.5`. The current trace reports flow-expression
  boolean/slot/literal/logical/comparison/definedness choices, value direct-access and assignment-source choices,
  array-pipeline plan/op lowering, declaration extraction/initializer/set routing, and compact control-flow
  attached/inline/marker if/switch paths plus branch-statement passthrough/rewrite handling. Keep these owner
  hooks lazy through `LinkedSpec::ActionIR::Trace`; requiring compact lowerer modules or calling them through
  `EmitContext` without trace configured must not load `LinkedSpec::Trace`. User clarification on 2026-07-04:
  documented trace capabilities are the variant-agnostic external contract. Rust and future variants cannot claim
  trace parity until they expose equivalent controls, levels, event classes, and sink behavior; keep Perl internals
  marked as implementation-specific in the mdBook.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4.3 — ActionIR pipeline trace):
  ActionIR pipeline decisions use debug-level `actionir:<owner>:<phase>:<label>:<decision>` names through
  `LinkedSpec::ActionIR::Trace`. Owners covered in this slice are `scanner`, `scanner_core`, `canonical_events`,
  `diagnostics`, and `rewrite_pipeline`. The coverage includes helper-event discovery, canonical queue matching,
  registered value-drop recognition, RAW_PERL fallback creation/preservation, unmatched helper scan events,
  unsupported/unresolved helper diagnostics, rewrite-rule construction, canonical lowering decisions, source-span
  skips, and implicit attached-if closure insertion/appending. Keep scanner trace intentionally focused on
  event-producing matches rather than per-contract no-match lines because diagnostics replays every contract and
  no-match noise would drown the useful signal. `ActionIR::Trace` must remain lazy: requiring ActionIR owners or
  running compatibility rewrite paths without trace configured must not load `LinkedSpec::Trace`.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4.2 — EmitContext owner-bridge trace):
  EmitContext bridge decisions use debug-level `emit_context:<phase>:<label>:<decision>` names. Current phases are
  `owner_package`, `owner_callback`, `owner_deps`, `owner_call`, `owner_call_with_deps`,
  `rewrite_action_code_for_compat`, `rewrite_action_code_with_diagnostics`, and `build_rule_ir_emit_context`.
  Keep this namespace for bridge/orchestration visibility only; scanner/canonical/diagnostic/rewrite-pipeline
  internals remain owned by `.3.4.3`. The trace helpers deliberately no-op unless `LinkedSpec::Trace` is already
  loaded, so require-only EmitContext consumers stay Trace-lazy. Owner-call wrappers must continue to preserve
  list/scalar/void context because `_rewrite_action_code_with_diagnostics(...)` and other bridge calls return
  meaningful list payloads.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4.1 — RuleIR planning trace):
  RuleIR planning decisions use debug-level `rule_ir:<phase>:<rule>:<decision>` names. Keep this namespace for
  future RuleIR planning additions instead of adding ad hoc trace strings. Current phases are `collect`, `select`,
  `meta`, and `validate`; covered decisions include lifecycle routing, explicit ACODE/BCODE collection,
  `MOVE_POS`/`MARK_POS` LECODE lowering, handler variant selection, action mode, execution shape, and mixed-action
  validation. The trace helper deliberately delegates through the existing lazy `_trace_decision` wrapper, so
  require-only `RuleIR.pm` users still do not load `LinkedSpec::Trace`.

- 2026-07-04 (TRACE-OBSERVABILITY.3.4 — compile/ActionIR coverage split):
  Do not instrument compile/ActionIR trace coverage as one patch. The owner surface is too large:
  `RuleIR.pm`, `RuleIR/EmitContext.pm`, scanner/canonical/diagnostic/rewrite owners, compact lowering owners, and
  `ActionIR::MethodLowering` need separate reviewable slices. The sequence is now `.3.4.1` RuleIR planning,
  `.3.4.2` EmitContext owner bridge, `.3.4.3` scanner/canonical/diagnostics/rewrite pipeline, `.3.4.4` compact
  lowering owners, `.3.4.5` MethodLowering, and `.3.4.6` closeout. Start with RuleIR because it selects the handler
  family/action-mode names the rest of the trace should reuse.

- 2026-07-04 (TRACE-OBSERVABILITY.3.3 — repetition generated path tracing):
  Repetition Perl generated handler templates now emit debug-level REP branch decisions through
  `trace_generated_handler_branch(...)`. Common REP branch names are `loop_enter`, `iteration_result`,
  `miss_min_satisfied`, and `max_continue`; `REP_ACODE` also reports `match` and `acode_index_<n>`, while bcode
  REP variants also report `zero_progress` and `zero_progress_min_satisfied`. Keep inner non-REP bcode helper
  traces disabled inside REP coderefs unless a later leaf deliberately changes trace granularity; `.3.3` keeps the
  REP loop as the ownership boundary for emitted decisions. Compile/ActionIR owner coverage has since closed under
  `.3.4.*`, and Rust trace parity is now split under `.4.*`.

- 2026-07-04 (TRACE-OBSERVABILITY.3.2 — non-repetition generated dispatch tracing):
  Non-repetition Perl generated handler templates now emit branch decisions through
  `trace_generated_handler_branch(...)`. Keep new non-REP branches on that helper rather than hand-formatting trace
  strings. Current branch names include `match`, `no_match_lx`, `acode_index_<n>`, `required_index_0`,
  `required_sequence_index`, `bcode_call_<Rule>`, `bcode_child_result`, and `bcode_no_child_match`. These are
  debug-level events, so CLI/per-call probes that need generated-handler branches must use `--trace debug` or
  `trace_level => 'debug'`. Repetition loops have since been instrumented under `.3.3`.

- 2026-07-04 (TRACE-OBSERVABILITY.3.1 — generated-handler branch helper seam):
  `LinkedSpec::Trace::trace_generated_handler_branch(%args)` is the only helper contract generated Perl handler
  templates should use for branch decisions. It returns the normalized original `taken` value, so wrapping a branch
  condition must not change parser behavior. Keep branch details lazy with `details => sub { ... }`; the helper
  deliberately skips that builder when trace is disabled and captures builder errors in the trace text when enabled.
  Do not hand-format generated-handler branch trace messages in templates; `.3.2` and `.3.3` should wire templates
  through this helper.

- 2026-07-04 (TRACE-OBSERVABILITY.3 — coverage extension split before code):
  Do not instrument "see everything" as one patch. Generated handler branch tracing needs a small reusable emitted
  helper seam first, then separate non-repetition and repetition template leaves because dispatch/no-match/LX/EX and
  min/max/zero-progress loop behavior carry different risks. Compile/ActionIR owner scopes followed after the
  runtime branch trace semantics became concrete. Rust trace parity has since split under `.4.*`; do not claim
  parity from a Perl-only trace model.

- 2026-07-04 (TRACE-OBSERVABILITY.2 — CLI control over existing trace):
  `bin/linkedspec` is deliberately a thin command-line bridge over the existing Perl reference public surfaces. It
  does not add a second trace state path: `--trace`, `--trace-file`, `--trace-mode`, `--trace-reset`, and
  `--trace-emoji` map to the existing trace option keys consumed by `Get(...)` / `get_parser(...)`. The runner
  prints parser results as canonical JSON; routed trace (`--trace-file ... --trace-mode route`) is the preferred
  machine-readable mode because stdout remains clean. This slice closes discoverability only. It does not claim
  generated handler branches, ActionIR owner branches, or Rust trace parity are covered. The Perl reference coverage
  has since closed through `.3.5`; Rust trace parity is now owned by `.4.*`.

- 2026-07-04 (TRACE-OBSERVABILITY.1 — coverage audit before trace work):
  The trace framework was not missing; coverage and discoverability are the gaps. Current Perl trace sees broad
  `Get`/parser invocation stages, per-rule runtime handler wrappers, selected decisions, dumps, and mark/capture
  events. At audit time it did not yet see the actual generated handler branches (`while`, `foreach`, `if`/`elsif`,
  `unless`, repetition min/max/zero-progress paths, acode index dispatch, bcode call dispatch); `.3.2` and `.3.3`
  have since wired the Perl reference templates. Most ActionIR owner lowering branches still have no enter/exit or
  decision trace. The first implementation path should be explicit,
  reviewable instrumentation in the generated handler templates plus owner-level wrappers, not an aspect/`Devel::*`
  approach. Also keep the public controls honest: use env vars, per-call trace options, or `configure_trace(...)`.
  Assigning `$LinkedSpec::DUMP_VERBOSITY` before the lazy `LinkedSpec::Trace` load is not a reliable facade control;
  `trace_mark_event` is an owner-level `LinkedSpec::Trace` function, not a `LinkedSpec` facade method.

- 2026-07-04 (TOP-RULE-AS-NORMAL.3.2 — Rust recursive top-rule values):
  The recursive value leak was not caused by child dispatch needing full variable-store isolation. The real Rust
  bug was narrower: `declare(array, items)` is parsed with raw first arg `Variable("array")`, and the runtime had
  been evaluating that as a normal variable, yielding `""` and making the declaration a no-op. Without a real
  declaration, recursive rule invocations shared the same auto-existing `items` array. The durable fix is to
  resolve a raw first positional variable as the literal declaration type token, then snapshot/restore only
  declared variables per rule invocation. Keep undeclared rule mutations shared unless a future leaf changes that
  contract deliberately; existing Rust tests rely on undeclared child mutations being caller-visible. User
  functions must suppress rule declaration tracking because they already swap in a function-local variable store.
  The oracle corpus is now 91 fixtures, adding three recursive top-rule/body value fixtures under this leaf.

- 2026-07-04 (RUST-PARITY.9 — closeout and next-frontier routing):
  `RUST-PARITY` is closed as a follow-on tree, not because generated source now covers every corpus fixture, but
  because the Rust parity obligations owned by this tree have a stable documented boundary: interpreter parity is
  guarded by the 88-fixture manifest corpus, generated source directly executes every supported structural family,
  and generated-source corpus proof is an 8-case subset. That distinction must stay visible in roadmap/book/live
  docs. Closing the tree also unblocks `TOP-RULE-AS-NORMAL.3.2`; its remaining recursive top-rule value checks
  should be implemented under the top-rule tree, not by reopening `RUST-PARITY`.

- 2026-07-04 (RUST-PARITY.8.5 — generated-source oracle/corpus integration):
  Keep two generated-source proof layers distinct. The synthetic `source_emitter` matrix is the structural-family
  proof: it must cover every current generated family and compile/run the emitted modules in an isolated crate. The
  manifest-backed corpus subset is the oracle-contract proof: it loads real `tests/corpus/manifest.json` entries,
  first checks normal Rust interpreter output against `[expected.json]`, then emits those same compiled specs and
  proves generated `parse(...)` returns the same value. The current generated-source corpus subset is intentionally
  curated rather than exhaustive: authored proof fixtures, terse helper/control/user-function fixtures, and shipped
  `tclite`/`portmap` smokes. The full 88-fixture corpus remains the interpreter parity gate until a separate leaf
  explicitly broadens generated-source corpus coverage.

- 2026-07-04 (RUST-PARITY.8.4 — REP generated-family direct execution):
  Generated source now has explicit repetition family markers instead of one opaque `Repetition` bucket:
  `RepAcode`, `RepBcode`, `RepAndAcode`, and `RepAndBcode`. `GeneratedPlanExecutor` routes all four directly.
  The important semantic fixes are shared with the interpreter so generated-source tests can keep using the
  interpreter as their first oracle: repeated blind-call rules now loop OR choice or AND sequence steps with
  min/max bounds and a zero-progress guard, and REP-AND acode counts a complete ordered regex group as one
  repetition before firing `IT`. The source-emitter matrix covers bounded REP acode/bcode, bounded REP-AND
  acode/bcode, zero-progress termination, and a same-position recursive `call(Top)` cutoff; the generated temp
  crate builds and runs all cases. A legacy-plan test keeps the v1 `GeneratedRuleFamily::Repetition` marker
  accepted for existing generated REP modules while current source emits explicit REP variants. `.8.5` is the next
  leaf for all-variant/corpus-backed generated-source validation.

- 2026-07-04 (RUST-PARITY.8.3.5 — non-REP generated-family matrix closeout):
  `GeneratedPlanExecutor::execute_rule` now routes exhaustively by `GeneratedRuleFamily`. `Default`, `OrAcode`,
  `AndSingleAcode`, `AndAcodeSeq`, `AndBcode`, and `OrBcode` use direct generated execution; `Repetition` is the
  only generated family that falls back through the interpreter-owned rule path. The source-emitter test now
  collects the family markers covered by its generated-module cases and asserts that they equal the complete
  non-REP family set before REP work begins. `.8.4` is the next implementation leaf for repetition generated
  execution and termination guards.

- 2026-07-04 (RUST-PARITY.8.3.4 — direct AND/OR bcode generated execution):
  `GeneratedPlanExecutor` now handles `AndBcode` and `OrBcode` directly. The direct path keeps the same runtime
  invocation envelope as the interpreter: recursion guard, entry/local match save/restore, clean return channel,
  rule `I` block, child-return-to-`retv` propagation, blind-edge attached code/fluent execution, and rule `E` block.
  The interpreted bcode branch now shares the blind-edge tail helper and uses rule mode for OR bcode first-match:
  explicit OR bcode rules stop after the first truthy child return instead of walking later entries, and no-match
  OR bcode executes `LX` before any parent `E` block. The source-emitter matrix proves both sides: AND bcode
  collects ordered child returns `A`, `B`; OR bcode on `a b` returns `or-bcode:A`; and OR bcode on `c` returns the
  `LX` payload `or-miss`. `.8.3.5` later closed the non-repetition matrix; `.8.4` owns REP direct execution.

- 2026-07-04 (RUST-PARITY.8.3.3 — direct AND acode generated execution):
  `GeneratedPlanExecutor` now handles `AndSingleAcode` and `AndAcodeSeq` directly. The important semantic detail is
  ordered AND acode sequence: a non-repetition AND regex/acode rule with multiple regex slots must consume slot 0,
  then slot 1, and so on; matching a later slot early or failing before the sequence is complete returns `undef`
  before the rule exit block. The shared Rust interpreter loop now enforces that same ordered-index contract, so the
  generated path does not become a divergent semantics. The source-emitter matrix locks this with a two-slot AND
  acode case whose second edge returns `and-seq`; stopping after the first regex would return `[]`, not the expected
  payload. `.8.3.4` remains the bcode direct-execution leaf.

- 2026-07-04 (RUST-PARITY.8.3.2 — direct default/OR acode generated execution):
  Generated Rust modules no longer use whole-parser `Engine::execute` for the first direct family slice. After
  `source_emitter` validates `GENERATED_RULES`, it calls `Engine::execute_generated_with_plan(...)`. That path uses
  a runtime-internal `GeneratedPlanExecutor` to run `Default` and `OrAcode` rules directly while preserving the
  interpreter's important invariants: `(rule,pos)` recursion guard, per-invocation entry/local match save/restore,
  lifecycle block order, action-edge `retv` plus scoped `call(child)` results, default-mode repetition, and the
  zero-progress guard. Unsupported generated families intentionally fall back inside the executor until `.8.3.3`
  (AND acode), `.8.3.4` (AND/OR bcode), and `.8.4` (REP) replace those paths.

- 2026-07-04 (RUST-PARITY.8.3.1 — generated family-plan metadata):
  The generated Rust-source path now has a durable rule-family plan before direct handler execution starts.
  `CompiledRule` carries parsed `RuleMode`, and `source_emitter` classifies rules into `Default`, `OrAcode`,
  `AndSingleAcode`, `AndAcodeSeq`, `AndBcode`, `OrBcode`, or `Repetition`. Generated modules embed that
  `GENERATED_RULES` table beside `COMPILED_SPEC_JSON` and validate label/family agreement before running. Execution
  still delegates through `Engine`; `.8.3.2` is the first direct-execution leaf and should use the emitted plan as the
  dispatch contract for default/OR acode before broadening to AND acode and bcode.

- 2026-07-04 (RUST-PARITY.8.3 — non-REP emitter lane split):
  Treat non-repetition generated source as a sequence of separate mechanisms, not one patch. The first code read
  found that `CompiledRule` carries regex/action/blind dispatch tables and `parse_mode`, but not enough parsed
  rule-mode metadata for generated source to distinguish OR-bcode from AND-bcode robustly. The correct sequence is
  now `.8.3.1` mode/family metadata plus generated family-plan emission, `.8.3.2` direct default/OR acode
  execution, `.8.3.3` direct AND acode execution, `.8.3.4` direct AND/OR bcode execution, and `.8.3.5` matrix
  closeout. No Rust source changed in the split.

- 2026-07-04 (RUST-PARITY.8.2 — Rust generated-source scaffold):
  The first Rust source-emitter slice deliberately emits a small generated module that delegates through the
  existing interpreter. `emit_rust_source(&CompiledSpec)` serializes the compiled structural contract into a Rust
  string literal, exposes a generated-source format marker, and builds `parse(input)` around
  `linkedspec_runtime::engine::Engine`. This is not yet direct HandlerIR-family source generation; it proves the
  public emitter API, generated-source dependency boundary, offline temp-crate build path, and runtime equivalence
  for one simple non-recursive case. `.8.3` should replace the delegation for non-REP structural families first,
  keeping this compile/run harness as the fast proof that generated source still builds and executes.

- 2026-07-04 (RUST-PARITY.8.1 — Rust source-emitter lane split):
  Do not start the Rust code-generation emitter as one broad patch. The durable boundary is now explicit:
  Perl's `HandlerVariantEmitter.pm` owns a 10-kind HandlerIR structural contract and currently emits Perl/JSON,
  while Rust's live execution contract is the interpreted `CompiledSpec`/`CompiledRule` model with parsed
  lifecycle `CodeBlock`s plus action/blind dispatch tables. `.8` adds a generated Rust-source path without
  weakening the interpreter or the 88-fixture oracle. The next implementation leaf, `.8.2`, should land only a
  minimal emitter API plus compile/run harness for a simple non-recursive case; non-REP families, REP families,
  and corpus/all-variant integration are separate leaves.

- 2026-07-04 (RUST-PARITY.7.4 — oracle corpus manifest guard):
  Treat `rust/linkedspec-runtime/tests/corpus/manifest.json` as part of the checked-in oracle contract, not a
  convenience file. The generator writes it with the ordered intended case list and case count; the Rust runner
  validates it before running fixtures. Adding, removing, or renaming an oracle case requires regenerating and
  staging both the relevant fixture directory changes and `manifest.json`. A missing directory and a stale extra
  directory are both test failures now. `RUST-PARITY.7` is closed; `.8.1` has since split the source-emitter lane
  and `.8.2` is the next implementation frontier.

- 2026-07-04 (RUST-PARITY.7.3.6 — legacy shipped-spec safety smokes):
  Treat the remaining RTL/plugin/legacy shipped specs as a measured fixture boundary. Green minimal smokes are now
  active for `regdef`, `tablegrep`, `simenv`, `vhdl`, `ds_vhistory`, `pplugin`, and `tkgui`, raising the Rust
  oracle corpus to 88 fixtures. Do not infer broader parity from those fixtures: `pplugin` real subdefs produce
  coderefs that the JSON oracle cannot encode, `tkgui` body output still depends on raw Perl pair-return action
  parsing, `sdce` has capture-slice segmentation divergence, recursive `tablegrep` groups double-report in Rust,
  `simenv` single-line values lose verbatim payloads, VHDL entity port clauses collapse to null, `ds_vhistory`
  branch entries classify as version entries, and `verilog` remains a placeholder with Perl `0` versus Rust `[]`.

- 2026-07-04 (RUST-PARITY.7.3.5 — null-output/spec smoke triage):
  Do not promote every shipped-spec parse smoke into the output oracle. `BNF`, `DT`, `ifelse`, and
  `operators_try` currently behave as diagnostic/debug-print grammars for the probed inputs and the Perl reference
  returns `null`; Rust's empty accumulator is therefore not a meaningful semantic-AST fixture for them. The real
  implementation issue in this leaf was narrower: `operators_try` has debug print strings containing literal
  braces, so Rust's code-block scanner must ignore `{` / `}` inside quoted strings with backslash escapes.
  `spec.spec` is different: minimal rule, action-edge, top-level user-function definition, and comment-skip smokes
  produce stable JSON-safe ASTs and are now active oracle fixtures. The oracle corpus is 81 fixtures after this
  slice.

- 2026-07-04 (RUST-PARITY.7.3.4.3 — action-edge child aggregation parity):
  Action-edge child calls are edge-scoped in the Rust runtime now. When a parent edge has already matched a child
  regex, block/fluent uses such as `call(child)`, `push(child)`, `push(child,target)`, and
  `push(child,target,index)` must consume the dispatched edge result, not run a fresh child search from the
  advanced parent cursor. Passive terminal children are a special case: Perl generated handlers expose the parent
  edge match and return `undef` without scanning again, so Rust skips executing body-less/no-dispatch terminal
  children after parent edge consumption. Keep scalar and aggregate stores distinct when scalar assignments carry
  aggregate-valued child returns; only direct shape RHS values infer aggregate targets. The shipped proofs are
  `portmap_concatenation`, `ebnf_expression_rules`, and `ebnf_logging_annotation`; the oracle corpus is 77
  fixtures after this slice.

- 2026-07-04 (SPEC-FORMAT-TERSE.7.4 — type-method no-drift closure):
  The supported type-method surface is closed for the current lane. Receiver families are string/scalar,
  array/list, hash, and number. Array numeric reducers (`sum`, `avg`, `median`, `range`, `min`, `max`) are terminal
  array/list receiver methods, not scalar number receiver links. Mutation, lifecycle/control, child-dispatch,
  parser-state/capture/input/mark readers, declaration helpers, and compatibility aliases stay explicit function,
  statement, or lifecycle surfaces unless a future task defines type-correct receiver semantics and lands
  Perl/Rust/tests/docs/KM together. No `SPEC-FORMAT-TERSE` leaf is currently pending; PNT returns to
  `RUST-PARITY.8.5` unless a new terse leaf is split.

- 2026-07-04 (SPEC-FORMAT-TERSE.7.3 — array numeric reducer receiver methods):
  Array/list receivers now have terminal numeric reducer methods: `sum`, `avg`, `median`, `range`, `min`, and
  `max`. Keep these in the array receiver family, not the scalar number receiver family. `score.min(3)` remains
  the scalar numeric comparison/min helper shape, while `scores.min()` is the array-form aggregate reducer.
  Reducer terminals must stop array chains: invalid continuations such as `scores.sum().drop_front(1)` return
  `undef`/`null`. On the Perl side, receiver-chain `uniq()` must stay on the pure internal array-pipeline path
  (`__array_value_uniq`) when feeding reducers; public `uniq(array(...))` still has statement/list-context
  behavior in older paths and is not the right lowering for pure receiver composition. Rust mirrors the receiver
  surface and now handles single-array `num_min`/`num_max` helper forms. Phase0 is 1021 green and the oracle corpus
  is 74 fixtures after this slice.

- 2026-07-04 (SPEC-FORMAT-TERSE.7.2 — string/scalar receiver methods verified):
  The string/scalar method backfill leaf required no code. `substr()` is already a receiver method, and focused
  probes show `"abcdef".substr(1, 3).uppercase()` equals `uppercase(substr("abcdef", 1, 3))` (`BCD`) with
  language-agnostic descriptor metadata (`ready=1`, zero fallback/raw/unresolved). The supported pure string
  receiver set is `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`,
  `concat`/`cat`, `coalesce_nonempty`, `split` as the array bridge, and the terminal predicates/length helpers.
  Keep regex-substitution `substr(:target, pattern, replacement, flags)` as a statement mutation, not a pure
  receiver method.

- 2026-07-04 (SPEC-FORMAT-TERSE.7.1 — type-method surface inventory):
  Do not start method backfill by assuming `substr()` is missing: string/scalar receiver-dot support already
  includes `substr` on Perl and Rust. The current receiver families are string/scalar, array/list, hash, and
  number; expression-valued blocks and pure user-function returns dispatch by yielded runtime type into those
  families. Booleans/flow-result values are terminal for now. Keep mutation, lifecycle/control, child-dispatch,
  capture/entry/match/input/mark, declaration, and compatibility-helper surfaces explicit unless a later leaf
  designs safe receiver semantics and updates Perl/Rust/tests/docs/KM together. `.7.3` deliberately added
  terminal array/list receiver aliases for numeric reducers; they remain array-consuming and are not scalar number
  receiver links.

- 2026-07-04 (SPEC-FORMAT-TERSE.6.4 — declaration helpers are legacy compatibility):
  Keep the post-migration boundary strict. `declare(...)` and declaration aliases stay accepted for existing specs,
  but they are not current authoring syntax and should not appear in new shipped specs, public examples, or current
  corpus examples. Do not add new declaration features. Do not remove or hard-diagnose declaration helpers without a
  new focused leaf that updates Perl, Rust, oracle fixtures, mdBook, and Knowledge Map together. The
  `autoexist_*_declare` oracle fixtures remain useful compatibility locks for declare/no-declare convergence.

- 2026-07-04 (SPEC-FORMAT-TERSE.6.3 — docs/corpus terse-surface sweep):
  Keep the `.6.3` boundary explicit. Current-facing mdBook examples and root corpus specs should show terse
  working-variable forms first: `name = value`, `items = []`, direct shape literals, `items += value`,
  `meta[key] = value`, `push(...)`, `copy(...)`, and `cat(...)`. The remaining old spellings are not drift when
  they live in named compatibility locks or legacy/reference pages. In the generated Rust oracle corpus, preserve
  `autoexist_*_declare`, `autoexist_array_bare_arg`, `terse_1_2_3_2_array_copy_bare_read`,
  `terse_1_2_3_2_hash_copy_bare_read`, and the hash receiver-method fixture as deliberate compatibility locks
  after `.6.4`. Also preserve the `merge_hash` lesson: today `merge_hash(base, overlay)` is not equivalent to
  `merge_hash(copy(hash(base)), overlay)`, so examples that intend an overlay merge must keep an explicit
  hash-valued first argument.

- 2026-07-04 (SPEC-FORMAT-TERSE.6.2.4 — shipped-spec no-drift verification):
  Treat the current terse-surface cleanliness boundary precisely. The shipped `specs/*.spec` files now compile and
  scan clean for the retired/currently-forbidden authored surfaces (`scalar(...)`, `assign(...)`, `declare(...)`,
  `.declare(...)`, and old helper spellings), and oracle regeneration is byte-stable over 73 fixtures. The broader
  repository is intentionally not clean yet: root `tests/corpus` fixtures, selected Rust oracle compatibility
  fixtures, and mdBook reference/walkthrough chapters still contain `declare(...)` and older helper references.
  Those are not `.6.2.4` blockers; they are the explicit worklist for `.6.3`, which should separate public
  teaching examples from historical/compatibility references instead of deleting evidence blindly.

- 2026-07-04 (SPEC-FORMAT-TERSE.6.2.3.2 — retired spec-file `scalar(...)` / `assign(...)`):
  The retirement boundary is the authored `.spec` DSL, not generated Perl internals. `scalar(@...)` in generated
  backend Perl remains a normal Perl built-in, while `scalar(name)` is no longer the DSL scalar-slot spelling.
  Perl keeps parser-normalized internal `set(...)` handling distinct from raw authored `assign(...)`, so migration
  can reject the old helper without breaking assignment operators. Bare-kind memory is the key follow-on: direct
  assignment and aggregate mutations record scalar/array/hash intent, `:name` forces scalar-slot reads/targets,
  and later bare reads/copies reuse the remembered kind. Rust mirrors that with `RuntimeVarKind` in
  `RuntimeContext`, so `items = [value]` followed by `return(items)` reads the array and `meta = { key => value }`
  followed by `copy(meta)` reads the hash. Phase0 is 1020 green after the migration.

- 2026-07-03 (SPEC-FORMAT-TERSE.6.2.3.1 — scalar-slot shorthand):
  `:name` is intentionally a scalar-slot expression, not a new aggregate or sigil system. Perl wires it through
  the existing scalar source-slot helper and scalar target extractor, then teaches the autodeclare collector to
  record `:name` as `$name` in value positions and `set(:name, ...)` as an explicit scalar target. Rust keeps the
  boundary visible with a dedicated `Expr::ScalarSlot { name }` AST node; runtime evaluation calls
  `ctx.get_scalar(name)`, and scalar-target resolution treats the raw `ScalarSlot` target as the variable name.
  Direct-shape inference is deliberately unchanged: bare `set(payload, [value])` assigns `@payload`, while
  `set(:payload, [value])` assigns `$payload = [ ... ]`. The oracle corpus now has 73 fixtures including
  `terse_6_2_3_1_scalar_slot_shorthand`, and phase0 is 1019 green.

- 2026-07-03 (RUST-PARITY.7.3.4.2 — portmap scalar helper parity):
  The `portmap` scalar mismatch had three independent runtime causes. First, `or(...)` was missing from Rust's
  helper surface, so `bar[3]` could not take the bit-classification branch; Rust now implements `or`, `and`, and
  `not` using the existing `RuntimeValue` truthiness. Second, Perl lowers `array(flat_array(entry_parts))` in list
  context, so the flattening helper splices into the enclosing constructor; Rust now splices explicit
  `flat`/`flat_array`/`flat_hash` call arguments while keeping `array_copy(...)` nested. Third, `CompiledAlternation`
  joined rule regexes as raw `pat1|pat2`, which let the internal `|(?i)(0x...)` branch inside `bare_bit_slice`
  become a sibling action-edge branch. Wrapping each rule regex as `(?:pattern)` preserves dispatch ownership and
  fixes the constant path. The four scalar `portmap` fixtures are active (`foo`, `bar[3]`, `baz[7:0]`, `0x1f`),
  bringing the oracle corpus to 72 fixtures. Concatenation remains owned by `.7.3.4.3` because it depends on
  action-edge fluent recursive aggregation, not scalar helper/list-context parity.

- 2026-07-03 (RUST-PARITY.7.3.4.4 — lib_reader action-helper parity):
  The `lib_reader` follow-up turned out to be narrower than the leaf title suggested. A focused edge-only
  child-regex test proves dependency-resolved action dispatch already carries child entry captures. The observable
  null/quoted fields in representative `lib_reader` outputs came from statement-form helper mutation drift:
  `substr(scalar(target), pattern, replacement, flags)` is the legacy regex-substitution form in shipped specs, not
  the pure value substring helper, and `split(array(target), scalar(source), delimiter)` is an array-replacement
  statement, not the pure array-valued split. Rust now detects those mutation shapes before value-form helpers,
  updates the target working variable, and keeps pure `substr(value, start, length?)` / `split(value, delimiter)`
  behavior separate. `lib_reader_sattribute` and `lib_reader_cattribute` are now checked-in oracle fixtures, taking
  the corpus to 68 fixtures.

- 2026-07-03 (SPEC-FORMAT-TERSE.6.2.2 — shipped specs old-helper-free):
  The second shipped-spec terse migration removes active old helper spellings without changing alias support.
  `set`, `push`, `copy`, and `cat` are now the shipped-spec source spellings for helper aliases that were already
  portable on Perl and Rust. The main caution was `push(...)`: all-bare `push(A,B)` is still the child-call
  convention, so migrated accumulator appends keep explicit targets such as `push(array(items), value)` where
  ambiguity would otherwise be possible. `portmap.spec` also demonstrates the separator rule directly: standalone
  flow markers do not need trailing semicolons, while real same-line statement separation still uses semicolons.
  Wrappers and constructors are deliberately left for `.6.2.3`; this slice only proves the helper-name migration
  by compiling all shipped specs, keeping phase0 at 1018 green tests, and keeping the Rust oracle corpus green over
  66 fixtures.

- 2026-07-03 (SPEC-FORMAT-TERSE.6.2.1 — shipped specs declare-free):
  The first shipped-spec declaration migration is intentionally narrow. It removes `declare(...)` / `.declare(...)`
  without broadening runtime declaration support and without mixing in the remaining verbose helper families.
  Preserving behavior mostly means choosing the corresponding terse initialization form: scalars use `name = value`
  or `name = undef`, arrays use `items = []`, and old fluent lifecycle chains become structured blocks when later
  operations must remain ordered (`I { value = entry_text(); ...; return(...) }`). Existing wrappers and helper
  names such as `scalar(...)`, `array(...)`, `assign(...)`, `push_value(...)`, `array_copy(...)`, and `concat(...)`
  are deliberately left for `.6.2.2`/`.6.2.3`, so the no-`declare` proof stays crisp: shipped specs compile, phase0
  is 1018 green, and Rust `corpus_oracle` is green over 66 fixtures. The user's broader method-surface directive is
  tracked as `.7`: inventory supported types first, then verify/backfill methods such as string `substr()` before
  code.

- 2026-07-03 (SPEC-FORMAT-TERSE.6.1 — declaration retirement owned):
  The active terse-format gap is not a Rust runtime `declare` initializer problem. The directive is language-surface
  cleanup: `declare(...)` shall not be used in spec files because `.1.1` auto-existing variables, `.1.3` mutation
  forms, `.1.2.3.5` direct RHS shape target-kind inference, and `.3.3` expression-valued assignments already give
  the terse replacements. Inventory before shipped-spec edits found 70 active `declare(...)` hits across 13
  shipped specs. `SPEC-FORMAT-TERSE.6.2` must migrate those specs first; post-migration implementation-support
  policy waits for `.6.4`.

- 2026-07-03 (RUST-PARITY.7.3.4.1 — header-rest action-edge parsing):
  The `lib_reader` top-rule collapse was parser/compiler-owned first. Rust's rule-header scanner captured the first
  non-space token after `:`/`::` as a mode suffix and treated unknown tokens as default mode, which silently dropped
  ordinary header-rest body syntax such as `->`, `->Child.push`, and `I.return(...)`. The parser now accepts only
  recognized mode suffixes as modes and restores unrecognized tokens to the body rest. Edge spacing was corrected at
  the same boundary: `specs/spec.spec` uses `->[ \t]*` and `=>[ \t]*`, so spaces after `->`/`=>` are optional; the
  old Rust `[ \t]+` requirement was implementation drift. `lib_file` now compiles the `group` `.push` dispatch and
  representative probes produce `GROUP` nodes instead of `[[]]`. Their capture fields are still null, which is
  runtime capture propagation for dependency-resolved child regex matches and is now owned by
  `RUST-PARITY.7.3.4.4`; that follow-up is now closed by the statement-form helper mutation work above.

- 2026-07-03 (RUST-PARITY.7.3.4 — structural mismatch triage):
  The `portmap`/`lib_reader`/`ebnf` divergences are not fixture-selection problems. Perl reference probes encode all
  representative outputs cleanly, but the Rust `corpus_oracle` path diverges before any fixture can be safely
  landed. `portmap` shows two runtime gaps: missing boolean helper parity (`bar[3]` warns `unknown helper 'or'`
  and is classified as `?bare:`) and missing list-context splice semantics (`array(flat_array(entry_parts))`
  becomes one nested array too deep); concatenation additionally exposes action-edge fluent recursive aggregation
  (`{foo bar[2]}` -> `[["?multi:",[]]]`). `lib_reader` first belongs to parser/compiler: the shipped
  `lib_file:: -> group .push` header-rest edge is absent from the Rust compiled `lib_file` rule, so top-level
  sattribute/cattribute inputs return `[[]]`. `ebnf` compiles its `.if(...).push(child, rule)...` chains, but the
  runtime duplicates rule headers and drops token payloads, so the first owner is action-edge fluent child/target
  semantics. Work is split into `.7.3.4.1` parser/compiler header-rest edge fix, `.7.3.4.2` runtime
  boolean/list-context parity, and `.7.3.4.3` action-edge fluent aggregation.

- 2026-07-03 (RUST-PARITY.7.3.7 — oracle timeout covers parser build + parse):
  The user-directed timeout re-debug found that a "timeout" can occur before parser execution. A fork+SIGKILL
  census over shipped specs made `BNF` exceed a 5s build+parse wrapper even on empty input. Focused probes showed
  `LinkedSpec::get_parser("BNF")` spends about 6.4s in parser construction, `get_parser("ebnf")` is the same
  slow-build class at about 7.0s, and parsing empty input after the BNF parser exists takes about 0.03s.
  `LINKEDSPEC_TRACE_LEVEL=debug` reaches `Parser generation completed successfully`, so the live issue is the
  oracle guard boundary, not a parser execution hang. `tools/gen_oracle_corpus.pl` now builds the parser and runs
  the parse in the forked child; the parent `ORACLE_TIMEOUT`/`SIGKILL` guard covers both phases. This is the
  permanent guard shape for broad shipped-spec corpus expansion.

- 2026-07-03 (RUST-PARITY.7.3.3.3 — hlink scalar-ref fixtures deferred):
  Bracket/mixed `hlink_substitution` oracle fixtures are not just waiting on a JSON spelling. Perl's reference AST
  uses scalar references for bracket payloads, which `JSON::PP` cannot encode, and current Rust has neither a
  scalar-ref `RuntimeValue` nor working execution for the shipped scalar-ref action branch:
  `return(\(my $capt = capture_slice()))` is rejected by the Rust action parser and `[abc]` falls through to
  unmatched-closing-bracket `exit_now(2)`. Keep `[abc]` and `foo[bar]{baz}` out of the corpus until
  `RUST-PARITY.7.3.3.4` either defines a tagged scalar-ref JSON contract plus Rust support or migrates the hlink
  spec to portable value shapes. PNT advances to `.7.3.4`.

- 2026-07-03 (RUST-PARITY.7.3.3.2 — hlink curly oracle fixture):
  The JSON-safe `hlink_substitution` curly delimiter candidate is now an active oracle fixture:
  `hlink_curly_brace` with input `{abc}` and Perl reference `["{abc}"]`. This was deliberately limited to the
  plain-string path from `.7.3.3.1`; the scalar-ref bracket and mixed hlink cases still need the explicit
  representation decision owned by `.7.3.3.3`. The generator remains under the fork/SIGKILL hard timeout, and
  Rust `corpus_oracle` is green over 66 fixtures without runtime changes.

- 2026-07-03 (RUST-PARITY.7.3.3.1 — hlink delimiter fixture split):
  The remaining `hlink_substitution` delimiter cases split by oracle representability. `{abc}` is JSON-safe and
  can be added as a normal shipped-spec fixture. `[abc]` and mixed `foo[bar]{baz}` return Perl scalar references
  in the reference AST (`[\'abc']` in phase0), and `JSON::PP` refuses scalar refs with `cannot encode reference to
  scalar`. That is an oracle-representation decision, not a Rust-runtime fix to guess inside the curly fixture
  slice. `.7.3.3.2` owns the JSON-safe curly case; `.7.3.3.3` owns scalar-ref canonicalization or explicit
  deferral for bracket/mixed hlink cases.

- 2026-07-03 (RUST-PARITY.7.3.2 — oracle timeout hardening):
  The timeout question split in `.7.3.1` resolved to two facts. First, the historic `RTLUtils`
  catastrophic-backtrack timeout is not live in the current core tree: `perl/RTLUtils.pm`, `perl/FSMGen.pm`, and
  `perl/VHDL/ConstantEval.pm` are absent, and the only current core hits are retirement comments/docs. Second, the
  oracle generator's generic guard was weaker than its documentation: `alarm()` cannot interrupt a catastrophic
  regex opcode. `tools/gen_oracle_corpus.pl` now runs each parser call in a child process, has the child serialize
  its result to JSON, and has the parent enforce `ORACLE_TIMEOUT` with wall-clock wait plus `SIGKILL`. Normal
  regeneration remains byte-stable over 65 fixtures, and `ORACLE_TIMEOUT=0` proves the hard-kill path.

- 2026-07-03 (RUST-PARITY.7.3.1 — batch-2 oracle lane split + timeout owner):
  `RUST-PARITY.7.3` should not be implemented as one broad shipped-spec corpus slice. The current oracle generator
  already has the required hard `alarm(...)` timeout, and the corpus runner is green over 65 fixtures. `.7.2`
  recorded enough concrete divergence evidence to split the remaining batch before touching generator/runtime code:
  make the timeout/hang question first, then keep `hlink_substitution` delimiter/link-path attempts separate,
  triage `portmap`/`lib_reader`/`ebnf` structural mismatches separately, triage `BNF`/`DT`/`ifelse`/
  `operators_try`/`spec.spec` null-output or action-parser-warning candidates separately, and isolate
  RTL/plugin/legacy safety smokes until after the timeout concern is resolved or retired. `TOOLBOX.md` is explicit:
  a true hang uses the fork+SIGKILL hard-timeout census first because `alarm()` cannot interrupt a catastrophic
  regex opcode; trace/debug and parser-source dumps come next on the exact live reproducer. Future `.7.3.*` leaves
  should either land green fixtures or record exact divergence evidence and split a narrower implementation owner
  before changing Rust behavior.

- 2026-07-03 (STAGED-LINKED-PARSING.5.6 — function-body staged prototype proof):
  The first staged linked parsing prototype is now proven end to end rather than merely wired. The proof sample
  exercises four user functions with scalar, multi-param, array-local, and hash-local bodies. Perl descriptor
  tests assert source-order function registry shape, exact `body_payload` text/spans, normalized
  `body_parse_job` paths/job ids, stitched `body_ast` action blocks, runtime output, and dispatch diagnostics
  containing phase, parent AST path, source span, and failure policy. Rust integration tests assert the same
  neutral contract across raw spec-parser AST output, normalized parsed state, compiled function records, runtime
  output, and diagnostics. This closes the first prototype leaf; broad public `parse_job(...)`, provider/import
  search, multiple payload parser families, recursive queues, and cycle diagnostics remain future work. PNT
  returns to `RUST-PARITY.7.3` after commit.

- 2026-07-03 (STAGED-LINKED-PARSING.5.5 — minimal staged parser registry dispatch):
  Function-body parse jobs now execute through an explicit staged registry path instead of direct body-parser
  calls. The first neutral provider supports `parser_spec_id = actionir-body.spec` with `top_rule =
  action_block`: resolve returns `builtin:actionir-body.spec`, load records the adapter contract digest
  `sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c`, compile builds a cache key over
  spec identity/digest/top rule/version/capability fields, and execute returns an `action_block` body AST.
  Dispatch order is parent AST path, source span, then job id. Perl exposes this in
  `LinkedSpec::StagedParserRegistry`; Rust exposes it in `linkedspec-runtime::staged_parser_registry`. General
  public `parse_job(...)` authoring, filesystem/import provider search, and recursive staged queues are still
  future work. Next frontier: `STAGED-LINKED-PARSING.5.6`.

- 2026-07-03 (STAGED-LINKED-PARSING.5.4 — function-body parse-job sidecar):
  Function-definition ASTs now have two separate staged records. `body_payload` remains the exact neutral text
  island with provenance. `body_parse_job` is the parse-intent sidecar for that text island: `kind = parse_job`,
  deterministic job id, parent AST path, `parser_spec_id = actionir-body.spec`, `top_rule = action_block`,
  `result_policy = replace_field`, `result_field = body_ast`, `failure_policy = fail`, exact text, source span,
  and diagnostic owner. The direct spec parser emits a source-order pending path; the Perl registry and Rust
  adapter normalize that path and job id after function ordinal assignment. The sidecar is preserved in Perl
  descriptors and Rust parsed/compiled function state; `.5.5` now dispatches the function-body job through the
  minimal staged registry path.
  Next frontier after `.5.4`: `STAGED-LINKED-PARSING.5.5`.

- 2026-07-02 (STAGED-LINKED-PARSING.5.3.2 — Rust consumes spec-defined user-function definition AST):
  Rust now follows the same definition-shell ownership rule as Perl: `specs/user_function_definition.spec` is the
  executable grammar owner for top-level `fn name(params) { body }` definitions. The old Rust core parser no
  longer raw-scans `fn` declarations; runtime `spec_parser` executes the spec parser first, validates returned
  `function_definition` / `function_definition_error` nodes, strips their exact source spans, then feeds the
  remaining rule-only source to the core parser. `body_payload` survives into `CompiledUserFunction` for the later
  staged parse-job work.
  Debugging points that should not be re-derived: (1) composed RGX alternations must scope leading inline flag
  toggles such as `(?m)` per alternative, or line-anchored branches can drift; (2) regex-literal delimiters in
  `.split(/\s*,\s*/)` must execute as regex splits, not literal string splits; (3) compact lifecycle chains with
  multiline arguments, for example `I.return({ ... })`, must collect continuation lines before lowering; (4)
  dispatched child rules set the anonymous capture cursor at entry end so `capture_slice()` returns the island
  after the opener; (5) self-recursive close/finalizer edges such as `-> function_definition[1] { return(...) }`
  run their block directly unless the block explicitly calls the rule, otherwise the runtime can seek to a later
  close and consume too much.
  Next frontier: `STAGED-LINKED-PARSING.5.4`.

- 2026-07-02 (STAGED-LINKED-PARSING.5.3.1 — spec-defined user-function definition AST):
  User-function definition parsing now has an executable spec-owned reference. `specs/user_function_definition.spec`
  parses the `fn name(params) { body }` shell and returns `function_definition` AST nodes with exact source/body
  text, spans, provenance, parsed params, arity, and a neutral `body_payload`. The new spec uses direct shape
  literals and receiver/bare-variable forms, not `declare(...)`, `array(...)`, `scalar(...)`, `hash(...)`, or
  `scalaref(...)`. It uses a linked opener/closer shell for the outer function body and linked body-island rules
  for nested braces, strings, comments, and regex literals. Generated-handler debug showed `body_brace` can start
  only on `{`, while `function_definition[1]` owns the outer `}` close edge; focused tests lock adjacent nested
  braces and unbalanced nested-body diagnostics. The Perl registry bridge now consumes that returned AST,
  validates its shape, post-annotates the source-order parent path, and strips function definitions before
  bootstrap parsing; the previous raw Perl scanner functions are gone. Runtime execution is unchanged: function
  bodies still run through the existing ActionIR body parser after the definition AST is returned. The uncommitted
  Rust body-payload/raw-parser expansion was removed from this slice; the remaining Rust host-language
  function-definition bridge is now the next explicit retirement frontier.
  Next frontier: `STAGED-LINKED-PARSING.5.3.2`.

- 2026-07-02 (STAGED-LINKED-PARSING.5.2 — function-definition AST-shape audit):
  The function-body prototype seam is now audited before code. Durable points. (1) **Harness shape.** A direct
  top regex rule cannot read its own captures through `entry_group(...)`; focused AST tests need a tiny wrapper
  top rule that dispatches to a normal `function_definition` rule and returns collected nodes from `LX`. (2)
  **Current self-hosted rule gaps.** The current `specs/spec.spec` rule uses numbered captures across an optional
  parameter list, so zero-arg functions compact captures and mis-shape as `params = body`, `body = null`. It also
  does not protect regex literals containing braces, so `/}/` truncates and `/{/` can miss the body. (3) **Bridge
  divergence.** Perl stores exact inner body text and byte spans; Rust trims `body_source` and stores line spans.
  The staged contract must define neutral provenance instead of copying either shape. (4) **Target AST.** ADR
  `0017` defines the expected function-definition node: `type`, `name`, `params`, `arity`, `source_text`,
  `source_span`, exact inner `body_source`, `body_span`, `body_parse_job`, and stitched `body_ast` after dispatch.
  (5) **Variation matrix.** The proof must cover zero/one/many params, whitespace, functions before/between rules,
  nested braces, quoted braces, escaped quotes, regex-brace bodies, adjacency, malformed definitions, duplicates,
  collisions, and reserved names.
  Next frontier: `STAGED-LINKED-PARSING.5.3`.

- 2026-07-02 (STAGED-LINKED-PARSING.5.1 — prototype split and payload selection):
  The broad prototype leaf is now split before code. Durable points. (1) **First payload family.** The prototype
  targets user-defined function body text because `specs/spec.spec` already extracts `fn name(args) { body }` as a
  bounded text island, and the current Perl/Rust bridges give a concrete behavior contract to preserve while the
  staged path replaces bridge debt. (2) **Neutrality is a gate.** ADR `0016` makes every staged artifact
  implementation-language neutral: `.spec` syntax, AST metadata, source provenance, parse jobs, dispatch/cache
  identity, diagnostics, fixtures, and docs are the contract; backend loaders/callbacks/internals are adapters. (3)
  **Implementation split.** Follow-up leaves are a seam audit, provenance plumbing, parse-job sidecar prototype,
  minimal registry/dispatch path, and end-to-end function-body proof with parity gates. Current shipped parsers do
  not yet implement staged dispatch. (4) **AST-shape oracle.** The seam audit must predict the returned
  `function_definition` AST shape before implementation, and the proof leaf must test that shape directly rather
  than relying only on runtime behavior. (5) **Variation-heavy rule tests.** The spec-file rule that returns the
  user-function AST needs broad coverage across function-definition variations: whitespace, arity, nested bodies,
  strings, regex-looking text, adjacency, and malformed definitions where applicable. A dedicated small spec
  file/top rule should be used for focused AST-shape tests instead of relying only on the whole `specs/spec.spec`
  parser.
  Next frontier: `STAGED-LINKED-PARSING.5.2`.

- 2026-07-02 (STAGED-LINKED-PARSING.4 — parser registry/dispatch contract):
  Dynamic staged dispatch now has a design contract before implementation. Durable points. (1) **Registry
  operations.** Backends expose neutral `resolve`, `load`, `compile`, and `execute` operations rather than
  host-language loaders. (2) **Resolution order.** A parse job resolves through parent import aliases/composed
  identities, declaring-spec-relative paths, configured search roots, then registry providers, all in declared
  order; missing/ambiguous/colliding resolutions diagnose. (3) **Cache identity.** Cache keys include normalized
  spec identity, content digest, import/include graph fingerprint, top rule, `.spec` language version,
  helper/action contract version, staged parsing contract version, and backend capabilities. (4) **Stable queue.**
  Collect jobs after a stage parse; order by parent AST path, source span, and job id; execute/stitch in that
  order; enqueue newly emitted jobs at the next depth. (5) **Cycle guard.** Active-chain repeats of normalized
  spec identity, top rule, payload digest, and source span are hard diagnostics. Current shipped parsers do not
  yet implement the staged registry/dispatch queue.
  Next frontier: `STAGED-LINKED-PARSING.5`.

- 2026-07-02 (STAGED-LINKED-PARSING.3 — parse-job annotation contract):
  Parse-job marking now has a design contract before implementation. Durable points. (1) **Authoring marker.**
  Future `.spec` code uses `parse_job(text_expr, options)` to mark extracted text for later parsing. Current
  shipped parsers do not yet accept or execute that helper. (2) **Sidecar metadata, not user payload.** The marker
  can appear in the AST, but scheduling metadata lives in a neutral sidecar to avoid collisions with user fields.
  Required metadata: deterministic job id, parent AST path, node kind, payload kind, exact text, source span or
  provenance list, parser spec id, optional top rule, result policy, and failure policy. (3) **Source provenance is
  mandatory.** Text derived from entry/capture helpers must retain corresponding spans; constructed text must carry
  provenance rather than silently losing attribution. (4) **Policies are explicit.** Result policies:
  `replace_marker`, `replace_field`, `sibling_field`, `append_child`. Failure policies: `fail`, `keep_text`,
  `diagnostic_node`. (5) **Neutrality.** This is a `.spec`/AST/diagnostic contract, not a Perl/Rust callback
  mechanism; Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, and future implementations inherit the same schema.
  Next frontier: `STAGED-LINKED-PARSING.4`.

- 2026-07-02 (STAGED-LINKED-PARSING.2 — spec import/composition contract):
  Spec-file composition now has a design contract before implementation. Durable points. (1) **Syntax is
  file-scope.** Future `.spec` source uses `import "path.spec" as alias` for qualified grammar reuse and
  `include "path.spec"` for structured unqualified composition. Current shipped parsers do not yet accept either
  directive. (2) **Import is not dispatch.** Imports/includes compose parsed grammar material; staged parse jobs
  parse runtime text payloads extracted into AST nodes. Keep diagnostics and descriptors separate. (3)
  **Structured, not textual.** `include` is a parsed-spec merge with preserved source provenance, not raw
  concatenation. (4) **Determinism.** Resolve relative to the containing spec, then configured search roots or
  registry identities in declared order; duplicate aliases/rules, ambiguous unqualified references, missing specs,
  and cycles are hard diagnostics. (5) **Neutrality.** The directive graph, namespace rules, cycle diagnostics,
  and dependency fingerprints are specified over `.spec` identities and content digests, not host-language module
  loaders. Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, and future implementations inherit the same contract.
  Next frontier: `STAGED-LINKED-PARSING.3`.

- 2026-07-02 (STAGED-LINKED-PARSING.1 — architecture doctrine):
  User clarified the architectural identity behind the project name: LinkedSpec is not just a compact grammar DSL;
  it is a staged parser-composition model. Durable points. (1) **Parse what is easy now.** A stage should consume
  reliable high-level anchors and extract bounded text islands when their inner grammar would make the outer stage
  brittle. (2) **Link stages through parse jobs.** The AST should carry payload text, source span, payload kind,
  parent path, parser identity/top-rule intent, insertion policy, and failure policy so a later spec can refine the
  payload into deeper AST. (3) **One stage can fan out.** Stage N does not imply one stage-N+1 grammar; different
  payload kinds can route to different next specs. (4) **Imports are not dispatch.** Spec imports/composition
  reuse grammar material; staged dispatch parses runtime payload text. Keep diagnostics distinct. (5)
  **Language-neutral always.** This must be specified over `.spec`, AST, descriptors, parse jobs, and diagnostics,
  not Perl/Rust mechanics; Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, and future implementations inherit the
  same contract. (6) **`specs/spec.spec` first.** For `.spec` language evolution, `specs/spec.spec` is the first
  authoritative grammar; permanent syntax should derive from that staged/self-hosted path rather than bootstrap.
  Next frontier: `STAGED-LINKED-PARSING.2` when this architecture track resumes.

- 2026-07-02 (RUST-PARITY.7.2 — first shipped-spec oracle batch after scalaref retirement):
  The corpus expansion found and closed two Rust parity seams before adding only green fixtures. Durable points.
  (1) **Header-rest must not be a second parser.** The old Rust inline-rest parser had its own narrow element
  recognizers, so compact shipped forms such as `raw_string: /.../ I.return(entry_text())` and multiline
  header-rest blocks could be parsed differently from identical body-line forms. `parse_inline_body` now delegates
  to `parse_single_element`, and any block it consumes advances the following body collection start. (2) **Capture
  helper lists are captures-only.** Perl's helper contract is not regex-library group numbering: `entry_group(0)`
  / `match_group(0)` read the first participating capture, not the full match. Rust now stores both the internal
  regex group layout and the LinkedSpec helper projection; helpers use the compacted capture projection while
  `entry_text()` / `match_text()` read the full match from spans. Optional captures that did not participate drop
  out; participating empty captures stay present. (3) **First clean shipped-spec batch is small on purpose.** The
  two accepted fixtures are `hlink_substitution` raw-string paths. Broader candidates (`portmap`, `lib_reader`,
  `ebnf`, `BNF`, `DT`, `ifelse`, `operators_try`, and `spec.spec` smokes) still expose structural output gaps and
  stay for `.7.3`/later. (4) **Book already had the contract.** The mdBook helper catalog and regex chapter already
  say numbered groups are 0-based, captures-only, compacted, and that whole match text comes from
  `entry_text()`/`match_text()`, so no public-book edit was required.
  Next frontier: `RUST-PARITY.7.3`.

- 2026-07-02 (SCALAREF-RETIREMENT.5 — closed scalaref retirement tree):
  Final no-drift sweep complete. Durable points. (1) **Root corpus cleaned.** The older language-neutral
  `tests/corpus/lispish` and `tests/corpus/tablegrep` examples now use direct nested access (`retv["content"]`,
  `retv["type"]`) and compile through `LinkedSpec::Get`. (2) **Current-facing prose reconciled.** Roadmap,
  architecture, method-like DSL, Rust parity, and KM wording now treats `scalaref(...)` as historical/retired
  rather than active support. (3) **Residual active uses intentional.** Active scans across shipped specs, root
  corpus, Rust corpus, mdBook, user guide, generator, sources, and tests find only the focused negative locks.
  `tools/run_ci_local.sh` passes with phase0 1015 green. (4) **PNT handoff.** `SCALAREF-RETIREMENT` is closed;
  resume at `RUST-PARITY.7.2`.

- 2026-07-02 (SCALAREF-RETIREMENT.4 — removed scalaref implementation support):
  `scalaref(...)` is now retired in implementation, not just migrated out of examples. Durable points. (1)
  **Perl surface removed.** `ValueExpr` no longer exposes `_lower_scalaref_value_expr(...)`; MethodLowering no
  longer accepts function-form `scalaref(...)` or receiver-dot `.scalaref(...)`; FlowExpr and return-payload
  helper whitelists no longer treat it as a value helper. The surviving path parser was renamed to
  `_split_nested_access_path_segments(...)` / `_lower_nested_access_segment_expr(...)` because it now serves only
  direct nested access. (2) **Rust surface removed.** `ScalarRefPath`, the special second-argument parser hook,
  validation support, runtime path evaluation, and the helper dispatch arm are gone. (3) **Failure policy.**
  Perl focused lowering reports the existing unsupported-helper sentinel for both function-form and receiver-dot
  uses; Rust unknown-helper evaluation returns `undef`/JSON `null`. (4) **Positive path.** Direct access such as
  `retv["content"]` and named working-hash reads through `scalar(hash(meta), key)` remain the canonical
  replacement contract.
  Next frontier: `SCALAREF-RETIREMENT.5` final drift sweep and tree close-out.

- 2026-07-02 (SCALAREF-RETIREMENT.3 — migrated scalaref live surface):
  The shipped/live surface no longer depends on the helper. Durable points. (1) **Direct-access function-form
  migration.** Shipped spec paths now use `retv["content"]`, `retv[0]`, `first_capt[0]`, and mixed
  `retv["children"][i]["name"]` forms; checked-in oracle inputs were regenerated and expected JSON stayed stable.
  (2) **Flow lowering gap closed.** Perl `FlowExpr` must consult `_lower_direct_nested_access_value_expr(...)`
  before falling back inside `is_defined`, `is_undefined`, `is_empty`, and composite flow expressions; otherwise
  direct-access replacements compile in value contexts but not flow contexts. (3) **Receiver-dot replacement.**
  Working-hash field reads use `scalar(hash(name), key)`. Direct bracket reads are only for scalar hashref
  payloads, for example `retv["key"]` or a scalar variable intentionally holding a hashref. (4) **Rust parity
  support.** Rust `scalar(hash_expr, key)` now reads from `RuntimeValue::Hash`, which keeps named-hash-temp
  replacements executable. (5) **Removal ordering.** Implementation recognition for `scalaref(...)` intentionally
  remained until `SCALAREF-RETIREMENT.4`, which has since removed it.
  Verification: phase0 1015 PASS, Rust corpus oracle PASS over 63 fixtures, mdBook build PASS, active
  `scalaref(` / `.scalaref(` scans clean on shipped specs/corpus/docs/tests/tools. Next frontier:
  `SCALAREF-RETIREMENT.4`.

- 2026-07-02 (SCALAREF-RETIREMENT.2 — scalaref retirement inventory contract):
  The inventory is complete enough to migrate. Durable points. (1) **Function form.** Shipped specs use
  `scalaref(base, path)` only as a scalar-held hash/array field read; direct nested access is the canonical
  replacement (`retv["content"]`, `retv[0]`, `retv["children"][0]["name"]`). Quote former `{field}` names. (2)
  **Receiver-dot form.** `.scalaref(key)` is the same user-facing helper name and is in retirement scope. Named
  working hashes can use `scalar(hash(meta), key)`. Direct bracket reads such as `retv["key"]` are for scalar
  hashref payloads, not named working-hash value reads. Expression receivers such as
  `meta.merge_hash(...).scalaref("a")` need an explicit named working-hash temporary before the field read. (3)
  **Implementation ordering.** Do not remove Perl/Rust support until `.3` migrates shipped specs, oracle fixtures,
  tests, and public docs. (4) **Counts.** Current shipped specs have 16 function-form calls; mdBook/user-guide
  examples have 332 function-form references; receiver-dot examples/tests exist in the hash receiver-chain slice.
  Next frontier: `SCALAREF-RETIREMENT.3`.

- 2026-07-02 (SCALAREF-RETIREMENT.1 — scalaref retirement ownership):
  `scalaref(...)` is now explicitly removal-bound, not merely legacy. Durable points. (1) **Separate owner.**
  `SCALAREF-RETIREMENT` owns the user directive to retire/remove the helper, separate from `RUST-PARITY.7.5.2`
  which restored current shipped Lispish parity. (2) **No behavior change yet.** This slice only creates the
  ownership track and live retrieval facts; current Perl/Rust behavior remains intact. (3) **Next proof step.**
  `.2` must inventory every `scalaref(...)` use across shipped specs, tests, docs, oracle fixtures, and
  implementation code before any spec migration or parser/runtime deletion. (4) **Expected destination.** Direct
  nested access is the likely replacement where it can express the current path reads; any remaining gap tied to
  Perl-shaped hash/object literal spelling must be named before removal.
  Next frontier: `SCALAREF-RETIREMENT.2`.

- 2026-07-02 (RUST-PARITY.7.5.2 — Lispish scalaref parity):
  Lispish is now active in the Rust oracle corpus. Durable points. (1) **Scoped legacy parser hook.** Rust adds
  `Expr::ScalarRefPath` only for `scalaref`'s second positional argument, preserving the existing meaning of
  ordinary brace expressions and hash literals. Bare path atoms such as `{content}` are literal legacy field
  names; explicit expressions such as `{scalar(k)}` and `[scalar(i)]` still evaluate. (2) **Return containment.**
  Child dispatch and `call(child)` now route child returns through the return channel without leaking child
  accumulator events into the parent accumulator. This updates the old `.5.1` additive-return model for child
  invocation boundaries while preserving top-level `execute()` accumulator output. (3) **Lispish action shape.**
  Generated Perl for Lispish uses action blocks that call the child inside the block, so Rust now skips automatic
  pre-dispatch when an attached action block explicitly calls the same child. (4) **Aggregate wrapper assignment.**
  `assign(array(word), array())` and matching hash wrapper assignments replace the aggregate working store rather
  than scalarizing the RHS. (5) **Compatibility boundary.** `scalaref(...)` and the existing Perl-shaped hash
  literal spelling are restored here only for shipped-surface Rust parity; both are legacy compatibility surfaces
  slated for retirement/removal under a separate task-tree-owned migration. The oracle corpus is now 63 fixtures,
  including `lispish_x_y`.
  Next frontier: `RUST-PARITY.7.2`.

- 2026-07-02 (RUST-PARITY.7.5.3 — action-edge fluent closure reconciliation):
  No Rust runtime code was needed for this slice. Durable points. (1) **Closure evidence.**
  `SPEC-FORMAT-TERSE.2.3.3.1` added action-edge fluent metadata and no-arg `.push` / `.return(...)` /
  `.return_undef`; `.2.3.3.3.2` completed explicit-target and flow-control action-edge continuations; and
  `.2.3.3.3.3.1` fixed the separate `tclite` default-mode repetition / child-preamble-return gap. (2)
  **Corpus evidence.** `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures, and the
  current 62-fixture Rust corpus oracle passes. (3) **Task-tree repair.** `RUST-PARITY.7.5.3` is marked done,
  `.7.5.2` is the remaining `.7.5` frontier for Lispish `scalaref(retv, {content})`, and `.7.2`/`.7.3` stay
  blocked until that shipped-spec gap is resolved. (4) **Docs.** The corpus README and live recovery docs no
  longer describe `tclite` as deferred behind fluent continuations.
  Next frontier: `RUST-PARITY.7.5.2`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.3.4 — assignment-expression closure):
  The parent assignment-expression contract is closed. Durable points. (1) **Closure fixture.** One portable
  Perl/Rust fixture composes scalar assignment, `=(...)`, canonical `set(...)`, legacy `assign(...)`,
  user-function body assignment, direct RHS array/hash shape assignment, array append snapshot values,
  hash-index snapshot values, aggregate snapshot reads, and receiver-chain terminals. (2) **Docs policy.**
  Public examples now prefer `set(...)` or operator assignment; `assign(...)` stays only as a documented legacy
  alias with current value semantics. (3) **Status repair.** Function-track parent containers are marked done
  now that their child leaves and `.4.4` finalization are complete. (4) **Gate.** Focused locks, oracle corpus,
  mdBook, Knowledge Map, memory/doctrine/diff, and full local CI gates pass; phase0 is now 1015 tests and the
  oracle corpus is 62 fixtures.
  Next frontier at that time: no concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf remained immediately after this
  closure.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.3.3 — mutation assignment expression values):
  Array append and hash-index mutation operators now have expression values. Durable points. (1) **Value
  contract.** `items += value` mutates the named array and yields the updated array snapshot; `meta[key] =
  value` mutates the named hash and yields the updated hash snapshot. The snapshot choice matches `.3.3.2`
  aggregate assignment values and makes receiver chains useful. (2) **Composition.** The forms compose in helper
  arguments, `return(...)`, expression-valued blocks, and receiver chains such as `(items += value).count()` and
  `(meta[key] = value).count_keys()`. (3) **Perl lowering.** AST assignment-value lowering emits scoped `do { ... }`
  mutation expressions and the auto-declaration collector records `@target` / `%target` plus scalar key/RHS
  reads. (4) **Rust parity.** Rust expression evaluation now handles `AssignArrayAppend` and
  `AssignHashIndex`, and the parser accepts parenthesized mutation receivers for fluent chains. (5) **Gate.**
  Focused locks, oracle corpus, full phase0, mdBook, Knowledge Map, memory/doctrine/diff, and full local CI gates
  pass; phase0 is now 1014 tests and the oracle corpus is 61 fixtures.
  Next frontier at the time: `SPEC-FORMAT-TERSE.3.3.4` (now done; no concrete `SPEC-FORMAT-TERSE`
  PNT-eligible leaf remained immediately after that closure).

- 2026-07-02 (SPEC-FORMAT-TERSE.3.3.2 — aggregate assignment expression values):
  Direct RHS shape assignments now return assigned aggregate values after target-kind inference. Durable points.
  (1) **Value contract.** `items = [value]`, `set(items,[value])`, `=(items,[value])`, and matching
  `array(items)` targets store and yield the assigned array; `meta = { key => value }`,
  `set(meta,{ key => value })`, and matching `hash(meta)` targets store and yield the assigned hash. (2) **Scalar
  boundary.** `set(scalar(payload), [value])` stores the whole shape payload in the scalar and yields that
  payload, not an aggregate working variable snapshot. (3) **Perl declaration guard.** Value-position aggregate
  assignments record `@`/`%` targets from the AST without treating ordinary helper arguments like
  `array_copy(items)` as `$items`. (4) **Rust parity.** `Expr::AssignScalar` and `set`/`assign`/`=` helper calls
  now route direct shapes through target-kind assignment and return the stored aggregate value. (5) **Gate.**
  Focused locks, oracle corpus, full phase0, mdBook, Knowledge Map, memory/doctrine/diff, and full local CI gates
  pass; phase0 is now 1013 tests and the oracle corpus is 60 fixtures.
  Next frontier: `SPEC-FORMAT-TERSE.3.3.3`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.3.1 — scalar assignment expression values):
  The scalar assignment-expression subset is now implemented. Durable points. (1) **Value contract.**
  `name = value`, `=(name,value)`, scalar `set(name,value)`, and scalar `assign(name,value)` store into the
  scalar target and yield the stored scalar value. (2) **Composition.** The forms compose in return payloads,
  helper arguments, expression-valued blocks, exact-arity user-function bodies, and compatible scalar receiver
  chains such as `=(raw, " hi ").trim()`. (3) **Boundary.** Direct RHS shape values were intentionally deferred
  so `.3.3.2` could preserve target-kind inference for arrays/hashes; array append and hash-index mutation values
  later landed in `.3.3.3`. (4) **Perl lowering guard.** Multi-argument `array(...)` only lowers direct scalar payloads
  needed by this slice; nested aggregate wrapper calls such as `count(array(items))` stay source-shaped to
  preserve `.2.3.5.6` quoted-wrapper behavior. (5) **Gate.** Focused Perl/Rust locks, oracle corpus, phase0,
  mdBook, Knowledge Map, memory/doctrine/diff, and full local CI gates pass; phase0 is now 1012 tests and the
  oracle corpus is 59 fixtures.
  Next frontier at the time: `SPEC-FORMAT-TERSE.3.3.2` (now done).

- 2026-07-02 (SPEC-FORMAT-TERSE.3.3 — expression-valued assignment split):
  The assignment-expression destination contract is now split before code. Durable points. (1) **Destination.**
  `target = value` is canonical, `=(target,value)` is the planned ordinary operator-call equivalent, and legacy
  `assign(target,value)` is migration debt rather than preferred new syntax. (2) **Expression value.** The
  value contract is the value stored after assignment and target-kind inference. (3) **Current behavior.**
  TOOLBOX probes confirm today is still statement-only: `name = "ok"; return(name)` runs, but value-position
  `return(name = "ok")`, `return(=(name,"ok"))`, `return(set(name,"ok"))`, and nested assignment helper args do
  not yet produce values. Rust expression evaluation still rejects scalar assignment, array append, and
  hash-index assignment as statement-only. (4) **Split order.** `.3.3.1` owns scalar assignment expression
  values and scalar `=(...)`; `.3.3.2` owns aggregate assignment expression values after target-kind inference;
  `.3.3.3` owns append/hash-index mutation expression contracts; `.3.3.4` owns compatibility/docs/oracle
  closure. (5) **Docs.** The book now states assignment/mutation forms are statement-level today and avoids
  promoting `assign(...)` in new examples.
  Next frontier: `SPEC-FORMAT-TERSE.3.3.1`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.2.3.4 — numeric comparison symbol callees):
  The comparison symbol-call surface is now complete. Durable points. (1) **Symbols.** `==`, `!=`, `>`, `>=`,
  `<`, and `<=` parse as ordinary value-call callees and normalize to `num_eq`, `num_ne`, `num_gt`, `num_ge`,
  `num_lt`, and `num_le` on Perl and Rust. (2) **Parser boundary.** Rust argument parsing now only treats
  `name=expr` as a keyword argument when a real identifier exists before `=`, so `==(...)` is not split as an
  empty keyword argument. (3) **Deferred assignment.** Single `=(target,value)` is still rejected/not parsed as
  a helper call; expression-valued assignment remains `.3.3`. (4) **Compatibility.** Slash regex literals and
  arithmetic slash calls keep the `.3.2.2` behavior, `str_*` remains the lexical string family, and `=>`
  remains a blind-call edge. (5) **Gate.** Focused Perl/Rust locks, oracle corpus, phase0, mdBook, Knowledge
  Map, memory/doctrine/diff, and full local CI gates pass; phase0 is now 1011 tests and the oracle corpus is 58
  fixtures.
  Then-frontier: `SPEC-FORMAT-TERSE.3.3` (now split/done; current frontier is `.3.3.1`).

- 2026-07-02 (SPEC-FORMAT-TERSE.3.2.3.3 — numeric comparison word aliases):
  The comparison-word flip is now complete. Durable points. (1) **Names.** Bare value-call `eq`, `ne`, `gt`,
  `ge`, `lt`, and `le` now normalize to `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl
  and Rust. (2) **String bridge.** Lexical string comparisons must use explicit `str_eq`, `str_ne`, `str_gt`,
  `str_ge`, `str_lt`, and `str_le`; shipped specs/tests with lexical bare comparisons were migrated to that
  bridge. (3) **Fallback boundary.** Owned word-call shapes lower/dispatch without raw helper residue while
  explicit `num_*` helpers and receiver numeric terminals remain stable. (4) **Still pending.** Numeric
  comparison symbol callees `==`, `!=`, `>`, `>=`, `<`, and `<=` remain `.3.2.3.4`; assignment `=(...)`
  remains `.3.3`. (5) **Gate.** Focused Perl/Rust locks, oracle corpus, phase0, mdBook, Knowledge Map,
  memory/doctrine/diff, and full local CI gates pass; phase0 is now 1010 tests and the oracle corpus is 57
  fixtures.
  Next frontier: `SPEC-FORMAT-TERSE.3.2.3.4`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.2.3.2 — explicit string comparison helpers):
  The bridge family is now implemented, not just contracted. Durable points. (1) **Names.** `str_eq`,
  `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` are shipped two-argument lexical string predicates on
  Perl and Rust. (2) **Perl lowering.** Flow/value lowering maps those names to Perl string comparison
  operators and emits scoped generated-source temps, so generated handlers do not retain raw `str_*` helper
  calls. (3) **Rust dispatch.** Validation reserves the names and runtime helper dispatch string-coerces both
  operands before evaluating the matching comparison. (4) **Compatibility.** Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le`
  remain runnable string-comparison aliases until `.3.2.3.3` flips ordinary word calls to numeric aliases;
  comparison symbol callees remain `.3.2.3.4`. (5) **Gate.** Focused Perl/Rust locks, oracle corpus, phase0,
  mdBook, Knowledge Map, memory/doctrine/diff, and full local CI gates pass; phase0 is now 1009 tests and the
  oracle corpus is 56 fixtures.
  Next frontier: `SPEC-FORMAT-TERSE.3.2.3.3`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.2.3.1 — string comparison bridge contract):
  The explicit bridge before comparison-word numeric aliases is now locked. Durable points. (1) **Bridge names.**
  `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` are the accepted explicit string comparison
  helpers. They preserve the existing lexical/string semantics of today's bare `eq`/`ne`/`gt`/`ge`/`lt`/`le`
  flow/helper predicates. (2) **Not shipped yet.** This leaf intentionally does not implement those names; the
  book describes them as accepted bridge names but warns not to use them in runnable specs until `.3.2.3.2`.
  (3) **Migration guard.** Bare comparison words cannot flip to numeric aliases until the `str_*` family exists
  and repo-owned string examples/tests either move to `str_*` or keep explicit compatibility coverage. (4)
  **Boundary.** No numeric-word alias, receiver-dot, symbol-callee, parser, compiler, or runtime behavior
  changed in this slice. (5) **Gate.** Focused comparison-owner syntax, mdBook, Knowledge Map, memory,
  doctrine, diff, and full local CI gates pass; phase0 remains 1008 tests.
  Next frontier: `SPEC-FORMAT-TERSE.3.2.3.2`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.2.3 — comparison call surface split):
  Comparison operator calls are now owned as a split migration, not a single implementation leaf. Durable
  points. (1) **Current behavior stays unchanged.** `num_eq`/`num_gt` and receiver terminals such as
  `score.gt(3)` are numeric comparisons; bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` remain string comparisons in the
  documented flow/helper contexts; comparison symbols are not implemented yet. (2) **Destination contract.**
  The future numeric comparison call surface is ordinary `callee(args)` form with word and symbol pairs:
  `eq`/`==`, `ne`/`!=`, `gt`/`>`, `ge`/`>=`, `lt`/`<`, and `le`/`<=`, all mapping to `num_*`. (3)
  **Compatibility bridge.** The explicit string family is `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`,
  and `str_le`; those must land before bare comparison words flip to numeric aliases. (4) **Split order.**
  `.3.2.3.1` locks the bridge contract, `.3.2.3.2` implements string helpers, `.3.2.3.3` flips word calls,
  and `.3.2.3.4` adds symbol callees. `=(target,value)` stays `.3.3`; `=>` stays the blind-call edge.
  Then-frontier: `SPEC-FORMAT-TERSE.3.2.3.1`; current frontier after the word-alias implementation is
  `SPEC-FORMAT-TERSE.3.2.3.4`.

- 2026-07-02 (SPEC-FORMAT-TERSE.3.2.2 — arithmetic symbol callees):
  Arithmetic symbol calls are now a real portable helper-call surface, not host-language fallback. Durable points.
  (1) **Call shape.** `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` parse as ordinary call expressions and
  map to `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod` on Perl and Rust. (2) **Slash disambiguation.**
  `/(` is treated as division only when a balanced argument list and safe call boundary are present; slash regexes
  still win for regex literals, including escaped-paren and lookbehind-close-brace forms. (3) **No precedence.**
  Symbol callees are function calls, so grouping is explicit: `+(2, *(3,4))`, not infix precedence. (4) **Gate.**
  Phase0 passes with 1008 tests, Rust corpus oracle passes with 55 fixtures, Rust core passes, and the focused
  Rust `.3.2.2` integration lock passes, and full local CI passes. The full runtime integration binary still has unrelated stale
  short-wrapper alias failures from the earlier `s/a/h` retirement baseline; the `.3.2.2` test in that binary is
  green.
  Then-frontier: `SPEC-FORMAT-TERSE.3.2.3`; current frontier after the word-alias implementation is
  `SPEC-FORMAT-TERSE.3.2.3.4`.

- 2026-07-02 (SPEC-FORMAT-TERSE.4.4 — function surface finalization ledger):
  The user-function MVP is now closed as a portable Perl/Rust contract rather than an open-ended syntax family.
  Durable points. (1) **Accepted surface.** Top-level `fn name(args) { ... }` is the only accepted definition
  spelling; parentheses are explicit for every arity, including `fn name() { ... }`; bodies are braced and
  value-oriented; calls compose as values, receiver-chain receivers, and standalone discarded statements. (2)
  **Deferred features.** Alternate spellings (`function ... endfunction`, `fn ... endfn`), omitted zero-arg
  parentheses, brace-less bodies, caller-state/parser-state/persistent side-effect functions, recursion support,
  closures, lambdas, currying/partial application, and namespaces are explicitly not in the MVP. (3) **Book/KM
  closure.** The formal grammar, pipeline/backend handoff, descriptor/state model docs, task tree, and Knowledge
  Map now carry the same boundary. (4) **Gate.** mdBook, memory/doctrine/Knowledge Map/diff/local-CI gates pass;
  no parser/compiler/runtime code changed.
  Then-frontier: `SPEC-FORMAT-TERSE.3.2.3`; current frontier after the word-alias implementation is
  `SPEC-FORMAT-TERSE.3.2.3.4`.

- 2026-07-02 (SPEC-FORMAT-TERSE.4.3.2 — Rust user-function runtime parity):
  Rust now executes the user-function registry shape landed in `.4.3.1`. Durable points. (1) **Resolution
  boundary.** `Engine::eval_expr` checks `CompiledSpec.functions` before ordinary helper fallback, so registered
  callees run as user functions and wrong arity diagnoses before any unknown-helper path. (2) **Execution scope.**
  Arguments are evaluated eagerly in the caller context; params bind into fresh function-local scalar stores, with
  aggregate params also exposed through local array/hash stores. The caller's scalar/array/hash stores are
  restored after the body returns, so function locals do not leak. (3) **Return and composition.** The compiled
  body `CodeBlock` yields final-expression or `return(expr)` values, and returned arrays/hashes/scalars feed the
  existing compatible receiver-dot chains. Standalone calls execute and discard their result. (4) **Hardening.**
  Direct and mutual recursion report unsupported-recursion diagnostics instead of recursing. (5) **Gate.** Focused
  `.4.3.2` runtime locks, oracle generation, the 54-fixture Rust corpus oracle, Rust runtime lib, and Rust core
  tests pass; mdBook/memory/doctrine/Knowledge Map/diff/local-CI gates pass before commit.
  Next frontier: `SPEC-FORMAT-TERSE.4.4`.

- 2026-07-02 (SPEC-FORMAT-TERSE.4.3.1 — Rust user-function registry parity):
  Rust now has the parsed/compiled user-function registry shape needed before runtime execution. Durable points.
  (1) **Parsed registry.** `SpecFile` carries `functions`; the parser extracts top-level `fn name(args) { ... }`
  definitions before or between rule paragraphs, keeps their source/body spans and body source, and prevents those
  definitions from becoming raw rule body text. (2) **Validation boundary.** Rust rejects duplicate functions,
  rule-label collisions, built-in helper/control-name collisions including `.3.2.1` numeric word aliases,
  lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, and reserved params before
  runtime. (3) **Compiled registry.**
  `CompiledSpec` carries `CompiledUserFunction` records, each with ordered params, exact arity, parsed
  `CodeBlock` body, source/body spans, and source text; malformed body code becomes a compile diagnostic.
  (4) **Still pending.** Runtime call resolution, fresh function-local execution scope, receiver-chain
  continuation, standalone discard, and oracle fixtures are intentionally left to `.4.3.2`. (5) **Gate.** Rust
  format check, core tests, runtime lib tests, corpus oracle, mdBook build, memory/doctrine/Knowledge Map checks,
  diff check, and full local CI pass after the registry slice.
  Next frontier: `SPEC-FORMAT-TERSE.4.3.2`.

- 2026-07-01 (SPEC-FORMAT-TERSE.4.2.3 — Perl user-function standalone discard/hardening):
  The Perl reference now closes the remaining `.4.2` user-function boundary. Durable points. (1) **Dynamic
  VALUE_DROP seam.** Static helper contracts cannot know user-defined names, so `ActionIR::CanonicalEvents`
  now uses the compiled function registry to classify only registered standalone calls/chains as `VALUE_DROP`;
  `Contracts` then lets the existing dropped-value lowerer compute and discard them. Unknown unregistered
  standalone calls stay raw compatibility debt. (2) **Nested function calls.** `MethodLowering` now recognizes
  function-local scalar params when a user-function call passes them as arguments to another user function; this
  fixes the `wrap(value) -> identity(value)` case so the value is passed, not the bare token name. (3)
  **Hardening diagnostics.** Direct recursion, mutual recursion, parser-state helper bodies, host-code-shaped
  bodies, and nested function syntax all stay unresolved-helper diagnostics with zero raw fallback. (4) **Gate.**
  Syntax checks, focused AST suite, phase0, mdBook build, memory/doctrine/Knowledge Map checks, diff check, and
  full local CI pass; phase0 is now 1007 tests.
  Next frontier: `SPEC-FORMAT-TERSE.4.3.1`.

- 2026-07-01 (SPEC-FORMAT-TERSE.4.2.2 — Perl user-function value-call execution):
  Registered user-function calls now execute in Perl value positions. Durable points. (1) **Registry threading.**
  `Compiler` captures the extracted function registry in the `compile_spec_entry` callback; `SpecEntry` places it
  on `RuleIR`; `RuleIR::EmitContext` localizes it into MethodLowering deps while rewriting rule actions.
  (2) **Resolution boundary.** `MethodLowering` checks registered callees before unknown-helper fallback, while
  built-in helper/control names remain excluded by the `.4.2.1` definition validator. Wrong-arity registered
  calls deliberately stay unresolved-helper diagnostics with zero raw fallback. (3) **Execution shape.**
  Generated calls are `do { ... }` value expressions: caller arguments are evaluated eagerly into temps, params
  bind as function-local lexicals, local scalar/array/hash working vars are declared inside the expression, body
  statements are lowered from the ActionIR AST, and the result is either the final expression or a function-local
  `return(expr)` payload. (4) **Composition locks.** Phase0 covers return payloads, assignment RHS, array append
  RHS, hash mutation value, helper arguments, returned-value receiver chains, final-expression bodies, non-final
  function-local returns, and local/caller shadowing. (5) **Still pending.** Standalone discard, recursion/purity
  diagnostics, hard unsupported-body rejection, and Rust parity remain tracked follow-ons.
  Next frontier: `SPEC-FORMAT-TERSE.4.2.3`.

- 2026-07-01 (SPEC-FORMAT-TERSE.4.2.1 — Perl user-function registry seam):
  The Perl reference now records user-defined function definitions without executing calls yet. Durable points.
  (1) **Grammar owner.** `specs/spec.spec` has an active `function_definition` part for top-level
  `fn name(args) { body }` and a `spec_file` dispatch edge for it. (2) **Temporary bridge.** Because the
  hardcoded bootstrap parser is still the primary parse path, `LinkedSpec::UserFunctionRegistry` extracts
  top-level function definitions before validation/bootstrap and replaces them with whitespace that preserves
  newlines. This keeps ordinary rule diagnostics and spans stable while the permanent grammar remains
  self-hosted. (3) **Descriptor registry.** `compiled_spec_state` now carries `function_order` and
  `functions_by_name`; public descriptors project `functions`, `meta.function_order`, and
  `meta.function_count`. Each function definition records ordered params, arity, source/body spans, body source,
  and an ActionIR `action_block` body AST. (4) **Diagnostics.** Definitions reject duplicate names, invalid or
  duplicate params, reserved runtime/lifecycle/function symbols, built-in helper/control-name collisions, and
  rule-label collisions before runtime. (5) **Execution still pending.** Registered value-position calls remain
  unresolved-helper diagnostics with zero raw fallback until `.4.2.2`; standalone discard and purity hardening
  remain `.4.2.3`. (6) **Gate.** Syntax checks, focused descriptor probes, `specs/spec.spec` descriptor
  compile at ratio 1.0000, focused AST suite, mdBook build, memory/doctrine/Knowledge Map checks, diff check,
  and full local CI pass; phase0 is now 1005 tests.
  Next frontier: `SPEC-FORMAT-TERSE.4.2.2`.

- 2026-07-01 (SPEC-FORMAT-TERSE.4.1 — user-function contract/inventory locked):
  User-defined function implementation is now split by concrete seams before code. Durable points.
  (1) **MVP grammar/semantics.** The accepted syntax is top-level `fn name(args) { ... }`, including
  `fn name() { ... }` for zero arity. Calls evaluate arguments eagerly, bind exact-arity positional parameters
  into a fresh function-local scope, evaluate a pure value/block body, and return either the first
  `return(expr)` payload or the final expression value. Standalone user-function call statements compute and
  silently discard the result. (2) **Purity boundary.** The MVP has no implicit caller working-variable capture,
  recursion, closures, lambdas, currying, host-code escape, parser-state helpers, or side-effect helpers. Local
  function variables are function-scoped only. (3) **Collision boundary.** Function names share the helper call
  surface, so definitions must be rejected if they collide with built-in helper/control/lifecycle names, rule
  labels, reserved runtime symbols, or another function; parameters must be unique valid identifiers and must not
  use reserved runtime symbols. (4) **Current Perl ground truth.** TOOLBOX probes show value-position
  `user_fn(...)` calls now diagnose as `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn` with zero raw fallback,
  while standalone `user_fn(...)` remains raw until the function registry owns discard semantics. (5) **Current
  Rust ground truth.** Rust parses `Expr::Call` and `Expr::FluentChain`, but `Engine::call_helper` sends
  unknown names to warning+`undef`; user functions need a registry resolver before helper fallback. (6) **Split
  before code.** `.4.2` is split into Perl grammar/registry, value-call execution, and discard/purity hardening;
  `.4.3` is split into Rust registry and runtime/oracle parity. (7) **Gate.** mdBook, Knowledge Map,
  memory/doctrine checks, diff check, and full local CI pass after the inventory; phase0 remains at 1004 tests.
  Next frontier: `SPEC-FORMAT-TERSE.4.2.1`.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5.4 — `fn` grammar ownership proof lock):
  The Perl ActionIR text-to-AST migration now closes with an explicit function-definition ownership boundary.
  Durable points. (1) **Permanent function syntax is self-hosted.** `specs/spec.spec` now states that
  `fn name(args) { ... }` belongs to the self-hosted grammar surface, not to a lasting hardcoded bootstrap
  extension. (2) **Bootstrap has no current first-class `fn` support.** Targeted source checks over
  `BootstrapSpec.pm` and `BootstrapSpec/Core.pm` find no `fn name(...)` grammar pattern or named
  function-definition node support. (3) **The raw scanner shape is not support.** A `fn`-shaped line inside a
  rule currently appears only as generic unsupported paragraph content (`1`) in bootstrap parse output, with no
  structured function node or payload. (4) **Regression lock.** Phase0 now has a 1004-test green baseline with
  this proof, and the canonical local CI gate passes after the lock. (5) **Next owner.** User-defined function implementation returns to
  `SPEC-FORMAT-TERSE.4.1`, which owns the function contract/inventory before adding the actual grammar/runtime
  behavior.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5.3.2 — user-function AST call handoff preparation):
  Unknown typed calls in value-return positions no longer leak as generated host-language calls. Durable points.
  (1) **Value-position unknown calls diagnose.** `return(user_fn("x"))` and
  `return(user_fn("x").trim())` now lower through the ActionIR AST path to the existing
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn` sentinel, so descriptor metadata reports unresolved helpers
  rather than language-agnostic readiness. (2) **Known helper names are fenced before unknown-call diagnostics.**
  The unknown-call walker carries an explicit known-name set for existing DSL helpers, source-boundary helpers,
  declaration aliases, retired return helpers, statement-only array mutation methods, and internal trace calls.
  That prevents compatibility surfaces from being mistaken for future user functions. (3) **Standalone function
  discard remains future work.** `user_fn("x")` and `user_fn("x").trim()` as standalone statements still remain
  raw until the user-function registry owns resolution and discard semantics. (4) **Known-but-unsupported value
  chains stay compatible.** `return(items.push_back("a"))` remains raw compatibility text because `push_back`
  is a statement-only mutation surface, not a value-chain function call. (5) **Full local gate green.** The
  focused AST suite, phase0 1003-test suite, mdBook build, memory/doctrine/Knowledge Map checks, diff check, and
  canonical `tools/run_ci_local.sh` gate all pass after the handoff.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5.3.1 — short wrapper aliases retired): The short wrapper spellings
  `s(...)`, `a(...)`, and `h(...)` are no longer treated as canonical `scalar(...)` / `array(...)` /
  `hash(...)` wrappers. Durable points. (1) **Canonical wrappers only.** Repo-owned specs, tests, root docs, and
  mdBook examples now use `scalar(...)`, `array(...)`, and `hash(...)`. (2) **Diagnostics, not raw fallback.**
  Residual short wrapper calls lower to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:s|a|h` and descriptor
  unresolved-helper metadata with zero raw-Perl fallback. (3) **Long forms and direct shapes remain the surface.**
  Existing `scalar(...)`/`array(...)`/`hash(...)` behavior stays supported, while direct `[]` / `{}` shape
  literals remain preferred for constructor payload examples where they are clearer. (4) **Next handoff.**
  `.5.3.2` can now focus only on user-function AST call resolution.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5.3 — short alias retirement split): The user clarified that
  `s(...)`, `a(...)`, and `h(...)` should retire too. Durable points. (1) **Do not treat short wrappers as
  permanent syntax.** Canonical wrapper spellings are `scalar(...)`, `array(...)`, and `hash(...)`; direct shape
  literals remain the preferred constructor surface where applicable. (2) **Retirement must be owned before
  code.** Shorthand use is active in shipped specs, phase0 locks, and book examples, so `.5.3` was split:
  `.5.3.1` retired the short aliases; `.5.3.2` completed the value-position user-function diagnostic handoff.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5.2 — dropped value statements): Retired the supported standalone
  value-statement raw fallback without changing user-function ownership. Durable points. (1) **Dropped values now
  have a canonical event.** The scanner recognizes standalone covered value calls and simple receiver chains,
  maps them to `VALUE_DROP`, and lowers them through typed AST value traversal before appending `undef`.
  (2) **Malformed covered helpers stay diagnostics.** Bad arity or unknown nested covered calls still surface as
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:*` with `raw_perl_dependency_count == 0`. (3) **Compatibility value
  probes are expressions.** `call_spec_handler_subst('Top', 's(foo)')`, `a(...)`, and `h(...)` continue to return
  value expressions instead of statement-level discard wrappers. (4) **User-defined functions are still `.5.3`.**
  Unknown standalone calls/chains such as `user_fn("x")` and `user_fn("x").trim()` remain raw until the
  user-function AST handoff owns resolution/diagnostics.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5.1 — fallback-boundary audit): Audited the remaining Perl
  ActionIR fallback boundary before code. Durable points. (1) **Malformed covered helpers are already
  diagnostics, not raw fallback.** `substr`, `count`, and nested covered-helper arity failures use
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER` and unresolved-helper metadata with `raw_perl_dependency_count == 0`.
  (2) **Compatibility fences stay explicit.** Retired helpers (`return_array`, `return_a`) and non-DSL
  host-shaped statements (`my $x = 1`, bare `print "x"`) remain `RAW_PERL`; narrow return payload
  compatibility remains fenced. (3) **Do not disturb `push(A,B)`.** The all-bare form still means child-call
  aggregation, not scalar append. (4) **Unknown typed calls are the user-function handoff risk.** The AST parser
  already produces `call` / `fluent_chain` nodes for `user_fn("x")` and `user_fn("x").trim()`, but return-value
  contexts currently emit generated host calls and report ready. `.5.3` must resolve those names as user
  functions or diagnostics, not via textual fallback. (5) **No current `fn` definition grammar was found in the
  bootstrap parser or `specs/spec.spec`.** `.5.4` still owns the permanent `specs/spec.spec` grammar/proof lock.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.5 — fallback/function handoff split): Split the last Perl ActionIR
  AST migration parent before code. Durable points. (1) **Fallback retirement needs an audit first.** `.5.1`
  classifies remaining source-text fallback as compatibility debt, supported-surface leakage, or function-handoff
  dependency before changing behavior. (2) **Supported AST-covered leakage gets its own code leaf.** `.5.2`
  owns diagnostics/no-host-leakage behavior for forms already represented by typed AST nodes. (3) **Function
  calls stay on AST call nodes.** `.5.3` prepares user-function call resolution through `call`/`fluent_chain`
  nodes, preserving receiver chaining and standalone-result discard. (4) **`fn` definition grammar is not
  bootstrap-owned.** `.5.4` locks `specs/spec.spec` ownership and removes or proves absent permanent bootstrap
  parser support for `fn <name>(...) { ... }`.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.4.4 — while control lowering from AST): Moved attached while
  loops onto typed AST consumption without changing loop semantics. Durable points. (1) **While controls now
  use the AST bridge.** Attached `while(cond) { ... }` statements parse through `LinkedSpec::ActionIR::AST`
  before the existing while lowerer runs. (2) **The guard is unchanged.** The bridge materializes typed
  condition/body fields, then reuses the existing `ControlFlow` lowerer so condition re-evaluation and the
  deterministic 10000-iteration safety diagnostic stay stable. (3) **Bodyless marker while is not a new
  product surface.** `control_while` marker nodes still parse for shape consistency, but lowering continues to
  require an attached body because there is no current `endwhile` syntax. (4) **Structured-control `.4.4`
  children are now complete.** The next owned step is `.5`: fallback retirement and user-defined functions on
  the AST path, split before code if needed.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.4.3 — switch-family control lowering from AST): Moved the switch
  structured-control family onto typed AST consumption without changing switch semantics. Durable points.
  (1) **Switch controls now share the AST bridge.** `switch`, `case`, `default`, `endcase`, and `endswitch`
  statements parse through `LinkedSpec::ActionIR::AST` before the existing switch stack lowerers run.
  (2) **Parsed branches are authoritative.** Attached `control_switch` nodes materialize from typed
  `source_expr`, `cases`, and optional `default` fields before generic body fallback, so parsed case/default
  branch AST nodes drive lowering when available. (3) **Switch mechanics stay unchanged.** Single evaluation of
  the switch source, case ordering, `default` once-only behavior, attached branch splitting, and marker
  `endcase`/`endswitch` stack closure still flow through the same `ControlFlow` implementation. (4) **While is
  the only structured-control child left in `.4.4`.** `.4.4.4` owns typed while condition/body consumption plus
  preservation of the iteration-safety guard.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.4.2 — if-family control lowering from AST): Moved the first
  structured-control family onto typed AST consumption without changing generated branch semantics. Durable
  points. (1) **ControlFlow now has an AST bridge.** `if`/`i`/`when`, `elseif`/`elif`, `else`/`otherwise`, and
  `endif` statements parse through `LinkedSpec::ActionIR::AST` before the existing branch lowerers run.
  (2) **The bridge materializes from fields, not source.** Conditions and branch bodies are reconstructed from
  typed AST nodes; focused tests poison original text and AST `source` fields to prove those fields are not the
  source of generated Perl. (3) **Branch mechanics stay unchanged.** Existing attached-block implicit close,
  marker-style `endif`, and when/otherwise alias behavior still flow through the same `ControlFlow` stack.
  (4) **Remaining control families are still split.** `.4.4.3` owns switch/case/default; `.4.4.4` owns while
  plus its iteration-safety behavior.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.4.1 — control-flow AST parser nodes): Added typed structured
  control nodes to the additive ActionIR AST parser without switching production lowering. Durable points.
  (1) **Statement control is now syntactically typed.** Attached and marker forms parse as `control_if`,
  `control_else`, `control_endif`, `control_while`, `control_switch`, `control_case`, `control_default`,
  `control_endcase`, and `control_endswitch`. (2) **Bodies and branches are typed too.** Attached bodies are
  `action_block` nodes with `body_source` / `body_source_span`; attached switch payloads expose parsed
  `cases` plus an optional `default` branch. (3) **Value control stays separate.** Inline value helpers
  `if(cond, then, else)` and `switch(value, case(...), default(...))` deliberately remain generic `call` nodes
  so existing inline value-control lowering is untouched. (4) **Lowering is still queued.** `.4.4.2` owns
  if/when/otherwise consumption from AST; `.4.4.3` owns switch/case/default; `.4.4.4` owns while.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.4 — structured-control split): Split the remaining structured
  control-flow AST migration before code. Durable points. (1) **Parser nodes come first.** `.4.4.1` owns typed
  AST node shapes for attached-block and marker-style control forms before lowering switches over. (2) **Branch
  families stay separate.** `.4.4.2` owns `if`/`when`/`otherwise`, `.4.4.3` owns switch/case/default state, and
  `.4.4.4` owns while lowering with iteration-safety behavior preserved. (3) **No runtime behavior changed in
  the split.** This commit only narrows ownership so code leaves can be validated independently.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.3 — block-value statements from AST): Moved expression-valued
  block internals onto typed AST statements. Durable points. (1) **Block values bridge before text splitting.**
  `_lower_block_value_expr(...)` now tries the parsed `block_value` node through the AST value path before the
  legacy source splitter. (2) **Side effects use `action_stmt.expr`.** AST block lowering now lowers non-final
  assignments, helper-call statements, and array end mutations from the typed statement expression before
  falling back to `stmt->{source}`. (3) **Block-local return stays block-local.** `return(expr)` inside an
  expression-valued block still uses the guarded `__ls_block_done` / `__ls_block_value` wrapper for non-final
  returns, but supported payloads come from typed AST call arguments. (4) **Compatibility remains bounded.**
  The legacy splitter remains only as fallback for untyped compatibility surfaces that later leaves still own.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.2 — helper-call statements from AST): Moved the next statement
  family onto typed AST consumption. Durable points. (1) **Call statements now have an AST bridge.**
  `return`, `return_undef`, `set_key`, `push`, `push_value`, and `push_nonempty` statements consume AST `call`
  names/arguments before legacy text parsing. (2) **Top-level `set`/`assign` needed the DeclareMethod path.**
  The assign bridge stays lazy inside `_lower_assign_method_statement(...)` so synthetic dependency-builder
  tests do not gain a new required callback. (3) **Receiver-dot array mutations are fluent-chain statements.**
  `items.push_back(...)`, `push_front`, `pop_back`, and `pop_front` now lower from typed receiver/call fields.
  (4) **Raw compatibility still falls back.** Unsupported/raw arguments such as `scalaref(retv, {content})`
  and host-style `substr($$STRING, ...)` return to the legacy path instead of becoming AST sentinels.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4.1 — assignment/mutation operators from AST): Landed the first
  statement-level AST consumer. Durable points. (1) **Typed fields drive operator statements.** `assign_scalar`,
  `assign_array_append`, and `assign_hash_index` nodes now lower from `name` / `key` / `value` fields before the
  legacy regex paths. (2) **Compatibility still enters existing policies.** The AST path materializes trusted
  helper/action text from typed nodes and then reuses the existing scalar assignment, array append, and
  hash-index lowering logic, preserving target-kind inference and source/mutation slot semantics. (3) **Poisoned
  source is locked out.** Focused tests intentionally use original poison identifiers plus fake AST `source`
  fields and assert generated output comes from typed fields. (4) **Helper statements followed in `.4.2`.**
  `set`, `push`, `set_key`, `return`, and `return_undef` are now covered by the statement-call AST bridge.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.4 — statement/control AST split): Split the next migration parent
  before code. Durable points. (1) **Operator statement nodes are first.** `.4.1` should use the AST parser's
  existing `assign_scalar`, `assign_array_append`, and `assign_hash_index` nodes before broadening helper-call
  statement behavior. (2) **Helper statements need slot policy.** `.4.2` owns `set`/`assign`, `push`,
  `set_key`, array end-mutation helpers, `return`, and `return_undef` as AST `call` nodes, preserving the
  existing symbol/value distinction. (3) **Block values remain a separate risk.** `.4.3` owns side-effect
  statements and block-local returns inside expression-valued blocks. (4) **Control flow waits for dedicated
  nodes.** `.4.4` owns if/when/otherwise, switch/case/default, and while forms, where parser support and
  iteration-safety locks must move together.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.4 — return payloads from AST): Moved typed return-payload
  lowering onto the ActionIR AST consumer. Durable points. (1) **Typed payloads run before regex substitution.**
  `_lower_return_payload_expr(...)` now parses the trimmed payload with `LinkedSpec::ActionIR::AST` and accepts
  AST-lowered values for non-raw nodes before the legacy helper-looking regex loop. (2) **Bare variables keep
  source-slot semantics.** The direct AST path intentionally excludes `variable` nodes so `return(count)`,
  `return(trueword)`, and block/control payload variables still lower through `_lower_source_slot_bare_scalar_read_expr(...)`
  as `$count`, `$trueword`, etc. (3) **Poisoned `source` is not authoritative.** String, regex, and numeric
  AST nodes rebuild trusted literals from typed fields, and return-payload tests now poison array/hash/string/
  call/chain/variable source fields. (4) **Unsupported covered chains still diagnose.** A typed payload such as
  `["x", "abc".substr()]` keeps the `.3.2.3` `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr` path instead of
  generated host `substr(...)`. (5) **Raw fallback remains compatibility debt.** Untyped payloads such as
  `\(my $capt = capture_slice())` still use the old narrow fallback until later retirement work can own them.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.3 — receiver-dot `fluent_chain` from AST): Moved
  receiver-dot value-chain lowering onto the ActionIR AST consumer. Durable points. (1) **The chain source is
  no longer authoritative for supported receiver families.** `MethodLowering` now dispatches `fluent_chain`
  nodes before the legacy receiver-dot text normalizers and uses typed receiver/call/argument fields for
  array, hash, string, and number chains. (2) **The helper catalog remains the byte-compatibility boundary.**
  The AST dispatcher builds the same helper-family surfaces and then enters the existing Perl helper catalog
  through the compatibility bridge, preserving wrapper behavior, array pipeline private helper names,
  hash/string-to-array bridges, block-valued receivers, and numeric terminal rules. (3) **Unsupported covered
  chain helpers reuse the diagnostics channel.** A malformed chain such as `"abc".substr()` reaches the
  `.3.2.3` unsupported-helper sentinel instead of leaking as a generated host `substr(...)` call. (4) **The old
  receiver splitters are fallback only.** They still exist for raw/unparsed compatibility surfaces, but parsed
  supported `fluent_chain` value expressions are now owned by AST traversal. (5) **Remaining migration risk is
  return/control.** `.3.4` owns return-payload AST traversal; `.4` owns statement/control lowering.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.2.3 — covered-call diagnostics): Retired silent host-call
  leakage for helper families already owned by AST call lowering. Durable points. (1) **Known helpers are not
  future functions.** The dispatcher now distinguishes unknown calls from known helper-family calls. Unknown
  calls remain available for the future user-function path; known covered helpers with unsupported arity or
  unsupported AST argument materialization become diagnostics. (2) **The sentinel is metadata plumbing, not a
  new public helper.** `MethodLowering` emits a harmless `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>`
  expression returning `undef`; it prevents generated Perl from accidentally trying to call host routines such
  as `substr(...)` or `count(...)`. (3) **Diagnostics reuse the existing unresolved-helper channel.**
  `ActionIR::Diagnostics` scans the sentinel into `unresolved_helper_count` / `unresolved_helpers`, marks the
  rule not language-agnostic-ready, and leaves `raw_perl_dependency_count == 0`. (4) **Supported calls remain
  byte-compatible.** Valid `.3.2.1` / `.3.2.2` helper forms still enter the existing helper catalog through the
  compatibility bridge. (5) **Receiver and return seams are still separate.** `.3.3` owns receiver-dot
  `fluent_chain` AST traversal and `.3.4` owns return-payload AST traversal.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.2.2 — aggregate helper calls from AST): Extended the
  MethodLowering AST call consumer to the aggregate/symbol-slot helper families. Durable points.
  (1) **Aggregate slots stay source-shaped.** Covered calls are reconstructed from AST fields before entering
  the existing Perl helper catalog, but bare aggregate operands are preserved as symbol tokens instead of
  being lowered to scalar values. This keeps `count(array(items))`, `copy(hash(meta))`, and
  `merge_hash(hash(base), overlay)` aligned with the existing array/hash inference and auto-declare collectors.
  (2) **Wrapper aliases remain compatibility syntax.** `scalar(...)`, `array(...)`, and `hash(...)` are now
  AST-consumed call nodes, including `s`/`a`/`h`, but they are still deprecated compatibility aliases per
  ADR 0007 rather than the canonical destination surface. (3) **Quoted wrapper payloads are still literals.**
  The AST bridge rebuilds quoted strings from node values, so `array("items")` remains a literal payload and
  never aliases `@items`. (4) **Nested covered calls are source-independent.** Focused fake-source tests now
  cover wrappers, `copy`, numeric reducers, collection helpers, nested value-only payloads inside hash helpers,
  and hash terminals. (5) **Diagnostics and receiver chains are now follow-up landed leaves.** `.3.2.3`
  replaces unsupported covered-call host-call leakage with unresolved-helper telemetry; `.3.3` moves
  receiver-dot `fluent_chain` value chains onto AST traversal.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.2.1 — value-only helper calls from AST): Landed the first
  production AST consumer for helper `call` nodes. Durable points. (1) **Covered calls ignore call-node source
  text.** The focused test injects fake source strings on AST call nodes and proves `MethodLowering` uses the
  typed `name`/`args` fields for covered helpers. (2) **Bare helper variables are preserved.** A bare
  `trim(value)` argument still lowers as the historical helper-slot token `value`, not `$value`; the deprecated
  `scalar(...)` wrapper remains only a compatibility alias until retirement-aware slot policy says otherwise.
  (3) **Unsupported argument calls stay compatible, not canonical.** Legacy wrapper aliases
  (`scalar(...)`/`array(...)`/`hash(...)`), aggregate wrappers, reducers, collection helpers, hash helpers, and
  receiver-chains still delegate through the explicit compatibility bridge. (4) **Numeric scope is
  scalar-argument only.** `num_add`/`num_mul`/binary numeric helpers and explicit `num_*` comparisons are
  covered; `num_sum`/`num_avg`/`num_median`/`num_range` remain aggregate/reducer work for `.3.2.2`.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.2 — AST helper-call lowering split): Split helper-call AST
  lowering before code. Durable points. (1) **Calls are not all value slots.** Helpers such as
  `trim(value)` and `num_add(a,b)` can recursively materialize AST value arguments, but helpers such as
  `scalar(name)`, `array(items)`, `hash(meta)`, `copy(items)`, and regex/tag/path helpers contain symbol,
  aggregate, delimiter, or tag slots where premature value lowering would change semantics. (2) **First child
  is value-only.** `.3.2.1` should cover scalar normalization, string predicates, coalesce/concat, and numeric
  helper families. (3) **Aggregate wrappers need slot policy.** `.3.2.2` owns wrapper and collection helpers
  so quoted-name boundaries and array/hash symbol precedence stay locked. (4) **Diagnostics are isolated.**
  `.3.2.3` retires silent host-call leakage only for helper families covered by the earlier children.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3.1 — non-call value AST lowering dispatcher): Landed the first
  production consumer of the Perl ActionIR AST seam. Durable points. (1) **The dispatcher is deliberately
  partial.** `_lower_method_value_expr(...)` now parses with `LinkedSpec::ActionIR::AST`, but top-level helper
  calls and receiver chains stay on compatibility paths until `.3.2`/`.3.3`. (2) **Non-call values are AST
  lowered.** Primitive literals, scoped bare scalar reads, direct indexed/nested access, shape literals, and
  block values lower from typed nodes. (3) **Context still matters for bare identifiers.** Bare variables become
  `$name` only in value slots that already accepted scalar reads; `scalaref(...)` path atoms such as `{content}`
  remain literal keys. (4) **Reserved direct-access atoms still opt out.** `foo["a"][true]` and
  `foo["a"][CAPTURE]` still leave the whole expression on the legacy fallback surface rather than lowering to a
  dereference. (5) **Block statement side effects are not done yet.** AST block values lower final value and
  block-return payloads, but statement-level side effects still delegate to the existing statement lowerer until
  the `.4` statement/control migration.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.3 — value/receiver AST lowering split): Split the broad `.3`
  migration before code. Durable points. (1) **The parent is a contract, not an implementation leaf.**
  Value lowering spans non-call values, helper-call composition, receiver-dot chains, and return-payload helper
  substitution; those need separate verification surfaces. (2) **`.3.1` is the first executable child.**
  It should route `_lower_method_value_expr(...)` through `LinkedSpec::ActionIR::AST` for primitive literals,
  bare scalar reads, direct access, shape literals, and block values while preserving helper-call behavior
  behind an explicit compatibility bridge. (3) **Receiver chains wait for `.3.3`.** Function-call, literal,
  direct-access, shape, and block receivers must traverse `fluent_chain` nodes rather than rebuilding helper
  call text. (4) **Return helper substitution waits for `.3.4`.** The regex replacement loop in
  `_lower_return_payload_expr(...)` must become AST traversal with diagnostics. (5) **User-defined functions
  remain blocked.** They must consume AST `Call` nodes after the value/receiver children are landed.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.2 — Perl ActionIR AST parser seam added): Landed the first additive
  code seam for the Perl text-to-AST migration. Durable points. (1) **The seam is read-only for now.**
  `LinkedSpec::ActionIR::AST` / `AST::Parser` parse helper/action text into typed nodes, but
  `RewritePipeline`, `MethodLowering`, and `RuleIR::EmitContext` still own production lowering until `.3+`.
  (2) **Statement values are explicit drops.** `action_stmt` nodes carry `drops_value => 1`, so standalone
  helper or future user-function calls silently discard their value. (3) **Function calls are valid
  receivers.** The parser accepts `call().method(...)`, numeric literal receivers, and block-valued receivers
  as `fluent_chain` nodes. (4) **The parser reuses existing seams without mutating them.** It calls
  `StatementSplit` and `MethodExpr`, then applies an AST-only newline refinement for receiver-chain
  statements; current statement splitting/lowering behavior is unchanged. (5) **Next migration risk is
  value/receiver lowering.** `.3` should consume these nodes for `_lower_method_value_expr(...)`,
  `_lower_return_payload_expr(...)`, and receiver-dot normalization before broader statement/control work.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.1 — Perl ActionIR text-lowering inventory locked): Completed the
  no-behavior inventory before implementation. Durable points. (1) **The decisive text-to-text boundary is
  `RewritePipeline`.** `_lower_action_code_from_canonical_ir(...)` matches canonical event raw statements back
  into source and `substr(...)`-replaces them with lowered Perl; the AST migration must remove that raw-span
  replacement for supported surfaces. (2) **The smallest parser seam is `MethodExpr` plus
  `StatementSplit::Core`.** Those modules already contain most delimiter/quote handling, but return strings;
  `.2` should reuse or port their mechanics into typed nodes. (3) **`MethodLowering` is the highest-risk
  recursive text parser.** `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, and receiver-dot
  normalization repeatedly parse/rewrite raw text and should move first after the parser seam. (4) **AST nodes
  should mirror Rust.** Use `ActionBlock`/`ActionStmt`, `Call`, `FluentChain`, value/literal/access nodes,
  assignment/mutation nodes, and control nodes with source spans; standalone expression statements drop their
  value silently. (5) **Raw fallback becomes legacy telemetry only.** `RAW_PERL` can remain during migration,
  but new supported surfaces, especially user-defined functions, must flow through AST `Call` nodes.

- 2026-07-01 (PERL-ACTIONIR-AST-MIGRATION.0 — text-to-AST doctrine adopted): User explicitly rejected Perl
  source-text lowering as too fragile and adopted the Rust-style text-to-AST path as cross-variant doctrine.
  Durable points. (1) **AST before lowering is now a contract.** Every backend must parse helper/action DSL
  text into typed AST/IR before lowering, interpretation, or code emission. (2) **Perl text-to-text is debt.**
  Existing structured source scans remain only as migration baseline; new supported surfaces must not extend
  them. (3) **User functions depend on this.** Implement `fn` through AST call/function nodes, not textual macro
  expansion. (4) **Future variants inherit the rule.** Dart, Julia, and Lua must start text-to-AST under
  ADR `0021`. (5) **Migration must be sliced.** Inventory first, parser seam second, then
  value/receiver and statement/control family replacement under phase0/oracle locks.

- 2026-07-01 (SPEC-FORMAT-TERSE.4 — user-defined function surface owned): Accepted user-defined functions
  into the active terse lane, with a deliberately constrained first contract. Durable points. (1) **Function
  calls are value expressions.** They must compose anywhere an ordinary value can compose, including helper
  arguments, assignment/return payloads, append/mutation value slots, and receiver-dot value chains. (2)
  **Unused call results are dropped silently.** A standalone call is an expression statement whose value is
  ignored; it must not warn, mutate hidden storage, or create diagnostic noise merely because the result is not
  consumed. (3) **MVP syntax is one shape.** Start with top-level `fn name(args) { ... }`, requiring
  parentheses even for zero args; alternate `function`/`endfunction`, `fn`/`endfn`, and optional-paren forms
  remain deferred. (4) **`specs/spec.spec` owns the language surface.** The user clarified that any temporary
  bootstrap parser support for `fn <name>(...) { ... }` must be removed after the text-to-AST migration; the
  permanent function grammar belongs in `specs/spec.spec`. (5) **Keep this out of general FP scope.** No
  recursion, closures, lambdas, currying, or implicit caller working-variable capture in the initial
  implementation. (6) **Next leaf is design/inventory before code.** `SPEC-FORMAT-TERSE.4.1` must inspect
  `specs/spec.spec`, the Perl bootstrap removal boundary, ActionIR AST seams, and Rust parser/runtime seams
  before implementation starts.

- 2026-07-01 (SPEC-FORMAT-TERSE.3.2.1 — numeric word aliases landed): Implemented the non-conflicting
  function-form numeric aliases on both variants. Durable points. (1) **Alias mapping belongs in value
  lowering/runtime dispatch, not shared Perl parse normalization.** A first attempt at parser-level
  normalization turned receiver-chain tails like `.floor()` into `num_floor()` too early; the landed Perl path
  maps aliases only after receiver-dot normalization has had a chance to see raw receiver methods. (2)
  **Receiver-dot number chains remain stable.** `3.5.floor().add(1)` still lowers through
  `num_floor`/`num_add` and the older number/block receiver oracle fixtures stay unchanged. (3)
  **Comparisons are still out of scope.** `gt(...)` remains the string comparison helper; numeric comparison
  spellings stay behind `.3.2.3`. (4) **Symbol callees are still a parser/lowering problem.** `+(a,b)` is
  deliberately left for `.3.2.2` because raw host fallback is unsafe. (5) **The oracle corpus is now 53
  fixtures.** The new fixture locks the Perl reference and Rust runtime on the same alias result vector.

- 2026-07-01 (SPEC-FORMAT-TERSE.3.2 — arithmetic call surface split before code): Closed the Round 3
  arithmetic/comparison parent as an ownership split, not an implementation. Durable points. (1) **Keep one
  call grammar.** The accepted surface remains `callee(args)` with word and symbol callees; do not add
  `(op a, b)` / `(ge a, b)` as a second call grammar. Ordinary nested calls already provide the intended
  Lisp-style composability. (2) **Word aliases and symbol callees are different mechanisms.** `add(...)` can
  map to `num_add(...)` through helper-name normalization, but `+(...)` requires parser support before the
  lowering layer can see it. (3) **Do not leave symbol calls to host fallback.** Probe result `+(2,3)` is
  dangerous on the Perl path because raw host Perl can reinterpret it as unary-plus/comma behavior instead of
  numeric addition. (4) **Comparison word aliases are a compatibility decision.** Bare
  `eq`/`ne`/`gt`/`ge`/`lt`/`le` are current string comparisons in flow/helper docs and lowering; numeric
  comparisons are `num_*` helpers or receiver terminals such as `score.gt(3)`. (5) **Next safe executable
  slice is non-conflicting numeric word aliases.** Frontier moves to `SPEC-FORMAT-TERSE.3.2.1`; comparison
  spellings stay isolated behind `.3.2.3`.

- 2026-07-01 (SPEC-FORMAT-TERSE.3.1 — edge syntax contract locked): Closed the Round 3 edge-syntax leaf as a
  confirmation/docs/KM slice. Durable points. (1) **No behavior changed.** `->` remains the action-edge
  surface and `=>` remains the blind-call surface. (2) **Grouped action targets are factoring only.**
  `-> A | B { code }` expands the shared code block across the listed targets; each target dispatches
  independently. (3) **The shared block is mandatory.** `-> A | B` without `{ ... }` remains invalid and is
  diagnosed as "Grouped action-edge targets require a shared code block". (4) **Existing locks were enough.**
  Phase0 already covers shared-block parse expansion, validation acceptance, missing-block rejection, and
  three-target grouping. (5) **Next Round 3 work was arithmetic/comparison spelling.** It was split by
  `.3.2`; the current frontier is `.3.2.1`.

- 2026-07-01 (SPEC-FORMAT-TERSE.5.0 — future variant parity ownership/inventory landed): Closed the
  unnumbered "Julia/Lua/Dart variant parity" frontier as an ownership slice before any backend code. Durable
  points. (1) **Implemented backends are Perl and Rust.** Perl remains the reference implementation; Rust is
  the implemented interpreter variant under `rust/`, validated incrementally by the language-neutral oracle
  corpus. (2) **Julia and Dart were the accepted future targets at this slice, not current implementations.**
  ADR `0006`, Phase 8, and the backend handoff chapter defined Rust/Julia/Dart lockstep obligations at that
  time, while Phase 9 explicitly scoped implementation to Rust only. (3) **Lua needed an explicit adoption
  decision at that time; ADR `0021` now
  supplies it.** The future backend rollout is now owned by `FUTURE-PARITY-BACKLOG` as Dart, then Julia, then
  Lua. (4) **The next executable language slice is Round 3, not backend code.** Future backend
  leaves are owned/deferred, so PNT returns to `SPEC-FORMAT-TERSE.3.1` (edge syntax confirmation). (5) **Keep
  KM facts current after roadmap milestones.** The older backend-vision card still said "Perl 5 only" after
  Phase 9; correcting that avoids future archaeology.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5.5 — block-valued receiver-dot chains landed): Closed the
  block-receiver audit with a small Perl gap fix and Rust parser parity. Durable points. (1)
  **Expression-valued blocks are ordinary receiver values.** The block runs first, including block-local
  `return(expr)`, and the yielded value feeds the compatible receiver family selected by the first method.
  (2) **The Perl gap was array-specific.** String, hash, and number block receivers already lowered through
  existing receiver-family normalization; array-yielding blocks were rejected by the array-value recognizer
  before helpers such as `sorted(...)` could lower. (3) **Array block recognition stays narrow.** Perl now
  marks a block array-like only when its visible exits are array-yielding expressions, avoiding a broad
  "every block is an array" rule that could misclassify scalar or hash blocks. (4) **Rust needed parser
  follow-through, not runtime changes.** The runtime already evaluates non-variable fluent receivers through
  `eval_expr`; the parser now lets block/hash/array primaries continue into `.method(...)` chains. (5)
  **Contract examples span all families.** Locked forms include `{ [3, 1, 2] }.sorted().join_values(",")`,
  `{ " a-b " }.trim().split("-").count()`,
  `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5.6 — aggregate wrapper quoted-name boundaries landed): Locked the
  aggregate wrapper constructor/read boundary. Durable points. (1) **Bare aggregate wrapper args are typed
  reads.** `array(foo)` / `a(foo)` read the array working variable `foo`; `hash(bar)` / `h(bar)` read the hash
  working variable `bar`. This remains useful in typed helper slots where a bare name alone could otherwise
  follow scalar or callee-inferred rules. (2) **Quoted wrapper args are payloads, not aliases.**
  `array("foo")` and `array('foo')` construct literal string payloads; quoted hash constructor keys are fixed
  keys. There is no scalar-indirect lookup where a scalar value names another aggregate. (3) **Direct shapes
  are the terse constructors.** Prefer `["literal"]`, `{ "key" => value }`, `[]`, and `{}` for new array/hash
  construction examples. (4) **Generic Perl value lowering must recognize shapes.** Direct shape literals now
  lower as array/hash value expressions inside generic helper composition, so helper chains do not need wrapper
  constructors merely to produce literal arrays/hashes. (5) **Reserved aggregate-name filtering matters.**
  Primitive literals and scalar-only engine locals must not be interpreted as aggregate variable names, while
  legitimate aggregate locals such as `IMATCH_LIST` and `IMATCH_HASH` remain available.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5.4 — number receiver-dot value chains landed): Implemented the
  number return-family receiver-chain leaf. Durable points. (1) **Number receiver chains are pure value
  composition over `num_*`.** Perl normalizes receiver-dot numeric links into helper expressions and Rust
  evaluates `Expr::FluentChain` by carrying the current number through the same helper family. Supported
  links are `abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`, `div`, `mod`, `min`, `max`, and `clamp`.
  (2) **Numeric literal parsing must preserve method dots.** Perl's receiver splitter skips decimal dots, and
  Rust only consumes a decimal point when it is followed by a digit, so both `3.5.floor()` and `5.add(3)` parse
  correctly. (3) **Comparison helpers are terminal value links.** `eq`, `ne`, `gt`, `ge`, `lt`, and `le`
  return boolean/scalar terminal values; invalid later receiver-dot calls return `undef` / JSON `null`.
  (4) **Multi-operand helpers are part of the contract.** Receiver `add(...)` and `mul(...)` feed every
  supplied operand to `num_add`/`num_mul`; Rust now consumes all operands instead of the first two. (5)
  **Keep statement/lifecycle methods out of receiver families.** `declare(...)` and similar statement or
  lifecycle calls are not terse numeric methods; block-valued chaining was closed separately by `.2.3.5.5`.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5.3 — string receiver-dot value chains landed): Implemented the
  string/scalar return-family receiver-chain leaf. Durable points. (1) **String receiver chains are pure value
  composition.** Perl normalizes compatible receiver-dot string links into helper expressions, and Rust
  evaluates `Expr::FluentChain` by carrying the current string value through the helper table. String-returning
  links include `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`,
  `concat`/`cat`, and `coalesce_nonempty`. (2) **Bare scalar receivers must be explicit scalar reads in Perl
  normalization.** `raw.trim()` wraps the receiver as `scalar(raw)` before helper composition so generated Perl
  reads `$raw` instead of leaving a host method call. Capture receivers and string-literal receivers are also
  locked. (3) **`split(delim)` is the explicit bridge into array receiver chains.** After split, the current
  value is an array and may continue through `trim_each`, `filter_nonempty`, `lowercase_each`, `count`,
  `join_values`, and the rest of the array receiver family. (4) **Scalar terminals end the chain.** `length`,
  `starts_with`, `ends_with`, `contains_substr`, and `matches` return number/boolean values; invalid later
  receiver-dot calls now lower/evaluate to `undef` / JSON `null` instead of leaking generated host residue.
  (5) **Block-valued receiver chaining is separately owned.** `.2.3.5.5` later locked blocks as values whose
  yielded runtime type selects the receiver family.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5.2 — hash receiver-dot value chains landed): Implemented the hash
  return-family receiver-chain leaf. Durable points. (1) **Receiver-dot hash chains are pure value
  composition.** Perl normalizes compatible hash receiver links into helper expressions, and Rust evaluates
  `Expr::FluentChain` by carrying the current hash value through the helper table. Hash-returning links include
  `hash_copy`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`, `pick_keys`, and `flat_hash`; `sorted_keys`
  and `sorted_values` bridge into the array receiver-chain family. (2) **Bare hash receivers must be explicit
  hash snapshots in Perl normalization.** `merge_hash(meta, ...)` can lose a leading bare word to optional-scope
  normalization, so receiver chains wrap a bare hash receiver as `hash(meta)` before composing helper calls.
  (3) **Receiver-dot `scalaref(key)` maps to Perl's established hash-field reader.** The Perl reference lowers
  the receiver form through `scalar(hash_expr, key)` while Rust uses its existing hash-consuming `scalaref`
  helper arm; both return the selected field value. (4) **Statement hash mutations remain separate.**
  `set_key(meta, key, value)` and `meta[key] = value` mutate the named working hash; `meta.set_key(key, value)`
  is pure and does not mutate unless assigned back. (5) **Rust `merge_hash` now matches the documented helper
  contract.** Later hash arguments override earlier keys, matching Perl and the mdBook contract.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5.1 — array receiver-dot value chains landed): Implemented the first
  return-family receiver-chain leaf. Durable points. (1) **Receiver-dot array chains are pure value
  composition.** Perl normalizes compatible receiver-dot array links into value expressions, and Rust evaluates
  `Expr::FluentChain` by carrying the current array value through the existing helper table. Terminals such as
  `first`, `count`, `index_of`, `contains`, `is_empty`, `is_nonempty`, and `join_values` return their documented
  value. (2) **Do not break legacy function-style pipeline lowering.** Public `uniq(...)`,
  `filter_match(...)`, `uppercase_each(...)`, and related function-style forms keep their pre-existing
  statement-pipeline lowering. The pure array-value path is private to receiver-dot chains, which is why
  `items.uniq().join_values(",")` works without changing historical source-shape locks for
  `filter_match(uniq(uppercase_each(array(items))), /^A/)`. (3) **Delimiter order is part of the contract.**
  `items.join_values("|")` maps to `join_values("|", items)`, not `join_values(items, "|")`. (4)
  **Statement mutations are still not values.** `items.push_back(value)` and the other `.1.6` end mutations
  remain statement-only; value slots return `undef` and do not mutate. (5) **`split_each` needed Rust parity
  cleanup.** Rust now matches the documented flat-array `split_each(arr, delim)` value behavior when that helper
  is used in receiver chains and function-style helper calls.

- 2026-07-01 (SPEC-FORMAT-TERSE.2.3.5 — return-type method chaining split): Completed the design/split before
  code. Durable points. (1) **Do not broaden statement mutations into value chains implicitly.** Perl currently
  lowers `items.push_back("a")` and `items.pop_back()` only as standalone mutations, while
  `return(items.pop_back())`, `set(out, items.push_back("a"))`, and chained receiver expressions remain raw.
  Rust parses `Expr::FluentChain`, but the runtime only special-cases single-call array end mutations as
  statements; generic fluent expression evaluation returns `undef`. (2) **Receiver-dot value chaining is
  receiver-as-first-argument plus a return-family contract.** Array-returning calls can feed array methods,
  hash-returning calls can feed hash methods, and scalar/string/number/boolean terminals either end the chain
  or continue only through an explicitly compatible next-family contract. (3) **Implementation is split by
  family.** `.2.3.5.1` owns array receiver-dot value chains first; `.2.3.5.2`, `.2.3.5.3`, and `.2.3.5.4`
  own hash, string, and number families. (4) **Inline value-control docs are now aligned with `.2.3.4.2`.**
  mdBook no longer calls inline `if(...)` / `switch(...)` Rust-only or Perl-pending; they are portable lazy
  value helpers in the supported value slots.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.4.2 — Perl inline value-control lowering landed): Implemented the Perl
  reference side of the inline value-control contract. Durable points. (1) **Value-control lowering belongs in
  value-expression lowering, not statement-control lowering.** `_lower_method_value_expr` now intercepts
  inline `if(...)` and `switch(...)` before generic helper lowering and returns scoped `do { ... }` expressions
  that yield the selected branch payload. Attached blocks and marker chains remain statement-control forms.
  (2) **Flow booleans and payload booleans have different host needs.** Flow conditions now lower literal
  `true`/`false` to host `1`/`0`; ordinary payload literals still lower through JSON booleans. This keeps
  `if(false, ...)`, `elseif(false, ...)`, and attached `while(false)` host-gated without changing return
  payload semantics. (3) **Inline branches must be scanned as value positions.** Auto-working-variable
  discovery now recurses through inline `if`/`switch` payloads, nested helper predicates, shape literals,
  direct access, and expression-valued block branches so selected branch code does not fall back to non-strict
  package globals. (4) **Do not reintroduce label-frozen regexes.** The legacy labelled `return(Label, ...)`
  compatibility contract delegates to `lower_return_general_statement`, and its label guard must not use `/o`;
  the first label seen in-process can otherwise freeze later corpus-order rewrites. (5) **Payload values are
  the portable assertion.** Fluent/action-edge return compatibility may still include ordinary string tags, but
  `.2.3.4.2` tests and oracle fixtures assert selected payload values, not mandatory `?...:` tag spelling.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.4.1 — Rust bare aggregate helper-argument parity landed): Implemented the
  narrow Rust parity fix from the `.2.3.4` audit. Durable points. (1) **Do not change global bare-variable
  evaluation.** `Expr::Variable` still reads scalar state; the new `hash_consuming_arg(...)` and
  `array_consuming_arg(...)` helpers promote a bare name to `ctx.hash_copy(name)` or `ctx.array_copy(name)` only
  when a helper arm already owns that aggregate-valued argument slot. (2) **The contract is helper-position
  typed.** `merge_hash(hash_copy(base), overlay)` and `count(drop_front(sorted(items)))` now match the Perl
  reference, and the same snapshot rule applies to hash/object helper slots (`set_key`, `rename_key`,
  `drop_keys`, `pick_keys`, `sorted_keys`, `sorted_values`, `count_keys`, `has_key`, `scalaref`, `flat_hash`)
  and array helper slots (`sorted`, `reversed`, `first`, `last`, `take`, `take_last`, `drop_front`, `drop_back`,
  `slice`, `contains`, `index_of`, `num_sum`, `flat_array`). (3) **The oracle now carries both boundaries.**
  `.2.3.4` keeps the explicit-wrapper fixture, while
  `terse_2_3_4_1_bare_hash_helper_arg_composition` and
  `terse_2_3_4_1_bare_array_helper_arg_composition` lock the bare aggregate argument forms; corpus oracle
  passes with 44 fixtures. (4) **The next portability blocker at that point was Perl inline value controls.**
  `.2.3.4.2` later closed `return(if(...))` / `return(switch(...))` value-lowering parity and moved the
  frontier to `.2.3.5`.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.4 — full composability audit split): Completed the audit leaf before
  implementation. Durable points. (1) **Pure helper composition is the accepted portable subset today.** The
  new oracle fixture composes `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))`
  and passes on Rust with the 42-fixture corpus. (2) **Bare aggregate helper arguments are a Rust parity gap,
  not a book fact.** The Perl reference treats `merge_hash(hash_copy(base), overlay)` as merging `%overlay`,
  but Rust evaluates bare `overlay` as a scalar before `merge_hash` sees evaluated arguments, so the diagnostic
  corpus returned Perl `2` vs Rust `1`. `.2.3.4.1` owns that helper-context aggregate bare-read implementation.
  (3) **Inline value controls are not portable yet.** Perl generated-source probes for `return(if(...))` and
  `return(switch(...))` produce branch-control `do { ... }` shapes that do not reliably return the selected
  value, and nested helper predicates/branches can fail handler compilation. Rust's lazy value helpers are not
  enough for cross-variant portability; `.2.3.4.2` owns the Perl reference fix. (4) **Receiver-dot mutations
  stay statement-only.** `items.push_back("a")` works as a statement, while value-position/chained forms still
  belong to `.2.3.5`. (5) **Book examples must prefer attached/marker control until parity lands.** Inline
  value `if`/`switch` examples are now labeled Rust-only/pending Perl parity rather than taught as portable.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.3.3.1 — Rust tclite default-mode repetition parity landed):
  Implemented the narrow parity slice that the previous `tclite` retry isolated. Durable points. (1)
  **Default mode is repetition in Rust metadata now.** `RuleMode::Default` participates in the repetition
  family with `rep_min = Some(0)` and no max, so a bare `Top::` / `Rule:` body behaves like the historical
  zero-min repeated-choice model instead of a single optional pass. (2) **Dispatched child entry info is already
  matched by the parent.** Perl action-edge dispatch passes the dependency-regex match into the child handler;
  if the child has `I.return(...)`, that return exits immediately before the child tries to match its entry
  regex locally. Rust now mirrors that preamble-return exit path, restoring the caller's return/match state
  before returning the child value. (3) **The shipped `tclite` minimal fixtures are active again.**
  `tclite_command_subst` and `tclite_double_quote` are in the generated oracle corpus, and the corpus now has
  41 passing fixtures. (4) **One-match tests must say so.** Capture-helper and lifecycle-order tests that were
  only meant to exercise one seek match now use explicit `OR{1,1}` instead of relying on bare default mode as a
  single pass. (5) **Do not overstate lifecycle scope.** Existing tests that expected `I.return(...)`
  to continue into matching/`E` were stale against Perl and were corrected, but this leaf should not be cited as
  a full audit of every lifecycle marker's multi-return control-flow edge.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.3.3 — Rust tclite oracle retry split): Retried `tclite`
  after the fluent blockers were closed, and split before code because the result isolated a different
  mechanism. Durable points. (1) **The retry is now evidence, not conjecture.** Perl returns
  `["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
  `["?tcl_script:",[["?double_quote:",[]]]]` for `""`; the temporarily re-enabled Rust oracle fixtures
  expected those values wrapped one level and got `[]` for both. (2) **Fluent parity is no longer the blocker.**
  Compact lifecycle/body receiver chains and action-edge explicit/flow chains are landed, so the remaining
  `tclite` failure belongs to default-mode recursive repetition/top-level default-rule dispatch. (3) **Keep the
  committed corpus green until the implementation lands.** At this split point the failed fixtures were not
  left in `tests/corpus/`; `.2.3.3.3.3.1` later re-enabled them once the Rust runtime reproduced the Perl
  values. (4)
  **Do not let `tclite` swallow broader recursion work silently.** If implementation shows a wider recursive
  value-parity surface, split it explicitly rather than hiding it inside the fixture re-enable.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.3.2 — Rust action-edge fluent flow chains): Implemented the
  action-edge explicit/flow slice on top of the existing action-edge fluent metadata. Durable points. (1)
  **Continuation ownership is parser-local.** Multiline dotted lines after an action edge now attach to the
  preceding `ActionEdge.fluent_chain`; they are not standalone body fluent elements and therefore cannot be
  dropped by later compilation. (2) **Push remains edge-scoped.** `.push(target)` uses the edge's child rule,
  while `.push(child,target)` makes the same child explicit; both dispatch the child, capture its rule return,
  truncate child accumulator leakage, and append the captured value to the named target array. (3)
  **Flow control reuses the statement-control stack.** `.if/.else/.endif` gates the following fluent calls with
  the same runtime mechanism as structured blocks, and inactive branch calls are skipped before helper
  evaluation. (4) **Ordinary helper calls stay ordinary.** Branch helpers such as `.say(...)` run through
  normal expression/helper evaluation instead of getting action-edge-only cases. (5) **`tclite` is now a
  separate audit.** With compact lifecycle and action-edge explicit/flow fluent surfaces landed, any remaining
  `tclite` divergence belongs to `.2.3.3.3.3` default-mode repetition/oracle re-enable work.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.3.1 — Rust compact lifecycle fluent chains): Implemented the compact
  lifecycle/body receiver-chain slice without adding a second runtime model for standalone body fluent chains.
  Durable points. (1) **Parser normalization is the seam.** A lifecycle marker followed by a receiver chain now
  becomes the same lifecycle statement text as the equivalent block form, for example
  `I.declare(...).set(...).return(...)` becomes `declare(...); set(...); return(...)`. (2) **Compiler/runtime
  reuse is the signoff property.** `compiler.rs` sees ordinary lifecycle `CodeBlock` entries and populates the
  existing `preamble` / `ecode` / marker slots; `engine.rs` executes the already-locked lifecycle statement
  semantics. (3) **Header-line support stays within the current parser contract.** Regex-first inline bodies
  such as `Top:: /x/ I.return(...) E.return(...)` are accepted; broader header-mode ambiguity is left alone.
  (4) **Action-edge explicit/flow chains remain separate.** This does not change `.push(child,target)` or
  fluent `.if(...).push(...).else().return_undef().endif()` execution, which remains `.2.3.3.3.2`.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.3 — remaining Rust fluent continuation split): Split before code because
  three different mechanisms were mixed. Durable points. (1) **Lifecycle/body compact chains are parser/compiler
  work first.** `I.return(...)` and `I.declare(...).return(...)` currently become a lifecycle marker followed by
  standalone `BodyElementKind::FluentChain`; `compiler.rs` drops that standalone element, so `.2.3.3.3.1` owns
  normalizing accepted lifecycle receiver chains into executable lifecycle statement blocks. (2) **Action-edge
  explicit/flow chains are not the no-arg action-edge subset.** `AcodeEntry.fluent_chain` now exists, but
  `engine.rs` only executes no-arg `.push`, `.return(expr)`, and `.return_undef`; `.push(child,target)` and
  `.if(...).push(...).else().return_undef().endif()` need a separate action-edge semantic pass. (3) **Do not
  hide `tclite` behind fluent work.** Re-enable attempts wait until the two fluent surfaces land; any remaining
  default-mode repetition divergence gets its own leaf.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.2 — Rust attached fluent block payloads): Implemented the
  attached-block subset without widening into compact lifecycle/body fluent continuations. Durable points.
  (1) **Normalize to the existing statement-block path.** Rust already knew how to execute attached
  `when/otherwise` blocks, so `-> child.when(cond) { ... }` and `I.when(cond) { ... }` now parse as action or
  lifecycle code blocks rather than introducing another runtime flow model. (2) **Dotted and no-dot fallback
  tails are one contract.** The parser accepts `.otherwise { ... }` and `otherwise { ... }` after the fluent
  `when` head on both action-edge and lifecycle surfaces. (3) **Remainder line ownership matters.** A multiline
  first branch that closes as `}.otherwise {` leaves the fallback opening brace on the previous physical line
  while the parser cursor has advanced; the attached-fluent parser therefore tracks the remainder's origin
  before consuming the next block. (4) **The next Rust fluent parity leaf is still real.** Standalone/body
  fluent chains such as `I.return(...)` are not claimed here and remain `.2.3.3.3`, along with any remaining
  `BodyElementKind::FluentChain` paths the compiler drops.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.3.1 — Rust action-edge fluent continuations): Implemented the
  action-edge subset without broadening into the rest of Rust fluent parity. Durable points. (1)
  **Action-edge fluent continuations need a structured channel.** Rust now carries `-> child .method(...)`
  chains on `ActionEdge` / `AcodeEntry` instead of letting them fall through as standalone `FluentChain` body
  elements. (2) **No-arg `.push` uses the child return channel, not the child's accumulator event stream.** The
  runtime dispatches the matched child, captures that child's rule return, truncates any child return event
  leakage from the shared accumulator, and appends the captured value to the current rule accumulator. (3)
  **Action-edge `.return(expr)` is a close-edge return, not another child dispatch.** The runtime evaluates the
  payload in the current rule/action context and returns through the current rule channel. (4) **The tclite
  oracle exposed later blockers.** Compact lifecycle/body fluent forms such as `I.return(...)` still parse as
  standalone fluent chains the compiler drops, and shipped recursive default rules still need repetition parity;
  both remain follow-on work.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.2 — lifecycle value/drop and return-channel lock): Landed the semantic
  lock without changing runtime behavior. Durable points. (1) **Lifecycle blocks are statement blocks.** A
  final ordinary statement can mutate state, but its value is discarded and is not an implicit rule return.
  (2) **Top-level return is a different channel from expression-block return.** A lifecycle/action
  `return(expr)` writes the surrounding rule/action return channel; `return(expr)` inside an expression-valued
  block remains local to that value block. (3) **Perl and Rust expose different host shapes here.** The Perl
  reference uses host return semantics for top-level lifecycle return. Rust already supports multiple
  top-level lifecycle return events in one block, and existing capture-helper tests rely on that event stream;
  `.2.3.2` documents and locks the value/drop distinction rather than changing that broader runtime contract.
  (4) **All seven lifecycle markers are source-locked.** The phase0 lock covers `I`, `LS`, `LE`, `LX`, `E`,
  `EX`, and `IT`; focused Rust tests cover value discard, top-level lifecycle return event recording, and
  expression-valued block-local return contrast.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3.1 — Perl fluent when/otherwise block-chain lock): Implemented the Perl
  reference lock. Durable points. (1) **True-branch probes can hide fallback parser bugs.** The `.2.3` split
  probes showed `.when(true) { ... }.otherwise { ... }` returning the first branch, but a false condition
  proved the fallback tail had been ignored. The lock now explicitly tests false `when` branches. (2) **The
  fix belongs in bootstrap parsing.** `ActionIR::ControlFlow` already knows how to lower attached
  `otherwise { ... }` once it receives that statement. The missing piece was `BootstrapSpec::Core` preserving
  the fluent attached tail after a method-empty chain. (3) **Dotted and no-dot continuations share one
  contract.** The tail parser now accepts an optional leading dot, recognizes `when` as the attached fluent-if
  head, and treats `otherwise` as an attached fallback tail. (4) **Rust remains separate.** This only locks the
  Perl reference; Rust fluent block-chain/action-edge parity stays `.2.3.3` / `RUST-PARITY.7.5.3`.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.3 — fluent/lifecycle/composability split): Split before code. Durable
  points. (1) **Perl is ahead of the portable contract for fluent block chains.** TOOLBOX descriptor/runtime
  probes show exact action and lifecycle forms like `.when(true) { ... }.otherwise { ... }` already lower with
  `ready=1 raw=0 fallback=0 unresolved=0` and run correctly on the Perl reference. (2) **Rust parity is not
  just another attached-statement parser tweak.** Rust statement attached blocks now exist, but expression
  fluent chains have only `.method(args)` calls, no attached-block payloads, and action/body fluent
  continuation preservation is tied to the existing `RUST-PARITY.7.5.3` gap. (3) **Lifecycle "drop the value"
  needs precision.** Final expression values in lifecycle blocks are not surfaced as block values, while
  explicit `return(expr)` still writes the surrounding rule/action return channel. Lock this before changing
  book wording or semantics. (4) **Composability and method chaining are separate.** Nested helper composition
  works for representative ordinary calls, but receiver-dot array end methods remain statement-only; value
  returning/chained method calls need a design split by return type. Frontier moves to `.2.3.1`.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.6.2 — Rust attached while parity landed): Implemented the Rust parity
  slice. Durable points. (1) **A loop is not another linear statement-control stack.** Attached `if` and
  `switch` can be flattened to marker statements, but `while` must re-enter its body. The Rust parser therefore
  claims `while(cond) { ... }` as one lazy `while` call whose second argument is the parsed body block; the
  runtime intercepts that call at statement execution instead of trying to jump in a flattened statement list.
  (2) **Return semantics split by context.** In lifecycle/action blocks, an active `return(expr)` inside the
  loop stops the current rule-action block after recording the rule return. In expression-valued blocks, the
  same surface remains block-local and returns the block value without leaking to the surrounding rule. (3)
  **The safety contract is mirrored, not inferred.** Rust uses the same deterministic 10000-iteration limit and
  diagnostic string as the Perl reference. (4) **The documented counter-loop pattern exposed a helper gap.**
  Rust already had numeric arithmetic but not the documented `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/
  `num_le` comparisons; `.2.2.6.2` adds that narrow helper family so `while(num_lt(...))` examples are truly
  portable. (5) **Oracle parity advanced.** Fixture `terse_2_2_6_2_attached_while_blocks` brings the Rust
  oracle corpus to 39 fixtures.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.6.1 — Perl attached while loop/safety landed): Implemented the Perl
  reference slice. Durable points. (1) **Emit an owned loop, but avoid diagnostic residue.** The DSL
  `while(cond) { ... }` lowers through ActionIR as a guarded host `for (; cond; )` block so the post-lowering
  unresolved-helper scan does not rediscover a raw `while(...)` token. (2) **The guard is local and
  deterministic.** Each lowered loop receives a unique `__ls_while_guard_N` counter and fails after 10000
  iterations with `LinkedSpec while iteration safety limit exceeded after 10000 iterations`, preventing
  non-terminating parser hangs. (3) **Condition mutation is the semantic lock.** Phase0 now proves a loop whose
  body updates `count` via `set(count,num_add(...))` exits at `3`, so the condition is re-evaluated after body
  statements. (4) **Rust remains next.** `.2.2.6.2` must mirror this accepted loop/safety contract in the Rust
  parser/runtime before the book can call attached `while` portable.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.6 — attached while split/ownership): Split before code. Durable points.
  (1) **This is not a one-file parser tweak.** Perl currently treats attached `while(cond) { ... }` as raw host
  code (`ready=0 raw=1 fallback=1`), while Rust has no attached statement-loop parser/runtime. (2) **The
  contract needs safety, not just syntax.** A DSL loop can be independent of input progress, so the accepted
  contract must include a deterministic iteration guard for non-terminating loops. (3) **Split by reference
  then parity.** `.2.2.6.1` owns the Perl ActionIR loop/safety contract; `.2.2.6.2` mirrors it on Rust after
  the Perl behavior is locked.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.5.2 — Rust attached-switch parity landed): Implemented the Rust parity
  slice. Durable points. (1) **Parser normalization is the Rust seam.** `CodeBlock::parse` now claims only
  one-argument attached `switch(...) { ... }` blocks with attached `case(value) { ... }` / `default { ... }`
  branch bodies, then emits `switch` / `case` / `default` / `endswitch` statements. (2) **Runtime needed a
  switch stack.** Unlike attached `if`, marker switch was not already gated as statements, so the runtime now
  carries `StatementSwitchFrame` state beside the existing if stack in lifecycle blocks and expression-valued
  block evaluation. (3) **The branch contract matches the Perl oracle.** The switch expression is evaluated
  once, cases are first-match, default runs only if no case matched, and inactive branches do not evaluate
  side effects. Use explicit value expressions such as `scalar(kind)` for portable variable-driven subjects.
  (4) **Lazy value-form switch remains separate.** Multi-argument `switch(expr, case(...), default(...))` still
  goes through the lazy helper path and is locked by the existing `cond_switch` tests. (5) **Oracle parity
  advanced.** Fixture `terse_2_2_5_2_attached_switch_blocks` brings the Rust oracle corpus to 38 fixtures.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.5.1 — Perl attached-switch separator/source lock landed): Implemented
  the Perl reference slice. Durable points. (1) **The splitter is the seam.** `StatementSplit::Core` now splits
  complete attached `case(...) { ... }` and `default { ... }` branch bodies before same-line branch
  continuations, letting the existing attached-switch lowerers do the semantic work. (2) **Source residue is
  locked out.** Compact adjacent branches now report `ready=1 raw=0 unresolved=0`, generated handlers do not
  keep host-shaped `case(...)` / `default { ... }` text, and runtime probes cover first-match, later-case, and
  default selection. (3) **The separator contract is unchanged.** A same-line ordinary statement after the
  final attached switch block still needs an explicit semicolon. (4) **Rust remains the next parity leaf.**
  `.2.2.5.2` should parse the accepted attached-switch contract into Rust statement control while preserving
  the existing lazy value-form `switch(...)` helper.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.5 — attached switch split/ownership): Split the attached
  `switch/case/default` leaf before code. Durable points. (1) **Perl is partial, not done.** A simple
  one-case/default attached switch can run, but adjacent branch blocks can leave unresolved `case` residue or
  host-like `default` labels in generated source. (2) **Separator semantics are the Perl reference slice.**
  `.2.2.5.1` should lock adjacent `case/default` block splitting, source output, first-match/default behavior,
  and the same-line statement separator after the final switch block. (3) **Rust parity follows the locked
  contract.** Rust already has lazy value-form `switch(...)` helpers, but attached statement blocks currently
  exist only for `if`/`when` in `CodeBlock::parse`; `.2.2.5.2` should add parser/runtime/oracle parity after
  the Perl source contract is stable.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.4 — when/otherwise landed): Implemented the alias leaf. Durable points.
  (1) **Normalize, do not host-dispatch.** Perl now lowers attached `when(cond) { ... } otherwise { ... }` to
  canonical `if/else`; generated handlers no longer contain host Perl `when`. (2) **Perl needed every recognition
  seam.** Statement splitting, scanner events, contract regexes, and `ControlFlow` all needed the aliases so
  lowering, metadata, diagnostics, and compact same-line branch splitting agree. (3) **Rust stayed parser-only.**
  `CodeBlock::parse` rewrites `when` to `if` and `otherwise` to `else` before the runtime sees statements, so
  `handle_statement_if_control` remains the single branch engine. (4) **Oracle parity advanced.** Fixture
  `terse_2_2_4_when_otherwise_aliases` brings the Rust oracle corpus to 37 fixtures.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.4 — when/otherwise ownership): Owned the `when/otherwise` alias leaf
  before code. Durable points. (1) **Host Perl `when` is explicitly not the contract.** Current generated
  handlers keep raw `when(true) { ... } otherwise { ... }`, emit Perl's experimental-`when` warning, and return
  the wrong branch in the true-condition probe. (2) **This is alias normalization.** `when(cond) { ... }`
  should become the existing attached `if(cond) { ... }`; `otherwise { ... }` should become attached
  `else { ... }`. (3) **Perl has several recognition seams.** Statement splitting, scanner/contract patterns,
  and `ControlFlow` dispatch all currently know `if`/`elseif`/`else` but not `when`/`otherwise`. (4) **Rust
  should stay parser-only.** `CodeBlock::parse` can emit existing `if`/`else`/`endif` statements for attached
  `when/otherwise`; `handle_statement_if_control` should not need a new branch family.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.3 — Rust attached-if landed): Implemented Rust parity for attached-block
  `if/elseif/else`. Durable points. (1) **Parser normalization was sufficient.** `CodeBlock::parse` now claims
  only one-argument attached `if(...) { ... }` / `elseif(...) { ... }` branches and bare `else { ... }`, then
  emits the existing marker-control statement sequence with an implicit `endif`. (2) **Runtime stayed stable.**
  `Engine::handle_statement_if_control` already gates `if` / `elseif` / `else` / `endif` in lifecycle blocks
  and block-value evaluation, so no separate Rust branch runtime was added. (3) **Separator rules still hold.**
  A same-line ordinary statement after the final attached branch still requires `;`; branch continuations are
  the only same-line adjacency accepted by the attached parser. (4) **Existing forms remain invariants.**
  Marker-form `if(cond); ... endif()` and inline-composite lazy `if(...)` are preserved and locked by focused
  runtime tests.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.3 — Rust attached-if ownership): Owned Rust parity before code. Durable
  points. (1) **The parser is the missing seam.** `CodeBlock::parse` handles statement separators and
  expression-valued blocks, but not attached statement branches such as `if(cond) { ... } elseif(cond2)
  { ... } else { ... }`. (2) **Runtime branch gating already exists.** `Engine::handle_statement_if_control`
  gates marker-form `if/elseif/else/endif` in lifecycle blocks and is reused by expression-valued block
  evaluation. (3) **Implementation should normalize, not duplicate.** Attached branches should become the same
  control-flow statement sequence the runtime already understands. (4) **Existing forms are invariants.**
  Inline-composite lazy `if(...)` and marker-form `if(cond); ... endif()` must remain unchanged.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.2 — Perl attached-if landed): Implemented the Perl reference compact
  attached-block `if/elseif/else` slice. Durable points. (1) **This is a splitter change.**
  `StatementSplit::Core` now recognizes a complete attached `if`/`elseif` branch body followed by same-line
  attached `elseif(...) {` or bare `else {` and splits before the continuation. (2) **It deliberately keeps
  marker-chain blockers intact.** Same-line no-semicolon helper chains such as `if(cond) return(...) else ...`
  still do not become implicit statements. (3) **Existing branch lowerers were sufficient.** Once split,
  `ControlFlow` lowers the branch statements and `RewritePipeline` keeps the implicit close open across
  `elseif`/`else`. (4) **Portable docs remain conservative.** The mdBook now notes Perl-reference support, but
  cross-backend portable attached-if waits for Rust parity in `.2.2.3`.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.2 — Perl attached-if ownership): Owned the Perl attached-block
  `if/elseif/else` implementation before code. Durable points. (1) **Attached branch blocks are partially
  implemented already.** Newline-separated `if(cond) { ... }`, `elseif(cond) { ... }`, and `else { ... }`
  statements lower through ActionIR with no raw fallback. (2) **The compact same-line form is the gap.**
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` remains one RAW_PERL statement because the statement
  splitter does not break a complete attached branch before same-line `elseif`/`else`. (3) **The implementation
  seam is the splitter, not a new flow lowerer.** `Scanner::FlowRules` and `ControlFlow` already parse/lower
  individual attached branch statements, and `RewritePipeline` already preserves implicit closures across
  `elseif`/`else` continuations. (4) **Existing branch forms are invariants.** Marker-form
  `if(cond); ... endif()` and inline-composite `if(...)` behavior must remain unchanged.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.2.1 — control-flow keyword surface split): Split Round 2 control flow
  before code. Durable points. (1) **Current portable branch control is narrower than older book wording.**
  Portable today means statement-marker `if(cond); ... elseif(cond); else(); ... endif()` plus inline-composite
  lazy `if`/`switch`; attached-block `if`, `when`/`otherwise`, statement-level `switch`, and `while` are not
  yet cross-backend contracts. (2) **Perl raw execution is not acceptance.** Attached `if(...) { ... }` may
  run on the Perl reference, but descriptor metadata records RAW_PERL fallback and unresolved helpers, so it
  is not language-agnostic ActionIR. `when(...)` rides host Perl's experimental `when` semantics and must be
  replaced with explicit DSL lowering. (3) **Rust has marker and lazy helper support, not attached statement
  blocks.** `Engine::handle_statement_if_control` gates marker-style statements; `call_helper` handles lazy
  inline-composite `if`/`switch`. `CodeBlock::parse` has no attached statement-block AST for Round 2 keyword
  bodies. (4) **Split order follows seams.** Land Perl attached-if first, Rust parity second, then
  `when`/`otherwise`, attached switch/default, and while with progress/iteration safety.

- 2026-06-30 (SPEC-FORMAT-TERSE.2.1.4 — expression-valued block early return landed): Closed the block-local
  return-depth split for expression-valued blocks. Durable points. (1) **Early return is value-block-local,
  not rule-local.** `return(expr)` inside a block value yields `expr` from that block and skips later block
  statements, but it does not set the surrounding rule return channel. The surrounding action must still
  explicitly return or assign the block value. (2) **Perl keeps old byte-stable core output.** Blocks without a
  non-final `return(expr)` still lower as the compact `do { ... final }` form; only early-return blocks use
  the guarded `$__ls_block_done` / `$__ls_block_value` wrapper. (3) **Rust spends the existing return payload
  detector at block-value depth.** `eval_block_value()` now checks `return_call_payload()` for each active
  statement before final-expression handling, evaluates the payload, and returns it directly. (4) **Hash
  precedence remains unchanged.** `{}` and top-level-fat-arrow `{ key => value }` still parse/lower as hash
  literals; only non-empty non-fat-arrow braces are value blocks.

- 2026-06-29 (SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity landed): Implemented Rust parity
  for the Perl core block-value subset. Durable points. (1) **Hash literals still win.** The parser now routes
  `{` through `parse_brace_expr()`: empty payloads and top-level `=>` payloads keep `Expr::HashLiteral`, while
  non-empty non-fat-arrow payloads become `Expr::BlockValue`. (2) **Block values reuse `CodeBlock` without
  changing lifecycle blocks.** `BlockValue` stores a nested `CodeBlock`; lifecycle `execute_block()` still
  returns `()`. (3) **Runtime evaluation is value-specific.** `eval_block_value()` executes side-effect
  statements through the same statement machinery and returns the final expression value; final `return(expr)`
  evaluates only its payload and does not push the rule accumulator. (4) **Early return remains separate.**
  Non-final `return(expr)` is rejected with the `.2.1.4` boundary instead of leaking into the surrounding rule
  return channel. (5) **Historical test locks must follow superseding leaves.** Full Rust package verification
  exposed stale interim expectations from `.1.5.3` and `.1.2.3.5.3`; the live tests now assert no-parenthesis
  helper spellings are rejected under the separator contract and direct shape RHS target-kind behavior belongs
  to `.1.2.3.5.4`.

- 2026-06-29 (SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity owned before code): Recorded
  the Rust implementation boundary before editing Rust. Durable points. (1) **The missing parser seam is an
  expression variant, not lifecycle `CodeBlock`.** `CodeBlock` already parses statement lists for lifecycle
  blocks, while `Expr` has array/hash literals but no block-value form. (2) **Brace disambiguation must keep
  hash literals first.** `parse_expr()` currently sends `{` to `parse_hash_literal()`, which accepts `{}` and
  keyed `=>` entries; non-empty non-fat-arrow braces should become block values rather than weakening the hash
  literal contract. (3) **Runtime needs a value-returning block evaluator.** `execute_block()` intentionally
  returns `()`, so `.2.1.3` should add a block-value path in `eval_expr()` that executes side-effect statements
  and returns the final expression or final `return(expr)` payload. (4) **Return depth stays split.** True
  mid-block early return remains `.2.1.4`; this Rust parity slice should match the Perl core only.

- 2026-06-29 (SPEC-FORMAT-TERSE.2.1.2 — Perl expression-valued blocks landed): Implemented the Perl-reference
  core block-value subset. Durable points. (1) **Hash literals keep precedence.** `_lower_method_value_expr`
  still tries direct `[]` / `{}` shape lowering first; only a non-empty brace payload without a top-level `=>`
  can become a block value. (2) **Block values lower to scalar `do { ... }` expressions.** Side-effect
  statements are lowered through the existing statement lowerers, while the final expression is lowered through
  value-source rules; final `return(expr)` is rewritten to the payload expression and does not emit a handler
  `return`. (3) **Final hash literals need scalar protection inside blocks.** A block final expression like
  `{ key => value }` is emitted as `+{...}` inside the `do` block so nested uses such as
  `array({ set(key,"stage"); set(value,"ok"); { key => value } })` receive one hashref instead of a flattened
  key/value list. (4) **Auto-`my` collection follows the new block final expression.** The collector records
  bare final expressions such as `{ set(x,"a"); x }`, preserving per-invocation lexical working variables.
  Rust parity remains `.2.1.3`; true early return remains `.2.1.4`.

- 2026-06-29 (SPEC-FORMAT-TERSE.2.1.1 — expression-valued block split): Split Round 2 block values before
  code. Durable points. (1) **Brace value syntax is already occupied.** Empty `{}` and top-level-fat-arrow
  `{ key => value }` forms are hash shape literals and must remain so. (2) **Current Perl block-shaped values
  are not usable.** `return({ set(x,"a"); x })` lowers as invalid Perl hash/block source, while
  `set(out, { ... })` takes the direct hash-shape target-inference path and emits malformed aggregate
  assignment. (3) **Rust has a separate missing AST seam.** `CodeBlock` is statement-only; `Expr` has hash and
  array literals but no block-expression variant or evaluator. (4) **Split by reference/parity/return depth.**
  `.2.1.2` owns the Perl reference core, `.2.1.3` owns Rust parity, and `.2.1.4` is reserved for true
  block-local early return if final-only `return(expr)` is not enough.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.6 — array end-mutation methods landed): Added statement-level
  receiver-dot array mutations without changing value-expression semantics. Durable points. (1) **Perl uses
  a top-level receiver-dot splitter, not a broad fluent parser.** `_parse_array_end_mutation_method_statement`
  splits only the top-level dot, protects quoted/nested text, accepts bare / `array(...)` / `a(...)`
  receivers, and delegates the method-call tail to the existing method-expression parser. (2) **The new
  ActionIR node is specific.** The contract/scanner emits `ARRAY_MUTATE` rather than overloading `PUSH`, so
  `pop_*` methods are not mislabeled in canonical metadata. (3) **Auto-declaration follows the lowerer
  oracle.** The collector records one `my @target` for accepted receivers and records push-value scalar reads
  only after the lowerer accepts the statement. (4) **Rust keeps this statement-only.** `Engine::execute_block`
  recognizes a single-call `Expr::FluentChain` with a named array receiver and mutates `RuntimeContext` before
  generic fluent evaluation; nested/value-return forms remain outside this slice.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.5.4 — Rust RHS shape target-kind inference landed): Mirrored the
  accepted Perl `.1.2.3.5.2` target-kind contract on the Rust backend. Durable points. (1) **Shape inference
  is keyed by the raw RHS AST, not the evaluated value alone.** `Engine::direct_shape_literal_kind` only
  classifies direct `Expr::ArrayLiteral` / `Expr::HashLiteral` values, so non-shape expressions that evaluate
  to arrays or hashes do not silently redirect scalar assignment. (2) **Bare and matching typed aggregate
  targets are the only redirected targets.** `items = [value]`, `set(items, [value])`, and
  `set(array(items), [value])` write the runtime array slot; hash shapes mirror that for `meta` /
  `hash(meta)`. (3) **The scalar boundary remains explicit.** `set(scalar(payload), [value])` falls through to
  the existing scalar-target resolver and stores the whole shape payload in scalar `payload`; `array(payload)`
  remains empty in the lock. (4) **RuntimeContext now has whole-aggregate replacement APIs.** `set_array` and
  `set_hash` replace a working aggregate after the RHS shape has been evaluated through the normal expression
  path, matching Perl's assignment semantics rather than append/entry mutation.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.5.3 — Rust shape-literal value parity landed): Mirrored the accepted
  `.1.2.3.5.1` direct shape value contract on the Rust backend without advancing `.1.2.3.5.4`. Durable points.
  (1) **Bracket/brace primaries are values, not access/assignment syntax.** `Expr::ArrayLiteral` and
  `Expr::HashLiteral` are parsed only when `[` or `{` starts an expression; existing `name[index]` direct access
  and `meta[key] = value` statement parsing still own their own bracket sites. (2) **Members reuse normal
  expression evaluation.** Array elements, hash keys, and hash values call `eval_expr`, so primitive literals,
  helper calls, scalar bare reads, direct access, and nested shape literals compose without a second evaluator.
  Hash keys use `RuntimeValue::to_str()`, matching the existing `hash(...)` helper key rule. (3) **Target
  inference remains deliberately absent on Rust.** `name = [value]` stays `AssignScalar` and stores an array
  payload in scalar `name`; `array(name)` remains empty in the boundary lock. `.1.2.3.5.4` owns matching the
  Perl aggregate-target rule. (4) **Oracle fixtures cover only value parity.** The two new corpus cases freeze
  return payloads and mutation RHS slots, not bare-target aggregate inference.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.5.2 — Perl RHS shape target-kind inference landed): Implemented the
  second RHS-shape child by making direct shape literals an assignment target-kind oracle. Durable points. (1)
  **Only bare targets infer from shape RHS.** `name = [value]`, `set(name, [])`, and `assign(name, [value])`
  lower to array assignment (`@name = ...`); `{}` / `{ key => value }` lower to hash assignment (`%name = ...`).
  Explicit wrappers preserve explicit kind, so `set(scalar(name), [value])` remains `$name = [$value]`. (2)
  **Inference reuses the shape lowerer.** `ActionIR::MethodLowering::_infer_direct_shape_literal_kind` first
  checks for a direct outer `[]` / `{}` shape and then delegates acceptance to `_lower_method_value_expr`, so
  target inference cannot accept a different shape grammar than `.1.2.3.5.1` value lowering. (3) **The
  collector must not record stale scalar targets.** `_collect_auto_working_var_decls` no longer records
  `assign/set(NAME, ...)` targets with a broad regex; it parses the call, classifies the source, and records
  `$NAME`, `@NAME`, or `%NAME` to match lowering. Operator assignments use the same helper. (4) **Declaration
  initializer shapes use DSL member lowering too.** `declare(array, items=[value])` and
  `declare(hash, meta={ key => value })` unwrap the lowered shape literal instead of raw payload text, so
  bare members become scoped scalar reads and recognized helpers compose.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.5.1 — Perl shape-literal value expressions landed): Implemented the
  first RHS-shape child as a value-lowering change, not a target-inference change. Durable points. (1) **Shape
  literals are now DSL values on the Perl reference.** `_lower_method_value_expr` recognizes accepted `[]` and
  `{ key => value }` value shapes before generic method-call dispatch, recursively lowering direct shape
  members through primitive literals, scalar bare reads, direct access, nested shapes, and recognized helper
  calls. (2) **Bare hash keys are dynamic.** `{ key => value }` now lowers as `{$key => $value}`; fixed object
  fields must be quoted (`{ "kind" => value }`). Existing return-payload tests with bare keys were updated to
  the new contract. (3) **Collector coverage follows the same shape oracle.** `_collect_auto_working_var_decls`
  records scalar bare reads only for shapes accepted by the lowerer, including shape literals in return payloads,
  assignment sources, append RHS values, hash-index RHS values, and push/set value slots. (4) **Target inference
  stayed separate at this leaf.** `.1.2.3.5.2` later accepted aggregate target inference for direct RHS shapes.
  Rust shape-literal parity stays `.1.2.3.5.3`.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.5 — RHS-shape/type-inference split): Split the remaining Channel 2
  shape work before code. Durable points. (1) **Raw empty shapes are not target inference.** Perl accepted
  `[]`/`{}` at split time by passing them through as arrayref/hashref value expressions, so `name = []` writes
  scalar `$name`; aggregate mutation slots such as `items += []` and `meta[key] = {}` still use separate `@items` /
  `%meta` state. (2) **Non-empty shapes needed a DSL lowerer first.** `[value]` and `{ key => value }`
  passed raw Perl barewords/strings at split time, so they did not compose with the `.1.2.3.3/.4` scalar
  bare-read contract before `.1.2.3.5.1`.
  Implementing target inference before expression-aware shape literals would bake in the wrong semantics.
  (3) **Rust parity has two obligations.** Rust cannot parse bracket/brace value primaries today; first mirror
  accepted shape-literal values, then mirror whatever target-kind inference the Perl reference adopts. (4)
  **Keep bracket/brace sites separated.** Direct access, hash-index assignment, future block braces, helper
  calls, and all-bare child-call routing must stay explicit boundaries for the `.1.2.3.5.x` children.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.4 — Rust scalar bare-read parity landed): Closed the Rust lockstep
  leaf for the accepted scalar Channel 2 read contract. Durable points. (1) **The runtime already had the
  scalar semantics.** `Expr::Variable` evaluates through `ctx.get_scalar(name)`, so source-slot bare reads,
  mutation key/RHS bare reads, and direct-access bare path atoms all needed parser acceptance and regression
  locks, not a second runtime dispatch path. (2) **Remove only obsolete reservations.** The Rust parser now
  allows bare RHS/key variables in `items += value` and `meta[key] = value`, and bare index variables in
  multi-segment direct access such as `foo["a"][idx]`; one-level `name[index]` still stays the legacy
  `IndexedVar` shape. (3) **Keep the next seam explicit.** RHS-shape `[]`/`{}` inference is still not
  implemented by this leaf and is now tracked as `SPEC-FORMAT-TERSE.1.2.3.5`; all-bare `push(A,B)` remains
  child-call routing.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.3.3 — direct-access bare path atoms landed): Closed the Perl scalar
  direct-access child with the scalar-index rule stated explicitly. Durable points. (1) **Bare path atoms are
  indexes, not hash keys.** In direct nested access, quoted segments remain hash keys; numeric, helper, and
  non-reserved bare segments are array indexes. Therefore `foo["a"][z]` is the terse form of
  `foo["a"][scalar(z)]`, not `foo["a"]["z"]`. (2) **Use the direct lowerer as the collector oracle.**
  `_collect_auto_working_var_decls` only records bare path atoms after `_lower_direct_nested_access_value_expr`
  accepts the whole expression, so reserved literals/engine locals and raw fallback shapes do not gain
  accidental `my` declarations. (3) **Assignment source lowering must prefer real method-value changes before
  flow fallback.** Direct access in `set(out, foo["a"][z])` needs the changed method-value result before a
  generic flow/source path can hand back the raw source. (4) **`scalaref(...)` compatibility is unchanged.**
  `scalaref(foo,{"a"}[z])` keeps its historical `[z]` path atom; use `[scalar(z)]` in that helper when a scalar
  working-variable index is intended. Rust parity landed later under `.1.2.3.4`.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.3.2 — mutation-slot bare scalar reads landed): Implemented the second
  scalar Channel 2 child by changing only accepted mutation key/RHS seams. Durable points. (1) **Do not
  broaden `_lower_method_value_expr`.** The new `_lower_mutation_slot_value_expr` is called only by
  statement-level array append, statement-level `set_key`, and hash-index assignment operator lowerers, so
  generic helper arguments and all-bare `push(A,B)` disambiguation stay stable. (2) **Scanner guards must move
  with lowerer guards.** `PrimitivePipelineRules` now recognizes bare RHS/key mutation statements for canonical
  ActionIR, but still avoids reserved nonliteral engine locals such as `CAPTURE` as mutation values. (3)
  **Every `$NAME` read has a collector peer.** `_collect_auto_working_var_decls` uses the lowerers as the
  acceptance oracle before adding `@target` / `%target` plus scalar key/RHS `my` declarations, deduping against
  explicit declarations and wrappers. (4) **The remaining scalar leaf is direct path atoms.** `foo["a"][z]`
  still stays raw while `foo["a"][scalar(z)]` works; `.1.2.3.3.3` owns that key-vs-index rule.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.3.1 — source-slot bare scalar reads landed): Implemented the first scalar
  Channel 2 child by changing only the source-slot seams. Durable points. (1) **The lowering hook is scoped.**
  `_lower_return_payload_expr` handles `return(NAME)` and `_lower_assignment_source_expr` handles
  `set/assign(out, NAME)` plus `out = NAME`; `_lower_method_value_expr` remains unchanged, so helper arguments
  do not silently become scalar reads. (2) **Every new `$NAME` read must be paired with collector coverage.**
  `_collect_auto_working_var_decls` now scans raw action blocks for return payload bare names, set/assign source
  bare names, and scalar-operator RHS bare names, then dedups against wrappers/declares and reserved names.
  (3) **Literal exactness now composes with scalar reads.** `true`/`false`/`undef` stay primitive literals, but
  prefix identifiers like `trueword` and `undefine` are no longer raw barewords in supported source slots; they
  read `$trueword` / `$undefine`. (4) **The split boundaries were locked at this leaf.** Mutation key/RHS slots
  advanced later in `.1.2.3.3.2`; direct `[z]` and all-bare `push(A,B)` remain separate.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.3 — Perl scalar bare reads split by lowering seam): Split the scalar
  Channel 2 owner before code. Durable points. (1) **Do not add a generic "bare word means scalar" fallback to
  `_lower_method_value_expr`.** That helper is used by many nested/value helper arguments; broadening it would
  silently change more than the accepted scalar slots and risks all-bare disambiguation such as `push(A,B)`.
  (2) **Return/assignment source slots are the first safe seam.** `return(count)`, `set(out,count)`, and
  `name = value` currently fall through to raw barewords and can be scoped through their return/source lowerers
  plus a scalar auto-`my` collector pass. (3) **Mutation key/RHS slots are separate because their acceptance
  gates differ.** `set_key(meta,key,"v")` already gets `$key` through `_lower_scalar_access_key_expr`, but
  `set_key(meta,"stage",value)` leaves the value raw; `items += value` and `meta[key] = value` are blocked by
  scanner/lowerer guards before the scalar lowerers can run. (4) **Direct `[z]` remains its own rule.** Direct
  access explicitly rejects bare path atoms, while `[scalar(z)]` works; the `[z]` leaf must state the
  scalar-index rule instead of inheriting it accidentally. No behavior changed in the split slice.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.2 — Rust aggregate bare value-read parity landed): Closed the Rust
  lockstep leaf by changing only aggregate-copy target resolution. Durable points. (1) **The parity gap was the
  call-site gate, not the parser.** `Expr::Variable` already evaluates as a scalar read in Rust, so broadening
  expression evaluation would have advanced the wrong Channel 2 surface. The safe change is narrower:
  `array_copy`/`hash_copy`/`copy` now pass `allow_bare=true` to aggregate target resolvers only where the Perl
  reference already treats the helper as a type-implying aggregate snapshot read. (2) **`copy(NAME)` remains
  array-first by construction.** The `copy` fallback resolves an array target before trying a hash target; a
  bare `copy(items)` therefore means array copy, while `copy(hash(meta))` is the explicit hash form. (3)
  **Scalar and direct-access Channel 2 boundaries stay intact.** No parser rule changed in that aggregate
  leaf; scalar-like bare reads stayed deferred until the later `.1.2.3.3` Perl and `.1.2.3.4` Rust leaves.
  (4) **Freeze both hand-written and oracle evidence.** The slice adds 4 integration
  locks plus 4 Perl-oracle fixtures; corpus oracle now covers 25 fixtures and the full runtime suite stays green.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3.1 — Perl aggregate bare value-read auto-existence landed): Extended the
  existing auto-working-variable collector instead of adding a separate pass. Durable points. (1) **Aggregate
  snapshot helpers are the only new value-read inference surface here.** `array_copy(NAME)` and array-first
  `copy(NAME)` imply an array working var; `hash_copy(NAME)` implies a hash working var. These forms already
  lower to `[@NAME]` / `{%NAME}` on Perl, so the safe fix is only to supply the missing `my @NAME` / `my %NAME`
  preamble. (2) **The collector stays conservative.** It scans literal-masked raw action blocks, skips reserved
  DSL/engine names, and dedups against wrapped references, mutation targets, accumulator arrays, and explicit
  declarations. Wrapped forms such as `array_copy(array(items))` and declared forms keep one declaration. (3)
  **Do not broaden this to scalar Channel 2 by regex drift.** `return(NAME)`, `items += value`, `meta[key] =
  value`, and bare direct-access atoms such as `[z]` remain pending scalar bare-read work. (4) **Rust parity is
  still separate.** `.1.2.3.2` must decide/update Rust aggregate target resolution so `array_copy(items)`,
  `hash_copy(meta)`, and `copy(items)` match the Perl reference without advancing scalar bare reads.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.2.3 — Channel 2 split by aggregate/scalar value-read surfaces): Split the
  broad Channel 2 owner before code. Durable points. (1) **Aggregate bare reads are already partially
  implemented on Perl, but unsafely.** `array_copy(items)`, `hash_copy(meta)`, and `copy(items)` lower to
  `[@items]`, `{%meta}`, and `[@items]`, but generated source does not auto-declare `my @items` / `my %meta`,
  so an undeclared bare aggregate read is still a non-strict package-global hazard. This is the first safe
  Perl leaf: add the missing preamble declarations without changing wrapped/declared specs. (2) **Rust is not
  lockstep for aggregate bare reads yet.** Its aggregate-copy resolvers pass `allow_bare=false` for value-read
  positions, so bare `array_copy(items)`/`hash_copy(meta)` do not name the working aggregate the way Perl's
  current lowering does. That becomes a separate parity leaf. (3) **Scalar bare reads are a different
  surface.** Perl still emits `return count` / `$out = count` / raw `items += value` / raw `foo["a"][z]`,
  while Rust already treats `Expr::Variable` as `ctx.get_scalar(name)`. Do not bundle scalar read semantics
  with aggregate auto-existence; it needs its own Perl reference + Rust parity pair. (4) **RHS-shape `[]`/`{}`
  inference is later.** It depends on the read semantics landing first and is not pre-published as an ID in
  this split.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5.5.2 — bare direct access merged into Channel 2): Closed the
  direct-access coordination leaf without code. Durable points. (1) **Do not special-case `[z]` inside direct
  access.** Reverify after `.1.5.5.1` showed `foo["a"][9]["b"][scalar(z)]` lowers, but `foo["a"][9]["b"][z]`
  remains raw and `return(z)` remains a bareword. Those are the same value-position bare-word-read problem.
  (2) **Channel ownership matters more than local convenience.** A direct-access-only rule for `[z]` would
  choose scalar/array/hash and key-vs-index semantics before the global Channel 2 design decides how bare
  names behave in return payloads, RHS expressions, hash keys, and helper value slots. (3) **The next safe
  slice is `.1.2.3`, not code in `.1.5.5.2`.** `.1.2.3` now owns the design/split for value-position
  bare-word reads + RHS-shape/type inference across Perl and Rust. Verification: TOOLBOX lowering reverify,
  Rust parser rejection lock, KM/memory/doctrine/diff checks.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5.5.1 — explicit direct nested access landed): Implemented the safe
  direct-access subset on both variants. Durable points. (1) **Direct access reuses the settled explicit-path
  semantics.** Perl routes `foo["a"][9]["b"][scalar(z)]` through a new ValueExpr lowerer and emits the same
  dereference chain as `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])`. Quoted segments are hash keys; numeric and
  helper/value segments are array indexes. (2) **Rust keeps legacy one-level indexing intact.** A single
  non-key `name[index]` remains `IndexedVar`; mixed/multi-segment explicit paths become `NestedAccess` with
  key/index segments and are evaluated from the scalar-held base payload. (3) **Channel 2 is still cleanly
  separated.** Bare direct-access atoms (`[z]`, `[key]`) are rejected/deferred rather than treated as scalar
  reads. Use `[scalar(z)]` today. `scalaref(...)` remains an accepted explicit helper, not a retired form.
  Verification: phase0, focused Rust parser/runtime locks, oracle corpus 21 fixtures, full Rust runtime,
  mdBook, KM, memory/doctrine, and local CI gates.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5.5 — split direct nested access before code): Grounded the then-open direct-access
  leaf with KM + TOOLBOX and split it by the Channel 2 boundary. Durable points. (1) **Direct bracket syntax is
  not automatically the existing `scalaref` path.** At split time, `foo["a"][9]["b"][scalar(z)]` emitted invalid
  Perl-shaped code, while `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` lowered correctly to the dereference chain.
  The explicit direct form is now implemented by `.1.5.5.1`; this split note explains why it was separated
  first. (2) **Bare path
  atoms are the same hard problem as bare value-position reads.** The final `[z]` in the brainstorm spelling is
  not a variable read today; it remains a bare atom just like the known `return(count)` gap. (3) **The first
  implementation slice should avoid smuggling Channel 2 in sideways.** `.1.5.5.1` will implement and lock
  explicit path segments; `.1.5.5.2` will coordinate the bare-segment semantics with the broader Channel 2
  value-position-read model. No engine/book behavior changed in the split slice.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5.4 — statement separators are newline-or-semicolon, not arbitrary
  whitespace): Landed the separator contract on Perl and Rust. Durable points. (1) **Statement detection and
  emitted-code validity are separate responsibilities.** `StatementSplit` now only creates implicit boundaries
  across line breaks, while `RewritePipeline` inserts the missing generated Perl `;` when two lowered canonical
  statements were newline-separated in source. (2) **Same-line adjacency remains an explicit blocker.**
  `set(name,"a") return(scalar(name))` is kept raw on the Perl reference and rejected by the Rust parser; this
  preserves the requirement that multiple statements on one physical line use semicolons. (3) **Nested
  semicolons stay protected.** Payloads such as `return(do { my $x = 1; $x })` remain one statement, and a
  following newline is the outer separator. (4) **Attached-control sugar needed normalization, not a splitter
  loophole.** Bootstrap now joins captured fluent `if(...) { ... } elseif(...) { ... } else { ... }` tails with
  internal newlines, so the conventional user-facing attached-control form keeps working while ordinary
  same-line helper adjacency stays non-canonical. Verification: phase0 982, oracle corpus 20 fixtures,
  focused Rust parser/runtime tests, corpus oracle 20 fixtures, full Rust runtime, mdBook, Knowledge Map,
  memory/doctrine, and local CI gates.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5.3 — call spacing is a grammar lock, not a new call shorthand):
  Locked the call-spacing contract on Perl and Rust. Durable points. (1) **The call grammar remains
  `callee(args)`.** Whitespace before `(` is only layout; `set (name, value)` and `set(name, value)` are the
  same helper call at supported statement/value sites. (2) **Do not use spacing support to smuggle in
  no-parenthesis calls.** `set name,"v"`, `return scalar name`, and `return(cat "a","b")` stay outside the
  helper-call surface, preserving room for the statement-separator and Channel 2 designs. (3) **Lock both
  statement and nested expression sites.** The regression covers return/set, nested `cat`/`scalar`/`array`,
  operator RHS calls, hash-index key/RHS calls, runtime typed output, and canonical IR metadata. (4) **Rust
  needed parser/runtime/oracle locks, not a semantic change.** The existing parser already allows whitespace
  before `(` in call parsing; the new unit/integration/oracle tests freeze that behavior against the Perl
  reference. Verification: phase0 981, oracle corpus 19 fixtures, focused Rust parser/runtime tests, corpus
  oracle, mdBook, Knowledge Map, doctrine/memory, and local CI gates.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5.2 — primitive literals are typed values, not identifiers with special
  prefixes): Landed primitive literal parity on Perl and Rust. Durable points. (1) **Literal recognition must
  be exact.** `true`, `false`, and `undef` are literals; `trueword` and `undefine` are not. This keeps the
  future Channel 2 bare-value-read design from being pre-empted by a prefix match. (2) **Perl booleans must be
  JSON booleans.** Lowering uses `JSON::PP::true` / `JSON::PP::false`, so public JSON output is `true`/`false`
  rather than `"true"`/`"false"`. (3) **Scanner and lowerer disambiguation must share the literal boundary.**
  `push(items,false)` is a value append, while `push(items,trueword)` stays the historical all-bare child-call
  form. `items += false` and `meta[true] = false` use the same exact-literal rule. (4) **Rust already had typed
  literal expressions, but not statement-form branch gating.** The parity fix is a statement control stack in
  `Engine::execute_block()` for `if(cond); elseif(cond); else(); endif()` marker statements; the existing
  multi-argument lazy `if(cond,then,else)` helper remains separate. A pre-existing nested-hash-constructor
  flattening issue was deliberately kept out of scope by returning `[flag, items, hash]` in the parity fixture.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.5 — split before code; literals, calls, separators, and access are
  separate seams): Grounded `.1.5` with KM/TOOLBOX/code-read and split it before implementation. Durable
  points. (1) **Primitive literals need a parity leaf, not just locks.** Perl currently returns `true` and
  `false` as bareword strings, while Rust has `BooleanLiteral`; typed boolean semantics must be made explicit
  before later leaves rely on them. (2) **Call spacing is mostly a lock leaf.** The method parser accepts
  whitespace before `(` at supported sites (`return (x)`, `set (name,x)`, nested `cat (...)`, wrapped
  `scalar (...)`) while no-paren calls remain out of scope. (3) **Statement detection and statement emission
  are different seams.** `StatementSplit` can identify newline-separated DSL statements, but Perl lowering
  still emits `$name = "a"\nreturn $name`, which does not compile; Rust currently accepts even broader
  whitespace-separated statements. The separator leaf must define and enforce "newline separates statements;
  same-line multiple statements require semicolon" across variants. (4) **Direct nested access is not
  `scalaref` with prettier punctuation yet.** Existing `scalaref(foo,{"a"}[9]{'b'}[scalar(z)])` lowers on
  Perl, but direct `foo["a"][9]['b'][z]` is raw on Perl, and Rust only has a single array-index `IndexedVar`.
  That leaf must coordinate with Channel 2 value-position bare-word reads.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3.4.3 — hash-index assignment is direct hash mutation with explicit
  key/value expressions): Landed `name[key] = value` on Perl and Rust. Durable points. (1) **Match the settled
  `set_key` statement contract, not the pure helper.** Top-level `NAME[KEY] = VALUE` mutates the named working
  hash directly, equivalent to `set_key(NAME, KEY, VALUE)`; nested/value-form `set_key(hash_expr, KEY, VALUE)`
  remains a pure copy helper. (2) **Auto-existence belongs to the target only.** The bare LHS `NAME` implies a
  hash target (`my %NAME` on Perl; per-parse hash map on Rust). (3) **Do not let the index syntax create
  Channel 2 early.** Accepted forms keep the key and RHS explicit: string literals, helper expressions, and
  wrapped working-variable reads (`scalar(key)` / `scalar(value)`). Bare `NAME[key] = "v"` and
  `NAME["k"] = value` remain reserved until value-position bare-word reads are designed. (4) **Parser support
  must be quote/nesting-aware.** A key such as `cat("s","tage")` contains commas and nested parentheses; the
  scanner/lowerer parses brackets and assignment boundaries instead of regex-splitting blindly. Verification:
  phase0 979, focused Rust core/runtime tests, corpus oracle 16 fixtures, mdBook, Knowledge Map, doctrine/
  memory, and local CI gates.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3.4.2 — array `+=` is a statement append, not a bare-RHS read): Landed
  `items += value` on Perl and Rust for explicit RHS expressions. Durable points. (1) **Reuse the settled
  append contract instead of inventing a second one.** Perl recognizes `NAME += RHS` through its own PUSH
  contract/scanner/lowerer and emits the same `push @NAME, RHS` as accepted `push(NAME,RHS)` /
  `push_value(NAME,RHS)` shapes; Rust models it as statement-only `Expr::AssignArrayAppend` and appends through
  `RuntimeContext::push_value`. (2) **The target is array-position auto-existence.** A bare LHS `items`
  auto-supplies one `my @items` on Perl; Rust uses the per-parse array map. (3) **Reject bare RHS deliberately.**
  `items += scalar(value)` is accepted; `items += value` is left untouched on Perl and rejected by the Rust
  statement parser because Channel 2 still owns bare value-position working-variable reads. (4) **Keep operator
  family boundaries crisp.** Increment-like `items ++`, scalar `name = value`, hash-index `name[key] = value`,
  and child-call `push(A,B)` stay separate. Verification: phase0 978, focused Rust core/runtime tests, corpus
  oracle 15 fixtures, mdBook, Knowledge Map, doctrine/memory, and local CI gates.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3.4.1 — scalar assignment is a statement boundary, not an expression
  shortcut): Landed `name = value` on Perl and Rust. Durable points. (1) **Parse the operator only where it is
  a target-position statement.** Perl recognizes `NAME = RHS` through its own ASSIGN contract/scanner/lowerer;
  Rust models it as statement-only `Expr::AssignScalar` and rejects it from nested `eval_expr`. That keeps
  `helper(name=value)` keyword args, equality, append, and hash-index assignment out of this leaf. (2) **The
  declaration collector must learn operator targets too.** Lowering `$name = ...` without adding `my $name`
  would revive the same non-strict generated-handler leak that `.1.1.1` fixed; the scalar target is therefore
  auto-declared exactly once. (3) **Operator syntax must not smuggle in Channel 2.** The RHS still uses the
  already-supported expression/lowering paths, while bare value-position reads remain pending. (4) **Rust
  parity needs both parser and executor locks.** Parser tests enforce the narrow syntax (`==`, `+=`,
  `name[key]=...` rejected/out of scope), and runtime tests prove `name = cat(...)` matches `set(...)` and does
  not leak across parses. Verification: phase0 977, oracle corpus 14 fixtures, focused Rust core/runtime tests,
  full Rust runtime suite, mdBook, Knowledge Map, doctrine/memory, and local CI all pass.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3.4 — operator syntax is not one implementation seam; split by target
  mutation): Split the operator family before coding. Durable points. (1) **The function forms now define the
  contract; operators should lower to those contracts one at a time.** Scalar `name = value` maps to
  `set(name,value)`, array `items += value` maps to the conservative `.1.3.2` append contract, and hash
  `name[key] = value` maps to `.1.3.3` `set_key(name,key,value)`. (2) **Perl and Rust fail for different
  structural reasons.** Perl sees all three as RAW_PERL blockers; Rust cannot parse/execute them because
  lifecycle code is `Stmt { expr }` only. Scalar assignment is the right first leaf because it can introduce
  minimal statement support without also solving append disambiguation or hash-index assignment. (3) **Do not
  let operator syntax smuggle in Channel 2.** `.1.3.4.1` must not make bare value-position reads broadly work;
  `.1.3.4.2` inherits the explicit bare-value boundary from `.1.3.2`; `.1.3.4.3` should stay equivalent to
  settled `set_key(...)`.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3.3 — `set_key` is intentionally position-sensitive: statement form mutates,
  value form stays pure): Landed the hash mutation spelling. Durable points. (1) **Keep mutation and value
  helpers separate by syntactic position.** Top-level `set_key(name,key,value)` is now a statement mutation,
  but nested `set_key(hash_expr,key,value)` remains a copy-valued expression. Collapsing those would make
  expression evaluation order observable and would break the existing pure helper contract. (2) **Event-driven
  Perl lowering needs all three sites.** Adding a contract entry alone is not enough; the scanner must emit the
  ASSIGN event, and the auto-working-var collector must learn the same bare hash target so generated handlers
  get one preamble `my %name`. (3) **Rust mirrors the statement boundary before generic expression eval.**
  `Engine::execute_block()` handles top-level `set_key(...)` first and mutates the named hash; `call_helper`
  keeps serving nested pure value calls. (4) **Dependency-surface fixtures are part of the contract.** Adding a
  new contract lowering dependency required the owner-dispatch synthetic fixtures to expose
  `_lower_set_key_statement`; otherwise phase0 catches the missing dep callback even when the real lowering
  works. Verification: phase0 976, focused Rust, corpus oracle 13 fixtures, mdBook, Knowledge Map,
  memory-architecture, doctrine checks, and full local CI gate all pass.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3.2 — the `push` alias is valid only after the child-call convention wins
  its ambiguous cases; parse balanced calls before auto-declaring array targets): Landed the array function
  spelling. Durable points. (1) **Do not treat `push` as a flat alias of `push_value`.** The DSL already has a
  live child-call family: `push(Child)`, `push(Child,target)`, and indexed variants. Therefore `push(A,B)` must
  keep child-call meaning, not silently become "append variable B into A". The safe contract is `push(target,
  value)` only when the value expression is unambiguous/non-all-bare; working-variable values still need an
  explicit read such as `scalar(value)`. (2) **Lowering and declaration
  collection need the same disambiguation.** The statement contract/scanner/lowering can skip all-bare
  `push(A,B)`, but the auto-`my @target` collector must also skip it or it would invent an accumulator for a
  child-call target. (3) **Do not regex-split function arguments when the DSL allows nested helpers.**
  `push(items, cat("a","b"))` contains a comma inside the value expression; the collector therefore uses the
  method-call parser to read balanced `push(...)` calls and then checks exactly two args. The source-dump lock
  asserting one `my @items` on that nested value protects the bug class. (4) **Rust parity can be "already
  implemented" but still needs a reference lock.** Rust already dispatched `"push"` through the `push_value`
  arm, but the reference contract now defines the disambiguation. The new oracle fixture + integration test
  lock Rust's accepted shape without letting Rust's broader alias decide the Perl/user-facing contract.
  Verification: phase0 975, focused Rust, corpus oracle 12 fixtures, mdBook, Knowledge Map, memory-architecture,
  and full local CI gate all pass.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.3 — a mutation surface with two spellings per operation is still multiple
  mechanisms; the dangerous part is `push`, because the desired terse spelling overlaps an intentionally-live
  child-call convention): Split `.1.3` instead of coding. Durable points. (1) **Audit what prior leaves already
  closed before adding code.** `set(name,val)` is not new work anymore: `.1.4.1` added `set` to the Perl
  statement recognizers and `.1.4.2` added the Rust alias. Fresh probes confirm `set(name,"ok")` and
  `assign(name,"ok")` both lower to `$name = "ok"` and a minimal parser returns `"ok"`. `.1.3.1` can be
  closed as an audit, not another implementation. (2) **`push(name,value)` is a syntax collision, not just a
  missing alias.** The live Perl surface already uses `push(Rule)`, `push(Rule,target)`, and indexed variants
  for child calls; the accumulator KM card says that convention is intentional, not debt. A two-bare-word form
  can mean "call rule `Item` into target `items`" or "append variable `item` into array `items`" without a
  disambiguation rule. Today `push_value(items,"a")` lowers/runs, while `push(items,"a")` passes through as raw
  Perl and fails handler compilation. Rust is already ahead here (`"push_value" | "push"`), so the Perl
  reference/policy must decide the contract before Rust behavior is treated as canonical. (3) **`set_key` has a
  pure-value form but not a statement mutation form.** Perl `return(set_key(name,"k","v"))` can return a hash
  value because hash symbol extraction accepts the bare name in that value path; standalone
  `set_key(name,...)` does not lower as a mutation statement. Rust only updates if arg0 is already a
  `RuntimeValue::Hash`. That is its own leaf and likely intersects Channel 2 bare value-position semantics.
  (4) **Operators are a parser/AST feature.** `name = "ok"`, `items += "a"`, and `name["k"] = "v"` pass through
  as raw/invalid Perl, and Rust `CodeBlock` parses only expression statements (`call`, variable, indexed var,
  literal, fluent chain). Operator support needs explicit statement forms on both variants; it should follow
  the function-form contract, not invent it. No engine/book change; KM card added; next frontier `.1.3.2`.

- 2026-06-29 (SPEC-FORMAT-TERSE.1.4.2 — Rust parity for a Perl helper rename must still respect the Rust
  runtime's value model; `copy` is a dispatching helper, not a repeatable match literal): Brought the Rust
  runtime to lockstep parity for the `.1.4.1` helper renames. Durable points. (1) **`set` and `cat` are real
  aliases in Rust; `copy` is not.** The clean Rust implementation mirrors the Perl split: `set` pipes onto
  `assign`, `cat` pipes onto `concat`, but `copy` gets a dedicated arm because a Rust `match` literal cannot
  appear in both `array_copy` and `hash_copy`, and because `copy` must preserve value kind. The arm clones
  materialized `Array`/`Hash` values and only falls back to target-name resolution for wrapped target forms.
  (2) **Hash target resolution needed its own resolver, not reuse of the array resolver.** Reusing
  `resolve_array_target` in `hash_copy` was enough for empty-value smoke paths but was semantically wrong for
  `h(name)`/`hash(name)` as a named hash target. The new `resolve_hash_target` mirrors the array resolver for
  hash wrappers, and the `hash`/`h` helper now treats a single bare variable as a runtime hash reference. That
  makes `copy(h(m))`, `hash_copy(h(m))`, and materialized `copy(hash("k","v"))` converge without changing
  Channel 2 bare value-position reads. (3) **The oracle stays in the divergence-free proof class.** The two new
  fixtures use non-recursive parent-edge specs and action-less children, like the earlier cross-variant cases,
  so `corpus_oracle` can compare Rust directly against the Perl reference values. Integration tests cover the
  properties the one-shot oracle cannot: canonical-vs-terse equality and per-parse target isolation. (4)
  **Zero-new warnings is part of parity signoff.** `cargo clippy` exits 0 with the existing 13-warning baseline
  only; no new slice warnings were left behind. Verification: generator syntax OK; oracle regeneration OK;
  focused `terse_1_4_2` tests PASS; corpus oracle PASS over 11 fixtures; full Rust runtime suite PASS (116 unit
  + 36 integration + oracle harness); phase0 975 green; full local gate EXIT 0. No book change; `.1.4` closed
  and next frontier is `.1.3`.

- 2026-06-24 (SPEC-FORMAT-TERSE.1.4.1 — a helper alias must be recognized at EVERY layer its canonical name is, not just the one seam the headline probe exercises; the isolated form passing is a false "done," and only probing the *composed* positions surfaces the rest): Implemented the Perl-reference renames `set`≡`assign`, `cat`≡`concat`, unified `copy`≡`array_copy`/`hash_copy`. Durable points. (1) **The headline-form probe is necessary but dangerously insufficient.** After adding the three "shapes" the split pass prescribed (`_normalize_method_name` for `cat`; the `assign_value` statement contract for `set`; a `copy` value-expr dispatch), the 4 headline `call_spec_handler_subst` forms all matched — yet `set(x, cat(a,b))`, `assign(x, copy(a(y)))`, and `assign(hash(h2), copy(h(m)))` still emitted raw un-lowered `cat(...)`/`copy(...)` (invalid Perl). The engine recognizes each canonical helper at *several disjoint* layers — value-expr dispatch, the assignment-SOURCE path (`FlowExpr` prefix list + `_lower_declare_initializer_expr` for array/hash targets, which even emit a *different* shape: hash source → `(%m)` list, not `{%m}`), the return-payload guard+rewriter, the bootstrap general-payload gate, and the array-vs-hash *type-inference* recognizers (`looks_like_{array,hash}_value_expr`, gating `num_sum`/`coalesce`). A `grep` for every literal occurrence of `concat`/`array_copy`/`hash_copy` + a per-occurrence "does the alias belong here?" pass is the only way to find them all; the probe sweep over *composed* forms (assignment source, push value, nested payload, reducer) is what proves you found them. (2) **The contract is event-driven, so extending the contract regex alone does nothing — extend the SCANNER.** `set` wouldn't lower even after `Contracts.pm`'s `assign_value` pattern accepted it, because the rewrite pipeline lowers from *scanner events* (`Scanner/PrimitivePipelineRules::_scan_contract_assign_value`, raw `\bassign\s*\(`); no event → the contract's `lower` never runs. Recognition and lowering are separate seams; both must learn the alias. (3) **`copy`'s type-ambiguity forbids the flat-method-set fix and demands kind RESOLUTION.** Adding `copy` to both the array- and hash-`looks_like` method-sets would double-classify it and break `coalesce`'s array-vs-hash disambiguation (it returns 0 on seeing a hash-like arg in array context). The correct fix mirrors the lowering dispatch: in each `looks_like` recognizer, resolve `copy(X)`'s kind by the wrapped symbol (array-first), so `copy(a(x))` is array-only and `copy(h(m))` hash-only — never both. (4) **Guard every alias-add by the NEW spelling so the byte-identity proof is structural, not just empirical.** Every edit triggers only on `set`/`cat`/`copy`, none of which any shipped spec uses — so the all-20-spec generated-source diff is *guaranteed* 0, and the broad `looks_like` edits carry zero corpus-regression risk by construction (re-confirmed: 0 diff, phase0 971→975 green). (5) **The decisive lock is end-to-end, not just string-equality.** Beyond `call_spec_handler_subst` parity (lowered strings equal) and the ASSIGN-node descriptor check, a real terse spec (`set`+`cat`+`copy`) compiled and *ran* byte-identical to its canonical twin (`["a!","b!","c!"]`, stable across a re-run) — proving the generated code executes, not just that two rewrites print the same text. `perl -c` on all 8 modules; gate EXIT 0 (975); `mdbook build` EXIT 0; book 3 pages; KM card updated (reverify now proves parity). Next: `.1.4.2` (Rust `Engine::call_helper()` lockstep parity).

- 2026-06-24 (SPEC-FORMAT-TERSE.1.4 — a "helper rename" is not one uniform alias; dump each target's recognition seam first, because the engine recognizes different helper families at different layers and a single normalization hook silently covers only one of them): PNT picked `.1.4` (renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`) and split it after a TOOLBOX-first `call_spec_handler_subst` ground-truth pass. Durable points. (1) **"Add three aliases" hid three different mechanisms — the probe, not the task title, revealed them.** `cat`→`concat` is a pure value-expr rename → the existing `_normalize_method_name` seam (`ActionIR/MethodExpr.pm:19-26`, where `s`/`a`/`h`→`scalar`/`array`/`hash` already live). `set`→`assign` is NOT: `assign` is recognized by a raw-text *statement* regex `\bassign\s*\(` (`ActionIR/Contracts.pm:1749/1753`) and lowered through `DeclareMethod`/`_lower_assign_statement`, a path `_normalize_method_name` never reaches — proven because `set(...)` probes as *fully* passthrough, not even partially lowered. Had I "just added all three to `_normalize_method_name`," `cat` would work and `set` would silently stay unrecognized — a latent half-done rename a quick smoke test could miss. The cheap probe (`set`/`cat`/`copy` through `call_spec_handler_subst`) is what forces the seam into the open before coding. (2) **`copy` is a genuinely different shape — a UNIFICATION, not a rename.** `array_copy`→`[@x]` and `hash_copy`→`{%x}` emit different sigils, so one `copy(name)` must resolve the symbol's kind at lowering time (try array symbol, else hash symbol) — it can be an alias of neither. That alone lifts `.1.4` above "mechanical." (3) **The same three shapes recur on the other variant but with a different constraint — Rust's `match` cannot repeat a literal across arms,** so `copy` needs its own value-type-dispatching arm (`Array`→clone / `Hash`→clone) while `set`/`cat` are pipe-arm aliases (`"assign" | "set"`); all four canonical helpers sit in one `Engine::call_helper()` match (`engine.rs`), no parser/compiler recognition. (4) **Split by variant (Perl reference + Rust parity) because the ownership areas and gates are disjoint** (Perl `ActionIR/*` + phase0 + book vs Rust `engine.rs` + oracle + cargo) and COMMIT.md forbids bundling — the third repeat of the `.1.1`/`.1.2` pattern, falling out of evidence rather than habit. (5) **Pin the byte-identity contract up front:** the shipped corpus uses the OLD names, so `.1.4.1`'s hard criterion is that old-name lowering stays byte-UNCHANGED (all 20 specs byte-identical — the `.1.1.1`/`.1.2.1` mine-vs-stashed diff discipline), with the NEW spellings proven byte-equal to their canonical via `call_spec_handler_subst`. DOCS/TREE/KM only; `scripts/check_doctrines.sh` (MEMORY-ARCH + KNOWLEDGE-MAP) EXIT 0; KM card [[terse-helper-rename-lowering-sites]] (map regenerated, 49 facts); no engine/book change (phase0 stays 971, N/A to a split slice; cargo 252). Next: implement `.1.4.1`.

- 2026-06-24 (SPEC-FORMAT-TERSE.1.2.2 — "lockstep parity" means reproduce the reference BEHAVIOR, and you only learn whether that needs code by RUNNING the other variant first; the precedent that the last parity leaf needed no change is a hypothesis, not a license to skip the probe): Brought the Rust variant to parity for `.1.2.1` (bare arg-position auto-existence). Durable points. (1) **The previous parity leaf's "no engine change" outcome is the most dangerous thing to carry forward — re-probe every time.** `.1.1.2` (wrapped auto-existence) needed no Rust change because the interpreter's HashMaps auto-vivify, and the `.1.2.2` leaf text even hypothesized "likely holds by architecture." A throwaway probe (bare-vs-wrapped, parse→validate→compile→execute, dump-don't-guess) killed that in one run: bare `assign(v,"ok")`→`[null]`, bare `push_value(items,..)`→`[[]]` vs wrapped `["ok"]`/`[["a","b"]]`. Auto-vivify is necessary but not sufficient — the bare name first has to be *recognized as the variable*, and Rust's `resolve_scalar_target`/`resolve_array_target` only un-wrapped `scalar(VAR)`/`array(VAR)` Calls; a bare `Expr::Variable` fell through to `val.to_str()` (the evaluated value → `""`). Had I trusted the precedent and shipped "tests only," the locks would have asserted `[null]`/`[[]]` as "parity" and frozen a divergence. (2) **The Perl reference's behavior IS the spec — the Rust fix is "do what `_extract_*_symbol_name`'s `^(\w+)$` fallback already does."** Parity work is not invention; it's reading what the reference does for the bare form (map the bare name straight to the var) and reproducing it. The Rust resolvers gained exactly that one branch. (3) **Scope the parity change to the SAME channel the reference leaf covered — don't let a shared helper drag in the next channel.** `resolve_array_target` is shared between the Channel-1 array TARGET (push_value/push_nonempty) and value-position READS (array_copy/hash_copy). Adding bare handling unconditionally would have made bare `array_copy(items)` read a var too — that is Channel 2 (value-position reads), which Perl `.1.2.1` did NOT add. An `allow_bare` flag (true only at the push sites) keeps Rust from getting *ahead* of the contract, which is as much a lockstep violation as falling behind. (4) **Reuse the project's cross-variant guard (the oracle corpus) and mirror the reference leaf's lock shapes.** The bare fixtures go through `gen_oracle_corpus.pl`→`corpus_oracle` (Rust == the Perl reference value, regeneration-safe; the existing 7 fixtures stayed byte-identical), and the 4 `terse_1_2_2_*` integration tests mirror `.1.1.2`'s value/convergence/no-leak shapes for what the once-per-fixture oracle can't express. (5) **Hold the zero-new-warnings bar even for a 3-line fix:** the `if allow_bare { if let … }` nest tripped `collapsible_if`; flattening it to a tuple `if let (true, Some(…)) = (allow_bare, raw_args.first())` kept engine.rs at its 11-warning baseline. Engine: 1 file; cargo 248→252; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0; no book change. Channel 1 complete on both variants; next `.1.4` (helper renames).

- 2026-06-24 (SPEC-FORMAT-TERSE.1.2.1 — when you auto-supply a declaration, the sigil MUST come from what the lowering actually emits, not from what the feature is "about"; and isolation of a codegen feature is proven at the generated-source level when the behavioral observation needs the very sugar you're bypassing): Implemented Perl arg-position bare working-variable auto-existence (Channel 1) by extending the `.1.1.1` collector. Durable points. (1) **The sigil is a property of the LOWERING, not the intent — read it before you emit a `my`.** A bare `assign(count, …)` *feels* like it could be any kind, but `_lower_assign_statement` calls `_extract_scalar_symbol_name` first and that claims any bare `^(\w+)$`, so the target ALWAYS lowers to scalar `$count` — even `assign(pair, set_key(hash(pair),…))` produces a scalar `$pair` (holding a hashref) distinct from the `%pair` the wrapped `hash(pair)` declares. If I had emitted `my %pair` for that bare target (matching the "it's a hash" intent), I'd have created a dead `my` and left the real `$pair` still leaking. So Channel 1 emits `$` for the `assign` target and `@` for the `push_value`/`push_nonempty` target — exactly the sigils the dump shows — and nothing for positions whose lowering is ambiguous. The probe (`probe_terse_1_2_1.pl`), not the spec prose, decided the sigil table. (2) **Anchor the bare pattern so it CANNOT poach the wrapped path: require `\s*,` after the bare name.** `assign(scalar(count), …)` must stay on the `.1.1.1` wrapped path; the bare pattern `\bassign\s*\(\s*(\w+)\s*,` doesn't match it because after `scalar` comes `(`, not `,`. That one anchor is what keeps wrapped/bare from double-collecting (they then also dedup by sigil+name through the shared `$record` closure) — verified by a phase0 lock that counts exactly one `my $count` for `assign(scalar(count),…)`. (3) **A purely-bare feature can be UN-observable behaviorally, so prove isolation at the source level.** To watch a bare `count` leak across parses you must read it back — but reading needs a wrapper (`return(scalar(count))`), which itself triggers `.1.1.1` and supplies the `my`, defeating isolation (`return(count)` bareword is Channel 2, not implemented). So the decisive `.1.2.1` lock is generated-source: with no wrapper anywhere, assert exactly one `my $count` AND that it sits before the `while(1)` loop (preamble = per-invocation = the no-leak property `.1.1.1` already proved behaviorally). The run-twice no-leak test is kept as an integrated guard (bare-mutate + wrapped-read), but it is honestly NOT the isolating proof. (4) **Re-confirm byte-identity by diffing the whole corpus against the stash — and this time it was a cleaner 0/20 than `.1.1.1`'s 19/20**, because the shipped specs wrap every arg-position target; the new pass only fires on genuinely un-wrapped vars, which the corpus doesn't have. (5) **Scope a migration leaf to what the lowering makes UNAMBIGUOUS, and defer the rest with evidence, not vibes.** The child-append `push(Rule[, target])`/`.push(target)` target overlaps a rule-name first arg and a numeric index — genuinely ambiguous — and a bare hash has no clean arg position (`set_key(name,…)` is a value read) — so both are Channel 2, recorded in Decisions + the KM card rather than hand-waved. Engine: 1 file; +3 phase0 locks (968→971); `tools/run_ci_local.sh` EXIT 0; ratio 1.0000; `mdbook build` EXIT 0; book taught in 3 pages. Next: `.1.2.2` (Rust lockstep parity).

- 2026-06-24 (SPEC-FORMAT-TERSE.1.2 — before implementing a broad language leaf, dump the engine's ACTUAL treatment of the un-sugared form; the ground truth re-scopes the leaf into the channels that already work vs the ones that don't, and the split falls out of the evidence): PNT picked `.1.2` (remove container wrappers + type inference) and, instead of coding, split it after a `dump_parser_source` ground-truth pass. Durable points. (1) **"Remove the wrappers" is not one change — the dump shows the engine already does HALF of it, badly.** A bare name in a type-implying arg position (`assign(count, v)`, `push_value(items,..)`, `.push(items)`) ALREADY lowers to the correctly-sigil'd variable (`$count`, `push @items`) because ValueExpr's `_extract_*_symbol_name` accept a bare `^(\w+)$` — but it gets NO auto-`my`, because the `.1.1.1` collector regex matches only WRAPPED `scalar/array/hash(NAME)`. So that bare var is a **leaky package global** — the exact `.1.1.1` hazard, still open for bare forms. Meanwhile a bare word in a VALUE position (`return(count)`) is not recognized as a variable at all (lowers to the bareword `return count ;`, not `$count`). Two channels of very different size and risk — invisible without the dump. (2) **The leaf split is a property of the ground truth, not a guess.** Channel 1 (arg-position auto-existence) is self-contained, directly extends `.1.1.1`, and closes a correctness gap → the right FIRST slice (`.1.2.1`). Channel 2 (value-position bare-word reads + RHS-shape `[]`/`{}` inference) needs var/call/literal disambiguation and couples with `.1.5` literal syntax → deferred (`.1.2.3`+), and deliberately NOT pre-published as IDs (the splitting rule forbids vague placeholders; I can't yet write precise acceptance for a design that depends on `.1.5`). Build the safe, foundational channel first; let the harder channel's design mature. (3) **Reuse the project's own split precedent: Perl reference + lockstep Rust parity are separable (ADR 0006), so every channel is a Perl leaf + a Rust leaf** — mirroring `.1.1`→`.1.1.1`/`.1.1.2` and `TOP-RULE-AS-NORMAL`'s `.2`/`.3`. (4) **A migration leaf must protect the existing surface explicitly.** The shipped corpus uses wrappers pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash 36), so the gradual-alias policy (ADR 0007) is not optional flavor — `.1.2.1`'s acceptance carries "wrapped/declare specs stay byte-identical" as a hard criterion, the same dedup-vs-lowered-`my` discipline that made `.1.1.1` byte-identical for 19/20 specs. (5) **The split slice is the clean handoff point for signoff-critical codegen.** The design + ground truth are committed (layer B + KM card [[terse-bare-working-vars-engine-gaps]]) so `.1.2.1` executes against a written spec, not a re-derivation, after a sharp fresh start. DOCS/TREE/KM only; `perl -c` clean on the landing modules; memory-arch + doctrine + KM gates EXIT 0; no engine/book change (phase0 stays 968, N/A to this slice). Next: implement `.1.2.1`.

- 2026-06-24 (SPEC-FORMAT-TERSE.1.1.2 — "lockstep parity" does not mean "mirror the fix"; reproduce the reference BEHAVIOR on the other variant and discover that an architectural difference can make the fix unnecessary — then the signoff move is locks + docs, not code): Brought the Rust variant to parity for `.1.1.1` (auto-existing working variables). Durable points. (1) **Assess the OTHER variant's architecture before assuming it needs the same change.** The Perl `.1.1.1` change was a *codegen* fix: generated handlers run non-strict, so an undeclared wrapper-referenced working var becomes a leaky package global, and the engine now auto-injects a per-invocation `my`. The Rust variant is an **interpreter** — working vars live in `RuntimeContext` HashMaps that auto-vivify on write (`set_scalar`=`insert`, `push_value`=`entry().or_default().push`) and read as `Undef`/empty when absent, and `Engine::execute` builds a fresh context per call. So working variables already auto-exist with no `declare`, and there is no leaky-global hazard to fix. The right outcome was **no engine change** — adding a "collector" to mirror a fix for a non-existent hazard would be ceremony, not parity. Reading `runtime.rs`/`engine.rs` (dump-don't-guess) is what established this; predicting from the Perl design would have invented work. (2) **Make parity locks GENUINELY cross-variant by running BOTH backends on the same grammars — and the Perl reference will reject your first lock design.** My first instinct (a REP `Top::*` accumulator and the exact recursive Perl `.1.1.1` lock specs) DIVERGED: the recursive `top:: -> top[0]` form returns `[null]`/`[[]]` on Rust (the separate `RUST-PARITY` recursive-grammar gap), and the REP form returns `[null,null,null]` on *Perl* — neither is a parity lock. Only the **divergence-free edge-action form** (the `.7.1` oracle proof class: non-recursive `Parent:: /re/ -> Child { return(...) }`, action-less child) produces identical Perl↔Rust output (modulo the documented one-level accumulator wrap). The lesson: a cross-variant lock is only valid once you've *run* both sides and confirmed they agree; pick the grammar class the oracle already proved divergence-free. (3) **Reuse the project's own parity mechanism (the oracle corpus) for the durable guard, and add focused tests for what it can't express.** The `autoexist_*` cases go through `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`, which checks Rust == the Perl reference value — the strongest, regeneration-safe cross-variant guard. But the oracle runs each fixture ONCE, so the decisive **per-parse no-leak** property (re-run the same engine, get the same value, not an accumulation) and the **declare/no-declare convergence equality** are added as explicit integration tests instead. (4) **Separate the deferred gap from the closed one, with evidence.** The recursive/REP auto-exist idiom is blocked by `RUST-PARITY`, not auto-existence — proven by showing the non-recursive equivalents are at full parity while the exact recursive specs return `[null]`. Record that boundary so a future reader does not re-attribute the recursive gap to this leaf. cargo 244→248 green; 7/7 oracle fixtures PASS; clippy zero-new; phase0 968 green (Perl untouched); KM card [[rust-working-vars-auto-vivify]]. `.1.1` container done; next `.1.2`.

- 2026-06-24 (SPEC-FORMAT-TERSE.1.1.1 — for a hot-path codegen change whose safety claim is "byte-identical for the existing corpus," PROVE it by diffing generated source across the whole corpus against the stashed code; the diff finds what design reasoning cannot): Implemented Perl auto-existing working variables — the engine now injects one preamble `my $NAME`/`@NAME`/`%NAME` for any wrapper-referenced (`scalar/array/hash(NAME)`, `s/a/h`) working variable that is not already declared. Durable points. (1) **Make the change byte-identical-by-construction for the existing surface, then verify the construction.** The injection is `$actual_icode = $auto_var_decls . $actual_icode` where `$auto_var_decls` is the empty string whenever every wrapper var is already declared — so for the fully-declared shipped corpus the concatenation is provably a no-op. But "provably" is a claim: I generated `dump_parser_source` for all 20 specs with my change vs the same two files `git stash`ed, and diffed. **19/20 byte-identical** confirmed the no-op; the 20th (tkgui) was the signal. (2) **The corpus diff catches both classes the design misses: a false positive AND a legitimate-but-surprising activation.** Lispish's `return(a(undef))` made my collector emit `my @undef` — `undef` is the DSL *literal* (array-constructor element), not a variable; no amount of staring at the regex surfaced it, the diff did → fixed with a reserved-name set (literals `undef`/`true`/`false` + the engine's own handler locals `$IMATCH`/`$LMATCH`/`$IPOS`/`$descr`/… which the dedup-via-lowered-code can't see because they're declared in the preamble *template*, not the action code). tkgui's `assign(scalar(subgui_name), …)` is a genuinely undeclared working scalar (leaky global today); the feature correctly gives it a `my` — I accepted that change only after proving its parse output is identical before/after. (3) **Collect from the RAW pre-lowering blocks, dedup against the LOWERED output.** By `compile_spec_entry` the wrappers are already lowered to `$count` — so collection must read `rule_ir->{code_blocks}` + the `acode/bcode/and_icode` entries at the `build_rule_ir_emit_context` chokepoint (never the regex `re` slots, and mask string/regex literals so `say("… s(x) …")` can't false-positive). Dedup is best done against the *lowered* `my <sigil>NAME` (covers `declare`, multi-entry declares, initializers, AND raw `my` uniformly) rather than re-parsing `declare(...)` argument lists. (4) **The decisive proof of the FEATURE — not just no-regression — is the cross-parse no-leak test, and the existing harness can't run it.** A leaky-global counter and a per-invocation `my` counter both return the right value *within one parse*; they differ only across parses (the global accumulates). `_ls_run_bounded` forks a fresh process per call, so it resets globals and cannot see the leak — I had to call the parser twice in the SAME process (alarm-guarded) and assert both results equal. That lock fails before the change and passes after; it is what actually proves "per-invocation lexical, not leaky global." (5) **The book is the variant-agnostic contract: document the behavior the reference now implements, frame it as the contract (a backend MUST supply it), and track the Rust parity as a separate leaf** rather than caveating the user-facing book with per-variant status. Engine: 2 files; +3 phase0 locks (965→968); `tools/run_ci_local.sh` EXIT 0; `mdbook build` EXIT 0; ratio 1.0000. Next: `.1.1.2` (Rust lockstep parity).

- 2026-06-23 (SPEC-FORMAT-TERSE.1.1 — before implementing the first leaf of a new language-feature track, dump the engine's actual codegen; the ground truth re-scopes the leaf and often re-frames the feature itself): Entered the terse-`.spec`-format implementation track (ADR `0007`) by PNT and, instead of coding, split the first leaf after a `dump_parser_source` pass. Durable points. (1) **"Auto-existing variables" sounds like a parser/grammar change; the codegen dump shows it is a SCOPING change.** `dump_parser_source` on a `declare`-using spec showed the whole rule (`I` + edges + `LX`) is ONE `sub` / ONE lexical scope and `declare(scalar,x)` is literally `my $x` emitted once in the preamble before the `while(1)` loop. So the feature is not "let bare names parse" — it is "auto-supply the `my` the author currently writes by hand." Reading the emitted Perl, not the brainstorm prose, is what made the design concrete (collect rule-wide wrapper references → inject `my` in the preamble). (2) **The probe re-framed WHY the feature matters.** I expected the no-`declare` case to fail loudly under strict vars; the dump + a `grep -c 'use strict' SpecEntry.pm` = 0 proved the opposite — generated handlers run NON-strict, so a working var without `declare` silently becomes a leaky **package global** (state-leak across invocations/recursion), not a compile error. Auto-existence is therefore a *correctness* feature (per-invocation `my` lexicals), not just terseness — a sharper justification than the brainstorm gave, now carded in [[working-vars-no-strict-need-my-lexical]]. (3) **An inline-at-first-use `my` is the obvious-but-wrong implementation, and the dump shows why.** Because edges run inside the rule's one `while(1)` dispatch loop, a `my @items` emitted at an edge's first push would re-run every iteration and reset the accumulator — the reason the existing idiom puts `declare` in the `I`-block (the run-once preamble). The injection MUST be preamble-level and rule-wide. Only the codegen made that non-obvious constraint visible up front. (4) **Split the reference change from the lockstep-parity change.** A Perl engine change + a Rust parity obligation (ADR `0006`) is two signoff slices, so `.1.1` → `.1.1.1` (Perl) + `.1.1.2` (Rust) — mirroring `TOP-RULE-AS-NORMAL`'s `.2`/`.3` split. The split slice itself touches only the tree + a KM card + live docs; the design lives in layer B + the KM card so the implementation session (or a post-crash resume) executes against a written spec, not a re-derivation. DOCS/TREE/KM only; gates green; phase0 965 unchanged.

- 2026-06-23 (TOP-RULE-AS-NORMAL.4 — a "reconcile the docs" slice is still a verification slice: run every example you touch through the real engine, and the engine will hand you the corrections to make): Reconciled the mdBook to the ADR-0010 "top rule is an ordinary rule entered first" model. Durable points. (1) **Verify the book against `LinkedSpec::Get`, never against your mental model — the engine corrects you.** Two defects surfaced only because I ran the examples: (a) the book's own `Pair::AND` regex-on-top teaching example read `entry_text()` and returns `{name:null,value:null}` — a **top rule has no entering match**, so own-slot matches must be read with `match_*` from a post-match edge, not `entry_*`/an `I` block (which runs before the rule matches its own regex); (b) the worked-walkthrough claimed `'a = 1, b = 2'`→two pairs in a `consume` context, but `consume` stops at the comma and yields one pair — two pairs is a `seek` result. Neither was visible by reading the prose. (2) **"De-footgun" means make the example RIGHT, not just legal — and that needs a second-order probe.** Fixing `entry_text()`→`match_group(0)` still leaked ` = value` because a **bare edge-less middle `AND` slot is a positional anchor that is not separately consumed**; the clean form folds the `\s*=\s*` separator into a slot that owns an edge. I only found the clean shape by probing 3-4 variants and diffing their outputs (`verify4c/4d`). (3) **Idiom vs law is a real, enforceable distinction: change the words, keep the recommendation.** The book had "Body rule only" (mode table), "never on the `::` entry rule", "a valid `.spec` needs at least two rules" stated as engine constraints; the engine imposes none of them (`Top::AND`, regex-on-top, recursive top rules all run). Reframed to "recommended idiom" across **6 files** (one, `helper-contract-catalog.md`, found by a whole-book grep sweep, not the named list) while keeping the two-rule no-regex shape as the recommended style for stream-of-records parsing — the [[feedback_conventions-not-contracts]] rule applied to the top-rule structure itself. (4) **Document a runtime invariant where a re-implementer will look, and tie it cross-variant.** The consume-before-recurse forward-progress termination rule went into `formal-grammar.md` §5.4 (the backend-implementation spec) phrased as a hard MUST, because the `.3.1` Rust diagnosis proved a backend that skips it stack-overflows — it is a cross-variant obligation, not a Perl detail. (5) **Lock the documented behavior and card the re-derivable fact.** Added phase0 `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family` (asserts both the correct `match_group` value AND the `entry_text`→null footgun) so the book's new example can't silently rot, and a KM card [[top-rule-reads-own-match-with-match-family]] so the next author doesn't re-derive the `entry_*` vs `match_*`-on-a-top-rule distinction. BOOK+TEST+DOC; phase0 964→965; `mdbook build` + `tools/run_ci_local.sh` EXIT 0; no engine/spec change.

- 2026-06-23 (TOP-RULE-AS-NORMAL.3.1 — "cross-variant parity" is not one gap: reproduce the reference's locks through the OTHER variant's full pipeline first, and the diagnosis will tell you which layer is actually yours): Mirrored the Perl `.2.1` forward-progress termination guard into the Rust variant. Durable points. (1) **Reproduce-first across variants, before assuming the gap or its size.** Driving the four Perl phase0 top-rule grammars through the Rust pipeline (`parse_spec`→`validate`→`compile`→`Engine::execute`, dump-don't-transcribe) showed the cross-variant gap is **two independent layers**, not one: (a) **termination** — the no-consume grammar `top:: /a/ I{return(call(top))}` made Rust recurse natively → **stack overflow → SIGABRT**, while Perl returns `undef`; and (b) **value** — Rust returns nulls for the recursive S-expression cases. The split is what made the slice signoff-sized. (2) **The decisive diagnostic was the CONTROL case: layer (b) is wrong even for the standard body-recursion idiom (`top:: -> sexpr` wrapper → `[[null],[null]]`), so it is NOT a top-rule-as-ordinary issue — it is the general recursive-grammar parse gap owned by `RUST-PARITY`** (recursive specs like Lispish are already deferred per `tests/corpus_oracle.rs`). Had I only tested the top-rule forms I'd have mis-attributed a pre-existing general gap to this tree and tried to "fix Lispish parsing" inside a parity slice. Test the thing that should be UNaffected to find the real boundary. (3) **Mirror the reference's PRECISE mechanism, not a blunt analogue.** The Rust guard is the same `(rule,pos)` active-set cutoff as Perl's `%__ls_recursion_active` — `recursion_active: HashSet<(String,usize)>` on `RuntimeContext` — explicitly NOT a recursion-DEPTH ceiling (which `.2.1` already rejected as both false-failing deep input and firing after the native stack already blew). It cuts the instant a `(label,pos)` re-enters its own active stack, so it never touches a terminating grammar (which advances `ctx.pos` first). (4) **Guard the single re-entry seam, once, balanced.** `Engine::execute_rule` is the Rust analogue of Perl's one `_build_runtime_handler` closure — every blind-call edge, action edge, and `call(rule)` helper flows through it — so a thin wrapper around the renamed `execute_rule_inner` covers all recursion; the frame is removed on BOTH the Ok and Err exit paths so the set stays empty between parses. (5) **Make the lock self-protecting and assert the tightest true value.** The no-consume lock runs a grammar that, if the guard regressed, would overflow the stack and ABORT the test process — the Rust analogue of the Perl fork+SIGKILL bound (a regression fails loudly, never silently passes). And the cut returns `[null]`, which is exactly Perl's `undef` wrapped one level by the documented Perl↔Rust accumulator output-shape rule — so I locked `== [null]` (value-shape parity), not a loose `is_array()`. Rust 242→244 green; phase0 964/964 + `tools/run_ci_local.sh` EXIT 0 (Perl untouched); split `.3` → `.3.1` (done) + `.3.2` (blocked on `RUST-PARITY`); book stays `.4`.

- 2026-06-23 (TOP-RULE-AS-NORMAL.2.2 — an "authorized engine change" is permission, not an obligation: when the probe shows the engine is already correct, the signoff move is a doc+lock, not a change): Closed `.2` by CONFIRMING there is no engine defect in top re-entry recursion. Durable points. (1) **A confirmed root cause still owes an empirical check before any edit — "dump it, don't transcribe it" applies to your own reasoning too.** Reading the dispatch + `call` lowering let me predict exactly why a bare `sexpr::` top-recursive rule returns `null` (the outermost frame loops to EOF and the default `lxcode = return undef` discards its accumulator) AND predict the fix (an `LX` accumulator-return). But I still ran `probe9.pl` before concluding, because the engine had already surprised me once this tree (the `dump_parser_source` artifact ≠ the runtime `{handler}` seam). The probe confirmed the prediction to the value, including the decisive `(a) (b)` case. (2) **ADR-0010 authorized an engine change; the right outcome was to NOT use that authorization.** The investigation showed top re-entry recursion already works — the `null` was the missing-`LX` authoring case (a recursive top rule is just an accumulating top rule, and the documented `top:: -> x .push` + `LX{...}` idiom applies). Touching the engine to "fix" a non-bug would have added risk to a 960-test hot path for nothing. Authorization is a ceiling on what you *may* do, not a floor on what you *must*. (3) **"Make X behave identically to Y" can be a mis-framing worth rejecting, with evidence.** TOP (`sexpr::`+LX) and BODY (`top:: -> sexpr {return(call(sexpr))}`) produce different results because they are different grammars with different arity — `(a) (b)` → `[["a"],["b"]]` (TOP accumulates the sequence) vs `["a"]` (BODY returns one form). The honest deliverable names that distinction rather than forcing a false equivalence. (4) **Lock the corrected, positive behavior — not the footgun.** The new phase0 lock asserts the WORKING top-recursion-with-LX values; the bare-no-LX `null` stays pinned termination-only (from `.2.1`), and the authoring requirement is routed to the book (`.4`) rather than frozen as a "this returns null" test. TEST+DOC only; phase0 963→964; `tools/run_ci_local.sh` EXIT 0; engine untouched.

- 2026-06-23 (TOP-RULE-AS-NORMAL.2.1 — for a high-blast-radius engine change, the win is finding the ONE real chokepoint with the toolbox, guarding it precisely instead of broadly, and letting the investigation re-scope the task honestly): Landed the forward-progress / consume-before-recurse termination guard for the `.spec` engine — one file, proven safe. Durable points. (1) **Read the lowering, not the `dump_parser_source` artifact.** The dump showed recursion as `&{$descr->{spec}{$rule}}(...)` (a direct CODE deref), but `call_spec_handler_subst` + `Contracts.pm:134`/`MethodLowering.pm:332` showed the REAL runtime lowering is `&{$$descr{spec}{$rule}{handler}}(...)`, and `{handler}` is the `SpecEntry::_build_runtime_handler` closure (`SpecEntry.pm:438`). The dump is a simplified standalone teaching artifact; trusting it would have put the guard in the wrong place. The payoff: **every** cross-rule call and recursion flows through that ONE real-Perl closure, so the guard is one site, not a per-variant edit of generated strings. (2) **Guard precisely, not bluntly.** The first instinct (a recursion-DEPTH ceiling) is unsafe twofold: it false-fails legitimately deep input, and Perl's own C-stack can overflow before any high ceiling fires. A **(rule, pos) active-stack non-progress cutoff** is strictly better — it fires the instant a rule re-enters a position already on its own stack (a genuine no-consume cycle), so it terminates E4-class hangs at depth ~2 (never near Perl's stack limit) and provably never touches a terminating grammar (which always advances `pos()` before re-entry). phase0 960→963 with zero regression is the proof. (3) **The matcher was already safe; the hang was narrower than "recursion."** A fork+SIGKILL battery (TOOLBOX 6.3 — `alarm` can't interrupt a runaway op) over zero-width/lookahead grammars in seek+consume NEVER hung: `LinkedRE::or`'s `/gc` (seek scans to EOF; consume rides Perl's repeated-zero-width prohibition) already makes forward progress. The ONLY engine hang was an unconditional no-consume self-tail-call. Reproducing the EXACT failing construction before writing the guard kept it minimal and gave it a real regression lock. (4) **Lock termination with a hard fork+SIGKILL bound, never `alarm`, and never lock a known-wrong value.** The phase0 locks run the parser in a forked child that `POSIX::_exit`s without emitting TAP, so a guard regression FAILS the test instead of hanging the suite. The top-recursion lock asserts TERMINATION only — not its (currently-wrong) value — because the investigation surfaced a SEPARATE gap. (5) **Let the probe re-scope the task: split, don't bundle.** probe7 showed a recursive rule AS the top rule returns `null` while the identical body rule parses (`(a(b)c)`→`["a",["b"],"c"]`) — an entry-alignment off-by-one, distinct from termination and not yet root-caused. Bundling an undiagnosed deeper engine change into this commit would have been rushing a signoff-critical hot path; splitting `.2`→`.2.1` (done) + `.2.2` (value correctness) is the honest decomposition. Engine: 1 file (`perl/LinkedSpec/SpecEntry.pm`); +3 phase0 locks; `tools/run_ci_local.sh` EXIT 0. No spec/book change (book is `.4`).

- 2026-06-23 (TOP-RULE-AS-NORMAL.1 — when a design discussion turns into an engine directive, the order is: investigate read-only to get the REAL scope, record the decision + authorization as an ADR, own the lane, and only then touch code — and a frozen engine is unfrozen one ADR-scoped exception at a time): Captured a user-authorized engine direction without writing any engine code. Durable points. (1) **Investigate before you scope, especially before you authorize effort.** The directive ("make the top rule a normal rule w.r.t. regex") sounded big; a short read-only TOOLBOX pass (`generate_only`+`dump_parser_source`, codegen grep) showed the regex/codegen dimension is ALREADY uniform — the top rule is just `&{$descr->{spec}{$top_rule}}(...)` (`Compiler.pm:1006`); `while(1)` is mode-driven, not top-driven; `Pair::AND`+regex already emits a standard AND handler (the `.3` fix got it there). The real, bounded gap is recursion *into* the top rule + termination. Scoping from the investigation (not the first impression) kept the task tree honest and shrank the work. (2) **Distrust your own probes when they contradict shipped reality.** My quick recursion grammars hung even on trivial input — but `specs/Lispish.spec` recurses and is green, so the hang was my malformed grammar (recursing into the top / a zero-progress blind-call), not an engine incapacity. I stated that caveat instead of asserting "recursion is broken." (3) **A frozen engine is unfrozen by a named ADR, not by momentum.** "You can touch the Perl variant" became ADR 0010 — a scoped exception in the exact shape of 0008 — with the cross-variant-parity obligation written in (the `.spec` file is the one contract; Perl-first must be mirrored to Rust/Julia/Dart). (4) **Supersede, don't delete, when a plan pivots mid-session.** An earlier `.6.1`/`.6.2` "engine-frozen" split (proposed minutes before, never committed) was withdrawn and `.6` marked `superseded` by the new lane — the honest record of how the decision evolved, not a silent rewrite. (5) **Recommend a fresh session for signoff-critical codegen at the tail of a long context** — the investigation + decision + ownership are captured and committed (handoff-ready); the engine surgery (`.2`) deserves a sharp start, and cross-variant parity besides. No engine/spec/test/book change in this slice.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.5.3.2.2 — when the *code* a doc describes has been deleted or moved, sync the doc to the new reality rather than line-editing an obsolete migration narrative; verify "what's where now" from git + the filesystem, not from the prose you're fixing): Synced the product/architecture surfaces (`ROADMAP_V2.md`, `ARCHITECTURE_STATE.md`, two mdBook files) to the post-retirement module state and closed the `LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE` trees (DOC-ONLY). Four durable points. (1) **A large migration narrative whose subject has left the tree is best *replaced*, not patched sentence-by-sentence.** ARCHITECTURE_STATE / ROADMAP_V2 / the book carried hundreds of lines of "X now owns Y, the `plugin/Z.plg` wrapper is gone" prose — all describing a plugin-retirement that is now *moot* because the code itself was either deleted (`LEGACY-VHDL-RETIRE`: the Perl-only VHDL/RTL/FSM subsystem) or quarantined to `noncore/` (`NONCORE-QUARANTINE`). Keeping each sentence individually "accurate" would be misleading busywork; the honest move is to state the current reality once (deleted vs relocated, `perl/` core-only) and let `git log` hold the per-helper history. (2) **Establish ground truth from git + the filesystem, never from the doc under repair.** The prose presented `RTLUtils`/`FSMGen`/`VHDL::ConstantEval` as live owners and `generic_fake_memory_module.plg`/`wrapgen.plg` as live `ceil_log2` callers — all false; `git diff-tree` on the retirement commits + an Explore import-tree pass showed the three modules deleted (`06496b4`), the domain island relocated (`336bded`/`2baddbd`), and the two `.plg` deleted even earlier (`cffac62`, so that caller prose was *doubly* stale). Reading the drift to fix the drift would have re-encoded the wrong facts. (3) **Supersede a historical milestone record, don't erase it.** ROADMAP_V2's `done` plugin-modernization tracker cell genuinely documents what that 2026-05-17 milestone accomplished; rather than rewrite the achievement out of existence, I appended a dated **Update** stating the owners have since been deleted/relocated — the same "supersede, don't mutate" rule the memory architecture applies to decision records. (4) **A guarded, content-anchored, match-count-asserted transform is the safe way to surgically replace long interwoven prose blocks** — anchor on short unique start/end tokens, assert exactly-one match, die-before-write on drift, then review the full `git diff`. That kept four files' worth of multi-paragraph replacements reviewable and reversible without transcribing 600-char lines by hand. Closed both trees (`LEGACY-VHDL-RETIRE` done; `NONCORE-QUARANTINE` done with `.N` deferred as an explicit Non-Goal); `mdbook build` EXIT 0; book stays variant-agnostic; phase0 960/960 unaffected. No engine/spec/test change.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.5.3.2.1 — clearing a gate that several trees waited on is itself a slice: split status-from-narrative, flip cross-tree blockers with evidence, and mark a multi-part downstream leaf `done` only when it is *fully* done): Reconciled the downstream blocked statuses now that both phase0 (960/960) and the full local gate (`tools/run_ci_local.sh` EXIT 0) are green. Four durable points. (1) **A green milestone that unblocks N trees is a *reconciliation* slice with real surface area — scope it, don't sprinkle the flips into the milestone commit.** Three trees (`NONCORE-QUARANTINE`, `LEGACY-VHDL-RETIRE`, `SPEC-FORMAT-TERSE`) plus the index, a KM card, the live docs, AND ~4 narrative/product docs (incl. 2 mdBook files) all referenced the old "blocked by the 173 / not green" reality. That is ~15 files and two genuinely different concerns: *status-ledger flips* (continuity bookkeeping) vs *narrative/product-surface drift* (the deferred `LEGACY-VHDL-RETIRE.5` body, which long predates this milestone). Per COMMIT.md's "don't bundle unrelated changes," the signoff move was to **split `.5.3.2` → `.5.3.2.1` (status & continuity) + `.5.3.2.2` (narrative + book drift)** and commit them separately, rather than one sprawling "reconcile everything" commit. (2) **Flip a cross-tree blocker with the *evidence*, not just the verdict — and name where the evidence lives.** Each "blocked"→"cleared" carries the concrete proof (phase0 960/960; `tools/run_ci_local.sh` EXIT 0) and a pointer to the owning leaf that produced it (`.5.4`/`.5.3.1`), so a future reader of `NONCORE-QUARANTINE.V` or the `SPEC-FORMAT-TERSE` gate can re-verify without re-deriving. (3) **A multi-part downstream leaf is `done` only when *every* part is — split the flip across the sub-leaves rather than marking it done early.** `NONCORE-QUARANTINE.V` and `LEGACY-VHDL-RETIRE.5` each bundle a verification/blocker-clear part (satisfiable now) with a doc/book/KM-sync part (the actual prose work, deferred to `.5.3.2.2`). I flipped them to `pending` with the blocker cleared and the verification recorded, and will only mark them `done` in `.5.3.2.2` when their doc bodies are actually written — never "done" ahead of the work. `LEGACY-VHDL-RETIRE.4` (a pure "confirm hang cleared + gate green" leaf) *is* fully satisfiable now, so it went straight to `done`. (4) **When the blocker that's clearing was itself a chain of masks, update the durable record (the KM card) to the *outcome*, not just the symptom.** The `rtlutils-regex-hang` card still warned that a second back-half hang (`HTML::PathLinks::link_path_tokens`, subtest 131) "persists until its own fix track." That track turned out to be `PHASE0-BACKHALF-TRIAGE`, and the subtest-131 hang never needed a regex fix at all — `NONCORE-QUARANTINE.3` excised its smoke when it relocated the module to `noncore/`. The card now carries a "Resolution" section recording that phase0 is green end-to-end and the gate it blocked (`SPEC-FORMAT-TERSE`) is cleared, so the next grep of that question gets the resolved answer, not the stale warning. No engine/spec/test/book change in this slice.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.5.3.1 — "green phase0" is not "green gate"; run the actual gate; and a relocation leaves leftovers in MORE places than the obvious one): Made the canonical full local gate (`tools/run_ci_local.sh`) pass green end-to-end by clearing a stale `plugin/` reference. Three durable points. (1) **A downstream "verify the full gate is green" acceptance is a claim you must *run*, not infer from a green phase0.** phase0 went green in `.5.4`, but the moment I scoped `.5.3` (which needs "full local gate green") and actually ran `bash tools/run_ci_local.sh`, it died at `require_tracked_tree plugin` — EXIT 1, *before phase0 even started*. The gate does more than phase0 (doctrine driver, tracked-input audits, machine-path audit, RAM guard, then `prove`), and one of those early audits was broken. Had I assumed "phase0 green ⇒ gate green," I'd have flipped the `NONCORE-QUARANTINE.V` blocker on a false premise. Run the gate. (2) **A directory relocation/removal leaves dangling references in every layer that names the path — tests AND CI scripts AND docs — so the cleanup is not done when the obvious consumer is fixed.** `NONCORE-QUARANTINE.3` rmdir'd `plugin/` and the cleanup has now surfaced *three* times: the `corpus_regression` dataset (`.5.1`), the `plugin_bridge` subtest (`.5.4`), and now two pathspec lists in `run_ci_local.sh` (`.5.3.1`). When you `git mv` a tree, `grep -rn '<dir>'` across t/, tools/, scripts/, .github/, and docs/ in the same slice — the leftovers don't announce themselves; they wait behind whatever currently fails first. (3) **Apply the family's settled policy: the core gate stays core-only — drop the quarantined path, don't retarget it into `noncore/`.** The fix mirrors `.5.1`/`.5.4`: `plugin` is *removed* from the gate's required-trees list (with a rationale comment), not repointed at `noncore/plugin/`, because `noncore/` is parked/quarantined and is not a core CI input. `bash -n` OK; `bash tools/run_ci_local.sh` → EXIT 0 ("[ci] local CI gate passed"), phase0 `1..960` / `Result: PASS`. Engine/spec untouched; book unaffected. Also: scoping `.5.3` correctly meant *splitting* it — the gate-flip spans 3 trees + a doc/book/KM sync, so `.5.3.1` (this) isolates the one clean, decidable, low-risk piece (full-gate-green) from the broader `.5.3.2` reconciliation.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.5.4 — the green milestone is earned by the same discipline as every leaf before it: dump the got-value, apply the family's precedent, prove with before/after `comm`): Re-blessed the last 3 dark-tail failures (TEST-ONLY) and `t/phase0_regression.t` reached fully green end-to-end (960/960) for the first time. Three durable points. (1) **A milestone leaf is not a special leaf — resist the temptation to transcribe the "obviously known" got-value.** The triage note already said 952/953 would now return scalar `1` and 960 was "the same as `.5.1`," and it was right — but I still dumped each value via `LinkedSpec::Get` first (Protocol A): 952/953 → `CODE\n$VAR1 = 1;\n`, 953-reject → `__AST_UNDEF__`, and confirmed `PluginBridge.pm:3` still says "Compatibility bridge" before deleting the `.plg`-corpus block that depended on the deleted dir. The dump is cheap; freezing a *wrong* "obvious" value into a green suite is expensive. (2) **Re-bless to the value AND preserve the test's intent — the message is part of the contract.** 952's assertion existed to prove seek mode reaches a *later* anchor (past leading `xx`); the old proof was the `?Top:` tag, which is gone. Rather than just swap the regex and leave a now-misleading message, I re-pointed the proof to the observable that still distinguishes seek from consume: seek on `xxa` returns a *defined* `$VAR1 = 1;` while consume on `xxa` returns `__AST_UNDEF__`. Same intent, current mechanism. (3) **Apply a family's established precedent rather than re-deciding it per sibling.** 960 was the third instance of the `NONCORE-QUARANTINE` plugin-dir leftover (after the corpus dataset in `.5.1`); `.5.1` had already decided the policy — *the core regression gate stays core-only and does not reach into `noncore/`* — so the faithful fix was the same shape (drop the `noncore/`-dependent `.plg`-corpus inspection, keep the core `PluginBridge.pm` check), not a fresh "should we retarget to noncore/?" deliberation. Consistency across a family of identical failures is itself a correctness property. And the recurring "remove a mask, reveal the next layer" pattern of this suite **finally bottomed out** here — the layer under 960 was green. `perl -c` OK; before 957 ok/3 not-ok → after 960 ok/0 not-ok, EXIT 0, `1..960`; `comm` = exactly the 3 cleared, 0 new. Engine/spec untouched; book unaffected. This also closes the bootstrap-then-PNT arc: a thorough resume (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + delegated codebase/mdBook analysis) landed directly on the frontier leaf and executed it to signoff.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.5.2 — a "hang" is a hypothesis: bisect before you blame a regex; instrument the LOOP, not just the call; and a streaming loop needs a progress invariant): Fixed the Lispish `corpus_regression` "hang" (TEST-ONLY) after PROVING it is not what everyone (me included) assumed. Five durable points. (1) **"Catastrophic backtracking" is a guess until the single-call timing says so — bisect first.** Three sessions read the multi-CPU-hour corpus stall as a ReDoS regex. One measurement killed that: a *single* `$parser->(\$full_392B_conf)` = **0.03s**. A 392-byte input that parses instantly once cannot be a backtracking regex; the cost had to be in *repetition*, not one match. The bisection (parse growing line-prefixes, all fast) is what redirected the hunt from the grammar to the driver loop. (2) **When a loop hangs, instrument the LOOP's state per iteration, not the operation in isolation.** Printing `pos()` and `defined($ast)` for each call of `parse_with_lispish_multi`'s `while(1)` exposed the mechanism in one shot: `iter1 pos 0→350 (def)`, then `iter2.. pos 350→350 (+0, def)` — the parser **re-returns the previous form's AST with pos unchanged**. The loop keyed termination only on `defined($ast)`; the parser never yields `undef`; so it spun to its 100000 cap (~3 min/file × 76 files). The single-call probe never saw it because the bug only manifests on the *repeated* call — which is why `ebnf` (single-call probe) was healthy and only the conf/tablescript (loop) datasets hung. (3) **A `while(1)` streaming loop MUST guard on forward progress — relying on a sentinel (`undef`) the producer may never emit is the bug.** The fix is one line (`last if pos_after <= pos_before`), and it is a genuine correctness fix to the loop invariant, not a workaround: a consume-loop that can't tell "made progress" from "stuck" is incorrect against any non-undef-terminating parser. Measured: 76/76 corpus files then parse ok. (4) **Fix at the layer of the actual defect, and name the deeper ones honestly.** The *minimal* correct fix was the harness loop (the missing invariant). The parser's never-undef *contract* and the grammar's missing top-level whitespace-skip (so multi-form files parse only their first form) are real but DEEPER defects (engine/spec, cross-variant) — I fixed the loop, made the corpus green, and logged the deeper two as documented follow-ons rather than smuggling a risky engine change into a test fix. (5) **Removing a mask reveals the next layer — every time.** Greening the corpus let subtests 942–960 run for the first time, surfacing 3 more dark-tail failures (all TEST-ONLY: 2 `return(1)`→scalar-`1` re-blesses + 1 more stale plugin-dir `opendir`, the same class as `.5.1`). The back half of this suite peels one layer at a time; budget for it. Engine/spec untouched.

- 2026-06-22 (DOCTRINE-ENFORCEMENT-ADOPT.1+.2 — adopt a portable architecture by REPLAY, start its registry honest, and a "toolbox" means the project's OWN tools): Adopted the 4th portable architecture (`DOCTRINE_ENFORCEMENT.md`) + a LinkedSpec `TOOLBOX.md`. Four durable points. (1) **Adopt a portable architecture by replaying its manifest, not by re-deriving it.** Like `MEMORY_ARCHITECTURE.md` and the Knowledge Map before it, the doctrine-enforcement standard ships a copy-verbatim core (the driver, the hooks, the standard doc) + a tiny adapt layer (the `DOCTRINES=()` registry, the §10 instance table, the discovery pointers). I copied the standard, adapted §5/§8/§10 to LinkedSpec's reality (driver shipped; evidence-check deferred; hosted CI disabled per ADR 0004 so the *local* gate is E4), and wired `.githooks/pre-commit` + `tools/run_ci_local.sh` to the one driver. (2) **Start the registry with checks that already pass, so the driver is honest and green on day one.** The registry = the two EXISTING structural checks (memory-architecture + Knowledge Map) that the pre-commit already ran ad hoc; the adoption just *formalizes the ad-hoc stack into one self-reporting registry* (with a meta-check that every registered enforcer exists + is executable, so a registry line can't be a dangling promise). New LinkedSpec-specific doctrines (e.g. the evidence/task-acceptance hard-gate `.3`) grow incrementally — deferred because its change-scope globs + tool-output signature regexes need careful design to avoid false-positives. (3) **"TOOLBOX" means the project's OWN tools — foreground them; demote generic techniques.** The user twice emphasized "LinkedSpec own debug tools." The first draft leaned on generic methods (`comm`, `perl -c`, an ad-hoc fork census); the revision foregrounds LinkedSpec's *own* debug surface (the `LinkedSpec::Get`/`return_descriptor`/`call_spec_handler_subst`/`dump_parser_source`/`parse_only`/`generate_only`/`return_state`/`runtime_ctx_ref` probes-and-options, the `LINKEDSPEC_TRACE_LEVEL` framework, the `tools/*` scripts, the gates) and relegates the generic methods to a clearly-labelled §6. Every option/env name was verified against `perl/` (`grep $option->{…}`, `grep LINKEDSPEC_`, `ls tools/`) — a catalog that documents a non-existent flag is worse than none. (4) **A live git hook is risky — test the driver standalone BEFORE wiring it, and let the commit itself be the hook's integration test.** I ran `bash scripts/check_doctrines.sh` (exit 0, 2/2) and `bash -n` on the rewritten hook + CI script before staging, so wiring the hook couldn't break commits; the adoption commit then exercises the rewired `pre-commit` (regenerate-and-stage KM + driver) as its own proof. No engine/spec/production code touched.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.5.1 — a "natural-stop tail" can be a real failure wearing a mask; alarm() can't kill a catastrophic regex; and always confirm WHICH module loaded): Resolved the `corpus_regression` subtest-941 stale plugin dataset (TEST-ONLY) and, in doing so, uncovered a real green-phase0 blocker. Five durable points. (1) **A recurring "natural-stop boundary" / repeated SIGALRM-at-the-same-place is a hypothesis, not a fact — peel it and look underneath.** Multiple prior sessions recorded the phase0 "corpus tail" as an intended exit-255 natural stop (or an external-load SIGALRM). It was neither: `corpus_regression` runs 4 datasets *in order*, and dataset #1 `opendir`'d a directory (`plugin/`) that `NONCORE-QUARANTINE.3` had deleted → `opendir … or die` killed the subtest before any assertion, **short-circuiting datasets #2-4 and aborting the run at 941**. The "clean stop" was a hard error masking everything after it. The fix that revealed the truth was simply removing the dead dataset and *re-running to see what happens next*. (2) **Removing one masking failure routinely exposes the next pre-existing one — this repo has done it three times now.** subtest-110 RTLUtils hang masked the back-half (→173 failures); the back-half triage + the plugin `opendir` die masked the corpus parse; removing the plugin die exposed a catastrophic Lispish backtrack. Budget for "fix one, find one" when clearing long-standing blockers. (3) **`alarm()` does NOT interrupt a catastrophic regex.** Perl's safe-signals defer `SIGALRM` to between opcodes, and a single backtracking regex match is one opcode that never yields — so a `local $SIG{ALRM}` + `alarm(N)` guard around `$parser->()` runs forever. To bound/enumerate catastrophic parses you must **fork a child per input and `kill('KILL')` it from the parent** after a wall-clock timeout. That's the only way I could census the corpus (~21/22 conf files hard-killed at 6s ⇒ ≈100%). (4) **A 392-byte input taking 374 CPU-minutes is a regex pathology, not a data-size or loop problem** — ReDoS-style catastrophic backtracking in the (Lispish) spec/generated parser. The tiny input is the tell. (5) **A stale `PERL5LIB` silently loads the wrong checkout — always run `perl -Iperl` and print `$INC{'LinkedSpec.pm'}` in any ad-hoc probe.** My first probe loaded `…/pgen/fx/perl/LinkedSpec.pm` (an older, different repo on `PERL5LIB`) and produced fast bogus errors; the real run uses `-Iperl` (this repo's `perl/` prepended) and reproduces the hang. The conclusion only became trustworthy after confirming the module path. Engine/spec untouched; `.5.2` (the catastrophic Lispish parse) blocked on a user direction decision.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.2.4 — when a corpus uses a now-resolved construct to STAND IN for a blocked-category rule, restore the category not the aggregate; and adapt an obsolete-premise test to its concept's live members rather than re-blessing it to assert its own opposite): Re-blessed the 5 cluster F/G subtests (TEST-ONLY), closing cluster `.2`. Three durable points. (1) **A migration-summary / category-aggregate test is most faithfully fixed by restoring its corpus to genuinely category-matching rules, not by re-blessing the rolled-up counts.** The F migration-summary corpora used `return(1)` as a placeholder for "unresolved-helper-blocked" rules (under the retired-`return_a` model). Now that `return(1)` is resolved/ready, re-blessing would have meant editing ~20 cascaded aggregates (ready/blocked counts, ratios, ready/blocked lists, raw-only/unresolved-only/mixed breakdown) AND would have *gutted* the test's coverage — the blocker-type-breakdown test needs a rule in each of the raw-only/unresolved-only/mixed buckets, which re-blessing to zero would erase. Restoring those rules to a genuinely-unresolved form (`return(Leaf, $x)`; mixed = `return(Leaf, $x); my $tmp = 2`) brought every original assertion back to green with near-zero assertion edits (2 spec edits + 1 blocker-payload string for the whole pair) and kept the categories the test exists to verify. The aggregate is downstream of the corpus; fix the cause (the corpus rule's category), not the symptom (the count). (2) **`return(Label, expr)` (a label-mismatch return) is the canonical "genuinely unresolved helper" stand-in** now that `return(1)` resolves — ground-truthed: a rule with only `return(Leaf, $x)` reports `unresolved_helper_count=1, raw=0, ready=0`, and `return(Leaf, $x); my $tmp = 1` reports a *mixed* blocker (unresolved + raw). That single form reconstructs the unresolved-only and mixed categories the corpora need. (3) **A test whose PREMISE was retired must be adapted to its concept's surviving members, never re-blessed into asserting its own opposite.** `compatibility_surface_metadata_includes_legacy_helper_wrappers` asserted the retired method-helpers `return_m`/`return_a` stay "ready compatibility surface" — but those are now RAW_PERL (blocking). A naive re-bless (accept Top blocked, Leaf compat empty) would make a test named "…includes legacy helper wrappers / stays ready" assert that the wrappers are gone and the rule is blocked — actively misleading. The faithful fix swaps the corpus to the still-live members of the same concept (`assign_call_my`, `capture_if` are still tracked compat contracts; bare `return 1` = `return_bare`; `return(a("?Top:"))` is canonical-ready), so the test still verifies "legacy helper wrappers are tracked as ready compatibility surface" — with the helpers that still exist. Ground-truthed the adapted corpus end-to-end before editing. `perl -c` OK; focused harness 5/5; full phase0 **6 → 1** (only the `corpus_regression` natural-stop tail), 0 regressions. Engine/spec untouched.

- 2026-06-22 (PHASE0-BACKHALF-TRIAGE.2.3 — re-bless a white-box test by RESTORING the spec the assertions describe, not by degrading the assertion; verify a CPU-blocked leaf with a load-independent focused harness; and check the TAP's *reach* before trusting a `comm`): Re-blessed/rewrote the 20 cluster-C `emit_context` white-box subtests (TEST-ONLY, `t/phase0_regression.t`). Five durable points. (1) **When a test asserts a payload/label/shape its current spec can no longer produce, the spec was degenerated by an earlier pass — restore the expression-bearing form rather than gut the assertion.** Three subtests (`payload_events`, `canonical_action_ir_with_raw_fallback`, `nested_semicolon`) had specs reading `return(1)` but assertions checking `args.arg =~ /$x + 1/`, `args.label eq 'Top'`, and a nested-semicolon `do { my $x = 1; $x }` payload — orphaned by a prior re-bless that simplified the return to `return(1)`. The faithful fix restores `return(Top, $x + 1)` (contract `return` → `args={arg,label}`) and `return(do { my $x = 1; $x })` (contract `return_general` → `args.payload`), which makes the assertions pass *and* keeps the test's original coverage (capture a label+expression return event; keep a nested semicolon intact). Re-blessing those to the degenerate `{payload=>'1'}` shape would have silently dropped the label/expression/nested-semicolon coverage the subtest exists to protect. Ground-truthed every restored form via `LinkedSpec::Get(..., return_descriptor=>1)` before editing. (2) **`return(Label, expr)` and `return(expr)` are different contracts — let the engine tell you the args key.** `return(Top, $x + 1)` → contract `return`, `args={arg,label}`; `return(expr)` → contract `return_general`, `args.payload`. The nested-semicolon test had to flip `$ret_evt->{args}{arg}` → `{payload}` accordingly. Don't assume the arg key; dump it. (3) **When the full gate is starved by external CPU and SIGALRM-truncates the TAP, verify the unreached subtests with a load-independent focused harness that runs the *actual* subtest blocks.** Two full runs died at subtest 803 under a load-29 external `rustc` build, leaving the 9 late meta/nested subtests (804–857) unverified. Rather than guess, I extracted those 9 `subtest '…' => sub {…}` blocks verbatim from the file (brace-balanced) and ran them under a minimal `Test::More` harness against the live engine = 9/9 pass — in seconds, immune to the corpus alarm. The partial full-run already covered the 11 cluster-C subtests ≤803 (0 regressions in 1–803), so the two together cover all 20. (4) **A SIGALRM-truncated TAP makes `comm` report every unreached subtest as falsely "cleared" — check the reach (last `ok N`) before trusting the diff.** The truncated after-run's `comm` claimed 24 "cleared" (incl. F tests and the corpus tail that simply never ran); the real cleared set is confirmed only by a run that reaches ≥ the highest target subtest (857 here, 883 to match baseline). The reach number is the gate on whether the `comm` is meaningful. (5) **"Delete the dead seam" (triage hint) vs minimal scope: keep harmless dead scaffolding *consistent across its family* and defer a coherent sweep, rather than removing it piecemeal from only the failing members.** The 13 `emit_context_avoids_deps_*` subtests trap a now-removed `LinkedSpec::Deps::*`; the traps can't fire and the real "Deps unloaded" guarantee is covered by `emit_context_require_avoids_linkedspec_deps_load`. Removing the traps only from the 5 failing siblings would split the family; I re-blessed outputs and kept the traps, deferring a one-slice sweep of all 13 as optional hygiene. The only forced structural change was dropping the *genuinely removed* `_lower_return_array_statement` probe. `perl -c` OK; full phase0 **26 → 6**; `comm` set-diff = exactly the 20 cleared, zero regressions. Engine/spec untouched.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.2.2.2 — drive a "judgment-heavy" leaf with a pre-flight that replays the exact assertions; and a killed test run gives a FALSE set-diff, not a partial one): Re-blessed the 4 `return_a`/`return_m` subtests (TEST-ONLY) — the cluster's highest-risk leaf. Four durable points. (1) **When a leaf has per-test judgment forks, write a pre-flight probe that replicates the subtests' EXACT assertions and run it before touching the file.** I built `/tmp/verify_22222.pl` to call `LinkedSpec::Get` on the candidate-rewritten specs and check every assertion each subtest makes (`is_deeply` ACODE/ICODE/BCODE equality via `Dumper`, `fallback==0`, node-membership greps, hit counts) — all green *before* a single edit. That converts "I think this rewrite works" into "every assertion this subtest runs is satisfied," and it caught the shape up front (`nodes=[IMATCH_GROUPS_READ, RETURN]`, `hits{RETURN}=2`) so the re-bless values were dumped, not guessed. (2) **Recover a retired helper's intended mapping from the test's OWN paired form, not from a general rule.** The general card says `return_a(L) → return(array("?L:", array_copy(array(L))))`, but the no-arg chained `.return_a().return_m()` was paired in the block spec with `{ return(1); return_m(Top) }` — the author's own statement that `.return_a()` ≡ `return(1)` *here*. Mapping `.return_a()` → `.return(1)` (matching the block) preserves the fluent==block equivalence the test actually checks; forcing the general accumulator form would have broken `is_deeply(fluent, block)`. The paired form is the contract. (3) **When an assertion tests a now-retired feature, re-bless to the canonical reality, don't force-fit the dead name.** Subtest-1's `grep RETURN_A`/`grep RETURN_M` tested distinct return-variant nodes that no longer exist (both retired into one `RETURN`). The honest re-bless asserts what's now true — `grep RETURN` + `is(hits{RETURN}, 2)` (two chained returns = two RETURN events) — and the description says the variant nodes retired into RETURN, so the test still documents "the chain produces multiple events" without pretending the variants survive. (4) **A SIGALRM-killed test run produces a FALSE set-diff (untouched tests look "cleared"), because block-buffered TAP loses the last unflushed chunk — re-run to a complete natural stop, don't reason over the truncated file.** External CPU contention (an unrelated `cargo`/`rustc` build at system-load 32, exceeding the 10-min runner cap) killed the gate mid-run; the truncated TAP showed 12 *untouched* `emit_context` tests as "cleared" purely because their result lines were never flushed. The fix is environmental, not analytical: wait for load to drop, run to the suite's natural exit-255 corpus stop (a *complete* TAP), and only then trust the `comm`. The verification gate can be blocked by the machine, not the change — and a half-written TAP is worse than no TAP because it looks authoritative. `perl -c` OK; full phase0 **30 → 26**; `comm` set-diff = exactly the 4 cleared, zero regressions. Engine/spec untouched.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.2.2.1 — a recon is a hypothesis: read the test bodies, re-dump the engine, count the occurrences yourself before you trust the plan): Executed the 17-subtest B1-array re-bless (TEST-ONLY). Three durable points, each a place the recorded plan was *almost* right. (1) **"Pins no literal output" is a property of a test you must re-verify, not inherit.** The recon blanketed all 17 failing subtests as "assert only fluent==block + fallback==0 + ready, no literal," so "any canonical rewrite passes." Reading the two BOTH subtests' bodies (`@17289`, `@20105`) disproved it: each pins a literal `canonical_action_ir_hits` hash carrying the stale `RETURN_A => 1` — the deferred `.2.2.1` Form-B merge. Had I trusted the recon, the rewrite would have killed `RAW_PERL` (clearing fallback) but left `RETURN_A => 1` asserted against an engine that now emits `RETURN`, converting one failing assertion into a *different* failing assertion — a "fix" that doesn't fix. The cure is cheap and non-negotiable: open the actual `is_deeply`/`is` blocks in every target before planning the edit. (2) **Re-bless a count to a *dumped* value, never an inferred one.** "RETURN_A folds into RETURN, so 2→3" is a plausible inference, but I dumped the rewritten spec's hits through `LinkedSpec::Get` first: `{…RETURN=>3…}`, fallback=0, ready=1, and confirmed tag-independence (I==LX) so the single shared hit-hash in the 7-tag loop is safe. The probe is the contract; the inference is the hypothesis. (3) **Count the in-scope occurrences independently and make the transform fail-closed on the count — the recon's tally was off by one.** The recon said "33 spec-body + 1 subst = 34"; the truth is 33 in-range (32 spec-body + 1 subst), with `return_array` 74× file-wide and **byte-identical across 17 failing and ~20 passing switch-case subtests**, so the only safe scoping is by *line range*. The transform computed the expected count from the ranges itself, asserted `rewrites == that` AND file-wide `return_array(` delta == rewrites, and died-before-write on drift; the full dry-run diff (`git diff --no-index` original vs a `/tmp` candidate) was inspected end-to-end before the file was touched. Paren surgery (one extra close paren per call, `return(array(` opens 2 vs 1) is matching-paren-aware, not append-to-EOL, because several forms have trailing `.elseif(...)`/`, elseif(...)`. `perl -c` OK; full phase0 **47 → 30**; `comm` set-diff = exactly the 17 cleared, zero regressions. Engine/spec untouched.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.2.2.1 recon — measure a token's failing-vs-passing split before a scoped re-bless; a string in 40 passing tests is a regression trap, not a target): Pre-implementation recon of the B1-array leaf surfaced a hazard worth its own note. (1) **`grep -c` of the token you're about to rewrite is necessary but not sufficient — bucket every occurrence by whether its enclosing test currently PASSES or FAILS.** `return_array` appears 74× in the suite; the naive read ("rewrite the retired helper everywhere") would have rewritten all 74. But 40 of them live in *passing* switch-case subtests whose assertions only check fluent==block equivalence (both forms fall to `RAW_PERL` *identically*, so they pass) — rewriting those would have changed behavior in 40 green tests for no reason and risked turning them red. Only the 34 in *failing* subtests are targets, and one of *those* is a cluster-C `emit_context` site that belongs to a different leaf (`.2.3`). The spec-body strings are byte-identical across failing and passing families, so the scoping can only be done by *line range*, never by string match. (2) **A test that pins no literal output is easier to re-bless than one that does — confirm which before planning the edit.** The failing B1-array subtests assert only `fluent==block` + `fallback_count==0` + `ready` (no `is_deeply` against a literal), so any *canonical, fallback-free* rewrite applied identically to both the fluent and block specs makes them pass — I don't need to reproduce `return_array`'s exact old output shape, only its fallback-freedom. Verified `return_array(semantic_annotation, X)` → `return(array("semantic_annotation", X))` gives `fallback=0`/`ready` with fluent==block. (3) **When a leaf is mechanical-but-multi-form and late in a long session, record the full verified plan and hand off — the recon is the slice.** Four syntactic forms (`.return_array` tail / `; return_array }` / bare line / `if`-mixed) + a subst-arg, each needing paren-balanced surgery scoped to 17 ranges, is exactly the work where a fresh-session pass protects signoff quality. The complete plan (scope, forms, verified rewrite, paren note) lives in the `.2.2.2.1` node so the next session executes it without re-deriving. No code change — phase0 stays 47.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.2.2 — recon by *helper*, not by cluster; recover semantics from the retirement commit then VERIFY the mapping before trusting it): Split the judgment-heavy B1 leaf (21 retired-helper subtests) into `.2.2.2.1` (array) + `.2.2.2.2` (accumulator) after a recon + an archaeology pass. Three durable points. (1) **When one re-bless leaf bundles several retired helpers, their blast radius differs — map the failing subtests by *which* helper before deciding the slice shape.** Mapping the 21 by helper showed 17 use `return_array` and 4 use `return_a`/`return_m`, and those two families need *different* work: `return_array` is a **pure alias** (first arg = rule label, dropped; barewords auto-quoted; output == canonical `return(array(...))`), so it's mostly an input-string rewrite with the expected often already canonical; `return_a`/`return_m` add a `"?L:"` tag + `array_copy(array(L))`/`entry_groups()`, which *change the dumped shape*, so their dependent `is_deeply`/node assertions must be re-dumped and re-blessed. Splitting on that line makes the array half near-mechanical and isolates the genuinely judgment-heavy half — instead of one 21-subtest slog at uniform (high) risk. (2) **Recover a retired helper's semantics from the retirement commit's own diff, then VERIFY the mapping empirically — a recovered mapping is still a hypothesis.** The archaeology agent read the COMPAT-ALIAS-RETIREMENT-V2.2 diff (`4e92503`) and produced a table, but its simplified `return_array(tag, payload) → [tag, payload]` was *wrong* for the actual phase0 usage: a direct `call_spec_handler_subst('Top', 'return_array(Top, semantic_annotation, hash(...))')` probe showed the engine **drops the first label arg** and **auto-quotes the bareword**, yielding `["semantic_annotation", {...}]` — i.e. `return_array(L, e1, e2) → return [e1, e2]`. Catching that *before* enshrining it saved 17 rewrites from a systematic off-by-one-arg error. The probe, not the prose, is the contract. (3) **The decomposition + a KM card is the honest slice when the leaf is judgment-heavy.** The verified per-helper mappings + pitfalls (incl. "`imatch()`/`imatch_list()` are NOT valid canonical helpers — they pass through to RAW_PERL too") live in `docs/knowledge/retired-return-helpers-canonical-rewrite.md` so the implementation session executes mechanically instead of re-deriving. No test/engine/spec change this slice — phase0 stays 47.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.2.1 — "mechanical re-bless" is two forms, not one; guard a bulk edit so it can't run on drift; and disprove a flake, don't wave it away): Re-blessed the 55 pure-B2 `method_like*` subtests (TEST-ONLY, `t/phase0_regression.t`). Four durable points. (1) **A retired node that *renames* is a faithful flip in a membership test but a *merge* in a count hash — handle the two forms separately.** `RETURN_A` retired *into* `RETURN`, so a `grep { $_ eq 'RETURN_A' } …nodes` membership check just flips the literal to `'RETURN'` (the node is still produced). But a `canonical_action_ir_hits` literal that carried BOTH `RETURN => M` and `RETURN_A => 1` must **merge** to `RETURN => M+1` — a blind `s/RETURN_A/RETURN/` would emit `{RETURN=>M, RETURN=>1}`, and Perl's last-key-wins silently sets the count to 1, turning a green re-bless into a wrong-count failure. 52 flips + 19 merges, recognized as distinct transforms, not one regex. (2) **Bulk-edit a 44k-line file with a guarded one-pass transform that asserts each target's shape and aborts before writing on any drift.** The script verified the Form-A occurrence count == exactly 52 and that every Form-B `RETURN_A => 1` sat directly beneath a `RETURN => N` line (alphabetical hash order guarantees adjacency) — die-before-write on mismatch. That turns "71 hand edits across 90 candidate sites" into one reviewable, fail-closed operation; a drifted file (e.g. a renamed fixture) stops the run instead of silently corrupting an unrelated hash. (3) **Measure the token's blast radius and exclude the look-alikes by *meaning*, not just by name.** `RETURN_A` appears 90× but only 71 were targets: 14 are cluster-C `emit_context` sites — including **passing** `helper_action_ir_events {kind} eq 'RETURN_A'` / `helper_action_ir_nodes` sites where `RETURN_A` is a still-valid *helper-event kind* (a different field than `canonical_action_ir_nodes`) — and 3 are BOTH subtests whose spec body uses a retired *helper* (→ `RAW_PERL`, a rewrite not a rename). Anchoring Form-A on the full `scalar(grep … @{$X->{canonical_action_ir_nodes}})` shape (not the bare token) is what kept the 12 passing kind-sites green. (4) **A "regression" in the set-diff is a hypothesis — disprove it with a clean re-run, and use the test's own coordinates.** The first after-run flagged one after-only failure (`parser_invalid_input_fails_at_runtime_parser_boundary`). It is a `Lispish` `open3` subprocess test at source line **4163 — before every one of my edits (17000+)** — exercising the *engine*, which a TEST-ONLY re-bless cannot touch; its exit-0/empty-output signature is the known CPU-contention flake (the same `bin/fsmgen`/concurrent-`prove` starvation noted in NONCORE-QUARANTINE.3). A clean re-run returned `ok 137` and an empty new-failure set. "Textually before the diff + engine byte-identical + non-deterministic on re-run" is the proof it's a flake, not a regression. Full phase0 102 → 47; cleared = exactly 55; engine/spec untouched.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.2 — split before you sweep: recon + a probe turns a "76 mechanical re-blesses" into a scoped, safe plan): Did NOT start editing cluster B (76 `method_like` subtests); split it into `.2.2.1`/`.2.2.2` after a read-only recon and an empirical probe. Three durable points. (1) **A triage verdict ("re-bless, mechanical") is a hypothesis about the *whole* cluster; sample the engine before trusting it for 76 edits.** One probe spec showed the canonical return node is now `RETURN` (not `RETURN_A`) — so B2 is a faithful `RETURN_A`→`RETURN` *rename*, not a *drop* (dropping would silently weaken 55 membership assertions). The same probe showed `.return_a().return_m()` lowers to `RAW_PERL` and `call_spec_handler_subst` returns retired helpers unchanged — so B1 (18+3 subtests) is genuine spec-*rewrite* work needing each retired helper's canonical mapping, not a token swap. Two sub-patterns hiding under one "cluster B" verdict; conflating them in one sweep would have mangled the B1 specs. (2) **Before any bulk find-replace, measure the blast radius of the token you're about to change.** `grep -c RETURN_A` = 90, but those 90 span cluster B, cluster-C `emit_context` white-box tests, AND apparently-passing `helper_action_ir_events` tests where `RETURN_A` is a legitimate event *kind*. A global `s/RETURN_A/RETURN/` would have turned ~12 passing tests red. The recon's per-subtest line map is what makes the edit scoped instead of a shotgun. (3) **When a leaf is too broad or partly judgment-heavy, the honest slice is the decomposition itself — and the hard-won analysis must be persisted to a durable layer, not left in chat.** The recon table + the empirical mapping live only in the conversation until written down; I captured them in the task tree (`.2.2.1`/`.2.2.2` nodes with the work-list + scope hazards) and a KM card (`actionir-return-node-retired-to-return`) so the next session executes mechanically instead of re-deriving (archaeology). No test/engine/spec change this slice — phase0 stays at 102.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.2.1 — re-bless against *dumped* engine output, not the triage prose; and a "cluster" count is a hypothesis, verify it from the run): Re-blessed the 7 cluster-A parser-collection-shape subtests (TEST-ONLY, `t/phase0_regression.t`). Three durable points. (1) **Before re-blessing a stale expectation, dump the actual engine output for that exact spec+input — never transcribe the value from the triage note.** A focused repro over the cluster-A specs (`Choice::OR+`, `::AND`, `::|`, `AND+`, `AND{2}/{2,3}/{,2}`) printed the real shapes (`[1,1]`, scalar `1`, `[[1,1],[1,1]]`), which confirmed the precise mapping (`['?Rule:',[]]` → the child's own `return(1)`) and the exact nesting to write. Re-blessing to a *measured* value is what keeps a re-bless from silently freezing a second bug. (2) **The triage's cluster count was a hypothesis (8); the run said 7.** The 8th name the triage filed under A — `blind_call_fluent_post_call_chain_matches_block_form` (206) — actually fails on the retired `.return_a()` helper, i.e. it's cluster B. Authoritative bucketing comes from the failing assertion (auto-tag shape vs retired-helper payload), not the subtest-name keyword; I re-filed it to `.2.2` and kept the STALE total at 108. (3) **Prove a re-bless slice the same way as an engine fix: full-suite `comm` set-diff, not just a lower number.** 109 → 102 is the headline, but the name-level set-diff (cleared = exactly the 7 cluster-A; new failures = none) is the proof the edit touched only what it claimed — even though external `bin/fsmgen` CPU contention SIGALRM-killed the run at the corpus tail, the set-diff is robust because the edit is textually confined to subtests 144–166 (so subtests 167+ cannot change behavior by construction). Engine/spec untouched.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.4 — a guard belongs where the deref is, and it must mirror the authority's exact contract): Fixed input-boundary Defect #2 (one file, `Runtime.pm`). Three durable points. (1) **A wrapper that pre-processes input must not dereference before the layer that owns input validation runs.** The `MEDIUM-IMPACT.3.2` comment-skip wrapper did `pos($$input_ref) = 0` at the very top, so a non-SCALAR-ref input died there with a raw `Not a SCALAR reference` — *before* the documented guard inside the compiled parser (`Compiler.pm validate_input_ref`) could produce the friendly message and populate `last_error`. The fix isn't to re-implement validation in the wrapper; it's to make the wrapper's own deref conditional (`if (ref($input_ref) eq 'SCALAR')`) and otherwise delegate untouched, so the existing authority still fires. Don't duplicate a contract — guard your own access and defer to the owner. (2) **Mirror the authority's acceptance test exactly, not approximately.** The inner guard accepts iff `ref ne 'SCALAR'` rejects — i.e. strictly `ref eq 'SCALAR'` (a blessed scalar ref or a `REF`-to-ref is rejected too). I used the identical predicate in the wrapper so there's no shape the wrapper would skip-process that the inner guard would later reject (or vice-versa). A guard that's looser or tighter than the contract it protects just moves the bug. (3) **Prove "only the intended tests moved" with a set-diff of the failing TAP, not just a lower count.** 111→109 could in principle hide a regression masked by a new pass; `comm -23` of the before/after failing-name sets showed the delta was *exactly* the two Defect #2 subtests and nothing else. The count is the headline; the set-diff is the proof.

- 2026-06-21 (PHASE0-BACKHALF-TRIAGE.3 — the fix that compiles the *generated* code is the one that counts; read the emitter's own working siblings; and let the test's expected SHAPE pick the design): Fixed AND-rule action-codegen Defect #1 (one file, `HandlerVariantEmitter.pm`). Five durable points. (1) **The bug was a one-character-class Perl quoting slip with an outsized blast radius: `\$"` vs `"\$"` inside a `/e` substitution replacement.** `s/\breturn\s*/\$" . $label . " = "/eg` evaluates the replacement as Perl, and bare `\$"` is `\($")` — a *reference to* the list-separator variable `$"` — which stringifies to `SCALAR(0x…)`; the intended literal `$` is `"\$"` (a double-quoted escaped dollar), which the SAME file already uses correctly three times (lines 524, 594, 928). Two sibling AND emitters had the broken form; the REP and I-block paths had the right form. Lesson: when one emitter is broken, diff it against its working siblings in the same file before inventing a fix — the correct pattern was already there. (2) **Dump the GENERATED source, not just the symptom.** `dump_parser_source => 1` + reading `runtime_ctx->{parser_source_chunks_ref}` printed `SCALAR(0xa6904dbe8)Top = ["?Top:", do {…}]` and a `return \@Top_collect` that nothing ever pushes to — that one dump revealed BOTH sub-bugs (the ref-stringification AND the wrong result shape) far faster than staring at the emitter template. (3) **The test's expected VALUE SHAPE is the design spec.** The contract was `['?Top:','bar']` (raw payload), not `[['?Top:','bar']]` (collect-wrapped) — that single fact rejected the "fix the typo but keep transform-to-assignment-and-collect" path (which can only ever produce a wrapped/empty result) and pointed at "emit edge acodes verbatim so `return [...]` returns directly." Cataloguing all 21 affected tests up front (one read-only agent) confirmed the shape was universal and that `call(Child)` is *always* wrapped as `return(call(Child))` (so removing the `call(` transform was safe). (4) **Verbatim emission is safe in BOTH AND contexts precisely because of the coderef wrapper.** A direct AND uses the seq body as the handler, so a verbatim `return X` exits the handler (correct). A REP-AND (`:AND+`) has `_emit_rep_and_acode_handler` wrap that same body in `sub { … }`, so the identical `return X` exits ONE iteration and the outer loop collects it (also correct). One change, two correct behaviors, because the surrounding structure — not a per-edge rewrite — decides the collection point. (5) **Bound the blast radius and prove it empirically.** Only the two `:AND`-acode emitters were touched, so NORMAL/OR/REP/bcode handlers are untouched by construction; the full-suite delta (173→111, exactly the predicted ~62-63 AND tests cleared, the remaining 111 all pre-existing known failures) is the proof that "small surface" held. The remaining 111 reconcile to the penny: 108 stale + 2 Defect #2 + 1 corpus-tail. Authorized by ADR `0008` (sanctioned engine-frozen exception).

- 2026-06-19 (PHASE0-BACKHALF-TRIAGE.1 — a "cluster" is a name-bucket, not a root-cause; let the symptom value (1 vs undef vs []) route the verdict; and bisect the engine, don't trust the bucket): Completed the read-only triage of the 173 back-half failures. Five durable points. (1) **Bucketing 173 tests by name keyword is necessary but NOT a root-cause — judge by the failing assertion's got/expected, not the subtest's name.** The six clusters (method_like/emit_context/named_mark/…) each turned out to be one of TWO root causes that cut across the name buckets: *intentionally-retired behavior* (STALE, re-bless) vs a *real codegen/validation defect* (REAL, engine-fix). The `emit_context` bucket alone split 20 STALE + 1 REAL; the `singles` bucket split 2 STALE + 4 REAL. Never let the name bucket decide the verdict. (2) **The got-value histogram is a fast root-cause router: `got=1` ⇒ engine ran `return(1)` and the test wanted the old tagged array (STALE); `got=undef` ⇒ handler failed to compile (REAL codegen); `got=[]` ⇒ handler compiled but dropped the payload (REAL codegen).** Grepping the TAP for `# got:` shapes ("60×1, 13×undef, 9×0") pre-sorted the 173 into stale-vs-real faster than reading 173 blocks. (3) **Bisect the engine with minimal repros before naming the bug — I almost mis-rooted it.** First read said "capture/mark helpers are broken"; the V1–V4 bisection proved capture/mark is FINE (single-edge AND works) and the real trigger is *multi-indexed-edge AND + a `return` edge* (the `SCALAR(0x…)Rule` emitter bug). And the "child rule returns `[]`" vs "top rule won't compile" are two SYMPTOMS of the SAME assembler bug — only a repro of each shows that. Dumping the generated handler source (`SCALAR(0x841821b88)Top = [[@items]]`) is what pinned it to the emitter, not the lowering. (4) **Read-only-triage-first is vindicated by exactly this:** re-blessing cluster D (60 tests, author-written `'?Child:'`/`'?Top:'` tags) would have frozen a non-compiling/empty-output engine path as "expected" and masked a real bug that makes the whole capture/mark feature unusable in multi-edge AND rules. The user's instinct to triage before touching anything was correct. (5) **"engine bytes unchanged" + "fails identically on the prior commit" = pre-existing latent defect, not my regression — but it's still a REAL engine bug to fix, not a stale test.** Two of the 173 (Defect #2) even trace to a *prior* commit (`d7294d0`, MEDIUM-IMPACT.3.2) that added a `Runtime.pm` wrapper deref ahead of the input-boundary guard — a real regression that was simply masked by the hang for as long as it has existed. "Latent" ≠ "stale." Both engine fixes (`.3`/`.4`) touch the reference `perl/` engine → blocked on user authorization per [[feedback_do-not-fix-reference-engine]] (these are genuine defects — invalid Perl + pre-empted validation — not docs-vs-reference drift). No code changed in `.1`; KM cards written; self-check + KM gate pass.

- 2026-06-19 (Triage start + trace directive — check whether the feature already exists before building it; and root-cause with the engine's own trace): Two durable points from owning the back-half triage + the user's trace directives. (1) **The "missing" CLI trace control already existed — `LINKEDSPEC_TRACE_LEVEL=debug` (Trace.pm ~236–261) — it was just undiscoverable** (no `--trace` flag, no `bin/` entrypoint, not in the book), which is why both the user and I assumed it was absent. Lesson: before "introduce X", grep for X (`grep ENV\{ ... TRACE`); the gap was discoverability + coverage, not existence — so the work is *expose + extend*, not *build*. (Also: setting `$LinkedSpec::Trace::DUMP_VERBOSITY` directly does nothing — the init is gated by `$TRACE_INITIALIZED` and reads the env var; use the env var or `configure_trace`.) (2) **Root-cause with the engine's trace + a minimal repro, don't infer from the diff.** For the parser-shape cluster I built the exact failing spec (`Choice::OR+ => First => Second`, children `return(1)`) and ran it under `LINKEDSPEC_TRACE_LEVEL=debug`: the engine returns `[1,1]` (each child's literal `return(1)`), while the test asserts the retired `['?Rule:',[]]` tagged-accumulator shape — so the cluster is *stale tests*, not an engine bug. Confirming via repro+trace (vs guessing "stale") is what makes the re-bless-vs-fix decision trustworthy. Clusters B–E (method_like/emit_context/capture-mark) get the same treatment next.

- 2026-06-19 (NONCORE-QUARANTINE.3+.4 — let the broken suite localize its own surgery; and a removed blocker is a discovery generator): Completed the relocation (23 domain `.pm` + 13 `.plg` → `noncore/`) and excised the 37-subtest legacy block. Four durable points. (1) **After moving the modules, phase0 *fast-fails* (require-not-found) instead of hanging — so the suite itself pinpoints exactly which subtests are island.** I moved everything first, ran phase0, and it died fast at the first island subtest; combined with a `git grep` showing all island references sit in one contiguous source range (3312–5378, nothing after 5700), that proved the legacy-migration block is excisable as a unit. Before excising, I verified the block had no shared file-scope `sub`/`my` used by later core tests (the `sub IndexOf/Recurse/…` in-range were moved-module stubs, not shared core setup). Anchor-splice (guarded unique start/end) removed 37 subtests cleanly (996→959), `perl -c` OK. (2) **Removing a long-standing blocker keeps generating discoveries — budget for it.** LEGACY-VHDL-RETIRE removed the RTLUtils hang → unmasked the HTML::PathLinks hang; NONCORE-QUARANTINE removed the whole island → unmasked **~173 pre-existing core-engine test failures** in the back half. Each layer peeled reveals the next. The back half of this 996-subtest suite has effectively been dark for a long time. (3) **Distinguish "my change broke it" from "my change revealed it" — by what changed and how it fails.** The 173 are structural/shape mismatches (e.g. parser returns `'1'` where an array is expected), 0 timeouts, 0 missing-module errors; and this work changed **zero engine bytes** (only `git mv` of non-engine files + test removal + docs). So the engine is byte-identical and these fail identically on the prior commit — pre-existing, not regressions I introduced. Most likely **stale tests** (written for evolved ActionIR/HandlerIR output, never re-run because of the hang), since the shipped specs + the front 100 subtests pass. Owning that distinction (revealed ≠ caused) is what lets me commit the relocation honestly and hand the 173 to a separate triage tree rather than treating them as my bug. (4) **Watch for external contention before trusting timing/flaky results.** Two runs gave wildly different progress until I found another session's `bin/fsmgen --emit-semantic-json` at 100% CPU starving the `alarm()`-guarded subprocess tests — I did NOT kill it (not mine) and confirmed it wasn't the cause of the structural 173. Relocation correct + committed; green phase0 blocked on the 173 (surfaced to the user).

- 2026-06-19 (NONCORE-QUARANTINE.1+.2 — reframe a symptom into the right problem; reachability is rooted/directional with dynamic edges; and quarantine beats delete when fate is undecided): The user redirected twice — first "extract `LinkedSpec.pm`'s dependency tree and act on what's unused," then "**move the non-core modules to a holding area, don't delete them**." Four durable points. (1) **The phase0 back-half hangs were a symptom, not the problem.** `HTML::PathLinks::link_path_tokens` etc. hang, but those modules aren't reachable from the product — they're a dead legacy island. So the fix isn't hang-by-hang debugging; it's separating the island out (which removes the hanging tests with it). Reframing a scary open-ended bug hunt into a bounded relocation is the highest-leverage move. (2) **A `use`/`require` scan is NOT the dependency tree — the decisive edges are dynamic name resolutions.** `LinkedSpec::get_parser('Lispish')`→`PathSearch`→`specs/Lispish.spec`; `get_plugin`/AUTOLOAD→`.plg`; `.plg`→`Module::func`. The user's `Lispish.pm` example was exactly this trap. And reachability is **directional + rooted**: `Lispish.pm` *uses* `Lispish.spec`, but nothing uses `Lispish.pm` → it's a dead consumer (non-core), while the spec it points at is kept. "X uses Y" says nothing about whether X is alive; only "is X reachable from a root" does. (3) **The cleanest cut was empirical:** shipped specs reference *zero* plugins/cross-specs (one grep), which severs the whole `.plg` corpus + domain-`.pm` island from the product in one stroke — 36 non-core `.pm` + 13 `.plg`, with a verified zero core→domain edge as the safety proof. Delegated the graph build to an agent, then cross-checked the load-bearing claims myself (`Global` has no core ref; tools/bin clean; the 12 zero-ref modules are 0-ref repo-wide). (4) **Relocate > delete when the fate is undecided (user call).** `git mv` to `noncore/` (layout preserved, loadable via `-Inoncore`) keeps every option — refactor / port (Rust/Julia/Dart) / publish / `git rm` — open and reversible, makes the non-core boundary explicit, and unblocks the engine, at near-zero cost vs deletion. A `noncore/README.md` ledger parks non-binding fate hints so future-us doesn't re-decide from zero. First batch = the 12 zero-reference modules (no code/spec/test touched). Plugin machinery stays in core (reachable via deprecated stubs) — POSTPONE. Honest read: most of the island is obsolete EDA glue tied to dead vendor tools / Win32 OLE / Tcl::Tk; a couple (Lispish parser, Liberty reader) have a reusable kernel worth a clean LLM-assisted rewrite *later* — the old code is best kept as a reference spec, not ported as-is.

- 2026-06-18 (LEGACY-VHDL-RETIRE.2+.3 — clearing one hang exposes the dark code behind it; prove the hang location, don't trust the prior note; and edit a 46k-line test file with the test runner as your backstop): Retired the Perl-only VHDL/RTL/FSM subsystem. Five durable lessons. (1) **A long-standing hang masks everything after it — removing it is a discovery, not just a fix.** The original `t/phase0_regression.t` hung at subtest 110, so subtests 111+ (the whole back half) had been *dark* for who-knows-how-long. Clearing the RTLUtils hang immediately surfaced a SECOND, pre-existing, unrelated hang (`HTML::PathLinks::link_path_tokens`, subtest 131) plus back-half failures. Lesson: when you remove a blocker that's been there a while, *expect* to inherit a backlog of newly-visible problems, and budget for triage rather than assuming "green." (2) **Prove the hang location with a pristine worktree before trusting any recorded attribution — including your own.** `LEGACY-VHDL-RETIRE.1` had "corrected" the hang to `RTLUtils.pm:746`/`drive_entity_component`; a `git worktree add --detach HEAD` run under `timeout` showed subtest 109 (`drive_entity_component`) *completing* and subtest 110 (`add_header_n_context_clause`) *hanging* — so the ORIGINAL MEMORY/ADR attribution was right and my `.1` "correction" was wrong. The pristine-worktree-with-timeout is the clean way to ground-truth a hang without contaminating your working tree. (3) **Distinguish "hung" from "slow," and "no output" from "didn't run."** Foreground runs got killed at 250s/600s reaching subtests 130/133 — that read as a possible second hang, but the back half is just subprocess-heavy AND has a real hang at 131; and the subtest-131 snippet showed "no output" only because STDOUT was buffered before the hang (the `require`s actually load fine — the *call* `link_path_tokens` hangs). Always retest with `$|=1`/file redirection and isolate `require` vs call. (4) **Editing a 46k-line test file: delete whole blocks by unique anchors, surgically clean mixed blocks, and let Test::More's per-subtest `plan` counts be the correctness oracle.** 8 module-smoke subtests deleted via an anchor-splice Perl pass (guarded unique start/end), 7 *mixed* subtests (which used the deleted `.plg` as corpus for kept-module assertions) cleaned by hand with exact `plan tests => N` recomputation; a wrong count or a dangling slurp fails loudly when the suite runs. (5) **Tracked vs untracked deletion matters (user rule):** every deleted file here was `git rm` (the 6 `.plg` + 3 modules are all tracked); `rm` is only for untracked artifacts. RTLUtils hang cleared; phase0 still not green (back-half) → gate stays blocked, surfaced to the user.

- 2026-06-18 (LEGACY-VHDL-RETIRE.1 — own the tree + a read-only inventory before you touch a destructive gate; verify the agent, not the prose): The recorded next action was "retire the Perl-only legacy VHDL subsystem to clear `RTLUTILS-REGEX-HANG`." Four durable points. (1) **The first leaf of a retirement is a read-only inventory, not a deletion — and it's non-destructive, so it proceeds without the user gate, while the deletions stay `blocked` on explicit scope confirmation.** `MEMORY.md` + [[feedback_keep-only-portable-cross-variant]] both say "confirm removal scope before deleting"; so `.1` maps everything and the deletions (`.2`–`.5`) are recorded `blocked` with the unblock condition = user scope confirmation. That lets me make real, committed progress on the gate-clearing prerequisite without overstepping a destructive, irreversible-feeling boundary. (2) **A delegated inventory is a hypothesis; the signoff move is to re-run the load-bearing sweep yourself.** An Explore agent produced a strong inventory, but I re-ran the `git grep` reference sweep + `wc -l` directly — which both confirmed the agent (6 dependent `.plg`, zero core dependency) AND caught that `ROADMAP_V2.md:157`/`ARCHITECTURE_STATE.md:588` still describe `generic_fake_memory_module.plg`/`wrapgen.plg` as live `ceil_log2` callers when **both files no longer exist** (stale drift). Trust, but verify — especially the negative ("nothing in core depends on this"). (3) **"Retire, don't fix" is the right call precisely because the regex lives in soon-deleted code.** The catastrophic regex is at `RTLUtils.pm:746` (not `add_header_n_context_clause` as earlier notes said — corrected); patching it would be wasted work on a module headed for deletion, and the subsystem is non-portable Perl-only legacy with zero `.spec`-core dependency and no Rust/Julia/Dart counterpart — exactly the retirement-debt the doctrine targets. (4) **Removing the phase0 migration-smoke tests is correct, not coverage loss:** those ≈206 lines only assert the *prior* plugin→package-owner migration shape of the very code being deleted, so they're obsoleted with it. No engine/spec/test code changed in `.1`; KM card `rtlutils-regex-hang.md` written; self-check + KM gate pass.

- 2026-06-18 (SPEC-FORMAT-TERSE.0 — ratify the WHAT before the HOW; activation ≠ implementation when a gate is down): The user activated the `SPEC-FORMAT-TERSE` tree (terse `.spec` format) mid-stream. Three process points worth keeping. (1) **A `proposed` tree's first leaf on activation is `.0` ratify+ADR, not engine code — and `.0` is the one leaf NOT gated by the regression suite.** That let me honor "activate now" immediately and to signoff quality (a complete ADR ratifying Rounds 1–3, the migration policy, the variant-parity stance, the reference-touching exception) without touching the Perl engine while `t/phase0_regression.t` is hung by the pre-existing `RTLUTILS-REGEX-HANG`. The implementation leaves (`.1.x`+) DO need the gate, so I recorded the gate as an explicit precondition and surfaced the execution-order decision rather than diving into engine code blindly. (2) **An apparent doctrine conflict can be a scoped exception, not a contradiction.** `[[feedback_do-not-fix-reference-engine]]` says "don't fix the reference" — but it governs *docs-vs-reference disagreements* (fix the docs). Deliberate, user-authorized language evolution is a different thing; the tree itself scopes "prove on the Perl reference first, then all variants in lockstep." I recorded this as a sanctioned exception in ADR 0007 + the auto-memory, instead of treating "activate SPEC-FORMAT-TERSE" as forbidden. (3) **Migration policy is the load-bearing design choice: gradual alias beats big-bang here.** Canonical-new-form + deprecated-old-alias (lower to identical ActionIR) keeps all 20 shipped specs + the book compiling and the ratio-1.0000 ActionIR-ready invariant (ADR 0002) intact at every step; old names retire in a later explicit leaf after the corpus + book are re-authored. Recorded as the ratified policy, flagged as confirmable. No engine/book change in `.0`.

- 2026-06-18 (SPEC-LANG-REFERENCE.10.5.4 — re-derive the WHOLE chapter, not just the broken rule; a flagged helper is a fork to surface, not a guess): Rewrote `worked-spec-walkthrough.md` (the book's central walkthrough) to the 2-rule idiom and ground-truthed every claim. Four durable points. (1) **A single-rule chapter that claims a scalar/hash result almost certainly mis-states its shape.** This chapter's whole narrative said the parser returns one hash `{kind,name,value}`; the verified 2-rule form returns the entry rule's accumulator snapshot — a one-element **list** `[{…}]` — and a longer input returns a longer list. Re-deriving with a mode-aware `LinkedSpec::Get` driver corrected the output shape in the intro, the "Running it inline" block, AND the `seek`/`consume` blocks (4 separate claim sites for one underlying fact). (2) **Output is not the only thing that moves under the 2-rule idiom — identity does too.** The top rule is now the `Top::` entry rule, so `runtime_ctx_ref`'s `ctx{top_rule}` flipped `Pair`→`Top`; the descriptor's `exists spec{Pair}` still held only because the matcher kept the name `Pair`. Re-probe the descriptor/ctx claims, not just the parser output. (3) **Two new dispatch traps, isolated by bisection.** `Pair:AND` with the `I {…}` block on a *separate* line collapses the pushed value to `[0]` (a bare `Pair:` matcher with regex+`I {` on one line returns the hash); an OR matcher with an `I` block over alternative capture groups is fragile (`[null]`/`[]`). Both were caught by running variants through the oracle before writing prose — so the OR growth path is shown as a structural sketch with no output claim, not a fabricated runnable. `entry_group(N)` (entering match), not `match_group(N)` (local match, unset in a dispatched single-slot matcher), remains the load-bearing reader choice. (4) **When the user flags a helper, verify its real status before acting — then surface the fork.** `declare()`/`assign()` (in the advanced sketch) turned out **live** in the reference engine (active `Contracts.pm` contracts) and pervasive in shipped specs + the book; their removal is owned by `SPEC-FORMAT-TERSE`, which was `proposed`, not done. So purging them book-wide now would itself be drift (book must mirror the live engine) and pre-empt unratified work. I removed them from the one optional sketch (safe, user-aligned) and surfaced the real fork via AskUserQuestion; the user chose to **activate `SPEC-FORMAT-TERSE`**, pausing the scorch. `mdbook build` exit 0; self-check exit 0. No Perl change.

- 2026-06-17 (SPEC-LANG-REFERENCE.10.5.1 — a whole-book audit; isolate your verification tooling, and let the scale of a doctrine-divergence be a decision the owner makes): Ran the exhaustive whole-book `.spec`-snippet scorch audit with **8 read-only `Explore` agents** over chapter groups, then personally re-ran every load-bearing finding. Four durable points. (1) **Don't let parallel agents share a mutable scratch tool.** I gave all 8 agents the same driver path `/tmp/lsq/run.pl` and told them to write scratch *spec* files there; one agent "helpfully" rewrote the *driver* itself mid-run (its replacement `use lib '…/pgen/fx/perl'` + `require LinkedSpec::Parser` broke it), which corrupted a run in my own shell. Fix: a **private** driver (`/tmp/lsq_me/run.pl`) the agents don't know about, and treating every agent `ACTUAL_OUTPUT` as a hypothesis to re-verify (the `.10.6` lesson, now mechanized). (2) **Probe the engine for the structural rule instead of arguing from the doctrine.** Direct `LinkedSpec::Get` probes settled what prose couldn't: `child::AND /re/` and `child:AND /re/` compile + run **identically** (`[0]` both), only the **first** rule is the `_INITIAL` entry, and multiple `::` rules don't collide — so "no regex on a `::` rule" is an **authoring discipline the book should teach**, not an engine constraint the compiler enforces (it reconfirms `.10.6`: the engine is permissive). (3) **When a long-standing, deliberately-written idiom turns out to be pervasively off-doctrine, the *scale* is the user's call, not mine.** The audit found the `Rule::AND /regex/ -> Rule[N] {return}` shape — regex on a `::` rule AND the `[]`-dropping self-slot-edge — in **~105 rule headers across ~20 files**, and `rule-modes-and-parse-modes.md` *explicitly teaches* `::AND`/`:AND` as "both valid shapes" (engine-true!). The agents themselves split on whether isolated helper-illustration fragments were violations. Rather than guess between "fix ~10 broken examples" and "rewrite the book's example idiom," I asked one AskUserQuestion; the user chose **full book-wide scorch**. Lesson: a scope that ranges over an order of magnitude, premised on doctrine-over-engine-permissiveness, is a decision to surface, not to assume. (4) **Re-verification overturns hypotheses in both directions.** The preliminary hunt's "`ebnf` richer example does not compile (Class D)" was **wrong** — a direct run parses it cleanly to its claimed structure (CLEAN); meanwhile portmap/tablegrep output drifts were confirmed exactly (`sens` `=` not `=~`; nested `["?bare:",["clk"]]` not flat). The audit is `.10.5.1`; it decomposed the remediation into per-file fix leaves `.10.5.2`–`.10.5.19` (`.10.4` folded into `.10.5.16`). No book/Perl change.

- 2026-06-17 (SPEC-LANG-REFERENCE.10.6 — verify a premise before propagating it; a sound doctrine needs no false mechanism to justify it): While starting `.10.4` I ground-truthed the `.10` correction's premise ("a regex on the top rule → `[]`; the `.5.2`/`.9` examples were broken") via `LinkedSpec::Get` and found it false: the OR self-ref / cross-rule action-edge regex-on-`::`-rule forms (the old examples AND the project's OWN frozen oracle fixtures `Top:: /x/ -> Done {…}`) run and return their value (`"hello-world"`, `5`, `["?pair:","key","val"]`); `match_group(N)` works in them; the ONLY shape returning `[]` is the explicit `::AND … -> Rule[N] { return }` (the real `.10.1` finding). Two reusable points. (1) **A recorded "verified" premise is still a hypothesis when it is the load-bearing justification — re-derive it before building more on it.** The `.10` correction was recorded as user-established + source-verified, but the source check (`Core.pm:414` "the label line has no regex") proved a narrow *syntactic* fact (the `Name::` label line carries no regex token), NOT the runtime claim ("a regex anywhere in the top rule's paragraph → `[]`"); the frozen fixtures put the regex on the *next* line and work. The "all 20 specs have no regex on top" finding is a corpus *convention*, not an engine constraint. (2) **A sound doctrine doesn't need a false mechanism to stand.** The authoring doctrine — write `.spec` as a top entry rule (no regex) + normal rule(s); never regex on top — is correct on its own (it's how all 20 shipped specs are written + the user's recorded preference). So I kept `.10.3` + the doctrine, retracted only the false "`[]`" sub-claim, and reframed the remediation rationale as "these examples violate the 2-rule doctrine," not "they return `[]`." Rewrote the KM card doctrine-first. No Perl, no book-example change. Frontier still → `.10.4`.

- 2026-06-17 (SPEC-LANG-REFERENCE.10.3 — execute the remediation; the empty-matchable regex is its own do-not-guess trap): Redid the `.5.2` Scalar+Numeric worked examples (33 of them) + both preambles in `helper-contract-catalog.md` with the verified 2-rule idiom (top `demo::` entry rule, no regex, `-> value .push` + `LX{return(array_copy(a(demo)))}`; normal `value : /<re>/ I.return(<expr>)` reading `entry_group(N)`). Three reusable points. (1) **Verify the scaffold and every example through the same oracle, from the exact text you put in the book.** The harness built each spec from the identical canonical scaffold the preamble teaches (not a paraphrase), ran it through `LinkedSpec::Get`, and JSON-encoded with `JSON::PP->canonical`, sanity-checked against the frozen `["hello-world"]` idiom — so the documented output and the real output cannot drift. (2) **The valid structure changes the documented output, and that's the point.** The invalid `Demo:: /re/ -> Demo {…}` form returned `[]`; the valid 2-rule form returns the top rule's one-element accumulator snapshot, so every output became `[value]` (`["hello-world"]`, `[5]`, `[3.5]`, `[null]`, `[1]`/`[0]`). Documenting the honest array — and explaining the wrap in the preamble (cross-ref runtime-semantics §5.5) — beats contriving a scalar-return scaffold no shipped spec uses. (3) **An empty-matchable regex is a silent multiplier in the `while(1)` dispatch loop.** `is_defined`'s `/(\w*)(\S*)/` matched twice on `hi` (both groups can be empty → a second zero-width hit → `["present","present"]`); the fix was a non-empty pattern `/(\w+)/`. Lesson: when an example's job is "one match → one value," use a pattern that cannot match empty, or the top loop will push more than once. `entry_group(N)` (entering match), not `match_group(N)` (local, unset in the child `I` block), remains the load-bearing reader choice. `mdbook build` exit 0; rendered HTML verified (full blocks stay single code blocks with the required inter-rule blank line). No Perl change. Frontier → `.10.4`.

- 2026-06-17 (SPEC-LANG-REFERENCE.10 CORRECTION — I diagnosed an "engine bug" that was actually MY malformed grammar; learn the language's structural invariants before judging the engine): The user corrected a fundamental misunderstanding I had carried through `.5.2`, `.9`, and `.10.1`. The lesson is large and worth stating bluntly. **(1) A `.spec` top-level rule (`::`) has NO regex — it is the `_INITIAL` entry/dispatch loop that matches the regexes of the non-top (`:`) rules; a valid spec needs ≥2 rules (top + ≥1 normal rule carrying the regex).** Authoritative: `BootstrapSpec/Core.pm:414` (label line is anchored `\A LABEL (::|:) MODE \z` — no regex allowed on it), `:417` (`::`→`_INITIAL`), `RuleIR.pm:193-195` (`_INITIAL`→`top_rule`), and all 20 shipped specs have `regex_on_top=no`. **(2) My entire `.5.2` scaffold (`Demo:: /re/ -> Demo { return(<expr>) }`) and `.9`'s §5.5 fix put a regex on the top rule — structurally invalid.** They "ran" only because the engine is permissive; they returned `[]` because the top loop matched nothing and nothing was accumulated. **(3) I then mis-diagnosed that `[]` as an `AND_SINGLE_ACODE` engine regression** and even floated "fixing the reference." That was doubly wrong: the premise (a valid grammar) was false, and the reference is the authoritative source of truth that must not be touched (the user: "It is named reference for a reason"). The whole `.10.1` verdict was built on my own malformed test inputs. **(4) The real fix is documentation-only,** with the verified 2-rule idiom (top entry rule + normal rule reading `entry_group(N)` — NOT `match_group(N)`, which is unset in the child's `I` block and was the cause of an interim `[null]`): `demo_top:: -> word_pair .push; LX{return(array_copy(a(demo_top)))}` + `word_pair : /(\w+) (\w+)/ I.return(concat(entry_group(0),"-",entry_group(1)))` → `["hello-world"]`. **Meta-lessons:** before concluding "the engine is buggy," (a) confirm your test input is a *valid* program in the language — verify your inputs, not just the engine; (b) ground the language's structural rules in the shipped corpus + the bootstrap parser, not in intuition transplanted from other grammar tools; (c) when a "verified" delegated-agent finding (the `.10.1` codegen trace) rests on a premise you supplied, the premise is the thing to check first. Deleted the wrong KM card; wrote `spec-top-rule-no-regex-two-rule-minimum.md`; superseded `.10.1`/`.10.2`; remediation is `.10.3`-`.10.5`. No Perl change. (`.5.2`/`.9` committed work is now flagged for redo — a real quality cost of not knowing the structural invariant up front.)

- 2026-06-17 (SPEC-LANG-REFERENCE.10.1 — a doc audit found an engine regression; verify the agent's verdict against source before enshrining it): Investigating *why* the book examples were wrong (the `.9` systemic finding) turned up a real bug in the Perl reference engine, not just bad docs. The single-slot `::AND -> Rule[0] { return(...) }` form returns `[]` because `_emit_and_single_acode_handler` (`HandlerVariantEmitter.pm:575-582`) computes the transformed edge acode and never `push`es it into the dispatch list, so the handler returns its never-written accumulator. Three durable points. (1) **The book is a falsifiability harness for the engine.** Writing/verifying user-facing examples (the SPEC-LANG-REFERENCE tree) exercised a path no test covered — every single-regex-AND assertion in `t/phase0_regression.t` checks metadata/descriptor/compilation, never the parser's runtime *value* — so a returns-`[]` regression sat latent since the MEDIUM-IMPACT.3.4.x rework. Documentation work with a real oracle is a legitimate way to find engine bugs; "the book is the user's window" cuts both ways. (2) **A delegated agent's verdict is a hypothesis until checked against source — even when it's well-argued.** The investigation agent concluded "regression, not intended" with file:line + git provenance; before recording that as a durable KM fact I re-read `HandlerVariantEmitter.pm:564-630` (confirmed the missing `push`), `git log -- HandlerVariantEmitter.pm` (confirmed the `148c746`/`7fec186` MEDIUM-IMPACT.3.4.x provenance), and `specentry-perl-coupling-inventory.md:234` (confirmed the pre-documented "lack E-block support" gap). Same discipline as rejecting the `.1` "E/IT deprecated" agent claim — trust, but verify the load-bearing claims. (3) **"Investigate, then recommend before any change" is the right shape for a fork with engine + parity blast radius.** The user explicitly held the PNT loop and asked for a recommendation first; the verdict (it's a bug) sharpens the fork but does NOT auto-resolve it — fixing the *reference* engine has cross-variant-parity + regression implications (Rust must mirror; existing specs/tests must not silently change output) that make it a product decision, not a mechanical one. So `.10.1` (investigate) closed as done with a KM card (`and-single-acode-edge-return-dropped.md`) capturing root cause + verified working idioms, and `.10.2` (the fix) stays blocked on the user's direction (engine-fix → dedicated engine tree; vs doc-rewrite; vs both). Lesson: when an audit uncovers a root-cause bug under a doc defect, don't silently widen the doc leaf into engine surgery — record the diagnosis durably, recommend, and let the owner authorize the blast radius. No code/book change in this slice.

- 2026-06-17 (SPEC-LANG-REFERENCE.9 — fixing one drifted example exposed a systemic one; scope the fix, own the rest, escalate the fork): `.9` was a one-line fix — swap the §5.5 `runtime-semantics.md` Pair example from `Pair::AND … -> Pair[0] { return(array(…)) }` (returns `[]`) to the verified OR self-ref `Pair:: … -> Pair { return(array(…)) }` (returns the documented `["?pair:","key","val"]`). Three durable points. (1) **Verify the negative AND the positive, and rule out the obvious confound.** Before rewriting I reconfirmed the broken form returns `[]` under default/`consume`/`seek` (so `parse_mode` — which the canonical walkthrough passes as `consume` — is NOT what makes it work) and that the replacement returns the documented value; only then did I edit. (2) **A scoped fix must still sweep for the same class of defect — and the sweep is where the real story was.** A whole-book `grep -E '-> \w+\[0\]'` + `::AND` scan showed the single-slot `::AND -> Rule[0] { return(...) }` "return value as output" pattern is used in *several* chapters that assert concrete outputs — including the canonical `user-model/worked-spec-walkthrough.md` (claims `{kind=>"pair",…}` for `answer = 42`; actually `[]`). So the §5.5 instance was the tip of a systemic book↔reference drift, not a one-off. (3) **Ground-truth the idiom before declaring "the book is wrong" — and when the fix direction is a real fork, escalate instead of guessing.** Shipped specs (`portmap`/`hlink_substitution`/`DT`) DO use `-> Rule[N] { return(...) }` self-edges, but on *multi-slot* rules returning at the *closing* slot (often `array_copy(array(accumulator))`), so the construct is valid and the drift is narrowly "single-slot `::AND` self-edge claiming the `return` value as the top-level output." That leaves a genuine fork I can't resolve alone: is single-slot-AND-self-edge-`return`→`[]` an **engine bug** (fix Perl reference + Rust + oracle so the examples become correct as written) or **intended reference behavior** (rewrite the examples)? The answer changes whether `.10` is engine+parity work or a multi-chapter doc rewrite — and could touch RUST-PARITY — so I owned `.10` (ownership-first), marked it **blocked on a user decision**, recorded the Open Question, and kept the PNT loop moving on the independent, already-verified `.5.3` rather than guessing the fork. Lesson: "no drift" + "do not guess" together mean: fix what you've verified, *measure* the blast radius, and hand a clearly-framed fork back to the owner rather than silently picking a direction that could be wrong at signoff level. `mdbook build` exit 0; frontier → `.5.3` (next unblocked); `.10` blocked.

- 2026-06-17 (SPEC-LANG-REFERENCE.5.2 — build a real oracle for "do not guess", and let it expose which helpers are condition-only): The leaf added a worked, **run-verified** example to every Scalar (§2) and Numeric (§5) helper in `helper-contract-catalog.md` (35 helpers). Four durable, reusable facts. (1) **The reliable single-helper documentation scaffold is a bare-`::` (OR/seek) top rule with a *self-referencing action edge and no slot index*: `Demo:: /<re>/ -> Demo { return(<expr>) }`.** The `return(...)` value then *is* the parser's top-level output, so the example's I/O is unambiguous. This was found empirically: the obvious `Rule::AND … -> Rule[0] { return(...) }` form (and even the §5.5 book example written that way) returns the **empty accumulator `[]`**, NOT the returned value — the AND-`[N]` self-edge accumulates instead of surfacing the return. The OR self-ref form surfaces it (verified for scalar, array, int, bool, undef). (2) **Don't trust a "verified" claim you didn't re-run — build a tiny oracle.** I wrote a scratch driver that builds each spec via `LinkedSpec::Get`, runs the documented input, and JSON-encodes the result with the *same* `JSON::PP->canonical` encoder as `tools/gen_oracle_corpus.pl`, then **sanity-checked it against the two frozen oracle fixtures** (`proof_edge_{scalar,array}_literal/expected.json`) — it reproduced them exactly, so its outputs are reference behavior. That sanity check is what let me trust (and then correct against) the rest. (3) **Not every "Scalar helper" in the catalog is a value expression — some lower only as control-flow conditions.** `is_defined`/`is_undefined` (and `is_empty`/`is_nonempty`/`not`/`and`/`or`/`eq`/`num_gt`/…) lower **only** via `ActionIR/FlowExpr.pm`'s `_lower_flow_composite_expr`; the value-expression helper set is the explicit regex list at `FlowExpr.pm:270` (which *does* include `matches`/`starts_with`/`ends_with`/`contains_substr`/`coalesce`/`concat`/the `num_*`/… but *not* the `is_*` predicates). So `return(is_defined(x))` emits a literal `is_defined(...)` call with no Perl backing and dies "Undefined subroutine"; the predicate must live inside an `if (...)` test. I documented `is_defined`/`is_undefined` condition-only with a usage note, and verified the `if (is_defined(x)) { return("present") } else { return("absent") }` form. Lesson: a helper catalog grouped by *data type* can still split by *lowering path* (value vs condition); document the form that actually compiles. (4) **`split(...)` does not compose into `num_sum(...)` here** (`num_sum(split(s,","))` → `null`; `split` returned at top level gives `1`), so the array-form reducers (`num_sum`/`num_avg`/`num_median`/`num_range`/array `num_min`/`num_max`) are documented with an explicit `array(...)` of capture groups or literals (verified `num_sum(array(1,2,3,4))`→`10`) and `split` is left to the Array family (`.5.3`). These four are KM-card candidates for `.7`. Separately, the oracle **caught a real book defect**: the §5.5 `runtime-semantics.md` Pair example outputs `[]`, not its documented tagged array — owned by new leaf `.9` (not bundled). `mdbook build` exit 0; frontier → `.9` then `.5.3`.

- 2026-06-17 (SPEC-LANG-REFERENCE.5.1 — audit before you sweep; "complete" and "useful" are different gaps): The leaf was a helper-catalog completeness + variant-neutrality + examples sweep. Splitting it started with a read-only audit (delegated) that produced two durable, anti-archaeology facts worth recording so nobody re-derives them. (1) **The catalog has 0 public-API completeness gaps — the scary id-count spread is an artifact, not missing docs.** `Contracts.pm` shows 158 ids by a loose `\bid\b => '` grep, 146 by an anchored `^\s*id =>` grep, and the catalog has 140 `###` headings — which looks like ~18 undocumented helpers. It is not: the 158 decompose as ~130 public helpers (all documented) + 17 *internal IR variants* whose names differ from the user-facing DSL name they implement (e.g. `capture_from_mark` IR → the documented `capture_from(name)` helper) + ~11 deprecated `compatibility_surface => 1` contracts (`my_declare_bare`, `exit_bare`, …) that are intentionally never public. Lesson: a raw id-count diff against doc headings over-reports gaps whenever the implementation namespace and the public namespace differ; reconcile the variants before declaring a gap (same discipline as the earlier "158 vs 146 contracts" non-issue). (2) **The real gap was orthogonal to completeness: 0 worked `.spec` examples across all 10 families / ~140 helpers.** Every helper has a signature + prose contract, but not one runnable example — so "is every helper documented?" was the wrong question; "can a user/backend-author *see it used*?" was the gap. That is a large, repetitive, must-compile-each surface (the audit estimated ~100h for full per-helper coverage), so per the splitting discipline it became per-family example sub-leaves `.5.2`–`.5.5` (≥1 compile-verified example per family), and `.5.1` shipped the audit + the only quick wins it surfaced — 2 Perl-sigil variant-neutrality leaks (`$name`, `$rule_label`) fixed and re-swept to confirm no others. Lesson: when a "sweep" leaf turns out to be 0% one dimension and 100% another, name the split by the dimension that's actually missing, and don't let the cheap dimension (2 fixes) masquerade as having closed the expensive one (140 examples). `mdbook build` exit 0; frontier → `.5.2`.

- 2026-06-17 (SPEC-LANG-REFERENCE.4 — verify at the layer you can, and document at the layer you can defend): The leaf added two worked examples (a grouped action-edge target `-> A | B { ... }`, and an `entry_*`-vs-`match_*` divergence). Two reusable points. (1) **"Valid against the grammar" has a verifiable floor: it compiles.** Even when a clean end-to-end runtime output is hard to surface, `LinkedSpec::Get(\$spec)` returning a parser is a real, cheap check that an example is syntactically and structurally valid — I compiled both examples and kept only compiling ones. (2) **When the top-level I/O won't come out clean, document the contract at the layer you *did* verify — don't fabricate the dump.** I ran ~9 minimal accumulator/dispatch shapes trying to surface a clean `entry_*` ≠ `match_*` output; every one collapsed to `[]`/`undef`/`0` — not because the readers are wrong but because surfacing a child's value to the top output runs straight into the divergence axes the oracle card enumerates (a lone rule's I-block return is `0`; a child `return` routes to retv / leaks; inline-spec retv is flaky). The disciplined move was to document the divergence at the **reader-wiring level** I verified in `.2` (entry_* = IMATCH / the entering match, match_* = LMATCH / the local match), concrete and consistent with the book's existing source-boundary example, but **without** asserting a top-level output I never observed. This is the same "discard what you can't verify" rule as `.3`, applied one layer up: I could verify *what each reader reads* (from the lowering) and *that the example compiles*, so I documented exactly that and explicitly recorded the scope boundary rather than papering over it with a plausible-looking output. Lesson: match the confidence of the prose to the strength of the evidence — compile-checked + source-grounded wiring is a legitimate, signoff-level basis for a teaching example; a guessed I/O dump is not. `mdbook build` exit 0; frontier → `.5`.

- 2026-06-17 (SPEC-LANG-REFERENCE.3 — document a contract from verified outputs, discard the example you can't verify, and don't dress a convention up as a rule): The leaf wrote the output/return-value shape contract into `runtime-semantics.md §5`. Three reusable points. (1) **Run the reference for the examples; corpus fixtures and a live parse beat prose.** The output shape ("a parser returns the top rule's value directly") was pinned from two frozen oracle-corpus fixtures (`proof_edge_{scalar,array}_literal/expected.json` → `"scalar-ok"`, `["?proof:","ok"]`) plus a live `LinkedSpec::Get` run on `/(\w+)=(\w+)/` over `key=val` → `["?pair:","key","val"]` — which incidentally re-confirmed `.2`'s `match_group(0)`=first-capture finding end-to-end at runtime. The oracle card `docs/knowledge/rust-perl-output-oracle.md` supplied the one-level-wrap reconciliation (the reference value is canonical; an accumulator-returning runtime wraps one level; the corpus stores the reference value and compares a wrapping backend against `[reference]`). (2) **When a hand-built example won't verify, delete it — don't ship a plausible guess.** A hand-rolled accumulating `Words::OR+` example returned `[undef,undef,undef]` instead of the tagged array I expected (repeated-rule accumulator + lifecycle-return mechanics are genuinely subtle — the same subtlety the `.7.1` oracle authors dodged by using parent→child literal-return grammars). Rather than reverse-engineer it under time pressure, I documented only verified material and described the accumulator→output relationship from real shipped source (`ds_vhistory.spec` `return(a("?ds_vhistory:", array_copy(a(vhistory))))`). "Do NOT guess" means a worked example you can't reproduce is a liability, not a nice-to-have. (3) **A convention is not a contract — say so explicitly (user feedback).** I initially wrote §5.6 as "The Tagged-Shape Convention" with "most shipped specs build their AST as tagged arrays," which reads as prescriptive. The user corrected this mid-leaf: the `["?<rule>:", …]` tag is an *old, optional* convention; the engine imposes no output schema and authors may use any shape or none. Reframed §5.6 to "The Output Shape Is the Author's Choice" and made the optionality explicit in §5.5/§5.7 too (saved as a durable feedback memory). Lesson for the variant-agnostic book: when documenting "how specs tend to look," separate the *engine contract* (what the runtime requires/produces) from *authoring conventions* (what some specs happen to do) — never let the latter masquerade as the former. `mdbook build` exit 0; frontier → `.4`.

- 2026-06-17 (SPEC-LANG-REFERENCE.2 — document the contract from the source of truth, and a doc-correctness audit pays for itself): The leaf wrote the new `user-model/regex-in-spec.md` chapter (regex as a first-class `.spec` concept) plus a `formal-grammar.md §3.1` capture-group expansion. Four reusable points. (1) **"Do NOT guess" means read the lowering, not the prose.** The capture-index contract was pinned by reading the actual ActionIR lowering — `Contracts.pm` lowers `entry_group(N)`→`$IMATCH_LIST[N]` and `match_group(N)`→`$LMATCH_LIST[N]`, and `LinkedRE::_build_match_info` builds `match_list = [grep {defined} $1..$N]` — so the contract is **0-based, captures-only (group 0 = $1, NOT the whole match), and compacted** (a non-participating group is dropped and shifts the indices after it). Cross-checking the shipped specs (`lib_reader.spec` `grouptype=entry_group(0), groupname=entry_group(1)` over `/\b(\w+)\s*\(\s*((?s:.*?))…/`) confirmed it against real usage, not just the engine. (2) **Documenting a contract surfaces contradictions the prose had hidden.** The book disagreed with itself: `helper-contract-catalog.md` said `entry_group` "index 0 is the full match" while `worked-spec-walkthrough.md` said index 0 is the first capture group. The engine settles it (walkthrough right, catalog wrong); fixing it meant correcting the catalog **and** two examples that silently used the wrong 1-based convention (`overview/what-is-linkedspec.md` `entry_group(1)`/`(2)` over `/(\w+)=(\w+)/`; the `formal-grammar.md` `Child` demo `entry_group(1)` over `/hello[ \t]+(\w+)/`). A whole-book grep for the indexing claim is the cheap way to catch the long tail. So a "write a chapter" leaf legitimately fixed a correctness bug — and the tree records that `.5` (helper-catalog sweep) need not re-litigate the indexing contract. (3) **The compaction behavior is the non-obvious gotcha worth a worked example.** Because undefined numbered groups are removed, `/(\d+)?([a-z]+)/` on `abc` makes `match_group(0)` = `"abc"` (the `[a-z]+`), not the digits — surprising to anyone expecting stable pattern-position indices; the documented remedy is named groups (`%+`/`match_hash` only ever holds participating names, so they don't shift). (4) **A variant-agnostic book documents the contract from the reference, and must not over-claim a backend that's still converging.** `DEVELOPMENT_NOTES` already records an open `RUST-PARITY` divergence — Rust's `entry_group(0)` currently returns the full match, not the first capture — so the chapter states the feature set as *defined by the Perl reference oracle* and says a conforming backend reproduces it (Rust builds alternation/branch-tracking on `rgx`'s `matched_branch_number`), rather than asserting Rust already matches the disputed capture-index semantics. That keeps the book honest while still giving a new backend the exact contract to implement. `mdbook build` exit 0; frontier → `.3` (output/return-shape contract).

- 2026-06-17 (SPEC-LANG-REFERENCE.1 — audit-as-decomposition, and treat agent findings as hypotheses): The user asked for the book to fully + variant-agnostically document the entire `.spec` surface so the next backend does no archaeology. Rather than guess gap-filling leaves, the first leaf is an audit that IS the decomposition (the splitting discipline). Three reusable points. (1) **Two complementary read-only sweeps beat one.** A surface inventory from the code (what CAN be written in a `.spec`: `Core.pm`/`Validation.pm`/`Contracts.pm`/`spec.spec`) and a coverage map of the book (what is documented, how well) are different questions; cross-referencing them turns "document everything" into a concrete, prioritized gap list (here: 8/10 areas already well-covered, so the real work is just the regex-first-class and output-shape contracts plus a few examples — far smaller than "rewrite the book"). (2) **An agent finding is a hypothesis until verified against the source of truth.** The surface agent asserted lifecycle markers `E`/`IT` are "deprecated"; that contradicts the completed `LIFECYCLE-FAMILY-AUDIT` (all 7 markers equivalent), so it was rejected, not propagated into the plan — the same discipline applied earlier to the "158 vs 146 contracts" flag (dismissed after a direct grep). (3) **The biggest anti-archaeology wins are the contracts a backend can't see from the prose.** The two CRITICAL gaps are exactly the things a new backend must currently reverse-engineer: what its regex engine must support (flags/named groups/capture-index ↔ `entry_group(N)`), and the output/return AST shape (the accumulator wrap + tagged shapes, which the RUST-PARITY oracle already pinned in `docs/knowledge/rust-perl-output-oracle.md` but the book never surfaced). Those become `.2`/`.3`; `.4`–`.6` add the missing worked examples, `.7` the KM cards, `.8` finalizes. Recorded the durable inventory in the tree's "Audit Findings" so the audit is not re-run.

- 2026-06-17 (DOC-DRIFT-SYNC.2 — a doc table can be wrong against the code AND against another doc; the source of truth is the implementation): The `:&`/`:|` rule-mode cells in `formal-grammar.md` were transposed — `:&` labeled "single-match choice" and `:|` labeled "ordered sequence", the exact inverse of the truth. Two reusable points. (1) **When two book chapters disagree, the tie-breaker is the implementation, not the more-detailed chapter.** Here the dedicated `user-model/rule-modes-and-parse-modes.md` was already correct (`:&` = ordered sequence, `:|` = single-choice dispatch), the appendix `formal-grammar.md` was wrong, and the arbiter was `BootstrapSpec/Core.pm:347-348` (`'&' => 'AND'`, `'|' => 'OR'`) — the bootstrap mode-alias map that actually resolves a suffix to a mode. A surveying agent flagged only the `:&` cell; reading the alias map showed *both* cells were inverted (a clean swap), so the fix was the swap, not the agent's one-cell patch (which would have duplicated `:&`'s text onto `:|` and left `:|` wrong). (2) **`:|` is single-choice, not repeated-choice — a subtlety worth pinning.** `:|` aliases to the OR *mode word* but its documented semantics are "exactly one successful alternative wins" (`:OR{1}`), distinct from the repeated-choice family (`:OR`/`:OR+`/bare `rule:`). The dedicated chapter says so explicitly ("Do not use `:|` when the rule should keep collecting repeated alternatives"); the appendix now agrees. Lesson for the variant-agnostic book: a rule-mode table is a contract backends implement, so each cell must be checked against the mode-resolution code, not paraphrased from a sibling row. Closes DOC-DRIFT-SYNC (both leaves); RUST-PARITY (frontier `.7.5.3`) is again the sole active tree.

- 2026-06-17 (DOC-DRIFT-SYNC.1 — the two roadmaps must agree, and "sync" has a direction): A bootstrap-session audit (verified directly against source before acting) found the long-form `ROADMAP.md` lagging its execution companion `ROADMAP_V2.md`: Overall `mostly done` vs `done`, and `ROADMAP.md` had no Phase 8 / Phase 9 rows or long-form sections at all while V2 marks both `done` (Phase 8 multi-backend handoff, Phase 9 Rust variant v0.1). Three reusable points. (1) **A two-document roadmap drifts silently because updates land in the execution companion first.** The doctrine (`docs/decisions/0001` §4; `ROADMAP_V2.md:425`) says fix both in the same slice — but in practice slices update V2's live tracker and forget the long-form file, so a periodic audit of "do `ROADMAP.md` and `ROADMAP_V2.md` agree?" is worth running at session bootstrap. (2) **Sync has a canonical direction.** `docs/TASK_TREE.md` "Relationship To Live Docs" names `ROADMAP_V2.md` the canonical high-level status tracker, so the fix flows V2 → `ROADMAP.md`; the long-form file is brought up to the tracker, not the reverse, and V2 stays untouched. (3) **Don't let the long-form roadmap over-claim a follow-on.** Phase 9 (the Rust *implementation* phase) is genuinely `done` (v0.1 operational), but full Perl-reference parity is the *active* `RUST-PARITY` tree — so the new `## Phase 9` section and Status row both state v0.1 + point at `docs/tasks/RUST-PARITY.md` for parity, keeping "phase done" and "variant at full parity" honestly distinct. Also: an audit finding is a *hypothesis* until verified — the same audit's "158 vs 146 contracts" flag was dismissed after a direct check (the book's 158 reproduces via `grep -cE "\bid\b => '"`; the 146 used a narrower pattern) and recorded as a Non-Goal so it isn't re-investigated. DOC-DRIFT-SYNC continues at `.2` (formal-grammar.md `:&`/`:|` rule-mode fix).

- 2026-06-17 (RUST-PARITY.7.5.1 — a correct fix whose own proof re-scoped the leaf; "necessary but not sufficient" is a split signal): The leaf was "fix the header-line-regex → 0-regex parser bug, then re-enable the tclite oracle and confirm green." The fix itself was exactly the one-char-class change the prior split predicted (`parser.rs:86` `(\S*)`→`([^\s/]*)`), and it is provably correct at the parse/compile layer — 4 new unit tests pin that a single-regex header rule now registers its regex and that a `/open/ /close/` bracket pair registers `[open, close]` so the self-recursive `-> name[1]` close edge resolves to index 1 (the recursive bracket matcher tclite/Lispish intend; before the fix `[1]` was out-of-bounds and the entry edge matched the *close*). Four reusable points. (1) **The leaf's own acceptance baked in an assumption the oracle then falsified.** "Re-enable tclite + confirm green" silently assumed the header-regex bug was tclite's *only* blocker. It was not: with the regexes registering, the oracle still showed tclite `[]` → `[]`. The acceptance bundled a *validation* (tclite green) that actually depended on a *second, unrelated fix*. Lesson: when an acceptance criterion is "and this downstream artifact goes green," treat green-ness as a hypothesis the work tests — not a step the fix is guaranteed to reach — and let a red result re-scope the leaf rather than tempt you to over-reach the diff to force it. (2) **The second root cause was independent and separately-reviewable → split, don't bundle.** tclite accumulates with fluent continuations on ACTION edges (`-> command_subst .push`, `-> command_subst[1] .return(...)`), but the Rust parser attaches a `.method` fluent chain only to a BLIND edge (`=>`, `parser.rs:443`); after a `->` edge the `.push`/`.return(...)` becomes a standalone `FluentChain` the compiler discards (`compiler.rs:171`). That is parser+compiler+engine surgery of its own, so it became `.7.5.3` (greens tclite); `.7.5.1` shipped as the self-contained parser fix and the tclite oracle cases were re-deferred (corpus back to 2 green proofs, `cargo test` stays green) — the textbook PNT "discovered independent dependency, commit the honest outcome" path. (3) **The user-visible symptom under-specified the fix's blast radius — and over-specified its scope.** "single-regex rules compile as 0-regex" pointed at single-colon rules, but the actual trigger was "a regex on the header line" (bites `:` and `::` alike) AND the *bracket-pair* case (which registered 1, not 0); meanwhile "tclite green" implied a bigger fix than the header regex actually is. Reading both the parser and the compiler's `build_dependency_regex_map` before touching anything is what separated the real one-line fix from the separate fluent-lowering work. (4) **Distinguish a pre-existing condition from a regression honestly.** `cargo clippy --tests` exits 101 here on `clippy::approx_constant` (`3.14` in `expr.rs:687`/`types_test.rs:143`) — verified pre-existing (those files untouched; the literal is in HEAD; the project's clippy gate has always measured the *warning multiset* core 10 / runtime 13 / validation.rs 4, not the exit code). Recorded as an Open Question + a flagged hygiene leaf, not silently "fixed" inside a parity slice. `RUST-PARITY` continues at `.7.5.3` (action-edge fluent lowering, greens tclite), then `.7.5.2` (scalaref, greens Lispish), `.7.2`/`.7.3` (corpus batches), `.7.4` (drift guard), `.8`/`.9`.

- 2026-06-17 (RUST-PARITY.7.5 split — pinpoint before you split, and don't bundle a foundational change): The `.7.1` oracle proved the Rust engine doesn't reproduce tclite/Lispish; `.7.5` owns the fix. Before splitting, a read-only investigation + a direct read of `rust/linkedspec-core/src/parser.rs:86` turned the *symptom* ("single-regex `name : /re/` rules compile as 0-regex") into the *exact* root cause: the rule-header regex `^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)` uses `(\S*)` for the mode-suffix group, and `\S*` greedily swallows a `/…/` regex that sits on the header line — `parse_mode_suffix("/;/")` returns `RuleMode::Default` and the regex is silently dropped (it never reaches `rest`/the body). Two reusable points. (1) **The precise trigger was not what the symptom said.** It is not "single colon" — it is "a regex on the header line", which bites `:` and `::` alike; the passing integration tests and the `::` *top* rules only escape it because they write the regex on a separate **body line** (`Child::`⏎`/…/`). Naming the bug "single-colon" (the surface correlation in tclite/Lispish) would have mis-scoped the fix and its tests. Locating the actual regex made the fix a one-character-class change (`(\S*)`→`([^\s/]*)`) *and* surfaced the real risk. (2) **A small diff with a foundational blast radius is its own leaf, carefully verified — not a freebie to bundle.** This regex parses *every* rule header, and today an open/close pair (`/open/ /close/`, e.g. `command_subst`/`parenthesis`/`curlyb`) registers "1 regex" precisely *because* group 3 eats the first of the pair; the fix moves both delimiters into `rest`, so the rest/body regex-parser must reproduce the bracket-pair semantics rather than emit two independent regexes — a real regression surface that demands the full suite + the oracle (re-enabled tclite) as the gate. So `.7.5.1` is the parser fix alone, and the second, independent gap — `expr.rs:299` has no `{` case, so Lispish's `scalaref(retv, {content})` raises `unexpected character '{'` and needs a new `Expr` variant + engine field-access semantics — is `.7.5.2` (larger; depends on `.7.5.1`). The two repro in isolation, confirming independence. Tree-structuring only; a fresh session is recommended for the foundational parser change.

- 2026-06-17 (RUST-PARITY.7.1 — building the oracle, and letting it overturn a recorded assumption): The leaf was "build the Perl↔Rust output oracle + first proof on tclite/Lispish." The valuable part was *not* the mechanism (a Perl generator + a Rust runner, both small) but what the mechanism immediately revealed. Four reusable lessons. (1) **An oracle's job is to find divergence — trust it over prior prose.** The `.7`-split note (written from a read-only investigation, not an actual run) asserted that on tclite/Lispish the Perl↔Rust gap is *only* the one-level accumulator wrap. The first real run falsified that for *both*: tclite `[]` → Rust `[]` (vs Perl's command_subst AST) and Lispish → `exit_now(1)`. The shared root cause is a real compiler gap — a single-regex rule written `name : /re/` (single colon; incl. the inline `name : /re/  I.return(...)` form) compiles in Rust as **0-regex**, so every `-> child[0]` dispatch edge "never fires" (`::` single-regex rules are fine; the integration tests prove that). Lesson: when an "investigation" concludes two systems agree "modulo X", the cheapest way to verify is to *build the comparator and run it* — a read-only mapping can mis-model runtime behavior. (2) **Scope discipline under PNT: the mechanism leaf must not absorb the engine fix it uncovers.** Fixing the 0-regex gap (and the `scalaref({content})` parser gap Lispish also needs) is engine/parser surgery, independently reviewable, and a *blocker* for adding shipped specs to the corpus — i.e. the PNT "discovered lower-level dependency" case. So it became a new leaf `.7.5` (now first in the frontier, ahead of the `.7.2`/`.7.3` corpus-expansion it blocks), and `.7.1` shipped the mechanism + a green proof, not a half-done engine fix bundled in. (3) **A "first proof" must be green on something — engineer the proof to dodge known divergences.** With shipped specs blocked, the proof needs a grammar both backends agree on. Finding it surfaced the full divergence map: Perl *inline-spec* `retv` returns undef (the `.5.2` friction) while Rust's works, so retv grammars disagree (Rust is the *more* correct side); Rust's `return(expr)` in a child leaks into the parent accumulator (a stray `0`) while Perl routes it to retv; `entry_group(0)` differs (Perl=first capture, Rust=full match); and a lone rule with top-level blocks returns 0 in Perl (needs a parent→child dispatch). The green proof grammars are deliberately constructed to avoid *all* of these: `Parent:: /x/ -> Done { return(<literal>) }` + an action-less `Done:: /[a-z]+/` — parent→child dispatch (so Perl's lifecycle "takes"), a literal edge return (no retv, no group indexing), and a child that can't push. Both backends then agree exactly (scalar `"scalar-ok"` → `["scalar-ok"]`; nested array `["?proof:","ok"]` → `[["?proof:","ok"]]`). Lesson: the act of building a minimal agreement case is itself a systematic way to enumerate a system's divergence axes. (4) **Architecture: a cross-variant oracle is a fixture generator, and adopt the corpus format the docs already specify.** The Rust suite stays Perl-free at `cargo test` time by comparing against checked-in `expected.json`, and the per-entry `input.spec`/`input.txt`/`expected.json` layout is exactly what `appendix/backend-handoff.md` already documents — so the corpus is self-contained/language-neutral (any future backend validates against it) *and* adopting it adds zero doc drift. Canonical JSON (`JSON::PP->canonical(1)`) makes regeneration byte-stable; the generator `alarm`-guards every parse so the known RTLUtils hang can't wedge generation. Knowledge card `docs/knowledge/rust-perl-output-oracle.md`. `RUST-PARITY` continues at `.7.5` (the engine fix), then `.7.2`/`.7.3` (corpus batches, now unblocked), `.7.4` (drift guard), `.8` (code-gen), `.9` (docs).

- 2026-06-16 (RUST-PARITY.7 split — designing a Perl↔Rust output oracle as a *fixture generator*, not a live comparison): The broad `.7` leaf wanted "all 20 shipped specs exercised in Rust + corpus + regression guard". Before writing any code, a two-agent read-only mapping of both sides surfaced three design-shaping facts that together justify a split and fix the architecture. (1) **There is no canonical cross-variant output form yet, and the two engines return different *shapes*.** The Perl reference (`LinkedSpec::Get(\$spec)->(\$input)`) returns the top rule's value **directly** (e.g. `tclite` `[]` → `["?tcl_script:",[["?command_subst:",[]]]]`); the Rust `engine.execute(input)` returns the **accumulator wrapped one level** (`[<value>]`, confirmed by the inline lifecycle corpus test that reads `outer[0]`). So the oracle's first real task is to *reconcile and document* that wrapping rule (Perl `X` ↔ Rust `[X]`) over canonical JSON — not assume the outputs are directly comparable. (2) **A live cross-process oracle is the wrong architecture.** Shelling out to Perl on every `cargo test` would make the Rust suite depend on a Perl toolchain, be slow, and re-trigger the `RTLUtils` hang per run. The right design is a **fixture generator**: a timeout-guarded Perl tool runs each (spec, input) once, serializes the AST to canonical JSON (`JSON::PP->canonical(1)`), and writes a checked-in fixture under `rust/linkedspec-runtime/tests/corpus/`; the Rust fixture-runner test then compares `engine.execute` against the *checked-in* fixture — Perl-free at test time, and exactly the language-neutral corpus ADR 0006 §Phase 8.6 calls for. (3) **The corpus has to be *built*, not just wired** — only ~3 of 20 specs (`tclite`/`Lispish`/`pplugin`) have input fixtures even on the Perl side, so ~16 need authored inputs, and the legacy/RTL specs need the hang guard. That is plainly multi-slice work, so `.7` is split: `.7.1` establishes the mechanism + canonical form + first proof (tclite/Lispish), `.7.2`/`.7.3` build the corpus in batches (fixing or recording each parity gap as it surfaces), `.7.4` adds the drift guard (the runner must fail on a missing/extra fixture) and finalizes. **Reusable principle:** a cross-variant "oracle" should crystallize the reference's output into versioned fixtures and have each variant assert against them, rather than run the reference inline — it decouples the variants' CI from the reference toolchain and makes the contract a reviewable artifact.

- 2026-06-16 (RUST-PARITY.6 — strict_syntax validation mode; verify a reference's semantics empirically before mirroring them, and reconcile a default that's already stricter than the reference): Adding the Rust strict_syntax mode was small in code (one `validate_with_options(spec, strict_syntax)` wrapper + a `check_unused_rules` pass) but had two reusable judgment calls. (1) **Don't infer a reference's behavior from reading its source — confirm it, especially when the reading is surprising.** The Perl `validate_dsl_syntax` builds `@defined_rules` from *every* rule label and `@used_rules` from edge targets only, with no top-rule special-casing — which implies strict mode flags an unreferenced top rule as "unused", i.e. would reject nearly every normal grammar. That's surprising enough to be a suspected misreading, so I probed the reference directly (`validate_dsl_syntax(\$spec, {strict_syntax=>1})` on `Top:: -> Child`): it genuinely fails with "Unused rule(s): Top". So the parity-correct behavior really is "top rule not exempt", and the Rust `check_unused_rules` reproduces it (and a test pins it). The probe was timeout-guarded and hits only `Validation.pm`, so it's safe despite the unrelated RTLUtils phase0 hang. (2) **When the backend's default is already stricter than the reference, don't silently relax it to "match" — preserve it and document the divergence.** The reference treats an undefined edge target as a *warning* by default (fatal only under strict); this Rust backend has always treated it as a hard error in every mode (`check_edge_targets`). Relaxing the default to mirror Perl would (a) need a warnings channel the validator doesn't have, (b) break the landed `validate_rejects_undefined_target` test, and (c) weaken a deliberate Rust contract — all out of a "add strict mode" leaf's scope. Instead I kept the default fatal and observed that, because `check_edge_targets` runs *before* the strict pass, the reference's "undefined-before-unused" ordering is preserved and strict mode's only *new* observable behavior in Rust is the unused-rule rejection. The divergence (default stricter than the reference) is recorded in the task tree + knowledge card, not erased. **API shape:** `validate(spec)` stays as the public non-strict entry (now `= validate_with_options(spec, false)`) so the ~70 call sites are untouched; one bool models the single Perl `$option->{strict_syntax}` knob (a struct is YAGNI until a second option exists). Output parity for *valid* specs is unaffected (valid specs have no undefined/unused issues), so the cross-variant-output-parity doctrine is intact. Knowledge card `docs/knowledge/rust-strict-syntax-validation.md`. This closes audit Gap 4; `RUST-PARITY` continues at `.7` (runtime corpus oracle), `.8` (code-gen emitter), `.9` (docs).

- 2026-06-16 (RUST-PARITY.5.5.4 — anonymous capture-slice family; closing a deliberately-handed-off book↔variant gap, and testing capture against the lifecycle order): The anonymous capture-slice family is the direct counterpart of the `.5.5.3` named-mark family — same endpoint taxonomy (match-start / cursor / end-of-input), same guarded `span_text`/`span_char_len`, same `_take_*`-mutates discipline — except it reads the single anonymous capture cursor `ctx.capture_start` (Perl `$IPOS`) instead of a named mark. Three reusable points. (1) **A gap one leaf records as "handed off to the next leaf" must actually be closed, not re-recorded.** `.5.5.3` fixed the *mark* `capture_from` to match-start and corrected the catalog, explicitly leaving the *anonymous* `capture_slice`/`capture_slice_len` (which shared the same match-end bug) for `.5.5.4` — with the book already stating the correct (match-start) contract, i.e. an intentional, tracked book-vs-one-variant gap. This leaf closes it: the engine now reads to `ctx.match_start_byte`, and the two landed `helpers_5_2_capture_slice_*` tests were updated to the parity-correct empty values (capture started at the match start → nothing precedes the match), exactly mirroring the `.5.5.3` `capture_from` test update. (2) **To test the anonymous match-start readers you must know the lifecycle/seek order.** The only setter, `start_capture_slice()`, records `ctx.pos` — and the `I`-block runs *before* the rule's seek (`execute_rule`: preamble at the top, match loop after), so for the top rule it records pos 0. With a Seek `Top::` rule over leading filler (`"  ab cd"`, match "ab" at byte 2), `capture_start`(0) < `match_start`(2), so `capture_slice` returns the non-empty pre-match `"  "` — a deterministic, parity-correct fixture that needs no multi-rule grammar. Without that ordering fact, a single-rule test sets `capture_start` to the match-end and every match-start reader looks (misleadingly) empty. (3) **A `_take_` reader's read-endpoint and its advance-target can differ — document the asymmetry.** `capture_take`/`capture_take_len` read up to the *match-start* but advance `capture_start` to the *cursor* (Perl `$IPOS = pos $$STRING`), while the `_until_cursor`/`_rest` takes advance to their own endpoint; the catalog §7 destructive note had to be refined to say "advance to the cursor (or end-of-input for `_rest`)" rather than "to the read's endpoint". **Scope discipline (a variant of the `.5.5.3` call):** the `RUST-PARITY.1` inventory's anonymous list itself omitted `capture_rest`/`capture_rest_len`/`capture_take` (no-mark) — the same family. Rather than ship a half-finished family mirroring the inventory's own gap, all 10 missing anonymous helpers landed together (one coherent, fully-tested, single-file family); the separately-discovered mark/match/entry-*anchored* helpers (`mark_match_*`, `mark_entry_*`, `capture_take(mark)`, `capture_take_between`) are a *different* family and stay deferred. Knowledge card `docs/knowledge/rust-anonymous-capture-slice-family.md`. With this leaf `.5.5` and `.5` are closed — every real Rust↔Perl parity-gap finding from the 3-agent audit is now done; `RUST-PARITY` continues at `.6` (strict_syntax), `.7` (runtime corpus), `.8` (code-gen emitter), `.9` (docs).

- 2026-06-16 (RUST-PARITY.5.5.3 — the book catalog is documentation, not the contract; read `Contracts.pm` when they disagree): The mark-based capture family's design hinged on one parity decision the prior session deliberately parked for "fresh focus": does `capture_from(mark)` end at the match **start** or the match **end**? The book Helper Contract Catalog §7 said "to the current position" (match-end) and the landed Rust `capture_from` agreed — but **both were wrong**. The authoritative source is the Perl reference's lowering in `perl/LinkedSpec/ActionIR/Contracts.pm` (~690–1047): the non-cursor readers lower to `substr($$STRING, $mark, $LSPOS - $mark - length $LMATCH)`, i.e. they end at `$LSPOS - length $LMATCH` = the **start** of the current local match (= `ctx.match_start_byte` in Rust, since `ctx.pos == match_end` and `match_width = match_end - match_start`). **Lesson:** the book is a variant-agnostic *description* of the contract and can drift or be imprecise; when implementing parity, the contract of record is the Perl lowering, and a catalog/code agreement does **not** make a behavior correct. Reading `Contracts.pm` directly (not the catalog) surfaced three more catalog imprecisions fixed in the same slice: the 1-arg `mark_copy` (it is 2-arg `mark_copy(target, source)` with copy-or-delete), the `_take_` readers' silent mark mutation, and the anonymous `capture_slice` endpoint (also match-start, not "current position"). **Scope discipline:** the Rust `capture_slice` arm shares the same match-end bug but is anonymous-family (`.5.5.4`) — the catalog now states the correct contract while the Rust anon fix is tracked for `.5.5.4`, an intentional, recorded book-vs-one-variant gap (the book documents the contract; the Perl reference satisfies it; Rust catches up by leaf). **Endpoint taxonomy worth remembering** for the whole capture family: non-cursor `*_from` → match-start; `*_until_cursor*` → cursor (`pos`); `*_rest*` → end-of-input; `_take_*` additionally advance the mark to the read's endpoint (the cursor, or end-of-input for `_rest_`); text readers return the slice, `_len_*` readers return the **char** count. Marks are byte offsets, so `mark_input_end` stores `input.len()` (bytes) and `mark_pos`/`_len_` convert byte→char at the DSL boundary.

- 2026-06-16 (ALIAS-RETIREMENT-DOC-SYNC.1 — zero-drift correction of retired-alias doc claims): A reusable lesson about the zero-drift doctrine and what counts as "the book/doc". When `RUST-PARITY.5.5.2` resolved that the array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` are retired (not recognized by the Perl reference), I initially deferred fixing the contradicting roadmap text as an out-of-scope "Perl-side doc change". That framing was wrong: the `.spec` language is the **one universal contract** and the docs are **variant-agnostic**, so "these aliases are retired" is contract truth that every doc must reflect — it is not a Perl-implementation detail. The "don't bundle unrelated changes" commit guardrail does not license leaving a *known* drift unfixed; it just means the fix gets its own task-tree-owned slice (which this is). **Two concrete process points:** (1) When a leaf *resolves* a documented contradiction (here the Open Question "book says retired vs ROADMAP_V2 says supported"), the resolution is incomplete until the losing doc is actually corrected — recording the decision in a task tree is necessary but not sufficient for zero-drift. (2) An audit grep for a retired-helper name catches *multiple alias categories* at once (array-edge vs capture vs named-map vs return aliases); only the category whose retirement is **independently verified** (no recognition regex + 0 shipped-spec uses + 0 `t/` locks + "Retired" in the canonical book catalog) should be edited in that slice — blanket-editing every grep hit would propagate unverified claims. The book was *almost* self-consistent already (its Helper Contract Catalog said "Retired") — the drift was one stray `formal-grammar.md` helper-listing line plus the internal roadmaps; fixing those made the book internally consistent without touching the catalog.
- 2026-06-16 (RUST-PARITY.5.5.2 — input-boundary helpers + flat splice in the Rust engine): The notable part of this leaf was not the code (3 small `call_helper` arms) but resolving a **parity-policy** question the leaf was explicitly told to settle: are the array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` still real, given the book catalog says "retired" but `ROADMAP_V2` says "remain compatibility syntax"? The deciding test for a parity-locked backend is **what the reference's recognized helper surface actually is** — not what either doc *says*. Empirically: the four aliases are absent from every current Perl helper-recognition regex (`BootstrapSpec/Core.pm:82`, `FlowExpr.pm:81,270`, `MethodLowering.pm:1627,1635` — which list canonical `drop_front`/`drop_back`/`flat`/`flat_array`/`array_copy` only), unused in all 20 shipped specs, and have 0 locks in `t/phase0_regression.t`. They were retired in `COMPAT-ALIAS-RETIREMENT.1`. **Reusable principle: parity = match the reference's recognized surface, so "may implement for compatibility" (the catalog's permissive note) is the *wrong* default for a parity-locked backend — implementing a retired alias makes the backend accept inputs the reference rejects, i.e. a divergence, not convergence.** Hence Rust adds only canonical `flat` (genuinely missing; the splice helper `flatten` retired *to*), not the three retired aliases, and an `engine.rs` comment records the reasoning so a future reader doesn't "fix" the omission. Implementation notes for the two readers: `input_end_line`/`input_end_col` reuse the exact char-based pattern from `cursor_col` (`.5.3`) but at end-of-input — `input_end_line` = `1 + whole-input newline count` (newline counts are byte/char identical), `input_end_col` = char distance past the last newline `+1`-when-none (parity with Perl `_build_column_read_expr(pos_expr => length($$STRING))`); the multibyte test (`"héllo"` → 6, not the 7 a byte count would give) locks the char-semantics. `flat` mirrors the established Rust convention that the *consuming* helper (`hash(...)`/`array(...)`), not the producer, realizes the splice — `flat` just returns Array→Array / Hash→Hash so `hash(..., flat(hash(...)))` merges. **Drift caught (flagged, not fixed here to avoid bundling a Perl-side change into a Rust slice):** `ROADMAP_V2.md` lines 256–262 still call `tail`/`drop_last` "compatibility alias … remain supported" — stale text predating the retirement; recommend a small Perl-side doc-sync slice (or fold into `.9`). Captured durably in new knowledge card `docs/knowledge/rust-retired-array-aliases-not-added.md`.
- 2026-06-16 (RUST-PARITY.5.5.1 — named-group reader helpers in the Rust engine): The cheapest kind of parity leaf — the infrastructure the new helpers needed was already built by earlier `.5.x` work, so this was a pure addition of 8 `call_helper` match arms with no struct or population changes. `ctx.entry_named`/`ctx.match_named` (`HashMap<String,String>`) already populate from the regex `MatchResult.named` (engine.rs:280 local, :291 entry-when-empty) and already save/restore per invocation in `SavedMatchState` (the `.5.2` discipline), so `entry_named`/`entry_has`/`entry_map`/`entry_named_map` + the four `match_*` simply read those maps. Three reusable points. (1) **Materializing a host `HashMap` into a DSL value must impose a deterministic order.** `entry_map`/`match_map` return `RuntimeValue::Hash` (an ordered `Vec<(String,RuntimeValue)>`); iterating the source `HashMap` directly would make the projection's order — and any order-sensitive consumer or test — nondeterministic across runs, so a shared `named_map_to_hash` helper sorts by key, matching the existing `sorted_keys`/`sorted_values` determinism guarantee. (2) **Retired aliases are implemented as combined arms, not separate code.** The catalog marks `entry_named_map`/`match_named_map` as retired aliases of `entry_map`/`match_map`; `"entry_map" | "entry_named_map" => …` makes them literally identical behavior at zero duplication. Backends MAY accept retired aliases for legacy specs (catalog "Compatibility Aliases" note) — this does not pre-empt the separate `.5.5.2` alias-retirement policy question, which is about `tail`/`drop_last`/`flatten` and whether the *Perl reference* still recognizes them. (3) **End-to-end is testable here without a Perl oracle** because the named-group path is self-contained: a top-rule grammar with a `(?P<name>…)` regex (rgx-core's named-capture syntax) populates both `entry_named` and `match_named` from the same match (entry == local on the dispatcher-less top rule, per `.5.2` seeding), so all 8 readers — and the present/absent and alias edges — are pinned by `cargo test` (`helpers_5_5_1_*`), the leaf's parity gate.
- 2026-06-16 (RUST-PARITY.5.4 — dedup shadowed arms + REP zero-progress guard): Two reusable lessons. (1) **Duplicate match arms hide bugs as "the worse arm wins."** `call_helper`'s big name `match` had `print`, `hash`/`h`, and `hash_copy` defined twice; Rust evaluates arms top-to-bottom, so the earlier (simpler/worse) arm shadowed the later (more complete) one — `rustc`'s `unreachable_patterns` lint flagged all three. The fix is to delete the worse arm so the better one becomes live (Hash-arg merge for `hash`, `resolve_array_target` raw-AST resolution for `hash_copy`, consolidated `say|print|print_each`). Lesson: treat `unreachable_patterns` as a correctness signal, not lint noise, and when deduping pick the arm whose behavior is the *superset*. A subtlety the dedup surfaced: there's no clean idiom to copy a *declared* hash because `hash(name)` is a constructor (eagerly builds an empty hash) not a reference, and `resolve_array_target` only recognizes `array(...)`/`a(...)` — so `hash_copy(hash(config))` returns `{}`; the hash-as-reference gap belongs to a later leaf, so the `.5.4` test pins the better arm via its *distinguishing* Hash-merge behavior rather than a round-trip that can't work yet. (2) **A "zero-progress guard" must measure progress, not iterations.** The REP loop guarded with `matches > rep_min && matches > 100` — a magic iteration cap that never looked at the cursor, so a zero-width match (`/x*/` on non-'x' input) spun ~100 times. The correct guard mirrors Perl's REP handler (`loop_end_pos == loop_start_pos`): snapshot `pos_before` at the top of the iteration and break when `ctx.pos == pos_before`; the existing post-loop min-bound check then converts a sub-`rep_min` no-progress stop into the right failure. Lesson: termination guards for "consume input" loops belong on the cursor delta, and an iteration cap (kept here only as `max_iter` backstop) is not a substitute.
- 2026-06-16 (RUST-PARITY.5.3 — char-based offsets/slicing in the Rust engine): The Rust regex engine (`rgx-core`) works in **byte** offsets, so `ctx.pos`, `capture_start`, `marks`, and `MatchResult.start`/`.end` are all byte offsets — but the Perl reference exposes **char** offsets (`pos()`/`length`/`substr` are char-based on character strings). The mismatch caused two bug classes: (1) `substr`/`input_slice` byte-sliced DSL char-offset args (`s[start..end]`), which **panics** when the byte index lands mid-multibyte-char and silently diverges otherwise; (2) every exposed length/column/position was a byte count, and `entry_start_pos`/`match_start_pos` were stubbed `0.0`. The chosen invariant (clean and minimal): **keep internal positions byte-based for the regex engine, and convert only at the DSL boundary.** Two directions: byte→char for everything surfaced to the DSL (`byte_to_char_offset(input, byte) = input[..byte].chars().count()`), and char-based slicing for helpers that take DSL char-offset args (`char_substr(s, start, len) = s.chars().skip(start).take(len).collect()`, which never panics). Line numbers are newline counts — identical in bytes or chars — so only columns (distance from the last newline) needed char counting. For the hardcoded `*_start_pos`, the engine now records the regex `m.start`/`m.end` into new `RuntimeContext` span fields (`entry/match_*_byte`) that piggyback on the `.5.2` `SavedMatchState` save/restore (the entry span follows the same dispatcher-vs-own-first-match seeding as the groups). **Reusable lessons:** (1) in a UTF-8 interpreter that wraps a byte-based regex engine, draw one explicit byte/char boundary — internal = byte, DSL-facing = char — and funnel every crossing through two named converters, rather than sprinkling `.chars().count()` ad hoc. (2) `&str[a..b]` slicing on attacker-or-DSL-controlled indices is a panic waiting to happen; prefer `chars().skip().take()` for any char-semantic substring. (3) byte==char for ASCII means the whole change is a no-op on the existing ASCII corpus — the only way to lock the fix is multibyte test inputs ('é' = 2 bytes), which is what the `chars_5_3_*` tests use. **Out of scope (flagged for a later parity leaf):** group indexing (`.5.2`) and the `entry_line`/`entry_col`/`match_line`/`match_col` helpers that take a position *argument* instead of using the stored span.
- 2026-06-16 (RUST-PARITY.5.2 — entry_*/match_* separation in the Rust engine): The Rust runtime shares **one** `RuntimeContext` for the whole parse, and the single match-set site set the rule's own regex match into BOTH the entry registers (`entry_groups`/`entry_named`) and the local registers (`match_groups`/`match_named`), so `entry_*` and `match_*` were always identical and a dispatched child clobbered the parent's match. The Perl reference instead keeps two **per-handler `my` lexicals**: `IMATCH` (entry) is set once in the handler preamble from the match the *dispatcher passed in* — `IMATCH = $$info{match}` (`SpecEntry::_build_handler_preamble`) — and a parent invokes a child handler with its **own** `$minfo` as that `$info` (`ActionIR/MethodLowering.pm:332`); `LMATCH` (local) is the rule's **own** regex match (`HandlerVariantEmitter::_build_lmatch_extraction`). Fix: `execute_rule` emulates that lexical scoping with a `SavedMatchState` save/restore — on entry it saves the caller's registers, sets THIS invocation's entry = the caller's local match, starts local empty; each own match updates only the local registers and seeds entry from the first own match **only when entry is still empty** (the dispatcher-less top rule, where the framework passes the top's own match as `$info`); both the blind-call early return and the normal return restore the caller's registers (the same save/restore discipline as the `.5.1` `return_value` channel). **Methodology note (reusable):** the runtime Perl oracle was inconclusive — minimal hand-authored inline `.spec` grammars hit top-rule/lifecycle authoring friction and returned empty/0 — so the contract was taken straight from the authoritative Perl **source** (the three sites above) and pinned by Rust tests; the leaf's parity gate is `cargo test` + `cargo clippy`, not a runtime oracle. **Out of scope:** group *indexing* parity (`entry_group(0)` = full match in Rust vs Perl `match_group(0)` = first capture) is a separate item — `.5.2` is about *which* match a helper reads, not the index. **Lesson:** in a shared-context interpreter, every "this is a per-frame value" (return value, entry match, local match) must be scoped with take/save-on-entry + restore-on-exit, or a child's frame leaks into the parent's.
- 2026-06-16 (RUST-PARITY.5.1 — retv propagation in the Rust engine): The Rust runtime interprets against a **single shared `RuntimeContext`** (one scalars/arrays/accumulator map for the whole parse — there is no per-rule scope yet), and `execute_rule` had no return-value channel (`Result<(), String>`). A rule's "return" was modeled only as pushes onto the one shared `ctx.accumulator`, which `execute()` returns as the top-level JSON. So a child's `return(expr)` went to that global accumulator and the parent's `scalar(retv)` resolved to undef — the `set_retv` helper existed but was never called. The fix threads a **per-invocation return channel** without disturbing the accumulator contract: `RuntimeContext.return_value: Option<RuntimeValue>` is `take`n on `execute_rule` entry (saving the caller's pending return) and read+restored on exit, so each invocation reports exactly its own last `return(...)` and child dispatch is transparent across stack frames; `return(expr)` writes the channel **in addition to** pushing the accumulator (the baseline depends on the accumulator, so it must stay); after `->`(acode) and `=>`(bcode) dispatch the engine sets `ctx.set_retv(child_retv)` so the parent's attached code / `LE` / `E` see the child result. This matches the variant-agnostic contract already in the book — `appendix/runtime-semantics.md` §3.3 ("LE … receives the child's return value via the `retv` variable") and §5.4 ("the rule's return value is whatever the E-block returns / the last lifecycle block to execute"). **Design choice — why `execute()` still returns the accumulator, not the new channel:** the existing 182 tests encode the accumulator shape (e.g. `E { return(array_copy(array(results))) }` makes `execute()` yield `[[...]]`, and tests read `arr[0]`), so the channel is purely additive — it feeds `retv`, not the top-level result. **Latent bug caught:** `call(child)` read the rule name from the *evaluated* arg, but a bare `call(RuleName)` evaluates to undef (a rule label is not a scalar variable), so a bare `call` never resolved a rule and always returned undef — the reason the Perl reference pattern `assign(s(retv), call(child))` (`specs/tablegrep.spec`) could not work in Rust. Fixed with `resolve_rule_name` (same raw-AST-vs-evaluated pattern as `resolve_array_target`/`resolve_scalar_target`). **Reusable lesson:** when threading a return value through a shared-context interpreter, scope it with take-on-entry / restore-on-exit rather than a bare field — a single global field would leak a child's return into the parent's frame for rules with no E-block or with `return(...)` in `LE` across REP iterations. The deeper "one shared context / no per-rule scope" simplification remains (out of scope for `.5.1`); `retv` is consequently a shared scalar that the post-dispatch `set_retv` always overwrites to the correct value, which is acceptable parity for now.
- 2026-06-16 (MDBOOK-FORMAT-CORRECTNESS — tree complete): Fixed a class of malformed `.spec` examples in the book where lifecycle blocks (`I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`) were drawn nested INSIDE an action-edge `-> X { … }` block. The format rule (from `BootstrapSpec/Core.pm`): lifecycle markers are `NON_ACTION_CODE_BLOCK` tokens — top-level rule-paragraph members, siblings of the `->`/`=>` edge tokens; an edge's `{ }` holds only that edge's action code, and the recursive brace scanner would consume a nested marker as edge-code text rather than recognize it as a hook. Found in 3 examples total: `appendix/runtime-semantics.md` §5.2/§5.3 (user-reported) and `appendix/formal-grammar.md` §8.1/§12 (found by the full-book Explore sweep across all 41 pages, which checked four violation classes and found only this one). All fixed grounded in the shipped specs — the correct sibling layout is `Rule:: I{…} -> Child{…} LE{…} LX{…}` (lifecycle blocks as peers of the edge), per `specs/tablegrep.spec` `grep::` and `dsl/value-container-flow-helper-reference.md`. **Two reusable lessons:** (1) variant-agnostic *framing* (the `MDBOOK-VARIANT-AGNOSTIC` tree) and `.spec` *format validity* are DIFFERENT audits — the variant-agnostic sweep read these same pages and did not catch the structural error because it wasn't checking snippet syntax; format-validity is now its own audit. (2) When a doc embeds a `.spec` snippet, verify it against the actual shipped specs / bootstrap grammar, not the surrounding prose — this bug had been copied between appendix pages.
- 2026-06-16 (SPEC-SPEC-SELFHOST.4 — docs sync + tree close): Documented the spec.spec rewrite (`.2`/`.3`, commit `4c667b7`) and closed the tree. Status update superseding the MEDIUM-IMPACT.3.x dual-path notes below: the rewritten `specs/spec.spec` is a faithful, complete self-hosting description of the format `BootstrapSpec/Core.pm` recognizes (13 rules — `spec_file` + 12 per-token part rules, group-at-`rule_header`), replacing the prior unusable 3-rule stub. It compiles at `language_agnostic_ready_ratio == 1.0000` (zero blocked, zero compatibility-surface) and the cross-check harness (`tools/cross_check_spec_parsers.pl`) now reports full paragraph-count parity with the bootstrap oracle across all 20 shipped specs (was 2/20 at MEDIUM-IMPACT.3.5); spec.spec divides itself into 13 paragraphs == its 13 rules (self-hosting). **Non-Goals preserved:** the hardcoded bootstrap stays the oracle/primary parse path; spec.spec remains the diagnostic/candidate side channel (the dual-path design). The PHASE7-SELF-HOSTED-SPEC.5 extension-surface policy is preserved verbatim in the new spec.spec header (the EXTENSION-SURFACE POLICY block: new `.spec` syntax is described in spec.spec first; hardcoded-bootstrap-grammar changes are exception-only and must be justified). Book synced: `compiler/pipeline-overview.md`'s dual-path note now states the paragraph-grouping parity. Docs only — no code change in this leaf (the rewrite itself was gated under `.3`).
- 2026-06-16 (MDBOOK-VARIANT-AGNOSTIC.7 — final consistency sweep, tree complete): Closed the tree with a whole-book verification pass. Reusable technique for "is the book consistently variant-agnostic?" — a scripted matrix over all `src/**.md` pages: for each page count Perl-API signals (`use LinkedSpec|LinkedSpec::(Get|get_parser)|\$parser->\(`) vs presence of a backend-frame phrase (`reference (backend|impl)|Perl reference|backend-neutral|universal contract|any … backend`), and flag any page with API blocks but no frame. Two interpretation notes: (1) a low frame-count is fine when a page uses one chapter-top frame to cover many blocks (the `.4` Option-A pattern — `get-and-get-parser` has 16 API hits / 1 frame and is correct); (2) the matrix over-counts API hits on pages that merely mention the project name "LinkedSpec" in prose (`spec-files-and-rule-paragraphs` flagged `api=1` with no actual code block) — always confirm with a precise `use LinkedSpec|\$parser->` grep before "fixing". The sweep found the book already consistent after `.1`–`.6`; only one optional polish remained (ebnf's descriptor block is far below its page frame, so its lead got an explicit "reference (Perl) backend" label). Net outcome of the tree: the `.spec` file is now framed as the one universal contract with Perl as the reference backend across all nine sections, matching ADR 0006 and the gold-standard `appendix/backend-handoff.md`. `mdbook build` exit 0; no code touched.
- 2026-06-16 (MDBOOK-VARIANT-AGNOSTIC.6 — appendix + corpus + development remediation): Finished the variant-agnostic sweep with the same demote-don't-delete convention. Two reusable insights for `.7` (the final consistency pass): (1) The "don't trust `.1` blindly, re-grep each page" discipline paid off again — it surfaced not a framing leak but a genuine **content drift**: the `ebnf` walkthrough still showed the pre-migration raw-Perl `semantic_annotation` action (`my $c = $CAPTURE; $c =~ s/…`), while the shipped `specs/ebnf.spec:187` had long since migrated to canonical helper DSL (`capture_slice()`, `substr(s(c), …)`, `return(a(…))`), and that same page's descriptor section already reported the rule `ready=1`/`compat_surface=0`. Lesson: walkthroughs that embed `.spec` snippets are a drift surface — verify embedded rule text against the actual shipped spec, not only for Perl-ism framing. (2) The 6 corpus walkthroughs share one `use LinkedSpec; my $parser = get_parser('X'); $parser->(\$input)` driver block; a single uniform "`.spec` is the contract; the reference (Perl) backend runs it by spec name" frame per page is the right touch (consistent with `.4` Option A). The legacy `plugin/`-migration prose and `pplugin`'s `.plg`/`PPlugin`/`eval` content stay (Non-Goals) behind a clear Perl-reference banner rather than being stripped. `mdbook build` exit 0; no code touched.
- 2026-06-16 (MDBOOK-VARIANT-AGNOSTIC.4 — public-api remediation): Resolved the tree's Open Question — for chapters that ARE essentially the Perl API (get/get_parser, trace-api), Option A (a per-chapter backend frame) beats Option B (relocating the API into a "Reference backend (Perl)" subsection): one frame labels every ```perl block at once, the chapter stays usable as the Perl reference API doc, and there's no heading/anchor churn or lost pedagogical flow. The reusable distinction this leaf sharpens: separate the *contract* (entry-point roles + option names + descriptor field names + trace model: levels/scopes/decisions/routing) from the *encoding* (coderef, `sub {}`, `qr//`, `use LinkedSpec` constants, package vars / typeglob aliasing, `$@`) — frame the former as backend-neutral and label the latter as the Perl reference representation. plugin-registry.md is the cleanest LABEL case: it's wholly Perl-reference + deprecated, so a single top banner ("not part of the `.spec` contract; a new backend need not implement it") is the right touch — no per-line edits. `mdbook build` exit 0; no code touched.
- 2026-06-16 (MDBOOK-VARIANT-AGNOSTIC.3 — user-model remediation): Reframed the mdBook user-model chapters with the `.2` demote-don't-delete convention. The efficient signoff pattern for heavy chapters (`worked-spec-walkthrough`, `runtime-context-and-tracing`): add ONE clear top frame stating that the `.spec` content and the structured contracts (runtime-context object, `last_error` schema, owner/stage attribution, handler source labels, trace levels/modes) are backend-neutral, while the runnable code, the raw error string (`$@`), the trace API, and `LINKEDSPEC_*` env vars are the Perl reference backend's surface — then a single frame labels every subsequent ```perl block at once, so the legitimate reference-backend examples can stay verbatim without per-block annotation. Only explicit "Perl" *prose* needs individual demotion ("caller-provided hash" → "object (a hash in the Perl reference backend)"; "raw Perl payload" → "raw host-language payload"; "generated Perl source and eval" → framed as reference-backend). Process note: the `.1` deterministic leakage scan undercounts where genuine Perl-API blocks are buried under DSL-label false positives — `rule-modes-and-parse-modes.md` was tagged CLEAN but had a real "Public option shape" `LinkedSpec::Get`/`get_parser` block; downstream leaves (`.4`–`.6`) should re-grep each page for `LinkedSpec::`/`use LinkedSpec`/`$@`/`my [%$@]` rather than trusting the `.1` CLEAN tag blindly. `mdbook build` exit 0; no code touched.
- 2026-06-16 (MDBOOK-VARIANT-AGNOSTIC.2 — overview remediation): Reframed the 5 mdBook overview pages to the variant-agnostic frame the gold-standard `appendix/backend-handoff.md` and ADR 0006 already use: the `.spec` file is the one universal contract; Perl is the reference backend (canonical behavioral oracle); Rust is the second backend. Editorial pattern applied consistently for the rest of the tree: do **not** delete legitimate Perl-reference detail — *demote* it. Concrete Perl API calls (`LinkedSpec::Get(\$spec)`, `get_parser`) become parenthetical "in the Perl reference backend …" examples rather than the primary surface; Perl-only nouns ("coderef") are kept but explicitly tagged as the Perl reference backend's form. Completed-phase historical facts that mention Perl internals (e.g. "`LinkedSpec.pm` is a 258-line facade" in the Phase 1 bullet) are left intact as historical records, but forward-looking *principles* (the design-rationale "why the facade is thin" bullet) were rewritten module-name-free. Caught and fixed a real drift while here: `project-status.md` claimed "Phases 0–7 done" but the roadmap has 0–9 done — added Phase 8 (multi-backend handoff) and Phase 9 (Rust variant), which are themselves the multi-backend story. No code touched; `mdbook build` exit 0. This editorial convention should carry into `.3`–`.6`.
- 2026-06-15 (RUST-EDGE-SEMANTICS.2 — implementation): Two-phase compiler rewrite. Phase 1: track same-line regex→edge adjacency using `element.line` comparison — matches Perl's model where `->` after `/regex/` on the same line is anchored. Phase 2: `build_dependency_regex_map` post-processing resolves edge-only entries (`has_parent_regex == false`) by looking up child rules' `regex_patterns[child_regex_idx]` and appending them to the parent rule's alternation, matching Perl's `Compiler::build_dependency_regex_map`. Parent regexes come first in the alternation (positions 0..P-1), child-resolved regexes appended after (P..P+C-1). Self-recursive entries (`-> SameRule[N]`) resolve against the rule's own already-populated parent regexes, duplicating them at new alternation positions. Missing child rules and OOB regex indices produce warnings (not errors), matching Perl's commented-out `exit 1`. The `has_parent_regex: bool` field on `AcodeEntry` has `#[serde(default)]` for backward compat with serialized data. The engine dispatch logic (`engine.rs:177: entry.regex_idx == m.index`) is unchanged — the fix is purely in what values populate `regex_patterns` and `regex_idx`.
- 2026-06-15 (RUST-EDGE-SEMANTICS.1 — audit): Full end-to-end gap analysis between Rust and Perl edge dispatch. The Rust compiler's "preceding regex" model (`current_regex_idx - 1`) is fundamentally incompatible with Perl's `dependency_regex_map` model. In Perl: (1) bootstrap parses `-> Child` as ACODE with `{relabel=>child_label, reidx=>child_regex_slot}` — `reidx` is the child rule's entrypoint index; (2) EmitContext builds `dependency_refs[{label, idx}]` from ACODE entries; (3) Compiler::build_dependency_regex_map collects each child rule's regex at the specified index into a combined LinkedRE alternation `$dependency_regex_map{$parent_label}`; (4) generated handler matches input against this child-regex alternation, `$$minfo{index}` identifies which child to dispatch. In Rust: compiler.rs builds `regex_patterns` from only explicit `/regex/` body elements — edge-only rules have empty alternation that never matches; `AcodeEntry.regex_idx` points to a parent regex slot, not an alternation position. The fix for .2 requires building the alternation from child rule dependency refs post-hoc (after all rules are compiled) and recomputing regex_idx to align with alternation order. The engine dispatch logic (engine.rs:177: `entry.regex_idx == m.index`) is correct in shape — the problem is purely in what values `regex_idx` and `regex_patterns` hold.
- 2026-06-15 (RGX-ADOPTION.1/.2): Adopted rgx-core as the regex engine in the Rust variant. The `regex` crate (v1) is fully replaced by `rgx-core` (v0.1.0, path dependency on `../rgx/rgx-core`). Migration is mechanical — rgx's API (`Regex::compile`, `find_first`, `find_first_at`, `Captures`) is a near drop-in replacement. rgx `MatchResult` exposes `.start`/`.end` as public fields (not accessor methods), and capture groups as `Vec<Option<(usize, usize)>>` byte ranges — extraction still uses `captures()` + `Captures::get()`/`Captures::name()` for string content. The `capture_names()` iterator has identical semantics to the regex crate. All 126 tests pass with zero behavioral changes. Key benefit: rgx supports PCRE2-level features (look-around, backreferences, subroutine calls) that the `regex` crate doesn't, opening the door for richer regex patterns in LinkedSpec specs. rgx pulls pgen (the PGEN regex parser), serde/serde_json/serde_stacker, and optionally Cranelift JIT (~200+ deps including wasmtime) — a heavier dependency footprint than regex v1, but the capability gain justifies it for a parser-prototyping platform.
- 2026-06-15 (RGX-BUILD-REPRO.1): rgx build blocker resolved. Upstream provided fixes for both cold-clone build failures reported in the RGX-BUILD-REPRO task tree. The `make` entrypoint (`BUILD-FLOW.1`) addresses the PGEN bootstrap issue — it runs `make -C subs/pgen/rust regex_parser_bootstrap` automatically before `cargo build`. The `--no-default-features` fix (`BUILD-FLOW.2`) gates `CharRange`/`posix_class_ranges()` behind `#[cfg(feature = "pgen-parser")]`, adds wildcard arms to the non-exhaustive `ast::Regex` match, and fixes Rust 2024 edition `_` expression issues. `docs/INTEGRATION.md` (`BUILD-FLOW.4`) is the downstream integration guide — exactly the kind of document the RGX-BUILD-REPRO report asked for. rgx submodule pin bumped from `b771c7b` to `8763a0e`. Verified working: `make` succeeds on cold clone (macOS arm64, rustc 1.95.0).
- 2026-06-15 (RUST-FUNCTIONAL-PARITY.5.1): Regex engine brought to signoff quality. Named capture extraction was completely missing — the `named` field was always an empty `HashMap`. Fixed by pre-computing `capture_names: Vec<Option<String>>` from `Regex::capture_names()` at compile time, then using it in `extract_named()` to map capture group indices to their names and values. Only groups with `Some(name)` are included; unnamed positional groups and unmatched optional named groups are excluded. Added `MatchResult::named_capture(name)` accessor for ergonomic single-capture lookup. Unlike Perl's `LinkedRE::oredRE` which builds a single `qr/$re0(?{$pos=0})|$re1(?{$pos=1})|.../` regex with embedded-code position tracking, the Rust engine iterates over alternatives and selects the earliest match — functionally equivalent, avoids Perl's `(?{...})` portability issues, and is trivially parallelizable in the future. Design decision: on tie at the same start position, the lowest-index alternative wins (consistent with iteration order). Test suite expanded 5→26 with thorough edge case coverage.
- 2026-06-15 (RUST-FUNCTIONAL-PARITY.4.1): Compiler brought to signoff quality. Replaced opaque tuple dispatch types with explicit `AcodeEntry { regex_idx, child_label, child_regex_idx, code }` and `BcodeEntry { child_label, code, fluent_chain }` structs — self-documenting API. Fixed critical regex_idx tracking bug: the compiler was incrementing `regex_idx` after both regex patterns AND action edges, creating spurious regex slots and wrong action-edge-to-regex associations. Now only regex patterns increment; action edges associate with the last regex that preceded them in the rule body. Separated `child_regex_idx` (the `[N]` in `-> rule[N]`, preserved for future multi-entrypoint dispatch) from the current-rule regex association. Fluent chains on blind edges (`=> rule .method(args)`) are now stored as structured `Vec<(String, String)>` in `BcodeEntry.fluent_chain` rather than as synthetic code strings that can't be parsed. Added `compile_all_shipped_specs_to_json` test proving serde roundtrip for all 20 shipped specs. Design decision: child_regex_idx is stored but not yet used by the engine (single-entrypoint dispatch in v1); it's forward-looking for multi-entrypoint support.
- 2026-06-15 (RUST-FUNCTIONAL-PARITY.3.1): Expression parser brought to signoff quality. Added `Expr::FluentChain` variant (`receiver: Box<Expr>` + `calls: Vec<FluentCall>`) for representing fluent method chains in the AST. Added `FluentCall` struct (`method` + `args`). Replaced broken placeholder fluent chain code (which produced a fake `Call { name: "chain", args: [Variable, Call { name: "" }] }`) with a proper recursive `parse_fluent_chain()` that handles unlimited `.method(args)` chains on calls, variables, and indexed vars. Added boolean literal parsing (`true`/`false`) with word-boundary guards so longer identifiers like `trueword` are not false-matched. Applied same word-boundary guard to `undef`. Extended fluent chain support to `parse_expr` for all three primary forms (call, indexed-var, plain variable). Added `Expr::FluentChain` interpreter support in `engine.rs`: evaluates the receiver expression (for side effects like `push_value`), then evaluates each fluent call in sequence. Test suite expanded 9→51 tests with comprehensive roundtrip validation: Display→Parse produces equivalent AST for all expression forms. Design decision: fluent chains are represented as a dedicated AST node rather than desugared into nested calls, keeping the AST close to the source and leaving desugaring decisions to the lowering layer (as in the Perl reference).
- 2026-06-15 (RUST-FUNCTIONAL-PARITY.2.3): Completed rgx evaluation as `regex` crate replacement for the Rust variant. API audit confirms all required primitives exist (`Regex::compile()`, `find_first_at()`, `find_first()`, `MatchResult.start`/`.end`/`.groups`, `capture_names()`). Migration mapping is mechanical: `Regex::new(p)` → `Regex::compile(p)`, `.find(text)` → `.find_first(text)`, `.find_at(text, pos)` → `.find_first_at(text, pos)`, method calls → field access (`.start()` → `.start`). rgx supports PCRE2-level features the `regex` crate lacks (look-around, backreferences, subroutine calls). Decision: DEFER — rgx is not on crates.io; requires cold-clone bootstrap (`make -C subs/pgen/rust regex_parser_bootstrap` per rgx README) before compilation. Re-evaluate when rgx is published to crates.io or the bootstrap has been run and workspace integration confirmed. Existing `regex` crate with look-around workaround (.2.2) sufficient for v1.
- 2026-06-14 (PHASE8-MULTI-BACKEND-HANDOFF.1): Created ADR 0006 — multi-backend vision formalized. Rust, Julia, Dart backends alongside Perl; same .spec files, lockstep semantics; HandlerIR as decoupling seam; specification-first (Phase 8 deliverables: formal grammar, HandlerIR spec, helper catalog, runtime semantics, test corpus, mdBook handoff). No bytecode VM — direct language emitters preferred.
- 2026-06-14 (PHASE8-MULTI-BACKEND-HANDOFF): Created Phase 8 task tree — 8 leaves for multi-backend specification and handoff. This is specification-only work: formal .spec grammar, HandlerIR spec, helper contract catalog, runtime semantics, language-neutral test corpus, and mdBook handoff chapter. The goal is that a Rust/Dart/Julia/Lua backend implementer can build a compliant LinkedSpec runtime without reading Perl source. Zero code changes planned — every deliverable is a document or test artifact. The multi-backend vision (lockstep backends consuming identical .spec files) was previously captured only as a KM fact card; Phase 8 formalizes it as a decision record (ADR 0006) and produces the specification surface. ADR 0021 later fixes the future rollout order as Dart, then Julia, then Lua.
- 2026-06-14 (PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1): Fixed 10 stale references across 6 files that still described PLUGIN-ACTION-MIGRATION as "proposed" when the tree is `retired`. The tree completed all 5 leaves on 2026-06-11 (17 dead files deleted, 19 kept as legacy corpus) then was retired by user decision. ROADMAP_V2.md, DEVELOPMENT_NOTES.md, LIVE_ACHIEVEMENT_STATUS.md, and 3 task-tree files now correctly reflect retired status.
- 2026-06-14 (DOC-BOOK-SYNC.1): Completed full mdBook and live docs audit. 19 gaps found across 13 files. The most significant findings: (1) HandlerVariantEmitter/HandlerIR is completely undocumented despite being a critical architectural layer (10 variant builders, JSON backend, backend dispatch table); (2) 5 legacy return helpers (return_a, return_m, return_ma, return_imatch, return_im) were removed from code on 2026-06-14 but are still documented as current in both the mdBook and USER_GUIDE.md; (3) configure_trace option names in trace-api.md don't match the actual implementation. The gap list is recorded in docs/tasks/DOC-BOOK-SYNC.md. Remediation follows in .2.
- 2026-06-14 (DOC-BOOK-SYNC): Created task tree for documentation and mdBook synchronization. This is the last remaining work item from ROADMAP_V2.md's overall roadmap tracker (status: mostly_done → remaining: ongoing documentation/book sync). The tree follows the standard 3-leaf + bootstrap pattern: audit (.1), remediate (.2), finalize (.3), with a bootstrap leaf (.0) for tree creation/registration. This is a documentation-only tree — no code changes expected. The prior BOOK-DOCUMENTATION-SYNC tree (completed) covered a sync pass in an earlier state of the codebase; this is a fresh sweep to catch any drift accumulated since.
- 2026-06-14 (ROADMAP-V2-TRACKER-SYNC): Synchronized ROADMAP_V2.md and ROADMAP.md trackers after the completion of COMPAT-ALIAS-RETIREMENT-V2 (all 8 retirement-candidate aliases removed), COMPAT-ALIAS-TEST-CLEANUP (test cleanup finalized), and FLUENT-BLOCK-EQUIVALENCE (fluent/block parity verified). The Method-like DSL migration track is now `done` — all 4 sub-trees plus the equivalence audit are complete. The overall roadmap is `mostly done` with only ongoing documentation/book sync and lifecycle-family audit work remaining. The PLUGIN-ACTION-MIGRATION tree was already retired (all 5 leaves done); references to it as a "proposed" or "remaining open" track are now historical.
- 2026-06-14 (COMPAT-ALIAS-RETIREMENT-V2.2): Retired medium-term legacy return helpers (return_a, return_ma, return_m, return_imatch/return_im, plus return_array) from all 7 implementation files. ~220 lines removed across LegacyRules.pm, Contracts.pm, CanonicalEvents/Core.pm, PrimitivePipelineRules.pm, FlowRules.pm, EmitContext.pm, MethodLowering.pm. These were the last remaining active compatibility aliases with dedicated infrastructure (scanner contracts, rewrite rules, canonical event mappings). Only canonical return(...) remains.
- 2026-06-14 (COMPAT-ALIAS-RETIREMENT-V2.1): Audited short-term compatibility aliases (tail, drop_last, flatten, array_values) across all 7 implementation layers. Implementation already canonical-only — aliases were incrementally retired during prior task trees. USER_GUIDE.md cleaned up (7 stale compatibility claims removed). The short-term alias retirement defined in METHOD-LIKE-DSL-MIGRATION.1 is effectively complete at the implementation level; only documentation lagged.
- 2026-06-14 (FLUENT-BLOCK-EQUIVALENCE — TREE COMPLETE): Both leaves done. Inventory (.1) confirmed all three expression forms exist for both if and switch families — no missing implementation gaps. Book documentation (.2) added a dedicated 270-line "Fluent and Block Forms" guide covering both expression styles, the seven lifecycle markers, three control-flow expression forms per family with worked examples, and an equivalence guarantee. The ROADMAP_V2.md "broaden fluent/block equivalence" item is now addressed: the surfaces already exist at the implementation level and are now clearly documented in one place for users. Regression coverage was already comprehensive (15+ subtests). The two control-flow families (if/elseif/else, switch/case/default) each support three expression forms: marker-style, inline-composite, and attached-block — all lowered through ControlFlow.pm. The structured lifecycle-block form (I/LS/LE/E/EX/IT/LX) is the fundamental "block" side. No missing implementation gaps found. The ROADMAP_V2.md "keep...aligned" items are maintenance directives about preserving existing parity, not unimplemented features. .2 rescoped to documentation (dedicated fluent/block equivalence guide) and regression hardening (lifecycle × form cross-product tests). The item "broaden fluent/block equivalence on supported surfaces" is the most concrete remaining work in the near-term priorities not already marked "landed." The task tree starts with an inventory/audit (.1) to survey current fluent vs block equivalence across all supported control-flow constructs (if/elseif/else, switch/case/default, marker-style, inline-composite, attached-block) and lifecycle families (I, LS, LE, E, EX, IT, LX). This follows the pattern of earlier trees (PHASE3-EXECUTION-SEMANTICS, PHASE4-CAPTURE-MARK-API) that start with a surface inventory before any implementation. The MEDIUM-IMPACT tree completed all 16 leaves — this is the first new active tree after that exhaustive cycle.

- 2026-06-13 (MEDIUM-IMPACT.3.5 — spec.spec dual-path parse): BootstrapSpec.pm now wires spec.spec as a diagnostic side channel alongside the bootstrap parser. `_build_spec_spec_parser()` lazily builds the spec.spec-generated parser through the bootstrap seed path (BootstrapSpec::Core → Compiler → spec.spec → generated parser) and caches it in a package variable. `run_bootstrap_parse()` runs both parsers — bootstrap (always primary, format compatibility) and spec.spec (diagnostic side channel). A recursion guard (`$BUILDING_SPEC_SPEC_PARSER` package variable) prevents infinite loop: if spec.spec tries to parse itself, it short-circuits to bootstrap-only parse. Key design decisions: (1) Bootstrap remains primary — the dual-path is a validation/diagnostic aid, not a hot-swap to spec.spec as primary; (2) The side-channel parse does not affect the caller's return value — bootstrap output is what's returned; (3) The build is lazy and cached — spec.spec parser is built once per process lifetime; (4) The recursion guard is a simple boolean toggle, sufficient because the recursive call path is exactly spec.spec → Compiler → BootstrapSpec → _build_spec_spec_parser → Compiler (infinite without guard). Cross-check at 2/20 exact match — parity improvements tracked in .3.4.

- 2026-06-13 (MEDIUM-IMPACT.3.4.4 — MIXED_ACTIONS resolved): Four coordinated changes avoid the MIXED_ACTIONS gate. Key insight: the edge `-> body_element` is an ACODE entry (not BCODE), generated by the bootstrap parser. AND I-blocks were routed to acode_entries which conflicted. Fix: (1) RuleIR routes AND I-blocks to new `and_icode_entries` field (not acode_entries), keeping acode_count at 0. (2) EmitContext rewrites and_icode_entries into and_icode string. (3) SpecEntry passes REs+and_icode to AND_BCODE variant. (4) AND_SINGLE_ACODE emitter prepends `$label = ` to edge acodes so lowered handler call results flow into @collect. The `call()` transform didn't work because edge codes are already lowered to `&{$$descr{spec}{X}{handler}}(...)` by the action rewriter. Prepending assignment captures the result value before LE code pushes. Cross-check improved from 1/20 to significant multi-rule parsing across all specs.

- 2026-06-12 (MEDIUM-IMPACT.3.4.3 — MIXED_ACTIONS discovery): Cross-check re-run after AND ICODE routing fix (.3.4.2) shows 1/20 match (was 10/20). Root cause: RuleIR's AND I-block routing to acode_entries creates acode_count=1 alongside existing bcode_count=1 (from `-> body_element` edge). RuleIR variant detection (`_select_rule_handler_variant`, line 34) returns `MIXED_ACTIONS` when both counts > 0 — execution shape is `invalid_mixed_actions`. Handler selection falls back to `_default`, which processes neither I-blocks nor edges. The MIXED_ACTIONS gate exists because the original architecture assumed rules use EITHER acodes (per-regex action code) OR bcodes (blind-call edges), never both. AND rules with combined I-block + edges violate this assumption. Fix (.3.4.4): emit AND I-block as a separate `and_icode` field in RuleIR (not an acode_entry), extend AND_BCODE emitter to support optional and_icode with IMATCH bridge + return→assignment. Avoids acode_count increment → no MIXED_ACTIONS.
- 2026-06-12 (MEDIUM-IMPACT.3.3): Dual-path cross-check complete. 10/20 specs have matching rule counts between BootstrapSpec (oracle) and spec.spec parser (candidate). 10/20 have inflated candidate counts due to spec.spec AND handler lacking E-block body collection and body_element:* over-matching individual body lines. The cross-check harness at tools/cross_check_spec_parsers.pl provides a reusable comparison framework. Gaps drive .3.4 fixes.
- 2026-06-12 (session bootstrap): Restructured MEDIUM-IMPACT.3 from 4→6 leaves — inserted dual-path cross-check before wiring spec.spec as primary. Strategy: BootstrapSpec::Core = oracle, spec.spec = candidate; compare all 20 specs → fix gaps → claim parity → wire primary. This ensures spec.spec earns primary-path status through demonstrated output parity. COMPAT-ALIAS-RETIREMENT tree completed and moved to Completed.
- 2026-06-12 (MEDIUM-IMPACT.3.2): Closed the comment/blank-line skipping gap. Added a parser wrapper in `Runtime::run_get` that resets `pos()` to 0 and skips past leading comment (`# ...`) and blank lines before the main parse loop. This approach avoids modifying the generated handler code or the spec.spec grammar. The wrapper applies to all parsers built via `LinkedSpec::Get()`, making it universally available. The self-parse of spec.spec now works with raw content (no pre-stripping needed). Inter-paragraph comment skipping is left as future enhancement.

- 2026-06-12 (MEDIUM-IMPACT.3.1 — post-commit bookkeeping): Completed administrative close-out for MEDIUM-IMPACT.3.1 (committed `2526f2b` + hash-fix chain). Task-tree frontier updated (.3.2 now first eligible). The substantive work — spec.spec accuracy audit, RuleIR ICODE→ACODE fix for REP/OR rules, SpecEntry REP handler return→assignment fix — is mechanically gated at 1005 PASS. The comment/blank-line skipping gap (.3.2) is the next prerequisite before wiring spec.spec as primary parse path (.3.3). MEMORY.md hash-fix chain (5 commits) is a known workflow artifact: updating MEMORY.md changes HEAD, requiring another MEMORY.md update. The chain stabilizes when the commit subject correctly reflects the MEMORY.md state it writes.

- 2026-06-11 (ACCUMULATOR-CONVENTION-AUDIT.3 — post-commit cleanup): Completed the administrative close-out for commit `3065636`. MEMORY.md `latest_commit` and `next_action` updated; task-tree commit log backfilled with hash. Clean working tree confirmed. PNT idle — no active task trees; `PLUGIN-ACTION-MIGRATION` tree is retired (all 5 leaves done, 17 dead files deleted, 19 kept as legacy corpus).

- 2026-06-11 (ACCUMULATOR-CONVENTION-AUDIT.3 — TREE COMPLETE): Completed synthesis and recommendations. Key conclusion: the implicit-target `push(Child)` convention is healthy and serves a clear purpose — it is not harmful, not ambiguous in practice, and should not be deprecated. The ecosystem already self-selected: 95.5% of accumulator ops use explicit targets, and the 4 remaining convention-based uses are idiomatic. 6 recommendations: (1) keep convention as-is, (2–3) document in mdBook, (4) no ActionIR changes, (5) no spec migrations, (6) teach `push_value` as preferred form. Tree moved to Completed; no active trees remain — PNT idle.

- 2026-06-11 (ACCUMULATOR-CONVENTION-AUDIT.2): Completed per-spec accumulator usage categorization. 88 total accumulator ops across 19 specs: only 4 convention-based (4.5%) — `push(reg_def)`, `push(reg_fld)` in regdef.spec, `push(sub_gui)` in tkgui.spec, `push(quoted_string, 1)` in ebnf.spec. The other 84 (95.5%) use explicit targets: 63 `push_value`, 19 fluent `.push()`, 2 `push_nonempty`. 10 specs use zero accumulators. The implicit-target convention is nearly extinct in practice. PNT frontier: `.3` (synthesis and recommendations).

- 2026-06-11 (ACCUMULATOR-CONVENTION-AUDIT.1): Activated accumulator convention audit tree. Completed ActionIR contract inventory: 9 accumulator-related contracts across `Contracts.pm` (`_build_call_and_dispatch_contracts` + `_build_assignment_and_regex_contracts`), `Scanner/PrimitiveBasicRules.pm`, and `MethodLowering.pm`. Only 2 are convention-based (implicit `@$label` target): `push_single_arg` → `push(Child)` and `push_indexed_arg` → `push(Child, idx)`. The `_builtin` contracts (`push_child_call_builtin`, `push_child_call_indexed_builtin`) are internal re-scan contracts (compatibility_surface=1), not user-facing. The `push(Child, arg)` disambiguation relies on regex match order: `\d+` (index) before `\w+` (target name). Created `PLUGIN-ACTION-MIGRATION` task tree (proposed, parked). PNT frontier: `.2` (per-spec usage categorization).

- 2026-06-05 (KNOWLEDGE-MAP-DOC.4 — TREE COMPLETE): Verified end-to-end — `bash tools/run_ci_local.sh` exit 0 with memory-arch + KM checks both passing before phase0 `Tests=1004 PASS`. Moved the tree Active→Completed. LinkedSpec now has the full stack: durable memory (layers A–D, `MEMORY_ARCHITECTURE.md`) + the question-keyed Knowledge Map retrieval layer (`KNOWLEDGE_MAP.md` derived from `docs/knowledge/` cards), both gated in pre-commit + the local CI gate. To port the KM to another repo: `cp -r knowledge-map /path/to/repo && bash knowledge-map/install.sh`, then add the hook snippet + CI line and `git config core.hooksPath .githooks`. No active trees remain — PNT idle.
- 2026-06-05 (KNOWLEDGE-MAP-DOC.3): Wired the KM gate. Key gotcha fixed: the `.githooks/pre-commit` was `exec`-based (replaces the process), so an appended gate would never run — rewrote it to call the memory-arch self-check then the KM regenerate/stage/check sequentially. Added the KM check to `tools/run_ci_local.sh`. Reconciled all bootstrap pointers to route to `KNOWLEDGE_MAP.md` + reversed the AGENTS.md "not adopted" line. Added ADR 0005 (adoption + archaeology boundary). Proved the gate bites (invalid card / tampered map → exit 1; clean → 0). PNT frontier: `.4` (verify + close).
- 2026-06-05 (KNOWLEDGE-MAP-DOC.2): Seeded 6 durable-fact cards under `docs/knowledge/` — each a signpost (front-matter `answers:`/`evidence`/`reverify` + a body pointing to the canonical home), verified true against the repo before writing the reverify. Map now 6 facts / 29 question keys; `check_knowledge_map.sh` OK. The flagship card `actionrewriter-removed-phase1` directly answers the question whose stale answer triggered the whole DOC-CODEBASE-ALIGNMENT effort — future sessions now grep it instead of re-deriving. PNT frontier: `.3` (wire the KM gate + reconcile bootstrap pointers + ADR 0005).
- 2026-06-05 (KNOWLEDGE-MAP-DOC.1): Began adopting the Knowledge Map (KM) retrieval layer — the composed, question-keyed index over front-mattered fact cards that makes archaeology (re-deriving an already-logged structural/causal fact) structurally impossible. Vendored the `knowledge-map/` bundle verbatim, ran `install.sh` (created `docs/knowledge/`, generated `KNOWLEDGE_MAP.md`). Reconciled the `MEMORY_ARCHITECTURE.md` §5 "not adopted" note → "adopted" and wired README discovery. Boundary to remember (from the KM standard): the KM eliminates archaeology for durable structural/causal facts; it does NOT remove first-time measurement of changing runtime state — there the rule is that the durable conclusion becomes a card. Remaining: `.2` seed cards, `.3` enforcement (pre-commit + run_ci_local KM gate) + bootstrap-pointer reconcile + ADR 0005, `.4` verify + close. PNT frontier: `.2`.
- 2026-06-04 (MEMORY-ARCHITECTURE-DOC.5 — TREE COMPLETE): Verified end-to-end — `bash tools/run_ci_local.sh` exit 0 with the memory-arch self-check running first (all invariants hold) and phase0 `Tests=1004 PASS`. Moved the tree Active→Completed. The durable agent-memory architecture is now adopted + enforced in linkedspec: layer A (`MEMORY.md` bounded resume pointer) / B (`docs/tasks/`) / C (`docs/decisions/`) / D (git), reachable from `AGENTS.md`+mirrors, gated by E1–E4. To port to another task-tree repo: copy `MEMORY_ARCHITECTURE.md` + `scripts/check_memory_architecture.sh` + `.githooks/`, add the one-line bootstrap pointers, `git config core.hooksPath .githooks`, wire the self-check into that repo's CI, and adapt the two knobs (line cap, commit-msg regex). No active trees remain — PNT idle.
- 2026-06-04 (MEMORY-ARCHITECTURE-DOC.4): Installed the §9 enforcement — `scripts/check_memory_architecture.sh` (E2), `.githooks/pre-commit`+`commit-msg` (E3, `core.hooksPath .githooks`), bootstrap pointers AGENTS/CLAUDE/.cursorrules/copilot (E1), and the self-check as the first gate in `tools/run_ci_local.sh` (E4). Two linkedspec adaptations vs the specforge reference: (1) the pre-commit hook does NOT reference the Knowledge Map (not adopted here); (2) the commit-msg regex accepts linkedspec's scheme — a task-tree leaf id anywhere in the subject/first-body-line OR a maintenance prefix ("Docs:" etc.). Caught and fixed a portability bug: bash `=~` is POSIX ERE with no `\b`, so the maintenance pattern uses an explicit separator class `([ :(!]|$)`. Proved every gate bites. PNT frontier: `.5` (end-to-end verify + close).
- 2026-06-04 (MEMORY-ARCHITECTURE-DOC.3): Demoted `MEMORY.md` from a 5204-line cumulative log to the 25-line bounded layer-A resume pointer (`MEMORY_ARCHITECTURE.md` §6 template; history preserved in git, verified via `git show HEAD:MEMORY.md`). Reconciled the doctrine conflict: `COMMIT.md` previously declared MEMORY.md "cumulative and not reset" — its `### 4)` section + workflow step 2 now define it as overwrite-only/capped and route durable facts to `docs/decisions/`; README ramp-up item 9 reframed to match. This is the key precondition for the `.4` pre-commit self-check (which caps MEMORY.md at 60 lines). PNT frontier: `.4` (install enforcement).
- 2026-06-04 (MEMORY-ARCHITECTURE-DOC.2): Created `docs/decisions/` (memory layer C) + INDEX + 4 seed ADR records: 0001 task-tree/commit/zero-drift doctrine (migrated out of harness `~/.claude` memory so it survives a harness/model switch), 0002 all-target ActionIR-ready invariant, 0003 raw-Perl-free `.spec` policy, 0004 hosted-CI-disabled/local-gate. Records point at authoritative tracked docs, not duplicating. PNT frontier: `.3` (demote MEMORY.md + reconcile COMMIT.md).
- 2026-06-04 (MEMORY-ARCHITECTURE-DOC.1): Began adopting the durable agent-memory architecture standard (`MEMORY_ARCHITECTURE.md`) — four layers (A resume pointer / B task-trees / C `docs/decisions/` / D git) plus §9 enforcement, harness-agnostic so memory survives session/crash/machine/model/harness loss. Copied the standard verbatim from the cross-project source (specforge); the optional composed Knowledge Map layer is explicitly **not** adopted here (noted in §5; tree non-goal). Wired discovery: README doc map + ramp-up + path map, and `SESSION_BOOTSTRAP.md`. Remaining leaves: `.2` decision records, `.3` demote MEMORY.md + reconcile COMMIT.md, `.4` enforcement kit (self-check + hooks + CI + bootstrap pointers), `.5` verify + close. PNT frontier: `.2`.
- 2026-06-04 (DOC-CODEBASE-ALIGNMENT.5): Synced `ROADMAP.md`'s live-status tracker with `ROADMAP_V2.md`/reality — its table was frozen at an early state (Phases 1/1A `mostly done`, 2-6 `in progress`, 7 `not started`, Backbone `mostly done`). Flipped 13 rows to current status, trimmed stale "Remaining focus" prose to concise task-tree-referenced notes, and annotated the Phase 1A planning section that `ActionRewriter.pm` was extracted then deleted in Phase 1. All 15 shared statuses now match V2; all ROADMAP.md ActionRewriter mentions are historical. **DOC-CODEBASE-ALIGNMENT tree COMPLETE (5 leaves).** No active trees remain; PNT idle (proposed `PLUGIN-ACTION-MIGRATION` stays proposed). Workflow note: the long-form `ROADMAP.md` tracker had silently diverged from the `ROADMAP_V2.md` working tracker; both must be updated in the same slice going forward (per `ROADMAP_V2.md`'s own drift rule).
- 2026-06-04 (DOC-CODEBASE-ALIGNMENT.4): Reconciled `ROADMAP_V2.md`'s Phase 1A row so the deleted `ActionRewriter.pm` is framed as historical, not a live OwnerDispatch seam participant (the Phase 1 row already recorded its deletion). Discovered while doing this that `ROADMAP.md`'s whole status tracker is stale (every phase/track behind `ROADMAP_V2.md`); split that into new leaf `.5` per the workflow splitting rule. `ROADMAP_V2.md` mandates updating both roadmaps in the same slice, satisfied by doing `.4` then `.5` back-to-back. PNT frontier: `.5`.
- 2026-06-04 (DOC-CODEBASE-ALIGNMENT.3): Scrubbed deleted-`ActionRewriter.pm` live claims from `USER_GUIDE.md` (7 references in two clusters). It had described ActionRewriter as a retained compatibility wrapper; now framed as a forwarding shim deleted in `PHASE1-PARSER-CORE-ISOLATION.2`, with `RuleIR::EmitContext::rewrite_action_code_for_compat(...)` as the focused entrypoint. Also corrected the `LinkedSpec::Deps` note (removed entirely). `docs/linkedspec-book/` was already clean. PNT frontier: `.4` (reconcile ROADMAP.md / ROADMAP_V2.md).
- 2026-06-04 (DOC-CODEBASE-ALIGNMENT.2): Refreshed `ARCHITECTURE_STATE.md` — it still listed the deleted `perl/LinkedSpec/ActionRewriter.pm` as a live owner-dispatch participant. ActionRewriter.pm was a pure forwarding shim over `RuleIR::EmitContext` and was deleted in `PHASE1-PARSER-CORE-ISOLATION.2`; the focused helper-rewrite compatibility entrypoint is now solely `RuleIR::EmitContext::rewrite_action_code_for_compat(...)` (façade: `LinkedSpec::call_spec_handler_subst(...)`). Updated the snapshot date, rewrote the "thinner now" bullet to "deleted entirely", and dropped it from the seam-sharing list. PNT frontier: `.3` (USER_GUIDE/book scrub of the same stale claim).
- 2026-06-04 (DOC-CODEBASE-ALIGNMENT.1): Reconciled `docs/TASK_TREE.md` with the real `docs/tasks/*.md` statuses after a session-bootstrap drift audit. The index had drifted three ways: (1) `PHASE7-SELF-HOSTED-SPEC` was still listed `active` though its file is `done`; (2) `PHASE1-PARSER-CORE-ISOLATION`, `METHOD-LIKE-DSL-MIGRATION`, and `BOOK-DOCUMENTATION-SYNC` were absent from the index entirely despite being complete; (3) `PHASE3/4/5` files carried `Status: active` in metadata while their top nodes already said `completed`. Workflow note for future sessions: the ledger uses both `done` (status vocabulary terminal state) and `completed` (Completed-table label and some older files) for finished trees — treat them as equivalent terminal markers, but keep each file's metadata `Status` consistent with its own top task-tree node. New owning tree: `DOC-CODEBASE-ALIGNMENT` (frontier `.2`: refresh `ARCHITECTURE_STATE.md`). 1004 PASS baseline.
- 2026-05-17 (PHASE7-SELF-HOSTED-SPEC.1): Completed .spec language surface inventory. 37 syntax categories across 9 sections. 4 follow-on leaves created (.2–.5). PNT frontier: .2 (author structural rule paragraphs).
- 2026-05-17 (PLUGIN-MODERNIZATION.5): PPlugin/PluginBridge retirement evaluation complete. 36 .plg files (~1,200+ actions) remain — cannot retire yet. Documented 5-step retirement path. PLUGIN-MODERNIZATION tree COMPLETE (5 leaves). Proposed follow-on: PLUGIN-ACTION-MIGRATION. No active trees remain — PNT idle.
- 2026-05-17 (PLUGIN-MODERNIZATION.4): Deprecated all 7 legacy plugin facade methods in LinkedSpec.pm. Compact DEPRECATED annotations with retirement timeline tied to .5. None removable yet (FSMGen AUTOLOAD, test locks). PNT frontier: .5 (PPlugin/PluginBridge retirement — last leaf).
- 2026-05-17 (PLUGIN-MODERNIZATION.3): De-scoped FSMGen.pm from LinkedSpec::get_plugin. Replaced default `\&LinkedSpec::get_plugin` with `sub {}` no-op in getop_plugin_list. Only external get_plugin caller now requires explicit opt-in. PNT frontier: .4 (reduce public facade plugin surface).
- 2026-05-17 (DOCTRINE): Codified task-tree-ownership doctrine. All code changes must be task-tree tracked/owned before implementation. Recorded in book chapter `development/local-ci-and-regression.md` and all live docs. Non-negotiable.
- 2026-05-17 (PLUGIN-MODERNIZATION.2): Removed 2 dead .plg files (hutils.plg, quick_sdf_hack.plg). Both confirmed zero external references. 36 .plg files remain. PNT frontier: .3 (de-scope FSMGen from get_plugin).
- 2026-05-17 (PLUGIN-MODERNIZATION.1): Inventoried plugin surface. 38 .plg files, 3 plugin modules, 7 facade methods, 1 external caller (FSMGen). Created follow-on leaves .2–.5. PNT frontier: .2 (remove already-extracted .plg wrappers).
- 2026-05-17 (BACKBONE-ACTION-IR-LOWERING.1): Audited all 12 ActionIR owners. All use OwnerDispatch uniformly. Zero old-style _require_dep wrappers. Backbone Item 3 ActionIR owner-contract cleanup complete. BACKBONE-ACTION-IR-LOWERING tree done (1 leaf). PNT frontier: PLUGIN-MODERNIZATION.1.
- 2026-05-17 (PHASE6-DOCUMENTATION.8): Backfilled 3 per-spec walkthroughs (tablegrep, portmap, pplugin). Each covers how to run, output shape, rule inventory, design points, descriptor readiness, and why interesting. Updated SUMMARY.md and shipped-specs-and-corpora.md reading order. PHASE6-DOCUMENTATION tree COMPLETE (8 leaves). All documentation gaps from .1 inventory now closed. PNT frontier: BACKBONE-ACTION-IR-LOWERING.1 (next active tree).
- 2026-05-17 (PHASE6-DOCUMENTATION.7): Expanded ActionIR lowering pipeline docs (184→347 combined). actionir-lowering-mental-model (107→164): added full pipeline stages + contracts table. action-model-and-helper-surface (77→183): expanded helper families + pipeline flow. PNT frontier: .8 (per-spec walkthroughs — last leaf).
- 2026-05-17 (PHASE6-DOCUMENTATION.6): Expanded all 4 overview chapters (153→275 lines). what-is-linkedspec (29→69), design-rationale (50→80), project-status (19→52), documentation-layers (55→74). Entry point now substantive with worked example, roadmap summary, and reading-order guidance. PNT frontier: .7 (ActionIR lowering pipeline docs).
- 2026-05-17 (PHASE6-DOCUMENTATION.5): Bridged book/USER_GUIDE cross-linking — added cross-references to 5 additional book chapters. USER_GUIDE.md now links to the book. 6 book chapters cross-reference USER_GUIDE files. PNT frontier: .6 (overview chapter expansion).
- 2026-05-17 (PHASE6-DOCUMENTATION.4): Completed public API docs — created trace-api.md (7 trace methods + verbosity levels) and plugin-registry.md (3 registry + 4 legacy methods). Updated get-and-get-parser.md. All 4 facade bands now documented. PNT frontier: .5 (book/USER_GUIDE cross-linking).
- 2026-05-17 (PHASE6-DOCUMENTATION.3): Documented Validation.pm — expanded ARCHITECTURE_STATE.md section from 4 bullets to 30-line entry covering all 5 public entry points, error reporting, and debugging. Expanded book pipeline-overview Stage 2 from 4 lines to 16-line structured description of three validation layers. Largest undocumented module now documented. PNT frontier: .4 (public API completeness).
- 2026-05-17 (PHASE6-DOCUMENTATION.2): Documented LinkedRE.pm — added 11-line section to ARCHITECTURE_STATE.md and 3-line explanatory note to book's generated-handlers-and-dispatch.md. 56-line core utility now has substantive coverage in both architecture and book layers. PNT frontier: .3 (Validation.pm docs).
- 2026-05-17 (PHASE6-DOCUMENTATION.1): Completed Phase 6 documentation inventory. 30 book chapters all substantive, 10 USER_GUIDE files (14.6K lines), 6 live docs, ARCHITECTURE_STATE.md, README.md. 7 gaps found: LinkedRE zero docs, Validation.pm thin, public API incomplete, book/USER_GUIDE silos, overview chapters thin, ActionIR lowering thin, per-spec walkthroughs incomplete. Created leaves .2–.8. PNT frontier: .2 (LinkedRE docs).
- 2026-05-17 (PHASE5-RUNTIME-DIAGNOSTICS.2): Fixed stderr leak in SpecEntry.pm line 740. Replaced `warn $compile_warning` on successful handler compilation with `_trace_decision("rule_handler_compile:$label", 1, "compiled with warnings: $compile_warning", DUMP_NONE)`. Compile warnings now route through trace decision instead of raw stderr. Handler compile failures remain on the structured last_error channel. PHASE5-RUNTIME-DIAGNOSTICS tree COMPLETE (2 leaves). Full suite: 1007 PASS. Next active tree: PHASE6-DOCUMENTATION.
- 2026-05-17 (PHASE5-RUNTIME-DIAGNOSTICS.1): Completed Phase 5 runtime diagnostics inventory. 5 structured error families verified across 30+ call sites. Eval minimized to 1 handler compile + 1 execution trap. Trace bridging intact. Handler caching confirmed. 1 stderr leak found: SpecEntry.pm:740 (`warn $compile_warning`). PNT frontier: .2 (fix stderr leak).
- 2026-05-17 (PHASE4-CAPTURE-MARK-API tree COMPLETE): All 4 leaves done (inventory, alias verification, mark-helper verification, finalize). Phase 4 `done` in ROADMAP_V2.md. 163 contracts, 100+ helpers across 6 families (anonymous boundary, named mark, bridge, cursor, whole-input, entry/match). Zero shipped spec legacy usage. 2 minor doc gaps: compat alias table and mark-helper reference completeness. Created .2/.3/.4. PNT frontier: .2 (compat alias doc cleanup).
- 2026-05-17 (PHASE3-EXECUTION-SEMANTICS.4): Verified BACKTRACK+parse_mode interaction already covered by .2 (source-boundary-helper-reference.md) and cross-referenced in .3 (rule-modes-and-parse-modes.md). PHASE3-EXECUTION-SEMANTICS tree COMPLETE (4 leaves). ROADMAP_V2.md Phase 3 → `done` (2026-05-17).
- 2026-05-17 (PHASE3-EXECUTION-SEMANTICS.3): Added "Forward-moving, non-backtracking model" subsection to rule-modes-and-parse-modes.md. States parser engine is forward-moving, no search tree, no partial-match unwind, no systemic backtracking. BACKTRACK/IBACKTRACK are sole rewind (local pos() manipulation). Cross-reference to source-boundary-helper-reference. 18-line prose addition.
- 2026-05-17 (PHASE3-EXECUTION-SEMANTICS.2): Documented BACKTRACK/IBACKTRACK as local cursor-rewind helpers in source-boundary-helper-reference.md. Explicitly distinguishes local pos() manipulation from systemic backtracking (LinkedSpec does not maintain a search tree or unwind partial rule matches). Covers parse_mode interaction after rewind and label-argument compatibility. 22-line prose addition.
- 2026-05-17 (PHASE3-EXECUTION-SEMANTICS.1): Completed Phase 3 execution semantics inventory. Seek/consume implementation is solid across 8 components; documentation is comprehensive but has 3 gaps: BACKTRACK/IBACKTRACK local-rewind contract not stated as local pos() manipulation (not search-tree rollback), no explicit non-backtracking forward-moving model statement, and BACKTRACK+parse_mode interaction not documented. All 3 gaps are book-only (no implementation changes). Created leaves .2, .3, .4. Full suite: 1007 PASS.
- 2026-05-16 (PHASE1A-CLOSE-OUT.2): Finalized ROADMAP_V2.md status update. Phase 1A (`mostly done` → `done`) and Phase 2 (`in progress` → `done`), both with 2026-05-16 completion dates. PHASE1A-CLOSE-OUT tree complete (2 leaves). Next: PNT to PHASE3-EXECUTION-SEMANTICS.1.
- 2026-05-16 (PHASE1A-CLOSE-OUT.1): Completed Phase 1A modularization audit. LinkedSpec.pm is a 286-line thin facade delegating all work through `_dispatch_owner_call` to 18 extracted modules. All modules use OwnerDispatch uniformly through 5 shared entry points. No monolith-era pragma (`use re 'eval'`), no dead wrappers, no circular coupling. Phase 1A modularization is complete — only ROADMAP_V2 status flip remains.
- 2026-05-16 (PHASE2-DSL-FRONTEND.3): Added `strict_syntax` option to `validate_dsl_syntax` (Validation.pm lines 719-741). When set, undefined rule references and unused rules become hard errors via `_report_dsl_validation_failure` instead of warnings via `_trace_log_output`. Default off preserves backwards compatibility. All 19 shipped specs fail strict mode because every top rule is unreferenced (the entry point is never a target). PHASE2-DSL-FRONTEND tree is now fully complete (all 6 leaves done, 1007 tests PASS).
- 2026-05-16 (PHASE2-DSL-FRONTEND.5): Expanded extra-colon rule-label rejection regression from 1 to 14 edge cases. The existing `_parse_rule_label_line` function already handled all extra-colon patterns correctly via its `invalid_mode` flag (Validation.pm line 70-71: `$tail =~ /\A:/o`). The expanded test covers triple/quadruple colons, colon-space-colon variants, double-colon-space-colon, mode-suffix+colon combinations, bounded-OR+colon, and tab-separated colons. Full suite: 1004 PASS.
- 2026-05-16 (PHASE2-DSL-FRONTEND.4): Closed the inside-block rule-start detection gap. Added explicit rejection in `validate_dsl_syntax` when `edge_scan_depth > 0` and `_parse_rule_label_line` matches (new check at lines 611-620 of Validation.pm). A line matching the rule-label pattern (e.g., `Word:`, `Word::`, `Word:AND+`) inside an open `{ }` block now triggers "Rule definition not allowed inside open block" instead of being silently consumed as body content. Updated 2 existing tests, added 5 new regression subtests. Verified no shipped specs have rule-label-like lines inside blocks. Full suite: 1004 tests PASS.
- 2026-05-16 (PHASE2-DSL-FRONTEND.6): Completed full fluent-continuation surface regression. Added 4 subtests covering lifecycle-marker fluent chains (I/LS/LE/E/EX/IT/LX with `.if(scalar(on)) { ... }`), deeply nested 5+ call chains (`.coalesce().trim().lowercase().length().push()`), quoted args with nested function calls (`.if(contains_substr(scalar(tag), "critical"))`), and empty-args method calls (`.push().return_undef()`). The `_looks_like_supported_rule_paragraph_member_line` regex patterns now have regression coverage for every fluent-continuation spelling that appears in the bootstrap grammar. Full suite: 999 tests PASS.
- 2026-05-16: Installed repo-local task-tree tracking workflow adapted from fsmgen. All roadmap phases now have owning task trees with PNT (Pick Next Task) semantics: one leaf at a time, leaf-ID commit traceability, split rules, blocker rules, and completion evidence. The workflow lives in `docs/TASK_TREE.md` (operating spec + active-tree index), `docs/tasks/TEMPLATE.md` (copyable skeleton), and per-phase `docs/tasks/<TREE>.md` files. The PostCompact hook re-reads live-docs, the task-tree index, and mdBook entry points after every compaction to preserve PNT context. from direct `LinkedSpec::get_plugin(...)` calls to the public plugin-bridge dispatch helper family: `LinkedSpec::get_plugin(...)`, `LinkedSpec::run_plugin(...)`, and `LinkedSpec::dispatch_plugin_autoload_name(...)`. The regression label now names the package-owner destination instead of the older get-plugin transition step.
- 2026-05-11: Tightened the plugin-modernization regression around repo-owned `.plg` files. The only remaining `LinkedSpec::get_plugin(...)` occurrence in the plugin corpus was a stale commented `setup_hold_tmax_tmin` lookup in `plugin/stan_omap2430c_backend.plg`; it is now gone, and phase0 scans every shipped `.plg` file to reject direct `LinkedSpec::get_plugin(...)` calls alongside direct `PPlugin->get(...)` calls.
- 2026-05-11: Removed unused `Compiler::_build_final_descriptor(...)`. The active compile pipeline already builds `_build_final_descriptor_state(...)` and projects the compatibility descriptor through `CompilerState` at the call site, so keeping the extra private projection helper only preserved an obsolete legacy-descriptor shortcut. Phase0 source-lock coverage now rejects reintroducing it.
- 2026-05-11: Finished another active final-descriptor naming cleanup in `Compiler.pm`. The live compiler path now uses `$final_descriptor_state` / `$final_descriptor` and `FINAL_DESCRIPTOR` trace banners instead of compressed `final_descr` wording, with source-lock coverage preventing the compressed local name from returning.
- 2026-05-11: Added a repo-wide phase0 guard for the DSL migration track. Every discovered target `.spec` now compiles as a descriptor and must report `language_agnostic_ready_ratio == 1.0000`, zero language-agnostic blocked rules, and zero compatibility-surface rules, turning the current all-target ActionIR-ready state into a single regression contract.
- 2026-05-11: Removed `Compiler::_compiled_descriptor_state_to_legacy_descriptor(...)`. Final descriptor projection now asks `CompilerState` directly through `_call_compiler_state('compiled_descriptor_state_to_legacy_descriptor', ...)`, and the projection-order regression now traps the `CompilerState` owner seam directly.
- 2026-05-11: Removed `Compiler::_compiled_spec_state_to_legacy_spec(...)`. Legacy spec-hash projection now asks `CompilerState` directly through `_call_compiler_state('compiled_spec_state_to_legacy_spec', ...)`, keeping compiled-spec projection ownership in the state owner without a compiler-local pass-through.
- 2026-05-11: Removed unused `Compiler::_compiled_descriptor_state_meta(...)`. Compiled descriptor metadata reads now remain solely in `CompilerState`; future descriptor metadata reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-11: Removed `Compiler::_is_compiled_descriptor_state(...)`. Final-descriptor assembly now asks `CompilerState` to validate compiled descriptor state shape directly through `_call_compiler_state('is_compiled_descriptor_state', ...)`, keeping descriptor-state predicates in the owner without a compiler-local pass-through.
- 2026-05-11: Removed `Compiler::_new_compiled_descriptor_state(...)`. Final-descriptor assembly now asks `CompilerState` to construct compiled descriptor state directly through `_call_compiler_state('new_compiled_descriptor_state', ...)`, keeping descriptor-state construction in the owner without a compiler-local pass-through.
- 2026-05-11: Removed `Compiler::_new_compiled_dependency_regex_state(...)`. Dependency-regex map enrichment now asks `CompilerState` to construct compiled dependency-regex state directly through `_call_compiler_state('new_compiled_dependency_regex_state', ...)`, keeping that state construction in the owner without a compiler-local pass-through.
- 2026-05-11: Removed `Compiler::_build_compiled_descriptor_meta(...)`. Final-descriptor assembly now asks `CompilerState` to build compiled-descriptor metadata directly through `_call_compiler_state('build_compiled_descriptor_meta', ...)`, keeping descriptor metadata ownership in the state owner without a compiler-local pass-through.
- 2026-05-11: Removed `Compiler::_record_compiled_spec_rule(...)`. Rule-table construction now records compiled rules by asking `CompilerState` directly through `_call_compiler_state('record_compiled_spec_rule', ...)`, keeping compiled-spec mutation ownership in the state owner without a compiler-local pass-through.
- 2026-05-10: Removed unused `Compiler::_compiled_descriptor_state_rules_by_label(...)`. Compiled descriptor rules-by-label access now remains solely in `CompilerState`; future compiler descriptor-state rule-map reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed unused `Compiler::_compiled_descriptor_state_dependency_regex_by_label(...)`. Compiled descriptor dependency-regex by-label access now remains solely in `CompilerState`; future compiler descriptor-state dependency-regex reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed unused `Compiler::_compiled_descriptor_state_dependency_regex_state(...)`. Compiled descriptor dependency-regex-state access now remains solely in `CompilerState`; future compiler descriptor-state dependency-regex reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed unused `Compiler::_compiled_descriptor_state_spec_state(...)`. Compiled descriptor spec-state access now remains solely in `CompilerState`; future compiler descriptor-state reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed unused `Compiler::_compiled_dependency_regex_state_to_dependency_regex_map(...)`. Compiled dependency-regex legacy-map projection now remains solely in `CompilerState`; future compiler projection needs should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed unused `Compiler::_compiled_dependency_regex_state_regex_by_label(...)`. Compiled dependency-regex by-label access now remains solely in `CompilerState`; future compiler reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed unused `Compiler::_is_compiled_dependency_regex_state(...)`. Compiled dependency-regex state shape checks now remain solely in `CompilerState`; future compiler validation should route through the explicit owner seam rather than adding local predicate mirrors.
- 2026-05-10: Removed unused `Compiler::_compiled_spec_state_meta(...)`. Compiled-spec metadata ownership now remains solely in `CompilerState`; future compiler metadata reads should route through the explicit owner seam rather than adding local mirrors.
- 2026-05-10: Removed `Compiler::_compiled_spec_state_redefined_rule_labels(...)`. Compiled-state trace reporting now asks the `CompilerState` owner directly for redefined rule labels.
- 2026-05-10: Removed `Compiler::_compiled_spec_state_definition_order(...)`. Compiled-state trace output now asks the `CompilerState` owner directly for definition order.
- 2026-05-10: Removed `Compiler::_compiled_spec_state_rule_rows(...)`. Dependency-regex map iteration now asks the `CompilerState` owner directly for compiled rule rows.
- 2026-05-10: Removed unused `Compiler::_compiled_spec_state_compiled_rule_order(...)`. Compiled-rule order access no longer has a compiler-local mirror of the `CompilerState` owner.
- 2026-05-10: Removed `Compiler::_compiled_spec_state_rule_info(...)`. Dependency-regex validation now retrieves referenced dependency-rule metadata directly from the `CompilerState` owner.
- 2026-05-10: Removed `Compiler::_compiled_spec_state_has_rule(...)`. Dependency-regex validation now asks the `CompilerState` owner directly whether referenced dependency rules exist.
- 2026-05-10: Removed unused `Compiler::_compiled_spec_state_rules_by_label(...)`. Rules-by-label map access now remains solely in the `CompilerState` owner instead of being mirrored by a compiler-local pass-through.
- 2026-05-10: Removed `Compiler::_compiled_spec_state_rule_count(...)`. Trace and parser-generation rule-count reads now ask the `CompilerState` owner directly through `_call_compiler_state(...)`.
- 2026-05-10: Removed `Compiler::_is_compiled_spec_state(...)`. The compiler pipeline now asks the `CompilerState` owner to validate compiled-spec state directly through `_call_compiler_state(...)`.
- 2026-05-10: Removed `Compiler::_new_compiled_spec_state(...)`. Rule-table build now asks the `CompilerState` owner for new compiled-spec state directly through `_call_compiler_state(...)`.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_dependency_re_result(...)`. The dependency-regex map validation boundary now builds invalid referenced dependency regex-list diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_dependency_rule_info_result(...)`. The dependency-regex map validation boundary now builds invalid referenced dependency-rule info diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_dependency_rule_missing(...)`. The dependency-regex map validation boundary now builds missing dependency-rule diagnostics directly.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_dependency_index_result(...)`. The dependency-regex map validation boundary now builds invalid dependency-index diagnostics directly while still sharing the remaining scalar value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_dependency_label_result(...)`. The dependency-regex map validation boundary now builds invalid dependency-label diagnostics directly while still sharing the remaining scalar value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_dependency_ref_result(...)`. The dependency-regex map validation boundary now builds invalid dependency-ref diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_rule_dependency_refs_result(...)`. The dependency-regex map validation boundary now builds invalid `dependency_refs` diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_rule_info_result(...)`. The dependency-regex map validation boundary now builds invalid rule-info diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_build_dependency_regex_map_spec_result(...)`. The compiled-spec input normalization callback now builds invalid input diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_final_descriptor_dependency_regex_result(...)`. The compiled dependency-regex normalization callback now builds invalid-output diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_final_descriptor_state_result(...)`. The final-descriptor validation boundary now builds invalid descriptor-state diagnostics directly while still sharing the remaining contract value-kind formatter.
- 2026-05-10: Removed `Compiler::_describe_compile_spec_entry_result(...)`. The rule-table tuple validation boundary now builds invalid compile-spec-entry diagnostics directly where it writes retained and structured failure detail.
- 2026-05-10: Removed `Compiler::_describe_build_compiled_rule_table_entry_result(...)`. The per-entry rule-table boundary now builds invalid parsed-entry diagnostics directly where it writes retained and structured failure detail.
- 2026-05-10: Removed `Compiler::_describe_build_compiled_rule_table_entries_result(...)`. The rule-table boundary now builds invalid parsed-entry-list diagnostics directly where it writes retained and structured failure detail.
- 2026-05-10: Removed `Compiler::_set_last_build_compiled_rule_table_failure_detail(...)`. Rule-table failure sites now write retained failure detail directly, and that lexical state is declared before the write sites so the later pipeline fallback reads the same retained diagnostic.
- 2026-05-10: Removed `Compiler::_clear_last_build_compiled_rule_table_failure_detail(...)`. Rule-table and pipeline boundaries now reset retained build-compiled-rule-table failure detail directly.
- 2026-05-09: Removed `Compiler::_get_last_build_compiled_rule_table_failure_detail(...)`. The pipeline fallback now reads the retained build-compiled-rule-table failure detail directly when constructing its structured diagnostic.
- 2026-05-09: Removed `Compiler::_bootstrap_parse_result_detail(...)`. Invalid bootstrap-parse result diagnostics now build their structured last-error detail directly at the failure boundary.
- 2026-05-09: Removed `Compiler::_describe_parser_input_ref(...)`. The top-level parser invocation now builds its invalid input-ref diagnostic directly where it writes the runtime-parser last-error payload.
- 2026-05-09: Removed `Compiler::_normalize_error_detail(...)`. Final-descriptor failure handling now trims trapped error detail directly where it writes the structured last-error payload.
- 2026-05-09: Removed `Compiler::_first_parsed_rule_label(...)`. Rule-table runtime-context preparation and final top-rule selection now read the first parsed rule label directly at their local decision points.
- 2026-05-09: Removed the small `Compiler::_reset_spec_content_pos(...)` wrapper. `run_get_pipeline(...)` now resets scalar input position directly at the validation and bootstrap-parse boundaries.
- 2026-05-09: Removed the one-use-shape `Compiler::_clear_active_dependency_regex_rule_label(...)` clearer wrapper. Dependency-regex map/build-final-descriptor boundaries now reset the active label directly around diagnostic attribution.
- 2026-05-09: Removed the one-use `Compiler::_get_active_dependency_regex_rule_label(...)` reader wrapper. Final-descriptor failure attribution now reads the active dependency-regex rule label directly where the diagnostic label is built.
- 2026-05-09: Removed the pass-through `Compiler::_set_runtime_ctx_last_error(...)` wrapper. Compiler-pipeline error boundaries now call `RuntimeContext::set_runtime_ctx_last_error_for_owner(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the `Compiler::_require_trace_pkg(...)` loader wrapper. Compiler trace helpers now load `LinkedSpec::Trace` directly through `OwnerDispatch::require_pkg(...)` inside their `$@`-preserving bodies.
- 2026-05-09: Removed the one-shot `Compiler::_require_validation_pkg(...)` wrapper. `run_get_pipeline(...)` now checks `Validation::validate_spec_content(...)` availability directly through `OwnerDispatch::require_pkg_cb(...)` during pipeline dependency setup.
- 2026-05-09: Removed the `SpecEntry::_require_trace_pkg(...)` loader wrapper. `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, and `_trace_log_dump(...)` now load `LinkedSpec::Trace` directly through `OwnerDispatch::require_pkg(...)` inside their `$@`-preserving bodies.
- 2026-05-09: Removed the one-shot `SpecEntry::_require_emit_context_pkg(...)` wrapper. `compile_spec_entry(...)` now checks `RuleIR::EmitContext::build_rule_ir_emit_context(...)` availability directly through `OwnerDispatch::require_pkg_cb(...)` before building the emit context.
- 2026-05-09: Removed the one-shot `SpecEntry::_require_rule_ir_pkg(...)` wrapper. `compile_spec_entry(...)` now checks `RuleIR::_collect_rule_ir(...)` availability directly through `OwnerDispatch::require_pkg_cb(...)` before entering RuleIR flow; the focused regression now inspects that live call path.
- 2026-05-09: Removed the one-shot `SpecEntry::_runtime_ctx_from_deps(...)` wrapper. `compile_spec_entry(...)` now reads the optional `runtime_ctx` dependency inline before setting up RuleIR flow.
- 2026-05-09: Removed the pass-through `SpecEntry::_set_runtime_ctx_last_error(...)` wrapper. Rule-handler compile/eval errors now call `RuntimeContext::set_runtime_ctx_last_error_for_owner(...)` through `_call_runtime_ctx(...)` directly with runtime-handler ownership.
- 2026-05-09: Removed the pass-through `ParserFactory::_set_runtime_ctx_last_error(...)` wrapper. Setup, validation, resolution, and load error writes now call `RuntimeContext::set_runtime_ctx_last_error_for_owner(...)` through `_call_runtime_ctx(...)` directly with parser-factory ownership.
- 2026-05-09: Removed the pass-through `ParserFactory::_set_runtime_ctx_last_error_unless_present(...)` wrapper. Compile-stage fallback writes now call `RuntimeContext::set_runtime_ctx_last_error_unless_present_for_owner(...)` through `_call_runtime_ctx(...)` directly with parser-factory ownership.
- 2026-05-09: Removed the one-shot `Runtime::_run_get_pipeline_cb(...)` wrapper. `run_get(...)` now resolves `Compiler::run_get_pipeline(...)` directly through `OwnerDispatch::require_pkg_cb(...)` inside the live orchestration body.
- 2026-05-09: Removed the pass-through `Runtime::_set_runtime_ctx_last_error_unless_present(...)` wrapper. Runtime-owner fallback writes now call `RuntimeContext::set_runtime_ctx_last_error_unless_present_for_owner(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the unused `Runtime::_set_runtime_ctx_last_error(...)` wrapper. Runtime-owner fallback writes are handled by the preserve-existing RuntimeContext helper, while source-lock coverage rejects reintroducing the dead direct setter.
- 2026-05-09: Removed the now-one-shot `Runtime::_build_runtime_context(...)` wrapper. `run_get(...)` now calls `RuntimeContext::prepare_runtime_ctx_for_run_get_option(...)` through `_call_runtime_ctx(...)` directly with owner metadata; the focused regression now inspects that live call path instead of preserving the pass-through.
- 2026-05-09: Removed the now-one-shot `ParserFactory::_set_runtime_ctx_spec_path(...)` wrapper. `run_get_parser(...)` now writes the resolved spec path by calling `RuntimeContext::set_runtime_ctx_spec_path(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the now-one-shot `ParserFactory::_prepare_runtime_ctx_for_get_parser(...)` wrapper. `run_get_parser(...)` now calls `RuntimeContext::prepare_runtime_ctx_for_get_parser(...)` through `_call_runtime_ctx(...)` directly with owner metadata and the requested spec name; the focused regression now inspects that live call path instead of preserving the pass-through.
- 2026-05-09: Removed the now-pass-through `SpecEntry::_emit_runtime_ctx_parser_source_line(...)` wrapper. Generated-handler parser-source emission now calls `RuntimeContext::emit_runtime_ctx_parser_source_line(...)` through `_call_runtime_ctx(...)` directly, matching the compiler-side parser-source emission cleanup.
- 2026-05-09: Removed the now-one-shot `SpecEntry::_set_runtime_ctx_top_rule(...)` wrapper. `compile_spec_entry(...)` now writes discovered top-rule state by calling `RuntimeContext::set_runtime_ctx_top_rule(...)` through `_call_runtime_ctx(...)` directly; the focused regression now inspects that live call path instead of preserving the pass-through.
- 2026-05-09: Removed the now-one-shot `Compiler::_prepare_runtime_ctx_for_build_compiled_rule_table(...)` wrapper. `build_compiled_rule_table(...)` now owns its small `top_rule` selection locally and calls `RuntimeContext::prepare_runtime_ctx_for_build_compiled_rule_table(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the now-pass-through `Compiler::_emit_runtime_ctx_parser_source_line(...)` wrapper. Compiler parser-source emission now calls `RuntimeContext::emit_runtime_ctx_parser_source_line(...)` through `_call_runtime_ctx(...)` directly, matching the earlier final parser-source flush cleanup.
- 2026-05-09: Removed the now-one-shot `Compiler::_clear_runtime_ctx_last_error(...)` wrapper. Compiler operation-boundary and parser-invocation stale-error clearing now call `RuntimeContext::clear_runtime_ctx_last_error(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the now-one-shot `Compiler::_get_runtime_ctx_top_rule(...)` wrapper. Parser-source emission, final descriptor trace output, parser-ready trace metadata, and parser-closure capture now read selected top-rule state by calling `RuntimeContext::get_runtime_ctx_top_rule(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the now-one-shot `Compiler::_set_runtime_ctx_top_rule(...)` wrapper. The compiler now writes selected top-rule state by calling `RuntimeContext::set_runtime_ctx_top_rule(...)` through `_call_runtime_ctx(...)` directly; the missing-top-rule parser regression stubs the shared owner helper directly instead of depending on a compiler-local pass-through.
- 2026-05-09: Removed the now-one-shot `Compiler::_has_runtime_ctx_last_error_type(...)` and `Compiler::_get_runtime_ctx_last_error_detail(...)` wrappers. The parser-invocation path now calls the shared `RuntimeContext` last-error read helpers directly when preserving deeper `runtime_handler` context.
- 2026-05-09: Removed the now-one-shot `Compiler::_flush_runtime_ctx_parser_source(...)` wrapper. The final parser-source output path now calls `RuntimeContext::flush_runtime_ctx_parser_source(...)` through `_call_runtime_ctx(...)` directly, leaving parser-source flushing ownership in `RuntimeContext` without a compiler-local pass-through.
- 2026-05-09: Removed the now-one-shot `Compiler::_compiler_rule_or_top_handler_source_label(...)` wrapper too. Rule-attributed compiler diagnostics now call `RuntimeContext::build_runtime_ctx_rule_or_top_handler_source_label(...)` through `_call_runtime_ctx(...)` directly, leaving `RuntimeContext` as the only owner for concrete-rule-versus-selected-top-rule label fallback.
- 2026-05-09: Removed the now-one-shot `Compiler::_compiler_top_rule_handler_source_label(...)` wrapper. Compiler top-rule-only fallback diagnostics now call `RuntimeContext::build_runtime_ctx_top_rule_handler_source_label(...)` through `_call_runtime_ctx(...)` directly.
- 2026-05-09: Removed the now-one-shot `ParserFactory::_parser_factory_handler_source_label(...)` wrapper. Parser-factory fallback diagnostics now call `RuntimeContext::build_runtime_ctx_top_rule_handler_source_label(...)` through `_call_runtime_ctx(...)` directly, matching the recent Runtime owner-label cleanup pattern.
- 2026-05-09: Removed the now-one-shot `Runtime::_runtime_owner_handler_source_label(...)` wrapper. Runtime-owner fallback diagnostics now call `RuntimeContext::build_runtime_ctx_top_rule_handler_source_label(...)` through `_call_runtime_ctx(...)` directly, matching the recent `SpecEntry` generated-handler label cleanup pattern.
- 2026-05-09: Added a durable documentation path-hygiene guard. `COMMIT.md` now states that tracked live docs and the public book must use repo-root-relative file references, and `t/phase0_regression.t` scans the live Markdown/book set for machine-local absolute path leaks such as user-home checkout paths, temporary checkout paths, Windows user-home paths, or the current checkout's absolute path.
- 2026-05-09: Removed the now-one-shot `SpecEntry::_generated_handler_source_label(...)` wrapper. Runtime handler construction now calls `RuntimeContext::build_rule_meta_handler_source_label(...)` through the existing `_call_runtime_ctx(...)` dispatch seam directly, keeping `SpecEntry` focused on handler construction rather than carrying a local label pass-through.
- 2026-05-09: Added `RuntimeContext::build_rule_meta_handler_source_label(...)` and routed `SpecEntry` generated-handler source labels through it. `SpecEntry` still owns runtime-handler construction, but the shared runtime-context owner now owns the detail of reading `selected_handler_variant` from rule metadata before forming `LinkedSpec::generated_handler:<rule>:<variant>`.
- 2026-05-09: Added `RuntimeContext::build_runtime_ctx_rule_or_top_handler_source_label(...)` and routed the compiler's rule-or-top generated-handler attribution through it. Compiler diagnostics that already know a concrete rule label still report that label, but fallback to selected `top_rule` now lives in the shared runtime-context owner instead of a compiler-local helper stack.
- 2026-05-09: Routed the compiler's parser-invocation top-rule `handler_source_label` through `RuntimeContext::build_runtime_ctx_top_rule_handler_source_label(...)` as well. The helper's optional `handler_variant` argument is now used on the runtime-parser boundary, so top-rule variant labels such as `LinkedSpec::generated_handler:Top:FORCED_OUTER_DIE` stay centralized without changing diagnostics output.
- 2026-05-09: Centralized top-rule generated-handler source labels in `LinkedSpec::RuntimeContext`. `build_runtime_ctx_top_rule_handler_source_label(...)` now owns the common "read active `top_rule`, return `LinkedSpec::generated_handler:<top_rule>`" operation, and `Runtime`, `ParserFactory`, and compiler top-rule diagnostics delegate to that helper instead of repeating the same local lookup/label-build sequence.
- 2026-05-09: Corrected the runtime-context boundary cleanup validation record to include the broader gate that was run before commit (`mdbook build`, `git diff --check`, and local CI). Keep `CHANGES.md` validation blocks aligned with both focused and broader checks whenever the broader gate is executed.
- 2026-05-09: Tightened shared `RuntimeContext` boundary hygiene for reused contexts. `prepare_runtime_ctx_for_run_get(...)` and `prepare_runtime_ctx_for_get_parser(...)` now clear stale `last_error` at the same preparation boundary that already refreshes `top_rule`, file identity, and parser-source capture state, matching the low-level `build_compiled_rule_table(...)` path. This keeps early runtime/parser-factory failures from preserving an unrelated structured payload from a prior call.
- 2026-05-09: Added `LIVE_ACHIEVEMENT_STATUS.md` as the live current-state tracker required by the batch workflow. `README.md` now includes it in the onboarding/document map, and `COMMIT.md` now makes it an explicit persistent doc to update alongside `CHANGES.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` whenever batch status changes. This closes the gap between the user's required live-doc list and the repo's documented commit workflow.
- 2026-05-09: Continued the Phase 1A/owner-dispatch cleanup in `LinkedSpec::ParserFactory`. The remaining `_require_value_dep(...)` one-shot validator is gone; `run_get_parser(...)` now validates required trace-level values (`dump_low` / `dump_medium`) inline in the same setup block that already validates trace, resolver, loader, and compile callbacks. This keeps the parser-factory setup seam direct instead of preserving a helper whose only job was to check two injected values once.
- 2026-05-09: Centralized stale file identity reset inside `LinkedSpec::RuntimeContext`. `clear_runtime_ctx_spec_identity(...)` now owns the paired `spec_name` / `spec_path` clear used by `run_get(...)`, `get_parser(...)`, and low-level `build_compiled_rule_table(...)` preparation while deliberately leaving `top_rule` alone so caller-selected entrypoint continuity remains a separate explicit step.
- 2026-05-09: Centralized parser-source capture reset inside `LinkedSpec::RuntimeContext`. `clear_runtime_ctx_parser_source_capture(...)` now owns the "clear chunks plus remove stale emit callback" operation that `run_get(...)`, `get_parser(...)`, and low-level `build_compiled_rule_table(...)` preparation need, while `prepare_runtime_ctx_for_run_get_pipeline(...)` still clears only chunks so an active parser-source emit callback installed by the runtime owner survives into compiler emission. The helper deliberately preserves `get_parser(...)`'s older no-new-storage behavior unless the caller asks to ensure chunk storage.
- 2026-05-09: Continued Phase 5 runtime-context hygiene on the low-level `build_compiled_rule_table(...)` path. `prepare_runtime_ctx_for_build_compiled_rule_table(...)` now clears stale parser-source chunks and drops stale `emit_parser_source_line` callbacks in addition to clearing stale `last_error`, file identity, and top-rule state. This keeps the standalone rule-table diagnostics surface aligned with the higher-level `run_get(...)`, `run_get_pipeline(...)`, and `get_parser(...)` preparation paths: a reused context should never make old generated parser source look like output from the current low-level rule-table call.
- 2026-04-30: Paused further `.plg` cleanup slices and picked up a Phase 5 runtime-context contract cleanup instead. `runtime_ctx_ref => \$ctx` now has explicit regression coverage for reuse after `$ctx` has already been populated with the shared context hashref; `RuntimeContext` names that Perl `REF` shape as a populated scalar slot, still accepts direct hashrefs, and rejects scalar slots already holding non-hash references with a public contract diagnostic instead of leaving the behavior implicit in Perl ref internals.
- 2026-04-30: Deleted the obsolete `plugin/tssio.plg` compatibility wrapper after `Timing::SetupHold::write_tssio(...)` became the concrete package-owned `tssio` report/action body. Phase0 now locks the wrapper absence while keeping the direct package-owner smoke for `tssio.lof`, per-path `sta_<n>.lof` sheets, banner/error strings, internal link formatting, and avoiding eager `PPlugin` loads.
- 2026-04-30: `specs/tclite.spec` is no longer deferred from phase0. The old literal command-substitution bracket regex now escapes `[` / `]`, the remaining fluent `.return_a` forms now use canonical helper payloads, and the descriptor reports zero raw fallback, zero unresolved helpers, and zero compatibility-surface counts across all `tclite` rules. Phase0 now includes `tclite.spec` in `compile_all_target_specs` and locks bracket plus empty-quote parser smokes.
- 2026-04-30: `specs/simenv.spec` is now fully compatibility-surface clean in descriptor migration metadata. The final cleanup added canonical `print_each(array(target), prefix, suffix?)` for array-backed debug output, migrated the remaining top/block/value/substitution return/exit/position/appender forms onto helpers, and fixed `BEGIN` / `END` block-name cleanup to use regex literals instead of string patterns. Phase0 locks zero compatibility metadata, the preferred source spelling, `print_each(...)` lowering, and the preserved nested begin/end AST smoke.
- 2026-04-30: `specs/vhdl.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `vhdl_file`, `architecture_statement_part`, `signal_decl_range`, `constant_declaration`, `variable_declaration`, `file_declaration`, `signal_declaration`, and `configuration_specification`; accumulator returns now use `array_copy(...)`, the signal range list-context return uses `flat_array(array(msi_lsi))`, and the repeated declaration/configuration comma-list payloads now use the new array-valued `split_tagged_records(...)` helper. Phase0 locks the helper lowering, zero compatibility metadata, source spelling, and preserved VHDL smoke behavior.
- 2026-04-30: `specs/ifelse.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `if`, `then`, `elsif`, `else`, `while`, and `while_then`; their flow-stop edges now use canonical `return_undef()` instead of bare `return`, preserving the debug parser's `undef` result and printed trace sequence. Phase0 now locks zero compatibility metadata, source spelling, and the runtime stdout smoke.
- 2026-04-30: `specs/ebnf.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `grammar_file`, `include_dir`, `include_file`, `semantic_annotation`, and `logging_annotation`; the top rule now uses helper-form child-call assignment, include readers use helper-form text cleanup plus split/trim/filter pipelines, semantic annotations use `capture_slice()` plus helper-form return payloads, and logging annotations replace the paragraph marker / `$IMATCH` mutation / bare arrayref return path with explicit rolling `start_capture_slice()` movement and a stored `entry_group(0)` name. Phase0 now locks zero compatibility metadata, source spelling, and preserved include / semantic / logging parser behavior.
- 2026-04-30: `specs/regdef.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `regdef_top`, `reg_def`, `reg_fld`, and `ob_cb`; the array payload rules now use helper-form `return(a(...))` / `I.return(...)` with `array_copy(a(...))` for accumulator snapshots, and `ob_cb` uses `return(1)`. Phase0 now locks zero compatibility metadata plus a runtime smoke for the nested register/field AST shape, closing the old bare-return path that could leave `flat_array(...)` as an unresolved runtime call.
- 2026-04-30: `specs/pplugin.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `pplugin_top`, `subdef`, and `curlyb`; the top flow now uses helper-form declarations, `next()`, child-call assignment, structured definedness flow, `return_undef()`, and `return(hash(flat_array(a(defs))))`, while `subdef` uses helper-form array return around the preserved plugin-body coderef and `curlyb` uses `return_undef()`. Phase0 locks zero compatibility metadata plus the preserved returned hash/coderef smoke behavior.
- 2026-04-30: `specs/hlink_substitution.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `substitute_top`, `substitute_statement2`, and `curlyb`; dangling/unmatched delimiter exits now use `exit_now(...)`, the bracket scalar-ref capture returns through helper-form `return(...)`, and the wrapped brace payload now uses `return(concat("{", capture_slice(), "}"))`. Phase0 locks zero compatibility metadata plus preserved parser smoke output.
- 2026-04-30: Added canonical `next()` helper support for action/lifecycle flow skips. It lowers to runtime `next`, contributes `NEXT` ActionIR metadata, and stays out of the compatibility-surface bucket while bare `next` remains compatibility syntax. `specs/tkgui.spec::{sub_gui_list,curlyb}` now use `next()`, `return_undef()`, and helper-form accumulator hash construction, so the full `tkgui` descriptor reports `compatibility_surface_rule_count == 0`; phase0 locks the helper contract plus preserved parser smoke output.
- 2026-04-29: `specs/portmap.spec` is now fully compatibility-surface clean in descriptor migration metadata. The final ready compatibility rules were the top `portmap` aggregate return and `concatenation`; `portmap` now uses structured helper flow over `count(a(portmap))` plus `scalar(...)` / `array_copy(...)`, `concatenation` now returns `a("?concat:", array_copy(a(concatenation)))`, and phase0 locks zero compatibility metadata plus the preserved singleton/multi/concat classification AST shapes.
- 2026-04-29: `specs/lib_reader.spec` is now fully compatibility-surface clean in descriptor migration metadata. The remaining ready compatibility rules were `lib_file` and `group`; `lib_file` now returns its accumulator through `return(array_copy(a(lib_file)))`, `group` now uses `exit_now(1)` for the syntax-error path, and phase0 locks zero compatibility-surface metadata plus the preserved grouped-attribute AST shape.
- 2026-04-29: `specs/Lispish.spec` is now fully compatibility-surface clean in descriptor migration metadata. The last ready compatibility rule was the top-level `Lispish` dispatcher: `return call(parenthesis)` now uses `return(call(parenthesis))`, and the syntax-error branch now uses `exit_now(1)` instead of bare `exit 1`; phase0 plus the public Lispish walkthrough lock the zero-compatibility summary and preferred source spelling.
- 2026-04-29: `exit_now(status)` is now a first-class canonical `EXIT` helper for fatal DSL flow; it lowers to host `exit` while avoiding compatibility-surface metadata. `specs/tablegrep.spec::{grep,group}` now use helper-form child-call captures, loop `retv` declaration, structured aggregate return flow, and `exit_now(...)`, so the full `tablegrep` descriptor reports `compatibility_surface_rule_count == 0`; phase0 locks the helper metadata plus preferred source spelling.
- 2026-04-29: `specs/operators_try.spec` is now fully compatibility-surface clean in descriptor migration metadata. The last ready compatibility rules were `group`, `function_call`, and `string`; their completion edges now use `return(1)` instead of bare `return 1`, and phase0 locks both per-rule metadata and source spelling.
- 2026-04-29: `specs/DT.spec` is now fully compatibility-surface clean in descriptor migration metadata. The last ready compatibility rules were `testcontrol`, `group`, and `inline_dt_definition`; their completion edges now use `return(1)` instead of the bare compatibility statement `return 1`, and phase0 locks both per-rule metadata and source spelling.
- 2026-04-29: `specs/BNF.spec` is now fully compatibility-surface clean in descriptor migration metadata. The last ready compatibility rule was `group`, where the completion edge now uses `return(1)` instead of the bare compatibility statement `return 1`; phase0 locks both the `BNF::group` metadata and the source spelling.
- 2026-04-29: `specs/ds_vhistory.spec` is now fully compatibility-surface clean in descriptor migration metadata. The last ready-but-legacy rule was `manifest`, which now uses `I.return(a("?manifest:"))` instead of `I { return ['?manifest:'] }`; phase0 locks both the manifest source spelling and `compatibility_surface_rule_count == 0` for the full `ds_vhistory` descriptor.
- 2026-04-29: `specs/ds_vhistory.spec::vhistory` no longer carries the last compatibility-surface assignment/push wrappers in its orchestration band. `$cur_object = call(object)` moved to `assign(s(cur_object), call(object))`, the child capture edges now use `push_value(a(capt), call(...))`, and phase0 locks `compatibility_surface_count == 0` plus the preferred source spellings while preserving zero raw/unresolved metadata.
- 2026-04-29: Added `input_slice(start, width)` as the explicit whole-input substring helper for rules that already hold absolute source boundaries. The helper now lowers through method values, assignment sources, return payloads, scan contracts, canonical `INPUT_SLICE_READ` metadata, and fluent `.return(...)`; `specs/sdce.spec::get_pinport` now uses `input_slice(match_end_pos(), call(oc_brace))` instead of raw `$LSPOS` `substr(...)`, and phase0 locks both the source spelling and zero raw/unresolved metadata.
- 2026-04-29: Fluent method-chain `.return(...)` now treats direct anonymous capture-reader payloads such as `capture_slice_len()` as canonical general-return payloads, matching block-form `return(capture_slice_len())` metadata instead of falling into legacy label-injected return rendering. `specs/sdce.spec::oc_brace` now uses `return(capture_slice_len())` instead of raw `$LSPOS - $IPOS - 1`, and phase0 locks both the fluent/block parity and the `sdce` helper spelling.
- 2026-04-29: Generalized `return(payload)` and fluent method-chain `.return(payload)` now both recognize immediate text/group helper payloads such as `entry_text()` as canonical general-return payloads instead of falling back to raw Perl or legacy label-injected `return(label, ...)` rendering. `specs/hlink_substitution.spec::raw_string` now spends `entry_text()` instead of raw `$IMATCH`, and phase0 locks that rule as raw-fallback-free/language-agnostic ActionIR-ready.
- 2026-04-29: Deleted the separate `_require_bootstrap_core_pkg(...)` loader wrapper from `BootstrapSpec.pm`. The meaningful local bootstrap grammar seam remains `build_bootstrap_spec(...)`, and that helper now resolves `BootstrapSpec::Core::build_bootstrap_spec(...)` directly through `LinkedSpec::OwnerDispatch::require_pkg_cb(...)` inside its `$@`-preserving body. Phase0 now locks that slimmer bootstrap facade shape.
- 2026-04-29: Deleted the separate `_require_data_dumper_pkg(...)` loader wrapper from `RuleIR.pm`. The meaningful local RuleIR dump-formatting seam remains `_dump_value(...)`, and that helper now lazy-loads `Data::Dumper` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside its `$@`-preserving body. Phase0 now locks that slimmer RuleIR dump helper shape.
- 2026-04-29: Deleted the separate `_require_data_dumper_pkg(...)` loader wrapper from `SpecEntry.pm`. The meaningful local spec-entry dump-formatting seam remains `_dump_value(...)`, and that helper now lazy-loads `Data::Dumper` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside its `$@`-preserving body. Phase0 now locks that slimmer spec-entry dump helper shape.
- 2026-04-29: Deleted the separate `_require_data_dumper_pkg(...)` loader wrapper from `Compiler.pm`. The meaningful local compiler dump-formatting seam remains `_dump_value(...)`, and that helper now lazy-loads `Data::Dumper` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside its `$@`-preserving body. Phase0 now locks that slimmer compiler dump helper shape.
- 2026-04-29: Deleted the separate `_require_linkedre_pkg(...)` loader wrapper from `Compiler.pm`. The meaningful local compiler regex seam remains `_ored_re(...)`, and that helper now lazy-loads `LinkedRE` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside its `$@`-preserving body. Phase0 now locks that slimmer compiler regex helper shape.
- 2026-04-29: Deleted the separate `_require_linkedre_pkg(...)` loader wrapper from `BootstrapSpec/Core.pm`. The meaningful local bootstrap regex seams remain `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and those helpers now lazy-load `LinkedRE` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside their `$@`-preserving bodies. Phase0 now locks that slimmer bootstrap-core helper shape.
- 2026-04-29: Deleted the single-use `_require_canonical_events_core_pkg(...)` loader wrapper from `ActionIR/CanonicalEvents.pm`. The meaningful local canonicalization seam remains `_canonicalize_helper_action_ir_event(...)`, and that helper now lazy-loads `CanonicalEvents::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside its `$@`-preserving delegation body. Phase0 now locks that slimmer canonical-events owner shape.
- 2026-04-29: Deleted the single-use `_require_statement_split_core_pkg(...)` loader wrapper from `ActionIR/StatementSplit.pm`. The meaningful local seam remains `_split_action_ir_statements(...)`, and that helper now lazy-loads `StatementSplit::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside its `$@`-preserving delegation body. Phase0 now locks that slimmer statement-split owner shape.
- 2026-04-29: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/MethodLowering.pm`. The meaningful local seams there remain `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, `_lower_return_general_statement(...)`, `_lower_assign_statement(...)`, `_lower_push_value_statement(...)`, `_lower_push_nonempty_statement(...)`, `_lower_regex_subst_statement(...)`, and `_lower_return_undef_statement(...)`, and those helper bodies now validate the required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer method-lowering owner shape.
- 2026-04-29: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/ControlFlow.pm`. The meaningful local seams there remain the control-flow lowering helper family from `_lower_control_flow_value_expr(...)` through `_lower_print_statement(...)`, and those helper bodies now validate the required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer control-flow owner shape.
- 2026-04-29: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/FlowExpr.pm`. The meaningful local seams there remain `_looks_like_array_value_expr(...)`, `_looks_like_hash_value_expr(...)`, `_lower_is_empty_expr(...)`, `_lower_defined_target_expr(...)`, and `_lower_flow_composite_expr(...)`, and those helper bodies now validate the required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer flow-expression owner shape.
- 2026-04-28: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/ValueExpr.pm`. The meaningful local seams there remain `_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_split_scalaref_path_segments(...)`, `_lower_scalaref_segment_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, and `_strip_literal_delimiters(...)`, and those helper bodies now validate the required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer value-expression owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/DeclareMethod.pm`. The meaningful local seams there remain `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`, `_lower_declare_initializer_expr(...)`, `_extract_declare_statement_from_method_expr(...)`, `_lower_declare_method_statement(...)`, and `_lower_assign_method_statement(...)`, and those helper bodies now validate the required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer declare-method owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `Compiler.pm`. The meaningful local seams there remain `_require_runtime_ctx(...)` and `run_get_pipeline(...)`, and those now validate the required runtime/pipeline dependencies inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer compiler source shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `PPlugin.pm`. The meaningful local seam there remains `_load_legacy_registry(...)`, and that loader now validates the required parser/discovery/registry callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer legacy-registry source shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ParserFactory.pm`. The meaningful local seam there remains `run_get_parser(...)`, and its setup block now validates the required trace/resolve/compile callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer parser-factory source shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `PluginBridge.pm`. The meaningful local seams there remain `_lookup_plugin_name(...)` and `_dispatch_plugin_name(...)`, and both now validate their required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer plugin-bridge source shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/ArrayPipeline.pm`. The meaningful local seams there remain `_normalize_split_delimiter_expr(...)` and `_build_array_pipeline_plan_from_expr(...)`, and both now validate their required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer array-pipeline owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/RewritePipeline.pm`. The meaningful local seams there remain `_build_action_rewrite_rules(...)` and `_rewrite_action_code_with_diagnostics(...)`, and both now validate their required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer rewrite-pipeline owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/Diagnostics.pm`. The meaningful local seams there remain `_find_unresolved_action_helpers(...)` and `_collect_action_helper_ir_nodes(...)`, and both now validate their required callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer diagnostics-owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/CanonicalEvents.pm`. The meaningful local seam there remains `_build_canonical_action_ir_events(...)`, and it now validates the required trim/split callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer canonical-events owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/StatementSplit.pm`. The meaningful local seam there remains `_split_action_ir_statements(...)`, and it now validates the required `trim_action_ir_value` callback inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer statement-split owner shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/ScannerCore.pm`. The meaningful local seam there remains `_scanner_rule_dep_bindings(...)`, and it now validates required scanner callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer scanner-core source shape.
- 2026-04-22: Deleted the separate local `_require_dep(...)` validator wrapper from `ActionIR/Contracts.pm`. The meaningful local seam there remains `_require_lowering_deps(...)`, and it now validates required lowering callbacks inline instead of bouncing through a second top-level helper subdef. Phase0 now locks that slimmer contracts-owner source shape.
- 2026-04-22: Deleted the dead local `_require_*_pkg(...)` owner-package shims from `RuleIR/EmitContext.pm`. The meaningful local seam there remains `_actionir_owner_package(...)`, and `_accumulate_action_rewrite_diagnostics(...)` now routes through `_call_actionir_owner('diagnostics', ...)` too, so the owner-key registry plus shared dispatcher are the only package/callback-loading seams left on that bridge. Phase0 now locks that slimmer emit-context owner-routing shape.
- 2026-04-22: Deleted the redundant local `_scanner_rule_binding_symbols(...)` helper from `ActionIR/ScannerCore.pm`. The meaningful local seams there are still the scanner-rule family registry plus `_scanner_dep_specs()`, and `_with_scanner_rule_family_deps(...)` now derives its rebinding symbols straight from that shared dep-spec table instead of maintaining a second hardwired symbol list in parallel. Phase0 now locks that slimmer scanner-core contract shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` `$@`-preservation wrapper from `Compiler.pm`. The meaningful local seams there are still `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)`, and those live helper bodies now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a wrapper subdef that only forwarded the same successful-eval-preservation behavior. Phase0 now locks that slimmer compiler trace/dump shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` `$@`-preservation wrapper from `SpecEntry.pm`. The meaningful local seams there are still `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_dump_value(...)`, and `_trace_runtime_mark_event(...)`, and those live helper bodies now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a wrapper subdef that only forwarded the same successful-eval-preservation behavior. Phase0 now locks that slimmer spec-entry trace/dump shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` `$@`-preservation wrapper from `RuleIR/EmitContext.pm`. The meaningful local seams there are still `_actionir_owner_default_deps(...)`, `_call_actionir_owner(...)`, `_call_actionir_owner_with_deps(...)`, `_accumulate_action_rewrite_diagnostics(...)`, and `rewrite_action_code_for_compat(...)`, and those live helper bodies now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a wrapper subdef that only forwarded the same successful-eval-preservation behavior. Phase0 now locks that slimmer emit-context dispatch shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` `$@`-preservation wrapper from `RuleIR.pm`. The meaningful local seams there are still `_trace_should_dump(...)`, `_trace_log_output(...)`, `_trace_decision(...)`, and `_dump_value(...)`, and those live helper bodies now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a wrapper subdef that only forwarded the same successful-eval-preservation behavior. Phase0 now locks that slimmer RuleIR helper shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` `$@`-preservation wrapper from `PluginBridge.pm`. The meaningful local seams there are still `_exec_legacy_plugin(...)`, `_get_legacy_plugin(...)`, `_lookup_plugin_name(...)`, and `_dispatch_plugin_name(...)`, and those live bodies now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a wrapper subdef that only forwarded the same successful-eval-preservation behavior. Phase0 now locks that slimmer plugin-bridge shape.
