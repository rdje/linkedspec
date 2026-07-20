local linkedspec = require("linkedspec")
local json = linkedspec.json

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label or "assertion failed" end
end

local function check_equal(actual, expected, label)
  check(actual == expected, (label or "values differ") ..
    ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function check_contains(actual, expected, label)
  check(tostring(actual):find(expected, 1, true) ~= nil, (label or "text differs") ..
    ": expected to contain " .. expected .. ", got " .. tostring(actual))
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

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
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
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-duplicate-slot.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean duplicate-slot test directory", 0) end
  if not ok then error(value, 0) end
end

local function sorted_keys(value)
  local result = {}
  for key in pairs(value) do result[#result + 1] = key end
  table.sort(result)
  return table.concat(result, ",")
end

local function sorted_values(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  table.sort(result)
  return table.concat(result, ",")
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function fixture(contract, fixture_id)
  for _, row in ipairs(contract.fixtures) do
    if row.id == fixture_id then return row end
  end
  error("missing duplicate-slot fixture " .. fixture_id, 0)
end

local function fixture_value(row)
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_source(row.source)),
    row.input
  ).value
end

local function expect_fixture(row, label)
  check_same_json(fixture_value(row), row.expected_result, label or row.id)
end

local function trace_identities(output)
  local identities = {}
  for _, line in ipairs(output) do
    if line:find("lua_runtime:regex_slot_selected", 1, true) then
      local target_rule = line:match("target_rule=([^%s]+)")
      local regex_index = line:match("regex_index=([0-9]+)")
      identities[#identities + 1] = target_rule .. "#" .. regex_index
    end
  end
  return identities
end

local function traced_native(row)
  local output = {}
  local emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH),
    { stdout_writer = function(value) output[#output + 1] = value end }
  )
  local value = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_source(row.source)),
    row.input,
    { trace = emitter }
  ).value
  return value, output
end

local function malformed_compiled(row)
  local compiled = compile_source(row.source)
  local edge = compiled:rule("Top").action_edges[2]
  edge.child_regex_index = 9
  return compiled
end

local contract = json.decode(read_file("capability_conformance/duplicate_regex_slot_identity_contract.json"))
local generated_identity = "duplicate-regex-slot/lua-admission.spec"

local function role_neutral_fixtures(value)
  check_equal(value.contract_id, linkedspec.REGEX_SLOT_IDENTITY_CONTRACT_ID, "contract id")
  check_equal(#value.fixtures, 5, "fixture count")
  check_equal(
    table.concat(value.identity.required_fields, ","),
    "target_rule,regex_index",
    "identity fields"
  )
  check_equal(
    value.selection.ordered.algorithm,
    "match_only_the_required_structural_slot_and_report_that_same_identity",
    "ordered algorithm"
  )
  local ids = {}
  for index, row in ipairs(value.fixtures) do ids[index] = row.id end
  check_equal(
    table.concat(ids, ","),
    "ordered_same_rule_duplicate,choice_same_rule_duplicate,repeated_ordered_duplicate," ..
      "repeated_non_duplicate_control,ordered_cross_target_duplicate",
    "fixture identities"
  )
end

local function role_native_ordered(value)
  local row = fixture(value, "ordered_same_rule_duplicate")
  expect_fixture(row, "native ordered")
  local alternation = linkedspec.compile_runtime_regex_alternation({ "a", "a" })
  local matched = linkedspec.match_runtime_regex_slot(alternation, 1, "aa", 1, "consume")
  check(matched ~= nil, "direct authored slot matches")
  check_equal(matched and matched.alternative_index, 1, "direct authored slot identity")
end

local function role_native_choice(value)
  expect_fixture(fixture(value, "choice_same_rule_duplicate"), "native choice")
end

local function role_repeated_ordered(value)
  expect_fixture(fixture(value, "repeated_ordered_duplicate"), "repeated ordered")
end

local function role_repeated_control(value)
  expect_fixture(fixture(value, "repeated_non_duplicate_control"), "repeated control")
end

local function role_cross_target(value)
  expect_fixture(fixture(value, "ordered_cross_target_duplicate"), "cross target")
end

local function role_loaded(value)
  with_temp_directory(function(root)
    for _, row in ipairs(value.fixtures) do
      local path = root .. "/" .. row.id .. ".spec"
      write_file(path, row.source)
      local loaded = linkedspec.load_and_compile_spec(
        linkedspec.path_spec_request(path),
        linkedspec.spec_load_options({ cwd = root, search_roots = {} })
      )
      check_same_json(
        linkedspec.runtime_parse(loaded:create_engine(), row.input).value,
        row.expected_result,
        row.id .. " loaded"
      )
    end
  end)
end

local function role_reconstructed(value)
  for _, row in ipairs(value.fixtures) do
    local parsed = linkedspec.parse_spec(row.source)
    local reconstructed = linkedspec.spec_ast.from_json(
      "SpecFile",
      json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
    )
    check_same_json(
      linkedspec.runtime_parse(linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed)), row.input).value,
      row.expected_result,
      row.id .. " reconstructed"
    )
  end
end

