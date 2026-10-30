-- TYPE-REFERENCE-BOOK.1.2.23.3.56.5 — current cursor rewind Number results.
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
  local file = assert(io.open("tests/fixtures/cursor_rewind_result_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "cursor-rewind-result.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "cursor-rewind-result.spec") end},
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
  io.stdout:write("CURSOR_REWIND ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "zzab:cd")
  io.stdout:write("CURSOR_REWIND_FENCE ", label, " ", json.encode(actual), "\n")
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


local function carrier(body,definitions)
  return (definitions or "") .. "\nTop::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {" .. body .. "}\n"
end
local primitive_body="save_cursor();p0=cursor_pos();v0=rewind_entry_start();p1=cursor_pos();v1=rewind_match_start();p2=cursor_pos();v2=restore_cursor();p3=cursor_pos();return([p0,v0,p1,v1,p2,v2,p3]);"
check_value("shared",fixture("spec"),"zzab:cd",fixture("json"))
check_value("primitive_ascii",carrier(primitive_body),"zzab:cd","[5,2,2,4,4,null,5]")
check_value("primitive_unicode",carrier(primitive_body),"🙂ab:cd","[4,1,1,3,3,null,4]")
check_value("numeric",carrier([=[entry_value=rewind_entry_start();p1=cursor_pos();local_value=rewind_match_start();p2=cursor_pos();return([entry_value.add(1).cat("!"),local_value.add(1),p1,p2,rewind_entry_start().add(1),rewind_match_start().add(1),cursor_pos()]);]=]),"zzab:cd",[=[["3!",5,2,4,3,5,4]]=])
check_value("zero_and_guards",carrier([=[order="";a=rewind_entry_start().coalesce({order=cat(order,"F");99}).add(1);b=rewind_entry_start().take({order=cat(order,"A");1});c=rewind_match_start().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");7});return([a,b,c,order,cursor_pos()]);]=]),"ab:cd",[=[[1,null,null,"",2]]=])
for _,helper in ipairs({"rewind_entry_start","rewind_match_start"}) do
  function_fence(helper,carrier("return(forbidden())","fn forbidden(){return(" .. helper .. "().coalesce(99).add(1))}"),helper)
end
check_value("explicit_number",carrier("return(inc(2))","fn inc(value){return(value.add(1))}"),"zzab:cd","3")
check_value("physical",carrier("saved=save_cursor();rewind_entry_start();p1=cursor_pos();rewind_match_start();p2=cursor_pos();restored=restore_cursor();return([saved,p1,p2,restored,cursor_pos()]);"),"zzab:cd","[null,2,4,null,5]")
check_value("bridges",carrier([=[return([rewind_entry_start().with(){return([value,"tail"])}[-1].uppercase(),rewind_match_start()[0].coalesce(["a","tail"])[-1].uppercase(),cursor_pos()]);]=]),"zzab:cd",[=[["TAIL","TAIL",4]]=])
check_value("absent","Top:: I {return([rewind_entry_start(),rewind_match_start(),cursor_pos(),restore_cursor(),cursor_pos()])}","x","[null,null,0,null,0]")

-- Existing strict arity is preservation, independently observed on both hosts.
for _,helper in ipairs({"save_cursor","restore_cursor","rewind_entry_start","rewind_match_start"}) do
  for _,form in ipairs({{"1",1},{"extra:1",1},{"1,2",2},{"trap()",1}}) do
    local actual=observe(carrier("save_cursor();return(" .. helper .. "(" .. form[1] .. "))","fn trap(){return(entry_text())}"),"zzab:cd")
    io.stdout:write("CURSOR_REWIND_ARITY ",helper," ",form[1]," ",json.encode(actual),"\n")
    verify(actual.compile_error==nil,helper .. " arity remains runtime")
    for _,route in ipairs({"native","restored","plan","fresh"}) do
      local row=actual[route]
      local native=route=="native" or route=="restored"
      verify(row~=nil and row.error~=nil and row.runtime==native and row.generated==(not native) and
        row.error:find("expects exactly 0 positional arguments, got " .. form[2],1,true)~=nil and
        row.error:find("helper '" .. helper .. "'",1,true)~=nil,
        helper .. " " .. form[1] .. " " .. route .. " typed arity")
      if native then
        verify(row~=nil and row.helper_name==helper and row.actual_arity==form[2] and
          row.expected_arity=="exactly 0 positional arguments" and row.code=="helper_arity_mismatch" and row.diagnostic_code==nil and
          row.diagnostic_stage=="runtime_execution",helper .. " " .. route .. " arity fields")
      end
    end
  end
end
io.stdout:write("CURSOR_REWIND_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("cursor rewind result checks passed: ",checks,"\n")
