-- TYPE-REFERENCE-BOOK.1.2.23.3.53.5 — structural boundary String composition.
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
local function fixture(extension)
  local file = assert(io.open("tests/fixtures/boundary_capture_fluent_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "boundary-capture-fluent.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "boundary-capture-fluent.spec") end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value),runtime=l.is_runtime_interpreter_error(value),generated=l.is_generated_source_error(value),helper_name=type(value)=="table" and value.helper_name or nil})
  end
  return result
end
local function check_value(label, source, input, expected_json)
  local actual = observe(source, input)
  local expected = json.encode(json.decode(expected_json))
  io.stdout:write("BOUNDARY_CAPTURE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "x")
  io.stdout:write("BOUNDARY_CAPTURE_FENCE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " remains runtime diagnosed")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    local native = route == "native" or route == "restored"
    verify(row ~= nil and row.error ~= nil, label .. " " .. route .. " rejects")
    verify(row ~= nil and row.runtime == native and row.generated == (not native), label .. " " .. route .. " typed envelope")
    local message = row and row.error
    local specific = message ~= nil and
      message:find("parser-state helper", 1, true) ~= nil and
      message:find("'" .. helper .. "'", 1, true) ~= nil and
      message:find("not supported in user functions", 1, true) ~= nil
    verify(specific and (not native or row.helper_name == helper),
      label .. " " .. route .. " authored helper diagnostic")
  end
end
local function boundary_source(body, endpattern)
  return "Top::\n I {" .. body .. "}\nEnd:OR{1,1}\n /" .. (endpattern or "END") .. "/\nFar:OR{1,1}\n /TAIL/\n"
end
check_value("shared", fixture("spec"), "αβ:ENDTAIL", fixture("json"))
for _, item in ipairs({
  {"primitive",[=[return([capture_until_boundary(End),cursor_pos(),capture_slice_pos()])]=], [=[["\u03b1\u03b2:",3,0]]=]},
  {"bound",[=[part=capture_until_boundary(End);return([part.coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])]=], [=[["\u03b1\u03b2:!",3,0]]=]},
  {"direct",[=[return([capture_until_boundary(End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])]=], [=[["\u03b1\u03b2:!",3,0]]=]},
  {"number",[=[return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])]=], [=[[4,3,0]]=]},
}) do
  check_value(item[1], boundary_source(item[2]), "αβ:ENDTAIL", item[3])
end
check_value("defined_empty", boundary_source([=[first=capture_until_boundary(End);order="";empty=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");return([first,empty,cursor_pos(),capture_slice_pos(),order])]=]),
  "αβ:ENDTAIL", [=[["\u03b1\u03b2:","!",3,0,""]]=])
check_value("unresolved", boundary_source([=[return([capture_until_boundary(Missing).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])]=]),
  "αβ:ENDTAIL", [=[["M!",0,0]]=])
check_value("valid_no_later", boundary_source([=[return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])]=],"ZZZ"),
  "αβ:ENDTAIL", [=[[11,10,0]]=])
check_value("quoted_comma_atom", boundary_source([=[return([capture_until_boundary("a,b,c",End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])]=]) .. "\nb:OR{1,1}\n /αβ/\n",
  "αβ:ENDTAIL", [=[["\u03b1\u03b2:!",3,0]]=])
check_value("earliest", boundary_source([=[return([capture_until_boundary(Far,End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])]=]),
  "αβ:ENDTAIL", [=[["\u03b1\u03b2:!",3,0]]=])
function_fence("pure_function", 'fn forbidden(){return(capture_until_boundary(End).coalesce("M").cat("!"))} ' .. boundary_source("return(forbidden())"), "capture_until_boundary")
check_value("literal_callback", boundary_source([=[cb={||return(capture_until_boundary(End).coalesce("M").cat("!"))};out=cb();return([out,cursor_pos(),capture_slice_pos()])]=]),
  "αβ:ENDTAIL", [=[["\u03b1\u03b2:!",3,0]]=])
function_fence("registered_callback", 'fn apply(callback: codeblock){return(callback())} ' .. boundary_source([=[return(apply(){return(capture_until_boundary(End).coalesce("M").cat("!"))})]=]), "capture_until_boundary")

io.stdout:write("BOUNDARY_CAPTURE_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("structural boundary String checks passed: ", checks, "\n")
