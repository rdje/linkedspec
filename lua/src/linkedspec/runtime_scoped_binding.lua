local M = {}

local STORE_NAMES = { "variables", "arrays", "harrays" }

local function require_table(value, label)
  if type(value) ~= "table" then
    error("RuntimeScopedBindingException: " .. label .. " must be a table", 0)
  end
  return value
end

local function snapshot_store(store, name, copy_value)
  local present = store[name] ~= nil
  local value
  if present then value = copy_value(store[name]) end
  return {
    present = present,
    value = value,
  }
end

local function restore_store(store, name, snapshot)
  store[name] = nil
  if snapshot.present then store[name] = snapshot.value end
end

local function validated_bindings(bindings)
  require_table(bindings, "bindings")
  local normalized = {}
  local seen = {}
  for index, binding in ipairs(bindings) do
    require_table(binding, "bindings[" .. index .. "]")
    local name = binding.name
    if type(name) ~= "string" or name == "" then
      error("RuntimeScopedBindingException: binding name must be a non-empty string", 0)
    end
    if seen[name] then
      error("RuntimeScopedBindingException: duplicate scoped binding '" .. name .. "'", 0)
    end
    seen[name] = true
    normalized[index] = { name = name, value = binding.value }
  end
  return normalized
end

function M.run_frame(context, bindings, copy_value, callback)
  require_table(context, "context")
  if type(copy_value) ~= "function" then
    error("RuntimeScopedBindingException: copy_value must be a function", 0)
  end
  if type(callback) ~= "function" then
    error("RuntimeScopedBindingException: callback must be a function", 0)
  end
  bindings = validated_bindings(bindings)
  if context.binding_identities == nil then context.binding_identities = {} end
  local identities = require_table(context.binding_identities, "context.binding_identities")

  local stores = {}
  for index, store_name in ipairs(STORE_NAMES) do
    stores[index] = require_table(context[store_name], "context." .. store_name)
  end

  local frame = {}
  for binding_index, binding in ipairs(bindings) do
    local snapshots = {}
    for store_index, store in ipairs(stores) do
      snapshots[store_index] = snapshot_store(store, binding.name, copy_value)
    end
    frame[binding_index] = {
      name = binding.name,
      snapshots = snapshots,
      identity_present = identities[binding.name] ~= nil,
      identity = identities[binding.name],
    }
  end
  for _, binding in ipairs(bindings) do
    for _, store in ipairs(stores) do store[binding.name] = nil end
    identities[binding.name] = {}
  end

  local ok, result = pcall(function()
    for _, binding in ipairs(bindings) do
      context.variables[binding.name] = copy_value(binding.value)
    end
    return copy_value(callback())
  end)
  for binding_index = #frame, 1, -1 do
    local saved = frame[binding_index]
    for store_index, store in ipairs(stores) do
      restore_store(store, saved.name, saved.snapshots[store_index])
    end
    identities[saved.name] = saved.identity_present and saved.identity or nil
  end
  if not ok then error(result, 0) end
  return result
end

function M.run(context, name, value, copy_value, callback)
  return M.run_frame(context, { { name = name, value = value } }, copy_value, callback)
end

return M
