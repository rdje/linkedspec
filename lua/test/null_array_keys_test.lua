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
    "x", "null-array-keys.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "null-array-keys.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

local failures = {}
local function check_case(name, source, expected)
  local ok, failure = pcall(check_consumers, source, expected)
  if ok then io.stdout:write(name .. " passed\n")
  else failures[#failures + 1] = name .. ": " .. tostring(failure) end
end

check_case("defined projections and free defaults", [=[Top:: I { return({"membership":[contains([[]],""),contains([{}],""),contains([2],"2"),contains([false],0)],"indexes":[index_of([[]],""),index_of([{}],""),index_of([2],"2"),index_of([false],0)],"unique":uniq([[],"",{},2,"2",false,0]),"missing":[contains([undef]),index_of([undef])]}); }]=],
  '{"membership":[1,1,1,1],"indexes":[0,0,0,0],"unique":[[],2,false],"missing":[0,null]}')
check_case("null versus defined projection", [=[Top:: I { return([contains([[]],undef),contains([undef],[]),index_of([[]],undef),index_of([undef],[]),uniq([[],undef,""])]); }]=],
  '[0,0,null,null,[[],null]]')
check_case("shared null Array keys", fixture("null_array_key_values", "spec"),
  fixture("null_array_key_values", "json"))
assert(#failures == 0, table.concat(failures, "\n"))
io.stdout:write("null Array key checks passed\n")
