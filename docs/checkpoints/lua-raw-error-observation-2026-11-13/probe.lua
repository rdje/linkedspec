assert(#arg == 3, "cases, owned output and SDK input root required")
local cases_path, output, input_root = arg[1], arg[2], arg[3]
assert(output:match("^docs/checkpoints/lua%-raw%-error%-observation%-2026%-11%-13/epochs/[a-z]+/[a-z]+$"))
assert(input_root == "" or input_root:match("^%.linkedspec%-data/raw%-error%-audit/[a-z]+/$"))
local l = require("linkedspec")
local json = l.json
local full = dofile("lua/test/raw_error_observation.lua")
local previous = dofile("lua/test/callable_array_transform_observation.lua")
io.stdout:setvbuf("no")
io.stdout:write("RAW_ERROR_OWNER ", debug.getinfo(l.runtime_execute, "S").source, "\n")
io.stdout:write("RAW_ERROR_HOST ", _VERSION, " ", jit and jit.version or "", "\n")

local function read(path)
  local file = assert(io.open(path, "rb"))
  local body = file:read("*a"); file:close()
  return body
end

local function persist(name, body)
  local path = output .. "/" .. name
  local file = assert(io.open(path, "wb"))
  file:write(body); file:close()
  assert(read(path) == body, "actual consumed artifact readback")
  return read(path)
end

local function old_record(failure)
  local ok, value = pcall(previous.observe, l, function() error(failure, 0) end)
  if not ok then return "observer-failure:" .. tostring(value) end
  return json.encode(value)
end

local function changed(value)
  if type(value) == "string" then return value .. "__field_control" end
  if type(value) == "number" then return value + 1 end
  if type(value) == "boolean" then return not value end
  error("selected mutation requires a scalar field", 0)
end

local function mutations(failure)
  local rows = json.array()
  local before = json.encode(full.snapshot(l, failure))
  local old_before = old_record(failure)
  local function walk(container, prefix)
    local keys = {}
    for key in pairs(container) do keys[#keys + 1] = key end
    table.sort(keys, function(left, right)
      if type(left) == type(right) then return left < right end
      return type(left) < type(right)
    end)
    for _, key in ipairs(keys) do
      local original = container[key]
      local path = prefix .. key
      if type(original) == "table" and original ~= json.null then
        walk(original, path .. ".")
      elseif type(original) == "string" or type(original) == "number" or type(original) == "boolean" then
        for _, operation in ipairs({"change", "remove"}) do
          if operation == "change" then container[key] = changed(original)
          else container[key] = nil end
          local new_changed = json.encode(full.snapshot(l, failure)) ~= before
          local old_changed = old_record(failure) ~= old_before
          container[key] = original
          assert(new_changed, "complete selected field observation missed " .. path)
          rows[#rows + 1] = json.harray({ path=path, operation=operation,
            raw_observer_changed=new_changed, prior_observer_changed=old_changed })
        end
      end
    end
  end
  if type(failure) == "table" then
    walk(failure, "")
    assert(failure.audit_unpublished_marker == nil)
    failure.audit_unpublished_marker = "distinguishing added outer field"
    local added_changed = json.encode(full.snapshot(l, failure)) ~= before
    assert(added_changed, "added outer field must change the raw observation")
    rows[#rows + 1] = json.harray({ path="audit_unpublished_marker", operation="add",
      raw_observer_changed=added_changed,
      prior_observer_changed=old_record(failure) ~= old_before })
    failure.audit_unpublished_marker = nil
  end
  assert(json.encode(full.snapshot(l, failure)) == before and old_record(failure) == old_before,
    "all field controls restore the exact observations")
  return rows
end

local function_parser = l.user_function_definition_ast_parser_from_spec_source(
  read(input_root .. "specs/user_function_definition.spec"))
for _, row in ipairs(json.decode(read(cases_path))) do
  assert(row.id:match("^[a-z][a-z0-9_]*$"))
  local parsed = l.parse_spec_with_staged_user_function_definitions(row.source, function_parser)
  local serialized = persist(row.id .. ".parsed.json", json.encode(l.spec_ast.to_json(parsed)))
  local restored_spec = l.spec_ast.from_json("SpecFile", json.decode(serialized))
  local compiled = l.compile_spec(parsed)
  local restored = l.compile_spec(restored_spec)
  local identity = "raw-error-audit/" .. row.id .. ".spec"
  local emitted = persist(row.id .. ".emitted.lua", l.emit_lua_source_v2(compiled, identity))
  local fresh = assert((loadstring or load)(emitted))()
  local routes = {
    {"native", function() return l.runtime_execute(l.runtime_engine(compiled), row.input).value end},
    {"restored", function() return l.runtime_execute(l.runtime_engine(restored), row.input).value end},
    {"plan", function() return l.execute_generated_parser_v2(compiled, l.build_generated_rule_plan(compiled), row.input, identity) end},
    {"fresh", function() return fresh.execute(row.input) end},
  }
  local result = json.harray({})
  for _, route in ipairs(routes) do
    local ok, failure = pcall(route[2])
    assert(not ok, "selected authored error unexpectedly succeeded: " .. row.id .. "/" .. route[1])
    result[route[1]] = json.harray({ observation=full.observe_failure(l, failure),
      prior_observation=old_record(failure), mutations=mutations(failure) })
  end
  io.stdout:write("RAW_ERROR_CASE ", row.id, " ", json.encode(result), "\n")
end
