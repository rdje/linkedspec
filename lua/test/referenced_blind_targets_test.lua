-- TYPE-REFERENCE-BOOK.1.2.23.3.48.5: blind declarations versus action slots.
local ls = require('linkedspec')
local json = ls.json
local assertions, failures = 0, {}
local function check(condition, label)
  assertions=assertions+1
  if not condition then failures[#failures+1]=label end
end
local function read(path)
  local file=assert(io.open(path,'rb'));local data=file:read('*a');assert(file:close());return data
end
for _, name in ipairs({'referenced_blind_intermediate','referenced_blind_intermediate_qualified',
    'pure_blind_targets','referenced_blind_intermediate_negatives'}) do
  for _, fixture in ipairs(json.decode(read('tests/fixtures/'..name..'.json'))) do
    local parsed=ls.parse_spec_with_staged_user_function_definitions(fixture.source)
    local ok,compiled=pcall(ls.compile_spec,parsed)
    local label=name..'/'..fixture.name
    check(ok==fixture.expected_builds,label..' compilation')
    if not fixture.expected_builds then
      check(not ok and ls.is_spec_validation_error(compiled),label..' strict validation error')
    elseif ok then
      local restored=ls.spec_ast.from_json('SpecFile',json.decode(json.encode(ls.spec_ast.to_json(parsed))))
      check(json.encode(ls.compiled_spec_to_json(ls.compile_spec(restored)))==
        json.encode(ls.compiled_spec_to_json(compiled)),label..' normalized compile')
      check(#ls.build_generated_rule_plan(compiled)>0,label..' generated plan')
      if name=='pure_blind_targets' then
        check(#compiled.rules_by_label.Child.regex_patterns==0,label..' no regex')
        check(#compiled.rules_by_label.Child.regex_slots==0,label..' no slot')
        local entry=compiled.dependency_regex_state.dependency_regex_map.Top
        if fixture.name=='mixed_regex_child' then
          check(entry and #entry.dependency_refs==1 and entry.dependency_refs[1].label=='Token' and
            #entry.patterns==1 and entry.patterns[1]=='x',label..' real regex map')
          check(#compiled.rules_by_label.Top.dependency_refs==2,label..' complete call refs')
        else
          check(entry==nil,label..' no manufactured regex map')
        end
      end
      local excluded=fixture.name=='blind_no_regex' or fixture.name=='marked_blind_target' or
        fixture.name=='markerless_blind'
      -- Original parent LX is unqualified48.2.2.1; the three qualified
      -- coordinators retain empty-tail progress authority under39.8.1.
      if name~='referenced_blind_intermediate' and not excluded then
        local cases=fixture.input and {fixture} or fixture.cases or {}
        for _,case in ipairs(cases) do
          for _,state in ipairs({compiled,ls.compile_spec(restored)}) do
            local result=ls.runtime_parse(ls.runtime_engine(state),case.input)
            check(json.encode(result.value)==json.encode(case.expected),label..' runtime value')
            check(result.matched,label..' matched')
            check(result.cursor_char_offset==case.expected_cursor,label..' cursor')
          end
          local result=ls.execute_generated_parser_v2(compiled,ls.build_generated_rule_plan(compiled),
            case.input,'referenced-blind.spec')
          check(json.encode(result)==json.encode(case.expected),label..' plan value')
        end
      end
    end
  end
end
for _,source in ipairs({
  'Top::AND\n -> Child\n => Child\nChild:\n I{return("C")}\n',
  'Top::AND\n /x/ -> Child\n => Child\nChild:\n I{return("C")}\n',
  'Top::AND\n => Missing\n',
}) do
  local ok,value=pcall(ls.compile_spec,ls.parse_spec(source),{validate_source=false})
  check(not ok and ls.is_compiled_spec_error(value),'strict validation bypass')
end
local empty=ls.compile_spec(ls.parse_spec('Top::AND\n => Child {return(retv)}\nChild:|\n // -> Child[0] {return("E")}\n'))
check(#empty.rules_by_label.Child.regex_patterns==1 and empty.rules_by_label.Child.regex_patterns[1]=='',
  'real empty regex remains a pattern')
check(empty.dependency_regex_state.dependency_regex_map.Top.patterns[1]=='','real empty regex dependency')
check(ls.runtime_parse(ls.runtime_engine(empty),'x').value=='E','real empty regex runtime')
for _, label in ipairs(failures) do io.stderr:write('FAIL '..label..'\n') end
print('Lua blind target compilation: '..assertions..' assertions, '..#failures..' failures')
assert(#failures==0,'blind target compilation failures')
