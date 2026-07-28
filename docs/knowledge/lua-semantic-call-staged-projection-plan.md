---
id: lua-semantic-call-staged-projection-plan
title: Lua typed semantic call core implements the exact dual-ABI 18/16 projection
answers:
  - "which Lua authorities own semantic functions helpers calls and bindings"
  - "how many records and relations are in the Lua calls semantic target"
  - "what is the Lua semantic calls implementation split"
  - "does Lua CompiledSpec definition_order contain functions"
  - "how must Lua merge function and rule authored order"
  - "is Lua staged function body_ast typed ActionIR authority"
  - "how must Lua validate staged function body_ast"
  - "are Lua ActionIR offsets global source offsets"
  - "how must Lua correlate action calls to exact authored source"
  - "how does Lua semantic call projection handle Unicode source positions"
  - "how must Lua resolve a user function before a helper"
  - "how must Lua infer semantic call and binding shapes"
  - "how must Lua map native staged function sidecars to neutral artifacts"
  - "which Lua generated plan is semantic authority"
  - "may Lua semantic call construction execute target or generated code"
  - "does the Lua calls plan add a public semantic query"
  - "where is the Lua typed semantic call core implemented and tested"
date: 2026-07-27
status: current private typed core implemented at exact 18 records and 16 relations; staged completion pending
tags: [lua, luajit, semantic-introspection, actionir, calls, bindings, staging, generated-source, unicode]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.7.4.0-.1; capability_conformance/semantic_introspection_model.json snapshot calls; docs/decisions/0050-semantic-introspection-staged-artifact-records.md; lua/src/linkedspec/semantic_static_projection.lua; lua/test/semantic_index_call_core_test.lua; lua/src/linkedspec/semantic_compilation_outcome.lua; lua/src/linkedspec/spec_parser.lua; lua/src/linkedspec/action_ast.lua; lua/src/linkedspec/action_parser.lua; lua/src/linkedspec/action_contracts.lua; lua/src/linkedspec/user_function_registry.lua; lua/src/linkedspec/staged_parser.lua; lua/src/linkedspec/compiled_spec.lua; lua/src/linkedspec/generated_source.lua; docs/knowledge/semantic-introspection-staged-artifact-schema.md; docs/knowledge/semantic-introspection-generated-plan-authority.md
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; for runtime in puc luajit; do bash tools/run_lua_project_data.sh \"$runtime\" lua/test/semantic_index_call_core_test.lua; done; rg -n 'authored_definitions|body_ast|generated_plan|compiled_rule_order' lua/src/linkedspec lua/test"
---

Behavior-free leaf `.10.7.4.0` freezes an additive private projection over Lua's closed static semantic foundation.
The neutral `calls` snapshot for fixture `calls_and_staging` is compiled, text-ceiling, and observation-free. It
contains exactly 22 records and 25 relations. The existing Lua static projection contributes six records and six
relations; the typed non-staged core is exactly 18/16; staged/generated completion adds four records and nine
relations.

The record inventory is one spec, one source, two rules, one regex slot, one edge, one function, three helpers,
one binding, four calls, three staged artifacts, one generated artifact, one decision, and two explanation steps.
Completion owns the three function `contains` relations, five directed staging-chain relations, and one
`generated_as` relation. Those roles and directions come from the neutral contract, not Lua-native table shapes.

Lua already retains every necessary authority without executing caller target code:

- the private accepted source/map owns strict UTF-8 bytes, decoded-scalar boundaries, exact excerpts,
  occurrences, and the content digest;
- `semantic_compilation_outcome.authored_definitions` owns merged function/rule authored order, while both
  `CompiledSpec.definition_order` and `compiled_rule_order` deliberately remain rule-only;
- the accepted function registry owns the definition, parameters, optional callable signature, exact shell/body
  source, staged payload/job/result, and the body job's global decoded-scalar range;
- reparsing only the retained exact `body_source` produces typed function-body ActionIR, whose JSON form must
  equal the retained staged `body_ast` before registry-aware contract resolution;
- compiled edge `action_payload.action_ast` and retained contracts own typed edge calls and bindings directly;
  and
- retained immutable `SemanticGeneratedPlanInput` owns the generated-v2 contract, format, caller logical
  identity, and ordered rule-family rows.

The staged `body_ast` is a plain JSON-compatible Lua table: it has no ActionIR `node_type`. It is an integrity
witness, never the semantic wire schema or sole call authority. The projector reparses only the already-retained
function-body payload as compiler-side ActionIR work, proves JSON equality to staged output, resolves its typed
contracts with the accepted registry, and projects from that result. It does not parse the `.spec` again.

Source correlation cannot add local action offsets to an authored member start. Function ActionIR spans count
decoded Unicode scalars in the exact retained body payload, so the staged job's global scalar range maps them
through the existing source map after equality is proved. Compiled edge ActionIR instead counts scalars in
normalized code with authored indentation removed. In the neutral fixture, edge range 52..122 plus local
`normalize` span 9..32 would incorrectly produce 61..84; the authored call is 78..101. Edge calls therefore use
typed outer-before-inner traversal plus a bounded, occurrence-safe scanner over the exact authored member that
skips strings, regex literals, comments, and balanced nested delimiters.

