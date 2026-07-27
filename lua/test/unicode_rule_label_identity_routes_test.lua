-- FUTURE-PARITY-BACKLOG.10.7.1.2 — exact downstream Lua label identity.

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

local function with_temp_directory(operation)
  local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
  assert(temp_root ~= "", "TMPDIR must not be empty")
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-unicode-identity.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean Unicode identity test directory", 0) end
  if not ok then error(value, 0) end
end

local function sorted_keys(value)
  local result = {}
  for key in pairs(value) do result[#result + 1] = key end
  table.sort(result)
  return result
end

local function copy_list(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function check_list(actual, expected, label)
  check_equal(#actual, #expected, label .. " length")
  for index, value in ipairs(expected) do
    check_equal(actual[index], value, label .. " item " .. index)
  end
end

local function decode_hex(value)
  check(#value % 2 == 0, "emitted payload has an even hex length")
  local chunks = {}
  for position = 1, #value, 2 do
    chunks[#chunks + 1] = string.char(assert(tonumber(value:sub(position, position + 1), 16)))
  end
  return table.concat(chunks)
end

local function load_generated_module(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local contract = json.decode(read_file("capability_conformance/unicode_rule_label_contract.json"))

local labels = json.array()
local label_set = {}
local function add_label(label)
  if label_set[label] then return end
  label_set[label] = true
  labels[#labels + 1] = label
end
for _, fixture in ipairs(contract.positive_fixtures) do add_label(fixture.label) end
for _, fixture in ipairs(contract.distinct_fixtures) do
  add_label(fixture.left)
  add_label(fixture.right)
end

local function fixture_label(collection, id, field)
  for _, fixture in ipairs(collection) do
    if fixture.id == id then return fixture[field] end
  end
  error("missing fixture " .. id, 0)
end

local source_lines = {}
for index, label in ipairs(labels) do
  source_lines[#source_lines + 1] = label .. (index == 1 and "::" or ":")
  source_lines[#source_lines + 1] = " /x/"
  source_lines[#source_lines + 1] = " E { return(" .. json.encode(label) .. ") }"
  source_lines[#source_lines + 1] = ""
end
local source = table.concat(source_lines, "\n")

-- every positive and distinct label survives compiled artifacts
check_equal(#contract.positive_fixtures, 9, "neutral positive fixture count")
check_equal(#contract.distinct_fixtures, 2, "neutral distinct fixture count")
check_equal(#labels, 10, "unique positive and distinct label count")

local parsed = linkedspec.parse_spec(source)
check_equal(linkedspec.validate_spec(parsed), nil, "identity source validates")
local parsed_labels = {}
for index, rule in ipairs(parsed.rules) do parsed_labels[index] = rule.header.label end
check_list(parsed_labels, labels, "parsed declaration labels")

local compiled = linkedspec.compile_spec(parsed)
local compiled_json = linkedspec.compiled_spec_to_json(compiled)
local descriptor = linkedspec.to_descriptor_json(compiled)
local plan = linkedspec.build_generated_rule_plan(compiled)
local plan_labels = {}
for index, row in ipairs(plan) do plan_labels[index] = row.label end

check_list(compiled.definition_order, labels, "compiled definition order")
check_list(compiled.compiled_rule_order, labels, "compiled rule order")
check_list(sorted_keys(compiled.rules_by_label), sorted_keys(label_set), "compiled rule map keys")
check_list(sorted_keys(compiled_json.rules_by_label), sorted_keys(label_set), "compiled JSON rule map keys")
check_list(sorted_keys(descriptor.spec), sorted_keys(label_set), "descriptor rule map keys")
check_list(descriptor.meta.definition_order, labels, "descriptor definition order")
check_list(descriptor.meta.compiled_rule_order, labels, "descriptor compiled order")
check_list(plan_labels, labels, "generated plan labels")

local reconstructed_ast = linkedspec.spec_ast.from_json(
  "SpecFile",
  json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
)
local reconstructed = linkedspec.compile_spec(reconstructed_ast)
check_same_json(linkedspec.compiled_spec_to_json(reconstructed), compiled_json, "reconstructed compiled JSON")
check_same_json(linkedspec.to_descriptor_json(reconstructed), descriptor, "reconstructed descriptor")

local reconstructed_engine = linkedspec.runtime_engine(reconstructed)
check_equal(linkedspec.runtime_parse(reconstructed_engine, "x").value, labels[1], "native default label")
for _, label in ipairs(labels) do
  local rule = compiled:rule(label)
  check(rule ~= nil, label .. " compiled rule exists")
  if rule ~= nil then check_equal(rule.label, label, label .. " compiled rule identity") end
  check_equal(
    linkedspec.resolve_entry_rule(compiled, label).rule.label,
    label,
    label .. " selector identity"
  )
  check_equal(
    linkedspec.runtime_parse(reconstructed_engine, "x", { top_rule = label }).value,
    label,
    label .. " reconstructed runtime identity"
  )
  check_equal(
    linkedspec.execute_generated_parser_v2(
      compiled,
      plan,
      "x",
      "unicode-label/direct-plan.spec",
      { top_rule = label }
    ),
    label,
    label .. " direct generated-plan identity"
  )
end

for _, fixture in ipairs(contract.distinct_fixtures) do
  check(fixture.left ~= fixture.right, fixture.id .. " byte identity remains distinct")
  check(compiled:rule(fixture.left) ~= nil, fixture.id .. " left rule exists")
  check(compiled:rule(fixture.right) ~= nil, fixture.id .. " right rule exists")
  check(compiled:rule(fixture.left) ~= compiled:rule(fixture.right), fixture.id .. " rules stay distinct")
end

local compiled_text = json.encode(compiled_json)
local descriptor_text = json.encode(descriptor)
for name, value in pairs({ compiled = compiled_text, descriptor = descriptor_text }) do
  check_equal(value:find("table: 0x", 1, true), nil, name .. " omits table identity")
  check_equal(value:find("userdata:", 1, true), nil, name .. " omits userdata identity")
end

-- emitted source reconstructs and executes every exact label
local identity = "unicode-label/emitted-規則-𐐀.spec"
local emitted_source = linkedspec.emit_lua_source_v2(compiled, identity)
local payload_hex = emitted_source:match('local _EFFECTIVE_SPEC_JSON_HEX = "([0-9a-f]+)"')
check(payload_hex ~= nil, "emitted effective-spec payload exists")
local emitted_reconstructed
if payload_hex ~= nil then
  emitted_reconstructed = linkedspec.compile_spec(linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(decode_hex(payload_hex))
  ))
  check_list(emitted_reconstructed.compiled_rule_order, labels, "emitted payload compiled order")
  local emitted_payload_plan = linkedspec.build_generated_rule_plan(emitted_reconstructed)
  local emitted_payload_labels = {}
  for index, row in ipairs(emitted_payload_plan) do emitted_payload_labels[index] = row.label end
  check_list(emitted_payload_labels, labels, "emitted payload plan labels")
end

local direct_module = load_generated_module(emitted_source, "@unicode-label-identity")
check_equal(direct_module.metadata().source_identity, identity, "direct emitted metadata identity")
local direct_plan = direct_module.plan()
local direct_plan_labels = {}
for index, row in ipairs(direct_plan) do direct_plan_labels[index] = row.label end
check_list(direct_plan_labels, labels, "direct emitted plan labels")
check_equal(direct_module.validate_plan(direct_plan), nil, "direct emitted plan validates")
for _, label in ipairs(labels) do
  check_equal(
    direct_module.execute("x", { top_rule = label }),
    label,
    label .. " direct emitted execution identity"
  )
end

with_temp_directory(function(root)
  local generated_path = root .. "/generated_parser.lua"
  local runner_path = root .. "/runner.lua"
  local labels_path = root .. "/labels.json"
  local stdout_path = root .. "/stdout.json"
  local stderr_path = root .. "/stderr.txt"
  write_file(generated_path, emitted_source)
  write_file(labels_path, json.encode(labels))
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
local labels = json.decode(read_file(arg[2]))
local plan = generated.plan()
generated.validate_plan(plan)
local plan_labels = json.array()
local values = json.array()
for index, row in ipairs(plan) do plan_labels[index] = row.label end
for index, label in ipairs(labels) do
  values[index] = generated.execute("x", { top_rule = label })
end
local output = {}
local selected = labels[#labels]
local traced = generated.execute_with_trace(
  "x",
  linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
  {
    top_rule = selected,
    stdout_writer = function(payload) output[#output + 1] = payload end,
  }
)
io.write(json.encode(json.harray({
  identity = generated.metadata().source_identity,
  labels = labels,
  plan = plan_labels,
  values = values,
  traced = traced,
  trace = table.concat(output),
})), "\n")
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
  check_equal(command_succeeded(command), true, "fresh emitted host status")
  check_equal(read_file(stderr_path), "", "fresh emitted host stderr")
  local observed = json.decode(read_file(stdout_path))
  check_equal(observed.identity, identity, "fresh emitted metadata identity")
  check_list(observed.labels, labels, "fresh emitted input labels")
  check_list(observed.plan, labels, "fresh emitted plan labels")
  check_list(observed.values, labels, "fresh emitted execution values")
  check_equal(observed.traced, labels[#labels], "fresh emitted traced value")
  check_contains(observed.trace, "requested=" .. labels[#labels], "fresh emitted trace selector")
  check_contains(observed.trace, "top_rule=" .. labels[#labels], "fresh emitted trace rule")
  check_contains(observed.trace, identity, "fresh emitted trace identity")

  -- strict loading and both primary source forms preserve every exact label
  local spec_path = root .. "/unicode-規則.spec"
  write_file(spec_path, source)
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request(spec_path),
    linkedspec.spec_load_options({ cwd = root, search_roots = {} })
  )
  check_equal(loaded.loaded.source_text, source, "strict loader source bytes")
  check_list(loaded.compiled.compiled_rule_order, labels, "strict loader compiled order")
  local loaded_compiled_json = json.encode(linkedspec.compiled_spec_to_json(loaded.compiled))
  local loaded_descriptor_json = json.encode(linkedspec.to_descriptor_json(loaded.compiled))
  check_equal(loaded_compiled_json:find(spec_path, 1, true), nil, "compiled JSON omits loader path")
  check_equal(loaded_descriptor_json:find(spec_path, 1, true), nil, "descriptor omits loader path")
  check_equal(loaded_compiled_json:find("table: 0x", 1, true), nil, "loaded JSON omits table identity")
  check_equal(loaded_descriptor_json:find("table: 0x", 1, true), nil, "loaded descriptor omits table identity")

  local loaded_engine = loaded:create_engine()
  for _, label in ipairs(labels) do
    check_equal(
      linkedspec.runtime_parse(loaded_engine, "x", { top_rule = label }).value,
      label,
      label .. " loaded runtime identity"
    )
    local inline = linkedspec.run_primary_cli({
      "--inline-spec", source,
      "--input", "x",
      "--top-rule", label,
    }, { cwd = root })
    check_equal(inline.exit_code, 0, label .. " inline primary exit")
    check_equal(inline.stdout, json.encode(label) .. "\n", label .. " inline primary stdout")
    check_equal(inline.stderr, "", label .. " inline primary stderr")

    local file_route = linkedspec.run_primary_cli({
      "--spec-file", spec_path,
      "--input", "x",
      "--top-rule", label,
    }, { cwd = root })
    check_equal(file_route.exit_code, 0, label .. " file primary exit")
    check_equal(file_route.stdout, json.encode(label) .. "\n", label .. " file primary stdout")
    check_equal(file_route.stderr, "", label .. " file primary stderr")
  end

  -- selectors, diagnostics, and traces retain exact Unicode identity
  local selected = fixture_label(contract.distinct_fixtures, "normalization_sensitive", "right")
  local missing = "規則Missing𐐀"
  local trace_output = {}
  local trace_emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function(payload) trace_output[#trace_output + 1] = payload end }
  )
  check_equal(
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(compiled),
      "x",
      { top_rule = selected, trace = trace_emitter }
    ).value,
    selected,
    "native traced selector identity"
  )
  local selection_events = {}
  for _, event in ipairs(linkedspec.trace_events(trace_emitter)) do
    if event.topic == "lua_runtime:entry_rule_selection" then
      selection_events[#selection_events + 1] = event
    end
  end
  check_equal(#selection_events, 1, "native selection trace event count")
  if selection_events[1] ~= nil then
    check_contains(selection_events[1].details, "requested=" .. selected, "native trace requested label")
    check_contains(selection_events[1].details, "effective=" .. selected, "native trace effective label")
    check_contains(selection_events[1].details, "basis=explicit_selector", "native trace selector basis")
  end
  check_contains(table.concat(trace_output), "top_rule=" .. selected, "native trace top rule")
  check_contains(table.concat(trace_output), selected, "native trace raw Unicode identity")

  local native_ok, native_failure = capture(function()
    return linkedspec.runtime_parse(
      linkedspec.runtime_engine(compiled),
      "x",
      { top_rule = missing, trace = trace_emitter }
    )
  end)
  check_equal(native_ok, false, "native missing selector rejected")
  check_equal(linkedspec.is_runtime_interpreter_error(native_failure), true, "native missing selector type")
  if linkedspec.is_runtime_interpreter_error(native_failure) then
    check_same_json(
      linkedspec.interpreter.to_json(native_failure.diagnostic),
      json.harray({
        type = "runtime_parser",
        stage = "select_entry_rule",
        owner_stage = "lua_runtime",
        summary = "Lua runtime entry-rule selection failed",
        detail = "entry rule '" .. missing .. "' is not defined",
        top_rule = missing,
        entry_rule = missing,
        rule_label = missing,
        handler_source_label = "lua_runtime:rule:" .. missing,
        code = "entry_rule_not_found",
      }),
      "native missing selector diagnostic"
    )
  end

  local generated_ok, generated_failure = capture(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      plan,
      "x",
      identity,
      { top_rule = missing }
    )
  end)
  check_equal(generated_ok, false, "generated missing selector rejected")
  check_equal(linkedspec.is_generated_source_error(generated_failure), true, "generated missing selector type")
  if linkedspec.is_generated_source_error(generated_failure) then
    check_same_json(
      linkedspec.generated_source_error_to_json(generated_failure),
      json.harray({
        type = "generated_source_error",
        stage = "select_entry_rule",
        code = "entry_rule_not_found",
        summary = "Generated Lua parser entry-rule selection failed",
        source_identity = identity,
        entry_rule = missing,
        rule_label = missing,
        detail = "entry rule '" .. missing .. "' is not defined",
      }),
      "generated missing selector diagnostic"
    )
  end

  local trace_path = root .. "/generated.trace"
  local trace_config = linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    trace_path
  ))
  check_equal(
    linkedspec.execute_generated_parser_with_trace_v2(
      compiled,
      plan,
      "x",
      trace_config,
      identity,
      { top_rule = selected }
    ),
    selected,
    "generated routed trace value"
  )
  local generated_trace = read_file(trace_path)
  check_contains(generated_trace, "requested=" .. selected, "generated trace requested label")
  check_contains(generated_trace, "effective=" .. selected, "generated trace effective label")
  check_contains(generated_trace, "top_rule=" .. selected, "generated trace top rule")
  check_contains(generated_trace, identity, "generated trace source identity")
end)

if #failures > 0 then
  error(table.concat(failures, "\n"), 0)
end
io.stdout:write("Lua Unicode rule-label identity routes: ", assertions, " assertions passed\n")
