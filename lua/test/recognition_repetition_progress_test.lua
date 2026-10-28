-- TYPE-REFERENCE-BOOK.1.2.23.3.39.4.6 — live recognition progress, both Lua ABIs.
local ls = require('linkedspec')
local json = ls.json
local file = assert(io.open('lua/test/recognition_repetition_progress_cases.json', 'rb'))
local fixtures = json.decode(file:read('*a'))
assert(file:close())
local assertions = 0
local function check(condition, label)
  assertions = assertions + 1
  assert(condition, label)
end
local function observe(operation, is_result)
  local ok, value = pcall(operation)
  if ok then
    if is_result then return { value = value.value, result = value } end
    return { value = value }
  end
  return { error = value }
end
for _, fixture in ipairs(fixtures) do
  local parsed = ls.parse_spec_with_staged_user_function_definitions(fixture.source)
  local compiled = ls.compile_spec(parsed)
  local restored = ls.spec_ast.from_json('SpecFile', json.decode(json.encode(ls.spec_ast.to_json(parsed))))
  for _, row in ipairs(fixture.cases) do
    local emitter = ls.trace_emitter(ls.trace_config_enabled(ls.TRACE_LOW), {
      stdout_writer = function() end,
    })
    local routes = {
      native = observe(function()
        return ls.runtime_parse(ls.runtime_engine(compiled), row.input, { trace = emitter })
      end, true),
      restored = observe(function()
        return ls.runtime_parse(ls.runtime_engine(ls.compile_spec(restored)), row.input)
      end, true),
      plan = observe(function()
        return ls.execute_generated_parser_v2(
          compiled, ls.build_generated_rule_plan(compiled), row.input, 'lua-live-progress.spec'
        )
      end, false),
    }
    local record = json.kind(row.expected) == 'harray' and row.expected.error_record or nil
    for route, actual in pairs(routes) do
      if record then
        check(actual.error ~= nil and tostring(actual.error):find(record.code, 1, true) ~= nil,
          fixture.name .. ' ' .. route .. ' progress code')
        if route ~= 'plan' then
          check(ls.is_runtime_interpreter_error(actual.error), fixture.name .. ' typed runtime failure')
          local diagnostic = ls.interpreter.to_json(actual.error.diagnostic)
          check(diagnostic.code == record.code, fixture.name .. ' diagnostic code')
          check(diagnostic.rule_label == record.rule, fixture.name .. ' failing rule')
          check(diagnostic.stage == 'runtime_execution', fixture.name .. ' runtime phase')
        end
      else
        check(actual.error == nil, fixture.name .. ' ' .. route .. ' completes')
        check(json.encode(actual.value) == json.encode(row.expected), fixture.name .. ' ' .. route .. ' value')
      end
    end
    if record then
      local observed = {}
      for _, event in ipairs(ls.trace_events(emitter)) do
        if event.topic == 'lua_runtime:recognition_repetition_progress_failure' then
          observed[#observed + 1] = event.details
        end
      end
      local expected = 'code=' .. record.code .. ' rule=' .. record.rule .. ' origin=' .. record.origin ..
        ' start_offset=' .. record.start_offset .. ' end_offset=' .. record.end_offset
      check(#observed == 1 and observed[1] == expected, fixture.name .. ' actual progress trace')
    end
  end
end
print('Lua live recognition repetition progress: ' .. assertions .. ' assertions, ' .. #fixtures .. ' sources')
