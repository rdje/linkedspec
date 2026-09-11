---
id: julia-semantic-runtime-observation-derivation
title: Julia derives immutable observed semantic snapshots only from typed events and detached static topology
answers:
  - "how do I derive a Julia observed SemanticIndex"
  - "what does Julia with_execution_observation do"
  - "how does Julia validate runtime semantic observation events"
  - "does Julia with_execution_observation execute or compile"
  - "does Julia with_execution_observation hash the input"
  - "how does Julia validate selecting rule and regex slot topology"
  - "where do Julia observed event source and value shape come from"
  - "does Julia observed-index derivation mutate the base index"
  - "what records and relations does Julia observed-index derivation add"
  - "what is the Julia runtime_events response digest"
  - "can Julia query an observed runtime snapshot"
date: 2026-07-23
status: current immutable observed-index derivation; generated/emitted propagation and parent composition complete
tags: [julia, semantic-introspection, runtime, observation, query, immutability, topology]
evidence: julia/src/semantic/SemanticRuntimeProjection.jl; julia/src/semantic/SemanticCompilationOutcome.jl; julia/src/semantic/SemanticIndex.jl; julia/src/LinkedSpecJulia.jl; julia/test/semantic_index_runtime_projection_test.jl; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.6.2
last_verified: 2026-07-26
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/semantic_index_runtime_observation_test.jl\"); include(\"julia/test/semantic_index_runtime_projection_test.jl\")'"
  - "rg -n 'with_execution_observation|_build_semantic_runtime_projection|observed_as|semantic_index_invalid_observation' julia/src/semantic/SemanticRuntimeProjection.jl julia/test/semantic_index_runtime_projection_test.jl"
---

# Julia immutable observed runtime projection

`LinkedSpecJulia.with_execution_observation(index, observation)` accepts a compiled static opaque `SemanticIndex`
and an `AbstractVector` containing exact `RuntimeSemanticObservationEvent` values. It returns a new index; it does
not mutate the base.

The derivation validates contract v1, the closed nullable-field topology for slot/result kinds, nonnegative scalar
positions and slot indices, exactly one successful final result last, the selected entry rule, and a lowercase
`input:sha256:` identity with exactly 64 hex digits. Each slot event must map from its executing rule through an
existing static edge and `selects_regex` relation to the named target rule/index slot. Failed/already-observed
bases plus empty, non-event, malformed, foreign, reordered, duplicate-final, wrong-entry, missing-slot, and
unrelated-edge sequences reject as `semantic_index_invalid_observation` at stage `execution_observation`.

Authority is limited to the recursively immutable private static projection. Slot source comes from the selected
regex-slot record and slot value shape from the selecting edge; final source and result shape come from the
selected static rule. Derivation does not parse, validate or compile source, execute a parser, enable trace,
install a sink, hash new input, read a path/environment, or inspect runtime/compiler/host objects. It validates the
identity already present in the caller's typed final event.

The returned projection sets `SemanticSnapshot.has_execution=true`, adds canonical `execution:0`, ordered
`event:execution:0:N` records, and one `observed_as` relation per event. Relation evidence points to the selected
regex slot for slot events and the selected entry rule for the final result. Projection data is thawed from a
detached static tree, canonicalized, and recursively frozen again. The base remains `has_execution=false`; caller
event-vector mutation and later JSON-response mutation cannot change either index.

Canonical `ab\n` yields two selected-slot events at scalar positions 1 and 2 plus final success at 2. Typed
`semantic_query` and raw-neutral `semantic_query_neutral` both match runtime-events digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. Focused proof adds 157 assertions; all
eleven semantic suites compose at 1,286 and complete Julia reaches 8,828 package assertions plus primary process
conformance and corpus 105/105.

Fresh emitted module/public generated propagation is complete in `.10.6.6.3`, and no-change `.10.6.6.4`
recomposes all twelve committed owners at focused 1,337 and closes the parent. Neither leaf changes this
derivation authority, generated-source v2/format 2, semantic rollout 4/9, or native admission 3/6. Exact Julia
admission remains pending in `.10.6.7`.

Related facts: [[julia-semantic-runtime-observation-authority-map]],
[[julia-semantic-runtime-observation-direct-capture]], [[julia-semantic-query-public-api]],
[[semantic-introspection-neutral-contract]].

## 2026-09-11 — runtime projection reading complete

Julia .1.28 reads SemanticRuntimeProjection1-329 through EOF. It validates the
compiled/unobserved base, closed typed slot/result fields, exactly one successful
final selected-entry result, and existing selecting-edge/slot topology. Input
identity uses an exact byte length plus lowercase hexadecimal classification,
not a newline-sensitive regex end anchor. Source and shapes come from retained
static owners; derivation builds a fresh frozen projection without execution.
Fresh capture66 and projection157 compose with the nine semantic suites at1286.
Prior action-observer wrapping .2.6 remains open; finite derivation proof does
not close it. Replay: [[julia-semantic-static-correlation-gaps]].
