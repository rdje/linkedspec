---
id: julia-semantic-runtime-observation-authority-map
title: Julia runtime semantics must be captured at typed accepted-slot and successful-result seams
answers:
  - "does Julia already have a semantic runtime observation sink"
  - "where must Julia capture regex slot semantic events"
  - "where must Julia capture final semantic result events"
  - "which Julia cursor owns semantic observation positions"
  - "should Julia semantic observations reuse trace output"
  - "should Julia semantic observations reuse diagnostic output"
  - "what happens when no Julia semantic observation sink is installed"
  - "how must Julia semantic observer callback failures propagate"
  - "why do Julia generated wrappers need semantic observer failure passthrough"
  - "which Julia execution routes reuse the runtime observation seams"
  - "how must Julia derive an observed semantic index"
  - "can Julia semantic query execute the parser"
  - "what is the Julia semantic runtime observation implementation split"
date: 2026-07-23
status: current authority plan; typed direct capture and immutable derivation implemented by linked facts
tags: [julia, semantic-introspection, runtime, observation, trace, diagnostics, generated-source]
evidence: julia/src/runtime/Interpreter.jl; julia/src/runtime/Matching.jl; julia/src/io/SpecLoader.jl; julia/src/source/SourceEmitter.jl; julia/src/trace/Trace.jl; julia/src/semantic/SemanticIndex.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/semantic/SemanticQuery.jl; capability_conformance/semantic_introspection_model.json; capability_conformance/semantic_introspection_contract.json; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.6.0
last_verified: 2026-07-23
reverify:
  - "rg -n 'RuntimeDiagnosticOutputSink|_RuntimeExecutionContext|runtime_parse|runtime_execute|regex_slot_selected|RuntimeParseResult' julia/src/runtime/Interpreter.jl"
  - "rg -n '_GeneratedDiagnosticOutputSinkFailure|execute_generated_parser_v2|execute_generated_parser_with_trace_v2|function execute\\(|function execute_with_trace' julia/src/source/SourceEmitter.jl"
  - "sed -n '120,155p' julia/src/io/SpecLoader.jl"
  - "sed -n '143,178p' capability_conformance/semantic_introspection_model.json"
  - "sed -n '236,248p' capability_conformance/semantic_introspection_contract.json"
  - "python3 tools/check_semantic_introspection_contract.py"
---

# Julia semantic runtime observation authority map

## Current boundary

Julia had no semantic runtime-observation sink at the `.10.6.6.0` audit boundary. `_RuntimeExecutionContext`
contains the input, code-unit cursor, trace emitter, diagnostic-output sink, and generated-plan metadata, but no
typed semantic channel. Existing high trace emits the string topic `julia_runtime:regex_slot_selected`; it has no
typed payload and no final-result topic. Trace text and diagnostic output are therefore optional observability
products, not normalized semantic evidence.

The authoritative regex-slot call sites are immediately after a match exists and its ordered slot identity has
been checked, and immediately before `_accept_runtime_regex_match!` mutates cursor/register/action state. At this
pre-effect seam the context still contains the old cursor. The exact post-match semantic position must therefore
come from `one_match.codeunit_end`, converted by `codeunit_offset_to_char_offset(context.input, ...)`; reading
`context.cursor_codeunit` here would record the wrong position. The event also has the executing rule plus the
accepted target rule and authored zero-based regex index from `_runtime_regex_slot_identity`.

The one final-result seam is the successful `runtime_parse` path immediately after `RuntimeParseResult` is
constructed and before it is returned. It owns the resolved entry label, copied exact input, and final
`cursor_char_offset`. A thrown entry selection or execution has no final `rule_result`; a normally returned parse
result is one completed invocation.

## Required typed native boundary

