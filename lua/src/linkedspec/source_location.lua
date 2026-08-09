-- Private immutable source identities, Unicode-scalar positions, and spans.
--
-- One SourceAuthority snapshots caller-supplied decoded strings. Public values
-- are opaque tokens whose state lives only in this module; they retain source
-- identity and scalar offsets, never decoded text or runtime/parser objects.

local json = require("linkedspec.json")

local M = {}

local VALIDATE_VALUE_PHASE = "validate_value"
local SOURCE_MISMATCH_CODE = "source_location_source_mismatch"
local POSITION_OUT_OF_RANGE_CODE = "source_location_position_out_of_range"
local REVERSED_SPAN_CODE = "source_location_reversed_span"
local INVALID_DERIVED_PROVENANCE_CODE =
  "source_location_invalid_derived_provenance"
local MAX_EXACT_INTEGER = 9007199254740991

local next_authority_id = 0
local private_state = setmetatable({}, { __mode = "k" })
local token_metatables = {}

local function fail(message)
  error("source location: " .. message, 0)
end

local function is_integer(value)
  return type(value) == "number" and value == math.floor(value)
end

local function token_metatable(node_type)
  local metatable = token_metatables[node_type]
  if metatable ~= nil then return metatable end

  metatable = {
    __metatable = "immutable " .. node_type,
    __newindex = function()
      error(node_type .. " is immutable", 2)
    end,
    __tostring = function(value)
      local state = private_state[value]
      if state ~= nil and state.record ~= nil and state.record.code ~= nil then
        return state.record.code
      end
      return node_type
    end,
  }
  token_metatables[node_type] = metatable
  return metatable
end

local function new_token(node_type, state)
  state.node_type = node_type
  local value = setmetatable({}, token_metatable(node_type))
  private_state[value] = state
  return value
end

local function state_of(value, expected_type)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil or state.node_type ~= expected_type then
    fail("expected " .. expected_type)
  end
  return state
end

local function options_table(options, operation)
  if type(options) ~= "table" then fail(operation .. " options must be a table") end
  return options
end

local function context_state(options)
  return state_of(options.context, "SourceLocationContext")
end

local function copied_harray(values)
  local result = json.harray()
  for key, value in pairs(values) do result[key] = value end
  return result
end

local function raise_value_error(code, context, fields)
  local record = json.harray({
    code = code,
    phase = VALIDATE_VALUE_PHASE,
    rule_role = context.rule_role,
    invocation_role = context.invocation_role,
  })
  for key, value in pairs(fields) do record[key] = value end
  error(new_token("SourceLocationException", { record = record }), 0)
end

local function claim_authority_id()
  if next_authority_id >= MAX_EXACT_INTEGER then
    fail("source authority identity space exhausted")
  end
  next_authority_id = next_authority_id + 1
  return next_authority_id
end

local function utf8_width(first_byte)
  if first_byte <= 0x7F then return 1 end
  if first_byte <= 0xDF then return 2 end
  if first_byte <= 0xEF then return 3 end
  return 4
end

local function decoded_source(source_id, text)
  local valid, invalid_position = json.validate_utf8(text)
  if not valid then
    fail(
      "decoded source '" .. source_id .. "' is not valid UTF-8 at byte " ..
        tostring(invalid_position)
    )
  end

  local byte_at_offset = { 0 }
  local line_at_offset = { 1 }
  local column_at_offset = { 1 }
  local byte_index = 1
  local scalar_offset = 0
  local line = 1
  local column = 1

  while byte_index <= #text do
    local first_byte = text:byte(byte_index)
    local width = utf8_width(first_byte)
    scalar_offset = scalar_offset + 1
    byte_index = byte_index + width
    if first_byte == 0x0A then
      line = line + 1
      column = 1
    else
      column = column + 1
    end
    byte_at_offset[scalar_offset + 1] = byte_index - 1
    line_at_offset[scalar_offset + 1] = line
    column_at_offset[scalar_offset + 1] = column
  end

  return {
    source_id = source_id,
    text = text,
    scalar_length = scalar_offset,
    byte_at_offset = byte_at_offset,
    line_at_offset = line_at_offset,
    column_at_offset = column_at_offset,
  }
