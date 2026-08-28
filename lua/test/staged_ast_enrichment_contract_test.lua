-- FUTURE-PARITY-BACKLOG.14.7.7.4 — admitted shared Lua staged-AST carrier.
--
-- Ordinary Lua discovery and canonical CI run this exact Lua-5.1-compatible
-- final-path consumer once on each admitted host:
--
--   bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua
--
local json = require("linkedspec.json")
local linkedspec = require("linkedspec")
local action_parser = require("linkedspec.action_parser")
local source_location = require("linkedspec.source_location")
local staged_ast_enrichment = require("linkedspec.staged_ast_enrichment")
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
local PRODUCTION_SOURCE = [[Top::
 /([^;]+);/
 E {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail", "required_capabilities", array("typed-source-location-v1")))
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

local function enrichment_error_code(value)
  if not staged_ast_enrichment.is_error(value) then return nil end
  return staged_ast_enrichment.diagnostic_code(value)
end

local function enrichment_diagnostic_is_complete(value)
  local code = enrichment_error_code(value)
  if code == nil then return false end
  local required
  for _, row in ipairs(contract.diagnostics) do
    if row.code == code then required = row.required_context break end
  end
  if required == nil then return false end
  local record = staged_ast_enrichment.to_json(value)
  for _, field in ipairs(required) do
    if record[field] == nil then return false end
  end
  return true
end

local function enrichment_options()
  return json.harray({
    declaring_spec_id = "grammar/main.spec",
    caller_capabilities = json.array({
      "staged-parse-job-v2",
      "structured-result-v1",
      "typed-source-location-v1",
      "xml-v1",
      "yaml-v1",
    }),
    caller_policy_modes = json.array({
      "append_child",
      "diagnostic_node",
      "fail",
      "keep_text",
      "replace_field",
      "replace_marker",
      "sibling_field",
      "trace",
    }),
    caller_ceilings = json.harray({
      source_detail = "text",
      max_steps = 200,
      max_result_nodes = 128,
      max_diagnostic_bytes = 8192,
    }),
    required_source_detail = "identity",
    required_versions = json.harray({
      spec_language_version = 2,
      helper_contract_version = "actionir-v3",
      staged_contract_version = 2,
    }),
  })
end

local function enrichment_marker(text, start_offset, result_policy, into, failure_policy, top_rule)
  local sidecar = json.harray({
    kind = "staged_parse_job_v2",
    version = 2,
    state = "declared",
    effect = "staged_parse_job_declaration",
    node_kind = "expression",
    payload_kind = "embedded_expression",
    parser_spec_id = "expr",
    result_policy = result_policy,
    failure_policy = failure_policy,
    required_capabilities = json.array({ "typed-source-location-v1" }),
    text = text,
    provenance = json.harray({
      kind = "direct_span",
      source_id = "ascii",
      start = start_offset,
      ["end"] = start_offset + #text,
      provenance = "capture",
    }),
    origin = "contract:parse_job",
  })
  if top_rule ~= false then sidecar.top_rule = top_rule or "Expr" end
  if into ~= nil and into ~= json.null then sidecar.into = into end
  return json.harray({
    kind = "STAGED_PARSE_JOB_MARKER",
    version = 2,
    sidecar_kind = "staged_parse_job_v2",
    effect = "staged_parse_job_declaration",
    staged_parse_job_v2 = sidecar,
  })
end

local function enrichment_callbacks(callback, snapshot)
  snapshot = snapshot or contract.resolution_snapshot
  local result = {}
  for _, entry in ipairs(snapshot.entries) do result[entry.compiled_authority] = callback end
  return result
end

local function enrichment_registry(callback, snapshot, callbacks)
  snapshot = snapshot or contract.resolution_snapshot
  return staged_ast_enrichment.freeze_registry(
    snapshot,
    callbacks or enrichment_callbacks(callback, snapshot)
  )
end

local function recursive_authority(options)
  options = options or {}
  local config = json.harray({
    cancellation_token = options.token or "cancel:open",
    deadline = options.deadline or 100,
    remaining_steps = options.remaining_steps == nil and 20 or options.remaining_steps,
    required_steps = options.required_steps == nil and 1 or options.required_steps,
    max_depth = options.max_depth or 4,
    max_calls = options.max_calls or 10,
  })
  if options.total_calls ~= nil then config.total_calls = options.total_calls end
  return staged_ast_enrichment.recursive_authority(
    config,
    options.cancelled or function() return false end,
    options.clock or function() return 1 end
  )
end

local function production_seed(observations, failure)
  local run_counter = 0
  return staged_ast_enrichment.execution_seed(
    contract.resolution_snapshot,
    enrichment_options(),
    function()
      run_counter = run_counter + 1
      local run_id = run_counter
      local token = json.harray({ run_id = run_id })
      local callbacks = {}
      local callback_identities = {}
      for _, entry in ipairs(contract.resolution_snapshot.entries) do
        local callback_name = entry.compiled_authority
        local callback = function(request, context)
          observations.callbacks[#observations.callbacks + 1] = json.harray({
            run_id = run_id,
            callback_name = callback_name,
            text = request.text,
            token = staged_ast_enrichment.cancellation_token(context),
          })
          staged_ast_enrichment.safe_point(context, 0)
          if failure then
            return staged_ast_enrichment.child_failure(json.harray({ code = "fixture_child_failure" }))
          end
          return staged_ast_enrichment.child_success(json.harray({
            kind = "expression",
            text = request.text,
            top_rule = request.top_rule,
          }))
        end
        callbacks[callback_name] = callback
        callback_identities[#callback_identities + 1] = tostring(callback)
      end
      local cancelled = function(actual_token)
        observations.cancellation_checks[#observations.cancellation_checks + 1] = json.harray({
          run_id = run_id,
          token = actual_token,
        })
        return false
      end
      local clock = function()
        observations.clock_checks[#observations.clock_checks + 1] = run_id
        return 1
      end
      observations.starts[#observations.starts + 1] = json.harray({
        run_id = run_id,
        token = token,
        callback_identities = callback_identities,
        cancelled = tostring(cancelled),
        clock = tostring(clock),
      })
      return {
        compiled_authorities = callbacks,
        recursive_authority = json.harray({
          cancellation_token = token,
          deadline = 100,
          remaining_steps = 20,
          required_steps = 1,
          max_depth = 4,
          max_calls = 10,
        }),
        cancelled = cancelled,
        clock = clock,
      }
    end
  )
end

check_equal(contract.contract_id, CONTRACT_ID, "neutral contract id")
check_equal(contract.format, 1, "neutral contract format")
check_equal(
  contract.status,
  "all_backends_complete_recurring_and_public_current",
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
  recurring_source_groups = 5,
  recurring_runtime_routes = 6,
  outward_guard_paths = 10,
  diagnostics = 37,
  rollout_legs = 9,
  ownership_rows = 35,
  mutations = 123,
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
  "complete",
}) do
  check_equal(contract.backend_consumers[index].status, expected, "consumer lifecycle " .. index)
end
local lua_consumer = contract.backend_consumers[5]
check_equal(lua_consumer.backend, "lua", "Lua consumer backend")
check_equal(lua_consumer.owner, "FUTURE-PARITY-BACKLOG.14.7.7.0", "Lua consumer owner")
check_equal(lua_consumer.path, CONSUMER_PATH, "Lua consumer stable path")
check_equal(lua_consumer.status, "complete", "Lua consumer admitted status")
check_equal(#contract.rollout, 9, "rollout row count")
for index = 1, 8 do
  check_equal(contract.rollout[index].status, "complete", "complete rollout " .. index)
end
check_equal(contract.rollout[9].status, "complete", "complete rollout 9")
check_equal(contract.rollout[6].owner, "FUTURE-PARITY-BACKLOG.14.7.7", "PUC Lua rollout owner")
check_equal(contract.rollout[7].owner, "FUTURE-PARITY-BACKLOG.14.7.7", "LuaJIT rollout owner")
check_equal(
  contract.authored_surface.availability,
  "portable exact-assignment parse_job authoring is current on Perl, Rust, Dart, Julia, " ..
    "PUC Lua, and LuaJIT through the dedicated staged marker and caller-frozen already-compiled authority",
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

local inert_callback = function()
  return staged_ast_enrichment.child_success(json.null)
end
local frozen_registry = enrichment_registry(inert_callback)
check_equal(
  staged_ast_enrichment.node_type(frozen_registry),
  "FrozenStagedRegistry",
  "caller-frozen registry is opaque"
)
check_contains(
  staged_ast_enrichment.snapshot_id(frozen_registry),
  "registry-snapshot:sha256:",
  "caller-frozen snapshot identity"
)
check_same_json(staged_ast_enrichment.cache_stats(frozen_registry), json.harray({
  snapshot_id = staged_ast_enrichment.snapshot_id(frozen_registry),
  entries = 0,
  hits = 0,
  misses = 0,
}), "caller-frozen cache starts empty")

for _, row in ipairs(contract.resolution_cases) do
  local ok, value = capture(function()
    return staged_ast_enrichment.resolve_pre_registered(frozen_registry, {
      declaring_spec_id = row.declaring_spec_id,
      parser_spec_id = row.parser_spec_id,
      job_id = "contract:resolution",
    })
  end)
  if row.diagnostic == json.null then
    check_equal(ok, true, "neutral resolution " .. row.id .. " accepts")
    check_equal(value, row.resolved_spec_id, "neutral resolution " .. row.id .. " identity")
  else
    check_equal(ok, false, "neutral resolution " .. row.id .. " rejects")
    check_equal(enrichment_error_code(value), row.diagnostic, "neutral resolution " .. row.id .. " diagnostic")
    check_equal(enrichment_diagnostic_is_complete(value), true, "neutral resolution " .. row.id .. " context")
  end
end

for _, row in ipairs(contract.authority_cases) do
  local ok, value = capture(function()
    return staged_ast_enrichment.evaluate_authority_case(
      frozen_registry,
      row,
      "contract:authority"
    )
  end)
  if row.accepted then
    check_equal(ok, true, "neutral authority " .. row.id .. " accepts")
    check_same_json(value, row.effective, "neutral authority " .. row.id .. " effective")
  else
    check_equal(ok, false, "neutral authority " .. row.id .. " rejects")
    check_equal(enrichment_error_code(value), row.diagnostic, "neutral authority " .. row.id .. " diagnostic")
    check_equal(enrichment_diagnostic_is_complete(value), true, "neutral authority " .. row.id .. " context")
  end
end

local forbidden_top = json.decode(json.encode(contract.authority_cases[1]))
forbidden_top.top_rule = "MissingTop"
local forbidden_top_ok, forbidden_top_error = capture(function()
  return staged_ast_enrichment.evaluate_authority_case(
    frozen_registry,
    forbidden_top,
    "contract:forbidden-top"
  )
end)
check_equal(forbidden_top_ok, false, "forbidden top rejects")
check_equal(enrichment_error_code(forbidden_top_error), "staged_top_rule_forbidden", "forbidden top diagnostic")
check_equal(enrichment_diagnostic_is_complete(forbidden_top_error), true, "forbidden top context")

local isolated_snapshot = json.decode(json.encode(contract.resolution_snapshot))
local isolated_callbacks = enrichment_callbacks(inert_callback, isolated_snapshot)
local isolated_registry = enrichment_registry(inert_callback, isolated_snapshot, isolated_callbacks)
isolated_snapshot.aliases[1].resolved_spec_id = "registry:yaml-v1"
isolated_callbacks["opaque:compiled:expr-v2"] = function()
  return staged_ast_enrichment.child_failure(json.harray({ code = "mutated" }))
end
check_equal(
  staged_ast_enrichment.resolve_pre_registered(isolated_registry, {
    declaring_spec_id = "grammar/main.spec",
    parser_spec_id = "expr",
    job_id = "contract:immutable",
  }),
  "registry:expr-v2",
  "snapshot mutation cannot change frozen resolution"
)

local malformed_snapshots = {}
for _, field_and_value in ipairs({
  { "immutable", false },
  { "prepared_before_authored_execution", false },
  { "filesystem_access_during_dispatch", true },
}) do
  local malformed = json.decode(json.encode(contract.resolution_snapshot))
  malformed[field_and_value[1]] = field_and_value[2]
  malformed_snapshots[#malformed_snapshots + 1] = malformed
end
local bad_digest = json.decode(json.encode(contract.resolution_snapshot))
bad_digest.entries[1].content_digest = "sha256:not-a-digest"
malformed_snapshots[#malformed_snapshots + 1] = bad_digest
local bad_default = json.decode(json.encode(contract.resolution_snapshot))
bad_default.entries[1].default_top_rule = "MissingTop"
malformed_snapshots[#malformed_snapshots + 1] = bad_default
local duplicate_order = json.decode(json.encode(contract.resolution_snapshot))
duplicate_order.search_roots[2].order = 1
malformed_snapshots[#malformed_snapshots + 1] = duplicate_order
for index, malformed in ipairs(malformed_snapshots) do
  local ok, value = capture(function()
    return enrichment_registry(inert_callback, malformed)
  end)
  check_equal(ok, false, "malformed snapshot " .. index .. " rejects")
  check_equal(enrichment_error_code(value), "staged_registry_snapshot_invalid", "malformed snapshot " .. index .. " diagnostic")
end

local missing_callbacks = enrichment_callbacks(inert_callback)
missing_callbacks[contract.resolution_snapshot.entries[1].compiled_authority] = nil
local missing_callback_ok, missing_callback_error = capture(function()
  return enrichment_registry(inert_callback, contract.resolution_snapshot, missing_callbacks)
end)
check_equal(missing_callback_ok, false, "missing compiled callback rejects")
check_equal(enrichment_error_code(missing_callback_error), "staged_registry_snapshot_invalid", "missing callback diagnostic")
local extra_callbacks = enrichment_callbacks(inert_callback)
extra_callbacks["opaque:compiled:extra"] = inert_callback
local extra_callback_ok, extra_callback_error = capture(function()
  return enrichment_registry(inert_callback, contract.resolution_snapshot, extra_callbacks)
end)
check_equal(extra_callback_ok, false, "extra compiled callback rejects")
check_equal(enrichment_error_code(extra_callback_error), "staged_registry_snapshot_invalid", "extra callback diagnostic")

for _, row in ipairs({
  { "register", "staged_registry_mutation_forbidden" },
  { "load", "staged_implicit_load_forbidden" },
}) do
  local ok, value = capture(function()
    return staged_ast_enrichment[row[1]](frozen_registry, {
      job_id = "contract:authority-denial",
      parser_spec_id = "expr",
    })
  end)
  check_equal(ok, false, row[1] .. " authority rejects")
  check_equal(enrichment_error_code(value), row[2], row[1] .. " authority diagnostic")
  check_equal(enrichment_diagnostic_is_complete(value), true, row[1] .. " authority context")
end

for _, row in ipairs(contract.job_id_cases) do
  local fields = json.decode(json.encode(row))
  fields.id = nil
  fields.expected_job_id = nil
  check_equal(
    staged_ast_enrichment.job_identity(fields),
    row.expected_job_id,
    "neutral job identity " .. row.id
  )
end

local base_cache_key
for _, row in ipairs(contract.cache_cases) do
  local key = staged_ast_enrichment.cache_identity(row.fields)
  if row.id == "base" then base_cache_key = key end
  check_equal(
    key == base_cache_key,
    row.same_as_base,
    "neutral cache identity " .. row.id
  )
end
check_contains(base_cache_key, "sha256:", "cache identity digest prefix")
local malformed_cache = json.decode(json.encode(contract.cache_cases[1].fields))
malformed_cache.ambient_loader = true
local malformed_cache_ok, malformed_cache_error = capture(function()
  return staged_ast_enrichment.cache_identity(malformed_cache)
end)
check_equal(malformed_cache_ok, false, "ambient cache authority rejects")
check_equal(enrichment_error_code(malformed_cache_error), "staged_cache_identity_invalid", "ambient cache diagnostic")
check_equal(enrichment_diagnostic_is_complete(malformed_cache_error), true, "ambient cache context")

for _, row in ipairs(contract.queue_cases) do
  check_same_json(
    staged_ast_enrichment.current_depth_order(row.jobs),
    row.expected_order,
    "neutral typed order " .. row.id
  )
end

for _, row in ipairs(contract.stitch_cases) do
  local expected_result = json.decode(json.encode(row.result))
  local registry = enrichment_registry(function()
    return staged_ast_enrichment.child_success(json.decode(json.encode(expected_result)))
  end)
  local parent = json.decode(json.encode(row.parent))
  parent[row.marker_field] = enrichment_marker(
    row.text,
    0,
    row.result_policy,
    row.into,
    "fail"
  )
  local outcome = staged_ast_enrichment.enrich_current_depth(
    registry,
    parent,
    enrichment_options()
  )
  check_same_json(outcome.ast, row.expected_parent, "neutral stitch " .. row.id)
  check_equal(#outcome.diagnostics, 0, "neutral stitch " .. row.id .. " diagnostics")
  check_equal(outcome.sidecars[1].state, "succeeded", "neutral stitch " .. row.id .. " state")
end

for _, row in ipairs(contract.failure_cases) do
  local registry = enrichment_registry(function()
    return staged_ast_enrichment.child_failure(json.harray({
      code = "child_parse_error",
      offset = 1,
    }))
  end)
  local parent = json.decode(json.encode(row.parent))
  parent[row.marker_field] = enrichment_marker(
    row.text,
    0,
    row.result_policy,
    row.into,
    row.failure_policy
  )
  local ok, value = capture(function()
    return staged_ast_enrichment.enrich_current_depth(
      registry,
      parent,
      enrichment_options()
    )
  end)
  if row.failure_policy == "fail" then
    check_equal(ok, false, "neutral failure fail aborts")
    check_equal(enrichment_error_code(value), "staged_child_failed", "neutral failure fail diagnostic")
    check_equal(enrichment_diagnostic_is_complete(value), true, "neutral failure fail context")
    check_equal(parent[row.marker_field].kind, "STAGED_PARSE_JOB_MARKER", "neutral failure parent unpublished")
  elseif row.failure_policy == "keep_text" then
    check_equal(ok, true, "neutral keep-text continues")
    check_same_json(value.ast, row.expected.parent, "neutral keep-text parent")
    check_equal(#value.diagnostics, 1, "neutral keep-text diagnostic count")
    check_equal(value.sidecars[1].state, "failed_keep_text", "neutral keep-text state")
  else
    check_equal(ok, true, "neutral diagnostic-node continues")
    check_equal(value.ast[row.marker_field], row.text, "neutral diagnostic-node text")
    check_equal(value.ast.ast.kind, "staged_parse_diagnostic", "neutral diagnostic-node kind")
    check_same_json(value.ast.ast.diagnostic, value.diagnostics[1], "neutral diagnostic-node retained diagnostic")
    check_equal(value.sidecars[1].state, "failed_diagnostic_node", "neutral diagnostic-node state")
  end
end

local observed_contexts = json.array()
local observed_order = json.array()
local callback_count = 0
local ordered_registry = enrichment_registry(function(request, context)
  observed_contexts[#observed_contexts + 1] = staged_ast_enrichment.runtime_context_to_json(context)
  observed_order[#observed_order + 1] = request.text
  callback_count = callback_count + 1
  context.cursor = 9
  context.marks.child = 1
  context.captures.capture = "local"
  context.variables.variable = true
  return staged_ast_enrichment.child_success(json.harray({
    kind = "parsed",
    text = request.text,
  }))
end)
local ordered_ast = json.harray({
  nodes = json.array({
    json.harray({ payload = enrichment_marker("first", 4, "replace_marker", nil, "fail") }),
    json.harray({ payload = enrichment_marker("second", 1, "replace_marker", nil, "fail") }),
  }),
})
local first_ordered = staged_ast_enrichment.enrich_current_depth(
  ordered_registry,
  ordered_ast,
  enrichment_options()
)
check_string_list(observed_order, { "first", "second" }, "complete-depth typed callback order")
for index, context in ipairs(observed_contexts) do
  check_same_json(context, json.harray({
    cursor = 0,
    marks = json.harray(),
    captures = json.harray(),
    variables = json.harray(),
  }), "fresh sibling context " .. index)
end
check_equal(first_ordered.cache.entries, 1, "first depth plan-cache entries")
check_equal(first_ordered.cache.misses, 1, "first depth plan-cache misses")
check_equal(first_ordered.cache.hits, 1, "first depth plan-cache hits")
local second_ordered = staged_ast_enrichment.enrich_current_depth(
  ordered_registry,
  ordered_ast,
  enrichment_options()
)
check_equal(second_ordered.cache.entries, 1, "second depth plan-cache entries")
check_equal(second_ordered.cache.misses, 1, "second depth plan-cache misses")
check_equal(second_ordered.cache.hits, 3, "second depth plan-cache hits")
check_equal(callback_count, 4, "child results always execute")
check_equal(ordered_ast.nodes[1].payload.kind, "STAGED_PARSE_JOB_MARKER", "parent AST remains unpublished")
local fresh_registry = enrichment_registry(inert_callback)
check_equal(staged_ast_enrichment.cache_stats(fresh_registry).entries, 0, "fresh registry has isolated cache")

local default_registry = enrichment_registry(function()
  return staged_ast_enrichment.child_success(json.harray({ kind = "expr" }))
end)
local default_outcome = staged_ast_enrichment.enrich_current_depth(
  default_registry,
  json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail", false) }),
  enrichment_options()
)
check_equal(default_outcome.sidecars[1].top_rule, "Expr", "default top selected before identity")
check_equal(
  default_outcome.sidecars[1].job_id,
  staged_ast_enrichment.job_identity(json.harray({
    declaring_spec_id = "grammar/main.spec",
    parent_ast_path = json.array({ "payload" }),
    node_kind = "expression",
    payload_kind = "embedded_expression",
    parser_spec_id = "expr",
    top_rule = "Expr",
    provenance = json.harray({
      kind = "direct_span",
      source_id = "ascii",
      start = 0,
      ["end"] = 1,
      provenance = "capture",
    }),
  })),
  "default top canonical job identity"
)

local invalid_callback_count = 0
local invalid_registry = enrichment_registry(function()
  invalid_callback_count = invalid_callback_count + 1
  return staged_ast_enrichment.child_success(json.harray({ kind = "unexpected" }))
end)
local invalid_asts = {
  {
    ast = json.harray({
      payload = enrichment_marker("x", 0, "sibling_field", "ast", "fail"),
      ast = json.harray({ kind = "occupied" }),
    }),
    code = "staged_stitch_target_collision",
  },
  {
    ast = json.harray({
      payload = enrichment_marker("x", 0, "append_child", "children", "fail"),
      children = json.harray(),
    }),
    code = "staged_append_target_invalid",
  },
  {
    ast = json.harray({ payload = enrichment_marker("x", 0, "sibling_field", nil, "fail") }),
    code = "staged_stitch_target_missing",
  },
  {
    ast = json.harray({ payload = enrichment_marker("x", 0, "replace_field", "ast", "fail") }),
    code = "staged_stitch_target_missing",
  },
}
for index, row in ipairs(invalid_asts) do
  local ok, value = capture(function()
    return staged_ast_enrichment.enrich_current_depth(
      invalid_registry,
      row.ast,
      enrichment_options()
    )
  end)
  check_equal(ok, false, "invalid depth " .. index .. " rejects")
  check_equal(enrichment_error_code(value), row.code, "invalid depth " .. index .. " diagnostic")
  check_equal(enrichment_diagnostic_is_complete(value), true, "invalid depth " .. index .. " context")
end
check_equal(invalid_callback_count, 0, "invalid depths reject before callback one")
check_equal(staged_ast_enrichment.cache_stats(invalid_registry).entries, 0, "invalid depths do not populate cache")

local unresolved = enrichment_marker("x", 0, "replace_marker", nil, "fail")
unresolved.staged_parse_job_v2.parser_spec_id = "missing-v1"
local unresolved_ok, unresolved_error = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    invalid_registry,
    json.harray({ payload = unresolved }),
    enrichment_options()
  )
end)
check_equal(unresolved_ok, false, "unresolved depth rejects")
check_equal(enrichment_error_code(unresolved_error), "staged_registry_missing", "unresolved depth diagnostic")
check_equal(enrichment_diagnostic_is_complete(unresolved_error), true, "unresolved depth context")
check_equal(invalid_callback_count, 0, "unresolved depth invokes no callback")

local atomic_input = json.harray({
  nodes = json.array({
    json.harray({ payload = enrichment_marker("ok", 0, "replace_marker", nil, "fail") }),
    json.harray({ payload = enrichment_marker("bad", 2, "replace_marker", nil, "fail") }),
  }),
})
local atomic_registry = enrichment_registry(function(request)
  if request.text == "bad" then
    return staged_ast_enrichment.child_failure(json.harray({ code = "expected_failure" }))
  end
  return staged_ast_enrichment.child_success(json.harray({ kind = "first_result" }))
end)
local atomic_ok, atomic_error = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    atomic_registry,
    atomic_input,
    enrichment_options()
  )
end)
check_equal(atomic_ok, false, "atomic fail aborts complete depth")
check_equal(enrichment_error_code(atomic_error), "staged_child_failed", "atomic fail diagnostic")
check_equal(atomic_input.nodes[1].payload.kind, "STAGED_PARSE_JOB_MARKER", "atomic fail publishes no sibling")

local conflict_calls = 0
local conflict_registry = enrichment_registry(function()
  conflict_calls = conflict_calls + 1
  return staged_ast_enrichment.child_success(json.harray({ kind = "replacement" }))
end)
local conflicting = json.harray({
  control = enrichment_marker("first", 0, "replace_field", "payload", "fail"),
  payload = enrichment_marker("second", 6, "replace_marker", nil, "fail"),
})
local conflict_ok, conflict_error = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    conflict_registry,
    conflicting,
    enrichment_options()
  )
end)
check_equal(conflict_ok, false, "cross-plan target conflict rejects")
check_equal(enrichment_error_code(conflict_error), "staged_stitch_target_collision", "cross-plan conflict diagnostic")
check_equal(enrichment_diagnostic_is_complete(conflict_error), true, "cross-plan conflict context")
check_equal(conflict_calls, 0, "cross-plan conflict rejects before callback one")

local duplicate_target = json.harray({
  first = enrichment_marker("first", 0, "sibling_field", "ast", "fail"),
  second = enrichment_marker("second", 6, "sibling_field", "ast", "fail"),
})
local duplicate_target_ok, duplicate_target_error = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    conflict_registry,
    duplicate_target,
    enrichment_options()
  )
end)
check_equal(duplicate_target_ok, false, "duplicate sibling target rejects")
check_equal(enrichment_error_code(duplicate_target_error), "staged_stitch_target_collision", "duplicate target diagnostic")
check_equal(conflict_calls, 0, "duplicate target rejects before callback one")

local append_order = json.array()
local append_registry = enrichment_registry(function(request)
  append_order[#append_order + 1] = request.text
  return staged_ast_enrichment.child_success(json.harray({ text = request.text }))
end)
local append_outcome = staged_ast_enrichment.enrich_current_depth(
  append_registry,
  json.harray({
    first = enrichment_marker("first", 0, "append_child", "children", "fail"),
    second = enrichment_marker("second", 6, "append_child", "children", "fail"),
    children = json.array(),
  }),
  enrichment_options()
)
check_string_list(append_order, { "first", "second" }, "multiple append target order")
check_equal(append_outcome.ast.first, "first", "first append marker materialized")
check_equal(append_outcome.ast.second, "second", "second append marker materialized")
check_same_json(append_outcome.ast.children, json.array({
  json.harray({ text = "first" }),
  json.harray({ text = "second" }),
}), "multiple appends share one deterministic target")

local nested_calls = 0
local nested_marker = enrichment_marker("nested", 1, "replace_marker", nil, "fail")
local nested_registry = enrichment_registry(function()
  nested_calls = nested_calls + 1
  return staged_ast_enrichment.child_success(nested_marker)
end)
local nested_outcome = staged_ast_enrichment.enrich_current_depth(
  nested_registry,
  json.harray({ payload = enrichment_marker("outer", 0, "replace_marker", nil, "fail") }),
  enrichment_options()
)
check_equal(nested_outcome.ast.payload.kind, "STAGED_PARSE_JOB_MARKER", "returned marker remains inert")
check_equal(nested_calls, 1, "returned marker is not rescanned")
nested_marker.callback = "opaque:live"
local smuggled_ok, smuggled_error = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    nested_registry,
    json.harray({ payload = enrichment_marker("outer-smuggled", 0, "replace_marker", nil, "fail") }),
    enrichment_options()
  )
end)
check_equal(smuggled_ok, false, "marker-shaped live authority rejects")
check_equal(enrichment_error_code(smuggled_error), "staged_result_not_detached", "marker-shaped live diagnostic")
check_equal(enrichment_diagnostic_is_complete(smuggled_error), true, "marker-shaped live context")

for _, row in ipairs(contract.detachment_cases) do
  local direct = staged_ast_enrichment.detach_plain(
    json.decode(json.encode(row.value)),
    row.max_nodes
  )
  check_equal(direct.accepted, row.accepted, "neutral detachment " .. row.id .. " acceptance")
  check_equal(direct.nodes, row.visited_nodes, "neutral detachment " .. row.id .. " visited nodes")
  if row.accepted then
    check_same_json(direct.value, row.value, "neutral detachment " .. row.id .. " value")
  end

  local options = enrichment_options()
  options.caller_ceilings.max_result_nodes = row.max_nodes
  local registry = enrichment_registry(function()
    return staged_ast_enrichment.child_success(json.decode(json.encode(row.value)))
  end)
  local ok, value = capture(function()
    return staged_ast_enrichment.enrich_current_depth(
      registry,
      json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail") }),
      options
    )
  end)
  if row.accepted then
    check_equal(ok, true, "neutral detached result " .. row.id .. " accepts")
    check_same_json(value.ast.payload, row.value, "neutral detached result " .. row.id .. " value")
  else
    check_equal(ok, false, "neutral detached result " .. row.id .. " rejects")
    check_equal(enrichment_error_code(value), row.diagnostic, "neutral detached result " .. row.id .. " diagnostic")
    check_equal(enrichment_diagnostic_is_complete(value), true, "neutral detached result " .. row.id .. " context")
  end
end

local cyclic = {}
cyclic[1] = cyclic
local cyclic_registry = enrichment_registry(function()
  return staged_ast_enrichment.child_success(cyclic)
end)
local cyclic_ok, cyclic_error = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    cyclic_registry,
    json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail") }),
    enrichment_options()
  )
end)
check_equal(cyclic_ok, false, "actual cyclic child result rejects")
check_equal(enrichment_error_code(cyclic_error), "staged_result_not_detached", "actual cyclic diagnostic")

