local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")

local M = {}

M.GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v1"
M.GENERATED_SOURCE_FORMAT = 1

M.EMIT_SOURCE_STAGE = "emit_source"
M.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE = "compile_or_load_generated_source"
M.VALIDATE_GENERATED_PLAN_STAGE = "validate_generated_plan"
M.EXECUTE_GENERATED_STAGE = "execute_generated"

M.GENERATED_SOURCE_EMIT_FAILED_CODE = "generated_source_emit_failed"
M.GENERATED_SOURCE_COMPILE_FAILED_CODE = "generated_source_compile_failed"
M.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE = "generated_plan_row_count_mismatch"
M.GENERATED_PLAN_LABEL_MISMATCH_CODE = "generated_plan_label_mismatch"
M.GENERATED_PLAN_FAMILY_MISMATCH_CODE = "generated_plan_family_mismatch"
M.GENERATED_PLAN_UNKNOWN_FAMILY_CODE = "generated_plan_unknown_family"
M.GENERATED_EXECUTION_FAILED_CODE = "generated_execution_failed"

local STAGES = {
  [M.EMIT_SOURCE_STAGE] = true,
  [M.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE] = true,
  [M.VALIDATE_GENERATED_PLAN_STAGE] = true,
  [M.EXECUTE_GENERATED_STAGE] = true,
}

local CODES = {
  [M.GENERATED_SOURCE_EMIT_FAILED_CODE] = true,
  [M.GENERATED_SOURCE_COMPILE_FAILED_CODE] = true,
  [M.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE] = true,
  [M.GENERATED_PLAN_LABEL_MISMATCH_CODE] = true,
  [M.GENERATED_PLAN_FAMILY_MISMATCH_CODE] = true,
  [M.GENERATED_PLAN_UNKNOWN_FAMILY_CODE] = true,
  [M.GENERATED_EXECUTION_FAILED_CODE] = true,
}

local ERROR_MT = {
  __generated_source_type = "GeneratedSourceError",
  __tostring = function(value)
    if value.detail == nil then return value.summary end
    return value.summary .. ": " .. value.detail
  end,
}

local METADATA_MT = { __generated_source_type = "GeneratedSourceMetadata" }

local function fail(message)
  error("GeneratedSourceError: " .. message, 0)
end

local function require_options(value, context)
  if type(value) ~= "table" then fail(context .. " options must be a table") end
  return value
end

local function require_string(value, label, allow_empty)
  if type(value) ~= "string" then fail(label .. " must be a string") end
  if not allow_empty and value == "" then fail(label .. " must not be empty") end
  return value
end

local function optional_string(value, label)
  if value == nil then return nil end
  return require_string(value, label, true)
end

local function raise(value)
  error(value, 0)
end

function M.node_type(value)
  local metatable = type(value) == "table" and getmetatable(value) or nil
  return metatable and metatable.__generated_source_type or nil
end

function M.is_generated_source_error(value)
  return getmetatable(value) == ERROR_MT
end

function M.is_generated_source_metadata(value)
  return getmetatable(value) == METADATA_MT
end

function M.generated_source_stage_name(stage)
  if type(stage) ~= "string" or not STAGES[stage] then
    fail("unsupported generated-source stage")
  end
  return stage
end

function M.generated_source_code_name(code)
  if type(code) ~= "string" or not CODES[code] then
    fail("unsupported generated-source code")
  end
  return code
end

function M.generated_source_error(options)
  options = require_options(options, "generated source error")
  return setmetatable({
    type = "generated_source_error",
    stage = M.generated_source_stage_name(options.stage),
    code = M.generated_source_code_name(options.code),
    summary = require_string(options.summary, "generated source error summary", false),
    source_identity = require_string(
      options.source_identity,
      "generated source error source_identity",
      true
    ),
    rule_label = optional_string(options.rule_label, "generated source error rule_label"),
    handler_family = optional_string(options.handler_family, "generated source error handler_family"),
    detail = optional_string(options.detail, "generated source error detail"),
  }, ERROR_MT)
