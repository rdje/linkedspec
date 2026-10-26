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
    "x", "index-result-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "index-result-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers(fixture("index_result_receiver_values"),
  '[2,2,1,null,null,null,2,2,2,2,2,2,"1!","X",8,null,null,null,2,"SNA",["a","b","c","d"],null,"N",["a","b"],null,"SN",["a","b"],["zero","old"],null,null,0,["a","b"],{"a":"a","b":"b"}]')
check_consumers([=[Top:: I { return([].first().index_of("a").sorted()); }]=], 'null')
io.stdout:write("index result receiver checks passed\n")
