---
id: julia-semantic-static-correlation-gaps
title: Julia static semantic projection rejects mixed slot order and conditionally omits entry explanations
answers:
  - why does Julia semantic_index reject a valid rule with mixed regex slots
  - can a Julia parent matcher shift semantic structural slot correlation
  - why does an unused function remove Julia entry explanation records
  - does a single-rule Julia semantic index explain entry selection
  - does Julia preserve out-of-range regex slot diagnostics in semantic queries
  - which tasks fix Julia mixed semantic slots and conditional entry explanations
date: 2026-09-11
status: confirmed public semantic construction and explainability limitations; repairs pending
tags: [julia, semantic-introspection, regex-slots, entry-selection, source-correlation, startup-reading]
evidence: "JULIA-STARTUP-READING.1.28 at clean 76a5299483e47b6494e8353c9b040b504be03760 reads SemanticQuery1371-1587, SemanticRuntimeProjection1-329 and SemanticStaticProjection1-954. Seven typed/runtime/public controls pass67 assertions. Julia .2.16.1/.2 owns mixed-slot correlation and .2.17.1/.2 owns entry explanation contract/implementation; startup .23 retains failure-class census."
reverify: "Run both managed blocks below; no source repair or counterpart/MCP recurrence is claimed."
---

## Mixed structural slot and parent matcher order

A Top rule with `/a/ -> Child { return(match_text()) }` followed by standalone
`/b/`, plus Child's `/a/`, compiles and independently executes input `a` to `"a"`.
Its compiled Top patterns are `["a","b"]`. Public `semantic_index` nevertheless
throws `semantic_static_correlation_failed` at `project_static_semantics`, with
identity Top and slot0. Reversing Top's members preserves execution and permits
semantic construction; its Top structural record is `regex:rule:Top:0`, pattern b,
with exact `/b/` source.

`julia/src/semantic/SemanticStaticProjection.jl`748–769 first filters cross-rule
parent matchers from authored slots. At762 it compares retained slots against the
unfiltered `compiled.regex_patterns` prefix. The parent-first case therefore
compares retained b against compiled a. Existing graph fixtures contain parent
matchers and structural slots in different rules and do not cover this mixed order.
Repair `.2.16.1` must reconcile actual typed ownership/index semantics, not delete
compiler evidence or change expected ordering to bless the current rejection.
`.2.16.2` owns supported carriers, transport, counterpart census and public proof.

## Conditional entry explanations

All three entry controls retain selected entry Top and compile/execute normally.
A two-rule source with no functions exposes an entry decision and two explanation
steps; `explain(spec:0)` returns three records and two relations. A single-rule
source or the same two-rule source prefixed by an unused function has no entry
decision and returns `semantic_query_invalid`, reason `not_explainable`.

The explicit condition at StaticProjection399 requires an empty function list
and more than one compiled rule before calling the entry-explanation builder.
This is separate from the opposite function-empty call-projection guard under
startup `.22`. Repair `.2.17.1` owns a frozen-model/hash impact audit and exact
supported-entry expectations before implementation; `.2.17.2` owns carrier/public
proof. Intake does not silently expand the neutral model or change fixture hashes.

## Positive failure controls and proof limits

The bare missing-rule source preserves native `bare_edge_target_undefined` and
projects the intentional `unknown_rule_reference`, exact Missing source and a
truthful dependency explanation. An existing Child referenced at slot9 preserves
`regex_slot_index_out_of_range` / `resolve_selector` in both native and projected
diagnostics, with exact `/x/ -> Child[9]` source and no fabricated decision or
explanation. Selector validation catches this case before the static normalization
branch; it does not reproduce the distinct Perl failure evidence under startup `.23`.

The seven cases contain three limitation cases and four comparison controls.
Fresh eleven-suite semantic composition passes1,286 assertions, including runtime
capture66 and immutable observation projection157; the prior nine suites contribute
1,063. Neutral semantic validation stays six fixture groups, twenty queries and128
mutations at rollout9/0/admission6/0. Finite success does not close either new repair,
shared budget `.82`, source correlation `.2.15`, or any prior owner. No new emitted,
reconstructed, MCP or other-backend result is claimed.