end

function M.generated_source_error_to_json(value)
  if not M.is_generated_source_error(value) then
    fail("generated_source_error_to_json expects GeneratedSourceError")
  end
  local result = json.harray({
    type = value.type,
    stage = value.stage,
    code = value.code,
    summary = value.summary,
    source_identity = value.source_identity,
  })
  if value.rule_label ~= nil then result.rule_label = value.rule_label end
  if value.handler_family ~= nil then result.handler_family = value.handler_family end
  if value.detail ~= nil then result.detail = value.detail end
  return result
end

function M.generated_source_compile_failed(source_identity, detail)
  return M.generated_source_error({
    stage = M.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE,
    code = M.GENERATED_SOURCE_COMPILE_FAILED_CODE,
    summary = "Generated Lua source failed to compile or load",
    source_identity = require_string(source_identity, "source_identity", true),
    detail = tostring(detail),
  })
end

function M.generated_source_execution_failed(source_identity, detail, options)
  options = options or {}
  require_options(options, "generated execution failure")
  return M.generated_source_error({
    stage = M.EXECUTE_GENERATED_STAGE,
    code = M.GENERATED_EXECUTION_FAILED_CODE,
    summary = "Generated Lua parser execution failed",
    source_identity = require_string(source_identity, "source_identity", true),
    rule_label = options.rule_label,
    handler_family = options.handler_family,
    detail = tostring(detail),
  })
end

function M.generated_source_metadata(source_identity)
  return setmetatable({
    contract_id = M.GENERATED_SOURCE_CONTRACT,
    format_version = M.GENERATED_SOURCE_FORMAT,
    source_identity = require_string(source_identity, "source_identity", false),
  }, METADATA_MT)
end

function M.generated_source_metadata_to_json(value)
  if not M.is_generated_source_metadata(value) then
    fail("generated_source_metadata_to_json expects GeneratedSourceMetadata")
  end
  return json.harray({
    contract_id = value.contract_id,
    format_version = value.format_version,
    source_identity = value.source_identity,
  })
end

local function hex_encode(value)
  local chunks = {}
  for index = 1, #value do
    chunks[index] = string.format("%02x", value:byte(index))
  end
  return table.concat(chunks)
end

local function effective_spec(compiled)
  local functions = {}
  for index, entry in ipairs(compiled.function_registry.entries) do
    functions[index] = entry.definition
  end
  local rules = {}
  for index, label in ipairs(compiled.compiled_rule_order) do
    local rule = compiled.rules_by_label[label]
    rules[index] = spec_ast.rule({ header = rule.header, body = rule.body_elements })
  end
  return spec_ast.spec_file({ functions = functions, rules = rules })
end

local function emit_failure(source_identity, summary, detail)
  raise(M.generated_source_error({
    stage = M.EMIT_SOURCE_STAGE,
    code = M.GENERATED_SOURCE_EMIT_FAILED_CODE,
    summary = summary,
    source_identity = source_identity,
    detail = detail,
  }))
end

