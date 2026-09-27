---
id: nested-tree-julia-carrier-readiness
title: Julia nesting proof has five public routes and latest-world emitted binding lookup
answers:
  - which Julia nesting carriers preserve values and Unicode spans
  - how many Julia nesting routes retain their engine after rejection
  - why can Julia emitted module loading warn despite invokelatest calls
  - how does the Julia nesting checker distinguish booleans and numbers
date: 2026-09-27
status: bounded carrier proof verified
tags: [language-readiness, julia, generated-source, recovery, spans]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4 passes30 new nesting,65 existing emitter and128 strict-document assertions. Five routes each execute40 original calls and three mutations; two retained engines prove28 recoveries. Fresh child exact report and cleanup pass; storage remains22 owners/five packages."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/source_emitter_test.jl"); include("julia/test/sexpr_document_v1_test.jl")'"
---

Native and SpecFile-JSON reconstructed engines retain their instance across rejection/recovery. Public generated
v2 runs on each compiled form, plus a fresh emitted host, construct an engine per invocation: three more routes,
without a same-engine recovery claim. The proof uses public APIs and no private generated-family runtime keyword.
Shared JSON checks distinguish Bool from Number and require exact values/spans. Every rejection must throw typed
RuntimeExitNow status1; a successful nothing cannot pass. Prefix/gap/span mutations expose the intended bad behavior.

The first new child harness used getfield directly after Base.include inside a running function. Julia1.12 warned
that the parser, metadata, plan, validate_plan and execute bindings belonged to a newer world, polluting its otherwise
successful report. Calling the retrieved function with invokelatest alone was insufficient. The established emitter
subset pattern fixes both access and invocation: `Base.invokelatest(() -> Core.getglobal(owner, name))` retrieves
the binding, then invokelatest invokes it. Captured warnings and initial29/30 failure are retained in the checkpoint.
The final30/30 child report is exact; no warning stripping or relaxed status checks were added.

The existing emitter test file owns scratch and reuses its offline private-depot host; all four emitted modules
execute in a fresh process with validated v2 metadata/plans and verified cleanup. Runtime, manifests and authored
fixture bytes are unchanged. [[nested-tree-readiness-reconciliation]] records the completed cross-runtime evidence and bounded milestone.
Related: [[nested-tree-public-native-readiness]], [[julia-generated-source-scaffold]], [[julia-project-data-ssd-storage]].
