-- TYPE-REFERENCE-BOOK.1.2.23.3.34.5 — named Number values and caller mark scopes.
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
  local file = assert(io.open("tests/fixtures/named_mark_number_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "named-mark-number.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "named-mark-number.spec") end},
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
  io.stdout:write("NAMED_MARK_NUMBER ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "αβ:cat")
  io.stdout:write("NAMED_MARK_NUMBER_FENCE ", label, " ", json.encode(actual), "\n")
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
check_value("shared", fixture("spec"), "αβ:cat", fixture("json"))
check_value("producers", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish),mark_line(finish),mark_col(finish),capture_len_from(begin),capture_rest_len_from(begin),capture_until_cursor_len_from(begin),capture_len_between(begin,finish)])}
]=], [=[αβ:cat]=], [=[[[6,1,7,3,6,6,6]]]=])
check_value("missing_producers", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(absent),mark_line(absent),mark_col(absent),capture_len_from(absent),capture_rest_len_from(absent),capture_until_cursor_len_from(absent),capture_len_between(absent,finish),capture_len_between(begin,absent)])}
]=], [=[αβ:cat]=], [=[[[null,null,null,null,null,null,null,null]]]=])
check_value("symbolic_shadow", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);begin="finish";finish="begin";return([capture_len_between(begin,finish),mark_pos(begin),mark_pos(finish)])}
]=], [=[αβ:cat]=], [=[[[6,0,6]]]=])
check_value("quoted_names", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos("finish"),capture_len_between("begin","finish")])}
]=], [=[αβ:cat]=], [=[[[6,6]]]=])
check_value("evaluated_name", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(cat("fin","ish")))}
]=], [=[αβ:cat]=], [=[[6]]=])
check_value("legacy_bound", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);p=mark_pos(finish);order="";a=p.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=p.take({order=cat(order,"T");1});c=p.add(0).set_key({order=cat(order,"X");"k"},{order=cat(order,"Y");1});return([a,b,c,order])}
]=], [=[αβ:cat]=], [=[[[6,[],null,"KVT"]]]=])
check_value("snapshot_bound", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";p=mark_pos(finish);snapshot=p.cat({order=cat(order,"S");"!"});clear_mark(finish);return([snapshot,mark_pos(finish),mark_pos(begin),order])}
]=], [=[αβ:cat]=], [=[[["6!",null,0,"S"]]]=])
check_value("direct_mark_pos", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(finish).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["6!"]]=])
check_value("direct_mark_line", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_line(finish).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["1!"]]=])
check_value("direct_mark_col", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_col(finish).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["7!"]]=])
check_value("direct_capture_len_from", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_from(begin).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["3!"]]=])
check_value("direct_capture_until_cursor_len_from", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["6!"]]=])
check_value("direct_capture_rest_len_from", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["6!"]]=])
check_value("direct_capture_len_between", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
]=], [=[αβ:cat]=], [=[["6!"]]=])
check_value("direct_legacy", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(finish).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=mark_pos(finish).take({order=cat(order,"T");1});return([a,b,order])}
]=], [=[αβ:cat]=], [=[[[6,[],"KVT"]]]=])
check_value("other_label", [=[Top::
 -> Other .push
 LX {return(copy(Top))}
Other:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Other[2] {mark_input_start(left);mark_input_end(right);return([mark_pos(right).coalesce(0).sub(1),mark_line(right).coalesce(0).add(1),mark_col(right).coalesce(0).cat("!"),capture_len_from(left).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(left).coalesce(0).add(1),capture_until_cursor_len_from(left).coalesce(0).sub(1),capture_len_between(left,right).coalesce(0).add(1)])}
]=], [=[αβ:cat]=], [=[[[5,2,"7!","TAIL",7,5,7]]]=])
check_value("partial_shared", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish).coalesce(0).sub(1),mark_line(finish).coalesce(0).add(1),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(begin).coalesce(0).add(1),capture_until_cursor_len_from(begin).coalesce(0).sub(1),capture_len_between(begin,finish).coalesce(0).add(1)])}
]=], [=[αβ:catTAIL]=], [=[[[9,2,"11!","TAIL",11,5,11]]]=])
check_value("zero_missing_reversed", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(begin).coalesce({order=cat(order,"Z");9}).add(1);b=capture_len_between(begin,begin).coalesce({order=cat(order,"E");9}).add(1);c=mark_pos(absent).coalesce({order=cat(order,"F");7}).add(1);d=capture_len_between(finish,begin).coalesce(9).add(1);return([a,b,c,d,order])}
]=], [=[αβ:cat]=], [=[[[1,1,8,10,"F"]]]=])
function_fence("function_mark_pos", [=[fn forbidden(){return(mark_pos(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "mark_pos")
function_fence("function_mark_line", [=[fn forbidden(){return(mark_line(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "mark_line")
function_fence("function_mark_col", [=[fn forbidden(){return(mark_col(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "mark_col")
function_fence("function_capture_len_from", [=[fn forbidden(){return(capture_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "capture_len_from")
function_fence("function_capture_until_cursor_len_from", [=[fn forbidden(){return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "capture_until_cursor_len_from")
function_fence("function_capture_rest_len_from", [=[fn forbidden(){return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "capture_rest_len_from")
function_fence("function_capture_len_between", [=[fn forbidden(){return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
]=], "capture_len_between")
check_value("literal_callback_all", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||return([mark_pos(finish).coalesce(0).cat("!"),mark_line(finish).coalesce(0).cat("!"),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat("!"),capture_until_cursor_len_from(begin).coalesce(0).cat("!"),capture_rest_len_from(begin).coalesce(0).cat("!"),capture_len_between(begin,finish).coalesce(0).cat("!")])};return(cb())}
]=], [=[αβ:cat]=], [=[[["6!","1!","7!","3!","6!","6!","6!"]]]=])
function_fence("registered_callback", [=[fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(apply(){return(mark_pos(finish).coalesce(0).cat("!"))})}
]=], "mark_pos")
check_value("callback_write_read_scope", [=[Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||mark_input_end(inside);return([mark_pos(inside),mark_pos(finish)])};result=cb();return([result,mark_pos(inside),mark_pos(finish)])}
]=], [=[αβ:cat]=], [=[[[[6,6],6,6]]]=])
check_value("callback_cross_rule_scope", [=[Top:: I {a=call(First);b=call(Second);return([a,b])}
First:: I {cb={||mark_input_end(shared);return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
Second:: I {cb={||return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
]=], [=[x]=], [=[[[1,1],[null,null]]]=])
check_value("dynamic_invocation", [=[Top::
 I {reader=call(First);mark_input_start(shared);a=reader();mark_input_end(shared);b=reader();return([a,b])}
First::
 I {mark_input_end(shared);return({||return(mark_pos(shared))})}
]=], [=[αβ:cat]=], [=[[0,6]]=])

io.stdout:write("NAMED_MARK_NUMBER_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("named Number checks passed: ", checks, "\n")
