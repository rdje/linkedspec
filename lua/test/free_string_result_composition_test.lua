-- TYPE-REFERENCE-BOOK.1.2.23.3.62.5 — canonical free String result guards.
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
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "free-string-result-composition.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "free-string-result-composition.spec") end},
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
  io.stdout:write("FREE_STRING_VALUE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
check_value("primitive_values",[==[Value:: I {return([trim(" tail "),lowercase("TAIL"),uppercase("tail"),replace_substr("a-b","-",","),rm_prefix(0,"x"),rm_suffix(false,"x"),substr("head",1,2),cat("a","b")])}]==],"x",[==[["tail","tail","TAIL","a,b",0,false,"ea","ab"]]==])
check_value("compatible_values",[==[Value:: I {return([trim(" tail ").uppercase(),replace_substr("a-b","-",",").split(",").last().uppercase(),rm_prefix(0,"x").add(1),rm_suffix(false,"x").cat("!")])}]==],"x",[==[["TAIL","B",1,"0!"]]==])
check_value("free_container_guards",[==[Value:: I {order="";left=trim("tail").take({order=cat(order,"A");1});right=uppercase("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("receiver_container_guards",[==[Value:: I {order="";left="tail".trim().take({order=cat(order,"A");1});right="tail".uppercase().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([left,right,order])}]==],"x",[==[[null,null,""]]==])
check_value("bound_guarded_bridge",[==[Value:: I {order="";saved=trim("tail");out=saved.coalesce(undef).take({order=cat(order,"A");1});return([out,saved,order])}]==],"x",[==[[null,"tail",""]]==])
check_value("valid_null_with",[==[Value:: I {order="";out=trim(undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}]==],"x",[==[["recovered","W"]]==])
check_value("guard_before_with",[==[Value:: I {order="";out=trim({order=cat(order,"S");return("tail")}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,"S"]]==])
check_value("source_order_snapshot",[==[Value:: I {value=" tail ";order="";out=replace_substr({order=cat(order,"S");return(value)},{value="other";order=cat(order,"O");" "},{order=cat(order,"N");"_"}).cat({order=cat(order,"C");"!"});return([out,value,order])}]==],"x",[==[["_tail_!","other","SONC"]]==])
check_value("all_free_guard_sources",[==[Value:: I {order="";out=[trim("tail").take({order=cat(order,"A");1}),lowercase("TAIL").take({order=cat(order,"A");1}),uppercase("tail").take({order=cat(order,"A");1}),replace_substr("a-b","-",",").take({order=cat(order,"A");1}),rm_prefix(0,"x").take({order=cat(order,"A");1}),rm_suffix(false,"x").take({order=cat(order,"A");1}),substr("tail",0,1).take({order=cat(order,"A");1}),cat("t","ail").take({order=cat(order,"A");1})];return([out,order])}]==],"x",[==[[[null,null,null,null,null,null,null,null],""]]==])
check_value("function_scope",[==[fn build(){order="";out=trim("tail").take({order=cat(order,"A");1});return([out,order])}
Value:: I {value="caller";return([build(),value])}]==],"x",[==[[[null,""],"caller"]]==])
check_value("free_bridge_rejection",[==[Value:: I {order="";out=trim(" a,b ").split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x",[==[[null,""]]==])
check_value("valid_empty_bridge_with",[==[Value:: I {order="";out=trim(" a,b ").split(",").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}]==],"x",[==[[[0,"tail"],"W"]]==])
check_value("valid_null_after_bridge_with",[==[Value:: I {order="";out=trim("").split(",").take(0).first().with(){order=cat(order,"W");return("recovered")};return([out,order])}]==],"x",[==[["recovered","W"]]==])
check_value("legacy_named_empty_fallback",[==[Value:: I {items="text";return([take(items,1),sorted_values(items)])}]==],"x",[==[[[],[]]]==])
check_value("numeric_identity_remains_an_array_index",[==[Value:: I {slots=["old"];index=rm_prefix(0,"x").copy();slots[index]="updated";return([index,slots,rm_suffix(false,"x").copy()])}]==],"x",[==[[0,["updated"],false]]==])
do
  local actual=observe([==[Value:: I {return(trim({items="text";push(items,"x")}).coalesce("masked"))}]==],"x")
  io.stdout:write("FREE_STRING_ERROR ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"needed source compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    verify(row~=nil and row.error~=nil and row.error:find("binding_kind_mismatch",1,true)~=nil,route .. " needed source error")
  end
end
do
  local actual=observe([==[Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}]==],"x")
  io.stdout:write("FREE_STRING_CONTEXT ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,"receiver-only context compiles independently")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    verify(actual[route]~=nil and json.encode(actual[route])==json.encode(actual.native),route .. " independent context agrees")
  end
end
local shapes=json.array({})
for _,source in ipairs({
  [==[trim().take(1)]==],
  [==[trim("tail","extra").take(1)]==],
  [==[cat("tail").take(1)]==],
  [==[cat().take(1)]==],
  [==[substr("tail",0,1,"g").take(1)]==],
  [==[trim(first:"tail").take(1)]==],
  [==[trim("tail"){return("x")}.take(1)]==],
  [==[custom_string("tail").take(1)]==],
  [==[{|| return(trim("tail").take(1)) }]==],
}) do
  local ok,result=pcall(l.parse_action_expression,source)
  shapes[#shapes+1]=ok and json.harray({source=source,ast=l.action_ast.to_json(result)}) or
    json.harray({source=source,error=tostring(result)})
end
verify(#shapes==9,"all authored excluded source shapes selected")
io.stdout:write("FREE_STRING_SHAPES ",json.encode(shapes),"\n")
io.stdout:write("FREE_STRING_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("free String result checks passed: ",checks,"\n")
