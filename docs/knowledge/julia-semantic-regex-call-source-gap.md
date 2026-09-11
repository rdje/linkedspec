---
id: julia-semantic-regex-call-source-gap
title: Julia semantic calls can cite grouped or whitespace-prefixed regex text
answers:
  - can Julia semantic call source point into a regex matcher
  - why does a grouped regex steal the Julia semantic trim call source
  - which task fixes Julia semantic regex call source correlation
  - does Julia semantic projection retain calls inside arrays
  - does Julia reproduce semantic false arity acceptance or repeated binding identities
date: 2026-09-11
status: confirmed public query counterexamples; repair pending behind startup prerequisites
tags: [julia, semantic-introspection, source-correlation, regex, startup-reading]
evidence: "JULIA-STARTUP-READING.1.26 reads SemanticCallProjection1012-1526, SemanticCompilationOutcome1-472 and SemanticIndex1-513 at clean 0a7d2cdf26542c674831b988d1e774ef586bc37b. Twelve public-query and separate typed/runtime controls pass92 diagnostic assertions, confirming three wrong call/binding source cases. Repair .2.15.1/.2 owns implementation and supported-route/public proof."
reverify: "Run the two managed blocks below; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py."
---

## Confirmed source mismatch

The caller supplies an unused function, bypassing the separate
[[semantic-rule-calls-empty-function-gate]], and a Top self-edge whose action is
`value = trim(" x "); return(value)`. Every valid control compiles, returns a
successful diagnostic-free public query, and separately executes to its expected
value. Semantic construction/query does not execute the caller target.

| Matcher | Returned call and binding bytes | Actual typed RHS bytes | Result |
| --- | --- | --- | --- |
| `/trim(x)/` | 70–81, `trim(" x ")` | 70–81 | Correct control |
| `/(trim(x))/` | 45–52, `trim(x)` | 72–83 | Wrong source |
| `/(?:trim(x))/` | 47–54, `trim(x)` | 74–85 | Wrong source |
| `/ trim(x)/` | 45–52, `trim(x)` | 71–82 | Wrong source |

Coordinates are zero-based half-open UTF-8 bytes for the exact embedded sources.
All four independent executions return `"x"`; the whitespace matcher receives
`" trimx"`, while the other regex cases receive `"trimx"`.

The cause is explicit in `julia/src/semantic/SemanticCallProjection.jl`:

- The action owner supplies the complete authored member range at line1057.
- `_semantic_call_scan_sites` at1337 scans that range, including its matcher.
- `_semantic_call_regex_start` at1436–1447 rejects a slash followed by `(` or
  ASCII whitespace at1438, so these valid matcher prefixes do not enter regex state.
- `_semantic_call_take!` at1449 selects the next matching name from those sites.
  The matcher occurrence is therefore registered for the actual typed action
  call, then copied into its binding source by the statement projector.

This is narrower than Dart's missing regex scanner, tracked separately by Dart
`.2.20`; the Julia plain `/trim(x)/` control works. Repair `.2.15.1` owns complete
lexical/typed action correlation and independent RED/GREEN source expectations.
`.2.15.2` owns supported carrier, ceiling, transport, counterpart and public proof.
No source repair, new MCP result or reconstructed/emitted result is claimed here.

## Bounded neighboring controls

The twelve controls contain three new source-miscorrelation cases, one existing
aggregate-source defect and eight positive/arity-rejection controls. Direct,
nested and string-decoy calls cite their typed RHS correctly. Four same-name
assignments retain four distinct binding IDs and excerpts. Wrong zero/two arity
rejects typed contracts, semantic construction and separate runtime execution;
exactly one argument succeeds. These do not reproduce the earlier Perl/Rust
false-acceptance or Rust repeated-binding identity failures.

The Julia array control retains its nested trim call and returns `["x"]`, unlike
the dated Perl/Rust/Dart omission. Its aggregate binding source remains null:
`emit_statement` receives no outer emitted call from the aggregate visitor. This
remains a binding-source defect owned by startup `.67.2`, whose acceptance
requires the RHS source independently of outer call emission. Correct nested-call
traversal grants no general source or container signoff. Callable/lifecycle and other composite surfaces remain outside
these controls. Prior `.22`, `.66`, `.67` and all Julia repairs remain open.

All nine existing semantic suites pass1,063 assertions: source135, outcome85,
static70, remaining99, call79, staged62, kernel100, traversal118 and public315.
Neutral semantic validation remains six fixture groups, twenty exact queries,
128 rejected mutations, rollout9/0 and admission6/0. Existing finite fixture
success does not cover the three wrong-source cases. Production source remains
identical to baseline baeb984e36a94a15951cd23d4c52def5064cdaca.

