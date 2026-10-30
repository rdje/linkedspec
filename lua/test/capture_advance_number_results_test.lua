-- TYPE-REFERENCE-BOOK.1.2.23.3.52.5 — advancing capture Number composition.
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
  local file = assert(io.open("tests/fixtures/capture_advance_number_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "capture-advance-number.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "capture-advance-number.spec") end},
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
  io.stdout:write("CAPTURE_ADVANCE_NUMBER ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "x")
  io.stdout:write("CAPTURE_ADVANCE_NUMBER_FENCE ", label, " ", json.encode(actual), "\n")
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
local function action(body, tail)
  return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>αβ)/\n /:/\n /" .. (tail or "cat") .. "/\n -> Value[2] {" .. body .. "}\n"
end
check_value("shared", fixture("spec"), "αβ:catTAIL", fixture("json"))
for _, item in ipairs({{"capture_take_len",1,6},{"capture_take_until_cursor_len",4,6},{"capture_take_rest_len",8,10}}) do
  check_value("bound_" .. item[1], action('part=' .. item[1] .. '();return([part.coalesce(99).add(1).cat("!"),capture_slice_pos(),cursor_pos()])'),
    "αβ:catTAIL", json.encode(json.array({json.array({tostring(item[2]+1) .. "!",item[3],6})})))
end
check_value("initial_missing_no_advance", [=[Top:: I {return([capture_take_len().coalesce(99).cat("!"),capture_slice_pos(),cursor_pos()])}]=],
  "x", [=[["99!",0,0]]=])
check_value("zero_reversed_once", action([=[first=capture_take_until_cursor_len();order="";zero=capture_take_until_cursor_len().coalesce({order=cat(order,"F");99}).add(1);missing=capture_take_len().coalesce(99).cat("!");return([first,zero,missing,capture_slice_pos(),cursor_pos(),order])]=]),
  "αβ:catTAIL", [=[[[4,1,"99!",6,6,""]]]=])
check_value("snapshot_before_reset", action([=[width=capture_take_rest_len().coalesce(0);snapshot=width.cat({start_capture_slice();"!"});return([width,snapshot,capture_slice_pos(),cursor_pos()])]=]),
  "αβ:catTAIL", [=[[[8,"8!",6,6]]]=])
check_value("named_width_source", action([=[mark_capture_slice(begin);out=capture_take_len_from(begin).coalesce(99).add(1).cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])]=]),
  "αβ:catTAIL", [=[[["2!",6,2,6]]]=])
check_value("literal_callback", [=[Top:: I {cb={||return(capture_take_rest_len().coalesce(99).add(1))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}]=],
  "abc", [=[[4,3,0]]=])
for _, helper in ipairs({"capture_take_len","capture_take_until_cursor_len","capture_take_rest_len"}) do
  function_fence("function_" .. helper,
    'fn forbidden(){return(' .. helper .. '().coalesce(99).add(1))} Top:: I {return(forbidden())}', helper)
end
function_fence("registered_callback", [=[fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest_len().coalesce(99).add(1))})}]=], "capture_take_rest_len")

io.stdout:write("CAPTURE_ADVANCE_NUMBER_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("advancing capture Number checks passed: ", checks, "\n")
