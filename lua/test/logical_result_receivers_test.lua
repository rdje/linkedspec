assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local function fixture(name, extension)
  local file = assert(io.open("tests/fixtures/" .. name .. "." .. extension, "r"))
  local source = file:read("*a")
  file:close()
  return source
end

local function check_consumers(source, expected_json)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local expected = json.encode(json.decode(expected_json))
  local function same(value, route)
    local actual = json.encode(value)
    assert(actual == expected, route .. ": expected " .. expected .. ", got " .. actual)
  end
  same(l.runtime_parse(l.runtime_engine(compiled), "x").value, "native")
  same(l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled),
    "x", "logical-result-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "logical-result-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: I { raw=[and(true),and(false),or(false,true),or(false,0),not(false),not(true)];nested=[cat(and(true),"!"),cat(and(false),"!"),cat(or(false,true),"!"),cat(or(false,0),"!"),cat(not(false),"!"),cat(not(true),"!")];truthiness=[and("0"),or("false"),not([]),not({}),not([undef]),not({"a":undef})];numeric=[num_add(and(true),1),num_add(or(false),1)];source=true;order="";effected=cat(and({order=cat(order,"L");source},{order=cat(order,"R");source=false;false}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"nested":nested,"truthiness":truthiness,"numeric":numeric,"effected":effected,"order":order,"source":source}); }]=],
  [=[{"raw":[true,false,true,false,true,false],"nested":["1!","0!","1!","0!","1!","0!"],"truthiness":[true,true,true,true,false,false],"numeric":[null,null],"effected":"0!","order":"LRC","source":null}]=])
io.stdout:write("logical Boolean producer controls passed\n")
for _, row in ipairs({
  {"and",0,"and()"},{"or",0,"or()"},{"not",0,"not()"},
  {"not",2,[=[not({fail("must-not-run")},{fail("must-not-run")})]=]},
  {"not",2,[=[not({print("must-not-run");true},{print("must-not-run");false})]=]},
}) do
  local source='Top:: I { return('..row[3]..'.cat("!")) }'
  local compiled=l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local ok, failure=pcall(function() return l.runtime_parse(l.runtime_engine(compiled),"x") end)
  assert(not ok and l.is_runtime_interpreter_error(failure),"typed source error")
  assert(failure.code=="helper_arity_mismatch" and failure.helper_name==row[1] and failure.actual_arity==row[2],"source arity fields")
  local diagnostic=l.interpreter.to_json(failure.diagnostic)
  assert(diagnostic.code=="helper_arity_mismatch" and diagnostic.rule_label=="Top","source diagnostic")
  local generated=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"logical-result-receivers.spec")))()
  for _, operation in ipairs({
    function() return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","logical-result-receivers.spec") end,
    function() return generated.execute("x") end,
  }) do
    local succeeded, error=pcall(operation)
    assert(not succeeded and l.is_generated_source_error(error),"typed generated source error")
    local detail=error.detail or ""
    assert(detail:find("helper_arity_mismatch",1,true),detail)
    assert(detail:find("helper_name="..row[1],1,true),detail)
    assert(detail:find("actual_arity="..row[2],1,true),detail)
  end
end
io.stdout:write("logical source error controls passed\n")
for _, name in ipairs({"logical_result_receiver_values","logical_rejected_consumer_effects"}) do
  check_consumers(fixture(name,"spec"),fixture(name,"json"))
end
check_consumers([=[Top:: I { return([[and(true)].first().sorted(),{or(false)}.sorted(),true.sorted()]) }]=], '[null,null,null]')
local file=assert(io.open("capability_conformance/logical_helper_contract.json","r"))
local contract=json.decode(file:read("*a"));file:close()
for _, name in ipairs({"values","effects","receiver_and_lazy_control"}) do
  local row=contract.fixtures[name]
  check_consumers(row.spec_source,json.encode(row.expected))
end
io.stdout:write("logical Boolean result and direct neutral checks passed\n")
