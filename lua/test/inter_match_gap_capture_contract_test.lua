-- INTER-MATCH-GAP-CAPTURE.6.5 — admitted shared Lua primary/composition stage.
--
-- This final consumer path now proves parsing, validation, compiled provenance,
-- source identity, private native state/lifecycle, normalized reconstruction,
-- compatible descriptors, generated-v2 execution, and independently loaded
-- emitted-source execution, existing-primary parity, and exact nine-role
-- composition on both Lua ABIs. Recurring/public admission remains owned by `.7`.

local linkedspec = require("linkedspec")
local json = linkedspec.json

local CONTRACT_ID = "linkedspec-inter-match-gap-capture-v1"
local CONTRACT_PATH = "capability_conformance/inter_match_gap_capture_contract.json"
local EXPECTED_ROLES = json.array({
  "native_execution",
  "ordinary_reconstruction",
  "descriptor",
  "generated_plan",
  "emitted_source",
  "target_lifecycle",
  "recursion_and_rollback",
  "portable_diagnostics",
  "primary_command",
})

local assertions = 0

local function fail(message)
  error(message, 0)
end

local function check(condition, label)
  assertions = assertions + 1
  if not condition then fail(label or "assertion failed") end
end

local function check_equal(actual, expected, label)
  assertions = assertions + 1
  if actual ~= expected then
    fail((label or "values differ") .. ": expected " .. tostring(expected) ..
      ", got " .. tostring(actual))
  end
end

local function check_nil(actual, label)
  check_equal(actual, nil, label)
end

local function check_json_equal(actual, expected, label)
  assertions = assertions + 1
  if actual == nil or expected == nil then
    if actual ~= expected then
      fail((label or "JSON values differ") .. ": expected " .. tostring(expected) ..
        ", got " .. tostring(actual))
    end
    return
  end
  local actual_json = json.encode(actual)
  local expected_json = json.encode(expected)
  if actual_json ~= expected_json then
    fail((label or "JSON values differ") .. ": expected " .. expected_json ..
      ", got " .. actual_json)
  end
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then return first == 0 end
  return first == true and (third == nil or third == 0)
end

local function with_temp_directory(operation)
  local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
  assert(temp_root ~= "", "TMPDIR must not be empty")
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-gap-emitted.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local workspace = assert(handle:read("*l"))
  assert(handle:close())

  local ok, value = pcall(operation, workspace)
  local cleaned = command_succeeded("rm -rf -- " .. shell_quote(workspace))
  if not cleaned then fail("unable to clean emitted gap workspace") end
  if not ok then error(value, 0) end
  return value, workspace
end

local function current_directory()
  local handle = assert(io.popen("pwd -P", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  return root
end

local function hex_encode(value)
  local chunks = {}
  for index = 1, #value do chunks[index] = string.format("%02x", value:byte(index)) end
  return table.concat(chunks)
end

local function compile_metadata(source, source_id)
  source_id = source_id or "inline"
  local parsed = linkedspec.parse_spec(source, { source_id = source_id })
  linkedspec.validate_spec(parsed)
  return linkedspec.compile_spec(parsed, { validate_source = false })
end

local function portable_diagnostic(source, source_id)
  local ok, result = pcall(compile_metadata, source, source_id)
  if ok then fail("fixture must be rejected statically") end
  if not linkedspec.is_spec_validation_error(result) then error(result, 0) end
  return linkedspec.spec_validation_error_to_json(result)
end

local function execute_native(source, input)
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_metadata(source)),
    input
  )
end

local function native_error(source, input)
  local ok, result = pcall(execute_native, source, input)
  if ok then fail("fixture must fail during native execution") end
  if not linkedspec.is_runtime_interpreter_error(result) then error(result, 0) end
  return result
end

local function compiled_rule_json(compiled, label)
  return linkedspec.compiled_spec_to_json(compiled).rules_by_label[label]
end

local function check_selector(edge, kind, authored, target, index, slot, label)
  check_equal(edge.selector_kind, kind, label .. " selector kind")
  if authored == nil then
    check(edge.authored_selector == json.null, label .. " authored selector")
  else
    check_equal(edge.authored_selector, authored, label .. " authored selector")
  end
  check_equal(edge.targets[1].label, target, label .. " target rule")
  check_equal(edge.child_regex_index, index, label .. " regex index")
  if slot == nil then
    check(edge.target_slot_id == json.null, label .. " target slot")
  else
    check_equal(edge.target_slot_id, slot, label .. " target slot")
  end
end

