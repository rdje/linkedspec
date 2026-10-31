-- TYPE-REFERENCE-BOOK.1.2.23.3.59.5 — canonical set stored-result guards.
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
  local file = assert(io.open("tests/fixtures/set_result_selection_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "set-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "set-result-composition.spec") end},
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
  io.stdout:write("SET_RESULT_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("shared",fixture("spec"),"x",fixture("json"))
check_value("existing_primitives_and_compatible_methods",[==[Value:: I {a=set(text," tail ").trim().uppercase();b=set(items,[3,1]).sorted().first();c=set(meta,{"k":"tail"});d=set(flag,false).not();e=set(number,0).add(1);f=set(absent,undef).coalesce("M");return([a,b,c,d,e,f,text,items,meta,flag,number,absent])}]==],"x",[==[["TAIL",1,{"k":"tail"},true,1,"M"," tail ",[3,1],{"k":"tail"},false,0,null]]==])
check_value("existing_completed_value_read",[==[Value:: I {saved=set(items,["tail"]);out=saved.coalesce(undef)[-1].uppercase();return([out,items])}]==],"x",[==[["TAIL",["tail"]]]==])
check_value("direct_incompatible_consumers_skip_operands",[==[Value:: I {order="";out=set(items,["tail"]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}]==],"x",[==[[null,["tail"],""]]==])
check_value("selected_guards_empty_defaults_and_noncontainer_recovery",[==[Value:: I {order="";bad=set(flag,false)[0].coalesce(false).take({order=cat(order,"A");1});text=set(word,"tail")[0].coalesce(["a","tail"])[-1].uppercase();empty=set(blank,"").coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,text,empty,flag,word,blank,order])}]==],"x",[==[[null,"TAIL","!",false,"tail","",""]]==])
check_value("source_once_before_consumer_rebinding_and_local_returns",[==[Value:: I {order="";out=set(items,{order=cat(order,"S");return(["tail"])}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}]==],"x",[==[["TAIL!",["new"],"SC"]]==])
check_value("with_actual_kinds_preserves_outer_value",[==[Value:: I {value="outer";order="";a=set(text,"source").with(){return([value,"tail"])}[-1].uppercase();b=set(meta,{}).with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=set(flag,false).with(){return(false)}.take({order=cat(order,"A");1});return([a,b,bad,value,order,text,meta,flag])}]==],"x",[==[["TAIL","TAIL",null,"outer","","source",{},false]]==])
check_value("function_local_set_source_and_selectors_keep_caller_scope",[==[fn pick(){items=["old"];order="";out=set(items,["a","tail"])[{order=cat(order,"I");-1}].uppercase();return([out,items,order])} Value:: I {items=["caller"];order="outer";return([pick(),items,order])}]==],"x",[==[[["TAIL",["a","tail"],"I"],["caller"],"outer"]]==])
check_value("set_preserves_existing_first_class_codeblock_values",[==[Value:: I {saved=set(thunk,{|| return("tail")});return([thunk(),saved()])}]==],"x",[==[["tail","tail"]]==])
check_value("selected_bool_skips_array_operand",[==[Value:: I {order="";out=set(items,[false])[0].take({order=cat(order,"A");1});return([out,items,order])}]==],"x",[==[[null,[false],""]]==])
check_value("selected_string_skips_hash_operands",[==[Value:: I {order="";out=set(items,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}]==],"x",[==[[null,["tail"],""]]==])
local actual=observe([=[Value:: I {return(set(target,{items="text";push(items,"x")}).coalesce("masked"))}]=],"x")
io.stdout:write("SET_RESULT_ERROR ",json.encode(actual),"\n")
verify(actual.compile_error==nil,"RHS source compiles")
for _,route in ipairs({"native","restored","plan","fresh"}) do
  local row=actual[route]
  verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,
    route .. " RHS error precedes default")
end
local alias=l.parse_action_expression([=[=(items,["tail"])]=])
verify(alias.kind=="call" and (alias.source_method or alias.name)=="=","assignment alias provenance")
local shapes=json.array({l.action_ast.to_json(alias)})
for _,source in ipairs({
  [=[set()]=],[=[set(items)]=],[=[set(items,["tail"],99)]=],
  [=[set(["items"],"tail")]=],[=[set(items,"tail"){return("x")}[0]]=],
  [=[set(items,["tail"])[-1]="x"]=],[=[{|| return(set(items,["tail"])[-1])}]=],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
io.stdout:write("SET_RESULT_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("SET_RESULT_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("canonical set result checks passed: ",checks,"\n")
