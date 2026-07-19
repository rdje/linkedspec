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
  local template = "/private/tmp/linkedspec-lua-root-admission-" .. label .. ".XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean root-admission test directory", 0) end
  if not ok then error(value, 0) end
end

local function optional_selector(value)
  if value == json.null then return nil end
  return value
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function compiled_for_rows(rows)
  if #rows == 0 then
    return linkedspec.compile_spec(linkedspec.spec_ast.spec_file({ rules = {} }), {
      validate_source = false,
    })
  end
  local lines = {}
  for _, row in ipairs(rows) do
    lines[#lines + 1] = row.label .. (row.authored_is_top and "::" or ":")
    lines[#lines + 1] = " /x/"
    lines[#lines + 1] = ' I { return("' .. row.label .. '") }'
    lines[#lines + 1] = ""
  end
  return compile_source(table.concat(lines, "\n"))
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

local function selection_trace(options)
  local output = {}
  options = options or {}
  options.stdout_writer = function(value) output[#output + 1] = value end
  return linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), options, output
end

local contract = json.decode(read_file("capability_conformance/root_rule_selection_contract.json"))
local generated_identity = "root-selection/lua-admission.spec"

-- Entry lifecycle returns make the selected rule observable before matching can
-- make exit lifecycle appear equivalent.
local marked_source = [[Earlier:
 /x/
 I { return("earlier") }

Marked::
 /x/
 I { return("marked") }

Later::
 /x/
 I { return("later") }
]]

local markerless_source = [[First:
 /x/
 I { return("first") }

Second:
 /x/
 I { return("second") }
]]

-- This source is shared byte-for-byte with the primary CLI trace manifest.
local trace_source = "Top::\n /x/ -> Done { return(\"trace\") }\n\nDone::\n /x/\n"

local function role_neutral_selection()
  check_equal(contract.contract_id, linkedspec.ENTRY_RULE_CONTRACT_ID, "root contract id")
  for _, case_value in ipairs(contract.selection_cases) do
    local compiled = compiled_for_rows(case_value.rules)
    local authored_before = {}
    for index, label in ipairs(compiled.compiled_rule_order) do
      authored_before[index] = label .. ":" .. tostring(compiled:rule(label).header.is_top)
    end
    local selection = linkedspec.resolve_entry_rule(
      compiled,
      optional_selector(case_value.explicit_selector)
    )
    check_equal(selection.rule.label, case_value.expected_label, case_value.id .. " label")
    check_equal(
      linkedspec.entry_rule_selection_basis_name(selection.basis),
      case_value.expected_basis,
      case_value.id .. " basis"
    )
    local authored_after = {}
    for index, label in ipairs(compiled.compiled_rule_order) do
      authored_after[index] = label .. ":" .. tostring(compiled:rule(label).header.is_top)
    end
    check_equal(
      table.concat(authored_after, ","),
      table.concat(authored_before, ","),
      case_value.id .. " authored identity"
    )
  end
end

local function role_neutral_failures()
  for _, case_value in ipairs(contract.failure_cases) do
    local ok, failure = capture(function()
      return linkedspec.resolve_entry_rule(
        compiled_for_rows(case_value.rules),
        optional_selector(case_value.explicit_selector)
      )
    end)
    check_equal(ok, false, case_value.id .. " rejects")
    check_equal(linkedspec.is_entry_rule_selection_error(failure), true, case_value.id .. " type")
    check_equal(failure.code, case_value.expected_code, case_value.id .. " code")
    check_equal(failure.stage, case_value.expected_stage, case_value.id .. " stage")
  end
end

local function role_neutral_strict()
  local sources = {
    explicit_selection_is_not_reference = "A:\n /a/\n\nB:\n /b/\n",
    marker_selection_is_not_reference = "Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n",
    closed_reference_cycle_has_no_unused_rules = "A:\n /a/ -> B\n\nB:\n /b/ -> A\n",
  }
  for _, case_value in ipairs(contract.strict_cases) do
    local spec = linkedspec.parse_spec(sources[case_value.id])
    if case_value.explicit_selector ~= json.null then
      linkedspec.resolve_entry_rule(linkedspec.compile_spec(spec), case_value.explicit_selector)
    end
    local ok, failure = capture(function()
      return linkedspec.validate_spec(spec, { strict_syntax = true })
    end)
    if #case_value.expected_unused == 0 then
      check_equal(ok, true, case_value.id .. " accepts")
    else
      check_equal(ok, false, case_value.id .. " rejects")
      check_equal(linkedspec.is_spec_validation_error(failure), true, case_value.id .. " type")
      check_contains(
        failure.message,
        "unused rule(s) in strict mode: " .. table.concat(case_value.expected_unused, ", "),
        case_value.id .. " labels"
      )
    end
  end
end

local function role_native()
  local marked = linkedspec.runtime_engine(compile_source(marked_source))
  check_equal(linkedspec.runtime_parse(marked, "x").value, "marked", "native first marker")
  check_equal(
    linkedspec.runtime_parse(marked, "x", { top_rule = "Earlier" }).value,
    "earlier",
    "native explicit ordinary"
  )
  check_equal(
    linkedspec.runtime_parse(marked, "x", { top_rule = "Later" }).value,
    "later",
    "native explicit later marker"
  )
  local markerless = linkedspec.runtime_engine(compile_source(markerless_source))
  check_equal(linkedspec.runtime_parse(markerless, "x").value, "first", "native first ordinary")
  check_equal(
    linkedspec.runtime_parse(markerless, "x", { top_rule = "Second" }).value,
    "second",
    "native explicit later ordinary"
  )
end

local function role_loaded()
  with_temp_directory("loaded", function(root)
    local path = root .. "/markerless.spec"
    write_file(path, markerless_source)
    local loaded = linkedspec.load_and_compile_spec(
      linkedspec.path_spec_request(path),
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    check_equal(
      linkedspec.runtime_parse(loaded:create_engine(), "x").value,
      "first",
      "loaded markerless default"
    )
    check_equal(
      linkedspec.runtime_parse(loaded:create_engine(), "x", { top_rule = "Second" }).value,
      "second",
      "loaded explicit ordinary"
    )
  end)
end

local function role_reconstructed()
  local normalized = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(linkedspec.parse_spec(marked_source))))
  )
  local compiled = linkedspec.compile_spec(normalized)
  local identity = {}
  for index, label in ipairs(compiled.compiled_rule_order) do
    identity[index] = label .. ":" .. tostring(compiled:rule(label).header.is_top)
  end
  check_equal(
    table.concat(identity, ","),
    "Earlier:false,Marked:true,Later:true",
    "reconstructed authored identity"
  )
  local engine = linkedspec.runtime_engine(compiled)
  check_equal(linkedspec.runtime_parse(engine, "x").value, "marked", "reconstructed first marker")
  check_equal(
    linkedspec.runtime_parse(engine, "x", { top_rule = "Earlier" }).value,
    "earlier",
    "reconstructed explicit ordinary"
  )
end

local function role_generated_direct()
  local marked = compile_source(marked_source)
  check_equal(
    linkedspec.execute_generated_parser_v2(
      marked,
      linkedspec.build_generated_rule_plan(marked),
      "x",
      generated_identity,
      { top_rule = "Earlier" }
    ),
    "earlier",
    "generated explicit ordinary"
  )
  local markerless = compile_source(markerless_source)
  check_equal(
    linkedspec.execute_generated_parser_v2(
      markerless,
      linkedspec.build_generated_rule_plan(markerless),
      "x",
      generated_identity
    ),
    "first",
    "generated markerless default"
  )
end

local function role_generated_traced()
  local compiled = compile_source(marked_source)
  local trace_config, options, output = selection_trace({ top_rule = "Later" })
  check_equal(
    linkedspec.execute_generated_parser_with_trace_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      "x",
      trace_config,
      generated_identity,
      options
    ),
    "later",
    "generated traced later marker"
  )
  local trace = table.concat(output)
  check_contains(trace, "lua_runtime:entry_rule_selection", "generated selection trace")
  check_contains(trace, "requested=Later", "generated requested rule")
  check_contains(trace, "effective=Later", "generated effective rule")
  check_contains(trace, "basis=explicit_selector", "generated selection basis")
  check_contains(trace, "rule=Later", "generated entered rule")
end

local function role_emitted_source_direct()
  with_temp_directory("emitted-direct", function(root)
    local path = root .. "/generated.lua"
    write_file(path, linkedspec.emit_lua_source_v2(compile_source(marked_source), generated_identity))
    local emitted = assert(loadfile(path))()
    check_equal(emitted.execute("x"), "marked", "emitted first marker")
    check_equal(emitted.execute("x", { top_rule = "Earlier" }), "earlier", "emitted explicit ordinary")
    check_equal(
      emitted.LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
      linkedspec.GENERATED_SOURCE_CONTRACT,
      "emitted contract identity"
    )
    check_equal(emitted.LINKEDSPEC_GENERATED_SOURCE_FORMAT, 2, "emitted format")
  end)
end

local function role_emitted_source_traced()
  with_temp_directory("emitted-traced", function(root)
    local path = root .. "/generated.lua"
    write_file(path, linkedspec.emit_lua_source_v2(compile_source(markerless_source), generated_identity))
    local emitted = assert(loadfile(path))()
    local output = {}
    check_equal(
      emitted.execute_with_trace(
        "x",
        linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
        {
          top_rule = "Second",
          stdout_writer = function(value) output[#output + 1] = value end,
        }
      ),
      "second",
      "emitted traced explicit ordinary"
    )
    local trace = table.concat(output)
    check_contains(trace, "requested=Second", "emitted traced requested rule")
    check_contains(trace, "effective=Second", "emitted traced effective rule")
    check_contains(trace, "basis=explicit_selector", "emitted traced selection basis")
  end)
end

local function role_descriptor()
  local compiled = compile_source(marked_source)
  local before = linkedspec.to_descriptor_json(compiled)
  check_equal(
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(compiled),
      "x",
      { top_rule = "Earlier" }
    ).value,
    "earlier",
    "descriptor explicit execution"
  )
  local after = linkedspec.to_descriptor_json(compiled)
  check_same_json(after, before, "descriptor immutable across selection")
  check_equal(after.meta.entry_rule_contract, linkedspec.ENTRY_RULE_CONTRACT_ID, "descriptor contract")
  check_equal(table.concat(after.meta.definition_order, ","), "Earlier,Marked,Later", "descriptor order")
  check_equal(after.meta.entry_rule, nil, "descriptor omits entry rule")
  check_equal(after.meta.selected_entry_rule, nil, "descriptor omits selected entry rule")
  check_equal(after.spec.Earlier.meta.is_top, false, "descriptor ordinary identity")
  check_equal(after.spec.Marked.meta.is_top, true, "descriptor first marker identity")
  check_equal(after.spec.Later.meta.is_top, true, "descriptor later marker identity")
end

local function role_diagnostic()
  local unknown_ok, unknown = capture(function()
    return linkedspec.runtime_parse(
      linkedspec.runtime_engine(compile_source(marked_source)),
      "x",
      { top_rule = "Missing" }
    )
  end)
  check_equal(unknown_ok, false, "unknown selector rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(unknown), true, "unknown selector type")
  check_equal(unknown.diagnostic.code, "entry_rule_not_found", "unknown selector code")
  check_equal(unknown.diagnostic.stage, "select_entry_rule", "unknown selector stage")
  check_equal(unknown.diagnostic.entry_rule, "Missing", "unknown selector identity")

  local empty = linkedspec.runtime_engine(compiled_for_rows({}))
  local zero_ok, zero = capture(function()
    return linkedspec.runtime_parse(empty, "", { top_rule = "Missing" })
  end)
  check_equal(zero_ok, false, "zero rules reject")
  check_equal(linkedspec.is_runtime_interpreter_error(zero), true, "zero rules type")
  check_equal(zero.diagnostic.code, "no_rules_defined", "zero rules code")
  check_equal(zero.diagnostic.stage, "validate_spec", "zero rules stage")

  local compiled = compile_source(marked_source)
  local stale_ok, stale = capture(function()
    return linkedspec.validate_generated_rule_plan_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      generated_identity,
      "linkedspec-generated-source-v1"
    )
  end)
  check_equal(stale_ok, false, "stale generated contract rejects")
  check_equal(linkedspec.is_generated_source_error(stale), true, "stale generated contract type")
  check_equal(stale.stage, "validate_generated_plan", "stale generated contract stage")
  check_equal(stale.code, "generated_source_contract_version_mismatch", "stale contract code")
end

local function role_runtime_trace()
  local failure_source = [[Earlier:
 /x/
 I { return(not(true, false)) }

Marked::
 /x/
 I { return("marked") }
]]
  local compiled = compile_source(failure_source)
  local trace_config, options, output = selection_trace({ top_rule = "Earlier" })
  local ok, failure = capture(function()
    return linkedspec.execute_generated_parser_with_trace_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      "x",
      trace_config,
      generated_identity,
      options
    )
  end)
  check_equal(ok, false, "selected runtime failure rejects")
  check_equal(linkedspec.is_generated_source_error(failure), true, "selected runtime failure type")
  check_equal(failure.stage, "execute_generated", "selected runtime failure stage")
  check_equal(failure.code, "generated_execution_failed", "selected runtime failure code")
  check_equal(failure.rule_label, "Earlier", "selected runtime failure rule")
  check_equal(failure.handler_family, "default", "selected runtime failure family")
  local trace = table.concat(output)
  check_contains(trace, "requested=Earlier", "runtime trace requested rule")
  check_contains(trace, "effective=Earlier", "runtime trace effective rule")
  check_contains(trace, "basis=explicit_selector", "runtime trace selection basis")
  check_contains(trace, "rule=Earlier", "runtime trace entered rule")
