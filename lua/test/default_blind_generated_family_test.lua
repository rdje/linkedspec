-- TYPE-REFERENCE-BOOK.1.2.23.3.39.4.9 — correct derived family, same v2 contract.
local ls = require('linkedspec')
local json = ls.json
local file = assert(io.open('lua/test/default_blind_generated_family_cases.json', 'rb'))
local fixtures = json.decode(file:read('*a'))
assert(file:close())
local assertions = 0
local defaults = { default=true, blind_default=true, default_null=true, default_zero=true }
local function check(condition, label)
  assertions = assertions + 1
  assert(condition, label)
end
for _, fixture in ipairs(fixtures) do
  local parsed = ls.parse_spec_with_staged_user_function_definitions(fixture.source)
  local compiled = ls.compile_spec(parsed)
  local restored = ls.spec_ast.from_json('SpecFile', json.decode(json.encode(ls.spec_ast.to_json(parsed))))
  local plan = ls.build_generated_rule_plan(compiled)
  local stale = {}
  for index, row in ipairs(plan) do
    local projected = ls.generated_plan_row_to_json(row)
    local count = 0
    for key in pairs(projected) do
      check(key == 'label' or key == 'family', fixture.name .. ' minimal plan key')
      count = count + 1
    end
    check(count == 2, fixture.name .. ' two plan fields')
    stale[index] = ls.generated_plan_row(row.label, row.family)
    if row.label == 'Top' then
      check(row.family == fixture.expected_family, fixture.name .. ' root family')
      if defaults[fixture.name] then stale[index] = ls.generated_plan_row(row.label, 'and_bcode') end
    end
  end
  local source = ls.emit_lua_source_v2(compiled, 'lua-default-family.spec')
  local generated = assert((loadstring or load)(source, '@lua-default-family.lua'))()
  local metadata = ls.generated_source_metadata_to_json(generated.metadata())
  check(metadata.contract_id == 'linkedspec-generated-source-v2', fixture.name .. ' contract id')
  check(metadata.format_version == 2, fixture.name .. ' format version')
  for _, row in ipairs(fixture.cases) do
    local operations = {
      native = function() return ls.runtime_parse(ls.runtime_engine(compiled), row.input) end,
      restored = function() return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)), row.input) end,
      plan = function() return ls.execute_generated_parser_v2(compiled, plan, row.input, 'lua-default-family.spec') end,
      emitted = function() return generated.execute(row.input) end,
    }
    for route, operation in pairs(operations) do
      local ok, actual = pcall(operation)
      check(ok, fixture.name .. ' ' .. route .. ' completes: ' .. tostring(actual))
      if route == 'native' or route == 'restored' then
        check(json.encode(actual.value) == json.encode(row.expected), fixture.name .. ' ' .. route .. ' value')
        check(actual.matched == row.expected_match, fixture.name .. ' ' .. route .. ' matched')
        check(actual.cursor_code_unit == row.expected_cursor, fixture.name .. ' ' .. route .. ' cursor')
      else
        check(json.encode(actual) == json.encode(row.expected), fixture.name .. ' ' .. route .. ' value')
      end
    end
  end
  if defaults[fixture.name] then
    local ok, failure = pcall(ls.execute_generated_parser_v2, compiled, stale, fixture.cases[1].input, 'lua-default-family.spec')
    check(not ok, fixture.name .. ' stale family rejected')
    check(ls.is_generated_source_error(failure), fixture.name .. ' typed stale failure')
    local diagnostic = ls.generated_source_error_to_json(failure)
    check(diagnostic.code == 'generated_plan_family_mismatch', fixture.name .. ' stale code')
    check(diagnostic.stage == 'validate_generated_plan', fixture.name .. ' validation before execution')
    check(diagnostic.rule_label == 'Top', fixture.name .. ' stale rule')
    check(diagnostic.handler_family == 'and_bcode', fixture.name .. ' stale family attribution')
  end
end
local ordinary = ls.compile_spec(ls.parse_spec('Top::\n /a/\n'))
check(ls.classify_generated_rule_family(ordinary:rule('Top')) == 'default', 'ordinary Default regex family unchanged')
print('Lua Default blind generated family: ' .. assertions .. ' assertions, ' .. #fixtures .. ' sources')
