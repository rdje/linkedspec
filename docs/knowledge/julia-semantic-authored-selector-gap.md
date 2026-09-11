---
id: julia-semantic-authored-selector-gap
title: Julia semantic edge projection mistakes unrelated target text for an authored selector
answers:
  - "can regex or action text make a Julia direct semantic edge indexed"
  - "why does Julia semantic source_form disagree with compiled selector_kind"
  - "does Julia semantic edge projection preserve authored zero versus omitted selector"
  - "can Julia semantic introspection fabricate a selects_regex relation"
  - "which task repairs Julia semantic authored selector identity"
date: 2026-09-11
status: confirmed native metadata defect; repair pending behind startup prerequisites
tags: [julia, semantic-introspection, selectors, source-correlation, startup-reading]
evidence: "JULIA-STARTUP-READING.1.29 at clean 71328d860453dbeaab5c1cc4f4b02bfd15c741d7 completes SemanticStaticProjection and SourceEmitter and reads spec/Ast1-101. Julia .2.18.1/.2 owns typed selector projection and supported-route/public proof. Exact seven-case replay below separates authored selector identity, resolved compiled slot, runtime result and public semantic metadata."
reverify: "Run both managed blocks below and the neutral semantic/generated-source contract checks."
---

## Whole-member search overrides typed authored identity

`julia/src/semantic/SemanticStaticProjection.jl`886 passes complete member text,
target label and resolved index to `_semantic_static_explicit_target_index` at
1046–1053. That helper searches for `Child[0]` anywhere in the member, without
lexical or target-name boundaries. The parsed and compiled edge already retain
`selector_kind` and `authored_selector`, but this projection discards that distinction.

A plain `/x/ -> Child` projects as direct with rule target shape. Adding
`Child[0]` inside the matcher or returned string makes the still-unindexed
compiled edge project as indexed, with regex-slot target shape and a
`selects_regex` relation. Even `OtherChild[0]` inside a string triggers this
substring match. All three cases compile, execute and return a successful,
diagnostic-free public semantic response containing incorrect authored facts.

The guard at736 compares `something(source.target_index,0)` with compiled slot
zero, so it cannot distinguish this false explicit zero from a correctly
omitted selector. Facts at279/284 and relations at380–389 then use the inferred
index. Whole-member source excerpts and byte spans remain exact; truthful
coordinates alone do not establish truthful metadata.

Actual numeric zero and one controls retain their correct indexed form. A
different-index `Child[1]` string on an unindexed edge does not match the helper's
expected zero and remains direct. These controls distinguish authored spelling
from numeric resolution and avoid claiming all target-shaped text has an effect.

Julia `.2.18.1` owns typed selector repair, named/grouped/repeated selector and
lexical-decoy coverage, including model-impact review before any necessary
contract migration. `.2.18.2` owns counterpart census, supported carriers/MCP,
public reconciliation and designated canonical closure. This is separate from
Julia `.2.15` call spans, `.2.16` mixed slots and Dart `.2.22` constructor rejection.
Intake measures native compilation/runtime and raw-neutral public queries only;
it grants no new emitted, reconstructed, observed or transport recurrence.

## Exact managed controls

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
request=Dict{String,Any}("contract"=>"linkedspec-semantic-query-v1","operation"=>"list","subjects"=>Any[],"record_kinds"=>Any[],"relation_kinds"=>Any[],"direction"=>"outgoing","page"=>Dict("after_id"=>nothing,"limit"=>100),"budget"=>Dict("max_records"=>1000,"max_relations"=>2000,"max_depth"=>4),"source"=>Dict("detail"=>"text","include_content_digest"=>false))
cases=[
 ("plain","/x/ -> Child { return(match_text()) }","x","x","unindexed",nothing,"direct"),
 ("explicit_zero","/x/ -> Child[0] { return(match_text()) }","x","x","numeric",0,"indexed"),
 ("explicit_one","/x/ -> Child[1] { return(match_text()) }","x","x","numeric",1,"indexed"),
 ("regex_decoy","/Child[0]/ -> Child { return(match_text()) }","Child0","Child0","unindexed",nothing,"indexed"),
 ("action_decoy","/x/ -> Child { return(\"Child[0]\") }","x","Child[0]","unindexed",nothing,"indexed"),
 ("other_index","/x/ -> Child { return(\"Child[1]\") }","x","Child[1]","unindexed",nothing,"direct"),
 ("label_substring","/x/ -> Child { return(\"OtherChild[0]\") }","x","OtherChild[0]","unindexed",nothing,"indexed"),
]
@testset "Julia .1.29 authored selector controls" begin
 wrong=String[]
 for (name,member,input,value,selector,authored,form) in cases
  source="Top::\n "*member*"\nChild::\n /x/\n /y/\n"
  compiled=compile_spec(parse_spec(source))
  edge=to_json(only(compiled.rules_by_label["Top"].action_edges))
  @test edge["selector_kind"]==selector
  @test edge["authored_selector"]==authored
  @test edge["child_regex_index"]==something(authored,0)
  @test runtime_parse(LinkedSpecRuntimeEngine(compiled),input).value==value
  index=semantic_index(source;logical_name="julia129.spec",source_detail_ceiling=SemanticSourceTextDetail)
  response=to_json(semantic_query_neutral(index,request))
  @test response["ok"] && isempty(response["diagnostics"]) && response["page"]["complete"]
  @test response["snapshot"]["state"]=="compiled" && !response["snapshot"]["has_execution"]
  record=only(r for r in response["records"] if r["kind"]=="edge")
  @test record["id"]=="edge:rule:Top:0"
  @test record["source"]["excerpt"]==member
  span=record["source"]["span"]
  @test String(Vector{UInt8}(codeunits(source)[span["start_byte"]+1:span["end_byte"]]))==member
  @test record["facts"]["source_form"]==form
  @test record["facts"]["target_shape"]["kind"]==(form=="indexed" ? "regex_slot" : "rule")
  relation_request=deepcopy(request);relation_request["operation"]="relations";relation_request["subjects"]=Any[record["id"]]
  relations=to_json(semantic_query_neutral(index,relation_request))
  @test relations["ok"] && isempty(relations["diagnostics"])
  selected=filter(r->r["kind"]=="selects_regex",relations["relations"])
  @test [r["to_id"] for r in selected]==(form=="indexed" ? ["regex:rule:Child:$(something(authored,0))"] : String[])
  @test [r["to_id"] for r in relations["relations"] if r["kind"]=="dispatches_to"]==["rule:Child"]
  selector=="unindexed" && form=="indexed" && push!(wrong,name)
  println(name,": compiled=",selector," authored=",authored," semantic=",form," selects_regex=",length(selected)," runtime=",repr(value))
 end
 @test wrong==["regex_decoy","action_decoy","label_substring"]
end
JL
```

Seven controls pass 99 assertions: three incorrect metadata cases and four
comparisons. All excerpts and independent byte slices remain exact.

## Existing focused composition

This recipe includes the existing emitter's independent generated-host cases,
then the four source/outcome/static semantic suites. Emitter65 plus semantic389
passes454 existing assertions. Neutral semantic6/20/128 stays rollout9/0 and
admission6/0; the generated-source checker retains ten families and census100/0/0.
Their finite success does
not close the new selector defect or any earlier repair.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/source_emitter_test.jl"); include("julia/test/semantic_index_source_foundation_test.jl"); include("julia/test/semantic_index_compilation_foundation_test.jl"); include("julia/test/semantic_index_static_graph_test.jl"); include("julia/test/semantic_index_static_remaining_test.jl")'
```
