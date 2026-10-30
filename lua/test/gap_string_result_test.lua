-- TYPE-REFERENCE-BOOK.1.2.23.3.57.5 — gap String actual-kind guards.
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
  local file = assert(io.open("tests/fixtures/gap_string_result_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "gap-string-result.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "gap-string-result.spec") end},
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
  io.stdout:write("GAP_STRING_RESULT ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "a,b;")
  io.stdout:write("GAP_STRING_RESULT_FENCE ", label, " ", json.encode(actual), "\n")
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



local function carrier(action,definitions,pattern)
  return (definitions or "") .. "\nList::\n @capture_gaps\n I {rows=[];order=\"\"}\n -> Item[word] {" .. action .. "}\n LX {return([rows,gap_text(),gap_kind(),order,cursor_pos()])}\nItem:\n word=/" .. (pattern or "[^,;]+") .. "/\n I {return(entry_text())}\n"
end
local function error_case(label,source,helper,code,stage,count)
  local actual=observe(source,"x")
  io.stdout:write("GAP_STRING_ERROR ",label," ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,label .. " compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    local native=route=="native" or route=="restored"
    verify(row~=nil and row.error~=nil and row.runtime==native and row.generated==(not native) and
      row.error:find(code,1,true)~=nil,label .. " " .. route .. " typed error")
    if native then
      verify(row~=nil and row.helper_name==helper and row.diagnostic_code==code and row.diagnostic_stage==stage and
        (count==nil or (row.actual_arity==count and row.expected_arity=="exactly 0 arguments")),
        label .. " " .. route .. " helper fields")
    end
  end
end
check_value("shared",fixture("spec"),"a,b;",fixture("json"))
check_value("primitive",carrier("push(rows,[gap_text(),gap_kind(),call(Item)])"),"a,b;",[=[[[["","prefix","a"],[",","interstitial","b"]],";","tail","",3]]=])
check_value("compatible",carrier([=[text=gap_text();kind=gap_kind();push(rows,[text.coalesce("F").cat("!"),gap_text().coalesce("F").cat("!"),kind.uppercase(),gap_kind().uppercase(),call(Item)])]=]),"a,b;",[=[[[["!","!","PREFIX","PREFIX","a"],[",!",",!","INTERSTITIAL","INTERSTITIAL","b"]],";","tail","",3]]=])
check_value("guards",carrier([=[a=gap_text().take({order=cat(order,"A");1});b=gap_kind().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});push(rows,[a,b,call(Item)])]=]),"a,b;",[=[[[[null,null,"a"],[null,null,"b"]],";","tail","",3]]=])
check_value("recovery",carrier([=[push(rows,[gap_text()[0].coalesce(["a","tail"])[-1].uppercase(),gap_kind()["missing"].coalesce(false),gap_kind()[0].coalesce(0).add(1),gap_text()[0].coalesce("").cat("!"),call(Item)])]=]),"a,b;",[=[[[["TAIL",false,1,"!","a"],["TAIL",false,1,"!","b"]],";","tail","",3]]=])
check_value("with_kinds",carrier([=[value="outer";a=gap_text().with(){return([value,"tail"])}[-1].uppercase();b=gap_kind().with(){return({"k":[false]})}["k"][-1];push(rows,[a,b,value,call(Item)])]=]),"a,b;",[=[[[["TAIL",false,"outer","a"],["TAIL",false,"outer","b"]],";","tail","",3]]=])
check_value("unicode",carrier([=[push(rows,[gap_text().length(),gap_text().cat("!"),call(Item)])]=],"","[ab]"),"a🙂b;",[=[[[[0,"!","a"],[1,"🙂!","b"]],";","tail","",3]]=])
for _,helper in ipairs({"gap_text","gap_kind"}) do
  for _,suffix in ipairs({"","[0]"}) do
    local label=helper .. (suffix=="" and "_primitive" or "_read")
    function_fence(label,carrier("push(rows,[denied(),call(Item)])","fn denied(){return(" .. helper .. "()" .. suffix .. ".coalesce(\"M\"))}"),helper)
  end
end
check_value("explicit_args",carrier("push(rows,[selected(gap_text(),gap_kind()),call(Item)])",[=[fn selected(text,kind){return([text.cat("!"),kind.uppercase()])}]=]),"a,b;",[=[[[[["!","PREFIX"],"a"],[[",!","INTERSTITIAL"],"b"]],";","tail","",3]]=])
for _,helper in ipairs({"gap_text","gap_kind"}) do
  for _,suffix in ipairs({"",".coalesce(\"M\")"}) do
    error_case(helper .. suffix,"Top:: I {return(" .. helper .. "()" .. suffix .. ")}",helper,"gap_capture_context_unavailable","access_gap_context")
  end
  for _,argument in ipairs({"1","extra:1"}) do
    error_case(helper .. "_" .. argument,"Top:: I {return(" .. helper .. "(" .. argument .. ")[0].coalesce(\"M\"))}",helper,"helper_arity_mismatch","helper_arity_mismatch",1)
  end
end
io.stdout:write("GAP_STRING_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("gap String result checks passed: ",checks,"\n")
