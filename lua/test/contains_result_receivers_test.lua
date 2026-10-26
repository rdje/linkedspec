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
    "x", "contains-result-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "contains-result-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end


check_consumers([[Top:: I { items=["a","b"]; raw=[contains(["a","b"],"a"),contains(["a","b"],"z"),contains([],"a"),contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([0],"0"),contains([false],0)]; order=""; value=contains(items,{order=cat(order,"O");items=["z"];"a"});missing=[].first(); missing_order=""; missing_value=contains(missing,{missing_order=cat(missing_order,"O");missing=["a"];"a"});return({"raw":raw,"snapshot_absent":[missing_value,missing_order,missing],"snapshot":[value,order,items],"text":[cat(contains(["a"],"z"),"!"),cat(coalesce_nonempty(contains(["a"],"z"),"late"),"!")]}) }]],
  '{"raw":[1,0,0,1,1,1,1,1,1],"snapshot":[1,"O",["z"]],"snapshot_absent":[0,"O",["a"]],"text":["0!","0!"]}')

io.stdout:write("contains producer controls passed\n")
check_consumers(fixture("contains_result_receiver_values", "spec"),
  fixture("contains_result_receiver_values", "text.json"))
io.stdout:write("contains result receiver checks passed\n")
