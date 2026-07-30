-- Strict synchronous caller-owned stdio transport for the native Lua MCP server.

local json = require("linkedspec.json")
local runtime = require("linkedspec.mcp_contract_runtime")

local M = {}

local UTF8_BOM = "\239\187\191"
local IO_LOG_RECORD = "linkedspec_mcp_io_failure\n"
local SAFE_INTEGER_ID = "9007199254740991"

local INTEGER_PATHS = {
  ["/params/requestId"] = { "params", "requestId" },
  ["/params/arguments/request/page/limit"] =
    { "params", "arguments", "request", "page", "limit" },
  ["/params/arguments/request/budget/max_depth"] =
    { "params", "arguments", "request", "budget", "max_depth" },
  ["/params/arguments/request/budget/max_records"] =
    { "params", "arguments", "request", "budget", "max_records" },
  ["/params/arguments/request/budget/max_relations"] =
    { "params", "arguments", "request", "budget", "max_relations" },
}

local function parse_failure()
  error("MCP wire parse failure", 0)
end

local function pointer_segment(value)
  return (value:gsub("~", "~0"):gsub("/", "~1"))
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

local function scanner(source, maximum_depth)
  return {
    source = source,
    length = #source,
    position = 1,
    maximum_depth = maximum_depth,
    containers = {},
    number_tokens = {},
    id_token = nil,
  }
end

local function peek(state)
  if state.position > state.length then return nil end
  return state.source:byte(state.position)
end

local function take(state, expected)
  if peek(state) ~= expected then return false end
  state.position = state.position + 1
  return true
end

local function is_digit(value)
  return value ~= nil and value >= 0x30 and value <= 0x39
end

local function skip_whitespace(state)
  while true do
    local byte = peek(state)
    if byte ~= 0x20 and byte ~= 0x09 and byte ~= 0x0A and byte ~= 0x0D then return end
    state.position = state.position + 1
  end
end

local function hex_value(byte)
  if byte >= 0x30 and byte <= 0x39 then return byte - 0x30 end
  if byte >= 0x41 and byte <= 0x46 then return byte - 0x41 + 10 end
  if byte >= 0x61 and byte <= 0x66 then return byte - 0x61 + 10 end
  return nil
end

local function take_hex_quad(state)
  if state.position + 3 > state.length then parse_failure() end
  local value = 0
  for offset = 0, 3 do
    local digit = hex_value(state.source:byte(state.position + offset))
    if digit == nil then parse_failure() end
    value = value * 16 + digit
  end
  state.position = state.position + 4
  return value
end

local function parse_escaped_scalar(state)
  local high = take_hex_quad(state)
  if high >= 0xD800 and high <= 0xDBFF then
    if not take(state, 0x5C) or not take(state, 0x75) then parse_failure() end
    local low = take_hex_quad(state)
    if low < 0xDC00 or low > 0xDFFF then parse_failure() end
    return 0x10000 + (high - 0xD800) * 0x400 + (low - 0xDC00)
  end
  if high >= 0xDC00 and high <= 0xDFFF then parse_failure() end
  return high
end

