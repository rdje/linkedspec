local M = {}

local ARRAY_MT = { __json_kind = "array" }
local OBJECT_MT = { __json_kind = "harray" }
local NULL_MT = {
  __json_kind = "null",
  __tostring = function()
    return "json.null"
  end,
}

M.null = setmetatable({}, NULL_MT)

local function fail(message, position)
  if position then
    error("JSON error at byte " .. position .. ": " .. message, 0)
  end
  error("JSON error: " .. message, 0)
end

function M.array(values)
  if values ~= nil and type(values) ~= "table" then
    fail("array values must be a table")
  end
  local result = setmetatable({}, ARRAY_MT)
  if values then
    for index = 1, #values do
      result[index] = values[index]
    end
  end
  return result
end

function M.harray(values)
  if values ~= nil and type(values) ~= "table" then
    fail("harray values must be a table")
  end
  local result = setmetatable({}, OBJECT_MT)
  if values then
    for key, value in pairs(values) do
      if type(key) ~= "string" then
        fail("harray keys must be strings")
      end
      result[key] = value
    end
  end
  return result
end

function M.kind(value)
  if value == M.null then
    return "null"
  end
  local value_type = type(value)
  if value_type ~= "table" then
    return value_type
  end
  local metatable = getmetatable(value)
  if metatable == ARRAY_MT then
    return "array"
  end
  if metatable == OBJECT_MT then
    return "harray"
  end
  return "table"
end

function M.validate_utf8(text)
  if type(text) ~= "string" then
    return false, 1
  end

  local index = 1
  local length = #text
  while index <= length do
    local first = text:byte(index)
    if first <= 0x7F then
      index = index + 1
    elseif first >= 0xC2 and first <= 0xDF then
      local second = text:byte(index + 1)
      if second == nil or second < 0x80 or second > 0xBF then
        return false, index
      end
      index = index + 2
    elseif first >= 0xE0 and first <= 0xEF then
      local second = text:byte(index + 1)
      local third = text:byte(index + 2)
      if second == nil or third == nil then
        return false, index
      end
      local second_min = first == 0xE0 and 0xA0 or 0x80
      local second_max = first == 0xED and 0x9F or 0xBF
      if second < second_min or second > second_max or third < 0x80 or third > 0xBF then
        return false, index
      end
      index = index + 3
    elseif first >= 0xF0 and first <= 0xF4 then
      local second = text:byte(index + 1)
      local third = text:byte(index + 2)
      local fourth = text:byte(index + 3)
      if second == nil or third == nil or fourth == nil then
        return false, index
      end
      local second_min = first == 0xF0 and 0x90 or 0x80
      local second_max = first == 0xF4 and 0x8F or 0xBF
      if second < second_min or second > second_max or
          third < 0x80 or third > 0xBF or fourth < 0x80 or fourth > 0xBF then
        return false, index
      end
      index = index + 4
    else
      return false, index
    end
  end
  return true
end

local function utf8_for_codepoint(codepoint)
  if codepoint <= 0x7F then
    return string.char(codepoint)
  elseif codepoint <= 0x7FF then
    return string.char(
      0xC0 + math.floor(codepoint / 0x40),
      0x80 + codepoint % 0x40
    )
  elseif codepoint <= 0xFFFF then
    return string.char(
      0xE0 + math.floor(codepoint / 0x1000),
      0x80 + math.floor(codepoint / 0x40) % 0x40,
      0x80 + codepoint % 0x40
    )
  end
  return string.char(
    0xF0 + math.floor(codepoint / 0x40000),
    0x80 + math.floor(codepoint / 0x1000) % 0x40,
    0x80 + math.floor(codepoint / 0x40) % 0x40,
    0x80 + codepoint % 0x40
  )
end

