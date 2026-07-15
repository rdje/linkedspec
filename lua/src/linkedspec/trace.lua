local json = require("linkedspec.json")

local M = {}

M.DUMP_NONE = 0
M.DUMP_LOW = 100
M.DUMP_MEDIUM = 200
M.DUMP_HIGH = 300
M.DUMP_FULL = 400
M.DUMP_DEBUG = 500

local ERROR_MT = {
  __runtime_interpreter_type = "LinkedSpecTraceException",
  __tostring = function(value) return "LinkedSpecTraceException: " .. value.message end,
}
local LEVEL_MT = { __runtime_interpreter_type = "LinkedSpecTraceLevel" }
local SINK_MT = { __runtime_interpreter_type = "LinkedSpecTraceSinkMode" }
local CONFIG_MT = { __runtime_interpreter_type = "LinkedSpecTraceConfig" }
local EVENT_MT = { __runtime_interpreter_type = "LinkedSpecTraceEvent" }
local SCOPE_MT = { __runtime_interpreter_type = "LinkedSpecTraceScope" }
local EMITTER_MT = { __runtime_interpreter_type = "LinkedSpecTraceEmitter" }

local LEVEL_VALUES = setmetatable({}, { __mode = "k" })
local SINK_VALUES = setmetatable({}, { __mode = "k" })
local CONFIG_VALUES = setmetatable({}, { __mode = "k" })
local EVENT_VALUES = setmetatable({}, { __mode = "k" })
local SCOPE_VALUES = setmetatable({}, { __mode = "k" })
local EMITTER_VALUES = setmetatable({}, { __mode = "k" })

local function fail(message)
  error(setmetatable({ message = message }, ERROR_MT), 0)
end

local function immutable_newindex()
  fail("trace values are immutable")
end

local function trim(value)
  return value:match("^%s*(.-)%s*$")
end

local function copy_array(values)
  local result = {}
  for index = 1, #values do result[index] = values[index] end
  return result
end

local function record_index(storage)
  return function(value, key)
    local fields = storage[value]
    if fields == nil then return nil end
    return fields[key]
  end
end

LEVEL_MT.__index = record_index(LEVEL_VALUES)
LEVEL_MT.__newindex = immutable_newindex
SINK_MT.__index = record_index(SINK_VALUES)
SINK_MT.__newindex = immutable_newindex
CONFIG_MT.__index = record_index(CONFIG_VALUES)
CONFIG_MT.__newindex = immutable_newindex
EVENT_MT.__index = record_index(EVENT_VALUES)
EVENT_MT.__newindex = immutable_newindex
SCOPE_MT.__index = record_index(SCOPE_VALUES)
SCOPE_MT.__newindex = immutable_newindex

local function trace_level(value)
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge or value % 1 ~= 0 then
    fail("trace level value must be a finite integer")
  end
  local result = setmetatable({}, LEVEL_MT)
  LEVEL_VALUES[result] = { value = value }
  return result
end

M.TRACE_NONE = trace_level(M.DUMP_NONE)
M.TRACE_LOW = trace_level(M.DUMP_LOW)
M.TRACE_MEDIUM = trace_level(M.DUMP_MEDIUM)
M.TRACE_HIGH = trace_level(M.DUMP_HIGH)
M.TRACE_FULL = trace_level(M.DUMP_FULL)
M.TRACE_DEBUG = trace_level(M.DUMP_DEBUG)

local function trace_sink_mode(name)
  local result = setmetatable({}, SINK_MT)
  SINK_VALUES[result] = { name = name }
  return result
end

M.TRACE_STDOUT = trace_sink_mode("stdout")
M.TRACE_ROUTE = trace_sink_mode("route")
M.TRACE_MIRROR = trace_sink_mode("mirror")

function M.is_trace_error(value) return getmetatable(value) == ERROR_MT end
function M.is_trace_level(value) return getmetatable(value) == LEVEL_MT end
function M.is_trace_sink_mode(value) return getmetatable(value) == SINK_MT end
function M.is_trace_config(value) return getmetatable(value) == CONFIG_MT end
function M.is_trace_event(value) return getmetatable(value) == EVENT_MT end
function M.is_trace_scope(value) return getmetatable(value) == SCOPE_MT end
function M.is_trace_emitter(value) return getmetatable(value) == EMITTER_MT end

