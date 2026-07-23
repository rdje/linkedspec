---
id: julia-semantic-call-staged-projection-plan
title: Julia calls staging and generated projection has a typed additive authority plan
answers:
  - "which Julia authorities own semantic functions helpers calls and bindings"
  - "how many records and relations are in the Julia calls semantic target"
  - "what is the Julia semantic calls implementation split"
  - "does Julia CompiledSpec definition_order contain functions"
  - "how must Julia merge function and rule authored order"
  - "is Julia function body_ast typed ActionBlock authority"
  - "how must Julia validate staged function body_ast"
  - "are Julia ActionSourceSpan offsets global source offsets"
  - "how must Julia correlate action calls to exact authored source"
  - "how does Julia semantic call projection handle Unicode source positions"
  - "how must Julia resolve a user function before a helper"
  - "how must Julia infer semantic call and binding shapes"
  - "how must Julia map native staged function sidecars to neutral artifacts"
  - "which Julia generated plan is semantic authority"
  - "may Julia semantic call construction execute target or generated code"
  - "does the Julia calls plan add a public semantic query"
date: 2026-07-23
status: current exact private projection; composition parent closed without promotion
tags: [julia, semantic-introspection, actionir, calls, bindings, staging, generated-source, unicode]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.4.0-.10.6.4.3; capability_conformance/semantic_introspection_model.json snapshot calls; docs/decisions/0050-semantic-introspection-staged-artifact-records.md; julia/src/semantic/SemanticIndex.jl; julia/src/semantic/SemanticCompilationOutcome.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/semantic/SemanticCallProjection.jl; julia/test/semantic_index_call_core_test.jl; julia/test/semantic_index_call_staged_test.jl; julia/src/spec/Ast.jl; julia/src/action/ActionAst.jl; julia/src/action/ActionParser.jl; julia/src/action/ActionContracts.jl; julia/src/action/FunctionRegistry.jl; julia/src/parser/UserFunctionDefinitionParser.jl; julia/src/parser/StagedParserRegistry.jl; julia/src/compiler/CompiledSpec.jl; julia/src/source/SourceEmitter.jl; docs/knowledge/semantic-introspection-staged-artifact-schema.md; docs/knowledge/semantic-introspection-generated-plan-authority.md; docs/knowledge/perl-semantic-call-staged-projection.md; docs/knowledge/rust-semantic-call-staged-projection.md; docs/knowledge/dart-semantic-introspection-authority-map.md
reverify: "python3 tools/check_semantic_introspection_contract.py; JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-call-staged-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia -e 'using LinkedSpecJulia, Test, JSON3; include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\"); include(\"julia/test/semantic_index_call_staged_test.jl\")'; rg -n '_semantic_call_add_staged_artifacts|_semantic_call_validate_staged_authority|_semantic_call_add_generated_plan' julia/src/semantic/SemanticCallProjection.jl julia/test/semantic_index_call_staged_test.jl"
---

Behavior-free leaf `.10.6.4.0` freezes an additive private projection over Julia's already-closed static semantic
foundation. The neutral `calls` snapshot for fixture `calls_and_staging` is compiled, text-ceiling, and explicitly
observation-free. It contains exactly 22 records and 25 relations. The existing Julia static projection already
contributes six records and six relations; the typed non-staged core is exactly 18/16, and staged/generated
completion adds four records and nine relations.

The complete record inventory is one spec, one source, two rules, one regex slot, one edge, one function, three
helpers, one binding, four calls, three staged artifacts, one generated artifact, one decision, and two explanation
steps. The staged/generated completion owns the three function `contains` relations, five directed staging-chain
relations, and one `generated_as` relation. Those roles and directions are semantic contract, not an adapter choice.

Julia already retains every necessary authority without executing caller target code:

- the private accepted source/map owns canonical strict UTF-8 bytes, Unicode-scalar boundaries, exact excerpts,
  occurrences, and content digest;
- `_semantic_authored_definition_order` owns merged function/rule authored order, while
  `CompiledSpec.definition_order` and `compiled_rule_order` remain rule-only;
