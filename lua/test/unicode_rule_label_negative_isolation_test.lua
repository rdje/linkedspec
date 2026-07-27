-- FUTURE-PARITY-BACKLOG.10.7.1.3.2 — negative labels and grammar isolation.

local linkedspec = require("linkedspec")
local ast = linkedspec.spec_ast
local action_ast = linkedspec.action_ast
local json = linkedspec.json
local unicode_rule_label = require("linkedspec.unicode_rule_label")

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

local function primary_trace_field(value)
  local result = {}
  for index = 1, #value do
    local byte = value:byte(index)
    local allowed = (byte >= 0x30 and byte <= 0x39) or
      (byte >= 0x41 and byte <= 0x5A) or
      (byte >= 0x61 and byte <= 0x7A) or
      byte == 0x5F or byte == 0x2E or byte == 0x3A or byte == 0x2D
    result[#result + 1] = allowed and string.char(byte) or string.format("%%%02X", byte)
  end
  return table.concat(result)
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then return first == 0 end
  return first == true and (third == nil or third == 0)
end

local function with_temp_directory(operation)
  local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
  assert(temp_root ~= "", "TMPDIR must not be empty")
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-unicode-negative.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean Unicode negative test directory", 0) end
  if not ok then error(value, 0) end
end

local function load_generated_module(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local contract = json.decode(read_file("capability_conformance/unicode_rule_label_contract.json"))
local negative_fixtures = contract.negative_fixtures

local function body_element(kind, line, source)
  return ast.body_element({ kind = kind, source = source or "external", line = line })
end

local function rule_header(label, line)
  return ast.rule_header({
    label = label,
    is_top = true,
    mode = ast.default_rule_mode(),
    rest = "",
    line = line,
  })
end

local function spec_with(label, kind)
  return ast.spec_file({
    rules = {
      ast.rule({
        header = rule_header(label, 1),
        body = { body_element(kind, 2) },
      }),
    },
  })
end

local function reconstruct(spec)
  return ast.from_json("SpecFile", json.decode(json.encode(ast.to_json(spec))))
end

local function negative_role_cases(label)
  return {
    {
      name = "declaration",
      role = "declaration",
      owner = nil,
      line = 1,
      spec = spec_with(label, ast.regex_body_kind({ pattern = "x" })),
    },
    {
      name = "action",
      role = "edge_target",
      owner = "Root",
      line = 2,
      spec = spec_with("Root", ast.action_edge_body_kind({
        targets = { ast.edge_target({ label = label }) },
      })),
    },
    {
      name = "blind",
      role = "edge_target",
      owner = "Root",
      line = 2,
      spec = spec_with("Root", ast.blind_edge_body_kind({ target = label })),
    },
    {
      name = "bare",
      role = "edge_target",
      owner = "Root",
      line = 2,
      spec = spec_with("Root", ast.bare_edge_body_kind({
        targets = { ast.bare_edge_target({ label = label }) },
      })),
    },
  }
end

local function invalid_label_json(role, label, line, owner)
  local message = role .. " '" .. label ..
    "' is not a nonempty Unicode 17.0.0 XID_Continue rule label"
  local fields = json.harray({ label = label, line = line, role = role })
  if owner ~= nil then fields.rule_label = owner end
  return json.harray({
    code = "invalid_rule_label",
    stage = "validate_rule_labels",
    message = message,
    fields = fields,
  })
end

local function check_invalid_label_failure(ok, value, expected, label)
  check_equal(ok, false, label .. " rejected")
  check_equal(linkedspec.is_spec_validation_error(value), true, label .. " validation type")
  if linkedspec.is_spec_validation_error(value) then
    check_same_json(linkedspec.spec_validation_error_to_json(value), expected, label .. " diagnostic")
  end
end

local artifact_operations = {
  {
    name = "validate",
    call = function(spec) return linkedspec.validate_spec(spec) end,
  },
  {
    name = "compile",
    call = function(spec) return linkedspec.compile_spec(spec) end,
  },
  {
    name = "descriptor",
    call = function(spec) return linkedspec.to_descriptor_json(linkedspec.compile_spec(spec)) end,
  },
  {
    name = "generated_plan",
    call = function(spec)
      return linkedspec.build_generated_rule_plan(linkedspec.compile_spec(spec))
    end,
  },
  {
    name = "emitted_source",
    call = function(spec)
      return linkedspec.emit_lua_source_v2(
        linkedspec.compile_spec(spec),
        "unicode-label/negative-artifact.spec"
      )
    end,
  },
}

-- every negative label fails every external AST trust and artifact route
check_equal(#negative_fixtures, 8, "neutral negative fixture count")
for _, fixture in ipairs(negative_fixtures) do
  check_equal(unicode_rule_label.is_rule_label(fixture.label), false, fixture.id .. " classifier rejection")
  for _, route in ipairs(negative_role_cases(fixture.label)) do
    local expected = invalid_label_json(route.role, fixture.label, route.line, route.owner)
    for _, trust in ipairs({
      { name = "programmatic", spec = route.spec },
      { name = "reconstructed", spec = reconstruct(route.spec) },
    }) do
      for _, operation in ipairs(artifact_operations) do
        local ok, value = capture(function() return operation.call(trust.spec) end)
        check_invalid_label_failure(
          ok,
          value,
          expected,
          fixture.id .. " " .. route.name .. " " .. trust.name .. " " .. operation.name
        )
      end
    end
  end
end

-- source no-prefix and newline routes reject complete invalid tokens
local function check_parse_error(source, label)
  local ok, value = capture(function() return linkedspec.parse_spec(source) end)
  check_equal(ok, false, label .. " rejected")
  check_equal(linkedspec.is_spec_parse_error(value), true, label .. " parse type")
end

local function check_raw_source(source, expected, label)
  local parsed = linkedspec.parse_spec("Root::\n " .. source .. "\n")
  check_equal(#parsed.rules, 1, label .. " rule count")
  check_equal(#parsed.rules[1].body, 1, label .. " body count")
  local element = parsed.rules[1].body[1]
  check_equal(ast.node_type(element.kind), "RawBodyElementKind", label .. " raw kind")
  if ast.node_type(element.kind) == "RawBodyElementKind" then
    check_equal(element.kind.text, expected, label .. " raw text")
  end
  local ok, value = capture(function() return linkedspec.validate_spec(parsed) end)
  check_equal(ok, false, label .. " validation rejection")
  check_equal(linkedspec.is_spec_validation_error(value), true, label .. " validation type")
  if linkedspec.is_spec_validation_error(value) then
    check_contains(value.message, expected, label .. " validation identity")
  end
end

for _, fixture in ipairs(negative_fixtures) do
  check_parse_error(fixture.label .. "::\n /x/\n", fixture.id .. " declaration")
  if fixture.id ~= "newline" then
    check_raw_source("-> " .. fixture.label, ("-> " .. fixture.label):match("^%s*(.-)%s*$"),
      fixture.id .. " action")
    check_raw_source("=> " .. fixture.label, ("=> " .. fixture.label):match("^%s*(.-)%s*$"),
      fixture.id .. " blind")
  end
  if fixture.label ~= "" and fixture.id ~= "newline" then
    local parsed = linkedspec.parse_spec("Root::\n " .. fixture.label .. "\n")
    local edge_count = 0
    for _, rule in ipairs(parsed.rules) do
      for _, element in ipairs(rule.body) do
        local node_type = ast.node_type(element.kind)
        if node_type == "ActionEdgeBodyElementKind" or node_type == "BlindEdgeBodyElementKind" or
            node_type == "BareEdgeBodyElementKind" then
          edge_count = edge_count + 1
        end
      end
    end
    if fixture.id == "colon" then
      check_equal(#parsed.rules, 2, "colon declaration split rule count")
      check_equal(parsed.rules[2].header.label, "Top", "colon declaration split label")
      check_equal(linkedspec.validate_spec(parsed), nil, "colon declaration split validates")
    else
      check_equal(edge_count, 0, fixture.id .. " bare has no partial edge")
      local ok, value = capture(function() return linkedspec.validate_spec(parsed) end)
      check_equal(ok, false, fixture.id .. " bare validation rejection")
      check_equal(linkedspec.is_spec_validation_error(value), true, fixture.id .. " bare validation type")
    end
  end
end

local no_prefix = "$Top"
check_parse_error(no_prefix .. "::\n /x/\n", "no-prefix declaration")
for _, prefix in ipairs({ "-> ", "=> ", "" }) do
  check_raw_source(prefix .. no_prefix, (prefix .. no_prefix):match("^%s*(.-)%s*$"),
    "no-prefix " .. (prefix == "" and "bare" or prefix))
end

local split_source = table.concat({
  "Root::OR",
  " -> Top",
  " Rule",
  "",
  "Top:",
  " /x/",
  "",
  "Rule:",
  " /x/",
}, "\n")
local split = linkedspec.parse_spec(split_source)
check_equal(linkedspec.validate_spec(split), nil, "newline split validates")
check_equal(ast.node_type(split.rules[1].body[1].kind), "ActionEdgeBodyElementKind", "newline action kind")
check_equal(split.rules[1].body[1].kind.targets[1].label, "Top", "newline action label")
check_equal(ast.node_type(split.rules[1].body[2].kind), "BareEdgeBodyElementKind", "newline bare kind")
check_equal(split.rules[1].body[2].kind.targets[1].label, "Rule", "newline bare label")

local function runtime_diagnostic(label)
  return json.harray({
    type = "runtime_parser",
    stage = "select_entry_rule",
    owner_stage = "lua_runtime",
    summary = "Lua runtime entry-rule selection failed",
    detail = "entry rule '" .. label .. "' is not defined",
    top_rule = label,
    entry_rule = label,
    rule_label = label,
    handler_source_label = "lua_runtime:rule:" .. label,
    code = "entry_rule_not_found",
  })
end

local function generated_diagnostic(label, identity)
  return json.harray({
    type = "generated_source_error",
    stage = "select_entry_rule",
    code = "entry_rule_not_found",
    summary = "Generated Lua parser entry-rule selection failed",
    source_identity = identity,
    entry_rule = label,
    rule_label = label,
    detail = "entry rule '" .. label .. "' is not defined",
  })
end

-- selectors diagnostics and traces preserve every exact invalid identity
local valid_source = "Top::\n /x/\n"
local valid_compiled = linkedspec.compile_spec(linkedspec.parse_spec(valid_source))
local valid_engine = linkedspec.runtime_engine(valid_compiled)
local valid_plan = linkedspec.build_generated_rule_plan(valid_compiled)
local generated_identity = "unicode-label/negative-selector.spec"
local emitted_source = linkedspec.emit_lua_source_v2(valid_compiled, generated_identity)
local emitted = load_generated_module(emitted_source, "@unicode-label-negative")

for _, fixture in ipairs(negative_fixtures) do
  local native_output = {}
  local emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function(payload) native_output[#native_output + 1] = payload end }
  )
  local native_ok, native_error = capture(function()
    return linkedspec.runtime_parse(valid_engine, "x", {
      top_rule = fixture.label,
      trace = emitter,
    })
  end)
  check_equal(native_ok, false, fixture.id .. " native selector rejected")
  check_equal(linkedspec.is_runtime_interpreter_error(native_error), true, fixture.id .. " native selector type")
  if linkedspec.is_runtime_interpreter_error(native_error) then
    check_same_json(
      linkedspec.interpreter.to_json(native_error.diagnostic),
      runtime_diagnostic(fixture.label),
      fixture.id .. " native selector diagnostic"
    )
  end
  local selection_events = {}
  for _, event in ipairs(linkedspec.trace_events(emitter)) do
    if event.topic == "lua_runtime:entry_rule_selection" then
      selection_events[#selection_events + 1] = event
    end
  end
  check_equal(#selection_events, 1, fixture.id .. " native selector trace count")
  if selection_events[1] ~= nil then
    check_contains(selection_events[1].details, "requested=" .. fixture.label,
      fixture.id .. " native trace identity")
    check_contains(selection_events[1].details, "effective=<none>", fixture.id .. " native trace failure")
  end
  check_contains(table.concat(native_output), fixture.label, fixture.id .. " native trace output identity")

  local generated_output = {}
  local generated_ok, generated_error = capture(function()
    return linkedspec.execute_generated_parser_with_trace_v2(
      valid_compiled,
      valid_plan,
      "x",
      linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
      generated_identity,
      {
        top_rule = fixture.label,
        stdout_writer = function(payload) generated_output[#generated_output + 1] = payload end,
      }
    )
  end)
  check_equal(generated_ok, false, fixture.id .. " generated selector rejected")
  check_equal(linkedspec.is_generated_source_error(generated_error), true, fixture.id .. " generated selector type")
  if linkedspec.is_generated_source_error(generated_error) then
    check_same_json(
      linkedspec.generated_source_error_to_json(generated_error),
      generated_diagnostic(fixture.label, generated_identity),
      fixture.id .. " generated selector diagnostic"
    )
  end
  check_contains(table.concat(generated_output), "requested=" .. fixture.label,
    fixture.id .. " generated trace identity")

  local emitted_ok, emitted_error = capture(function()
    return emitted.execute("x", { top_rule = fixture.label })
  end)
  check_equal(emitted_ok, false, fixture.id .. " emitted selector rejected")
  check_equal(linkedspec.is_generated_source_error(emitted_error), true, fixture.id .. " emitted selector type")
  if linkedspec.is_generated_source_error(emitted_error) then
    check_same_json(
      linkedspec.generated_source_error_to_json(emitted_error),
      generated_diagnostic(fixture.label, generated_identity),
      fixture.id .. " emitted selector diagnostic"
    )
  end
end

-- emitted fresh-host selectors loaders and primary commands preserve rejection
with_temp_directory(function(root)
  local generated_path = root .. "/generated_parser.lua"
  local runner_path = root .. "/runner.lua"
  local labels_path = root .. "/labels.json"
  local stdout_path = root .. "/stdout.json"
  local stderr_path = root .. "/stderr.txt"
  write_file(generated_path, emitted_source)
  write_file(labels_path, json.encode(negative_fixtures))
  write_file(runner_path, [[
local linkedspec = require("linkedspec")
local json = linkedspec.json
local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end
local generated = assert(loadfile(arg[1]))()
local fixtures = json.decode(read_file(arg[2]))
local diagnostics = json.array()
local traces = json.array()
for index, fixture in ipairs(fixtures) do
  local output = {}
  local ok, value = pcall(function()
    return generated.execute_with_trace(
      "x",
      linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
      {
        top_rule = fixture.label,
        stdout_writer = function(payload) output[#output + 1] = payload end,
      }
    )
  end)
  assert(not ok)
  assert(linkedspec.is_generated_source_error(value))
  diagnostics[index] = linkedspec.generated_source_error_to_json(value)
  traces[index] = table.concat(output)
end
io.write(json.encode(json.harray({ diagnostics = diagnostics, traces = traces })), "\n")
]])
  local runtime = os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME") or
    (type(jit) == "table" and "luajit" or "lua")
  local command = table.concat({
    "env LUA_PATH=" .. shell_quote(os.getenv("LUA_PATH") or ""),
    "LUA_CPATH=" .. shell_quote(os.getenv("LUA_CPATH") or ""),
    shell_quote(runtime),
    shell_quote(runner_path),
    shell_quote(generated_path),
    shell_quote(labels_path),
    ">" .. shell_quote(stdout_path),
    "2>" .. shell_quote(stderr_path),
  }, " ")
  check_equal(command_succeeded(command), true, "fresh emitted negative host status")
  check_equal(read_file(stderr_path), "", "fresh emitted negative host stderr")
  local observed = json.decode(read_file(stdout_path))
  check_equal(#observed.diagnostics, #negative_fixtures, "fresh emitted diagnostic count")
  check_equal(#observed.traces, #negative_fixtures, "fresh emitted trace count")
  for index, fixture in ipairs(negative_fixtures) do
    check_same_json(
      observed.diagnostics[index],
      generated_diagnostic(fixture.label, generated_identity),
      fixture.id .. " fresh emitted diagnostic"
    )
    check_contains(observed.traces[index], "requested=" .. fixture.label,
      fixture.id .. " fresh emitted trace identity")
  end

  for index, fixture in ipairs(negative_fixtures) do
    local source = fixture.label .. "::\n /x/\n"
    local path = root .. "/invalid-" .. index .. ".spec"
    write_file(path, source)
    local loaded_ok, loaded_error = capture(function()
      return linkedspec.load_and_compile_spec(
        linkedspec.path_spec_request(path),
        linkedspec.spec_load_options({ cwd = root, search_roots = {} })
      )
    end)
    check_equal(loaded_ok, false, fixture.id .. " strict loader rejected")
    check_equal(linkedspec.is_spec_pipeline_error(loaded_error), true, fixture.id .. " loader error type")
    if linkedspec.is_spec_pipeline_error(loaded_error) then
      local projected = linkedspec.spec_pipeline_error_to_json(loaded_error)
      check_equal(projected.stage, "parse_spec", fixture.id .. " loader stage")
      check_equal(projected.code, "spec_parse_failed", fixture.id .. " loader code")
      check_equal(projected.request_kind, "path", fixture.id .. " loader request kind")
      check_equal(projected.requested, path, fixture.id .. " loader requested path")
      check_equal(projected.resolved_path, path, fixture.id .. " loader resolved path")
      check_equal(projected.detail:find(path, 1, true), nil, fixture.id .. " loader detail path privacy")
      check_contains(projected.detail, source:match("^[^\n]*"), fixture.id .. " loader source identity")
    end

    for _, route in ipairs({
      { name = "inline", args = { "--inline-spec", source, "--input", "x" } },
      { name = "file", args = { "--spec-file", path, "--input", "x" } },
    }) do
      local result = linkedspec.run_primary_cli(route.args, { cwd = root })
      check_equal(result.exit_code, 1, fixture.id .. " " .. route.name .. " primary exit")
      check_equal(result.stdout, "", fixture.id .. " " .. route.name .. " primary stdout")
      check_equal(result.stderr, "linkedspec: parser compilation failed\n",
        fixture.id .. " " .. route.name .. " primary stderr")
    end

    local selector = linkedspec.run_primary_cli({
      "--inline-spec", valid_source,
      "--input", "x",
      "--top-rule", fixture.label,
      "--trace", "debug",
      "--trace-mode", "stdout",
    }, { cwd = root })
    check_equal(selector.exit_code, 1, fixture.id .. " primary selector exit")
    check_equal(selector.stderr, "linkedspec: parser invocation failed\n",
      fixture.id .. " primary selector stderr")
    check_contains(selector.stdout, "top_rule=" .. primary_trace_field(fixture.label),
      fixture.id .. " primary selector identity")
  end
end)

local function function_definition(name, params, rest_param)
  local signature = nil
  if rest_param ~= nil then
    signature = ast.callable_signature({
      kind = "callable_signature",
      version = 1,
      positional_params = params,
      rest_param = rest_param,
      min_arity = #params,
      max_arity = nil,
    })
  end
  return ast.function_definition({
    name = name,
    params = params,
    arity = #params,
    signature = signature,
    body_source = "return(value)",
    source = "fn " .. name .. "(...) { return(value) }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
end

local function function_spec(functions)
  return ast.spec_file({
    functions = functions,
    rules = {
      ast.rule({
        header = rule_header("Top", 1),
        body = { body_element(ast.regex_body_kind({ pattern = "x" }), 2, "/x/") },
      }),
    },
  })
end

local function check_validation_message(spec, expected, label)
  local ok, value = capture(function() return linkedspec.validate_spec(spec) end)
  check_equal(ok, false, label .. " rejected")
  check_equal(linkedspec.is_spec_validation_error(value), true, label .. " validation type")
  if linkedspec.is_spec_validation_error(value) then
    check_equal(value.message, expected, label .. " validation message")
  end
end

-- unrelated identifier grammars retain their existing boundaries
check_equal(
  linkedspec.validate_spec(function_spec({ function_definition("_function9", { "value_2" }) })),
  nil,
  "valid ASCII function and parameter"
)
for _, name in ipairs({ "Töp", "9_function", "A·B", "𐐀Rule" }) do
  check_validation_message(
    function_spec({ function_definition(name, { "value" }) }),
    "invalid user function name '" .. name .. "'",
    "function name " .. name
  )
  check_validation_message(
    function_spec({ function_definition("valid_name", { name }) }),
    "user function 'valid_name' has invalid parameter '" .. name .. "'",
    "parameter name " .. name
  )
  check_validation_message(
    function_spec({ function_definition("valid_variadic", { "value" }, name) }),
    "user function 'valid_variadic' has invalid rest parameter '" .. name .. "'",
    "rest parameter " .. name
  )
end

local valid_call = linkedspec.parse_action_expression("trim(value_2)")
check_equal(valid_call.kind, "call", "ASCII ActionIR call kind")
check_equal(valid_call.name, "trim", "ASCII ActionIR call name")
local valid_variable = linkedspec.parse_action_expression("value_2")
check_equal(valid_variable.kind, "variable", "ASCII ActionIR variable kind")
local valid_assignment = linkedspec.parse_action_expression("value_2 = 1")
check_equal(valid_assignment.kind, "assign_scalar", "ASCII ActionIR assignment kind")
local valid_fluent = linkedspec.parse_action_expression('"x"._method9()')
check_equal(valid_fluent.kind, "fluent_chain", "ASCII ActionIR fluent kind")
check_equal(valid_fluent.calls[1].method, "_method9", "ASCII ActionIR fluent method")

for _, fixture in ipairs({
  { name = "Töp", fluent_reason = "invalid_fluent_chain" },
  { name = "A·B", fluent_reason = "invalid_fluent_chain" },
  { name = "𐐀Rule", fluent_reason = "unsupported_expression" },
}) do
  local name = fixture.name
  local call = linkedspec.parse_action_expression(name .. "(value)")
  check_equal(call.kind, "raw_perl", name .. " ActionIR call raw")
  check_equal(call.reason, "unsupported_expression", name .. " ActionIR call reason")
  local variable = linkedspec.parse_action_expression(name)
  check_equal(variable.kind, "raw_perl", name .. " ActionIR variable raw")
  local assignment = linkedspec.parse_action_expression(name .. " = 1")
  check_equal(assignment.kind, "raw_perl", name .. " ActionIR assignment raw")
  local fluent = linkedspec.parse_action_expression('"x".' .. name .. "()")
  check_equal(fluent.kind, "raw_perl", name .. " ActionIR fluent raw")
  check_equal(fluent.reason, fixture.fluent_reason, name .. " ActionIR fluent reason")
  local mark = linkedspec.parse_action_expression("mark_here(" .. name .. ")")
  check_equal(mark.kind, "call", name .. " mark helper call")
  check_equal(mark.args[1].value.kind, "raw_perl", name .. " mark argument raw")
end

local body_fluent = linkedspec.parse_spec("Root::\n ._method9()\n")
check_equal(ast.node_type(body_fluent.rules[1].body[1].kind), "FluentChainBodyElementKind",
  "ASCII body fluent kind")
check_equal(body_fluent.rules[1].body[1].kind.calls[1].method, "_method9", "ASCII body fluent method")
check_equal(linkedspec.validate_spec(body_fluent), nil, "ASCII body fluent validates")

local lifecycle_markers = { "I", "LS", "LE", "LX", "E", "EX", "IT" }
local lifecycle_lines = { "Root::" }
for _, marker in ipairs(lifecycle_markers) do
  lifecycle_lines[#lifecycle_lines + 1] = " " .. marker .. " { return(\"" .. marker .. "\") }"
end
lifecycle_lines[#lifecycle_lines + 1] = " /x/"
local lifecycle = linkedspec.parse_spec(table.concat(lifecycle_lines, "\n"))
local observed_lifecycle = {}
for _, element in ipairs(lifecycle.rules[1].body) do
  if ast.node_type(element.kind) == "CodeBlockBodyElementKind" then
    observed_lifecycle[#observed_lifecycle + 1] = element.kind.lifecycle
  end
end
check_equal(#observed_lifecycle, #lifecycle_markers, "lifecycle marker count")
for index, marker in ipairs(lifecycle_markers) do
  check_equal(observed_lifecycle[index], marker, "lifecycle marker " .. marker)
end

for _, marker in ipairs({ "IX", "Töp", "𐐀Rule" }) do
  local parsed = linkedspec.parse_spec("Root::\n " .. marker .. " { return(\"bad\") }\n /x/\n")
  local codeblock_count = 0
  for _, element in ipairs(parsed.rules[1].body) do
    if ast.node_type(element.kind) == "CodeBlockBodyElementKind" then codeblock_count = codeblock_count + 1 end
  end
  check_equal(codeblock_count, 0, marker .. " is not a lifecycle marker")
  local ok, value = capture(function() return linkedspec.validate_spec(parsed) end)
  check_equal(ok, false, marker .. " lifecycle-like source rejected")
  check_equal(linkedspec.is_spec_validation_error(value), true, marker .. " lifecycle-like validation type")
end

for _, marker in ipairs({ "@capture_slice", "@capture_from_here", "@move_pos", "@mark(shared_9)" }) do
  local parsed = linkedspec.parse_spec("Root::\n " .. marker .. "\n /x/\n")
  check_equal(ast.node_type(parsed.rules[1].body[1].kind), "SplitMarkerBodyElementKind",
    marker .. " split marker kind")
  check_equal(parsed.rules[1].body[1].kind.marker, marker, marker .. " split marker identity")
end
for _, marker in ipairs({ "@mark(Töp)", "@mark(A·B)", "@mark(𐐀Rule)" }) do
  local parsed = linkedspec.parse_spec("Root::\n " .. marker .. "\n /x/\n")
  check_equal(ast.node_type(parsed.rules[1].body[1].kind), "RawBodyElementKind", marker .. " stays raw")
  check_equal(parsed.rules[1].body[1].kind.text, marker, marker .. " raw identity")
end

local conditional = linkedspec.parse_spec("Root::\n -? flag_9\n /x/\n")
check_equal(ast.node_type(conditional.rules[1].body[1].kind), "ConditionalBodyElementKind",
  "ASCII conditional kind")
check_equal(conditional.rules[1].body[1].kind.word, "flag_9", "ASCII conditional word")
for _, fixture in ipairs({
  { source = "-? Töp", word = "T", suffix = "öp" },
  { source = "-? A·B", word = "A", suffix = "·B" },
}) do
  local parsed = linkedspec.parse_spec("Root::\n " .. fixture.source .. "\n /x/\n")
  check_equal(ast.node_type(parsed.rules[1].body[1].kind), "ConditionalBodyElementKind",
    fixture.source .. " conditional prefix")
  check_equal(parsed.rules[1].body[1].kind.word, fixture.word, fixture.source .. " conditional word")
  check_equal(ast.node_type(parsed.rules[1].body[2].kind), "RawBodyElementKind",
    fixture.source .. " conditional suffix kind")
  check_equal(parsed.rules[1].body[2].kind.text, fixture.suffix, fixture.source .. " conditional suffix")
end
local supplementary_conditional = linkedspec.parse_spec("Root::\n -? 𐐀Rule\n /x/\n")
check_equal(ast.node_type(supplementary_conditional.rules[1].body[1].kind), "RawBodyElementKind",
  "supplementary conditional stays raw")

local bounded = linkedspec.parse_spec("Top::OR{2,3}\n /x/\n")
check_equal(bounded.rules[1].header.mode.name, "OrBounded", "bounded mode kind")
check_equal(bounded.rules[1].header.mode.min, 2, "bounded mode minimum")
check_equal(bounded.rules[1].header.mode.max, 3, "bounded mode maximum")
local invalid_bounded = linkedspec.parse_spec("Top::OR{2,Töp}\n /x/\n")
check_equal(invalid_bounded.rules[1].header.mode.name, "Default", "invalid bounded mode remains default")
check_equal(invalid_bounded.rules[1].header.rest, "OR{2,Töp}", "invalid bounded mode rest identity")
check_equal(ast.node_type(invalid_bounded.rules[1].body[1].kind), "BareEdgeBodyElementKind",
  "invalid bounded mode rest structure")
check_equal(invalid_bounded.rules[1].body[1].kind.targets[1].label, "OR",
  "invalid bounded mode ASCII target")
check_equal(invalid_bounded.rules[1].body[1].kind.code, "2,Töp", "invalid bounded mode code identity")

for _, name in ipairs({ "Grammaire_é", "Töp", "A·B", "𐐀Rule", "9_name" }) do
  check_equal(
    linkedspec.validate_spec_request(linkedspec.named_spec_request(name)),
    true,
    name .. " loader name remains Unicode scalar text"
  )
end

for _, pattern in ipairs({ "Töp", "A·B", "𐐀Rule", "Top-Rule" }) do
  local parsed = linkedspec.parse_spec("Top::\n /" .. pattern .. "/\n")
  check_equal(linkedspec.validate_spec(parsed), nil, pattern .. " regex validates")
  check_equal(ast.node_type(parsed.rules[1].body[1].kind), "RegexBodyElementKind", pattern .. " regex kind")
  check_equal(parsed.rules[1].body[1].kind.pattern, pattern, pattern .. " regex identity")
end

if #failures > 0 then
  error(table.concat(failures, "\n"), 0)
end
io.stdout:write("Lua Unicode rule-label negative isolation: ", assertions, " assertions passed\n")
