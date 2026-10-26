assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local function check_consumers(source, expected_json)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  local expected = json.encode(json.decode(expected_json))
  local function same(value, route)
    local actual = json.encode(value)
    assert(actual == expected, route .. ": expected " .. expected .. ", got " .. actual)
  end
  same(l.runtime_parse(l.runtime_engine(compiled), "x").value, "native")
  same(l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled),
    "x", "count-length-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "count-length-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[fn sized(values) { return(values.count().add(1)) }
Top:: /x/ E {
 items=[1,2]; saved=copy(items); meta={"a":1,"b":2}; order="";
 direct=[items.count().add(3),"abcd".length().add(2),meta.count_keys().mul(2)];
 empty=[ [].count().add(1), "".length().add(1), {}.count_keys().add(1) ];
 selected=[ [[1,2,3]].first().count().add(1), ["ab"].first().length().add(1), [{"a":1}].first().count_keys().add(1) ];
 pipeline=[items.sorted().length().add(1)," x ".trim().length().add(1),meta.sorted_values().count().add(1)];
 text=items.count().cat(" items").uppercase(); missing=[].first().length().add(1);
 from_function=sized(items); unicode_count="🙂a".length().add(1);
 counted={order=cat(order,"S"); items}.count().add({order=cat(order,"A"); items+=9; 3});
 raw="ab"; measured=raw.length().add({order=cat(order,"L"); raw="changed"; 3});
 keys={order=cat(order,"H"); meta}.count_keys().add({order=cat(order,"K"); meta["c"]=3; 3});
 invalid_effects=0;
 bad_count={invalid_effects=num_add(invalid_effects,1); [1]}.count({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 bad_length={invalid_effects=num_add(invalid_effects,1); "a"}.length({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 bad_keys={invalid_effects=num_add(invalid_effects,1); {"a":1}}.count_keys({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 return([direct,empty,selected,pipeline,text,missing,from_function,unicode_count,counted,measured,keys,order,items,saved,raw,meta,bad_count,bad_length,bad_keys,invalid_effects]);
}]=],
  '[[5,6,4],[1,1,1],[4,3,2],[3,2,3],"2 ITEMS",null,3,3,5,5,5,"SALHK",[1,2,9],[1,2],"changed",{"a":1,"b":2,"c":3},null,null,null,0]')
check_consumers([=[Top:: /x/ E {
  return([count("ab"),count({"a":1}),count(7),count(false),count(undef),count([1,2])]);
}]=], '[0,0,0,0,0,2]')
io.stdout:write("count/length receiver checks passed\n")
