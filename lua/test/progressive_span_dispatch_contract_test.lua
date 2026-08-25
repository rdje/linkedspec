-- FUTURE-PARITY-BACKLOG.14.6.6.3 — admitted shared Lua progressive carriers.
--
-- Ordinary Lua discovery and canonical CI both run this exact Lua-5.1-
-- compatible final-path consumer on the two admitted hosts:
--
--   bash tools/run_lua_project_data.sh puc lua/test/progressive_span_dispatch_contract_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test/progressive_span_dispatch_contract_test.lua

local authority = require("linkedspec.bounded_child_parse_authority")
local json = require("linkedspec.json")
local linkedspec = require("linkedspec")

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
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
  local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
end

local function expect_failure_code(operation, code, label)
  local ok, captured = capture(operation)
  check_equal(ok, false, label .. " rejects")
  check(
    string.find(tostring(captured), code, 1, true) ~= nil,
    label .. " reports " .. code .. ": " .. tostring(captured)
  )
  return captured
end

local contract = json.decode(read_file(
  "capability_conformance/progressive_span_dispatch_contract.json"
))
local fingerprint = "sha256:" .. string.rep("1", 64)
local expected_value = json.harray({ kind = "identifier", text = "a" })
local authored_source = [[Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
]]

check_equal(contract.contract_id, "linkedspec-progressive-span-dispatch-v1", "neutral contract id")
check_equal(contract.format, 1, "neutral contract format")
check_equal(
  contract.status,
  "all_private_backends_complete_recurring_and_public_pending",
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
  lua_carrier_paths = 9,
  backend_guard_groups = 0,
  backend_guard_paths = 0,
  outward_guard_paths = 10,
  diagnostics = 26,
  rollout_legs = 9,
  mutations = 112,
}) do
  check_equal(contract.expected_counts[name], expected, "neutral count " .. name)
