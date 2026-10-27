-- TYPE-REFERENCE-BOOK.1.2.23.3.29.2.5 — safe pure-function boundary controls.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function source(definitions, action)
  return definitions .. "\nTop::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {" .. action .. "}\n"
end
local function routes(spec)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(spec))
  return {
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), "name=Alpha").value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), "name=Alpha", "function-state-boundary.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "function-state-boundary.spec")))()
      return parser.execute("name=Alpha")
    end},
  }
end
local function reject(spec, helper)
  for _, route in ipairs(routes(spec)) do
    local ok, actual = pcall(route[2])
    local text = ok and json.encode(actual) or tostring(actual)
    io.stdout:write("FUNCTION_STATE ", helper, " ", route[1], " ", tostring(ok), " ", text, "\n")
    local valid = not ok and text:find("parser-state helper", 1, true) and text:find(helper, 1, true)
    if valid and route[1] == "native" then
      valid = l.is_runtime_interpreter_error(actual) and actual.helper_name == helper
    elseif valid then
      valid = l.is_generated_source_error(actual)
    end
    if not valid then failures[#failures + 1] = helper .. " " .. route[1] .. ": " .. text end
  end
end
for _, helper in ipairs({"entry_groups", "match_groups", "entry_map", "match_map", "entry_named_map", "match_named_map", "entry_group", "match_group"}) do
  local argument = helper:sub(-5) == "group" and "0" or ""
  reject(source("fn forbidden(){return(" .. helper .. "(" .. argument .. "))}", "return(forbidden())"), helper)
end
for _, row in ipairs({{"input_text", "input_text()"}, {"cursor_pos", "cursor_pos()"}, {"entry_start_pos", "entry_start_pos()"}, {"mark_pos", "mark_pos(point)"}, {"capture_slice", "capture_slice()"}, {"save_cursor", "save_cursor()"}}) do
  reject(source("fn forbidden(){return(" .. row[2] .. ")}", "return(forbidden())"), row[1])
end
reject(source("fn inner(){return(entry_groups())}\nfn outer(){match_map();return(inner())}", "return(outer())"), "match_map")
local pure = source("fn entry_custom(text){local_text=text.uppercase();return(local_text)}\nfn capture_custom(text){return(entry_custom(text))}", 'return([capture_custom(entry_group(0)),capture_custom(match_named("value")),entry_groups().last().uppercase(),match_map()["value"].uppercase()])')
for _, route in ipairs(routes(pure)) do
  local ok, actual = pcall(function() return json.encode(route[2]()) end)
  io.stdout:write("FUNCTION_STATE_PURE ", route[1], " ", tostring(actual), "\n")
  if not ok or actual ~= '[["NAME","ALPHA","NAME","ALPHA"]]' then failures[#failures+1] = "pure " .. route[1] .. ": " .. tostring(actual) end
end
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("function state checks passed\n")
