-- TYPE-REFERENCE-BOOK.1.2.23.3.63.5 — canonical arithmetic source and Number-prefix result guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "free-numeric-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "free-numeric-result-composition.spec") end},
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
  io.stdout:write("FREE_NUMERIC_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_arithmetic",[==[Value:: I {return([num_abs(-3),num_floor(3.8),num_ceil(3.2),num_round(2.5),num_add(1,2,3),num_sub(5,2),num_mul(2,3,4),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(7,3,5),num_max(3,5,4)])}]==],"x",[==[[3,3,4,3,6,3,24,3.5,1,10,3,5]]==])
check_value("compatible_values",[==[Value:: I {return([num_add(2,3).cat("!"),num_div(6,2).cat(",tail").split(",").last().uppercase(),num_add(0,0).coalesce_nonempty(9).add(1),2.add(3).cat("!")])}]==],"x",[==[["5!","TAIL",1,"5!"]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=num_add(1,2).take({order=cat(order,"A");1});right=num_sub(5,2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left=1.add(2).take({order=cat(order,"A");1});right=5.sub(2).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("free_guard_before_with",[==[Value:: I {order="";out=num_add({order=cat(order,"S");return(1)},2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("receiver_guard_before_with",[==[Value:: I {order="";out={order=cat(order,"S");return(1)}.add(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=num_add(1,2).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("receiver_bridge_rejection",[==[Value:: I {order="";out=1.add(2).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_array_bridges",[==[Value:: I {return([num_add(1,2).split(",").first().cat("!"),1.add(2).split(",").first().cat("!")])}]==],"x",[==[["3!","3!"]]==])
check_value("source_operand_snapshot",[==[Value:: I {value=3;order="";out=num_add({order=cat(order,"S");return(value)},{value=99;order=cat(order,"O");return(2)}).cat({order=cat(order,"C");"!"});return([out,value,order])}]==],"x",[==[["5!",99,"SOC"]]==])
check_value("zero_typed_indices",[==[Value:: I {slots=["old"];index=num_add(0,0).copy();slots[index]="free";other=0.add(0).copy();slots[other]="receiver";return([index,other,slots])}]==],"x",[==[[0,0,["receiver"]]]==])
check_value("valid_null_with",[==[Value:: I {order="";left=num_div(1,0).with(){order=cat(order,"F");return("free")};right=1.div(0).with(){order=cat(order,"R");return("receiver")};return([left,right,order])}]==],"x",[==[["free","receiver","FR"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out=num_div(1,0).coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}]==],"x",[==[[0,"W"]]==])
check_value("all_canonical_free_guards",[==[Value:: I {order="";out=[num_abs(-3).take({order=cat(order,"A");1}),num_floor(3.8).take({order=cat(order,"A");1}),num_ceil(3.2).take({order=cat(order,"A");1}),num_round(2.5).take({order=cat(order,"A");1}),num_add(1,2,3).take({order=cat(order,"A");1}),num_sub(5,2).take({order=cat(order,"A");1}),num_mul(2,3,4).take({order=cat(order,"A");1}),num_div(7,2).take({order=cat(order,"A");1}),num_mod(7,3).take({order=cat(order,"A");1}),num_clamp(12,0,10).take({order=cat(order,"A");1}),num_min(7,3,5).take({order=cat(order,"A");1}),num_max(3,5,4).take({order=cat(order,"A");1})];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
check_value("all_short_receiver_with_guards",[==[Value:: I {order="";out=[3.abs().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.8.floor().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.2.ceil().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.5.round().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},1.add(2,3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},5.sub(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},2.mul(3,4).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},7.div(2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},7.mod(3).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},12.clamp(0,10).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},7.min(3,5).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},3.max(5,4).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";left=num_add(1,2).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=1.add(2).take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,null,""],"caller"]]==])
do
  local actual=observe([==[Value:: I {return(num_add({items="text";push(items,"x")},1).coalesce("masked"))}]==],"x")
  io.stdout:write("FREE_NUMERIC_ERROR ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[num_abs().take(1).with(){return("x")}]==],
  [==[num_add(1).take(1).with(){return("x")}]==],
  [==[num_clamp(1,2).take(1)]==],
  [==[num_add(first:1,second:2).take(1)]==],
  [==[add(1,2).take(1)]==],
  [==[+(1,2).take(1)]==],
  [==[num_min([1,2]).take(1)]==],
  [==[[1,2].min().with(){return(value)}]==],
  [==[num_eq(1,1).take(1).with(){return("x")}]==],
  [==[1.eq(1).take(1).with(){return("x")}]==],
  [==[1.add().with(){return("x")}]==],
  [==[1.add(2){return("x")}]==],
  [==[{|| return(num_add(1,2).take(1)) }]==],
  [==[num_add(1,2).map_leaves(){return(value)}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==14,"all authored excluded arithmetic source shapes selected")
io.stdout:write("FREE_NUMERIC_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("FREE_NUMERIC_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("arithmetic source and Number-prefix checks passed: ",checks,"\n")