local repeated_failure_calls = 0
local repeated_failure_registry = enrichment_registry(function()
  repeated_failure_calls = repeated_failure_calls + 1
  return staged_ast_enrichment.child_failure(json.harray({ code = "repeatable_failure" }))
end)
local failing_ast = json.harray({
  payload = enrichment_marker("bad", 0, "replace_marker", nil, "fail"),
})
for attempt = 1, 2 do
  local ok, value = capture(function()
    return staged_ast_enrichment.enrich_current_depth(
      repeated_failure_registry,
      failing_ast,
      enrichment_options()
    )
  end)
  check_equal(ok, false, "repeated child failure " .. attempt .. " rejects")
  check_equal(enrichment_error_code(value), "staged_child_failed", "repeated child failure " .. attempt .. " diagnostic")
end
local repeated_failure_cache = staged_ast_enrichment.cache_stats(repeated_failure_registry)
check_equal(repeated_failure_calls, 2, "failed child results never cache")
check_equal(repeated_failure_cache.entries, 1, "failed child plan cache entries")
check_equal(repeated_failure_cache.misses, 1, "failed child plan cache misses")
check_equal(repeated_failure_cache.hits, 1, "failed child plan cache hits")

local fail_first = true
local recovery_calls = 0
local recovery_registry = enrichment_registry(function()
  recovery_calls = recovery_calls + 1
  if fail_first then
    fail_first = false
    return staged_ast_enrichment.child_failure(json.harray({ code = "first_attempt_failed" }))
  end
  return staged_ast_enrichment.child_success(json.harray({ kind = "fresh" }))
end)
local recovery_first_ok = capture(function()
  return staged_ast_enrichment.enrich_current_depth(
    recovery_registry,
    failing_ast,
    enrichment_options()
  )
end)
check_equal(recovery_first_ok, false, "failed first result is not cached")
local recovered = staged_ast_enrichment.enrich_current_depth(
  recovery_registry,
  failing_ast,
  enrichment_options()
)
check_same_json(recovered.ast.payload, json.harray({ kind = "fresh" }), "fresh result after failure")
check_equal(recovery_calls, 2, "recovery callback executes twice")
check_equal(recovered.cache.misses, 1, "recovery plan miss count")
check_equal(recovered.cache.hits, 1, "recovery plan hit count")

