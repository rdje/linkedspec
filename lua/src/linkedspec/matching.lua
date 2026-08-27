local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local native = require("linkedspec_regex_pcre2")
local staged_capture_provenance = require("linkedspec.staged_capture_provenance")

local M = {}

local ERROR_MT = {
  __tostring = function(value)
    return "RuntimeRegexException: " .. value.message
  end,
}

local AlternationMethods = {}
local MatchMethods = {}
local RegisterMethods = {}

local TYPE_MTS = {
  RuntimeRegexAlternative = { __runtime_match_type = "RuntimeRegexAlternative" },
  RuntimeRegexAlternation = {
    __runtime_match_type = "RuntimeRegexAlternation",
    __index = AlternationMethods,
  },
  RuntimeRegexMatch = { __runtime_match_type = "RuntimeRegexMatch", __index = MatchMethods },
  RuntimeLineColumn = { __runtime_match_type = "RuntimeLineColumn" },
  RuntimeMatchRegisters = {
    __runtime_match_type = "RuntimeMatchRegisters",
    __index = RegisterMethods,
  },
}

local function fail(message, fields)
  fields = fields or {}
  fields.message = message
  error(setmetatable(fields, ERROR_MT), 0)
end

function M.is_runtime_regex_error(value)
  return getmetatable(value) == ERROR_MT
end

function M.node_type(value)
  if type(value) ~= "table" then return nil end
  local metatable = getmetatable(value)
  return metatable and metatable.__runtime_match_type or nil
end

function M.runtime_regex_engine()
  return "pcre2-native"
end

function M.runtime_regex_engine_version()
  return native.version()
end

function M.parse_mode_from_name(name)
  if name == "seek" or name == "consume" then return name end
  fail("unsupported parse mode '" .. tostring(name) .. "'", { stage = "parse_mode", parse_mode = name })
end

function M.parse_mode_name(mode)
  return M.parse_mode_from_name(mode)
end

local function normalize_mode(mode)
  if mode == nil then return "seek" end
  return M.parse_mode_from_name(mode)
end

local function validate_utf8(value, context)
  if type(value) ~= "string" then fail(context .. " must be a string") end
  local valid, position = json.validate_utf8(value)
  if not valid then
    fail(context .. " is not valid UTF-8 at byte " .. (position - 1), {
      stage = "regex_input",
      byte_offset = position - 1,
    })
  end
  return value
end

local function is_utf8_boundary(input, offset)
  if offset == 0 or offset == #input then return true end
  local byte = input:byte(offset + 1)
  return byte < 0x80 or byte > 0xBF
end

local function checked_byte_offset(input, offset)
  if type(offset) ~= "number" or offset % 1 ~= 0 then
    fail("byte offset must be an integer", { stage = "regex_offset" })
  end
  if offset < 0 then offset = 0 end
  if offset > #input then offset = #input end
  if not is_utf8_boundary(input, offset) then
    fail("byte offset " .. offset .. " is not a UTF-8 character boundary", {
      stage = "regex_offset",
      byte_offset = offset,
    })
  end
  return offset
end

local function utf8_width(input, index)
  local first = input:byte(index)
  if first <= 0x7F then return 1 end
  if first <= 0xDF then return 2 end
  if first <= 0xEF then return 3 end
  return 4
end

function M.byte_offset_to_char_offset(input, byte_offset)
  input = validate_utf8(input, "regex input")
  local target = checked_byte_offset(input, byte_offset)
  local byte_index = 1
  local char_offset = 0
  while byte_index <= target do
    byte_index = byte_index + utf8_width(input, byte_index)
    char_offset = char_offset + 1
  end
  return char_offset
end

function M.char_offset_to_byte_offset(input, char_offset)
  input = validate_utf8(input, "regex input")
  if type(char_offset) ~= "number" or char_offset % 1 ~= 0 then
    fail("character offset must be an integer", { stage = "regex_offset" })
  end
  if char_offset < 0 then char_offset = 0 end
  local byte_index = 1
  local current = 0
  while byte_index <= #input and current < char_offset do
    byte_index = byte_index + utf8_width(input, byte_index)
    current = current + 1
  end
  return byte_index - 1
