-- FUTURE-PARITY-BACKLOG.10.7.7 — composed dual-ABI Lua semantic admission.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local sha256 = require("linkedspec.sha256")

local CONSUMER = "lua/test/semantic_introspection_lua_admission_test.lua"
local CANONICAL_DRIVER = "tools/run_ci_local.sh"
local RUNTIME_IDENTITY = "semantic-introspection/runtime.spec"
local RUNTIME_DIGEST = "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887"
local ROLES = json.array({
  "source_normalization",
  "compiled_snapshots",
  "failed_snapshot",
  "runtime_direct",
  "runtime_loaded",
  "runtime_generated",
  "runtime_traced",
  "native_and_neutral_json",
  "exact_twenty_queries",
  "privacy_page_budget_error_explain",
  "query_non_interference",
  "stale_host_leak_denial",
})

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

local function check_contains(actual, expected, label)
  check(tostring(actual):find(expected, 1, true) ~= nil, (label or "text differs") ..
    ": expected to contain " .. expected .. ", got " .. tostring(actual))
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

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then return first == 0 end
  return first == true and (third == nil or third == 0)
end

local function with_temp_directory(operation)
  local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
  assert(temp_root ~= "", "TMPDIR must not be empty")
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-semantic-admission.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean semantic-admission test directory", 0) end
  if not ok then error(value, 0) end
  return value
end

local function clone(value)
  return json.decode(json.encode(value))
end

local function compile(source)
  local parsed = linkedspec.parse_spec(source)
  linkedspec.validate_spec(parsed)
  return linkedspec.compile_spec(parsed)
end

