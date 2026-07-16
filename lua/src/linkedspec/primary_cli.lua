local compiled_spec = require("linkedspec.compiled_spec")
local filesystem = require("linkedspec_filesystem_native")
local interpreter = require("linkedspec.interpreter")
local json = require("linkedspec.json")
local spec_loader = require("linkedspec.spec_loader")
local function_parser = require("linkedspec.user_function_definition_parser")

local M = {}

M.DISPLAY_COMMAND = "lua/bin/linkedspec-lua"

local HELP_TEMPLATE = [[Usage:
  {{COMMAND}} --spec NAME --input TEXT [options]
  {{COMMAND}} --spec-file PATH --input-file PATH [options]
  {{COMMAND}} --inline-spec TEXT --input TEXT [options]

Source selection (choose exactly one):
  --spec NAME          Resolve and compile a named .spec
  --spec-file PATH     Compile .spec source read from PATH
  --inline-spec TEXT   Compile the literal .spec source TEXT

Input selection (choose exactly one):
  --input TEXT         Parse TEXT
  --input-file PATH    Parse file contents read from PATH

Text encoding:
  Arguments, source, input, JSON, help/errors, and trace use strict UTF-8.
  Text is not normalized, trimmed, or newline/BOM converted. UTF-16/UTF-32
  files are not detected implicitly.

Parser options:
  --top-rule NAME      Select the entry rule
  --parse-mode MODE    MODE is seek or consume

Trace options:
  --trace LEVEL        LEVEL is none/quiet, low, medium/med, high, full,
                       debug/verbose, or an integer
  --trace-file PATH    Write trace output to PATH
  --trace-mode MODE    MODE is stdout, route, or mirror
  --trace-reset        Truncate --trace-file before writing
  --trace-emoji        Enable emoji trace prefixes

Help:
  --help, -h           Show this help

Trace output:
  Emits deterministic compile/input/invoke phase records shared by every primary
  backend command. Native embedding APIs retain richer backend-internal events.

Output:
  Prints the parser result as canonical JSON on stdout. When trace output is sent
  to stdout it is intentionally interleaved with that JSON; use --trace-file with
  --trace-mode route for machine-readable stdout plus routed trace.

Failures:
  Compilation, input-load, and parser-invocation failures write one stable phase
  heading to stderr and exit 1. Usage errors write this help and exit 2.

Examples:
  {{COMMAND}} --spec Lispish --input '(hello world)'
  {{COMMAND}} --spec-file demo.spec --input-file demo.txt \
    --trace high --trace-file linkedspec.trace.log --trace-mode route --trace-reset
]]

local VALUE_OPTIONS = {
  ["--spec"] = "spec",
  ["--spec-file"] = "spec_file",
  ["--inline-spec"] = "inline_spec",
  ["--input"] = "input",
  ["--input-file"] = "input_file",
  ["--top-rule"] = "top_rule",
  ["--parse-mode"] = "parse_mode",
  ["--trace"] = "trace_level",
  ["--trace-file"] = "trace_file",
  ["--trace-mode"] = "trace_mode",
}

local TRACE_LEVELS = {
  none = 0,
  quiet = 0,
  low = 100,
  medium = 200,
  med = 200,
  high = 300,
  full = 400,
  debug = 500,
  verbose = 500,
}

local TRACE_EMOJI = {
  [100] = "ℹ️",
  [200] = "🔎",
  [300] = "🧭",
  [400] = "🐞",
  [500] = "🔥",
}

local HOST_SEPARATOR = package.config:sub(1, 1)

local function command_result(stdout, stderr, exit_code)
  return { stdout = stdout, stderr = stderr, exit_code = exit_code }
end

function M.help(display_command)
  display_command = display_command or M.DISPLAY_COMMAND
  return (HELP_TEMPLATE:gsub("{{COMMAND}}", function() return display_command end))
end

local function usage_failure(message, display_command)
  return command_result("", "linkedspec: " .. message .. "\n\n" .. M.help(display_command), 2)
end

local function operational_failure(message, stdout)
  return command_result(stdout or "", "linkedspec: " .. message .. "\n", 1)
end

local function split_option(argument)
  if argument:sub(1, 2) == "--" then
    local equals = argument:find("=", 3, true)
    if equals then return argument:sub(1, equals - 1), argument:sub(equals + 1) end
  end
  return argument, nil
end

local function defined_count(...)
  local count = 0
  for index = 1, select("#", ...) do
    local value = select(index, ...)
    if value ~= nil then count = count + 1 end
  end
  return count
end

local function valid_trace_level(value)
  return value:match("^-?%d+$") ~= nil or TRACE_LEVELS[value:lower()] ~= nil
end

