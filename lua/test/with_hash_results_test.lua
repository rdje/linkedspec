-- TYPE-REFERENCE-BOOK.1.2.23.3.31.5 — safe ordinary with result controls.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function fixture(extension)
  local file = assert(io.open("tests/fixtures/with_hash_result_values." .. extension, "r"))
  local source = file:read("*a")
  file:close()
  return source
end
local function routes(source, input)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  return {
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "with-hash-results.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "with-hash-results.spec")))()
      return parser.execute(input)
    end},
  }
end
local function check(label, source, input, expected_json)
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs(routes(source, input)) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("WITH_RESULT ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end
local function action(body)
  return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {" .. body .. "}\n"
end
check("frozen target", fixture("spec"), "name=Alpha", fixture("json"))
check("helper and receiver actual kinds", action([=[
order="";value="outer";
a={order=cat(order,"S");"source"}.with(){order=cat(order,"W");return(3)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
b="source".with(){return("text")}.take({order=cat(order,"A");1});
c="source".with(){return(["a","b"])}.last().uppercase();
d="source".with(){return(false)}.coalesce({order=cat(order,"F");true});
e="source".with(){return(null)}.coalesce({order=cat(order,"N");7}).add(1);
f=with("source"){return(3)}.set_key({order=cat(order,"J");"k"},{order=cat(order,"L");1});
g=with("source"){return("text")}.take({order=cat(order,"T");1});
return([a,b,c,d,e,f,g,order,value]);
]=]), "name=Alpha", '[[null,null,"B",false,8,null,null,"SWN","outer"]]')
check("pure function scoped value", 'fn pure(text){return(text.with(){return({"n":[value.uppercase()]})}.sorted_values().first().first())}\nTop:: I {return(pure("ok"))}', "x", '"OK"')
check("distinct nested with scopes", action([=[
value="outer";order="";
result="outside".with(){inner="inside".with(){order=cat(order,"I");return({"k":[value]})}.sorted_values().first().first();order=cat(order,"O");return({"k":[value,inner]});}.sorted_values().first();
return([result,value,order]);
]=]), "name=Alpha", '[[["outside","inside"],"outer","IO"]]')
for _, route in ipairs(routes('fn forbidden(){return("x".with(){return({"n":[entry_len()]})}.sorted_values().first()[0].uppercase())}\nTop:: I {return(forbidden())}', "x")) do
  local ok, actual = pcall(route[2])
  local text = tostring(actual)
  local valid = not ok and text:find("parser-state helper", 1, true) and text:find("entry_len", 1, true)
  if valid and route[1] == "native" then
    valid = l.is_runtime_interpreter_error(actual) and actual.helper_name == "entry_len"
  elseif valid then
    valid = l.is_generated_source_error(actual)
  end
  io.stdout:write("WITH_RESULT_FENCE ", route[1], " ", text, "\n")
  if not valid then failures[#failures+1] = "specific function fence " .. route[1] .. ": " .. text end
end

if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("ordinary with checks passed\n")
