assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function observe(identifier, source, input, output)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local emitted = l.emit_lua_source_v2(compiled, "key-count-source/" .. identifier .. ".spec")
    local function persist(directory, extension, body)
      local file = assert(io.open(output .. "/" .. directory .. "/" .. identifier .. extension, "wb"))
      file:write(body); file:close()
    end
    persist("emitted", ".lua", emitted)
    persist("parsed", ".json", json.encode(l.spec_ast.to_json(parsed)))
    io.stdout:write("KEY_COUNT_LUA_INPUT ", identifier, " ", json.encode(l.spec_ast.to_json(parsed)), "\n")
    local parser = assert((loadstring or load)(emitted))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "key-count-source/" .. identifier .. ".spec") end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value),runtime=l.is_runtime_interpreter_error(value),generated=l.is_generated_source_error(value),helper_name=type(value)=="table" and value.helper_name or nil,diagnostic_code=type(value)=="table" and value.diagnostic and value.diagnostic.code or nil,diagnostic_stage=type(value)=="table" and value.diagnostic and value.diagnostic.stage or nil,code=type(value)=="table" and value.code or nil,actual_arity=type(value)=="table" and value.actual_arity or nil,expected_arity=type(value)=="table" and value.expected_arity or nil})
  end
  return result
end
local file = assert(io.open(arg[1], "rb"))
local cases = json.decode(file:read("*a")); file:close()
for _, row in ipairs(cases) do
  assert(row.id:match("^[a-z][a-z0-9_]*$"))
  local actual = observe(row.id, row.source, row.input, arg[2])
  io.stdout:write("KEY_COUNT_LUA ", row.id, " ", json.encode(actual), "\n")
end
