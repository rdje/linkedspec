-- Private typed boundary for the Lua runtime's compatibility projections.
--
-- Runtime registers remain zero-based UTF-8 byte offsets. One adapter owns one
-- copied input SourceAuthority and converts those registers into immutable
-- positions/spans only while validating or projecting a helper result.

local json = require("linkedspec.json")
local source_location = require("linkedspec.source_location")

local M = {}

local INPUT_SOURCE_ID = "input"
local INVOCATION_ROLE = "compatibility_projection"

local FAMILY_ORDER = {
  "capture_mark",
  "entry_match",
  "input_cursor",
  "cursor_control",
}

local PROJECTION_ROWS = {
  capture_mark = {
    { "capture_between", "span_text" },
    { "capture_from", "span_text" },
    { "capture_len_between", "span_length" },
    { "capture_len_from", "span_length" },
    { "capture_rest", "span_text" },
    { "capture_rest_from", "span_text" },
    { "capture_rest_len", "span_length" },
    { "capture_rest_len_from", "span_length" },
    { "capture_slice", "span_text" },
    { "capture_slice_col", "span_start_column" },
    { "capture_slice_len", "span_length" },
    { "capture_slice_line", "span_start_line" },
    { "capture_slice_pos", "span_start_offset" },
    { "capture_slice_until_cursor", "span_text" },
    { "capture_slice_until_cursor_len", "span_length" },
    { "capture_until_boundary", "span_text" },
    { "capture_take", "span_text" },
    { "capture_take_between", "span_text" },
    { "capture_take_between_len", "span_length" },
    { "capture_take_len", "span_length" },
    { "capture_take_len_from", "span_length" },
    { "capture_take_rest", "span_text" },
    { "capture_take_rest_from", "span_text" },
    { "capture_take_rest_len", "span_length" },
    { "capture_take_rest_len_from", "span_length" },
    { "capture_take_until_cursor", "span_text" },
    { "capture_take_until_cursor_from", "span_text" },
    { "capture_take_until_cursor_len", "span_length" },
    { "capture_take_until_cursor_len_from", "span_length" },
    { "capture_until_cursor_from", "span_text" },
    { "capture_until_cursor_len_from", "span_length" },
    { "mark_capture_slice", "capture_boundary_write_position" },
    { "mark_copy", "mark_write_position" },
    { "mark_exists", "mark_exists" },
    { "mark_here", "mark_write_position" },
    { "mark_input_end", "mark_write_position" },
    { "mark_input_start", "mark_write_position" },
    { "mark_pos", "mark_read_offset" },
    { "start_capture_slice", "capture_boundary_write_position" },
    { "start_capture_slice_from", "capture_boundary_write_position" },
    { "clear_mark", "mark_delete" },
    { "mark_col", "mark_read_column" },
    { "mark_entry_end", "mark_write_position" },
    { "mark_entry_start", "mark_write_position" },
    { "mark_line", "mark_read_line" },
    { "mark_match_end", "mark_write_position" },
    { "mark_match_start", "mark_write_position" },
  },
  entry_match = {
    { "entry_col", "span_start_column" },
    { "entry_end_col", "position_column" },
    { "entry_end_line", "position_line" },
    { "entry_end_pos", "position_offset" },
    { "entry_group", "capture_group_text" },
    { "entry_groups", "capture_group_list" },
    { "entry_has", "capture_group_exists" },
    { "entry_len", "span_length" },
    { "entry_line", "span_start_line" },
    { "entry_map", "capture_group_map" },
    { "entry_named", "capture_group_text" },
    { "entry_start_col", "span_start_column" },
    { "entry_start_line", "span_start_line" },
    { "entry_start_pos", "span_start_offset" },
    { "entry_text", "span_text" },
    { "match_col", "span_start_column" },
    { "match_end_col", "position_column" },
    { "match_end_line", "position_line" },
    { "match_end_pos", "position_offset" },
    { "match_group", "capture_group_text" },
    { "match_groups", "capture_group_list" },
    { "match_has", "capture_group_exists" },
    { "match_len", "span_length" },
    { "match_line", "span_start_line" },
    { "match_map", "capture_group_map" },
    { "match_named", "capture_group_text" },
    { "match_start_col", "span_start_column" },
    { "match_start_line", "span_start_line" },
    { "match_start_pos", "span_start_offset" },
    { "match_text", "span_text" },
  },
  input_cursor = {
    { "cursor_col", "position_column" },
    { "cursor_line", "position_line" },
    { "cursor_pos", "cursor_position" },
    { "cursor_rest", "span_text" },
    { "cursor_rest_len", "span_length" },
    { "input_end_col", "position_column" },
    { "input_end_line", "position_line" },
    { "input_end_pos", "position_offset" },
    { "input_len", "source_length" },
    { "input_slice", "source_slice_text" },
    { "input_text", "source_text" },
  },
  cursor_control = {
    { "restore_cursor", "cursor_state_write_compatibility" },
    { "rewind_entry_start", "cursor_state_write_compatibility" },
    { "rewind_match_start", "cursor_state_write_compatibility" },
    { "save_cursor", "cursor_checkpoint_compatibility" },
  },
}

