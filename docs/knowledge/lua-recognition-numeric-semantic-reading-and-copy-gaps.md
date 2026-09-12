---
id: lua-recognition-numeric-semantic-reading-and-copy-gaps
title: Lua recognition numeric and semantic reading owns integer overflow and diagnostic null loss
answers:
  - what did Lua startup reading group sixteen cover
  - can PUC Lua numeric addition wrap negative or multiplication become zero
  - why can Lua num_abs return a negative value
  - does Lua semantic diagnostic copying preserve typed null
  - which task owns Lua scalar and reducer integer overflow repair
  - which task owns Lua semantic diagnostic null preservation
  - which current Lua semantic foundation and scoped binding checks passed
date: 2026-09-12
status: exact group sixteen read; numeric .2.13 and diagnostic copy .2.14 repairs pending
tags: [lua, reading, numeric, recognition, semantic, diagnostics, null, validation]
evidence: "LUA-STARTUP-READING.1.16 reads 1500 fragments /46858 bytes from 1c74ad498b0e1448d43739e4c7cabf496a646ea9. Source382, outcome122, scoped26 and boundary10 controls pass per host, 1080 assertions total. Native/reconstructed numeric observations and isolated diagnostic-copy observations have separate repair ownership. Nine Perl Get/lowering cases and neutral numeric55/18 plus semantic6/20/128 checks pass. Cumulative16/51,19651 fragments/815109 bytes."
reverify:
  - "Run the exact managed LUA_READING_BOUNDARIES_16 replay below."
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_source_foundation_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_source_foundation_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_compilation_foundation_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_compilation_foundation_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact source reading

Activation is `1c74ad498b0e1448d43739e4c7cabf496a646ea9`. The frozen source
baseline remains `baeb984e36a94a15951cd23d4c52def5064cdaca`. Group sixteen has
1,500 fragments /46,858 bytes and ordered-range SHA-256
`96a35519ffd3e49916b79e25a81b9e376cc3090aee62bc5a63293d947ad7a0d3`.
Coordinates below are inclusive LF lines under `lua/src/linkedspec`.

| File | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| recognition_transaction_runtime.lua | 142–501 | 12179 | fc4bde01e0cbdd48b6f1adbcc3e4c58175f291a6eaf1c99723afba55d1670d03 |
| runtime_scoped_binding.lua | 1–102 | 3246 | 464db7ba11424a763d2f41935c00d379f1dcfd5efeded8a0a0607b914139e628 |
| scalar_numeric.lua | 1–192 | 5629 | 963052346fe869a674d7814ad691db90a4bb51e7c1e10716278ac8b1aefc1b2e |
| semantic_compilation_outcome.lua | 1–253 | 7583 | 98198703dd35b97e213aea2341fa7929afdc1a2deaa7df0ad2f7de2e56c9f5b4 |
| semantic_index.lua | 1–593 | 18221 | 0520c5881c16a1275c557ec18894378e1b725d53beaeb5e8c3f46331898839a5 |

Twelve complete untruncated windows cover every byte:

- Recognition adapter: 142–291,292–441,442–501.
- Scoped binding: 1–102; scalar numeric: 1–150,151–192.
- Compilation outcome: 1–150,151–253.
- Semantic index: 1–150,151–300,301–450,451–593.

The first four modules are fully read; semantic index stops inside
compilation_authority. The next child owns its suffix. Cumulative reading is
16/51, 19,651 fragments /815,109 bytes, 28 complete files and one partial semantic
index. All 99 frozen Lua sources remain unchanged. Targeted test/validator reads
for diagnosis grant no additional physical reading credit.

# Comprehension and canonical reconciliation