end
check_equal(#contract.rollout, 9, "neutral rollout row count")
for index = 1, 7 do
  check_equal(contract.rollout[index].status, "complete", "complete rollout " .. index)
end
for index = 8, 9 do
  check_equal(contract.rollout[index].status, "pending", "pending rollout " .. index)
end
check_equal(contract.rollout[6].owner, "FUTURE-PARITY-BACKLOG.14.6.6", "PUC Lua owner")
check_equal(contract.rollout[7].owner, "FUTURE-PARITY-BACKLOG.14.6.6", "LuaJIT owner")
local lua_carriers = contract.current_boundary.lua_carriers
check_equal(lua_carriers.canonical_discovery, "ordinary_and_exact_canonical_dual_abi", "Lua carrier discovery state")
check_equal(#lua_carriers.marker_rows, 9, "Lua carrier marker count")
check_equal(#contract.current_boundary.backend_guard_groups, 0, "Lua pending guard retired")

do
  local job = linkedspec.spec_ast.staged_parse_job({
    version = 1,
    job_id = "progressive-lua-carrier",
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
  local ok, captured = capture(function() return linkedspec.execute_staged_parse_job(job) end)
  check_equal(ok, false, "unrelated staged registry rejects expr-v1")
  check_equal(linkedspec.is_staged_parser_registry_error(captured), true, "staged rejection remains typed")
end

local parsed, compiled = compile_source(authored_source)
local compiled_json = linkedspec.compiled_spec_to_json(compiled)
local top = compiled_json.rules_by_label.Top
local generic_calls = {}
for _, object in ipairs(objects_with_kind(top, "call")) do
  if object.name == "dispatch_span" then generic_calls[#generic_calls + 1] = object end
end
local progressive_nodes = objects_with_kind(top, "progressive_dispatch_span")

check_equal(#generic_calls, 0, "generic dispatch_span call count")
check_equal(#progressive_nodes, 1, "dedicated progressive node count")
local progressive = progressive_nodes[1]
check_equal(progressive.target, "value", "progressive target")
check_equal(progressive.parser_id, "expr-v1", "progressive parser identity")
check_equal(progressive.top_rule, "Expr", "progressive top rule")
check_equal(progressive.span, "span", "progressive span binding")
local encoded_action = json.encode(top)
check_equal(count_literal(encoded_action, '"name":"dispatch_span"'), 0, "serialized generic call absent")
check_equal(count_literal(encoded_action, '"kind":"progressive_dispatch_span"'), 1, "serialized node exact")
check_equal(count_literal(encoded_action, fingerprint), 0, "compiled ActionIR omits fingerprint")
check_equal(count_literal(encoded_action, "ProgressiveExecutionSeed"), 0, "compiled ActionIR omits authority")
local payload = top.lifecycle_action_payloads[1]
check_equal(payload.contracts.ok, true, "dedicated node satisfies helper contract")
check_equal(#payload.contracts.diagnostics, 0, "dedicated node has no helper diagnostic")

local malformed = {
  {
    [[Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span(parser_id, "Expr", span) } /never/]],
    "progressive_parser_identity_literal_required",
  },
  {
    [[Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("Expr/V1", "Expr", span) } /never/]],
    "progressive_parser_identity_invalid",
  },
  {
    [[Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", top_rule, span) } /never/]],
    "progressive_top_rule_literal_required",
  },
  {
    [[Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Bad-Rule", span) } /never/]],
    "progressive_top_rule_invalid",
  },
  {
    [[Top:: I { value = dispatch_span("expr-v1", "Expr", hash("source_id", "input")) } /never/]],
    "progressive_span_binding_required",
  },
  {
    [[Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); return(cat(dispatch_span("expr-v1", "Expr", span))) } /never/]],
    "progressive_span_binding_required",
  },
  {
    [[Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Expr", span); return(value) } /never/]],
    "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
  },
  {
    [[fn dispatch_child() { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Expr", span); return(value) }
Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { return(dispatch_child()) } /never/]],
    "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
  },
}
for index, row in ipairs(malformed) do
  expect_failure_code(function() return compile_source(row[1]) end, row[2], "malformed form " .. index)
end

local child_result = json.harray({ kind = "identifier", text = "a" })
local callback_count = 0
local child_ceilings = authority.ceilings({
  source_detail = "text",
  policy_modes = json.array({ "deterministic", "fail-only" }),
  max_steps = 100,
  max_result_nodes = 100,
  max_diagnostic_bytes = 4096,
})
local registry = authority.registry({
  entries = json.array({
    authority.registry_entry({
      parser_id = "expr-v1",
      compiled_authority = function(request)
        callback_count = callback_count + 1
        check_equal(authority.request_parser_id(request), "expr-v1", "callback parser identity")
        check_equal(authority.request_top_rule(request), "Expr", "callback top rule")
        check_equal(authority.request_fingerprint(request), fingerprint, "callback fingerprint")
        local view = authority.request_source_view(request)
        check_equal(authority.view_text(view), "a", "bounded callback source view")
        check_equal(authority.local_to_global(view, 0), 0, "bounded callback start rebases")
        check_equal(authority.local_to_global(view, 1), 1, "bounded callback end rebases")
        return child_result
      end,
      fingerprint = fingerprint,
      allowed_top_rules = json.array({ "Expr" }),
      capabilities = json.array({
        "actionir-v1",
        "structured-result-v1",
        "typed-source-location-v1",
      }),
      ceilings = child_ceilings,
    }),
  }),
})

local function execution_seed(input)
  local sources = json.harray({ input = input })
  local token = authority.cancellation_token()
  local seed = authority.execution_seed({
    registry = registry,
    invocation = {
      sources = sources,
      source_id = "input",
      cancellation_token = token,
      now = function() return 1 end,
      deadline_tick = 100,
      remaining_steps = 100,
      max_depth = 8,
      total_calls = 0,
      max_calls = 16,
      active_chain = json.array(),
    },
    caller_capabilities = json.array({
      "actionir-v1",
      "structured-result-v1",
      "typed-source-location-v1",
    }),
    required_capabilities = json.array({ "structured-result-v1" }),
    caller_ceilings = child_ceilings,
    required_source_detail = "none",
    dispatch_cost = 1,
  })
  sources.input = "mutated-after-seed"
  return seed
end

local seed = execution_seed("abc")
check_equal(authority.node_type(seed), "ProgressiveExecutionSeed", "opaque execution seed type")
check_equal(tostring(seed), "ProgressiveExecutionSeed(<opaque>)", "opaque execution seed display")
check(
  authority.start_execution(seed, "abc") ~= authority.start_execution(seed, "abc"),
  "each execution starts fresh progressive authority"
)
expect_failure_code(
  function() return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "abc") end,
  "progressive_registry_missing",
  "missing native authority"
)

local live_source = [[Top::
 I {
  tx = recognition_checkpoint()
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  recognition_rollback(tx)
  return(value)
 }
 /never/
]]
local _, live_compiled = compile_source(live_source)
expect_failure_code(
  function()
    return linkedspec.runtime_parse(
      linkedspec.runtime_engine(live_compiled, {
        bounded_child_parse_authority = execution_seed("abc"),
      }),
      "abc"
    )
  end,
  "progressive_transaction_forbidden",
  "live recognition token defense"
)

-- All four routes use fresh authority and preserve the parent cursor.
local native_engine = linkedspec.runtime_engine(compiled, {
  bounded_child_parse_authority = execution_seed("abc"),
})
local native_result = linkedspec.runtime_parse(native_engine, "abc")
check_same_json(native_result.value, expected_value, "native carrier value")
check_equal(native_result.cursor_char_offset, 0, "native parent cursor unchanged")
native_result.value.text = "mutated-parent-result"
check_equal(child_result.text, "a", "native result detached from callback")
check_same_json(linkedspec.runtime_parse(native_engine, "abc").value, expected_value, "native engine starts fresh")

local normalized = json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
local normalized_text = json.encode(normalized)
for _, forbidden in ipairs({ fingerprint, "ProgressiveExecutionSeed", "ProgressiveRegistryEntry", "cancellation_token" }) do
  check_equal(count_literal(normalized_text, forbidden), 0, "normalized SpecFile omits " .. forbidden)
end
local reconstructed_spec = linkedspec.spec_ast.from_json("SpecFile", normalized)
linkedspec.validate_spec(reconstructed_spec)
check_same_json(linkedspec.spec_ast.to_json(reconstructed_spec), normalized, "normalized SpecFile reconstruction")
local reconstructed = linkedspec.compile_spec(reconstructed_spec)
local reconstructed_result = linkedspec.runtime_parse(
  linkedspec.runtime_engine(reconstructed, {
    bounded_child_parse_authority = execution_seed("abc"),
  }),
  "abc"
)
check_same_json(reconstructed_result.value, expected_value, "reconstructed carrier value")
check_equal(reconstructed_result.cursor_char_offset, 0, "reconstructed parent cursor unchanged")

local plan = linkedspec.build_generated_rule_plan(compiled)
check_equal(#plan, 1, "generated plan row count")
check_equal(plan[1].label, "Top", "generated plan label")
check_equal(plan[1].family, "default", "generated plan family")
local generated_value = linkedspec.execute_generated_parser_v2(
  compiled,
  plan,
  "abc",
  "progressive-span-dispatch/lua-carrier.spec",
  { bounded_child_parse_authority = execution_seed("abc") }
)
check_same_json(generated_value, expected_value, "generated-plan carrier value")

-- The emitted carrier is independently loaded emitted source, then receives
-- a live seed only at its execution boundary.
local emitted_identity = "progressive-span-dispatch/lua-carrier-emitted.spec"
local emitted = linkedspec.emit_lua_source_v2(compiled, emitted_identity)
check_equal(count_literal(emitted, fingerprint), 0, "emitted source omits fingerprint")
check_equal(count_literal(emitted, "ProgressiveExecutionSeed"), 0, "emitted source omits seed object")
check_equal(count_literal(emitted, "ProgressiveRegistryEntry"), 0, "emitted source omits registry object")
check_equal(count_literal(emitted, "cancellation_token"), 0, "emitted source omits cancellation authority")
check_equal(count_literal(emitted, "compiled_authority"), 0, "emitted source omits callback")
check_equal(count_literal(emitted, "abc"), 0, "emitted source omits decoded input snapshot")
local loader = loadstring or load
local chunk, load_error = loader(emitted, "@progressive_span_dispatch_generated.lua")
check(chunk ~= nil, "emitted module loads: " .. tostring(load_error))
if chunk ~= nil then
  local generated_module = chunk()
  check_equal(generated_module.metadata().source_identity, emitted_identity, "emitted source identity")
  local emitted_value = generated_module.execute("abc", {
    bounded_child_parse_authority = execution_seed("abc"),
  })
  check_same_json(emitted_value, expected_value, "emitted carrier value")
end

check(callback_count >= 5, "all successful routes invoked bounded callback")
check_equal(child_result.text, "a", "all carrier results remain detached")

local dormant_path = "lua/test_dormant/progressive_span_dispatch_contract_test.lua"
local ordinary_path = "lua/test/progressive_span_dispatch_contract_test.lua"
check(
  file_exists(ordinary_path) and not file_exists(dormant_path),
  "ordinary consumer exists without dormant duplicate"
)
local ordinary_driver = read_file("tools/run_lua_local.sh")
check(
  count_literal(ordinary_driver, ordinary_path) == 2 and
    count_literal(ordinary_driver, '"$LUA_CMD" ' .. ordinary_path) == 1 and
    count_literal(ordinary_driver, '"$LUAJIT_CMD" ' .. ordinary_path) == 1,
  "ordinary discovery runs the consumer exactly once per ABI"
)
local canonical_driver = read_file("tools/run_ci_local.sh")
check(
  count_literal(canonical_driver, "require_tracked_file " .. ordinary_path) == 1 and
    count_literal(canonical_driver, lua_carriers.puc_registration_marker) == 1 and
    count_literal(canonical_driver, lua_carriers.puc_invocation) == 1 and
    count_literal(canonical_driver, lua_carriers.luajit_registration_marker) == 1 and
    count_literal(canonical_driver, lua_carriers.luajit_invocation) == 1,
  "canonical discovery requires and runs one exact route per ABI"
)
check(
  contract.rollout[6].status == "complete" and
    contract.rollout[6].paths[1] == ordinary_path and #contract.rollout[6].paths == 1 and
    contract.rollout[7].status == "complete" and
    contract.rollout[7].paths[1] == ordinary_path and #contract.rollout[7].paths == 1,
  "both Lua rollout rows bind the one admitted consumer"
)
for _, row in ipairs(lua_carriers.marker_rows) do
  local source = read_file(row.path)
  for _, token in ipairs(row.tokens) do
    check(string.find(source, token, 1, true) ~= nil, row.path .. " contains " .. token)
  end
end
for _, path in ipairs(contract.current_boundary.outward_guard.paths) do
  local source = read_file(path)
  for _, token in ipairs(contract.current_boundary.outward_guard.forbidden_tokens) do
    check_equal(count_literal(source, token), 0, path .. " outward token " .. token .. " absent")
  end
end

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
