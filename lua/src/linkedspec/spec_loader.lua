local filesystem = require("linkedspec_filesystem_native")
local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local spec_validator = require("linkedspec.spec_validator")
local trace = require("linkedspec.trace")
local trace_support = require("linkedspec.trace_support")

local M = {}

local REQUEST_MT = { __spec_loader_type = "SpecRequest" }
local OPTIONS_MT = { __spec_loader_type = "SpecLoadOptions" }
local RESOLVED_MT = { __spec_loader_type = "ResolvedSpec" }
local LOADED_MT = { __spec_loader_type = "LoadedSpec" }
local LOADED_COMPILED_METHODS = {}
local LOADED_COMPILED_MT = {
  __spec_loader_type = "LoadedCompiledSpec",
  __index = LOADED_COMPILED_METHODS,
}
local ERROR_MT = {
  __spec_loader_type = "SpecPipelineError",
  __tostring = function(value) return value.summary end,
}

local HOST_SEPARATOR = package.config:sub(1, 1)

local function fail(message)
  error("SpecLoaderError: " .. message, 0)
end

function M.node_type(value)
  local metatable = type(value) == "table" and getmetatable(value) or nil
  return metatable and metatable.__spec_loader_type or nil
end

function M.is_spec_pipeline_error(value)
  return getmetatable(value) == ERROR_MT
end

local function require_string(value, label, allow_empty)
  if type(value) ~= "string" then fail(label .. " must be a string") end
  if not allow_empty and value == "" then fail(label .. " must not be empty") end
  return value
end

local function copy_string_list(values, label)
  if values == nil then return {} end
  if type(values) ~= "table" then fail(label .. " must be a table") end
  local result = {}
  for index, value in ipairs(values) do
    result[index] = require_string(value, label .. "[" .. index .. "]", false)
  end
  for key in pairs(values) do
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 or key > #result then
      fail(label .. " must be a dense one-based list")
    end
  end
  return result
end

local function request(kind, requested)
  return setmetatable({
    kind = kind,
    requested = require_string(requested, "requested spec", true),
  }, REQUEST_MT)
end

function M.named_spec_request(name)
  return request("name", name)
end

function M.path_spec_request(path)
  return request("path", path)
end

function M.spec_load_options(value)
  if type(value) ~= "table" then fail("spec load options must be a table") end
  local cwd = require_string(value.cwd, "spec load cwd", false)
  if cwd:find("\0", 1, true) then fail("spec load cwd must not contain NUL bytes") end
  local search_roots = copy_string_list(value.search_roots, "spec search roots")
  for index, root in ipairs(search_roots) do
    if root:find("\0", 1, true) then
      fail("spec search roots[" .. index .. "] must not contain NUL bytes")
    end
  end
  if value.trace ~= nil and not trace.is_trace_emitter(value.trace) then
    fail("trace must be a LinkedSpecTraceEmitter")
  end
  return setmetatable({ cwd = cwd, search_roots = search_roots, trace = value.trace }, OPTIONS_MT)
end

local function require_request(value)
  if getmetatable(value) ~= REQUEST_MT then fail("expected SpecRequest") end
  return value
end

local function require_options(value)
  if getmetatable(value) ~= OPTIONS_MT then fail("expected SpecLoadOptions") end
  return value
end

local function pipeline_error(request_value, stage, code, summary, resolved_path, detail)
  return setmetatable({
    type = "spec_pipeline_error",
    stage = stage,
    code = code,
    summary = summary,
    request_kind = request_value.kind,
    requested = request_value.requested,
    resolved_path = resolved_path,
    detail = detail,
  }, ERROR_MT)
end

local function raise_pipeline_error(request_value, stage, code, summary, resolved_path, detail)
  error(pipeline_error(request_value, stage, code, summary, resolved_path, detail), 0)
end

