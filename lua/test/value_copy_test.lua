-- TYPE-REFERENCE-BOOK.1.2.1.4.2.2.5 — ADR0138 value copying, safe patterns only.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/value_copy_values." .. extension, "r"))
  local source = file:read("*a"); file:close(); return source
end

local function check_copy(label, source, expected_json, input)
  input = input or "x"
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs({
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "value-copy.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "value-copy.spec")))()
      return parser.execute(input)
    end},
  }) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("COPY_OBSERVATION ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end

check_copy("shared primitive/source/scope flows", fixture("spec"), fixture("json"))
check_copy("copied container kind before operands", [=[Top:: I {
  order="";
  a=copy({"a":1}).take({order=cat(order,"A");1});
  b=copy([1]).set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
  return([a,b,order]);
}]=], '[null,null,""]')
check_copy("method shape before effects", [=[Top:: I {
  order="";
  a={order=cat(order,"S");false}.copy({order=cat(order,"A");1});
  b={order=cat(order,"R");[1]}.copy(fail("must-not-run"));
  return([a,b,order]);
}]=], '[null,null,""]')
check_copy("legacy accumulator and text", 'Top::\n -> Item .push\n LX.return([copy(Top),copy("Top")])\n\nItem: /x/ I.return("x")\n', '[["x","x"],"Top"]', "xx")

if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("value copy checks passed\n")
