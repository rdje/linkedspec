assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}

local function fixture(extension)
  local file = assert(io.open("tests/fixtures/tagged_record_receiver_values." .. extension,"r"))
  local source=file:read("*a");file:close();return source
end

local function routes(compiled, options)
  return {
    {"native",function() return l.runtime_parse(l.runtime_engine(compiled),"x",options).value end},
    {"plan",function() return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","tagged-record-results.spec",options) end},
    {"fresh",function()
      local parser=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"tagged-record-results.spec")))()
      return parser.execute("x",options)
    end},
  }
end

local function check_records(label,source,expected_json)
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

check_records("eager producer and current pure split",[=[Top:: I { counter=0;records=split_tagged_records("a,b,",",","row",set(counter,num_add(counter,1)),false,null,["x"],{"key":"v"});empty=split_tagged_records("",",","row",set(counter,num_add(counter,1)));return([records,empty,counter,split("a,b,",","),split("",",")]); }]=], '[[["row","a",1,false,null,["x"],{"key":"v"}],["row","b",1,false,null,["x"],{"key":"v"}],["row","",1,false,null,["x"],{"key":"v"}]],[["row","",2]],2,["a","b",""],[""]]')
check_records("shared String tagged-record and selected field chains",fixture("spec"),fixture("json"))
check_records("earlier carried values and independent row copies",[=[Top:: I { carried=["x"];number=7;records=split_tagged_records("a,b",",","row",carried,number,{carried+="later";number=9;number});records[0][2][0]="changed";return([records,carried,number]); }]=], '[[["row","a",["changed"],7,9],["row","b",["x"],7,9]],["x","later"],9]')
check_records("minimum receiver shape skips effects",[=[Top:: I { order="";bad0={order=cat(order,"S");"a,b"}.split_tagged_records().count();bad1={order=cat(order,"S");"a,b"}.split_tagged_records({order=cat(order,"D");","}).take({order=cat(order,"C");1});return([bad0,bad1,order]); }]=], '[null,null,""]')
check_records("short free shapes retain empty Arrays and eager operands",[=[Top:: I { order="";short=split_tagged_records({order=cat(order,"S");"a,b"},{order=cat(order,"D");","});return([split_tagged_records(),short,order]); }]=], '[[],[],"SD"]')
if #failures > 0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("tagged-record producer and receiver checks passed\n")
