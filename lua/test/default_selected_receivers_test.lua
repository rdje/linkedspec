assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local function fixture(name)
  local file = assert(io.open("tests/fixtures/" .. name .. ".spec", "r"))
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
    "x", "default-selected-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "default-selected-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers(fixture("default_selected_receiver_values"),
  '["A-B","A-B","A-B","X:Y","KEPT",null,null,null,"A-B",null,1,1,3,"0!","A-B","SDJ",["a","b","c"],"KEPT","",["a","b"],{"a":"x","b":"y"},"X:Y"]')
check_consumers([=[Top:: I { return(["kept".coalesce_nonempty(["a"]).sorted(), "".coalesce_nonempty("kept").sorted(), "kept".coalesce_nonempty({"k":1}).sorted_values()]); }]=],
  '[null,null,null]')
check_consumers(fixture("coalesce_receiver_values"),
  '["first","CHOSEN","SELECTED","empty",0,false,null,"A","ABCDEF"]')
io.stdout:write("selected default receiver checks passed\n")
