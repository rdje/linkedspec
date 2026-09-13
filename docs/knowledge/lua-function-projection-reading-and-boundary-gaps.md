---
id: lua-function-projection-reading-and-boundary-gaps
title: Lua function projection reading confirms retained metadata and caller-copy limitations
answers:
  - "what exact Lua source did startup reading child 29 cover"
  - "does Lua function projection verify payload versions against the contract"
  - "can Lua supplied function nodes retain false source line numbers through execution"
  - "does Lua codeblock function projection mutate caller supplied nodes"
  - "can failed Lua function projection partially change a caller sidecar"
  - "which Lua function frontend and registry APIs accept false options"
  - "does Lua replace an explicitly false function parser with the default"
  - "does the Lua rule label prefix scanner treat false position as omitted"
date: 2026-09-13
status: exact scoped reading complete; metadata, caller-copy and default-validation repairs pending
tags: [lua, functions, projection, source-spans, validation, startup, evidence]
evidence: "LUA-STARTUP-READING.1.29 activates from e38ca093856d4ec749e1ae125b3c10a90f6058ab. All 1500 fragments /50431 bytes are read in eight complete windows. Existing 338 assertions and 166 complete two-host observations pass, with precise malformed acceptances preserved as pending .2.31/.32 and six .2.8 children. Both neutral callable checkers pass. Prior source, guidance, repair evidence and parked named arguments remain intact."
reverify: "Run LUA_FUNCTION_PROJECTION_READING_29 and its managed commands below. This is focused diagnostic reproduction, not a full gate or repair closure."
---

# Exact scope and comprehension

Every scoped byte is read in eight complete untruncated windows:

| Source under lua/src/linkedspec/ | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| unicode_rule_label.lua | 824–920 | 97 /3,198 | a0b3f5320fe92ccddc8349dbd10d279e36ccd1d718bdaf13b99213042edcc609 |
| user_function_definition_parser.lua | 1–235 | 235 /8,305 | 6aa39ca90e4a135c574ff77a47409713906784c66cac4911c7c3e7c58924ca96 |
| user_function_definition_shell.lua | 1–801 | 801 /27,075 | 2769aa36130b6a4d8d541b81e49917e09c181822d9d0f3e27534f62699b0179c |
| user_function_registry.lua | 1–367 | 367 /11,853 | a614c05cd112f6dc7166c0c49fb9275688d06dd4856a39b508319eff7a323ceb |

The shell windows are 1–200, 201–400, 401–600 and 601–801; registry windows are
1–200 and 201–367. The classifier suffix and parser each occupy one window.
Ordered range SHA-256 is
`fac1b1db4576a3c34b6d471313bf0cfa74770a5aa63795210e589fc69fa3e85f`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Coverage reaches 29/51 groups,
39,151 fragments /1,442,482 bytes, with 51 complete files and the registry partial.

The classifier uses byte arithmetic to reject invalid UTF-8 sequences and binary
search over the pinned inclusive ranges. Complete-label validation requires a
nonempty string of admitted scalars. Prefix extraction starts at a one-based byte
position, stops before an invalid/unadmitted scalar and returns the exact bytes
and next position. It does not normalize spelling. Its false-default gap is below;
normal classifier proof from `.1.28` remains dated and source-identical.

The automatic parser locates the bundled grammar relative to its own module,
loads it through the governed exact-path loader with no search roots, and caches
the first successful parse/validate/compile result. Each caller source gets a fresh
runtime engine using the cached grammar and `user_function_definitions` top rule.
Metadata exposes the successful build count and resolved identity. Typed wrapper
stages preserve parser grammar, execution and output-normalization ownership;
projection errors and staged registry errors remain with their original owners.
There is no competing raw `fn` scanner in the automatic parser.

The shell normalizes direct, singleton-wrapped and nested output arrays; verifies
UTF-8 before mapping zero-based Unicode character coordinates to byte boundaries;
checks source/body slices and containment; rejects overlapping definition spans;
and replaces each covered non-CR/LF character with a space before ordinary rule
parsing. It validates fixed-v1, variadic-v2 and final-codeblock metadata against
matching payload/job fields. Parent paths and job identifiers normalize to actual
source-order indexes. The metadata and caller-copy gaps below qualify those checks.
Function names retain their separate ASCII identifier grammar. The named-argument
direction remains approved and parked; this reading adds no syntax or binding.

