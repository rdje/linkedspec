-- FUTURE-PARITY-BACKLOG.11.8.1-.3 -- callable construction, invocation, and emitted identity.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local semantic_index_module = require("linkedspec.semantic_index")

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

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
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
  local template = temp_root:gsub("/+$", "") ..
    "/linkedspec-lua-callable-codeblock-emitted.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())

  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf -- " .. shell_quote(root))
  if not cleaned then error("unable to clean callable-codeblock emitted workspace", 0) end
  if not ok then error(value, 0) end
  return value, root
end

local function table_key_set(value)
  local result = json.harray()
  for key in pairs(value) do result[key] = true end
  return result
end

local function utf8_length(value)
  local count = 0
  local position = 1
  while position <= #value do
    local first = value:byte(position)
    local width = first <= 0x7F and 1 or (first <= 0xDF and 2 or (first <= 0xEF and 3 or 4))
    position = position + width
    count = count + 1
  end
  return count
end

local function assignment_value(source)
  local block = linkedspec.parse_action_block("value = " .. source)
  return block.statements[1].expr.value
end

local function portable_runtime_value(value, active)
  if linkedspec.action_ast.node_type(value) == "ActionExpr" then
    return linkedspec.action_ast.to_json(value)
  end
  local kind = json.kind(value)
  if kind ~= "array" and kind ~= "harray" then return value end
  active = active or {}
  if active[value] then error("test runtime value must not be cyclic", 0) end
  active[value] = true
  local result = kind == "array" and json.array() or json.harray()
  for key, item in pairs(value) do result[key] = portable_runtime_value(item, active) end
  active[value] = nil
  return result
end

local function compile_source(source)
  return linkedspec.compile_spec(
    linkedspec.parse_spec_with_staged_user_function_definitions(source)
  )
end

local decode_hex

local function reconstruct_emitted(compiled, identity)
  local source = linkedspec.emit_lua_source_v2(compiled, identity)
  local payload = assert(source:match(
    'local _EFFECTIVE_SPEC_JSON_HEX = "([0-9a-f]+)"'
  ))
  return linkedspec.compile_spec(linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(decode_hex(payload))
  ))
end

local function execute_generated(compiled, input, identity)
  return portable_runtime_value(linkedspec.execute_generated_parser_v2(
    compiled,
    linkedspec.build_generated_rule_plan(compiled),
    input,
    identity
  ))
end

local function generated_failure(compiled, identity)
  local ok, failure = capture(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      "x",
      identity
    )
  end)
  check_equal(ok, false, identity .. " generated failure expected")
  check_equal(linkedspec.is_generated_source_error(failure), true,
    identity .. " generated failure type")
  if linkedspec.is_generated_source_error(failure) then
    check_equal(failure.stage, "execute_generated", identity .. " generated failure stage")
    check_equal(failure.code, "generated_execution_failed", identity .. " generated failure code")
    check_equal(failure.source_identity, identity, identity .. " generated failure identity")
  end
  return failure
end

local function execute_native(compiled)
  return portable_runtime_value(
    linkedspec.runtime_execute(linkedspec.runtime_engine(compiled), "xx").value
  )
end

local function runtime_failure(compiled)
  local ok, failure = capture(function()
    return linkedspec.runtime_execute(linkedspec.runtime_engine(compiled), "x")
  end)
  check_equal(ok, false, "runtime failure expected")
  check_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed runtime failure")
  return failure
end

local function invalid_call_source(id)
  local bodies = {
    fixed_missing = 'cb = {|left, right| return(cat(left, right)) }; return(cb("a"))',
    fixed_extra = 'cb = {|left, right| return(cat(left, right)) }; return(cb("a", "b", "c"))',
    rest_missing_fixed = 'cb = {|prefix, ...items| return(items) }; return(cb())',
    keyword_argument = 'cb = {|value| return(value) }; return(cb(value: "x"))',
    bound_non_codeblock = 'text = "not callable"; return(text())',
    unknown_call = 'cb = {|| return(missing()) }; return(cb())',
    direct_recursion = 'reader = {|| return(reader()) }; return(reader())',
  }
  local body = assert(bodies[id], "unowned invalid callable-codeblock case " .. tostring(id))
  return "Top::\n /x/\n E { " .. body .. " }\n"
end

