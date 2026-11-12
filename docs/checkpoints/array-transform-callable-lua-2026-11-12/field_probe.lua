assert(#arg == 2, "owned source cases and output required")
assert(arg[2]:match("^docs/checkpoints/array%-transform%-callable%-lua%-2026%-11%-12/fieldprobe/[a-z]+$"))
local l = require("linkedspec")
local json = l.json
local file = assert(io.open("specs/user_function_definition.spec", "rb"))
local grammar = file:read("*a"); file:close()
local parser = l.user_function_definition_ast_parser_from_spec_source(grammar)
file = assert(io.open(arg[1], "rb"))
local cases = json.decode(file:read("*a")); file:close()
io.stdout:write("LUA_FIELD_OWNER ", debug.getinfo(l.runtime_execute, "S").source, "\n")
for _, row in ipairs(cases) do
  local parsed = l.parse_spec_with_staged_user_function_definitions(row.source, parser)
  local serialized = json.encode(l.spec_ast.to_json(parsed))
  local path = arg[2] .. "/" .. row.id .. ".parsed.json"
  file = assert(io.open(path, "wb")); file:write(serialized); file:close()
  file = assert(io.open(path, "rb")); assert(file:read("*a") == serialized); file:close()
  local compiled = l.compile_spec(parsed)
  local ok, failure = pcall(function() return l.runtime_execute(l.runtime_engine(compiled), row.input).value end)
  assert(not ok and l.is_runtime_interpreter_error(failure))
  local names, outer = json.array({}), json.harray({})
  for name, value in pairs(failure) do
    names[#names + 1] = name
    if name == "diagnostic" then outer[name] = l.interpreter.to_json(value)
    else
      assert(type(value) == "string" or type(value) == "number" or type(value) == "boolean")
      outer[name] = value
    end
  end
  table.sort(names)
  local public = l.interpreter.to_json(failure)
  local result = json.harray({outer_field_names=names, outer_values=outer, published_json=public})
  if failure.code == "binding_kind_mismatch" then
    assert(failure.identifier == "items" and failure.expected_kind == "array" and failure.actual_kind == "scalar")
    assert(public.identifier == nil and public.expected_kind == nil and public.actual_kind == nil)
    local previous = failure.expected_kind
    failure.expected_kind = "different"
    result.outer_change_is_not_serialized = json.encode(l.interpreter.to_json(failure)) == json.encode(public)
    failure.expected_kind = previous
    assert(result.outer_change_is_not_serialized)
    previous = failure.message
    failure.message = "distinguishing message"
    result.message_change_is_serialized = json.encode(l.interpreter.to_json(failure)) ~= json.encode(public)
    failure.message = previous
    assert(result.message_change_is_serialized)
  else
    assert(failure.code == "user_function_arity_mismatch")
    result.arity_fields_absent = failure.actual_arity == nil and failure.expected_arity == nil and failure.expected == nil and failure.got == nil
    assert(result.arity_fields_absent)
  end
  io.stdout:write("LUA_FIELD_PROBE ", row.id, " ", json.encode(result), "\n")
end
