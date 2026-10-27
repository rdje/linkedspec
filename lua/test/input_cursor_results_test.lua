-- TYPE-REFERENCE-BOOK.1.2.23.3.27.5 — safe readonly input/cursor result checks.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/input_cursor_result_values." .. extension, "r"))
  local source = file:read("*a"); file:close(); return source
end

local function check_selection(label, source, input, expected_json)
  local prepared, compiled = pcall(function()
    return l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  end)
  if not prepared then
    failures[#failures+1] = label .. " compile: " .. tostring(compiled)
    return
  end
  local expected = json.encode(json.decode(expected_json))
  for _, route in ipairs({
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "input-cursor-results.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "input-cursor-results.spec")))()
      return parser.execute(input)
    end},
  }) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("INPUT_CURSOR_OBSERVATION ", label, " ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then
      failures[#failures+1] = label .. " " .. route[1] .. ": expected " .. expected .. ", got " .. tostring(actual)
    end
  end
end

local function check_action(label,action,expected)
  local source="Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /name/\n /=/\n /Alpha/\n -> Value[2] {" .. action .. "}\n"
  check_selection(label,source,"name=Alpha",expected)
end
check_selection("unchanged frozen target",fixture("spec"),"name=Alpha",fixture("json"))
check_action("with actual kinds and outer scope",[=[
 order="";value="outer";
 a=input_text().with() {return(value)}.take({order=cat(order,"A");1});
 b=input_len().with() {return(value)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 c=input_text().with() {order=cat(order,"W");return(["a","b"])}.last().uppercase();
 d=input_len().with() {return({"k":[false]})}.sorted_values().first().first();
 return([a,b,c,d,order,value]);
]=],'[[null,null,"B",false,"W","outer"]]')
check_action("source order defaults Number indices and named controls",[=[
 order="";start=5;width=5;
 result=input_slice({order=cat(order,"S");start},{order=cat(order,"W");width}).coalesce({order=cat(order,"F");"bad"}).cat({order=cat(order,"C");start=0;width=4;"!"});
 items=["zero","one"];index=input_len().coalesce({order=cat(order,"F");7}).sub(10);items[index]="updated";
 a=input_text();b=input_len();c=cursor_rest();d=cursor_rest_len();
 return([result,order,start,width,items,input_slice(0,0).coalesce("late").cat("!"),a.coalesce("late").split("=")[-1].uppercase(),b.coalesce(0).add(1),c.coalesce("late").cat("!"),d.coalesce(7).add(1)]);
]=],'[["Alpha!","SWC",0,4,["updated","one"],"!","ALPHA",11,"!",1]]')
check_action("reader counts and legacy bound flat results",[=[
 thunk={|| return([false,["tail"]])};
 return([input_text().count(),input_len().count_keys(),input_text().with() {return(value)}.count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),flat([1])[9].count()]);
]=],'[[null,null,null,false,"TAIL",0,0,0]]')

for _,row in ipairs({
 {"input_text",'input_text("ignored").count()',"helper 'input_text' expects exactly 0 positional arguments, got 1"},
 {"input_slice",'input_slice(0).count()',"helper 'input_slice' expects exactly 2 positional arguments, got 1"},
}) do
 local compiled=l.compile_spec(l.parse_spec_with_staged_user_function_definitions('Top:: I {return('..row[2]..')}'))
 for _,route in ipairs({
  {"native",function() return l.runtime_parse(l.runtime_engine(compiled),"x").value end},
  {"plan",function() return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","input-cursor-results.spec") end},
  {"fresh",function()
   local parser=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"input-cursor-results.spec")))()
   return parser.execute("x")
  end},
 }) do
  local ok,failure=pcall(route[2])
  local valid=not ok
  if valid and route[1]=="native" then
   valid=l.is_runtime_interpreter_error(failure) and failure.code=="helper_arity_mismatch" and failure.helper_name==row[1] and failure.actual_arity==1
  elseif valid then
   valid=l.is_generated_source_error(failure) and (failure.detail or ""):find(row[3],1,true)
  end
  if not valid then failures[#failures+1]="source error "..row[1].." "..route[1]..": "..tostring(failure) end
  io.stdout:write("INPUT_CURSOR_SOURCE_ERROR ",row[1]," ",route[1]," ",tostring(failure),"\n")
 end
end
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("input cursor checks passed\n")
