-- TYPE-REFERENCE-BOOK.1.2.23.3.66.5 — lexical comparison source/prefix guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "lexical-result-guard-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "lexical-result-guard-composition.spec") end},
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
  io.stdout:write("LEXICAL_GUARD_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_comparisons",[==[Value:: I {return([[str_eq("a","a"),str_ne("a","b"),str_gt("b","a"),str_ge("a","a"),str_lt("a","b"),str_le("a","a"),str_eq("a","b"),str_ne("a","a"),str_gt("a","b"),str_ge("a","b"),str_lt("b","a"),str_le("b","a")],["a".str_eq("a"),"a".str_ne("b"),"b".str_gt("a"),"a".str_ge("a"),"a".str_lt("b"),"a".str_le("a"),"a".str_eq("b"),"a".str_ne("a"),"a".str_gt("b"),"a".str_ge("b"),"b".str_lt("a"),"b".str_le("a")]])}]==],"x",[==[[[true,true,true,true,true,true,false,false,false,false,false,false],[true,true,true,true,true,true,false,false,false,false,false,false]]]==])
check_value("compatible_values",[==[Value:: I {return([str_eq("a","a").cat("!"),str_eq("a","b").coalesce_nonempty(9).cat("!"),str_lt("a","b").cat(",tail").split(",").last().uppercase(),"a".str_eq("b").cat("!")])}]==],"x",[==[["1!","0!","TAIL","0!"]]==])
check_value("value_kinds",[==[Value:: I {return([str_eq("a","b").copy(),"a".str_eq("b").copy(),str_eq("a","b").add(1),"a".str_eq("a").add(1)])}]==],"x",[==[[false,false,null,null]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=str_eq("a","b").take({order=cat(order,"A");1});right=str_gt("b","a").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left="a".str_eq("b").take({order=cat(order,"A");1});right="b".str_gt("a").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("free_guard_before_with",[==[Value:: I {order="";out=str_eq({order=cat(order,"S");return("a")},{order=cat(order,"O");return("b")}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"SO"]]==])
check_value("receiver_guard_before_with",[==[Value:: I {order="";out={order=cat(order,"S");return("a")}.str_eq({order=cat(order,"O");return("b")}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"SO"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=str_eq("a","b").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("receiver_bridge_rejection",[==[Value:: I {order="";out="a".str_eq("b").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_array_bridges",[==[Value:: I {return([str_eq("a","b").split(",").first().cat("!"),"a".str_eq("a").split(",").first().cat("!")])}]==],"x",[==[["0!","1!"]]==])
check_value("source_operand_snapshot",[==[Value:: I {word="a";order="";out=str_eq({order=cat(order,"S");return(word)},{word="zzz";order=cat(order,"O");return("b")}).cat({order=cat(order,"C");"!"});return([out,word,order])}]==],"x",[==[["0!","zzz","SOC"]]==])
check_value("valid_false_and_true_with",[==[Value:: I {order="";left=str_eq("a","b").with(){order=cat(order,"F");return([value,value.copy()])};right="a".str_eq("a").with(){order=cat(order,"R");return(value)};return([left,right,order])}]==],"x",[==[[[false,false],true,"FR"]]==])
check_value("valid_null_with",[==[Value:: I {order="";left=str_eq("a","a").add("bad").with(){order=cat(order,"F");return("free")};right="a".str_eq("a").add("bad").with(){order=cat(order,"R");return("receiver")};return([left,right,order])}]==],"x",[==[["free","receiver","FR"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out=str_eq("a","b").add("bad").coalesce([]).with(){order=cat(order,"W");return(value.count())};return([out,order])}]==],"x",[==[[0,"W"]]==])
check_value("with_result_array",[==[Value:: I {order="";out=str_eq("a","b").with(){order=cat(order,"W");return(["ok"])}.first().uppercase();return([out,order])}]==],"x",[==[["OK","W"]]==])
check_value("all_canonical_free_with_guards",[==[Value:: I {order="";out=[str_eq("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ne("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_gt("b","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ge("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_lt("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_le("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_eq("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ne("a","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_gt("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_ge("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_lt("b","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},str_le("b","a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
check_value("all_short_receiver_with_guards",[==[Value:: I {order="";out=["a".str_eq("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ne("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"b".str_gt("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ge("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_lt("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_le("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_eq("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ne("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_gt("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"a".str_ge("b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"b".str_lt("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")},"b".str_le("a").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";left=str_eq("a","b").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};right="a".str_eq("a").take({order=cat(order,"B");1}).with(){order=cat(order,"X");return("ran")};return([left,right,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,null,""],"caller"]]==])
check_value("all_canonical_free_guards",[==[Value:: I {order="";out=[str_eq("a","a").take({order=cat(order,"A");1}),str_ne("a","b").take({order=cat(order,"A");1}),str_gt("b","a").take({order=cat(order,"A");1}),str_ge("a","a").take({order=cat(order,"A");1}),str_lt("a","b").take({order=cat(order,"A");1}),str_le("a","a").take({order=cat(order,"A");1}),str_eq("a","b").take({order=cat(order,"A");1}),str_ne("a","a").take({order=cat(order,"A");1}),str_gt("a","b").take({order=cat(order,"A");1}),str_ge("a","b").take({order=cat(order,"A");1}),str_lt("b","a").take({order=cat(order,"A");1}),str_le("b","a").take({order=cat(order,"A");1})];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null,null,null,null,null],""]]==])
do
  local actual=observe([==[Value:: I {return(str_eq({items="text";push(items,"x")},"a").coalesce("masked"))}]==],"x")
  io.stdout:write("LEXICAL_GUARD_ERROR needed_source_error ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[str_eq().take(1).with(){return("x")}]==],
  [==[str_eq("a").take(1).with(){return("x")}]==],
  [==[str_eq("a","a","a").take(1)]==],
  [==[str_eq(left:"a",right:"a").take(1)]==],
  [==[eq("a","a").take(1)]==],
  [==[==("a","a").take(1)]==],
  [==[num_eq(1,1).take(1).with(){return("x")}]==],
  [==[and(false).take(1).with(){return("x")}]==],
  [==["a".str_eq().with(){return("x")}]==],
  [==["a".str_eq("a","a").with(){return("x")}]==],
  [==["a".str_eq(right:"a").with(){return("x")}]==],
  [==[str_eq("a","a"){return("x")}]==],
  [==["a".str_eq("a"){return("x")}]==],
  [==[str_eq("a","a").map_leaves(){return(value)}]==],
  [==["a".str_eq("a").map_leaves(){return(value)}]==],
  [==[{|| return(str_eq("a","a").take(1).with(){return("x")}) }]==],
  [==[str_eq("a","a").custom_compare().with(){return("x")}]==],
  [==["a".str_eq("a").custom_compare().with(){return("x")}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==18,"all authored excluded lexical source shapes selected")
io.stdout:write("LEXICAL_GUARD_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("LEXICAL_GUARD_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("lexical source and prefix checks passed: ",checks,"\n")