end

local function role_primary_cli()
  local routes = {
    { marked_source, {}, '"marked"\n' },
    { markerless_source, {}, '"first"\n' },
    { marked_source, { "--top-rule", "Earlier" }, '"earlier"\n' },
  }
  for index, route in ipairs(routes) do
    local arguments = { "--inline-spec", route[1], "--input", "x" }
    for _, value in ipairs(route[2]) do arguments[#arguments + 1] = value end
    local result = linkedspec.run_primary_cli(arguments)
    check_equal(result.exit_code, 0, "primary route " .. index .. " exit")
    check_equal(result.stdout, route[3], "primary route " .. index .. " stdout")
    check_equal(result.stderr, "", "primary route " .. index .. " stderr")
  end
  local unknown = linkedspec.run_primary_cli({
    "--inline-spec", marked_source, "--input", "x", "--top-rule", "Missing",
  })
  check_equal(unknown.exit_code, 1, "primary unknown exit")
  check_equal(unknown.stdout, "", "primary unknown stdout")
  check_equal(unknown.stderr, "linkedspec: parser invocation failed\n", "primary unknown stderr")
end

local function role_primary_request_trace()
  local default = linkedspec.run_primary_cli({
    "--inline-spec", trace_source, "--input", "x", "--trace", "medium",
  })
  check_equal(default.exit_code, 0, "default request trace exit")
  check_equal(
    default.stdout,
    read_file("cli_conformance/cases/trace/medium_stdout.txt"),
    "default request trace bytes"
  )
  check_equal(default.stderr, "", "default request trace stderr")

  with_temp_directory("primary-trace", function(root)
    local trace_path = root .. "/trace.log"
    write_file(trace_path, "stale trace\n")
    local explicit = linkedspec.run_primary_cli({
      "--inline-spec", trace_source,
      "--input", "x",
      "--top-rule", "Top\nInjected",
      "--trace", "medium",
      "--trace-file", "trace.log",
      "--trace-mode", "route",
      "--trace-reset",
    }, { cwd = root })
    check_equal(explicit.exit_code, 1, "explicit request trace exit")
    check_equal(explicit.stdout, "", "explicit request trace stdout")
    check_equal(explicit.stderr, "linkedspec: parser invocation failed\n", "explicit request trace stderr")
    check_equal(
      read_file(trace_path),
      read_file("cli_conformance/cases/trace/failure_invoke_escaped_medium.txt"),
      "explicit request trace bytes"
    )
  end)
end

local role_map = {
  neutral_selection = role_neutral_selection,
  neutral_failures = role_neutral_failures,
  neutral_strict = role_neutral_strict,
  native = role_native,
  loaded = role_loaded,
  reconstructed = role_reconstructed,
  generated_direct = role_generated_direct,
  generated_traced = role_generated_traced,
  emitted_source_direct = role_emitted_source_direct,
  emitted_source_traced = role_emitted_source_traced,
  descriptor = role_descriptor,
  diagnostic = role_diagnostic,
  runtime_trace = role_runtime_trace,
  primary_cli = role_primary_cli,
  primary_request_trace = role_primary_request_trace,
}

local admission = contract.lua_admission
check(admission ~= nil, "neutral contract declares Lua admission")
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
  io.stdout:write("root-rule selection dual-ABI admission: ", assertions, " assertions passed\n")
else
  io.stderr:write(
    "root-rule selection dual-ABI admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
