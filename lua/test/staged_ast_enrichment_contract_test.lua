-- FUTURE-PARITY-BACKLOG.14.7.7.0 — dormant shared Lua staged-AST enrichment RED.
--
-- This exact final-path consumer is intentionally omitted from ordinary Lua
-- and canonical CI discovery. Its focused repository-local commands are:
--
--   bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua
--
-- Every pre-boundary assertion must remain GREEN on both Lua ABIs. The sole
-- intentional RED is the final missing dedicated `STAGED_PARSE_JOB_MARKER`
-- plus typed `staged_parse_job_v2` provenance assertion. The current generic
-- `parse_job(...)` call and unsupported-helper rejection are not an
-- implementation.

local json = require("linkedspec.json")
local linkedspec = require("linkedspec")

local CONTRACT_ID = "linkedspec-staged-ast-enrichment-v1"
local CONSUMER_PATH = "lua/test/staged_ast_enrichment_contract_test.lua"
local SOURCE_IDENTITY = "staged-ast-enrichment/lua-red.spec"
local EMITTED_IDENTITY = "staged-ast-enrichment/lua-red-emitted.spec"
local AUTHORED_SOURCE = [[Top::
 /([^;]+);/
 I {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
]]

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function check_contains(actual, expected, label)
  check(
    string.find(tostring(actual), expected, 1, true) ~= nil,
    label .. ": expected to contain " .. expected .. ", got " .. tostring(actual)
  )
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function check_string_list(actual, expected, label)
  check_equal(table.concat(actual, "\n"), table.concat(expected, "\n"), label)
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

local function case_ids(contract, field)
  local result = {}
  for index, row in ipairs(contract[field]) do result[index] = row.id end
  return result
end

local function compile_source(source)
  local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
end

local function v1_job(top_rule)
  local body_source = "return(trim(value))"
  return linkedspec.spec_ast.staged_parse_job({
    version = 1,
    job_id = "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-29",
    parent_ast_path = json.array({ "functions", "0", "body_source" }),
    node_kind = "function_definition",
    payload_kind = "function_body",
    function_name = "normalize",
    params = json.array({ "value" }),
    arity = 1,
    text = body_source,
    source_span = linkedspec.spec_ast.staged_source_span({
      start = 10,
      ["end"] = 29,
      line_start = 1,
      line_end = 1,
    }),
    parser_spec_id = "actionir-body.spec",
    top_rule = top_rule or "action_block",
    result_policy = "replace_field",
    result_field = "body_ast",
    failure_policy = "fail",
    diagnostic_owner = "function_body",
  })
end

local function expect_native_failure(ok, failure, label)
  check_equal(ok, false, label .. " rejects")
  local typed = not ok and linkedspec.is_runtime_interpreter_error(failure)
  check_equal(typed, true, label .. " remains a typed runtime failure")
  local fields = typed and failure or {}
  check_equal(fields.message, "unsupported runtime helper 'parse_job'", label .. " detail")
  check_equal(fields.helper_name, "parse_job", label .. " helper identity")
  local diagnostic = fields.diagnostic
  check_equal(linkedspec.is_runtime_diagnostic(diagnostic), true, label .. " diagnostic type")
  local projected = diagnostic and linkedspec.interpreter.to_json(diagnostic) or {}
  check_equal(projected.stage, "runtime_execution", label .. " diagnostic stage")
  check_equal(projected.rule_label, "Top", label .. " diagnostic rule")
  check_equal(projected.detail, "unsupported runtime helper 'parse_job'", label .. " diagnostic detail")
end

local function expect_generated_failure(ok, failure, identity, label)
  check_equal(ok, false, label .. " rejects")
  local typed = not ok and linkedspec.is_generated_source_error(failure)
  check_equal(typed, true, label .. " remains a typed generated failure")
  local fields = typed and failure or {}
  check_equal(fields.stage, "execute_generated", label .. " stage")
  check_equal(fields.code, "generated_execution_failed", label .. " code")
  check_equal(fields.source_identity, identity, label .. " source identity")
  check_equal(fields.rule_label, "Top", label .. " rule label")
  check_equal(fields.handler_family, "default", label .. " handler family")
  check_contains(fields.detail or "", "unsupported runtime helper 'parse_job'", label .. " detail")
end

local contract = json.decode(read_file(
  "capability_conformance/staged_ast_enrichment_contract.json"
))

check_equal(contract.contract_id, CONTRACT_ID, "neutral contract id")
check_equal(contract.format, 1, "neutral contract format")
check_equal(
  contract.status,
  "neutral_perl_rust_dart_and_julia_complete_lua_dormant_red",
  "neutral lifecycle status"
)

for name, expected in pairs({
  registry_entries = 4,
  sources = 2,
  provenance_cases = 8,
  job_id_cases = 3,
  resolution_cases = 8,
  authority_cases = 6,
  cache_cases = 10,
  queue_cases = 4,
  isolation_cases = 3,
  stitch_cases = 4,
  failure_cases = 3,
  chain_cases = 10,
  detachment_cases = 5,
  carrier_requirements = 4,
  backend_consumers = 5,
  runtime_routes = 6,
  outward_guard_paths = 10,
  diagnostics = 37,
  rollout_legs = 9,
  ownership_rows = 35,
  mutations = 98,
}) do
  check_equal(contract.expected_counts[name], expected, "neutral count " .. name)
end

local expected_ids = {
  provenance_cases = {
    "direct_unicode",
    "direct_empty",
    "derived_ordered",
    "direct_reversed",
    "direct_out_of_bounds",
    "derived_empty",
    "derived_segment_invalid",
    "copied_text_smuggling",
  },
  job_id_cases = {
    "direct_identity",
    "derived_identity",
    "default_top_normalized_before_identity",
  },
  resolution_cases = {
    "alias_first",
    "declaring_relative_second",
    "search_root_order",
    "provider_order",
    "missing",
    "same_priority_ambiguous",
    "alias_relative_collision",
    "path_traversal_rejected",
  },
  authority_cases = {
    "intersection_and_minima",
    "entry_cannot_elevate_caller",
    "required_capability_missing",
    "policy_denied",
    "source_detail_denied",
    "helper_version_mismatch",
  },
  cache_cases = {
    "base",
    "identical",
    "content_changed",
    "graph_changed",
    "top_changed",
    "spec_version_changed",
    "helper_version_changed",
    "staged_version_changed",
    "capability_order_normalized",
    "capability_set_changed",
  },
  queue_cases = {
    "parent_then_provenance",
    "job_id_tie_break",
    "derived_order_key",
    "breadth_first_recursive_enqueue",
  },
  isolation_cases = {
    "siblings_receive_fresh_runtime_contexts",
    "falsey_child_state_does_not_escape",
    "shared_budget_spans_next_depth",
  },
  stitch_cases = {
    "replace_marker",
    "replace_field",
    "sibling_field",
    "append_child",
  },
  failure_cases = {
    "fail_aborts_composed_parse",
    "keep_text_continues",
    "diagnostic_node_uses_result_target",
  },
  chain_cases = {
    "direct_strictly_smaller",
    "derived_strictly_smaller",
    "exact_tuple_cycle",
    "same_extent_non_decreasing",
    "derived_not_contained",
    "depth_exceeded",
    "call_limit_exceeded",
    "cancelled",
    "deadline_exceeded",
    "budget_exhausted",
  },
  detachment_cases = {
    "plain_nested",
    "falsey_scalar",
    "live_parser_handle",
    "reference_cycle_marker",
    "node_limit",
  },
}
for field, expected in pairs(expected_ids) do
  check_string_list(case_ids(contract, field), expected, "neutral " .. field .. " ids")
end

for index, expected in ipairs({
  "complete",
  "complete",
  "complete",
  "complete",
  "dormant_red",
}) do
  check_equal(contract.backend_consumers[index].status, expected, "consumer lifecycle " .. index)
end
local lua_consumer = contract.backend_consumers[5]
check_equal(lua_consumer.backend, "lua", "Lua consumer backend")
check_equal(lua_consumer.owner, "FUTURE-PARITY-BACKLOG.14.7.7.0", "Lua consumer owner")
check_equal(lua_consumer.path, CONSUMER_PATH, "Lua consumer stable path")
check_equal(lua_consumer.status, "dormant_red", "Lua consumer dormant status")
check_equal(#contract.rollout, 9, "rollout row count")
for index = 1, 5 do
  check_equal(contract.rollout[index].status, "complete", "complete rollout " .. index)
end
for index = 6, 9 do
  check_equal(contract.rollout[index].status, "pending", "pending rollout " .. index)
end
check_equal(contract.rollout[6].owner, "FUTURE-PARITY-BACKLOG.14.7.7", "PUC Lua rollout owner")
check_equal(contract.rollout[7].owner, "FUTURE-PARITY-BACKLOG.14.7.7", "LuaJIT rollout owner")
check_equal(
  contract.authored_surface.availability,
  "neutral executable authority with private Perl, Rust, Dart, and Julia carriers complete; " ..
    "the shared PUC Lua and LuaJIT general carrier contract is dormant RED; recurring and " ..
    "public authoring remain pending under FUTURE-PARITY-BACKLOG.14.7.7-.10",
  "authored availability"
)

local compatibility = contract.compatibility_v1
for field, expected in pairs({
  status = "current_unchanged",
  record_version = 1,
  parser_spec_id = "actionir-body.spec",
  resolved_spec_id = "builtin:actionir-body.spec",
  top_rule = "action_block",
  result_policy = "replace_field",
  result_field = "body_ast",
  failure_policy = "fail",
  source_provenance = "legacy copied exact text plus numeric offset and line span",
  general_authoring = false,
  upgrade_to_v2 = "explicit_only",
}) do
  check_equal(compatibility[field], expected, "function-body v1 " .. field)
end

local v1_result = linkedspec.staged_parser_registry_to_json(
  linkedspec.execute_staged_parse_jobs({ v1_job() })[1]
)
check_string_list(v1_result.phases, { "resolve", "load", "compile", "execute" }, "v1 phases")
check_equal(v1_result.resolved_spec_id, "builtin:actionir-body.spec", "v1 resolved identity")
check_equal(v1_result.registry_provider, "builtin", "v1 registry provider")
check_equal(v1_result.compiled_parser.top_rule, "action_block", "v1 compiled top rule")
check_equal(v1_result.cache_key.content_digest, linkedspec.ACTION_IR_BODY_ADAPTER_DIGEST, "v1 cache digest")
check_equal(v1_result.result_policy, "replace_field", "v1 result policy")
check_equal(v1_result.result_field, "body_ast", "v1 result field")
check_equal(v1_result.failure_policy, "fail", "v1 failure policy")
check_equal(v1_result.result.kind, "action_block", "v1 result kind")

local wrong_top_ok, wrong_top = capture(function()
  return linkedspec.execute_staged_parse_job(v1_job("missing_top"))
end)
check_equal(wrong_top_ok, false, "wrong-top v1 rejects")
check_equal(linkedspec.is_staged_parser_registry_error(wrong_top), true, "wrong-top v1 typed error")
for _, context in ipairs({
  "phase=compile",
  "parent_ast_path=functions.0.body_source",
  "parser_spec_id=actionir-body.spec",
  "resolved_spec_id=builtin:actionir-body.spec",
  "top_rule=missing_top",
  "payload_kind=function_body",
  "source_span=10-29",
  "failure_policy=fail",
}) do
  check_contains(wrong_top.message or "", context, "wrong-top v1 context")
end

local general_job = linkedspec.spec_ast.staged_parse_job({
  version = 2,
  job_id = "parse_job:v2:sha256:dormant-red",
  parent_ast_path = json.array({ "Top", "job_marker" }),
  node_kind = "expression",
  payload_kind = "embedded_expression",
  text = "1+2",
  source_span = linkedspec.spec_ast.staged_source_span({
    start = 0,
    ["end"] = 3,
    line_start = 1,
    line_end = 1,
  }),
  parser_spec_id = "expr-v1",
  top_rule = "Expr",
  result_policy = "sibling_field",
  result_field = "expression_ast",
  failure_policy = "fail",
})
local general_ok, general_error = capture(function()
  return linkedspec.execute_staged_parse_job(general_job)
end)
check_equal(general_ok, false, "general-v2 registry rejects")
check_equal(linkedspec.is_staged_parser_registry_error(general_error), true, "general-v2 registry typed error")
check_contains(general_error.message or "", "phase=resolve", "general-v2 resolve phase")
check_contains(general_error.message or "", "parser_spec_id=expr-v1", "general-v2 parser identity")
check_contains(
  general_error.message or "",
  "unsupported parser spec id 'expr-v1'",
  "general-v2 narrow-registry detail"
)

local parsed, compiled = compile_source(AUTHORED_SOURCE)
local compiled_json = linkedspec.compiled_spec_to_json(compiled)
local top = compiled_json.rules_by_label.Top
local generic_calls = {}
for _, object in ipairs(objects_with_kind(top, "call")) do
  if object.name == "parse_job" then generic_calls[#generic_calls + 1] = object end
end
local marker_nodes = objects_with_kind(top, "staged_parse_job_marker")

check_equal(#generic_calls, 1, "generic parse_job call count")
local generic_call = generic_calls[1] or {}
check_equal(#(generic_call.args or {}), 2, "generic parse_job argument count")
local first_argument = generic_call.args and generic_call.args[1] or {}
local second_argument = generic_call.args and generic_call.args[2] or {}
check_equal(first_argument.kind, "call", "generic text expression kind")
check_equal(first_argument.name, "entry_group", "generic text helper")
check_equal(second_argument.kind, "call", "generic options expression kind")
check_equal(second_argument.name, "hash", "generic options helper")
check_equal(#marker_nodes, 0, "dedicated staged marker absent")
local encoded_action = json.encode(top)
check_equal(count_literal(encoded_action, '"name":"parse_job"'), 1, "serialized generic call exact")
check_equal(count_literal(encoded_action, "STAGED_PARSE_JOB_MARKER"), 0, "serialized neutral marker absent")
check_equal(count_literal(encoded_action, "staged_parse_job_v2"), 0, "serialized typed sidecar absent")
local payload = top.lifecycle_action_payloads[1]
check_equal(payload.contracts.ok, false, "generic parse_job remains contract-unknown")
check_equal(#payload.contracts.diagnostics, 1, "generic parse_job diagnostic count")
check_equal(payload.contracts.diagnostics[1].code, "unknown_helper", "generic parse_job diagnostic code")

local native_ok, native_failure = capture(function()
  return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "1+2;")
end)
expect_native_failure(native_ok, native_failure, "native carrier")

local normalized = json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
local reconstructed_spec = linkedspec.spec_ast.from_json("SpecFile", normalized)
linkedspec.validate_spec(reconstructed_spec)
check_same_json(linkedspec.spec_ast.to_json(reconstructed_spec), normalized, "normalized SpecFile reconstruction")
local reconstructed = linkedspec.compile_spec(reconstructed_spec)
local reconstructed_ok, reconstructed_failure = capture(function()
  return linkedspec.runtime_parse(linkedspec.runtime_engine(reconstructed), "1+2;")
end)
expect_native_failure(reconstructed_ok, reconstructed_failure, "reconstructed carrier")

local plan = linkedspec.build_generated_rule_plan(compiled)
check_equal(#plan, 1, "generated plan row count")
check_equal(plan[1].label, "Top", "generated plan label")
check_equal(plan[1].family, "default", "generated plan family")
local generated_ok, generated_failure = capture(function()
  return linkedspec.execute_generated_parser_v2(
    compiled,
    plan,
    "1+2;",
    SOURCE_IDENTITY
  )
end)
expect_generated_failure(generated_ok, generated_failure, SOURCE_IDENTITY, "generated-plan carrier")

local emitted = linkedspec.emit_lua_source_v2(compiled, EMITTED_IDENTITY)
local loader = loadstring or load
local chunk, load_error = loader(emitted, "@staged_ast_enrichment_generated.lua")
check(chunk ~= nil, "emitted module loads: " .. tostring(load_error))
if chunk ~= nil then
  local generated_module = chunk()
  check_equal(generated_module.metadata().source_identity, EMITTED_IDENTITY, "emitted source identity")
  local emitted_ok, emitted_failure = capture(function()
    return generated_module.execute("1+2;")
  end)
  expect_generated_failure(emitted_ok, emitted_failure, EMITTED_IDENTITY, "emitted carrier")
end
check_equal(count_literal(emitted, "STAGED_PARSE_JOB_MARKER"), 0, "emitted neutral marker absent")
check_equal(count_literal(emitted, "staged_parse_job_v2"), 0, "emitted typed sidecar absent")
check_equal(count_literal(emitted, CONTRACT_ID), 0, "emitted staged contract id absent")

check(file_exists(CONSUMER_PATH), "stable final-path consumer exists")
local ordinary = read_file("tools/run_lua_local.sh")
local inline_ordinary = read_file("lua/test/run.lua")
local canonical = read_file("tools/run_ci_local.sh")
check_equal(count_literal(ordinary, CONSUMER_PATH), 0, "consumer absent from ordinary Lua driver")
check_equal(count_literal(inline_ordinary, "staged_ast_enrichment_contract_test.lua"), 0, "consumer absent from inline suite")
check_equal(count_literal(canonical, CONSUMER_PATH), 0, "consumer absent from canonical CI")
local umbrella = read_file("lua/src/linkedspec/init.lua")
for _, private_token in ipairs({
  "parse_job(text_expr",
  "STAGED_PARSE_JOB_MARKER",
  CONTRACT_ID,
}) do
  check_equal(count_literal(umbrella, private_token), 0, "outward token absent: " .. private_token)
end

-- Intentional RED: owner .14.7.7.1 must replace only the reserved generic
-- assignment with one dedicated logical marker and typed provenance sidecar.
check(
  #generic_calls == 0 and #marker_nodes == 1,
  "LINKEDSPEC_STAGED_AST_ENRICHMENT_LUA_RED: missing dedicated marker and typed provenance"
)

if #failures == 0 then
  io.stdout:write(
    "Lua staged-AST enrichment contract: ", assertions,
    " assertions passed on ", linkedspec.runtime_implementation(), "\n"
  )
else
  io.stderr:write(
    "Lua staged-AST enrichment contract: ", #failures,
    " of ", assertions, " assertions failed on ",
    linkedspec.runtime_implementation(), "\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
