assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local function fixture(name, extension)
  local file = assert(io.open("tests/fixtures/" .. name .. "." .. extension, "r"))
  local source = file:read("*a")
  file:close()
  return source
end

local function check_consumers(source, expected_json)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local expected = json.encode(json.decode(expected_json))
  local function same(value, route)
    local actual = json.encode(value)
    assert(actual == expected, route .. ": expected " .. expected .. ", got " .. actual)
  end
  same(l.runtime_parse(l.runtime_engine(compiled), "x").value, "native")
  same(l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled),
    "x", "defined-default-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "defined-default-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: I { raw=[coalesce(undef,"fallback"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce(undef,[2,3]),coalesce(undef,{"a":"a","b":"b"})];nested=[uppercase(trim(coalesce(undef," chosen "))),cat(coalesce(false,true),"!")];hits=0;lazy=coalesce("",{hits=num_add(hits,1);"late"},{target=1;target[0]=2;"bad"});items=["a","b"];chosen=coalesce(undef,items);items[0]="z";values=["zero","one"];values[coalesce(undef,1)]="updated";return([raw,nested,lazy,hits,chosen,items,values]); }]=],
  [=[[["fallback","",0,false,null,[2,3],{"a":"a","b":"b"}],["CHOSEN","0!"],"",0,["a","b"],["z","b"],["zero","updated"]]]=])
io.stdout:write("defined-only default producer controls passed\n")
check_consumers(fixture("defined_default_receiver_values", "spec"), fixture("defined_default_receiver_values", "json"))
check_consumers([=[Top:: I { order="";named=undef;flag=false;return([named.coalesce("kept").sorted(),[].first().coalesce("kept").sorted_values(),flag.coalesce(true).take({order=cat(order,"A");1}),{order=cat(order,"S");true}.coalesce().cat({order=cat(order,"C");"!"}),order]); }]=], '[null,null,null,null,""]')
io.stdout:write("defined-only default receiver and selected controls passed\n")