local function parse_string(state)
  if not take(state, 0x22) then parse_failure() end
  local chunks = {}
  while state.position <= state.length do
    local byte = peek(state)
    if byte == 0x22 then
      state.position = state.position + 1
      return table.concat(chunks)
    elseif byte < 0x20 then
      parse_failure()
    elseif byte ~= 0x5C then
      chunks[#chunks + 1] = string.char(byte)
      state.position = state.position + 1
    else
      state.position = state.position + 1
      local escape = peek(state)
      if escape == nil then parse_failure() end
      state.position = state.position + 1
      if escape == 0x22 or escape == 0x2F or escape == 0x5C then
        chunks[#chunks + 1] = string.char(escape)
      elseif escape == 0x62 then
        chunks[#chunks + 1] = "\b"
      elseif escape == 0x66 then
        chunks[#chunks + 1] = "\f"
      elseif escape == 0x6E then
        chunks[#chunks + 1] = "\n"
      elseif escape == 0x72 then
        chunks[#chunks + 1] = "\r"
      elseif escape == 0x74 then
        chunks[#chunks + 1] = "\t"
      elseif escape == 0x75 then
        chunks[#chunks + 1] = utf8_for_codepoint(parse_escaped_scalar(state))
      else
        parse_failure()
      end
    end
  end
  parse_failure()
end

local function parse_literal(state, literal)
  if state.source:sub(state.position, state.position + #literal - 1) ~= literal then
    parse_failure()
  end
  state.position = state.position + #literal
end

local function parse_number(state)
  local start = state.position
  if take(state, 0x2D) and state.position > state.length then parse_failure() end
  local first = peek(state)
  if first == 0x30 then
    state.position = state.position + 1
  elseif first ~= nil and first >= 0x31 and first <= 0x39 then
    state.position = state.position + 1
    while is_digit(peek(state)) do state.position = state.position + 1 end
  else
    parse_failure()
  end
  if take(state, 0x2E) then
    if not is_digit(peek(state)) then parse_failure() end
    while is_digit(peek(state)) do state.position = state.position + 1 end
  end
  local exponent = peek(state)
  if exponent == 0x65 or exponent == 0x45 then
    state.position = state.position + 1
    local sign = peek(state)
    if sign == 0x2B or sign == 0x2D then state.position = state.position + 1 end
    if not is_digit(peek(state)) then parse_failure() end
    while is_digit(peek(state)) do state.position = state.position + 1 end
  end
  return state.source:sub(start, state.position - 1)
end

local function push_container(state, value)
  if #state.containers >= state.maximum_depth then parse_failure() end
  state.containers[#state.containers + 1] = value
end

local parse_value

parse_value = function(state, root_container, capture_root_id, path)
  skip_whitespace(state)
  local start = state.position
  local byte = peek(state)
  local token_kind = byte == 0x22 and "string" or
    ((byte == 0x2D or is_digit(byte)) and "number" or "other")
  if byte == 0x7B then
    state.position = state.position + 1
    push_container(state, {
      kind = "object", root = root_container, phase = "key_or_end",
      keys = {}, key = nil, path = path,
    })
    return
  elseif byte == 0x5B then
    state.position = state.position + 1
    push_container(state, {
      kind = "list", phase = "value_or_end", index = 0, path = path,
    })
    return
  elseif byte == 0x22 then
    parse_string(state)
  elseif byte == 0x74 then
    parse_literal(state, "true")
  elseif byte == 0x66 then
    parse_literal(state, "false")
  elseif byte == 0x6E then
    parse_literal(state, "null")
  elseif byte == 0x2D or is_digit(byte) then
    local raw = parse_number(state)
    state.number_tokens[path] = raw
  else
    parse_failure()
  end
  if capture_root_id then
    state.id_token = {
      kind = token_kind,
      raw = token_kind == "number" and state.source:sub(start, state.position - 1) or nil,
    }
  end
end

local function scan(state)
  skip_whitespace(state)
  parse_value(state, true, false, "")
  while #state.containers > 0 do
    local container = state.containers[#state.containers]
    if container.kind == "object" then
      if container.phase == "key_or_end" then
        skip_whitespace(state)
        if take(state, 0x7D) then
          state.containers[#state.containers] = nil
        else
          container.phase = "key"
        end
      elseif container.phase == "key" then
        skip_whitespace(state)
        if peek(state) ~= 0x22 then parse_failure() end
        local key = parse_string(state)
        if container.keys[key] then parse_failure() end
        container.keys[key] = true
        container.key = key
        container.phase = "colon"
      elseif container.phase == "colon" then
        skip_whitespace(state)
        if not take(state, 0x3A) then parse_failure() end
        container.phase = "value"
      elseif container.phase == "value" then
        skip_whitespace(state)
        local key = container.key
        container.phase = "comma_or_end"
        parse_value(state, false, container.root and key == "id",
          container.path .. "/" .. pointer_segment(key))
      else
        skip_whitespace(state)
        if take(state, 0x7D) then
          state.containers[#state.containers] = nil
        elseif take(state, 0x2C) then
          container.phase = "key"
        else
          parse_failure()
        end
      end
    else
      if container.phase == "value_or_end" then
        skip_whitespace(state)
        if take(state, 0x5D) then
          state.containers[#state.containers] = nil
        else
          container.phase = "value"
        end
      elseif container.phase == "value" then
        skip_whitespace(state)
        local index = container.index
        container.index = index + 1
        container.phase = "comma_or_end"
        parse_value(state, false, false, container.path .. "/" .. tostring(index))
      else
        skip_whitespace(state)
        if take(state, 0x5D) then
          state.containers[#state.containers] = nil
        elseif take(state, 0x2C) then
          container.phase = "value"
        else
          parse_failure()
        end
      end
    end
  end
  skip_whitespace(state)
  if state.position ~= state.length + 1 then parse_failure() end
end

local function fractional(raw)
  return raw ~= nil and raw:find("[%.eE]") ~= nil
end

local function invalidate_path(root, segments)
  local parent = root
  for index = 1, #segments - 1 do
    if json.kind(parent) ~= "harray" then return end
    parent = rawget(parent, segments[index])
  end
  if json.kind(parent) == "harray" and rawget(parent, segments[#segments]) ~= nil then
    parent[segments[#segments]] = json.harray({})
  end
end

local function preserve_integer_token_kinds(request, number_tokens)
  for path, segments in pairs(INTEGER_PATHS) do
    if fractional(number_tokens[path]) then invalidate_path(request, segments) end
  end
end

local function safe_integer_id(raw)
  if fractional(raw) then return false end
  local digits = raw:sub(1, 1) == "-" and raw:sub(2) or raw
  digits = digits:gsub("^0+", "")
  if digits == "" then digits = "0" end
  return #digits < #SAFE_INTEGER_ID or
    (#digits == #SAFE_INTEGER_ID and digits <= SAFE_INTEGER_ID)
end

local function valid_id(value, token)
  if token == nil then return false end
  if token.kind == "number" then
    if not safe_integer_id(token.raw) then return false end
  elseif token.kind ~= "string" then
    return false
  end
  return runtime.validate_named("requestId", value)
end

local function decode_payload(payload, maximum_depth)
  if payload:sub(1, 3) == UTF8_BOM then return nil, "parse" end
  if not json.validate_utf8(payload) then return nil, "parse" end
  local state = scanner(payload, maximum_depth)
  if not pcall(scan, state) then return nil, "parse" end
  local ok, value = pcall(json.decode, payload)
  if not ok then return nil, "parse" end
  if json.kind(value) ~= "harray" then return nil, "invalid_request" end
  if rawget(value, "id") ~= nil and not valid_id(value.id, state.id_token) then
    return nil, "invalid_request"
  end
  preserve_integer_token_kinds(value, state.number_tokens)
  return value, nil
end

local function validated_id(request)
  local value = rawget(request, "id")
  if value ~= nil and runtime.validate_named("requestId", value) then
    return runtime.clone_data(value)
  end
  return nil
end

local function request_limits()
  local contract = runtime.contract()
  local limits = json.kind(contract) == "harray" and contract.request_limits or nil
  local line_bytes = json.kind(limits) == "harray" and
    limits.line_bytes_excluding_delimiter or nil
  local depth = json.kind(limits) == "harray" and limits.json_nesting_depth or nil
  if type(line_bytes) ~= "number" or line_bytes < 1 or line_bytes ~= math.floor(line_bytes) or
      type(depth) ~= "number" or depth < 1 or depth ~= math.floor(depth) then
    error("invalid MCP wire limits", 0)
  end
  return line_bytes, depth
end

local function process_payload(server_api, server, payload, authorization_context, maximum_depth)
  local request, rejection = decode_payload(payload, maximum_depth)
  if request == nil then
    local kind = rejection == "parse" and "parse_error" or "invalid_request"
    return server_api._protocol_error(nil, kind), nil
  end
  local id = validated_id(request)
  local ok, response, prepared = pcall(server_api._dispatch_for_wire,
    server, request, authorization_context)
  if not ok then return server_api._protocol_error(id, "internal_error"), nil end
  if response == nil then return nil, nil end
  if not runtime.validate_frame(response) then
    server_api._wire_response_emitted(server, prepared)
    return server_api._protocol_error(id, "internal_error"), nil
  end
  return response, prepared
end

local function checked_write(stream, bytes)
  local ok, result = pcall(stream.write, stream, bytes)
  if not ok or result == nil or result == false then error("MCP output failure", 0) end
end

local function checked_flush(stream)
  local ok, result = pcall(stream.flush, stream)
  if not ok or result == nil or result == false then error("MCP flush failure", 0) end
end

local function emit(server_api, server, output, response, prepared)
  if response == nil then return end
  server_api._wire_before_emit(server, prepared)
  if not server_api._wire_response_ready(server, prepared) then return end
  if not runtime.validate_frame(response) then error("invalid MCP response", 0) end
  checked_write(output, runtime.canonical_json(response) .. "\n")
  checked_flush(output)
  server_api._wire_response_emitted(server, prepared)
end

local function read_byte(input)
  local ok, value, detail = pcall(input.read, input, 1)
  if not ok or (value == nil and detail ~= nil) then error("MCP input failure", 0) end
  if value == nil then return nil end
  if type(value) ~= "string" or #value ~= 1 then error("MCP input failure", 0) end
  return value
end

local function stream_loop(server_api, server, input, output, authorization_context,
    maximum_line_bytes, maximum_depth)
  local chunks = {}
  local length = 0
  local overlong = false
  while true do
    local byte = read_byte(input)
    if byte == nil then break end
    if byte == "\n" then
      if overlong then
        emit(server_api, server, output,
          server_api._protocol_error(nil, "parse_error"), nil)
      else
        local payload = table.concat(chunks)
        if payload:sub(-1) == "\r" then payload = payload:sub(1, -2) end
        if #payload > maximum_line_bytes then
          emit(server_api, server, output,
            server_api._protocol_error(nil, "parse_error"), nil)
        else
          local response, prepared = process_payload(server_api, server, payload,
            authorization_context, maximum_depth)
          emit(server_api, server, output, response, prepared)
        end
      end
      chunks, length, overlong = {}, 0, false
    elseif not overlong then
      length = length + 1
      if length > maximum_line_bytes + 1 then
        chunks, overlong = {}, true
      else
        chunks[#chunks + 1] = byte
      end
    end
  end

  if overlong then
    emit(server_api, server, output,
      server_api._protocol_error(nil, "parse_error"), nil)
  elseif length > 0 then
    local payload = table.concat(chunks)
    if #payload > maximum_line_bytes then
      emit(server_api, server, output,
        server_api._protocol_error(nil, "parse_error"), nil)
    else
      local response, prepared = process_payload(server_api, server, payload,
        authorization_context, maximum_depth)
      emit(server_api, server, output, response, prepared)
    end
  end
  server:shutdown()
end

local function log_failure(log)
  if log == nil then return end
  pcall(function()
    local written = log:write(IO_LOG_RECORD)
    if written == nil or written == false then return end
    log:flush()
  end)
end

function M.serve(server_api, server, input, output, authorization_context, log)
  local ok, line_bytes, depth = pcall(request_limits)
  if not ok then server_api._raise_contract_failure() end
  ok = pcall(stream_loop, server_api, server, input, output,
    authorization_context, line_bytes, depth)
  if ok then return true end
  pcall(server.shutdown, server)
  log_failure(log)
  server_api._raise_io_failure()
end

-- Package-private proof seam for number-kind and duplicate-key classification.
M._decode_payload = decode_payload

return M
