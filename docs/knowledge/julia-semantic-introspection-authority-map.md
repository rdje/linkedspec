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
date: 2026-07-22
status: current
tags: [julia, semantic-introspection, source-map, diagnostics, runtime, generated-source, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.0; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/decisions/0050-semantic-introspection-staged-artifact-records.md; capability_conformance/semantic_introspection_model.json; julia/src/spec/Ast.jl; julia/src/spec/Parser.jl; julia/src/spec/Validator.jl; julia/src/parser/StagedParserRegistry.jl; julia/src/parser/UserFunctionDefinitionParser.jl; julia/src/compiler/CompiledSpec.jl; julia/src/action/ActionAst.jl; julia/src/action/ActionParser.jl; julia/src/action/ActionContracts.jl; julia/src/action/FunctionRegistry.jl; julia/src/io/SpecLoader.jl; julia/src/runtime/Interpreter.jl; julia/src/source/SourceEmitter.jl; julia/src/trace/Trace.jl
reverify: "python3 tools/check_semantic_introspection_contract.py; rg -n 'semantic_index|semantic_query|SemanticIndex|SemanticQuery|definition_order|ActionSourceSpan|regex_slot_selected|diagnostic_output_sink' julia/src; LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia bash tools/run_julia_local.sh"
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
UTF-8 bytes. An exact `UInt8[0xff]` probe has `isvalid == false`, but direct `parse_spec` produces a generic
`SpecParseException` and staged parsing produces `UserFunctionDefinitionParserException`. Semantic construction
must explicitly reject malformed decoded strings and malformed byte input before language parsing, then retain
only caller logical identity. `SpecLoader` already checks decoded file bytes but also retains resolved host paths;
those paths and implicit file authority cannot enter semantic records or errors.

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

Implementation is dependency-ordered under `.10.6`: Unicode rule-label closure; strict source/compiled-or-failed
foundation; static graph/privacy/failure projection; calls/bindings/staged/generated projection; typed and raw
query; runtime observation across every route; and one exact 12-role Julia admission consumer. None of these facts
promotes Julia rollout or admission by itself.
