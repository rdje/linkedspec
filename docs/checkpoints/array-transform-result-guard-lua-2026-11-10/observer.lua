assert(#arg == 2, "cases and owned output paths required")
assert(arg[1]:match("^docs/checkpoints/array%-transform%-result%-guard%-lua%-2026%-11%-10/[a-z]+/cases%.json$"), "owned cases path required")
assert(arg[2]:match("^docs/checkpoints/array%-transform%-result%-guard%-lua%-2026%-11%-10/[a-z]+/[a-z]+$"), "owned output path required")
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
io.stdout:write("ARRAY_TRANSFORM_LUA_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\n")
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local grammar_file = assert(io.open("specs/user_function_definition.spec", "rb"))
local grammar = grammar_file:read("*a"); grammar_file:close()
io.stdout:write("ARRAY_TRANSFORM_LUA_GRAMMAR ", json.encode(json.harray({path="specs/user_function_definition.spec",source=grammar})), "\n")
local function_parser = l.user_function_definition_ast_parser_from_spec_source(grammar)

local function observe(identifier, source, input, output)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source, function_parser)
    local compiled = l.compile_spec(parsed)
    if identifier == "take_later_with" or identifier == "reverse_copy_later_with" or identifier == "sort_logical_later_with" then
      for _, payload in ipairs(l.compiled_spec.action_payloads(compiled.rules_by_label.Value)) do
        io.stdout:write("ARRAY_TRANSFORM_LUA_COMPILED_ACTION ", identifier, " ", json.encode(l.action_ast.to_json(payload.action_ast)), "\n")
      end
    end
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local emitted = l.emit_lua_source_v2(compiled, "array-transform-result-guard/" .. identifier .. ".spec")
    local function persist(directory, extension, body)
      local file = assert(io.open(output .. "/" .. directory .. "/" .. identifier .. extension, "wb"))
      file:write(body); file:close()
    end
    persist("emitted", ".lua", emitted)
    persist("parsed", ".json", json.encode(l.spec_ast.to_json(parsed)))
    io.stdout:write("ARRAY_TRANSFORM_LUA_INPUT ", identifier, " ", json.encode(l.spec_ast.to_json(parsed)), "\n")
    local parser = assert((loadstring or load)(emitted))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "array-transform-result-guard/" .. identifier .. ".spec") end},
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
  io.stdout:write("ARRAY_TRANSFORM_LUA ", row.id, " ", json.encode(actual), "\n")
end
