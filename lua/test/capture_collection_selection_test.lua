-- TYPE-REFERENCE-BOOK.1.2.23.3.25.5 — safe readonly capture result checks.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/capture_collection_selection_values." .. extension, "r"))
  local source = file:read("*a"); file:close(); return source
end

local function check_selection(label, source, input, expected_json)
  local prepared, compiled = pcall(function()
    return l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  end)
  if not prepared then
    failures[#failures+1] = label .. " compile: " .. tostring(compiled)
    return
  end
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs({
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "capture-collection-selection.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "capture-collection-selection.spec")))()
      return parser.execute(input)
    end},
  }) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("CAPTURE_SELECTION_OBSERVATION ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end

check_selection("unchanged frozen target", fixture("spec"), "name=Alpha", fixture("json"))
check_selection("aliases with incompatible operands", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  order="";
  a=match_groups()[-1].with() {return(value)}.take({order=cat(order,"A");1});
  b=entry_named_map()["head"].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
  c=match_named_map()["value"].take({order=cat(order,"C");1});
  return([a,b,c,order]);
 }]=], "name=Alpha", '[[null,null,null,""]]')
check_selection("String kinds compaction static helpers", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>0)(?<empty>)(?<missing>x)?/
 /=/
 /(?<value>Alpha)(?<empty>)(?<missing>x)?/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  entry_groups={|| return(["shadow"]) };
  match_map={|| return({"value":"shadow"}) };
  return([entry_groups()[0],entry_groups()[1],entry_groups()[2].coalesce("missing"),entry_map()["empty"],match_groups()[-1],match_map()["value"],entry_named_map()["head"],match_named_map()["empty"]]);
 }]=], "0=Alpha", '[["0","","missing","","","Alpha","0",""]]')
check_selection("missing capture versus legacy counts", [=[Top:: I {
 thunk={|| return([false,["tail"]])};
 return([entry_groups()[0].count(),entry_map()["head"].count(),match_groups()[0].count(),match_map()["value"].count(),entry_named_map()["head"].count(),match_named_map()["value"].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),cursor_rest()[0].count(),flat([1])[9].count()]);
}]=], "x", '[null,null,null,null,null,null,false,"TAIL",0,0,0,0]')

if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("capture selection checks passed\n")
