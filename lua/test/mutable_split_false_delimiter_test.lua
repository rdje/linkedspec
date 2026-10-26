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
    "x", "mutable-split-false-delimiter.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "mutable-split-false-delimiter.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[Top:: /x/ E {
 parts=["old"]; pure=split("a0b",false); updated=split(parts,"a0b",false); parts+="tail";
 order=""; source="a0b"; computed=["old"];
 result=split(computed,{order=cat(order,"S");source},{order=cat(order,"D");source="changed";false});
 computed+="later";
 with_true=["old"];split(with_true,"a1b",true);
 with_zero=["old"];split(with_zero,"a0b",0);
 with_string=["old"];split(with_string,"a0b","0");
 with_empty=["old"];split(with_empty,"ab","");
 two_arg_target=["old"];split(two_arg_target,"ab");
 return([pure,updated,parts,result,computed,order,source,with_true,with_zero,with_string,with_empty,two_arg_target,["a","b"].join_values(false).uppercase()]);
}]=],
  '[["a","b"],["a","b"],["a","b","tail"],["a","b"],["a","b","later"],"SD","changed",["a","b"],["a","b"],["a","b"],["a","b"],["old"],"A0B"]')
io.stdout:write("mutable split false delimiter checks passed\n")
