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

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function parse_source(source)
  return linkedspec.parse_spec_with_staged_user_function_definitions(source)
end

local function compile_source(source)
  return linkedspec.compile_spec(parse_source(source))
end

local function lifecycle(source)
  for _, element in ipairs(parse_source(source).rules[1].body) do
    if linkedspec.spec_ast.node_type(element.kind) == "CodeBlockBodyElementKind" then
      return element
    end
  end
  error("missing lifecycle element", 0)
end

local function all_kinds(source)
  local result = {}
  for _, rule in ipairs(parse_source(source).rules) do
    for _, element in ipairs(rule.body) do
      result[#result + 1] = linkedspec.spec_ast.to_json(element.kind).kind
    end
  end
  return result
end

local function contains(values, expected)
  for _, value in ipairs(values) do
    if value == expected then return true end
  end
  return false
end

local function execute(compiled, input)
  return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), input).value
end

local function load_generated_module(source, chunk_name)
  local loader = loadstring or load
  local chunk, load_error = loader(source, chunk_name)
  if not chunk then error(load_error, 0) end
  return chunk()
end

local contract = json.decode(read_file(
  "capability_conformance/standalone_lifecycle_block_contract.json"
))

for _, row in ipairs(contract.placement_twins) do
  local explicit = lifecycle(row.explicit)
  local shorthand = lifecycle(row.shorthand)
  check_same_json(
    linkedspec.spec_ast.to_json(explicit.kind),
    linkedspec.spec_ast.to_json(shorthand.kind),
    row.id .. " semantic kind"
  )
  check_equal(explicit.kind.lifecycle, "I", row.id .. " lifecycle")
  check_equal(explicit.kind.code, row.interior:match("^%s*(.-)%s*$"), row.id .. " explicit code")
  check_equal(shorthand.kind.code, row.interior:match("^%s*(.-)%s*$"), row.id .. " shorthand code")
  check_equal(explicit.line, row.opening_line, row.id .. " explicit line")
  check_equal(shorthand.line, row.opening_line, row.id .. " shorthand line")
  check(not contains(all_kinds(row.shorthand), "plain_block"), row.id .. " emits no plain block")
end

do
  local row = contract.provenance_twin
  local explicit = lifecycle(row.explicit)
  local shorthand = lifecycle(row.shorthand)
  check_equal(explicit.source, row.explicit_block_source, "explicit source")
  check_equal(shorthand.source, row.shorthand_block_source, "shorthand source")
  check_equal(explicit.line, row.opening_line, "explicit provenance line")
  check_equal(shorthand.line, row.opening_line, "shorthand provenance line")
  check_same_json(
    linkedspec.spec_ast.to_json(explicit.kind),
    linkedspec.spec_ast.to_json(shorthand.kind),
    "provenance semantic kind"
  )

  local explicit_payload = compile_source(row.explicit):rule("Top").lifecycle_action_payloads[1]
  local shorthand_payload = compile_source(row.shorthand):rule("Top").lifecycle_action_payloads[1]
  local explicit_semantic = linkedspec.compiled_spec.to_json(explicit_payload)
  local shorthand_semantic = linkedspec.compiled_spec.to_json(shorthand_payload)
  explicit_semantic.source = nil
  shorthand_semantic.source = nil
  check_same_json(explicit_semantic, shorthand_semantic, "provenance ActionIR equivalence")
end

for _, row in ipairs(contract.duplicate_cases) do
  local parsed = parse_source(row.source)
  local compiled = linkedspec.compile_spec(parsed)
  check_equal(
    execute(compiled, contract.duplicate_input),
    contract.duplicate_expected,
    row.id .. " native authored order"
  )
  local reconstructed = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  check_equal(
    execute(linkedspec.compile_spec(reconstructed), contract.duplicate_input),
    contract.duplicate_expected,
    row.id .. " reconstructed authored order"
  )
  local identity = "standalone-lifecycle/lua-" .. row.id .. ".spec"
  check_equal(
    linkedspec.execute_generated_parser_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      contract.duplicate_input,
      identity
    ),
    contract.duplicate_expected,
    row.id .. " generated plan authored order"
  )
  local generated = load_generated_module(
    linkedspec.emit_lua_source_v2(compiled, identity),
    "@standalone-lifecycle-" .. row.id
  )
  check_equal(
    generated.execute(contract.duplicate_input),
    contract.duplicate_expected,
    row.id .. " emitted source authored order"
  )
end

for _, row in ipairs(contract.ownership_cases) do
  check(contains(all_kinds(row.source), row.expected_kind), row.id .. " brace ownership")
end

for _, row in ipairs(contract.malformed_twins) do
  local explicit_ok, explicit_error = pcall(compile_source, row.explicit)
  local shorthand_ok, shorthand_error = pcall(compile_source, row.shorthand)
  check_equal(explicit_ok, false, row.id .. " explicit rejects")
  check_equal(shorthand_ok, false, row.id .. " shorthand rejects")
  check(type(explicit_error) == type(shorthand_error), row.id .. " failure boundary type")
  check(#tostring(explicit_error) > 0, row.id .. " explicit diagnostic")
  check(#tostring(shorthand_error) > 0, row.id .. " shorthand diagnostic")
end

do
  local normalized = parse_source([[Top::
 { return("must-not-run") }
]])
  local top = normalized.rules[1]
  local legacy = linkedspec.spec_ast.spec_file({
    source_id = "legacy-plain.spec",
    rules = {
      linkedspec.spec_ast.rule({
        header = top.header,
        body = {
          linkedspec.spec_ast.body_element({
            kind = linkedspec.spec_ast.plain_block_body_kind({
              code = ' return("must-not-run") ',
            }),
            source = '{ return("must-not-run") }',
            line = 2,
          }),
        },
      }),
    },
  })
  local reconstructed = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(legacy)))
  )
  local compiled = linkedspec.compile_spec(reconstructed, { validate_source = false })
  check_equal(#compiled:rule("Top").plain_action_payloads, 1, "legacy plain payload remains readable")
  check_equal(execute(compiled, ""), json.null, "legacy plain payload remains inert")
  check_equal(
    linkedspec.execute_generated_parser_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      "",
      "standalone-lifecycle/lua-legacy-plain.spec"
    ),
    json.null,
    "legacy plain generated plan remains inert"
  )
end

if #failures == 0 then
  io.stdout:write(
    "standalone lifecycle block ",
    linkedspec.runtime_implementation(),
    " admission: ",
    assertions,
    " assertions passed\n"
  )
else
  io.stderr:write(
    "standalone lifecycle block admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
