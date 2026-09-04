-- FUTURE-PARITY-BACKLOG.19.6.1 -- frozen nested write-vivification admission.

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

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function literal(value)
  if value == json.null then return "undef" end
  local value_type = type(value)
  if value_type == "boolean" then return value and "true" or "false" end
  if value_type == "number" then return tostring(value) end
  if value_type == "string" then return json.encode(value) end
  local kind = json.kind(value)
  if kind == "array" then
    local items = {}
    for index, item in ipairs(value) do items[index] = literal(item) end
    return "[" .. table.concat(items, ", ") .. "]"
  elseif kind == "harray" then
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys)
    local entries = {}
    for index, key in ipairs(keys) do
      entries[index] = json.encode(key) .. " : " .. literal(value[key])
    end
    return "{ " .. table.concat(entries, ", ") .. " }"
  end
  error("unsupported write-vivification fixture value", 0)
end

local function instrument(marker, expression)
  return "{ say(" .. json.encode(marker) .. "); " .. expression .. " }"
end

local function event_messages(events)
  local result = json.array()
  for index, event in ipairs(events) do
    result[index] = event.message:gsub("%s+$", "")
  end
  return result
end

local function source_engine(action)
  local source = "Top::\n -> Done { " .. action .. " }\n\nDone::\n /[a-z]+/\n"
  return linkedspec.runtime_engine(linkedspec.compile_spec(
    linkedspec.parse_spec_with_staged_user_function_definitions(source)
  ))
end

local function compile_source(source)
  return linkedspec.compile_spec(
    linkedspec.parse_spec_with_staged_user_function_definitions(source)
  )
end

