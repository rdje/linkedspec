-- FUTURE-PARITY-BACKLOG.14.4.6 — shared Lua recursive-observation admission.
--
-- Ordinary Lua discovery and canonical CI execute this exact Lua-5.1-compatible
-- consumer once with PUC Lua and once with LuaJIT. The implementation remains
-- private: no facade, schema, semantic/MCP, CLI, or README surface is added.

local json = require("linkedspec.json")
local linkedspec = require("linkedspec")
local recognition_runtime = require("linkedspec.recognition_transaction_runtime")

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

local function expect_error(needle, operation, label)
  local ok, captured = capture(operation)
  check_equal(ok, false, label .. " rejects")
  if not ok then
    check(
      tostring(captured):find(needle, 1, true) ~= nil,
      label .. " preserves " .. needle .. ": got " .. tostring(captured)
    )
  end
end

local function capture_bindings(operation)
  local original = recognition_runtime.bind_observation
  local bindings = {}
  recognition_runtime.bind_observation = function(ctx, rule_label, target, scope)
    original(ctx, rule_label, target, scope)
    bindings[#bindings + 1] = json.decode(json.encode(ctx.harrays[target]))
  end
  local ok, captured = capture(operation)
  recognition_runtime.bind_observation = original
  return ok, captured, bindings
end

local function compile_source(source)
  local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
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

local function expected_observation(options)
  local selected_match = json.null
  if options.selected_start ~= nil then
    selected_match = json.harray({
      source_id = "input",
      start = options.selected_start,
      ["end"] = options.selected_end,
      provenance = "match",
    })
  end
  local accepted_exit = json.null
  if options.accepted_exit ~= nil then
    accepted_exit = json.harray({ source_id = "input", offset = options.accepted_exit })
  end
  return json.harray({
    source_id = "input",
    rule_label = options.rule_label,
    invocation_id = options.invocation_id,
    parent_invocation_id = options.parent_invocation_id or json.null,
    entry_position = json.harray({ source_id = "input", offset = options.entry_offset }),
    selected_match = selected_match,
    accepted_exit = accepted_exit,
    outcome = options.outcome,
    diagnostic = options.diagnostic or json.null,
  })
end

local authored_source = [[Top::
 I {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }

Child::AND
 /🙂/
 E { return(false) }
]]

-- Dedicated lowering and static/effect policy.
do
  local _, compiled = compile_source(authored_source)
  local top = linkedspec.compiled_spec_to_json(compiled).rules_by_label.Top
  local observations = objects_with_kind(top, "observe_recognition")
  check_equal(#observations, 1, "one dedicated observation node")
  if #observations == 1 then
    check_equal(observations[1].target, "observation", "observation target")
    check_equal(observations[1].rule, "Child", "observation static child")
  else
    check(false, "observation target unavailable")
    check(false, "observation static child unavailable")
  end
  local eager_calls = 0
  for _, object in ipairs(all_objects(top)) do
    if object.kind == "call" and object.name == "Child" then eager_calls = eager_calls + 1 end
  end
  check_equal(eager_calls, 0, "observation child is not eagerly called")
  local serialized = json.encode(linkedspec.compiled_spec_to_json(compiled))
  local _, serialized_count = serialized:gsub('"kind":"observe_recognition"', "")
  check_equal(serialized_count, 1, "serialized observation node is exact once")

  local fixtures = {
    {
      [[Top::
 I { value = observe_recognition(observation["nested"], call(Child)) }
Child::AND
 /x/
]],
      "source_location_recursive_observation_target",
      "nested observation target",
    },
    {
      [[Top::
 I { value = observe_recognition(observation, dynamic_child) }
Child::AND
 /x/
]],
      "source_location_recursive_observation_operand",
      "dynamic observation operand",
    },
    {
      [[Top:: I { value = observe_recognition(observation, call(Missing)) }]],
      "source_location_recursive_observation_operand",
      "missing observation rule",
    },
    {
      [[Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer: I { value = observe_recognition(observation, call(Child)); return(value) }
Child::AND /x/
]],
      "recognition_effect_forbidden:binding_write",
      "rule observation effect",
    },
    {
      [[fn inspect() { value = observe_recognition(observation, call(Child)); return(value) }
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer: I { return(inspect()) }
Child::AND /x/
]],
      "recognition_effect_forbidden:binding_write",
      "function observation effect",
    },
  }
  for _, fixture in ipairs(fixtures) do
    expect_error(fixture[2], function() compile_source(fixture[1]) end, fixture[3])
  end
end

-- Native and reconstructed carriers preserve false payloads and detached records.
do
  local parsed, compiled = compile_source(authored_source)
  local expected = json.array({
    false,
    expected_observation({
      rule_label = "Child",
      invocation_id = 2,
      parent_invocation_id = 1,
      entry_offset = 0,
      selected_start = 0,
      selected_end = 1,
      accepted_exit = 1,
      outcome = "accepted",
    }),
  })
  local ok, first = capture(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "🙂").value
  end)
  check_equal(ok, true, "native observation executes")
  if ok then
    check_same_json(first, expected, "native false payload and observation")
    first[2].entry_position.offset = 99
    first[2].selected_match.start = 99
    check_same_json(
      linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "🙂").value,
      expected,
      "native observation is detached"
    )
  end

  local reconstructed = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  linkedspec.validate_spec(reconstructed)
  local reconstructed_ok, reconstructed_value = capture(function()
    return linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed)),
      "🙂"
    ).value
  end)
  check_equal(reconstructed_ok, true, "reconstructed observation executes")
  if reconstructed_ok then
    check_same_json(reconstructed_value, expected, "reconstructed observation")
  end