function M.parse_trace_level(input)
  if M.is_trace_level(input) then return input end
  if type(input) == "number" then return trace_level(input) end
  if type(input) ~= "string" then fail("trace level must be a string, integer, or LinkedSpecTraceLevel") end
  local value = trim(input)
  if value == "" then fail("empty trace level") end
  if value:match("^[+-]?%d+$") then return trace_level(tonumber(value)) end
  local normalized = value:lower()
  if normalized == "none" or normalized == "quiet" or normalized == "off" then return M.TRACE_NONE end
  if normalized == "low" then return M.TRACE_LOW end
  if normalized == "medium" or normalized == "med" then return M.TRACE_MEDIUM end
  if normalized == "high" then return M.TRACE_HIGH end
  if normalized == "full" then return M.TRACE_FULL end
  if normalized == "debug" or normalized == "verbose" then return M.TRACE_DEBUG end
  fail("unsupported trace level '" .. input .. "'")
end

function M.trace_allows(configured, event)
  configured = M.parse_trace_level(configured)
  event = M.parse_trace_level(event)
  return configured.value > M.DUMP_NONE and event.value > M.DUMP_NONE and configured.value >= event.value
end

function M.trace_level_name(level)
  local value = M.parse_trace_level(level).value
  if value <= M.DUMP_NONE then return "none" end
  if value <= M.DUMP_LOW then return "low" end
  if value <= M.DUMP_MEDIUM then return "medium" end
  if value <= M.DUMP_HIGH then return "high" end
  if value <= M.DUMP_FULL then return "full" end
  return "debug"
end

function M.parse_trace_sink_mode(input)
  if M.is_trace_sink_mode(input) then return input end
  if type(input) ~= "string" then fail("trace sink mode must be a string or LinkedSpecTraceSinkMode") end
  local value = trim(input):lower()
  if value == "stdout" or value == "console" then return M.TRACE_STDOUT end
  if value == "route" or value == "routed" or value == "file" then return M.TRACE_ROUTE end
  if value == "mirror" or value == "both" then return M.TRACE_MIRROR end
  fail("unsupported trace sink mode '" .. input .. "'")
end

local function trace_config_from_fields(fields)
  local result = setmetatable({}, CONFIG_MT)
  CONFIG_VALUES[result] = {
    level = M.parse_trace_level(fields.level or M.TRACE_NONE),
    trace_file = fields.trace_file,
    sink_mode = M.parse_trace_sink_mode(fields.sink_mode or M.TRACE_STDOUT),
    reset_file = fields.reset_file or false,
    emoji = fields.emoji or false,
  }
  return result
end

function M.trace_config(options)
  options = options or {}
  if type(options) ~= "table" then fail("trace config options must be a table") end
  if options.trace_file ~= nil and type(options.trace_file) ~= "string" then
    fail("trace_file must be a string when present")
  end
  if options.reset_file ~= nil and type(options.reset_file) ~= "boolean" then
    fail("reset_file must be a boolean when present")
  end
  if options.emoji ~= nil and type(options.emoji) ~= "boolean" then
    fail("emoji must be a boolean when present")
  end
  return trace_config_from_fields(options)
end

function M.trace_config_disabled() return M.trace_config() end
function M.trace_config_enabled(level) return M.trace_config({ level = level }) end

function M.with_trace_level(config, level)
  if not M.is_trace_config(config) then fail("with_trace_level expects LinkedSpecTraceConfig") end
  return trace_config_from_fields({
    level = level,
    trace_file = config.trace_file,
    sink_mode = config.sink_mode,
    reset_file = config.reset_file,
    emoji = config.emoji,
  })
end