All nine distinct neutral ranges reproduce exactly: function 0..43, `trim` 29..40, `Top` 45..50, edge 52..122,
`normalize` 78..101, `match_text` 88..100, `return` 105..119, `Done` 124..129, and the `Done` regex 131..134. The
binding and normalize-call records deliberately share the normalize range under different keys. Function-surface
`return` is syntax, so only nested `trim` is a call record; edge-surface `return` is the governed helper call.

An interleaved multibyte probe preserves authored `Top`, `normalize`, `Done` at lines 1/4/6 while compiled order
stays `Top`, `Done`. Its body is scalar 68..87 but byte 69..89; local `trim("é")` is scalar 8..17 and staged
equality remains exact. The existing source map is the sole byte/scalar/line/column conversion authority.

Traversal is deterministic: merge definitions by authored source start, retain statement order, visit an outer
call before nested argument calls, and assign global call order across owners while ids remain owner-local.
Registered user functions resolve before the deliberately narrow `trim`, `match_text`, and `return` helper table.
Conservative fixed-point shape inference uses typed literals, parameter/binding state, registered function return
shapes, and those helper contracts; unsupported calls and cycles remain `unknown`. Fixed-v1 functions derive their
bounded signatures from accepted params/arity. Native variadic-v2 `CallableSignature` owns positional/rest,
minimum, and unbounded maximum facts without an invented fixed maximum.

Assignment targets create mutable action bindings from right-hand-side shape; typed variable occurrences own
reads/writes. No sample value, target execution, trace detail, descriptor, implementation source, loader, emitter,
or host identity may contribute semantic meaning.

Native staging is deliberately normalized. Lua retains `function_definition` / `function_body`, parent path
`functions/0/body_source`, parser `actionir-body.spec`, top rule `action_block`, result policy
`replace_field/body_ast`, failure policy `fail`, and a decoded-scalar payload span. Neutral v1 maps these to
payload/action-source/string, job/action-program/unknown, and result/action-program/unknown records with parent
`function:normalize`, parser `linkedspec-action-v1`, top `FunctionBody`, result `typed_action_program`, failure
`compile_diagnostic`, and succeeded status only after typed equality and successful contract resolution. Native
payload/job tables, source maps, staged JSON AST, and typed ActionIR remain private.

Generated provenance consumes the retained plan, validates generated-source-v2 contract/format/logical identity
and every row against compiled rule order, and selects the unique entry row. The fixture's ordered rows are
`Top/default`, `Done/default`; only the selected neutral handler-plan artifact leaves the owner. The projector must
not call the plan builder or emitter, infer `and_acode`, execute native/generated code, or retain generated Lua
implementation text.

Implementation stays in the existing private `semantic_static_projection.lua` owner and is dependency-ordered:

- `.10.7.4.1` implements typed function/helper/call/binding/decision projection, merged definition order, exact 18/16,
  source and Unicode correlation, function-before-helper resolution, fixed/rest signatures, conservative shapes,
  recursive freeze/detachment, host denial, and focused dual-ABI core proof;
- `.10.7.4.2` extends the same owner with normalized payload/job/result and selected retained plan, exact 22/25,
  staged/plan corruption rejection, privacy, and no-execution proof; and
- `.10.7.4.3` adds no replacement implementation or test. It recomposes the committed source, outcome, static,
  core-call, and staged/generated suites and closes the parent.

The `.1` implementation deep-equals the governed non-staged snapshot at exactly 18 records, 16 relations, and ten
private source refs. Its global typed preorder is function `trim`, edge `normalize`, nested `match_text`, then edge
`return`; helper ids remain first-use ordered. The same owner updates function, binding, edge, and rule shapes,
emits the one user-function resolution decision and two explanation steps, and freezes the complete extended tree
before the existing materializer returns a fresh detached copy. Focused proof is 128 assertions on both PUC Lua and
LuaJIT, including reordered Unicode definitions, different byte/scalar widths, duplicate nested occurrences,
quoted and regex call-like text, variadic rest signatures, and host/privacy denial.

The extension remains behind the existing opaque-index test materializer. It adds no public record accessor/query,
runtime observation, trace dependency, generated-format change, rollout movement, or native admission. Portable
output excludes caller paths, host/metatable identity, source/sidecar maps, AST/ActionIR, compiled regex,
descriptors, implementation source, loaders/executors, sinks, environment, clock, and randomness.

Implementation proof preserves source/outcome/graph/remaining at 379/122/64/122 per ABI and passes complete Lua
package `1..177`, PUC primary 66x2, corpus 105, primary 5x2x66, Unicode 10/10, and all six unchanged ledgers. It
also passes canonical Rust admission 1/1 in 77.99s, Dart 1/1, Julia 416/416 in 27.4s, containment/moved-root proof,
reference primary 66x2, and Phase 0 1,031/1,031 in 622s; Knowledge Map generation is 724 facts / 5,767 keys. It adds
no public API/query, runtime observation, staged/generated role, generated-format change, rollout movement, or
native admission. Staged/generated completion `.10.7.4.2` is the next owner after the clean `.1` commit.

See [[lua-semantic-introspection-authority-map]], [[lua-semantic-source-outcome-plan]],
[[lua-semantic-static-projection-plan]], [[semantic-introspection-neutral-contract]],
[[semantic-introspection-staged-artifact-schema]], [[semantic-introspection-generated-plan-authority]],
[[julia-semantic-call-staged-projection-plan]], and [[rust-semantic-call-staged-projection]].
