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
    "x", "numeric-comparison-results.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "numeric-comparison-results.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: I { raw=[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)];boundaries=[num_eq("02","2"),num_eq("-.5",-0.5),num_eq(undef,0),num_eq(false,0),num_eq(true,1),num_eq("",0),num_eq("x",0),num_eq([],0),num_eq({},0),num_eq(2),num_eq(2,2,2)];aliases=[eq(2,2),ne(2,2),gt(2,1),ge(2,2),lt(2,3),le(2,2),==(2,2),!=(2,2),>(2,1),>=(2,2),<(2,3),<=(2,2)];nested=[cat(num_eq(2,2),"!"),cat(coalesce_nonempty(num_eq(2,3),"late"),"!"),num_add(num_eq(2,3),2),uppercase(last(split(cat(num_eq(2,2),",x"),",")))];source=2;order="";effected=cat(num_eq({order=cat(order,"S");source},{order=cat(order,"O");source=3;2}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"boundaries":boundaries,"aliases":aliases,"nested":nested,"effected":effected,"order":order,"source":source}); }]=],
  [=[{"raw":[1,1,1,1,1,1,0,0,0,0,0,0],"boundaries":[1,1,null,null,null,null,null,null,null,null,null],"aliases":[1,0,1,1,1,1,1,0,1,1,1,1],"nested":["1!","0!",2,"X"],"effected":"1!","order":"SOC","source":null}]=])
io.stdout:write("numeric comparison producer controls passed\n")
check_consumers(fixture("numeric_comparison_result_receiver_values", "spec"),
  fixture("numeric_comparison_result_receiver_values", "json"))
check_consumers([=[Top:: I { score=2;values=["zero","one"];values[score.eq(2)]="updated";return(values) }]=], '["zero","updated"]')
io.stdout:write("numeric comparison result checks passed\n")