function M.with_trace_file(config, path)
  if not M.is_trace_config(config) then fail("with_trace_file expects LinkedSpecTraceConfig") end
  if type(path) ~= "string" then fail("trace file path must be a string") end
  return trace_config_from_fields({
    level = config.level,
    trace_file = path,
    sink_mode = config.sink_mode == M.TRACE_STDOUT and M.TRACE_ROUTE or config.sink_mode,
    reset_file = config.reset_file,
    emoji = config.emoji,
  })
end

function M.with_trace_sink_mode(config, sink_mode)
  if not M.is_trace_config(config) then fail("with_trace_sink_mode expects LinkedSpecTraceConfig") end
  return trace_config_from_fields({
    level = config.level,
    trace_file = config.trace_file,
    sink_mode = sink_mode,
    reset_file = config.reset_file,
    emoji = config.emoji,
  })
end

function M.with_trace_reset_file(config, reset_file)
  if not M.is_trace_config(config) then fail("with_trace_reset_file expects LinkedSpecTraceConfig") end
  if reset_file == nil then reset_file = true end
  if type(reset_file) ~= "boolean" then fail("reset_file must be a boolean") end
  return trace_config_from_fields({
    level = config.level,
    trace_file = config.trace_file,
    sink_mode = config.sink_mode,
    reset_file = reset_file,
    emoji = config.emoji,
  })
end

function M.with_trace_emoji(config, emoji)
  if not M.is_trace_config(config) then fail("with_trace_emoji expects LinkedSpecTraceConfig") end
  if emoji == nil then emoji = true end
  if type(emoji) ~= "boolean" then fail("emoji must be a boolean") end
  return trace_config_from_fields({
    level = config.level,
    trace_file = config.trace_file,
    sink_mode = config.sink_mode,
    reset_file = config.reset_file,
    emoji = emoji,
  })
end

function M.trace_should_emit(config, level)
  if M.is_trace_emitter(config) then config = EMITTER_VALUES[config].config end
  if not M.is_trace_config(config) then fail("trace_should_emit expects trace config or emitter") end
  return M.trace_allows(config.level, level)
end

local function trace_truthy(value)
  if value == nil then return false end
  local text = trim(tostring(value)):lower()
  return text ~= "" and text ~= "0" and text ~= "false" and text ~= "no" and text ~= "off"
end

function M.trace_config_from_environment(environment)
  if environment ~= nil and type(environment) ~= "table" then
    fail("trace environment must be a table when present")
  end
  local function get(name)
    if environment then return environment[name] end
    return os.getenv(name)
  end
  local config = M.trace_config_disabled()
  local level = get("LINKEDSPEC_TRACE_LEVEL")
  if level == nil then level = get("LINKEDSPEC_DUMP_VERBOSITY") end
  if level ~= nil then config = M.with_trace_level(config, level) end
  local trace_file = get("LINKEDSPEC_TRACE_FILE")
  if trace_file ~= nil then
    if type(trace_file) ~= "string" then fail("LINKEDSPEC_TRACE_FILE must be a string") end
    trace_file = trim(trace_file)
    if trace_file ~= "" then
      config = M.with_trace_file(config, trace_file)
      if trace_truthy(get("LINKEDSPEC_TRACE_MIRROR_STDOUT")) then
        config = M.with_trace_sink_mode(config, M.TRACE_MIRROR)
      end
    end
  end
  if trace_truthy(get("LINKEDSPEC_TRACE_RESET_FILE")) then
    config = M.with_trace_reset_file(config)
  end
  if trace_truthy(get("LINKEDSPEC_TRACE_EMOJI")) then config = M.with_trace_emoji(config) end
  return config
end

local EVENT_KINDS = {
  enter = true,
  exit = true,
  decision = true,
  mark = true,
  dump = true,
  log = true,
}

M.TRACE_ENTER = "enter"
M.TRACE_EXIT = "exit"
M.TRACE_DECISION = "decision"
M.TRACE_MARK = "mark"
M.TRACE_DUMP = "dump"
M.TRACE_LOG = "log"

function M.trace_event_kind_name(kind)
  if type(kind) ~= "string" or not EVENT_KINDS[kind] then
    fail("unsupported trace event kind")
  end
  return kind
end

