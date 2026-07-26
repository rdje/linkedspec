-- Package-internal compiled-or-failed authority for the opaque semantic index.
--
-- Construction deliberately reuses the existing staged language pipeline. It
-- never loads caller source by path, emits or executes generated source, runs
-- target actions/lifecycle code, or creates trace/diagnostic/observation sinks.

local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local source_emitter = require("linkedspec.source_emitter")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")
local staged_parser_registry = require("linkedspec.staged_parser_registry")
local function_shell = require("linkedspec.user_function_definition_shell")
local user_function_definition_parser = require("linkedspec.user_function_definition_parser")

local M = {}

local function copy_json_value(value, active)
  local value_type = type(value)
  if value == nil or value_type == "boolean" or value_type == "number" or value_type == "string" then
    return value
  end
  if value_type ~= "table" then
    error("semantic compilation diagnostic contains a non-portable field", 0)
  end
  active = active or {}
  if active[value] then error("semantic compilation diagnostic contains a cycle", 0) end
  active[value] = true
  local result = json.kind(value) == "array" and json.array() or json.harray()
  for key, item in next, value do result[key] = copy_json_value(item, active) end
  active[value] = nil
  return result
end

local function copied_fields(fields)
  local result = json.harray()
  for name, value in next, fields or {} do
    if type(name) ~= "string" then
      error("semantic compilation diagnostic field names must be strings", 0)
    end
    result[name] = copy_json_value(value)
  end
  return result
end

local function error_message(value)
  if type(value) == "table" and type(value.message) == "string" then return value.message end
  return tostring(value)
end

local function fallback_diagnostic(value, code, stage)
  local fields = json.harray()
  if spec_parser.is_parse_error(value) then fields.line = value.line end
  return {
    code = code,
    stage = stage,
    message = error_message(value),
    fields = fields,
  }
end

local function language_diagnostic(value, fallback_code, fallback_stage)
  if spec_validator.is_validation_error(value) and value.code ~= nil and value.stage ~= nil then
    return {
      code = value.code,
      stage = value.stage,
      message = value.message,
      fields = copied_fields(value.fields),
    }
  end
  if compiled_spec.is_entry_rule_selection_error(value) then
    local fields = json.harray()
    if value.entry_rule ~= nil then fields.entry_rule = value.entry_rule end
    return {
      code = value.code,
      stage = value.stage,
      message = value.message,
      fields = fields,
    }
  end
  return fallback_diagnostic(value, fallback_code, fallback_stage)
end

local function recognized_parse_error(value)
  return spec_parser.is_parse_error(value) or
    user_function_definition_parser.is_error(value) or
    function_shell.is_projection_error(value) or
    staged_parser_registry.is_staged_parser_registry_error(value)
end

local function recognized_validation_error(value)
  return spec_validator.is_validation_error(value)
end

local function recognized_compile_error(value)
  return compiled_spec.is_compiled_spec_error(value)
end

local function recognized_entry_error(value)
  return compiled_spec.is_entry_rule_selection_error(value)
end

local function recognized_plan_error(value)
  return source_emitter.is_generated_source_error(value)
end

local function rethrow_unrecognized(value, recognized)
  if recognized(value) then return end
  error(value, 0)
end

local function failed_outcome(options)
  return {
    parsed = options.parsed,
    validated = options.validated == true,
    compiled = nil,
    diagnostic = options.diagnostic,
    entry = nil,
    generated_plan = nil,
    authored_definitions = options.authored_definitions or {},
  }
end

local function authored_definitions(parsed)
  local result = {}
  for _, definition in ipairs(parsed.functions) do
    result[#result + 1] = {
      kind = "function",
      name = definition.name,
      line = definition.source_span.line_start,
    }
  end
  for _, rule in ipairs(parsed.rules) do
    result[#result + 1] = {
      kind = "rule",
      name = rule.header.label,
      line = rule.header.line,
    }
  end
  table.sort(result, function(left, right)
    if left.line ~= right.line then return left.line < right.line end
    if left.kind ~= right.kind then return left.kind == "function" end
    return left.name < right.name
  end)
  return result
end

function M.build(source, options)
  local parsed_ok, parsed = pcall(
    user_function_definition_parser.parse_spec_with_staged_user_function_definitions,
    source
  )
  if not parsed_ok then
    rethrow_unrecognized(parsed, recognized_parse_error)
    return failed_outcome({
      diagnostic = language_diagnostic(
        parsed,
        "semantic_index_parse_failed",
        "parse_source"
      ),
    })
  end

  local validated_ok, validation_error = pcall(spec_validator.validate_spec, parsed)
  if not validated_ok then
    rethrow_unrecognized(validation_error, recognized_validation_error)
    return failed_outcome({
      parsed = parsed,
      diagnostic = language_diagnostic(
        validation_error,
        "semantic_index_validation_failed",
        "validate_source"
      ),
    })
  end

  local compiled_ok, candidate = pcall(
    compiled_spec.compile_spec,
    parsed,
    { validate_source = false }
  )
  if not compiled_ok then
    rethrow_unrecognized(candidate, recognized_compile_error)
    return failed_outcome({
      parsed = parsed,
      validated = true,
      diagnostic = language_diagnostic(
        candidate,
        "semantic_index_compilation_failed",
        "compile_source"
      ),
    })
  end

  local definitions = authored_definitions(parsed)
  local selected_ok, selected = pcall(
    compiled_spec.resolve_entry_rule,
    candidate,
    options.entry_rule
  )
  if not selected_ok then
    rethrow_unrecognized(selected, recognized_entry_error)
    return failed_outcome({
      parsed = parsed,
      validated = true,
      authored_definitions = definitions,
      diagnostic = language_diagnostic(
        selected,
        "semantic_index_entry_selection_failed",
        "select_entry_rule"
      ),
    })
  end

  local plan_ok, rows = pcall(source_emitter.build_generated_rule_plan, candidate)
  if not plan_ok then
    rethrow_unrecognized(rows, recognized_plan_error)
    return failed_outcome({
      parsed = parsed,
      validated = true,
      authored_definitions = definitions,
      diagnostic = language_diagnostic(
        rows,
        "semantic_index_generated_plan_failed",
        "build_generated_plan"
      ),
    })
  end

  local copied_rows = {}
  for index, row in ipairs(rows) do
    copied_rows[index] = { label = row.label, family = row.family }
  end
  return {
    parsed = parsed,
    validated = true,
    compiled = candidate,
    diagnostic = nil,
    entry = {
      label = selected.rule.label,
      basis = compiled_spec.entry_rule_selection_basis_name(selected.basis),
    },
    generated_plan = {
      contract_id = source_emitter.GENERATED_SOURCE_CONTRACT,
      format_version = source_emitter.GENERATED_SOURCE_FORMAT,
      source_identity = options.logical_name,
      rows = copied_rows,
    },
    authored_definitions = definitions,
  }
end

return M
