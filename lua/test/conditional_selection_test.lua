-- TYPE-REFERENCE-BOOK.1.2.23.3.26.5 — safe inline conditional result checks.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")

local function routes(compiled)
  return {
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), "x").value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), "x", "conditional-selection.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "conditional-selection.spec")))()
      return parser.execute("x")
    end},
  }
end

local function compile(source)
  return l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
end

local function check_selection(label, source, expected_json)
  local prepared, compiled = pcall(compile, source)
  if not prepared then
    failures[#failures+1] = label .. " compile: " .. tostring(compiled)
    return
  end
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs(routes(compiled)) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("CONDITIONAL_SELECTION_OBSERVATION ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/conditional_selection_values." .. extension, "r"))
  local source = file:read("*a"); file:close(); return source
end

check_selection("unchanged frozen target", fixture("spec"), fixture("json"))
check_selection("with rejects incompatible operands", [=[Top:: I {
 order="";
 a=if(true,[false],[])[0].with() {return(value)}.take({order=cat(order,"A");1});
 b=switch("k",case("k",[[1]]))[0].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
 return([a,b,order]);
}]=], '[null,null,""]')
check_selection("lazy order and block local return", [=[Top:: I {
 order="";
 selected=if({order=cat(order,"C");false},["bad"],
  elseif({order=cat(order,"E");true},{order=cat(order,"T");return([{"items":["a","b"]}]);order="bad"}),
  else({order=cat(order,"F");["bad"]}))[0]["items"][-1].uppercase().cat({order=cat(order,"M");"!"});
 return([selected,order]);
}]=], '["B!","CETM"]')
check_selection("missing inline versus legacy bound flat and switch header counts", [=[Top:: I {
 thunk={|| return([false,["tail"]])};
 return([if(false,[1])[0].count(),switch("other",case("k",[1]))[0].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),flat([1])[9].count(),switch("k")[0].count()]);
}]=], '[null,null,false,"TAIL",0,0,0,0]')

local value = l.parse_action_expression('if(true,[1],[])[0]')
assert(value.receiver.name == "if")
assert(#value.receiver.args == 3)
assert(not value.receiver.trailing_block_arg)
local header = l.parse_action_expression('if(true)[0]')
assert(#header.receiver.args == 1)
local alias = l.parse_action_expression('i(false,[1])[0]')
assert((alias.receiver.source_method or alias.receiver.name) == "i")
local attached = l.parse_action_expression('if(true) {return([1])}[0]')
assert(attached.receiver.trailing_block_arg)
io.stdout:write("six native parsed source role checks passed\n")

for _, row in ipairs({
  {"if", 'if(true)[0]', "helper 'if' expects at least 2 positional arguments, got 1"},
  {"i", 'i(false,[1])[0]', "unsupported runtime helper 'i'"},
}) do
  local compiled = compile('Top:: I {return(' .. row[2] .. ')}')
  for _, route in ipairs(routes(compiled)) do
    local ok, failure = pcall(route[2])
    local valid = not ok
    if valid and route[1] == "native" then
      valid = l.is_runtime_interpreter_error(failure) and failure.helper_name == row[1]
      if row[1] == "if" then
        valid = valid and failure.code == "helper_arity_mismatch" and failure.actual_arity == 1
      else
        valid = valid and tostring(failure):find(row[3], 1, true)
      end
    elseif valid then
      local detail = failure.detail or ""
      valid = l.is_generated_source_error(failure) and detail:find(row[3], 1, true)
    end
    if not valid then failures[#failures+1] = "source error " .. row[1] .. " " .. route[1] .. ": " .. tostring(failure) end
    io.stdout:write("CONDITIONAL_SOURCE_ERROR ", row[1], " ", route[1], " ", tostring(failure), "\n")
  end
end

if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("conditional selection checks passed\n")
