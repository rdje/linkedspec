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

function M.run(context, name, value, copy_value, callback)
  require_table(context, "context")
  if type(name) ~= "string" or name == "" then
    error("RuntimeScopedBindingException: binding name must be a non-empty string", 0)
  end
  if type(copy_value) ~= "function" then
    error("RuntimeScopedBindingException: copy_value must be a function", 0)
  end
  if type(callback) ~= "function" then
    error("RuntimeScopedBindingException: callback must be a function", 0)
  end

  local stores = {}
  local snapshots = {}
  for index, store_name in ipairs(STORE_NAMES) do
    local store = require_table(context[store_name], "context." .. store_name)
    stores[index] = store
    snapshots[index] = snapshot_store(store, name, copy_value)
  end
  for _, store in ipairs(stores) do
    store[name] = nil
  end

  local ok, result = pcall(function()
    context.variables[name] = copy_value(value)
    return copy_value(callback())
  end)
  for index, store in ipairs(stores) do
    restore_store(store, name, snapshots[index])
  end
  if not ok then error(result, 0) end
  return result
end

return M
