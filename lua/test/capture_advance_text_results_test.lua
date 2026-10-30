-- TYPE-REFERENCE-BOOK.1.2.23.3.51.5 — advancing capture String composition.
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
  local file = assert(io.open("tests/fixtures/capture_advance_text_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "capture-advance-text.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "capture-advance-text.spec") end},
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
  io.stdout:write("CAPTURE_ADVANCE_TEXT ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "x")
  io.stdout:write("CAPTURE_ADVANCE_TEXT_FENCE ", label, " ", json.encode(actual), "\n")
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
for _, item in ipairs({{"capture_take",":",6},{"capture_take_until_cursor",":cat",6},{"capture_take_rest",":catTAIL",10}}) do
  check_value("bound_" .. item[1], action('part=' .. item[1] .. '();return([part.coalesce("M").cat("!"),capture_slice_pos(),cursor_pos()])'),
    "αβ:catTAIL", json.encode(json.array({json.array({item[2] .. "!",item[3],6})})))
end
check_value("initial_missing_no_advance", [=[Top:: I {return([capture_take().coalesce("M").cat("!"),capture_slice_pos(),cursor_pos()])}]=],
  "x", [=[["M!",0,0]]=])
check_value("empty_reversed_once", action([=[first=capture_take_until_cursor();order="";empty=capture_take_until_cursor().coalesce({order=cat(order,"F");"fallback"}).cat("!");missing=capture_take().coalesce("M").cat("!");return([first,empty,missing,capture_slice_pos(),cursor_pos(),order])]=]),
  "αβ:catTAIL", [=[[[":cat","!","M!",6,6,""]]]=])
check_value("string_zero", action([=[return([capture_take_until_cursor().coalesce("M").split(":")[-1].coalesce("bad"),capture_slice_pos(),cursor_pos()])]=], "0"),
  "αβ:0TAIL", [=[[["0",4,4]]]=])
check_value("number_link", action([=[return([capture_take_rest().coalesce("M").length().add(1),capture_slice_pos(),cursor_pos()])]=]),
  "αβ:catTAIL", [=[[[9,10,6]]]=])
check_value("named_overload", action([=[mark_capture_slice(begin);out=capture_take(begin).coalesce("M").cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])]=]),
  "αβ:catTAIL", [=[[[":!",6,2,6]]]=])
check_value("literal_callback", [=[Top:: I {cb={||return(capture_take_rest().coalesce("M").cat("!"))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}]=],
  "abc", [=[["abc!",3,0]]=])
for _, helper in ipairs({"capture_take","capture_take_until_cursor","capture_take_rest"}) do
  function_fence("function_" .. helper,
    'fn forbidden(){return(' .. helper .. '().coalesce("M").cat("!"))} Top:: I {return(forbidden())}', helper)
end
function_fence("registered_callback", [=[fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest().coalesce("M").cat("!"))})}]=], "capture_take_rest")

io.stdout:write("CAPTURE_ADVANCE_TEXT_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("advancing capture String checks passed: ", checks, "\n")
