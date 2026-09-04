local compiled_spec = require("linkedspec.compiled_spec")
local interpreter = require("linkedspec.interpreter")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")
local staged_ast_enrichment = require("linkedspec.staged_ast_enrichment")

local M = {}

M.GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"
M.GENERATED_SOURCE_FORMAT = 2

M.EMIT_SOURCE_STAGE = "emit_source"
M.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE = "compile_or_load_generated_source"
M.VALIDATE_GENERATED_PLAN_STAGE = "validate_generated_plan"
M.VALIDATE_COMPILED_RULE_STAGE = "validate_compiled_rule"
M.VALIDATE_GENERATED_SPEC_STAGE = "validate_spec"
M.SELECT_GENERATED_ENTRY_RULE_STAGE = "select_entry_rule"
M.EXECUTE_GENERATED_STAGE = "execute_generated"
M.EXECUTE_RULE_STAGE = "execute_rule"

M.GENERATED_SOURCE_EMIT_FAILED_CODE = "generated_source_emit_failed"
M.GENERATED_SOURCE_COMPILE_FAILED_CODE = "generated_source_compile_failed"
M.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE = "generated_plan_row_count_mismatch"
M.GENERATED_PLAN_LABEL_MISMATCH_CODE = "generated_plan_label_mismatch"
M.GENERATED_PLAN_FAMILY_MISMATCH_CODE = "generated_plan_family_mismatch"
M.GENERATED_PLAN_UNKNOWN_FAMILY_CODE = "generated_plan_unknown_family"
M.GENERATED_SOURCE_CONTRACT_VERSION_MISMATCH_CODE = "generated_source_contract_version_mismatch"
M.REGEX_SLOT_IDENTITY_INVALID_CODE = "regex_slot_identity_invalid"
M.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE = "ordered_regex_slot_identity_lost"
M.GENERATED_NO_RULES_DEFINED_CODE = "no_rules_defined"
M.GENERATED_ENTRY_RULE_NOT_FOUND_CODE = "entry_rule_not_found"
M.GENERATED_EXECUTION_FAILED_CODE = "generated_execution_failed"

local STAGES = {
  [M.EMIT_SOURCE_STAGE] = true,
  [M.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE] = true,
  [M.VALIDATE_GENERATED_PLAN_STAGE] = true,
  [M.VALIDATE_COMPILED_RULE_STAGE] = true,
  [M.VALIDATE_GENERATED_SPEC_STAGE] = true,
  [M.SELECT_GENERATED_ENTRY_RULE_STAGE] = true,
  [M.EXECUTE_GENERATED_STAGE] = true,
  [M.EXECUTE_RULE_STAGE] = true,
}

