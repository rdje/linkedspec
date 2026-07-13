local json = require("linkedspec.json")

local M = {}

M.CONTRACT_ID = "linkedspec-scalar-numeric-v1"

local UNARY = {
  num_abs = true,
  num_floor = true,
  num_ceil = true,
  num_round = true,
}

local VARIADIC = {
  num_add = true,
  num_mul = true,
  num_min = true,
  num_max = true,
}

local BINARY = {
  num_sub = true,
  num_div = true,
  num_mod = true,
}

local COMPARISON = {
  num_eq = true,
  num_ne = true,
  num_gt = true,
  num_ge = true,
  num_lt = true,
  num_le = true,
}

local REDUCER = {
  num_sum = true,
  num_avg = true,
  num_median = true,
  num_range = true,
  num_min = true,
  num_max = true,
}

local SUPPORTED = {}
for name in pairs(UNARY) do SUPPORTED[name] = true end
for name in pairs(VARIADIC) do SUPPORTED[name] = true end
for name in pairs(BINARY) do SUPPORTED[name] = true end
for name in pairs(COMPARISON) do SUPPORTED[name] = true end
SUPPORTED.num_clamp = true

local function is_finite(value)
  return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function is_decimal_text(value)
  if type(value) ~= "string" or value == "" then return false end
  local body = value
  if body:sub(1, 1) == "-" then
    body = body:sub(2)
    if body == "" then return false end
  end
  return body:match("^%d+$") ~= nil or
    body:match("^%d+%.%d+$") ~= nil or
    body:match("^%.%d+$") ~= nil
end

local function scalar_number(value)
  if is_finite(value) then return value end
  if not is_decimal_text(value) then return nil end
  local parsed = tonumber(value)
  if not is_finite(parsed) then return nil end
  return parsed
end

local function normalize(value)
  if not is_finite(value) then return json.null end
  if value == 0 then return 0 end
  return value
end

local function valid_arity(name, count)
  if UNARY[name] then return count == 1 end
  if VARIADIC[name] then return count >= 2 end
  if BINARY[name] or COMPARISON[name] then return count == 2 end
  if name == "num_clamp" then return count == 3 end
  return false
end

local function numeric_args(args)
  local values = {}
  for index, value in ipairs(args) do
    local parsed = scalar_number(value)
    if parsed == nil then return nil end
    values[index] = parsed
  end
  return values
end

function M.supports(name)
  return SUPPORTED[name] == true
end

function M.is_comparison(name)
  return COMPARISON[name] == true
end

function M.supports_reducer(name)
  return REDUCER[name] == true
end

function M.evaluate_reducer(name, args)
  if not M.supports_reducer(name) then
    error("unsupported numeric reducer '" .. tostring(name) .. "'", 2)
  end
  if type(args) ~= "table" or #args ~= 1 or json.kind(args[1]) ~= "array" then return json.null end
  local values = numeric_args(args[1])
  if values == nil then return json.null end
  if #values == 0 then return name == "num_sum" and 0 or json.null end

  local total = 0
  for _, value in ipairs(values) do total = total + value end
  if name == "num_sum" then return normalize(total) end
  if name == "num_avg" then return normalize(total / #values) end

  table.sort(values)
  if name == "num_median" then
    local middle = math.floor(#values / 2) + 1
    if #values % 2 == 1 then return normalize(values[middle]) end
    return normalize((values[middle - 1] + values[middle]) / 2)
  end
  if name == "num_range" then return normalize(values[#values] - values[1]) end
  if name == "num_min" then return normalize(values[1]) end
  return normalize(values[#values])
end

function M.evaluate(name, args)
  if not M.supports(name) then
    error("unsupported scalar numeric helper '" .. tostring(name) .. "'", 2)
  end
  if type(args) ~= "table" or not valid_arity(name, #args) then return json.null end
  local values = numeric_args(args)
  if values == nil then return json.null end

  local result
  if name == "num_add" then
    result = 0
    for _, value in ipairs(values) do result = result + value end
  elseif name == "num_mul" then
    result = 1
    for _, value in ipairs(values) do result = result * value end
  elseif name == "num_sub" then
    result = values[1] - values[2]
  elseif name == "num_div" then
    if values[2] == 0 then return json.null end
    result = values[1] / values[2]
  elseif name == "num_mod" then
    if values[2] == 0 or values[1] ~= math.floor(values[1]) or values[2] ~= math.floor(values[2]) then
      return json.null
    end
    result = values[1] - math.floor(values[1] / values[2]) * values[2]
  elseif name == "num_abs" then
    result = math.abs(values[1])
  elseif name == "num_floor" then
    result = math.floor(values[1])
  elseif name == "num_ceil" then
    result = math.ceil(values[1])
  elseif name == "num_round" then
    result = values[1] >= 0 and math.floor(values[1] + 0.5) or math.ceil(values[1] - 0.5)
  elseif name == "num_min" then
    result = values[1]
    for index = 2, #values do result = math.min(result, values[index]) end
  elseif name == "num_max" then
    result = values[1]
    for index = 2, #values do result = math.max(result, values[index]) end
  elseif name == "num_clamp" then
    if values[2] > values[3] then return json.null end
    result = math.min(math.max(values[1], values[2]), values[3])
  else
    local comparison =
      (name == "num_eq" and values[1] == values[2]) or
      (name == "num_ne" and values[1] ~= values[2]) or
      (name == "num_gt" and values[1] > values[2]) or
      (name == "num_ge" and values[1] >= values[2]) or
      (name == "num_lt" and values[1] < values[2]) or
      (name == "num_le" and values[1] <= values[2])
    result = comparison and 1 or 0
  end
  return normalize(result)
end

return M