end

local function source_for(authority, source_id)
  return authority.sources[source_id]
end

local function boundary_index(source, offset)
  if source == nil or not is_integer(offset) or offset < 0 or
      offset > source.scalar_length then
    return nil
  end
  return offset + 1
end

local function span_record(span)
  return json.harray({
    source_id = span.source_id,
    start = span.start_offset,
    ["end"] = span.end_offset,
    provenance = span.provenance,
  })
end

local function invalid_provenance(context, provenance_index, source_id)
  raise_value_error(INVALID_DERIVED_PROVENANCE_CODE, context, {
    provenance_index = provenance_index,
    source_id = source_id,
  })
end

local function materialize_span(authority, span, context, provenance_index)
  local source = source_for(authority, span.source_id)
  local start_index = boundary_index(source, span.start_offset)
  local end_index = boundary_index(source, span.end_offset)
  if span.authority_id ~= authority.authority_id or start_index == nil or
      end_index == nil or span.start_offset > span.end_offset then
    invalid_provenance(context, provenance_index, span.source_id)
  end
  local start_byte = source.byte_at_offset[start_index]
  local end_byte = source.byte_at_offset[end_index]
  return source.text:sub(start_byte + 1, end_byte)
end

function M.node_type(value)
  local state = type(value) == "table" and private_state[value] or nil
  return state and state.node_type or nil
end

function M.is_error(value)
  return M.node_type(value) == "SourceLocationException"
end

function M.source_location_context(options)
  options = options_table(options, "source_location_context")
  if type(options.rule_role) ~= "string" then
    fail("source_location_context rule_role must be a string")
  end
  if type(options.invocation_role) ~= "string" then
    fail("source_location_context invocation_role must be a string")
  end
  return new_token("SourceLocationContext", {
    rule_role = options.rule_role,
    invocation_role = options.invocation_role,
  })
end