local function trace_event(kind, topic, details, level)
  kind = M.trace_event_kind_name(kind)
  if type(topic) ~= "string" then fail("trace event topic must be a string") end
  if type(details) ~= "string" then fail("trace event details must be a string") end
  local result = setmetatable({}, EVENT_MT)
  EVENT_VALUES[result] = {
    kind = kind,
    topic = topic,
    details = details,
    level = M.parse_trace_level(level),
  }
  return result
end

local function trace_scope(topic, level, emitted)
  local result = setmetatable({}, SCOPE_MT)
  SCOPE_VALUES[result] = { topic = topic, level = level, emitted = emitted }
  return result
end

local function trace_file_path(config)
  if config.trace_file == nil or trim(config.trace_file) == "" then return nil end
  return config.trace_file
end

local function uses_file_sink(config)
  return config.sink_mode == M.TRACE_ROUTE or config.sink_mode == M.TRACE_MIRROR
end

local function open_trace_file(path, mode)
  local handle, message = io.open(path, mode)
  if not handle then fail("unable to open trace file '" .. path .. "': " .. tostring(message)) end
  return handle
end

local function prepare_trace_file(config)
  local path = trace_file_path(config)
  if path == nil or (not uses_file_sink(config) and not config.reset_file) then return end
  local handle = open_trace_file(path, config.reset_file and "wb" or "ab")
  local ok, message = handle:close()
  if ok == nil then fail("unable to close trace file '" .. path .. "': " .. tostring(message)) end
end

function M.trace_emitter(config, options)
  if not M.is_trace_config(config) then fail("trace_emitter expects LinkedSpecTraceConfig") end
  options = options or {}
  if type(options) ~= "table" then fail("trace emitter options must be a table") end
  if options.stdout_writer ~= nil and type(options.stdout_writer) ~= "function" then
    fail("stdout_writer must be a function when present")
  end
  prepare_trace_file(config)
  local result = setmetatable({}, EMITTER_MT)
  EMITTER_VALUES[result] = {
    config = config,
    stdout_writer = options.stdout_writer or function(payload) io.stdout:write(payload) end,
    events = {},
    lines = {},
    indent_level = 0,
  }
  return result
end

function M.trace_config_of(emitter)
  if not M.is_trace_emitter(emitter) then fail("trace_config_of expects LinkedSpecTraceEmitter") end
  return EMITTER_VALUES[emitter].config
end

function M.trace_events(emitter)
  if not M.is_trace_emitter(emitter) then fail("trace_events expects LinkedSpecTraceEmitter") end
  return copy_array(EMITTER_VALUES[emitter].events)
end

function M.trace_lines(emitter)
  if not M.is_trace_emitter(emitter) then fail("trace_lines expects LinkedSpecTraceEmitter") end
  return copy_array(EMITTER_VALUES[emitter].lines)
end

local function write_trace_payload(emitter, payload)
  local state = EMITTER_VALUES[emitter]
  local config = state.config
  if config.sink_mode ~= M.TRACE_ROUTE then state.stdout_writer(payload) end
  local path = trace_file_path(config)
  if uses_file_sink(config) and path ~= nil then
    local handle = open_trace_file(path, "ab")
    local ok, message = handle:write(payload)
    if ok == nil then
      handle:close()
      fail("unable to write trace file '" .. path .. "': " .. tostring(message))
    end
    ok, message = handle:close()
    if ok == nil then fail("unable to close trace file '" .. path .. "': " .. tostring(message)) end
  end
end

