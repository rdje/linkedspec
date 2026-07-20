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

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then return first == 0 end
  return first == true and (third == nil or third == 0)
end

local function with_temp_directory(operation)
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-repeated-result.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean repeated-result test directory", 0) end
  if not ok then error(value, 0) end
  return value
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
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

local function nullable(value)
  if value == json.null then return nil end
  return value
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function all_rows(contract)
  local result = {}
  for _, row in ipairs(contract.mode_cases) do result[#result + 1] = row end
  for _, row in ipairs(contract.special_cases) do result[#result + 1] = row end
  return result
end

local function case_by_id(contract, case_id)
  for _, row in ipairs(all_rows(contract)) do
    if row.id == case_id then return row end
  end
  error("missing repeated-action-result case " .. case_id, 0)
end

local function execute_row(row)
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_source(row.source)),
    row.input
  )
end

local function expect_native(row, label)
  local ok, result = capture(function() return execute_row(row) end)
  check_equal(ok, true, (label or row.id) .. " executes")
  if not ok then return end
  check_same_json(result.value, row.expected_result, (label or row.id) .. " value")
  check_equal(result.cursor_code_unit, row.expected_position, (label or row.id) .. " cursor")
end

local function selected_identities(output)
  local result = {}
  for _, line in ipairs(output) do
    if line:find("lua_runtime:regex_slot_selected", 1, true) then
      local target_rule = line:match("target_rule=([^%s]+)")
      local regex_index = line:match("regex_index=([0-9]+)")
      result[#result + 1] = target_rule .. "#" .. regex_index
    end
  end
  return result
end

local function traced_native(row)
  local output = {}
  local emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH),
    { stdout_writer = function(value) output[#output + 1] = value end }
  )
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_source(row.source)),
    row.input,
    { trace = emitter }
  )
  return result.value, output
end

local function load_generated_module(source, chunk_name)
  local loader = loadstring or load
  local chunk, load_error = loader(source, chunk_name)
  if not chunk then error(load_error, 0) end
  return chunk()
end

local contract = json.decode(read_file("capability_conformance/repeated_action_result_contract.json"))
local generated_identity = "repeated-action-result/lua-admission.spec"

local function role_neutral_contract(value)
  check_equal(value.contract_id, "linkedspec-explicit-repetition-action-result-v1", "contract id")
  check_equal(
    table.concat(value.scope.explicit_repetition_modes, ","),
    "Star,Plus,Optional,Or,OrPlus,OrBounded",
    "explicit mode inventory"
  )
  check_equal(#value.mode_cases, 8, "mode case count")
  check_equal(#value.special_cases, 10, "special case count")
  check_equal(value.semantics.lifecycle_return, "whole_rule_return", "lifecycle authority")
  check_equal(value.generated_source_v2.format_version, 2, "generated format")
end

local function role_ast_metadata(value)
  for _, row in ipairs(value.mode_cases) do
    local rule = compile_source(row.source):rule("Top")
    check_equal(rule.mode_metadata.is_repetition, row.is_repetition, row.id .. " repetition")
    check_equal(rule.mode_metadata.rep_min, nullable(row.rep_min), row.id .. " minimum")
    check_equal(rule.mode_metadata.rep_max, nullable(row.rep_max), row.id .. " maximum")
    check_equal(linkedspec.classify_generated_rule_family(rule), row.generated_family, row.id .. " family")
  end
  local blind = compile_source(case_by_id(value, "blind_or_repeats").source):rule("Top")
  check_equal(blind.mode_metadata.rep_min, 1, "blind OR minimum")
  check_equal(linkedspec.classify_generated_rule_family(blind), "rep_bcode", "blind OR family")
end

local function role_native_mode_matrix(value)
  for _, row in ipairs(value.mode_cases) do expect_native(row) end
end

local function role_native_special_cases(value)
  for _, row in ipairs(value.special_cases) do
    if row.edge_surface ~= "blind" then expect_native(row) end
  end
end

local function role_loaded(value)
  local row = case_by_id(value, "explicit_or_two_hits")
  with_temp_directory(function(root)
    local path = root .. "/explicit-or.spec"
    write_file(path, row.source)
    local loaded = linkedspec.load_and_compile_spec(
      linkedspec.path_spec_request(path),
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    local result = linkedspec.runtime_parse(loaded:create_engine(), row.input)
    check_same_json(result.value, row.expected_result, "loaded value")
  end)
end

local function role_reconstructed(value)
  local row = case_by_id(value, "explicit_or_two_hits")
  local parsed = linkedspec.parse_spec(row.source)
  local reconstructed = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed)),
    row.input
  )
  check_same_json(result.value, row.expected_result, "reconstructed value")
end

local function role_descriptor(value)
  for _, case_id in ipairs({ "explicit_or_two_hits", "pipe_distinct_scalar" }) do
    local row = case_by_id(value, case_id)
    local metadata = linkedspec.to_descriptor_json(compile_source(row.source)).spec.Top.meta
    check_equal(metadata.family, value.descriptor_contract.family, case_id .. " descriptor family")
    check_equal(metadata.cursor_policy, value.descriptor_contract.cursor_policy, case_id .. " descriptor cursor")
    check_equal(metadata.mode.is_repetition, row.is_repetition, case_id .. " descriptor repetition")
    check_equal(metadata.mode.rep_min, nullable(row.rep_min), case_id .. " descriptor minimum")
    check_equal(metadata.mode.rep_max, nullable(row.rep_max), case_id .. " descriptor maximum")
  end
end

