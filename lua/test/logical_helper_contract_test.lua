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

local contract = json.decode(read_file("capability_conformance/logical_helper_contract.json"))

local function contract_row(rows, id)
  for _, row in ipairs(rows) do
    if row.id == id then return row end
  end
  error("logical-helper contract row is missing: " .. id, 0)
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function reconstruct_source(source)
  local parsed = linkedspec.parse_spec(source)
  local serialized = json.encode(linkedspec.spec_ast.to_json(parsed))
  return linkedspec.compile_spec(
    linkedspec.spec_ast.from_json("SpecFile", json.decode(serialized))
  )
end

local function execute_native(compiled)
  return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "x").value
end

local function generated_module(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local function generated_identity(id, role)
  return "logical-helper/" .. id .. "-" .. role .. ".spec"
end

local function execute_generated(compiled, id)
  return linkedspec.execute_generated_parser_v1(
    compiled,
    linkedspec.build_generated_rule_plan(compiled),
    "x",
    generated_identity(id, "generated")
  )
end

local function emitted_module(compiled, id)
  return generated_module(
    linkedspec.emit_lua_source_v1(compiled, generated_identity(id, "emitted")),
    "@logical-helper-" .. id .. "-emitted"
  )
end

local function primary(source)
  return linkedspec.run_primary_cli({ "--inline-spec", source, "--input", "x" })
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function check_runtime_arity_failure(ok, failure, row, label)
  check_equal(ok, false, label .. " rejected")
  local typed = not ok and linkedspec.is_runtime_interpreter_error(failure)
  check_equal(typed, true, label .. " typed runtime failure")
  local fields = typed and failure or {}
  check_equal(fields.code, row.expected_code, label .. " code")
  check_equal(fields.helper_name, row.helper_name, label .. " helper name")
  check_equal(fields.actual_arity, row.actual_arity, label .. " actual arity")
  check_equal(fields.expected_arity, row.expected_arity, label .. " expected arity")
  check_contains(fields.message or "", "helper_arity_mismatch", label .. " code token")
  check_contains(fields.message or "", "helper_name=" .. row.helper_name, label .. " helper token")
  check_contains(fields.message or "", "actual_arity=" .. row.actual_arity, label .. " actual token")
  check_equal((fields.message or ""):find("must not run", 1, true), nil, label .. " no operand effect")

  local diagnostic = typed and fields.diagnostic or nil
  check_equal(linkedspec.is_runtime_diagnostic(diagnostic), true, label .. " diagnostic type")
  local diagnostic_json = diagnostic and linkedspec.interpreter.to_json(diagnostic) or {}
  check_equal(diagnostic_json.stage, "helper_arity_mismatch", label .. " diagnostic stage")
  check_equal(diagnostic_json.code, row.expected_code, label .. " diagnostic code")
  check_equal(diagnostic_json.helper_name, row.helper_name, label .. " diagnostic helper")
  check_equal(diagnostic_json.actual_arity, row.actual_arity, label .. " diagnostic actual")
  check_equal(diagnostic_json.expected_arity, row.expected_arity, label .. " diagnostic expected")
  check_equal(diagnostic_json.rule_label, "Top", label .. " diagnostic rule")
end

local function check_generated_arity_failure(ok, failure, row, label)
  check_equal(ok, false, label .. " rejected")
  local typed = not ok and linkedspec.is_generated_source_error(failure)
  check_equal(typed, true, label .. " typed generated failure")
  local fields = typed and failure or {}
  check_equal(
    fields.stage and linkedspec.generated_source_stage_name(fields.stage),
    "execute_generated",
    label .. " stage"
  )
  check_equal(
    fields.code and linkedspec.generated_source_code_name(fields.code),
    "generated_execution_failed",
    label .. " code"
  )
  local detail = fields.detail or ""
  check_contains(detail, "helper_arity_mismatch", label .. " detail code")
  check_contains(detail, "helper_name=" .. row.helper_name, label .. " detail helper")
  check_contains(detail, "actual_arity=" .. row.actual_arity, label .. " detail actual")
  check_equal(detail:find("must not run", 1, true), nil, label .. " no operand effect")
end

check_equal(contract.format, 1, "contract format")
check_equal(contract.contract_id, "linkedspec-logical-helper-v1", "contract id")
check_equal(#contract.truthiness_cases, 17, "truthiness case count")
check_equal(#contract.helper_cases, 10, "helper case count")

do
  local codeblock_source = table.concat({
    "fn truth(callback: codeblock) { return(and(callback)) }",
    "Top::",
    " /x/",
    ' E { return(truth({ fail("codeblock must not run") })) }',
    "",
  }, "\n")
  local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(codeblock_source)
  local result = execute_native(linkedspec.compile_spec(parsed))
  check_equal(result, true, "inert codeblock is truthful without invocation")
end

for _, fixture_id in ipairs({ "values", "effects", "receiver_and_lazy_control" }) do
  local fixture = contract.fixtures[fixture_id]
  local compiled = compile_source(fixture.spec_source)
  check_same_json(execute_native(compiled), fixture.expected, fixture_id .. " native")
  check_same_json(
    execute_native(reconstruct_source(fixture.spec_source)),
    fixture.expected,
    fixture_id .. " reconstructed"
  )
  check_same_json(execute_generated(compiled, fixture_id), fixture.expected, fixture_id .. " generated")
  check_same_json(emitted_module(compiled, fixture_id).execute("x"), fixture.expected, fixture_id .. " emitted")

  local primary_result = primary(fixture.spec_source)
  check_equal(primary_result.exit_code, 0, fixture_id .. " primary exit")
  check_equal(primary_result.stderr, "", fixture_id .. " primary stderr")
  check_same_json(json.decode(primary_result.stdout), fixture.expected, fixture_id .. " primary value")
end

for _, fixture in ipairs(contract.fixtures.invalid_arity) do
  local row = contract_row(contract.invalid_arity_cases, fixture.id)
  local compiled = compile_source(fixture.spec_source)
  local native_ok, native_failure = capture(function() return execute_native(compiled) end)
  check_runtime_arity_failure(native_ok, native_failure, row, fixture.id .. " native")

  local reconstructed = reconstruct_source(fixture.spec_source)
  local reconstructed_ok, reconstructed_failure = capture(function()
    return execute_native(reconstructed)
  end)
  check_runtime_arity_failure(
    reconstructed_ok,
    reconstructed_failure,
    row,
    fixture.id .. " reconstructed"
  )

  local generated_ok, generated_failure = capture(function()
    return execute_generated(compiled, fixture.id)
  end)
  check_generated_arity_failure(generated_ok, generated_failure, row, fixture.id .. " generated")

  local emitted = emitted_module(compiled, fixture.id)
  local emitted_ok, emitted_failure = capture(function() return emitted.execute("x") end)
  check_generated_arity_failure(emitted_ok, emitted_failure, row, fixture.id .. " emitted")

  local primary_result = primary(fixture.spec_source)
  check_equal(primary_result.exit_code, 1, fixture.id .. " primary exit")
  check_equal(primary_result.stdout, "", fixture.id .. " primary stdout")
  check_equal(primary_result.stderr, "linkedspec: parser invocation failed\n", fixture.id .. " primary stderr")
end

if #failures == 0 then
  io.stdout:write("logical helper contract: ", assertions, " assertions passed\n")
else
  io.stderr:write("logical helper contract: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
