-- TYPE-REFERENCE-BOOK.1.2.23.3.32.5 — safe immediate with-result reads.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
local checks = 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end
local function fixture(extension)
  local file = assert(io.open("tests/fixtures/with_result_selection_values." .. extension, "r"))
  local value = file:read("*a"); file:close(); return value
end
local function routes(source)
  local parsed = l.parse_spec_with_staged_user_function_definitions(source)
  local compiled = l.compile_spec(parsed)
  local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
  local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "with-result-selection.spec")))()
  return {
    {"native", function() return l.runtime_execute(l.runtime_engine(compiled), "x").value end},
    {"restored", function() return l.runtime_execute(l.runtime_engine(restored), "x").value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), "x", "with-result-selection.spec") end},
    {"fresh", function() return parser.execute("x") end},
  }
end
local function observe(source)
  local ok, prepared = pcall(routes, source)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value),runtime=l.is_runtime_interpreter_error(value),generated=l.is_generated_source_error(value)})
  end
  return result
end
local function check_value(label, source, expected_json)
  local actual = observe(source)
  local expected = json.encode(json.decode(expected_json))
  io.stdout:write("WITH_SELECTION_ACTUAL ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    verify(actual[route] ~= nil and actual[route].error == nil and json.encode(actual[route].value) == expected, label .. " " .. route)
  end
end
local roles = {
  {"nested_pure", [=[fn pure(text){return(with(text){return([uppercase(value)])}[0])}
Top:: I {value="outer";nested=with("outside"){return(with("inside"){return([value])}[0])};return([nested,value,pure("ok")]);}]=]},
  {"bound_final", [=[Top:: I {order="";cb={|item|return([item])};return([with("z",cb)[0],with("z",cb)[9].count(),with("z",cb)[0].take({order=cat(order,"B");1}),order]);}]=]},
  {"literal_final", [=[Top:: I {return([with("z",{|item|return([item])})[0],with("z",{|item|return([item])})[9].count()]);}]=]},
  {"callback_bodies", [=[fn apply(callback: codeblock){return(callback())}
Top:: I {cb={||return(with("x"){return(["yes"])}[0])};a=apply(){return(with("x"){return(["yes"])}[0])};return([cb(),a,"x".with(){return([false])}[0].copy()]);}]=]},
  {"malformed_role", [=[Top:: I {return(with("x","extra"){return([1])}[0]);}]=]},
  {"missing_source", [=[Top:: I {return(with(missing_source()){return([1])}[0].uppercase())}]=]},
  {"missing_body", [=[Top:: I {return(with("x"){return([missing()])}[0].uppercase())}]=]},
  {"function_state", [=[fn forbidden(){return(with("x"){return([entry_len()])}[0].uppercase())}
Top:: I {return(forbidden())}]=]},
}
check_value("frozen", fixture("spec"), fixture("json"))

local role_sources = {}
for _, role in ipairs(roles) do role_sources[role[1]] = role[2] end
check_value("nested_pure", role_sources.nested_pure, '["inside","outer","OK"]')
check_value("bound_final", role_sources.bound_final, '["z",0,[],"B"]')
check_value("literal_final", role_sources.literal_final, '["z",0]')
check_value("callback_bodies", role_sources.callback_bodies, '["yes","yes",false]')
check_value("legacy_bound_read", [=[Top:: I {
  thunk={|| return([false,["tail"]])};
  return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()]);
}]=], '[false,"TAIL",0,0]')
local function check_error(label, source, required)
  local actual = observe(source)
  io.stdout:write("WITH_SELECTION_ERROR ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " remains runtime diagnosed")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error ~= nil, label .. " " .. route .. " rejects")
    verify(row ~= nil and ((route == "native" or route == "restored") and row.runtime == true and row.generated == false or (route == "plan" or route == "fresh") and row.generated == true and row.runtime == false), label .. " " .. route .. " typed envelope")
    local valid = row ~= nil and row.error ~= nil
    for _, part in ipairs(required) do valid = valid and row.error:find(part, 1, true) ~= nil end
    verify(valid, label .. " " .. route .. " specific diagnostic")
  end
end
check_error("malformed_role", role_sources.malformed_role, {"helper 'with'", "expects 0 to 1 arguments", "got 2"})
check_error("missing_source", role_sources.missing_source, {"unsupported runtime helper", "missing_source"})
check_error("missing_body", role_sources.missing_body, {"unknown_helper", 'name="missing"'})
check_error("function_state", role_sources.function_state, {"parser-state helper", "entry_len"})
io.stdout:write("WITH_SELECTION_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("with selection checks passed: ", checks, "\n")