The recognition adapter completes invocation cleanup, restores staged token state,
restores prior same-label marks and records accepted/failed/aborted observations.
Rejected recursion reserves invocation identity without claiming accepted exit.
Gap candidates track prefix/interstitial/tail ranges and commit only after the
selected match has advanced; checkpoint/rollback also copy and restore gap state
and phase. Entry-slot metadata stays separate. Commit removes the token while
returning its payload directly, preserving false; rollback reapplies the private
frame and gap snapshots. The latest unchanged recognition consumer remains the
previous leaf's 246 assertions per host, not fresh evidence for this leaf.

Scoped binding validates names and duplicates before rebinding all three stores.
It snapshots presence separately from value, isolates temporary identities, copies
inputs and callback results, restores stores in reverse order and rethrows the
original callback error. The exact existing 2,946-byte test body was selected
without edits (SHA-256 2bda2a1ab606b3421f2af76f3431271088f0b866b4cf6fd044442d32c85a7b75);
only a small assertion harness surrounds it. Its 26 assertions pass on each host.

Scalar numeric owns strict untrimmed decimal conversion, explicit arities,
finite-value checks, invalid-to-null behavior, comparisons, half-away rounding,
floor modulo and copied-array reducers. Generic scalar conversion is separate.
Finite normalization occurs after native arithmetic, so a wrapped finite integer
can already have the wrong value; the new numeric owner below addresses this.

Compilation outcome uses the staged parser, validator, compiler with duplicate
validation disabled, entry selector and generated-plan builder. Recognized errors
become failed outcomes with retained parsed/validated presence; unrecognized values
rethrow unchanged. Authored functions/rules merge by line with deterministic ties.
The source index validates options and UTF-8 before lazy compiler work, maps byte
and scalar boundaries with LF line advances, enforces source-detail ceilings and
keeps state behind opaque weak-key handles. Its source-coordinate guard explicitly
rejects infinity and NaN, unlike the separate transaction gap owned by .2.12.
Recursive diagnostic copies contain the second finding below.

Knowledge retrieval preceded diagnosis: [[lua-recognition-transaction-integration]],
[[lua-scalar-numeric-runtime]], [[cross-backend-scalar-numeric-drift]],
[[lua-semantic-source-outcome-plan]], [[lua-semantic-source-foundation]],
[[lua-semantic-compilation-foundation]] and
[[lua-semantic-introspection-authority-map]]. The older 378-source /122-outcome
foundation evidence remains dated; current source count is 382. Toolbox targeted
Lua, neutral numeric/semantic and Perl Get/lowering entrypoints guided diagnosis.

# PUC integer arithmetic changes sign or magnitude

Each expression below runs through native and SpecFile-JSON-reconstructed Lua
parsers. The source is a zero-regex `Top` action edge to `/x/` rule `Done`, on `x`.
The same source runs through fresh Perl Get; call_spec_handler_subst records actual
reference lowering. Lua JSON output is compared separately from raw value_text.

| Expression | Installed PUC result before JSON | LuaJIT represented result | Perl Get observation |
| --- | --- | --- | --- |
| num_add(9223372036854775807,1) | -9223372036854775808 | positive 2^63 | positive 2^63 |
| num_abs(-9223372036854775808) | -9223372036854775808 | positive 2^63 | positive 2^63 |
| num_mul(4611686018427387904,4) | 0 | positive 2^64 | approximately positive 2^64 |
| num_sub(-9223372036854775808,1) | 9223372036854775807 | approximately negative 2^63 | approximately negative 2^63 |
| num_sum([9223372036854775807,1]) | -9223372036854775808 | positive 2^63 | positive 2^63 |

Small addition, direct 1e20, adding zero to 1e20 and invalid division are controls.
There are nine source cases, two Lua carriers per host and nine fresh Perl cases.
The five PUC defective cases occur on both carriers. LuaJIT's floating representation
is not an arbitrary-precision guarantee: subtraction below the negative boundary
is rounded. Perl JSON similarly emits two floating results with limited decimal
precision; the independent comparison explicitly uses relative tolerance 1e-14 for
those two magnitudes, while preserving sign and rejecting zero/wraparound.