local function load_generated(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local function collect(events)
  return function(event) events[#events + 1] = event end
end

local function plain_sequence(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function typed_request(value)
  local after_id = value.page.after_id
  if after_id == json.null then after_id = nil end
  return linkedspec.semantic_query_request(value.operation, {
    contract = value.contract,
    subjects = plain_sequence(value.subjects),
    record_kinds = plain_sequence(value.record_kinds),
    relation_kinds = plain_sequence(value.relation_kinds),
    direction = value.direction,
    page = { after_id = after_id, limit = value.page.limit },
    budget = {
      max_records = value.budget.max_records,
      max_relations = value.budget.max_relations,
      max_depth = value.budget.max_depth,
    },
    source = {
      detail = value.source.detail,
      include_content_digest = value.source.include_content_digest,
    },
  })
end

local function ids(values)
  local result = json.array()
  for index, value in ipairs(values) do result[index] = value.id end
  return result
end

local function diagnostic_codes(values)
  local result = json.array()
  for index, value in ipairs(values) do result[index] = value.code end
  return result
end

local function response_digest(response)
  return sha256.hex(json.encode(linkedspec.semantic_query_to_json(response)))
end

local function event_json(events)
  local result = json.array()
  for index, event in ipairs(events) do
    result[index] = linkedspec.runtime_semantic_observation_event_to_json(event)
  end
  return result
end

local function find_by_id(values, id, label)
  for _, value in ipairs(values) do
    if value.id == id then return value end
  end
  error("missing " .. (label or "row") .. " " .. id, 0)
end

local contract = json.decode(read_file(
  "capability_conformance/semantic_introspection_contract.json"
))
local sources = {
  graph = read_file("capability_conformance/semantic_introspection/graph.spec"),
  calls_and_staging = read_file(
    "capability_conformance/semantic_introspection/calls_and_staging.spec"
  ),
  failed = read_file("capability_conformance/semantic_introspection/failed.spec"),
  runtime = read_file("capability_conformance/semantic_introspection/runtime.spec"),
  privacy = read_file("capability_conformance/semantic_introspection/privacy.spec"),
}
local runtime_input = read_file("capability_conformance/semantic_introspection/runtime.input")
local runtime_compiled = compile(sources.runtime)
local runtime_plan = linkedspec.build_generated_rule_plan(runtime_compiled)
local runtime_base = linkedspec.semantic_index(sources.runtime, {
  logical_name = "runtime.spec",
  source_detail_ceiling = "text",
})
local indexes = {}
local responses = json.harray({})
local direct_events = nil
local runtime_index = nil

local expected_events = json.array({
  json.harray({
    contract_id = linkedspec.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
    event_kind = "regex_slot_selected",
    rule_label = "Top",
    target_rule = "Top",
    regex_index = 0,
    position = 1,
    input_identity = json.null,
    status = json.null,
  }),
  json.harray({
    contract_id = linkedspec.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
    event_kind = "regex_slot_selected",
    rule_label = "Top",
    target_rule = "Top",
    regex_index = 1,
    position = 2,
    input_identity = json.null,
    status = json.null,
  }),
  json.harray({
    contract_id = linkedspec.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
    event_kind = "rule_result",
    rule_label = "Top",
    target_rule = json.null,
    regex_index = json.null,
    position = 2,
    input_identity =
      "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece",
    status = "succeeded",
  }),
})

local function query_case(id)
  return find_by_id(contract.query_cases, id, "semantic query case")
end

local function index_for(snapshot)
  if snapshot == "runtime" then
    if runtime_index == nil then error("runtime admission index is not captured", 0) end
    return runtime_index
  end
  if indexes[snapshot] ~= nil then return indexes[snapshot] end
  local fixture, logical_name, ceiling
  if snapshot == "graph" then
    fixture, logical_name, ceiling = "graph", "graph.spec", "text"
  elseif snapshot == "calls" then
    fixture, logical_name, ceiling = "calls_and_staging", "calls_and_staging.spec", "text"
  elseif snapshot == "failed" then
    fixture, logical_name, ceiling = "failed", "failed.spec", "span"
  elseif snapshot == "privacy" then
    fixture, logical_name, ceiling = "privacy", "privacy.spec", "text"
  elseif snapshot == "privacy_limited" then
    fixture, logical_name, ceiling = "privacy", "privacy.spec", "identity"
  else
    error("unexpected semantic admission snapshot " .. tostring(snapshot), 0)
  end
  indexes[snapshot] = linkedspec.semantic_index(sources[fixture], {
    logical_name = logical_name,
    source_detail_ceiling = ceiling,
  })
  return indexes[snapshot]
end

local function assert_case(index, governed)
  local request_value = clone(governed.request)
  local request_before = clone(request_value)
  local typed = governed.id == "capabilities" and index:capabilities() or
    index:query(typed_request(request_value))
  local neutral = index:query_neutral(request_value)
  local expected = governed.expected
  check_same_json(request_value, request_before, governed.id .. " request remains immutable")
  check_same_json(linkedspec.semantic_query_to_json(typed),
    linkedspec.semantic_query_to_json(neutral), governed.id .. " native/neutral identity")
  check_equal(typed.ok, expected.ok, governed.id .. " status")
  check_same_json(ids(typed.records), expected.record_ids, governed.id .. " record ids")
  check_same_json(ids(typed.relations), expected.relation_ids, governed.id .. " relation ids")
  check_same_json(diagnostic_codes(typed.diagnostics), expected.diagnostic_codes,
    governed.id .. " diagnostic codes")
  check_equal(typed.page.complete, expected.complete, governed.id .. " page completeness")
  check_equal(response_digest(typed), expected.response_sha256, governed.id .. " response digest")
  return typed
end

local function capture(route, invoke)
  local events = {}
  local value = invoke(collect(events))
  check_same_json(value, json.array({ "A", "B" }), route .. " result")
  check_same_json(event_json(events), expected_events, route .. " events")
  local derived = runtime_base:with_execution_observation(events)
  local response = assert_case(derived, query_case("runtime_events"))
  check_equal(response_digest(response), RUNTIME_DIGEST, route .. " governed digest")
  return events, derived
end

local isolated_result = nil

local function isolated_emitted(emitted_source)
  return with_temp_directory(function(root)
    local module_path = root .. "/runtime_generated.lua"
    local runner_path = root .. "/runner.lua"
    local stdout_path = root .. "/stdout.json"
    local stderr_path = root .. "/stderr.txt"
    write_file(module_path, emitted_source)
    write_file(runner_path, [[
local linkedspec = require("linkedspec")
local json = linkedspec.json
local sha256 = require("linkedspec.sha256")
local module = assert(loadfile(arg[1]))()
local input = "ab\n"
local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end
local source = read_file("capability_conformance/semantic_introspection/runtime.spec")
local contract = json.decode(read_file(
  "capability_conformance/semantic_introspection_contract.json"
))
local runtime_request
for _, row in ipairs(contract.query_cases) do
  if row.id == "runtime_events" then runtime_request = row.request end
end
local base = linkedspec.semantic_index(source, {
  logical_name = "runtime.spec",
  source_detail_ceiling = "text",
})
local direct_events = {}
local direct = module.execute(input, {
  semantic_observation_sink = function(event) direct_events[#direct_events + 1] = event end,
})
local trace = {}
local traced_events = {}
local traced = module.execute_with_trace(input, linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
  semantic_observation_sink = function(event) traced_events[#traced_events + 1] = event end,
  stdout_writer = function(payload) trace[#trace + 1] = payload end,
})
local function project(events)
  local result = json.array()
  for index, event in ipairs(events) do
    result[index] = linkedspec.runtime_semantic_observation_event_to_json(event)
  end
  return result
end
local function digest(events)
  local response = base:with_execution_observation(events):query_neutral(runtime_request)
  return sha256.hex(json.encode(linkedspec.semantic_query_to_json(response)))
end
io.write(json.encode(json.harray({
  direct = direct,
  traced = traced,
  direct_events = project(direct_events),
  traced_events = project(traced_events),
  direct_digest = digest(direct_events),
  traced_digest = digest(traced_events),
  trace_nonempty = table.concat(trace) ~= "",
})), "\n")
]])
    local runtime = os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME") or
      (type(jit) == "table" and "luajit" or "lua")
    local command = table.concat({
      "env LUA_PATH=" .. shell_quote(os.getenv("LUA_PATH") or ""),
      "LUA_CPATH=" .. shell_quote(os.getenv("LUA_CPATH") or ""),
      shell_quote(runtime), shell_quote(runner_path), shell_quote(module_path),
      ">" .. shell_quote(stdout_path), "2>" .. shell_quote(stderr_path),
    }, " ")
    check_equal(command_succeeded(command), true, "isolated emitted host status")
    check_equal(read_file(stderr_path), "", "isolated emitted host stderr")
    return json.decode(read_file(stdout_path))
  end)
end

local function role_source_normalization()
  -- Lua's native source carrier is a byte string; this makes a distinct decoded-equivalent copy.
  local bytes = sources.privacy
  local text = table.concat({ bytes:sub(1, #bytes) })
  local from_bytes = linkedspec.semantic_index(bytes, {
    logical_name = "privacy.spec", source_detail_ceiling = "text",
  })
  local from_text = linkedspec.semantic_index(text, {
    logical_name = "privacy.spec", source_detail_ceiling = "text",
  })
  local governed = query_case("privacy_text_and_digest")
  check_same_json(linkedspec.semantic_query_to_json(assert_case(from_bytes, governed)),
    linkedspec.semantic_query_to_json(assert_case(from_text, governed)),
    "native byte-string and decoded-equivalent source identity")
end

local function role_compiled_snapshots()
  local cases = {
    { "graph", "graph_list_rules" },
    { "calls", "calls_symbols_and_shapes" },
    { "privacy", "privacy_text_and_digest" },
    { "privacy_limited", "source_ceiling_forbidden" },
  }
  for _, row in ipairs(cases) do
    local index = index_for(row[1])
    check_equal(index:compilation_authority().compiled, true, row[1] .. " compiled authority")
    check_equal(index:semantic_snapshot().has_execution, false, row[1] .. " static snapshot")
    assert_case(index, query_case(row[2]))
  end
end

local function role_failed_snapshot()
  local index = index_for("failed")
  check_equal(index:compilation_authority().compiled, false, "failed snapshot lacks compile authority")
  check_equal(index:semantic_snapshot().state, "failed_compilation", "failed snapshot state")
  assert_case(index, query_case("failed_diagnostic"))
end

local function role_runtime_direct()
  direct_events, runtime_index = capture("native direct", function(sink)
    return linkedspec.runtime_parse(linkedspec.runtime_engine(runtime_compiled), runtime_input, {
      semantic_observation_sink = sink,
    }).value
  end)
end

local function role_runtime_loaded()
  with_temp_directory(function(root)
    write_file(root .. "/runtime.spec", sources.runtime)
    local loaded = linkedspec.load_and_compile_spec(
      linkedspec.path_spec_request("runtime.spec"),
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    local loaded_events = capture("loaded", function(sink)
      return linkedspec.runtime_parse(loaded:create_engine(), runtime_input, {
        semantic_observation_sink = sink,
      }).value
    end)
    check_same_json(event_json(loaded_events), event_json(direct_events), "loaded/direct event identity")

    local normalized = clone(linkedspec.spec_ast.to_json(linkedspec.parse_spec(sources.runtime)))
    local reconstructed = linkedspec.spec_ast.from_json("SpecFile", normalized)
    linkedspec.validate_spec(reconstructed)
    local reconstructed_events = capture("reconstructed AST", function(sink)
      return linkedspec.runtime_parse(
        linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed)), runtime_input,
        { semantic_observation_sink = sink }
      ).value
    end)
    check_same_json(event_json(reconstructed_events), event_json(direct_events),
      "reconstructed/direct event identity")
  end)
end

local function role_runtime_generated()
  local helper_events = capture("generated public helper", function(sink)
    return linkedspec.execute_generated_parser_v2(
      runtime_compiled, runtime_plan, runtime_input, RUNTIME_IDENTITY,
      { semantic_observation_sink = sink }
    )
  end)
  check_same_json(event_json(helper_events), event_json(direct_events),
    "generated helper/direct event identity")

  local emitted_source = linkedspec.emit_lua_source_v2(runtime_compiled, RUNTIME_IDENTITY)
  local emitted = load_generated(emitted_source, "@semantic-introspection-lua-admission")
  local emitted_events = capture("fresh emitted direct", function(sink)
    return emitted.execute(runtime_input, { semantic_observation_sink = sink })
  end)
  check_same_json(event_json(emitted_events), event_json(direct_events),
    "fresh emitted/direct event identity")

  local emitted_trace = {}
  local emitted_traced_events = capture("fresh emitted traced", function(sink)
    return emitted.execute_with_trace(
      runtime_input, linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
        semantic_observation_sink = sink,
        stdout_writer = function(payload) emitted_trace[#emitted_trace + 1] = payload end,
      }
    )
  end)
  check(table.concat(emitted_trace) ~= "", "fresh emitted trace is nonempty")
  check_same_json(event_json(emitted_traced_events), event_json(direct_events),
    "fresh emitted traced/direct event identity")

  isolated_result = isolated_emitted(emitted_source)
  check_same_json(isolated_result.direct, json.array({ "A", "B" }), "isolated direct result")
  check_same_json(isolated_result.traced, isolated_result.direct, "isolated traced result")
  check_equal(isolated_result.trace_nonempty, true, "isolated trace is nonempty")
  check_same_json(isolated_result.direct_events, expected_events, "isolated direct events")
  check_same_json(isolated_result.traced_events, expected_events, "isolated traced events")
  check_equal(isolated_result.direct_digest, RUNTIME_DIGEST, "isolated direct digest")
  check_equal(isolated_result.traced_digest, RUNTIME_DIGEST, "isolated traced digest")
end

local function role_runtime_traced()
  local native_trace = {}
  local native_events = capture("native traced", function(sink)
    return linkedspec.runtime_parse_with_trace(
      linkedspec.runtime_engine(runtime_compiled), runtime_input,
      linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
        semantic_observation_sink = sink,
        stdout_writer = function(payload) native_trace[#native_trace + 1] = payload end,
      }
    ).value
  end)
  check(table.concat(native_trace) ~= "", "native trace is nonempty")
  check_same_json(event_json(native_events), event_json(direct_events),
    "native traced/direct event identity")

  local generated_trace = {}
  local generated_events = capture("generated helper traced", function(sink)
    return linkedspec.execute_generated_parser_with_trace_v2(
      runtime_compiled, runtime_plan, runtime_input,
      linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), RUNTIME_IDENTITY, {
        semantic_observation_sink = sink,
        stdout_writer = function(payload) generated_trace[#generated_trace + 1] = payload end,
      }
    )
  end)
  check(table.concat(generated_trace) ~= "", "generated helper trace is nonempty")
  check_same_json(event_json(generated_events), event_json(direct_events),
    "generated traced/direct event identity")
end

local function role_native_and_neutral_json()
  local index = index_for("graph")
  local governed = query_case("capabilities")
  local request = clone(governed.request)
  local native = index:capabilities()
  local neutral = index:query_neutral(request)
  check_same_json(linkedspec.semantic_query_to_json(native),
    linkedspec.semantic_query_to_json(neutral), "capabilities native/neutral identity")
  check_same_json(clone(linkedspec.semantic_query_to_json(native)),
    linkedspec.semantic_query_to_json(native), "capabilities JSON round trip")
  local detached = linkedspec.semantic_query_to_json(native)
  detached.records[1].facts.record_kinds[1] = "host_private_kind"
  check_equal(response_digest(index:capabilities()), governed.expected.response_sha256,
    "detached capabilities JSON cannot mutate native response")
end

local function role_exact_twenty_queries()
  check_equal(#contract.query_cases, 20, "exact governed query count")
  for _, governed in ipairs(contract.query_cases) do
    local response = assert_case(index_for(governed.snapshot), governed)
    responses[governed.id] = linkedspec.semantic_query_to_json(response)
  end
end

local function role_privacy_page_budget_error_explain()
  local none = responses.privacy_none.records[1]
  check_equal(none.source, json.null, "privacy none source is null")
  check_same_json(none.redactions, json.array({ "/facts/pattern" }), "privacy none redactions")
  local text = responses.privacy_text_and_digest.records[1]
  check_equal(text.facts.pattern, "é", "privacy text is exact UTF-8")
  check(tostring(text.source.content_digest):match("^sha256:[0-9a-f]+$") ~= nil and
    #text.source.content_digest == 71, "privacy content digest shape")
  check_equal(responses.source_ceiling_forbidden.ok, false, "source ceiling denied")
  for _, id in ipairs({ "pagination_after_id", "page_boundary" }) do
    check_equal(responses[id].page.complete, query_case(id).expected.complete,
      id .. " page completion")
  end
  for _, row in ipairs({
    { "budget_prefix", "semantic_query_budget_exceeded" },
    { "relation_budget_prefix", "semantic_query_budget_exceeded" },
    { "unsupported_contract", "semantic_query_contract_unsupported" },
    { "invalid_operation_combination", "semantic_query_invalid" },
  }) do
    check_equal(responses[row[1]].diagnostics[1].code, row[2], row[1] .. " diagnostic")
  end
  local has_explanation = false
  for _, record in ipairs(responses.graph_explain_entry.records) do
    if record.kind == "explanation_step" then has_explanation = true end
  end
  check(has_explanation, "explain response contains explanation step")
end

local function role_query_non_interference()
  local index = index_for("graph")
  local governed = query_case("graph_explain_entry")
  local request = clone(governed.request)
  check_equal(index:semantic_snapshot().has_execution, false, "query source begins static")
  local first = index:query_neutral(request)
  local second = index:query_neutral(request)
  check_same_json(linkedspec.semantic_query_to_json(first),
    linkedspec.semantic_query_to_json(second), "repeated query identity")
  check_equal(index:semantic_snapshot().has_execution, false, "query source remains static")
  check_equal(runtime_base:semantic_snapshot().has_execution, false, "runtime base remains static")
  local detached = linkedspec.semantic_query_to_json(first)
  detached.records[1].facts.outcome = "mutated"
  check_equal(response_digest(index:query_neutral(request)), governed.expected.response_sha256,
    "detached response cannot alter fresh query")

  local implementation = read_file("lua/src/linkedspec/semantic_query.lua")
  check_equal(implementation:find('require("linkedspec.json")', 1, true) ~= nil, true,
    "query kernel retains neutral JSON dependency")
  for _, forbidden in ipairs({
    'require("linkedspec.semantic_index")',
    'require("linkedspec.spec_parser")',
    'require("linkedspec.spec_validator")',
    'require("linkedspec.action_parser")',
    'require("linkedspec.source_emitter")',
    'require("linkedspec.interpreter")',
    "io.open(", "io.popen(", "os.getenv(", "os.time(", "math.random(", "debug.",
  }) do
    check_equal(implementation:find(forbidden, 1, true), nil,
      "query kernel omits forbidden authority " .. forbidden)
  end
end

local function role_stale_host_leak_denial()
  local encoded = json.encode(responses)
  for _, forbidden in ipairs({
    "/" .. "Users/", "/private" .. "/tmp/", "CompiledSpec", "ActionIR", "SpecFile",
    "RuntimeSemanticObservationEvent", "generated_implementation_source",
    "table:", "userdata:", "0x",
  }) do
    check_equal(encoded:find(forbidden, 1, true), nil, "responses deny host leak " .. forbidden)
  end
end

local role_functions = {
  source_normalization = role_source_normalization,
  compiled_snapshots = role_compiled_snapshots,
  failed_snapshot = role_failed_snapshot,
  runtime_direct = role_runtime_direct,
  runtime_loaded = role_runtime_loaded,
  runtime_generated = role_runtime_generated,
  runtime_traced = role_runtime_traced,
  native_and_neutral_json = role_native_and_neutral_json,
  exact_twenty_queries = role_exact_twenty_queries,
  privacy_page_budget_error_explain = role_privacy_page_budget_error_explain,
  query_non_interference = role_query_non_interference,
  stale_host_leak_denial = role_stale_host_leak_denial,
}

local completed = {}
for _, role in ipairs(ROLES) do
  completed[role] = (completed[role] or 0) + 1
  check_equal(completed[role], 1, role .. " executes exactly once")
  role_functions[role]()
end
for _, role in ipairs(ROLES) do check_equal(completed[role], 1, role .. " completed") end

local expected_consumer = json.harray({
  path = CONSUMER,
  canonical_driver = CANONICAL_DRIVER,
  roles = clone(ROLES),
})
local admissions = {}
for _, row in ipairs(contract.target_admissions) do
  if row.backend == "lua" then admissions[row.runtime] = row end
end
for _, runtime in ipairs({ "puc_lua", "luajit" }) do
  local admission = assert(admissions[runtime], "missing Lua admission " .. runtime)
  check_equal(admission.status, "complete", runtime .. " admission status")
  check_same_json(admission.consumer, expected_consumer, runtime .. " admission consumer")
end
local rollout
for _, row in ipairs(contract.rollout) do
  if row.capability == "lua_dual_abi" then rollout = row end
end
assert(rollout, "missing semantic rollout lua_dual_abi")
check_equal(rollout.status, "complete", "Lua dual-ABI rollout status")
local canonical = false
for _, path in ipairs(contract.canonical_ci.required_tracked_files) do
  if path == CONSUMER then canonical = true end
end
check(canonical, "Lua semantic admission is canonical CI inventory")

if #failures > 0 then
  io.stderr:write("not ok - composed Lua semantic admission\n")
  for _, failure in ipairs(failures) do io.stderr:write("  " .. failure .. "\n") end
  os.exit(1)
end

print("ok - composed Lua semantic admission (" .. assertions .. " assertions)")
