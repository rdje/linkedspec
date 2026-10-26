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
    "x", "scalar-arithmetic-results.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "scalar-arithmetic-results.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: I { raw=[num_abs(-3),num_floor(3.7),num_ceil(3.2),num_round(2.5),num_add(2,3),num_sub(5,2),num_mul(2,3),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(8,3),num_max(2,5)];aliases=[abs(-3),floor(3.7),ceil(3.2),round(2.5),add(2,3),sub(5,2),mul(2,3),div(7,2),mod(7,3),clamp(12,0,10),min(8,3),max(2,5)];symbols=[+(2,3),-(5,2),*(2,3),/(7,2),%(7,3)];invalid=[num_div(2,0),num_mod(2.5,2),num_clamp(2,3,1),num_add(false,1),num_add(undef,1),num_add("x",1),num_add([],1),num_add({},1)];text=[cat(num_add(2,3),"!"),cat(coalesce_nonempty(num_add(0,0),"late"),"!"),num_add(coalesce_nonempty(num_div(2,0),7),1),num_add("-.5",1)];source=2;order="";effected=cat(num_add({order=cat(order,"S");source},{order=cat(order,"O");source=9;3}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"aliases":aliases,"symbols":symbols,"invalid":invalid,"text":text,"effected":effected,"order":order,"source":source}); }]=],
  [=[{"raw":[3,3,4,3,5,3,6,3.5,1,10,3,5],"aliases":[3,3,4,3,5,3,6,3.5,1,10,3,5],"symbols":[5,3,6,3.5,1],"invalid":[null,null,null,null,null,null,null,null],"text":["5!","0!",8,0.5],"effected":"5!","order":"SOC","source":null}]=])
io.stdout:write("scalar arithmetic producer controls passed\n")
check_consumers(fixture("scalar_arithmetic_result_receiver_values", "spec"),
  fixture("scalar_arithmetic_result_receiver_values", "json"))
check_consumers([=[Top:: I { values=["zero","one","two","three"];values[2.add(1)]="first";values[8.min("3")]="updated";return(values) }]=], '["zero","one","two","updated"]')
check_consumers([=[Top:: I { return([" 2 ".trim().add(3).cat("!")," 2 ".trim().eq(2).cat("!")," X ".trim().eq(2).coalesce_nonempty(7).add(1)]) }]=], '["5!","1!",8]')
io.stdout:write("scalar arithmetic result checks passed\n")
