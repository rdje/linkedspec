-- TYPE-REFERENCE-BOOK.1.2.23.3.39.4.8 — ordinary and callable unknown diagnostics.
local ls = require('linkedspec')
local json = ls.json
local file = assert(io.open('lua/test/runtime_unknown_helper_diagnostic_cases.json', 'rb'))
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
      restored = function() return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)), row.input) end,
      plan = function()
        return ls.execute_generated_parser_v2(
          compiled, ls.build_generated_rule_plan(compiled), row.input, 'lua-unknown-helper.spec'
        )
      end,
    }
    for route, operation in pairs(operations) do
      local ok, actual = pcall(operation)
      local label = fixture.name .. ' ' .. route
      if row.error_code then
        check(not ok, label .. ' fails closed')
        check(tostring(actual):find(row.error_contains, 1, true) ~= nil, label .. ' error text')
        if route == 'plan' then
          -- This public envelope does not expose the inner SDK code.
          check(actual.code == 'generated_execution_failed', label .. ' generated envelope')
          check(actual.stage == 'execute_generated', label .. ' generated stage')
          check(actual.rule_label == row.error_rule, label .. ' generated failing rule')
        else
          check(ls.is_runtime_interpreter_error(actual), label .. ' typed runtime error')
          local diagnostic = actual.diagnostic
          check(diagnostic.code == row.error_code, label .. ' machine-readable code')
          check(diagnostic.stage == row.error_stage, label .. ' owning stage')
          check(diagnostic.rule_label == row.error_rule, label .. ' failing rule')
        end
      else
        check(ok, label .. ' completes: ' .. tostring(actual))
        if route == 'plan' then
          check(json.encode(actual) == json.encode(row.expected), label .. ' generated value')
        else
          check(json.encode(actual.value) == json.encode(row.expected), label .. ' value')
          check(actual.matched == row.expected_match, label .. ' match flag')
          check(actual.cursor_code_unit == row.expected_cursor, label .. ' cursor')
        end
      end
    end
  end
end
print('Lua ordinary unknown-helper diagnostics: ' .. assertions .. ' assertions, ' .. #fixtures .. ' sources')
