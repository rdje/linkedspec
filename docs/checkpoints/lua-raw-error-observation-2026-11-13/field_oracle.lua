-- The same raw-field-change oracle must reject the legacy projection.
assert(#arg == 2 and (arg[1] == "legacy" or arg[1] == "raw"))
local mode, output = arg[1], arg[2]
assert(output:match("^docs/checkpoints/lua%-raw%-error%-observation%-2026%-11%-13/oracles/[a-z]+/[a-z]+$"))
local l = require("linkedspec")
local json = l.json
local full = dofile("lua/test/raw_error_observation.lua")
local previous = dofile("lua/test/callable_array_transform_observation.lua")
local function read(path)
  local file = assert(io.open(path, "rb"))
  local body = file:read("*a"); file:close()
  return body
end
local parser = l.user_function_definition_ast_parser_from_spec_source(read("specs/user_function_definition.spec"))
local wanted = {own_needed_source_take_receiver=true, own_signature_fixed_missing_composed=true}
io.stdout:setvbuf("no")
for _, row in ipairs(json.decode(read("tests/fixtures/lua_raw_error_observation_cases.json"))) do
  if wanted[row.id] then
    local parsed = l.parse_spec_with_staged_user_function_definitions(row.source, parser)
    local body = json.encode(l.spec_ast.to_json(parsed))
    local path = output .. "/" .. row.id .. ".parsed.json"
    local file = assert(io.open(path, "wb")); file:write(body); file:close()
    assert(read(path) == body)
    local compiled = l.compile_spec(parsed)
    local ok, failure = pcall(l.runtime_execute, l.runtime_engine(compiled), row.input)
    assert(not ok and l.is_runtime_interpreter_error(failure))
    local function observe()
      if mode == "raw" then return json.encode(full.snapshot(l, failure)) end
      return json.encode(previous.observe(l, function() error(failure, 0) end))
    end
    local before = observe()
    local field = failure.code == "binding_kind_mismatch" and "expected_kind" or "rule_label"
    local original = assert(failure[field])
    failure[field] = original .. "__distinguishing_field"
    local different = observe() ~= before
    failure[field] = original
    io.stdout:write("RAW_FIELD_ORACLE ", mode, " ", row.id, " ", field, " ", tostring(different), "\n")
    assert(different, "raw-field oracle: projection misses " .. field)
  end
end
