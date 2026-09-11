---
id: semantic-query-budget-contract-gaps
title: Semantic explain costs and page-only budget diagnostics conflict with declared limits
answers:
  - does semantic explain obey max_relations and max_depth
  - why does a one-record semantic page report a two-record budget reached
  - can semantic explain return more relations than its budget
  - does the neutral semantic evaluator reproduce Julia query budget gaps
  - which task owns semantic query budget contract repair
date: 2026-09-11
status: confirmed Julia and neutral evaluator inconsistencies; shared repair pending
tags: [semantic-introspection, budgets, pagination, julia, neutral-contract, startup-reading]
evidence: "JULIA-STARTUP-READING.1.27 at clean 7b43a264f2f71ca14059b134ff631a4e93c8b042 reads SemanticIndex514-643 and SemanticQuery1-1370. Six native controls pass26 assertions; six complete responses equal the neutral evaluator. SESSION-STARTUP-READING.82.1-.82.4 own contract expectations, neutral repair, bounded backend implementation and transport/public closure."
reverify: "Run the two managed reproduction blocks below; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py."
---

## Exact observed boundaries

Use the unchanged graph fixture and its canonical entry explanation. Costs are
reported logical records/relations/depth, not host CPU or memory consumption.
Julia public raw-neutral queries and the neutral Python evaluator return exactly
the same complete JSON response for each of these six requests.

| Request change from the canonical example | Returned cost records/relations/depth | Complete | Diagnostic |
| --- | --- | --- | --- |
| Default explain | 3 / 2 / 1 | true | none |
| Explain max_relations=1 | 3 / 2 / 1 | true | none |
| Explain max_depth=0 | 3 / 2 / 1 | true | none |
| Explain max_records=1 | 1 / 0 / 0 | false | max_records |
| List all records, page.limit=1 | 1 / 0 / 0 | false | none |
| Same list page, max_records=2 | 1 / 0 / 0 | false | max_records |

The two explain controls exceed a requested relation/depth maximum without an
incomplete response or diagnostic. The final list control says the budget was
reached after returning one record under a two-record limit; it returns the same
`spec:0` next cursor as the page-only control. Explain's record ceiling does work
in the measured one-record control, retaining only the decision.

ADR0049 defines logical costs and incomplete budget prefixes; the neutral
contract exposes the maxima alongside emitted primary/secondary cost accounting.
The public book says a page boundary is not a budget failure and reaching a
record/relation/depth ceiling produces a budget diagnostic. The measured behavior
needs explicit reconciliation with those promises, rather than treating equality
to the neutral oracle as correctness. Shared `.82.1` freezes exact applicable
limits and boundary precedence before changing policy or canonical hashes.

## Causal owners

In `julia/src/semantic/SemanticQuery.jl`, the explain branch beginning906 pages
steps using only `max_records - 1` at926. It then includes every explained_by
relation to returned steps and reports depth1 when a step is returned, without
applying the requested relation/depth ceilings. The neutral evaluator mirrors
this at `tools/check_semantic_introspection_contract.py`1199–1203.

Julia `_semantic_query_page_stream`1049–1066 sets `limited_by_budget` at1057 from
the size of the entire remaining stream, before selecting the smaller page. The
kernel emits the budget warning whenever that flag is set. Neutral `page_stream`
1110–1120 and `evaluate_query`1204–1210 mirror this; the helper computes an
additional reached-boundary reason but the evaluator ignores that reason.

No fresh Perl/Rust/Dart/Lua runtime census, MCP reproduction or source repair is
claimed. `.82.3` requires six-runtime measurement and bounded implementation
children before source changes; `.82.2` owns independent neutral RED/GREEN proof,
and `.82.4` owns carrier/transport/public recurrence. All startup reading/policy
prerequisites remain. Source-correlation `.22`, `.67` and Julia `.2.15` stay distinct.

All nine existing Julia semantic suites pass1,063 assertions. The unchanged
neutral fixture/mutation check still passes six groups, twenty queries and128
mutations at rollout9/0/admission6/0. These fixtures do not test these combined
boundaries. A first private-checker harness passed relative paths to load_json;
its diagnostic formatter expects repository-derived absolute inputs. The corrected
replay uses m.ROOT/path below; no production defect or assertion credit follows
from that harness failure.