local contract = json.decode(read_file(CONTRACT_PATH))
check_equal(contract.contract_id, CONTRACT_ID, "contract id")
check_equal(contract.format, 1, "contract format")
check_equal(contract.rollout[6].id, "puc_lua_runtime", "PUC rollout id")
check_equal(contract.rollout[6].status, "complete", "PUC rollout status")
check_equal(contract.rollout[7].id, "luajit_runtime", "LuaJIT rollout id")
check_equal(contract.rollout[7].status, "complete", "LuaJIT rollout status")
check_equal(#EXPECTED_ROLES, 9, "role count")
for index, role in ipairs(contract.recurring_gate.consumers[5].roles) do
  check_equal(EXPECTED_ROLES[index], role, "role " .. index)
end

local source = table.concat({
  "Top::OR",
  " @capture_gaps",
  ' -> Part[head] { return("named") }',
  ' -> Part[0] { return("numeric") }',
  ' -> Part { return("unindexed") }',
  "Part:",
  " head = /H/",
  " /S/",
  " foot=/F/",
  " é́=/U/",
  "",
}, "\n")

local parsed = linkedspec.parse_spec(source)
check_equal(parsed.source_id, "inline", "default source id")
local part_rows = {}
for _, element in ipairs(parsed.rules[2].body) do
  if linkedspec.spec_ast.node_type(element.kind) == "RegexBodyElementKind" then
    part_rows[#part_rows + 1] = element.kind
  end
end
check_equal(#part_rows, 4, "mixed declaration count")
check_equal(part_rows[1].slot_id, "head", "first named slot")
check_nil(part_rows[2].slot_id, "anonymous slot")
check_equal(part_rows[3].slot_id, "foot", "second named slot")
check_equal(part_rows[4].slot_id, "é́", "exact Unicode slot")

for _, declaration in ipairs({ "head=/H/", "head =/H/", "head= /H/", "head = /H/" }) do
  local row = linkedspec.parse_spec("Top::\n " .. declaration .. "\n").rules[1].body[1].kind
  check_equal(row.slot_id, "head", declaration .. " slot")
  check_equal(row.pattern, "H", declaration .. " pattern")
end

linkedspec.validate_spec(parsed)
local compiled = linkedspec.compile_spec(parsed, { validate_source = false })
check_equal(compiled.source_id, "inline", "compiled source id")
local part_json = compiled_rule_json(compiled, "Part")
check_equal(#part_json.regex_slots, 4, "compiled slot count")
local expected_slots = {
  { 0, "head", 7 },
  { 1, nil, 8 },
  { 2, "foot", 9 },
  { 3, "é́", 10 },
}
for index, expected in ipairs(expected_slots) do
  local row = part_json.regex_slots[index]
  check_equal(row.regex_index, expected[1], "slot index " .. index)
  if expected[2] == nil then
    check(row.slot_id == json.null, "anonymous compiled slot")
  else
    check_equal(row.slot_id, expected[2], "slot id " .. index)
  end
  check_equal(row.source_id, "inline", "slot source " .. index)
  check_equal(row.line, expected[3], "slot line " .. index)
end

local top_json = compiled_rule_json(compiled, "Top")
check_equal(top_json.capture_gaps.enabled, true, "capture directive enabled")
check_equal(top_json.capture_gaps.directive, "@capture_gaps", "capture directive spelling")
check_equal(top_json.capture_gaps.source_id, "inline", "capture directive source")
check_equal(top_json.capture_gaps.line, 2, "capture directive line")
check_equal(#top_json.action_edges, 3, "selector edge count")
check_selector(top_json.action_edges[1], "named", "head", "Part", 0, "head", "named")
check_selector(top_json.action_edges[2], "numeric", 0, "Part", 0, "head", "numeric")
check_selector(top_json.action_edges[3], "unindexed", nil, "Part", 0, "head", "unindexed")

local reordered = compile_metadata(table.concat({
  "Top::",
  ' -> Part[head] { return("named") }',
  ' -> Part[0] { return("numeric") }',
  "Part:",
  " other=/H/",
  " head=/H/",
  "",
}, "\n"))
local reordered_edges = compiled_rule_json(reordered, "Top").action_edges
check_selector(reordered_edges[1], "named", "head", "Part", 1, "head", "reordered named")
check_selector(reordered_edges[2], "numeric", 0, "Part", 0, "other", "reordered numeric")

for _, header in ipairs({ "Top::", "Top::OR", "Top::OR+", "Top::OR{1,3}", "Top:+" }) do
  local eligible = compile_metadata(
    header .. '\n @capture_gaps\n -> Part { return("x") }\nPart: /H/\n'
  )
  check_equal(compiled_rule_json(eligible, "Top").capture_gaps.enabled, true,
    header .. " capture eligibility")
end
compile_metadata(table.concat({
  "Top::",
  " @capture_gaps",
  " @mark(gap_control)",
  ' -> Part { return("x") }',
  "Part: /H/",
  "",
}, "\n"))
check(true, "named mark remains independent")

local ineligible = {
  {
    "Top::\n @capture_gaps\n /H/\n",
    "none",
  },
  {
    "Top::\n @capture_gaps\n -> Part\n => Part\nPart: /H/\n",
    "mixed",
  },
  {
    'Top::\n @capture_gaps\n /H/ -> Part { return("x") }\nPart: /H/\n',
    "local_adjacency",
  },
}
for _, fixture in ipairs(ineligible) do
  local result = portable_diagnostic(fixture[1])
  check_equal(result.code, "capture_gaps_rule_ineligible", fixture[2] .. " code")
  check_equal(result.fields.edge_ownership, fixture[2], fixture[2] .. " ownership")
end

local located = portable_diagnostic("Top::\n -bad=/H/\n", "contract-fixture.spec")
check_equal(located.fields.source_id, "contract-fixture.spec", "diagnostic source id")
check_equal(located.fields.line, 2, "diagnostic line")

local descriptor = linkedspec.to_descriptor_json(compiled)
local top_descriptor = descriptor.spec.Top
check_nil(top_descriptor.regex_slots, "fresh descriptor regex slots stay absent")
check_nil(top_descriptor.capture_gaps, "fresh descriptor directive stays absent")
check_nil(top_descriptor.resolved_slot_edges, "fresh descriptor selector rows stay absent")
check_nil(top_descriptor.action_edges[1].selector_kind, "legacy action descriptor selector kind")
check_nil(top_descriptor.meta.resolved_edges[1].selector_kind, "legacy resolved edge selector kind")
check_equal(top_descriptor.dependency_refs[1].label, "Part", "legacy dependency label")
check_equal(top_descriptor.dependency_refs[1].idx, 0, "legacy dependency index")

local normalized = linkedspec.spec_ast.from_json("SpecFile", linkedspec.spec_ast.to_json(parsed))
check_equal(normalized.source_id, "inline", "normalized source id")
check_equal(normalized.rules[2].body[1].kind.slot_id, "head", "normalized slot id")
local legacy_json = linkedspec.spec_ast.to_json(parsed)
legacy_json.source_id = nil
local legacy = linkedspec.spec_ast.from_json("SpecFile", legacy_json)
check_equal(legacy.source_id, "inline", "legacy normalized source default")

local staged = linkedspec.parse_spec_with_staged_user_function_definitions(
  'fn label() {return("hit")}\n\nTop:: /H/\n',
  nil,
  { source_id = "staged.spec" }
)
check_equal(staged.source_id, "staged.spec", "staged source id")

local root = current_directory()
local loaded_options = linkedspec.spec_load_options({ cwd = root, search_roots = {} })
local relative_loaded = linkedspec.load_and_compile_spec(
  linkedspec.path_spec_request("specs/ifelse.spec"),
  loaded_options
)
check_equal(relative_loaded.compiled.source_id, "specs/ifelse.spec", "relative loaded source id")
local absolute_loaded = linkedspec.load_and_compile_spec(
  linkedspec.path_spec_request(root .. "/specs/ifelse.spec"),
  loaded_options
)
check_equal(absolute_loaded.compiled.source_id, "ifelse.spec", "absolute loaded source basename")

local emitted = linkedspec.emit_lua_source_v2(compiled, "metadata-emitted")
check(emitted:find(hex_encode('"source_id":"inline"'), 1, true) ~= nil,
  "emitted normalized carrier retains source id")

check_json_equal(execute_native([[
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }
 LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }
Part:
 head=/H/
 I.return(entry_text())
]], "αHω").value, json.decode('[["prefix","α"],["tail","ω"]]'),
  "Unicode prefix and tail")

check_json_equal(execute_native([[
Top::
 @capture_gaps
 -> Part { return("unexpected") }
 LS { return(array(gap_kind(), gap_text(), match_text())) }
Part: /H/
]], "αH").value, json.decode('["prefix","α","H"]'),
  "candidate available before LS")

check_json_equal(execute_native([[
Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
]], "αHβ\nS🙂Fω").value, json.decode([[
[
 {"kind":"prefix","text":"α","span":{"source_id":"input","start":0,"end":1,"provenance":"gap"},"child":{"slot":{"target_rule":"Part","regex_index":0,"slot_id":"header","selector_kind":"named","authored_selector":"header"},"text":"H","falsey":0}},
 {"kind":"interstitial","text":"β\n","span":{"source_id":"input","start":2,"end":4,"provenance":"gap"},"child":{"slot":{"target_rule":"Part","regex_index":1,"slot_id":"section","selector_kind":"named","authored_selector":"section"},"text":"S","falsey":0}},
 {"kind":"interstitial","text":"🙂","span":{"source_id":"input","start":5,"end":6,"provenance":"gap"},"child":{"slot":{"target_rule":"Part","regex_index":2,"slot_id":"footer","selector_kind":"named","authored_selector":"footer"},"text":"F","falsey":0}},
 {"kind":"tail","text":"ω","span":{"source_id":"input","start":7,"end":8,"provenance":"gap"}}
]
]]), "Unicode segmentation and entry-slot identity")

check_json_equal(execute_native([[
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
]], "HSF").value, json.decode([[
[
 ["prefix","",{"source_id":"input","start":0,"end":0,"provenance":"gap"}],
 ["interstitial","",{"source_id":"input","start":1,"end":1,"provenance":"gap"}],
 ["interstitial","",{"source_id":"input","start":2,"end":2,"provenance":"gap"}],
 ["tail","",{"source_id":"input","start":3,"end":3,"provenance":"gap"}]
]
]]), "empty gap boundaries")

check_json_equal(execute_native([[
Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
]], "p{abc}gap!").value, json.decode('[["p","}"],["gap","!"],["","tail"]]'),
  "child-extended committed cursor")

check_json_equal(execute_native([[
Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
]], "p{axtail").value, json.decode('["p",["a","tail"],"p"]'),
  "nested invocation isolation")

check_json_equal(execute_native([[
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
]], "aHXbS").value, json.decode('["a","Xb",""]'),
  "recognition rollback restores gap state")

local terminal_cases = {
  {
    [[Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
]],
    "abc",
    '["tail","abc",{"source_id":"input","start":0,"end":3,"provenance":"gap"}]',
  },
  {
    [[Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
]],
    "aHtail",
    '["a","tail"]',
  },
  {
    [[Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
]],
    "whole",
    '["whole"]',
  },
  {
    [[Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
]],
    "aHtail",
    '["a","tail"]',
  },
}
for index, case in ipairs(terminal_cases) do
  check_json_equal(execute_native(case[1], case[2]).value, json.decode(case[3]),
    "terminal gap case " .. index)
end

local unavailable = native_error("Direct::\n /H/\n I { return(gap_text()) }\n", "H")
check_equal(unavailable.message,
  "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable",
  "unavailable gap message")
check_equal(unavailable.diagnostic.code, "gap_capture_context_unavailable",
  "unavailable gap code")
check_equal(unavailable.diagnostic.stage, "access_gap_context", "unavailable gap stage")

local post_commit = native_error(
  "Top::OR{1}\n @capture_gaps\n -> Part { return(0) }\n IT { return(gap_kind()) }\nPart: /H/\n",
  "H"
)
check_equal(post_commit.diagnostic.code, "gap_capture_context_unavailable",
  "post-commit gap unavailable")

local regression = native_error(
  "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
  "aH"
)
check_equal(regression.message,
  "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression",
  "cursor regression message")
check_equal(regression.diagnostic.code, "source_location_cursor_regression",
  "cursor regression code")
check_equal(regression.diagnostic.stage, "advance_gap_context", "cursor regression stage")

for _, helper_name in ipairs({ "entry_slot", "gap_span", "gap_text", "gap_kind" }) do
  local arity = native_error(
    "Top::OR{1}\n @capture_gaps\n -> Part { return(" .. helper_name .. "(1)) }\nPart: /H/\n",
    "H"
  )
  check_equal(arity.diagnostic.code, "helper_arity_mismatch", helper_name .. " arity code")
  check_equal(arity.diagnostic.stage, "helper_arity_mismatch", helper_name .. " arity stage")
  check_equal(arity.diagnostic.actual_arity, 1, helper_name .. " actual arity")
end

check(execute_native(
  "Top::OR{2}\n @capture_gaps\n -> Part { return(gap_text()) }\n EX { return(\"unexpected-ex\") }\n E { return(\"unexpected-e\") }\nPart: /H/\n",
  "H"
).value == json.null, "failed minimum returns null")
check(execute_native("Part::\n /H/\n I { return(entry_slot()) }\n", "H").value == json.null,
  "direct entry slot is null")
check_equal(execute_native("Top::\n /H/\n E { return(\"legacy\") }\n", "H").value,
  "legacy", "legacy rule behavior")

do
  local carrier_source = [[Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }
 LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }
Part:
 head=/H/
 I.return(entry_text())
]]
  local source_identity = "lua-gap-carrier.spec"
  local generated_identity = "lua-gap-generated-v2.spec"
  local expected = json.decode('[["prefix","α"],["tail","ω"]]')
  local authored = linkedspec.parse_spec(carrier_source, { source_id = source_identity })
  local normalized_json = linkedspec.spec_ast.to_json(authored)
  local reconstructed = linkedspec.spec_ast.from_json("SpecFile", normalized_json)
  check_json_equal(linkedspec.spec_ast.to_json(reconstructed), normalized_json,
    "normalized reconstruction identity")
  check_equal(reconstructed.source_id, source_identity, "reconstructed source identity")
  local carrier_compiled = linkedspec.compile_spec(reconstructed)
  check_json_equal(
    linkedspec.runtime_parse(linkedspec.runtime_engine(carrier_compiled), "αHω").value,
    expected,
    "reconstructed native value"
  )

  local carrier_descriptor = linkedspec.to_descriptor_json(carrier_compiled)
  local top_meta = carrier_descriptor.spec.Top.meta
  local part_meta = carrier_descriptor.spec.Part.meta
  local expected_slot = json.decode(
    '{"regex_index":0,"slot_id":"head","source_id":"lua-gap-carrier.spec","line":7}'
  )
  local expected_capture = json.decode(
    '{"enabled":true,"directive":"@capture_gaps","source_id":"lua-gap-carrier.spec","line":3}'
  )
  local expected_resolved_slot_edge = json.decode(
    '{"selector_kind":"named","authored_selector":"head","target_rule":"Part","regex_index":0,"target_slot_id":"head"}'
  )
  check_json_equal(part_meta.regex_slots, json.array({ expected_slot }), "descriptor regex slots")
  check_json_equal(top_meta.capture_gaps, expected_capture, "descriptor capture directive")
  check_json_equal(top_meta.resolved_slot_edges, json.array({ expected_resolved_slot_edge }),
    "descriptor resolved slot edges")
  check_json_equal(top_meta.resolved_edges, json.decode(
    '[{"ownership":"action","target":"Part","regex_index":0,"block":true,"fluent":null}]'
  ), "legacy resolved edges")
  check_json_equal(carrier_descriptor.spec.Top.dependency_refs,
    json.decode('[{"label":"Part","idx":0}]'), "legacy dependency refs")

  part_meta.regex_slots[1].slot_id = "detached-mutation"
  top_meta.capture_gaps.enabled = false
  top_meta.resolved_slot_edges[1].target_slot_id = "detached-mutation"
  local fresh_descriptor = linkedspec.to_descriptor_json(carrier_compiled)
  check_json_equal(fresh_descriptor.spec.Part.meta.regex_slots, json.array({ expected_slot }),
    "detached regex slots")
  check_json_equal(fresh_descriptor.spec.Top.meta.capture_gaps, expected_capture,
    "detached capture directive")
  check_json_equal(fresh_descriptor.spec.Top.meta.resolved_slot_edges,
    json.array({ expected_resolved_slot_edge }), "detached resolved slot edges")

  local plan = linkedspec.build_generated_rule_plan(carrier_compiled)
  check_equal(linkedspec.GENERATED_SOURCE_CONTRACT, "linkedspec-generated-source-v2",
    "generated contract")
  check_equal(linkedspec.GENERATED_SOURCE_FORMAT, 2, "generated format")
  local plan_json = json.array()
  for index, row in ipairs(plan) do
    plan_json[index] = linkedspec.generated_plan_row_to_json(row)
  end
  check_json_equal(plan_json, json.decode(
    '[{"label":"Top","family":"default"},{"label":"Part","family":"default"}]'
  ), "generated plan rows")
  check_json_equal(linkedspec.execute_generated_parser_v2(
    carrier_compiled,
    plan,
    "αHω",
    generated_identity
  ), expected, "generated direct value")
  check_json_equal(linkedspec.execute_generated_parser_with_trace_v2(
    carrier_compiled,
    plan,
    "αHω",
    linkedspec.trace_config_disabled(),
    generated_identity
  ), expected, "generated traced value")

  local carrier_cases = {
    {
      [[Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
]],
      "p{abc}gap!",
      '[["p","}"],["gap","!"],["","tail"]]',
    },
    {
      [[Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
]],
      "p{axtail",
      '["p",["a","tail"],"p"]',
    },
    {
      [[Top::
 @capture_gaps
 -> Open { opening = call(Open); return(array(gap_text(), call(Top), gap_text())) }
 -> Atom { return(array(gap_text(), call(Atom))) }
Open:
 /\{/
 I.return(entry_text())
Atom:
 /x/
 I.return(entry_text())
]],
      "p{ax",
      '["p",["a","x"],"p"]',
    },
    {
      [[Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
]],
      "aHXbS",
      '["a","Xb",""]',
    },
  }
  for index, carrier_case in ipairs(carrier_cases) do
    local parsed_case = linkedspec.parse_spec(
      carrier_case[1],
      { source_id = "carrier-case-" .. index .. ".spec" }
    )
    local normalized_case = linkedspec.spec_ast.from_json(
      "SpecFile",
      linkedspec.spec_ast.to_json(parsed_case)
    )
    local compiled_case = linkedspec.compile_spec(normalized_case)
    local expected_case = json.decode(carrier_case[3])
    local case_plan = linkedspec.build_generated_rule_plan(compiled_case)
    check_json_equal(
      linkedspec.runtime_parse(linkedspec.runtime_engine(compiled_case), carrier_case[2]).value,
      expected_case,
      "carrier native case " .. index
    )
    check_json_equal(linkedspec.execute_generated_parser_v2(
      compiled_case,
      case_plan,
      carrier_case[2],
      generated_identity
    ), expected_case, "carrier generated case " .. index)
    check_json_equal(linkedspec.execute_generated_parser_with_trace_v2(
      compiled_case,
      case_plan,
      carrier_case[2],
      linkedspec.trace_config_disabled(),
      generated_identity
    ), expected_case, "carrier traced case " .. index)
  end

  local error_cases = {
    {
      "Direct::\n /H/\n I { return(gap_text()) }\n",
      "H",
      "gap_capture_context_unavailable",
      "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable",
    },
    {
      "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
      "aH",
      "source_location_cursor_regression",
      "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression",
    },
  }
  for case_index, error_case in ipairs(error_cases) do
    local parsed_error = linkedspec.parse_spec(error_case[1], { source_id = source_identity })
    local normalized_error = linkedspec.spec_ast.from_json(
      "SpecFile",
      linkedspec.spec_ast.to_json(parsed_error)
    )
    local compiled_error = linkedspec.compile_spec(normalized_error)
    local native_ok, native_failure = pcall(
      linkedspec.runtime_parse,
      linkedspec.runtime_engine(compiled_error),
      error_case[2]
    )
    check(not native_ok and linkedspec.is_runtime_interpreter_error(native_failure) and
      native_failure.diagnostic.code == error_case[3],
      "reconstructed error " .. case_index)
    local error_plan = linkedspec.build_generated_rule_plan(compiled_error)
    for _, traced in ipairs({ false, true }) do
      local operation = traced and linkedspec.execute_generated_parser_with_trace_v2 or
        linkedspec.execute_generated_parser_v2
      local ok, failure
      if traced then
        ok, failure = pcall(
          operation,
          compiled_error,
          error_plan,
          error_case[2],
          linkedspec.trace_config_disabled(),
          generated_identity
        )
      else
        ok, failure = pcall(operation, compiled_error, error_plan, error_case[2], generated_identity)
      end
      if ok or not linkedspec.is_generated_source_error(failure) then
        fail("generated error type " .. case_index .. "/" .. tostring(traced))
      end
      local projected = linkedspec.generated_source_error_to_json(failure)
      check_equal(projected.stage, "execute_generated",
        "generated error stage " .. case_index .. "/" .. tostring(traced))
      check_equal(projected.code, "generated_execution_failed",
        "generated error code " .. case_index .. "/" .. tostring(traced))
      check_equal(projected.source_identity, generated_identity,
        "generated error identity " .. case_index .. "/" .. tostring(traced))
      check(projected.detail:find(error_case[4], 1, true) ~= nil,
        "generated error detail " .. case_index .. "/" .. tostring(traced))
    end
  end
end

do
  local emitted_assertions_start = assertions

  local value_cases = {
    {
      name = "unicode_entry_falsey",
      source = [[Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
]],
      input = "αHβ\nS🙂Fω",
    },
    {
      name = "empty_spans",
      source = [[Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
]],
      input = "HSF",
    },
    {
      name = "child_cursor",
      source = [[Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
]],
      input = "p{abc}gap!",
    },
    {
      name = "nested_isolation",
      source = [[Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
]],
      input = "p{axtail",
    },
    {
      name = "rollback",
      source = [[Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
]],
      input = "aHXbS",
    },
    {
      name = "lifecycle_order",
      source = [[Top::OR{1}
 I { events = [] }
 @capture_gaps
 -> Part { push(events, array("action", gap_kind(), gap_text())) }
 LS { push(events, array("ls", gap_kind(), gap_text(), match_text())) }
 LE { push(events, array("le", gap_kind(), gap_text())) }
 IT { push(events, array("it")) }
 LX { push(events, array("lx", gap_kind(), gap_text())); return(copy(events)) }
Part: /H/
]],
      input = "aHb",
    },
    {
      name = "no_match_tail",
      source = [[Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
]],
      input = "abc",
    },
    {
      name = "failed_minimum",
      source = [[Top::OR{2}
 @capture_gaps
 -> Part { return(gap_text()) }
 EX { return("unexpected-ex") }
 E { return("unexpected-e") }
Part: /H/
]],
      input = "H",
    },
    {
      name = "direct_entry",
      source = "Part::\n /H/\n I { return(entry_slot()) }\n",
      input = "H",
    },
    {
      name = "legacy",
      source = "Top::\n /H/\n E { return(\"legacy\") }\n",
      input = "H",
    },
  }
  local error_cases = {
    {
      name = "unavailable",
      source = "Direct::\n /H/\n I { return(gap_text()) }\n",
      input = "H",
      diagnostic_code = "gap_capture_context_unavailable",
      marker = "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable",
    },
    {
      name = "regression",
      source = "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
      input = "aH",
      diagnostic_code = "source_location_cursor_regression",
      marker = "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression",
    },
  }
  assert(#value_cases == 10 and #error_cases == 2, "emitted gap case inventory drifted")

  local expected_values = json.harray()
  local emitted_observation, emitted_root = with_temp_directory(function(workspace)
    local traces = workspace .. "/traces"
    assert(command_succeeded("mkdir -p -- " .. shell_quote(traces)),
      "unable to create emitted gap trace directory")
    local manifest_values = json.array()
    for index, fixture in ipairs(value_cases) do
      local identity = "generated-source/lua-gap/" .. fixture.name .. ".spec"
      local fixture_compiled = compile_metadata(fixture.source, identity)
      local expected = linkedspec.runtime_parse(
        linkedspec.runtime_engine(fixture_compiled),
        fixture.input
      ).value
      local plan = linkedspec.build_generated_rule_plan(fixture_compiled)
      local plan_json = json.array()
      for plan_index, row in ipairs(plan) do
        plan_json[plan_index] = linkedspec.generated_plan_row_to_json(row)
      end
      expected_values[fixture.name] = json.harray({ value = expected, plan = plan_json })

      local emitted_source = linkedspec.emit_lua_source_v2(fixture_compiled, identity)
      check(emitted_source:find("linkedspec-generated-source-v2", 1, true) ~= nil,
        fixture.name .. " emitted contract")
      check(emitted_source:find("LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", 1, true) ~= nil,
        fixture.name .. " emitted format")
      local module_path = workspace .. "/value_" .. index .. ".lua"
      local trace_path = traces .. "/" .. fixture.name .. ".trace"
      write_file(module_path, emitted_source)
      manifest_values[index] = json.harray({
        name = fixture.name,
        path = module_path,
        input = fixture.input,
        trace = trace_path,
      })
    end

    local manifest_errors = json.array()
    for index, fixture in ipairs(error_cases) do
      local identity = "generated-source/lua-gap/" .. fixture.name .. ".spec"
      local native_failure = native_error(fixture.source, fixture.input)
      check(native_failure.diagnostic.code == fixture.diagnostic_code and
        native_failure.message == fixture.marker,
        fixture.name .. " native typed error")
      local module_path = workspace .. "/error_" .. index .. ".lua"
      local trace_path = traces .. "/" .. fixture.name .. "-error.trace"
      write_file(module_path, linkedspec.emit_lua_source_v2(
        compile_metadata(fixture.source, identity),
        identity
      ))
      manifest_errors[index] = json.harray({
        name = fixture.name,
        path = module_path,
        input = fixture.input,
        trace = trace_path,
      })
    end

    local manifest_path = workspace .. "/manifest.json"
    local runner_path = workspace .. "/runner.lua"
    local stdout_path = workspace .. "/stdout.json"
    local stderr_path = workspace .. "/stderr.txt"
    write_file(manifest_path, json.encode(json.harray({
      values = manifest_values,
      errors = manifest_errors,
    })))
    write_file(runner_path, [[
local linkedspec = require("linkedspec")
local json = linkedspec.json

local function load_module(path)
  local chunk, failure = loadfile(path)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function trace_config(path)
  return linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    path
  ))
end

local function capture_failure(operation)
  local ok, value = pcall(operation)
  assert(not ok, "generated operation unexpectedly succeeded")
  assert(linkedspec.is_generated_source_error(value), tostring(value))
  return linkedspec.generated_source_error_to_json(value)
end

local manifest_file = assert(io.open(assert(arg[1]), "rb"))
local manifest = json.decode(assert(manifest_file:read("*a")))
assert(manifest_file:close())
local result = json.harray({ values = json.harray(), errors = json.harray() })
for _, fixture in ipairs(manifest.values) do
  local generated = load_module(fixture.path)
  local plan = json.array()
  for index, row in ipairs(generated.plan()) do
    plan[index] = linkedspec.generated_plan_row_to_json(row)
  end
  local direct = generated.execute(fixture.input)
  local traced = generated.execute_with_trace(fixture.input, trace_config(fixture.trace))
  result.values[fixture.name] = json.harray({
    direct = direct,
    traced = traced,
    plan = plan,
    trace = read_file(fixture.trace),
  })
end
for _, fixture in ipairs(manifest.errors) do
  local generated = load_module(fixture.path)
  local direct = capture_failure(function() return generated.execute(fixture.input) end)
  local traced = capture_failure(function()
    return generated.execute_with_trace(fixture.input, trace_config(fixture.trace))
  end)
  result.errors[fixture.name] = json.harray({
    direct = direct,
    traced = traced,
    trace = read_file(fixture.trace),
  })
end
io.write(json.encode(result), "\n")
]])

    local runtime = os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME") or
      (type(jit) == "table" and "luajit" or "lua")
    local command = table.concat({
      "env",
      shell_quote("LUA_PATH=" .. (os.getenv("LUA_PATH") or package.path)),
      shell_quote("LUA_CPATH=" .. (os.getenv("LUA_CPATH") or package.cpath)),
      shell_quote(runtime),
      shell_quote(runner_path),
      shell_quote(manifest_path),
      ">" .. shell_quote(stdout_path),
      "2>" .. shell_quote(stderr_path),
    }, " ")
    check(command_succeeded(command), "fresh emitted gap host status")
    check_equal(read_file(stderr_path), "", "fresh emitted gap host stderr")
    return json.decode(read_file(stdout_path))
  end)

  for _, fixture in ipairs(value_cases) do
    local actual = emitted_observation.values[fixture.name]
    local expected = expected_values[fixture.name]
    check_json_equal(actual.direct, expected.value, fixture.name .. " emitted direct value")
    check_json_equal(actual.traced, expected.value, fixture.name .. " emitted traced value")
    check_json_equal(actual.plan, expected.plan, fixture.name .. " emitted plan")
    local trace = actual.trace
    check(trace:find("generated_rule_enter", 1, true) ~= nil,
      fixture.name .. " emitted enter trace")
    check(trace:find("generated_rule_exit", 1, true) ~= nil,
      fixture.name .. " emitted exit trace")
    check(trace:find("generated-source/lua-gap/" .. fixture.name .. ".spec", 1, true) ~= nil,
      fixture.name .. " emitted trace identity")
  end
  for _, fixture in ipairs(error_cases) do
    local routes = emitted_observation.errors[fixture.name]
    for _, route in ipairs({ "direct", "traced" }) do
      local failure = routes[route]
      check_equal(failure.stage, "execute_generated", fixture.name .. " " .. route .. " stage")
      check_equal(failure.code, "generated_execution_failed", fixture.name .. " " .. route .. " code")
      check_equal(failure.source_identity,
        "generated-source/lua-gap/" .. fixture.name .. ".spec",
        fixture.name .. " " .. route .. " identity")
      check(failure.detail:find(fixture.marker, 1, true) ~= nil,
        fixture.name .. " " .. route .. " detail")
    end
    local trace = routes.trace
    check(trace:find("generated_rule_enter", 1, true) ~= nil,
      fixture.name .. " emitted error enter trace")
    check(trace:find("generated-source/lua-gap/" .. fixture.name .. ".spec", 1, true) ~= nil,
      fixture.name .. " emitted error trace identity")
  end
  check(command_succeeded("test ! -e " .. shell_quote(emitted_root)),
    "fresh emitted gap workspace cleanup")
  if assertions - emitted_assertions_start ~= 105 then
    fail("emitted gap assertion inventory drifted: expected 105, got " ..
      tostring(assertions - emitted_assertions_start))
  end
end

local cases = {
  {
    "Top::\n -bad=/H/\n",
    "regex_slot_name_invalid",
    "parse_declaration",
    2,
    { slot_name = "-bad" },
  },
  {
    "Top::\n 123=/H/\n",
    "regex_slot_name_invalid",
    "parse_declaration",
    2,
    { slot_name = "123" },
  },
  {
    "Top::\n head=/H/\n head=/S/\n",
    "regex_slot_duplicate_name",
    "resolve_declaration",
    3,
    { slot_name = "head", first_line = 2 },
  },
  {
    'Top::\n -> Part[missing] { return("x") }\nPart:\n head=/H/\n',
    "regex_slot_unknown_name",
    "resolve_selector",
    2,
    { target_rule = "Part", authored_selector = "missing" },
  },
  {
    'Top::\n -> Part[2] { return("x") }\nPart:\n /H/\n',
    "regex_slot_index_out_of_range",
    "resolve_selector",
    2,
    { target_rule = "Part", regex_index = 2, regex_count = 1 },
  },
  {
    'Top::\n -> Part[head { return("x") }\nPart:\n head=/H/\n',
    "regex_slot_selector_invalid",
    "parse_selector",
    2,
    { target_rule = "Part", authored_selector = "head" },
  },
  {
    'Top::\n @capture_gaps\n @capture_gaps\n -> Part { return("x") }\nPart: /H/\n',
    "capture_gaps_duplicate_directive",
    "parse_directive",
    3,
    { first_line = 2 },
  },
  {
    'Top::AND\n @capture_gaps\n -> Part { return("x") }\nPart: /H/\n',
    "capture_gaps_rule_ineligible",
    "validate_directive",
    2,
    {
      family = "and",
      cursor_policy = "consume",
      edge_ownership = "action",
      execution_shape = "single_match",
    },
  },
  {
    "Top::\n @capture_gaps\n => Part\nPart: /H/\n",
    "capture_gaps_rule_ineligible",
    "validate_directive",
    2,
    {
      family = "or_default",
      cursor_policy = "seek",
      edge_ownership = "blind",
      execution_shape = "default_scan_loop",
    },
  },
  {
    'Top::\n @capture_gaps\n @move_pos\n -> Part { return("x") }\nPart: /H/\n',
    "capture_gaps_legacy_marker_conflict",
    "validate_directive",
    2,
    { marker = "@move_pos", marker_line = 3 },
  },
}

for case_index, case in ipairs(cases) do
  local result = portable_diagnostic(case[1])
  check_equal(result.code, case[2], "diagnostic " .. case_index .. " code")
  check_equal(result.stage, case[3], "diagnostic " .. case_index .. " stage")
  check_equal(result.fields.rule_label, "Top", "diagnostic " .. case_index .. " rule")
  check_equal(result.fields.source_id, "inline", "diagnostic " .. case_index .. " source")
  check_equal(result.fields.line, case[4], "diagnostic " .. case_index .. " line")
  for field, expected in pairs(case[5]) do
    check_equal(result.fields[field], expected, "diagnostic " .. case_index .. " " .. field)
  end
end

local ADMISSION_SOURCE = [[Top::
 I { items = [] }
 @capture_gaps
 -> Item[word] { push(items, array(call(Item), gap_text())) }
 LX { return(copy(items)) }
Item:
 word=/[a-z]+/
 I.return(entry_text())
]]
local ADMISSION_INPUT = "alpha, beta | gamma\n- delta"
local ADMISSION_EXPECTED = json.decode(
  '[["alpha",""],["beta",", "],["gamma"," | "],["delta","\\n- "]]'
)

local function role_native_execution()
  check_json_equal(execute_native(ADMISSION_SOURCE, ADMISSION_INPUT).value,
    ADMISSION_EXPECTED, "admission native execution")
end

local function role_ordinary_reconstruction()
  local authored = linkedspec.parse_spec(
    ADMISSION_SOURCE,
    { source_id = "lua-gap-admission.spec" }
  )
  local normalized = linkedspec.spec_ast.to_json(authored)
  local reconstructed = linkedspec.spec_ast.from_json("SpecFile", normalized)
  check_json_equal(linkedspec.spec_ast.to_json(reconstructed), normalized,
    "admission reconstruction identity")
  check_json_equal(linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed)),
    ADMISSION_INPUT
  ).value, ADMISSION_EXPECTED, "admission reconstructed execution")
