-- FUTURE-PARITY-BACKLOG.14.7.7.1 — private Lua staged marker/provenance carrier.
--
-- This exact final-path consumer is intentionally omitted from ordinary Lua
-- and canonical CI discovery. Its focused repository-local commands are:
--
--   bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua
--
-- Every marker/provenance/static-boundary assertion remains GREEN on both Lua
-- ABIs. The sole intentional RED is the final caller-frozen resolution/cache
-- boundary owned by FUTURE-PARITY-BACKLOG.14.7.7.2.

local json = require("linkedspec.json")
local linkedspec = require("linkedspec")
local action_parser = require("linkedspec.action_parser")
local source_location = require("linkedspec.source_location")
local staged_parse_job = require("linkedspec.staged_parse_job")

local CONTRACT_ID = "linkedspec-staged-ast-enrichment-v1"
local CONSUMER_PATH = "lua/test/staged_ast_enrichment_contract_test.lua"
local SOURCE_IDENTITY = "staged-ast-enrichment/lua-red.spec"
local EMITTED_IDENTITY = "staged-ast-enrichment/lua-red-emitted.spec"
local AUTHORED_SOURCE = [[Top::
 /([^;]+);/
 E {
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

local function expect_marker(result, expected_text, expected_provenance, label)
  local marker
  if type(result) == "table" and result.kind == "STAGED_PARSE_JOB_MARKER" then
    marker = result
  else
    local projected = linkedspec.interpreter.to_json(result)
    check_equal(projected.matched, true, label .. " matched")
    marker = projected.value or {}
  end
  check_equal(marker.kind, "STAGED_PARSE_JOB_MARKER", label .. " marker kind")
  check_equal(marker.version, 2, label .. " marker version")
  check_equal(marker.sidecar_kind, "staged_parse_job_v2", label .. " sidecar kind")
  check_equal(marker.effect, "staged_parse_job_declaration", label .. " marker effect")
  local sidecar = marker.staged_parse_job_v2 or {}
  for field, expected in pairs({
    kind = "staged_parse_job_v2",
    version = 2,
    state = "declared",
    effect = "staged_parse_job_declaration",
    node_kind = "expression",
    payload_kind = "embedded_expression",
    parser_spec_id = "expr-v1",
    top_rule = "Expr",
    result_policy = "sibling_field",
    into = "expression_ast",
    failure_policy = "fail",
    origin = "Top:parse_job",
    text = expected_text,
  }) do
    check_equal(sidecar[field], expected, label .. " sidecar " .. field)
  end
  check_equal(json.kind(sidecar.required_capabilities), "array", label .. " capability array")
  check_equal(#(sidecar.required_capabilities or {}), 0, label .. " capability count")
  check_same_json(sidecar.provenance, expected_provenance, label .. " typed provenance")
  local encoded = json.encode(marker)
  for _, forbidden in ipairs({ "capture_spans", "byte_start", "byte_end", "authority" }) do
    check_equal(count_literal(encoded, forbidden), 0, label .. " detached token " .. forbidden)
  end
  return marker
end

local function expect_staged_parse_error(source, code, label)
  local ok, failure = capture(function() return action_parser.parse_action_expression(source) end)
  check_equal(ok, false, label .. " rejects")
  check_contains(
    failure,
    "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:" .. code,
    label .. " diagnostic"
  )
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

check_equal(#generic_calls, 0, "generic parse_job call count")
check_equal(#marker_nodes, 1, "dedicated staged marker exact")
local logical_marker = marker_nodes[1] or {}
check_equal(logical_marker.target, "job_marker", "logical marker target")
check_equal(logical_marker.version, 2, "logical marker version")
check_equal(logical_marker.sidecar_kind, "staged_parse_job_v2", "logical marker sidecar kind")
check_equal(logical_marker.effect, "staged_parse_job_declaration", "logical marker effect")
check_same_json(logical_marker.text_plan, json.harray({
  kind = "direct_span",
  source = "entry_group",
  index = 0,
}), "logical direct provenance plan")
check_same_json(logical_marker.options, json.harray({
  node_kind = "expression",
  payload_kind = "embedded_expression",
  spec = "expr-v1",
  top = "Expr",
  result_policy = "sibling_field",
  into = "expression_ast",
  on_error = "fail",
  required_capabilities = json.array(),
}), "logical normalized options")
local encoded_action = json.encode(top)
check_equal(count_literal(encoded_action, '"name":"parse_job"'), 0, "serialized generic call absent")
check_equal(count_literal(encoded_action, "STAGED_PARSE_JOB_MARKER"), 0, "serialized neutral marker absent")
check_equal(count_literal(encoded_action, "staged_parse_job_v2"), 1, "serialized logical sidecar exact")
local payload = top.lifecycle_action_payloads[1]
check_equal(payload.contracts.ok, true, "dedicated marker contract known")
check_equal(#payload.contracts.diagnostics, 0, "dedicated marker diagnostic count")

local direct_provenance = json.harray({
  kind = "direct_span",
  source_id = "input",
  start = 0,
  ["end"] = 3,
  provenance = "entry_group",
})
local native_result = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "1+2;")
expect_marker(native_result, "1+2", direct_provenance, "native carrier")

for _, row in ipairs({
  { "entry_text()", "1+2;", 4, "entry_text" },
  { "match_text()", "1+2;", 4, "match_text" },
  { "match_group(0)", "1+2", 3, "match_group" },
}) do
  local source = AUTHORED_SOURCE:gsub("entry_group%(0%)", row[1], 1)
  local _, direct_compiled = compile_source(source)
  expect_marker(
    linkedspec.runtime_parse(linkedspec.runtime_engine(direct_compiled), "1+2;"),
    row[2],
    json.harray({
      kind = "direct_span",
      source_id = "input",
      start = 0,
      ["end"] = row[3],
      provenance = row[4],
    }),
    "direct " .. row[4] .. " carrier"
  )
end

local capability_expr = action_parser.parse_action_expression(
  'job = parse_job(entry_text(), hash("node_kind", "expression", ' ..
    '"payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", ' ..
    '"result_policy", "replace_marker", "on_error", "fail", ' ..
    '"required_capabilities", array("z-cap", "a-cap")))'
)
check_equal(capability_expr.kind, "staged_parse_job_marker", "capability marker kind")
check_string_list(
  capability_expr.options.required_capabilities,
  { "a-cap", "z-cap" },
  "required capabilities normalize"
)

local normalized = json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
local reconstructed_spec = linkedspec.spec_ast.from_json("SpecFile", normalized)
linkedspec.validate_spec(reconstructed_spec)
check_same_json(linkedspec.spec_ast.to_json(reconstructed_spec), normalized, "normalized SpecFile reconstruction")
local reconstructed = linkedspec.compile_spec(reconstructed_spec)
expect_marker(
  linkedspec.runtime_parse(linkedspec.runtime_engine(reconstructed), "1+2;"),
  "1+2",
  direct_provenance,
  "reconstructed carrier"
)

local plan = linkedspec.build_generated_rule_plan(compiled)
check_equal(#plan, 1, "generated plan row count")
check_equal(plan[1].label, "Top", "generated plan label")
check_equal(plan[1].family, "default", "generated plan family")
expect_marker(
  linkedspec.execute_generated_parser_v2(
    compiled,
    plan,
    "1+2;",
    SOURCE_IDENTITY
  ),
  "1+2",
  direct_provenance,
  "generated-plan carrier"
)

local emitted = linkedspec.emit_lua_source_v2(compiled, EMITTED_IDENTITY)
local loader = loadstring or load
local chunk, load_error = loader(emitted, "@staged_ast_enrichment_generated.lua")
check(chunk ~= nil, "emitted module loads: " .. tostring(load_error))
if chunk ~= nil then
  local generated_module = chunk()
  check_equal(generated_module.metadata().source_identity, EMITTED_IDENTITY, "emitted source identity")
  expect_marker(generated_module.execute("1+2;"), "1+2", direct_provenance, "emitted carrier")
end
check_equal(count_literal(emitted, "STAGED_PARSE_JOB_MARKER"), 0, "emitted runtime marker remains constructed")
check_equal(count_literal(emitted, "staged_parse_job_v2"), 0, "emitted logical sidecar stays hex-opaque")
check_equal(count_literal(emitted, CONTRACT_ID), 0, "emitted staged contract id absent")

local authority_sources = json.harray()
for _, source in ipairs(contract.sources) do authority_sources[source.source_id] = source.text end
local authority = source_location.source_authority({ sources = authority_sources })
for _, row in ipairs(contract.provenance_cases) do
  local ok, value = capture(function()
    return staged_parse_job.validate_and_materialize_provenance(
      authority,
      row.provenance,
      "neutral:" .. row.id
    )
  end)
  check_equal(ok, row.accepted, "neutral provenance " .. row.id .. " acceptance")
  if ok then
    check_equal(value.text, row.materialized_text, "neutral provenance " .. row.id .. " text")
    check_same_json(value.provenance, row.provenance, "neutral provenance " .. row.id .. " record")
  else
    check_equal(staged_parse_job.is_error(value), true, "neutral provenance " .. row.id .. " typed error")
    local projected = staged_parse_job.is_error(value) and staged_parse_job.to_json(value) or {}
    check_equal(projected.code, row.diagnostic, "neutral provenance " .. row.id .. " diagnostic")
  end
end

local alternation = linkedspec.compile_runtime_regex_alternation({ "(a)(a)(é)(🙂)" })
local raw_match = linkedspec.runtime_match(alternation, "aaé🙂", 0, "consume")
local public_match = linkedspec.matching.to_json(raw_match)
check_equal(raw_match.capture_spans, nil, "private capture spans absent from match object")
check_equal(
  linkedspec.matching.staged_capture_byte_span,
  nil,
  "private capture span accessor absent from outward matching module"
)
check_equal(count_literal(json.encode(public_match), "capture_spans"), 0, "private capture spans absent from JSON")
local derived_source = [[Top::
 /(a)(a)(é)(🙂);/
 E {
  job_marker = parse_job(cat(entry_group(0), cat(entry_group(1), entry_group(2), entry_group(3))), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
]]
local _, derived_compiled = compile_source(derived_source)
local derived_segments = json.array({
  json.harray({ kind = "direct_span", source_id = "input", start = 0, ["end"] = 1, provenance = "entry_group" }),
  json.harray({ kind = "direct_span", source_id = "input", start = 1, ["end"] = 2, provenance = "entry_group" }),
  json.harray({ kind = "direct_span", source_id = "input", start = 2, ["end"] = 3, provenance = "entry_group" }),
  json.harray({ kind = "direct_span", source_id = "input", start = 3, ["end"] = 4, provenance = "entry_group" }),
})
expect_marker(
  linkedspec.runtime_parse(linkedspec.runtime_engine(derived_compiled), "aaé🙂;"),
  "aaé🙂",
  json.harray({ kind = "derived_text", policy = "concatenate_in_order", segments = derived_segments }),
  "derived repeated/Unicode carrier"
)

local options_text = 'hash("node_kind", "expression", "payload_kind", "embedded_expression", ' ..
  '"spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", ' ..
  '"into", "expression_ast", "on_error", "fail")'
for _, row in ipairs({
  { "job = parse_job(entry_text())", "staged_parse_job_options_required", "missing options" },
  { "job = parse_job(entry_text(), options)", "staged_parse_job_options_required", "dynamic options" },
  { "job = parse_job(entry_text(), hash(\"node_kind\", \"expression\", \"node_kind\", \"expression\"))", "staged_parse_job_options_required", "duplicate option" },
  { "job = parse_job(entry_text(), hash(\"unknown\", \"value\"))", "staged_parse_job_option_unknown", "unknown option" },
  { "job = parse_job(entry_text(), " .. options_text:gsub('%)$', ', \"required_capabilities\", array(\"same\", \"same\"))') .. ")", "staged_parse_job_options_required", "duplicate capability" },
  { "job = parse_job(entry_text(), " .. options_text:gsub('expr%-v1', '-bad') .. ")", "staged_parser_identity_invalid", "invalid parser" },
  { "job = parse_job(entry_text(), " .. options_text:gsub('Expr', 'Bad-Rule') .. ")", "staged_top_rule_invalid", "invalid top" },
  { "job = parse_job(entry_text(), " .. options_text:gsub('sibling_field', 'bad_policy') .. ")", "staged_result_policy_invalid", "invalid result policy" },
  { "job = parse_job(entry_text(), " .. options_text:gsub('on_error\", \"fail', 'on_error\", \"bad') .. ")", "staged_failure_policy_invalid", "invalid failure policy" },
  { "job = parse_job(entry_text(), " .. options_text:gsub('expression_ast', 'bad-target') .. ")", "staged_result_target_invalid", "invalid target" },
  { "job = parse_job(\"copied\", " .. options_text .. ")", "staged_source_provenance_invalid", "copied text" },
  { "job = parse_job(trim(entry_text()), " .. options_text .. ")", "staged_source_provenance_invalid", "transformed text" },
  { "job = parse_job(entry_group(index), " .. options_text .. ")", "staged_source_provenance_invalid", "dynamic capture index" },
  { "job = parse_job(cat(), " .. options_text .. ")", "staged_source_provenance_invalid", "empty derived text" },
}) do
  expect_staged_parse_error(row[1], row[2], row[3])
end
for index, source in ipairs({
  "parse_job(entry_text(), " .. options_text .. ")",
  "return(parse_job(entry_text(), " .. options_text .. "))",
  "value.parse_job(entry_text(), " .. options_text .. ")",
  "jobs += parse_job(entry_text(), " .. options_text .. ")",
  "jobs[0] = parse_job(entry_text(), " .. options_text .. ")",
}) do
  expect_staged_parse_error(source, "staged_parse_job_options_required", "residual parse_job form " .. index)
end

local _, forged_compiled = compile_source([[Top:: I { return(1) } /never/]])
local forged_call = action_parser.parse_action_expression("future_helper()")
forged_call.name = "parse_job"
forged_compiled.rules_by_label.Top.lifecycle_action_payloads[1].action_ast.statements[1].expr = forged_call
local forged_ok, forged_error = capture(function() return linkedspec.runtime_engine(forged_compiled) end)
check_equal(forged_ok, false, "runtime reconstructed residual call rejects")
check_contains(
  forged_error,
  "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:staged_parse_job_options_required",
  "runtime reconstructed residual diagnostic"
)

local recognition_source = [[Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { job = parse_job(entry_text(), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail")); return(job) } /never/]]
local recognition_ok, recognition_error = capture(function() return compile_source(recognition_source) end)
check_equal(recognition_ok, false, "recognition-reachable declaration rejects")
check_contains(
  recognition_error,
  "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
  "recognition-reachable declaration diagnostic"
)
local recognition_function_source = [[fn staged_child() { job = parse_job(entry_text(), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail")); return(job) }
Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { return(staged_child()) } /never/]]
local function_ok, function_error = capture(function() return compile_source(recognition_function_source) end)
check_equal(function_ok, false, "transitive function declaration rejects")
check_contains(
  function_error,
  "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
  "transitive function declaration diagnostic"
)

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

-- Intentional RED: owner .14.7.7.2 must add caller-frozen resolution/cache and
-- result/failure-policy execution without changing the marker/provenance seam.
check(
  type(staged_parse_job.enrich_current_depth) == "function",
  "LINKEDSPEC_STAGED_AST_ENRICHMENT_LUA_RED: missing caller-frozen resolution cache and result failure policies"
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
