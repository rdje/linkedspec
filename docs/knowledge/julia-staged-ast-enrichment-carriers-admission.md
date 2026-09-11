---
id: julia-staged-ast-enrichment-carriers-admission
title: Julia privately admits staged-AST enrichment through four fresh-authority production carriers
answers:
  - "is Julia general staged AST enrichment admitted"
  - "which Julia carriers execute staged AST enrichment"
  - "how does Julia staged AST enrichment get fresh authority per execution"
  - "where is StagedAstEnrichmentSeed used in Julia"
  - "does Julia generated source serialize staged parser callbacks"
  - "does Julia staged AST enrichment preserve generated source v2"
  - "does Julia staged AST enrichment run after the parent parse"
  - "is the Julia staged AST consumer in ordinary and canonical CI"
  - "how many Julia staged AST enrichment assertions pass"
  - "what follows FUTURE-PARITY-BACKLOG 14.7.6.4"
date: 2026-08-27
status: current Julia carrier admission with six-runtime recurrence and exact public assignment authoring
tags: [julia, staged-parsing, carriers, generated-source, invocation-authority, admission, ci, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.4 adds opaque host-only StagedAstEnrichmentSeed to LinkedSpecRuntimeEngine and the generated-v2 execution wrappers. The seed deeply owns only logical registry/options plus a host factory; every top-level execution invokes that factory and starts a new _FrozenStagedRegistry with an empty plan cache and a new _StagedRecursiveAuthority. The engine completes the parent value, rejects live recognition transactions, and only then calls _enrich_staged_recursively. Native, SpecFile-JSON reconstructed, validated generated-plan, and independently included emitted-module routes each execute twice through one seed. All eight results are equal and detached, each reports one cache entry/zero hits/one miss/one call, and all eight runs observe distinct cancellation identities plus 32 distinct compiled callback closures. Compiled JSON, generated plans, and emitted source contain no callback, compiled parser, registry/source snapshot, cancellation/deadline/budget authority, mutable queue/cache, durable absolute path, or host handle. The stable consumer passes 491/491, is included once by ordinary Julia discovery, and is required/logged/invoked exactly once by canonical CI. Neutral governance advances only Julia to complete and rejects 97 mutations. Function-body v1, generated-source v2, public/outward surfaces, other backend behavior, Lua, recurrence, and combined no-drift remain unchanged or pending."
root_cause: "Julia already had the private marker, pure frozen registry, one-depth engine, and recursive scheduler, but LinkedSpecRuntimeEngine returned the completed parent value directly. Generated-v2 and emitted wrappers forwarded only progressive authority. There was no host-only top-level recipe that could create a fresh general-v2 registry/cache/recursive authority for every execution and invoke it after the complete parent AST."
evidence_update_2026_08_27_lua_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.7.0 preserves all Julia production/admission behavior while advancing only the shared Lua consumer lifecycle to dormant_red. Julia remains 491/491 against neutral governance at 98 mutations; Lua marker/provenance .14.7.7.1 is next."
evidence_update_2026_08_27_lua_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.7.1 preserves all Julia production/admission behavior while implementing Lua's exclusive inert marker and private-native-range-backed typed direct/ordered-derived provenance. Julia remains 491/491 against unchanged 98-mutation governance; Lua .14.7.7.2 is next."
evidence_update_2026_08_27_lua_admission: "FUTURE-PARITY-BACKLOG.14.7.7.4 preserves all Julia production/admission behavior while promoting the shared Lua lifecycle and two rollout rows. Julia remains 491/491 against the all-private-complete 106-mutation neutral contract."
evidence_update_2026_08_28_lua_recomposition: "FUTURE-PARITY-BACKLOG.14.7.7.5 reruns Julia 491/491 unchanged while independently recomposing the committed shared Lua 888/888 dual-ABI carriers, exact topology, and 106-mutation governance. All private backend routes are independently recomposed; recurrence .14.7.8 is next."
evidence_update_2026_08_28_recurring_and_public: "FUTURE-PARITY-BACKLOG.14.7.8 composes Julia 491/491 in six-runtime recurrence; .14.7.9 admits exact assignment-form parse_job publicly through the unchanged dedicated carrier/frozen authority and changes only aggregate governance snapshots in this consumer."
last_verified: 2026-08-27
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c '^include\\(\"staged_ast_enrichment_contract_test[.]jl\"\\)$' julia/test/runtests.jl)\" -eq 1"
  - "test \"$(rg -c '^require_tracked_file julia/test/staged_ast_enrichment_contract_test[.]jl$' tools/run_ci_local.sh)\" -eq 1"
  - "test \"$(rg -c '^log \"running exact Julia staged-AST enrichment admission consumer\"$' tools/run_ci_local.sh)\" -eq 1"
  - "test \"$(rg -c '^bash tools/run_julia_project_data[.]sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test[.]jl$' tools/run_ci_local.sh)\" -eq 1"
