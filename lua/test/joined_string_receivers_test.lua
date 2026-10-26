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
    "x", "joined-string-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "joined-string-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[fn joined(values) { return(values.join_values(":").uppercase()) }
Top:: /x/ E {
 delimiter_effects=0; false_free=join_values(false,["a","b"]); false_raw=["a","b"].join_values(false); false_computed=["a","b"].join_values({delimiter_effects=num_add(delimiter_effects,1);false}).uppercase();
 named_parts=["a","b"]; mutated=named_parts.push_back("c").join_values(",").uppercase(); incompatible_mutated=named_parts.push_back("d").join_values(",").sorted();
 parts=[" a ","b "]; saved=copy(parts); meta={"b":"y","a":"x"};
 direct=parts.join_values("-").trim().uppercase();
 selected=[["a","b"]].first().join_values("-").uppercase();
 pipeline=["b","a"].sorted().join_values(":").uppercase();
 from_hash=meta.sorted_values().join_values(":").uppercase();
 string="a-b".split("-").join_values(":").uppercase();
 numeric=["a","b"].join_values(":").length().add(1);
 repeated=["a","b"].join_values(":").split(":").last().uppercase();
 from_function=joined(["a","b"]); empty=[].join_values(",").cat("!");
 unicode=["ß","a"].join_values(" ").uppercase();
 items=["a","b"]; order="";
 effected={order=cat(order,"S");items}.join_values({order=cat(order,"D");items+="c";","}).cat({order=cat(order,"A");items+="d";"!"});
 bare=["x","y"]; named=bare.join_values({order=cat(order,"N");bare+="z";"-"}).uppercase();
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values().uppercase();
 extra={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values({invalid_effects=num_add(invalid_effects,1);","},{invalid_effects=num_add(invalid_effects,1);"!"}).uppercase();
 incompatible=["a"].join_values(",").sorted();
 return([false_free,false_raw,false_computed,delimiter_effects,mutated,incompatible_mutated,named_parts,direct,selected,pipeline,from_hash,string,numeric,repeated,from_function,empty,unicode,effected,named,order,items,bare,parts,saved,meta,missing,extra,invalid_effects,incompatible]);
}]=],
  '["a0b","a0b","A0B",1,"A,B,C",null,["a","b","c","d"],"A -B","A-B","A:B","X:Y","A:B",4,"B","A:B","!","SS A","a,b!","X-Y","SDAN",["a","b","c","d"],["x","y","z"],[" a ","b "],[" a ","b "],{"a":"x","b":"y"},null,null,0,null]')
io.stdout:write("joined String receiver checks passed\n")
