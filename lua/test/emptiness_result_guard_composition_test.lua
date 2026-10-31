-- TYPE-REFERENCE-BOOK.1.2.23.3.68.5 — emptiness source/prefix guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "emptiness-result-guard-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "emptiness-result-guard-composition.spec") end},
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
  io.stdout:write("EMPTINESS_GUARD_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_emptiness",[==[Value:: I {return([[is_empty([]),is_empty([1]),is_nonempty([1]),is_nonempty([])],[[].is_empty(),[1].is_empty(),[1].is_nonempty(),[].is_nonempty()]])}]==],"x",[==[[[true,false,true,false],[true,false,true,false]]]==])
check_value("empty_domains",[==[Value:: I {return([is_empty(undef),is_empty(""),is_empty([]),is_empty({}),is_empty(0),is_empty(false),is_empty("0"),is_empty([0]),is_empty({"k":0}),is_nonempty(undef),is_nonempty(""),is_nonempty([]),is_nonempty({}),is_nonempty(0),is_nonempty(false),is_nonempty("0"),is_nonempty([0]),is_nonempty({"k":0})])}]==],"x",[==[[true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true]]==])
check_value("compatible_values",[==[Value:: I {return([is_empty([1]).cat("!"),is_empty([1]).coalesce_nonempty("late").cat("!"),is_nonempty([]).cat("!"),is_nonempty([]).coalesce("late").cat("!")])}]==],"x",[==[["0!","0!","0!","0!"]]==])
check_value("value_kinds",[==[Value:: I {return([is_empty([1]).copy(),[1].is_empty().copy(),is_empty([1]).add(1),is_empty([]).add(1)])}]==],"x",[==[[false,false,null,null]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=is_empty([1]).take({order=cat(order,"A");1});right=is_empty([]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left=[1].is_empty().take({order=cat(order,"A");1});right=[].is_empty().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("free_guard_before_with",[==[Value:: I {order="";out=is_empty({order=cat(order,"S");[1]}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("receiver_guard_before_with",[==[Value:: I {order="";out={order=cat(order,"S");[1]}.is_empty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=is_empty([1]).cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("receiver_bridge_rejection",[==[Value:: I {order="";out=[1].is_empty().cat("x").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_array_bridges",[==[Value:: I {return([is_empty([1]).cat(",x").split(",").last().uppercase(),[].is_empty().cat(",x").split(",").last().uppercase()])}]==],"x",[==[["X","X"]]==])
check_value("source_snapshot",[==[Value:: I {order="";value=[];out=is_empty({order=cat(order,"S");value}).cat({value=[1];order=cat(order,"C");"!"});return([out,value.is_empty().cat("!"),order])}]==],"x",[==[["1!","0!","SC"]]==])
check_value("valid_false_and_true_with",[==[Value:: I {order="";left=is_empty([1]).with(){order=cat(order,"F");return([value,value.copy()])};right=[].is_empty().with(){order=cat(order,"R");return(value)};return([left,right,order])}]==],"x",[==[[[false,false],true,"FR"]]==])
check_value("valid_null_with",[==[Value:: I {order="";left=is_empty([1]).add("bad").with(){order=cat(order,"F");return("free")};right=[1].is_empty().add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}]==],"x",[==[["free","receiver","FR"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out=is_empty([1]).add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}]==],"x",[==[[0,"W"]]==])
check_value("with_result_array",[==[Value:: I {order="";out=is_empty([1]).with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}]==],"x",[==[["OK","W"]]==])
check_value("all_canonical_free_with_guards",[==[Value:: I {order="";out=[is_empty([]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_empty([1]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_nonempty([1]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},is_nonempty([]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null],""]]==])
check_value("all_short_receiver_with_guards",[==[Value:: I {order="";out=[[].is_empty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},[1].is_empty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},[1].is_nonempty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},[].is_nonempty().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";left=is_empty([1]).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=[].is_empty().take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,null,""],"caller"]]==])
check_value("all_canonical_free_guards",[==[Value:: I {order="";out=[is_empty([]).take({order=cat(order,"A");1}),is_empty([1]).take({order=cat(order,"A");1}),is_nonempty([1]).take({order=cat(order,"A");1}),is_nonempty([]).take({order=cat(order,"A");1})];return([out,order])}]==],"x",[==[[[null,null,null,null],""]]==])
check_value("repeated_predicates",[==[Value:: I {return([is_empty([1]).is_empty().cat("!"),is_empty([1]).is_nonempty().cat("!"),[1].is_empty().is_empty().cat("!"),[].is_empty().is_nonempty().cat("!")])}]==],"x",[==[["0!","1!","0!","1!"]]==])
do
  local actual=observe([==[Value:: I {return(is_empty({items="text";push(items,"x")}).coalesce("masked"))}]==],"x")
  io.stdout:write("EMPTINESS_GUARD_ERROR needed_source_error ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[is_empty().take(1).with(){return("x")}]==],
  [==[is_empty([],[]).take(1).with(){return("x")}]==],
  [==[is_empty(value:[]).take(1)]==],
  [==[is_nonempty().take(1)]==],
  [==[is_nonempty([1],[2]).take(1)]==],
  [==[is_nonempty(value:[1]).take(1)]==],
  [==[[].is_empty(1).with(){return("x")}]==],
  [==[[1].is_nonempty(1).with(){return("x")}]==],
  [==[[].is_empty(value:1).with(){return("x")}]==],
  [==[is_empty([]){return("x")}]==],
  [==[[].is_empty(){return("x")}]==],
  [==[is_empty([]).map_leaves(){return(value)}]==],
  [==[[].is_empty().map_leaves(){return(value)}]==],
  [==[{|| return(is_empty([]).take(1).with(){return("x")}) }]==],
  [==[is_empty([]).custom_empty().with(){return("x")}]==],
  [==[[].is_empty().custom_empty().with(){return("x")}]==],
  [==[is_defined(undef).take(1).with(){return("x")}]==],
  [==[str_eq("a","b").take(1).with(){return("x")}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==18,"all authored excluded emptiness source shapes selected")
io.stdout:write("EMPTINESS_GUARD_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("EMPTINESS_GUARD_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("emptiness source and prefix checks passed: ",checks,"\n")
