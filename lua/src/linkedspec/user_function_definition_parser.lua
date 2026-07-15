local compiled_spec = require("linkedspec.compiled_spec")
local function_shell = require("linkedspec.user_function_definition_shell")
local interpreter = require("linkedspec.interpreter")
local json = require("linkedspec.json")
local spec_loader = require("linkedspec.spec_loader")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")
local staged_parser_registry = require("linkedspec.staged_parser_registry")
local trace = require("linkedspec.trace")
local trace_support = require("linkedspec.trace_support")

local M = {}

M.USER_FUNCTION_DEFINITION_SPEC_ID = "user_function_definition.spec"
M.USER_FUNCTION_DEFINITION_TOP_RULE = "user_function_definitions"

local PARSER_MT = { __user_function_definition_parser_type = "UserFunctionDefinitionAstParser" }
local ERROR_MT = {
  __user_function_definition_parser_type = "UserFunctionDefinitionParserError",
  __tostring = function(value)
    return "UserFunctionDefinitionParserException: " .. value.message
  end,
}

local HOST_SEPARATOR = package.config:sub(1, 1)
local default_parser
local default_parser_build_count = 0

local function fail(stage, message, cause)
  error(setmetatable({
    stage = stage,
    message = message,
    cause = cause and tostring(cause) or nil,
  }, ERROR_MT), 0)
end

function M.node_type(value)
  local metatable = type(value) == "table" and getmetatable(value) or nil
  return metatable and metatable.__user_function_definition_parser_type or nil
end

function M.is_error(value)
  return getmetatable(value) == ERROR_MT
end

local function require_string(value, label)
  if type(value) ~= "string" then fail("api", label .. " must be a string") end
  return value
end

local function require_parser(value)
  if getmetatable(value) ~= PARSER_MT then
    fail("api", "expected UserFunctionDefinitionAstParser")
  end
  return value
end

local function trace_from_options(options, label)
  options = options or {}
  if type(options) ~= "table" then fail("api", label .. " options must be a table") end
  if options.trace ~= nil and not trace.is_trace_emitter(options.trace) then
    fail("api", "trace must be a LinkedSpecTraceEmitter")
  end
  return options.trace
end

local function run_stage(stage, message, operation)
  local ok, result = pcall(operation)
  if not ok then fail(stage, message .. ": " .. tostring(result), result) end
  return result
end

function M.parser_from_spec_source(source, options)
  source = require_string(source, "user-function definition parser spec source")
  options = options or {}
  if type(options) ~= "table" then fail("api", "parser options must be a table") end
  local emitter = trace_from_options(options, "parser")
  return trace_support.run(
    emitter,
    "lua_frontend:function_parser_spec",
    "source_bytes=" .. #source,
    function()
      local parsed = run_stage(
        "parse_parser_spec",
        "failed to parse user_function_definition.spec",
        function() return spec_parser.parse_spec(source, { trace = emitter }) end
      )
      run_stage(
        "validate_parser_spec",
        "failed to validate user_function_definition.spec",
        function() return spec_validator.validate_spec(parsed, { trace = emitter }) end
      )
      local compiled = run_stage(
        "compile_parser_spec",
        "failed to compile user_function_definition.spec",
        function() return compiled_spec.compile_spec(parsed, { trace = emitter }) end
      )
      return setmetatable({
        compiled_spec = compiled,
        spec_name = options.spec_name or M.USER_FUNCTION_DEFINITION_SPEC_ID,
        spec_path = options.spec_path,
        spec_origin = options.spec_origin,
      }, PARSER_MT)
    end,
    "ok"
  )
end

local function module_directory()
  if type(debug) ~= "table" or type(debug.getinfo) ~= "function" then
    fail("resolve_parser_spec", "Lua debug.getinfo is required for module-relative bundled spec resolution")
  end
  local info = debug.getinfo(1, "S")
  local source = info and info.source or nil
  if type(source) ~= "string" or source:sub(1, 1) ~= "@" then
    fail("resolve_parser_spec", "cannot resolve bundled spec from a non-file Lua module source")
  end
  local path = source:sub(2)
  local directory = path:match("^(.*)[/\\][^/\\]+$")
  if directory == nil or directory == "" then
    fail("resolve_parser_spec", "cannot determine user-function parser module directory")
  end
  return directory
