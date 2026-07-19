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

local function check_contains(actual, expected, label)
  check(tostring(actual):find(expected, 1, true) ~= nil, (label or "text differs") ..
    ": expected to contain " .. expected .. ", got " .. tostring(actual))
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
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
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-root-routes.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean route-test directory", 0) end
  if not ok then error(value, 0) end
end

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function trace_emitter()
  local output = {}
  local emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
    { stdout_writer = function(value) output[#output + 1] = value end }
  )
  return emitter, output
end

local function selection_event(emitter, label)
  local matches = {}
  for _, event in ipairs(linkedspec.trace_events(emitter)) do
    if event.topic == "lua_runtime:entry_rule_selection" then matches[#matches + 1] = event end
  end
  check_equal(#matches, 1, label .. " event count")
  return matches[1] or { details = "", level = linkedspec.TRACE_LOW }
end

local marked_source = [[
Earlier:
 /x/
 I { return("earlier") }

Marked::
 /x/
 I { return("marked") }

Later::
 /x/
 I { return("later") }
]]

local markerless_source = [[
First:
 /x/
 I { return("first") }

Second:
 /x/
 I { return("second") }
]]

check_equal(
  linkedspec.generated_source_stage_name(linkedspec.VALIDATE_GENERATED_SPEC_STAGE),
  "validate_spec",
  "generated validation stage"
)
check_equal(
  linkedspec.generated_source_stage_name(linkedspec.SELECT_GENERATED_ENTRY_RULE_STAGE),
  "select_entry_rule",
  "generated selection stage"
)
check_equal(
  linkedspec.generated_source_code_name(linkedspec.GENERATED_NO_RULES_DEFINED_CODE),
  "no_rules_defined",
  "generated zero-rule code"
)
check_equal(
  linkedspec.generated_source_code_name(linkedspec.GENERATED_ENTRY_RULE_NOT_FOUND_CODE),
  "entry_rule_not_found",
  "generated unknown-rule code"
)

with_temp_directory(function(root)
  local options = linkedspec.spec_load_options({ cwd = root, search_roots = {} })
  local routes = {
    { name = "marked", source = marked_source, default_value = "marked", explicit = "Earlier", explicit_value = "earlier" },
    { name = "markerless", source = markerless_source, default_value = "first", explicit = "Second", explicit_value = "second" },
  }

  for _, route in ipairs(routes) do
    local path = root .. "/" .. route.name .. ".spec"
    write_file(path, route.source)
    local loaded = linkedspec.load_and_compile_spec(linkedspec.path_spec_request(path), options)
    local descriptor = linkedspec.to_descriptor_json(loaded.compiled)
    check_equal(linkedspec.runtime_parse(loaded:create_engine(), "x").value, route.default_value, route.name .. " loaded default")
    check_equal(
      linkedspec.runtime_parse(loaded:create_engine(), "x", { top_rule = route.explicit }).value,
      route.explicit_value,
      route.name .. " loaded explicit"
    )
    check_same_json(linkedspec.to_descriptor_json(loaded.compiled), descriptor, route.name .. " loaded descriptor")

    local normalized_json = json.decode(json.encode(linkedspec.spec_ast.to_json(linkedspec.parse_spec(route.source))))
    local reconstructed = linkedspec.compile_spec(linkedspec.spec_ast.from_json("SpecFile", normalized_json))
    check_equal(linkedspec.runtime_parse(linkedspec.runtime_engine(reconstructed), "x").value, route.default_value, route.name .. " reconstructed default")
    check_equal(
      linkedspec.runtime_parse(linkedspec.runtime_engine(reconstructed), "x", { top_rule = route.explicit }).value,
      route.explicit_value,
      route.name .. " reconstructed explicit"
    )
    check_same_json(linkedspec.to_descriptor_json(reconstructed), descriptor, route.name .. " reconstructed descriptor")
  end

  local zero_path = root .. "/zero.spec"
  write_file(zero_path, "# no rules\n")
  local zero_ok, zero = capture(function()
    return linkedspec.load_and_compile_spec(linkedspec.path_spec_request(zero_path), options)
  end)
  check_equal(zero_ok, false, "loader zero rejected")
  check_equal(linkedspec.is_spec_pipeline_error(zero), true, "loader zero type")
  check_equal(zero.stage, "validate_spec", "loader zero stage")
  check_equal(zero.code, "no_rules_defined", "loader zero code")
  check_equal(zero.detail, "spec does not define any rules", "loader zero detail")

  local duplicate_path = root .. "/duplicate.spec"
  write_file(duplicate_path, "Same:\n /x/\n\nSame:\n /y/\n")
  local duplicate_ok, duplicate = capture(function()
    return linkedspec.load_and_compile_spec(linkedspec.path_spec_request(duplicate_path), options)
  end)
  check_equal(duplicate_ok, false, "loader unrelated validation rejected")
  check_equal(linkedspec.is_spec_pipeline_error(duplicate), true, "loader unrelated validation type")
  check_equal(duplicate.stage, "validate_spec", "loader unrelated validation stage")
  check_equal(duplicate.code, "spec_validation_failed", "loader unrelated validation code")

  for _, route in ipairs(routes) do
    local compiled = linkedspec.compile_spec(linkedspec.parse_spec(route.source))
    local plan = linkedspec.build_generated_rule_plan(compiled)
    local identity = "root-routes/" .. route.name .. ".spec"
    local descriptor = linkedspec.to_descriptor_json(compiled)
    check_equal(
      linkedspec.execute_generated_parser_v2(compiled, plan, "x", identity),
      route.default_value,
      route.name .. " generated default"
    )
    check_equal(
      linkedspec.execute_generated_parser_v2(compiled, plan, "x", identity, { top_rule = route.explicit }),
      route.explicit_value,
      route.name .. " generated explicit"
    )
    for _, row in ipairs(plan) do
      local projected = linkedspec.generated_plan_row_to_json(row)
      check_equal(projected.entry_rule, nil, route.name .. " plan omits entry rule")
      check_equal(projected.is_top, nil, route.name .. " plan omits marker")
    end

    local emitter, output = trace_emitter()
    check_equal(
      linkedspec.execute_generated_parser_v2(compiled, plan, "x", identity, { trace = emitter }),
      route.default_value,
      route.name .. " generated traced value"
    )
    local event = selection_event(emitter, route.name .. " generated trace")
    check_equal(event.kind, linkedspec.TRACE_DECISION, route.name .. " generated trace kind")
    check_equal(linkedspec.trace_level_name(event.level), "low", route.name .. " generated trace level")
    check_contains(event.details, "taken=1", route.name .. " generated trace taken")
    check_contains(event.details, "requested=<default>", route.name .. " generated trace requested")
    check_contains(event.details, "effective=" .. (route.name == "marked" and "Marked" or "First"), route.name .. " generated trace effective")
    check_contains(event.details, "basis=" .. (route.name == "marked" and "first_authored_marker" or "first_authored_rule"), route.name .. " generated trace basis")
    check_contains(table.concat(output), "lua_runtime:entry_rule_selection", route.name .. " generated trace output")

    local explicit_emitter = trace_emitter()
    check_equal(
      linkedspec.execute_generated_parser_v2(
        compiled,
        plan,
        "x",
        identity,
        { top_rule = route.explicit, trace = explicit_emitter }
      ),
      route.explicit_value,
      route.name .. " generated traced explicit value"
    )
    local explicit_event = selection_event(explicit_emitter, route.name .. " generated explicit trace")
    check_contains(explicit_event.details, "requested=" .. route.explicit, route.name .. " explicit trace requested")
    check_contains(explicit_event.details, "effective=" .. route.explicit, route.name .. " explicit trace effective")
    check_contains(explicit_event.details, "basis=explicit_selector", route.name .. " explicit trace basis")

    local source = linkedspec.emit_lua_source_v2(compiled, identity)
    check_contains(source, 'M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"', route.name .. " emitted contract")
    check_contains(source, "M.LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", route.name .. " emitted format")
    local emitted_path = root .. "/" .. route.name .. "_generated.lua"
    write_file(emitted_path, source)
    local emitted = assert(loadfile(emitted_path))()
    check_equal(emitted.execute("x"), route.default_value, route.name .. " emitted default")
    check_equal(emitted.execute("x", { top_rule = route.explicit }), route.explicit_value, route.name .. " emitted explicit")
    local emitted_output = {}
    check_equal(
      emitted.execute_with_trace(
        "x",
        linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
        { stdout_writer = function(value) emitted_output[#emitted_output + 1] = value end }
      ),
      route.default_value,
      route.name .. " emitted traced value"
    )
    check_contains(table.concat(emitted_output), "lua_runtime:entry_rule_selection", route.name .. " emitted trace output")
    local emitted_explicit_output = {}
    check_equal(
      emitted.execute_with_trace(
        "x",
        linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
        {
          top_rule = route.explicit,
          stdout_writer = function(value) emitted_explicit_output[#emitted_explicit_output + 1] = value end,
        }
      ),
      route.explicit_value,
      route.name .. " emitted traced explicit value"
    )
    check_contains(
      table.concat(emitted_explicit_output),
      "requested=" .. route.explicit .. " effective=" .. route.explicit .. " basis=explicit_selector",
      route.name .. " emitted explicit trace"
    )
    check_same_json(linkedspec.to_descriptor_json(compiled), descriptor, route.name .. " generated descriptor")
  end

  local compiled = linkedspec.compile_spec(linkedspec.parse_spec(marked_source))
  local plan = linkedspec.build_generated_rule_plan(compiled)
  local identity = "root-routes/failure.spec"
  local emitter, output = trace_emitter()
  local unknown_ok, unknown = capture(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      plan,
      "x",
      identity,
      { top_rule = "Missing", trace = emitter }
    )
  end)
  check_equal(unknown_ok, false, "generated unknown rejected")
  check_equal(linkedspec.is_generated_source_error(unknown), true, "generated unknown type")
  check_same_json(
    linkedspec.generated_source_error_to_json(unknown),
    json.harray({
      type = "generated_source_error",
      stage = "select_entry_rule",
      code = "entry_rule_not_found",
      summary = "Generated Lua parser entry-rule selection failed",
      source_identity = identity,
      entry_rule = "Missing",
      rule_label = "Missing",
      detail = "entry rule 'Missing' is not defined",
    }),
    "generated unknown JSON"
  )
  local failure_event = selection_event(emitter, "generated failure trace")
  check_contains(failure_event.details, "taken=0", "generated failure taken")
  check_contains(failure_event.details, "requested=Missing", "generated failure requested")
  check_contains(failure_event.details, "effective=<none>", "generated failure effective")
  check_contains(failure_event.details, "stage=select_entry_rule", "generated failure stage")
  check_contains(failure_event.details, "code=entry_rule_not_found", "generated failure code")
  check_contains(table.concat(output), "lua_runtime:entry_rule_selection", "generated failure trace output")

  local empty = linkedspec.compile_spec(linkedspec.spec_ast.spec_file({ rules = {} }), { validate_source = false })
  local zero_generated_ok, zero_generated = capture(function()
    return linkedspec.execute_generated_parser_v2(empty, {}, "", identity, { top_rule = "Missing" })
  end)
  check_equal(zero_generated_ok, false, "generated zero rejected")
  check_equal(linkedspec.is_generated_source_error(zero_generated), true, "generated zero type")
  check_same_json(
    linkedspec.generated_source_error_to_json(zero_generated),
    json.harray({
      type = "generated_source_error",
      stage = "validate_spec",
      code = "no_rules_defined",
      summary = "Generated Lua parser entry-rule selection failed",
      source_identity = identity,
      detail = "compiled spec does not contain any rules",
    }),
    "generated zero JSON"
  )

  local stale_plan = {}
  for index = 1, #plan - 1 do stale_plan[index] = plan[index] end
  local stale_ok, stale = capture(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      stale_plan,
      "x",
      identity,
      { top_rule = "Missing" }
    )
  end)
  check_equal(stale_ok, false, "stale plan rejected")
  check_equal(stale.stage, linkedspec.VALIDATE_GENERATED_PLAN_STAGE, "stale plan stage before selection")
  check_equal(stale.code, linkedspec.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE, "stale plan code")
end)

if #failures == 0 then
  io.stdout:write("root-rule selection routes: ", assertions, " assertions passed\n")
else
  io.stderr:write("root-rule selection routes: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