function M.source_authority(options)
  options = options_table(options, "source_authority")
  if type(options.sources) ~= "table" then
    fail("source_authority sources must be a table")
  end

  local source_ids = {}
  for source_id, text in pairs(options.sources) do
    if type(source_id) ~= "string" then fail("source ids must be strings") end
    if type(text) ~= "string" then
      fail("decoded source '" .. source_id .. "' must be a string")
    end
    source_ids[#source_ids + 1] = source_id
  end
  table.sort(source_ids)

  local sources = {}
  for _, source_id in ipairs(source_ids) do
    sources[source_id] = decoded_source(source_id, options.sources[source_id])
  end
  return new_token("SourceAuthority", {
    authority_id = claim_authority_id(),
    sources = sources,
  })
end

function M.position(authority_value, options)
  local authority = state_of(authority_value, "SourceAuthority")
  options = options_table(options, "position")
  local context = context_state(options)
  if type(options.source_id) ~= "string" then fail("position source_id must be a string") end
  if not is_integer(options.offset) then fail("position offset must be an integer") end

  local source = source_for(authority, options.source_id)
  if boundary_index(source, options.offset) == nil then
    raise_value_error(POSITION_OUT_OF_RANGE_CODE, context, {
      source_id = options.source_id,
      position_offset = options.offset,
      source_length = source and source.scalar_length or 0,
    })
  end
  return new_token("Position", {
    authority_id = authority.authority_id,
    source_id = options.source_id,
    offset = options.offset,
  })
end

function M.direct_span(authority_value, options)
  local authority = state_of(authority_value, "SourceAuthority")
  options = options_table(options, "direct_span")
  local context = context_state(options)
  local start_position = state_of(options.start, "Position")
  local end_position = state_of(options["end"], "Position")
  if type(options.provenance) ~= "string" or options.provenance == "" then
    fail("direct_span provenance must be a nonempty string")
  end

  if start_position.source_id ~= end_position.source_id or
      start_position.authority_id ~= end_position.authority_id or
      start_position.authority_id ~= authority.authority_id then
    raise_value_error(SOURCE_MISMATCH_CODE, context, {
      source_id = start_position.source_id,
      other_source_id = end_position.source_id,
    })
  end
  if start_position.offset > end_position.offset then
    raise_value_error(REVERSED_SPAN_CODE, context, {
      source_id = start_position.source_id,
      start_offset = start_position.offset,
      end_offset = end_position.offset,
    })
  end
  return new_token("Span", {
    authority_id = authority.authority_id,
    source_id = start_position.source_id,
    start_offset = start_position.offset,
    end_offset = end_position.offset,
    provenance = options.provenance,
  })
end

function M.derived_text(authority_value, options)
  local authority = state_of(authority_value, "SourceAuthority")
  options = options_table(options, "derived_text")
  local context = context_state(options)
  if options.policy ~= "concatenate_in_order" then
    fail("derived_text policy must be concatenate_in_order")
  end
  if type(options.spans) ~= "table" then fail("derived_text spans must be an array") end

  local spans = {}
  for index = 1, #options.spans do
    local span = state_of(options.spans[index], "Span")
    if span.authority_id ~= authority.authority_id or
        source_for(authority, span.source_id) == nil then
      invalid_provenance(context, index - 1, span.source_id)
    end
    spans[index] = span
  end
  return new_token("DerivedText", {
    authority_id = authority.authority_id,
    policy = options.policy,
    spans = spans,
  })
end

function M.coordinates(authority_value, position_value, options)
  local authority = state_of(authority_value, "SourceAuthority")
  local position = state_of(position_value, "Position")
  options = options_table(options, "coordinates")
  local context = context_state(options)
  local source = source_for(authority, position.source_id)
  local index = boundary_index(source, position.offset)
  if position.authority_id ~= authority.authority_id or index == nil then
    raise_value_error(POSITION_OUT_OF_RANGE_CODE, context, {
      source_id = position.source_id,
      position_offset = position.offset,
      source_length = source and source.scalar_length or 0,
    })
  end
  return json.harray({
    source_id = position.source_id,
    offset = position.offset,
    line = source.line_at_offset[index],
    column = source.column_at_offset[index],
    utf8_byte_offset = source.byte_at_offset[index],
  })
end

function M.materialize(authority_value, value, options)
  local authority = state_of(authority_value, "SourceAuthority")
  options = options_table(options, "materialize")
  local context = context_state(options)
  local node_type = M.node_type(value)
  if node_type == "Span" then
    return materialize_span(authority, state_of(value, "Span"), context, 0)
  end
  if node_type ~= "DerivedText" then
    fail("materialize expects Span or DerivedText")
  end

  local derived = state_of(value, "DerivedText")
  if derived.authority_id ~= authority.authority_id then
    invalid_provenance(
      context,
      0,
      derived.spans[1] and derived.spans[1].source_id or ""
    )
  end
  local chunks = {}
  for index, span in ipairs(derived.spans) do
    chunks[index] = materialize_span(authority, span, context, index - 1)
  end
  return table.concat(chunks)
end

function M.to_json(value)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil then fail("to_json expects a typed source-location value") end
  if state.node_type == "Position" then
    return json.harray({ source_id = state.source_id, offset = state.offset })
  end
  if state.node_type == "Span" then return span_record(state) end
  if state.node_type == "DerivedText" then
    local spans = json.array()
    for index, span in ipairs(state.spans) do spans[index] = span_record(span) end
    return json.harray({ policy = state.policy, spans = spans })
  end
  if state.node_type == "SourceLocationException" then
    return copied_harray(state.record)
  end
  fail("to_json does not project " .. state.node_type)
end

return M