end

local function role_descriptor()
  local compiled = compile_metadata(ADMISSION_SOURCE, "lua-gap-admission.spec")
  local rules = linkedspec.to_descriptor_json(compiled).spec
  check_json_equal(rules.Top.meta.capture_gaps, json.decode(
    '{"enabled":true,"directive":"@capture_gaps","source_id":"lua-gap-admission.spec","line":3}'
  ), "admission descriptor directive")
  check_json_equal(rules.Item.meta.regex_slots, json.decode(
    '[{"regex_index":0,"slot_id":"word","source_id":"lua-gap-admission.spec","line":7}]'
  ), "admission descriptor slot")
end

local function role_generated_plan()
  local compiled = compile_metadata(ADMISSION_SOURCE)
  local plan = linkedspec.build_generated_rule_plan(compiled)
  local plan_json = json.array()
  for index, row in ipairs(plan) do
    plan_json[index] = linkedspec.generated_plan_row_to_json(row)
  end
  check_json_equal(plan_json, json.decode(
    '[{"label":"Top","family":"default"},{"label":"Item","family":"default"}]'
  ), "admission generated plan")
  check_json_equal(linkedspec.execute_generated_parser_v2(
    compiled,
    plan,
    ADMISSION_INPUT,
    "lua-gap-admission.spec"
  ), ADMISSION_EXPECTED, "admission generated execution")