local function role_emitted_source(value)
  local row = case_by_id(value, "explicit_or_two_hits")
  local compiled = compile_source(row.source)
  local emitted = linkedspec.emit_lua_source_v2(compiled, generated_identity)
  check_contains(emitted, "linkedspec-generated-source-v2", "emitted contract")
  check_contains(emitted, "LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", "emitted format")
  check_contains(emitted, "rep_acode", "emitted repeated family")
  local generated = load_generated_module(emitted, "@repeated-action-result-emitted")
  check_same_json(generated.execute(row.input), row.expected_result, "emitted direct value")
  local output = {}
  check_same_json(
    generated.execute_with_trace(
      row.input,
      linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH),
      { stdout_writer = function(line) output[#output + 1] = line end }
    ),
    row.expected_result,
    "emitted traced value"
  )
  check_equal(#selected_identities(output), 2, "emitted selected-hit count")
  local ok, failure = capture(function()
    return linkedspec.validate_generated_rule_plan_v2(
      compiled,
      { linkedspec.generated_plan_row("Top", "or_acode") },
      generated_identity
    )
  end)
  check_equal(ok, false, "stale bare-OR family rejects")
  check_equal(linkedspec.is_generated_source_error(failure), true, "stale family typed")
  if not ok and linkedspec.is_generated_source_error(failure) then
    check_equal(failure.code, linkedspec.GENERATED_PLAN_FAMILY_MISMATCH_CODE, "stale family code")
  end
end

local function role_generated_direct(value)
  for _, row in ipairs(value.mode_cases) do
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
  local row = case_by_id(value, "explicit_or_two_hits")
  local result, output = traced_native(row)
  check_same_json(result, row.expected_result, "native trace value")
  check_equal(
    table.concat(selected_identities(output), ","),
    table.concat(row.expected_selected_slots, ","),
    "native trace selected slots"
  )
end

local function role_generated_trace(value)
  local row = case_by_id(value, "explicit_or_two_hits")
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
    table.concat(selected_identities(output), ","),
    table.concat(row.expected_selected_slots, ","),
    "generated trace selected slots"
  )
end

local function role_primary_command(value)
  for _, case_id in ipairs({ "explicit_or_two_hits", "pipe_distinct_scalar" }) do
    local row = case_by_id(value, case_id)
    local result = linkedspec.run_primary_cli({
      "--inline-spec", row.source,
      "--input", row.input,
    })
    check_equal(result.exit_code, 0, case_id .. " primary exit")
    check_equal(result.stderr, "", case_id .. " primary stderr")
    if result.exit_code == 0 then
      check_same_json(json.decode(result.stdout), row.expected_result, case_id .. " primary value")
    end
  end
end

local function role_corpus_bundle(value)
  local row = case_by_id(value, value.corpus_bundle.fixture_id)
  local source = read_file(value.corpus_bundle.source)
  local input = read_file(value.corpus_bundle.input):gsub("\n$", "")
  local expected = json.decode(read_file(value.corpus_bundle.expected))
  check_equal(source, row.source, "corpus source")
  check_equal(input, row.input, "corpus input")
  check_same_json(expected, row.expected_result, "corpus expected")
  check_same_json(
    linkedspec.runtime_parse(linkedspec.runtime_engine(compile_source(source)), input).value,
    expected,
    "corpus execution"
  )
end

local function role_lifecycle_authority(value)
  for _, case_id in ipairs({
    "exit_lifecycle_overrides_collection",
    "loop_end_lifecycle_exits_rule",
  }) do
    expect_native(case_by_id(value, case_id), case_id .. " lifecycle")
  end
end

local function role_bounds_and_progress(value)
  for _, case_id in ipairs({
    "compact_optional_one_hit",
    "bounded_exact_two_hits",
    "bounded_up_to_two_hits",
    "zero_permitted_hits_empty",
    "below_minimum_is_null",
  }) do
    expect_native(case_by_id(value, case_id), case_id .. " bound")
  end
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_source([[
Top::OR{,3}
 /x*/ -> Top[0] { return("Z") }
]])),
    ""
  )
  check_same_json(result.value, json.array({ "Z" }), "zero-progress value")
  check_equal(result.cursor_code_unit, 0, "zero-progress cursor")
end

local role_map = {
  neutral_contract = role_neutral_contract,
  ast_metadata = role_ast_metadata,
  native_mode_matrix = role_native_mode_matrix,
  native_special_cases = role_native_special_cases,
  loaded = role_loaded,
  reconstructed = role_reconstructed,
  descriptor = role_descriptor,
  emitted_source = role_emitted_source,
  generated_direct = role_generated_direct,
  native_trace = role_native_trace,
  generated_trace = role_generated_trace,
  primary_command = role_primary_command,
  corpus_bundle = role_corpus_bundle,
  lifecycle_authority = role_lifecycle_authority,
  bounds_and_progress = role_bounds_and_progress,
}

local admission = contract.admissions.lua_dual_abi
check_equal(admission.status, "complete", "Lua admission status")
local declared_roles = admission.roles or {}
check_equal(sorted_values(declared_roles), sorted_keys(role_map), "consumer implements exact declared roles")

local completed = {}
for _, role in ipairs(declared_roles) do
  check(completed[role] == nil, "role " .. role .. " runs only once")
  completed[role] = true
  role_map[role](contract)
end
check_equal(sorted_keys(completed), sorted_keys(role_map), "every declared role completes once")

if #failures == 0 then
  io.stdout:write("repeated action-result dual-ABI admission: ", assertions, " assertions passed\n")
else
  io.stderr:write(
    "repeated action-result dual-ABI admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
