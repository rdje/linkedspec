---
id: julia-callback-helper-recursion-identity-gap
title: Julia uses helper names as callback recursion identities
answers:
  - "why does nested Julia with report codeblock recursion"
  - "can Julia nest distinct map_leaves callbacks"
  - "does Julia preserve bound callback identity through with"
  - "which task owns Julia helper callback recursion identity"
date: 2026-09-11
status: confirmed-open
tags: [julia, callable, codeblock, callback, recursion, startup, defect]
evidence: "JULIA-STARTUP-READING.1.16; activation bfd68cd6ec4dc3a8801ea51e12f2d666f735b275; Interpreter4750/4776,5141/6039,6080; nine native/SpecFile-JSON controls,84 assertions; gated repair .2.8"
reverify: "Run the managed JULIA_CALLBACK_IDENTITY16 fence below; assertions describe the pre-repair behavior."
---

# Helper names are not callback identities

Julia's shared codeblock executor checks and pushes its supplied `name` in
`context.active_codeblocks`. Direct bound calls supply the variable name, but
helper/receiver `with` supplies `with`, and tree callbacks retain their method.
Different anonymous values passed through the same helper therefore collide.
A callback passed by variable also loses its original binding identity there.

| Case | Native and reconstructed outcome |
| --- | --- |
| Single with | value a |
| Nested helper with | false cycle with → with |
| Nested receiver with | false cycle with → with |
| Helper with containing receiver with | false cycle with → with |
| Sequential with | values a, b |
| Nested map_leaves | false cycle map_leaves → map_leaves |
| map_leaves containing reduce_leaves | value [1] |
| Direct bound cb recursion | intended cycle cb → cb |
| Bound cb recursion through with(v, cb) | wrong identity with → with |

All successful controls match at cursor1. All failures are runtime
`codeblock_recursion_unsupported` at `callable_codeblock_invocation` with exact
callable_name and cycle fields. The 18 source/route outcomes pass84 assertions.
They establish false rejection and wrong cycle identity; they do not establish
unbounded recursion escape, exact repeated-body counts, enabled trace closure or
fresh generated/emitted reproduction of this defect.

The existing callable125/contextual118/construction239, map mutation496 and
array2/hash1/function9/tree2 suites pass (992 plus one selected-set equality).
Neutral callable23, mutation167+592 and write105 checks also pass. Their current
fixtures do not cover this callback identity composition. The initial diagnostic
embedded escaped JSON in a Julia raw string and failed before runtime; direct raw
source literals below correct that harness encoding without changing product code.

Julia .2.8.1/.2.8.2 own identity repair and supported-route/public proof after startup
.3/.4/.5. [[dart-callback-helper-recursion-identity-gap]] independently owns Dart
.2.10; [[lua-callable-codeblock-emitted-route-identity]] describes the intended
anonymous-versus-bound distinction in dated Lua evidence. No new Lua run or other
backend conclusion is claimed. The map_leaves! receiver mutation guard is separate.

## Exact replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_CALLBACK_IDENTITY16'
using LinkedSpecJulia, JSON3, Test
rows = [
    ("single_with", raw"""return(with("a") { return(value) })"""),
    ("nested_helper_with", raw"""return(with("outer") { return(with("inner") { return(value) }) })"""),
    ("nested_receiver_with", raw"""return("outer".with() { return("inner".with() { return(value) }) })"""),
    ("nested_mixed_with", raw"""return(with("outer") { return("inner".with() { return(value) }) })"""),
    ("sequential_with", raw"""return([with("a") { return(value) }, with("b") { return(value) }])"""),
    ("nested_tree_map", raw"""return([1].map_leaves() { return([value].map_leaves() { return(value) }) })"""),
    ("mixed_tree_map_reduce", raw"""return([1].map_leaves() { return([value].reduce_leaves(0) { return(num_add(acc, value)) }) })"""),
    ("direct_bound_recursion", raw"""cb = {|v| return(cb(v)) }; return(cb("x"))"""),
    ("helper_bound_recursion", raw"""cb = {|v| return(with(v, cb)) }; return(cb("x"))"""),
]
success=Dict("single_with"=>"a","sequential_with"=>Any["a","b"],"mixed_tree_map_reduce"=>Any[1])
names=Dict("nested_helper_with"=>"with","nested_receiver_with"=>"with","nested_mixed_with"=>"with","nested_tree_map"=>"map_leaves","direct_bound_recursion"=>"cb","helper_bound_recursion"=>"with")
@testset "Julia helper callback recursion identity diagnostic" begin
 for (name,body) in rows
  spec=parse_spec("Top::\n /x/\n E { "*body*" }\n")
  normalized=JSON3.read(JSON3.write(to_json(spec)),Dict{String,Any})
  for (route,carrier) in [("native",spec),("spec_json",from_json(SpecFile,normalized))]
   engine=LinkedSpecRuntimeEngine(compile_spec(carrier));result=nothing
   caught=try result=runtime_parse(engine,"x");nothing catch error;error end
   if haskey(success,name)
    @test caught===nothing
    @test result.value==success[name]
    @test result.matched
    @test result.cursor_codeunit==1
   else
    @test caught isa RuntimeInterpreterException
    diagnostic=to_json(caught.diagnostic)
    @test diagnostic["stage"]=="callable_codeblock_invocation"
    @test diagnostic["code"]=="codeblock_recursion_unsupported"
    @test diagnostic["callable_name"]==names[name]
    @test diagnostic["cycle"]==[names[name],names[name]]
   end
   println(JSON3.write(Dict("case"=>name,"route"=>route,"value"=>result===nothing ? nothing : result.value,"cycle"=>caught===nothing ? nothing : to_json(caught.diagnostic)["cycle"])))
  end
 end
end
JULIA_CALLBACK_IDENTITY16
```