Leaf `.10.6.6.1` must export the contract
`linkedspec-semantic-execution-observation-v1`, a closed immutable `regex_slot_selected` / `rule_result` event-kind
and event vocabulary, and an optional invocation-local synchronous callback type. Slot events carry contract,
kind, executing rule, target rule/index, and Unicode-scalar position. Result events carry contract, kind, entry
rule, scalar position, exact `input:sha256:<lowercase-hex>` identity, and status `succeeded`; the opposite nullable
fields stay absent. Host result values do not enter the event.

The sink is separate from `LinkedSpecTraceEmitter` and `RuntimeDiagnosticOutputSink`. Every emission helper must
return before allocating an event when the sink is absent; the final helper must also return before hashing input.
A callback exception must unwind synchronously as the exact caller object. Generated execution needs an
invocation-local failure marker/pass-through around only that callback so its broad catch can rethrow the original
semantic failure before generic `GeneratedSourceException` translation; the pass-through must not classify an
unrelated runtime exception as an observer failure.

`runtime_parse` is the shared engine seam. `runtime_execute` and both traced convenience functions delegate to it;
`create_engine(LoadedCompiledSpec)` constructs the same `LinkedSpecRuntimeEngine`; normalized JSON reconstruction
does likewise. `execute_generated_parser_v2` validates the plan and calls `runtime_parse`, while its traced form
only creates the trace emitter. Emitted module `execute` and `execute_with_trace` delegate to those generated-plan
helpers. The same optional sink must flow through all of these adapters without changing results, cursors, trace
bytes/events, diagnostic events, entry/failure behavior, or generated-source v2/format 2.

## Required immutable derivation boundary

Leaf `.10.6.6.2` must add one public derivation that accepts caller-retained typed events and returns a new opaque
`SemanticIndex`. It validates the exact event type/contract/field combinations, nonnegative positions, stable
result input identity, a compiled base with no prior execution, and exactly one successful final event last whose
rule is the base snapshot's selected entry. Each slot event must map through the base projection's executing-rule
edge and `selects_regex` relation to the declared target slot.

Derivation consumes only the recursively immutable private static projection. It obtains slot event source and
value shape from the matching edge, and final source/result shape from the selected rule; it never inspects host
result values, compiler objects, runtime context, trace, diagnostics, paths, or other host state. A new projection
sets `has_execution=true`, adds canonical `execution:0` and ordered event records plus `observed_as` relations, and
leaves the base index unchanged. Query continues to read detached projection data and cannot execute a parser,
install a sink, enable trace, hash new input, or mutate either index.

## Dependency order

- `.10.6.6.1`: immutable typed event/sink API plus direct, loaded, reconstructed, traced-convenience, and validated
  generated-plan engine capture.
- `.10.6.6.2`: strict detached derivation, malformed/topology rejection, immutable base/derived isolation, and the
  twentieth exact response digest.
- `.10.6.6.3`: public generated helpers and fresh emitted direct/traced propagation, callback-failure passthrough,
  failure omission, and result/cursor/trace/diagnostic non-interference with unchanged v2/format 2.
- `.10.6.6.4`: no-change composition/signoff and parent closure without Julia rollout or native-admission
promotion.

Typed direct/native and validated generated-plan capture now implements `.1`, and strict immutable observed-index
derivation implements `.2`. Retrieve [[julia-semantic-runtime-observation-direct-capture]] for capture and
[[julia-semantic-runtime-observation-derivation]] for validation/topology/query. Fresh emitted propagation remains
the exact `.3` boundary.

## Exact neutral anchor

The governed input is the three UTF-8 bytes `61 62 0a` (`ab\n`). Its identity is
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. The expected events select
`Top[0]` at scalar position 1, select `Top[1]` at position 2, then complete `Top` at position 2. Query case
`runtime_events` must retain response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

The `.10.6.6.0` runtime probe confirmed direct, loaded, reconstructed, generated-plan, generated-traced, fresh
emitted, and fresh emitted-traced routes all return `Any["A", "B"]`; result-bearing routes end at scalar position
2, and each traced generated route emits exactly two existing slot marks. This is topology evidence only and does
not make trace text a semantic authority.
