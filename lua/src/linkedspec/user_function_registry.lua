local action_ast = require("linkedspec.action_ast")
local action_parser = require("linkedspec.action_parser")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")

local M = {}

local ERROR_MT = {
  __tostring = function(value)
    return "UserFunctionRegistryException: " .. value.message
  end,
}

local ENTRY_MT = { __user_function_type = "UserFunctionEntry" }
local RESOLUTION_MT = { __user_function_type = "UserFunctionCallResolution" }
local FRAME_MT = { __user_function_type = "UserFunctionInvocationFrame" }

local RegistryMethods = {}
local REGISTRY_MT = {
  __user_function_type = "UserFunctionRegistry",
  __index = RegistryMethods,
}

local function fail(message, fields)
  fields = fields or {}
  fields.message = message
  error(setmetatable(fields, ERROR_MT), 0)
end

function M.is_registry_error(value)
  return getmetatable(value) == ERROR_MT
end

function M.node_type(value)
  if type(value) ~= "table" then
    return nil
  end
  local metatable = getmetatable(value)
  return metatable and metatable.__user_function_type or nil
end

local function copy_list(values)
  local result = {}
  for index, value in ipairs(values) do
    result[index] = value
  end
  return result
end

local function validate_dense_list(values, context)
  if type(values) ~= "table" then
    fail(context .. " must be a dense list")
  end
  local count = 0
  local max_index = 0
  for key in pairs(values) do
    if type(key) ~= "number" or key % 1 ~= 0 or key < 1 then
      fail(context .. " must use one-based integer indexes")
    end
    count = count + 1
    if key > max_index then max_index = key end
  end
  if count ~= max_index then
    fail(context .. " must not be sparse")
  end
  return values
end

local function clone_runtime_value(value, active)
  local value_type = type(value)
  if value == json.null or value_type == "string" or value_type == "number" or value_type == "boolean" then
    return value
  end
  if action_ast.node_type(value) == "ActionExpr" and value.kind == "block_value" then
    local copied = action_parser.parse_action_expression(value.source)
    if copied.kind ~= "block_value" then
      fail("evaluated codeblock arguments must carry parseable block_value source")
    end
    return copied
  end
  local kind = json.kind(value)
  if kind ~= "array" and kind ~= "harray" then
    fail("evaluated function arguments must be scalar, array, harray, or codeblock values")
  end
  active = active or {}
  if active[value] then
    fail("evaluated function arguments must not be cyclic")
  end
  active[value] = true
  local result
  if kind == "array" then
    result = json.array()
    for index, item in ipairs(value) do
      result[index] = clone_runtime_value(item, active)
    end
  else
    result = json.harray()
    for key, item in pairs(value) do
      if type(key) ~= "string" then
        fail("evaluated harray arguments must use string keys")
      end
      result[key] = clone_runtime_value(item, active)
    end
  end
  active[value] = nil
  return result
end

local function entry(index, definition)
  return setmetatable({ index = index, definition = definition }, ENTRY_MT)
end

local function call_resolution(name, requested_arity, expected_arities, matched_entry)
  local expected = copy_list(expected_arities)
  local name_known = #expected > 0
  return setmetatable({
    name = name,
    requested_arity = requested_arity,
    expected_arities = expected,
    entry = matched_entry,
    name_known = name_known,
    matched = matched_entry ~= nil,
    arity_mismatch = name_known and matched_entry == nil,
  }, RESOLUTION_MT)
end

local function validate_registry(registry)
  if M.node_type(registry) ~= "UserFunctionRegistry" then
    fail("expected UserFunctionRegistry")
  end
  return registry
end

