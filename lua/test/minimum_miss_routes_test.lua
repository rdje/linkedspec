-- TYPE-REFERENCE-BOOK.1.2.23.3.39.4.3 — ordinary minima preserve cursor and errors.
local ls = require('linkedspec')
local json = ls.json
local file = assert(io.open('lua/test/minimum_miss_routes_cases.json', 'rb'))
local fixtures = json.decode(file:read('*a'))
assert(file:close())
local assertions = 0
local function check(condition, label)
  assertions = assertions + 1
  assert(condition, label)
end
for _, fixture in ipairs(fixtures) do
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
          compiled, ls.build_generated_rule_plan(compiled), row.input, 'lua-minimum.spec'
        )
      end,
    }
    local expected_error = json.kind(row.expected) == 'harray' and row.expected.error_contains or nil
    for route, operation in pairs(operations) do
      local ok, actual = pcall(operation)
      if expected_error then
        check(not ok and tostring(actual):find(expected_error, 1, true) ~= nil,
          fixture.name .. ' ' .. route .. ' original error')
        if route ~= 'plan' then
          check(actual.diagnostic ~= nil, fixture.name .. ' original diagnostic')
          local diagnostic = ls.interpreter.to_json(actual.diagnostic)
          check(diagnostic.rule_label == row.expected.error_rule, fixture.name .. ' failing rule')
          check(diagnostic.stage == 'runtime_execution', fixture.name .. ' runtime phase')
        end
      else
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
print('Lua ordinary minimum miss routes: ' .. assertions .. ' assertions, ' .. #fixtures .. ' sources')
