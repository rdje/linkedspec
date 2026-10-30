-- TYPE-REFERENCE-BOOK.1.2.23.3.55.5 — detached gap/slot record reads.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end
local function fixture(extension)
  local file = assert(io.open("tests/fixtures/gap_slot_record_selection_values." .. extension, "r"))
  local value = file:read("*a"); assert(file:close()); return value
end
local function observe(source, input)
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local parser = assert((loadstring or load)(l.emit_lua_source_v2(compiled, "gap-slot-selection.spec")))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "gap-slot-selection.spec") end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value),runtime=l.is_runtime_interpreter_error(value),generated=l.is_generated_source_error(value),helper_name=type(value)=="table" and value.helper_name or nil,diagnostic_code=type(value)=="table" and value.diagnostic and value.diagnostic.code or nil,diagnostic_stage=type(value)=="table" and value.diagnostic and value.diagnostic.stage or nil})
  end
  return result
end
local function check_value(label, source, input, expected_json)
  local actual = observe(source, input)
  local expected = json.encode(json.decode(expected_json))
  io.stdout:write("GAP_SLOT_SELECTION ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " compiles")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    verify(row ~= nil and row.error == nil and json.encode(row.value) == expected, label .. " " .. route)
  end
end
local function function_fence(label, source, helper)
  local actual = observe(source, "x")
  io.stdout:write("GAP_SLOT_SELECTION_FENCE ", label, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, label .. " remains runtime diagnosed")
  for _, route in ipairs({"native","restored","plan","fresh"}) do
    local row = actual[route]
    local native = route == "native" or route == "restored"
    verify(row ~= nil and row.error ~= nil, label .. " " .. route .. " rejects")
    verify(row ~= nil and row.runtime == native and row.generated == (not native), label .. " " .. route .. " typed envelope")
    local message = row and row.error
    local specific = message ~= nil and
      message:find("parser-state helper", 1, true) ~= nil and
      message:find("'" .. helper .. "'", 1, true) ~= nil and
      message:find("not supported in user functions", 1, true) ~= nil
    verify(specific and (not native or row.helper_name == helper),
      label .. " " .. route .. " authored helper diagnostic")
  end
end

local function gap_source(definitions, action, item)
  return definitions .. "\nList::\n @capture_gaps\n I {rows=[]}\n -> Item[word] {" .. action .. "}\n LX {return(rows)}\nItem:\n word=/[^,;]+/\n I {" .. item .. "}\n"
end
local function error_fence(label,source,helper,code,stage)
  local actual=observe(source,"x")
  io.stdout:write("GAP_SLOT_ERROR ",label," ",json.encode(actual),"\n")
  verify(actual.compile_error==nil,label .. " compiles")
  for _,route in ipairs({"native","restored","plan","fresh"}) do
    local row=actual[route]
    local native=route=="native" or route=="restored"
    verify(row~=nil and row.error~=nil and row.runtime==native and row.generated==(not native) and row.error:find(code,1,true)~=nil,label .. " " .. route .. " typed error")
    if native then
      verify(row~=nil and row.helper_name==helper and row.diagnostic_code==code and row.diagnostic_stage==stage,label .. " " .. route .. " helper diagnostic")
    end
  end
end
check_value("shared",fixture("spec"),"a,b",fixture("json"))
check_value("primitive_records",gap_source("","push(rows,[gap_span(),call(Item)])","return(entry_slot())"),"a,b",[=[[[{"source_id":"input","start":0,"end":0,"provenance":"gap"},{"target_rule":"Item","regex_index":0,"slot_id":"word","selector_kind":"named","authored_selector":"word"}],[{"source_id":"input","start":1,"end":2,"provenance":"gap"},{"target_rule":"Item","regex_index":0,"slot_id":"word","selector_kind":"named","authored_selector":"word"}]]]=])
check_value("bound_fields",gap_source("",[=[span=gap_span();push(rows,[span["start"].add(1),call(Item)])]=],[=[entry_record=entry_slot();return(entry_record["slot_id"].uppercase())]=]),"a,b",[=[[[1,"WORD"],[2,"WORD"]]]=])
check_value("direct_zero",gap_source("",[=[push(rows,[gap_span()["end"].coalesce(99).cat("!"),call(Item)])]=],[=[return([entry_slot()["regex_index"].coalesce(99).add(1),entry_slot()["slot_id"].uppercase()])]=]),"a,b",[=[[["0!",[1,"WORD"]],["2!",[1,"WORD"]]]]=])
check_value("null_slot_kinds_signed",[=[Top:: I {return([entry_slot(),entry_slot()["missing"].coalesce("M"),entry_slot()["missing"].coalesce(false),entry_slot()["missing"].coalesce(0),entry_slot()["missing"].coalesce(["a","tail"])[-1].uppercase()])}]=],"x",[=[[null,"M",false,0,"TAIL"]]=])
error_fence("primitive_gap_context","Top:: I {return(gap_span())}","gap_span","gap_capture_context_unavailable","access_gap_context")
error_fence("selected_gap_context",[=[Top:: I {return(gap_span()["start"].coalesce(99))}]=],"gap_span","gap_capture_context_unavailable","access_gap_context")
for _,pair in ipairs({{"gap_span","start"},{"entry_slot","slot_id"}}) do
  local helper,field=pair[1],pair[2]
  local definitions='fn selected(){return(' .. helper .. '()["' .. field .. '"].coalesce("M"))}'
  function_fence(helper .. "_function",gap_source(definitions,"push(rows,selected())","return(entry_text())"),helper)
end
check_value("explicit_record_arguments",gap_source([=[fn selected(span,item){return([span["start"].add(1),item])}
fn identify(slot){return(slot["slot_id"].uppercase())}]=],"push(rows,selected(gap_span(),call(Item)))","return(identify(entry_slot()))"),"a,b",[=[[[1,"WORD"],[2,"WORD"]]]=])
for _,helper in ipairs({"entry_slot","gap_span","gap_text","gap_kind"}) do
  for _,argument in ipairs({"1","extra:1"}) do
    error_fence(helper .. "_" .. argument,"Top:: I {return(" .. helper .. "(" .. argument .. "))}",helper,"helper_arity_mismatch","helper_arity_mismatch")
  end
end
io.stdout:write("GAP_SLOT_SELECTION_SUMMARY ",checks," checks ",#failures," failures\n")
if #failures>0 then error(table.concat(failures,"\n"),0) end
io.stdout:write("gap/slot record selection checks passed: ",checks,"\n")