function M.emit_trace_line(emitter, level, line)
  if not M.is_trace_emitter(emitter) then fail("emit_trace_line expects LinkedSpecTraceEmitter") end
  if type(line) ~= "string" then fail("trace line must be a string") end
  level = M.parse_trace_level(level)
  if not M.trace_should_emit(emitter, level) then return nil end
  local payload = line:sub(-1) == "\n" and line or (line .. "\n")
  local state = EMITTER_VALUES[emitter]
  state.lines[#state.lines + 1] = payload
  write_trace_payload(emitter, payload)
  return nil
end

local function emoji_prefix(config, level)
  if not config.emoji then return "" end
  if level.value <= M.DUMP_NONE then return "🛑 " end
  if level.value <= M.DUMP_LOW then return "ℹ️ " end
  if level.value <= M.DUMP_MEDIUM then return "🔎 " end
  if level.value <= M.DUMP_HIGH then return "🧭 " end
  if level.value <= M.DUMP_FULL then return "🐞 " end
  return "🔥 "
end

local function render_trace_event(emitter, event)
  local state = EMITTER_VALUES[emitter]
  local indent = string.rep("  ", state.indent_level)
  local details = trim(event.details) == "" and "" or (" " .. event.details)
  local level = M.trace_level_name(event.level):upper()
  local prefix = emoji_prefix(state.config, event.level)
  if event.kind == "enter" then
    return "[" .. level .. "][enter] " .. indent .. prefix .. "-> " .. event.topic .. details
  end
  if event.kind == "exit" then
    return "[" .. level .. "][exit] " .. indent .. prefix .. "<- " .. event.topic .. details
  end
  return "[" .. level .. "][" .. event.kind .. "] " .. indent .. prefix .. event.topic .. details
end

function M.emit_trace_event(emitter, kind, topic, details, level)
  if not M.is_trace_emitter(emitter) then fail("emit_trace_event expects LinkedSpecTraceEmitter") end
  level = M.parse_trace_level(level)
  if not M.trace_should_emit(emitter, level) then return nil end
  local event = trace_event(kind, topic, details, level)
  local state = EMITTER_VALUES[emitter]
  state.events[#state.events + 1] = event
  M.emit_trace_line(emitter, level, render_trace_event(emitter, event))
  return event
end

function M.enter_trace_scope(emitter, topic, details, level)
  if not M.is_trace_emitter(emitter) then fail("enter_trace_scope expects LinkedSpecTraceEmitter") end
  level = M.parse_trace_level(level)
  local emitted = M.trace_should_emit(emitter, level)
  if emitted then
    M.emit_trace_event(emitter, "enter", topic, details, level)
    EMITTER_VALUES[emitter].indent_level = EMITTER_VALUES[emitter].indent_level + 1
  end
  return trace_scope(topic, level, emitted)
end

function M.exit_trace_scope(emitter, scope, details)
  if not M.is_trace_emitter(emitter) then fail("exit_trace_scope expects LinkedSpecTraceEmitter") end
  if not M.is_trace_scope(scope) then fail("exit_trace_scope expects LinkedSpecTraceScope") end
  if type(details) ~= "string" then fail("trace scope exit details must be a string") end
  if not scope.emitted then return nil end
  local state = EMITTER_VALUES[emitter]
  state.indent_level = math.max(0, state.indent_level - 1)
  M.emit_trace_event(emitter, "exit", scope.topic, details, scope.level)
  return nil
end

function M.trace_decision(emitter, topic, taken, reason, level)
  if type(taken) ~= "boolean" then fail("trace decision taken value must be a boolean") end
  if type(reason) ~= "string" then fail("trace decision reason must be a string") end
  M.emit_trace_event(
    emitter,
    "decision",
    topic,
    "taken=" .. (taken and "1" or "0") .. " reason=" .. reason,
    level
  )
  return taken
end

function M.log_trace_output(emitter, level, message, context)
  if type(message) ~= "string" then fail("trace log message must be a string") end
  if context == nil then context = "" end
  if type(context) ~= "string" then fail("trace log context must be a string") end
  local details = context == "" and message or (message .. " context=" .. context)
  return M.emit_trace_event(emitter, "log", "log_output", details, level)
end

function M.log_trace_dump(emitter, level, message)
  if type(message) ~= "string" then fail("trace dump message must be a string") end
  return M.emit_trace_event(emitter, "dump", "log_dump", message, level)
end

function M.to_json(value)
  if not M.is_trace_event(value) then fail("trace to_json expects LinkedSpecTraceEvent") end
  return json.harray({
    kind = value.kind,
    topic = value.topic,
    details = value.details,
    level = M.trace_level_name(value.level),
    level_value = value.level.value,
  })
end

return M
