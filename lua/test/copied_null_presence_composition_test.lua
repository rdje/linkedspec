-- TYPE-REFERENCE-BOOK.1.2.23.3.69.6.5 — copied-null presence composition.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "copied-null-presence-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "copied-null-presence-composition.spec") end},
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
local function check_value(label, source, input, expected_json)
  local actual = observe(source, input)
  local expected = json.encode(json.decode(expected_json))
  io.stdout:write("COPIED_NULL_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
do
  local file=assert(io.open("tests/fixtures/copied_null_presence_cases.json","r"))
  local cases=json.decode(file:read("*a"));file:close()
  for _,row in ipairs(cases) do
    if row.expected_error then
      local actual=observe(row.source,row.input)
      io.stdout:write("COPIED_NULL_ERROR ",row.id," ",json.encode(actual),"\n")
      verify(actual.compile_error==nil,row.id .. " compiles")
      for _,route in ipairs({"native","restored","plan","fresh"}) do
        local value=actual[route]
        verify(value~=nil and value.error~=nil and value.error:find(row.expected_error,1,true)~=nil,row.id .. " " .. route .. " needed key error")
      end
    else
      check_value(row.id,row.source,row.input,json.encode(row.expected))
    end
  end
end
check_value("rejected_copy_without_with",[==[Top:: I {order="";out=has_key({},"k").take({order=cat(order,"A");1}).copy().has_key({order=cat(order,"K");"k"});return([out,order])}]==],"x",'[null,""]')
io.stdout:write("COPIED_NULL_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("copied-null presence checks passed: ",checks,"\n")
