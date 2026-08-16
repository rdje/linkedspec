-- INTER-MATCH-GAP-CAPTURE.6.3 — dormant shared Lua carrier-execution stage.
--
-- This final consumer path now proves parsing, validation, compiled provenance,
-- source identity, private native state/lifecycle, normalized reconstruction,
-- compatible descriptors, and generated-v2 execution on both Lua ABIs.
-- Independent emitted execution, primary execution, and admission remain
-- owned by `.6.4-.6.5`.
-- DORMANT: INTER-MATCH-GAP-CAPTURE.6.5 owns Lua runtime admission

local linkedspec = require("linkedspec")
local json = linkedspec.json

local CONTRACT_ID = "linkedspec-inter-match-gap-capture-v1"
local CONTRACT_PATH = "capability_conformance/inter_match_gap_capture_contract.json"
local FUTURE_ROLES = {
  "native_execution",
  "ordinary_reconstruction",
  "descriptor",
  "generated_plan",
  "emitted_source",
  "target_lifecycle",
  "recursion_and_rollback",
  "portable_diagnostics",
  "primary_command",
}

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
check_equal(contract.rollout[6].status, "pending", "PUC rollout status")
check_equal(contract.rollout[7].id, "luajit_runtime", "LuaJIT rollout id")
check_equal(contract.rollout[7].status, "pending", "LuaJIT rollout status")
check_equal(#FUTURE_ROLES, 9, "future role count")
for index, role in ipairs(contract.recurring_gate.consumers[5].roles) do
  check_equal(FUTURE_ROLES[index], role, "future role " .. index)
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

io.stdout:write(
  "Lua inter-match gap contract: OK (",
  assertions,
  " assertions; dormant; runtime=",
  linkedspec.runtime_implementation(),
  ")\n"
)
