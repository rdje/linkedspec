local l = require("linkedspec")
local json = l.json
local cases = {
  {"zero",[=[Top:: I { return([1].reduce_leaves() {return(value)}.cat("!")); }]=]},
  {"source_effect",[=[Top:: I { return({print("REDUCTION_ARITY_SOURCE_EFFECT");[1]}.reduce_leaves() {print("REDUCTION_ARITY_CALLBACK_EFFECT");return(value)}.cat({print("REDUCTION_ARITY_CONSUMER_EFFECT");"!"})); }]=]},
  {"two",[=[Top:: I { return([1].reduce_leaves(0,1) {return(value)}.cat("!")); }]=]},
}
for _,case in ipairs(cases) do
  local ok,compiled = pcall(function()
    return l.compile_spec(l.parse_spec_with_staged_user_function_definitions(case[2]))
  end)
  if not ok then
    io.stdout:write(json.encode(json.harray({label=case[1],phase="compile",error=tostring(compiled)})),"\n")
  else
    local function observe(route,operation)
      local events=json.array()
      local options={diagnostic_sink=function(event) events[#events+1]=event.message end}
      local success,value=pcall(operation,options)
      local row=json.harray({label=case[1],phase=route,ok=success,value=json.null,events=events})
      if success then row.value=value == nil and json.null or value else row.error=tostring(value) end
      io.stdout:write(json.encode(row),"\n")
    end
    observe("native",function(options) return l.runtime_parse(l.runtime_engine(compiled),"x",options).value end)
    observe("plan",function(options) return l.execute_generated_parser_v2(compiled,l.build_generated_rule_plan(compiled),"x","reduction-arity.spec",options) end)
    observe("fresh",function(options)
      local parser=assert((loadstring or load)(l.emit_lua_source_v2(compiled,"reduction-arity.spec")))()
      return parser.execute("x",options)
    end)
  end
end