## Managed paired reproduction

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JL'
using LinkedSpecJulia, JSON3, Test
contract=JSON3.read(read("capability_conformance/semantic_introspection_contract.json",String),Dict{String,Any})
source=read("capability_conformance/semantic_introspection/graph.spec",String)
index=semantic_index(source;logical_name="graph.spec",source_detail_ceiling=SemanticSourceTextDetail)
base=only(c["request"] for c in contract["query_cases"] if c["id"]=="graph_explain_entry")
rows=Any[]
@testset "Julia .1.27 semantic budget boundaries" begin
 for name in ["explain_default","explain_relations1","explain_depth0","explain_records1","list_page1","list_page1_records2"]
  request=deepcopy(base)
  if name=="explain_relations1";request["budget"]["max_relations"]=1
  elseif name=="explain_depth0";request["budget"]["max_depth"]=0
  elseif name=="explain_records1";request["budget"]["max_records"]=1
  elseif startswith(name,"list_")
   request["operation"]="list";request["subjects"]=Any[];request["page"]["limit"]=1
   name=="list_page1_records2" && (request["budget"]["max_records"]=2)
  end
  response=to_json(semantic_query_neutral(index,request))
  @test response["ok"] && response["snapshot"]["state"]=="compiled"
  cost=response["cost"];codes=[d["code"] for d in response["diagnostics"]]
  if name in ("explain_default","explain_relations1","explain_depth0")
   @test (length(response["records"]),length(response["relations"]))==(3,2)
   @test cost==Dict("records_examined"=>3,"relations_examined"=>2,"depth_reached"=>1)
   @test isempty(codes) && response["page"]["complete"]
  elseif name=="explain_records1"
   @test (length(response["records"]),length(response["relations"]))==(1,0)
   @test codes==["semantic_query_budget_exceeded"]
   @test response["diagnostics"][1]["fields"]["limit"]=="max_records" && !response["page"]["complete"]
  else
   @test length(response["records"])==1 && isempty(response["relations"])
   @test cost==Dict("records_examined"=>1,"relations_examined"=>0,"depth_reached"=>0)
   @test !response["page"]["complete"] && response["page"]["next_after_id"]=="spec:0"
   @test codes==(name=="list_page1" ? String[] : ["semantic_query_budget_exceeded"])
  end
  push!(rows,Dict("case"=>name,"request"=>request,"response"=>response))
  println(name,": ",JSON3.write(Dict("cost"=>cost,"page"=>response["page"],"diagnostics"=>response["diagnostics"])))
 end
end
write(".linkedspec-data/scratch/julia127-query-budgets.json",JSON3.write(rows))
JL
```

```bash
bash tools/project_data_run.sh python3 - <<'PYTHON'
from pathlib import Path
import importlib.util,sys,json
spec=importlib.util.spec_from_file_location('julia127_neutral','tools/check_semantic_introspection_contract.py')
m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)
contract=m.load_json(m.ROOT/'capability_conformance/semantic_introspection_contract.json')
model=m.load_json(m.ROOT/'capability_conformance/semantic_introspection_model.json')
snapshot=next(row for row in model['snapshots'] if row['id']=='graph')
rows=json.loads(Path('.linkedspec-data/scratch/julia127-query-budgets.json').read_text())
assert len(rows)==6 and len({r['case'] for r in rows})==6
for row in rows:
 response=m.evaluate_query(contract,snapshot,row['request'])
 m.validate_response(contract,response,row['case'])
 assert response==row['response'],row['case']
 print(row['case']+': full neutral/Julia response equality')
lookup={r['case']:r for r in rows}
assert lookup['explain_relations1']['response']['cost']['relations_examined']>lookup['explain_relations1']['request']['budget']['max_relations']
assert lookup['explain_depth0']['response']['cost']['depth_reached']>lookup['explain_depth0']['request']['budget']['max_depth']
r=lookup['list_page1_records2'];assert r['response']['cost']['records_examined']<r['request']['budget']['max_records'] and r['response']['diagnostics'][0]['fields']['limit']=='max_records'
print('PASS six full paired responses; two unbounded explain costs and one premature max_records warning match the neutral evaluator')
PYTHON
```

Existing nine-suite replay is the second fence in
[[julia-semantic-regex-call-source-gap]]. No repeated assertion credit is claimed.
