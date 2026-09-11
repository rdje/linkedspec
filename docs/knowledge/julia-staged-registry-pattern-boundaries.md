---
id: julia-staged-registry-pattern-boundaries
title: Julia staged registry pattern validation diverges from the neutral authority
answers:
  - "does Julia staged registry reject trailing newlines in identities and digests"
  - "does Julia staged registry validate every allowed top rule"
  - "does Julia staged parser identity accept digit-led path components"
  - "which task owns Julia staged registry pattern repairs"
date: 2026-09-11
status: confirmed private boundary defects; JULIA-STARTUP-READING.2.13 repair pending
tags: [julia, staged-parsing, registry, identity, validation, startup]
evidence: "JULIA-STARTUP-READING.1.21; activation bd95e0fee7556b5e41d7899b7fcb437a2e3f0028; StagedAstEnrichment489-1988 read physically in six untruncated windows."
reverify: "Run the exact managed recipes below; source coverage is independently reconstructed by julia-startup-reading-coverage."
---

# Staged registry validation boundaries

The existing [[julia-staged-ast-enrichment-current-depth-authority]] and
[[julia-staged-ast-enrichment-recursive-authority]] remain the architecture owners.
Reading 489-1988 covers copied finite acyclic plain data; logical snapshot hashing
with opaque callback normalization; frozen exact callback bindings; pure alias,
declaring-relative, ordered-root/provider resolution; version/top/capability/policy
intersection and minimum ceilings; selected-top job identity; eight-field plan-only
cache identity; typed path/provenance ordering; active-lineage decrease predicates;
source rebasing; plan preparation/cache; and the stitch-target validation prefix.
The remaining stitch/scheduler suffix is not credited by this reading.

`StagedAstEnrichment.jl:619-626` uses dollar-anchored `occursin` for parser
identity, top rule and SHA-256 digest. A final LF therefore passes all three.
The parser pattern additionally requires a letter after each separator, whereas
the neutral `PARSER_ID_PATTERN.fullmatch` accepts a digit there: `expr:1` and
`expr/2.spec` are valid neutral identities rejected by Julia's predicate.

Actual private registry and current-depth calls establish that trailing LF in
content digest, import fingerprint, selected default top, authored alias or
resolved parser id survives registry construction and reaches one successful
callback. A sixth malformed snapshot adds unused allowed top `bad-top`; it also
freezes and dispatches an otherwise valid selected top. `_freeze_staged_registry`
validates the default pattern and its membership but never applies the pattern to
every allowed top. Neutral registry validation rejects the five entry mutations;
neutral resolution rejects the malformed alias before lookup. Four malformed
cache fields also produce distinct SHA-256 keys instead of validation errors.

The valid control dispatches once. These are host-supplied private snapshot/cache/
current-depth boundaries, not new authored or generated/emitted reproductions.
The existing 491-assertion staged consumer includes its previously admitted carrier
cases and still passes; its finite fixtures do not establish malformed rejection.
The added Julia diagnostic passes 36 assertions and the neutral diagnostic 14.
Julia `.2.13.1/.2` own complete pattern alignment/all-top validation and supported
boundary recurrence. MCP `.2.4` and progressive `.2.5` retain separate validators.

The first exploratory Julia callback returned an ordinary Dict rather than the
required `_staged_child_success` wrapper; the runtime correctly reported
staged_child_failed after 16 diagnostic assertions. The final saved recipe uses
the existing callback protocol and passes completely. The neutral exploratory
harness first used the filename-only Python wrapper with stdin, then caught the
wrong exception class; the saved recipe uses project_data_run and ContractError.
No source/test changes or repair are inferred from these harness corrections.