## Exact managed controls

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
request=Dict{String,Any}("contract"=>"linkedspec-semantic-query-v1","operation"=>"list","subjects"=>Any[],"record_kinds"=>Any[],"relation_kinds"=>Any[],"direction"=>"outgoing","page"=>Dict("after_id"=>nothing,"limit"=>100),"budget"=>Dict("max_records"=>1000,"max_relations"=>2000,"max_depth"=>4),"source"=>Dict("detail"=>"text","include_content_digest"=>false))
cases=[("mixed_parent_first","Top::\n /a/ -> Child { return(match_text()) }\n /b/\nChild::\n /a/\n"),("mixed_slot_first","Top::\n /b/\n /a/ -> Child { return(match_text()) }\nChild::\n /a/\n"),("missing","Top:\n Missing\n"),("slot_range","Top::\n /x/ -> Child[9]\nChild::\n /y/\n"),("single_entry","Top::\n /x/\n"),("multi_entry","Top::\n /x/\nOther::\n /y/\n"),("function_entry","fn unused(value) { return(value) }\n\nTop::\n /x/\nOther::\n /y/\n")]
attempt(f)=try f() catch e;e end
@testset "Julia .1.28 static projection controls" begin
 for (name,source) in cases
  compiled=attempt(()->compile_spec(parse_spec_with_staged_user_function_definitions(source)))
  index=attempt(()->semantic_index(source;logical_name="julia128.spec",source_detail_ceiling=SemanticSourceTextDetail))
  if name in ("missing","slot_range")
   @test compiled isa SpecValidationException
   @test index isa SemanticIndex
   native=to_json(compilation_diagnostic(index))
   response=to_json(semantic_query_neutral(index,request))
   @test response["ok"] && response["snapshot"]["state"]=="failed_compilation"
   diagnostic=only(r for r in response["records"] if r["kind"]=="diagnostic")
   if name=="missing"
    @test native["code"]=="bare_edge_target_undefined"
    @test diagnostic["facts"]["code"]=="unknown_rule_reference"
    @test diagnostic["source"]["excerpt"]=="Missing"
    @test only(r for r in response["records"] if r["kind"]=="explanation_step")["facts"]["rule_code"]=="dependency_target_missing"
   else
    @test native["code"]==diagnostic["facts"]["code"]=="regex_slot_index_out_of_range"
    @test native["stage"]==diagnostic["facts"]["stage"]=="resolve_selector"
    @test diagnostic["source"]["excerpt"]=="/x/ -> Child[9]"
    @test !any(r["kind"] in ["decision","explanation_step"] for r in response["records"])
   end
   println(name,": distinct native/projected diagnostic and exact authored source")
   continue
  end
  @test compiled isa CompiledSpec
  @test runtime_execute(LinkedSpecRuntimeEngine(compiled),startswith(name,"mixed_") ? "a" : "x").value==(startswith(name,"mixed_") ? "a" : nothing)
  if startswith(name,"mixed_")
   @test compiled.rules_by_label["Top"].regex_patterns==(name=="mixed_parent_first" ? ["a","b"] : ["b","a"])
  end
  if name=="mixed_parent_first"
   @test index isa SemanticIndexError
   @test index.code=="semantic_static_correlation_failed"
   @test index.message=="Authored and compiled regex-slot identities differ"
   @test to_json(index)["fields"]==Dict("identity"=>"Top","slot"=>0)
   println(name,": compiled regexes [a,b], runtime a; semantic construction rejects filtered slot b against a")
   continue
  end
  @test index isa SemanticIndex
  @test entry_selection(index).label=="Top"
  @test compilation_diagnostic(index)===nothing
  response=to_json(semantic_query_neutral(index,request))
  @test response["ok"] && response["snapshot"]["state"]=="compiled" && !response["snapshot"]["has_execution"]
  @test isempty(response["diagnostics"])
  decision=[r for r in response["records"] if r["kind"]=="decision" && r["facts"]["decision_kind"]=="entry_selection"]
  expected=name in ("mixed_slot_first","multi_entry")
  @test length(decision)==(expected ? 1 : 0)
  explain=deepcopy(request);explain["operation"]="explain";explain["subjects"]=Any["spec:0"]
  explanation=to_json(semantic_query_neutral(index,explain))
  @test explanation["ok"]==expected
  if expected
   @test length(explanation["records"])==3 && length(explanation["relations"])==2
   @test isempty(explanation["diagnostics"])
  else
   @test isempty(explanation["records"]) && isempty(explanation["relations"])
   @test explanation["diagnostics"][1]["fields"]["reason"]=="not_explainable"
  end
  if name=="mixed_slot_first"
   slot=only(r for r in response["records"] if r["id"]=="regex:rule:Top:0")
   @test slot["facts"]["pattern"]=="b" && slot["source"]["excerpt"]=="/b/"
  end
  println(name,": entry Top retained; entry explanation ",expected ? "available" : "absent/not_explainable")
 end
end
JL
```

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e '
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
include("julia/test/semantic_index_source_foundation_test.jl")
include("julia/test/semantic_index_compilation_foundation_test.jl")
include("julia/test/semantic_index_static_graph_test.jl")
include("julia/test/semantic_index_static_remaining_test.jl")
include("julia/test/semantic_index_call_core_test.jl")
include("julia/test/semantic_index_call_staged_test.jl")
include("julia/test/semantic_index_query_kernel_test.jl")
include("julia/test/semantic_index_query_traversal_test.jl")
include("julia/test/semantic_index_query_public_test.jl")
include("julia/test/semantic_index_runtime_observation_test.jl")
include("julia/test/semantic_index_runtime_projection_test.jl")
'
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
```