local function parse_arguments(arguments)
  local options = { trace_reset = false, trace_emoji = false }
  local errors = {}
  local help = false
  local index = 1
  while index <= #arguments do
    local argument = arguments[index]
    local option, inline_value = split_option(argument)
    if option == "--help" or option == "-h" then
      if inline_value ~= nil then
        errors[#errors + 1] = option .. " does not accept a value"
      else
        help = true
      end
    elseif option == "--trace-reset" or option == "--trace-emoji" then
      if inline_value ~= nil then
        errors[#errors + 1] = option .. " does not accept a value"
      elseif option == "--trace-reset" then
        options.trace_reset = true
      else
        options.trace_emoji = true
      end
    elseif VALUE_OPTIONS[option] ~= nil then
      local value = inline_value
      if value == nil then
        if index + 1 > #arguments then
          errors[#errors + 1] = option .. " requires a value"
        else
          index = index + 1
          value = arguments[index]
        end
      end
      if value ~= nil then options[VALUE_OPTIONS[option]] = value end
    elseif option:sub(1, 1) == "-" then
      errors[#errors + 1] = "unknown option '" .. option .. "'"
    else
      errors[#errors + 1] = "unexpected positional argument '" .. argument .. "'"
    end
    index = index + 1
  end

  if #errors > 0 then return nil, false, table.concat(errors, "; ") end
  if help then return nil, true, nil end
  if defined_count(options.spec, options.spec_file, options.inline_spec) ~= 1 then
    return nil, false, "choose exactly one source option: --spec, --spec-file, or --inline-spec"
  end
  if defined_count(options.input, options.input_file) ~= 1 then
    return nil, false, "choose exactly one input option: --input or --input-file"
  end
  if options.parse_mode ~= nil and options.parse_mode ~= "seek" and options.parse_mode ~= "consume" then
    return nil, false, "--parse-mode must be 'seek' or 'consume'"
  end
  if options.trace_level ~= nil and not valid_trace_level(options.trace_level) then
    return nil, false, "--trace has an unsupported level '" .. options.trace_level .. "'"
  end
  if options.trace_mode ~= nil and options.trace_mode ~= "stdout" and
      options.trace_mode ~= "route" and options.trace_mode ~= "mirror" then
    return nil, false, "--trace-mode must be 'stdout', 'route', or 'mirror'"
  end
  return options, false, nil
end

local function is_absolute_path(path)
  if HOST_SEPARATOR == "/" then return path:sub(1, 1) == "/" end
  return path:match("^[A-Za-z]:[\\/]") ~= nil or path:sub(1, 2) == "\\\\"
end

local function join_path(parent, child)
  if is_absolute_path(child) then return child end
  if parent:sub(-1) == "/" or parent:sub(-1) == "\\" then return parent .. child end
  return parent .. HOST_SEPARATOR .. child
end

local function trace_level_number(value)
  if value == nil then return 0 end
  if value:match("^-?%d+$") then return tonumber(value) end
  return TRACE_LEVELS[value:lower()]
end

local function trace_field(value)
  local result = {}
  for index = 1, #value do
    local byte = value:byte(index)
    local allowed = (byte >= 0x30 and byte <= 0x39) or
      (byte >= 0x41 and byte <= 0x5A) or
      (byte >= 0x61 and byte <= 0x7A) or
      byte == 0x5F or byte == 0x2E or byte == 0x3A or byte == 0x2D
    result[#result + 1] = allowed and string.char(byte) or string.format("%%%02X", byte)
  end
  return table.concat(result)
end

local function reset_file(path)
  local handle = io.open(path, "wb")
  if not handle then return false end
  local closed = handle:close()
  return closed ~= nil
end

local function append_file(path, payload)
  local handle = io.open(path, "ab")
  if not handle then return false end
  local written = handle:write(payload)
  local closed = handle:close()
  return written ~= nil and closed ~= nil
end

local function create_trace(options, cwd)
  local file = options.trace_file
  if file == "" then file = nil end
  if file ~= nil then file = join_path(cwd, file) end
  local mode = options.trace_mode or (file ~= nil and "route" or "stdout")
  if options.trace_reset and file ~= nil and not reset_file(file) then return nil end
  return {
    level = trace_level_number(options.trace_level),
    file = file,
    mode = mode,
    emoji = options.trace_emoji,
    stdout = {},
  }
end

local function emit_trace(trace, threshold, level_name, event)
  if trace.level < threshold then return true end
  local emoji = trace.emoji and (TRACE_EMOJI[threshold] .. " ") or ""
  local payload = "[linkedspec][" .. level_name .. "] " .. emoji .. event .. "\n"
  if trace.mode == "stdout" or trace.mode == "mirror" then
    trace.stdout[#trace.stdout + 1] = payload
  end
  if (trace.mode == "route" or trace.mode == "mirror") and trace.file ~= nil then
    return append_file(trace.file, payload)
  end
  return true
end

local function trace_stdout(trace)
  return table.concat(trace.stdout)
end

local function strict_utf8_file(path)
  local handle = io.open(path, "rb")
  if not handle then return nil end
  local content = handle:read("*a")
  local closed = handle:close()
  if content == nil or closed == nil or not json.validate_utf8(content) then return nil end
  return content
end

local function compile_request(options, cwd, repo_root)
  if options.inline_spec ~= nil then
    local parsed = function_parser.parse_spec_with_staged_user_function_definitions(options.inline_spec)
    return { compiled = compiled_spec.compile_spec(parsed) }
  end

  local request
  local search_roots = {}
  if options.spec ~= nil then
    request = spec_loader.named_spec_request(options.spec)
    if repo_root ~= nil then search_roots[1] = join_path(repo_root, "specs") end
  else
    request = spec_loader.path_spec_request(options.spec_file)
  end
  local loaded = spec_loader.load_and_compile_spec(
    request,
    spec_loader.spec_load_options({ cwd = cwd, search_roots = search_roots })
  )
  return { compiled = loaded.compiled, loaded = loaded }
end

local function load_input(options, cwd)
  if options.input_file == nil then return options.input end
  return strict_utf8_file(join_path(cwd, options.input_file))
end

local function execute_request(prepared, options, input)
  local engine_options = { parse_mode = options.parse_mode or "seek" }
  local engine
  if prepared.loaded ~= nil then
    engine = prepared.loaded:create_engine(engine_options)
  else
    engine = interpreter.runtime_engine(prepared.compiled, engine_options)
  end
  local parse_options = {}
  if options.top_rule ~= nil then parse_options.top_rule = options.top_rule end
  return interpreter.runtime_execute(engine, input, parse_options)
end

function M.run(arguments, context)
  context = context or {}
  local display_command = context.display_command or M.DISPLAY_COMMAND
  local options, help, argument_error = parse_arguments(arguments)
  if argument_error ~= nil then return usage_failure(argument_error, display_command) end
  if help then return command_result(M.help(display_command), "", 0) end

  local cwd = context.cwd or filesystem.current_directory()
  local trace = create_trace(options, cwd)
  if trace == nil then return operational_failure("parser compilation failed") end
  local source_kind = options.spec ~= nil and "named" or (options.spec_file ~= nil and "file" or "inline")
  local input_kind = options.input_file ~= nil and "file" or "literal"
  local source_argument = options.spec or options.spec_file or options.inline_spec or ""
  local input_argument = options.input_file or options.input or ""
  local top_rule = options.top_rule ~= nil and trace_field(options.top_rule) or "<default>"
  local parse_mode = options.parse_mode or "seek"

  local function emit(threshold, level_name, event)
    if emit_trace(trace, threshold, level_name, event) then return nil end
    return operational_failure("parser compilation failed", trace_stdout(trace))
  end

  local function phase_failure(event, message)
    local emitted = emit_trace(trace, 100, "low", event)
    return operational_failure(emitted and message or "parser compilation failed", trace_stdout(trace))
  end

  local trace_failure = emit(100, "low", "compile:start") or
    emit(200, "medium", "request source=" .. source_kind .. " input=" .. input_kind ..
      " top_rule=" .. top_rule .. " parse_mode=" .. parse_mode) or
    emit(300, "high", "arguments source_bytes=" .. #source_argument .. " input_bytes=" .. #input_argument) or
    emit(500, "debug", "protocol version=1")
  if trace_failure ~= nil then return trace_failure end

  local compiled_ok, prepared = pcall(compile_request, options, cwd, context.repo_root)
  if not compiled_ok then return phase_failure("compile:error", "parser compilation failed") end
  local compile_trace_failure = emit(100, "low", "compile:ok")
  if compile_trace_failure ~= nil then return compile_trace_failure end

  local input_start_failure = emit(100, "low", "input:start")
  if input_start_failure ~= nil then return input_start_failure end
  local input = load_input(options, cwd)
  if input == nil then return phase_failure("input:error", "input load failed") end
  local input_trace_failure = emit(300, "high", "input bytes=" .. #input) or
    emit(100, "low", "input:ok") or emit(100, "low", "invoke:start")
  if input_trace_failure ~= nil then return input_trace_failure end

  local invoke_ok, result = pcall(execute_request, prepared, options, input)
  if not invoke_ok then return phase_failure("invoke:error", "parser invocation failed") end
  local json_ok, encoded = pcall(json.encode, result.value)
  if not json_ok then return phase_failure("invoke:error", "parser invocation failed") end
  local invoke_trace_failure = emit(100, "low", "invoke:ok") or
    emit(400, "full", "result json_bytes=" .. #encoded)
  if invoke_trace_failure ~= nil then return invoke_trace_failure end
  return command_result(trace_stdout(trace) .. encoded .. "\n", "", 0)
end

return M