local function role_descriptor(value)
  for _, fixture_id in ipairs({ "ordered_same_rule_duplicate", "ordered_cross_target_duplicate" }) do
    local row = fixture(value, fixture_id)
    local descriptor = linkedspec.to_descriptor_json(compile_source(row.source))
    check_equal(
      descriptor.meta[value.descriptor_contract.meta_field],
      value.descriptor_contract.meta_value,
      fixture_id .. " descriptor contract"
    )
    local identities = {}
    for index, edge in ipairs(descriptor.spec.Top.meta.resolved_edges) do
      identities[index] = edge.target .. "#" .. edge.regex_index
    end
    check_equal(
      table.concat(identities, ","),
      table.concat(row.expected_match_identities, ","),
      fixture_id .. " descriptor identities"
    )
  end
end

local function role_emitted_source(value)
  local source = linkedspec.emit_lua_source_v2(
    compile_source(fixture(value, "ordered_same_rule_duplicate").source),
    generated_identity
  )
  check_contains(source, "linkedspec-generated-source-v2", "emitted generated contract")
  check_contains(source, "LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", "emitted format")
  check_contains(source, "LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT", "emitted slot constant")
  check_contains(source, value.contract_id, "emitted slot contract")
  check_contains(source, "_EFFECTIVE_SPEC_JSON_HEX", "emitted normalized payload")
  check(source:find("regex_text_identity", 1, true) == nil, "emitted source omits text identity")
end

local function role_generated_direct(value)
  for _, row in ipairs(value.fixtures) do
    local compiled = compile_source(row.source)
    check_same_json(
      linkedspec.execute_generated_parser_v2(
        compiled,
        linkedspec.build_generated_rule_plan(compiled),
        row.input,
        generated_identity
      ),
      row.expected_result,
      row.id .. " generated direct"
    )
  end
end

local function role_native_trace(value)
  local ordered = fixture(value, "repeated_ordered_duplicate")
  local ordered_value, ordered_output = traced_native(ordered)
  check_same_json(ordered_value, ordered.expected_result, "ordered trace value")
  check_equal(
    table.concat(trace_identities(ordered_output), ","),
    table.concat(ordered.expected_match_identities, ","),
    "ordered trace identities"
  )
  check_contains(table.concat(ordered_output), "selection_role=ordered_required", "ordered trace role")

  local choice = fixture(value, "choice_same_rule_duplicate")
  local choice_value, choice_output = traced_native(choice)
  check_same_json(choice_value, choice.expected_result, "choice trace value")
  check_equal(
    table.concat(trace_identities(choice_output), ","),
    table.concat(choice.expected_match_identities, ","),
    "choice trace identities"
  )
  check_contains(table.concat(choice_output), "selection_role=choice", "choice trace role")
end