The registry prefix validates dense top-level definition lists, snapshots typed
records through neutral AST reconstruction, rejects duplicate names, preserves
order and exposes jobs, names, entries and arity resolutions. Fixed signatures
require exact arity; variadic signatures match at or above the minimum and report
`at least N`. Descriptor projection emits fixed v1, variadic v2 or final-codeblock
v3 records. The scoped runtime-value copier handles typed aggregates and reparses
codeblock source; its callers and remaining registry implementation belong to
`.1.30`. This partial registry reading is not complete invocation-frame signoff.

Knowledge retrieval precedes source derivation: [[lua-spec-defined-function-parser]],
[[lua-function-definition-shell-projection]], [[lua-user-function-registry]],
[[lua-variadic-v2-signature-state]], [[lua-final-codeblock-metadata]],
[[lua-fixed-v1-user-function-runtime]] and [[lua-actionir-contract-resolver]].
The source-span question also resolves [[julia-function-projection-metadata-gaps]]
before counterpart diagnosis. Existing `.2.1` gains exact qualification ownership
for stale future descriptor/generated/callable guidance in those function cards,
and for the shell card's defensive-copy statement. Dated milestones remain exact.

# Confirmed function metadata gaps — .2.31

Start from the real bundled parser's fixed node for:

```spec
fn one(value) { return(value) }
Top:: I.return(one("ok"))
```

A changed payload version of `99`, a missing payload version, `false`, or `null`
is retained through supplied-node staging, compilation and execution returning
`ok`. `validate_body_payload` at shell line 423 checks kind and common fields
without a version check. Separately, changing definition/body/payload/job line
spans together to 99 also executes and retains line 99 for this line-1 function;
payload provenance still says line 1. `span_field` at 129 requires positive ordered
lines, and `validate_span_text` at 160 checks character slices without deriving
their source lines. Coherent sidecars therefore do not establish source accuracy.

Twelve cases per host preserve complete before/after input nodes, returned typed
definition JSON or exact error, and runtime value. Five malformed cases and the
clean control are accepted. Changed body text, unmatched job lines, wrong parser,
boolean outer version, boolean outer arity and negative version reject with the
existing typed projection errors. All twelve fixed caller inputs remain exact.
Lua's correct outer boolean rejection is distinct from Julia's Bool/Integer issue.

`.2.31.1` owns payload versions, `.2.31.2` source-derived lines and provenance, and
`.2.31.3` supported-carrier/public proof. Julia `.2.22` gains a qualified counterpart
link without a fresh Julia execution or replacement of its older evidence.
Ordinary source parsing produces clean metadata; the measured malformed carrier is
the public caller-supplied node API. No emitted, CLI/MCP or semantic-query outcome
is inferred from these native projection/staging/compile/runtime observations.

# Confirmed caller mutation — .2.32

Real grammar-produced fixed, variadic and final-codeblock nodes are supplied to
all three public routes: direct projection, rule-shell composition and staged
composition. Fixed and variadic nodes remain unchanged. Every codeblock success
rewrites the caller's outer node and both sidecars: `fixed_params` and
`codeblock_param` disappear, replaced by canonical `params` and `arity`.

A wrong `body_parse_job.parameter_kinds` correctly raises the existing projection
error, but only after the caller's `body_payload` has already been rewritten. The
outer node and job retain their original fields, leaving a partially changed
caller record. All three rejecting routes show that exact partial state.

`project` passes the caller object at shell line 736. `project_function` invokes
`canonicalize_codeblock_definition` before its later sidecar clones. Writes at
249–252 update each sidecar in sequence, then 255–258 update the outer node.
The job failure is reached after payload mutation. Twelve cases per host retain
complete before/after graphs and full projected definitions/errors; no mutation
is inferred merely from reference identity. `.2.32.1` owns detached canonicalization
and `.2.32.2` exact success/failure and direct-consumer proof. Current canonical
outputs and typed failure ownership must be preserved while protecting caller input.

