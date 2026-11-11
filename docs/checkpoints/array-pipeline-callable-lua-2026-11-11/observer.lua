assert(#arg == 2, "cases and owned output paths required")
assert(arg[1]:match("^docs/checkpoints/array%-pipeline%-callable%-lua%-2026%-11%-11/[a-z]+/cases%.json$"), "owned cases path required")
assert(arg[2]:match("^docs/checkpoints/array%-pipeline%-callable%-lua%-2026%-11%-11/[a-z]+/[a-z]+$"), "owned output path required")
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local observation = dofile("lua/test/callable_array_pipeline_observation.lua")
io.stdout:setvbuf("no")
io.stdout:write("CALLABLE_PIPELINE_LUA_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\n")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local grammar_file = assert(io.open("specs/user_function_definition.spec", "rb"))
local grammar = grammar_file:read("*a"); grammar_file:close()
io.stdout:write("CALLABLE_PIPELINE_LUA_GRAMMAR ", json.encode(json.harray({path="specs/user_function_definition.spec",source=grammar})), "\n")
local function_parser = l.user_function_definition_ast_parser_from_spec_source(grammar)

local function persist(directory, identifier, extension, body)
  local path = arg[2] .. "/" .. directory .. "/" .. identifier .. extension
  local file = assert(io.open(path, "wb"))
  file:write(body); file:close()
  file = assert(io.open(path, "rb"))
  local retained = file:read("*a"); file:close()
  assert(retained == body, "actual artifact readback drift")
  return retained
end

local function observe(identifier, source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source, function_parser)
    local retained = persist("parsed", identifier, ".json", json.encode(l.spec_ast.to_json(parsed)))
    io.stdout:write("CALLABLE_PIPELINE_LUA_INPUT ", identifier, " ", retained, "\n")
    local restored_spec = l.spec_ast.from_json("SpecFile", json.decode(retained))
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(restored_spec)
    local identity = "callable-array-pipeline/" .. identifier .. ".spec"
    local emitted = persist("emitted", identifier, ".lua", l.emit_lua_source_v2(compiled, identity))
    local parser = assert((loadstring or load)(emitted))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, identity) end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({preparation_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do result[route[1]] = observation.observe(l, route[2]) end
  return result
end

local file = assert(io.open(arg[1], "rb"))
local cases = json.decode(file:read("*a")); file:close()
for _, row in ipairs(cases) do
  assert(row.id:match("^[a-z][a-z0-9_]*$"))
  local actual = observe(row.id, row.source, row.input)
  io.stdout:write("CALLABLE_PIPELINE_LUA ", row.id, " ", json.encode(actual), "\n")
end
