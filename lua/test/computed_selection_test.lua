-- TYPE-REFERENCE-BOOK.1.2.23.3.24.5 — safe computed selection checks.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/src/linkedspec/action_parser.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/computed_selection_values." .. extension, "r"))
  local source = file:read("*a"); file:close(); return source
end

local function check_selection(label, source, expected_json)
  local prepared, compiled = pcall(function()
    return l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  end)
  if not prepared then
    failures[#failures+1] = label .. " compile: " .. tostring(compiled)
    return
  end
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs({
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), "x").value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), "x", "computed-selection.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "computed-selection.spec")))()
      return parser.execute("x")
    end},
  }) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("COMPUTED_SELECTION_OBSERVATION ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end

assert(l.parse_action_expression('"x".?').kind == "raw_perl")
assert(l.parse_action_expression('@host.trim()').receiver.kind == "raw_perl")
assert(l.parse_action_expression('items[0]').kind == "indexed_var")
assert(l.parse_action_expression('(array("a"))[0]').kind == "raw_perl")
local selected = l.parse_action_expression('["🙂","b"][-1].uppercase()').receiver
assert(selected.kind == "value_access" and selected.source == '["🙂","b"][-1]')
assert(selected.source_span.start == 0 and selected.source_span["end"] == 13)

check_selection("unchanged full target", fixture("spec"), fixture("json"))
check_selection("existing data-call kind guards", [=[Top:: I {
  order="";
  a=array(false)[0].take({order=cat(order,"A");1});
  b=array([1])[0].set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
  c={order=cat(order,"S");"a,b"}.split(",").copy({order=cat(order,"A");1});
  return([a,b,c,order]);
}]=], '[null,null,null,""]')
check_selection("function scopes snapshots repeated bridges", [=[fn echo(value) {return(value)}
fn select(text) {position=-1;return(echo(text.split(","))[position].uppercase())}
Top:: I {
  position=9;order="";source=["old","tail"];
  selected=echo({order=cat(order,"S");source})[{order=cat(order,"I");source=["new"];-1}].uppercase().cat({order=cat(order,"C");"!"});
  return([selected,order,source,select("a,b"),position,
    [undef][0].coalesce([{"items":["a","b"]}])[0]["items"][-1].uppercase()]);
}]=], '["TAIL!","SIC",["new"],"B",9,"B"]')
check_selection("scoped with kind guards", [=[Top:: I {
  order="";
  a=array(false)[0].with() {return(value)}.take({order=cat(order,"A");1});
  b=array([2,1])[0].with() {return(value)}.sorted()[0].add(2);
  return([a,b,order]);
}]=], '[null,3,""]')
check_selection("existing bound-call result policy", [=[Top:: I {
  thunk={|| return([false,["tail"]])};
  return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()]);
}]=], '[false,"TAIL",0,0]')
check_selection("regex split index Unicode String", [=[Top:: I {
  return(["αXβ".split(/[x]/i)[-1].uppercase(),split("aXb",/[x]/i)[1].uppercase()]);
}]=], '["Β","B"]')

if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("computed selection checks passed\n")
