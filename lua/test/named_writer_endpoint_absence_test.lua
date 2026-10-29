-- TYPE-REFERENCE-BOOK.1.2.23.3.49.5 — unavailable named capture endpoints.
assert(loadfile('lua/src/linkedspec/interpreter.lua'))
assert(loadfile('lua/test/run.lua'))
local ls = require('linkedspec')
local json = ls.json
local file = assert(io.open('tests/fixtures/named_writer_endpoint_absence.json', 'rb'))
local fixtures = json.decode(file:read('*a')); assert(file:close())
local assertions, failures = 0, {}
local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end
for _, fixture in ipairs(fixtures) do
  local parsed = ls.parse_spec_with_staged_user_function_definitions(fixture.source)
  local restored = ls.spec_ast.from_json('SpecFile', json.decode(json.encode(ls.spec_ast.to_json(parsed))))
  local compiled = ls.compile_spec(parsed)
  for _, spec in ipairs({compiled, ls.compile_spec(restored)}) do
    local result = ls.runtime_parse(ls.runtime_engine(spec), fixture.input)
    check(result.matched == true, fixture.name .. ' matched')
    check(json.encode(result.value) == json.encode(fixture.expected), fixture.name .. ' value')
    check(result.cursor_char_offset == fixture.expected_cursor, fixture.name .. ' Unicode cursor')
  end
  local value = ls.execute_generated_parser_v2(
    compiled, ls.build_generated_rule_plan(compiled), fixture.input, 'named-writer-endpoint-absence.spec'
  )
  check(json.encode(value) == json.encode(fixture.expected), fixture.name .. ' plan value')
end
print('Lua local-match writer endpoint presence: ' .. assertions .. ' assertions, ' .. #failures .. ' failures')
if #failures > 0 then
  for _, failure in ipairs(failures) do io.stderr:write(failure, '\n') end
  os.exit(1)
end
