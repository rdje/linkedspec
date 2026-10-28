-- TYPE-REFERENCE-BOOK.1.2.23.3.33.5 — readonly capture Number method flow.
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
  local file = assert(io.open("tests/fixtures/capture_boundary_number_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "capture-boundary-number.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "capture-boundary-number.spec") end},
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
  io.stdout:write("CAPTURE_NUMBER ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "x")
  io.stdout:write("CAPTURE_NUMBER_FENCE ", label, " ", json.encode(actual), "\n")
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
-- Missing current-match endpoint width stays diagnostic-only under40.
check_value("shared", fixture("spec"), "αβ:cat", fixture("json"))
check_value("original",[=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";
original=[capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len(),capture_slice_length(),capture_len_from_rule_start(),capture_rest_length()];
width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();
return([original,snapshot,capture_slice_pos(),order]);}
]=],"αβ:cat",[=[[[[1,2,1,3,4,4,1,1,4],"4!",6,"S"]]]=])
check_value("zero",[=[Top:: I {order="";primitive=[capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len()];zero=capture_slice_pos().coalesce({order=cat(order,"F");7}).add(1);return([primitive,zero,order])}]=],"x",[=[[[0,1,1,0,1],1,""]]=])
check_value("legacy",[=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";a=capture_rest_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=capture_rest_len().take({order=cat(order,"T");1});return([a,b,order]);}
]=],"αβ:cat",[=[[[4,[],"KVT"]]]=])
check_value("literal_callback",[=[Top:: I {cb={||return(capture_rest_len().coalesce(0).cat("!"))};return(cb())}]=],"x",[=["1!"]=])
function_fence("registered_callback",[=[fn apply(callback: codeblock){return(callback())}
Top:: I {return(apply(){return(capture_rest_len().coalesce(0).cat("!"))})}]=],"capture_rest_len")
function_fence("function_capture_slice_len",[=[fn forbidden(){return(capture_slice_len().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_slice_len")
function_fence("function_capture_slice_pos",[=[fn forbidden(){return(capture_slice_pos().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_slice_pos")
function_fence("function_capture_slice_line",[=[fn forbidden(){return(capture_slice_line().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_slice_line")
function_fence("function_capture_slice_col",[=[fn forbidden(){return(capture_slice_col().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_slice_col")
function_fence("function_capture_slice_until_cursor_len",[=[fn forbidden(){return(capture_slice_until_cursor_len().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_slice_until_cursor_len")
function_fence("function_capture_rest_len",[=[fn forbidden(){return(capture_rest_len().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_rest_len")
function_fence("function_capture_slice_length",[=[fn forbidden(){return(capture_slice_length().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_slice_length")
function_fence("function_capture_len_from_rule_start",[=[fn forbidden(){return(capture_len_from_rule_start().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_len_from_rule_start")
function_fence("function_capture_rest_length",[=[fn forbidden(){return(capture_rest_length().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}]=],"capture_rest_length")

io.stdout:write("CAPTURE_NUMBER_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("capture Number checks passed: ", checks, "\n")