end

local function bundled_spec_relative_path()
  return table.concat({ "..", "..", "..", "specs", M.USER_FUNCTION_DEFINITION_SPEC_ID }, HOST_SEPARATOR)
end

local function build_default_parser(emitter)
  local loaded = run_stage(
    "load_parser_spec",
    "failed to load bundled user_function_definition.spec",
    function()
      return spec_loader.load_spec(
        spec_loader.path_spec_request(bundled_spec_relative_path()),
        spec_loader.spec_load_options({ cwd = module_directory(), search_roots = {}, trace = emitter })
      )
    end
  )
  local parser = M.parser_from_spec_source(loaded.source_text, {
    spec_name = M.USER_FUNCTION_DEFINITION_SPEC_ID,
    spec_path = loaded.resolved.path,
    spec_origin = loaded.resolved.origin,
    trace = emitter,
  })
  default_parser_build_count = default_parser_build_count + 1
  return parser
end

local function default_user_function_definition_parser(emitter)
  trace_support.decision(
    emitter,
    "lua_frontend:function_parser_spec:cache",
    default_parser ~= nil,
    "cache_hit=" .. (default_parser ~= nil and "1" or "0")
  )
  if default_parser == nil then default_parser = build_default_parser(emitter) end
  return default_parser
end

function M.default_parser_metadata(options)
  local parser = default_user_function_definition_parser(trace_from_options(options, "parser metadata"))
  return json.harray({
    type = "user_function_definition_ast_parser",
    spec_name = parser.spec_name,
    spec_path = parser.spec_path,
    spec_origin = parser.spec_origin,
    top_rule = M.USER_FUNCTION_DEFINITION_TOP_RULE,
    build_count = default_parser_build_count,
  })
end

function M.parse_user_function_definition_asts(source, parser, options)
  source = require_string(source, "user-function source")
  local emitter = trace_from_options(options, "function definition parse")
  parser = require_parser(parser or default_user_function_definition_parser(emitter))
  return trace_support.run(
    emitter,
    "lua_frontend:function_parser_execute",
    "source_bytes=" .. #source,
    function()
      local result = run_stage(
        "execute_parser_spec",
        "user_function_definition.spec execution failed",
        function()
          return interpreter.runtime_parse(
            interpreter.runtime_engine(parser.compiled_spec, {
              spec_name = parser.spec_name,
              spec_path = parser.spec_path,
              trace = emitter,
            }),
            source,
            { top_rule = M.USER_FUNCTION_DEFINITION_TOP_RULE, trace = emitter }
          )
        end
      )
      local nodes = run_stage(
        "normalize_output",
        "user_function_definition.spec returned unsupported output",
        function() return function_shell.definition_nodes_from_output(result.value) end
      )
      trace_support.decision(
        emitter,
        "lua_frontend:function_parser_execute:definitions",
        result.matched,
        "definition_count=" .. #nodes
      )
      return nodes
    end,
    function(nodes) return "ok definition_count=" .. #nodes end
  )
end

function M.parse_spec_with_staged_user_function_definitions(source, parser, options)
  local emitter = trace_from_options(options, "staged function definition parse")
  return trace_support.run(
    emitter,
    "lua_frontend:parse_spec_with_functions",
    "source_bytes=" .. (type(source) == "string" and #source or 0),
    function()
      local nodes = M.parse_user_function_definition_asts(source, parser, { trace = emitter })
      return staged_parser_registry.parse_spec_with_staged_user_function_definition_asts(
        source,
        nodes,
        { trace = emitter }
      )
    end,
    function(spec)
      return "ok functions=" .. #spec.functions .. " rules=" .. #spec.rules
    end
  )
end

return M