decode_hex = function(value)
  local bytes = {}
  for index = 1, #value, 2 do
    bytes[#bytes + 1] = string.char(tonumber(value:sub(index, index + 1), 16))
  end
  return table.concat(bytes)
end

local contextual_source = [[fn apply(value, callback: codeblock) { return(callback()) }
fn invoke(value, callback: codeblock) { return(callback(value)) }

Top::
 /x/
 E {
   value = {|item| return(cat(item, "!")) };
   return([
     with("x") { return(cat(value, "!")) },
     with("x", { return(cat(value, "!")) }),
     with("x", {|item| return(cat(item, "!")) }),
     with("x", value),
     with("outer") { return(with("inner") { return(cat(value, "!")) }) },
     "x".with() { return(cat(value, "!")) },
     "x".with({ return(cat(value, "!")) }),
     "x".with({|item| return(cat(item, "!")) }),
     "x".with(value),
     apply("a") { return(cat(value, "!")) },
     apply("b", { return(cat(value, "?")) }),
     invoke("c", {|item| return(cat(item, ".")) }),
     { "b" : 2, "a" : 1 }.map_leaves() { return(cat(value, "!")) },
     { "b" : 2, "a" : 1 }.map_leaves({ return(cat(value, "!")) }),
     { "b" : 2, "a" : 1 }.map_leaves(value)
   ])
 }
]]
local contextual_expected = json.array({
  "x!", "x!", "x!", "x!", "inner!", "x!", "x!", "x!", "x!",
  "a!", "b?", "c.",
  json.harray({ a = "1!", b = "2!" }),
  json.harray({ a = "1!", b = "2!" }),
  json.harray({ a = "1!", b = "2!" }),
})
local contextual_invalid_source = [[fn apply(value, callback: codeblock) { return(callback()) }

Top::
 /x/
 E { return(apply("x", { "value" : value })) }
]]
local mutual_recursion_source = [[Top::
 /x/
 E {
   left = {|| return(right()) };
   right = {|| return(left()) };
   return(left())
 }
]]
local helper_recursion_source = [[Top::
 /x/
 E {
   callback = {|item| return(with(item, callback)) };
   return(callback("x"))
 }
]]
local keyword_user_source = [[fn identity(value) { return(value) }

Top::
 /x/
 E { return(identity(value: "x")) }
]]

local contract = json.decode(read_file("capability_conformance/callable_codeblock_contract.json"))

-- The seven neutral brace classes remain disjoint.
for _, row in ipairs(contract.brace_classification) do
  local kind = assignment_value(row.source).kind
  if kind == "hash_literal" then kind = "harray_literal" end
  check_equal(kind, row.expected_kind, "brace class " .. row.id)
end

-- Every valid literal has the exact neutral record, signature, body, and spans.
local expected_fields = json.harray()
for _, field in ipairs(contract.ast_schema.fields) do expected_fields[field] = true end
for _, row in ipairs(contract.literals) do
  local expression = assignment_value(row.source)
  local record = linkedspec.action_ast.to_json(expression)
  check_equal(expression.kind, "codeblock_literal", row.id .. " typed node")
  check_same_json(table_key_set(record), expected_fields, row.id .. " exact field set")
  check_equal(record.kind, "codeblock_literal", row.id .. " record kind")
  check_equal(record.version, 1, row.id .. " record version")
  check_equal(record.source_text, row.source, row.id .. " source text")
  check_equal(record.body_source, row.body_source, row.id .. " body source")
  check_equal(record.body_ast.kind, "action_block", row.id .. " typed body")
  check_equal(record.body_ast.source, row.body_source, row.id .. " body AST source")
  check(#record.body_ast.statements > 0, row.id .. " body statements")
  check_equal(record.source_span.start, 8, row.id .. " source span start")
  check_equal(record.source_span["end"], 8 + utf8_length(row.source), row.id .. " source span end")

  local closer = assert(row.source:find("|", 3, true))
  local expected_body_start = 8 + utf8_length(row.source:sub(1, closer))
  check_equal(record.body_span.start, expected_body_start, row.id .. " body span start")
  check_equal(record.body_span["end"], 8 + utf8_length(row.source:sub(1, -2)), row.id .. " body span end")

  local positional = json.array()
  local rest = json.null
  if row.signature_source ~= "" then
    for part in row.signature_source:gmatch("[^,]+") do
      local name = part:match("^%s*(.-)%s*$")
      if name:sub(1, 3) == "..." then rest = name:sub(4)
      else positional[#positional + 1] = name end
    end
  end
  check_same_json(record.signature, json.harray({
    kind = "callable_signature",
    version = 1,
    positional_params = positional,
    rest_param = rest,
    min_arity = #positional,
    max_arity = rest == json.null and #positional or json.null,
  }), row.id .. " signature")
end

local nested_source = "prefix = \"😀\"; cb = {|| nested = {|value| return(value) } }"
local nested_block = linkedspec.parse_action_block(nested_source)
local outer = linkedspec.action_ast.to_json(nested_block.statements[2].expr.value)
local inner = outer.body_ast.statements[1].expr.value
local inner_start = assert(nested_source:find("{|value|", 1, true)) - 1
check_equal(inner.source_span.start, utf8_length(nested_source:sub(1, inner_start)),
  "nested literal uses containing Unicode coordinates")
local delimiter_source =
  "{|value| return({ \"marker\" : \"|}\", \"nested\" : { \"value\" : value } }) }"
local delimiter_literal = linkedspec.parse_action_expression(delimiter_source)
check_equal(delimiter_literal.kind, "codeblock_literal", "nested delimiters retain literal boundary")
check_equal(delimiter_literal.source, delimiter_source, "nested delimiters retain exact source")
check_equal(delimiter_literal.body_ast.statements[1].expr.kind, "call",
  "nested delimiters retain typed deferred body")

-- Malformed literal-like braces retain all nine neutral diagnostic codes.
for _, row in ipairs(contract.invalid_literal_cases) do
  local expression = linkedspec.parse_action_expression(row.source)
  check_equal(expression.kind, "codeblock_literal_error", row.id .. " typed literal error")
  check_equal(expression.code, row.expected_code, row.id .. " parser code")
  local resolution = linkedspec.resolve_action_expression_contracts(expression)
  check_equal(#resolution.diagnostics, 1, row.id .. " one contract diagnostic")
  check_equal(resolution.diagnostics[1] and resolution.diagnostics[1].code,
    row.expected_code, row.id .. " contract diagnostic code")
end

local construction_literal = contract.literals[3]
local construction_source = "Top::\n" ..
  " /x/ -> Done { state = \"before\"; cb = " .. construction_literal.source ..
  "; alias = copy(cb); return({ \"state\" : state, \"cb\" : alias }) }\n\n" ..
  "Done::\n /x/\n"
local construction_compiled = compile_source(construction_source)
local direct = execute_native(construction_compiled)
local authored_literal = construction_compiled.rules_by_label.Top.action_edges[1]
  .action_payload.action_ast.statements[2].expr.value
check_equal(direct.state, "before", "construction does not execute the body")
check_equal(direct.cb.kind, "codeblock_literal", "native construction is typed")
check_equal(direct.cb.source_text, construction_literal.source, "native construction source")
check_equal(direct.cb.body_source, construction_literal.body_source, "native construction body")
check_same_json(direct.cb.source_span, linkedspec.action_ast.to_json(authored_literal).source_span,
  "runtime copy preserves containing source span")
check_same_json(direct.cb.body_span, linkedspec.action_ast.to_json(authored_literal).body_span,
  "runtime copy preserves containing body span")
check(json.encode(linkedspec.compiled_spec_to_json(construction_compiled)):find(
  "codeblock_literal", 1, true) ~= nil, "compiled JSON retains typed literal")
local generated = portable_runtime_value(linkedspec.execute_generated_parser_v2(
  construction_compiled,
  linkedspec.build_generated_rule_plan(construction_compiled),
  "xx",
  "callable-codeblock-construction.spec"
))
check_same_json(generated, direct, "generated plan preserves inert construction")

local emitted = linkedspec.emit_lua_source_v2(
  construction_compiled,
  "callable-codeblock-construction.spec"
)
local effective_hex = emitted:match('local _EFFECTIVE_SPEC_JSON_HEX = "([0-9a-f]+)"')
check(effective_hex ~= nil, "emitted source contains effective SpecFile payload")
if effective_hex ~= nil then
  local reconstructed_spec = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(decode_hex(effective_hex))
  )
  local reconstructed = execute_native(linkedspec.compile_spec(reconstructed_spec))
  check_same_json(reconstructed, direct, "emitted payload reconstructs inert construction")
end

-- Ordinary user functions copy explicit literals through arguments and results.
local function_source = [[fn identity(value) { return(value) }
fn make() { return({|| return("never") }) }

Top::
 /x/ -> Done {
   state = "before";
   from_arg = identity({|value| state = "wrong"; return(value) });
   from_result = make();
   return({ "state" : state, "from_arg" : from_arg, "from_result" : from_result })
 }

Done::
 /x/
]]
local transported = execute_native(compile_source(function_source))
check_equal(transported.state, "before", "function transport remains inert")
check_equal(transported.from_arg.kind, "codeblock_literal", "function argument literal")
check_equal(transported.from_result.kind, "codeblock_literal", "function result literal")
check_equal(transported.from_arg.signature.positional_params[1], "value", "argument signature")
check_equal(transported.from_result.signature.max_arity, 0, "result signature")

local variadic_spec = linkedspec.parse_spec_with_staged_user_function_definitions(
  "fn gather(...items) { return(items) }\n\nTop::\n /x/\n"
)
local malformed_variadic = json.decode(json.encode(linkedspec.spec_ast.to_json(variadic_spec)))
malformed_variadic.functions[1].signature.rest_param = json.null
local variadic_ok, variadic_failure = capture(function()
  return linkedspec.spec_ast.from_json("SpecFile", malformed_variadic)
end)
check_equal(variadic_ok, false, "nullable literal signature does not weaken variadic function state")
check(tostring(variadic_failure):find("rest_param", 1, true) ~= nil,
  "variadic function rejection names rest parameter")

-- Literal bodies are deferred from eager contracts and removed-selector scanning.
local deferred = linkedspec.parse_action_expression(
  "{|| state = \"wrong\"; missing(); call(Done); return(retv) }"
)
check_equal(#linkedspec.resolve_action_expression_contracts(deferred).diagnostics, 0,
  "literal body is deferred from action contracts")
check_equal(linkedspec.action_ast.find_removed_aggregate_selector(deferred), nil,
  "literal body is deferred from removed-selector scanning")
local eager_unknown = linkedspec.resolve_action_expression_contracts(
  linkedspec.parse_action_expression("cb()")
)
check_equal(eager_unknown.diagnostics[1] and eager_unknown.diagnostics[1].code,
  "unknown_helper", "unbound call remains statically unknown")

-- Dynamic invocation adds only the two narrow ActionIR seams required by the neutral contract.
local keyword_call = linkedspec.parse_action_expression('cb(value: "x")')
check_equal(keyword_call.kind, "call", "colon keyword call remains typed")
check_equal(#keyword_call.args, 1, "colon keyword count")
check_equal(linkedspec.action_ast.node_type(keyword_call.args[1]),
  "ActionArgument", "colon keyword argument node")
check_equal(keyword_call.args[1].argument_kind, "keyword", "colon keyword argument kind")
check_equal(keyword_call.args[1].name, "value", "colon keyword argument name")

local assignment_call = linkedspec.parse_action_expression('cb(value = "x")')
check_equal(assignment_call.kind, "call", "assignment argument call remains typed")
check_equal(assignment_call.args[1].argument_kind, "positional", "assignment remains positional")
check_equal(assignment_call.args[1].value.kind, "assign_scalar", "assignment retains expression kind")

local result_chain = linkedspec.parse_action_expression('collector("p")["items"].length()')
check_equal(result_chain.kind, "fluent_chain", "call-result access may receive a fluent chain")
check_equal(result_chain.receiver.kind, "value_access", "call-result access uses a typed receiver")
check_equal(result_chain.receiver.receiver.kind, "call", "value access retains evaluated receiver")
check_equal(result_chain.receiver.segments[1].kind, "key", "value access retains key segment")
check_equal(result_chain.receiver.segments[1].value, "items", "value access retains key")

-- The exact neutral fixture proves caller-state reads and mutation, copied parameters/rest,
-- result access, block-local return, and inert construction in one execution.
local expected_call_ids = json.harray()
for _, id in ipairs({
  "construction_is_deferred",
  "fixed_exact",
  "dynamic_read_uses_call_time_state",
  "nonparameter_mutation_persists",
  "parameter_binding_restores",
  "rest_empty",
  "rest_mixed",
  "rest_result_receiver_chain",
  "block_local_return",
  "standalone_discard_keeps_effects",
  "static_name_precedence",
}) do expected_call_ids[id] = true end
local actual_call_ids = json.harray()
for _, row in ipairs(contract.call_cases) do actual_call_ids[row.id] = true end
check_same_json(actual_call_ids, expected_call_ids, "all neutral call cases are owned")
local fixture_compiled = compile_source(contract.fixture.spec_source)
check_same_json(
  execute_native(fixture_compiled),
  contract.fixture.expected,
  "exact neutral dynamic invocation fixture native"
)
check_same_json(
  execute_native(reconstruct_emitted(
    fixture_compiled,
    "callable-codeblock/neutral-fixture-reconstructed.spec"
  )),
  contract.fixture.expected,
  "exact neutral dynamic invocation fixture reconstructed"
)
check_same_json(
  execute_generated(
    fixture_compiled,
    contract.fixture.input,
    "callable-codeblock/neutral-fixture-generated.spec"
  ),
  contract.fixture.expected,
  "exact neutral dynamic invocation fixture generated"
)

local invocation_source = [[fn choose() { return("static") }
fn invoke(value, callback: codeblock) { return(callback(value)) }

Top::
 /x/
 E {
   state = "";
   append_state = {|value| state = cat(state, value); return(state) };
   append_state("x");
   cat = {|left, right| return("shadow") };
   choose = {|| return("shadow") };
   order = "";
   tick = {|value| order = cat(order, value); return(value) };
   joiner = {|left, right| return(cat(left, right)) };
   original = { "nested" : [{ "value" : "outer" }] };
   mutate_copy = {|copy| copy["nested"][0]["value"] = "inner"; return(copy) };
   mutated = mutate_copy(original);
   nested_return = {|| copy(return("done")); return("wrong") };
   return({
     "discard_state" : state,
     "helper_precedence" : cat("a", "b"),
     "function_precedence" : choose(),
     "ordered_result" : joiner(tick("a"), tick("b")),
     "ordered_effect" : order,
     "original" : original,
     "mutated" : mutated,
     "declared_final_literal" : invoke("c", {|item| return(cat(item, ".")) }),
     "nested_return" : nested_return()
   })
 }
]]
local invocation_compiled = compile_source(invocation_source)
local invocation_expected = json.harray({
  discard_state = "x",
  helper_precedence = "ab",
  function_precedence = "static",
  ordered_result = "ab",
  ordered_effect = "ab",
  original = json.harray({ nested = json.array({ json.harray({ value = "outer" }) }) }),
  mutated = json.harray({ nested = json.array({ json.harray({ value = "inner" }) }) }),
  declared_final_literal = "c.",
  nested_return = "done",
})
check_same_json(execute_native(invocation_compiled), invocation_expected,
  "dynamic invocation precedence order copies and local return native")
check_same_json(execute_native(reconstruct_emitted(
  invocation_compiled,
  "callable-codeblock/invocation-reconstructed.spec"
)), invocation_expected, "dynamic invocation reconstructed identity")
check_same_json(execute_generated(
  invocation_compiled,
  "x",
  "callable-codeblock/invocation-generated.spec"
), invocation_expected, "dynamic invocation generated identity")

local contextual_compiled = compile_source(contextual_source)
check_same_json(execute_native(contextual_compiled), contextual_expected,
  "contextual forms native identity")
check_same_json(execute_native(reconstruct_emitted(
  contextual_compiled,
  "callable-codeblock/contextual-reconstructed.spec"
)), contextual_expected, "contextual forms reconstructed identity")
check_same_json(execute_generated(
  contextual_compiled,
  "x",
  "callable-codeblock/contextual-generated.spec"
), contextual_expected, "contextual forms generated identity")

-- Every neutral invalid call projects the exact governed diagnostic fields.
local expected_runtime_details = json.harray()
for _, row in ipairs(contract.invalid_call_cases) do
  local compiled = compile_source(invalid_call_source(row.id))
  local failure = runtime_failure(compiled)
  expected_runtime_details[row.id] = tostring(failure)
  if linkedspec.is_runtime_interpreter_error(failure) then
    check_equal(linkedspec.is_runtime_diagnostic(failure.diagnostic), true,
      row.id .. " typed runtime diagnostic")
    local diagnostic = failure.diagnostic and linkedspec.interpreter.to_json(failure.diagnostic) or {}
    for key, expected in pairs(row.expected_error) do
      check_same_json(diagnostic[key], expected, row.id .. " diagnostic " .. key)
    end
  end
  local reconstructed = runtime_failure(reconstruct_emitted(
    compiled,
    "callable-codeblock/" .. row.id .. "-reconstructed.spec"
  ))
  if linkedspec.is_runtime_interpreter_error(reconstructed) then
    local diagnostic = reconstructed.diagnostic and
      linkedspec.interpreter.to_json(reconstructed.diagnostic) or {}
    for key, expected in pairs(row.expected_error) do
      check_same_json(diagnostic[key], expected, row.id .. " reconstructed diagnostic " .. key)
    end
  end
  local generated = generated_failure(
    compiled,
    "callable-codeblock/" .. row.id .. "-generated.spec"
  )
  if linkedspec.is_generated_source_error(generated) then
    check_equal(generated.detail, tostring(failure),
      row.id .. " generated runtime detail identity")
  end
end

local mutual_compiled = compile_source(mutual_recursion_source)
local mutual_failure = runtime_failure(mutual_compiled)
expected_runtime_details.mutual_recursion = tostring(mutual_failure)
if linkedspec.is_runtime_interpreter_error(mutual_failure) then
  local diagnostic = mutual_failure.diagnostic and
    linkedspec.interpreter.to_json(mutual_failure.diagnostic) or {}
  check_equal(diagnostic.code, "codeblock_recursion_unsupported", "mutual recursion code")
  check_equal(diagnostic.callable_name, "left", "mutual recursion callable")
  check_same_json(diagnostic.cycle, json.array({ "left", "right", "left" }),
    "mutual recursion ordered cycle")
end
local mutual_reconstructed = runtime_failure(reconstruct_emitted(
  mutual_compiled,
  "callable-codeblock/mutual-reconstructed.spec"
))
if linkedspec.is_runtime_interpreter_error(mutual_reconstructed) then
  local diagnostic = mutual_reconstructed.diagnostic and
    linkedspec.interpreter.to_json(mutual_reconstructed.diagnostic) or {}
  check_equal(diagnostic.code, "codeblock_recursion_unsupported", "mutual reconstructed code")
  check_same_json(diagnostic.cycle, json.array({ "left", "right", "left" }),
    "mutual reconstructed ordered cycle")
end
local mutual_generated = generated_failure(
  mutual_compiled,
  "callable-codeblock/mutual-generated.spec"
)
if linkedspec.is_generated_source_error(mutual_generated) then
  check_equal(mutual_generated.detail, tostring(mutual_failure),
    "mutual generated runtime detail identity")
end

local helper_recursion_compiled = compile_source(helper_recursion_source)
local helper_recursion_failure = runtime_failure(helper_recursion_compiled)
expected_runtime_details.helper_bound_recursion = tostring(helper_recursion_failure)
if linkedspec.is_runtime_interpreter_error(helper_recursion_failure) then
  local diagnostic = helper_recursion_failure.diagnostic and
    linkedspec.interpreter.to_json(helper_recursion_failure.diagnostic) or {}
  check_equal(diagnostic.code, "codeblock_recursion_unsupported", "helper-bound recursion code")
  check_equal(diagnostic.callable_name, "callback", "helper-bound recursion callable")
  check_same_json(diagnostic.cycle, json.array({ "callback", "callback" }),
    "helper-bound recursion ordered cycle")
end
local helper_recursion_reconstructed = runtime_failure(reconstruct_emitted(
  helper_recursion_compiled,
  "callable-codeblock/helper-bound-recursion-reconstructed.spec"
))
if linkedspec.is_runtime_interpreter_error(helper_recursion_reconstructed) then
  local diagnostic = helper_recursion_reconstructed.diagnostic and
    linkedspec.interpreter.to_json(helper_recursion_reconstructed.diagnostic) or {}
  check_equal(diagnostic.code, "codeblock_recursion_unsupported",
    "helper-bound reconstructed recursion code")
  check_same_json(diagnostic.cycle, json.array({ "callback", "callback" }),
    "helper-bound reconstructed ordered cycle")
end
local helper_recursion_generated = generated_failure(
  helper_recursion_compiled,
  "callable-codeblock/helper-bound-recursion-generated.spec"
)
if linkedspec.is_generated_source_error(helper_recursion_generated) then
  check_equal(helper_recursion_generated.detail, tostring(helper_recursion_failure),
    "helper-bound generated runtime detail identity")
end

local keyword_user_compiled = compile_source(keyword_user_source)
local keyword_user_failure = runtime_failure(keyword_user_compiled)
expected_runtime_details.user_function_keyword = tostring(keyword_user_failure)
if linkedspec.is_runtime_interpreter_error(keyword_user_failure) then
  check_equal(keyword_user_failure.code, "user_function_keyword_arguments_unsupported",
    "colon keyword cannot bypass user-function policy")
  check_equal(keyword_user_failure.got, 1, "user-function keyword count")
end
local keyword_user_reconstructed = runtime_failure(reconstruct_emitted(
  keyword_user_compiled,
  "callable-codeblock/user-keyword-reconstructed.spec"
))
if linkedspec.is_runtime_interpreter_error(keyword_user_reconstructed) then
  check_equal(keyword_user_reconstructed.code, "user_function_keyword_arguments_unsupported",
    "reconstructed colon keyword retains user-function policy")
end
local keyword_user_generated = generated_failure(
  keyword_user_compiled,
  "callable-codeblock/user-keyword-generated.spec"
)
if linkedspec.is_generated_source_error(keyword_user_generated) then
  check_equal(keyword_user_generated.detail, tostring(keyword_user_failure),
    "generated colon keyword retains user-function policy")
end

local contextual_invalid_compiled = compile_source(contextual_invalid_source)
local contextual_invalid = runtime_failure(contextual_invalid_compiled)
expected_runtime_details.contextual_harray = tostring(contextual_invalid)
if linkedspec.is_runtime_interpreter_error(contextual_invalid) then
  check_equal(contextual_invalid.code, "final_argument_not_codeblock",
    "contextual harray native rejection")
  check_equal(contextual_invalid.value_kind, "harray", "contextual harray native kind")
end
local contextual_invalid_reconstructed = runtime_failure(reconstruct_emitted(
  contextual_invalid_compiled,
  "callable-codeblock/contextual-invalid-reconstructed.spec"
))
if linkedspec.is_runtime_interpreter_error(contextual_invalid_reconstructed) then
  check_equal(contextual_invalid_reconstructed.code, "final_argument_not_codeblock",
    "contextual harray reconstructed rejection")
  check_equal(contextual_invalid_reconstructed.value_kind, "harray",
    "contextual harray reconstructed kind")
end
local contextual_invalid_generated = generated_failure(
  contextual_invalid_compiled,
  "callable-codeblock/contextual-invalid-generated.spec"
)
if linkedspec.is_generated_source_error(contextual_invalid_generated) then
  check_equal(contextual_invalid_generated.detail, tostring(contextual_invalid),
    "contextual harray generated rejection")
end

-- Byte-fresh emitted modules reuse the same effective SpecFile, compiler, generated plan,
-- and interpreter in an independently launched host process.
local emitted_cases = json.array({
  json.harray({
    id = "fixture",
    compiled = fixture_compiled,
    identity = "callable-codeblock/emitted-fixture.spec",
    input = contract.fixture.input,
    outcome = "value",
  }),
  json.harray({
    id = "contextual",
    compiled = contextual_compiled,
    identity = "callable-codeblock/emitted-contextual.spec",
    input = "x",
    outcome = "value",
  }),
  json.harray({
    id = "invocation",
    compiled = invocation_compiled,
    identity = "callable-codeblock/emitted-invocation.spec",
    input = "x",
    outcome = "value",
  }),
})
for _, row in ipairs(contract.invalid_call_cases) do
  emitted_cases[#emitted_cases + 1] = json.harray({
    id = row.id,
    compiled = compile_source(invalid_call_source(row.id)),
    identity = "callable-codeblock/emitted-" .. row.id .. ".spec",
    input = "x",
    outcome = "error",
    expected_detail = expected_runtime_details[row.id],
  })
end
for _, row in ipairs({
  {
    id = "mutual_recursion",
    compiled = mutual_compiled,
  },
  {
    id = "helper_bound_recursion",
    compiled = helper_recursion_compiled,
  },
  {
    id = "user_function_keyword",
    compiled = keyword_user_compiled,
  },
  {
    id = "contextual_harray",
    compiled = contextual_invalid_compiled,
  },
}) do
  emitted_cases[#emitted_cases + 1] = json.harray({
    id = row.id,
    compiled = row.compiled,
    identity = "callable-codeblock/emitted-" .. row.id .. ".spec",
    input = "x",
    outcome = "error",
    expected_detail = expected_runtime_details[row.id],
  })
end

local emitted_observation, emitted_root = with_temp_directory(function(root)
  local manifest = json.array()
  for _, case in ipairs(emitted_cases) do
    local source = linkedspec.emit_lua_source_v2(case.compiled, case.identity)
    check(source:find("codeblock_literal", 1, true) == nil,
      case.id .. " emitted state is not a host-language record")
    check(source:find("{|", 1, true) == nil,
      case.id .. " emitted state is not a host-language closure body")
    local module_path = root .. "/" .. case.id .. ".lua"
    write_file(module_path, source)
    check_equal(read_file(module_path), source, case.id .. " exact emitted bytes")
    manifest[#manifest + 1] = json.harray({
      id = case.id,
      path = module_path,
      input = case.input,
      outcome = case.outcome,
    })
  end

  local corrupt_source = linkedspec.emit_lua_source_v2(
    fixture_compiled,
    "callable-codeblock/emitted-corrupt.spec"
  )
  local replacements
  corrupt_source, replacements = corrupt_source:gsub(
    'local _EFFECTIVE_SPEC_JSON_HEX = "[0-9a-f]+"',
    'local _EFFECTIVE_SPEC_JSON_HEX = "00"',
    1
  )
  check_equal(replacements, 1, "corrupt emitted payload replacement")
  local corrupt_path = root .. "/corrupt_payload.lua"
  write_file(corrupt_path, corrupt_source)
  manifest[#manifest + 1] = json.harray({
    id = "corrupt_payload",
    path = corrupt_path,
    input = "x",
    outcome = "load_error",
  })

  local manifest_path = root .. "/manifest.json"
  local runner_path = root .. "/runner.lua"
  local stdout_path = root .. "/stdout.json"
  local stderr_path = root .. "/stderr.txt"
  write_file(manifest_path, json.encode(manifest))
  write_file(runner_path, [[
local linkedspec = require("linkedspec")
local json = linkedspec.json

local manifest_file = assert(io.open(assert(arg[1]), "rb"))
local manifest = json.decode(assert(manifest_file:read("*a")))
assert(manifest_file:close())
local result = json.harray({
  values = json.harray(),
  errors = json.harray(),
  metadata = json.harray(),
})
for _, row in ipairs(manifest) do
  local loaded, module_or_error = pcall(function()
    local chunk, failure = loadfile(row.path)
    if chunk == nil then error(failure, 0) end
    return chunk()
  end)
  if row.outcome == "load_error" then
    assert(not loaded, row.id .. " unexpectedly loaded")
    result.errors[row.id] = linkedspec.is_generated_source_error(module_or_error) and
      linkedspec.generated_source_error_to_json(module_or_error) or
      json.harray({ detail = tostring(module_or_error) })
  else
    assert(loaded, module_or_error)
    local generated = module_or_error
    local executed, value_or_error = pcall(generated.execute, row.input)
    if row.outcome == "value" then
      assert(executed, value_or_error)
      result.values[row.id] = value_or_error
      result.metadata[row.id] = linkedspec.generated_source_metadata_to_json(generated.metadata())
    else
      assert(not executed, row.id .. " unexpectedly executed")
      result.errors[row.id] = linkedspec.is_generated_source_error(value_or_error) and
        linkedspec.generated_source_error_to_json(value_or_error) or
        json.harray({ detail = tostring(value_or_error) })
    end
  end
end
io.write(json.encode(result), "\n")
]])

  local runtime = os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME") or
    (type(jit) == "table" and "luajit" or "lua")
  local command = table.concat({
    "env",
    shell_quote("LUA_PATH=" .. (os.getenv("LUA_PATH") or package.path)),
    shell_quote("LUA_CPATH=" .. (os.getenv("LUA_CPATH") or package.cpath)),
    shell_quote(runtime),
    shell_quote(runner_path),
    shell_quote(manifest_path),
    ">" .. shell_quote(stdout_path),
    "2>" .. shell_quote(stderr_path),
  }, " ")
  check_equal(command_succeeded(command), true, "fresh emitted callable host status")
  check_equal(read_file(stderr_path), "", "fresh emitted callable host stderr")
  return json.decode(read_file(stdout_path))
end)
check_equal(command_succeeded("test ! -e " .. shell_quote(emitted_root)), true,
  "fresh emitted callable workspace cleanup")
