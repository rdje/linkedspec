---
id: julia-staged-diagnostic-byte-boundaries
title: Julia staged diagnostic fallback can exceed its retained byte allowance
answers:
  - "can Julia staged diagnostics exceed max_diagnostic_bytes"
  - "does Julia staged truncation fit an exhausted diagnostic allowance"
  - "does Julia reject an exhausted staged call counter before incrementing"
  - "which task owns Julia staged diagnostic byte repair"
date: 2026-09-11
status: confirmed private diagnostic gap; JULIA-STARTUP-READING.2.14 pending
tags: [julia, staged-parsing, diagnostics, budgets, startup]
evidence: "JULIA-STARTUP-READING.1.22; activation7b70255e2986ff4e11c4f0c716adc7de84cafdf0; completes StagedAstEnrichment and StagedParseJobDeclaration, plus UnicodeCaseMapping1-343."
reverify: "Run the exact managed recipe below; julia-startup-reading-coverage owns independent byte reconstruction."
---

# Staged diagnostic accounting

The existing [[julia-staged-ast-enrichment-recursive-authority]] owns scheduling.
Source reading completes target reservation/collision checks, finite acyclic
detachment with live-key rejection, all settlement policies, fresh ephemeral
callback contexts, guarded call admission, cumulative resources and breadth-first
returned-marker queues. Queues come only from detached successful child results
mapped through exact stitch destinations; old markers are not rescanned.
One-depth execution remains a distinct entrypoint without recursive resources.

`_staged_bounded_diagnostic!` at StagedAstEnrichment2435-2462 measures the
canonical compact UTF-8 diagnostic. If oversized, it creates and measures the
context-bearing truncation sentinel, then returns it without another size decision.
Remaining allowance clamps at zero; subsequent siblings still retain sentinels.

| Allowance | Markers | Retained record bytes | Remaining |
| ---: | ---: | ---: | ---: |
| 0 | 1 | rejected before callback | unavailable |
| 1 | 1 | 187 | 0 |
| 64 | 1 | 188 | 0 |
| 256 | 1 | 189 | 67 |
| 4096 | 1 | 1671 | 2425 |
| 64 | 2 | 188 + 187 | 0 |
| 4096 | 2 | 1671 + 1671 | 754 |

These counts exclude the list wrapper and duplicate sidecar copies; even the
narrow record count exceeds three small allowances. The second 64-byte sibling
sentinel records maximum_bytes0. Existing staged tests only check sentinel code
and a zero remainder, not the retained byte count. Julia .2.14 coordinates the
accounting/representation decision with Dart .2.17.1, then owns implementation
and supported-carrier/public proof. No unbounded metadata exemption is inferred.

By contrast, `_staged_dispatch_resource_check` checks total_calls >= max_calls
before adding one. Private ordinary31/32 and maximum-minus-one/maximum controls
dispatch once and reach their limits; exhausted32/32 and Int-maximum/maximum
dispatch zero callbacks and raise staged_call_limit_exceeded. The maximum error
reports a saturated candidate field without admitting the callback. This positive
Julia result does not close Rust startup .75 or Dart .2.18; their separate measured
failures remain in [[rust-staged-call-counter-saturation]] and
[[dart-staged-resource-boundary-gaps]].

StagedParseJobDeclaration validates exact direct/derived record keys and typed
source ownership. Live entry/local whole-match or participating capture ranges
convert through SourceLocation before materialization. Detached markers retain
only logical options, exact text and provenance. UnicodeCaseMapping1-343 reads
the generated Unicode17 metadata and lower table through U+042F; the rest of the
generated module remains unread. [[dart-julia-unicode-17-case-mapping]] owns it.

Existing casing39/typed127/staged491 pass657 assertions plus one selection check.
The private diagnostic/call matrix passes51 assertions over eleven controls.
Neutral Unicode regeneration byte-compares all generated modules, with1563/1581
mappings,158/464 property ranges and12 fixtures; typed231 and staged123/public129
mutations pass. No source, format, data or repair change occurs. The new defect
proof is private recursive-host API only, not fresh authored/emitted recurrence.

