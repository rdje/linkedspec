local input_root = os.getenv("LINKEDSPEC_ARRAY_PIPELINE_INPUT_ROOT") or ""
-- TYPE-REFERENCE-BOOK.1.2.23.3.79.5 — installed-host ordinary Array-pipeline result guards.
assert(loadfile(input_root .. "lua/src/linkedspec/interpreter.lua"))
assert(loadfile(input_root .. "lua/test/run.lua"))
local l = require("linkedspec")
local json = l.json
io.stdout:write("ARRAY_PIPELINE_LUA_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\n")
local failures, checks = {}, 0
io.stdout:setvbuf("no")
io.stdout:write("HOST ", _VERSION, " ", jit and jit.version or "", "\n")
local grammar_file = assert(io.open(input_root .. "specs/user_function_definition.spec", "rb"))
local grammar = grammar_file:read("*a"); grammar_file:close()
io.stdout:write("ARRAY_PIPELINE_LUA_NORMAL_GRAMMAR ", json.encode(json.harray({path="specs/user_function_definition.spec",source=grammar})), "\n")
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
local function observe(identifier, source, input, output)
  if output ~= nil and output ~= "" then
    assert(output:match("^docs/checkpoints/array%-pipeline%-result%-guard%-lua%-2026%-11%-11/[a-z]+/[a-z]+$"), "owned capture path required")
  end
  local ok, prepared = pcall(function()
    local parsed = l.parse_spec_with_staged_user_function_definitions(source, function_parser)
    local compiled = l.compile_spec(parsed)
    local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(json.encode(l.spec_ast.to_json(parsed)))))
    local emitted = l.emit_lua_source_v2(compiled, "array-pipeline-result-guard/" .. identifier .. ".spec")
    if output ~= nil and output ~= "" then
      local function persist(directory, extension, body)
        local file = assert(io.open(output .. "/" .. directory .. "/" .. identifier .. extension, "wb"))
        file:write(body); file:close()
      end
      persist("emitted", ".lua", emitted)
      persist("parsed", ".json", json.encode(l.spec_ast.to_json(parsed)))
      io.stdout:write("ARRAY_PIPELINE_LUA_INPUT ", identifier, " ", json.encode(l.spec_ast.to_json(parsed)), "\n")
    end
    local parser = assert((loadstring or load)(emitted))()
    return {
      {"native", function() return l.runtime_execute(l.runtime_engine(compiled), input).value end},
      {"restored", function() return l.runtime_execute(l.runtime_engine(restored), input).value end},
      {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), input, "array-pipeline-result-guard/" .. identifier .. ".spec") end},
      {"fresh", function() return parser.execute(input) end},
    }
  end)
  if not ok then return json.harray({compile_error=tostring(prepared)}) end
  local result = json.harray({})
  for _, route in ipairs(prepared) do
    local success, value = pcall(route[2])
    result[route[1]] = success and json.harray({value=value}) or json.harray({error=tostring(value),runtime=l.is_runtime_interpreter_error(value),generated=l.is_generated_source_error(value),helper_name=type(value)=="table" and value.helper_name or nil,diagnostic_code=type(value)=="table" and value.diagnostic and value.diagnostic.code or nil,diagnostic_stage=type(value)=="table" and value.diagnostic and value.diagnostic.stage or nil,code=type(value)=="table" and value.code or nil,actual_arity=type(value)=="table" and value.actual_arity or nil,expected_arity=type(value)=="table" and value.expected_arity or nil})
  end
  return result
end
local host = jit and "luajit" or "puc"
local profiles = assert(fixture("array_pipeline_result_guard_lua_profiles.json")[host])
local cases = fixture("array_pipeline_result_guard_lua_cases.json")
for _, row in ipairs(cases) do
  local actual = observe(row.id, row.source, row.input, os.getenv("LINKEDSPEC_ARRAY_PIPELINE_CAPTURE"))
  io.stdout:write("ARRAY_PIPELINE_LUA_NORMAL ", row.id, " ", json.encode(actual), "\n")
  verify(actual.compile_error == nil, row.id .. " compiles")
  local profile = profiles[row.id]
  if profile then verify(profile.source == row.source, row.id .. " source-bound profile") end
  for _, route in ipairs({"native", "restored", "plan", "fresh"}) do
    local expected = profile and profile[route] or json.harray({value=row.expected})
    verify(actual[route] ~= nil and json.encode(actual[route]) == json.encode(expected), row.id .. " " .. route)
  end
end
io.stdout:write("ARRAY_PIPELINE_LUA_SUMMARY ", checks, " checks ", #failures, " failures\n")
if #failures > 0 then error(table.concat(failures, "\n"), 0) end