check_same_json(emitted_observation.values.fixture, contract.fixture.expected,
  "fresh emitted neutral fixture")
check_same_json(emitted_observation.values.contextual, contextual_expected,
  "fresh emitted contextual equivalence")
check_same_json(emitted_observation.values.invocation, invocation_expected,
  "fresh emitted dynamic invocation equivalence")
check_equal(emitted_observation.metadata.fixture.contract_id,
  "linkedspec-generated-source-v2", "fresh emitted fixture contract")
check_equal(emitted_observation.metadata.fixture.source_identity,
  "callable-codeblock/emitted-fixture.spec", "fresh emitted fixture identity")
for _, case in ipairs(emitted_cases) do
  if case.outcome == "error" then
    local emitted_error = emitted_observation.errors[case.id] or {}
    check_equal(emitted_error.code, "generated_execution_failed",
      case.id .. " fresh emitted wrapper code")
    check_equal(emitted_error.source_identity, case.identity,
      case.id .. " fresh emitted error identity")
    check_equal(emitted_error.detail, case.expected_detail,
      case.id .. " fresh emitted runtime detail identity")
  end
end
check_equal(emitted_observation.errors.corrupt_payload.code,
  "generated_source_compile_failed", "fresh emitted corrupt payload rejection")

local failed_cleanup_root
local cleanup_ok, cleanup_error = capture(function()
  with_temp_directory(function(root)
    failed_cleanup_root = root
    write_file(root .. "/owned.lua", "return true\n")
    error("intentional callable emitted cleanup probe", 0)
  end)
end)
check_equal(cleanup_ok, false, "emitted cleanup failure path propagates")
check(tostring(cleanup_error):find("intentional callable emitted cleanup probe", 1, true) ~= nil,
  "emitted cleanup failure identity")