end

function M.line_column_at_byte_offset(input, byte_offset)
  input = validate_utf8(input, "regex input")
  local target = checked_byte_offset(input, byte_offset)
  local line = 1
  local column = 1
  local byte_index = 1
  while byte_index <= target do
    local first = input:byte(byte_index)
    if first == 0x0A then
      line = line + 1
      column = 1
    else
      column = column + 1
    end
    byte_index = byte_index + utf8_width(input, byte_index)
  end
  return setmetatable({ line = line, column = column }, TYPE_MTS.RuntimeLineColumn)
end

local function patterns_from(value)
  if compiled_spec.node_type(value) == "CompiledRule" then return value.regex_patterns end
  if type(value) ~= "table" then fail("regex patterns must be a dense list or CompiledRule") end
  local count = 0
  local max_index = 0
  for key in pairs(value) do
    if type(key) ~= "number" or key % 1 ~= 0 or key < 1 then
      fail("regex patterns must use one-based integer indexes")
    end
    count = count + 1
    if key > max_index then max_index = key end
  end
  if count ~= max_index then fail("regex patterns must not be sparse") end
  return value
end

function M.compile_runtime_regex_alternation(value)
  local patterns = patterns_from(value)
  local alternatives = {}
  for index, pattern in ipairs(patterns) do
    validate_utf8(pattern, "regex pattern")
    local ok, compiled_or_error = pcall(native.compile, pattern)
    if not ok then
      fail(
        "regex compile error for alternative " .. (index - 1) .. " '/" .. pattern .. "/': " ..
          tostring(compiled_or_error),
        {
          stage = "regex_compile",
          alternative_index = index - 1,
          pattern = pattern,
        }
      )
    end
    alternatives[index] = setmetatable({
      index = index - 1,
      pattern = pattern,
      native_regex = compiled_or_error,
    }, TYPE_MTS.RuntimeRegexAlternative)
  end
  return setmetatable({ alternatives = alternatives }, TYPE_MTS.RuntimeRegexAlternation)
end

local function runtime_regex_match(input, alternative, raw)
  local match = setmetatable({
    input = input,
    alternative_index = alternative.index,
    pattern = alternative.pattern,
    byte_start = raw.start_byte,
    byte_end = raw.end_byte,
    groups = raw.groups,
    captures = raw.captures,
    named = raw.named,
  }, TYPE_MTS.RuntimeRegexMatch)
  return staged_capture_provenance.record(match, raw.capture_spans)
end

function M.reindex_runtime_regex_match(match, alternative_index)
  if M.node_type(match) ~= "RuntimeRegexMatch" then fail("reindex expects RuntimeRegexMatch") end
  if type(alternative_index) ~= "number" or alternative_index % 1 ~= 0 or alternative_index < 0 then
    fail("reindexed alternative must be a non-negative integer")
  end
  local reindexed = setmetatable({
    input = match.input,
    alternative_index = alternative_index,
    pattern = match.pattern,
    byte_start = match.byte_start,
    byte_end = match.byte_end,
    groups = match.groups,
    captures = match.captures,
    named = match.named,
  }, TYPE_MTS.RuntimeRegexMatch)
  return staged_capture_provenance.copy(match, reindexed)
end

local function native_match(alternative, input, byte_cursor, anchored)
  local ok, raw_or_error = pcall(native.match, alternative.native_regex, input, byte_cursor, anchored)
  if not ok then
    fail("regex match error for /" .. alternative.pattern .. "/: " .. tostring(raw_or_error), {
      stage = "regex_match",
      alternative_index = alternative.index,
      pattern = alternative.pattern,
    })
  end
  if raw_or_error == nil then return nil end
  return runtime_regex_match(input, alternative, raw_or_error)
end

local function validate_alternation(value)
  if M.node_type(value) ~= "RuntimeRegexAlternation" then
    fail("expected RuntimeRegexAlternation")
  end
  return value
end