## Exact managed reproduction

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
request=Dict{String,Any}("contract"=>"linkedspec-semantic-query-v1","operation"=>"list","subjects"=>Any[],"record_kinds"=>Any[],"relation_kinds"=>Any[],"direction"=>"outgoing","page"=>Dict("after_id"=>nothing,"limit"=>100),"budget"=>Dict("max_records"=>1000,"max_relations"=>2000,"max_depth"=>4),"source"=>Dict("detail"=>"text","include_content_digest"=>false))
edge(rhs;pattern="x")="Top::\n /$pattern/ -> Top { value = $rhs; return(value) }\n"
unused="fn unused(value) { return(value) }\n\n"
normal="fn normalize(value) { return(trim(value)) }\n\n"
cases=[("direct",unused*edge("trim(\" x \")"),"x","x"), ("plain_regex",unused*edge("trim(\" x \")";pattern="trim(x)"),"trimx","x"), ("group_regex",unused*edge("trim(\" x \")";pattern="(trim(x))"),"trimx","x"), ("noncapture_regex",unused*edge("trim(\" x \")";pattern="(?:trim(x))"),"trimx","x"), ("space_regex",unused*edge("trim(\" x \")";pattern=" trim(x)")," trimx","x"), ("array",unused*edge("[trim(\" x \")]"),"x",Any["x"]), ("nested",unused*edge("trim(trim(\" x \"))"),"x","x"), ("string",unused*edge("trim(\"trim(x)\")"),"x","trim(x)"), ("repeated",unused*"Top::\n /x/ -> Top { value = trim(\" 0 \" ); value = trim(\" 1 \" ); value = trim(\" 2 \" ); value = trim(\" 3 \" ); return(value) }\n","x","3"), ("arity_zero",normal*edge("normalize()"),"x",nothing), ("arity_one",normal*edge("normalize(\" x \")"),"x","x"), ("arity_two",normal*edge("normalize(\" x \", \" y \")"),"x",nothing)]
@testset "Julia .1.26 public query and separate typed/runtime controls" begin
 for (name,source,input,expected) in cases
  spec=parse_spec_with_staged_user_function_definitions(source)
  validate_spec(spec)
  compiled=compile_spec(spec)
  payload=only(compiled.rules_by_label["Top"].action_edges).action_payload
  if name in ("arity_zero","arity_two")
   @test !payload.contracts.ok
   err=try semantic_index(source;logical_name="julia126.spec",source_detail_ceiling=SemanticSourceTextDetail);nothing catch e;e end
   @test err isa SemanticIndexError
   @test err.code=="semantic_call_correlation_failed"
   @test err.message=="Compiled action owner has unresolved typed contracts"
   @test_throws RuntimeInterpreterException runtime_execute(LinkedSpecRuntimeEngine(compiled),input)
   println(name,": typed contracts and semantic construction reject; runtime rejects")
   continue
  end
  @test payload.contracts.ok
  @test runtime_execute(LinkedSpecRuntimeEngine(compiled),input).value==expected
  response=to_json(semantic_query_neutral(semantic_index(source;logical_name="julia126.spec",source_detail_ceiling=SemanticSourceTextDetail),request))
  @test response["ok"] && response["snapshot"]["state"]=="compiled" && !response["snapshot"]["has_execution"]
  @test isempty(response["diagnostics"])
  records=response["records"]
  @test length(unique(r["id"] for r in records))==length(records)
  calls=[r for r in records if r["kind"]=="call" && r["owner_id"]=="edge:rule:Top:0"]
  bindings=[r for r in records if r["kind"]=="binding" && r["owner_id"]=="edge:rule:Top:0"]
  expected_calls=name=="nested" ? ["trim","trim","return"] : name=="repeated" ? ["trim","trim","trim","trim","return"] : name=="arity_one" ? ["normalize","return"] : ["trim","return"]
  @test [r["name"] for r in calls]==expected_calls
  if name in ("group_regex","noncapture_regex","space_regex")
   typed=to_json(first(payload.action_ast.statements).expr)["value"]
   @test typed["kind"]=="call" && typed["source"]=="trim(\" x \")"
   @test first(calls)["source"]["excerpt"]==first(bindings)["source"]["excerpt"]=="trim(x)"
   actual=first(calls)["source"]["span"]
   expected_start=first(findfirst(typed["source"],source))-1
   @test expected_start!=actual["start_byte"]
   @test String(Vector{UInt8}(codeunits(source)[actual["start_byte"]+1:actual["end_byte"]]))=="trim(x)"
   println(name,": wrong call/binding bytes ",actual["start_byte"],"-",actual["end_byte"],"; actual typed RHS ",expected_start,"-",expected_start+ncodeunits(typed["source"]),"; runtime=",JSON3.write(expected))
  elseif name=="array"
   typed=to_json(first(payload.action_ast.statements).expr)["value"]
   @test typed["kind"]=="array_literal" && typed["items"][1]["name"]=="trim"
   @test first(calls)["source"]["excerpt"]=="trim(\" x \")"
   @test first(bindings)["source"]===nothing
   println(name,": nested trim retained; binding source null; runtime=",JSON3.write(expected))
  elseif name=="repeated"
   @test [r["id"] for r in bindings]==["binding:edge:rule:Top:0:value:$i" for i in 0:3]
   @test length(unique(r["source"]["excerpt"] for r in bindings))==4
   println(name,": four distinct binding identities and source excerpts")
  else
   @test first(calls)["source"]["excerpt"]==to_json(first(payload.action_ast.statements).expr)["value"]["source"]
   println(name,": exact call source; runtime=",JSON3.write(expected))
  end
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
'
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
```
