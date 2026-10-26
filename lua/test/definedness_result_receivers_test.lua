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
    "x", "definedness-result-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "definedness-result-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end


check_consumers([[Top:: I { return([is_defined([].first()),is_undefined([].first()),is_defined(""),is_defined(false),is_defined(0),is_defined([]),is_defined({}),cat(is_defined([].first()),"!"),coalesce_nonempty(is_defined([].first()),"late"),true.is_defined(),false.is_defined(),undef.is_undefined()]) }]],
  '[false,true,true,true,true,true,true,"0!",false,true,true,true]')

io.stdout:write("definedness producer controls passed\n")
check_consumers(fixture("definedness_result_receiver_values", "spec"),
  fixture("definedness_result_receiver_values", "json"))
io.stdout:write("definedness result receiver checks passed\n")
