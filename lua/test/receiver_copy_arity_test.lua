assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local source = [=[Top:: /x/ E {
 effects=0;
 invalid={effects=num_add(effects,1); [["a"]]}.first().copy({effects=num_add(effects,1); 1});
 invalid_direct={effects=num_add(effects,1); ["b"]}.copy({effects=num_add(effects,1); 1});
 valid_effects=0; original=[["a"]];
 copied={valid_effects=num_add(valid_effects,1); original}.first().copy();
 copied+="b";
 return([invalid,invalid_direct,effects,copied,original,valid_effects,"x".copy().uppercase(),missing.copy()]);
}]=]
local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
local expected = json.encode(json.decode('[null,null,0,["a","b"],[["a"]],1,"X",null]'))
local function same(value, route)
 local actual = json.encode(value)
 assert(actual == expected, route .. ": expected " .. expected .. ", got " .. actual)
end
same(l.runtime_parse(l.runtime_engine(compiled), "x").value, "native")
same(l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled),
 "x", "receiver-copy-arity.spec"), "generated-plan")
local generated = assert((loadstring or load)(l.emit_lua_source_v2(
 compiled, "receiver-copy-arity.spec")))()
same(generated.execute("x"), "fresh-emitted")
io.stdout:write("receiver copy arity checks passed\n")