end

local function role_emitted_source()
  local observed, workspace = with_temp_directory(function(root)
    local identity = "generated-source/lua-gap/admission.spec"
    local module_path = root .. "/admission.lua"
    write_file(module_path, linkedspec.emit_lua_source_v2(
      compile_metadata(ADMISSION_SOURCE),
      identity
    ))
    local chunk, load_error = loadfile(module_path)
    if chunk == nil then error(load_error, 0) end
    return chunk().execute(ADMISSION_INPUT)
  end)
  check_json_equal(observed, ADMISSION_EXPECTED, "admission emitted execution")
  check(command_succeeded("test ! -e " .. shell_quote(workspace)),
    "admission emitted cleanup")
end

local function role_target_lifecycle()
  check_json_equal(execute_native([[Top::OR{1}
 I { events = [] }
 @capture_gaps
 -> Part { push(events, array("action", gap_kind(), gap_text())) }
 LS { push(events, array("ls", gap_kind(), gap_text(), match_text())) }
 LE { push(events, array("le", gap_kind(), gap_text())) }
 IT { push(events, array("it")) }
 LX { push(events, array("lx", gap_kind(), gap_text())); return(copy(events)) }
Part: /H/
]], "aHb").value, json.decode(
    '[["ls","prefix","a","H"],["action","prefix","a"],["le","prefix","a"],["it"],["lx","tail","b"]]'
  ), "admission target lifecycle")