local function role_generated_trace(value)
  local row = fixture(value, "ordered_cross_target_duplicate")
  local compiled = compile_source(row.source)
  local output = {}
  local result = linkedspec.execute_generated_parser_with_trace_v2(
    compiled,
    linkedspec.build_generated_rule_plan(compiled),
    row.input,
    linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH),
    generated_identity,
    { stdout_writer = function(line) output[#output + 1] = line end }
  )
  check_same_json(result, row.expected_result, "generated trace value")
  check_equal(
    table.concat(trace_identities(output), ","),
    table.concat(row.expected_match_identities, ","),
    "generated trace identities"
  )
end

local function role_primary_command(value)
  for _, row in ipairs(value.fixtures) do
    local result = linkedspec.run_primary_cli({
      "--inline-spec", row.source,
      "--input", row.input,
    })
    check_equal(result.exit_code, 0, row.id .. " primary exit")
    check_equal(result.stderr, "", row.id .. " primary stderr")
    if result.exit_code == 0 then
      check_same_json(json.decode(result.stdout), row.expected_result, row.id .. " primary value")
    else
      check(false, row.id .. " primary value")
    end
  end
end

local function role_invalid_identity_diagnostics(value)
  local expected = {}
  for _, row in ipairs(value.diagnostics) do expected[row.code] = row end

  local source_ok, source_error = capture(function()
    return compile_source("Top::\n -> Missing[3]\n")
  end)
  check_equal(source_ok, false, "invalid source identity rejects")
  check_equal(linkedspec.is_spec_validation_error(source_error), true, "invalid source type")
  check_equal(source_error.code, "regex_slot_identity_invalid", "invalid source code")
  check_equal(source_error.stage, "validate_compiled_rule", "invalid source stage")
  check_same_json(source_error.fields, json.harray({
    rule_label = "Top",
    target_rule = "Missing",
    regex_index = 3,
  }), "invalid source fields")

  local row = fixture(value, "ordered_same_rule_duplicate")
  local malformed = malformed_compiled(row)
  local compiled_ok, compiled_error = capture(function()
    return linkedspec.validate_compiled_regex_slot_identities(malformed)
  end)
  check_equal(compiled_ok, false, "malformed compiled identity rejects")
  check_equal(linkedspec.is_spec_validation_error(compiled_error), true, "malformed compiled type")
  check_same_json(linkedspec.spec_validation_error_to_json(compiled_error), json.harray({
    code = "regex_slot_identity_invalid",
    stage = "validate_compiled_rule",
    message = "rule 'Top' references rule 'Top' regex slot 9, but that structural slot does not exist",
    fields = json.harray({
      rule_label = "Top",
      target_rule = "Top",
      regex_index = 9,
    }),
  }), "malformed compiled diagnostic")

  local runtime_ok, runtime_error = capture(function()
    return linkedspec.runtime_engine(malformed)
  end)
  check_equal(runtime_ok, false, "runtime rejects malformed identity")
  check_equal(linkedspec.is_runtime_interpreter_error(runtime_error), true, "runtime malformed type")
  check_equal(runtime_error.diagnostic.code, "regex_slot_identity_invalid", "runtime malformed code")
  check_equal(runtime_error.diagnostic.stage, "validate_compiled_rule", "runtime malformed stage")
  check_equal(runtime_error.diagnostic.rule_label, "Top", "runtime malformed owner")
  check_equal(runtime_error.diagnostic.target_rule, "Top", "runtime malformed target")
  check_equal(runtime_error.diagnostic.regex_index, 9, "runtime malformed slot")

  local generated_ok, generated_error = capture(function()
    return linkedspec.validate_generated_rule_plan_v2(
      malformed,
      linkedspec.build_generated_rule_plan(malformed),
      generated_identity
    )
  end)
  check_equal(generated_ok, false, "generated adapter rejects malformed identity")
  check_equal(linkedspec.is_generated_source_error(generated_error), true, "generated malformed type")
  check_equal(generated_error.stage, "validate_compiled_rule", "generated malformed stage")
  check_equal(generated_error.code, "regex_slot_identity_invalid", "generated malformed code")
  check_equal(generated_error.rule_label, "Top", "generated malformed owner")
  check_equal(generated_error.target_rule, "Top", "generated malformed target")
  check_equal(generated_error.regex_index, 9, "generated malformed slot")

  local emission_ok, emission_error = capture(function()
    return linkedspec.emit_lua_source_v2(malformed, generated_identity)
  end)
  check_equal(emission_ok, false, "emitter rejects malformed identity")
  check_equal(linkedspec.is_generated_source_error(emission_error), true, "emitter malformed type")
  check_equal(emission_error.stage, "validate_compiled_rule", "emitter malformed stage")
  check_equal(emission_error.code, "regex_slot_identity_invalid", "emitter malformed code")
  check_equal(emission_error.target_rule, "Top", "emitter malformed target")
  check_equal(emission_error.regex_index, 9, "emitter malformed slot")

  local ordered_ok, ordered_error = capture(function()
    return linkedspec.assert_ordered_regex_slot_identity("Top", "First", 0, "Second", 0)
  end)
  check_equal(ordered_ok, false, "ordered mismatch rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(ordered_error), true, "ordered mismatch type")
  check_equal(ordered_error.diagnostic.code, "ordered_regex_slot_identity_lost", "ordered mismatch code")
  check_equal(ordered_error.diagnostic.stage, "execute_rule", "ordered mismatch stage")
  check_equal(
    sorted_keys({
      rule_label = ordered_error.diagnostic.rule_label,
      target_rule = ordered_error.diagnostic.target_rule,
      expected_regex_index = ordered_error.diagnostic.expected_regex_index,
      actual_regex_index = ordered_error.diagnostic.actual_regex_index,
    }),
    sorted_values(expected.ordered_regex_slot_identity_lost.fields),
    "ordered mismatch fields"
  )
  check_contains(
    tostring(ordered_error),
    "ordered_regex_slot_identity_lost stage=execute_rule rule_label=Top target_rule=First " ..
      "expected_regex_index=0 actual_regex_index=0",
    "ordered mismatch message"
  )
end

local role_map = {
  neutral_fixtures = role_neutral_fixtures,
  native_ordered = role_native_ordered,
  native_choice = role_native_choice,
  repeated_ordered = role_repeated_ordered,
  repeated_control = role_repeated_control,
  cross_target = role_cross_target,
  loaded = role_loaded,
  reconstructed = role_reconstructed,
  descriptor = role_descriptor,
  emitted_source = role_emitted_source,
  generated_direct = role_generated_direct,
  native_trace = role_native_trace,
  generated_trace = role_generated_trace,
  primary_command = role_primary_command,
  invalid_identity_diagnostics = role_invalid_identity_diagnostics,
}

local admission = contract.lua_admission
check(admission ~= nil, "neutral contract declares Lua admission")
local declared_roles = admission and admission.roles or {}
check_equal(sorted_values(declared_roles), sorted_keys(role_map), "consumer implements exact declared roles")

local completed = {}
for _, role in ipairs(declared_roles) do
  check(completed[role] == nil, "role " .. role .. " runs only once")
  completed[role] = true
  role_map[role](contract)
end
check_equal(sorted_keys(completed), sorted_keys(role_map), "every declared role completes once")

if #failures == 0 then
  io.stdout:write("duplicate regex-slot identity dual-ABI admission: ", assertions, " assertions passed\n")
else
  io.stderr:write(
    "duplicate regex-slot identity dual-ABI admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
