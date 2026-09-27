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
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-generated-v2.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean generated-v2 test directory", 0) end
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

local function replace_plain_once(value, old, new)
  local first, last = value:find(old, 1, true)
  if first == nil then return value, 0 end
  return value:sub(1, first - 1) .. new .. value:sub(last + 1), 1
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function execution_outcome(operation)
  local ok, value = capture(operation)
  if ok then return json.harray({ ok = true, value = value }) end
  return json.harray({ ok = false })
end

local function load_generated_module(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local contract = json.decode(read_file("capability_conformance/rule_local_cursor_contract.json"))
local generated_contract = contract.generated_source_v2
local validate_v2 = linkedspec.validate_generated_rule_plan_v2 or linkedspec.validate_generated_rule_plan_v1
local execute_v2 = linkedspec.execute_generated_parser_v2 or linkedspec.execute_generated_parser_v1
local emit_v2 = linkedspec.emit_lua_source_v2 or linkedspec.emit_lua_source_v1

check_equal(linkedspec.GENERATED_SOURCE_CONTRACT, generated_contract.contract_id, "generated contract id")
check_equal(linkedspec.GENERATED_SOURCE_FORMAT, generated_contract.format_version, "generated format")
check(type(linkedspec.validate_generated_source_contract_v2) == "function", "contract-v2 validator exported")
check(type(linkedspec.validate_generated_rule_plan_v2) == "function", "plan-v2 validator exported")
check(type(linkedspec.execute_generated_parser_v2) == "function", "direct-v2 executor exported")
check(type(linkedspec.execute_generated_parser_with_trace_v2) == "function", "trace-v2 executor exported")
check(type(linkedspec.emit_lua_source_v2) == "function", "emitter-v2 exported")
check_equal(linkedspec.validate_generated_rule_plan_v1, nil, "plan-v1 validator retired")
check_equal(linkedspec.execute_generated_parser_v1, nil, "direct-v1 executor retired")
check_equal(linkedspec.execute_generated_parser_with_trace_v1, nil, "trace-v1 executor retired")
check_equal(linkedspec.emit_lua_source_v1, nil, "emitter-v1 retired")

local identity = "generated-source/lua-v2-family-matrix.spec"
local family_source = [[
DefaultRoot::
 /hello[ \t]+(\w+)/
 LE { return(match_group(0)) }

OrAcode:|
 /go/ -> OrDone { return("or-acode") }
OrDone: /go/

AndSingle:AND
 /one/ -> AndSingleDone { return("and-single") }
AndSingleDone: /one/

AndSeq:AND
 /a/ -> AndSeqFirst
 /[ \t]+b/ -> AndSeqSecond { return("and-seq") }
AndSeqFirst: /a/
AndSeqSecond: /[ \t]+b/

AndBcode:AND
 => AndBlindA
 => AndBlindB
AndBlindA:& /a/ LE { return("A") }
AndBlindB:& /[ \t]+b/ LE { return("B") }

OrBcode:|
 => OrBlindA
 => OrBlindB
OrBlindA: /a/ LE { return("A") }
OrBlindB: /b/ LE { return("B") }

RepAcode:OR{1,2}
 /a/ -> RepA { return("rep-acode") }
RepA: /a/

RepBcode:OR{1,2}
 => RepBlind
RepBlind: /a/ LE { return("rep-bcode") }

RepAndAcode:AND{1}
 /a/ -> RepAndA { return("rep-and-acode") }
RepAndA: /a/

RepAndBcode:AND{1}
 => RepAndBlind
RepAndBlind:& /a/ LE { return("rep-and-bcode") }
]]
local cases = {
  { label = "DefaultRoot", family = "default", input = "prefix hello one" },
  { label = "OrAcode", family = "or_acode", input = "prefix go" },
  { label = "AndSingle", family = "and_single_acode", input = "prefix one" },
  { label = "AndSeq", family = "and_acode_seq", input = "prefix a b" },
  { label = "AndBcode", family = "and_bcode", input = "prefix a b" },
  { label = "OrBcode", family = "or_bcode", input = "prefix a" },
  { label = "RepAcode", family = "rep_acode", input = "prefix a" },
  { label = "RepBcode", family = "rep_bcode", input = "prefix a" },
  { label = "RepAndAcode", family = "rep_and_acode", input = "prefix a" },
  { label = "RepAndBcode", family = "rep_and_bcode", input = "prefix a" },
}
local expected_policies = {}
for _, family in ipairs(generated_contract.seek_families) do expected_policies[family] = "seek" end
for _, family in ipairs(generated_contract.consume_families) do expected_policies[family] = "consume" end

local compiled = compile_source(family_source)
local plan = linkedspec.build_generated_rule_plan(compiled)
local by_label = {}
for _, row in ipairs(plan) do
  by_label[row.label] = row.family
  check_equal(
    sorted_keys(linkedspec.generated_plan_row_to_json(row)),
    sorted_values(generated_contract.plan_row_fields),
    row.label .. " minimal plan fields"
  )
end
local plan_ok = capture(function() return validate_v2(compiled, plan, identity) end)
check_equal(plan_ok, true, "v2 plan validates")
for _, case in ipairs(cases) do
  check_equal(by_label[case.label], case.family, case.label .. " family")
  local policy = linkedspec.generated_family_cursor_policy and
    linkedspec.generated_family_cursor_policy(case.family) or "seek"
  check_equal(policy, expected_policies[case.family], case.label .. " derived cursor policy")
  local native = execution_outcome(function()
    return linkedspec.runtime_parse(
      linkedspec.runtime_engine(compiled),
      case.input,
      { top_rule = case.label }
    ).value
  end)
  local generated = execution_outcome(function()
    return execute_v2(compiled, plan, case.input, identity, { top_rule = case.label })
  end)
  check_same_json(generated, native, case.label .. " generated/native outcome")
end

local mismatch_ok, mismatch = capture(function()
  return validate_v2(compiled, plan, identity, "linkedspec-generated-source-v1")
end)
check_equal(mismatch_ok, false, "v1 contract rejected")
if not mismatch_ok and linkedspec.is_generated_source_error(mismatch) then
  check_equal(mismatch.stage, "validate_generated_plan", "v1 rejection stage")
  check_equal(mismatch.code, "generated_source_contract_version_mismatch", "v1 rejection code")
  check_equal(mismatch.source_identity, identity, "v1 rejection identity")
  check_equal(mismatch.expected_contract, generated_contract.contract_id, "v1 expected contract")
  check_equal(mismatch.actual_contract, "linkedspec-generated-source-v1", "v1 actual contract")
  check_equal(
    mismatch.detail,
    "regenerate the generated artifact from its .spec source",
    "v1 regeneration guidance"
  )
else
  for _, label in ipairs({
    "v1 rejection stage",
    "v1 rejection code",
    "v1 rejection identity",
    "v1 expected contract",
    "v1 actual contract",
    "v1 regeneration guidance",
  }) do check(false, label) end
end

local pipe_source = [[
Top::|
 => X
 => Y
X:
 I { return("x") }
 /x/
Y:
 I { return("y") }
 /y/
]]
local pipe_compiled = compile_source(pipe_source)
local pipe_plan = linkedspec.build_generated_rule_plan(pipe_compiled)
check_equal(pipe_plan[1].family, "or_bcode", "compact pipe generated family")
check_same_json(
  execute_v2(pipe_compiled, pipe_plan, "xy", "generated-source/lua-v2-pipe.spec"),
  "x",
  "compact pipe generated choice"
)

local structural_cases = {
  {
    id = "ordered_landmarks",
    input = "junk h junk b",
    source = [[
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
]],
  },
  {
    id = "anchored_choice",
    input = "prefix x",
    source = [[
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
]],
  },
}
for _, case in ipairs(structural_cases) do
  local structural = compile_source(case.source)
  local structural_plan = linkedspec.build_generated_rule_plan(structural)
  local native = linkedspec.runtime_parse(linkedspec.runtime_engine(structural), case.input).value
  local generated = execute_v2(
    structural,
    structural_plan,
    case.input,
    "generated-source/lua-v2-" .. case.id .. ".spec"
  )
  check_same_json(generated, native, case.id .. " generated/native value")
end

local emitted = emit_v2(pipe_compiled, "generated-source/lua-v2-fresh.spec")
check_equal(emitted, emit_v2(pipe_compiled, "generated-source/lua-v2-fresh.spec"), "deterministic v2 bytes")
check(emitted:find("linkedspec-generated-source-v2", 1, true) ~= nil, "v2 source contract marker")
check(emitted:find("LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", 1, true) ~= nil, "v2 source format marker")
check_equal(
  emitted:find("cursor_policy", 1, true) or emitted:find("parse_mode", 1, true),
  nil,
  "generated source omits cursor fields"
)
local direct_module = load_generated_module(emitted, "@generated-v2-direct")
check_equal(direct_module.execute("xy"), "x", "direct loaded v2 choice")
local trace_output = {}
check_equal(
  direct_module.execute_with_trace(
    "xy",
    linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
    { stdout_writer = function(value) trace_output[#trace_output + 1] = value end }
  ),
  "x",
  "direct loaded v2 trace value"
)
local trace_text = table.concat(trace_output)
check(trace_text:find("generated_rule_enter", 1, true) ~= nil, "v2 trace enter")
check(trace_text:find("generated_family_decision", 1, true) ~= nil, "v2 trace decision")
check(trace_text:find("generated_rule_exit", 1, true) ~= nil, "v2 trace exit")
check(trace_text:find("source_identity=generated-source/lua-v2-fresh.spec", 1, true) ~= nil, "v2 trace identity")

with_temp_directory(function(root)
  local valid_path = root .. "/valid.lua"
  local corrupt_path = root .. "/corrupt.lua"
  local legacy_path = root .. "/legacy.lua"
  local runner_path = root .. "/runner.lua"
  local stdout_path = root .. "/stdout.json"
  local stderr_path = root .. "/stderr.txt"
  local corrupt = emitted:gsub(
    'local _EFFECTIVE_SPEC_JSON_HEX = "[0-9a-f]+"',
    'local _EFFECTIVE_SPEC_JSON_HEX = "not-hex"',
    1
  )
  local legacy = replace_plain_once(
    corrupt,
    'M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"',
    'M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v1"'
  )
  write_file(valid_path, emitted)
  write_file(corrupt_path, corrupt)
  write_file(legacy_path, legacy)
  write_file(runner_path, [[
local linkedspec = require("linkedspec")
local json = linkedspec.json
local function load_observation(path)
  local ok, value = pcall(function() return assert(loadfile(path))() end)
  if ok then return { ok = true, module = value } end
  local projected = linkedspec.is_generated_source_error(value) and
    linkedspec.generated_source_error_to_json(value) or { detail = tostring(value) }
  return { ok = false, failure = projected }
end
local valid = load_observation(arg[1])
local legacy = load_observation(arg[2])
local corrupt = load_observation(arg[3])
local result = json.harray({
  valid_ok = valid.ok,
  legacy_ok = legacy.ok,
  corrupt_ok = corrupt.ok,
  legacy_failure = legacy.failure,
  corrupt_failure = corrupt.failure,
})
if valid.ok then
  result.metadata = linkedspec.generated_source_metadata_to_json(valid.module.metadata())
  result.value = valid.module.execute("xy")
  result.plan = json.array()
  for index, row in ipairs(valid.module.plan()) do
    result.plan[index] = linkedspec.generated_plan_row_to_json(row)
  end
  local output = {}
  result.traced = valid.module.execute_with_trace(
    "xy",
    linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
    { stdout_writer = function(payload) output[#output + 1] = payload end }
  )
  result.trace = table.concat(output)
end
io.write(json.encode(result), "\n")
]])
  local runtime = os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME") or (type(jit) == "table" and "luajit" or "lua")
  local command = table.concat({
    "env LUA_PATH=" .. shell_quote(os.getenv("LUA_PATH") or ""),
    "LUA_CPATH=" .. shell_quote(os.getenv("LUA_CPATH") or ""),
    shell_quote(runtime),
    shell_quote(runner_path),
    shell_quote(valid_path),
    shell_quote(legacy_path),
    shell_quote(corrupt_path),
    ">" .. shell_quote(stdout_path),
    "2>" .. shell_quote(stderr_path),
  }, " ")
  check_equal(command_succeeded(command), true, "fresh generated-v2 host status")
  local stdout = read_file(stdout_path)
  local stderr = read_file(stderr_path)
  check_equal(stderr, "", "fresh generated-v2 host stderr")
  local observed = json.decode(stdout)
  check_equal(observed.valid_ok, true, "fresh v2 load")
  check_equal(observed.metadata.contract_id, generated_contract.contract_id, "fresh v2 contract")
  check_equal(observed.metadata.format_version, generated_contract.format_version, "fresh v2 format")
  check_equal(observed.metadata.source_identity, "generated-source/lua-v2-fresh.spec", "fresh v2 identity")
  check_equal(observed.value, "x", "fresh v2 value")
  check_equal(observed.traced, "x", "fresh v2 traced value")
  check(observed.trace:find("generated_rule_enter", 1, true) ~= nil, "fresh v2 enter trace")
  check(observed.trace:find("generated_family_decision", 1, true) ~= nil, "fresh v2 decision trace")
  check(observed.trace:find("generated_rule_exit", 1, true) ~= nil, "fresh v2 exit trace")
  check(observed.trace:find("source_identity=generated-source/lua-v2-fresh.spec", 1, true) ~= nil, "fresh v2 trace identity")
  check_equal(observed.legacy_ok, false, "fresh legacy contract rejected")
  check_equal(observed.legacy_failure.stage, "validate_generated_plan", "fresh legacy stage before payload")
  check_equal(
    observed.legacy_failure.code,
    "generated_source_contract_version_mismatch",
    "fresh legacy code before payload"
  )
  check_equal(observed.legacy_failure.expected_contract, generated_contract.contract_id, "fresh legacy expected")
  check_equal(observed.legacy_failure.actual_contract, "linkedspec-generated-source-v1", "fresh legacy actual")
  check_equal(
    observed.legacy_failure.detail,
    "regenerate the generated artifact from its .spec source",
    "fresh legacy guidance"
  )
  check_equal(observed.corrupt_ok, false, "fresh corrupt v2 rejected")
  check_equal(observed.corrupt_failure.stage, "compile_or_load_generated_source", "fresh corrupt v2 stage")
  check_equal(observed.corrupt_failure.code, "generated_source_compile_failed", "fresh corrupt v2 code")
end)

-- Bounded nesting uses unchanged authored data and the existing isolated-host owner.
do
  local fixture = "tests/language-readiness/nested-tree/"
  local nesting = dofile(fixture .. "lua_checks.lua")
  local original = read_file(fixture .. "grammar.spec")
  local nesting_cases = json.decode(read_file(fixture .. "cases.json"))
  local function replace_exact(source, needle, replacement, expected_count)
    local pieces, cursor, count = {}, 1, 0
    while true do
      local first, last = source:find(needle, cursor, true)
      if first == nil then break end
      pieces[#pieces + 1] = source:sub(cursor, first - 1)
      pieces[#pieces + 1] = replacement
      cursor, count = last + 1, count + 1
    end
    pieces[#pieces + 1] = source:sub(cursor)
    assert(count == expected_count, "exact mutation target count")
    return table.concat(pieces)
  end
  local prefix = " if(matches(input_slice(0, cursor_pos()), /[^ \\t\\r\\n\\f\\x0B]/));\n" ..
    "  exit_now(1);\n endif();\n"
  local variants = {
    { id = "original", source = original },
    { id = "prefix", source = replace_exact(original, prefix, "", 1) },
    { id = "gap", source = replace_exact(original, " -> Invalid { exit_now(1) }\n", "", 2) },
    { id = "span", source = replace_exact(original,
      "[start, cursor_pos()]", "[cursor_pos(), cursor_pos()]", 1) },
  }
  local modules = {}
  for _, variant in ipairs(variants) do
    local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(variant.source)
    linkedspec.validate_spec(parsed)
    local reconstructed = linkedspec.spec_ast.from_json("SpecFile",
      json.decode(json.encode(linkedspec.spec_ast.to_json(parsed))))
    linkedspec.validate_spec(reconstructed)
    for _, spec in ipairs({ parsed, reconstructed }) do
      local carrier = linkedspec.compile_spec(spec)
      local carrier_plan = linkedspec.build_generated_rule_plan(carrier)
      linkedspec.validate_generated_rule_plan_v2(carrier, carrier_plan, variant.id)
      local labels = json.array()
      for index, row in ipairs(carrier_plan) do labels[index] = row.label end
      check_same_json(labels, json.array({ "Top", "List", "Atom", "Space", "Invalid" }),
        variant.id .. " nesting plan")
      local engine = linkedspec.runtime_engine(carrier)
      -- These two native routes retain the engine throughout each rejection/recovery sequence.
      check(nesting.variant(variant.id, nesting_cases, function(input)
        return linkedspec.runtime_parse(engine, input).value
      end), variant.id .. " nesting native")
      -- Public generated entry constructs an engine on every call.
      check(nesting.variant(variant.id, nesting_cases, function(input)
        return linkedspec.execute_generated_parser_v2(carrier, carrier_plan, input, variant.id)
      end), variant.id .. " nesting generated")
    end
    modules[variant.id] = linkedspec.emit_lua_source_v2(
      linkedspec.compile_spec(parsed), "nested-tree/" .. variant.id)
  end

  local owned_root
  with_temp_directory(function(root)
    owned_root = root
    write_file(root .. "/checks.lua", read_file(fixture .. "lua_checks.lua"))
    write_file(root .. "/cases.json", read_file(fixture .. "cases.json"))
    for id, module_source in pairs(modules) do write_file(root .. "/" .. id .. ".lua", module_source) end
    write_file(root .. "/runner.lua", [[
local linkedspec = require("linkedspec")
local json = linkedspec.json
local root = assert(arg[1])
local checks = dofile(root .. "/checks.lua")
local handle = assert(io.open(root .. "/cases.json", "rb"))
local cases = json.decode(assert(handle:read("*a")))
assert(handle:close())
local modules = 0
for _, id in ipairs({ "original", "prefix", "gap", "span" }) do
  local parser = assert(loadfile(root .. "/" .. id .. ".lua"))()
  checks.exact_json(linkedspec.generated_source_metadata_to_json(parser.metadata()), json.harray({
    contract_id = "linkedspec-generated-source-v2",
    format_version = 2,
    source_identity = "nested-tree/" .. id,
  }), id .. " metadata")
  parser.validate_plan(parser.plan())
  assert(checks.variant(id, cases, parser.execute))
  modules = modules + 1
end
io.write(json.encode(json.harray({ modules = modules, original_executions = 40, mutations = 3 })), "\n")
]])
    local runtime = assert(os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME"), "selected ABI runtime required")
    local stdout_path, stderr_path = root .. "/stdout.json", root .. "/stderr.txt"
    local command = table.concat({
      "env LUA_PATH=" .. shell_quote(assert(os.getenv("LUA_PATH"))),
      "LUA_CPATH=" .. shell_quote(assert(os.getenv("LUA_CPATH"))),
      shell_quote(runtime), shell_quote(root .. "/runner.lua"), shell_quote(root),
      ">" .. shell_quote(stdout_path), "2>" .. shell_quote(stderr_path),
    }, " ")
    local succeeded = command_succeeded(command)
    local stdout, stderr = read_file(stdout_path), read_file(stderr_path)
    assert(succeeded, "nesting child failed:\n" .. stdout .. stderr)
    check_equal(stderr, "", "nesting child stderr")
    check_same_json(json.decode(stdout),
      json.harray({ modules = 4, original_executions = 40, mutations = 3 }),
      "nesting child completion")
  end)
  check(command_succeeded("test ! -e " .. shell_quote(owned_root)), "nesting child cleanup")
end

if #failures == 0 then
  io.stdout:write("rule-local cursor generated source: ", assertions, " assertions passed\n")
else
  io.stderr:write("rule-local cursor generated source: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
