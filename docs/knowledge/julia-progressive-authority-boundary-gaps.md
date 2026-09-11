---
id: julia-progressive-authority-boundary-gaps
title: Julia progressive nesting can widen grants and its identity patterns admit a final LF
answers:
  - does Julia nested progressive dispatch preserve parent effective authority
  - can a Julia progressive child dispatch after its local remaining budget reaches zero
  - can Julia nested progressive requests widen capabilities and ceilings
  - does Julia progressive parser identity validation reject a terminal newline
  - do Julia progressive top rule and fingerprint patterns use complete matching
  - which repair owns Julia progressive nested authority and pattern validation
  - does Julia enforce direct progressive result and diagnostic limits
date: 2026-09-11
status: confirmed-open; startup .37 and Julia .2.5 own repairs
tags: [julia, progressive, authority, budgets, patterns, startup]
evidence: "JULIA-STARTUP-READING.1.12 reads all1367 BoundedChildParseAuthority lines; native30 nested/14 direct/20 pattern assertions and12 neutral pattern outcomes pass. Existing authority210/carrier62 and neutral116/public60 pass without covering the gaps."
reverify: "Run the native and neutral managed blocks below; these assert pre-repair observations, not desired acceptance."
---

# Exact observed boundaries

Activation: `f9d5b78553cb3e9b5441ede8e0cf2bdec89fc033`.
`julia/src/runtime/BoundedChildParseAuthority.jl:410` checks request lifetime;
the callback at897 forwards new nested arguments directly to the shared invocation.
Safe-point930 and effective-authority1018 consult invocation-wide steps and those
new caller grants, without inheriting the active child's narrower remaining budget
or grants. ADR0080 requires narrowing without extension. Existing startup `.37.1`
already owns this cross-runtime repair; Julia evidence extends the Dart/Perl census.

| Nested case | Observed Julia result |
| --- | --- |
| Outer cost1 consumes its single effective step | Nested cost1 still runs; two calls and8 invocation steps remain |
| Outer has one effective step left | Nested cost1 runs, providing the positive control |
| Outer grants test, steps2, result_nodes1; nested supplies extra and100 ceilings | Inner receives extra/test, both100 ceilings and remaining_steps8 versus outer1 |
| Nested requires extra without widening caller inputs | Capability denial before the inner callback; outer returns typed child failure |

Six direct controls separately show scalar0 accepted, a three-element result under
one node rejected, cost2 under one step rejected and cost11 under ten invocation
steps rejected. The callback can read its supplied source at detail none. Throwing
that source string plus a suffix is rendered by Julia with an opening quote; its
eight-byte retained diagnostic is exactly `"owned-p`. This cap works. Input
visibility alone is not an exposure claim; startup `.37.2` retains the independently
justified outward source-detail review. The first probe expected Dart's unquoted
prefix; inspecting Julia's actual showerror output corrected that expectation.

At1334-1339, parser ID, top-rule and fingerprint validators use dollar-anchored
`occursin`. All accept an otherwise valid string plus LF; CRLF and extra `!` reject.
Four registry/dispatch controls (valid and each malformed field separately) reach
the callback and preserve the exact strings. The neutral checker uses `re.fullmatch`
at `tools/check_progressive_span_dispatch_contract.py:841-845` and rejects every
nonempty suffix. Julia `.2.5.1/.2.5.2` own full matching and supported-carrier proof;
MCP `.2.4` owns its distinct validators. No fresh authored/emitted reproduction,
registry-loading access or repair closure is claimed here.

Existing authority210 and carrier62 tests pass. Neutral governance remains116
mutations/public60. These finite green rows do not cover the combined nested or
terminal-LF controls above. All source bytes remain unchanged.

# Native reproduction

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_PROGRESSIVE_BOUNDARY_PROBE'
using LinkedSpecJulia, JSON3, Test
const P=LinkedSpecJulia.BoundedChildParseAuthority
const source="owned-probe-text"
limits(steps;nodes=1)=P.ProgressiveCeilings(source_detail=P.ProgressiveNone,policy_modes=["fail-only"],max_steps=steps,max_result_nodes=nodes,max_diagnostic_bytes=8)
entry(id,callback,ceiling;caps=["test"],top="Top",fingerprint="sha256:"*repeat("0",64))=P.ProgressiveRegistryEntry(parser_id=id,compiled_authority=callback,fingerprint=fingerprint,allowed_top_rules=[top],capabilities=caps,ceilings=ceiling)
state(registry,token)=P.start_invocation(registry,P.ProgressiveInvocationConfig(sources=Dict("source"=>source),source_id="source",cancellation_token=token,clock=P.ProgressiveClock(()->0),deadline_tick=10,remaining_steps=10,max_depth=3,max_calls=3))
args(id,token,ceiling,cost;caps=["test"],required=String[],top="Top")=P.ProgressiveDispatchArguments(origin="reading-probe",parser_id=id,top_rule=top,span=Dict("source_id"=>"source","start"=>0,"end"=>length(source),"provenance"=>"test"),caller_capabilities=caps,required_capabilities=required,caller_ceilings=ceiling,child_token=token,cost=cost)
@testset "Nested progressive authority diagnostic" begin
 for (name,steps,widen,required,accepted) in [("zero",1,false,false,true),("positive",2,false,false,true),("widen",2,true,true,true),("narrow_control",2,false,true,false)]
  token=P.ProgressiveCancellationToken();outer=limits(steps);wide=limits(100;nodes=100);seen=Dict{String,Any}()
  registry=P.ProgressiveRegistry(entries=[
   entry("outer-v1",request->begin
    seen["outer_remaining"]=request.remaining_steps
    seen["outer_effective"]=P.to_json(request.effective)
    try
     P.dispatch_nested(request,args("inner-v1",token,widen ? wide : outer,1;caps=widen ? ["test","extra"] : ["test"],required=required ? ["extra"] : String[]))
    catch error
     seen["nested_code"]=P.diagnostic_code(error);rethrow()
    end
   end,outer),
   entry("inner-v1",request->begin
    seen["inner_remaining"]=request.remaining_steps
    seen["inner_effective"]=P.to_json(request.effective);0
   end,wide;caps=["test","extra"])
  ])
  invocation=state(registry,token)
  result=try P.dispatch(invocation,args("outer-v1",token,outer,1)) catch error;P.diagnostic_code(error) end
  @test result==(accepted ? 0 : "progressive_child_failed")
  @test seen["outer_remaining"]==steps-1
  @test P.total_calls(invocation)==(accepted ? 2 : 1)
  @test P.remaining_steps(invocation)==(accepted ? 8 : 9)
  if accepted
   @test seen["inner_remaining"]==(widen ? 8 : steps-1)
   @test seen["inner_effective"]["capabilities"]==(widen ? ["extra","test"] : ["test"])
   @test seen["inner_effective"]["max_steps"]==(widen ? 100 : steps)
   @test seen["inner_effective"]["max_result_nodes"]==(widen ? 100 : 1)
  else
   @test seen["nested_code"]=="progressive_capability_denied"
   @test !haskey(seen,"inner_effective")
  end
  println(JSON3.write(Dict("case"=>name,"result"=>result,"remaining"=>P.remaining_steps(invocation),"calls"=>P.total_calls(invocation),"seen"=>seen)))
 end