---

# Julia staged-AST carrier admission

`StagedAstEnrichmentSeed` is an opaque host recipe. It deeply copies the logical frozen registry and enrichment
options, validates both eagerly, and retains one opaque factory without invoking it. Each top-level execution
invokes the factory and requires exactly a fresh compiled-callback map, recursive authority, cancellation probe,
and clock. A new registry means a new empty plan cache; a new recursive authority means lineage, budgets, calls,
diagnostic bytes, and callback contexts cannot leak between executions.

`LinkedSpecRuntimeEngine` completes the parent execution before it invokes the host factory or creates any staged
execution state. A parent failure therefore consumes no staged callback, cache, cancellation, clock, lineage, or
budget authority. The engine then checks that no recognition transaction remains live, runs enrichment, expires
the one-use state, returns a detached neutral outcome, and preserves the primary `StagedAstEnrichmentException`
through generated execution. With no seed, existing parse results are unchanged.

The same optional seed crosses native execution, normalized `SpecFile`-JSON reconstruction, validated generated
plans, and generated-source-v2 `execute` / `execute_with_trace`. Independently included emitted source carries
only the logical compiled program and optional host parameter. It never serializes the factory or any concrete
callback, registry, source, cancellation, clock, cache, queue, resource, path, or host authority.

The admitted consumer executes all four routes twice through one seed. It proves eight fresh run identities and
cancellation tokens, four new compiled callback closures per run, callback/cancellation/clock observation on
every run, one cache miss and zero hits per result, result equality, cross-result mutation isolation, no-seed
compatibility, no factory start on parent failure, exact child-failure identity, transaction denial, and
execution-state expiry.

Julia rollout and six-runtime recurrence are complete. Exact scalar assignment-form `parse_job(...)` authoring is
public through this unchanged backend behavior; unrelated outward surfaces and host authority remain denied.
Combined typed public no-drift retains `.14.8`.

Related: [[julia-staged-ast-enrichment-recursive-authority]],
[[julia-staged-ast-enrichment-current-depth-authority]],
[[julia-staged-ast-enrichment-marker-provenance]],
[[staged-consumer-current-projection-lockstep]],
[[dart-staged-ast-enrichment-carriers-admission]],
[[general-staged-ast-enrichment-neutral-contract]], and ADR `0088`.

## 2026-09-11 — emitter loader and staged-prefix reading .1.48

Julia .1.48 reads consumer1–799, including production helper definitions and the
production-route test prefix736–799. Those helpers build fresh host callback,
cancellation and clock fixtures, while four marker-only carriers are completely
read and executed. The production test's assertions after799 remain unread and
excluded from this slice's bounded replay. Earlier491-assertion carrier evidence
is preserved as historical proof; this slice claims61 prefix assertions only.
Neutral staged123/public129 checks pass. Replay and the explicit734 boundary are
in [[julia-generated-source-v2-rule-local-cursor]]. All repairs remain open.

## 2026-09-11 — returned-result isolation claim requires a stronger test

Julia .1.49 confirms that consumer859–861 mutates a deepcopy, so that assertion
passes even with eight deliberately aliased results. The earlier cross-result
mutation-isolation claim is not established by that check. Direct mutations of
all eight actual returned AST kind fields preserve their seven siblings in the
fresh diagnostic; no runtime alias defect is established. Julia .2.26 owns the
permanent coverage correction and counterpart audit. Exact22 added diagnostic/
selection assertions and164 existing-prefix assertions are recorded in
[[julia-staged-result-isolation-test-gap]]. All prior runtime repairs remain open.