# Confirmed absent-value defaults — .2.8 extensions

Eight public function-related operations accept a whole `false` options value:
parser constructor, parser metadata, automatic node parse, automatic staged parse,
project, rule shell and registry construction from functions or a spec. Nil and
empty tables are valid; true, zero and text reject with the established typed
owners. The causes are `options or {}` at definition parser 59/75, shell 713/764
and registry 167. `.2.8.21/.22` own this connected function-option surface and proof.

The optional parser object also maps `false` to the cached parser at parser line
177, whereas true/zero/text reject `expected UserFunctionDefinitionAstParser`.
`.2.8.23/.24` own absent-only parser selection and cache/consumer controls.
The private rule-label scanner similarly maps `position=false` to byte 1 at
classifier line 905: `take_rule_label_prefix("Top!", false)` returns `Top, 4`,
just like omission or 1. True/zero/text follow the existing nil-label invalid-
position convention. `.2.8.25/.26` own the generated classifier and its generator.
This is a private byte-position API; it is not a new function-name grammar rule.

The 59 complete observations per host retain route, case, exact result or typed
error; the default parser build count remains 1. Valid default behavior and the
invalid-position return convention remain compatibility controls for repairs.

# Focused verification and limits

Eleven unchanged selected tests pass 169 assertions per installed host, 338 total:
fixed/variadic union, variadic drift, codeblock metadata/drift, Unicode projection,
error/sidecar ownership, nested output shapes, automatic composition, typed parser
failures, overlap rejection, and registry order/jobs/arity. The diagnostic test
reads and executions do not advance their later physical source owners.

Neutral signatures pass three definitions, nine calls and seven invalid
definitions. Neutral callable codeblocks pass seven literals, eleven calls,
nine invalid literals, seven invalid calls, four invalid declarations, eight
contextual forms and 23 governance mutations. The previous classifier assertions
are not run or counted again: five direct proof inputs remain byte-identical to
the `.1.28` commit. All current observations use installed PUC 5.5.1 and LuaJIT,
not the still-pending declared PUC 5.4 target.

The full two-host diagnostic JSON compares exactly: 48 projection/metadata
observations and 118 option/position observations, 166 total. Independent checks
verify accepted/rejected cases, retained payload types and lines, unmodified fixed
inputs and the exact whole-node mutation delta, including partial failure state.
Complete canonical per-host JSON SHA-256 values are:

- Projection: `67239bcbaa782f1d85976e0cff80483260fa94fecd25d6698fbe0065edad209d`.
- Optional boundaries: `17abf58ff7efb8bcdf5a7704adab4098881f141940962d4e7544ebb302f6c3ca`.

No production source/tool or old fact card changes, canonical gate, dependency
build, push or repair closure is claimed. All thirty-two repair roots and earlier
failures remain open. Next `.1.30` reads registry 368–539, body-fluent test 1–137,
callable-codeblock test 1–950 and diagnostic-output test 1–241. Startup/ADR0118
and the parked authoring direction remain unchanged.

## Exact reproduction

