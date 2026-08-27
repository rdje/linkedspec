---
id: dart-staged-ast-enrichment-carriers-admission
title: Dart privately admits staged-AST enrichment through four fresh-authority production carriers
answers:
  - "is Dart general staged AST enrichment admitted"
  - "which Dart carriers execute staged AST enrichment"
  - "how does Dart staged AST enrichment get fresh authority per execution"
  - "where is StagedAstEnrichmentSeed used in Dart"
  - "does Dart generated source serialize staged parser callbacks"
  - "does Dart staged AST enrichment preserve generated source v2"
  - "does Dart staged AST enrichment run after the parent parse"
  - "is the Dart staged AST consumer in canonical CI"
  - "how many Dart staged AST enrichment tests pass"
  - "what follows FUTURE-PARITY-BACKLOG 14.7.5.4"
date: 2026-08-27
status: current private Dart carrier admission; Julia is also admitted and Lua marker/provenance is dormant
tags: [dart, staged-parsing, carriers, generated-source, invocation-authority, admission, ci, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.4 adds opaque host-only StagedAstEnrichmentSeed to LinkedSpecRuntimeEngine and the generated-v2 execution wrappers. Every top-level execution starts a new FrozenStagedRegistry with an empty plan cache and a new StagedRecursiveAuthority, completes the parent parse, rejects any live recognition transaction, and only then calls enrichStagedRecursively. Native, SpecFile-JSON reconstructed, validated generated-plan, and independently analyzed/executed emitted-source routes each execute twice through one seed; every run reports one miss/zero hits, one callback, fresh cancellation and clock observations, equal detached AST/sidecar/diagnostic/cache/resource records, and no cross-result mutation. Compiled JSON and emitted source contain no callback, compiled parser, registry/source authority, cancellation/deadline/budget state, mutable queue/cache, path, or host handle. The former dormant consumer moves to dart/test/staged_ast_enrichment_contract_test.dart, passes 19/19, runs once in ordinary discovery, and is required/invoked exactly once by canonical CI. Neutral governance advances only Dart to complete and rejects 90 mutations. Function-body v1, generated-source v2, public/outward surfaces, later backends, recurrence, and combined no-drift remain unchanged or pending."
evidence_update_2026_08_27_julia_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.6.0 preserves all Dart carrier behavior while advancing Julia to one 86-GREEN/one-RED dormant consumer and neutral governance to 92 mutations. It also corrects the contract's stale Dart-dormant availability duplicate and aligns the Dart ordinary runtime command with the already-proven package cwd."
evidence_update_2026_08_27_julia_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.6.1 preserves every Dart carrier and admission boundary while implementing Julia's exclusive inert marker plus live-proven direct/ordered-derived provenance. Julia's dormant consumer advances to 131 GREEN and one exact pre-registered-resolution/cache/policy RED; .14.7.6.2 is next."
evidence_update_2026_08_27_julia_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.6.2 preserves every Dart carrier and admission boundary while adding Julia's private tuple-frozen resolver/cache, complete current-depth target reservation/order/isolation, detachment, and every result/failure policy. Julia's dormant consumer advances to 309 GREEN and one exact recursive-authority RED; .14.7.6.3 is next."
evidence_update_2026_08_27_julia_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.6.3 preserves every Dart carrier and admission boundary while adding Julia's private breadth-first returned-marker queue, exact lineage/cycle/decrease checks, shared resources, expiring safe points, and direct/ordered-derived source projection. Julia's dormant consumer advances to 386 GREEN and one exact carrier/admission RED; .14.7.6.4 is next."
evidence_update_2026_08_27_julia_admission: "FUTURE-PARITY-BACKLOG.14.7.6.4 preserves Dart behavior while admitting Julia's equivalent fresh four-route seed. The synchronized Dart projection remains 19/19 against neutral governance at 97 mutations; Lua .14.7.7 is next."
evidence_update_2026_08_27_lua_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.7.0 preserves Dart behavior while advancing only the shared Lua consumer lifecycle to dormant_red. The synchronized Dart projection remains 19/19 against neutral governance at 98 mutations; Lua marker/provenance .14.7.7.1 is next."
evidence_update_2026_08_27_lua_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.7.1 preserves Dart behavior while implementing Lua's exclusive inert marker and private-native-range-backed typed direct/ordered-derived provenance. The synchronized Dart projection remains 19/19 against unchanged 98-mutation governance; Lua .14.7.7.2 is next."
root_cause: "Dart had complete private marker, frozen-registry, one-depth, and recursive authority, but LinkedSpecRuntimeEngine returned the raw parent value and the generated execution wrappers accepted only progressive authority. No top-level host seam could inject nonserializable staged authority or start a fresh scheduler after the completed parent parse, so the final consumer had to remain outside ordinary and canonical discovery."
last_verified: 2026-08-27
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c '^require_tracked_file dart/test/staged_ast_enrichment_contract_test[.]dart$' tools/run_ci_local.sh)\" -eq 1"
  - "test \"$(rg -c '^log_step running exact Dart staged-AST enrichment admission consumer$' tools/run_ci_local.sh)\" -eq 1"
---

# Dart staged-AST carrier admission

`StagedAstEnrichmentSeed` is an opaque host recipe. It deeply owns the caller-frozen logical registry, opaque
compiled callbacks, recursive policy and ceilings, cancellation authority, clock, and optional detached outcome
sink. `start()` constructs a new `FrozenStagedRegistry` and `StagedRecursiveAuthority` for every execution, so
reusing one seed never reuses a cache, scheduler counters, or callback context.

`LinkedSpecRuntimeEngine` starts the host authority beside the existing progressive seed, executes the complete
parent rule, checks that no recognition transaction remains live, and then enriches the returned AST inside the
existing structured runtime-error boundary. With no staged seed, every existing execution path is unchanged.

The same optional seed crosses native execution, `SpecFile`-JSON reconstruction, validated generated plans, and
generated-source-v2 `execute`. Emitted source contains the logical marker plus the private seed type seam, but no
concrete registry, callback, parser, source, cancellation, clock, resource, filesystem, or host authority. The
embedding host supplies those values for each call.

The admitted consumer executes every route twice through one seed. Each result records one cache entry, zero
hits, and one miss. Callback, cancellation, and clock observations prove a new recursive invocation on every run.
All four routes return equal detached records, and mutating one result cannot affect another.

This is private backend behavior, not public `parse_job(...)` authoring. Dart rollout is complete. Julia has since
reached the same private admission boundary; Lua, six-runtime recurrence, public authoring, independent
recomposition, and combined no-drift retain their existing owners.

Related: [[dart-staged-ast-enrichment-recursive-authority]],
[[dart-staged-ast-enrichment-current-depth-authority]], [[dart-staged-ast-enrichment-marker-provenance]],
[[rust-staged-ast-enrichment-carriers-admission]], [[julia-staged-ast-enrichment-dormant-red]],
[[julia-staged-ast-enrichment-marker-provenance]],
[[general-staged-ast-enrichment-neutral-contract]], and ADR
`0088`.
