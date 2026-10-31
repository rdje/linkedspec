-- TYPE-REFERENCE-BOOK.1.2.23.3.61.5 — retained constructor result guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "constructor-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "constructor-result-composition.spec") end},
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
  io.stdout:write("CONSTRUCTOR_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_array",[==[Value::
 I {return(array("tail",0,false,undef,["nested"],{"k":1}))}
]==],"x",[==[["tail",0,false,null,["nested"],{"k":1}]]==])
check_value("primitive_hash",[==[Value::
 I {return(hash("k",["head","tail"],"flag",false,"zero",0,"missing",undef))}
]==],"x",[==[{"flag":false,"k":["head","tail"],"missing":null,"zero":0}]==])
check_value("empty_and_compatible",[==[Value::
 I {a=array(3,1).sorted().last().add(4);b=hash("k","tail").sorted_keys().last().uppercase();return([array().count(),hash().count_keys(),a,b])}
]==],"x",[==[[0,0,7,"K"]]==])
check_value("direct_reads",[==[Value::
 I {a=array("head","tail")[-1].uppercase();b=hash("k",["head","tail"])["k"][-1].uppercase();return([a,b])}
]==],"x",[==[["TAIL","TAIL"]]==])
check_value("array_hash_guard",[==[Value::
 I {order="";out=array("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,order])}
]==],"x",[==[[null,""]]==])
check_value("hash_array_guard",[==[Value::
 I {order="";out=hash("k","tail").take({order=cat(order,"A");1});return([out,order])}
]==],"x",[==[[null,""]]==])
check_value("selected_guards",[==[Value::
 I {order="";a=array(false,"tail")[0].take({order=cat(order,"A");1});b=hash("k","tail")["k"].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}
]==],"x",[==[[null,null,""]]==])
check_value("completed_bound_guards",[==[Value::
 I {order="";items=array("tail");meta=hash("k","tail");a=items.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce(undef).take({order=cat(order,"A");1});return([a,b,items,meta,order])}
]==],"x",[==[[null,null,["tail"],{"k":"tail"},""]]==])
check_value("source_order_snapshot",[==[Value::
 I {order="";items=["head","tail"];out=array({order=cat(order,"S");return(items)},["old"])[{items=["new"];order=cat(order,"I");0}][{order=cat(order,"J");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
]==],"x",[==[["TAIL!",["new"],"SIJC"]]==])
check_value("with_kinds",[==[Value::
 I {value="outer";order="";a=array("head","tail").with(){return(hash("k",[value,"tail"]))}["k"][-1].uppercase();bad=hash("k","tail").with(){return(false)}.take({order=cat(order,"A");1});return([a,bad,value,order])}
]==],"x",[==[["TAIL",null,"outer",""]]==])
check_value("function_scope",[==[fn pick(){items=["tail"];return(array(items,"other")[0][-1].uppercase())}
Value::
 I {items=["caller"];return([pick(),items])}
]==],"x",[==[["TAIL",["caller"]]]==])
check_value("array_payload_order",[==[Value::
 I {order="";out=array({order=cat(order,"A");"first"},{order=cat(order,"B");"tail"}).last().uppercase();return([out,order])}
]==],"x",[==[["TAIL","AB"]]==])
check_value("guard_before_with",[==[Value::
 I {order="";out=array("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}
]==],"x",[==[[null,""]]==])
check_value("valid_empty_with",[==[Value::
 I {order="";out=hash().with(){order=cat(order,"W");return([value.count_keys(),"tail"])};return([out,order])}
]==],"x",[==[[[0,"tail"],"W"]]==])
check_value("hash_rejection_source_once_with",[==[Value:: I {order="";out=hash({order=cat(order,"S");return("k")},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("array_prefix_rejection_skips_with",[==[Value:: I {order="";out=array("head","tail").take(1).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_empty_array_prefix_with",[==[Value:: I {order="";out=array("tail").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}]==],"x",[==[[[0,"tail"],"W"]]==])
check_value("valid_null_result_with",[==[Value:: I {order="";out=array("tail").with(){order=cat(order,"N");return(undef)}.with(){order=cat(order,"W");return("recovered")};return([out,order])}]==],"x",[==[["recovered","NW"]]==])
check_value("computed_key_forms",[==[Value:: I {names=["idx"];meta={"key":"field"};return([hash("k".cat("x"),1),hash(names[0],2),hash(meta["key"],3),hash({return("block")},4),hash(cat("c","all"),5)])}]==],"x",[==[[{"kx":1},{"idx":2},{"field":3},{"block":4},{"call":5}]]==])
check_value("hash_block_key_value_order_snapshot",[==[Value:: I {name="old";order="";out=hash({order=cat(order,"K");return(name)},{name="new";order=cat(order,"V");return([false,0,"tail"])});return([out,name,order])}]==],"x",[==[[{"old":[false,0,"tail"]},"new","KV"]]==])
check_value("hash_block_key_function_scope",[==[fn build(key){return(hash({return(key)},array("tail",false)))} Value:: I {key="caller";return([build("inside"),key])}]==],"x",[==[[{"inside":["tail",false]},"caller"]]==])
do
  local actual=observe([==[Value:: I {return(array({items="text";push(items,"x")},"tail").last().coalesce("masked"))}]==],"x")
  io.stdout:write("CONSTRUCTOR_ARGUMENT_ERROR ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed argument compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed argument error")
  end
end
do
  local actual=observe([==[Value:: I {return(hash({items="text";push(items,"x")},"tail").take(1))}]==],"x")
  io.stdout:write("CONSTRUCTOR_KEY_ERROR ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed key compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed key error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[array(items).take(1)]==],
  [==[hash(meta).take(1)]==],
  [==[hash("odd").take(1)]==],
  [==[hash(flat_array(["k",1])).take(1)]==],
  [==[array(flat_array([1,2])).set_key("k",1)]==],
  [==[array(flat_hash({"k":1})).set_key("k",1)]==],
  [==[flat_array([1,2]).set_key("k",1)]==],
  [==[custom_constructor("tail").set_key("k",1)]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==8,"all authored excluded source shapes selected")
io.stdout:write("CONSTRUCTOR_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("CONSTRUCTOR_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("constructor result checks passed: ",checks,"\n")
