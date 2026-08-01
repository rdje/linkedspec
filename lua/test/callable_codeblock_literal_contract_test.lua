-- FUTURE-PARITY-BACKLOG.11.8.1 -- inert callable-codeblock construction.

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

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
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

local function execute_native(compiled)
  return portable_runtime_value(
    linkedspec.runtime_execute(linkedspec.runtime_engine(compiled), "xx").value
  )
end

local function decode_hex(value)
  local bytes = {}
  for index = 1, #value, 2 do
    bytes[#bytes + 1] = string.char(tonumber(value:sub(index, index + 1), 16))
  end
  return table.concat(bytes)
end

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
  "unknown_helper", "bound invocation remains future work")

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
