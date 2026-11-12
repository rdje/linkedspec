assert(#arg == 2, "owned trace sources and output required")
assert(arg[2]:match("^docs/checkpoints/array%-transform%-callable%-lua%-2026%-11%-12/trace/[a-z]+$"))
local l = require("linkedspec")
local json = l.json
local observation = dofile("lua/test/callable_array_transform_observation.lua")
io.stdout:setvbuf("no")
io.stdout:write("CALLABLE_TRANSFORM_LUA_TRACE_OWNER ", debug.getinfo(l.runtime_execute,"S").source, "\n")
local grammar_file = assert(io.open("specs/user_function_definition.spec", "rb"))
local grammar = grammar_file:read("*a"); grammar_file:close()
io.stdout:write("CALLABLE_TRANSFORM_LUA_TRACE_GRAMMAR ", json.encode(grammar), "\n")
local function_parser = l.user_function_definition_ast_parser_from_spec_source(grammar)
local source_file = assert(io.open(arg[1], "rb"))
local cases = json.decode(source_file:read("*a")); source_file:close()
local function persist(name, body)
  local path = arg[2] .. "/" .. name
  local file = assert(io.open(path, "wb")); file:write(body); file:close()
  file = assert(io.open(path, "rb")); local retained = file:read("*a"); file:close()
  assert(retained == body)
end
for _, row in ipairs(cases) do
  assert(row.id:match("^[a-z][a-z0-9_]*$"))
  local config = l.with_trace_reset_file(l.with_trace_file(l.trace_config_enabled(l.TRACE_DEBUG), arg[2] .. "/" .. row.id .. ".trace.log"))
  local emitter = l.trace_emitter(config)
  local parsed = l.parse_spec_with_staged_user_function_definitions(row.source, function_parser, {trace=emitter})
  persist(row.id .. ".parsed.json", json.encode(l.spec_ast.to_json(parsed)))
  local compiled = l.compile_spec(parsed, {trace=emitter})
  local payloads = json.array({})
  for _, payload in ipairs(l.compiled_spec.action_payloads(compiled.rules_by_label.Value)) do
    payloads[#payloads + 1] = l.action_ast.to_json(payload.action_ast)
  end
  persist(row.id .. ".compiled.json", json.encode(payloads))
  local actual = observation.observe(l, function()
    return l.runtime_execute(l.runtime_engine(compiled), row.input, {trace=emitter}).value
  end)
  io.stdout:write("CALLABLE_TRANSFORM_LUA_TRACE ", row.id, " ", json.encode(actual), "\n")
end