local thrown_registry = enrichment_registry(function()
  error("contained child exception", 0)
end)
local thrown = staged_ast_enrichment.enrich_current_depth(
  thrown_registry,
  json.harray({ payload = enrichment_marker("panic", 0, "replace_marker", nil, "keep_text") }),
  enrichment_options()
)
check_equal(thrown.ast.payload, "panic", "callback exception keeps exact text")
check_equal(thrown.diagnostics[1].child_diagnostic.code, "staged_child_exception", "callback exception contained")

;(function()
for _, row in ipairs(contract.chain_cases) do
  local actual = staged_ast_enrichment.evaluate_chain_case(row)
  check_equal(actual.accepted, row.accepted, "recursive chain " .. row.id .. " acceptance")
  check_equal(actual.diagnostic, row.diagnostic, "recursive chain " .. row.id .. " diagnostic")
end

local recursive_observed = {}
local recursive_tokens = {}
local retained_context
local recursive_registry = enrichment_registry(function(request, context)
  recursive_observed[#recursive_observed + 1] = json.harray({
    depth = request.stage_depth,
    text = request.text,
    stage_chain_length = #request.stage_chain,
    context = staged_ast_enrichment.runtime_context_to_json(context),
    token = staged_ast_enrichment.cancellation_token(context),
    deadline = staged_ast_enrichment.deadline(context),
    remaining_before = staged_ast_enrichment.remaining_steps(context),
  })
  retained_context = retained_context or context
  staged_ast_enrichment.safe_point(context, 1)
  context.cursor = request.stage_depth
  context.marks.child = request.text
  if request.text == "abcdef" then
    return staged_ast_enrichment.child_success(json.harray({
      kind = "branch",
      child = enrichment_marker("bc", 1, "replace_marker", nil, "fail"),
    }))
  elseif request.text == "ghijkl" then
    return staged_ast_enrichment.child_success(json.harray({
      kind = "branch",
      child = enrichment_marker("hi", 7, "replace_marker", nil, "fail"),
    }))
  end
  return staged_ast_enrichment.child_success(json.harray({ kind = "leaf", text = request.text }))
end)
local recursive = staged_ast_enrichment.enrich_recursively(
  recursive_registry,
  json.harray({
    nodes = json.array({
      json.harray({ payload = enrichment_marker("abcdef", 0, "replace_marker", nil, "fail") }),
      json.harray({ payload = enrichment_marker("ghijkl", 6, "replace_marker", nil, "fail") }),
    }),
  }),
  enrichment_options(),
  recursive_authority({
    token = "cancel:shared",
    cancelled = function(token)
      recursive_tokens[#recursive_tokens + 1] = token
      return false
    end,
  })
)
check_equal(#recursive_observed, 4, "recursive callback count")
check_same_json(
  json.array({
    recursive_observed[1].text,
    recursive_observed[2].text,
    recursive_observed[3].text,
    recursive_observed[4].text,
  }),
  json.array({ "abcdef", "ghijkl", "bc", "hi" }),
  "recursive breadth-first order"
)
for index, expected_depth in ipairs({ 1, 1, 2, 2 }) do
  check_equal(recursive_observed[index].depth, expected_depth, "recursive depth " .. index)
  check_equal(
    recursive_observed[index].stage_chain_length,
    expected_depth,
    "recursive request chain length " .. index
  )
  check_equal(recursive_observed[index].context.cursor, 0, "fresh recursive cursor " .. index)
  check_equal(next(recursive_observed[index].context.marks), nil, "fresh recursive marks " .. index)
  check_equal(recursive_observed[index].token, "cancel:shared", "shared recursive token " .. index)
  check_equal(recursive_observed[index].deadline, 100, "shared recursive deadline " .. index)
end
for index, expected in ipairs({ 19, 17, 15, 13 }) do
  check_equal(recursive_observed[index].remaining_before, expected, "shared recursive budget " .. index)
end
for _, token in ipairs(recursive_tokens) do
  check_equal(token, "cancel:shared", "recursive cancellation token identity")
end
for index, expected_depth in ipairs({ 1, 1, 2, 2 }) do
  check_equal(recursive.sidecars[index].stage_depth, expected_depth, "recursive sidecar depth " .. index)
  check_equal(#recursive.sidecars[index].stage_chain, expected_depth - 1, "recursive sidecar chain " .. index)
end
check_equal(recursive.ast.nodes[1].payload.child.kind, "leaf", "first recursive leaf")
check_equal(recursive.ast.nodes[2].payload.child.text, "hi", "second recursive leaf")
check_equal(recursive.resources.remaining_steps, 12, "recursive cumulative steps")
check_equal(recursive.resources.total_calls, 4, "recursive cumulative calls")
check_equal(recursive.resources.remaining_result_nodes, 116, "recursive cumulative result nodes")
check_equal(#recursive.diagnostics, 0, "recursive diagnostics empty")
local expired_ok, expired = capture(function()
  return staged_ast_enrichment.safe_point(retained_context, 0)
end)
check_equal(expired_ok, false, "recursive context expires")
check_equal(enrichment_error_code(expired), "staged_registry_snapshot_invalid", "expired context diagnostic")

local routed_registry = enrichment_registry(function(request)
  local starts = { abcd = 0, efgh = 10, ijkl = 20 }
  if starts[request.text] ~= nil then
    return staged_ast_enrichment.child_success(enrichment_marker(
      request.text:sub(2, 3),
      starts[request.text] + 1,
      "replace_marker",
      nil,
      "fail"
    ))
  end
  return staged_ast_enrichment.child_success(json.harray({ kind = "routed_leaf" }))
end)
local routed = staged_ast_enrichment.enrich_recursively(
  routed_registry,
  json.harray({
    replace = json.harray({
      control = enrichment_marker("abcd", 0, "replace_field", "ast", "fail"),
      ast = json.null,
    }),
    sibling = json.harray({
      control = enrichment_marker("efgh", 10, "sibling_field", "ast", "fail"),
    }),
    append = json.harray({
      control = enrichment_marker("ijkl", 20, "append_child", "children", "fail"),
      children = json.array(),
    }),
  }),
  enrichment_options(),
  recursive_authority()
)
check_equal(routed.ast.replace.ast.kind, "routed_leaf", "recursive replace-field rebase")
check_equal(routed.ast.sibling.ast.kind, "routed_leaf", "recursive sibling-field rebase")
check_equal(routed.ast.append.children[1].kind, "routed_leaf", "recursive append-child rebase")
local routed_depths = { 0, 0 }
for _, sidecar in ipairs(routed.sidecars) do routed_depths[sidecar.stage_depth] = routed_depths[sidecar.stage_depth] + 1 end
check_equal(routed_depths[1], 3, "routed first depth count")
check_equal(routed_depths[2], 3, "routed second depth count")

local cycle_calls = 0
local cycle_marker = enrichment_marker("abcdef", 0, "replace_marker", nil, "fail")
local cycle_registry = enrichment_registry(function()
  cycle_calls = cycle_calls + 1
  return staged_ast_enrichment.child_success(cycle_marker)
end)
local cycle_ok, cycle_error = capture(function()
  return staged_ast_enrichment.enrich_recursively(
    cycle_registry,
    json.harray({ payload = cycle_marker }),
    enrichment_options(),
    recursive_authority()
  )
end)
check_equal(cycle_ok, false, "recursive exact cycle rejects")
check_equal(enrichment_error_code(cycle_error), "staged_cycle", "recursive exact cycle diagnostic")
check(enrichment_diagnostic_is_complete(cycle_error), "recursive exact cycle context complete")
check_equal(cycle_calls, 1, "recursive exact cycle preflight")

local nondecreasing_ok, nondecreasing = capture(function()
  return staged_ast_enrichment.enrich_recursively(
    enrichment_registry(function()
      return staged_ast_enrichment.child_success(
        enrichment_marker("uvwxyz", 0, "replace_marker", nil, "fail")
      )
    end),
    json.harray({ payload = cycle_marker }),
    enrichment_options(),
    recursive_authority()
  )
end)
check_equal(nondecreasing_ok, false, "recursive nondecreasing lineage rejects")
check_equal(
  enrichment_error_code(nondecreasing),
  "staged_chain_non_decreasing",
  "recursive nondecreasing lineage diagnostic"
)
check(enrichment_diagnostic_is_complete(nondecreasing), "recursive nondecreasing context complete")

for _, denial in ipairs({
  { "staged_depth_exceeded", { max_depth = 1 } },
  { "staged_call_limit_exceeded", { max_calls = 1 } },
}) do
  local ok, value = capture(function()
    return staged_ast_enrichment.enrich_recursively(
      enrichment_registry(function()
        return staged_ast_enrichment.child_success(
          enrichment_marker("bc", 1, "replace_marker", nil, "fail")
        )
      end),
      json.harray({ payload = cycle_marker }),
      enrichment_options(),
      recursive_authority(denial[2])
    )
  end)
  check_equal(ok, false, denial[1] .. " rejects")
  check_equal(enrichment_error_code(value), denial[1], denial[1] .. " diagnostic")
  check(enrichment_diagnostic_is_complete(value), denial[1] .. " context complete")
end

for _, denial in ipairs({
  { "staged_budget_exhausted", { remaining_steps = 0 } },
  { "staged_cancelled", { cancelled = function() return true end } },
  { "staged_deadline_exceeded", { deadline = 10, clock = function() return 11 end } },
}) do
  local calls = 0
  local ok, value = capture(function()
    return staged_ast_enrichment.enrich_recursively(
      enrichment_registry(function()
        calls = calls + 1
        return staged_ast_enrichment.child_success(json.null)
      end),
      json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail") }),
      enrichment_options(),
      recursive_authority(denial[2])
    )
  end)
  check_equal(ok, false, denial[1] .. " dispatch rejects")
  check_equal(enrichment_error_code(value), denial[1], denial[1] .. " dispatch diagnostic")
  check(enrichment_diagnostic_is_complete(value), denial[1] .. " dispatch context complete")
  check_equal(calls, 0, denial[1] .. " callback remains uncalled")
end

local narrowed = staged_ast_enrichment.enrich_recursively(
  enrichment_registry(function() return staged_ast_enrichment.child_success(json.null) end),
  json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail") }),
  enrichment_options(),
  recursive_authority({ remaining_steps = 500, required_steps = 0 })
)
check_equal(narrowed.resources.remaining_steps, 200, "caller step ceiling narrows authority")

local node_options = enrichment_options()
node_options.caller_ceilings.max_result_nodes = 5
local node_calls = 0
local node_limit_ok, node_limit = capture(function()
  return staged_ast_enrichment.enrich_recursively(
    enrichment_registry(function()
      node_calls = node_calls + 1
      return staged_ast_enrichment.child_success(json.harray({ kind = "leaf", value = 1 }))
    end),
    json.harray({
      nodes = json.array({
        json.harray({ payload = enrichment_marker("a", 0, "replace_marker", nil, "fail") }),
        json.harray({ payload = enrichment_marker("b", 1, "replace_marker", nil, "fail") }),
      }),
    }),
    node_options,
    recursive_authority()
  )
end)
check_equal(node_limit_ok, false, "cumulative result-node limit rejects")
check_equal(
  enrichment_error_code(node_limit),
  "staged_result_node_limit_exceeded",
  "cumulative result-node diagnostic"
)
check(enrichment_diagnostic_is_complete(node_limit), "cumulative result-node context complete")
check_equal(node_calls, 2, "cumulative result-node limit spans siblings")

local direct_rebased = staged_ast_enrichment.enrich_recursively(
  enrichment_registry(function(_, context)
    check_same_json(
      staged_ast_enrichment.rebase_position(context, 1),
      json.harray({ source_id = "ascii", offset = 2 }),
      "direct position rebasing"
    )
    check_same_json(
      staged_ast_enrichment.rebase_span(context, json.harray({ start = 1, ["end"] = 3 })),
      json.harray({
        kind = "direct_span",
        source_id = "ascii",
        start = 2,
        ["end"] = 4,
        provenance = "capture",
      }),
      "direct span rebasing"
    )
    return staged_ast_enrichment.child_failure(json.harray({
      code = "child_parse_error",
      position = json.harray({ offset = 1 }),
      span = json.harray({ start = 1, ["end"] = 3 }),
      end_offset = 3,
    }))
  end),
  json.harray({ payload = enrichment_marker("abcd", 1, "replace_marker", nil, "keep_text") }),
  enrichment_options(),
  recursive_authority()
)
local direct_child = direct_rebased.diagnostics[1].child_diagnostic
check_same_json(direct_child.position, json.harray({ source_id = "ascii", offset = 2 }), "direct diagnostic position")
check_equal(direct_child.span.kind, "direct_span", "direct diagnostic span kind")
check_equal(direct_child.span.start, 2, "direct diagnostic span start")
check_equal(direct_child.span["end"], 4, "direct diagnostic span end")
check_same_json(direct_child.end_offset, json.harray({ source_id = "ascii", offset = 4 }), "direct diagnostic offset")

local derived_marker = enrichment_marker("abcd", 0, "replace_marker", nil, "keep_text")
derived_marker.staged_parse_job_v2.provenance = json.harray({
  kind = "derived_text",
  policy = "concatenate_in_order",
  segments = json.array({
    json.harray({ kind = "direct_span", source_id = "ascii", start = 0, ["end"] = 2, provenance = "capture" }),
    json.harray({ kind = "direct_span", source_id = "unicode", start = 1, ["end"] = 3, provenance = "capture" }),
  }),
})
local derived = staged_ast_enrichment.enrich_recursively(
  enrichment_registry(function(_, context)
    check_same_json(
      staged_ast_enrichment.rebase_position(context, 2),
      json.harray({ source_id = "unicode", offset = 1 }),
      "derived position rebasing"
    )
    local span = staged_ast_enrichment.rebase_span(
      context,
      json.harray({ start = 1, ["end"] = 3 })
    )
    check_equal(span.kind, "derived_text", "derived span kind")
    check_equal(#span.segments, 2, "derived span segment count")
    return staged_ast_enrichment.child_failure(json.harray({
      code = "child_parse_error",
      span = json.harray({ start = 1, ["end"] = 3 }),
    }))
  end),
  json.harray({ payload = derived_marker }),
  enrichment_options(),
  recursive_authority()
)
check_equal(derived.diagnostics[1].child_diagnostic.span.kind, "derived_text", "derived diagnostic span")
check_equal(#derived.diagnostics[1].child_diagnostic.span.segments, 2, "derived diagnostic segments")

local invalid_range = staged_ast_enrichment.enrich_recursively(
  enrichment_registry(function()
    return staged_ast_enrichment.child_failure(json.harray({
      code = "child_parse_error",
      span = json.harray({ start = 1, ["end"] = 99 }),
    }))
  end),
  json.harray({ payload = enrichment_marker("abcd", 0, "replace_marker", nil, "keep_text") }),
  enrichment_options(),
  recursive_authority()
)
check_same_json(
  invalid_range.diagnostics[1].child_diagnostic,
  json.harray({ code = "child_parse_error", source_projection = "invalid_local_range" }),
  "invalid local diagnostic range"
)

local diagnostic_options = enrichment_options()
diagnostic_options.caller_ceilings.max_diagnostic_bytes = 64
local truncated = staged_ast_enrichment.enrich_recursively(
  enrichment_registry(function()
    return staged_ast_enrichment.child_failure(json.harray({
      code = "child_parse_error",
      detail = string.rep("x", 1024),
    }))
  end),
  json.harray({ payload = enrichment_marker("bad", 0, "replace_marker", nil, "keep_text") }),
  diagnostic_options,
  recursive_authority()
)
check_equal(truncated.diagnostics[1].code, "staged_diagnostic_truncated", "diagnostic truncation")
check_equal(truncated.resources.remaining_diagnostic_bytes, 0, "diagnostic bytes are cumulative")

local safe_cancel_checks = 0
local safe_cancel_ok, safe_cancel = capture(function()
  return staged_ast_enrichment.enrich_recursively(
    enrichment_registry(function(_, context)
      staged_ast_enrichment.safe_point(context, 0)
      return staged_ast_enrichment.child_success(json.null)
    end),
    json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail") }),
    enrichment_options(),
    recursive_authority({
      cancelled = function()
        safe_cancel_checks = safe_cancel_checks + 1
        return safe_cancel_checks >= 2
      end,
    })
  )
end)
check_equal(safe_cancel_ok, false, "safe-point cancellation rejects")
check_equal(enrichment_error_code(safe_cancel), "staged_cancelled", "safe-point cancellation diagnostic")
check(enrichment_diagnostic_is_complete(safe_cancel), "safe-point cancellation context complete")

local safe_clock_checks = 0
local safe_deadline_ok, safe_deadline = capture(function()
  return staged_ast_enrichment.enrich_recursively(
    enrichment_registry(function(_, context)
      staged_ast_enrichment.safe_point(context, 0)
      return staged_ast_enrichment.child_success(json.null)
    end),
    json.harray({ payload = enrichment_marker("x", 0, "replace_marker", nil, "fail") }),
    enrichment_options(),
    recursive_authority({
      deadline = 10,
      clock = function()
        safe_clock_checks = safe_clock_checks + 1
        return safe_clock_checks == 1 and 1 or 11
      end,
    })
  )
end)
check_equal(safe_deadline_ok, false, "safe-point deadline rejects")
check_equal(enrichment_error_code(safe_deadline), "staged_deadline_exceeded", "safe-point deadline diagnostic")
check(enrichment_diagnostic_is_complete(safe_deadline), "safe-point deadline context complete")

local production_parsed, production_compiled = compile_source(PRODUCTION_SOURCE)
local raw_production = linkedspec.runtime_parse(linkedspec.runtime_engine(production_compiled), "1+2;").value
check_equal(raw_production.kind, "STAGED_PARSE_JOB_MARKER", "dormant route stays raw without seed")
local observations = { starts = {}, callbacks = {}, cancellation_checks = {}, clock_checks = {} }
local seed = production_seed(observations, false)
check_equal(tostring(seed), "StagedAstEnrichmentSeed(<opaque>)", "production seed stays opaque")
local invalid_engine_ok = capture(function()
  return linkedspec.runtime_engine(production_compiled, { staged_ast_enrichment_seed = "not-a-seed" })
end)
check_equal(invalid_engine_ok, false, "production engine rejects non-seed")

local native_engine = linkedspec.runtime_engine(production_compiled, { staged_ast_enrichment_seed = seed })
local production_values = json.array()
for _ = 1, 2 do
  production_values[#production_values + 1] = linkedspec.runtime_parse(native_engine, "1+2;").value
end
local production_normalized = json.decode(json.encode(linkedspec.spec_ast.to_json(production_parsed)))
local production_reconstructed_ast = linkedspec.spec_ast.from_json("SpecFile", production_normalized)
linkedspec.validate_spec(production_reconstructed_ast)
local production_reconstructed = linkedspec.compile_spec(production_reconstructed_ast)
local reconstructed_engine = linkedspec.runtime_engine(
  production_reconstructed,
  { staged_ast_enrichment_seed = seed }
)
for _ = 1, 2 do
  production_values[#production_values + 1] = linkedspec.runtime_parse(reconstructed_engine, "1+2;").value
end
local production_plan = linkedspec.build_generated_rule_plan(production_compiled)
for _ = 1, 2 do
  production_values[#production_values + 1] = linkedspec.execute_generated_parser_v2(
    production_compiled,
    production_plan,
    "1+2;",
    SOURCE_IDENTITY,
    { staged_ast_enrichment_seed = seed }
  )
end
local production_emitted = linkedspec.emit_lua_source_v2(production_compiled, EMITTED_IDENTITY)
local production_chunk, production_load_error = loader(
  production_emitted,
  "@staged_ast_enrichment_production_generated.lua"
)
check(production_chunk ~= nil, "production emitted module loads: " .. tostring(production_load_error))
if production_chunk ~= nil then
  local production_module = production_chunk()
  for _ = 1, 2 do
    production_values[#production_values + 1] = production_module.execute(
      "1+2;",
      { staged_ast_enrichment_seed = seed }
    )
  end
end
check_equal(#production_values, 8, "all production carrier executions")
for index, value in ipairs(production_values) do
  check_same_json(value.ast, json.harray({ kind = "expression", text = "1+2", top_rule = "Expr" }), "production AST " .. index)
  check_equal(#value.diagnostics, 0, "production diagnostics " .. index)
  check_equal(#value.sidecars, 1, "production sidecar count " .. index)
  check_equal(value.sidecars[1].state, "succeeded", "production sidecar state " .. index)
  check_equal(value.cache.entries, 1, "production cache entry " .. index)
  check_equal(value.cache.hits, 0, "production cache hit " .. index)
  check_equal(value.cache.misses, 1, "production cache miss " .. index)
  check_equal(value.resources.total_calls, 1, "production call count " .. index)
  if index > 1 then check_same_json(value, production_values[1], "production route parity " .. index) end
end
check_equal(#observations.starts, 8, "fresh production starts")
check_equal(#observations.callbacks, 8, "fresh production callbacks")
for index, row in ipairs(observations.starts) do
  check_equal(row.run_id, index, "fresh production run id " .. index)
  check_equal(row.token.run_id, index, "fresh production token " .. index)
end
for index, row in ipairs(observations.callbacks) do
  check_equal(row.run_id, index, "callback run id " .. index)
  check_equal(row.token.run_id, index, "callback token " .. index)
  check_equal(row.text, "1+2", "callback text " .. index)
end

local parent_failure_observations = {
  starts = {}, callbacks = {}, cancellation_checks = {}, clock_checks = {},
}
local parent_failure_seed = production_seed(parent_failure_observations, false)
local _, parent_failure_compiled = compile_source([[Top::
 /([^;]+);/
 E {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail", "required_capabilities", array("typed-source-location-v1")))
  fail("parent failed")
  return(job_marker)
 }
]])
local parent_failure_ok = capture(function()
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(parent_failure_compiled, {
      staged_ast_enrichment_seed = parent_failure_seed,
    }),
    "1+2;"
  )
end)
check_equal(parent_failure_ok, false, "parent failure rejects before staged execution")
check_equal(#parent_failure_observations.starts, 0, "parent failure consumes no staged authority")

local transaction_observations = {
  starts = {}, callbacks = {}, cancellation_checks = {}, clock_checks = {},
}
local transaction_seed = production_seed(transaction_observations, false)
local transaction_execution = staged_ast_enrichment.start_execution(transaction_seed)
local transaction_ok, transaction_error = capture(function()
  return staged_ast_enrichment.complete_execution(transaction_execution, raw_production, true)
end)
check_equal(transaction_ok, false, "live recognition transaction rejects staged execution")
check_equal(
  enrichment_error_code(transaction_error),
  "staged_transaction_forbidden",
  "live recognition transaction diagnostic"
)
check(enrichment_diagnostic_is_complete(transaction_error), "live transaction context complete")
local reused_ok, reused = capture(function()
  return staged_ast_enrichment.complete_execution(transaction_execution, raw_production, false)
end)
check_equal(reused_ok, false, "staged execution state expires after denial")
check_equal(enrichment_error_code(reused), "staged_registry_snapshot_invalid", "expired execution diagnostic")
local detached_probe = production_values[1]
detached_probe.ast.kind = "mutated"
for index = 2, #production_values do
  check_equal(production_values[index].ast.kind, "expression", "production outputs detached " .. index)
end
local portable_production_plan = json.array()
for index, row in ipairs(production_plan) do
  portable_production_plan[index] = json.harray({ label = row.label, family = row.family })
end
for _, artifact in ipairs({
  json.encode(linkedspec.spec_ast.to_json(production_parsed)),
  json.encode(portable_production_plan),
  production_emitted,
}) do
  for _, forbidden in ipairs({
    "authority_factory",
    "compiled_authorities",
    "recursive_authority",
    "cancellation_token",
    "mutable_queue",
    "run_id",
  }) do
    check_equal(count_literal(artifact, forbidden), 0, "logical artifact excludes " .. forbidden)
  end
end

local failure_observations = { starts = {}, callbacks = {}, cancellation_checks = {}, clock_checks = {} }
local failure_seed = production_seed(failure_observations, true)
local native_failure_ok, native_failure = capture(function()
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(production_compiled, { staged_ast_enrichment_seed = failure_seed }),
    "1+2;"
  )
end)
local generated_failure_ok, generated_failure = capture(function()
  return linkedspec.execute_generated_parser_v2(
    production_compiled,
    production_plan,
    "1+2;",
    SOURCE_IDENTITY,
    { staged_ast_enrichment_seed = failure_seed }
  )
end)
check_equal(native_failure_ok, false, "native staged failure preserved")
check_equal(generated_failure_ok, false, "generated staged failure preserved")
check_equal(enrichment_error_code(native_failure), "staged_child_failed", "native staged failure identity")
check_equal(enrichment_error_code(generated_failure), "staged_child_failed", "generated staged failure identity")
check(enrichment_diagnostic_is_complete(native_failure), "native staged failure context complete")
check(enrichment_diagnostic_is_complete(generated_failure), "generated staged failure context complete")
end)()

check(file_exists(CONSUMER_PATH), "stable final-path consumer exists")
local ordinary = read_file("tools/run_lua_local.sh")
local inline_ordinary = read_file("lua/test/run.lua")
local canonical = read_file("tools/run_ci_local.sh")
local lua_admission = contract.canonical_execution.lua_admission
check(
  count_literal(ordinary, CONSUMER_PATH) == 2 and
    count_literal(ordinary, '"$LUA_CMD" ' .. CONSUMER_PATH) == 1 and
    count_literal(ordinary, '"$LUAJIT_CMD" ' .. CONSUMER_PATH) == 1,
  "ordinary discovery runs the consumer exactly once per ABI"
)
check_equal(count_literal(inline_ordinary, "staged_ast_enrichment_contract_test.lua"), 0, "consumer absent from inline suite")
check(
  count_literal(canonical, "require_tracked_file " .. CONSUMER_PATH) == 1 and
    count_literal(canonical, lua_admission.puc_registration_marker) == 1 and
    count_literal(canonical, lua_admission.puc_invocation) == 1 and
    count_literal(canonical, lua_admission.luajit_registration_marker) == 1 and
    count_literal(canonical, lua_admission.luajit_invocation) == 1,
  "canonical discovery requires and runs one exact route per ABI"
)
local umbrella = read_file("lua/src/linkedspec/init.lua")
for _, private_token in ipairs({
  "parse_job(text_expr",
  "STAGED_PARSE_JOB_MARKER",
  "staged_ast_enrichment",
  CONTRACT_ID,
}) do
  check_equal(count_literal(umbrella, private_token), 0, "outward token absent: " .. private_token)
end

check(
  type(staged_ast_enrichment.enrich_recursively) == "function",
  "recursive enrichment implementation remains present"
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
