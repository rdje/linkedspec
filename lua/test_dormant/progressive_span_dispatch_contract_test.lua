-- FUTURE-PARITY-BACKLOG.14.6.6.0 — dormant shared Lua progressive RED.
--
-- This exact final-path consumer is deliberately absent from ordinary Lua
-- discovery and canonical CI. Run the same Lua-5.1-compatible source on both
-- admitted hosts through repository-local project storage:
--
--   bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_contract_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_contract_test.lua

local json = require("linkedspec.json")
local linkedspec = require("linkedspec")

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(
    actual == expected,
    label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)
  )
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

local function file_exists(path)
  local handle = io.open(path, "rb")
  if handle == nil then return false end
  assert(handle:close())
  return true
end

local function count_literal(text, needle)
  local count = 0
  local position = 1
  while true do
    local found = string.find(text, needle, position, true)
    if found == nil then return count end
    count = count + 1
    position = found + #needle
  end
end

local function all_objects(value, result)
  result = result or {}
  if type(value) ~= "table" then return result end
  result[#result + 1] = value
  for _, child in pairs(value) do
    if type(child) == "table" then all_objects(child, result) end
  end
  return result
end

local function objects_with_kind(value, kind)
  local result = {}
  for _, object in ipairs(all_objects(value)) do
    if object.kind == kind then result[#result + 1] = object end
  end
  return result
end

local function compile_source(source)
  local parsed = linkedspec.parse_spec(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
end

local contract = json.decode(read_file(
  "capability_conformance/progressive_span_dispatch_contract.json"
))

local authored_source = [[Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
]]

check_equal(
  contract.contract_id,
  "linkedspec-progressive-span-dispatch-v1",
  "neutral contract id"
)
check_equal(contract.format, 1, "neutral contract format")
check_equal(
  contract.status,
  "perl_rust_dart_and_julia_complete_other_backends_pending",
  "neutral rollout status"
)
for name, expected in pairs({
  registry_entries = 2,
  sources = 2,
  view_cases = 8,
  authority_cases = 6,
  cancellation_cases = 6,
  chain_cases = 8,
  execution_cases = 4,
  rust_carrier_paths = 9,
  dart_carrier_paths = 8,
  julia_carrier_paths = 9,
  backend_guard_groups = 1,
  backend_guard_paths = 5,
  outward_guard_paths = 10,
  diagnostics = 26,
  rollout_legs = 9,
  mutations = 106,
}) do
  check_equal(contract.expected_counts[name], expected, "neutral count " .. name)
end
check_equal(#contract.rollout, 9, "neutral rollout row count")
for index = 1, 5 do
  check_equal(contract.rollout[index].status, "complete", "complete rollout " .. index)
end
for index = 6, 9 do
  check_equal(contract.rollout[index].status, "pending", "pending rollout " .. index)
end
check_equal(contract.rollout[6].leg, "puc_lua", "PUC Lua rollout leg")
check_equal(
  contract.rollout[6].owner,
  "FUTURE-PARITY-BACKLOG.14.6.6",
  "PUC Lua rollout owner"
)
check_equal(contract.rollout[7].leg, "luajit", "LuaJIT rollout leg")
check_equal(
  contract.rollout[7].owner,
  "FUTURE-PARITY-BACKLOG.14.6.6",
  "LuaJIT rollout owner"
)
check_equal(#contract.current_boundary.backend_guard_groups, 1, "one Lua guard group")
local lua_guard = contract.current_boundary.backend_guard_groups[1]
check_equal(lua_guard.backend, "lua", "Lua guard identity")
check_equal(#lua_guard.paths, 5, "Lua guard path count")
check_same_json(
  lua_guard.forbidden_tokens,
  json.array({ "dispatch_span", "PROGRESSIVE_DISPATCH_SPAN" }),
  "Lua guard tokens"
)

do
  local job = linkedspec.spec_ast.staged_parse_job({
    version = 1,
    job_id = "progressive-lua-red",
    parent_ast_path = json.array({ "Top" }),
    node_kind = "progressive_span_dispatch",
    payload_kind = "source_span",
    text = "a",
    source_span = linkedspec.spec_ast.staged_source_span({
      start = 0,
      ["end"] = 1,
      line_start = 1,
      line_end = 1,
    }),
    parser_spec_id = "expr-v1",
    top_rule = "Expr",
    result_policy = "replace_field",
    result_field = "value",
    failure_policy = "fail_only",
    diagnostic_owner = "progressive_span_dispatch",
  })
  local ok, captured = capture(function()
    return linkedspec.execute_staged_parse_job(job)
  end)
  check_equal(ok, false, "unrelated staged registry rejects expr-v1")
  check_equal(
    linkedspec.is_staged_parser_registry_error(captured),
    true,
    "staged rejection remains typed"
  )
  check_equal(
    tostring(captured),
    "StagedParserRegistryException: staged parse dispatch failed: " ..
      "phase=resolve job_id=progressive-lua-red parent_ast_path=Top " ..
      "parser_spec_id=expr-v1 top_rule=Expr source_span=0-1 " ..
      "failure_policy=fail_only detail=unsupported parser spec id 'expr-v1'",
    "staged resolve boundary"
  )
end

local parsed, compiled = compile_source(authored_source)
local compiled_json = linkedspec.compiled_spec_to_json(compiled)
local top = compiled_json.rules_by_label.Top
local generic_calls = {}
for _, object in ipairs(objects_with_kind(top, "call")) do
  if object.name == "dispatch_span" then generic_calls[#generic_calls + 1] = object end
end
local progressive_nodes = objects_with_kind(top, "progressive_dispatch_span")
local assignments = {}
for _, object in ipairs(objects_with_kind(top, "assign_scalar")) do
  if object.name == "value" then assignments[#assignments + 1] = object end
end

check_equal(#generic_calls, 1, "current generic dispatch_span call count")
check_equal(#progressive_nodes, 0, "current dedicated progressive node count")
check_equal(#assignments, 1, "current dispatch assignment count")
check_equal(assignments[1].value, generic_calls[1], "generic call remains assignment value")
check_equal(#generic_calls[1].args, 3, "generic dispatch operand count")
check_equal(generic_calls[1].args[1].value, "expr-v1", "generic parser identity")
check_equal(generic_calls[1].args[2].value, "Expr", "generic top rule")
check_equal(generic_calls[1].args[3].name, "span", "generic span binding")
local payload = top.lifecycle_action_payloads[1]
check_equal(payload.contracts.ok, false, "generic helper contract remains unresolved")
check_equal(#payload.contracts.diagnostics, 1, "one generic helper diagnostic")
check_equal(payload.contracts.diagnostics[1].code, "unknown_helper", "generic helper code")
check_equal(
  payload.contracts.diagnostics[1].helper_name,
  "dispatch_span",
  "generic helper identity"
)

local expected_runtime_record = json.harray({
  message = "unsupported runtime helper 'dispatch_span'",
  diagnostic = json.harray({
    type = "runtime_parser",
    stage = "runtime_execution",
    summary = "Lua runtime interpreter failed",
    detail = "unsupported runtime helper 'dispatch_span'",
    owner_stage = "lua_runtime",
    top_rule = "Top",
    rule_label = "Top",
    handler_source_label = "lua_runtime:rule:Top",
  }),
})

local function check_runtime_failure(label, operation)
  local ok, captured = capture(operation)
  check_equal(ok, false, label .. " rejects")
  check_equal(
    linkedspec.is_runtime_interpreter_error(captured),
    true,
    label .. " typed runtime error"
  )
  if linkedspec.is_runtime_interpreter_error(captured) then
    check_same_json(
      linkedspec.interpreter.to_json(captured),
      expected_runtime_record,
      label .. " exact runtime record"
    )
  end
end

check_runtime_failure("native carrier", function()
  return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "abc").value
end)

local normalized = json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
local reconstructed_spec = linkedspec.spec_ast.from_json("SpecFile", normalized)
linkedspec.validate_spec(reconstructed_spec)
check_same_json(
  linkedspec.spec_ast.to_json(reconstructed_spec),
  normalized,
  "normalized SpecFile reconstruction"
)
local reconstructed = linkedspec.compile_spec(reconstructed_spec)
check_runtime_failure("reconstructed carrier", function()
  return linkedspec.runtime_parse(linkedspec.runtime_engine(reconstructed), "abc").value
end)

local plan = linkedspec.build_generated_rule_plan(compiled)
check_equal(#plan, 1, "generated plan row count")
check_equal(plan[1].label, "Top", "generated plan label")
check_equal(plan[1].family, "default", "generated plan family")
do
  local ok, captured = capture(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      plan,
      "abc",
      "progressive-span-dispatch/lua-red.spec"
    )
  end)
  check_equal(ok, false, "generated-plan carrier rejects")
  check_equal(
    tostring(captured),
    "Generated Lua parser execution failed: RuntimeInterpreterException: " ..
      "unsupported runtime helper 'dispatch_span'",
    "generated-plan carrier boundary"
  )
end

local emitted_identity = "progressive-span-dispatch/lua-red-emitted.spec"
local emitted = linkedspec.emit_lua_source_v2(compiled, emitted_identity)
check_equal(count_literal(emitted, "dispatch_span"), 0, "emitted source omits generic spelling")
check_equal(
  count_literal(emitted, "progressive_dispatch_span"),
  0,
  "emitted source omits dedicated spelling"
)
check_equal(
  count_literal(emitted, "sha256:1111111111111111111111111111111111111111111111111111111111111111"),
  0,
  "emitted source omits registry fingerprint"
)
local loader = loadstring or load
local chunk, load_error = loader(emitted, "@progressive_span_dispatch_generated.lua")
check(chunk ~= nil, "emitted module loads: " .. tostring(load_error))
if chunk ~= nil then
  local generated_module = chunk()
  check_equal(
    generated_module.metadata().source_identity,
    emitted_identity,
    "emitted source identity"
  )
  local ok, captured = capture(function() return generated_module.execute("abc") end)
  check_equal(ok, false, "emitted carrier rejects")
  check_equal(
    tostring(captured),
    "Generated Lua parser execution failed: RuntimeInterpreterException: " ..
      "unsupported runtime helper 'dispatch_span'",
    "emitted carrier boundary"
  )
end

local dormant_path = "lua/test_dormant/progressive_span_dispatch_contract_test.lua"
local ordinary_path = "lua/test/progressive_span_dispatch_contract_test.lua"
check_equal(file_exists(dormant_path), true, "dormant consumer exists")
check_equal(file_exists(ordinary_path), false, "ordinary consumer remains absent")
check_equal(
  count_literal(read_file("tools/run_lua_local.sh"), "progressive_span_dispatch_contract_test.lua"),
  0,
  "ordinary discovery remains absent"
)
check_equal(
  count_literal(read_file("tools/run_ci_local.sh"), "progressive_span_dispatch_contract_test.lua"),
  0,
  "canonical discovery remains absent"
)
for _, path in ipairs(lua_guard.paths) do
  local source = read_file(path)
  check_equal(count_literal(source, "dispatch_span"), 0, path .. " generic token absent")
  check_equal(
    count_literal(source, "PROGRESSIVE_DISPATCH_SPAN"),
    0,
    path .. " dedicated token absent"
  )
end

-- This is the sole intentional RED boundary. Every assertion above records
-- current behavior; carrier owner .14.6.6.2 must replace the generic call with
-- one exclusive logical-only node and make this combined invariant GREEN.
check(
  #generic_calls == 0 and #progressive_nodes == 1,
  "Lua progressive RED: missing exclusive progressive_dispatch_span node"
)

if #failures == 0 then
  io.stdout:write(
    "Lua progressive span-dispatch contract: ", assertions,
    " assertions passed on ", linkedspec.runtime_implementation(), "\n"
  )
else
  io.stderr:write(
    "Lua progressive span-dispatch contract: ", #failures,
    " of ", assertions, " assertions failed on ",
    linkedspec.runtime_implementation(), "\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