```bash
bash tools/project_data_run.sh python3 - <<'LUA_FUNCTION_PROJECTION_READING_29'
from pathlib import Path
p = Path(".linkedspec-data/scratch/lua129")
p.mkdir(parents=True, exist_ok=True)
(p / 'projection.lua').write_text('local linked = require(\'linkedspec\')\nlocal json = require(\'linkedspec.json\')\nlocal ast = require(\'linkedspec.spec_ast\')\nlocal source = \'fn one(value) { return(value) }\\nTop:: I.return(one("ok"))\\n\'\nlocal function clone(value) return json.decode(json.encode(value)) end\nlocal original = linked.parse_user_function_definition_asts(source)\nassert(#original == 1)\nlocal output = json.harray({metadata=json.array(), mutation=json.array()})\nlocal function result_record(name, operation, nodes)\n  local before = clone(nodes)\n  local ok, result = pcall(operation)\n  local record = json.harray({case=name, accepted=ok, before=before, after=clone(nodes),\n    changed=json.encode(before) ~= json.encode(nodes)})\n  if ok then record.result=result\n  else record.error=tostring(result); record.projection_error=linked.is_user_function_projection_error(result) end\n  return record\nend\nfor _, name in ipairs({\'clean\',\'payload_version\',\'payload_version_missing\',\'payload_version_false\',\n    \'payload_version_null\',\'false_lines\',\'body_text\',\'job_lines\',\'job_parser\',\'version_true\',\n    \'arity_true\',\'version_negative\'}) do\n  local nodes=clone(original);local n=nodes[1]\n  if name==\'payload_version\' then n.body_payload.version=99\n  elseif name==\'payload_version_missing\' then n.body_payload.version=nil\n  elseif name==\'payload_version_false\' then n.body_payload.version=false\n  elseif name==\'payload_version_null\' then n.body_payload.version=json.null\n  elseif name==\'false_lines\' then\n    for _, span in ipairs({n.source_span,n.body_span,n.body_payload.source_span,n.body_parse_job.source_span}) do\n      span.line_start=99;span.line_end=99\n    end\n  elseif name==\'body_text\' then n.body_source=\'return("drift")\'\n  elseif name==\'job_lines\' then n.body_parse_job.source_span.line_start=99;n.body_parse_job.source_span.line_end=99\n  elseif name==\'job_parser\' then n.body_parse_job.parser_spec_id=\'other.spec\'\n  elseif name==\'version_true\' then n.version=true\n  elseif name==\'arity_true\' then n.arity=true\n  elseif name==\'version_negative\' then n.version=-1 end\n  output.metadata[#output.metadata+1]=result_record(name,function()\n    local spec=linked.parse_spec_with_staged_user_function_definition_asts(source,nodes)\n    local compiled=linked.compile_spec(spec)\n    local result=linked.runtime_execute(linked.runtime_engine(compiled),\'\')\n    return json.harray({definition=ast.to_json(spec.functions[1]),value=result.value})\n  end,nodes)\nend\nlocal sources={\n  fixed=\'fn one(value) { return(value) }\\nTop:: I.return("ok")\\n\',\n  variadic=\'fn all_values(...items) { return(items) }\\nTop:: I.return("ok")\\n\',\n  codeblock=\'fn apply(value, callback: codeblock) { return(value) }\\nTop:: I.return("ok")\\n\',\n}\nfor _, kind in ipairs({\'fixed\',\'variadic\',\'codeblock\',\'codeblock_job_drift\'}) do\n  local text=sources[kind==\'codeblock_job_drift\' and \'codeblock\' or kind]\n  local base=linked.parse_user_function_definition_asts(text)\n  for _, route in ipairs({\'project\',\'shell\',\'staged\'}) do\n    local nodes=clone(base)\n    if kind==\'codeblock_job_drift\' then nodes[1].body_parse_job.parameter_kinds=json.harray({value=\'codeblock\'}) end\n    output.mutation[#output.mutation+1]=result_record(kind..\':\'..route,function()\n      local projected\n      if route==\'project\' then projected=linked.project_user_function_definition_asts(text,nodes)\n      elseif route==\'shell\' then projected=linked.parse_spec_with_user_function_definition_asts(text,nodes)\n      else projected=linked.parse_spec_with_staged_user_function_definition_asts(text,nodes) end\n      return ast.to_json(projected.functions[1])\n    end,nodes)\n  end\nend\nio.write(json.encode(output),\'\\n\')\n')
(p / 'options.lua').write_text('local linked=require(\'linkedspec\')\nlocal json=require(\'linkedspec.json\')\nlocal labels=require(\'linkedspec.unicode_rule_label\')\nlocal source=\'Top:: I.return("ok")\\n\'\nlocal spec=linked.parse_spec(source)\nlocal handle=assert(io.open(\'specs/user_function_definition.spec\',\'rb\'))\nlocal grammar=handle:read(\'*a\');handle:close()\nlocal routes={\n  {\'parser-constructor\',function(v)return linked.user_function_definition_ast_parser_from_spec_source(grammar,v)end},\n  {\'parser-metadata\',function(v)return linked.user_function_definition_parser_metadata(v)end},\n  {\'parse-nodes\',function(v)return linked.parse_user_function_definition_asts(source,nil,v)end},\n  {\'parse-staged\',function(v)return linked.parse_spec_with_staged_user_function_definitions(source,nil,v)end},\n  {\'project\',function(v)return linked.project_user_function_definition_asts(source,json.array(),v)end},\n  {\'shell\',function(v)return linked.parse_spec_with_user_function_definition_asts(source,json.array(),v)end},\n  {\'registry-functions\',function(v)return linked.user_function_registry_from_functions({},v)end},\n  {\'registry-spec\',function(v)return linked.user_function_registry_from_spec(spec,v)end},\n}\nlocal cases={{name=\'absent\'},{name=\'empty\',value={}},{name=\'false\',value=false},\n  {name=\'true\',value=true},{name=\'zero\',value=0},{name=\'text\',value=\'options\'}}\nlocal records=json.array()\nfor _,route in ipairs(routes)do\n  for _,case in ipairs(cases)do\n    local ok,result=pcall(route[2],case.value)\n    local row=json.harray({route=route[1],case=case.name,accepted=ok})\n    if ok then\n      if route[1]==\'parser-constructor\' then row.value=linked.user_function_definition_parser.node_type(result)\n      elseif route[1]==\'parser-metadata\' then row.value=result.build_count\n      elseif route[1]==\'parse-nodes\' then row.value=#result\n      elseif route[1]==\'registry-functions\' or route[1]==\'registry-spec\' then row.value=#result:names()\n      elseif route[1]==\'project\' then row.value=#result.functions\n      else row.value=#result.rules end\n    else row.error=tostring(result) end\n    records[#records+1]=row\n  end\nend\nfor _,case in ipairs({{name=\'absent\'},{name=\'false\',value=false},{name=\'true\',value=true},\n  {name=\'zero\',value=0},{name=\'text\',value=\'parser\'}})do\n  local ok,result=pcall(linked.parse_user_function_definition_asts,source,case.value)\n  local row=json.harray({route=\'optional-parser\',case=case.name,accepted=ok})\n  if ok then row.value=#result else row.error=tostring(result)end\n  records[#records+1]=row\nend\nfor _,case in ipairs({{name=\'absent\'},{name=\'false\',value=false},{name=\'true\',value=true},\n  {name=\'zero\',value=0},{name=\'text\',value=\'1\'},{name=\'one\',value=1}})do\n  local label,position=labels.take_rule_label_prefix(\'Top!\',case.value)\n  records[#records+1]=json.harray({route=\'label-position\',case=case.name,label=label or json.null,position=position})\nend\nassert(#records==59)\nio.write(json.encode(records),\'\\n\')\n')
(p / 'select-tests.py').write_text('from pathlib import Path\nimport json\nnames = [\'function shell preserves the exact fixed-v1 variadic-v2 signature union\', \'function shell rejects drifting variadic signature records\', \'function shell preserves exact final codeblock parameter metadata\', \'function shell rejects drifting and invalid codeblock declarations\', \'function shell projects spec-owned nodes with Unicode character spans\', \'function shell rejects spec-produced error and drifting sidecars\', \'function shell normalizes nested spec output shapes\', \'spec-defined function parser automatically composes Unicode function shells\', \'spec-defined function parser preserves typed failure ownership\', \'function shell rejects overlapping source spans\', \'user function registry preserves order jobs definitions and exact arity\']\ns = Path(\'lua/test/run.lua\').read_text()\nselection = \'local selected = {\\n\' + \'\'.join((\'  [\' + json.dumps(n) + \'] = true,\\n\' for n in names)) + \'}\\nlocal assertions = 0\\n\'\ns = selection + s\nfor old, new in [(\'local function test(name, operation)\\n\', \'local function test(name, operation)\\n  if not selected[name] then return end\\n\'), (\'local function assert_equal(actual, expected, label)\\n\', \'local function assert_equal(actual, expected, label)\\n  assertions = assertions + 1\\n\'), (\'local function assert_contains(actual, expected, label)\\n\', \'local function assert_contains(actual, expected, label)\\n  assertions = assertions + 1\\n\')]:\n    assert s.count(old) == 1\n    s = s.replace(old, new, 1)\ns += \'\\nassert(total == 11, "selected test count drift")\\nio.write("selected assertions: ", assertions, "\\\\n")\\n\'\nPath(\'.linkedspec-data/scratch/lua129/selected.lua\').write_text(s)\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport copy\nimport hashlib\nimport json\nimport subprocess\n\nroot=Path('.linkedspec-data/scratch/lua129')\npins={'projection':'67239bcbaa782f1d85976e0cff80483260fa94fecd25d6698fbe0065edad209d',\n      'options':'17abf58ff7efb8bcdf5a7704adab4098881f141940962d4e7544ebb302f6c3ca'}\noutputs={}\nfor name,pin in pins.items():\n    hosts=[json.loads((root/(name+'-'+host+'.json')).read_text()) for host in ['puc','luajit']]\n    assert hosts[0]==hosts[1]\n    for actual in hosts:\n        assert hashlib.sha256(json.dumps(actual,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()==pin\n    outputs[name]=hosts[0]\nmetadata=outputs['projection']['metadata'];mutation=outputs['projection']['mutation']\nassert len(metadata)==12 and len(mutation)==12\naccepted={'clean','payload_version','payload_version_missing','payload_version_false','payload_version_null','false_lines'}\nfor row in metadata:\n    assert row['before']==row['after'] and row['changed'] is False\n    assert row['accepted']==(row['case'] in accepted)\n    if row['accepted']:\n        result=row['result'];definition=result['definition'];assert result['value']=='ok'\n        line=99 if row['case']=='false_lines' else 1\n        for field in ['source_span','body_span']:\n            assert definition[field]=={'line_start':line,'line_end':line}\n        assert definition['body_parse_job']['source_span']['line_start']==line\n        assert definition['body_payload']['provenance'][0]['source_span']['line_start']==1\n        if row['case']=='payload_version_missing':assert 'version' not in definition['body_payload']\n        else:\n            expected={'payload_version':99,'payload_version_false':False,'payload_version_null':None}.get(row['case'],1)\n            actual=definition['body_payload']['version'];assert type(actual)==type(expected) and actual==expected\n    else:assert row['projection_error'] is True and row['error'].startswith('UserFunctionDefinitionException: ')\nfor row in mutation:\n    kind,route=row['case'].split(':');assert route in ['project','shell','staged']\n    assert row['accepted']==(kind!='codeblock_job_drift')\n    expected=copy.deepcopy(row['before'])\n    if kind.startswith('codeblock'):\n        n=expected[0]\n        targets=[n['body_payload']] if kind=='codeblock_job_drift' else [n,n['body_payload'],n['body_parse_job']]\n        for target in targets:\n            target['params']=['value','callback'];target['arity']=2\n            del target['fixed_params'];del target['codeblock_param']\n        assert row['changed'] is True\n    else:assert row['changed'] is False\n    assert row['after']==expected\n    if not row['accepted']:assert row['projection_error'] is True and 'body_parse_job must declare only the final parameter as codeblock' in row['error']\noptions=outputs['options'];assert len(options)==59\nfor row in options:\n    route=row['route'];case=row['case']\n    if route=='label-position':\n        admitted=case in ['absent','false','one'];assert row['label']==('Top' if admitted else None)\n        expected=4 if admitted else {'true':True,'zero':0,'text':'1'}[case]\n        assert type(row['position'])==type(expected) and row['position']==expected\n    else:\n        valid=case in ['absent','empty','false'];assert row['accepted']==valid\n        if valid:\n            expected={'parser-constructor':'UserFunctionDefinitionAstParser','parser-metadata':1,'parse-staged':1,'shell':1}.get(route,0)\n            assert row['value']==expected\n        else:assert 'must be a table' in row['error'] or 'expected UserFunctionDefinitionAstParser' in row['error']\nfor row in json.loads((root/'scope.json').read_text()):\n    raw=b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start']-1:row['end']])\n    assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']\nbase='e38ca093856d4ec749e1ae125b3c10a90f6058ab'\npaths=['lua/src/linkedspec/unicode_rule_label.lua','lua/test/unicode_rule_label_classifier_test.lua',\n       'tools/check_unicode_rule_label_contract.py','unicode_case/generate_unicode_rule_label_contract.py',\n       'capability_conformance/unicode_rule_label_contract.json']\nfor name in paths:assert Path(name).read_bytes()==subprocess.check_output(['git','show',base+':'+name])\nreport={'complete_projection_observations':48,'complete_optional_boundary_observations':118,\n        'per_host_metadata_cases':12,'per_host_projection_copy_cases':12,'per_host_options_cases':59,\n        'prior_classifier_proof_inputs_unchanged':len(paths),'digests':pins}\n(root/'verification.json').write_text(json.dumps(report,indent=2)+'\\n');print(json.dumps(report,indent=2))\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/src/linkedspec/unicode_rule_label.lua",\n    "start": 824,\n    "end": 920,\n    "bytes": 3198,\n    "sha256": "a0b3f5320fe92ccddc8349dbd10d279e36ccd1d718bdaf13b99213042edcc609"\n  },\n  {\n    "path": "lua/src/linkedspec/user_function_definition_parser.lua",\n    "start": 1,\n    "end": 235,\n    "bytes": 8305,\n    "sha256": "6aa39ca90e4a135c574ff77a47409713906784c66cac4911c7c3e7c58924ca96"\n  },\n  {\n    "path": "lua/src/linkedspec/user_function_definition_shell.lua",\n    "start": 1,\n    "end": 801,\n    "bytes": 27075,\n    "sha256": "2769aa36130b6a4d8d541b81e49917e09c181822d9d0f3e27534f62699b0179c"\n  },\n  {\n    "path": "lua/src/linkedspec/user_function_registry.lua",\n    "start": 1,\n    "end": 367,\n    "bytes": 11853,\n    "sha256": "a614c05cd112f6dc7166c0c49fb9275688d06dd4856a39b508319eff7a323ceb"\n  }\n]\n')
LUA_FUNCTION_PROJECTION_READING_29
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua129/select-tests.py
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua129/selected.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua129/selected.lua
bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua129/projection.lua > .linkedspec-data/scratch/lua129/projection-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua129/projection.lua > .linkedspec-data/scratch/lua129/projection-luajit.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua129/options.lua > .linkedspec-data/scratch/lua129/options-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua129/options.lua > .linkedspec-data/scratch/lua129/options-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua129/verify.py
```

