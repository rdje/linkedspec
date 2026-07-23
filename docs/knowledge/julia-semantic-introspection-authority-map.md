---
id: julia-semantic-introspection-authority-map
title: Julia semantic introspection must compose typed native authorities behind a new opaque source map
answers:
  - "which Julia authorities can build the semantic index"
  - "does Julia already expose semantic_index or semantic_query"
  - "does Julia CompiledSpec definition_order include functions"
  - "where do Julia semantic source spans come from"
  - "are Julia ActionSourceSpan offsets global source offsets"
  - "can a Julia String contain malformed UTF-8"
  - "does Julia parse_spec reject malformed text at an encoding boundary"
  - "what Julia failure does failed.spec report"
  - "how must Julia normalize failed.spec for semantic introspection"
  - "does Julia already have a semantic observation sink"
  - "where can Julia semantic runtime slot events be captured"
  - "where can Julia semantic final result events be captured"
  - "can Julia trace text be used as semantic observations"
  - "which Julia generated routes must propagate semantic observations"
  - "how must Julia preserve semantic observer exception identity"
  - "can Julia LoadedSpec identity enter semantic responses"
  - "can Julia outward descriptors be the semantic wire schema"
  - "are Julia semantic public values automatically immutable"
  - "must Julia semantic raw query validation reject Bool as an integer"
  - "what are the Julia semantic introspection implementation leaves"
  - "what Julia semantic source and outcome API is frozen"
  - "does Julia compiled state JSON alias CompiledSpec"
  - "does Julia descriptor JSON alias CompiledSpec"
  - "can Julia semantic construction use descriptor JSON safely"
  - "how does Julia semantic_index accept text and UTF-8 bytes"
  - "what source detail ceilings does Julia semantic_index use"
  - "which Julia semantic foundation failures throw and which become outcomes"
  - "does Julia semantic foundation construction execute target actions"
  - "does Julia semantic foundation construction use SpecLoader"
  - "how is Julia semantic authored definition order merged"
