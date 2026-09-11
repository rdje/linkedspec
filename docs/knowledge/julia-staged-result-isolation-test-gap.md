---
id: julia-staged-result-isolation-test-gap
title: Julia staged carrier isolation test mutates a copy and misses shared returned state
answers:
  - "does Julia staged carrier isolation test mutate actual returned results"
  - "why is deepcopy insufficient for a cross-result isolation test"
  - "can the Julia staged detached_probe pass aliased results"
  - "which task repairs Julia staged returned-result isolation coverage"
  - "do the eight probed Julia staged results share their AST objects"
date: 2026-09-11
status: confirmed test-coverage gap; actual AST-kind mutation controls isolate correctly; repair pending
tags: [julia, staged-parsing, testing, isolation, startup, defect]
evidence: "JULIA-STARTUP-READING.1.49 at activation47ea423f55797ff352e720bbadc415babd0741e3; consumer859-861; repair JULIA-STARTUP-READING.2.26."
reverify: "Run the repository-managed JULIA_STAGED_ISOLATION_AUDIT recipe below; no source file is edited."
---

# Ineffective permanent isolation assertion

The production-carrier test builds two results from each of native, reconstructed,
generated-plan and fresh-emitted routes. At
`julia/test/staged_ast_enrichment_contract_test.jl:859`, it deepcopies the first
result, changes the copy's AST kind, then checks that the original results still
have their original kind. That checks the new copy, without challenging aliasing
among the returned values. It cannot substantiate cross-result mutation isolation.

A controlled vector containing eight references to one result passes that exact
copy-and-assert pattern. Direct mutation then changes all eight references, proving
the test's false assurance. Separately, the actual eight returned AST objects have
distinct identities; mutating each actual AST kind leaves all seven sibling results
equal to their before-snapshots. This finite control finds no runtime alias defect.
It does not prove every mutable path or subsequent-execution isolation.

Julia `.2.26` owns permanent direct-result tests, deliberate aliased controls,
relevant nested branches, fresh-execution checks, counterpart audit and book repair.
Startup reading/policy prerequisites still gate source/test changes. Historical
carrier evidence remains intact, with the cross-result claim qualified here.

# Exact diagnostic replay

This injects diagnostics into the existing fully read first four testsets, ending
at931, and closes only their enclosing testset. The unchanged prefix contributes
164 assertions;21 injected diagnostics plus one exact-anchor assertion contribute
22 more. The nested summary reports185; the anchor assertion runs outside it.
No unread consumer suffix or replacement permanent source is executed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_STAGED_ISOLATION_AUDIT'
using LinkedSpecJulia,JSON3,Test
source=join(readlines("julia/test/staged_ast_enrichment_contract_test.jl";keep=true)[1:931])*"\nend\n"
anchor="        detached_probe = deepcopy(first(all_values))"
@test length(findall(anchor,source))==1
probe=raw"""
        @testset "startup .1.49 actual-result isolation diagnostic" begin
            aliased = fill(deepcopy(first(all_values)),8)
            @test all(value === first(aliased) for value in aliased)
            detached = deepcopy(first(aliased))
            detached["ast"]["kind"] = "mutated"
            @test all(value["ast"]["kind"] == "expression" for value in aliased)
            aliased[1]["ast"]["kind"] = "shared-mutation"
            @test all(value["ast"]["kind"] == "shared-mutation" for value in aliased)
            baseline = deepcopy(all_values)
            @test length(unique(objectid(value["ast"]) for value in all_values)) == 8
            for i in eachindex(all_values)
                all_values[i]["ast"]["kind"] = "actual-mutation-$i"
                @test all(j == i || all_values[j] == baseline[j] for j in eachindex(all_values))
                @test all_values[i]["ast"]["kind"] == "actual-mutation-$i"
                all_values[i]["ast"]["kind"] = baseline[i]["ast"]["kind"]
            end
            @test all_values == baseline
            println("isolation diagnostic: old deepcopy check passes8 aliased results; direct mutations isolate8 actual returned ASTs")
        end
"""
include_string(Main,replace(source,anchor=>probe*"\n"*anchor),joinpath(pwd(),"julia/test/staged_ast_enrichment_contract_test.jl"))
JULIA_STAGED_ISOLATION_AUDIT
```
