-- TYPE-REFERENCE-BOOK.1.2.23.3.62.6.5 — canonical receiver String-prefix bridge guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "receiver-string-bridge-guards.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "receiver-string-bridge-guards.spec") end},
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
  io.stdout:write("RECEIVER_BRIDGE_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("reject_bridge_with",[==[Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("reject_bridge_without_with",[==[Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,order])}]==],"x",[==[[null,""]]==])
check_value("source_once",[==[Value:: I {order="";out={order=cat(order,"S");return(" a,b ")}.trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("valid_selected_with",[==[Value:: I {order="";out=" a,b ".trim().split(",").last().with(){order=cat(order,"W");return(value.uppercase())};return([out,order])}]==],"x",[==[["B","W"]]==])
check_value("valid_empty_with",[==[Value:: I {order="";out="a".trim().split(",").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}]==],"x",[==[[[0,"tail"],"W"]]==])
check_value("valid_null_with",[==[Value:: I {order="";out="".trim().split(",").take(0).first().with(){order=cat(order,"W");return("recovered")};return([out,order])}]==],"x",[==[["recovered","W"]]==])
check_value("all_eight_prefixes",[==[Value:: I {order="";out=[" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"A,B".lowercase().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a,b".uppercase().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a-b".replace_substr("-",",").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"prefixa,b".rm_prefix("prefix").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a,bsuffix".rm_suffix("suffix").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a,b!".substr(0,3).split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")},"a".cat(",b").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")}];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";out="a,b".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,""],"caller"]]==])
check_value("direct_rejection_with",[==[Value:: I {order="";out="tail".trim().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("primitive_values",[==[Value:: I {return([trim(" tail "),lowercase("TAIL"),uppercase("tail"),replace_substr("a-b","-",","),rm_prefix(0,"x"),rm_suffix(false,"x"),substr("head",1,2),cat("a","b")])}]==],"x",[==[["tail","tail","TAIL","a,b",0,false,"ea","ab"]]==])
check_value("compatible_values",[==[Value:: I {return([trim(" tail ").uppercase(),replace_substr("a-b","-",",").split(",").last().uppercase(),rm_prefix(0,"x").add(1),rm_suffix(false,"x").cat("!")])}]==],"x",[==[["TAIL","B",1,"0!"]]==])
check_value("receiver_numeric_identity_remains_an_array_index",[==[Value:: I {slots=["old"];index=0.rm_prefix("x").copy();slots[index]="updated";return([index,slots,false.rm_suffix("x").copy()])}]==],"x",[==[[0,["updated"],false]]==])
do
  local actual=observe([==[Value:: I {return({items="text";push(items,"x")}.trim().split(",").with(){return("masked")})}]==],"x")
  io.stdout:write("RECEIVER_BRIDGE_ERROR ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==["tail".trim("extra").split(",").set_key("k",1).with(){return("x")}]==],
  [==["tail".cat().with(){return("x")}]==],
  [==["tail".substr(0,1,2).with(){return("x")}]==],
  [==["tail".trim(first:"extra").with(){return("x")}]==],
  [==["tail".custom_string().with(){return("x")}]==],
  [==["tail".trim().map_leaves(){return(value)}]==],
  [==[{|| return("tail".trim().split(",").set_key("k",1).with(){return("x")}) }]==],
  [==["tail".substr(/a/,"x","g")]==],
  [==["tail".trim(){return("x")}]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==9,"all authored excluded receiver source shapes selected")
io.stdout:write("RECEIVER_BRIDGE_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("RECEIVER_BRIDGE_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("receiver String bridge checks passed: ",checks,"\n")
