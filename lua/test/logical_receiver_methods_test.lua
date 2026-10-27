assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/logical_receiver_method_values." .. extension,"r"))
  local source=file:read("*a");file:close();return source
end

local function routes(compiled, options)
  return {
    {"native",function() return l.runtime_parse(l.runtime_engine(compiled),"x",options).value end},
    {"plan",function() return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","logical-receiver-methods.spec",options) end},
    {"fresh",function()
      local parser=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"logical-receiver-methods.spec")))()
      return parser.execute("x",options)
    end},
  }
end

local function check_methods(label,source,expected_json)
  local compiled=l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local expected=json.encode(json.decode(expected_json))
  local prior=#failures
  for _,row in ipairs(routes(compiled)) do
    local ok,actual=pcall(function() return json.encode(row[2]()) end)
    if not ok then
      failures[#failures+1]=label .. " " .. row[1] .. ": " .. tostring(actual)
    elseif actual ~= expected then
      failures[#failures+1]=label .. " " .. row[1] .. ": expected " .. expected .. ", got " .. actual
    end
  end
  if #failures == prior then io.stdout:write(label," passed\n") end
end

check_methods("free logical producers",[=[Top:: I { return([and(true,false),or(false,true),not(false),not("0"),not(0),not([]),not([null]),not({}),not({"key":null})]); }]=], '[false,true,true,false,true,true,false,true,false]')
check_methods("existing scalar value copy",[=[Top:: I { return([and(true).copy(),true.copy(),copy(false)]); }]=], '[true,true,false]')
check_methods("shared logical methods",fixture("spec"),fixture("json"))
check_methods("ordinary method shape skips effects",[=[Top:: I { order="";a={order=cat(order,"S");true}.and().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");false}.or().cat({order=cat(order,"C");"!"});c={order=cat(order,"S");false}.not({order=cat(order,"A");true}).cat({order=cat(order,"C");"!"});d={order=cat(order,"S");false}.not(fail("must-not-run"));return([a,b,c,d,order]); }]=], '[null,null,null,null,""]')
check_methods("valid prefix and consumer kind effects",[=[Top:: I { order="";a={order=cat(order,"S");false}.and({order=cat(order,"R");true}).take({order=cat(order,"A");1});first=[a,order];order="";b={order=cat(order,"S");false}.or({order=cat(order,"R");true}).cat({order=cat(order,"C");"!"}).set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});return([first,[b,order]]); }]=], '[[null,"SR"],[null,"SRC"]]')
check_methods("existing with prefix logical value",[=[Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not();return([a,order,value]); }]=], '[true,"W","outer"]')
check_methods("existing with scope and consumer rejection",[=[Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not().take({order=cat(order,"A");1});return([a,order,value]); }]=], '[null,"W","outer"]')
check_methods("existing with value copy and container recovery",[=[Top:: I { scalar="x".with() {return(false)}.not().copy();hash="x".with() {return(false)}.not().add(1).coalesce({"key":7}).copy().sorted_values().first().add(1);array="x".with() {return(false)}.not().add(1).coalesce([7]).copy().first().add(1);return([scalar,hash,array]); }]=], '[true,8,8]')
for _,row in ipairs({
 {"and",0,"and().not()"},
 {"not",2,[=[not({fail("must-not-run")},{fail("must-not-run")}).or(true)]=]},
}) do
 local source='Top:: I { return('..row[3]..') }'
 local compiled=l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
 for _,route in ipairs(routes(compiled)) do
  local ok,failure=pcall(route[2])
  if ok then
   failures[#failures+1]="invalid source "..row[1].." "..route[1].." accepted"
  elseif route[1]=="native" then
   if not l.is_runtime_interpreter_error(failure) or failure.code~="helper_arity_mismatch" or failure.helper_name~=row[1] or failure.actual_arity~=row[2] then
    failures[#failures+1]="invalid source "..route[1]..": "..tostring(failure)
   else
    local diagnostic=l.interpreter.to_json(failure.diagnostic)
    if diagnostic.code~="helper_arity_mismatch" or diagnostic.rule_label~="Top" then failures[#failures+1]="invalid source diagnostic" end
   end
  else
   local detail=failure.detail or ""
   if not l.is_generated_source_error(failure) or not detail:find("helper_arity_mismatch",1,true) or not detail:find("helper_name="..row[1],1,true) or not detail:find("actual_arity="..row[2],1,true) then
    failures[#failures+1]="invalid source "..route[1]..": "..tostring(failure)
   end
  end
 end
end
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("logical receiver methods and source errors passed\n")
