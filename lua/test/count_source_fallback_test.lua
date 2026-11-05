-- TYPE-REFERENCE-BOOK.1.2.23.3.73.6.5 — initial Count source permission.
assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")

local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end

local function observe(row)
  local parsed = l.parse_spec_with_staged_user_function_definitions(row.source)
  local compiled = l.compile_spec(parsed)
  local restored = l.compile_spec(l.spec_ast.from_json("SpecFile",
    json.decode(json.encode(l.spec_ast.to_json(parsed)))))
  local emitted = l.emit_lua_source_v2(compiled, "count-source-fallback.spec")
  local capture = os.getenv("LINKEDSPEC_COUNT_SOURCE_CAPTURE")
  if capture then
    -- Preserve actual public AST/module inputs before loading or execution.
    local file = assert(io.open(capture .. "/" .. row.id .. ".lua", "w"))
    file:write(emitted); file:close()
    file = assert(io.open(capture .. "/" .. row.id .. ".ast.json", "w"))
    file:write(json.encode(l.spec_ast.to_json(parsed))); file:close()
  end
  local parser = assert((loadstring or load)(emitted))()
  local result = json.harray({})
  for _, route in ipairs({
    {"native", function() return l.runtime_execute(l.runtime_engine(compiled), row.input).value end},
    {"restored", function() return l.runtime_execute(l.runtime_engine(restored), row.input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled,
      l.build_generated_rule_plan(compiled), row.input, "count-source-fallback.spec") end},
    {"fresh", function() return parser.execute(row.input) end},
  }) do
    local ok, value = pcall(route[2])
    result[route[1]] = ok and json.harray({value=value}) or json.harray({
      error=tostring(value), runtime=l.is_runtime_interpreter_error(value),
      generated=l.is_generated_source_error(value),
    })
  end
  return result
end

local file = assert(io.open("tests/fixtures/count_boolean_source_cases.json", "r"))
local cases = json.decode(file:read("*a")); file:close()
for _, row in ipairs(cases) do
  local ok, actual = pcall(observe, row)
  verify(ok, row.id .. " compiles and loads")
  if ok then
    io.stdout:write("COUNT_SOURCE_LUA ", row.id, " ", json.encode(actual), "\n")
    for _, route in ipairs({"native", "restored", "plan", "fresh"}) do
      local value = actual[route]
      if row.expected_error then
        verify(value and value.error and value.error:find(row.expected_error, 1, true), row.id .. " " .. route)
      else
        local expected = row.expected
        if row.expected_nonperl ~= nil then expected = row.expected_nonperl end
        -- JSON encoding distinguishes Boolean false, Number zero, String and null.
        verify(value and value.error == nil and json.encode(value.value) == json.encode(expected), row.id .. " " .. route)
      end
    end
  else
    io.stdout:write("COUNT_SOURCE_LUA_SETUP ", row.id, " ", tostring(actual), "\n")
  end
end
io.stdout:write("COUNT_SOURCE_LUA_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
