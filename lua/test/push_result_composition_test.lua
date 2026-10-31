-- TYPE-REFERENCE-BOOK.1.2.23.3.58.5 — explicit push snapshot result guards.
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
  local file = assert(io.open("tests/fixtures/push_result_selection_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "push-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "push-result-composition.spec") end},
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
  io.stdout:write("PUSH_SNAPSHOT_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("shared",fixture("spec"),"x",fixture("json"))
check_value("primitive_saved",[==[Value:: I {items=[];saved=push(items,"a");items.push_back("later");return([saved,items])}]==],"x",[==[[["a"],["a","later"]]]==])
check_value("absent_empty",[==[Value:: I {empty=push(created,"").last().coalesce("F").cat("!");missing=push(nulls,undef).last().coalesce(["a","tail"])[-1].uppercase();array=push(empties,[]).last().count().add(1);return([empty,missing,array,created,nulls,empties])}]==],"x",[==[["!","TAIL",1,[""],[null],[[]]]]==])
check_value("transitions",[==[Value:: I {items=[];number=push(items,[3,1]).last().sorted().last().add(4);hash=push(items,{"k":"tail"}).last().sorted_keys().last().uppercase();count=push(items,"tail").count().add(1);text=push(items,"tail").copy().last().uppercase();boolean=push(items,false).last().not();logical=push(items,"tail").is_nonempty().and(false);return([number,hash,count,text,boolean,logical,items])}]==],"x",[==[[7,"K",4,"TAIL",true,false,[[3,1],{"k":"tail"},"tail","tail",false,"tail"]]]==])
check_value("direct_guard",[==[Value:: I {items=[];order="";out=push(items,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}]==],"x",[==[[null,["tail"],""]]==])
check_value("selected_recovery",[==[Value:: I {items=[];order="";bad=push(items,false)[-1].take({order=cat(order,"A");1});out=push(items,"tail")[-1][0].coalesce(["a","tail"])[-1].uppercase();empty=push(items,"")[-1].coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,out,empty,items,order])}]==],"x",[==[[null,"TAIL","!",[false,"tail",""],""]]==])
check_value("with_kinds",[==[Value:: I {items=[];value="outer";order="";array=push(items,"a").with(){return([value,"tail"])}[-1].uppercase();hash=push(items,"b").with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=push(items,"c").with(){return(false)}.take({order=cat(order,"A");1});boolean=push(items,"d").with(){return(false)}.coalesce(true);return([array,hash,bad,boolean,value,order,items])}]==],"x",[==[["TAIL","TAIL",null,false,"outer","",["a","b","c","d"]]]==])
check_value("source_once",[==[Value:: I {items=[];order="";out=push(items,{order=cat(order,"S");return("tail")}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}]==],"x",[==[["TAIL!",["new"],"SC"]]==])
check_value("function_local",[==[fn pick(){items=[];out=push(items,"tail").last().uppercase();return([out,items])} Value:: I {items=["caller"];return([pick(),items])}]==],"x",[==[[["TAIL",["tail"]],["caller"]]]==])
check_value("static_child",[==[Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
]==],"x",[==[[["unchanged"],["child-result"],["child-result"]]]==])
check_value("selected_string_guard",[==[Value:: I {items=[];order="";out=push(items,"tail")[-1].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}]==],"x",[==[[null,["tail"],""]]==])
for _,entry in ipairs({
  {"primitive", [=[Value:: I {items="text";return(push(items,"x"))}]=]},
  {"fluent", [=[Value:: I {items="text";return(push(items,"x").last().coalesce("masked"))}]=]},
}) do
  local label,source=entry[1],entry[2]
  local actual=observe(source,"x")
  io.stdout:write("PUSH_SNAPSHOT_ERROR ",label," ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,label .. " compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,
      label .. " " .. route .. " source error precedes default")
  end
end
io.stdout:write("PUSH_SNAPSHOT_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("push snapshot result checks passed: ",checks,"\n")