local CODES = {
  [M.GENERATED_SOURCE_EMIT_FAILED_CODE] = true,
  [M.GENERATED_SOURCE_COMPILE_FAILED_CODE] = true,
  [M.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE] = true,
  [M.GENERATED_PLAN_LABEL_MISMATCH_CODE] = true,
  [M.GENERATED_PLAN_FAMILY_MISMATCH_CODE] = true,
  [M.GENERATED_PLAN_UNKNOWN_FAMILY_CODE] = true,
  [M.GENERATED_SOURCE_CONTRACT_VERSION_MISMATCH_CODE] = true,
  [M.REGEX_SLOT_IDENTITY_INVALID_CODE] = true,
  [M.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE] = true,
  [M.GENERATED_NO_RULES_DEFINED_CODE] = true,
  [M.GENERATED_ENTRY_RULE_NOT_FOUND_CODE] = true,
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
local PLAN_ROW_MT = { __generated_source_type = "GeneratedPlanRow" }
local GENERATED_DIAGNOSTIC_SINK_FAILURE_MT = {
  __tostring = function() return "GeneratedDiagnosticOutputSinkFailure" end,
}
local GENERATED_SEMANTIC_SINK_FAILURE_MT = {
  __tostring = function() return "GeneratedSemanticObservationSinkFailure" end,
}

local FAMILY_NAMES = {
  "default",
  "or_acode",
  "and_single_acode",
  "and_acode_seq",
  "and_bcode",
  "or_bcode",
  "rep_acode",
  "rep_bcode",
  "rep_and_acode",
  "rep_and_bcode",
}

local FAMILY_NAME_SET = {}
for _, family in ipairs(FAMILY_NAMES) do FAMILY_NAME_SET[family] = true end

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

local function optional_integer(value, label)
  if value == nil then return nil end
  if type(value) ~= "number" or value % 1 ~= 0 then fail(label .. " must be an integer") end
  return value
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
    entry_rule = optional_string(options.entry_rule, "generated source error entry_rule"),
    rule_label = optional_string(options.rule_label, "generated source error rule_label"),
    handler_family = optional_string(options.handler_family, "generated source error handler_family"),
    expected_contract = optional_string(options.expected_contract, "generated source error expected_contract"),
    actual_contract = optional_string(options.actual_contract, "generated source error actual_contract"),
    target_rule = optional_string(options.target_rule, "generated source error target_rule"),
    regex_index = optional_integer(options.regex_index, "generated source error regex_index"),
    expected_regex_index = optional_integer(
      options.expected_regex_index,
      "generated source error expected_regex_index"
    ),
    actual_regex_index = optional_integer(
      options.actual_regex_index,
      "generated source error actual_regex_index"
    ),
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
  if value.entry_rule ~= nil then result.entry_rule = value.entry_rule end
  if value.rule_label ~= nil then result.rule_label = value.rule_label end
  if value.handler_family ~= nil then result.handler_family = value.handler_family end
  if value.expected_contract ~= nil then result.expected_contract = value.expected_contract end
  if value.actual_contract ~= nil then result.actual_contract = value.actual_contract end
  if value.target_rule ~= nil then result.target_rule = value.target_rule end
  if value.regex_index ~= nil then result.regex_index = value.regex_index end
  if value.expected_regex_index ~= nil then result.expected_regex_index = value.expected_regex_index end
  if value.actual_regex_index ~= nil then result.actual_regex_index = value.actual_regex_index end
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

function M.generated_source_regex_slot_identity_failed(source_identity, validation_error)
  if type(validation_error) ~= "table" or validation_error.code ~= M.REGEX_SLOT_IDENTITY_INVALID_CODE then
    fail("spec validation error is not a regex-slot identity failure")
  end
  return M.generated_source_error({
    stage = M.VALIDATE_COMPILED_RULE_STAGE,
    code = M.REGEX_SLOT_IDENTITY_INVALID_CODE,
    summary = "Compiled regex slot identity is invalid",
    source_identity = require_string(source_identity, "source_identity", true),
    rule_label = validation_error.fields.rule_label,
    target_rule = validation_error.fields.target_rule,
    regex_index = validation_error.fields.regex_index,
    detail = validation_error.message,
  })
end

function M.generated_source_ordered_regex_slot_identity_lost(source_identity, runtime_error)
  local diagnostic = type(runtime_error) == "table" and runtime_error.diagnostic or nil
  if diagnostic == nil or diagnostic.code ~= M.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE then
    fail("runtime error is not an ordered regex-slot identity failure")
  end
  return M.generated_source_error({
    stage = M.EXECUTE_RULE_STAGE,
    code = M.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE,
    summary = "Ordered regex-slot identity invariant failed",
    source_identity = require_string(source_identity, "source_identity", true),
    rule_label = diagnostic.rule_label,
    target_rule = diagnostic.target_rule,
    expected_regex_index = diagnostic.expected_regex_index,
    actual_regex_index = diagnostic.actual_regex_index,
    detail = diagnostic.detail,
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

function M.generated_source_entry_rule_selection_failed(source_identity, runtime_error)
  if not interpreter.is_runtime_interpreter_error(runtime_error) or runtime_error.diagnostic == nil then
    fail("runtime error is not an entry-rule selection failure")
  end
  local diagnostic = runtime_error.diagnostic
  if diagnostic.code ~= M.GENERATED_NO_RULES_DEFINED_CODE and
      diagnostic.code ~= M.GENERATED_ENTRY_RULE_NOT_FOUND_CODE then
    fail("runtime error is not an entry-rule selection failure")
  end
  local zero_rules = diagnostic.code == M.GENERATED_NO_RULES_DEFINED_CODE
  return M.generated_source_error({
    stage = zero_rules and M.VALIDATE_GENERATED_SPEC_STAGE or M.SELECT_GENERATED_ENTRY_RULE_STAGE,
    code = zero_rules and M.GENERATED_NO_RULES_DEFINED_CODE or M.GENERATED_ENTRY_RULE_NOT_FOUND_CODE,
    summary = "Generated Lua parser entry-rule selection failed",
    source_identity = require_string(source_identity, "source_identity", true),
    entry_rule = diagnostic.entry_rule,
    rule_label = diagnostic.rule_label,
    detail = diagnostic.detail,
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

function M.generated_plan_row(label, family)
  return setmetatable({
    label = require_string(label, "generated plan row label", false),
    family = require_string(family, "generated plan row family", false),
  }, PLAN_ROW_MT)
end

function M.is_generated_plan_row(value)
  return getmetatable(value) == PLAN_ROW_MT
end

function M.generated_plan_row_to_json(value)
  if not M.is_generated_plan_row(value) then
    fail("generated_plan_row_to_json expects GeneratedPlanRow")
  end
  return json.harray({ label = value.label, family = value.family })
end

function M.generated_rule_family_names()
  local result = json.array()
  for index, family in ipairs(FAMILY_NAMES) do result[index] = family end
  return result
end

function M.generated_family_cursor_policy(family)
  if type(family) ~= "string" or not FAMILY_NAME_SET[family] then
    fail("unsupported generated rule family")
  end
  return interpreter.generated_family_execution_policy(family).cursor_policy
end

function M.classify_generated_rule_family(rule)
  if compiled_spec.node_type(rule) ~= "CompiledRule" then
    fail("classify_generated_rule_family expects CompiledRule")
  end
  local mode = rule.mode_metadata.name
  local is_generated_repetition = mode == "Plus" or mode == "Star" or mode == "Optional" or mode == "Or" or
    mode == "OrPlus" or mode == "AndPlus" or mode == "OrBounded" or mode == "AndBounded"
  if is_generated_repetition then
    if #rule.blind_edges > 0 then
      return rule.mode_metadata.is_and and "rep_and_bcode" or "rep_bcode"
    end
    return rule.mode_metadata.is_and and "rep_and_acode" or "rep_acode"
  end
  if #rule.blind_edges > 0 then
    return (mode == "Or" or mode == "Pipe") and "or_bcode" or "and_bcode"
  end
  if mode == "Default" then return "default" end
  if mode == "Pipe" then return "or_acode" end
  if mode == "Single" then return "and_single_acode" end
  if mode == "And" then
    if #rule.regex_patterns <= 1 and #rule.action_edges <= 1 then
      return "and_single_acode"
    end
    return "and_acode_seq"
  end
  fail("unsupported generated rule mode '" .. tostring(mode) .. "'")
end

function M.build_generated_rule_plan(compiled)
  if compiled_spec.node_type(compiled) ~= "CompiledSpec" then
    fail("build_generated_rule_plan expects CompiledSpec")
  end
  local plan = json.array()
  for index, label in ipairs(compiled.compiled_rule_order) do
    plan[index] = M.generated_plan_row(
      label,
      M.classify_generated_rule_family(compiled.rules_by_label[label])
    )
  end
  return plan
end

local function generated_plan_failure(source_identity, code, summary, options)
  options = options or {}
  raise(M.generated_source_error({
    stage = M.VALIDATE_GENERATED_PLAN_STAGE,
    code = code,
    summary = summary,
    source_identity = source_identity,
    rule_label = options.rule_label,
    handler_family = options.handler_family,
    expected_contract = options.expected_contract,
    actual_contract = options.actual_contract,
    detail = options.detail,
  }))
end

function M.validate_generated_source_contract_v2(actual_contract, source_identity)
  local identity = require_string(source_identity, "source_identity", false)
  local actual = require_string(actual_contract, "actual generated source contract", false)
  if actual == M.GENERATED_SOURCE_CONTRACT then return end
  generated_plan_failure(
    identity,
    M.GENERATED_SOURCE_CONTRACT_VERSION_MISMATCH_CODE,
    "Generated source contract does not match the active validator",
    {
      expected_contract = M.GENERATED_SOURCE_CONTRACT,
      actual_contract = actual,
      detail = "regenerate the generated artifact from its .spec source",
    }
  )
end

function M.validate_generated_rule_plan_v2(compiled, plan, source_identity, actual_contract)
  local identity = require_string(source_identity, "source_identity", false)
  M.validate_generated_source_contract_v2(actual_contract or M.GENERATED_SOURCE_CONTRACT, identity)
  if compiled_spec.node_type(compiled) ~= "CompiledSpec" then
    raise(M.generated_source_compile_failed(identity, "compiled must be a CompiledSpec"))
  end
  if type(plan) ~= "table" then fail("generated rule plan must be a table") end
  local slots_ok, slots_error = pcall(compiled_spec.validate_compiled_regex_slot_identities, compiled)
  if not slots_ok then
    if type(slots_error) == "table" and slots_error.code == M.REGEX_SLOT_IDENTITY_INVALID_CODE then
      raise(M.generated_source_regex_slot_identity_failed(identity, slots_error))
    end
    raise(M.generated_source_compile_failed(identity, slots_error))
  end
  local selector_ok, selector_error = pcall(compiled_spec.validate_no_removed_aggregate_selectors, compiled)
  if not selector_ok then raise(M.generated_source_compile_failed(identity, selector_error)) end
  local nested_write_ok, nested_write_error = pcall(
    compiled_spec.validate_nested_write_serialized_state,
    compiled
  )
  if not nested_write_ok then raise(M.generated_source_compile_failed(identity, nested_write_error)) end
  local receiver_mutation_ok, receiver_mutation_error = pcall(
    compiled_spec.validate_receiver_mutation_serialized_state,
    compiled
  )
  if not receiver_mutation_ok then
    raise(M.generated_source_compile_failed(identity, receiver_mutation_error))
  end
  if #compiled.compiled_rule_order ~= #plan then
    generated_plan_failure(
      identity,
      M.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE,
      "Generated rule plan row count does not match compiled rules",
      {
        detail = "expected=" .. #compiled.compiled_rule_order .. " actual=" .. #plan,
      }
    )
  end

  local validated = {}
  for index, row in ipairs(plan) do
    if not M.is_generated_plan_row(row) then
      fail("generated rule plan row " .. (index - 1) .. " must be a GeneratedPlanRow")
    end
    local expected_label = compiled.compiled_rule_order[index]
    if row.label ~= expected_label then
      generated_plan_failure(
        identity,
        M.GENERATED_PLAN_LABEL_MISMATCH_CODE,
        "Generated rule plan label does not match compiled rule",
        {
          rule_label = expected_label,
          detail = "row=" .. (index - 1) .. " expected=" .. expected_label .. " actual=" .. row.label,
        }
      )
    end
    if not FAMILY_NAME_SET[row.family] then
      generated_plan_failure(
        identity,
        M.GENERATED_PLAN_UNKNOWN_FAMILY_CODE,
        "Generated rule plan contains an unknown family",
        {
          rule_label = expected_label,
          handler_family = row.family,
          detail = "row=" .. (index - 1),
        }
      )
    end
    local expected_family = M.classify_generated_rule_family(compiled.rules_by_label[expected_label])
    if row.family ~= expected_family then
      generated_plan_failure(
        identity,
        M.GENERATED_PLAN_FAMILY_MISMATCH_CODE,
        "Generated rule plan family does not match compiled rule",
        {
          rule_label = expected_label,
          handler_family = row.family,
          detail = "row=" .. (index - 1) .. " expected=" .. expected_family .. " actual=" .. row.family,
        }
      )
    end
    validated[expected_label] = row.family
  end
  return validated
end

local function copy_options(options, context)
  options = options or {}
  require_options(options, context)
  local result = {}
  for key, value in pairs(options) do result[key] = value end
  return result
end

local function execute_generated(compiled, plan, input, source_identity, options, trace_config)
  local identity = require_string(source_identity, "source_identity", false)
  local families = M.validate_generated_rule_plan_v2(compiled, plan, identity)
  local runtime_options = copy_options(options, "generated execution")
  local diagnostic_sink = runtime_options.diagnostic_sink
  if type(diagnostic_sink) == "function" then
    runtime_options.diagnostic_sink = function(event)
      local delivered, failure = pcall(diagnostic_sink, event)
      if not delivered then
        raise(setmetatable({ failure = failure }, GENERATED_DIAGNOSTIC_SINK_FAILURE_MT))
      end
    end
  end
  local semantic_sink = runtime_options.semantic_observation_sink
  if type(semantic_sink) == "function" then
    local generated_semantic_sink = function(event)
      local delivered, failure = pcall(semantic_sink, event)
      if not delivered then
        raise(setmetatable({ failure = failure }, GENERATED_SEMANTIC_SINK_FAILURE_MT))
      end
    end
    runtime_options.semantic_observation_sink = generated_semantic_sink
    runtime_options._generated_semantic_observation_sink = generated_semantic_sink
  end
  runtime_options._generated_families = families
  runtime_options._generated_source_identity = identity
  local bounded_child_parse_authority = runtime_options.bounded_child_parse_authority
  runtime_options.bounded_child_parse_authority = nil
  local staged_ast_enrichment_seed = runtime_options.staged_ast_enrichment_seed
  runtime_options.staged_ast_enrichment_seed = nil
  local operation
  if trace_config == nil then
    operation = function()
      return interpreter.runtime_parse(interpreter.runtime_engine(compiled, {
        bounded_child_parse_authority = bounded_child_parse_authority,
        staged_ast_enrichment_seed = staged_ast_enrichment_seed,
      }), input, runtime_options)
    end
  else
    operation = function()
      return interpreter.runtime_parse_with_trace(
        interpreter.runtime_engine(compiled, {
          bounded_child_parse_authority = bounded_child_parse_authority,
          staged_ast_enrichment_seed = staged_ast_enrichment_seed,
        }),
        input,
        trace_config,
        runtime_options
      )
    end
  end

  local ok, result = pcall(operation)
  if ok then return result.value end
  if M.is_generated_source_error(result) then raise(result) end
  if staged_ast_enrichment.is_error(result) then raise(result) end
  if getmetatable(result) == GENERATED_DIAGNOSTIC_SINK_FAILURE_MT then
    raise(result.failure)
  end
  if getmetatable(result) == GENERATED_SEMANTIC_SINK_FAILURE_MT then
    raise(result.failure)
  end
  if interpreter.is_runtime_exit_now(result) then raise(result) end
  if interpreter.is_runtime_interpreter_error(result) and result.diagnostic ~= nil and
      result.diagnostic.code == interpreter.PARSE_MODE_OVERRIDE_REMOVED_CODE then
    raise(result)
  end
  if interpreter.is_runtime_interpreter_error(result) and result.diagnostic ~= nil and
      result.diagnostic.code == M.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE then
    raise(M.generated_source_ordered_regex_slot_identity_lost(identity, result))
  end
  if interpreter.is_runtime_interpreter_error(result) and result.diagnostic ~= nil and
      (result.diagnostic.code == M.GENERATED_NO_RULES_DEFINED_CODE or
        result.diagnostic.code == M.GENERATED_ENTRY_RULE_NOT_FOUND_CODE) then
    raise(M.generated_source_entry_rule_selection_failed(identity, result))
  end
  local rule_label = nil
  if interpreter.is_runtime_interpreter_error(result) and result.diagnostic ~= nil then
    rule_label = result.diagnostic.rule_label
  end
  raise(M.generated_source_execution_failed(identity, result, {
    rule_label = rule_label,
    handler_family = rule_label and families[rule_label] or nil,
  }))
end

function M.execute_generated_parser_v2(compiled, plan, input, source_identity, options)
  return execute_generated(compiled, plan, input, source_identity, options, nil)
end

function M.execute_generated_parser_with_trace_v2(
    compiled,
    plan,
    input,
    trace_config,
    source_identity,
    options
  )
  return execute_generated(compiled, plan, input, source_identity, options, trace_config)
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
  return spec_ast.spec_file({
    source_id = compiled.source_id,
    functions = functions,
    rules = rules,
  })
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

local function generated_module_source(identity_hex, spec_json_hex, plan)
  local plan_lines = {}
  for index, row in ipairs(plan) do
    plan_lines[index] = '  linkedspec.generated_plan_row(decode_hex("' ..
      hex_encode(row.label) .. '"), "' .. row.family .. '"),'
  end
  return table.concat({
    "-- Generated LinkedSpec parser module.",
    "-- Contract id: linkedspec-generated-source-v2.",
    "-- Source format: linkedspec_lua source_emitter v2.",
    "-- Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.",
    "",
    'local linkedspec = require("linkedspec")',
    "local M = {}",
    "",
    'M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"',
    "M.LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2",
    'M.LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT = "linkedspec-duplicate-regex-slot-identity-v1"',
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
    "local _GENERATED_PLAN = {",
    table.concat(plan_lines, "\n"),
    "}",
    "",
    "linkedspec.validate_generated_source_contract_v2(",
    "  M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT,",
    "  M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY",
    ")",
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
    "",
    "function M.plan()",
    "  local result = {}",
    "  for index, row in ipairs(_GENERATED_PLAN) do",
    "    result[index] = linkedspec.generated_plan_row(row.label, row.family)",
    "  end",
    "  return result",
    "end",
    "",
    "function M.validate_plan(actual)",
    "  linkedspec.validate_generated_rule_plan_v2(",
    "    _COMPILED_SPEC,",
    "    actual,",
    "    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY",
    "  )",
    "end",
    "",
    "function M.execute(input, options)",
    "  return linkedspec.execute_generated_parser_v2(",
    "    _COMPILED_SPEC,",
    "    _GENERATED_PLAN,",
    "    input,",
    "    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,",
    "    options",
    "  )",
    "end",
    "",
    "function M.execute_with_trace(input, trace_config, options)",
    "  return linkedspec.execute_generated_parser_with_trace_v2(",
    "    _COMPILED_SPEC,",
    "    _GENERATED_PLAN,",
    "    input,",
    "    trace_config,",
    "    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,",
    "    options",
    "  )",
    "end",
    "",
    "return M",
    "",
  }, "\n")
end

function M.emit_lua_source(compiled)
  return M.emit_lua_source_v2(compiled, "<inline>")
end

function M.emit_lua_source_v2(compiled, source_identity)
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
    compiled_spec.validate_compiled_regex_slot_identities(compiled)
    compiled_spec.validate_no_removed_aggregate_selectors(compiled)
    compiled_spec.validate_nested_write_serialized_state(compiled)
    compiled_spec.validate_receiver_mutation_serialized_state(compiled)
    local spec_json = json.encode(spec_ast.to_json(effective_spec(compiled)))
    return generated_module_source(
      hex_encode(identity),
      hex_encode(spec_json),
      M.build_generated_rule_plan(compiled)
    )
  end)
  if ok then return result end
  if M.is_generated_source_error(result) then raise(result) end
  if type(result) == "table" and result.code == M.REGEX_SLOT_IDENTITY_INVALID_CODE then
    raise(M.generated_source_regex_slot_identity_failed(identity, result))
  end
  emit_failure(
    identity,
    "Failed to serialize compiled spec for generated Lua source",
    tostring(result)
  )
end

return M
