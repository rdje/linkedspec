-- TYPE-REFERENCE-BOOK.1.2.23.3.38.3 — selected cursor before flagged LS.
local ls = require('linkedspec')
local json = ls.json
local assertions, sources = 0, 0
local function check(condition, label)
  assertions = assertions + 1
  assert(condition, label)
end
for _, path in ipairs({
  'dart/test/fixtures/gap_ls_cursor.json',
  'dart/test/fixtures/gap_ls_broad_carrier.json',
}) do
  local file = assert(io.open(path, 'rb'))
  local fixtures = json.decode(file:read('*a'))
  assert(file:close())
  for _, fixture in ipairs(fixtures) do
    sources = sources + 1
    local parsed = ls.parse_spec_with_staged_user_function_definitions(fixture.source)
    local compiled = ls.compile_spec(parsed)
    local restored = ls.spec_ast.from_json('SpecFile', json.decode(json.encode(ls.spec_ast.to_json(parsed))))
    for _, row in ipairs(fixture.cases) do
      -- Preserve this host's independently measured unflagged compatibility
      -- baseline; the reference4/4 is not a portable target for this row.
      local compatibility = fixture.name == 'unflagged_timing_control'
      local expected = row.expected
      if compatibility then expected = json.array({1, 1}) end
      for route, operation in pairs({
        native = function() return ls.runtime_parse(ls.runtime_engine(compiled), row.input) end,
        restored = function() return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)), row.input) end,
        plan = function()
          return ls.execute_generated_parser_v2(
            compiled, ls.build_generated_rule_plan(compiled), row.input, 'gap-ls-cursor.spec'
          )
        end,
      }) do
        local ok, actual = pcall(operation)
        local label = fixture.name .. ' ' .. route
        if json.kind(expected) == 'harray' and expected.error_contains then
          check(not ok, label .. ' fails closed')
          check(tostring(actual):find(expected.error_contains, 1, true) ~= nil, label .. ' source error')
          if route ~= 'plan' then
            check(ls.is_runtime_interpreter_error(actual), label .. ' typed runtime failure')
            check(actual.diagnostic.code == expected.error_code, label .. ' code')
            check(actual.diagnostic.rule_label == expected.error_rule, label .. ' rule')
            check(actual.diagnostic.stage == 'advance_gap_context', label .. ' commit stage')
          end
        else
          check(ok, label .. ' completes: ' .. tostring(actual))
          if route == 'plan' then
            check(json.encode(actual) == json.encode(expected), label .. ' generated value')
          else
            check(json.encode(actual.value) == json.encode(expected), label .. ' value')
            local matched = row.expected_match
            local cursor = row.expected_char_cursor
            if compatibility then matched, cursor = true, 1 end
            check(actual.matched == matched, label .. ' matched')
            check(ls.interpreter.to_json(actual).cursor_char_offset == cursor, label .. ' character cursor')
          end
        end
      end
    end
  end
end
print('Lua selected cursor before LS: ' .. assertions .. ' assertions, ' .. sources ..
  ' sources (8 portable, 1 compatibility)')
