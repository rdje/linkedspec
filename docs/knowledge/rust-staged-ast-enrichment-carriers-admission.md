---
id: rust-staged-ast-enrichment-carriers-admission
title: Rust privately admits staged-AST enrichment through four fresh-authority production carriers
answers:
  - "is Rust general staged AST enrichment admitted"
  - "which Rust carriers execute staged AST enrichment"
  - "how does Rust staged AST enrichment get fresh authority per execution"
  - "where is StagedAstEnrichmentSeed used"
  - "does Rust generated source serialize staged parser callbacks"
  - "does Rust staged AST enrichment preserve generated source v2"
  - "why was the Rust staged AST dead_code allowance removed"
  - "does Rust staged AST enrichment run after the parent parse"
  - "is the Rust staged AST consumer in canonical CI"
  - "what follows FUTURE-PARITY-BACKLOG 14.7.4.4"
date: 2026-08-26
status: current private Rust carrier admission; Dart is also admitted and Julia .14.7.6.0 is next
tags: [rust, staged-parsing, carriers, generated-source, invocation-authority, admission, ci, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.4.4 adds opaque host-only StagedAstEnrichmentSeed to ExecutionOptions. Every native or generated top-level execution starts a new FrozenStagedRegistry with an empty PlanCache and a new StagedRecursiveAuthority before parent parsing, then calls enrich_recursively only after the complete parent value returns and after checking live recognition-transaction state. Native, serialized/reconstructed, validated generated-plan, and independently compiled emitted-source routes each execute twice through one seed; every run reports one miss/zero hits, one callback, fresh cancellation/clock checks, equal detached AST/sidecars/diagnostics/cache/resources, and no cross-result mutation. Compiled JSON, generated plans, and emitted source contain no callback, compiled parser, registry/source authority, cancellation/deadline/budget state, mutable queue/cache, path, or host handle. The outer cfg, manifest check-cfg, cfg-only exports, and dead-code allowance are removed after the first production caller. The exact ordinary consumer is GREEN and registered once in canonical CI; neutral governance advances only Rust to complete and 84 mutations. Function-body v1, generated-source v2, public/outward surfaces, later backends, recurrence, and combined no-drift remain unchanged or pending."
evidence_update_2026_08_27_dart_admission: "FUTURE-PARITY-BACKLOG.14.7.5.4 admits Dart's equivalent fresh four-route seed and advances the neutral oracle to 90 mutations with Perl, Rust, and Dart complete. The Rust path remains unchanged; Julia .14.7.6.0 is next."
root_cause: "Rust had complete dormant marker, frozen-registry, one-depth, and recursive authority, but no top-level host seam could inject nonserializable authority or run it after a completed parent parse. Consequently the module required a temporary dead-code allowance and the final consumer could not enter ordinary or canonical discovery."
reverify:
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t"
  - "test \"$(rg -c '^require_tracked_file rust/linkedspec-runtime/tests/staged_ast_enrichment_contract[.]rs$' tools/run_ci_local.sh)\" -eq 1"
  - "test \"$(rg -c '^cargo test --manifest-path rust/Cargo[.]toml -p linkedspec-runtime --test staged_ast_enrichment_contract$' tools/run_ci_local.sh)\" -eq 1"
  - "! rg -n 'linkedspec_staged_ast_enrichment_red|allow\\(dead_code\\)' rust/linkedspec-runtime/Cargo.toml rust/linkedspec-runtime/src/lib.rs rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs"
---

# Rust staged-AST carrier admission

`StagedAstEnrichmentSeed` is an opaque host recipe carried only by `ExecutionOptions`. It retains caller-frozen
logical registry data plus opaque compiled callbacks, enrichment policy, recursive ceilings, cancellation, and a
clock. `start()` reconstructs the registry and recursive authority for every execution, so even repeated calls
with the same options receive an empty cache and unspent counters.

The engine starts that invocation before parent execution but does not expose it to authored code. Only after the
complete parent value returns does the engine verify that no recognition transaction remains active and run
`enrich_recursively`. Errors stay inside the existing native/generated runtime-error paths. With no seed, every
existing execution API returns its unchanged result.

The same options-bearing seam covers native and JSON-reconstructed engines, validated generated plans, and the
generated-source-v2 `execute_with_options` entrypoint used by an independently compiled emitted module. Generated
data contains the logical marker only; the host supplies callbacks and resource authority at invocation time.

The admitted consumer executes every route twice through one seed. Each result shows one cache entry, zero hits,
one miss, proving that cache state was not reused. Callback, cancellation, and clock counters prove a new recursive
run each time. All four routes return equal detached records, and mutating one returned AST cannot affect another.

This is private backend behavior, not public `parse_job(...)` authoring. Rust rollout is complete. Dart has since
reached the same private admission boundary; Julia, Lua, six-runtime recurrence,
public authoring, independent recomposition, and combined no-drift retain their existing owners.

Related: [[rust-staged-ast-enrichment-recursive-authority]],
[[rust-staged-ast-enrichment-current-depth-authority]], [[rust-staged-ast-enrichment-marker-provenance]],
[[perl-staged-ast-enrichment-carriers-admission]], [[general-staged-ast-enrichment-neutral-contract]], and ADR
`0088`.
