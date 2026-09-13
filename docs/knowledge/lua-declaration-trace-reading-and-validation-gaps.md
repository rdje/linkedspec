---
id: lua-declaration-trace-reading-and-validation-gaps
title: Lua declaration and trace reading identifies provenance admission and error cleanup gaps
answers:
  - "what exact Lua source did startup reading child 25 cover"
  - "does Lua reject original non-string staged provenance fields"
  - "can Lua malformed source_id select a caller-owned runtime placeholder source"
  - "does Lua validate complete derived provenance segment arrays"
  - "does Lua narrow staged registry reject false options"
  - "does Lua trace config reject false options levels and sink modes"
  - "can a failing Lua trace writer replace the original typed error"
  - "does Lua trace support close scopes after invalid success details"
  - "which tasks own Lua provenance and trace cleanup repairs"
date: 2026-09-13
status: exact reading complete; provenance and trace repairs remain pending
tags: [lua, startup, staged-parsing, provenance, trace, validation, unicode]
evidence: "LUA-STARTUP-READING.1.25; clean activation 813b2aad2bda623b4e08f3e48d27f9216a47701e. Five exact ranges /1500 fragments /51794 bytes in nine complete windows. Five selected tests pass 134 assertions per installed host, 268 total. Independent verification pins 164 complete observations and nineteen neutral provenance controls. New .2.29/.2.30 own provenance and trace repairs; .2.8.17-.20 own registry and trace admission. No source changed."
reverify:
  - "Run LUA_DECLARATION_TRACE_READING_25 and the managed commands below; these pin dated pre-repair observations."
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py"
---

# Exact coverage and comprehension

Source baseline `baeb984e36a94a15951cd23d4c52def5064cdaca` is unchanged.
This group contains 1,500 fragments /51,794 bytes with ordered range SHA-256
`33b109f98ff932383f2a394953080da8776680afaea6b634f5d6a3d75ca80d81`.