local function decode_codepoints(value)
  local result = {}
  local index = 1
  while index <= #value do
    local first = value:byte(index)
    local codepoint
    if first <= 0x7F then
      codepoint = first
      index = index + 1
    elseif first <= 0xDF then
      codepoint = (first - 0xC0) * 0x40 + value:byte(index + 1) - 0x80
      index = index + 2
    elseif first <= 0xEF then
      codepoint = (first - 0xE0) * 0x1000 +
        (value:byte(index + 1) - 0x80) * 0x40 + value:byte(index + 2) - 0x80
      index = index + 3
    else
      codepoint = (first - 0xF0) * 0x40000 +
        (value:byte(index + 1) - 0x80) * 0x1000 +
        (value:byte(index + 2) - 0x80) * 0x40 + value:byte(index + 3) - 0x80
      index = index + 4
    end
    result[#result + 1] = codepoint
  end
  return result
end

local function is_unicode_control(codepoint)
  return codepoint <= 0x1F or (codepoint >= 0x7F and codepoint <= 0x9F)
end

local function is_unicode_whitespace(codepoint)
  return (codepoint >= 0x09 and codepoint <= 0x0D) or
    codepoint == 0x20 or codepoint == 0x85 or codepoint == 0xA0 or codepoint == 0x1680 or
    (codepoint >= 0x2000 and codepoint <= 0x200A) or
    codepoint == 0x2028 or codepoint == 0x2029 or codepoint == 0x202F or
    codepoint == 0x205F or codepoint == 0x3000
end

local function invalid_name(value)
  local valid_utf8 = json.validate_utf8(value)
  if not valid_utf8 or value == "" then return true end
  local codepoints = decode_codepoints(value)
  if is_unicode_whitespace(codepoints[1]) or is_unicode_whitespace(codepoints[#codepoints]) then return true end
  local all_whitespace = true
  for _, codepoint in ipairs(codepoints) do
    if is_unicode_control(codepoint) then return true end
    if not is_unicode_whitespace(codepoint) then all_whitespace = false end
  end
  if all_whitespace or value:sub(1, 1) == "/" or value:find("\\", 1, true) then return true end
  if value:match("^[A-Za-z]:/") then return true end
  for component in (value .. "/"):gmatch("(.-)/") do
    if component == "" or component == "." or component == ".." then return true end
  end
  return false
end

function M.validate_spec_request(value)
  local request_value = require_request(value)
  if request_value.kind == "name" then
    if invalid_name(request_value.requested) then
      raise_pipeline_error(
        request_value,
        "validate_spec_name",
        "invalid_spec_name",
        "Invalid spec name"
      )
    end
  elseif request_value.kind == "path" then
    local valid_utf8 = json.validate_utf8(request_value.requested)
    if request_value.requested == "" or request_value.requested:find("\0", 1, true) or not valid_utf8 then
      raise_pipeline_error(
        request_value,
        "validate_spec_path",
        "invalid_spec_path",
        "Invalid spec path"
      )
    end
  else
    fail("unsupported spec request kind")
  end
  return true
end

local function portable_to_host(value)
  if HOST_SEPARATOR == "/" then return value end
  return (value:gsub("/", function() return HOST_SEPARATOR end))
end

local function join_path(parent, child)
  if parent:sub(-1) == "/" or parent:sub(-1) == "\\" then return parent .. child end
  return parent .. HOST_SEPARATOR .. child
end

local function is_absolute_path(value)
  if HOST_SEPARATOR == "/" then return value:sub(1, 1) == "/" end
  return value:match("^[A-Za-z]:[\\/]") ~= nil or value:sub(1, 2) == "\\\\"
end

local function candidates(request_value, options)
  local raw = {}
  if request_value.kind == "path" then
    raw[1] = {
      path = is_absolute_path(request_value.requested) and request_value.requested or
        join_path(options.cwd, request_value.requested),
      origin = "path_exact",
    }
  else
    local requested_path = portable_to_host(request_value.requested)
    local filename = request_value.requested:sub(-5) == ".spec" and request_value.requested or
      (request_value.requested .. ".spec")
    local host_filename = portable_to_host(filename)
    raw[#raw + 1] = { path = join_path(options.cwd, requested_path), origin = "cwd_exact" }
    raw[#raw + 1] = { path = join_path(options.cwd, host_filename), origin = "cwd_spec_suffix" }
    for index, root in ipairs(options.search_roots) do
      raw[#raw + 1] = {
        path = join_path(root, host_filename),
        origin = "search_root:" .. (index - 1),
      }
    end
  end
  local seen = {}
  local result = {}
  for _, candidate in ipairs(raw) do
    if not seen[candidate.path] then
      seen[candidate.path] = true
      result[#result + 1] = candidate
    end
  end
  return result
end

local function resolve_spec(request_input, options_input, emitter)
  local request_value = require_request(request_input)
  local options = require_options(options_input)
  M.validate_spec_request(request_value)
  local first_non_regular
  for _, candidate in ipairs(candidates(request_value, options)) do
    local inspected = filesystem.inspect(candidate.path)
    if type(inspected) ~= "table" or type(inspected.status) ~= "string" then
      raise_pipeline_error(
        request_value,
        "resolve_spec_path",
        "spec_read_failed",
        "Unable to inspect spec path",
        candidate.path,
        "native filesystem inspector returned an invalid result"
      )
    elseif inspected.status == "file" then
      trace_support.decision(
        emitter,
        "lua_io:resolve_spec:candidate",
        true,
        "origin=" .. candidate.origin .. " path=" .. candidate.path .. " status=file"
      )
      return setmetatable({
        request = request(request_value.kind, request_value.requested),
        path = candidate.path,
        origin = candidate.origin,
      }, RESOLVED_MT)
    elseif inspected.status == "non_regular" then
      trace_support.decision(
        emitter,
        "lua_io:resolve_spec:candidate",
        false,
        "origin=" .. candidate.origin .. " path=" .. candidate.path .. " status=non_regular"
      )
      first_non_regular = first_non_regular or candidate.path
    elseif inspected.status == "error" then
      raise_pipeline_error(
        request_value,
        "resolve_spec_path",
        "spec_read_failed",
        "Unable to inspect spec path",
        candidate.path,
        inspected.detail
      )
    elseif inspected.status ~= "missing" then
      raise_pipeline_error(
        request_value,
        "resolve_spec_path",
        "spec_read_failed",
        "Unable to inspect spec path",
        candidate.path,
        "native filesystem inspector returned unsupported status '" .. inspected.status .. "'"
      )
    else
      trace_support.decision(
        emitter,
        "lua_io:resolve_spec:candidate",
        false,
        "origin=" .. candidate.origin .. " path=" .. candidate.path .. " status=missing"
      )
    end
  end
  if first_non_regular then
    raise_pipeline_error(
      request_value,
      "resolve_spec_path",
      "spec_path_not_file",
      "Spec path is not a file",
      first_non_regular
    )
  end
  raise_pipeline_error(
    request_value,
    "resolve_spec_path",
    "spec_path_not_found",
    "Spec path not found"
  )
end

function M.resolve_spec(request_input, options_input)
  local request_value = require_request(request_input)
  local options = require_options(options_input)
  return trace_support.run(
    options.trace,
    "lua_io:resolve_spec",
    "request_kind=" .. request_value.kind .. " requested=" .. request_value.requested,
    function() return resolve_spec(request_value, options, options.trace) end,
    function(resolved) return "ok path=" .. resolved.path end
  )
end

local function load_spec(request_input, options_input, emitter)
  local request_value = require_request(request_input)
  local resolved = M.resolve_spec(request_value, options_input)
  local handle, open_error = io.open(resolved.path, "rb")
  if not handle then
    raise_pipeline_error(
      request_value,
      "load_spec_content",
      "spec_read_failed",
      "Unable to read spec file",
      resolved.path,
      open_error
    )
  end
  local bytes, read_error = handle:read("*a")
  local closed, close_error = handle:close()
  if bytes == nil or not closed then
    raise_pipeline_error(
      request_value,
      "load_spec_content",
      "spec_read_failed",
      "Unable to read spec file",
      resolved.path,
      read_error or close_error
    )
  end
  local valid_utf8, invalid_position = json.validate_utf8(bytes)
  if not valid_utf8 then
    raise_pipeline_error(
      request_value,
      "decode_spec_content",
      "invalid_utf8",
      "Spec file is not valid UTF-8",
      resolved.path,
      "invalid UTF-8 at byte " .. (invalid_position - 1)
    )
  end
  trace_support.decision(
    emitter,
    "lua_io:load_spec:content",
    true,
    "origin=" .. resolved.origin .. " path=" .. resolved.path .. " source_bytes=" .. #bytes
  )
  return setmetatable({ resolved = resolved, source_text = bytes }, LOADED_MT)
end

function M.load_spec(request_input, options_input)
  local request_value = require_request(request_input)
  local options = require_options(options_input)
  return trace_support.run(
    options.trace,
    "lua_io:load_spec",
    "request_kind=" .. request_value.kind .. " requested=" .. request_value.requested,
    function() return load_spec(request_value, options, options.trace) end,
    function(loaded) return "ok path=" .. loaded.resolved.path end
  )
end

local function run_source_stage(request_value, resolved_path, stage, code, summary, operation)
  local ok, result = pcall(operation)
  if not ok then
    raise_pipeline_error(request_value, stage, code, summary, resolved_path, tostring(result))
  end
  return result
end

local function load_and_compile_spec(request_input, options_input, emitter)
  local request_value = require_request(request_input)
  local loaded = M.load_spec(request_value, options_input)
  local resolved_path = loaded.resolved.path
  trace_support.decision(
    emitter,
    "lua_io:load_and_compile_spec:loaded",
    true,
    "origin=" .. loaded.resolved.origin .. " path=" .. resolved_path ..
      " source_bytes=" .. #loaded.source_text
  )
  local parsed = run_source_stage(
    request_value,
    resolved_path,
    "parse_spec",
    "spec_parse_failed",
    "Unable to parse spec",
    function()
      -- Loaded only at call time: the function parser itself uses this loader
      -- for its one module-relative bundled grammar, so eager loading would
      -- create a module cycle without changing the dependency graph.
      local function_parser = require("linkedspec.user_function_definition_parser")
      return function_parser.parse_spec_with_staged_user_function_definitions(
        loaded.source_text,
        nil,
        { trace = emitter }
      )
    end
  )
  run_source_stage(
    request_value,
    resolved_path,
    "validate_spec",
    "spec_validation_failed",
    "Spec validation failed",
    function() return spec_validator.validate_spec(parsed, { trace = emitter }) end
  )
  local compiled = run_source_stage(
    request_value,
    resolved_path,
    "compile_spec",
    "spec_compile_failed",
    "Spec compilation failed",
    function() return compiled_spec.compile_spec(parsed, { validate_source = false, trace = emitter }) end
  )
  return setmetatable({ loaded = loaded, compiled = compiled }, LOADED_COMPILED_MT)
end

function M.load_and_compile_spec(request_input, options_input)
  local request_value = require_request(request_input)
  local options = require_options(options_input)
  return trace_support.run(
    options.trace,
    "lua_io:load_and_compile_spec",
    "request_kind=" .. request_value.kind .. " requested=" .. request_value.requested,
    function() return load_and_compile_spec(request_value, options, options.trace) end,
    function(result) return "ok path=" .. result.loaded.resolved.path end
  )
end

local function require_loaded_compiled(value)
  if getmetatable(value) ~= LOADED_COMPILED_MT then fail("expected LoadedCompiledSpec") end
  return value
end

local function create_engine(value, options)
  value = require_loaded_compiled(value)
  options = options or {}
  if type(options) ~= "table" then fail("loaded spec engine options must be a table") end
  if options.spec_name ~= nil or options.spec_path ~= nil then
    fail("loaded spec engine identity is derived from the resolved request")
  end
  local engine_options = {}
  for key, item in pairs(options) do engine_options[key] = item end
  local resolved = value.loaded.resolved
  if resolved.request.kind == "name" then
    engine_options.spec_name = resolved.request.requested
  end
  engine_options.spec_path = resolved.path
  local interpreter = require("linkedspec.interpreter")
  return interpreter.runtime_engine(value.compiled, engine_options)
end

function M.create_engine(value, options)
  value = require_loaded_compiled(value)
  options = options or {}
  if type(options) ~= "table" then fail("loaded spec engine options must be a table") end
  if options.trace ~= nil and not trace.is_trace_emitter(options.trace) then
    fail("trace must be a LinkedSpecTraceEmitter")
  end
  return trace_support.run(
    options.trace,
    "lua_io:create_engine",
    "path=" .. value.loaded.resolved.path,
    function() return create_engine(value, options) end,
    "ok"
  )
end

function LOADED_COMPILED_METHODS:create_engine(options)
  return M.create_engine(self, options)
end

function M.spec_pipeline_error_to_json(value)
  if getmetatable(value) ~= ERROR_MT then fail("expected SpecPipelineError") end
  return json.harray({
    type = value.type,
    stage = value.stage,
    code = value.code,
    summary = value.summary,
    request_kind = value.request_kind,
    requested = value.requested,
    resolved_path = value.resolved_path,
    detail = value.detail,
  })
end

return M