function M.seek_match(alternation, input, byte_cursor)
  validate_alternation(alternation)
  input = validate_utf8(input, "regex input")
  local cursor = checked_byte_offset(input, byte_cursor or 0)
  local best = nil
  for _, alternative in ipairs(alternation.alternatives) do
    local candidate = native_match(alternative, input, cursor, false)
    if candidate and (
      best == nil or
      candidate.byte_start < best.byte_start or
      (candidate.byte_start == best.byte_start and candidate.alternative_index < best.alternative_index)
    ) then
      best = candidate
    end
  end
  return best
end

function M.consume_match(alternation, input, byte_cursor)
  validate_alternation(alternation)
  input = validate_utf8(input, "regex input")
  local cursor = checked_byte_offset(input, byte_cursor or 0)
  for _, alternative in ipairs(alternation.alternatives) do
    local candidate = native_match(alternative, input, cursor, true)
    if candidate then return candidate end
  end
  return nil
end

function M.runtime_match(alternation, input, byte_cursor, parse_mode)
  local mode = normalize_mode(parse_mode)
  if mode == "seek" then return M.seek_match(alternation, input, byte_cursor) end
  return M.consume_match(alternation, input, byte_cursor)
end

function M.match_runtime_regex_slot(alternation, alternative_index, input, byte_cursor, parse_mode)
  validate_alternation(alternation)
  if type(alternative_index) ~= "number" or alternative_index % 1 ~= 0 or alternative_index < 0 or
      alternative_index >= #alternation.alternatives then
    fail("runtime regex slot index is out of range", {
      stage = "regex_slot",
      alternative_index = alternative_index,
    })
  end
  input = validate_utf8(input, "regex input")
  local cursor = checked_byte_offset(input, byte_cursor or 0)
  local mode = normalize_mode(parse_mode)
  return native_match(alternation.alternatives[alternative_index + 1], input, cursor, mode == "consume")
end

function AlternationMethods:seek_match(input, byte_cursor)
  return M.seek_match(self, input, byte_cursor)
end

function AlternationMethods:consume_match(input, byte_cursor)
  return M.consume_match(self, input, byte_cursor)
end

function AlternationMethods:match(input, byte_cursor, parse_mode)
  return M.runtime_match(self, input, byte_cursor, parse_mode)
end

function AlternationMethods:match_slot(alternative_index, input, byte_cursor, parse_mode)
  return M.match_runtime_regex_slot(self, alternative_index, input, byte_cursor, parse_mode)
end

function AlternationMethods:is_empty()
  return #self.alternatives == 0
end

function MatchMethods:text()
  return self.groups[1] or ""
end

function MatchMethods:byte_length()
  return self.byte_end - self.byte_start
end

function MatchMethods:char_start()
  return M.byte_offset_to_char_offset(self.input, self.byte_start)
end

function MatchMethods:char_end()
  return M.byte_offset_to_char_offset(self.input, self.byte_end)
end

function MatchMethods:char_length()
  return self:char_end() - self:char_start()
end

function MatchMethods:is_zero_width()
  return self.byte_start == self.byte_end
end

function MatchMethods:named_capture(name)
  if type(name) ~= "string" then fail("named capture name must be a string") end
  return self.named[name]
end

function MatchMethods:start_line_column()
  return M.line_column_at_byte_offset(self.input, self.byte_start)
end

function MatchMethods:made_progress_from(byte_cursor)
  return self.byte_end > checked_byte_offset(self.input, byte_cursor)
end

function MatchMethods:is_zero_progress_from(byte_cursor)
  return self.byte_end == checked_byte_offset(self.input, byte_cursor)
end

local function validate_match_input(input, match, context)
  if match ~= nil then
    if M.node_type(match) ~= "RuntimeRegexMatch" then fail(context .. " must be RuntimeRegexMatch") end
    if match.input ~= input then fail(context .. " input does not belong to register input") end
  end
end

