-- TYPE-REFERENCE-BOOK.1.2.23.3.30.5 — safe Number reader result controls.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function fixture(extension)
  local file = assert(io.open("tests/fixtures/entry_match_number_result_values." .. extension, "r"))
  local source = file:read("*a")
  file:close()
  return source
end
local function routes(source, input)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  return {
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "entry-match-number-results.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "entry-match-number-results.spec")))()
      return parser.execute(input)
    end},
  }
end
local function check(label, source, input, expected_json)
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs(routes(source, input)) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("NUMBER_READER ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end
local function action(body)
  return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {" .. body .. "}\n"
end
check("frozen target", fixture("spec"), "name=Alpha", fixture("json"))
check("absent lazy fallback", 'Top:: I {order="";return([match_len().coalesce({order=cat(order,"F");7}).add(1),order])}', "x", '[8,"F"]')
for _, route in ipairs(routes("fn forbidden(){return(entry_len())}\nTop:: I {return(forbidden())}", "x")) do
  local ok, actual = pcall(route[2])
  local text = tostring(actual)
  local valid = not ok and text:find("parser-state helper", 1, true) and text:find("entry_len", 1, true)
  if valid and route[1] == "native" then
    valid = l.is_runtime_interpreter_error(actual) and actual.helper_name == "entry_len"
  elseif valid then
    valid = l.is_generated_source_error(actual)
  end
  io.stdout:write("NUMBER_READER_FENCE ", route[1], " ", text, "\n")
  if not valid then failures[#failures+1] = "specific function fence " .. route[1] .. ": " .. text end
end
local legacy = action([=[order="";result=match_len().add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([match_len().set_key("k",1),entry_len().take(1),result,order]);]=])
-- Preserve independently observed direct roots separately from normalized results.
check("legacy roots and normalized guard", legacy, "name=Alpha", '[[5,[],null,""]]')

if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("entry match Number checks passed\n")
