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
    "x", "string-comparison-result-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "string-comparison-result-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end


check_consumers([[Top:: I { word="abc"; zero_text="0"; raw=[str_eq(word,"abc"),str_ne(word,"z"),str_gt(word,"aaa"),str_ge(word,"abc"),str_lt(word,"zzz"),str_le(word,"abc"),str_eq(word,"z"),str_ne(word,"abc"),str_gt(word,"zzz"),str_ge(word,"zzz"),str_lt(word,"aaa"),str_le(word,"aaa")]; order=""; null_result=str_eq({order=cat(order,"S");undef},{order=cat(order,"O");"a"});return({"raw":raw,"boundaries":[str_eq(undef,""),str_eq("",undef),str_eq("",""),str_eq("0",zero_text),str_eq(zero_text,"0")],"text":[cat(str_eq("a","b"),"!"),cat(coalesce_nonempty(str_eq("a","b"),"late"),"!")],"null_result":null_result,"order":order}) }]],
  '{"raw":[true,true,true,true,true,true,false,false,false,false,false,false],"boundaries":[null,null,true,true,true],"text":["0!","0!"],"null_result":null,"order":"SO"}')

io.stdout:write("comparison producer controls passed\n")
check_consumers(fixture("string_comparison_result_receiver_values", "spec"),
  fixture("string_comparison_result_receiver_values", "null.json"))
io.stdout:write("comparison result receiver checks passed\n")
