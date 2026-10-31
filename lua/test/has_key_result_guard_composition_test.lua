-- TYPE-REFERENCE-BOOK.1.2.23.3.69.5 — presence source/prefix guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "presence-result-guard-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "presence-result-guard-composition.spec") end},
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
  io.stdout:write("PRESENCE_GUARD_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_presence",[==[Value:: I {return([has_key({"k":false},"k"),has_key({},"k"),has_key({"k":undef},"k"),{"k":1}.has_key("k"),{}.has_key("k")])}]==],"x",[==[[1,0,1,1,0]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=has_key({},"k").take({order=cat(order,"A");1});right=has_key({"k":1},"k").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left={}.has_key("k").take({order=cat(order,"A");1});right={"k":1}.has_key("k").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("free_guard_before_with",[==[Value:: I {order="";out=has_key({order=cat(order,"S");{}},{order=cat(order,"K");"k"}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"SK"]]==])
check_value("receiver_guard_before_with",[==[Value:: I {order="";out={order=cat(order,"S");{}}.has_key({order=cat(order,"K");"k"}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"SK"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=has_key({},"k").cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("receiver_bridge_rejection",[==[Value:: I {order="";out={}.has_key("k").cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("compatible_values",[==[Value:: I {return([has_key({},"k").cat("!"),has_key({},"k").coalesce_nonempty("late").cat("!"),{}.has_key("k").coalesce("late").cat("!")])}]==],"x",[==[["0!","0!","0!"]]==])
check_value("value_kinds",[==[Value:: I {return([has_key({},"k").copy(),{}.has_key("k").copy(),has_key({},"k").add(1),has_key({"k":1},"k").add(1)])}]==],"x",[==[[0,0,1,2]]==])
check_value("source_key_snapshot",[==[Value:: I {order="";meta={};out=has_key({order=cat(order,"S");meta},{order=cat(order,"K");meta["k"]=1;"k"}).cat({order=cat(order,"C");meta["k"]=2;"!"});return([out,meta,order])}]==],"x",[==[["0!",{"k":2},"SKC"]]==])
check_value("valid_false_with",[==[Value:: I {order="";out=has_key({},"k").with(){order=cat(order,"W");return([value,value.copy()])};return([out,order])}]==],"x",[==[[[0,0],"W"]]==])
check_value("null_source_key_effect",[==[Value:: I {order="";out=has_key(undef,{order=cat(order,"K");"k"}).cat("!");return([out,order])}]==],"x",[==[["0!","K"]]==])
check_value("valid_array_bridges",[==[Value:: I {return([has_key({},"k").cat(",x").split(",").last().uppercase(),{"k":1}.has_key("k").cat(",x").split(",").last().uppercase()])}]==],"x",[==[["X","X"]]==])
check_value("valid_null_with",[==[Value:: I {order="";left=has_key({},"k").add("bad").with(){order=cat(order,"F");return("free")};right={}.has_key("k").add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}]==],"x",[==[["free","receiver","FR"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out=has_key({},"k").add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}]==],"x",[==[[0,"W"]]==])
check_value("with_result_array",[==[Value:: I {order="";out=has_key({},"k").with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}]==],"x",[==[["OK","W"]]==])
check_value("function_scope",[==[fn build(){order="";left=has_key({},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right={"k":1}.has_key("k").take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,null,""],"caller"]]==])
check_value("all_canonical_free_with_guards",[==[Value:: I {order="";out=[has_key({},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},has_key({"k":1},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},has_key({"k":false},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},has_key({"k":undef},"k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null],""]]==])
check_value("all_short_receiver_with_guards",[==[Value:: I {order="";out=[{}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},{"k":1}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},{"k":false}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},{"k":undef}.has_key("k").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null],""]]==])
check_value("all_canonical_free_guards",[==[Value:: I {order="";out=[has_key({},"k").take({order=cat(order,"A");1}),has_key({"k":1},"k").take({order=cat(order,"A");1}),has_key({"k":false},"k").take({order=cat(order,"A");1}),has_key({"k":undef},"k").take({order=cat(order,"A");1})];return([out,order])}]==],"x",[==[[[null,null,null,null],""]]==])
check_value("repeated_predicates",[==[Value:: I {return([has_key({},"k").is_empty().cat("!"),has_key({},"k").is_defined().cat("!"),{}.has_key("k").is_nonempty().cat("!"),{"k":1}.has_key("k").is_undefined().cat("!")])}]==],"x",[==[["0!","1!","1!","0!"]]==])
do
  local function fixture(name)
    local f=assert(io.open("tests/fixtures/" .. name,"r"));local text=f:read("*a");f:close();return text
  end
  check_value("null_source_operand_snapshot",fixture("has_key_null_source_operand_values.spec"),"x",fixture("has_key_null_source_operand_values.perl.json"))
end
do
  local actual=observe([==[Value:: I {return(has_key({items="text";push(items,"x")},"k").coalesce("masked"))}]==],"x")
  io.stdout:write("PRESENCE_GUARD_ERROR needed_source_error ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[has_key().take(1).with(){return("x")}]==],
  [==[has_key({}).take(1)]==],
  [==[has_key({},"k","x").take(1)]==],
  [==[has_key(source:{},key:"k").take(1)]==],
  [==[{}.has_key().with(){return("x")}]==],
  [==[{}.has_key("k","x").with(){return("x")}]==],
  [==[{}.has_key(key:"k").with(){return("x")}]==],
  [==[has_key({},key:"k").take(1)]==],
  [==[has_key({},"k"){return("x")}]==],
  [==[{}.has_key("k"){return("x")}]==],
  [==[has_key({},"k").map_leaves(){return(value)}]==],
  [==[{}.has_key("k").map_leaves(){return(value)}]==],
  [==[{|| return(has_key({},"k").take(1).with(){return("x")}) }]==],
  [==[has_key({},"k").custom_presence().with(){return("x")}]==],
  [==[{}.has_key("k").custom_presence().with(){return("x")}]==],
  [==[is_empty([]).take(1).with(){return("x")}]==],
  [==[is_defined(undef).take(1).with(){return("x")}]==],
  [==[and(false).take(1).with(){return("x")}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==18,"all authored excluded presence source shapes selected")
io.stdout:write("PRESENCE_GUARD_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("PRESENCE_GUARD_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("presence source and prefix checks passed: ",checks,"\n")
