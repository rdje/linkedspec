-- TYPE-REFERENCE-BOOK.1.2.23.4.28: selected route-specific error field regression.
local l = require("linkedspec")
local json = l.json
local observation = dofile("lua/test/raw_error_observation.lua")
local previous = dofile("lua/test/callable_array_transform_observation.lua")
local output = os.getenv("LINKEDSPEC_RAW_ERROR_CAPTURE")
if output and output ~= "" then
  assert(output:match("^docs/checkpoints/lua%-raw%-error%-observation%-2026%-11%-13/normal/[a-z]+$"))
end
local function read(path)
  local file = assert(io.open(path, "rb"))
  local body = file:read("*a"); file:close()
  return body
end
local function persist(name, body)
  if output == nil or output == "" then return body end
  local path = output .. "/" .. name
  local file = assert(io.open(path, "wb"))
  file:write(body); file:close()
  assert(read(path) == body, "actual normal input readback")
  return read(path)
end
local function old_projection(failure)
  return json.encode(previous.observe(l, function() error(failure, 0) end))
end
local host = jit and "luajit" or "puc"
local profiles = assert(json.decode(read("tests/fixtures/lua_raw_error_observation_profiles.json"))[host])
local function_parser = l.user_function_definition_ast_parser_from_spec_source(
  read("specs/user_function_definition.spec"))
local checks = 0
io.stdout:setvbuf("no")
io.stdout:write("RAW_ERROR_NORMAL_OWNER ", debug.getinfo(l.runtime_execute, "S").source, "\n")
for _, row in ipairs(json.decode(read("tests/fixtures/lua_raw_error_observation_cases.json"))) do
  local parsed = l.parse_spec_with_staged_user_function_definitions(row.source, function_parser)
  local serialized = persist(row.id .. ".parsed.json", json.encode(l.spec_ast.to_json(parsed)))
  local compiled = l.compile_spec(parsed)
  local restored = l.compile_spec(l.spec_ast.from_json("SpecFile", json.decode(serialized)))
  local identity = "raw-error-audit/" .. row.id .. ".spec"
  local emitted = persist(row.id .. ".emitted.lua", l.emit_lua_source_v2(compiled, identity))
  local fresh = assert((loadstring or load)(emitted))()
  local routes = {
    {"native", function() return l.runtime_execute(l.runtime_engine(compiled), row.input).value end},
    {"restored", function() return l.runtime_execute(l.runtime_engine(restored), row.input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), row.input, identity) end},
    {"fresh", function() return fresh.execute(row.input) end},
  }
  local actual = json.harray({})
  for _, route in ipairs(routes) do
    local ok, failure = pcall(route[2])
    assert(not ok, row.id .. "/" .. route[1] .. " must retain its failure")
    local captured = observation.observe_failure(l, failure)
    local baseline = json.encode(captured)
    assert(baseline == json.encode(profiles[row.id][route[1]]), row.id .. "/" .. route[1] .. " complete observed fields")
    checks = checks + 1
    actual[route[1]] = captured
    if l.is_runtime_interpreter_error(failure) then
      local field = failure.code == "binding_kind_mismatch" and "expected_kind" or "rule_label"
      local original = assert(failure[field])
      local raw_before = json.encode(observation.snapshot(l, failure))
      local old_before = old_projection(failure)
      for _, operation in ipairs({"change", "remove"}) do
        if operation == "change" then failure[field] = original .. "__field_control"
        else failure[field] = nil end
        assert(json.encode(observation.snapshot(l, failure)) ~= raw_before, "raw field " .. operation .. " must be detected")
        assert(old_projection(failure) == old_before, "prior projection's known blind field remains explicit")
        failure[field] = original
        assert(json.encode(observation.observe_failure(l, failure)) == baseline, "control restores exact fields")
        checks = checks + 3
      end
    end
  end
  io.stdout:write("RAW_ERROR_NORMAL ", row.id, " ", json.encode(actual), "\n")
end
io.stdout:write("RAW_ERROR_NORMAL_SUMMARY ", checks, " checks PASS\n")
