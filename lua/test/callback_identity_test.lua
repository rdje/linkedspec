-- TYPE-REFERENCE-BOOK.1.2.23.3.31.6.4.1 — finite callback identity controls.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
local checks = 0
local function check(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end
local cases = {
  {"contextual", [=[value="outer";result=with("outside"){return(with("inside"){return(value)})};return([result,value]);]=], '["inside","outer"]'},
  {"explicit", [=[value="saved";result=with("outer",{|outer|return(with("inner",{|inner|return(cat(outer,inner))}))});return([result,value,coalesce(outer,"missing"),coalesce(inner,"missing")]);]=], '["outerinner","saved","missing","missing"]'},
  {"helper cycle", [=[calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,cb),"escaped"))};return(cb("x"));]=], nil, "cb", '["cb","cb"]'},
  {"receiver cycle", [=[calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),v.with(cb),"escaped"))};return(cb("x"));]=], nil, "cb", '["cb","cb"]'},
  {"opaque cycle", [=[calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,coalesce(cb,cb)),"escaped"))};return(cb("x"));]=], nil, "cb", '["cb","cb"]'},
  {"anonymous unknown", [=[return(with("x"){return(missing())})]=], nil, "missing"},
  {"direct cycle", [=[calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),cb(v),"escaped"))};return(cb("x"));]=], nil, "cb", '["cb","cb"]'},
  {"caller callback named value", [=[value={|item|return(cat(item,"!"))};return([with("a",value),"b".with(value),value("c")]);]=], '["a!","b!","c!"]'},
  {"distinct tree callbacks", [=[return([1].map_leaves(){return([value].map_leaves(){return(value)})})]=], '[[1]]'},
  {"mutual cycle", [=[calls=0;a={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),b(v),"escaped"))};b={|v|return(a(v))};return(a("x"));]=], nil, "a", '["a","b","a"]'},
}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
for _, case in ipairs(cases) do
  local spec = l.parse_spec_with_staged_user_function_definitions("Top:: I {" .. case[2] .. "}")
  local compiled = l.compile_spec(spec)
  local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(spec)))))
  local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "callback-identity.spec")))()
  local routes = {
    {"native", function() return l.runtime_execute(l.runtime_engine(compiled), "x").value end},
    {"restored", function() return l.runtime_execute(l.runtime_engine(restored), "x").value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), "x", "callback-identity.spec") end},
    {"fresh", function() return parser.execute("x") end},
  }
  local native_detail
  for index, route in ipairs(routes) do
    local ok, value = pcall(route[2])
    local label = case[1] .. " " .. route[1]
    io.stdout:write("CALLBACK_IDENTITY ", label, " ", ok and json.encode(value) or tostring(value), "\n")
    if case[3] then
      check(ok and json.encode(value) == json.encode(json.decode(case[3])), label .. " exact result and kinds")
    else
      check(not ok, label .. " rejects")
      if not ok then
        local code = case[5] and "codeblock_recursion_unsupported" or "unknown_helper"
        if index <= 2 then
          check(l.is_runtime_interpreter_error(value), label .. " typed runtime error")
          local diagnostic = value.diagnostic and l.interpreter.to_json(value.diagnostic) or {}
          check(diagnostic.code == code, label .. " diagnostic code")
          check(diagnostic.stage == "callable_codeblock_invocation", label .. " diagnostic stage")
          if case[5] then
            check(diagnostic.callable_name == case[4], label .. " callable name")
            check(diagnostic.cycle ~= nil and json.encode(diagnostic.cycle) == case[5], label .. " exact cycle")
            check(diagnostic.handler_source_label == "lua_runtime:codeblock:" .. case[4], label .. " source label")
          else
            check(diagnostic.name == case[4], label .. " unknown helper name")
          end
          if index == 1 then native_detail = tostring(value) end
          check(tostring(value) == native_detail, label .. " runtime detail identity")
        else
          check(l.is_generated_source_error(value), label .. " typed generated error")
          check(value.code == "generated_execution_failed" and value.stage == "execute_generated", label .. " generated envelope")
          check(value.source_identity == "callback-identity.spec", label .. " generated source identity")
          check(value.detail == native_detail, label .. " generated inner detail identity")
        end
      end
    end
  end
end

-- The same frame owner restores every store after a failed callback body.
do
  local scoped = require("linkedspec.runtime_scoped_binding")
  local context = {
    variables = {value = "outer"},
    arrays = {value = json.array({"outer-array"})},
    harrays = {value = json.harray({key = "outer-harray"})},
    binding_identities = {value = {}},
  }
  local identity = context.binding_identities.value
  local sentinel = {}
  local ok, failure = pcall(function()
    scoped.run(context, "value", "argument", function(value) return value end, function()
      context.variables.value = "changed"
      context.variables.state = "kept"
      error(sentinel, 0)
    end)
  end)
  check(not ok and failure == sentinel, "failed frame preserves original error")
  check(context.variables.value == "outer", "failed frame restores scalar")
  check(json.encode(context.arrays.value) == '["outer-array"]', "failed frame restores Array")
  check(json.encode(context.harrays.value) == '{"key":"outer-harray"}', "failed frame restores Hash")
  check(context.binding_identities.value == identity, "failed frame restores binding identity")
  check(context.variables.state == "kept", "failed frame preserves unrelated effects")
end
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("callback identity checks passed: ", checks, "\n")
