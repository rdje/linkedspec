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

local function with_temp_directory(label, operation)
  local template = "/private/tmp/linkedspec-lua-cursor-admission-" .. label .. ".XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean cursor-admission test directory", 0) end
  if not ok then error(value, 0) end
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function normalized_compiled(source)
  local parsed = linkedspec.parse_spec(source)
  local normalized = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  return linkedspec.compile_spec(normalized)
end

local function runtime_value(compiled, input)
  return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), input).value
end

local function sorted_keys(values)
  local result = {}
  for key in pairs(values) do result[#result + 1] = key end
  table.sort(result)
  return table.concat(result, ",")
end

local function sorted_values(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  table.sort(result)
  return table.concat(result, ",")
end

local function edge_source(parent_family, sources, declared_rules)
  local lines = { parent_family == "and" and "Top::AND" or "Top::" }
  for _, source in ipairs(sources) do lines[#lines + 1] = " " .. source end
  for _, label in ipairs(declared_rules) do
    lines[#lines + 1] = ""
    lines[#lines + 1] = label .. ":"
    lines[#lines + 1] = " /x/ /y/"
  end
  return table.concat(lines, "\n") .. "\n"
end

local function validation_diagnostic(source)
  local ok, failure = capture(function()
    local parsed = linkedspec.parse_spec(source)
    local normalized = linkedspec.spec_ast.from_json(
      "SpecFile",
      json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
    )
    return linkedspec.validate_spec(normalized)
  end)
  check_equal(ok, false, "portable diagnostic fixture rejects")
  check_equal(linkedspec.is_spec_validation_error(failure), true, "portable diagnostic type")
  return linkedspec.spec_validation_error_to_json(failure)
end

local contract = json.decode(read_file("capability_conformance/rule_local_cursor_contract.json"))

local default_source = [[
Top::
 /x/
 -> Top { return("hit") }
]]

local and_source = [[
Top::AND
 /x/
 -> Top { return("hit") }
]]

local mixed_source = [[
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
]]

local recursion_source = [[
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
]]

local ordered_source = [[
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
]]

local anchored_source = [[
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
]]

local generated_identity = "rule-local-cursor/lua-admission.spec"
local state = { observed_diagnostics = {} }

local function observe(code)
  state.observed_diagnostics[code] = true
end

local function role_native_default_family()
  check_equal(contract.policy.or_default_cursor, "seek", "neutral default policy")
  local compiled = compile_source(default_source)
  check_equal(runtime_value(compiled, "prefix x"), "hit", "native default seeks")
  check_equal(compiled:rule("Top").mode_metadata.is_and, false, "native default family metadata")
end

local function role_native_and_family()
  check_equal(contract.policy.and_cursor, "consume", "neutral AND policy")
  local compiled = compile_source(and_source)
  check_same_json(runtime_value(compiled, "prefix x"), json.null, "native AND rejects leading input")
  check_equal(runtime_value(compiled, "x"), "hit", "native AND accepts contiguous input")
  check_equal(compiled:rule("Top").mode_metadata.is_and, true, "native AND family metadata")
end

local function role_ordinary_normalized()
  local parsed = linkedspec.parse_spec(mixed_source)
  local encoded = json.encode(linkedspec.spec_ast.to_json(parsed))
  for _, option in ipairs(contract.option_retirement.dynamic_option_names) do
    check(encoded:find(option, 1, true) == nil, "normalized AST omits " .. option)
  end
  check_same_json(
    runtime_value(normalized_compiled(mixed_source), "prefix x"),
    json.array({ "hit" }),
    "normalized execution preserves mixed-family policy"
  )
end

local function role_loaded_spec()
  with_temp_directory("loaded", function(root)
    local path = root .. "/loaded.spec"
    write_file(path, mixed_source)
    local loaded = linkedspec.load_and_compile_spec(
      linkedspec.path_spec_request(path),
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    check_same_json(
      linkedspec.runtime_parse(loaded:create_engine(), "prefix x").value,
      json.array({ "hit" }),
      "loaded execution preserves mixed-family policy"
    )
  end)
end

local function role_descriptor_v1()
  local source = [[
Top::
 /x/ -> Top { return("seek") }
Consume:AND
 /x/ -> Consume { return("consume") }
]]
  local descriptor = linkedspec.to_descriptor_json(compile_source(source))
  check_equal(
    descriptor.meta.cursor_contract,
    contract.descriptor_contract.meta.cursor_contract,
    "descriptor cursor identity"
  )
  check_equal(descriptor.spec.Top.meta.cursor_policy, "seek", "descriptor default policy")
  check_equal(descriptor.spec.Consume.meta.cursor_policy, "consume", "descriptor AND policy")
  check(json.encode(descriptor):find('"parse_mode"', 1, true) == nil, "descriptor omits global cursor field")
end

local function role_emitted_source_v2()
  local emitted = linkedspec.emit_lua_source_v2(compile_source(mixed_source), generated_identity)
  check_contains(emitted, contract.generated_source_v2.contract_id, "emitted v2 contract")
  check_contains(
    emitted,
    "LINKEDSPEC_GENERATED_SOURCE_FORMAT = " .. contract.generated_source_v2.format_version,
    "emitted v2 format"
  )
  check_contains(emitted, "function M.execute(", "emitted direct entry")
  check_contains(emitted, "function M.execute_with_trace(", "emitted trace entry")
  check(emitted:find("cursor_policy", 1, true) == nil, "emitted source omits cursor policy field")
  for _, option in ipairs(contract.option_retirement.dynamic_option_names) do
    check(emitted:find(option, 1, true) == nil, "emitted source omits " .. option)
  end
end

local function role_generated_direct()
  local compiled = compile_source(default_source)
  local plan = linkedspec.build_generated_rule_plan(compiled)
  check_same_json(
    linkedspec.generated_plan_row_to_json(plan[1]),
    json.harray({ label = "Top", family = "default" }),
    "generated plan stays minimal"
  )
  check_equal(
    linkedspec.execute_generated_parser_v2(compiled, plan, "prefix x", generated_identity),
    "hit",
    "generated direct preserves default seek"
  )
  local ok, failure = capture(function()
    return linkedspec.validate_generated_rule_plan_v2(
      compiled,
      plan,
      generated_identity,
      "linkedspec-generated-source-v1"
    )
  end)
  check_equal(ok, false, "stale generated contract rejects")
  check_equal(linkedspec.is_generated_source_error(failure), true, "stale contract typed error")
  local projected = linkedspec.generated_source_error_to_json(failure)
  check_equal(
    projected.code,
    contract.generated_source_v2.v1_reconstruction_error,
    "stale contract portable code"
  )
  observe(projected.code)
end

local function role_generated_trace()
  local compiled = compile_source(default_source)
  local output = {}
  check_equal(
    linkedspec.execute_generated_parser_with_trace_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      "prefix x",
      linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
      generated_identity,
      { stdout_writer = function(value) output[#output + 1] = value end }
    ),
    "hit",
    "generated trace preserves direct value"
  )
  local trace = table.concat(output)
  check_contains(trace, "generated_rule_enter", "generated trace enters rule")
  check_contains(trace, "generated_family_decision", "generated trace derives family")
  check_contains(trace, "generated_rule_exit", "generated trace exits rule")
  check_contains(trace, "source_identity=" .. generated_identity, "generated trace identity")
end

local function role_mixed_parent_child()
  check_same_json(
    runtime_value(compile_source(mixed_source), "prefix x"),
    json.array({ "hit" }),
    "AND parent does not override seeking child"
  )
end

local function role_recursion()
  check_same_json(
    runtime_value(compile_source(recursion_source), "p junk xp junk z"),
    json.array({ json.array({ "done" }) }),
    "recursive entries re-derive family policy"
  )
end

local function role_structural_ordered_landmarks()
  check_same_json(
    runtime_value(compile_source(ordered_source), "junk h junk b"),
    json.array({ "header", "body" }),
    "AND over seeking children implements ordered landmarks"
  )
end

local function role_structural_anchored_choice()
  check_same_json(
    runtime_value(compile_source(anchored_source), "prefix x"),
    json.null,
    "OR over consuming children implements anchored choice"
  )
end

local function role_static_option_removal()
  local interpreter_source = read_file("lua/src/linkedspec/interpreter.lua")
  local loader_source = read_file("lua/src/linkedspec/spec_loader.lua")
  local corpus_source = read_file("lua/src/linkedspec/corpus.lua")
  local emitter_source = read_file("lua/src/linkedspec/source_emitter.lua")
  local cli_source = read_file("lua/src/linkedspec/primary_cli.lua")
  local matching_source = read_file("lua/src/linkedspec/matching.lua")
  check(interpreter_source:find("engine.parse_mode", 1, true) == nil, "engine override state is absent")
  check(loader_source:find("parse_mode", 1, true) == nil, "loader override is absent")
  check(corpus_source:find("parse_mode", 1, true) == nil, "corpus override is absent")
  check(emitter_source:find("parse_mode", 1, true) == nil, "emitter override is absent")
  check(cli_source:find("options.parse_mode", 1, true) == nil, "CLI execution override is absent")
  check(cli_source:find("--parse-mode MODE", 1, true) == nil, "CLI help override is absent")
  check(cli_source:find('option == "--parse-mode"', 1, true) ~= nil, "CLI tombstone remains")
  check(matching_source:find("function M.runtime_match", 1, true) ~= nil, "runtime matcher remains")
  check(matching_source:find("function M.seek_match", 1, true) ~= nil, "seek matcher remains")
  check(matching_source:find("function M.consume_match", 1, true) ~= nil, "consume matcher remains")

  local expected = contract.option_retirement.error
  local compiled = compile_source(and_source)
  for _, option in ipairs(contract.option_retirement.dynamic_option_names) do
    local options = {}
    options[option] = "seek"
    local ok, failure = capture(function() return linkedspec.runtime_engine(compiled, options) end)
    check_equal(ok, false, option .. " rejects")
    check_equal(linkedspec.is_runtime_interpreter_error(failure), true, option .. " typed error")
    local projected = failure and failure.diagnostic or {}
    check_equal(projected.stage, expected.stage, option .. " stage")
    check_equal(projected.code, expected.code, option .. " code")
    check_equal(projected.option_name, expected.fields.option_name, option .. " normalized field")
    observe(projected.code)
  end
end

local function role_primary_command()
  local success = linkedspec.run_primary_cli({
    "--inline-spec",
    default_source,
    "--input",
    "prefix x",
  })
  check_equal(success.exit_code, 0, "primary default status")
  check_equal(success.stdout, '"hit"\n', "primary default value")
  check_equal(success.stderr, "", "primary default stderr")

  local cli = contract.option_retirement.cli
  local removed = linkedspec.run_primary_cli({
    "--inline-spec",
    default_source,
    "--input",
    "x",
    cli.flag,
    "seek",
  })
  check_equal(removed.exit_code, cli.exit, "primary retired flag status")
  check_equal(removed.stdout, "", "primary retired flag stdout")
  check_equal(removed.stderr:match("^[^\n]+"), "linkedspec: " .. cli.stderr, "primary retired flag detail")
  local help = linkedspec.run_primary_cli({ "--help" })
  check_equal(help.exit_code, 0, "primary help status")
  check(help.stdout:find(cli.flag, 1, true) == nil, "primary help omits retired flag")
  check_equal(help.stderr, "", "primary help stderr")
end

local function role_portable_diagnostics()
  local diagnostics = {}
  for _, row in ipairs(contract.diagnostics) do diagnostics[row.code] = row end

  local invalid_rows = {}
  for _, row in ipairs(contract.edge_resolution_cases) do
    if row.expected_error ~= nil then invalid_rows[#invalid_rows + 1] = row end
  end
  for _, row in ipairs(contract.rule_edge_set_cases) do
    if row.expected_error ~= nil then invalid_rows[#invalid_rows + 1] = row end
  end

  for _, row in ipairs(invalid_rows) do
    local sources = row.sources or { row.source }
    local projected = validation_diagnostic(edge_source(row.parent_family, sources, row.declared_rules))
    local expected = diagnostics[row.expected_error]
    check_equal(projected.code, row.expected_error, row.id .. " portable code")
    check_equal(projected.stage, expected.stage, row.id .. " portable stage")
    check_equal(sorted_keys(projected.fields), sorted_values(expected.fields), row.id .. " portable fields")
    observe(projected.code)
  end

  local expected = {}
  for _, row in ipairs(contract.diagnostics) do expected[row.code] = true end
  check_equal(
    sorted_keys(state.observed_diagnostics),
    sorted_keys(expected),
    "composed Lua roles observe every portable diagnostic/removal outcome"
  )
end

local role_map = {
  native_default_family = role_native_default_family,
  native_and_family = role_native_and_family,
  ordinary_normalized = role_ordinary_normalized,
  loaded_spec = role_loaded_spec,
  descriptor_v1 = role_descriptor_v1,
  emitted_source_v2 = role_emitted_source_v2,
  generated_direct = role_generated_direct,
  generated_trace = role_generated_trace,
  mixed_parent_child = role_mixed_parent_child,
  recursion = role_recursion,
  structural_ordered_landmarks = role_structural_ordered_landmarks,
  structural_anchored_choice = role_structural_anchored_choice,
  static_option_removal = role_static_option_removal,
  primary_command = role_primary_command,
  portable_diagnostics = role_portable_diagnostics,
}

local admission = contract.lua_dual_abi_admission
check(admission ~= nil, "neutral contract declares Lua dual-ABI admission")
local declared_roles = admission and admission.roles or {}
check_equal(sorted_values(declared_roles), sorted_keys(role_map), "consumer implements exact declared roles")

local completed = {}
for _, role in ipairs(declared_roles) do
  check(completed[role] == nil, "role " .. role .. " runs only once")
  completed[role] = true
  role_map[role]()
end
check_equal(sorted_keys(completed), sorted_keys(role_map), "every declared role completes once")

if #failures == 0 then
  io.stdout:write("rule-local cursor dual-ABI admission: ", assertions, " assertions passed\n")
else
  io.stderr:write(
    "rule-local cursor dual-ABI admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