Related facts: [[lua-startup-reading-coverage]], [[lua-reading-evidence-capacity-admission]],
[[lua-unicode-casing-properties-and-rule-label-reading]].

## Preservation and documentation verification

The independent audit preserves all 1,404 prior source, Knowledge, decision,
immutable-history and policy files. Among 2,564 old task nodes, only this reading
leaf, Lua .2/.2.1/.2.8, startup .3.6 and the Julia .2.22 counterpart annotation
change; the other 2,558 remain exact. Thirteen new nodes are explicitly pending.
Both prior history suffixes, live History query instructions, all 87 earlier Known
book headings and the parked authoring tree remain exact. The book adds two Known
headings, reaching 89. Five embedded payloads equal the executed originals. The
independent range reconstruction reproduces all baseline digests and 29 completed
groups without advancing unread source.

Knowledge regeneration reports 1,115 facts /8,927 question keys. Memory passes at
60 lines. The shared history checker passes 34 mutation controls and all three
surfaces /66 segments. Changes is 417 lines /30,264 bytes and Notes 347 /27,645;
no rollover is needed. The book renders; its 10,119,946-byte search-index warning
remains startup .41.9-owned. `git diff --check` passes. Normal registered hooks
remain required for this focused commit; no pending repair or canonical boundary
is represented as complete.
