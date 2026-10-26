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
    "x", "aggregate-numeric-receivers.spec"), "generated-plan")
  local generated = assert((loadstring or load)(l.emit_lua_source_v2(
    compiled, "aggregate-numeric-receivers.spec")))()
  same(generated.execute("x"), "fresh-emitted")
end

check_consumers([=[fn reduced(values) { return(values.sum().mul(2)) }
Top:: /x/ E {
 items=[2,4,6]; saved=copy(items); meta={"b":4,"a":2};
 direct=[items.sum().add(1),items.avg().add(1),items.median().add(1),items.range().add(1),items.min().add(1),items.max().add(1)];
 empty_helpers=[num_sum([]),num_add(num_sum([]),1),num_sum(["bad"]),num_avg([])];
 empty=[ [].sum().add(1),[].avg().add(1),[].median().add(1),[].range().add(1),[].min().add(1),[].max().add(1) ];
 selected=[ [[2,4]].first().sum().mul(2), [[2,4]].last().max().add(1) ];
 pipeline=[items.sorted().take(2).sum().add(1),meta.sorted_values().avg().mul(2)];
 overloads=[ [2,4].sum().min(3).add(1),[2,4].sum().max(8).sub(1),5.min(3).add(1),[3].first().min(2).add(1) ];
 text=[1,2].sum().cat(" total").uppercase(); bridge=[1,2].sum().cat(":a").split(":").last().uppercase(); even=[4,1,3,2].median().mul(2);
 from_function=reduced(items); invalid_source=["bad"].sum().add(1);
 order="";
 summed={order=cat(order,"S");items}.sum().add({order=cat(order,"A");items+=8;1});
 effects=0;
 bad_sum={effects=num_add(effects,1);[1]}.sum({effects=num_add(effects,1);1}).add(1);
 bad_avg={effects=num_add(effects,1);[1]}.avg({effects=num_add(effects,1);1}).add(1);
 bad_median={effects=num_add(effects,1);[1]}.median({effects=num_add(effects,1);1}).add(1);
 bad_range={effects=num_add(effects,1);[1]}.range({effects=num_add(effects,1);1}).add(1);
 named=[1,2]; mutated=named.push_back(3).sum().add(1); bad_push=named.push_back(9).sum(1);
 return([mutated,named,bad_push,direct,empty,empty_helpers,selected,pipeline,overloads,text,bridge,even,from_function,invalid_source,summed,order,items,saved,bad_sum,bad_avg,bad_median,bad_range,effects,[1,2].sum().drop_front(1),[1,2].min().sorted(),[1,2].sum().uppercase_each()]);
}]=],
  '[7,[1,2,3],null,[13,5,5,5,3,7],[1,null,null,null,null,null],[0,1,null,null],[12,5],[7,6],[4,7,4,3],"3 TOTAL","A",5,24,null,13,"SA",[2,4,6,8],[2,4,6],null,null,null,null,0,null,null,null]')
io.stdout:write("aggregate numeric receiver checks passed\n")
