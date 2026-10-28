-- TYPE-REFERENCE-BOOK.1.2.23.3.36.4 — safe outgoing-edge body candidates.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end
local function read_file(path)
  local file = assert(io.open(path, "r"))
  local value = file:read("*a")
  assert(file:close())
  return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json(
      "SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))
    ))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "active-edge-body.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "active-edge-body.spec") end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value)})
  end
  return result
end
local function check_value(label, source, input, expected_json)
  local actual = observe(source, input)
  local expected = json.encode(json.decode(expected_json))
  io.stdout:write("ACTIVE_EDGE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native", "restored", "plan", "fresh"}) do
    local value = actual[route]
    verify(value ~= nil and value.error == nil and json.encode(value.value) == expected, label .. " " .. route)
  end
end
local function carrier(head, action)
  return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>" .. head .. ")/\n /:/\n /(?<token>cat)/\n -> Value[2] {" .. action .. "}\n"
end

check_value("wildcard", carrier("..", 'return("BODY")'), "αβ:cat", '["BODY"]')
check_value("literal", carrier("αβ", 'return("BODY")'), "αβ:cat", '["BODY"]')
for _, mode in ipairs({"", "|"}) do
  local source = "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:" .. mode .. [[

 /H/
 /a/
 /a/
 -> Value[2] {return(2)}
 -> Value[1] {return(1)}
]]
  check_value("reverse" .. mode, source, "Ha", "[2]")
end
check_value("earliest", [[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /H/
 /b/
 /a/
 -> Value[1] {return("B")}
 -> Value[2] {return("A")}
]], "Hab", '["A"]')
check_value("cross_target", [[Top::
 /./
 -> Second {return("second")}
 -> First {return("first")}
First: /a/
Second: /a/
]], "a", '"second"')
check_value("no_eligible", [[Top::
 /./
 @capture_gaps
 -> Value {return("edge")}
 LS {return("wrong")}
 LX {return("miss")}
Value: /cat/
]], "x", '"miss"')
check_value("captures", carrier("..", [[
mark_match_start(begin);mark_match_end(finish);
return([match_text(),match_group(0),match_named(token),mark_pos(begin),mark_pos(finish),entry_named(head)])
]]), "αβ:cat", '[["cat","cat","cat",3,6,"αβ"]]')
check_value("boundary_catalog", [[Top:: I {return(capture_until_boundary("Landmark"))}
Landmark:
 /END/
 /!/
 -> Landmark[1] {return(1)}
]], "bodyEND!", '"body"')
local gap_source = carrier("..", "return([gap_text(),gap_span(),match_text()])")
gap_source = gap_source:gsub(" %-> Value%[2%]", " @capture_gaps\n -> Value[2]", 1)
check_value("gap_span", gap_source, "αβ:cat", '[[":",{"source_id":"input","start":2,"end":3,"provenance":"gap"},"cat"]]')
local contract = json.decode(read_file("capability_conformance/duplicate_regex_slot_identity_contract.json"))
for _, row in ipairs(contract.fixtures) do
  check_value(row.id, row.source, row.input, json.encode(row.expected_result))
end
check_value("seek", 'Top:: /x/ -> Top {return("hit")}\n', "prefix x", '"hit"')
check_value("consume", 'Top::AND /x/ -> Top {return("hit")}\n', "prefix x", "null")

local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(carrier("..", 'return("BODY")')))
verify(#compiled:rule("Value").regex_patterns == 3, "full catalog retained")
for _, generated in ipairs({false, true}) do
  local output = {}
  local options = {stdout_writer=function(line) output[#output + 1] = line end}
  local value
  if generated then
    value = l.execute_generated_parser_with_trace_v2(
      compiled, l.build_generated_rule_plan(compiled), "αβ:cat",
      l.trace_config_enabled(l.TRACE_HIGH), "active-edge-body.spec", options
    )
  else
    local trace = l.trace_emitter(l.trace_config_enabled(l.TRACE_HIGH), options)
    value = l.runtime_execute(l.runtime_engine(compiled), "αβ:cat", {trace=trace}).value
  end
  local selected = {}
  for _, line in ipairs(output) do
    if line:find("lua_runtime:regex_slot_selected", 1, true) and line:find("rule_label=Value ", 1, true) then
      selected[#selected + 1] = line
    end
  end
  io.stdout:write("ACTIVE_EDGE_TRACE ", json.encode(json.harray({generated=generated, value=value, slots=json.array(selected)})), "\n")
  verify(json.encode(value) == '["BODY"]', "trace value " .. tostring(generated))
  verify(#selected == 1, "one selected slot " .. tostring(generated))
  verify(#selected == 1 and selected[1]:find("target_rule=Value regex_index=2", 1, true) ~= nil, "written slot " .. tostring(generated))
end
io.stdout:write("ACTIVE_EDGE_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("active-edge body checks passed: ", checks, "\n")