| Repo-root source | Inclusive lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/staged_parse_job.lua` | 50–264 | 7484 | `f0eef79a67992ec68c48d391e337c72fab19d5e1a14834a08f4c11f138694db7` |
| `lua/src/linkedspec/staged_parser_registry.lua` | 1–567 | 19670 | `505372f922a8429a26ef0d52f46286d72a7f1c6c833f4773ac0526ce9aa60d6c` |
| `lua/src/linkedspec/trace.lua` | 1–500 | 18848 | `b8eca0546b66b0312e70d77f083135556365e88a2b138bc66b36b543ae84a183` |
| `lua/src/linkedspec/trace_support.lua` | 1–49 | 1723 | `a984de248c22dfe4a9127c0e43ca1316df65192c80d0ad1e0f8c99bda0d46cc7` |
| `lua/src/linkedspec/unicode_case_mapping.lua` | 1–169 | 4069 | `e926fe50343cc9b797315926462b10f4e67ac2a3b76188791a7f6c6097fbfb68` |

The nine complete viewing windows are declaration 50–264; registry 1–200,
201–400, 401–567; trace 1–200, 201–400, 401–500; trace support 1–49; Unicode 1–169.
Reading totals 25/51 groups, 33,151 fragments /1,286,750 bytes: 47 complete files
and the partial generated mapping. The Unicode prefix includes exact lower-case
entries through U+01CF → U+01D0; regeneration grants no unread-source credit.

The declaration suffix translates typed-source errors into attributed staged
errors, reconstructs direct/ordered derived provenance, and materializes text
through caller-owned source authority. Capture-backed declarations recover stored
byte pairs and convert them to typed scalar positions. They return inert markers
and normalized sidecars; declaration itself does not dispatch a child parser.

The narrow registry normalizes jobs, validates dense queues and sorts stable
path/span/job/input identities. It resolves only the built-in ActionIR body
adapter, records the neutral compilation identity and executes the existing
action parser. Function dispatch validates sidecar/definition identity, fixed,
variadic and contextual metadata, rejects duplicates, and immutably stitches
body ASTs. This provider is distinct from the general staged registry/recursive
enrichment engine read in earlier groups.

Trace levels, sink modes, configurations, events and scopes are immutable typed
values with weak private stores. Numeric thresholds must be finite integers;
aliases, environment fallback, routed/mirrored files, reset/append behavior,
ordered events, rendering, filters and indentation share one emitter. The support
wrapper adds phase scopes around single-result pipeline operations. File reset
requested explicitly at emitter construction remains intentional even when quiet;
the admission probe below creates no file sink.

Before diagnosis, retrieved [[lua-staged-function-body-registry]],
[[lua-staged-function-execution-split]], prior staged marker/current-depth/recursive
cards, [[lua-trace-controls-sinks]], [[lua-native-full-pipeline-trace]],
[[six-variant-unicode-17-case-parity]], [[dart-staged-provenance-type-validation-gap]],
[[perl-lazy-trace-exception-state-drift]] and [[dart-primary-cli-trace-overflow]].
The Perl exception-state mechanism and Dart numeric-file-preparation issue remain
separate. No new execution of those backends is claimed. Lua `.2.1` owns stale
future/current guidance and qualifications to healthy-writer tracing guarantees;
their historical cards remain byte-exact here.

# Original provenance fields and complete segment arrays

`typed_direct_span` at declaration 65–79 converts malformed source/provenance
fields to diagnostic strings `<runtime>` and `<invalid>` before checking exact
keys, kind, replacement non-emptiness and integer offsets. It omits validation of
the original string types and then uses those diagnostic labels as source data.

Nineteen private host-record cases are compared against the existing neutral
`materialize_provenance` function. Eight malformed records are accepted only by
Lua; eleven valid/rejected controls agree. Sources are entirely caller-owned:
`input = Aé🙂BC` and, where explicitly supplied, `<runtime> = R🙂ST`.

| Original input | Measured Lua result | Neutral result |
| --- | --- | --- |
| Direct provenance null, 7, object or false | Accepts é🙂 with provenance string `<invalid>` | Rejects |
| Derived segment provenance null | Accepts é🙂 with replacement label | Rejects |
| Source ID null, 7 or false with caller source `<runtime>` | Accepts 🙂S from that caller source | Rejects |
| Valid direct or derived input:[1,3) | Exact é🙂 | Agrees |
| Explicit string `<runtime>` / `<invalid>` labels | Exact 🙂S | Agrees |
| Missing/empty label, extra field, string offset, unknown source, reversed span, empty derived array, null source without alias | Typed staged error | Agrees |

Literal placeholder-looking strings remain valid when supplied as strings.
The defect is coercion of a malformed original field, not a forbidden source name.
This is a private module API probe; no path, ambient source, external access or
ordinary authored-spec route is demonstrated. Dart `.2.19` retains its original
seventeen-case evidence; its new task annotation records this independent Lua
confirmation without changing that historical card.

Four additional cases pass tagged or plain segment arrays containing one valid
segment plus an extra false member or sparse index 3 = false. All are accepted
with only one retained segment. Caller tables still report two members and the
added false field. The declaration's `ipairs` loop at 141 copies only the prefix
before typed derived construction, so downstream validation cannot see the lost
member. These host-table shapes are separate from valid JSON arrays.

Lua `.2.29.1` owns original string validation, `.2.29.2` complete segment shape,
and `.2.29.3` independent neutral and actual-carrier verification. Coordinate the
existing `.2.25` density conventions without merging different copying owners.

# Trace and registry option admission

Seven operations each receive omitted, empty, false, true, zero and text options.
Five are narrow registry plural/singular execution, dispatch, stitch and staged
definition parsing; two are trace config/emitter construction. All 42 cases agree
across hosts: the first three succeed with identical values and the other three
reject established errors. Registry line 37 and trace 157/352 replace false with
an empty table before validation.

Nine further controls show false level/sink values become none/stdout through
config, enabled and with helpers (trace 147/149). Direct level/sink parsers and
the environment constructor correctly reject false. False `reset_file` and
`emoji` fields are valid booleans and remain preserved. `.2.8.17/.18` own registry
admission and proof; `.2.8.19/.20` own trace admission and sink compatibility.

# Trace error precedence and scope cleanup

Eight bounded cases per host use in-memory writers and stable error objects.
An operation runs exactly once in each support-wrapper case.

| Case | Observed result |
| --- | --- |
| Quiet operation error | Same original object; no events or writes |
| Healthy active writer, operation error | Same original object; balanced enter/exit |
| Writer throws on exit after operation error | Sink object replaces original object |
| Successful operation and formatter | Returns 7; balanced enter/exit |
| Formatter returns false | Typed-text error; only enter remains; following log is still indented |
| Formatter throws, healthy writer | Same formatter object; balanced enter/exit |
| Public validate_spec with unrecognized body syntax, healthy writer | Original typed validation error |
| Same public validation with writer throwing on exit | Sink object; original validation type lost |

`trace_support.run` invokes exit unprotected at line 23 before rethrowing the
primary error at 24. Sink failure interrupts that rethrow. The invalid computed
formatter type raises at 36 before exit at 38, leaving scope indentation active.
The actual public validation probe demonstrates the first mechanism beyond the
private wrapper. A non-string formatter is a host callback misuse with deficient
cleanup, not an ordinary authored parser failure. Events are stored before writer
dispatch, so retained structured events and successfully delivered output differ
in the sink-failure case. The verifier preserves both observations.

`.2.30.1` owns primary error precedence, `.2.30.2` scope cleanup and `.2.30.3`
independent nested/public-caller proof and documentation. Existing healthy-sink
tests remain valid for their covered cases. No signal, timeout, network endpoint,
unbounded parser execution or full-suite result is involved.

# Focused proof and limits

Five existing tests selected from unchanged `lua/test/run.lua` pass on installed
PUC 5.5.1 and LuaJIT: controls, sinks, full-pipeline trace, narrow registry and
runtime decisions. Instrumented existing equality/contains helpers count 134
assertions each, 268 total; test selection asserts exactly five executed tests.
The exact source-derived selection procedure is embedded below, not the whole
runner. The separate 23 provenance, 8 trace and 51 option observations per host
total 164. Full canonical JSON digests and independent semantic checks retain all
values, identities, diagnostics and events, rather than acceptance flags alone.

Neutral staged governance passes 9 rollout legs /123 mutations plus public129;
typed-source governance passes 14 complete /0 pending /231 mutations. Unicode
17.0.0 regeneration/contract proof passes 1,563 lower, 1,581 upper, 158/464 property
ranges and 12 fixtures. These governance checks are not fresh all-backend runs.
Supported PUC 5.4 proof, known installed-PUC nil-error failures, earlier repair
owners, startup reading/policy gates and dependency-build restrictions remain.
No full CI, production source edits, dependency builds or push occur in this leaf.

The first option fixture used an untagged empty definition list and correctly
failed that distinct constructor boundary. Replacing the fixture with the required
`json.array()` made all three valid parse controls succeed; both hosts were rerun.
An earlier interrupted tool display lost completion statuses; explicit reruns
consumed trace and Unicode completion. Diagnostic fixtures and outputs stay under
the repository-local scratch directory and are recreated by this durable recipe.

## Reproduction

The following payloads pin September 13 pre-repair behavior. A future intentional
repair should update its own evidence, not silently rewrite this dated record.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_DECLARATION_TRACE_READING_25'
from pathlib import Path
p = Path(".linkedspec-data/scratch/lua125")
p.mkdir(parents=True, exist_ok=True)
(p / 'provenance.lua').write_text('local json=require("linkedspec.json")\nlocal source=require("linkedspec.source_location")\nlocal staged=require("linkedspec.staged_parse_job")\nlocal rows=json.array()\nlocal function direct(changes)\n local v=json.harray({kind="direct_span",source_id="input",start=1,["end"]=3,provenance="capture"})\n for key,value in pairs(changes or {})do v[key]=value end\n return v\nend\nlocal function derived(segment)return json.harray({kind="derived_text",policy="concatenate_in_order",segments=json.array({segment})})end\nlocal cases={\n {"valid_direct",direct()}, {"valid_derived",derived(direct())},\n {"null_provenance",direct({provenance=json.null})},\n {"numeric_provenance",direct({provenance=7})},\n {"object_provenance",direct({provenance=json.harray({kind="not_text"})})},\n {"null_source_without_alias",direct({source_id=json.null})},\n {"null_source_with_alias",direct({source_id=json.null}),true},\n {"numeric_source_with_alias",direct({source_id=7}),true},\n {"derived_null_provenance",derived(direct({provenance=json.null}))},\n {"empty_provenance",direct({provenance=""})},\n {"missing_provenance",direct()},\n {"extra_key",direct({text="not_source"})},\n {"string_start",direct({start="1"})},\n {"unknown_source",direct({source_id="absent"})},\n {"reversed_span",direct({start=3,["end"]=1})},\n {"empty_derived",json.harray({kind="derived_text",policy="concatenate_in_order",segments=json.array()})},\n {"literal_placeholders",direct({source_id="<runtime>",provenance="<invalid>"}),true},\n {"false_provenance",direct({provenance=false})},\n {"false_source_with_alias",direct({source_id=false}),true},\n}\ncases[11][2].provenance=nil\nfor _,name in ipairs({"tagged_extra","plain_extra","tagged_hole","plain_hole"})do\n local segments\n if name:sub(1,6)=="tagged" then segments=json.array({direct()})else segments={direct()}end\n if name:sub(-5)=="extra" then segments.extra=false else segments[3]=false end\n cases[#cases+1]={name,json.harray({kind="derived_text",policy="concatenate_in_order",segments=segments}),false,true}\nend\nfor _,case in ipairs(cases)do\n local sources=json.harray({input="Aé🙂BC"});if case[3] then sources["<runtime>"]="R🙂ST" end\n local row=json.harray({case=case[1],alias=case[3]==true})\n if case[4] then\n  local n=0;for _ in pairs(case[2].segments)do n=n+1 end\n  row.segment_members=n;row.segment_host_length=#case[2].segments\n  row.extra_false=case[2].segments.extra==false;row.third_false=case[2].segments[3]==false\n else row.record=case[2]end\n local ok,value=pcall(staged.validate_and_materialize_provenance,source.source_authority({sources=sources}),case[2],"lua125:provenance")\n row.ok=ok\n if ok then row.value=value elseif staged.is_error(value) then row.error=staged.to_json(value)else row.error=tostring(value)end\n rows[#rows+1]=row\nend\nio.write(json.encode(rows),"\\n")\n')
(p / 'trace-failures.lua').write_text('local ls=require("linkedspec")\nlocal json=ls.json\nlocal trace=require("linkedspec.trace")\nlocal support=require("linkedspec.trace_support")\nlocal rows=json.array()\nlocal function token(name)return setmetatable({name=name},{__tostring=function(t)return t.name end})end\nfor _,case in ipairs({"quiet_error","active_error","sink_error","success","formatter_invalid","formatter_error"})do\n local primary=token("primary_failure");local sink_error=token("sink_failure");local format_error=token("formatter_failure")\n local output=json.array();local writes=0;local calls=0\n local config=trace.trace_config_enabled(case=="quiet_error" and trace.TRACE_NONE or trace.TRACE_DEBUG)\n local emitter=trace.trace_emitter(config,{stdout_writer=function(text)\n  writes=writes+1\n  if case=="sink_error" and text:find("[exit]",1,true) then error(sink_error,0)end\n  output[#output+1]=text\n end})\n local fn=function()calls=calls+1;if case:find("_error",1,true) and case~="formatter_error" then error(primary,0)end;return 7 end\n local details="ok"\n if case=="formatter_invalid" then details=function()return false end\n elseif case=="formatter_error" then details=function()error(format_error,0)end end\n local ok,value=pcall(support.run,emitter,"probe","start",fn,details)\n local row=json.harray({case=case,ok=ok,calls=calls,same_primary=value==primary,same_sink=value==sink_error,same_formatter=value==format_error,writes=writes,events=json.array(),output=output})\n if ok then row.value=value else row.error=tostring(value)end\n for i,event in ipairs(trace.trace_events(emitter))do row.events[i]=trace.to_json(event)end\n trace.log_trace_output(emitter,trace.TRACE_LOW,"after")\n row.after_line=trace.trace_lines(emitter)[#trace.trace_lines(emitter)] or json.null\n rows[#rows+1]=row\nend\nfor _,bad_sink in ipairs({false,true})do\n local sink_error=token("sink_failure");local writes=0\n local emitter=trace.trace_emitter(trace.trace_config_enabled(trace.TRACE_DEBUG),{stdout_writer=function(text)\n  writes=writes+1;if bad_sink and text:find("[exit]",1,true)then error(sink_error,0)end\n end})\n local spec=ls.parse_spec("Top::\\n ???\\n")\n local ok,value=pcall(ls.validate_spec,spec,{trace=emitter})\n rows[#rows+1]=json.harray({case=bad_sink and "public_sink_error" or "public_error",ok=ok,is_validation_error=ls.is_spec_validation_error(value),same_sink=value==sink_error,error=tostring(value),writes=writes})\nend\nio.write(json.encode(rows),"\\n")\n')
(p / 'options.lua').write_text('local ls=require("linkedspec")\nlocal json=ls.json\nlocal ast=ls.spec_ast\nlocal reg=require("linkedspec.staged_parser_registry")\nlocal trace=require("linkedspec.trace")\nlocal function registry_function(name, params, index, body_ast, body_source_override, signature, parameter_kinds)\n  local body_source = body_source_override or "return(value)"\n  local path = { "functions", tostring(index), "body_source" }\n  local payload = json.harray({\n    kind = "staged_payload",\n    node_kind = "function_definition",\n    payload_kind = "function_body",\n    parent_ast_path = json.array(path),\n    function_name = name,\n    text = body_source,\n  })\n  local job_options = {\n    version = 1,\n    job_id = "parse_job:function_body:functions." .. index .. ".body_source",\n    parent_ast_path = path,\n    node_kind = "function_definition",\n    payload_kind = "function_body",\n    function_name = name,\n    text = body_source,\n    source_span = ast.staged_source_span({ start = 0, ["end"] = #body_source, line_start = 1, line_end = 1 }),\n    parser_spec_id = "actionir-body.spec",\n    top_rule = "action_block",\n    result_policy = "replace_field",\n    result_field = "body_ast",\n    failure_policy = "fail",\n    diagnostic_owner = "function_body",\n  }\n  if signature == nil then\n    payload.params = json.array(params)\n    payload.arity = #params\n    job_options.params = params\n    job_options.arity = #params\n    if parameter_kinds ~= nil then\n      payload.parameter_kinds = json.decode(json.encode(parameter_kinds))\n      job_options.parameter_kinds = parameter_kinds\n    end\n  else\n    payload.signature = ast.to_json(signature)\n    job_options.signature = signature\n  end\n  local source_params = table.concat(params, ", ")\n  if signature ~= nil then\n    source_params = source_params == "" and ("..." .. signature.rest_param) or\n      (source_params .. ", ..." .. signature.rest_param)\n  end\n  return ast.function_definition({\n    name = name,\n    params = params,\n    arity = #params,\n    signature = signature,\n    parameter_kinds = parameter_kinds,\n    body_source = body_source,\n    body_payload = payload,\n    body_parse_job = ast.staged_parse_job(job_options),\n    body_ast = body_ast,\n    source = "fn " .. name .. "(" .. source_params .. ") { " .. body_source .. " }",\n    source_span = ast.source_span({ line_start = 1, line_end = 1 }),\n    body_span = ast.source_span({ line_start = 1, line_end = 1 }),\n  })\nend\n\n\nlocal definition=registry_function("probe",{},0,nil,"return(7)")\nlocal empty=ls.parse_spec("Top::\\n")\nlocal rows=json.array()\nlocal values={{"omitted"},{"empty",{}},{"false",false},{"true",true},{"zero",0},{"text","bad"}}\nlocal routes={\n {"jobs",function(v)return #reg.execute_staged_parse_jobs({definition.body_parse_job},v) end},\n {"job",function(v)return reg.execute_staged_parse_job(definition.body_parse_job,v).kind end},\n {"dispatch",function(v)return #reg.dispatch_function_body_parse_jobs(empty,v).results end},\n {"stitch",function(v)return ast.node_type(reg.stitch_function_body_parse_jobs(empty,v)) end},\n {"parse",function(v)return ast.node_type(reg.parse_spec_with_staged_user_function_definition_asts("Top::\\n",json.array(),v))end},\n {"trace_config",function(v)return trace.trace_config(v).level.value end},\n {"trace_emitter",function(v)return trace.is_trace_emitter(trace.trace_emitter(trace.trace_config_disabled(),v))end},\n}\nfor _,r in ipairs(routes) do for _,c in ipairs(values)do\n local ok,value=pcall(r[2],c[2]); local row=json.harray({route=r[1],case=c[1],ok=ok})\n if ok then row.value=value else row.error=tostring(value);row.registry_error=reg.is_staged_parser_registry_error(value)end\n rows[#rows+1]=row\nend end\nlocal cases={\n {"config_false_level",function()return trace.trace_config({level=false}).level.value end},\n {"config_false_sink",function()return trace.trace_config({sink_mode=false}).sink_mode.name end},\n {"enabled_false",function()return trace.trace_config_enabled(false).level.value end},\n {"with_false",function()return trace.with_trace_level(trace.trace_config_disabled(),false).level.value end},\n {"with_false_sink",function()return trace.with_trace_sink_mode(trace.trace_config_disabled(),false).sink_mode.name end},\n {"parse_false_level",function()return trace.parse_trace_level(false)end},\n {"parse_false_sink",function()return trace.parse_trace_sink_mode(false)end},\n {"environment_false",function()return trace.trace_config_from_environment(false)end},\n {"valid_boolean_fields",function()local c=trace.trace_config({reset_file=false,emoji=false});return c.reset_file==false and c.emoji==false end},\n}\nfor _,c in ipairs(cases)do local ok,v=pcall(c[2]);local row=json.harray({route="trace_fields",case=c[1],ok=ok});if ok then row.value=v else row.error=tostring(v)end;rows[#rows+1]=row end\nio.write(json.encode(rows),"\\n")\n')
(p / 'verify-boundaries.py').write_text("from pathlib import Path\nimport hashlib\nimport json\nimport runpy\n\nroot = Path('.linkedspec-data/scratch/lua125')\npins = {\n    'provenance': (23, '023d37c68cf6c5f1753b2b4bd4fbd82f7ed3aaae631b709f3049fa824402b0ed'),\n    'trace': (8, 'd3d951f5a023ba6752d8d1ac745765d0a315989198c80ddaf08d4c3b91713486'),\n    'options': (51, '77461b473f0de5c142163f46a8ee3ed40b93e32257ec78e4e2adef613ba57f9a'),\n}\nobservations = {}\nfor name, (count, digest) in pins.items():\n    rows = []\n    for host in ('puc', 'luajit'):\n        data = json.loads((root / (name + '-' + host + '.json')).read_text())\n        canonical = json.dumps(data, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()\n        assert len(data) == count\n        assert hashlib.sha256(canonical).hexdigest() == digest, (name, host)\n        rows.append(data)\n    assert rows[0] == rows[1]\n    observations[name] = rows[0]\n\nmaterialize = runpy.run_path('tools/check_staged_ast_enrichment_contract.py')['materialize_provenance']\nmismatches = []\nfor row in observations['provenance'][:19]:\n    sources = {'input': 'Aé🙂BC'}\n    if row['alias']:\n        sources['<runtime>'] = 'R🙂ST'\n    ok, text, code = materialize({'provenance': row['record']}, sources)\n    if row['ok'] != ok:\n        assert row['ok'] is True and ok is False and code == 'staged_source_provenance_invalid'\n        mismatches.append(row['case'])\n    elif ok:\n        assert row['value']['text'] == text\n    else:\n        assert row['error']['code'] == code\nassert mismatches == ['null_provenance', 'numeric_provenance', 'object_provenance',\n                      'null_source_with_alias', 'numeric_source_with_alias',\n                      'derived_null_provenance', 'false_provenance', 'false_source_with_alias']\nfor row in observations['provenance'][19:]:\n    assert row['ok'] and row['segment_members'] == 2 and row['segment_host_length'] == 1\n    assert row['extra_false'] != row['third_false']\n    assert row['value']['text'] == 'é🙂'\n    assert len(row['value']['provenance']['segments']) == 1\n\ntraces = {row['case']: row for row in observations['trace']}\nfor name in ['quiet_error', 'active_error', 'sink_error', 'success', 'formatter_invalid', 'formatter_error']:\n    assert traces[name]['calls'] == 1\nassert traces['quiet_error']['same_primary'] and traces['quiet_error']['writes'] == 0\nassert traces['active_error']['same_primary'] and len(traces['active_error']['events']) == 2\nassert traces['sink_error']['same_sink'] and not traces['sink_error']['same_primary']\nassert traces['success']['value'] == 7 and len(traces['success']['events']) == 2\nassert traces['formatter_error']['same_formatter'] and len(traces['formatter_error']['events']) == 2\nassert len(traces['formatter_invalid']['events']) == 1\nassert traces['formatter_invalid']['after_line'] == '[LOW][log]   log_output after\\n'\nassert traces['public_error']['is_validation_error'] and not traces['public_error']['same_sink']\nassert traces['public_sink_error']['same_sink'] and not traces['public_sink_error']['is_validation_error']\n\noptions = observations['options']\nfor route in ['jobs', 'job', 'dispatch', 'stitch', 'parse', 'trace_config', 'trace_emitter']:\n    rows = [r for r in options if r['route'] == route]\n    assert len(rows) == 6\n    assert [r['ok'] for r in rows] == [True, True, True, False, False, False]\n    assert rows[0]['value'] == rows[1]['value'] == rows[2]['value']\nfields = {r['case']: r for r in options if r['route'] == 'trace_fields'}\nassert len(fields) == 9\nfor name in ['config_false_level', 'enabled_false', 'with_false']:\n    assert fields[name]['value'] == 0\nfor name in ['config_false_sink', 'with_false_sink']:\n    assert fields[name]['value'] == 'stdout'\nfor name in ['parse_false_level', 'parse_false_sink', 'environment_false']:\n    assert fields[name]['ok'] is False\nassert fields['valid_boolean_fields']['value'] is True\nprint('Lua .1.25: 164 complete observations equal across installed hosts; 19 neutral provenance cases, 8 admission mismatches; 4 host-array cases and exact trace/option controls verified')\n")
(p / 'select-tests.py').write_text('from pathlib import Path\nimport json\nnames = [\'trace controls expose ordered levels immutable config and structured primitives\', \'trace sinks and direct runtime entrypoints stay caller-owned and result-neutral\', \'full-pipeline tracing filters levels stays quiet and preserves attributed failures\', \'staged parser registry orders dispatches stitches and diagnoses sidecar drift\', \'runtime trace events expose exact interpreter decisions without changing results\']\ns = Path(\'lua/test/run.lua\').read_text()\nselection = \'local selected = {\\n\' + \'\'.join(\'  [\' + json.dumps(n) + \'] = true,\\n\' for n in names) + \'}\\nlocal assertions = 0\\n\'\ns = selection + s\nfor old, new in [\n (\'local function test(name, operation)\\n\', \'local function test(name, operation)\\n  if not selected[name] then return end\\n\'),\n (\'local function assert_equal(actual, expected, label)\\n\', \'local function assert_equal(actual, expected, label)\\n  assertions = assertions + 1\\n\'),\n (\'local function assert_contains(actual, expected, label)\\n\', \'local function assert_contains(actual, expected, label)\\n  assertions = assertions + 1\\n\')]:\n assert s.count(old) == 1\n s = s.replace(old, new, 1)\ns += \'\\nassert(total == 5, "selected test count drift")\\nio.write("selected assertions: ", assertions, "\\\\n")\\n\'\nPath(\'.linkedspec-data/scratch/lua125/selected.lua\').write_text(s)\n')
LUA_DECLARATION_TRACE_READING_25
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua125/select-tests.py
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua125/provenance.lua > .linkedspec-data/scratch/lua125/provenance-puc.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua125/trace-failures.lua > .linkedspec-data/scratch/lua125/trace-puc.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua125/options.lua > .linkedspec-data/scratch/lua125/options-puc.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua125/selected.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua125/provenance.lua > .linkedspec-data/scratch/lua125/provenance-luajit.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua125/trace-failures.lua > .linkedspec-data/scratch/lua125/trace-luajit.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua125/options.lua > .linkedspec-data/scratch/lua125/options-luajit.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua125/selected.lua
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua125/verify-boundaries.py
```

