-- TYPE-REFERENCE-BOOK.1.2.23.3.60.5 — canonical free-default result guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "free-default-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "free-default-result-composition.spec") end},
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
  io.stdout:write("FREE_DEFAULT_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("scalar_primitives",[==[Value::
 I {return([coalesce(undef,"tail"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce_nonempty("",0,"late"),coalesce_nonempty(undef,false,"late"),coalesce_nonempty(undef,"")])}
]==],"x",[==[["tail","",0,false,null,0,false,null]]==])
check_value("scalar_compatible",[==[Value::
 I {return([coalesce(undef," tail ").trim().uppercase(),coalesce_nonempty("",0).add(1),coalesce(false,true).not(),coalesce_nonempty(undef,"tail").cat("!")])}
]==],"x",[==[["TAIL",1,true,"tail!"]]==])
check_value("scalar_string_guards",[==[Value::
 I {order="";a=coalesce(undef,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=coalesce_nonempty("","tail").take({order=cat(order,"A");1});return([a,b,order])}
]==],"x",[==[[null,null,""]]==])
check_value("scalar_number_bool_guards",[==[Value::
 I {order="";a=coalesce(undef,0).take({order=cat(order,"A");1});b=coalesce_nonempty(undef,false).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}
]==],"x",[==[[null,null,""]]==])
check_value("container_compatible",[==[Value::
 I {return([coalesce(undef,["head","tail"])[-1].uppercase(),coalesce_nonempty(undef,{"k":"tail"}).sorted_keys().last().uppercase(),coalesce([],"late").count(),coalesce_nonempty({},"late").count_keys()])}
]==],"x",[==[["TAIL","K",0,0]]==])
check_value("container_guards",[==[Value::
 I {order="";a=coalesce(["tail"],undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=coalesce_nonempty({"k":"tail"},undef).take({order=cat(order,"A");1});return([a,b,order])}
]==],"x",[==[[null,null,""]]==])
check_value("completed_bound_guards",[==[Value::
 I {order="";saved=coalesce(undef,["tail"]);meta=coalesce_nonempty("",{"k":"tail"});a=saved.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce(undef).take({order=cat(order,"A");1});return([a,b,saved,meta,order])}
]==],"x",[==[[null,null,["tail"],{"k":"tail"},""]]==])
check_value("selected_guard",[==[Value::
 I {order="";a=coalesce(undef,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,order])}
]==],"x",[==[[null,""]]==])
check_value("lazy_order_and_snapshot",[==[Value::
 I {order="";items=["head","tail"];out=coalesce({order=cat(order,"S");undef},{order=cat(order,"D");items},{order=cat(order,"L");"late"})[{items=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
]==],"x",[==[["TAIL!",["new"],"SDIC"]]==])
check_value("skip_unused_failure",[==[Value::
 I {order="";a=coalesce("",{items="text";push(items,"x")}).cat("!");b=coalesce_nonempty(0,{items="text";push(items,"x")}).add(1);return([a,b,order])}
]==],"x",[==[["!",1,""]]==])
check_value("with_kinds_and_outer_scope",[==[Value::
 I {value="outer";order="";a=coalesce(undef,"tail").with(){return({"k":[value,"tail"]})}["k"][-1].uppercase();bad=coalesce_nonempty("","tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([a,bad,value,order])}
]==],"x",[==[["TAIL",null,"outer",""]]==])
check_value("function_scope",[==[fn pick(){order="";items=["head","tail"];out=coalesce({order=cat(order,"S");undef},{order=cat(order,"D");items},{order=cat(order,"L");"late"})[{items=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
Value::
 I {items=["caller"];order="outer";return([pick(),items,order])}
]==],"x",[==[[["TAIL!",["new"],"SDIC"],["caller"],"outer"]]==])
check_value("valid_null_with_runs",[==[Value:: I {order="";out=coalesce(undef,undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}]==],"x",[==[["recovered","W"]]==])
check_value("valid_empty_array_with_runs",[==[Value:: I {order="";out=coalesce(["tail"],undef).take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}]==],"x",[==[[[0,"tail"],"W"]]==])
check_value("rejection_skips_with_after_source_once",[==[Value:: I {order="";out=coalesce_nonempty({order=cat(order,"S");""},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("valid_with_preserves_outer_value",[==[Value:: I {value="outer";out=coalesce(undef,"tail").with(){return(value.cat("!"))};return([out,value])}]==],"x",[==[["tail!","outer"]]==])
check_value("named_nonempty_container_guards",[==[Value:: I {order="";items=["tail"];meta={"k":"tail"};a=items.coalesce_nonempty({order=cat(order,"F");"late"}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce_nonempty({order=cat(order,"F");"late"}).take({order=cat(order,"A");1});return([a,b,items,meta,order])}]==],"x",[==[[null,null,["tail"],{"k":"tail"},""]]==])
local actual=observe([=[Value:: I {return(coalesce(undef,{items="text";push(items,"x")}).coalesce("masked"))}]=],"x")
io.stdout:write("FREE_DEFAULT_ERROR ",json.encode(actual),"\n")
verify(actual.compile_error==nil,"needed default compiles")
for _,route in ipairs({"native","restored","plan","fresh"}) do
  local row=actual[route]
  verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,
    route .. " needed default error precedes recovery")
end
local shapes=json.array({})
for _,source in ipairs({
  [=[coalesce().take(1)]=],
  [=[coalesce("tail").take(1)]=],
  [=[coalesce(first:"tail",second:undef).take(1)]=],
  [=[coalesce_nonempty("","tail"){return("x")}.take(1)]=],
  [=[(coalesce(undef,"tail")).take(1)]=],
  [=[thunk().take(1)]=],
  [=[coalesce(undef,["tail"])[-1]="x"]=],
  [=[{|| return(coalesce(undef,"tail").take(1)) }]=],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==8,"all authored excluded source shapes selected")
io.stdout:write("FREE_DEFAULT_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("FREE_DEFAULT_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("free-default result checks passed: ",checks,"\n")