- `UserFunctionRegistry` owns the accepted function definition, parameters and optional callable signature;
- `parse_action_block(body_source)` produces typed function-body `ActionBlock`, and the projector must require its
  JSON form to equal the staged registry's retained `body_ast` map before resolving contracts;
- compiled edge `action_payload.action_ast` owns typed action calls and bindings directly;
- `resolve_action_block_contracts` plus the registry owns accepted call identity and arity; and
- the retained `SemanticGeneratedPlanInput` owns the generated-v2 contract, format, caller logical identity, and
  ordered rule-family rows.

The staged `FunctionDefinition.body_ast` is a plain JSON-compatible map, not a typed `ActionBlock`. It is therefore
an integrity cross-check, never the semantic wire schema or sole call authority. The adapter reparses only the
already-retained function-body payload as compiler-side ActionIR work, proves equality to the staged result,
resolves its typed contracts, and projects from that typed result. This is not a second `.spec` parse and not target
execution.

Source correlation cannot add local action offsets to an authored member start. `ActionSourceSpan` counts decoded
Unicode scalars local to normalized action text, and compiled edge payloads remove authored indentation. Function
payload jobs retain a global decoded-scalar body range, so the exact function shell is the unique authored shell
occurrence enclosing that range. Calls then map through an occurrence-safe balanced scanner over the bounded raw
shell or edge, driven by typed outer-before-inner traversal. All nine distinct neutral source ranges already
reproduce exactly through the existing source map; the function binding and normalize call deliberately share one
range under different record keys. Interleaved multibyte source proves `é` changes UTF-8 byte width without
changing Unicode-scalar column semantics and does not turn a function shell into a rule member.

Traversal is deterministic: merge definitions by exact authored source start, retain statement order, visit an
outer call before nested argument calls, and assign global call order across owners while call ids remain local to
their owner. A function-surface `return` is syntax and only its argument calls are records; action-edge `return` is
the governed helper. Resolve an exact registered user-function name before the narrow neutral helper table. For
this fixture that table contains only `trim`, `match_text`, and `return`, with their exact signatures, effects, and
return shapes. Shape inference is a conservative fixed point over typed literals, current bindings, registered
function returns, and those helper contracts; any unsupported case remains `unknown`.

Fixed-arity v1 function definitions use parameters/arity when their native signature is absent. A future variadic
`CallableSignature` maps positional parameters, optional rest parameter, minimum arity, and unbounded maximum
without inventing a fixed bound. Function/helper identifiers retain their existing narrower grammar; Unicode-17
rule-label widening is a separate identity boundary.

Native function staging is deliberately normalized rather than copied. Julia retains
`function_definition`/`function_body`, parent path `functions/0/body_source`, parser `actionir-body.spec`, top rule
`action_block`, result policy `replace_field/body_ast`, failure `fail`, and decoded-scalar payload span. Neutral v1
maps those to separate payload/action-source/string, parse-job/action-program/unknown, and
result/action-program/unknown records with parent `function:normalize`, parser `linkedspec-action-v1`, top
`FunctionBody`, result `typed_action_program`, failure `compile_diagnostic`, and succeeded status only after the
typed equality/contract checks pass. Payload source, job maps, JSON body AST, and typed ActionIR stay private.

Generated provenance consumes the retained plan, validates contract/format/logical identity and every label
against compiled rule order, and selects the unique entry row. The calls fixture's exact family is `default`; the
adapter must not infer `and_acode` or invoke an emitter. Only the neutral handler-plan artifact leaves the private
owner, never generated Julia implementation text.

Implementation is dependency-ordered. `.10.6.4.1` adds one private call projector and exact typed core proof at
18 records / 16 relations. `.10.6.4.2` extends that same owner with staged normalization and selected generated
plan to exact 22/25. `.10.6.4.3` recomposes the committed foundation/static/call suites and closes the parent with
no replacement implementation or test. The extension stays behind the existing underscore-only proof seam; no
public record accessor/query, runtime observation, trace dependency, rollout movement, or native admission belongs
to `.10.6.4`.

