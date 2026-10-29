-- TYPE-REFERENCE-BOOK.1.2.23.3.39.4.0 — independent safe installed-host intake.
local ls = require('linkedspec')
local json = ls.json
local function read(path)
  local file=assert(io.open(path,'rb'))
  local value=file:read('*a');assert(file:close());return value
end
local rows=json.decode(read('lua/test/sparse_and_structural_sequence_cases.json'))
local owners=json.decode(read('lua/test/sparse_and_structural_sequence_owners.json'))
local assertions,healthy,dormant=0,0,0
local function check(condition,message)
  assertions=assertions+1
  assert(condition,message)
end
for _,row in ipairs(rows) do
  if owners[row.name] then
    dormant=dormant+1
    print('OWNED DORMANT '..row.name..' '..owners[row.name])
  else
    healthy=healthy+1
    local parsed=ls.parse_spec_with_staged_user_function_definitions(row.source)
    local restored=ls.spec_ast.from_json('SpecFile',json.decode(json.encode(ls.spec_ast.to_json(parsed))))
    local compiled=ls.compile_spec(parsed)
    for _,item in ipairs(row.cases) do
      local error_contains=json.kind(item.expected)=='harray' and item.expected.error_contains or nil
      if error_contains then
        local operations={
          function() return ls.runtime_parse(ls.runtime_engine(compiled),item.input) end,
          function() return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)),item.input) end,
          function() return ls.execute_generated_parser_v2(compiled,ls.build_generated_rule_plan(compiled),item.input,'lua-sparse-intake.spec') end,
        }
        for _,operation in ipairs(operations) do
          local ok,failure=pcall(operation)
          check(not ok and tostring(failure):find(error_contains,1,true)~=nil,row.name..' expected error')
        end
      else
        local emitter=ls.trace_emitter(ls.trace_config_enabled(ls.TRACE_HIGH),{
          stdout_writer=function() end,
        })
        local semantic_slots={}
        local native=ls.runtime_parse(ls.runtime_engine(compiled),item.input,{
          trace=emitter,
          semantic_observation_sink=function(event)
            local record=ls.runtime_semantic_observation_event_to_json(event)
            if record.event_kind=='regex_slot_selected' then
              semantic_slots[#semantic_slots+1]=record.target_rule..'#'..record.regex_index..'@'..record.position
            end
          end,
        })
        local reconstructed=ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)),item.input)
        local plan=ls.execute_generated_parser_v2(compiled,ls.build_generated_rule_plan(compiled),item.input,'lua-sparse-intake.spec')
        check(json.encode(native.value)==json.encode(item.expected),row.name..' native value')
        check(json.encode(reconstructed.value)==json.encode(item.expected),row.name..' reconstructed value')
        check(json.encode(plan)==json.encode(item.expected),row.name..' generated value')
        check(json.encode(ls.interpreter.to_json(native))==json.encode(ls.interpreter.to_json(reconstructed)),row.name..' reconstructed result')
        if row.name=='falsey_null' then
          check(native.matched==true,'selected null remains matched')
          check(native.cursor_code_unit==4,'selected null consumes full structure')
        end
        if (row.name=='duplicate' or row.name=='duplicate_one_slot' or row.name=='compact_duplicate') and item.input=='aa' then
          local selected={}
          for _,event in ipairs(ls.trace_events(emitter)) do
            if event.topic=='lua_runtime:regex_slot_selected' then selected[#selected+1]=event.details end
          end
          local identity='rule_label=Value selection_role=ordered_required target_rule=Value regex_index=0'
          check(#selected==2 and selected[1]==identity and selected[2]==identity,row.name..' two selected occurrences')
          check(table.concat(semantic_slots,',')=='Value#0@1,Value#0@2',row.name..' semantic occurrences and positions')
        elseif row.name=='cross_distinct_indices' and item.input=='cat' then
          local selected={}
          for _,event in ipairs(ls.trace_events(emitter)) do
            if event.topic=='lua_runtime:regex_slot_selected' then selected[#selected+1]=event.details end
          end
          check(#selected==1 and selected[1]=='rule_label=Value selection_role=ordered_required target_rule=Part regex_index=1',row.name..' logical dependency identity')
          check(table.concat(semantic_slots,',')=='Part#1@3',row.name..' semantic logical identity and position')
        end
        end
    end
  end
end
print('Lua sparse AND structural sequence: '..assertions..' assertions, '..healthy..' healthy sources, '..dormant..' owned dormant')
