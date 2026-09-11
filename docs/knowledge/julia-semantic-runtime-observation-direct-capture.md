---
id: julia-semantic-runtime-observation-direct-capture
title: Julia exposes typed invocation-local runtime semantic observations at the shared native engine seams
answers:
  - "how do I capture Julia runtime semantic observations"
  - "what fields are in a Julia RuntimeSemanticObservationEvent"
  - "which Julia runtime routes accept semantic_observation_sink"
  - "does Julia semantic observation work with trace and diagnostics"
  - "what positions do Julia regex slot observation events report"
  - "does Julia hash input when no semantic observation sink is installed"
  - "does Julia preserve semantic observation callback exception identity"
  - "do fresh emitted Julia parser wrappers accept semantic_observation_sink"
  - "does Julia runtime observation derive a semantic index yet"
date: 2026-07-23
status: typed capture admitted; historical passthrough proof is limited by open action callback repair .2.6
tags: [julia, semantic-introspection, runtime, observation, trace, diagnostics, generated-source]
evidence: julia/src/runtime/SemanticObservation.jl; julia/src/runtime/Interpreter.jl; julia/src/source/SourceEmitter.jl; julia/src/LinkedSpecJulia.jl; julia/test/semantic_index_runtime_observation_test.jl; julia/test/semantic_index_runtime_observation_routes_test.jl; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.6.1 and .10.6.6.3
last_verified: 2026-07-26
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/semantic_index_runtime_observation_test.jl\")'"
  - "rg -n 'semantic_observation_sink|_record_runtime_regex_slot_selected|_emit_runtime_semantic_rule_result' julia/src/runtime/Interpreter.jl julia/src/source/SourceEmitter.jl"
---

# Julia typed runtime semantic observation capture

**Current qualification (2026-09-11):** historical callback identity evidence below
covers the tested direct/final seams. A callback thrown from a Child slot inside
Top `I { return(call(Child)) }` loses identity at the action-block catch, then is
translated again by generated-plan execution. `.2.6.1/.2.6.2` own repair and carrier
recurrence; see [[julia-semantic-observer-action-failure-wrapping]]. This diagnostic
covers native and validated-plan direct/traced conveniences with tracing disabled;
it grants no new enabled-trace, original-backtrace or fresh-emitted defect proof.
The dated rollout/admission counts below are historical, not current pending state.


`LinkedSpecJulia` exports contract `linkedspec-semantic-execution-observation-v1`, the closed
`RuntimeSemanticRegexSlotSelected` / `RuntimeSemanticRuleResult` kind vocabulary, immutable
`RuntimeSemanticObservationEvent`, `RuntimeSemanticObservationSink`, and stable kind-name/JSON projections.
Events contain only contract id, kind, executing rule, nullable target/index, Unicode-scalar position, nullable
input identity, and nullable status. They never contain a host result value.

Pass `semantic_observation_sink = event -> ...` to `runtime_parse`, `runtime_execute`, either traced convenience,
`execute_generated_parser_v2`, or `execute_generated_parser_with_trace_v2`. Loaded and normalized
JSON-reconstructed engines use the same runtime entry. Each accepted regex slot emits synchronously after ordered
identity succeeds and before match effects, using the accepted match end converted to a Unicode-scalar offset.
One normally returned parse emits a final `rule_result` after `RuntimeParseResult` construction with status
`succeeded` and `input:sha256:<UTF-8 digest>`. Throws and immediate exit omit the final event.

The semantic sink is independent of trace and diagnostic-output sinks. Installing it does not change result,
cursor, trace bytes/events, diagnostic events, or ordinary failure behavior. Without a sink, the slot and final
helpers return before event allocation, scalar conversion, or input hashing; focused warmed allocation checks are
zero. A sink exception is marked only at the callback boundary and rethrown as the exact caller object through
both native and generated-plan broad catches.

Fresh emitted module `execute` and `execute_with_trace` wrappers now accept and forward the same sink under
`.10.6.6.3`; this is an additive public wrapper keyword and does not change generated-source v2/format 2 or the
minimal generated plan. The separate `.10.6.6.2` derivation accepts retained typed events through
`with_execution_observation` and returns a new validated observed `SemanticIndex`. Retrieve
[[julia-semantic-runtime-observation-generated-routes]] for emitted/isolated-host behavior and
[[julia-semantic-runtime-observation-derivation]] for topology, immutability, and the twentieth digest.

The canonical `ab\n` execution emits `Top[0]` at position 1, `Top[1]` at position 2, and final `Top` success at
position 2 with identity
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. Focused proof adds 66 assertions;
the ten semantic suites compose at 1,129 and complete Julia reaches 8,671 package assertions plus primary process
conformance and corpus 105/105.

Full signoff also passes primary 5x2x66, all ten Unicode-manifest legs, unchanged Unicode/semantic/capability/
generated/language/public ledgers, and canonical CI with Rust semantic admission 1/1 in 82.37 seconds, Dart 1/1,
reference primary 66x2, and Phase 0 1,031/1,031 in 662 seconds.

No-change composition `.10.6.6.4` subsequently recomposed all twelve committed semantic owners at focused 1,337
and closed parent `.10.6.6` without changing this capture API, runtime behavior, generated format, rollout 4/9,
or native admission 3/6. Exact Julia admission remains pending in `.10.6.7`.

Related facts: [[julia-semantic-runtime-observation-authority-map]], [[julia-semantic-query-public-api]],
[[julia-semantic-runtime-observation-generated-routes]], [[julia-semantic-runtime-observation-derivation]],
[[semantic-introspection-neutral-contract]].

## Reading reconciliation at Julia .1.14

Interpreter1616-3115 selects root and family before rule execution, restores local
bindings/marks/recognition frames and registers on unwind, and memoizes action
child dispatch. Regex identity is recorded before acceptance effects; the absent
semantic sink returns before event construction or hashing. Final observation is
emitted after RuntimeParseResult construction. The action catch qualification above
is the new confirmed gap; the remaining attached-switch body begins after this range.

Focused replay for the existing direct-dependent suites (176 assertions plus one
selected-set equality), without the complete component or canonical gate:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_RULE_READING14'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT = pwd()
const selected = Set(["Runtime rule interpreter", "Runtime value blocks controls and trailing blocks"])
const seen = Set{String}()
for expression in Meta.parseall(read("julia/test/runtests.jl", String)).args
    expression isa Expr || continue
    if expression.head == :function
        Core.eval(Main, expression)
    elseif expression.head == :macrocall && expression.args[1] == Symbol("@testset") && expression.args[3] in selected
        Core.eval(Main, expression)
        push!(seen, expression.args[3])
    end
end
@test seen == selected
include("julia/test/source_emitter_test.jl")
include("julia/test/semantic_index_runtime_observation_test.jl")
JULIA_RULE_READING14
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
```