date: 2026-07-22
status: current
tags: [julia, semantic-introspection, source-map, diagnostics, runtime, generated-source, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.0 and .10.6.2.0; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/decisions/0050-semantic-introspection-staged-artifact-records.md; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/semantic_introspection_model.json; julia/src/spec/Ast.jl; julia/src/spec/Parser.jl; julia/src/spec/Validator.jl; julia/src/parser/StagedParserRegistry.jl; julia/src/parser/UserFunctionDefinitionParser.jl; julia/src/compiler/CompiledSpec.jl; julia/src/action/ActionAst.jl; julia/src/action/ActionParser.jl; julia/src/action/ActionContracts.jl; julia/src/action/FunctionRegistry.jl; julia/src/io/SpecLoader.jl; julia/src/runtime/Interpreter.jl; julia/src/source/SourceEmitter.jl; julia/src/trace/Trace.jl
reverify: "python3 tools/check_semantic_introspection_contract.py; rg -n 'semantic_index|semantic_query|SemanticIndex|SemanticQuery|definition_order|ActionSourceSpan|regex_slot_selected|diagnostic_output_sink|to_descriptor_json' julia/src; JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia -e 'using LinkedSpecJulia; s=read(\"capability_conformance/semantic_introspection/calls_and_staging.spec\",String); x=parse_spec_with_staged_user_function_definitions(s); validate_spec(x); c=compile_spec(x;validate_source=false); println(c.definition_order); println([e.definition.name for e in c.function_registry.entries]); println([(r.label,r.family) for r in build_generated_rule_plan(c)]); d=to_descriptor_json(c); d[\"meta\"][\"compiled_rule_order\"][1]=\"mutated\"; println(c.compiled_rule_order)'"
---

Julia has no semantic-index implementation or partial public semantic vocabulary yet. Its exported API contains no
`semantic_index`, `SemanticIndex`, `semantic_query`, `SemanticQuery`, capabilities type, or typed runtime semantic
observation. The adapter must therefore be a new opaque native owner rather than a renamed descriptor or a query
wrapper over public dictionaries.

The reusable meaning is already present, but distributed across typed layers:

- `SpecFile`, rules, function shells, body elements, and staged payload/job/result sidecars own authored structure.
- `CompiledSpec`, `CompiledRule`, typed action nodes/contracts, the function registry, selected entry, generated
  rule-family plan, and emitted-source plan own accepted and executable structure.
- `SpecPortableDiagnostic` owns cloneable compilation evidence. The neutral `failed.spec` currently produces
  native code `bare_edge_target_undefined`, stage `normalize_edges`, and fields `rule_label=Top` / `target=Missing`;
  semantic projection must retain that native foundation while normalizing the v1 record to
  `unknown_rule_reference` at neutral stage `compile`.
- `RuntimeParseResult` owns final output and Unicode-scalar cursor position. The runtime's accepted regex-slot seam
  owns selected rule/slot identity before effects are applied.

No one native span is the neutral source model. Ordinary `SourceSpan` is line-only. `StagedSourceSpan` has scalar
start/stop plus line bounds. `ActionSourceSpan` uses Unicode-scalar offsets local to normalized action text because
`_action_len` counts collected characters; those offsets are neither global-source nor UTF-8-byte coordinates.
The adapter therefore needs one private copied accepted-source map that correlates these authorities to canonical
zero-based half-open UTF-8 byte and Unicode-scalar positions.

Julia's type system does not supply the strict constructor boundary automatically. A `String` can contain invalid
UTF-8 bytes. Exact malformed sequences `ff`, `c3 28`, `e2 82`, and `ed a0 80` all have `isvalid == false`, but direct
`parse_spec` fails inconsistently as `InvalidCharError` or `SpecParseException`, while staged parsing reports
`UserFunctionDefinitionParserException`. Direct `Vector{UInt8}` input has no parser method. Semantic construction
must therefore copy either valid `AbstractString` or `AbstractVector{UInt8}` input, reject invalid text/bytes before
any character iteration or language parsing, and retain only caller logical identity. `SpecLoader` checks decoded
file bytes but also retains requested/resolved host paths and origin; it cannot be a constructor or identity owner.

`CompiledSpec.definition_order` is rule order, not complete definition order: the calls fixture retains `Top` and
`Done` there while its function shell lives in separate typed staged/function state. Neutral definition order must
merge authored rule and function authorities. The outward descriptor likewise contains a Julia-native projection;
it is compatibility state, not the portable record/relation schema.

Runtime observation must be a separate optional invocation-local typed sink. Existing high trace emits the string
topic `julia_runtime:regex_slot_selected`, but trace detail is not typed semantic evidence and there is no final
result trace topic. Capture belongs directly at the accepted-slot seam and only after successful final
`RuntimeParseResult` construction. Direct, loaded, reconstructed, generated-plan, emitted, and traced routes must
forward the same sink without changing result/cursor/trace/diagnostic behavior. Generated execution currently
translates broad failures to `GeneratedSourceException`; a semantic-channel-specific wrapper/pass-through must
preserve the caller callback's exact exception object and stack, independently of the existing diagnostic sink.

Public semantic values also require deliberate detachment. Julia structs are immutable bindings but can contain
mutable `Vector` and `Dict` members, so returned capabilities, records, relations, pages, explanations, and errors
must be deep-copied or otherwise immutable. Raw-neutral validation must explicitly reject `Bool` for integer
fields because `Bool <: Integer` in Julia; the neutral `numeric_boolean` boundary cannot be inherited from a type
test alone.

Behavior-free foundation planning `.10.6.2.0` proved that detachment is mandatory at the first boundary, not only
at query time. `to_json(compiled)["definition_order"]` and
`to_descriptor_json(compiled)["meta"]["compiled_rule_order"]` return the live `CompiledSpec` vectors: changing the
supposed projection changes compiler state. The semantic foundation must not consume either JSON surface. It keeps
typed staged/compiled authorities privately and returns new structs, tuples, or recursively detached maps; its
display must omit the logical name, source, paths, and host objects.

The frozen Julia foundation surface is `semantic_index(source, options)` plus keyword convenience. It accepts copied
valid text or strict UTF-8 bytes with `SemanticIndexOptions` containing a nonempty control-free caller logical name,
one `none`/`identity`/`span`/`text` `SemanticSourceDetail`, and an optional exact Unicode-17 rule selector. Public
source values use zero-based half-open UTF-8 bytes and one-based line/Unicode-scalar columns; SHA-256 covers the
canonical bytes and is disclosable only at `text`. Exact source identity/span/excerpt/occurrence accessors must apply
the ceiling before returning a detached value and reject Boolean range arguments explicitly.

The outcome half follows only after that source owner is stable. It calls the staged user-function-aware parser,
validator, compiler with duplicate validation disabled, entry selector, and shared generated-v2 plan builder once.
It merges functions and rules by authored source position because `CompiledSpec.definition_order` contains only
rules (`Top`, `Done`) while the calls fixture function `normalize` precedes them. Native portable failure stays
exact: `failed.spec` is `bare_edge_target_undefined` / `normalize_edges` with `rule_label=Top`, `target=Missing`;
missing selection is `entry_rule_not_found` / `select_entry_rule`. Fatal process exceptions rethrow; all ordinary
parse/validation/compile/selection/plan failures become detached failed-compilation outcomes. Generated plan rows
for the calls fixture are `Top/default`, `Done/default` and use caller logical identity rather than a path.

Construction has no path input and never calls `SpecLoader`, a target runtime engine, generated execution, trace,
diagnostic output, or semantic observation. The existing staged frontend may compile/execute its declared trusted
function-shell/body parser specifications as compiler infrastructure; that is distinct from executing the caller's
target spec. A target action containing an unconditional host error still parses, validates, compiles, selects, and
plans successfully during the probe. Public semantic records/query remain absent until later leaves.

Implementation is dependency-ordered under `.10.6`: Unicode rule-label closure; source-only copied input/map
`.10.6.2.1`; staged compiled-or-failed authority `.10.6.2.2`; composed foundation closeout `.10.6.2.3`; static
graph/privacy/failure projection; calls/bindings/staged/generated projection; typed and raw query; runtime
observation across every route; and one exact 12-role Julia admission consumer. None of these facts promotes Julia
rollout or admission by itself.