## Exact Julia replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READ21'
include("julia/test/staged_ast_enrichment_contract_test.jl")
const J=LinkedSpecJulia
@testset "reading21 staged identity boundaries" begin
 for (value,accepted) in [("expr",true),("expr-v2",true),("expr:1",false),("expr/2.spec",false),("expr\n",true)]
  @test J._staged_valid_parser_identity(value)==accepted
 end
 @test J._staged_valid_top_rule("Expr\n")
 @test J._staged_valid_digest("sha256:"*repeat("1",64)*"\n")
 base=JULIA_STAGED_ENRICHMENT_CONTRACT["cache_cases"][1]["fields"]
 for field in ["normalized_spec_id","content_digest","import_graph_fingerprint","top_rule"]
  fields=deepcopy(base);fields[field]*="\n"
  key=J._staged_cache_identity(fields)
  @test startswith(key,"sha256:")
  @test key!=J._staged_cache_identity(base)
 end
 for kind in ["valid","content_digest","import_graph_fingerprint","default_top_rule","alias","resolved_spec_id","unused_bad_top"]
  snapshot=deepcopy(JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"])
  entry=snapshot["entries"][1]
  parser="expr";top=nothing
  if kind in ("content_digest","import_graph_fingerprint")
   entry[kind]*="\n"
  elseif kind=="default_top_rule"
   entry[kind]*="\n";push!(entry["allowed_top_rules"],entry[kind])
  elseif kind=="alias"
   snapshot["aliases"][1]["authored_id"]*="\n";parser*="\n"
  elseif kind=="resolved_spec_id"
   old=entry[kind];entry[kind]*="\n"
   for row in snapshot["aliases"]
    row["resolved_spec_id"]==old && (row["resolved_spec_id"]=entry[kind])
   end
   for group in snapshot["search_roots"],row in group["candidates"]
    row["resolved_spec_id"]==old && (row["resolved_spec_id"]=entry[kind])
   end
  elseif kind=="unused_bad_top"
   push!(entry["allowed_top_rules"],"bad-top")
  end
  calls=Ref(0)
  callback=(text,context)->begin calls[]+=1;J._staged_child_success(Dict{String,Any}("value"=>"ok")) end
  callbacks=Dict{String,Function}(e["compiled_authority"]=>callback for e in snapshot["entries"])
  registry=J._freeze_staged_registry(snapshot,callbacks)
  @test calls[]==0
  marker=_julia_staged_enrichment_marker("x",0,"replace_marker",nothing,"fail";top_rule=top)
  marker["staged_parse_job_v2"]["parser_spec_id"]=parser
  outcome=J._enrich_staged_current_depth(registry,marker,_julia_staged_enrichment_options())
  @test calls[]==1
  @test outcome.ast==Dict{String,Any}("value"=>"ok")
  println("reading21 registry accepted and dispatched: ",kind)
 end
end
JULIA_READ21
```

## Exact neutral replay

```bash
bash tools/project_data_run.sh python3 - <<'PY_READ21'
import copy,importlib.util,json
from pathlib import Path
spec=importlib.util.spec_from_file_location("staged_read21","tools/check_staged_ast_enrichment_contract.py")
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
c=json.loads(Path("capability_conformance/staged_ast_enrichment_contract.json").read_text())
checks=0
for value,accepted in [("expr",True),("expr-v2",True),("expr:1",True),("expr/2.spec",True),("expr\n",False)]:
 assert bool(m.PARSER_ID_PATTERN.fullmatch(value))==accepted;checks+=1
assert not m.TOP_RULE_PATTERN.fullmatch("Expr\n");checks+=1
assert not m.SHA256_PATTERN.fullmatch("sha256:"+"1"*64+"\n");checks+=1
for kind in ["valid","content_digest","import_graph_fingerprint","default_top_rule","resolved_spec_id","unused_bad_top"]:
 snapshot=copy.deepcopy(c["resolution_snapshot"]);entry=snapshot["entries"][0]
 if kind in ("content_digest","import_graph_fingerprint","resolved_spec_id"):
  entry[kind]+="\n"
 elif kind=="default_top_rule":
  entry[kind]+="\n";entry["allowed_top_rules"].append(entry[kind])
 elif kind=="unused_bad_top":
  entry["allowed_top_rules"].append("bad-top")
 try:
  m.validate_registry(snapshot);accepted=True
 except m.ContractError as error:
  accepted=False;print(kind,str(error))
 assert accepted==(kind=="valid");checks+=1
snapshot=copy.deepcopy(c["resolution_snapshot"]);snapshot["aliases"][0]["authored_id"]+="\n"
assert m.resolve_identity(snapshot,{"declaring_spec_id":"grammar/main.spec","parser_spec_id":"expr\n"})==(None,"staged_parser_identity_invalid");checks+=1
print("reading21 neutral assertions:",checks)
PY_READ21
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
```