end

local function role_recursion_and_rollback()
  check_json_equal(execute_native([[Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
]], "p{axtail").value, json.decode('["p",["a","tail"],"p"]'),
    "admission nested execution")
  check_json_equal(execute_native([[Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
]], "aHXbS").value, json.decode('["a","Xb",""]'),
    "admission rollback execution")
end

local function role_portable_diagnostics()
  check_equal(native_error(
    "Direct::\n /H/\n I { return(gap_text()) }\n",
    "H"
  ).diagnostic.code, "gap_capture_context_unavailable",
    "admission unavailable diagnostic")
  check_equal(native_error(
    "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
    "aH"
  ).diagnostic.code, "source_location_cursor_regression",
    "admission regression diagnostic")
end

local function role_primary_command()
  local result = linkedspec.run_primary_cli({
    "--inline-spec",
    ADMISSION_SOURCE,
    "--input",
    ADMISSION_INPUT,
  })
  check_equal(result.exit_code, 0, "admission primary status")
  check_equal(result.stdout, json.encode(ADMISSION_EXPECTED) .. "\n",
    "admission primary stdout")
  check_equal(result.stderr, "", "admission primary stderr")
end

do
  local admission_assertions_start = assertions
  local role_map = {
    native_execution = role_native_execution,
    ordinary_reconstruction = role_ordinary_reconstruction,
    descriptor = role_descriptor,
    generated_plan = role_generated_plan,
    emitted_source = role_emitted_source,
    target_lifecycle = role_target_lifecycle,
    recursion_and_rollback = role_recursion_and_rollback,
    portable_diagnostics = role_portable_diagnostics,
    primary_command = role_primary_command,
  }
  local runtime = linkedspec.runtime_implementation() == "puc-lua" and "puc_lua" or "luajit"
  local consumer
  for _, candidate in ipairs(contract.recurring_gate.consumers) do
    if candidate.backend == "lua" and candidate.runtime == runtime then consumer = candidate end
  end
  assert(consumer ~= nil, "admitted Lua consumer row is required")
  local declared_roles = json.array()
  for index, role in ipairs(consumer.roles) do declared_roles[index] = role end
  check_json_equal(declared_roles, EXPECTED_ROLES, "admitted role ledger")
  check_equal(#declared_roles, #EXPECTED_ROLES, "admitted role cardinality")
  local role_count = 0
  for _ in pairs(role_map) do role_count = role_count + 1 end
  check_equal(role_count, #EXPECTED_ROLES, "admitted role map cardinality")

  local completed = {}
  local completed_count = 0
  for _, role in ipairs(declared_roles) do
    check(not completed[role], "admitted role executes once: " .. role)
    completed[role] = true
    completed_count = completed_count + 1
    role_map[role]()
  end
  check_equal(completed_count, role_count, "admitted role completion")
  if assertions - admission_assertions_start ~= 30 then
    fail("admission assertion inventory drifted: expected 30, got " ..
      tostring(assertions - admission_assertions_start))
  end
end

io.stdout:write(
  "Lua inter-match gap contract: OK (",
  assertions,
  " assertions; admitted; runtime=",
  linkedspec.runtime_implementation(),
  ")\n"
)
