-- Frozen runtime over the generated, filesystem-free MCP contract binding.

local binding = require("linkedspec.mcp_contract")
local json = require("linkedspec.json")
local sha256 = require("linkedspec.sha256")

local M = {}

local BUNDLE
local PAYLOAD_BY_ID
local REF_PREFIX = "#/$defs/"

local function contract_error()
  error("generated MCP contract is invalid", 0)
end

local function clone_data(value)
  local ok, encoded = pcall(json.encode, value)
  if not ok then contract_error() end
  local decoded_ok, decoded = pcall(json.decode, encoded)
  if not decoded_ok then contract_error() end
  return decoded
end

local function object(value)
  if json.kind(value) == "harray" then return value end
  return nil
end

local function json_array(value)
  if json.kind(value) == "array" then return value end
  return nil
end

local function initialize()
  if BUNDLE ~= nil then return end
  if type(binding) ~= "table" or binding.binding_format ~= 1 or
      type(binding.bundle_sha256) ~= "string" or type(binding.bundle_json) ~= "string" then
    contract_error()
  end
  if sha256.hex(binding.bundle_json) ~= binding.bundle_sha256 then contract_error() end
  local ok, decoded = pcall(json.decode, binding.bundle_json)
  if not ok or object(decoded) == nil or decoded.binding_format ~= binding.binding_format then
    contract_error()
  end
  local semantic = object(decoded.semantic_payloads)
  local payloads = semantic and json_array(semantic.payloads) or nil
  if payloads == nil then contract_error() end
  local by_id = {}
  for index = 1, #payloads do
    local row = object(payloads[index])
    local id = row and row.id or nil
    if type(id) ~= "string" or by_id[id] ~= nil then contract_error() end
    by_id[id] = row.response
  end
  BUNDLE = decoded
  PAYLOAD_BY_ID = by_id
end

local function finite_number(value)
  return type(value) == "number" and value == value and
    value ~= math.huge and value ~= -math.huge
end

local function integer(value)
  return finite_number(value) and value == math.floor(value)
end

local function has_type(value, expected)
  if expected == "null" then return value == json.null end
  if expected == "boolean" then return type(value) == "boolean" end
  if expected == "array" then return json.kind(value) == "array" end
  if expected == "object" then return json.kind(value) == "harray" end
  if expected == "string" then
    return type(value) == "string" and json.validate_utf8(value)
  end
  if expected == "integer" then return integer(value) end
  if expected == "number" then return finite_number(value) end
  return false
end

local function same_json(left, right)
  local left_ok, left_json = pcall(json.encode, left)
  local right_ok, right_json = pcall(json.encode, right)
  return left_ok and right_ok and left_json == right_json
end

local function scalar_length(value)
  local valid = json.validate_utf8(value)
  if not valid then contract_error() end
  local count = 0
  local position = 1
  while position <= #value do
    local first = value:byte(position)
    if first <= 0x7F then
      position = position + 1
    elseif first <= 0xDF then
      position = position + 2
    elseif first <= 0xEF then
      position = position + 3
    else
      position = position + 4
    end
    count = count + 1
  end
  return count
end

local function validate_string(value, schema)
  local length = scalar_length(value)
  if schema.minLength ~= nil and length < schema.minLength then contract_error() end
  if schema.maxLength ~= nil and length > schema.maxLength then contract_error() end
  local maximum_bytes = schema["x-linkedspec-maxUtf8Bytes"]
  if maximum_bytes ~= nil and #value > maximum_bytes then contract_error() end
  if schema.pattern ~= nil then
    local matches = false
    if schema.pattern == "^[A-Za-z0-9_-]{43}$" then
      matches = #value == 43 and value:match("^[A-Za-z0-9_-]+$") ~= nil
    elseif schema.pattern == "^sha256:[0-9a-f]{64}$" then
      matches = #value == 71 and value:match("^sha256:[0-9a-f]+$") ~= nil
    end
    if not matches then contract_error() end
  end
  if schema.format == "uri" and
      value:match("^[A-Za-z][A-Za-z0-9+%.%-]*:") == nil then
    contract_error()
  end
end

local validate

local function matches(value, schema, depth)
  return pcall(validate, value, schema, depth)
end