end
@testset "Direct progressive limits diagnostic" begin
 for (name,callback,cost,expected,remaining) in [("scalar",r->0,1,0,9),("nodes",r->[1,2,3],1,"progressive_result_not_detached",9),("cost",r->0,2,"progressive_budget_exhausted",10),("remaining",r->0,11,"progressive_budget_exhausted",10),("source_view",r->P.view_text(r.source_view),1,source,9),("diagnostic",r->throw(P.view_text(r.source_view)*":"*repeat("x",40)),1,"progressive_child_failed",9)]
  token=P.ProgressiveCancellationToken();ceiling=limits(1)
  invocation=state(P.ProgressiveRegistry(entries=[entry("probe-v1",callback,ceiling)]),token)
  diagnostic=Ref{Any}(nothing)
  result=try P.dispatch(invocation,args("probe-v1",token,ceiling,cost)) catch error;diagnostic[]=P.to_json(error);P.diagnostic_code(error) end
  @test result==expected
  @test P.remaining_steps(invocation)==remaining
  if name=="diagnostic"
   @test diagnostic[]["child_diagnostic"]==string(Char(34),"owned-p")
   @test ncodeunits(diagnostic[]["child_diagnostic"])==8
  end
  println(JSON3.write(Dict("case"=>name,"result"=>result,"remaining"=>remaining,"diagnostic"=>diagnostic[])))
 end
end
@testset "Progressive terminal LF pattern diagnostic" begin
 for (validator,base) in [(P._valid_parser_id,"probe-v1"),(P._valid_top_rule,"Top"),(P._valid_fingerprint,"sha256:"*repeat("0",64))]
  for (suffix,expected) in [("",true),("\n",true),("\r\n",false),("!",false)]
   @test validator(base*suffix)==expected
  end
 end
 for which in ["valid","id","top","fingerprint"]
  id="probe-v1"*(which=="id" ? "\n" : "")
  top="Top"*(which=="top" ? "\n" : "")
  fingerprint="sha256:"*repeat("0",64)*(which=="fingerprint" ? "\n" : "")
  token=P.ProgressiveCancellationToken();seen=Ref{Any}(nothing);ceiling=limits(1)
  callback=request->begin seen[]=Dict("id"=>request.parser_id,"top"=>request.top_rule,"fingerprint"=>request.fingerprint);0 end
  registry=P.ProgressiveRegistry(entries=[entry(id,callback,ceiling;top=top,fingerprint=fingerprint)])
  @test P.dispatch(state(registry,token),args(id,token,ceiling,1;top=top))==0
  @test seen[]==Dict("id"=>id,"top"=>top,"fingerprint"=>fingerprint)
  println(JSON3.write(Dict("pattern_case"=>which,"seen"=>seen[])))
 end
end
JULIA_PROGRESSIVE_BOUNDARY_PROBE
```

# Independent neutral pattern comparison

```bash
bash tools/project_data_run.sh python3 - <<'PY_NEUTRAL12'
import sys,re
sys.path.insert(0,'tools')
from check_progressive_span_dispatch_contract import PARSER_ID_PATTERN,TOP_RULE_PATTERN,REGISTRY_SCHEMA
for key,pattern,base in [('id',PARSER_ID_PATTERN,'probe-v1'),('top',TOP_RULE_PATTERN,'Top'),('fingerprint',REGISTRY_SCHEMA['fingerprint_pattern'],'sha256:'+'0'*64)]:
 for suffix in ['', '\n', '\r\n', '!']:
  actual=re.fullmatch(pattern,base+suffix) is not None
  assert actual==(not suffix),(key,repr(suffix),actual)
print('PASS twelve exact progressive neutral pattern outcomes')
PY_NEUTRAL12
bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py
```