end

-- Failure, zero-regex, and action-edge cursor semantics.
do
  local _, failed = compile_source([[Top::
 I { value = observe_recognition(observation, call(Missing)); return(array(value, observation)) }
Missing::AND
 /z/
]])
  local failed_ok, failed_value = capture(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(failed), "x").value
  end)
  check_equal(failed_ok, true, "failed observation executes")
  if failed_ok then
    check_same_json(failed_value, json.array({
      json.null,
      expected_observation({
        rule_label = "Missing", invocation_id = 2, parent_invocation_id = 1,
        entry_offset = 0, outcome = "failed",
      }),
    }), "failed observation")
  end

  local _, zero = compile_source([[Top::
 I { value = observe_recognition(observation, call(Coordinator)); return(array(value, observation)) }
Coordinator:
 I { return("coordinated") }
]])
  local zero_ok, zero_value = capture(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(zero), "").value
  end)
  check_equal(zero_ok, true, "zero-regex observation executes")
  if zero_ok then
    check_same_json(zero_value, json.array({
      "coordinated",
      expected_observation({
        rule_label = "Coordinator", invocation_id = 2, parent_invocation_id = 1,
        entry_offset = 0, accepted_exit = 0, outcome = "accepted",
      }),
    }), "zero-regex observation")
  end

  local _, edge = compile_source([[Top::
 /a/ -> Top {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }
Child::AND
 /b/
 /c/
 -> Child[0] { first = match_text() }
 -> Child[1] { return(array(entry_text(), entry_start_pos())) }
]])
  local edge_ok, edge_value = capture(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(edge), "abc").value
  end)
  check_equal(edge_ok, true, "action-edge observation executes")
  if edge_ok then
    check_same_json(edge_value, json.array({
      json.array({ "a", 0 }),
      expected_observation({
        rule_label = "Child", invocation_id = 2, parent_invocation_id = 1,
        entry_offset = 1, selected_start = 2, selected_end = 3,
        accepted_exit = 3, outcome = "accepted",
      }),
    }), "action-edge observation")
  end
end

