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

local contract = json.decode(read_file("capability_conformance/diagnostic_output_contract.json"))

local function contract_row(rows, id)
  for _, row in ipairs(rows) do
    if row.id == id then return row end
  end
  error("diagnostic output contract row is missing: " .. id, 0)
end

local function program_source(id)
  return contract_row(contract.programs, id).spec_source
end

local function scenario(id)
  return contract_row(contract.scenarios, id)
end

local function engine(source)
  return linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source)))
end

local function generated_module(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local function event_json(events)
  local result = json.array()
  for index, event in ipairs(events) do
    result[index] = linkedspec.interpreter.to_json(event)
  end
  return result
end

local function render_expression(row)
  local value = row.value
  if value.kind == "string" then
    return json.encode(value.value)
  elseif value.kind == "boolean" then
    return value.value and "true" or "false"
  elseif value.kind == "number" then
    return row.id == "number_negative_zero" and "-0.0" or json.encode(value.value)
  elseif value.kind == "null" then
    return "undef"
  elseif value.kind == "array" then
    return "[1]"
  elseif value.kind == "harray" then
    return '{ "k" : 1 }'
  elseif value.kind == "codeblock" then
    return "{ return(undef) }"
  end
  error("unsupported diagnostic scalar render kind: " .. tostring(value.kind), 0)
end

local function collect_sink(events)
  return function(event) events[#events + 1] = event end
end

check_equal(contract.contract_id, "linkedspec-diagnostic-output-v1", "contract id")
check_equal(contract.event_schema.native_type, "RuntimeDiagnosticOutputEvent", "event native type")

do
  local collected = scenario("ordered_unicode_with_sink").expected
  local outcome = collected.outcome
  local runtime = engine(program_source("ordered_unicode"))
  local events = {}
  local result = linkedspec.runtime_parse(runtime, "x", { diagnostic_sink = collect_sink(events) })

  check_same_json(result.output, outcome.output, "ordered output")
  check_same_json(result.value, outcome.value, "ordered value")
  check_same_json(event_json(events), collected.events, "ordered events")
  for index, event in ipairs(events) do
    check_equal(linkedspec.interpreter.node_type(event), "RuntimeDiagnosticOutputEvent", "event type " .. index)
  end

  local quiet = scenario("ordered_unicode_quiet").expected.outcome
  check_same_json(linkedspec.runtime_parse(runtime, "x").output, quiet.output, "quiet parse output")
  check_same_json(linkedspec.runtime_execute(runtime, "x").value, quiet.value, "quiet execute value")

  local aliases = {
    function(sink)
      return linkedspec.runtime_execute(runtime, "x", { diagnostic_sink = sink })
    end,
    function(sink)
      return linkedspec.runtime_parse_with_trace(
        runtime,
        "x",
        linkedspec.trace_config_disabled(),
        { diagnostic_sink = sink, stdout_writer = function() end }
      )
    end,
    function(sink)
      return linkedspec.runtime_execute_with_trace(
        runtime,
        "x",
        linkedspec.trace_config_disabled(),
        { diagnostic_sink = sink, stdout_writer = function() end }
      )
    end,
  }
  for index, invoke in ipairs(aliases) do
    local alias_events = {}
    local alias_result = invoke(collect_sink(alias_events))
    check_same_json(alias_result.value, outcome.value, "alias value " .. index)
    check_same_json(event_json(alias_events), collected.events, "alias events " .. index)
  end
end

for _, row in ipairs(contract.scalar_render_cases) do
  local events = {}
  local result = linkedspec.runtime_parse(
    engine("Top::\n /x/\n E { print(" .. render_expression(row) .. "); return(\"ok\") }\n"),
    "x",
    { diagnostic_sink = collect_sink(events) }
  )
  check_equal(result.value, "ok", row.id .. " result")
  check_equal(#events, 1, row.id .. " event count")
  check_equal(events[1].message, row.expected, row.id .. " rendering")
end

for _, row in ipairs(contract.invalid_arity_cases) do
  local arguments = {}
  for index = 1, row.actual_arity do
    arguments[index] = index == 1 and "exit_now(77)" or json.encode("arg-" .. tostring(index - 1))
  end
  local source = "Top::\n /x/\n E { " .. row.helper_name .. "(" .. table.concat(arguments, ", ") ..
    "); return(\"late\") }\n"
  local ok, failure = pcall(linkedspec.runtime_parse, engine(source), "x")
  check_equal(ok, false, row.id .. " rejected")
  check_equal(linkedspec.is_runtime_interpreter_error(failure), true, row.id .. " typed arity failure")
  check_equal(failure.code, row.expected_code, row.id .. " failure code")
  check_equal(failure.expected_arity, row.expected_arity, row.id .. " expected arity")
  check_equal(failure.actual_arity, row.actual_arity, row.id .. " actual arity")
  check_contains(failure.message, row.expected_arity, row.id .. " arity wording")
end

do
  local expected = scenario("wrong_kind_no_events").expected
  local events = {}
  local result = linkedspec.runtime_parse(
    engine(program_source("wrong_kind")),
    "x",
    { diagnostic_sink = collect_sink(events) }
  )
  check_same_json(result.output, expected.outcome.output, "wrong-kind output")
  check_same_json(event_json(events), expected.events, "wrong-kind events")
end

do
  local expected = scenario("event_before_immediate_exit").expected
  local events = {}
  local ok, failure = pcall(
    linkedspec.runtime_parse,
    engine(program_source("immediate_exit")),
    "x",
    { diagnostic_sink = collect_sink(events) }
  )
  check_equal(ok, false, "immediate exit propagated")
  check_equal(type(linkedspec.is_runtime_exit_now), "function", "exit predicate is public")
  check_equal(
    type(linkedspec.is_runtime_exit_now) == "function" and linkedspec.is_runtime_exit_now(failure),
    true,
    "immediate exit typed separately"
  )
  check_equal(linkedspec.interpreter.node_type(failure), "RuntimeExitNow", "immediate exit native type")
  check_equal(failure.status, expected.outcome.status, "immediate exit status")
  check_same_json(
    linkedspec.interpreter.to_json(failure),
    json.harray({ status = expected.outcome.status }),
    "immediate exit JSON"
  )
  check_same_json(event_json(events), expected.events, "pre-exit events")
end

local function runtime_interpreter_failure()
  local ok, failure = pcall(linkedspec.runtime_parse, {}, "x")
  if ok or not linkedspec.is_runtime_interpreter_error(failure) then
    error("unable to prepare caller-owned RuntimeInterpreterException", 0)
  end
  return failure
end

for _, id in ipairs({ "print_each_sink_failure", "synchronous_sink_failure" }) do
  local row = scenario(id)
  local caller_failure = id == "print_each_sink_failure" and runtime_interpreter_failure() or {
    id = row.sink.error_id,
  }
  local events = {}
  local invocation = 0
  local ok, failure = pcall(
    linkedspec.runtime_parse,
    engine(program_source(row.program_id)),
    "x",
    {
      diagnostic_sink = function(event)
        invocation = invocation + 1
        events[#events + 1] = event
        if invocation == row.sink.invocation then error(caller_failure, 0) end
      end,
    }
  )
  check_equal(ok, false, id .. " propagated")
  check_equal(failure, caller_failure, id .. " exact caller identity")
  check_same_json(event_json(events), row.expected.events, id .. " delivered events")
end

do
  local marker = "diagnostic-only-pré🙂"
  local trace_output = {}
  local trace_emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function(payload) trace_output[#trace_output + 1] = payload end }
  )
  local events = {}
  local result = linkedspec.runtime_parse(
    engine("Top::\n /x/\n E { say(" .. json.encode(marker) .. "); return(\"ok\") }\n"),
    "x",
    { trace = trace_emitter, diagnostic_sink = collect_sink(events) }
  )
  local trace_text = table.concat(trace_output)
  check_equal(result.value, "ok", "trace separation result")
  check_equal(events[1].message, marker .. "\n", "trace separation event")
  check_contains(trace_text, "lua_runtime:parse", "native trace remains active")
  check_equal(trace_text:find(marker, 1, true), nil, "event message stays out of native trace")
end

do
  local identity = "diagnostic-output/generated-lua.spec"
  local ordered_compiled = linkedspec.compile_spec(linkedspec.parse_spec(program_source("ordered_unicode")))
  local generated = generated_module(
    linkedspec.emit_lua_source_v2(ordered_compiled, identity),
    "@generated-diagnostic-output"
  )
  local expected = scenario("ordered_unicode_with_sink").expected
  local events = {}
  local value = generated.execute("x", { diagnostic_sink = collect_sink(events) })
  check_same_json(value, expected.outcome.value, "generated direct value")
  check_same_json(event_json(events), expected.events, "generated direct events")

  local traced_events = {}
  local traced = generated.execute_with_trace(
    "x",
    linkedspec.trace_config_disabled(),
    {
      diagnostic_sink = collect_sink(traced_events),
      stdout_writer = function() end,
    }
  )
  check_same_json(traced, value, "generated traced value")
  check_same_json(event_json(traced_events), expected.events, "generated traced events")

  local failure_compiled = linkedspec.compile_spec(linkedspec.parse_spec(program_source("sink_failure")))
  local failure_generated = generated_module(
    linkedspec.emit_lua_source_v2(failure_compiled, identity),
    "@generated-diagnostic-sink-failure"
  )
  local caller_failure = { id = "generated-caller-sink-failure" }
  local invocation = 0
  local sink_ok, sink_failure = pcall(failure_generated.execute, "x", {
    diagnostic_sink = function()
      invocation = invocation + 1
      if invocation == 2 then error(caller_failure, 0) end
    end,
  })
  check_equal(sink_ok, false, "generated sink failure propagated")
  check_equal(sink_failure, caller_failure, "generated sink failure identity")

  local exit_compiled = linkedspec.compile_spec(linkedspec.parse_spec(program_source("immediate_exit")))
  local exit_generated = generated_module(
    linkedspec.emit_lua_source_v2(exit_compiled, identity),
    "@generated-diagnostic-exit"
  )
  local exit_events = {}
  local exit_ok, exit_failure = pcall(exit_generated.execute, "x", {
    diagnostic_sink = collect_sink(exit_events),
  })
  check_equal(exit_ok, false, "generated exit propagated")
  check_equal(linkedspec.is_runtime_exit_now(exit_failure), true, "generated exit type")
  check_equal(exit_failure.status, 23, "generated exit status")
  check_same_json(
    event_json(exit_events),
    scenario("event_before_immediate_exit").expected.events,
    "generated pre-exit events"
  )
end

if #failures == 0 then
  io.stdout:write("diagnostic output contract: ", assertions, " assertions passed\n")
else
  io.stderr:write("diagnostic output contract: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
