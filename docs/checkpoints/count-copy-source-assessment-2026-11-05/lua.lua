local l = require("linkedspec")
local json = l.json
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end
local function observe(source, input, label)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local emitted = l.emit_lua_source_v2(compiled, "count-copy-source-assessment.spec")
    local file=assert(io.open(assert(arg[1]) .. "/" .. label .. ".lua","wb"))
    file:write(emitted);file:close()
    if true then
      io.stdout:write("COUNT_COPY_LUA_INPUT ", json.encode(json.harray({source=source,parsed=l.spec_ast.to_json(parsed),emitted=emitted})), "\n")
    end
    local parser = assert((loadstring or load)(emitted))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "count-copy-source-assessment.spec") end},
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
local file=assert(io.open("docs/checkpoints/count-copy-source-assessment-2026-11-05/cases.json","r"))
local cases=json.decode(file:read("*a"));file:close()
for _,row in ipairs(cases) do
  local actual=observe(row.source,row.input,row.id)
  io.stdout:write("COUNT_COPY_LUA ",row.id," ",json.encode(actual),"\n")
end
