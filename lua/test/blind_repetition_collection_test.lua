-- TYPE-REFERENCE-BOOK.1.2.23.3.39.4.4 — implicit blind iteration values.
local ls = require('linkedspec')
local json = ls.json
local file = assert(io.open('lua/test/blind_repetition_collection_cases.json', 'rb'))
local fixtures = json.decode(file:read('*a'))
assert(file:close())
local assertions, owned, dormant = 0, 0, 0
local function check(condition, label)
  assertions = assertions + 1
  assert(condition, label)
end
for _, fixture in ipairs(fixtures) do
  if fixture.name == 'default' or fixture.name == 'postcall_return' then
    dormant = dormant + 1
    local owner = fixture.name == 'default' and '39.4.9' or '39.4.5'
    print('OWNED DORMANT ' .. fixture.name .. ' TYPE-REFERENCE-BOOK.1.2.23.3.' .. owner)
  else
    owned = owned + 1
  local parsed = ls.parse_spec_with_staged_user_function_definitions(fixture.source)
  local compiled = ls.compile_spec(parsed)
  local restored = ls.spec_ast.from_json('SpecFile', json.decode(json.encode(ls.spec_ast.to_json(parsed))))
  for _, row in ipairs(fixture.cases) do
    local operations = {
      native = function() return ls.runtime_parse(ls.runtime_engine(compiled), row.input) end,
      restored = function()
        return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)), row.input)
      end,
      plan = function()
        return ls.execute_generated_parser_v2(
          compiled, ls.build_generated_rule_plan(compiled), row.input, 'lua-blind-collection.spec'
        )
      end,
    }
    for route, operation in pairs(operations) do
      local ok, actual = pcall(operation)
      check(ok, fixture.name .. ' ' .. route .. ' completes: ' .. tostring(actual))
      if route == 'plan' then
        check(json.encode(actual) == json.encode(row.expected), fixture.name .. ' generated value')
      else
        check(json.encode(actual.value) == json.encode(row.expected), fixture.name .. ' ' .. route .. ' value')
        check(actual.matched == row.expected_match, fixture.name .. ' ' .. route .. ' matched')
        check(actual.cursor_code_unit == row.expected_cursor, fixture.name .. ' ' .. route .. ' cursor')
      end
    end
  end
  end
end
print('Lua implicit blind iteration collections: ' .. assertions .. ' assertions, ' .. owned .. ' sources, ' .. dormant .. ' owned dormant')