validate = function(value, schema_value, depth)
  if depth > 256 then contract_error() end
  if type(schema_value) == "boolean" then
    if not schema_value then contract_error() end
    return
  end
  local schema = object(schema_value)
  if schema == nil then contract_error() end

  local reference = schema["$ref"]
  if reference ~= nil then
    if type(reference) ~= "string" or reference:sub(1, #REF_PREFIX) ~= REF_PREFIX then
      contract_error()
    end
    local name = reference:sub(#REF_PREFIX + 1)
    if name == "" or name:find("/", 1, true) ~= nil then contract_error() end
    local root = object(BUNDLE.schema)
    local definitions = root and object(root["$defs"]) or nil
    local definition = definitions and definitions[name] or nil
    if definition == nil then contract_error() end
    validate(value, definition, depth + 1)
  end

  if schema.type ~= nil then
    local accepted = false
    if type(schema.type) == "string" then
      accepted = has_type(value, schema.type)
    elseif json_array(schema.type) ~= nil then
      for index = 1, #schema.type do
        if type(schema.type[index]) == "string" and has_type(value, schema.type[index]) then
          accepted = true
          break
        end
      end
    end
    if not accepted then contract_error() end
  end
  if schema.const ~= nil and not same_json(value, schema.const) then contract_error() end
  if schema.enum ~= nil then
    local allowed = json_array(schema.enum)
    if allowed == nil then contract_error() end
    local accepted = false
    for index = 1, #allowed do
      if same_json(value, allowed[index]) then accepted = true break end
    end
    if not accepted then contract_error() end
  end
  if schema.oneOf ~= nil then
    local branches = json_array(schema.oneOf)
    if branches == nil then contract_error() end
    local count = 0
    for index = 1, #branches do
      if matches(value, branches[index], depth + 1) then count = count + 1 end
    end
    if count ~= 1 then contract_error() end
  end
  if schema.allOf ~= nil then
    local branches = json_array(schema.allOf)
    if branches == nil then contract_error() end
    for index = 1, #branches do validate(value, branches[index], depth + 1) end
  end

  if json.kind(value) == "harray" then
    local properties = object(schema.properties)
    local property_count = 0
    for _ in next, value do property_count = property_count + 1 end
    if schema.maxProperties ~= nil and property_count > schema.maxProperties then contract_error() end
    local required = json_array(schema.required)
    if required ~= nil then
      for index = 1, #required do
        local name = required[index]
        if type(name) ~= "string" or rawget(value, name) == nil then contract_error() end
      end
    end
    for name, child in next, value do
      if schema.propertyNames ~= nil then
        validate(name, schema.propertyNames, depth + 1)
      end
      if properties ~= nil and rawget(properties, name) ~= nil then
        validate(child, properties[name], depth + 1)
      elseif schema.additionalProperties == false then
        contract_error()
      elseif type(schema.additionalProperties) == "boolean" or
          object(schema.additionalProperties) ~= nil then
        validate(child, schema.additionalProperties, depth + 1)
      end
    end
  elseif json.kind(value) == "array" then
    local prefix = json_array(schema.prefixItems)
    local prefix_count = prefix and #prefix or 0
    if prefix ~= nil then
      for index = 1, math.min(#value, #prefix) do
        validate(value[index], prefix[index], depth + 1)
      end
    end
    if schema.items ~= nil then
      for index = prefix_count + 1, #value do
        validate(value[index], schema.items, depth + 1)
      end
    end
    if schema.minItems ~= nil and #value < schema.minItems then contract_error() end
    if schema.maxItems ~= nil and #value > schema.maxItems then contract_error() end
  elseif type(value) == "string" then
    validate_string(value, schema)
  elseif integer(value) then
    if schema.minimum ~= nil and value < schema.minimum then contract_error() end
    if schema.maximum ~= nil and value > schema.maximum then contract_error() end
  end
end

function M.clone_data(value)
  return clone_data(value)
end

function M.canonical_json(value)
  local ok, result = pcall(json.encode, value)
  if not ok then contract_error() end
  return result
end

function M.contract()
  initialize()
  return clone_data(BUNDLE.contract)
end

function M.source_sha256()
  initialize()
  return clone_data(BUNDLE.source_sha256)
end

function M.corpus()
  initialize()
  return clone_data(BUNDLE.corpus)
end

function M.protocol_version()
  initialize()
  local contract = object(BUNDLE.contract)
  if contract == nil or type(contract.protocol_version) ~= "string" then contract_error() end
  return contract.protocol_version
end

function M.frame(name)
  initialize()
  if type(name) ~= "string" then return nil end
  local frames = object(BUNDLE.canonical_frames)
  local value = frames and rawget(frames, name) or nil
  if value == nil then return nil end
  return clone_data(value)
end

function M.payload(name)
  initialize()
  if type(name) ~= "string" or PAYLOAD_BY_ID[name] == nil then return nil end
  return clone_data(PAYLOAD_BY_ID[name])
end

function M.validate_named(name, value)
  initialize()
  if type(name) ~= "string" then return false end
  local schema = object(BUNDLE.schema)
  local definitions = schema and object(schema["$defs"]) or nil
  local definition = definitions and rawget(definitions, name) or nil
  if definition == nil then return false end
  return matches(value, definition, 0)
end

function M.validate_frame(value)
  initialize()
  return matches(value, BUNDLE.schema, 0)
end

local function set_server_name(response)
  local result = object(response.result)
  local metadata = result and object(result._meta) or nil
  local server = metadata and object(metadata["io.modelcontextprotocol/serverInfo"]) or nil
  if server == nil then contract_error() end
  server.name = "linkedspec-semantic-lua"
end

function M.discover_response(id)
  local response = M.frame("discover_response_lua")
  if response == nil then contract_error() end
  response.id = clone_data(id)
  return response
end

function M.tools_list_response(id)
  local response = M.frame("tools_list_response_perl")
  if response == nil then contract_error() end
  set_server_name(response)
  response.id = clone_data(id)
  return response
end

function M.tool_success_response(id, payload)
  if not M.validate_named("semanticQueryResponse", payload) then contract_error() end
  local response = M.frame("capabilities_call_response")
  if response == nil then contract_error() end
  set_server_name(response)
  response.id = clone_data(id)
  local result = object(response.result)
  local content = result and json_array(result.content) or nil
  local first = content and object(content[1]) or nil
  if result == nil or first == nil then contract_error() end
  result.structuredContent = clone_data(payload)
  first.text = M.canonical_json(payload)
  return response
end

function M.tool_error_response(id, unavailable)
  local response = M.frame("policy_denied_response")
  if response == nil then contract_error() end
  set_server_name(response)
  if unavailable then
    local source = M.frame("handle_unavailable_response")
    local source_result = source and object(source.result) or nil
    local result = object(response.result)
    if source_result == nil or result == nil then contract_error() end
    result.content = clone_data(source_result.content)
  end
  response.id = clone_data(id)
  return response
end

function M.json_rpc_error(id, kind, requested)
  initialize()
  local contract = object(BUNDLE.contract)
  if contract == nil then contract_error() end
  local code
  local message
  if kind == "legacy_initialize" then
    local legacy = object(contract.legacy_diagnostic)
    if legacy ~= nil then code, message = legacy.code, legacy.message end
  else
    local owners = {
      parse_error = "invalid_utf8",
      invalid_request = "invalid_envelope",
      method_not_found = "unknown_method",
      invalid_params = "method_params",
      internal_error = "sanitized_unexpected_failure",
      unsupported_version = "unsupported_protocol_version",
    }
    local owner_name = owners[kind]
    local rows = json_array(contract.json_rpc_errors)
    if owner_name == nil or rows == nil then contract_error() end
    for index = 1, #rows do
      local row = object(rows[index])
      local owned = row and json_array(row.owns) or nil
      if owned ~= nil then
        for owned_index = 1, #owned do
          if owned[owned_index] == owner_name then
            code, message = row.code, row.message
            break
          end
        end
      end
      if code ~= nil then break end
    end
  end
  if not integer(code) or type(message) ~= "string" then contract_error() end
  local error_value = json.harray({ code = code, message = message })
  if kind == "unsupported_version" then
    error_value.data = json.harray({
      requested = type(requested) == "string" and requested or "",
      supported = json.array({ M.protocol_version() }),
    })
  end
  return json.harray({
    jsonrpc = "2.0",
    id = id == nil and json.null or clone_data(id),
    error = error_value,
  })
end

initialize()

return M