local function ordinary_action(fixture, include_result)
  local statements = {}
  local initial = fixture.initial_binding
  if initial.present then statements[#statements + 1] = "document = " .. literal(initial.value) end

  local segments = {}
  for index, segment in ipairs(fixture.segments) do
    local source = segment.source
    if source:match("^[A-Za-z_][A-Za-z0-9_]*$") and
        source ~= "true" and source ~= "false" and source ~= "null" and source ~= "undef" then
      local value = segment.kind == "codeblock" and "{|value| return(value) }" or literal(segment.value)
      statements[#statements + 1] = source .. " = " .. value
    end
    segments[index] = instrument("segment:" .. (index - 1), source)
  end

  local rhs = fixture.rhs
  if rhs.source:match("^[A-Za-z_][A-Za-z0-9_]*$") then
    statements[#statements + 1] = rhs.source .. " = " .. literal(rhs.value)
  end
  local assignment = "document[" .. table.concat(segments, "][") .. "] = " ..
    instrument("rhs", rhs.source)
  if include_result then
    statements[#statements + 1] = "result = (" .. assignment .. ")"
    statements[#statements + 1] = "return(array(document, result))"
  else
    statements[#statements + 1] = assignment
  end
  return table.concat(statements, "; ")
end

local function nested_write_in(action)
  local block = linkedspec.parse_action_block(action)
  for _, statement in ipairs(block.statements) do
    local expression = statement.expr
    if expression.kind == "assign_nested_access" then return expression end
    if expression.value and expression.value.kind == "assign_nested_access" then return expression.value end
  end
  error("action did not contain a top-level nested write", 0)
end

local function structural_message(expected)
  local segment = expected.segment_index
  if expected.code == "nested_write_segment_invalid" then
    return "nested write segment " .. segment .. " for binding 'document' must evaluate to a string or " ..
      "nonnegative integer; got " .. expected.actual_kind .. " (" .. expected.reason .. ")"
  elseif expected.code == "nested_write_kind_conflict" then
    return "nested write segment " .. segment .. " for binding 'document' requires " ..
      expected.expected_kind .. "; found " .. expected.actual_kind
  end
  return "nested write segment " .. segment .. " for binding 'document' cannot create array index " ..
    expected.index .. " at length " .. expected.length
end

local function load_generated_module(source, chunk_name)
  local loader = loadstring or load
  local chunk, failure = loader(source, chunk_name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local contract = json.decode(read_file("capability_conformance/write_vivification_contract.json"))

check_equal(contract.contract_id, "linkedspec-write-vivification-v1", "contract id")
check_equal(#contract.valid_syntax_cases, 5, "valid syntax count")
check_equal(#contract.invalid_syntax_cases, 7, "invalid syntax count")
check_equal(#contract.success_cases, 11, "success count")
check_equal(#contract.failure_cases, 16, "structural failure count")
check_equal(#contract.evaluation_failure_cases, 3, "evaluation failure count")
check_equal(#contract.read_exclusion_cases, 3, "read exclusion count")

local expression_kinds = {
  identifier = "variable",
  integer_literal = "number",
  string_literal = "string",
}

for _, fixture in ipairs(contract.valid_syntax_cases) do
  local expected = fixture.expected_ast
  local expression = linkedspec.parse_action_expression(fixture.source)
  local actual = linkedspec.action_ast.to_json(expression)
  check_equal(linkedspec.action_ast.node_type(expression), "ActionExpr", fixture.id .. " node type")
  check_equal(actual.kind, "assign_nested_access", fixture.id .. " kind")
  check_equal(actual.source, fixture.source, fixture.id .. " source")
  check_same_json(actual.source_span, expected.source_span, fixture.id .. " assignment span")
  check_equal(actual.base, expected.base, fixture.id .. " base")
  check_equal(#actual.segments, #expected.segments, fixture.id .. " segment count")
  for index, expected_segment in ipairs(expected.segments) do
    local actual_segment = actual.segments[index]
    check_equal(actual_segment.kind, "path_segment", fixture.id .. " segment kind " .. index)
    check_equal(actual_segment.source, expected_segment.source, fixture.id .. " segment source " .. index)
    check_same_json(actual_segment.source_span, expected_segment.source_span,
      fixture.id .. " segment span " .. index)
    check_equal(actual_segment.expression.kind,
      expression_kinds[expected_segment.expression.kind] or expected_segment.expression.kind,
      fixture.id .. " expression kind " .. index)
    check_equal(actual_segment.expression.source, expected_segment.expression.source,
      fixture.id .. " expression source " .. index)
    check_same_json(actual_segment.expression.source_span, expected_segment.expression.source_span,
      fixture.id .. " expression span " .. index)
  end
  check_equal(actual.value.kind, expression_kinds[expected.value.kind] or expected.value.kind,
    fixture.id .. " value kind")
  check_equal(actual.value.source, expected.value.source, fixture.id .. " value source")
  check_same_json(actual.value.source_span, expected.value.source_span, fixture.id .. " value span")
end

for _, fixture in ipairs(contract.invalid_syntax_cases) do
  local ok, failure = capture(function() return linkedspec.parse_action_expression(fixture.source) end)
  check_equal(ok, false, fixture.id .. " rejects")
  check_equal(linkedspec.is_action_parse_error(failure), true, fixture.id .. " typed failure")
  if linkedspec.is_action_parse_error(failure) then
    local actual = linkedspec.action_parse_error_to_json(failure)
    local expected = fixture.diagnostic
    check_equal(actual.code, expected.code, fixture.id .. " code")
    check_equal(actual.stage, expected.stage, fixture.id .. " stage")
    check_equal(actual.message, expected.message, fixture.id .. " message")
    check_equal(actual.source_span.start, expected.source_span.start, fixture.id .. " start")
    check_equal(actual.source_span["end"], expected.source_span["end"], fixture.id .. " end")
    check_equal(actual.source_span.unit, expected.source_span.unit, fixture.id .. " unit")
    check_equal(actual.source_span.provenance, expected.source_span.provenance,
      fixture.id .. " provenance")
  end
end

for _, fixture in ipairs(contract.excluded_syntax_cases) do
  local expression = linkedspec.parse_action_expression(fixture.source)
  if fixture.classification == "not_nested_write" then
    check_equal(expression.kind, "assign_scalar", fixture.id)
  elseif fixture.classification == "read_only" then
    check_equal(expression.kind, "nested_access", fixture.id)
  elseif fixture.classification == "unsupported_helper" then
    check_equal(expression.kind, "call", fixture.id .. " kind")
    check_equal(expression.name, "vivify", fixture.id .. " name")
  else
    check(expression.kind ~= "assign_nested_access", fixture.id)
  end
end

do
  local future_receiver_mutation = linkedspec.parse_action_expression(
    'document.map_leaves!({|value| return(value) })'
  )
  check_equal(future_receiver_mutation.kind, "raw_perl", "map_leaves bang remains unadmitted")
end

local astral = linkedspec.action_ast.to_json(
  linkedspec.parse_action_expression('document["🙂"][position] = "值"')
)
check_same_json(astral.source_span, json.harray({ start = 0, ["end"] = 29 }), "astral assignment span")
check_same_json(astral.segments[1].source_span, json.harray({ start = 9, ["end"] = 12 }),
  "astral first segment span")
check_same_json(astral.segments[2].source_span, json.harray({ start = 14, ["end"] = 22 }),
  "astral second segment span")
check_same_json(astral.value.source_span, json.harray({ start = 26, ["end"] = 29 }),
  "astral value span")

for _, fixture in ipairs(contract.success_cases) do
  local action
  if fixture.id == "rhs_same_binding_side_effect_composes" then
    action = 'document = { "audit" : [] }; result = (document[' ..
      instrument("segment:0", '"value"') .. '] = { say("rhs"); ' ..
      'document = { "audit" : ["rhs"] }; "done" }); return(array(document, result))'
  elseif fixture.id == "segment_same_binding_side_effect_composes" then
    action = 'result = (document[{ say("segment:0"); document = { "seed" : 1 }; "value" }] = ' ..
      instrument("rhs", '"done"') .. '); return(array(document, result))'
  else
    action = ordinary_action(fixture, true)
  end
  local events = {}
  local result = linkedspec.runtime_parse(source_engine(action), "xhello", {
    diagnostic_sink = function(event) events[#events + 1] = event end,
  })
  check_same_json(result.value, json.array({ fixture.expected_binding, fixture.expected_result }),
    fixture.id .. " result")
  check_same_json(event_messages(events), fixture.expected_effects, fixture.id .. " evaluation order")
end

for _, fixture in ipairs(contract.failure_cases) do
  local action
  if fixture.id == "rhs_side_effect_survives_outer_gap" then
    action = "document = []; document[" .. instrument("segment:0", "2") ..
      '] = { say("rhs"); document = ["rhs"]; "outer" }'
  else
    action = ordinary_action(fixture, false)
  end
  local events = {}
  local ok, failure = capture(function()
    return linkedspec.runtime_parse(source_engine(action), "xhello", {
      diagnostic_sink = function(event) events[#events + 1] = event end,
    })
  end)
  check_equal(ok, false, fixture.id .. " rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(failure), true, fixture.id .. " typed failure")
  if linkedspec.is_runtime_interpreter_error(failure) then
    local expected = fixture.expected_error
    local actual = linkedspec.interpreter.to_json(failure.diagnostic)
    check_equal(actual.code, expected.code, fixture.id .. " code")
    check_equal(actual.operation, "nested_write_vivification", fixture.id .. " operation")
    check_equal(actual.binding, fixture.binding, fixture.id .. " binding")
    for _, field in ipairs({
      "segment_index", "path", "actual_kind", "reason", "expected_kind", "index", "length",
    }) do
      if expected[field] ~= nil then check_same_json(actual[field], expected[field], fixture.id .. " " .. field) end
    end
    check_equal(failure.message, structural_message(expected), fixture.id .. " message")
    local write = nested_write_in(action)
    local source_span = write.segments[expected.segment_index + 1].source_span
    check_same_json(actual.source_span, json.harray({
      start = source_span.start,
      ["end"] = source_span["end"],
      unit = "unicode_scalar",
      provenance = "authored",
    }), fixture.id .. " diagnostic span")
  end
  check_same_json(event_messages(events), fixture.expected_effects, fixture.id .. " evaluation order")
end

for _, fixture in ipairs(contract.evaluation_failure_cases) do
  local statements = {}
  if fixture.initial_binding.present then
    statements[#statements + 1] = "document = " .. literal(fixture.initial_binding.value)
  end
  local segments = {}
  local failing_marker
  local expected_failure
  for index, segment in ipairs(fixture.segments) do
    local marker = "segment:" .. (index - 1)
    if segment.evaluation_error ~= nil then
      failing_marker = marker
      expected_failure = segment.evaluation_error
    end
    segments[index] = instrument(marker, literal(segment.value or "unreached"))
  end
  if fixture.rhs.evaluation_error ~= nil then
    failing_marker = "rhs"
    expected_failure = fixture.rhs.evaluation_error
  end
  statements[#statements + 1] = "document[" .. table.concat(segments, "][") .. "] = " ..
    instrument("rhs", literal(fixture.rhs.value or "unreached"))

  local _, injected = capture(function() return linkedspec.runtime_parse({}, "x") end)
  injected.code = expected_failure.code
  injected.message = expected_failure.message
  local events = {}
  local ok, failure = capture(function()
    return linkedspec.runtime_parse(source_engine(table.concat(statements, "; ")), "xhello", {
      diagnostic_sink = function(event)
        events[#events + 1] = event
        if event.message:gsub("%s+$", "") == failing_marker then error(injected, 0) end
      end,
    })
  end)
  check_equal(ok, false, fixture.id .. " rejects")
  check_equal(failure, injected, fixture.id .. " preserves exact failure identity")
  check_equal(failure.code, expected_failure.code, fixture.id .. " code")
  check_equal(failure.message, expected_failure.message, fixture.id .. " message")
  check_same_json(event_messages(events), fixture.expected_effects, fixture.id .. " stopped order")
end

for _, fixture in ipairs(contract.read_exclusion_cases) do
  local statements = {}
  if fixture.initial_binding.present then
    statements[#statements + 1] = "document = " .. literal(fixture.initial_binding.value)
  end
  local segments = {}
  for index, segment in ipairs(fixture.segments) do segments[index] = literal(segment.value) end
  statements[#statements + 1] = "observed = document[" .. table.concat(segments, "][") .. "]"
  statements[#statements + 1] = "return(array(document, observed))"
  local result = linkedspec.runtime_parse(source_engine(table.concat(statements, "; ")), "xhello")
  local expected_binding = fixture.expected_binding.present and fixture.expected_binding.value or json.null
  check_same_json(result.value, json.array({ expected_binding, fixture.expected_result }), fixture.id)
end

do
  local expected = contract.detachment_case.expected
  local result = linkedspec.runtime_parse(source_engine([[
initial = { "existing" : ["keep"] };
document = initial;
rhs = ["a"];
result = (document["payload"] = rhs);
rhs[0] = "rhs-mutated";
result["payload"][0] = "result-mutated";
document["existing"][0] = "binding-mutated";
initial["existing"][0] = "initial-mutated";
return(array(initial, rhs, document, result))
]]), "xhello")
  check_same_json(result.value,
    json.array({ expected.initial, expected.rhs, expected.binding, expected.result }), "detachment")
end

do
  local fresh_source = [[fn build_document() {
 document["items"][0] = "value";
 return(document)
}

Top::
 -> Done { return(array(build_document(), build_document())) }

Done::
 /[a-z]+/
]]
  local fresh = linkedspec.runtime_parse(linkedspec.runtime_engine(compile_source(fresh_source)), "xhello")
  check_same_json(fresh.value, json.array({
    json.harray({ items = json.array({ "value" }) }),
    json.harray({ items = json.array({ "value" }) }),
  }), "fresh function state")

  local bound_null_source = [[fn write_document(document) {
 document["key"] = "value";
 return(document)
}

Top::
 -> Done { return(write_document(undef)) }

Done::
 /[a-z]+/
]]
  local ok, failure = capture(function()
    return linkedspec.runtime_parse(linkedspec.runtime_engine(compile_source(bound_null_source)), "xhello")
  end)
  check_equal(ok, false, "bound null rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(failure), true, "bound null typed")
  if linkedspec.is_runtime_interpreter_error(failure) then
    check_equal(failure.diagnostic.code, "nested_write_kind_conflict", "bound null code")
    check_equal(failure.diagnostic.binding, "document", "bound null binding")
    check_equal(failure.diagnostic.actual_kind, "null", "bound null actual kind")
  end
end

local route_source = [[Top::
 -> Done { key_name = "sections"; document[key_name][0]["title"] = "Intro"; return(document) }

Done::
 /[a-z]+/
]]
local route_expected = json.harray({
  sections = json.array({ json.harray({ title = "Intro" }) }),
})
local authored = linkedspec.parse_spec(route_source, { source_id = "write-vivification/lua.spec" })
local reconstructed = linkedspec.spec_ast.from_json(
  "SpecFile",
  json.decode(json.encode(linkedspec.spec_ast.to_json(authored)))
)
local route_compiled = linkedspec.compile_spec(reconstructed)
local descriptor_json = json.encode(linkedspec.to_descriptor_json(route_compiled))
check_contains(descriptor_json, '"kind":"assign_nested_access"', "descriptor nested-write node")
check_contains(descriptor_json, '"kind":"path_segment"', "descriptor path segment")
check_contains(descriptor_json, '"source":"key_name"', "descriptor authored selector")
check_same_json(
  linkedspec.runtime_parse(linkedspec.runtime_engine(route_compiled), "xhello").value,
  route_expected,
  "public reconstructed route"
)
local route_identity = "write-vivification/lua.spec"
local route_plan = linkedspec.build_generated_rule_plan(route_compiled)
check_same_json(
  linkedspec.execute_generated_parser_v2(route_compiled, route_plan, "xhello", route_identity),
  route_expected,
  "generated direct route"
)
local emitted = linkedspec.emit_lua_source_v2(route_compiled, route_identity)
local generated = load_generated_module(emitted, "@write-vivification-lua")
check_same_json(generated.execute("xhello"), route_expected, "emitted source route")
local cli = linkedspec.run_primary_cli({ "--inline-spec", route_source, "--input", "xhello" })
check_equal(cli.exit_code, 0, "primary CLI exit")
check_equal(cli.stderr, "", "primary CLI stderr")
check_same_json(json.decode(cli.stdout), route_expected, "primary CLI result")

do
  local corrupted = compile_source([[
Top::
 -> Done { document["x"] = "y"; return(document) }

Done::
 /[a-z]+/
]])
  local payload = linkedspec.compiled_spec.action_payloads(corrupted.rules_by_label.Top)[1]
  payload.action_ast.statements[1].expr.segments = {}

  local validator_ok, validator_failure = capture(function()
    return linkedspec.validate_nested_write_serialized_state(corrupted)
  end)
  check_equal(validator_ok, false, "corrupt validator rejects")
  check_equal(linkedspec.is_compiled_spec_error(validator_failure), true, "corrupt validator typed")
  check_contains(validator_failure.message, "nested_write_serialized_state_invalid", "validator code")

  local runtime_ok, runtime_failure = capture(function() return linkedspec.runtime_engine(corrupted) end)
  check_equal(runtime_ok, false, "corrupt runtime rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(runtime_failure), true, "corrupt runtime typed")
  if linkedspec.is_runtime_interpreter_error(runtime_failure) then
    check_equal(runtime_failure.diagnostic.code, "nested_write_serialized_state_invalid", "runtime code")
  end

  local emit_ok, emit_failure = capture(function()
    return linkedspec.emit_lua_source_v2(corrupted, "write-vivification/corrupt.spec")
  end)
  check_equal(emit_ok, false, "corrupt emit rejects")
  check_equal(linkedspec.is_generated_source_error(emit_failure), true, "corrupt emit typed")
  if linkedspec.is_generated_source_error(emit_failure) then
    check_contains(emit_failure.detail, "nested_write_serialized_state_invalid", "emit detail")
  end

  local plan_ok, plan_failure = capture(function()
    return linkedspec.validate_generated_rule_plan_v2(
      corrupted,
      linkedspec.build_generated_rule_plan(corrupted),
      "write-vivification/corrupt.spec"
    )
  end)
  check_equal(plan_ok, false, "corrupt generated plan rejects")
  check_equal(linkedspec.is_generated_source_error(plan_failure), true, "corrupt plan typed")
  if linkedspec.is_generated_source_error(plan_failure) then
    check_contains(plan_failure.detail, "nested_write_serialized_state_invalid", "plan detail")
  end

  local reserved = compile_source([[
Top::
 -> Done { document["x"] = "y"; return(document) }

Done::
 /[a-z]+/
]])
  local reserved_payload = linkedspec.compiled_spec.action_payloads(reserved.rules_by_label.Top)[1]
  reserved_payload.action_ast.statements[1].expr.base = "retv"
  local reserved_ok, reserved_failure = capture(function()
    return linkedspec.validate_nested_write_serialized_state(reserved)
  end)
  check_equal(reserved_ok, false, "corrupt reserved root rejects")
  check_equal(linkedspec.is_compiled_spec_error(reserved_failure), true, "corrupt reserved root typed")
  check_contains(reserved_failure.message, "must not be a reserved binding", "corrupt reserved root detail")
end

if #failures == 0 then
  io.stdout:write("write-vivification Lua dual-ABI admission: ", assertions, " assertions passed\n")
else
  io.stderr:write(
    "write-vivification Lua dual-ABI admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