local COMPATIBILITY_ALIASES = {
  { "capture_from_rule_start", "capture_slice" },
  { "capture_len_from_rule_start", "capture_slice_len" },
  { "capture_rest_length", "capture_rest_len" },
  { "capture_slice_here", "start_capture_slice" },
  { "capture_slice_length", "capture_slice_len" },
  { "entry_named_map", "entry_map" },
  { "match_named_map", "match_map" },
}

local AdapterMethods = {}
local ADAPTER_MT = {
  __index = AdapterMethods,
  __metatable = "private RuntimeSourceLocation",
}

local function projection_context(rule_label, projection)
  return source_location.source_location_context({
    rule_role = rule_label .. ":" .. projection,
    invocation_role = INVOCATION_ROLE,
  })
end

local function compatible(operation)
  local ok, value = pcall(operation)
  if ok then return value end
  if source_location.is_error(value) then return nil end
  error(value, 0)
end

local function detached_rows(rows)
  local result = json.array()
  for index, row in ipairs(rows) do result[index] = json.array({ row[1], row[2] }) end
  return result
end

function M.projection_rows()
  local result = json.harray()
  for _, family in ipairs(FAMILY_ORDER) do
    result[family] = detached_rows(PROJECTION_ROWS[family])
  end
  return result
end

function M.compatibility_aliases()
  return detached_rows(COMPATIBILITY_ALIASES)
end

function M.runtime(input)
  if type(input) ~= "string" then error("runtime source input must be a string", 0) end
  local authority = source_location.source_authority({
    sources = json.harray({ [INPUT_SOURCE_ID] = input }),
  })
  return setmetatable({ authority = authority }, ADAPTER_MT)
end

function M.source_authority(adapter)
  if type(adapter) ~= "table" or getmetatable(adapter) ~= ADAPTER_MT.__metatable or
      source_location.node_type(adapter.authority) ~= "SourceAuthority" then
    error("runtime source authority expects the private adapter", 0)
  end
  return adapter.authority
end

function AdapterMethods:position_from_byte(byte_offset, rule_label, projection)
  return compatible(function()
    return source_location.position_from_utf8_byte(self.authority, {
      source_id = INPUT_SOURCE_ID,
      utf8_byte_offset = byte_offset,
      context = projection_context(rule_label, projection),
    })
  end)
end

function AdapterMethods:position_from_scalar(offset, rule_label, projection)
  return compatible(function()
    return source_location.position(self.authority, {
      source_id = INPUT_SOURCE_ID,
      offset = offset,
      context = projection_context(rule_label, projection),
    })
  end)
end

function AdapterMethods:span_from_bytes(start_byte, end_byte, rule_label, projection)
  local start_position = self:position_from_byte(start_byte, rule_label, projection)
  local end_position = self:position_from_byte(end_byte, rule_label, projection)
  if start_position == nil or end_position == nil then return nil end
  return compatible(function()
    return source_location.direct_span(self.authority, {
      start = start_position,
      ["end"] = end_position,
      provenance = projection,
      context = projection_context(rule_label, projection),
    })
  end)