-- Ordinary nested cutoff stays ordinary; explicit direct/mutual observation is typed.
do
  local _, ordinary = compile_source([[Top:: I { value = observe_recognition(observation, call(Child)); return(array(value, observation)) }
Child: I { nested = call(Child); return("guarded") }
]])
  local ordinary_ok, ordinary_value = capture(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(ordinary), "").value
  end)
  check_equal(ordinary_ok, true, "ordinary nested cutoff executes")
  if ordinary_ok then
    check_same_json(ordinary_value, json.array({
      "guarded",
      expected_observation({
        rule_label = "Child", invocation_id = 2, parent_invocation_id = 1,
        entry_offset = 0, accepted_exit = 0, outcome = "accepted",
      }),
    }), "ordinary nested cutoff is not observed rejection")
  end

  local _, direct = compile_source([[Top:: I { value = observe_recognition(top_observation, call(DirectRecur)); return(value) }
DirectRecur: I { value = observe_recognition(observation, call(DirectRecur)); return(value) }
]])
  local direct_ok, direct_error, direct_bindings = capture_bindings(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(direct), "x")
  end)
  check_equal(direct_ok, false, "direct observed recursion rejects")
  check(
    tostring(direct_error):find("source_location_nonprogress_direct_recursion", 1, true) ~= nil,
    "direct observed recursion preserves typed error: got " .. tostring(direct_error)
  )
  check_same_json(direct_bindings[1] or json.null, expected_observation({
    rule_label = "DirectRecur", invocation_id = 3, parent_invocation_id = 2,
    entry_offset = 0, outcome = "rejected",
    diagnostic = "source_location_nonprogress_direct_recursion",
  }), "direct rejection binds before propagation")

  local _, mutual = compile_source([[Top:: I { value = observe_recognition(top_observation, call(MutualA)); return(value) }
MutualA: I { value = observe_recognition(observation_a, call(MutualB)); return(value) }
MutualB: I { value = observe_recognition(observation_b, call(MutualA)); return(value) }
]])
  local mutual_ok, mutual_error, mutual_bindings = capture_bindings(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(mutual), "x")
  end)
  check_equal(mutual_ok, false, "mutual observed recursion rejects")
  check(
    tostring(mutual_error):find("source_location_nonprogress_mutual_recursion", 1, true) ~= nil,
    "mutual observed recursion preserves typed error: got " .. tostring(mutual_error)
  )
  check_same_json(mutual_bindings[1] or json.null, expected_observation({
    rule_label = "MutualA", invocation_id = 4, parent_invocation_id = 3,
    entry_offset = 0, outcome = "rejected",
    diagnostic = "source_location_nonprogress_mutual_recursion",
  }), "mutual rejection binds before propagation")
end

-- Aborted observation propagates the original typed runtime diagnostic.
do
  local _, aborted = compile_source([[Top::
 I { value = observe_recognition(observation, call(AbortChild)); return(value) }
AbortChild:
 I { recognition_commit(missing) }
]])
  local aborted_ok, aborted_error, aborted_bindings = capture_bindings(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(aborted), "")
  end)
  check_equal(aborted_ok, false, "aborted observation rejects")
  check(
    tostring(aborted_error):find("recognition_token_expected", 1, true) ~= nil,
    "aborted observation preserves original typed error: got " .. tostring(aborted_error)
  )
  check_same_json(aborted_bindings[1] or json.null, expected_observation({
    rule_label = "AbortChild", invocation_id = 2, parent_invocation_id = 1,
    entry_offset = 0, outcome = "aborted",
  }), "aborted observation binds before propagation")
end

-- Generated-plan carrier.
do
  local _, compiled = compile_source(authored_source)
  local generated_ok, generated_value = capture(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      "🙂",
      "recursive-observation/lua.spec"
    )
  end)
  check_equal(generated_ok, true, "generated-plan observation executes")
  if generated_ok then
    check_same_json(generated_value, json.array({
      false,
      expected_observation({
        rule_label = "Child", invocation_id = 2, parent_invocation_id = 1,
        entry_offset = 0, selected_start = 0, selected_end = 1,
        accepted_exit = 1, outcome = "accepted",
      }),
    }), "generated-plan observation")
  end
end

-- Independently loaded emitted carrier.
do
  local _, compiled = compile_source(authored_source)
  local identity = "recursive-observation/lua-emitted.spec"
  local emitted = linkedspec.emit_lua_source_v2(compiled, identity)
  local loader = loadstring or load
  local chunk, failure = loader(emitted, "@recursive_observation_generated.lua")
  check(chunk ~= nil, "emitted observation source loads")
  if chunk == nil then
    failures[#failures + 1] = tostring(failure)
  else
    local generated_module = chunk()
    local emitted_ok, emitted_value = capture(function() return generated_module.execute("🙂") end)
    check_equal(emitted_ok, true, "emitted observation executes")
    if emitted_ok then
      check_same_json(emitted_value, json.array({
        false,
        expected_observation({
          rule_label = "Child", invocation_id = 2, parent_invocation_id = 1,
          entry_offset = 0, selected_start = 0, selected_end = 1,
          accepted_exit = 1, outcome = "accepted",
        }),
      }), "emitted observation")
    end
    check_equal(generated_module.metadata().source_identity, identity, "emitted observation identity")
  end
end

if #failures == 0 then
  io.stdout:write(
    "Lua recursive-observation contract: ", assertions,
    " assertions passed on ", linkedspec.runtime_implementation(), "\n"
  )
else
  io.stderr:write(
    "Lua recursive-observation contract: ", #failures,
    " of ", assertions, " assertions failed on ",
    linkedspec.runtime_implementation(), "\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