check_equal(command_succeeded("test ! -e " .. shell_quote(failed_cleanup_root)), true,
  "emitted workspace cleans after injected failure")

-- Static semantic bindings expose the exact callable signature.
local semantic_source = [[fn identity(value) { return(value) }

Top::
 /x/ -> Done {
   cb = {|left, ...items| return(items) };
   return(cb)
 }

Done::
 /x/
]]
local index = linkedspec.semantic_index(semantic_source, {
  logical_name = "callable-codeblock-semantic.spec",
  source_detail_ceiling = "none",
})
local projection = semantic_index_module._static_projection_for_testing(index)
local binding
for _, record in ipairs(projection.records) do
  if record.kind == "binding" and record.name == "cb" then binding = record end
end
check(binding ~= nil, "semantic codeblock binding exists")
if binding ~= nil then
  local shape = binding.facts.value_shape
  check_equal(shape.kind, "codeblock", "semantic binding kind")
  check_same_json(shape.signature, json.harray({
    parameters = json.array({
      json.harray({ name = "left", kind = "value", required = true }),
    }),
    arity_min = 1,
    arity_max = json.null,
    rest_parameter = "items",
    final_codeblock = false,
  }), "semantic callable signature")
end

if #failures > 0 then
  error(table.concat(failures, "\n"), 0)
end

io.stdout:write(string.format(
  "[lua-callable-codeblock] PASS: %d assertions on %s\n",
  assertions,
  linkedspec.runtime_implementation()
))
