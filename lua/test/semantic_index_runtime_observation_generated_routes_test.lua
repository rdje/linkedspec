-- FUTURE-PARITY-BACKLOG.10.7.6.3 — generated and emitted observation routes.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local observation = require("linkedspec.semantic_observation")
local sha256 = require("linkedspec.sha256")

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
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-semantic-routes.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean semantic-route test directory", 0) end
  if not ok then error(value, 0) end
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

local function event_json(events)
  local result = json.array()
  for index, event in ipairs(events) do
    result[index] = linkedspec.runtime_semantic_observation_event_to_json(event)
  end
  return result
end

local function query_case(contract, id)
  for _, value in ipairs(contract.query_cases) do
    if value.id == id then return value end
  end
  error("missing semantic query case " .. id, 0)
end

local canonical_source = read_file("capability_conformance/semantic_introspection/runtime.spec")
local canonical_input = read_file("capability_conformance/semantic_introspection/runtime.input")
local semantic_contract = json.decode(
  read_file("capability_conformance/semantic_introspection_contract.json")
)
local runtime_request = query_case(semantic_contract, "runtime_events").request
local runtime_digest = "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887"
local canonical_identity =
  "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece"
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
    input_identity = canonical_identity,
    status = "succeeded",
  }),
})

local compiled = compile(canonical_source)
local plan = linkedspec.build_generated_rule_plan(compiled)
local identity = "semantic-observation/generated-routes.spec"
local emitted_source = linkedspec.emit_lua_source_v2(compiled, identity)
local emitted = load_generated(emitted_source, "@semantic-observation-generated-routes")
local base = linkedspec.semantic_index(canonical_source, {
  logical_name = "runtime.spec",
  source_detail_ceiling = "text",
})

local function derived_digest(events)
  local observed = base:with_execution_observation(events)
  local response = observed:query_neutral(json.decode(json.encode(runtime_request)))
  return sha256.hex(json.encode(linkedspec.semantic_query_to_json(response)))
end

local function verify_route(label, invoke)
  local events = {}
  local value = invoke(collect(events))
  check_same_json(value, json.array({ "A", "B" }), label .. " result")
  check_same_json(event_json(events), expected_events, label .. " events")
  check_equal(derived_digest(events), runtime_digest, label .. " derived digest")
  for index, event in ipairs(events) do
    check_equal(getmetatable(event), "protected", label .. " protected event " .. index)
  end
  return value, events
end

verify_route("public generated direct", function(sink)
  return linkedspec.execute_generated_parser_v2(
    compiled, plan, canonical_input, identity, { semantic_observation_sink = sink }
  )
end)

