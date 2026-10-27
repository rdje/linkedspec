-- TYPE-REFERENCE-BOOK.1.2.23.3.29.2.6.5 — safe parser-context controls.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures = {}
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function gap_source(definitions, action, item)
  return definitions .. "\nList::\n @capture_gaps\n I {set(rows,array())}\n -> Item[word] {" .. action .. "}\n LX {return(copy(rows))}\nItem:\n word=/[^,;]+/\n I {" .. item .. "}\n"
end
local function routes(source, input)
  local compiled = l.compile_spec(l.parse_spec_with_staged_user_function_definitions(source))
  return {
    {"native", function() return l.runtime_parse(l.runtime_engine(compiled), input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "function-parser-context.spec") end},
    {"fresh", function()
      local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "function-parser-context.spec")))()
      return parser.execute(input)
    end},
  }
end
local function reject(source, input, helper)
  for _, route in ipairs(routes(source, input)) do
    local ok, actual = pcall(route[2])
    local text = ok and json.encode(actual) or tostring(actual)
    io.stdout:write("FUNCTION_CONTEXT ", helper, " ", route[1], " ", tostring(ok), " ", text, "\n")
    local valid = not ok and text:find("parser-state helper", 1, true) and text:find(helper, 1, true)
    if valid and route[1] == "native" then
      valid = l.is_runtime_interpreter_error(actual) and actual.helper_name == helper
    elseif valid then
      valid = l.is_generated_source_error(actual)
    end
    if not valid then failures[#failures+1] = helper .. " " .. route[1] .. ": " .. text end
  end
end
local function check_values(source, input, expected)
  expected = json.encode(json.decode(expected))
  for _, route in ipairs(routes(source, input)) do
    local ok, actual = pcall(function() return json.encode(route[2]()) end)
    io.stdout:write("FUNCTION_CONTEXT_PURE ", route[1], " ", tostring(actual), "\n")
    if not ok or actual ~= expected then failures[#failures+1] = "pure " .. route[1] .. ": " .. tostring(actual) end
  end
end
reject('fn selected(){return(call(Child))}\nTop:: I {return(selected())}\nChild: I {return("child")}\n', "x", "call")
for _, helper in ipairs({"gap_text", "gap_kind", "gap_span", "entry_slot"}) do
  reject(gap_source("fn selected(){return(" .. helper .. "())}", "push(rows,selected())", "return(entry_text())"), "a,b", helper)
end
reject(gap_source("fn selected(){return(entry_slot())}", "push(rows,call(Item))", "return(selected())"), "a,b", "entry_slot")
check_values('fn upper(text){return(text.uppercase())}\nTop:: I {return(upper(call(Child)))}\nChild: I {return("child")}\n', "x", '"CHILD"')
check_values(gap_source("fn selected(text,kind,span){return([text.uppercase(),kind,span])}", "push(rows,selected(gap_text(),gap_kind(),gap_span()))", "return(entry_text())"), "a,b", '[["","prefix",{"source_id":"input","start":0,"end":0,"provenance":"gap"}],[",","interstitial",{"source_id":"input","start":1,"end":2,"provenance":"gap"}]]')
check_values(gap_source("fn identify(slot){return(slot)}", "push(rows,call(Item))", "return(identify(entry_slot()))"), "a,b", '[{"target_rule":"Item","regex_index":0,"slot_id":"word","selector_kind":"named","authored_selector":"word"},{"target_rule":"Item","regex_index":0,"slot_id":"word","selector_kind":"named","authored_selector":"word"}]')
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("function context checks passed\n")