Related facts: [[lua-staged-completion-reading-and-boundary-gaps]],
[[lua-validator-staged-prefix-reading-and-array-gaps]],
[[lua-startup-reading-coverage]], [[lua-reading-evidence-capacity-admission]].

## Preservation and documentation verification

The independent audit byte-compares 1,400 prior Lua, Knowledge, decision, immutable
history and policy files. Of 2,552 old task nodes, 2,546 remain exact; the six
changed nodes are this reading leaf, Lua repair parents .2/.2.1/.2.8, startup
.3.6 and Dart .2.19. All twelve new nodes remain pending. The parked authoring tree,
both old history suffixes and the live-status History query section are exact.
All 85 prior Known limitation headings remain; two new headings bring the book
to 87. Five embedded payloads match the executed scratch files exactly. Independent
coverage reconstruction reproduces all three baseline digests and 25 completed
groups; no old source or historical evidence is silently replaced.

Knowledge regeneration reports 1,111 facts /8,905 question keys. Memory architecture
and intended clean handoff pass at 60 lines. Both history checks pass without
rollover: Changes 389 lines /27,639 bytes; Notes 319 /24,548. The mdBook renders
successfully; its 10,110,892-byte search-index warning remains startup .41.9-owned.
`git diff --check` passes. The normal registered commit hooks remain required;
this focused reading leaf does not claim canonical CI or a repaired runtime.
