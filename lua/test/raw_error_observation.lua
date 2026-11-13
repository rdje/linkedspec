-- Test-only, finite value observation. Public SDK serialization stays separate.
local M = {}

function M.snapshot(l, value)
  local active = {}
  local function visit(item)
    if item == l.json.null then return l.json.harray({ kind = "null" }) end
    local kind = type(item)
    if kind == "string" or kind == "boolean" then
      return l.json.harray({ kind = kind, value = item })
    elseif kind == "number" then
      assert(item == item and item ~= math.huge and item ~= -math.huge,
        "raw error observation requires finite numbers")
      return l.json.harray({ kind = kind, value = item })
    end
    assert(kind == "table", "unsupported raw error field value: " .. kind)
    assert(not active[item], "raw error observation does not accept cycles")
    active[item] = true
    local keys, fields = {}, l.json.array()
    for key in pairs(item) do
      assert(type(key) == "string" or type(key) == "number", "unsupported raw error field key")
      keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
      if type(left) == type(right) then return left < right end
      return type(left) < type(right)
    end)
    for _, key in ipairs(keys) do
      fields[#fields + 1] = l.json.harray({ key = visit(key), value = visit(item[key]) })
    end
    active[item] = nil
    return l.json.harray({ kind = "table", fields = fields })
  end
  return visit(value)
end

function M.observe_failure(l, failure)
  local runtime = l.is_runtime_interpreter_error(failure)
  local generated = l.is_generated_source_error(failure)
  local published
  if runtime then published = l.interpreter.to_json(failure)
  elseif generated then published = l.generated_source_error_to_json(failure) end
  return l.json.harray({
    runtime = runtime,
    generated = generated,
    text = tostring(failure),
    fields = M.snapshot(l, failure),
    published = published,
  })
end

return M
