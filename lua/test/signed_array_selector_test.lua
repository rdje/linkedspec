assert(loadfile("lua/src/linkedspec/interpreter.lua"))
local l = require("linkedspec")
local json = l.json

local function compile(action)
  return l.compile_spec(l.parse_spec_with_staged_user_function_definitions(
    "Top::\n /x/\n E { " .. action .. " }\n"
  ))
end

local function same(actual, expected)
  assert(json.encode(actual) == json.encode(json.decode(expected)),
    "expected " .. expected .. ", got " .. json.encode(actual))
end

local cases = {
  {"items = [10,20,30]; return([items[-1],items[-2],items[-3],items[-4]])", "[30,20,10,null]"},
  {"pick = {|items| return(items[-1]) }; return(pick([10,20,30]))", "30"},
  {"items = [10,20,30]; saved = (items[-2] = 99); items[0] = 7; return([items,saved])",
    "[[7,99,30],[10,99,30]]"},
  {'cb = {|| document = {"rows":[[1],[2,3]]}; document["rows"][-1][-2] = 99; return(document) }; return(cb())',
    '{"rows":[[1],[99,3]]}'},
  {'items = [10]; items[1] = 20; keys = {"-1":7}; keys["-1"] = 8; return([items,keys["-1"]])',
    '[[10,20],8]'},
  {'items = [10,20,30]; index = "-1"; return([items[-1.0],items[index]])', '[30,null]'},
  {"items = [10,20]; items[-1] = { items[2] = 30; 99 }; return(items)", "[10,20,99]"},
  {'make = {|| return([10,20,30]) }; return([make()[-1],make()[-4],make()[-1.5],make()["-1"]])',
    '[30,null,null,null]'},
}

for _, case in ipairs(cases) do
  local compiled = compile(case[1])
  same(l.runtime_parse(l.runtime_engine(compiled), "x").value, case[2])
  same(l.execute_generated_parser_v2(
    compiled, l.build_generated_rule_plan(compiled), "x", "signed-array.spec"
  ), case[2])
end

local loader = loadstring or load
local generated = assert(loader(l.emit_lua_source_v2(compile(cases[4][1]), "signed-array.spec")))()
same(generated.execute("x"), cases[4][2])

local function diagnostic(action)
  local ok, failure = pcall(function()
    return l.runtime_parse(l.runtime_engine(compile(action)), "x")
  end)
  assert(not ok and type(failure) == "table", "expected typed write failure")
  return l.interpreter.to_json(failure.diagnostic)
end

local underflow = diagnostic("items = [[1]]; items[-1][-2] = 9")
assert(underflow.code == "nested_write_array_underflow")
assert(underflow.index == -2 and underflow.length == 1 and underflow.resolved_index == -1)
assert(underflow.segment_index == 1 and underflow.source_span.unit == "unicode_scalar")
same(underflow.path, "[-1]")
assert(underflow.detail ==
  "nested write segment 1 for binding 'items' cannot select array index -2 at length 1 (resolved index -1)")

for _, action in ipairs({
  "missing[-1] = 9",
  'document = {}; document["rows"][-1] = 9',
  "items = []; items[0][-1] = 9",
}) do
  local missing = diagnostic(action)
  assert(missing.code == "nested_write_segment_invalid" and missing.reason == "negative_integer")
end
assert(diagnostic("items = undef; items[-1] = 9").code == "nested_write_kind_conflict")
local invalid = diagnostic("items = [1]; items[-2][true] = 9")
assert(invalid.code == "nested_write_segment_invalid" and invalid.segment_index == 1)
io.stdout:write("signed array selectors: targeted checks passed\n")
