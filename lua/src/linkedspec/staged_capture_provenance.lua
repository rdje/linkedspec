-- Private weak-key storage for staged capture provenance.
--
-- Runtime match objects and their public JSON retain no capture-range field.
-- Only the staged declaration carrier can retrieve the owned numeric pairs.

local M = {}

local ranges_by_match = setmetatable({}, { __mode = "k" })

function M.record(match, raw_ranges)
  if type(match) ~= "table" or type(raw_ranges) ~= "table" then
    error("staged capture provenance expects a match and range array", 0)
  end
  local owned = {}
  for index, value in ipairs(raw_ranges) do
    if type(value) ~= "table" or type(value.start_byte) ~= "number" or
        type(value.end_byte) ~= "number" then
      error("staged capture provenance range is malformed", 0)
    end
    owned[index] = { start_byte = value.start_byte, end_byte = value.end_byte }
  end
  ranges_by_match[match] = owned
  return match
end

function M.copy(source, target)
  local ranges = ranges_by_match[source]
  if ranges == nil then error("staged capture provenance source is unknown", 0) end
  return M.record(target, ranges)
end

function M.byte_span(match, index)
  if type(index) ~= "number" or index ~= math.floor(index) or index < 0 then
    error("staged capture index must be a non-negative integer", 0)
  end
  local ranges = ranges_by_match[match]
  local value = ranges and ranges[index + 1] or nil
  if value == nil then return nil end
  return value.start_byte, value.end_byte
end

return M