local function decoder(source)
  local position = 1
  local length = #source

  local function skip_whitespace()
    while position <= length do
      local byte = source:byte(position)
      if byte == 0x20 or byte == 0x09 or byte == 0x0A or byte == 0x0D then
        position = position + 1
      else
        return
      end
    end
  end

  local function parse_hex4()
    local text = source:sub(position, position + 3)
    if #text ~= 4 or not text:match("^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$") then
      fail("invalid Unicode escape", position)
    end
    position = position + 4
    return tonumber(text, 16)
  end

  local function parse_string()
    local start = position
    if source:sub(position, position) ~= '"' then
      fail("expected string", position)
    end
    position = position + 1
    local chunks = {}
    while position <= length do
      local byte = source:byte(position)
      if byte == 0x22 then
        position = position + 1
        return table.concat(chunks)
      elseif byte == 0x5C then
        position = position + 1
        local escape = source:sub(position, position)
        if escape == "" then
          fail("unterminated escape", position)
        end
        local simple = {
          ['"'] = '"',
          ["\\"] = "\\",
          ["/"] = "/",
          ["b"] = "\b",
          ["f"] = "\f",
          ["n"] = "\n",
          ["r"] = "\r",
          ["t"] = "\t",
        }
        if simple[escape] ~= nil then
          chunks[#chunks + 1] = simple[escape]
          position = position + 1
        elseif escape == "u" then
          position = position + 1
          local codepoint = parse_hex4()
          if codepoint >= 0xD800 and codepoint <= 0xDBFF then
            if source:sub(position, position + 1) ~= "\\u" then
              fail("high surrogate must be followed by a low surrogate", position)
            end
            position = position + 2
            local low = parse_hex4()
            if low < 0xDC00 or low > 0xDFFF then
              fail("invalid low surrogate", position - 4)
            end
            codepoint = 0x10000 + (codepoint - 0xD800) * 0x400 + (low - 0xDC00)
          elseif codepoint >= 0xDC00 and codepoint <= 0xDFFF then
            fail("unexpected low surrogate", position - 4)
          end
          chunks[#chunks + 1] = utf8_for_codepoint(codepoint)
        else
          fail("invalid escape", position)
        end
      elseif byte < 0x20 then
        fail("unescaped control character", position)
      else
        chunks[#chunks + 1] = string.char(byte)
        position = position + 1
      end
    end
    fail("unterminated string", start)
  end

  local function parse_number()
    local start = position
    if source:sub(position, position) == "-" then
      position = position + 1
    end
    local first = source:sub(position, position)
    if first == "0" then
      position = position + 1
      if source:sub(position, position):match("%d") then
        fail("leading zero in number", position)
      end
    elseif first:match("[1-9]") then
      repeat
        position = position + 1
      until not source:sub(position, position):match("%d")
    else
      fail("invalid number", position)
    end
    if source:sub(position, position) == "." then
      position = position + 1
      if not source:sub(position, position):match("%d") then
        fail("fraction requires a digit", position)
      end
      repeat
        position = position + 1
      until not source:sub(position, position):match("%d")
    end
    local exponent = source:sub(position, position)
    if exponent == "e" or exponent == "E" then
      position = position + 1
      local sign = source:sub(position, position)
      if sign == "+" or sign == "-" then
        position = position + 1
      end
      if not source:sub(position, position):match("%d") then
        fail("exponent requires a digit", position)
      end
      repeat
        position = position + 1
      until not source:sub(position, position):match("%d")
    end
    local value = tonumber(source:sub(start, position - 1))
    if value == nil or value == math.huge or value == -math.huge or value ~= value then
      fail("number is outside the finite range", start)
    end
    return value
  end

  local parse_value

  local function parse_array()
    position = position + 1
    skip_whitespace()
    local result = M.array()
    if source:sub(position, position) == "]" then
      position = position + 1
      return result
    end
    local index = 1
    while true do
      result[index] = parse_value()
      index = index + 1
      skip_whitespace()
      local separator = source:sub(position, position)
      if separator == "]" then
        position = position + 1
        return result
      end
      if separator ~= "," then
        fail("expected ',' or ']'", position)
      end
      position = position + 1
      skip_whitespace()
    end
  end

  local function parse_object()
    position = position + 1
    skip_whitespace()
    local result = M.harray()
    local seen = {}
    if source:sub(position, position) == "}" then
      position = position + 1
      return result
    end
    while true do
      local key_position = position
      local key = parse_string()
      if seen[key] then
        fail("duplicate object key", key_position)
      end
      seen[key] = true
      skip_whitespace()
      if source:sub(position, position) ~= ":" then
        fail("expected ':'", position)
      end
      position = position + 1
      skip_whitespace()
      result[key] = parse_value()
      skip_whitespace()
      local separator = source:sub(position, position)
      if separator == "}" then
        position = position + 1
        return result
      end
      if separator ~= "," then
        fail("expected ',' or '}'", position)
      end
      position = position + 1
      skip_whitespace()
    end
  end

  parse_value = function()
    skip_whitespace()
    local token = source:sub(position, position)
    if token == '"' then
      return parse_string()
    elseif token == "[" then
      return parse_array()
    elseif token == "{" then
      return parse_object()
    elseif token == "-" or token:match("%d") then
      return parse_number()
    elseif source:sub(position, position + 3) == "true" then
      position = position + 4
      return true
    elseif source:sub(position, position + 4) == "false" then
      position = position + 5
      return false
    elseif source:sub(position, position + 3) == "null" then
      position = position + 4
      return M.null
    end
    fail("expected value", position)
  end

  local result = parse_value()
  skip_whitespace()
  if position <= length then
    fail("trailing content", position)
  end
  return result
end

function M.decode(source)
  if type(source) ~= "string" then
    fail("decode input must be a string")
  end
  local valid, invalid_position = M.validate_utf8(source)
  if not valid then
    fail("input is not valid UTF-8", invalid_position)
  end
  return decoder(source)
end

local function encode_string(value)
  local valid, invalid_position = M.validate_utf8(value)
  if not valid then
    fail("string is not valid UTF-8", invalid_position)
  end
  local chunks = { '"' }
  for index = 1, #value do
    local byte = value:byte(index)
    if byte == 0x22 then
      chunks[#chunks + 1] = '\\"'
    elseif byte == 0x5C then
      chunks[#chunks + 1] = "\\\\"
    elseif byte == 0x08 then
      chunks[#chunks + 1] = "\\b"
    elseif byte == 0x0C then
      chunks[#chunks + 1] = "\\f"
    elseif byte == 0x0A then
      chunks[#chunks + 1] = "\\n"
    elseif byte == 0x0D then
      chunks[#chunks + 1] = "\\r"
    elseif byte == 0x09 then
      chunks[#chunks + 1] = "\\t"
    elseif byte < 0x20 then
      chunks[#chunks + 1] = string.format("\\u%04x", byte)
    else
      chunks[#chunks + 1] = string.char(byte)
    end
  end
  chunks[#chunks + 1] = '"'
  return table.concat(chunks)
end

local function encode_value(value, active)
  local value_type = type(value)
  if value == M.null then
    return "null"
  elseif value_type == "string" then
    return encode_string(value)
  elseif value_type == "boolean" then
    return value and "true" or "false"
  elseif value_type == "number" then
    if value == math.huge or value == -math.huge or value ~= value then
      fail("cannot encode a non-finite number")
    end
    if value == 0 then
      return "0"
    end
    if value % 1 == 0 then
      return string.format("%.0f", value)
    end
    return string.format("%.17g", value)
  elseif value_type ~= "table" then
    fail("cannot encode value of type " .. value_type)
  end

  local kind = M.kind(value)
  if kind ~= "array" and kind ~= "harray" then
    fail("plain Lua tables are ambiguous; use json.array or json.harray")
  end
  if active[value] then
    fail("cannot encode a cyclic value")
  end
  active[value] = true

  local chunks = {}
  if kind == "array" then
    local count = #value
    for key in pairs(value) do
      if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > count then
        fail("JSON array has a non-contiguous index")
      end
    end
    for index = 1, count do
      chunks[index] = encode_value(value[index], active)
    end
    active[value] = nil
    return "[" .. table.concat(chunks, ",") .. "]"
  end

  local keys = {}
  for key in pairs(value) do
    if type(key) ~= "string" then
      fail("JSON harray key is not a string")
    end
    keys[#keys + 1] = key
  end
  table.sort(keys)
  for index, key in ipairs(keys) do
    chunks[index] = encode_string(key) .. ":" .. encode_value(value[key], active)
  end
  active[value] = nil
  return "{" .. table.concat(chunks, ",") .. "}"
end

function M.encode(value)
  return encode_value(value, {})
end

return M