local function generated_module_source(identity_hex, spec_json_hex)
  return table.concat({
    "-- Generated LinkedSpec parser module.",
    "-- Contract id: linkedspec-generated-source-v1.",
    "-- Source format: linkedspec_lua source_emitter v1.",
    "-- Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.",
    "",
    'local linkedspec = require("linkedspec")',
    "local M = {}",
    "",
    'M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v1"',
    "M.LINKEDSPEC_GENERATED_SOURCE_FORMAT = 1",
    'local _SOURCE_IDENTITY_HEX = "' .. identity_hex .. '"',
    'local _EFFECTIVE_SPEC_JSON_HEX = "' .. spec_json_hex .. '"',
    "",
    "local function decode_hex(value)",
    '  if type(value) ~= "string" or #value % 2 ~= 0 or value:find("[^0-9a-f]") then',
    '    error("generated-source hex payload is malformed", 0)',
    "  end",
    "  local chunks = {}",
    "  for index = 1, #value, 2 do",
    "    chunks[#chunks + 1] = string.char(assert(tonumber(value:sub(index, index + 1), 16)))",
    "  end",
    "  return table.concat(chunks)",
    "end",
    "",
    "M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY = decode_hex(_SOURCE_IDENTITY_HEX)",
    "",
    "function M.metadata()",
    "  return linkedspec.generated_source_metadata(M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY)",
    "end",
    "",
    "local function load_compiled_spec()",
    "  local ok, result = pcall(function()",
    "    local payload = decode_hex(_EFFECTIVE_SPEC_JSON_HEX)",
    "    local decoded = linkedspec.json.decode(payload)",
    '    return linkedspec.compile_spec(linkedspec.spec_ast.from_json("SpecFile", decoded))',
    "  end)",
    "  if ok then return result end",
    "  if linkedspec.is_generated_source_error(result) then error(result, 0) end",
    "  error(linkedspec.generated_source_compile_failed(",
    "    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,",
    "    result",
    "  ), 0)",
    "end",
    "",
    "local _COMPILED_SPEC = load_compiled_spec()",
    "local _RUNTIME_ENGINE = linkedspec.runtime_engine(_COMPILED_SPEC)",
    "",
    "local function execute_runtime(operation)",
    "  local ok, result = pcall(operation)",
    "  if ok then return result.value end",
    "  if linkedspec.is_generated_source_error(result) then error(result, 0) end",
    "  local rule_label = nil",
    "  if linkedspec.is_runtime_interpreter_error(result) and result.diagnostic ~= nil then",
    "    rule_label = result.diagnostic.rule_label",
    "  end",
    "  error(linkedspec.generated_source_execution_failed(",
    "    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,",
    "    result,",
    "    { rule_label = rule_label }",
    "  ), 0)",
    "end",
    "",
    "function M.execute(input, options)",
    "  return execute_runtime(function()",
    "    return linkedspec.runtime_parse(_RUNTIME_ENGINE, input, options)",
    "  end)",
    "end",
    "",
    "function M.execute_with_trace(input, trace_config, options)",
    "  return execute_runtime(function()",
    "    return linkedspec.runtime_parse_with_trace(_RUNTIME_ENGINE, input, trace_config, options)",
    "  end)",
    "end",
    "",
    "return M",
    "",
  }, "\n")
end

function M.emit_lua_source(compiled)
  return M.emit_lua_source_v1(compiled, "<inline>")
end

function M.emit_lua_source_v1(compiled, source_identity)
  local identity = type(source_identity) == "string" and source_identity or ""
  if type(source_identity) ~= "string" then
    emit_failure(identity, "Generated Lua source identity must be Unicode text", "source_identity must be a string")
  elseif source_identity == "" then
    emit_failure(identity, "Generated Lua source identity must not be empty", "source_identity is required")
  elseif not json.validate_utf8(source_identity) then
    emit_failure(
      identity,
      "Generated Lua source identity must be valid Unicode text",
      "source_identity must encode as strict UTF-8"
    )
  elseif compiled_spec.node_type(compiled) ~= "CompiledSpec" then
    emit_failure(
      identity,
      "Failed to emit generated Lua source from invalid compiled spec",
      "compiled must be a CompiledSpec"
    )
  end

  local ok, result = pcall(function()
    compiled_spec.validate_no_removed_aggregate_selectors(compiled)
    local spec_json = json.encode(spec_ast.to_json(effective_spec(compiled)))
    return generated_module_source(hex_encode(identity), hex_encode(spec_json))
  end)
  if ok then return result end
  if M.is_generated_source_error(result) then raise(result) end
  emit_failure(
    identity,
    "Failed to serialize compiled spec for generated Lua source",
    tostring(result)
  )
end

return M
