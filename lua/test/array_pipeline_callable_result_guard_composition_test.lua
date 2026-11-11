local input_root = os.getenv("LINKEDSPEC_CALLABLE_PIPELINE_INPUT_ROOT") or ""
-- TYPE-REFERENCE-BOOK.1.2.23.3.79.6.5: installed-host callable pipeline guards.
assert(loadfile(input_root .. "lua/src/linkedspec/interpreter.lua"))
assert(loadfile(input_root .. "lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
local observation = dofile(input_root .. "lua/test/callable_array_pipeline_observation.lua")
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("CALLABLE_PIPELINE_LUA_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\n")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local grammar_file = assert(io.open(input_root .. "specs/user_function_definition.spec", "rb"))
local grammar = grammar_file:read("*a"); grammar_file:close()
io.stdout:write("CALLABLE_PIPELINE_LUA_NORMAL_GRAMMAR ", json.encode(json.harray({path="specs/user_function_definition.spec",source=grammar})), "\n")
local function_parser = l.user_function_definition_ast_parser_from_spec_source(grammar)

local function verify(valid, label)
  checks = checks + 1
  if not valid then failures[#failures + 1] = label end
end

local function fixture(name)
  local file = assert(io.open(input_root .. "tests/fixtures/" .. name, "rb"))
  local value = json.decode(file:read("*a")); file:close()
  return value
end

local function retained_input(output, directory, identifier, extension, body)
  if output == nil or output == "" then return body end
  local path = output .. "/" .. directory .. "/" .. identifier .. extension
  local file = assert(io.open(path, "wb"))
  file:write(body); file:close()
  file = assert(io.open(path, "rb"))
  local retained = file:read("*a"); file:close()
  assert(retained == body, "normal artifact readback drift")
  return retained
end

local function observe(row, output)
  if output ~= nil and output ~= "" then
    assert(output:match("^docs/checkpoints/array%-pipeline%-callable%-lua%-2026%-11%-11/[a-z]+/[a-z]+$"), "owned capture path required")
  end
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(row.source, function_parser)
    local serialized = retained_input(output, "parsed", row.id, ".json", json.encode(l.spec_ast.to_json(parsed)))
    local restored_spec = l.spec_ast.from_json("SpecFile", json.decode(serialized))
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(restored_spec)
    local identity = "callable-array-pipeline/" .. row.id .. ".spec"
    local emitted = retained_input(output, "emitted", row.id, ".lua", l.emit_lua_source_v2(compiled, identity))
    local parser = assert((loadstring or load)(emitted))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), row.input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), row.input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), row.input, identity) end},
      {"fresh", function() return parser.execute(row.input) end},
    }
  end)
  if not ok then return json.harray({preparation_error=tostring(prepared)}) end
  local actual = json.harray({})
  for _, route in ipairs(prepared) do actual[route[1]] = observation.observe(l, route[2]) end
  return actual
end

local host = jit and "luajit" or "puc"
local profiles = assert(fixture("array_pipeline_callable_result_guard_lua_profiles.json")[host])
for _, row in ipairs(fixture("array_pipeline_callable_result_guard_lua_cases.json")) do
  local actual = observe(row, os.getenv("LINKEDSPEC_CALLABLE_PIPELINE_CAPTURE"))
  io.stdout:write("CALLABLE_PIPELINE_LUA_NORMAL ", row.id, " ", json.encode(actual), "\n")
  verify(actual.preparation_error == nil, row.id .. " prepares")
  local profile = profiles[row.id]
  verify(profile ~= nil and profile.source == row.source, row.id .. " exact source profile")
  for _, route in ipairs({"native", "restored", "plan", "fresh"}) do
    verify(actual[route] ~= nil and profile ~= nil and json.encode(actual[route]) == json.encode(profile[route]), row.id .. " " .. route)
  end
end
io.stdout:write("CALLABLE_PIPELINE_LUA_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
