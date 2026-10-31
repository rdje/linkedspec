-- TYPE-REFERENCE-BOOK.1.2.23.3.65.5 — eager logical Boolean source/prefix guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "logical-result-guard-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "logical-result-guard-composition.spec") end},
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
  io.stdout:write("LOGICAL_GUARD_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_logical",[==[Value:: I {return([[and(true),and(false),or(true),or(false),not(false),not(true)],[true.and(true),true.and(false),false.or(true),false.or(false),false.not(),true.not()]])}]==],"x",[==[[[true,false,true,false,true,false],[true,false,true,false,true,false]]]==])
check_value("typed_truth_domains",[==[Value:: I {return([and("0"),and("false"),and(""),and(0),and(undef),and([]),and({}),and([false]),and({"k":false})])}]==],"x",[==[[true,true,false,false,false,false,false,true,true]]==])
check_value("compatible_values",[==[Value:: I {return([and(false).coalesce_nonempty(9).cat("!"),not(false).cat("!"),or(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase(),false.not().and(true).cat("!")])}]==],"x",[==[["0!","1!","B","1!"]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=and(false).take({order=cat(order,"A");1});right=not(false).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left=true.and(false).take({order=cat(order,"A");1});right=false.not().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("free_guard_before_with",[==[Value:: I {order="";out=and({order=cat(order,"S");return(false)},{order=cat(order,"O");return(true)}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"SO"]]==])
check_value("receiver_guard_before_with",[==[Value:: I {order="";out={order=cat(order,"S");return(false)}.and({order=cat(order,"O");return(true)}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"SO"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=and(false).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("receiver_bridge_rejection",[==[Value:: I {order="";out=false.and(true).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_array_bridges",[==[Value:: I {return([and(false).split(",").first().cat("!"),false.or(true).split(",").first().cat("!")])}]==],"x",[==[["0!","1!"]]==])
check_value("source_operand_snapshot",[==[Value:: I {value=false;order="";out=and({order=cat(order,"S");return(value)},{value=true;order=cat(order,"O");return(true)}).cat({order=cat(order,"C");"!"});return([out,value,order])}]==],"x",[==[["0!",true,"SOC"]]==])
check_value("bool_value_copies",[==[Value:: I {return([and(false).copy(),false.and(true).copy(),copy(false)])}]==],"x",[==[[false,false,false]]==])
check_value("valid_false_and_true_with",[==[Value:: I {order="";left=and(false).with(){order=cat(order,"F");return([value,value.copy()])};right=true.or(false).with(){order=cat(order,"R");return(value)};return([left,right,order])}]==],"x",[==[[[false,false],true,"FR"]]==])
check_value("valid_null_with",[==[Value:: I {order="";left=and(false).add(1).with(){order=cat(order,"F");return("free")};right=false.and(true).add(1).with(){order=cat(order,"R");return("receiver")};return([left,right,order])}]==],"x",[==[["free","receiver","FR"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out=and(false).add(1).coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}]==],"x",[==[[0,"W"]]==])
check_value("with_result_array",[==[Value:: I {order="";out=and(false).with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}]==],"x",[==[["OK","W"]]==])
check_value("all_canonical_free_with_guards",[==[Value:: I {order="";out=[and(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},and(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},or(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},or(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},not(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},not(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null],""]]==])
check_value("all_short_receiver_with_guards",[==[Value:: I {order="";out=[true.and(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},true.and(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},false.or(true).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},false.or(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},false.not().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},true.not().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";left=and(false).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right=false.and(true).take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,null,""],"caller"]]==])
check_value("decisive_eager_args",[==[Value:: I {order="";left=and({order=cat(order,"L");return(false)},{order=cat(order,"R");return(true)}).cat({order=cat(order,"C");"!"});right=or({order=cat(order,"A");return(true)},{order=cat(order,"B");return(false)}).cat({order=cat(order,"D");"!"});return([left,right,order])}]==],"x",[==[["0!","1!","LRCABD"]]==])
do
  local actual=observe([==[Value:: I {return(and({items="text";push(items,"x")},true).coalesce("masked"))}]==],"x")
  io.stdout:write("LOGICAL_GUARD_ERROR needed_source_error ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
do
  local actual=observe([==[Value:: I {return(not({fail("must-not-run")},false).cat("!"))}]==],"x")
  io.stdout:write("LOGICAL_GUARD_ERROR typed_arity_source_error ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("helper_arity_mismatch",1,true)~=nil,route .. " needed source error")
    verify(row~=nil and row.error~=nil and row.error:find("must-not-run",1,true)==nil,route .. " invalid arity precedes operands")
    if route=="native" or route=="restored" then
      verify(row~=nil and row.code=="helper_arity_mismatch",route .. " typed code")
      verify(row~=nil and row.helper_name=="not",route .. " original helper")
      verify(row~=nil and row.actual_arity==2,route .. " original arity")
    else
      verify(row~=nil and row.error~=nil and row.error:find("helper_name=not",1,true)~=nil,route .. " helper token")
      verify(row~=nil and row.error~=nil and row.error:find("actual_arity=2",1,true)~=nil,route .. " arity token")
    end
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[and().take(1).with(){return("x")}]==],
  [==[or().take(1).with(){return("x")}]==],
  [==[not().take(1)]==],
  [==[not(true,false).take(1)]==],
  [==[and(value:true).take(1).with(){return("x")}]==],
  [==[false.and().with(){return("x")}]==],
  [==[false.or().with(){return("x")}]==],
  [==[false.not(true).with(){return("x")}]==],
  [==[false.and(right:true).with(){return("x")}]==],
  [==[and(true){return("x")}]==],
  [==[false.and(true){return("x")}]==],
  [==[and(true).map_leaves(){return(value)}]==],
  [==[false.and(true).map_leaves(){return(value)}]==],
  [==[{|| return(and(false).take(1).with(){return("x")}) }]==],
  [==[and(false).custom_logical().with(){return("x")}]==],
  [==[false.not().custom_logical().with(){return("x")}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==16,"all authored excluded logical source shapes selected")
io.stdout:write("LOGICAL_GUARD_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("LOGICAL_GUARD_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("logical source and prefix checks passed: ",checks,"\n")