The local mechanism is scalar_numeric.lua: sum122, add148, multiply151, subtract153
and abs163 execute host integer operations before normalize76 checks finiteness.
The wrong sign/zero is present in the runtime value before JSON encoding.
The subtraction result's JSON spelling is additionally rounded from max-int to
2^63 by the already-owned .2.11 encoder defect; that is not a second arithmetic
operation. The installed PUC evidence is 5.5.1; .2.2 still owns declared 5.4 proof.

`.2.13.1` owns coherent scalar/reducer arithmetic correction and `.2.13.2`
independent domain/carrier proof. Existing startup .20 numeric grammar, .55 text/
number work, Dart .2.12, Julia .2.9 and Lua .2.11 keep their separate scopes.
No arbitrary-precision, new text spelling or fresh six-runtime admission is claimed.

# Typed null becomes an empty object in diagnostic copies

A recognized synthetic validator error carries these valid JSON fields:

```json
{"scalar_null":null,"scalar_false":false,"nested_array":[null,false],"nested_object":{"member":null}}
```

Both the compilation outcome and independently isolated index copy project:

```json
{"scalar_null":{},"scalar_false":false,"nested_array":[{},false],"nested_object":{"member":{}}}
```

The outcome's copy helper at semantic_compilation_outcome.lua29 and the index's
helper at semantic_index.lua54 treat every non-array table as an harray, including
the typed json.null sentinel. False controls and caller fields remain intact.
The index's fields accessor and to_json projection agree on the same changed data;
comparison against the original typed fields reveals the loss.

The corrected fixture creates a valid parsed spec before replacing the outer
parse/validation seams, obtains a genuine recognized validator error, and restores
all three temporary module replacements. It then injects the original typed fields
into that detached failed outcome to isolate the index helper independently.
No production file is changed. This does not establish that an ordinary source
currently generates those nullable validator fields; `.2.14.1/.2` own correction,
producer-domain census, detachment and supported semantic/MCP carrier proof.

# Focused proof and limits

Source foundation382, compilation foundation122, unchanged scoped-binding26 and
boundary10 valid assertions pass per installed host: 1,080 total. Two boundary
assertions per host compare the entire unchanged 55-case numeric fixture on native
and reconstructed routes; those are not counted as 110 independent assertions.
The 36 numeric rows and six copied-field projections are independently checked
observations, counted separately. The nine Perl reference/lowering cases also stay
separate. All eight final managed Lua executions and the Perl process complete;
all results and cleanup outcomes are consumed.

Neutral numeric validation passes 55 cases /18 helpers. Neutral semantic validation
passes six fixture groups, twenty queries,128 mutations and existing 9/9 rollout,
6/6 admission governance. Governance counts are not fresh runtime executions.
No declared PUC5.4, full Lua gate, broad corpus, generated/emitted defect route,
MCP defect consumer or full CI result is claimed. Prior public-selector failure
remains startup .28.7-owned. Fourteen Lua repair roots remain pending.

Probe setup corrections are distinct from production findings: the first
SpecFile reconstruction call omitted its required node-type argument; the first
diagnostic fixture intercepted trusted parser-internal validation and returned
semantic_index_parse_failed with empty fallback fields; and the first Perl call
passed a scalar rather than the required scalar reference. Correct API calls and
isolated seams produce the final evidence above. These failed/intermediate runs
are not counted as passing proof.

# Exact replay payloads

The replay recreates only repository-local scratch. Payload identities:

| Payload | Bytes | SHA-256 |
| --- | ---: | --- |
| boundary-probe.lua | 4891 | 613a7d80ddea1b7cdb2b9bad5019a048fd9c1a691b69c9346e1ea25447b39e44 |
| scoped-binding-proof.lua | 3364 | 4fa5553e320adec46499cce72bbfa3637b8aed051a720749f5dba61321e05df9 |
| numeric-cases.json | 402 | 969371e199faeeb9c3bb1a87e22634091586def5689c79ae949bd0ace1be4ef7 |
| numeric-reference.pl | 653 | a9e55473c9e70c4b376c3f66db0576f563f41bbc111c1474677d9788aa50802a |
| verify-boundaries.py | 2541 | 24c8cd7f3c544c4b6b5a8bcdea16be2417d3b8c67045762ad68e8a1857712ff8 |

