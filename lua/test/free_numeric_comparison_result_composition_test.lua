-- TYPE-REFERENCE-BOOK.1.2.23.3.64.5 — canonical numeric comparison source and Number-prefix result guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "free-numeric-comparison-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "free-numeric-comparison-result-composition.spec") end},
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
  io.stdout:write("FREE_NUMERIC_COMPARISON_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_comparisons",[==[Value:: I {return([[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)],[2.eq(2),2.ne(3),3.gt(2),2.ge(2),2.lt(3),2.le(2),2.eq(3),2.ne(2),2.gt(3),2.ge(3),3.lt(2),3.le(2)]])}]==],"x",[==[[[1,1,1,1,1,1,0,0,0,0,0,0],[1,1,1,1,1,1,0,0,0,0,0,0]]]==])
check_value("strict_numeric_domains",[==[Value:: I {return([num_eq("02",2),num_lt("-.5",0),num_eq(false,0),num_eq(undef,0),num_eq([],0),num_eq({},0),num_eq(" 2",2),"02".eq(2),false.eq(0),"bad".eq(0)])}]==],"x",[==[[1,1,null,null,null,null,null,1,null,null]]==])
check_value("compatible_values",[==[Value:: I {return([num_eq(2,2).cat("!"),num_eq(2,3).coalesce_nonempty(9).cat("!"),num_lt(2,3).cat(",tail").split(",").last().uppercase(),2.eq(3).add(2)])}]==],"x",[==[["1!","0!","TAIL",2]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=num_eq(2,3).take({order=cat(order,"A");1});right=num_gt(3,2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left=2.eq(3).take({order=cat(order,"A");1});right=3.gt(2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("free_guard_before_with",[==[Value:: I {order="";out=num_eq({order=cat(order,"S");return(2)},2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("receiver_guard_before_with",[==[Value:: I {order="";out={order=cat(order,"S");return(2)}.eq(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=num_eq(2,3).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("receiver_bridge_rejection",[==[Value:: I {order="";out=2.eq(3).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_array_bridges",[==[Value:: I {return([num_eq(2,2).split(",").first().cat("!"),2.eq(3).split(",").first().cat("!")])}]==],"x",[==[["1!","0!"]]==])
check_value("source_operand_snapshot",[==[Value:: I {value=2;order="";out=num_eq({order=cat(order,"S");return(value)},{value=99;order=cat(order,"O");return(2)}).cat({order=cat(order,"C");"!"});return([out,value,order])}]==],"x",[==[["1!",99,"SOC"]]==])
check_value("zero_typed_indices",[==[Value:: I {slots=["old"];index=num_eq(2,3).copy();slots[index]="free";other=2.eq(3).copy();slots[other]="receiver";return([index,other,slots])}]==],"x",[==[[0,0,["receiver"]]]==])
check_value("valid_null_with",[==[Value:: I {order="";left=num_eq("bad",2).with(){order=cat(order,"F");return("free")};right="bad".eq(2).with(){order=cat(order,"R");return("receiver")};return([left,right,order])}]==],"x",[==[["free","receiver","FR"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out=num_eq("bad",2).coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}]==],"x",[==[[0,"W"]]==])
check_value("all_canonical_free_guards",[==[Value:: I {order="";out=[num_eq(2,2).take({order=cat(order,"A");1}),num_ne(2,3).take({order=cat(order,"A");1}),num_gt(3,2).take({order=cat(order,"A");1}),num_ge(2,2).take({order=cat(order,"A");1}),num_lt(2,3).take({order=cat(order,"A");1}),num_le(2,2).take({order=cat(order,"A");1}),num_eq(2,3).take({order=cat(order,"A");1}),num_ne(2,2).take({order=cat(order,"A");1}),num_gt(2,3).take({order=cat(order,"A");1}),num_ge(2,3).take({order=cat(order,"A");1}),num_lt(3,2).take({order=cat(order,"A");1}),num_le(3,2).take({order=cat(order,"A");1})];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
check_value("all_short_receiver_with_guards",[==[Value:: I {order="";out=[2.eq(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ne(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.gt(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ge(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.lt(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.le(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.eq(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ne(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.gt(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.ge(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.lt(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.le(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";left=num_eq(2,3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=2.eq(3).take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,null,""],"caller"]]==])
check_value("valid_zero_and_one_with",[==[Value:: I {order="";zero=num_eq(2,3).with(){order=cat(order,"F");return(value.add(2))};one=2.eq(2).with(){order=cat(order,"R");return(value.add(2))};return([zero,one,order])}]==],"x",[==[[2,3,"FR"]]==])
do
  local actual=observe([==[Value:: I {return(num_eq({items="text";push(items,"x")},2).coalesce("masked"))}]==],"x")
  io.stdout:write("FREE_NUMERIC_COMPARISON_ERROR ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[num_eq().take(1).with(){return("x")}]==],
  [==[num_eq(1).take(1).with(){return("x")}]==],
  [==[num_eq(1,1,1).take(1)]==],
  [==[num_eq(left:1,right:1).take(1)]==],
  [==[eq(1,1).take(1)]==],
  [==[==(1,1).take(1)]==],
  [==[num_min([1,2]).take(1)]==],
  [==[[1,2].min().with(){return(value)}]==],
  [==[str_eq("a","a").take(1).with(){return("x")}]==],
  [==["a".str_eq("a").take(1).with(){return("x")}]==],
  [==[1.eq().with(){return("x")}]==],
  [==[1.eq(2){return("x")}]==],
  [==[{|| return(num_eq(1,1).take(1)) }]==],
  [==[num_eq(1,1).map_leaves(){return(value)}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==14,"all authored excluded numeric comparison source shapes selected")
io.stdout:write("FREE_NUMERIC_COMPARISON_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("FREE_NUMERIC_COMPARISON_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("numeric comparison source and Number-prefix checks passed: ",checks,"\n")