local quiet_trace = {}
local quiet_value = linkedspec.execute_generated_parser_with_trace_v2(
  compiled,
  plan,
  canonical_input,
  linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
  identity,
  { stdout_writer = function(payload) quiet_trace[#quiet_trace + 1] = payload end }
)
local traced_events = {}
local observed_trace = {}
local traced_value = linkedspec.execute_generated_parser_with_trace_v2(
  compiled,
  plan,
  canonical_input,
  linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
  identity,
  {
    semantic_observation_sink = collect(traced_events),
    stdout_writer = function(payload) observed_trace[#observed_trace + 1] = payload end,
  }
)
check_same_json(traced_value, quiet_value, "generated traced result non-interference")
check_equal(table.concat(observed_trace), table.concat(quiet_trace), "generated trace byte identity")
check_same_json(event_json(traced_events), expected_events, "public generated traced events")
check_equal(derived_digest(traced_events), runtime_digest, "public generated traced digest")

verify_route("fresh emitted direct", function(sink)
  return emitted.execute(canonical_input, { semantic_observation_sink = sink })
end)

local emitted_failure = { id = "emitted-semantic-callback" }
local emitted_failure_events = {}
local emitted_ok, emitted_error = pcall(emitted.execute, canonical_input, {
  semantic_observation_sink = function(event)
    emitted_failure_events[#emitted_failure_events + 1] = event
    error(emitted_failure, 0)
  end,
})
check_equal(emitted_ok, false, "emitted callback failure propagated")
check_equal(emitted_error, emitted_failure, "emitted callback exact identity")
check_equal(#emitted_failure_events, 1, "emitted callback stops later events")

local emitted_trace_events = {}
local emitted_trace_output = {}
local emitted_trace_value = emitted.execute_with_trace(
  canonical_input,
  linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
  {
    semantic_observation_sink = collect(emitted_trace_events),
    stdout_writer = function(payload) emitted_trace_output[#emitted_trace_output + 1] = payload end,
  }
)
check_same_json(emitted_trace_value, quiet_value, "emitted traced result")
check_same_json(event_json(emitted_trace_events), expected_events, "emitted traced events")
check_equal(derived_digest(emitted_trace_events), runtime_digest, "emitted traced digest")
check_equal(table.concat(emitted_trace_output), table.concat(quiet_trace), "emitted trace byte identity")

check_equal(emitted_source, linkedspec.emit_lua_source_v2(compiled, identity), "deterministic emitted bytes")
check_contains(emitted_source, "linkedspec-generated-source-v2", "emitted v2 contract")
check_contains(emitted_source, "LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", "emitted format 2")
check_equal(emitted_source:find("semantic_observation_sink", 1, true), nil,
  "emitted source serializes no semantic option")
check_equal(emitted_source:find(linkedspec.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT, 1, true), nil,
  "emitted source serializes no event vocabulary")
check_equal(emitted.metadata().format_version, 2, "emitted metadata format")
for index, row in ipairs(emitted.plan()) do
  local projected = linkedspec.generated_plan_row_to_json(row)
  local keys = {}
  for key in pairs(projected) do keys[#keys + 1] = key end
  table.sort(keys)
  check_equal(table.concat(keys, ","), "family,label", "minimal generated plan row " .. index)
end

local original_slot = observation.regex_slot_selected
local original_result = observation.rule_result
local original_hash = sha256.hex
observation.regex_slot_selected = function() error("unexpected generated no-sink slot event", 0) end
observation.rule_result = function() error("unexpected generated no-sink result event", 0) end
sha256.hex = function() error("unexpected generated no-sink hash", 0) end
local no_sink_ok, no_sink_value = pcall(
  linkedspec.execute_generated_parser_v2,
  compiled,
  plan,
  canonical_input,
  identity
)
observation.regex_slot_selected = original_slot
observation.rule_result = original_result
sha256.hex = original_hash
check_equal(no_sink_ok, true, "generated no-sink path performs no observation work")
check_same_json(no_sink_value, json.array({ "A", "B" }), "generated no-sink result")

local generated_families = {}
for _, row in ipairs(plan) do generated_families[row.label] = row.family end
local unmarked_events = {}
local unmarked_ok, unmarked_error = pcall(
  linkedspec.runtime_parse,
  linkedspec.runtime_engine(compiled),
  canonical_input,
  {
    _generated_families = generated_families,
    _generated_source_identity = identity,
    semantic_observation_sink = collect(unmarked_events),
  }
)
check_equal(unmarked_ok, false, "generated runtime rejects an unmarked semantic sink")
check_equal(linkedspec.is_runtime_interpreter_error(unmarked_error), true,
  "generated unmarked sink uses native validation")
check_equal(#unmarked_events, 0, "generated unmarked sink emits no events")

local orphan_events = {}
local orphan_sink = collect(orphan_events)
local orphan_ok, orphan_error = pcall(
  linkedspec.runtime_parse,
  linkedspec.runtime_engine(compiled),
  canonical_input,
  {
    semantic_observation_sink = orphan_sink,
    _generated_semantic_observation_sink = orphan_sink,
  }
)
check_equal(orphan_ok, false, "generated semantic marker requires generated metadata")
check_equal(linkedspec.is_runtime_interpreter_error(orphan_error), true,
  "orphan generated marker uses native validation")
check_equal(#orphan_events, 0, "orphan generated marker emits no events")

local function runtime_error_value()
  local ok, value = pcall(linkedspec.runtime_parse, {}, "x")
  if ok or not linkedspec.is_runtime_interpreter_error(value) then
    error("unable to construct runtime error test value", 0)
  end
  return value
end

local callback_cases = {
  { label = "string", value = function() return "semantic-callback-string" end },
  { label = "table", value = function() return { id = "semantic-callback-table" } end },
  { label = "nil", value = function() return nil end },
  { label = "runtime error", value = runtime_error_value },
}
for _, row in ipairs(callback_cases) do
  local caller_value = row.value()
  local delivered = {}
  local invocation = 0
  local ok, value = pcall(linkedspec.execute_generated_parser_v2,
    compiled,
    plan,
    canonical_input,
    identity,
    {
      semantic_observation_sink = function(event)
        invocation = invocation + 1
        delivered[#delivered + 1] = event
        if invocation == 2 then error(caller_value, 0) end
      end,
    }
  )
  check_equal(ok, false, row.label .. " callback failure propagated")
  check_equal(value, caller_value, row.label .. " callback exact identity")
  check_equal(#delivered, 2, row.label .. " callback stops later events")
end

local traced_failure = { id = "traced-semantic-callback" }
local failure_trace = {}
local failure_events = {}
local traced_ok, traced_error = pcall(linkedspec.execute_generated_parser_with_trace_v2,
  compiled,
  plan,
  canonical_input,
  linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH),
  identity,
  {
    semantic_observation_sink = function(event)
      failure_events[#failure_events + 1] = event
      error(traced_failure, 0)
    end,
    stdout_writer = function(payload) failure_trace[#failure_trace + 1] = payload end,
  }
)
check_equal(traced_ok, false, "traced callback failure propagated")
check_equal(traced_error, traced_failure, "traced callback exact identity")
check_equal(#failure_events, 1, "traced callback stops immediately")
check_contains(table.concat(failure_trace), "error=semantic_observation_sink", "traced scope cleanup")

local diagnostic_source = [[
Top::
 /x/
 E { say("diagnostic-route"); return("ok") }
]]
local diagnostic_compiled = compile(diagnostic_source)
local diagnostic_plan = linkedspec.build_generated_rule_plan(diagnostic_compiled)
local baseline_diagnostics = {}
local baseline_value = linkedspec.execute_generated_parser_v2(
  diagnostic_compiled,
  diagnostic_plan,
  "x",
  "semantic-observation/diagnostic.spec",
  { diagnostic_sink = function(event) baseline_diagnostics[#baseline_diagnostics + 1] = event end }
)
local diagnostic_events = {}
local semantic_events = {}
local diagnostic_value = linkedspec.execute_generated_parser_v2(
  diagnostic_compiled,
  diagnostic_plan,
  "x",
  "semantic-observation/diagnostic.spec",
  {
    diagnostic_sink = function(event) diagnostic_events[#diagnostic_events + 1] = event end,
    semantic_observation_sink = collect(semantic_events),
  }
)
check_equal(diagnostic_value, baseline_value, "diagnostic co-channel result non-interference")
check_same_json(linkedspec.interpreter.to_json(diagnostic_events[1]),
  linkedspec.interpreter.to_json(baseline_diagnostics[1]),
  "diagnostic co-channel event non-interference")
check_equal(#diagnostic_events, 1, "diagnostic co-channel event count")
check_equal(#semantic_events, 2, "semantic co-channel event count")

local unmatched_compiled = compile("Top::\n /x/\n")
local unmatched_events = {}
local unmatched_value = linkedspec.execute_generated_parser_v2(
  unmatched_compiled,
  linkedspec.build_generated_rule_plan(unmatched_compiled),
  "y",
  "semantic-observation/unmatched.spec",
  { semantic_observation_sink = collect(unmatched_events) }
)
check_equal(unmatched_value, json.null, "normally unmatched value")
check_equal(#unmatched_events, 1, "normally unmatched final count")
check_equal(unmatched_events[1].event_kind, "rule_result", "normally unmatched final kind")

local exit_compiled = compile("Top::\n /x/\n E { exit_now(7); return(\"late\") }\n")
local exit_events = {}
local exit_ok, exit_value = pcall(linkedspec.execute_generated_parser_v2,
  exit_compiled,
  linkedspec.build_generated_rule_plan(exit_compiled),
  "x",
  "semantic-observation/exit.spec",
  { semantic_observation_sink = collect(exit_events) }
)
check_equal(exit_ok, false, "generated exit propagated")
check_equal(linkedspec.is_runtime_exit_now(exit_value), true, "generated exit type")
check_equal(#exit_events, 1, "generated exit omits final event")
check_equal(exit_events[1].event_kind, "regex_slot_selected", "generated exit keeps accepted slot")

local failed_compiled = compile("Top::\n /x/\n E { fail(\"boom\") }\n")
local failed_events = {}
local failed_ok, failed_value = pcall(linkedspec.execute_generated_parser_v2,
  failed_compiled,
  linkedspec.build_generated_rule_plan(failed_compiled),
  "x",
  "semantic-observation/failure.spec",
  { semantic_observation_sink = collect(failed_events) }
)
check_equal(failed_ok, false, "generated runtime failure propagated")
check_equal(linkedspec.is_generated_source_error(failed_value), true, "generated runtime failure translated")
check_equal(#failed_events, 1, "generated runtime failure omits final event")

local outer_events = {}
local inner_events = {}
local reentered = false
local reentrant_value = linkedspec.execute_generated_parser_v2(compiled, plan, canonical_input, identity, {
  semantic_observation_sink = function(event)
    outer_events[#outer_events + 1] = event
    if not reentered then
      reentered = true
      local inner_value = linkedspec.execute_generated_parser_v2(
        compiled, plan, canonical_input, identity, { semantic_observation_sink = collect(inner_events) }
      )
      check_same_json(inner_value, json.array({ "A", "B" }), "reentrant inner result")
    end
  end,
})
check_same_json(reentrant_value, json.array({ "A", "B" }), "reentrant outer result")
check_same_json(event_json(outer_events), expected_events, "reentrant outer events")
check_same_json(event_json(inner_events), expected_events, "reentrant inner events")

with_temp_directory(function(root)
  local module_path = root .. "/generated.lua"
  local runner_path = root .. "/runner.lua"
  local stdout_path = root .. "/stdout.json"
  local stderr_path = root .. "/stderr.txt"
  write_file(module_path, emitted_source)
  write_file(runner_path, [[
local linkedspec = require("linkedspec")
local json = linkedspec.json
local sha256 = require("linkedspec.sha256")
local module = assert(loadfile(arg[1]))()
local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end
local source = read_file("capability_conformance/semantic_introspection/runtime.spec")
local input = read_file("capability_conformance/semantic_introspection/runtime.input")
local contract = json.decode(read_file("capability_conformance/semantic_introspection_contract.json"))
local request
for _, row in ipairs(contract.query_cases) do
  if row.id == "runtime_events" then request = row.request end
end
local events = {}
local value = module.execute(input, {
  semantic_observation_sink = function(event) events[#events + 1] = event end,
})
local trace_output = {}
local traced_events = {}
local traced = module.execute_with_trace(input, linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
  semantic_observation_sink = function(event) traced_events[#traced_events + 1] = event end,
  stdout_writer = function(payload) trace_output[#trace_output + 1] = payload end,
})
local observed = linkedspec.semantic_index(source, {
  logical_name = "runtime.spec",
  source_detail_ceiling = "text",
}):with_execution_observation(events)
local response = observed:query_neutral(request)
local function project(values)
  local result = json.array()
  for index, event in ipairs(values) do
    result[index] = linkedspec.runtime_semantic_observation_event_to_json(event)
  end
  return result
end
io.write(json.encode(json.harray({
  value = value,
  traced = traced,
  events = project(events),
  traced_events = project(traced_events),
  digest = sha256.hex(json.encode(linkedspec.semantic_query_to_json(response))),
  trace = table.concat(trace_output),
})), "\n")
]])
  local runtime = os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME") or
    (type(jit) == "table" and "luajit" or "lua")
  local command = table.concat({
    "env LUA_PATH=" .. shell_quote(os.getenv("LUA_PATH") or ""),
    "LUA_CPATH=" .. shell_quote(os.getenv("LUA_CPATH") or ""),
    shell_quote(runtime),
    shell_quote(runner_path),
    shell_quote(module_path),
    ">" .. shell_quote(stdout_path),
    "2>" .. shell_quote(stderr_path),
  }, " ")
  check_equal(command_succeeded(command), true, "isolated generated host status")
  check_equal(read_file(stderr_path), "", "isolated generated host stderr")
  local observed = json.decode(read_file(stdout_path))
  check_same_json(observed.value, json.array({ "A", "B" }), "isolated direct result")
  check_same_json(observed.traced, observed.value, "isolated traced result")
  check_same_json(observed.events, expected_events, "isolated direct events")
  check_same_json(observed.traced_events, expected_events, "isolated traced events")
  check_equal(observed.digest, runtime_digest, "isolated derived digest")
  check_contains(observed.trace, "lua_runtime:regex_slot_selected", "isolated generated trace")
end)

if #failures == 0 then
  io.stdout:write("Lua generated semantic observation routes: ", assertions, " assertions passed\n")
else
  io.stderr:write("Lua generated semantic observation routes: ", #failures, " of ", assertions,
    " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
