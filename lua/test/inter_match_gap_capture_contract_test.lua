-- INTER-MATCH-GAP-CAPTURE.6.1 — dormant shared Lua authored/static metadata stage.
--
-- This final consumer path deliberately proves only parsing, validation,
-- compiled provenance, and direct/staged/loaded/normalized/emitted source
-- identity in this leaf. Native gap state, descriptors, generated execution,
-- independent emitted execution, primary execution, and admission remain
-- owned by `.6.2-.6.5`.
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
  "Lua inter-match gap metadata contract: OK (",
  assertions,
  " assertions; dormant; runtime=",
  linkedspec.runtime_implementation(),
  ")\n"
)