end

function AdapterMethods:span_from_scalars(start_offset, end_offset, rule_label, projection)
  local start_position = self:position_from_scalar(start_offset, rule_label, projection)
  local end_position = self:position_from_scalar(end_offset, rule_label, projection)
  if start_position == nil or end_position == nil then return nil end
  return compatible(function()
    return source_location.direct_span(self.authority, {
      start = start_position,
      ["end"] = end_position,
      provenance = projection,
      context = projection_context(rule_label, projection),
    })
  end)
end

function AdapterMethods:position_is_valid_byte(byte_offset, rule_label, projection)
  return self:position_from_byte(byte_offset, rule_label, projection) ~= nil
end

function AdapterMethods:position_offset_from_byte(byte_offset, rule_label, projection)
  local position = self:position_from_byte(byte_offset, rule_label, projection)
  return position and source_location.position_offset(position) or nil
end

local function coordinate(adapter, field, byte_offset, rule_label, projection)
  local position = adapter:position_from_byte(byte_offset, rule_label, projection)
  if position == nil then return nil end
  return compatible(function()
    return source_location.coordinates(adapter.authority, position, {
      context = projection_context(rule_label, projection),
    })[field]
  end)
end

function AdapterMethods:position_line_from_byte(byte_offset, rule_label, projection)
  return coordinate(self, "line", byte_offset, rule_label, projection)
end

function AdapterMethods:position_column_from_byte(byte_offset, rule_label, projection)
  return coordinate(self, "column", byte_offset, rule_label, projection)
end

function AdapterMethods:span_text_from_bytes(start_byte, end_byte, rule_label, projection)
  local span = self:span_from_bytes(start_byte, end_byte, rule_label, projection)
  if span == nil then return nil end
  return compatible(function()
    return source_location.materialize(self.authority, span, {
      context = projection_context(rule_label, projection),
    })
  end)
end

function AdapterMethods:span_length_from_bytes(start_byte, end_byte, rule_label, projection)
  local span = self:span_from_bytes(start_byte, end_byte, rule_label, projection)
  return span and source_location.span_scalar_length(span) or nil
end

function AdapterMethods:span_start_offset_from_bytes(start_byte, end_byte, rule_label, projection)
  local span = self:span_from_bytes(start_byte, end_byte, rule_label, projection)
  if span == nil then return nil end
  return self:position_offset_from_byte(start_byte, rule_label, projection)
end

function AdapterMethods:span_start_line_from_bytes(start_byte, end_byte, rule_label, projection)
  if self:span_from_bytes(start_byte, end_byte, rule_label, projection) == nil then return nil end
  return self:position_line_from_byte(start_byte, rule_label, projection)
end

function AdapterMethods:span_start_column_from_bytes(start_byte, end_byte, rule_label, projection)
  if self:span_from_bytes(start_byte, end_byte, rule_label, projection) == nil then return nil end
  return self:position_column_from_byte(start_byte, rule_label, projection)
end

function AdapterMethods:source_length()
  return source_location.source_scalar_length(self.authority, INPUT_SOURCE_ID)
end

function AdapterMethods:source_text(rule_label, projection)
  local length = self:source_length()
  if length == nil then return nil end
  local span = self:span_from_scalars(0, length, rule_label, projection)
  if span == nil then return nil end
  return compatible(function()
    return source_location.materialize(self.authority, span, {
      context = projection_context(rule_label, projection),
    })
  end)
end

function AdapterMethods:source_slice(start_offset, width, rule_label, projection)
  local length = self:source_length()
  if length == nil then return nil end
  local start = math.min(start_offset, length)
  local finish = math.min(start + width, length)
  local span = self:span_from_scalars(start, finish, rule_label, projection)
  if span == nil then return nil end
  return compatible(function()
    return source_location.materialize(self.authority, span, {
      context = projection_context(rule_label, projection),
    })
  end)
end

return M