```bash
bash tools/project_data_run.sh python3 - <<'LUA_READING_BOUNDARIES_16'
from pathlib import Path
root = Path('.linkedspec-data/scratch/lua116')
root.mkdir(parents=True, exist_ok=True)
(root / 'boundary-probe.lua').write_text('local ls = require("linkedspec")\nlocal json = ls.json\nlocal numeric = require("linkedspec.scalar_numeric")\nlocal validator = require("linkedspec.spec_validator")\nlocal outcome = require("linkedspec.semantic_compilation_outcome")\nlocal controls = 0\nlocal function check(condition, label)\n  assert(condition, label)\n  controls = controls + 1\nend\nlocal function read_file(path)\n  local f = assert(io.open(path, "rb")); local value = assert(f:read("*a")); assert(f:close()); return value\nend\nlocal function execute(source, reconstruct)\n  local spec = ls.parse_spec(source)\n  if reconstruct then spec = ls.spec_ast.from_json("SpecFile", json.decode(json.encode(ls.spec_ast.to_json(spec)))) end\n  return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(spec)), "x").value\nend\nlocal contract = json.decode(read_file("capability_conformance/scalar_numeric_contract.json"))\ncheck(json.encode(execute(contract.spec_source, false)) == json.encode(contract.expected), "55-case neutral numeric native fixture")\ncheck(json.encode(execute(contract.spec_source, true)) == json.encode(contract.expected), "55-case neutral numeric reconstructed fixture")\nlocal cases = {\n  { "small_add", "num_add(40, 2)" },\n  { "large_literal", "100000000000000000000" },\n  { "large_add_zero", "num_add(100000000000000000000, 0)" },\n  { "int_add", "num_add(9223372036854775807, 1)" },\n  { "int_abs", "num_abs(-9223372036854775808)" },\n  { "int_mul", "num_mul(4611686018427387904, 4)" },\n  { "int_sub", "num_sub(-9223372036854775808, 1)" },\n  { "reducer_sum", "num_sum([9223372036854775807, 1])" },\n  { "invalid_division", "num_div(1, 0)" },\n}\nfor _, item in ipairs(cases) do\n  local source = "Top::\\n -> Done { return(" .. item[2] .. ") }\\nDone:\\n /x/\\n"\n  for _, reconstruct in ipairs({ false, true }) do\n    local value = execute(source, reconstruct)\n    io.write(json.encode(json.harray({ case = item[1], expression = item[2], route = reconstruct and "reconstructed" or "native", value_text = tostring(value), value = value, is_negative = type(value) == "number" and value < 0 })), "\\n")\n  end\nend\n-- Recognized diagnostic injection uses the same module seams as the admitted\n-- semantic compilation consumer. It does not claim a native validator emits null.\nlocal ok, failure = pcall(validator.regex_slot_identity_invalid, "Top", "Child", 1, "typed diagnostic field probe")\ncheck(not ok and validator.is_validation_error(failure), "recognized validation diagnostic fixture")\nlocal fields = json.harray({ scalar_null = json.null, scalar_false = false, nested_array = json.array({ json.null, false }), nested_object = json.harray({ member = json.null }) })\nfailure.fields = fields\nlocal source = "Top::\\n { return(42) }\\n"\nlocal options = { logical_name = "probe.spec", source_detail_ceiling = "identity" }\nlocal staged_parser = require("linkedspec.user_function_definition_parser")\nlocal parsed_fixture = ls.parse_spec(source)\nlocal original_parse = staged_parser.parse_spec_with_staged_user_function_definitions\nstaged_parser.parse_spec_with_staged_user_function_definitions = function() return parsed_fixture end\nlocal original_validate = validator.validate_spec\nvalidator.validate_spec = function() error(failure, 0) end\nlocal built_ok, built = pcall(outcome.build, source, options)\nvalidator.validate_spec = original_validate\nstaged_parser.parse_spec_with_staged_user_function_definitions = original_parse\ncheck(built_ok, "recognized synthetic outcome builds")\nio.write("OUTCOME_DIAGNOSTIC ", built.diagnostic.code, " ", built.diagnostic.stage, " ", json.encode(built.diagnostic.fields), "\\n")\ncheck(fields.scalar_null == json.null and fields.nested_array[1] == json.null, "caller diagnostic nulls remain intact")\ncheck(built.diagnostic.fields.scalar_false == false and built.diagnostic.fields.nested_array[2] == false, "false diagnostic controls survive")\n-- Restore original typed fields only on this detached synthetic outcome to\n-- isolate the index projection\'s separate copying boundary.\nbuilt.diagnostic.fields = fields\nlocal original_build = outcome.build\noutcome.build = function() return built end\nlocal index_ok, index = pcall(ls.semantic_index, source, options)\noutcome.build = original_build\ncheck(index_ok, "synthetic diagnostic index builds")\nlocal diagnostic = index:compilation_diagnostic()\nio.write("INDEX_FIELDS ", json.encode(diagnostic.fields), "\\n")\nio.write("INDEX_JSON ", json.encode(diagnostic:to_json().fields), "\\n")\ncheck(diagnostic.fields.scalar_false == false, "index diagnostic false control")\ncheck(fields.scalar_null == json.null, "index preserves caller null authority")\ncheck(validator.validate_spec == original_validate and outcome.build == original_build and staged_parser.parse_spec_with_staged_user_function_definitions == original_parse, "all temporary module replacements restored")\nio.write("PASS ", controls, " valid controls; boundary observations reported separately\\n")\n')
(root / 'scoped-binding-proof.lua').write_text('local json = require("linkedspec.json")\nlocal assertions = 0\nlocal function assert_equal(actual, expected, label)\n  assert(actual == expected, label)\n  assertions = assertions + 1\nend\nlocal function assert_json_equal(actual, expected, label)\n  assert_equal(json.encode(actual), json.encode(expected), label)\nend\nlocal function test(name, body)\n  body()\n  io.write("PASS ", name, ": ", assertions, " assertions\\n")\nend\ntest("scoped runtime bindings restore every store on success and error", function()\n  local runtime_scoped_binding = require("linkedspec.runtime_scoped_binding")\n  local function scoped_copy(value)\n    if type(value) ~= "table" then return value end\n    return json.decode(json.encode(value))\n  end\n\n  local input = json.array({ "inner" })\n  local context = {\n    variables = { value = false },\n    arrays = { value = json.array({ "prior-array" }) },\n    harrays = { value = json.harray({ state = "prior-harray" }) },\n  }\n  local result = runtime_scoped_binding.run(context, "value", input, scoped_copy, function()\n    assert_equal(json.kind(context.variables.value), "array", "temporary value kind")\n    assert_equal(context.variables.value == input, false, "temporary value is copied")\n    assert_equal(context.arrays.value, nil, "prior array store is hidden")\n    assert_equal(context.harrays.value, nil, "prior harray store is hidden")\n    context.variables.value[#context.variables.value + 1] = "scoped"\n    context.arrays.value = json.array({ "temporary-array" })\n    context.harrays.value = json.harray({ state = "temporary-harray" })\n    return context.variables.value\n  end)\n  assert_json_equal(result, json.decode(\'["inner","scoped"]\'), "scoped result is copied before restore")\n  assert_json_equal(input, json.decode(\'["inner"]\'), "caller input remains isolated")\n  assert_equal(context.variables.value, false, "false scalar binding restores exactly")\n  assert_json_equal(context.arrays.value, json.decode(\'["prior-array"]\'), "array store restores")\n  assert_json_equal(\n    context.harrays.value,\n    json.decode(\'{"state":"prior-harray"}\'),\n    "harray store restores"\n  )\n\n  local absent = { variables = {}, arrays = {}, harrays = {} }\n  local scoped_names = { "value", "key", "path", "depth", "acc" }\n  local marker = {}\n  local ok, failure = pcall(function()\n    runtime_scoped_binding.run_frame(absent, {\n      { name = "value", value = "temporary" },\n      { name = "key", value = "a" },\n      { name = "path", value = json.array({ "a" }) },\n      { name = "depth", value = 1 },\n      { name = "acc", value = json.array({ "seed" }) },\n    }, scoped_copy, function()\n      for _, name in ipairs(scoped_names) do\n        absent.variables[name] = "changed"\n        absent.arrays[name] = json.array({ "changed" })\n        absent.harrays[name] = json.harray({ changed = true })\n      end\n      error(marker, 0)\n    end)\n  end)\n  assert_equal(ok, false, "callback error propagates")\n  assert_equal(failure, marker, "callback error identity is preserved")\n  for _, name in ipairs(scoped_names) do\n    assert_equal(absent.variables[name], nil, "absent " .. name .. " scalar remains absent after frame error")\n    assert_equal(absent.arrays[name], nil, "absent " .. name .. " array remains absent after frame error")\n    assert_equal(absent.harrays[name], nil, "absent " .. name .. " harray remains absent after frame error")\n  end\nend)\n')
(root / 'numeric-cases.json').write_text('[["small_add","num_add(40, 2)"],["large_literal","100000000000000000000"],["large_add_zero","num_add(100000000000000000000, 0)"],["int_add","num_add(9223372036854775807, 1)"],["int_abs","num_abs(-9223372036854775808)"],["int_mul","num_mul(4611686018427387904, 4)"],["int_sub","num_sub(-9223372036854775808, 1)"],["reducer_sum","num_sum([9223372036854775807, 1])"],["invalid_division","num_div(1, 0)"]]\n')
(root / 'numeric-reference.pl').write_text('use strict;\nuse warnings;\nuse LinkedSpec;\nuse JSON::PP;\nmy $json=JSON::PP->new->canonical(1)->allow_nonref(1);\nopen my $fh,\'<\',\'.linkedspec-data/scratch/lua116/numeric-cases.json\' or die $!;\nlocal $/; my $cases=$json->decode(<$fh>); close $fh or die $!;\nfor my $case (@$cases) {\n  my ($name,$expression)=@$case;\n  my $source="Top::\\n -> Done { return($expression) }\\nDone:\\n /x/\\n";\n  my $parser=LinkedSpec::Get(\\$source);\n  my $input=\'x\';\n  my $value=$parser->(\\$input);\n  my $lowered=LinkedSpec::call_spec_handler_subst(\'Top\',"return($expression)");\n  print $json->encode({case=>$name,expression=>$expression,value=>$value,lowered=>$lowered}),"\\n";\n}\n')
(root / 'verify-boundaries.py').write_text("from pathlib import Path\nimport json,math\nroot=Path('.linkedspec-data/scratch/lua116')\nexpected_puc={'small_add':42,'large_literal':10**20,'large_add_zero':10**20,'int_add':-(2**63),'int_abs':-(2**63),'int_mul':0,'int_sub':2**63,'reducer_sum':-(2**63),'invalid_division':None}\nexpected_lj=dict(expected_puc,int_add=2**63,int_abs=2**63,int_mul=2**64,int_sub=-(2**63),reducer_sum=2**63)\nfields={'scalar_null':{},'scalar_false':False,'nested_array':[{},False],'nested_object':{'member':{}}}\nfor host,expected in [('puc',expected_puc),('luajit',expected_lj)]:\n lines=(root/('boundary-'+host+'.log')).read_text().splitlines()\n records=[json.loads(l) for l in lines if l.startswith('{')]\n assert len(records)==18\n seen=set()\n for r in records:\n  pair=(r['case'],r['route']); assert pair not in seen; seen.add(pair)\n  assert r['value']==expected[r['case']],(host,r)\n  assert r['is_negative']==(isinstance(r['value'],(int,float)) and r['value']<0)\n  if host=='puc' and r['case']=='int_sub': assert r['value_text']=='9223372036854775807'\n assert seen=={(case,route) for case in expected for route in ['native','reconstructed']}\n diagnostic=[l for l in lines if l.startswith('OUTCOME_DIAGNOSTIC ')]; assert len(diagnostic)==1\n prefix='OUTCOME_DIAGNOSTIC regex_slot_identity_invalid validate_compiled_rule '\n assert diagnostic[0].startswith(prefix) and json.loads(diagnostic[0][len(prefix):])==fields\n for label in ['INDEX_FIELDS ','INDEX_JSON ']:\n  selected=[l for l in lines if l.startswith(label)]; assert len(selected)==1 and json.loads(selected[0][len(label):])==fields\n assert lines[-1]=='PASS 10 valid controls; boundary observations reported separately'\n print('PASS',host,'18 numeric observation rows; 3 isolated copied-field projections; 10 valid controls')\nreference=[json.loads(l) for l in (root/'numeric-reference.jsonl').read_text().splitlines()]\nassert len(reference)==9 and {r['case'] for r in reference}==set(expected_puc)\nexact={'small_add':42,'large_literal':10**20,'large_add_zero':10**20,'int_add':2**63,'int_abs':2**63,'reducer_sum':2**63,'invalid_division':None}\nfor r in reference:\n if r['case'] in exact: assert r['value']==exact[r['case']],r\n elif r['case']=='int_mul': assert math.isclose(r['value'],2**64,rel_tol=1e-14) and r['value']>0\n elif r['case']=='int_sub': assert math.isclose(r['value'],-(2**63)-1,rel_tol=1e-14) and r['value']<0\n assert r['lowered'].startswith('return ')\nprint('PASS 9 fresh Perl Get/reference-lowering cases; two floating JSON magnitudes checked with explicit tolerance, no exact-integer claim')\n")
LUA_READING_BOUNDARIES_16
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua116/boundary-probe.lua > .linkedspec-data/scratch/lua116/boundary-puc.log
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua116/boundary-probe.lua > .linkedspec-data/scratch/lua116/boundary-luajit.log
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua116/scoped-binding-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua116/scoped-binding-proof.lua
bash tools/project_data_run.sh env PERL5LIB=perl perl .linkedspec-data/scratch/lua116/numeric-reference.pl > .linkedspec-data/scratch/lua116/numeric-reference.jsonl
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua116/verify-boundaries.py
```

# Independent preservation and landing checks

Canonical coverage replay preserves all three inventory/range/group digests and
all 99 source identities. Independent completed-node sums confirm16/51,
19,651 fragments /815,109 bytes; each new scoped range matches its exact digest.
All five embedded replay payloads match the executed scratch bytes.
The preservation audit keeps 1,391 prior source/card/decision/history/policy files
byte-exact and 2,479 of 2,482 old task nodes. Only .1.16, the Lua repair container
and startup .3.6 change; exactly six pending numeric/null repair nodes are added.
Both hot histories retain their exact prior suffixes, and live status retains its
exact History section. All 64 prior Known book headings remain, with two added.
The approved named-argument tree remains byte-exact and parked.

Memory, Knowledge, both bounded histories, rendered book and normal doctrines
govern landing. ADR0118 capacity and all startup prerequisites remain unchanged.

Knowledge generation passes at 1,102 facts /8,837 question keys; explicit memory
validation passes at 60 lines. Both history checks pass (Changes326 lines /22,063
bytes; Notes256 /18,153); no rollover is required. The book builds with the existing
search-index size warning (10,064,347 bytes), still startup .41.9-owned. Diff checks
pass; all nine normal doctrine hooks govern the commit.
