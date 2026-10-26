assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json

local source = [=[fn clone_first(values) { return(values.first().copy()) }
Top::
 /x/
 E {
  nested=[[3,1],[2]]; saved=copy(nested); rows=[{"b":2,"a":1}];
  copied_array=clone_first(nested); copied_hash=clone_first(rows);
  repeated=[[[4,1],[2]]].first().first().sorted().last().add(2);
  order=""; calls=0;
  computed={order=cat(order,"S"); [{"a":1}]}.first().set_key("b",{order=cat(order,"V"); calls=num_add(calls,1); 2});
  invalid_effects=0;
  invalid={invalid_effects=num_add(invalid_effects,1); [" a "]}.first({invalid_effects=num_add(invalid_effects,1); 1}).trim();
  return([
   " a : b ".split(/:/).first().trim().uppercase(),
   [" A "," B "].last().trim().lowercase(),
   [[3,1],[2]].first().sorted().last().add(4),
   [{"b":2,"a":1}].first().sorted_keys().last().uppercase(),
   [2,3].last().mul(4),
   [].first().trim(),copied_array,copied_hash,repeated,computed,order,calls,
   nested,saved,rows,invalid,invalid_effects,[[3,1]].first().min(),[3].first().min(2),
   [[3,1],[2]].first().copy().sorted().last().add(4),
   [{"b":2,"a":1}].first().copy().sorted_keys().last().uppercase()
  ]);
 }
]=]
local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
-- Decode the authored vector with the public codec, preserving its null slots.
local expected = json.encode(json.decode('["A","b",7,"B",12,null,[3,1],{"a":1,"b":2},6,{"a":1,"b":2},"SV",1,[[3,1],[2]],[[3,1],[2]],[{"a":1,"b":2}],null,0,1,2,7,"B"]'))
local function same(value, route)
  local actual = json.encode(value)
  assert(actual == expected, route .. ": expected " .. expected .. ", got " .. actual)
end
same(l.runtime_parse(l.runtime_engine(compiled), "x").value, "native")
same(l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled),
  "x", "selected-value-receivers.spec"), "generated-plan")
local generated = assert((loadstring or load)(l.emit_lua_source_v2(
  compiled, "selected-value-receivers.spec")))()
same(generated.execute("x"), "fresh-emitted")
io.stdout:write("selected-value receiver checks passed\n")