function M.from_functions(functions)
  validate_dense_list(functions, "functions")
  local entries = {}
  local by_name = {}
  for index, definition in ipairs(functions) do
    if spec_ast.node_type(definition) ~= "FunctionDefinition" then
      fail("functions must contain only FunctionDefinition values")
    end
    if by_name[definition.name] then
      fail("duplicate user function '" .. definition.name .. "'")
    end
    local copied_definition = spec_ast.from_json("FunctionDefinition", spec_ast.to_json(definition))
    local item = entry(index - 1, copied_definition)
    entries[#entries + 1] = item
    by_name[definition.name] = { item }
  end
  return setmetatable({ entries = entries, by_name = by_name }, REGISTRY_MT)
end

function M.from_spec(spec)
  if spec_ast.node_type(spec) ~= "SpecFile" then
    fail("from_spec expects SpecFile")
  end
  return M.from_functions(spec.functions)
end

function M.empty()
  return M.from_functions({})
end

function RegistryMethods:names()
  validate_registry(self)
  local result = {}
  for index, item in ipairs(self.entries) do
    result[index] = item.definition.name
  end
  return result
end

function RegistryMethods:body_parse_jobs()
  validate_registry(self)
  local result = {}
  for _, item in ipairs(self.entries) do
    if item.definition.body_parse_job then
      result[#result + 1] = item.definition.body_parse_job
    end
  end
  return result
end

function RegistryMethods:has_name(name)
  validate_registry(self)
  return type(name) == "string" and self.by_name[name] ~= nil
end

function RegistryMethods:expected_arities_for(name)
  validate_registry(self)
  if type(name) ~= "string" then fail("expected_arities_for name must be a string") end
  local values = self.by_name[name]
  if not values then return {} end
  local result = {}
  for index, item in ipairs(values) do
    result[index] = item.definition.arity
  end
  return result
end

function RegistryMethods:lookup(name)
  validate_registry(self)
  if type(name) ~= "string" then fail("lookup name must be a string") end
  local values = self.by_name[name]
  return values and values[1] or nil
end

function RegistryMethods:resolve_exact(name, arity)
  validate_registry(self)
  if type(name) ~= "string" or type(arity) ~= "number" or arity % 1 ~= 0 or arity < 0 then
    fail("resolve_exact expects a string name and non-negative integer arity")
  end
  local values = self.by_name[name]
  if not values then return nil end
  for _, item in ipairs(values) do
    if item.definition.arity == arity then return item end
  end
  return nil
end

function RegistryMethods:resolve_call(name, arity)
  validate_registry(self)
  local expected = self:expected_arities_for(name)
  return call_resolution(name, arity, expected, self:resolve_exact(name, arity))
end

local function projected_definition(definition)
  return spec_ast.to_json(definition)
end

local function entry_to_json(item)
  local result = projected_definition(item.definition)
  result.index = item.index
  return result
end

local function resolution_to_json(value)
  local expected = json.array()
  for index, arity in ipairs(value.expected_arities) do expected[index] = arity end
  local result = json.harray({
    name = value.name,
    requested_arity = value.requested_arity,
    expected_arities = expected,
    name_known = value.name_known,
    matched = value.matched,
    arity_mismatch = value.arity_mismatch,
  })
  if value.entry then result.entry = entry_to_json(value.entry) end
  return result
end

function M.to_descriptor_json(item)
  if M.node_type(item) ~= "UserFunctionEntry" then
    fail("to_descriptor_json expects UserFunctionEntry")
  end
  local definition = item.definition
  local projected = projected_definition(definition)
  return json.harray({
    index = item.index,
    kind = "user_function_definition",
    version = 1,
    name = definition.name,
    params = projected.params,
    arity = definition.arity,
    source_text = definition.source,
    source_span = projected.source_span,
    body_span = projected.body_span,
    body_source = definition.body_source,
    body_payload = projected.body_payload,
    body_parse_job = projected.body_parse_job,
    body_ast = projected.body_ast,
  })
end

function M.to_json(value)
  local node_type = M.node_type(value)
  if node_type == "UserFunctionRegistry" then
    local functions = json.array()
    for index, item in ipairs(value.entries) do functions[index] = entry_to_json(item) end
    local jobs = json.array()
    for index, job in ipairs(value:body_parse_jobs()) do jobs[index] = spec_ast.to_json(job) end
    return json.harray({ functions = functions, body_parse_jobs = jobs })
  elseif node_type == "UserFunctionEntry" then
    return entry_to_json(value)
  elseif node_type == "UserFunctionCallResolution" then
    return resolution_to_json(value)
  end
  fail("to_json expects a user function registry, entry, or call resolution")
end

local function definition_with_body_ast(definition, body_ast)
  return spec_ast.function_definition({
    name = definition.name,
    params = definition.params,
    arity = definition.arity,
    body_source = definition.body_source,
    body_payload = definition.body_payload,
    body_parse_job = definition.body_parse_job,
    body_ast = body_ast,
    source = definition.source,
    source_span = definition.source_span,
    body_span = definition.body_span,
  })
end

function M.stitch_function_body_ast(spec, job_id, body_ast)
  if spec_ast.node_type(spec) ~= "SpecFile" then fail("stitch_function_body_ast expects SpecFile") end
  if type(job_id) ~= "string" then fail("stitch_function_body_ast job_id must be a string") end
  local functions = {}
  local found = false
  for index, definition in ipairs(spec.functions) do
    local job = definition.body_parse_job
    if job and job.job_id == job_id then
      if job.result_policy ~= "replace_field" or job.result_field ~= "body_ast" then
        fail("function body parse job '" .. job_id .. "' cannot stitch into body_ast")
      end
      functions[index] = definition_with_body_ast(definition, body_ast)
      found = true
    else
      functions[index] = definition
    end
  end
  if not found then fail("function body parse job '" .. job_id .. "' not found") end
  return spec_ast.spec_file({ functions = functions, rules = spec.rules })
end

local function recursion_cycle(active_names, name)
  for index, active_name in ipairs(active_names) do
    if active_name == name then
      local cycle = {}
      for active_index = index, #active_names do cycle[#cycle + 1] = active_names[active_index] end
      cycle[#cycle + 1] = name
      return table.concat(cycle, " -> ")
    end
  end
  return nil
end

function M.prepare_invocation(registry, name, evaluated_values, active_names, options)
  validate_registry(registry)
  validate_dense_list(evaluated_values, "evaluated_values")
  active_names = validate_dense_list(active_names or {}, "active_names")
  options = options or {}
  if type(options) ~= "table" then fail("invocation options must be a table") end
  if options.rule_label ~= nil and type(options.rule_label) ~= "string" then
    fail("invocation rule_label must be a string when present")
  end
  for _, active_name in ipairs(active_names) do
    if type(active_name) ~= "string" then fail("active_names must contain only strings") end
  end

  local resolution = registry:resolve_call(name, #evaluated_values)
  if not resolution.name_known then
    fail("unknown user function '" .. tostring(name) .. "'", { code = "unknown_user_function" })
  elseif resolution.arity_mismatch then
    fail(
      "user function '" .. name .. "' expects arity " .. table.concat(resolution.expected_arities, " or ") ..
        ", got " .. #evaluated_values,
      { code = "user_function_arity_mismatch", stage = "user_function_call", helper_name = name }
    )
  end

  local cycle = recursion_cycle(active_names, name)
  if cycle then
    local detail = "user function recursion is not supported: " .. cycle
    if options.rule_label then detail = detail .. " in rule " .. options.rule_label end
    fail(
      detail,
      {
        code = "user_function_recursion",
        stage = "user_function_call",
        summary = "Lua user function recursion failed",
        helper_name = name,
        rule_label = options.rule_label,
        handler_source_label = "lua_runtime:function:" .. name,
        cycle = cycle,
      }
    )
  end

  local arguments = {}
  local variables = {}
  local arrays = {}
  local harrays = {}
  for index, param in ipairs(resolution.entry.definition.params) do
    local value = clone_runtime_value(evaluated_values[index])
    arguments[index] = value
    variables[param] = clone_runtime_value(value)
    local kind = json.kind(value)
    if kind == "array" then
      arrays[param] = clone_runtime_value(value)
    elseif kind == "harray" then
      harrays[param] = clone_runtime_value(value)
    end
  end
  local active_path = copy_list(active_names)
  active_path[#active_path + 1] = name
  return setmetatable({
    entry = resolution.entry,
    arguments = arguments,
    variables = variables,
    arrays = arrays,
    harrays = harrays,
    active_path = active_path,
  }, FRAME_MT)
end

return M
