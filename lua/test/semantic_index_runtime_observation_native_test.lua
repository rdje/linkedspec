-- FUTURE-PARITY-BACKLOG.10.7.6.1 — typed invocation-local native capture.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local matching = require("linkedspec.matching")
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
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-observation.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean observation-test directory", 0) end
  if not ok then error(value, 0) end
end

local function compile(source)
  local spec = linkedspec.parse_spec(source)
  linkedspec.validate_spec(spec)
  return linkedspec.compile_spec(spec)
end

local function engine(source)
  return linkedspec.runtime_engine(compile(source))
end

local function collect(events)
  return function(event) events[#events + 1] = event end
end

local function capture(route)
  local events = {}
  local result = route(collect(events))
  return result, events
end

local function event_json(events)
  local result = json.array()
  for index, event in ipairs(events) do
    result[index] = linkedspec.runtime_semantic_observation_event_to_json(event)
  end
  return result
end

local function trace_event_json(emitter)
  local result = json.array()
  for index, event in ipairs(linkedspec.trace_events(emitter)) do
    result[index] = linkedspec.trace_event_to_json(event)
  end
  return result
end

local canonical_source = read_file("capability_conformance/semantic_introspection/runtime.spec")
local canonical_input = read_file("capability_conformance/semantic_introspection/runtime.input")
local canonical_identity =
  "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece"
local canonical_compiled = compile(canonical_source)
local canonical_engine = linkedspec.runtime_engine(canonical_compiled)
local canonical_events = json.array({
  json.harray({
    contract_id = "linkedspec-semantic-execution-observation-v1",
    event_kind = "regex_slot_selected",
    rule_label = "Top",
    target_rule = "Top",
    regex_index = 0,
    position = 1,
    input_identity = json.null,
    status = json.null,
  }),
  json.harray({
    contract_id = "linkedspec-semantic-execution-observation-v1",
    event_kind = "regex_slot_selected",
    rule_label = "Top",
    target_rule = "Top",
    regex_index = 1,
    position = 2,
    input_identity = json.null,
    status = json.null,
  }),
  json.harray({
    contract_id = "linkedspec-semantic-execution-observation-v1",
    event_kind = "rule_result",
    rule_label = "Top",
    target_rule = json.null,
    regex_index = json.null,
    position = 2,
    input_identity = canonical_identity,
    status = "succeeded",
  }),
})

check_equal(canonical_input, "ab\n", "canonical input bytes")
check_equal(
  linkedspec.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
  "linkedspec-semantic-execution-observation-v1",
  "public observation contract"
)
check_equal(linkedspec.semantic_observation_sink, nil, "root omits sink constructor")
check_equal(linkedspec.runtime_semantic_observation_event, nil, "root omits event constructor")
check_equal(linkedspec.with_execution_observation, nil, "root omits observed-index derivation")

do
  local result, events = capture(function(sink)
    return linkedspec.runtime_parse(canonical_engine, canonical_input, {
      semantic_observation_sink = sink,
    })
  end)
  check_same_json(result.value, json.array({ "A", "B" }), "canonical result value")
  check_equal(result.matched, true, "canonical matched")
  check_equal(result.cursor_code_unit, 2, "canonical byte cursor")
  check_equal(result.cursor_char_offset, 2, "canonical scalar cursor")
  check_equal(#events, 3, "canonical event count")
  check_same_json(event_json(events), canonical_events, "canonical events")

  for index, event in ipairs(events) do
    check_equal(linkedspec.is_runtime_semantic_observation_event(event), true,
      "canonical protected event " .. index)
    check_equal(getmetatable(event), "protected", "canonical protected metatable " .. index)
    check_equal(next(event), nil, "canonical event state hidden " .. index)
    local pair_count = 0
    for _ in pairs(event) do pair_count = pair_count + 1 end
    check_equal(pair_count, 0, "canonical event pairs hidden " .. index)
    local mutation_ok, mutation = pcall(function() event.position = 999 end)
    check_equal(mutation_ok, false, "canonical event immutable " .. index)
    check_contains(mutation, "immutable", "canonical immutable diagnostic " .. index)
  end

  local detached = linkedspec.runtime_semantic_observation_event_to_json(events[1])
  detached.rule_label = "Mutated"
  detached.target_rule = "Mutated"
  check_equal(events[1].rule_label, "Top", "detached JSON cannot mutate event")
  check_equal(
    linkedspec.runtime_semantic_observation_event_to_json(events[1]).rule_label,
    "Top",
    "fresh detached JSON projection"
  )
  check_equal(linkedspec.is_runtime_semantic_observation_event(detached), false,
    "detached JSON is not a typed event")
  check_equal(linkedspec.is_runtime_semantic_observation_event(canonical_events[1]), false,
    "deep-equivalent JSON is not a typed event")
  local plain_ok, plain_error = pcall(
    linkedspec.runtime_semantic_observation_event_to_json,
    canonical_events[1]
  )
  check_equal(plain_ok, false, "plain event JSON rejected")
  check_contains(plain_error, "expected RuntimeSemanticObservationEvent", "plain event diagnostic")
end

with_temp_directory(function(root)
  local path = root .. "/runtime.spec"
  write_file(path, canonical_source)
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request(path),
    linkedspec.spec_load_options({ cwd = root, search_roots = {} })
  )
  local normalized = json.decode(json.encode(linkedspec.spec_ast.to_json(
    linkedspec.parse_spec(canonical_source)
  )))
  local reconstructed = linkedspec.compile_spec(linkedspec.spec_ast.from_json("SpecFile", normalized))
  local routes = {
    { "direct", canonical_engine },
    { "loaded", loaded:create_engine() },
    { "reconstructed", linkedspec.runtime_engine(reconstructed) },
  }
  for _, route in ipairs(routes) do
    local baseline = linkedspec.runtime_parse(route[2], canonical_input)
    local observed, events = capture(function(sink)
      return linkedspec.runtime_parse(route[2], canonical_input, {
        semantic_observation_sink = sink,
      })
    end)
    check_same_json(linkedspec.interpreter.to_json(observed), linkedspec.interpreter.to_json(baseline),
      route[1] .. " observed result equivalence")
    check_same_json(event_json(events), canonical_events, route[1] .. " events")
  end
end)

for _, route in ipairs({
  {
    "execute alias",
    function(sink)
      return linkedspec.runtime_execute(canonical_engine, canonical_input, {
        semantic_observation_sink = sink,
      })
    end,
  },
  {
    "parse traced convenience",
    function(sink)
      return linkedspec.runtime_parse_with_trace(
        canonical_engine,
        canonical_input,
        linkedspec.trace_config_disabled(),
        { semantic_observation_sink = sink, stdout_writer = function() end }
      )
    end,
  },
  {
    "execute traced convenience",
    function(sink)
      return linkedspec.runtime_execute_with_trace(
        canonical_engine,
        canonical_input,
        linkedspec.trace_config_disabled(),
        { semantic_observation_sink = sink, stdout_writer = function() end }
      )
    end,
  },
}) do
  local result, events = capture(route[2])
  check_same_json(result.value, json.array({ "A", "B" }), route[1] .. " result")
  check_equal(result.cursor_code_unit, 2, route[1] .. " byte cursor")
  check_equal(result.cursor_char_offset, 2, route[1] .. " scalar cursor")
  check_same_json(event_json(events), canonical_events, route[1] .. " events")
end

do
  local unicode_input = "xé"
  local result, events = capture(function(sink)
    return linkedspec.runtime_parse(
      engine("Töp::\n /é/\n E { return(\"ok\") }\n"),
      unicode_input,
      { semantic_observation_sink = sink }
    )
  end)
  check_equal(result.cursor_code_unit, 3, "Unicode byte cursor")
  check_equal(result.cursor_char_offset, 2, "Unicode scalar cursor")
  check_equal(#events, 2, "Unicode event count")
  check_equal(events[1].position, 2, "Unicode slot scalar position")
  check_equal(events[2].position, 2, "Unicode result scalar position")
  check_equal(events[1].rule_label, "Töp", "Unicode executing rule")
  check_equal(events[1].target_rule, "Töp", "Unicode target rule")
  check_equal(events[2].input_identity, "input:sha256:" .. sha256.hex(unicode_input),
    "Unicode UTF-8 input identity")
end

do
  local events = {}
  local result = linkedspec.runtime_parse(
    engine("Top::\n /z/\n"),
    "x",
    { semantic_observation_sink = collect(events) }
  )
  check_equal(result.matched, false, "normally unmatched result")
  check_equal(#events, 1, "normally unmatched final event count")
  check_equal(events[1].event_kind, "rule_result", "normally unmatched final kind")
  check_equal(events[1].position, result.cursor_char_offset, "normally unmatched final position")
  check_equal(events[1].status, "succeeded", "normally unmatched final status")
end

do
  local invalid_ok, invalid = pcall(
    linkedspec.runtime_parse,
    canonical_engine,
    canonical_input,
    { semantic_observation_sink = {} }
  )
  check_equal(invalid_ok, false, "invalid sink rejected")
  check_contains(invalid, "semantic_observation_sink must be a function", "invalid sink diagnostic")

  local engine_ok, engine_error = pcall(linkedspec.runtime_engine, canonical_compiled, {
    semantic_observation_sink = function() end,
  })
  check_equal(engine_ok, false, "engine-level sink rejected")
  check_contains(engine_error, "invocation-local", "engine-level sink diagnostic")
end

do
  local selector_events = {}
  local selector_ok, selector_failure = pcall(
    linkedspec.runtime_parse,
    canonical_engine,
    canonical_input,
    { top_rule = "Missing", semantic_observation_sink = collect(selector_events) }
  )
  check_equal(selector_ok, false, "selector failure propagated")
  check_equal(linkedspec.is_runtime_interpreter_error(selector_failure), true, "selector typed failure")
  check_equal(#selector_events, 0, "selector failure emits no events")

  local execution_events = {}
  local execution_ok, execution_failure = pcall(
    linkedspec.runtime_parse,
    engine("Top::\n /x/\n E { say(); return(\"late\") }\n"),
    "x",
    { semantic_observation_sink = collect(execution_events) }
  )
  check_equal(execution_ok, false, "execution failure propagated")
  check_equal(linkedspec.is_runtime_interpreter_error(execution_failure), true, "execution typed failure")
  check_equal(#execution_events, 1, "execution failure retains selected slot only")
  check_equal(execution_events[1].event_kind, "regex_slot_selected", "execution omits final result")

  local exit_events = {}
  local exit_ok, exit_failure = pcall(
    linkedspec.runtime_parse,
    engine("Top::\n /x/\n E { exit_now(7); return(\"late\") }\n"),
    "x",
    { semantic_observation_sink = collect(exit_events) }
  )
  check_equal(exit_ok, false, "exit propagated")
  check_equal(linkedspec.is_runtime_exit_now(exit_failure), true, "exit typed failure")
  check_equal(exit_failure.status, 7, "exit status")
  check_equal(#exit_events, 1, "exit retains selected slot only")
  check_equal(exit_events[1].event_kind, "regex_slot_selected", "exit omits final result")
end

do
  local original_slot = observation.regex_slot_selected
  local original_result = observation.rule_result
  local original_hash = sha256.hex
  local original_char_end = matching.byte_offset_to_char_offset
  observation.regex_slot_selected = function() error("unexpected slot event allocation", 0) end
  observation.rule_result = function() error("unexpected result event allocation", 0) end
  sha256.hex = function() error("unexpected input hash", 0) end
  matching.byte_offset_to_char_offset = function() error("unexpected scalar conversion", 0) end
  local quiet_ok, quiet_failure = pcall(
    linkedspec.runtime_parse,
    engine("Top::\n /x/\n E { exit_now(19); return(\"late\") }\n"),
    "x"
  )
  observation.regex_slot_selected = original_slot
  observation.rule_result = original_result
  sha256.hex = original_hash
  matching.byte_offset_to_char_offset = original_char_end
  check_equal(quiet_ok, false, "quiet exit propagated")
  check_equal(linkedspec.is_runtime_exit_now(quiet_failure), true, "quiet no-work path reaches exit")
  check_equal(quiet_failure.status, 19, "quiet no-work exit status")
end

local function runtime_interpreter_failure()
  local ok, failure = pcall(linkedspec.runtime_parse, {}, "x")
  if ok or not linkedspec.is_runtime_interpreter_error(failure) then
    error("unable to prepare caller-owned RuntimeInterpreterError", 0)
  end
  return failure
end

for index, caller_failure in ipairs({
  "semantic-sink-string",
  { id = "semantic-sink-table" },
  runtime_interpreter_failure(),
}) do
  local delivered = {}
  local ok, failure = pcall(
    linkedspec.runtime_parse,
    canonical_engine,
    canonical_input,
    {
      semantic_observation_sink = function(event)
        delivered[#delivered + 1] = event
        error(caller_failure, 0)
      end,
    }
  )
  check_equal(ok, false, "callback failure propagated " .. index)
  check_equal(failure, caller_failure, "callback exact identity " .. index)
  check_equal(#delivered, 1, "callback stops after first event " .. index)
end

do
  local delivered = {}
  local ok, failure = pcall(
    linkedspec.runtime_parse,
    canonical_engine,
    canonical_input,
    {
      semantic_observation_sink = function(event)
        delivered[#delivered + 1] = event
        if #delivered == 3 then error(nil, 0) end
      end,
    }
  )
  check_equal(ok, false, "nil callback failure propagated")
  check_equal(failure, nil, "nil callback value preserved")
  check_equal(#delivered, 3, "final callback delivered before failure")
  check_equal(delivered[3].event_kind, "rule_result", "final callback failure kind")
end

do
  local caller_failure = { id = "traced-semantic-sink-failure" }
  local trace_output = {}
  local delivered = {}
  local ok, failure = pcall(
    linkedspec.runtime_parse_with_trace,
    canonical_engine,
    canonical_input,
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    {
      stdout_writer = function(value) trace_output[#trace_output + 1] = value end,
      semantic_observation_sink = function(event)
        delivered[#delivered + 1] = event
        error(caller_failure, 0)
      end,
    }
  )
  check_equal(ok, false, "traced callback failure propagated")
  check_equal(failure, caller_failure, "traced callback exact identity")
  check_equal(#delivered, 1, "traced callback stops after first event")
  check_contains(table.concat(trace_output), "error=semantic_observation_sink",
    "traced callback closes active scopes")
end

do
  local source = "Top::\n /x/\n E { say(\"diagnostic-only\"); return(\"ok\") }\n"
  local runtime = engine(source)
  local baseline_trace_output = {}
  local observed_trace_output = {}
  local baseline_trace = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function(value) baseline_trace_output[#baseline_trace_output + 1] = value end }
  )
  local observed_trace = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function(value) observed_trace_output[#observed_trace_output + 1] = value end }
  )
  local baseline_diagnostics = {}
  local observed_diagnostics = {}
  local observed_events = {}
  local baseline = linkedspec.runtime_parse(runtime, "x", {
    trace = baseline_trace,
    diagnostic_sink = collect(baseline_diagnostics),
  })
  local observed = linkedspec.runtime_parse(runtime, "x", {
    trace = observed_trace,
    diagnostic_sink = collect(observed_diagnostics),
    semantic_observation_sink = collect(observed_events),
  })
  check_same_json(linkedspec.interpreter.to_json(observed), linkedspec.interpreter.to_json(baseline),
    "semantic sink preserves result")
  check_equal(table.concat(observed_trace_output), table.concat(baseline_trace_output),
    "semantic sink preserves trace bytes")
  check_same_json(trace_event_json(observed_trace), trace_event_json(baseline_trace),
    "semantic sink preserves trace events")
  check_same_json(linkedspec.interpreter.to_json(observed_diagnostics[1]),
    linkedspec.interpreter.to_json(baseline_diagnostics[1]),
    "semantic sink preserves diagnostics")
  check_equal(#observed_diagnostics, 1, "diagnostic count remains separate")
  check_equal(#observed_events, 2, "semantic count remains separate")
  check_equal(linkedspec.is_runtime_semantic_observation_event(observed_diagnostics[1]), false,
    "diagnostic is not semantic event")
end

do
  local outer_events = {}
  local nested_events = {}
  local nested = false
  local outer = linkedspec.runtime_parse(canonical_engine, canonical_input, {
    semantic_observation_sink = function(event)
      outer_events[#outer_events + 1] = event
      if not nested then
        nested = true
        local result = linkedspec.runtime_parse(canonical_engine, canonical_input, {
          semantic_observation_sink = collect(nested_events),
        })
        check_same_json(result.value, json.array({ "A", "B" }), "reentrant nested result")
      end
    end,
  })
  check_same_json(outer.value, json.array({ "A", "B" }), "reentrant outer result")
  check_same_json(event_json(outer_events), canonical_events, "reentrant outer event isolation")
  check_same_json(event_json(nested_events), canonical_events, "reentrant nested event isolation")
end

do
  local plan = linkedspec.build_generated_rule_plan(canonical_compiled)
  local generated_events = {}
  local generated_ok, generated_failure = pcall(
    linkedspec.execute_generated_parser_v2,
    canonical_compiled,
    plan,
    canonical_input,
    "semantic-introspection/runtime.spec",
    { semantic_observation_sink = collect(generated_events) }
  )
  check_equal(generated_ok, false, "generated observation remains fenced")
  check_equal(#generated_events, 0, "generated fence emits no observations")
  check_equal(linkedspec.is_generated_source_error(generated_failure), true,
    "generated fence uses existing translation until propagation leaf")

  local emitter_source = read_file("lua/src/linkedspec/source_emitter.lua")
  check_equal(emitter_source:find("semantic_observation_sink", 1, true), nil,
    "generated source owner has no observation propagation")
  check_equal(emitter_source:find("semantic_observation", 1, true), nil,
    "generated source owner has no semantic carrier")
  local emitted = linkedspec.emit_lua_source_v2(canonical_compiled, "semantic-introspection/runtime.spec")
  check_equal(emitted:find("semantic_observation", 1, true), nil,
    "emitted source has no observation adapter")
  check_equal(emitted:find("with_execution_observation", 1, true), nil,
    "emitted source has no observed-index derivation")
  check_equal(linkedspec.GENERATED_SOURCE_FORMAT, 2, "generated source format unchanged")
end

if #failures == 0 then
  io.stdout:write("Lua native semantic runtime observation: ", assertions, " assertions passed\n")
else
  io.stderr:write("Lua native semantic runtime observation: ", #failures, " of ", assertions,
    " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