Completion leaf `.10.6.4.2` now implements the second step in that same owner. It requires the native payload map
and typed `StagedParseJob` to agree with the accepted function name, body, exact source span, parent path,
parameters or variadic signature, parser/top-rule request, result-field stitch, failure policy, and retained body
AST. Only then does it emit the three fixed neutral records and their exact eight staged relations. Native payload,
job, and body-AST values never become semantic facts.

The retained generated plan must match `GENERATED_SOURCE_CONTRACT`, `GENERATED_SOURCE_FORMAT`, caller logical
identity, complete compiled label order, and exactly one selected entry row. Projection retains only that row's
family and one `generated_as` relation. The plan builder, emitter, generated loader/executor, runtime, and trace are
not invoked. Exact complete equality is 22 records / 25 relations / ten source references; corrupt sidecars and
plan contract/identity/order/selection reject before retention. New proof is 62 assertions, six-suite composition
is 530, and complete Julia is 8,072/primary/105. Full 5x2x66 primary, ten Unicode legs, unchanged ledgers, and
canonical Rust 76.95s + Dart 1/1 + primary 66x2 + Phase 0 1,031/622s pass. `.10.6.4.3` is the next no-change
composition owner.

Typed-core leaf `.10.6.4.1` now implements the first step in `SemanticCallProjection.jl`. The existing private
static extension invokes it before canonicalization and freeze, so the retained semantic graph remains one
immutable owner. The projector merges authored function/rule order, reparses each retained function body as typed
ActionIR and requires exact JSON equality with the staged `body_ast`, resolves contracts, correlates typed calls
through a bounded occurrence-safe source scanner, then materializes function/helper/call/binding records and
relations. The scanner recognizes escaped strings and context-valid regex literals, so call-shaped text inside
either cannot consume a typed call's occurrence. The exact non-staged target is 18 records / 16 relations.

Call traversal is outer-before-inner with owner-local ids and global authored order. Resolution is user function
before the narrow `trim`/`match_text`/`return` helper table; signatures cover fixed and variadic shapes; a
conservative fixed point derives binding/call shapes without inventing unsupported types. New proof is 79
assertions, five-suite composition is 468, and complete Julia is 8,010/primary/105. Full 5x2x66 primary, all ten
Unicode legs, unchanged governance ledgers, canonical local CI, mdBook/KM 685/5,252, and exact 1,618,660-KiB
cleanup preserving 517 Pgen artifacts pass. No staged/generated artifact, public query/accessor, execution
observation, trace dependency, or admission movement is part of the core leaf; the separate completion above
preserves that boundary.

Plan signoff passes committed focused 389, complete Julia 7,931/primary/105, full primary 5x2x66, all ten Unicode
manifest legs, and every unchanged governance ledger. Canonical local CI passes all four doctrines, Rust semantic
admission in 77.84 seconds, Dart admission 1/1, reference primary 66x2, and Phase 0 1,031/1,031 in 625 seconds.
mdBook and Knowledge Map 684/5,231 pass. Exact safe cleanup reclaims about 1.56 GB while preserving 517 Pgen issue
artifacts. No production, test, fixture, public API, query, generated format, trace, observation, or ledger behavior
changes; `.10.6.4.1` becomes eligible only after the plan commit is clean.

Composition closeout `.10.6.4.3` now reruns all six committed semantic suites at focused 530 and the complete Julia,
5x2x66 primary, ten-leg Unicode, governance, and canonical gates. Canonical Rust semantic admission passes in
77.68 seconds, Dart is 1/1, reference primary is 66x2, and Phase 0 is 1,031/622s. Parent `.10.6.4` is closed without
a second projector, replacement test, public query, runtime observation, format change, rollout, or admission.
Behavior-free query authority audit `.10.6.5.0` is the next dependency-eligible owner after the clean commit.

See [[julia-semantic-introspection-authority-map]], [[semantic-introspection-neutral-contract]],
[[semantic-introspection-staged-artifact-schema]], [[semantic-introspection-generated-plan-authority]],
[[julia-semantic-static-projection-plan]], [[rust-semantic-call-staged-projection]], and
[[dart-semantic-introspection-authority-map]].
