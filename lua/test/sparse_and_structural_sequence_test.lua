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
        local native=ls.runtime_parse(ls.runtime_engine(compiled),item.input)
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
        end
    end
  end
end
print('Lua sparse AND structural sequence: '..assertions..' assertions, '..healthy..' healthy sources, '..dormant..' owned dormant')
