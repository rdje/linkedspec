assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/substring_optional_argument_values." .. extension, "r"))
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
    "x", "substring-arguments.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "substring-arguments.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: I { return([substr("abc"),substr("abc",true,true,"extra"),substr("abc",1,undef,"extra")]); }]=], '[null,"","bc"]')
io.stdout:write("legacy free substring arities passed\n")
check_consumers(fixture("spec"),fixture("json"))
io.stdout:write("substring optional argument reference passed\n")