function M.runtime_match_registers(input, options)
  input = validate_utf8(input, "register input")
  options = options or {}
  if type(options) ~= "table" then fail("register options must be a table") end
  local cursor = checked_byte_offset(input, options.cursor_byte or 0)
  local capture_start
  if options.capture_start_byte == json.null then
    capture_start = nil
  elseif options.capture_start_byte == nil then
    capture_start = cursor
  else
    capture_start = checked_byte_offset(input, options.capture_start_byte)
  end
  validate_match_input(input, options.entry_match, "entry match")
  validate_match_input(input, options.local_match, "local match")
  return setmetatable({
    input = input,
    cursor_byte = cursor,
    entry_match = options.entry_match,
    local_match = options.local_match,
    capture_start_byte = capture_start,
  }, TYPE_MTS.RuntimeMatchRegisters)
end

function RegisterMethods:cursor_char_offset()
  return M.byte_offset_to_char_offset(self.input, self.cursor_byte)
end

function RegisterMethods:cursor_line_column()
  return M.line_column_at_byte_offset(self.input, self.cursor_byte)
end

function RegisterMethods:enter_child()
  return M.runtime_match_registers(self.input, {
    cursor_byte = self.cursor_byte,
    entry_match = self.local_match,
    capture_start_byte = self.local_match and self.local_match.byte_end or self.cursor_byte,
  })
end

function RegisterMethods:with_local_match(match)
  validate_match_input(self.input, match, "local match")
  return M.runtime_match_registers(self.input, {
    cursor_byte = match.byte_end,
    entry_match = self.entry_match or match,
    local_match = match,
    capture_start_byte = self.capture_start_byte == nil and match.byte_end or self.capture_start_byte,
  })
end

function RegisterMethods:with_cursor_byte(byte_cursor)
  return M.runtime_match_registers(self.input, {
    cursor_byte = byte_cursor,
    entry_match = self.entry_match,
    local_match = self.local_match,
    capture_start_byte = self.capture_start_byte == nil and json.null or self.capture_start_byte,
  })
end

function RegisterMethods:with_capture_start_byte(byte_cursor)
  return M.runtime_match_registers(self.input, {
    cursor_byte = self.cursor_byte,
    entry_match = self.entry_match,
    local_match = self.local_match,
    capture_start_byte = byte_cursor,
  })
end

function RegisterMethods:zero_progress_since(previous_byte_cursor)
  return self.cursor_byte == checked_byte_offset(self.input, previous_byte_cursor)
end

local function string_array(values)
  local result = json.array()
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function string_harray(values)
  local result = json.harray()
  for key, value in pairs(values) do result[key] = value end
  return result
end

local function match_to_json(match)
  local line_column = match:start_line_column()
  return json.harray({
    alternative_index = match.alternative_index,
    pattern = match.pattern,
    text = match:text(),
    code_unit_start = match.byte_start,
    code_unit_end = match.byte_end,
    code_unit_length = match:byte_length(),
    char_start = match:char_start(),
    char_end = match:char_end(),
    char_length = match:char_length(),
    line = line_column.line,
    column = line_column.column,
    groups = string_array(match.groups),
    captures = string_array(match.captures),
    named = string_harray(match.named),
    zero_width = match:is_zero_width(),
  })
end

function M.to_json(value)
  local node_type = M.node_type(value)
  if node_type == "RuntimeRegexAlternation" then
    local patterns = json.array()
    for index, alternative in ipairs(value.alternatives) do patterns[index] = alternative.pattern end
    return json.harray({ patterns = patterns })
  elseif node_type == "RuntimeRegexMatch" then
    return match_to_json(value)
  elseif node_type == "RuntimeLineColumn" then
    return json.harray({ line = value.line, column = value.column })
  elseif node_type == "RuntimeMatchRegisters" then
    local line_column = value:cursor_line_column()
    local result = json.harray({
      cursor_code_unit = value.cursor_byte,
      cursor_char_offset = value:cursor_char_offset(),
      cursor_line = line_column.line,
      cursor_column = line_column.column,
    })
    if value.capture_start_byte ~= nil then result.capture_start_code_unit = value.capture_start_byte end
    if value.entry_match then result.entry_match = match_to_json(value.entry_match) end
    if value.local_match then result.local_match = match_to_json(value.local_match) end
    return result
  end
  fail("to_json expects runtime matching state")
end

return M