## Exact focused replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READ22'
using LinkedSpecJulia,JSON3,Test
const REPO_ROOT=pwd()
selected=0
for expression in Meta.parseall(read("julia/test/runtests.jl",String)).args
 if expression isa Expr && expression.head==:macrocall && expression.args[1]==Symbol("@testset") && expression.args[3]=="Generated Unicode 17 casing and runtime paths"
  Core.eval(Main,expression);global selected+=1
 end
end
@test selected==1
include("julia/test/typed_source_location_contract_test.jl")
include("julia/test/staged_ast_enrichment_contract_test.jl")
const J=LinkedSpecJulia
@testset "reading22 staged diagnostic and call bounds" begin
 for (ceiling,count) in [(0,1),(1,1),(64,1),(256,1),(4096,1),(64,2),(4096,2)]
  calls=Ref(0)
  registry=_julia_staged_enrichment_registry((_request,_context)->begin
   calls[]+=1
   J._staged_child_failure(Dict{String,Any}("code"=>"large_child_failure","detail"=>repeat("x",1024)))
  end)
  options=_julia_staged_enrichment_options()
  options["caller_ceilings"]["max_diagnostic_bytes"]=ceiling
  ast=Dict{String,Any}("nodes"=>Any[
   _julia_staged_enrichment_marker("x",i,"replace_marker",nothing,"keep_text") for i in 0:count-1
  ])
  if ceiling==0
   error=_julia_staged_enrichment_capture(()->J._enrich_staged_recursively(registry,ast,options,_julia_staged_enrichment_recursive_authority()))
   @test _julia_staged_enrichment_error_code(error)=="staged_registry_snapshot_invalid"
   @test calls[]==0
   continue
  end
  result=J._enrich_staged_recursively(registry,ast,options,_julia_staged_enrichment_recursive_authority())
  sizes=[ncodeunits(J._staged_canonical_json(d)) for d in result.diagnostics]
  @test calls[]==count
  @test result.ast==Dict{String,Any}("nodes"=>Any["x" for _ in 1:count])
  @test length(sizes)==count
  @test result.resources.remaining_diagnostic_bytes==max(0,ceiling-sum(sizes))
  @test (sum(sizes)>ceiling)==(ceiling in (1,64))
  @test all(d["code"]==(ceiling==4096 ? "staged_child_failed" : "staged_diagnostic_truncated") for d in result.diagnostics)
  if count==2 && ceiling==64
   @test [d["maximum_bytes"] for d in result.diagnostics]==[64,0]
  end
  println(JSON3.write(Dict("ceiling"=>ceiling,"markers"=>count,"sizes"=>sizes,"remaining"=>result.resources.remaining_diagnostic_bytes)))
 end
 for (initial,maximum) in [(31,32),(32,32),(typemax(Int)-1,typemax(Int)),(typemax(Int),typemax(Int))]
  calls=Ref(0)
  registry=_julia_staged_enrichment_registry((_request,_context)->begin calls[]+=1;J._staged_child_success("ok") end)
  marker=_julia_staged_enrichment_marker("x",0,"replace_marker",nothing,"fail")
  authority=_julia_staged_enrichment_recursive_authority(;total_calls=initial,max_calls=maximum)
  if initial==maximum
   error=_julia_staged_enrichment_capture(()->J._enrich_staged_recursively(registry,marker,_julia_staged_enrichment_options(),authority))
   @test calls[]==0
   @test _julia_staged_enrichment_error_code(error)=="staged_call_limit_exceeded"
   @test J.to_json(error)["calls"]==(initial==typemax(Int) ? initial : initial+1)
  else
   result=J._enrich_staged_recursively(registry,marker,_julia_staged_enrichment_options(),authority)
   @test calls[]==1
   @test result.resources.total_calls==maximum
   @test result.ast=="ok"
  end
 end
end
JULIA_READ22
bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
```

