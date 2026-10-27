assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/reduction_result_receiver_values." .. extension,"r"))
  local source=file:read("*a");file:close();return source
end

local function routes(compiled, options)
  return {
    {"native",function() return l.runtime_parse(l.runtime_engine(compiled),"x",options).value end},
    {"plan",function() return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","reduction-results.spec",options) end},
    {"fresh",function()
      local parser=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"reduction-results.spec")))()
      return parser.execute("x",options)
    end},
  }
end

local function check_consumers(label,source,expected_json)
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

check_consumers("admitted accumulator producers",[=[Top:: I { return([[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) },["a",["b"]].reduce_leaves("") { return(cat(acc,value)) },[1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) },[1].reduce_leaves({}) { return({"key":"B"}) },[].reduce_leaves(false) { return(true) },[1].reduce_leaves(0) { return(undef) },[].reduce_leaves(["empty"]) { return(value) },{"b":2,"a":1}.reduce_leaves(0) { return(acc.add(value)) }]); }]=], '[6,"ab",[1,2,3],{"key":"B"},false,null,["empty"],3]')
check_consumers("admitted traversal root shape and path order",[=[Top:: I { original=[1,[2]];seen=[];walked=original.walk_leaves() {seen+=join_values("/",path);return(99)};mapped=original.map_leaves() {return(value.add(1))};meta={"b":{"y":2},"a":1,"arr":[9]};paths=[];hash=meta.walk_leaves() {paths+=join_values("/",path);return(0)};return([original,walked,mapped,seen,hash,paths,[1,[2]].reduce_leaves(0) {return(acc.add(value))}]); }]=], '[[1,[2]],[1,[2]],[2,[3]],["0","1/0"],{"b":{"y":2},"a":1,"arr":[9]},["a","arr","b/y"],3]')
check_consumers("shared reduction actual results and scoped effects",fixture("spec"),fixture("json"))
check_consumers("source initial callback consumer order",[=[Top:: I { items=[1,2];order="";calls=0;result={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) {order=cat(order,"L");return(acc.add(value))}.cat({order=cat(order,"C");items=undef;"!"});return([result,order,calls,items]); }]=], '["3!","SILLC",1,null]')
check_consumers("invalid root skips initial and callback",[=[Top:: I { order="";result={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};other=undef.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};return([result,other,order]); }]=], '[null,null,"S"]')
check_consumers("opposite container kinds skip consumer operands",[=[Top:: I { order="";a={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");[]}) {order=cat(order,"L");return(acc)}.set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});first=[a,order];order="";b={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");{}}) {order=cat(order,"L");return(acc)}.take({order=cat(order,"A");1});return([first,[b,order]]); }]=], '[[null,"SIL"],[null,"SIL"]]')

for _,case in ipairs({
  {0,[=[Top:: I { return({print("arity-source");[1]}.reduce_leaves() {print("arity-callback");return(value)}.cat({print("arity-consumer");"!"})); }]=]},
  {2,[=[Top:: I { return({print("arity-source");[1]}.reduce_leaves({print("arity-initial");0},{print("arity-extra");1}) {print("arity-callback");return(value)}.cat({print("arity-consumer");"!"})); }]=]},
}) do
  local compiled=l.compile_spec(l.parse_spec_with_staged_user_function_definitions(case[2]))
  local events={}
  local options={diagnostic_sink=function(event) events[#events+1]=event.message end}
  for _,row in ipairs(routes(compiled,options)) do
    events={}
    local ok,value=pcall(row[2])
    local expected="helper 'reduce_leaves' expects exactly 1 argument(s) before the final codeblock, got " .. case[1]
    if ok or not tostring(value):find(expected,1,true) then
      failures[#failures+1]="malformed " .. case[1] .. " " .. row[1] .. " wrong error: " .. tostring(value)
    end
    if #events ~= 0 then
      failures[#failures+1]="malformed " .. case[1] .. " " .. row[1] .. " evaluated effects: " .. table.concat(events,",")
    end
  end
end
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("reduction result and malformed arity effects passed\n")
