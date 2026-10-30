-- TYPE-REFERENCE-BOOK.1.2.23.3.54.5 — static child-return typed reads.
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
local function fixture(extension)
  local file = assert(io.open("tests/fixtures/rule_call_selection_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "rule-call-selection.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "rule-call-selection.spec") end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value),runtime=l.is_runtime_interpreter_error(value),generated=l.is_generated_source_error(value),helper_name=type(value)=="table" and value.helper_name or nil})
  end
  return result
end
local function check_value(label, source, input, expected_json)
  local actual = observe(source, input)
  local expected = json.encode(json.decode(expected_json))
  io.stdout:write("RULE_CALL_SELECTION ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "x")
  io.stdout:write("RULE_CALL_SELECTION_FENCE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " remains runtime diagnosed")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    local native = route == "native" or route == "restored"
    verify(row ~= nil and row.error ~= nil, label .. " " .. route .. " rejects")
    verify(row ~= nil and row.runtime == native and row.generated == (not native), label .. " " .. route .. " typed envelope")
    local message = row and row.error
    local specific = message ~= nil and
      message:find("parser-state helper", 1, true) ~= nil and
      message:find("'" .. helper .. "'", 1, true) ~= nil and
      message:find("not supported in user functions", 1, true) ~= nil
    verify(specific and (not native or row.helper_name == helper),
      label .. " " .. route .. " authored helper diagnostic")
  end
end
check_value("shared", fixture("spec"), "αβ:ENDTAIL", fixture("json"))
check_value("selected_kinds",[=[
Top:: I {return([call(Child)[0],call(Child)[1],call(Child)[2],call(Child)[3],call(Child)[4],call(Child)[5]])}
Child: I {return([false,0,"0",undef,["a"],hash("name","b")])}
]=],"x",[=[[false,0,"0",null,["a"],{"name":"b"}]]=])
check_value("scalar_null_empty_missing",[=[
Top:: I {return([call(Text)[-1].coalesce("M"),call(Nothing)[0].coalesce("N"),call(Empty)[-1].coalesce("E"),call(Object)["missing"].coalesce("K")])}
Text: I {return("red:tail")}
Nothing: I {return(undef)}
Empty: I {return([])}
Object: I {return(hash())}
]=],"x",[=[["M","N","E","K"]]=])
check_value("bound_method_controls",[=[
Top:: I {part=call(Child);return([part[-1].uppercase(),call(Child).last().uppercase()])}
Child: I {return(["red","tail"])}
]=],"x",[=[["TAIL","TAIL"]]=])
check_value("static_label_signed_read",[=[
Top:: I {Child="Wrong";return(call(Child)[-1].uppercase())}
Child: I {return(["red","tail"])}
Wrong: I {return(["wrong"])}
]=],"x",[=["TAIL"]=])
function_fence("pure_function",[=[
fn forbidden(){return(call(Child)[-1].uppercase())}
Top:: I {return(forbidden())}
Child: I {return(["tail"])}
]=],"call")
check_value("explicit_value_argument",[=[
fn upper(text){return(text.uppercase())}
Top:: I {return(upper(call(Child)[-1]))}
Child: I {return(["red","tail"])}
]=],"x",[=["TAIL"]=])
io.stdout:write("RULE_CALL_SELECTION_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("static rule-call result checks passed: ", checks, "\n")
