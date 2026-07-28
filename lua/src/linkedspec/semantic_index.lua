-- Opaque strict-source, compiled-or-failed, static-projection, and immutable
-- static-query and immutable observed-runtime foundation for Lua semantic
-- introspection. Generated observation propagation remains a later owner.

local json = require("linkedspec.json")
local sha256 = require("linkedspec.sha256")
local unicode_rule_label = require("linkedspec.unicode_rule_label")

local M = {}

local SOURCE_ID = "source:0"
local SNAPSHOT_ID = "snapshot:0"
local SOURCE_DETAIL_RANK = {
  none = 0,
  identity = 1,
  span = 2,
  text = 3,
}

local INDEX_STATE = setmetatable({}, { __mode = "k" })
local VALUE_STATE = setmetatable({}, { __mode = "k" })
local ERROR_STATE = setmetatable({}, { __mode = "k" })

local INDEX_METHODS = {}
local VALUE_METHODS = {}
local ERROR_METHODS = {}
local outcome_builder
local runtime_projector
local static_projector
local semantic_query
local fail

local function empty_pairs()
  return function() return nil end, nil, nil
end

local function immutable_newindex()
  error("Semantic index values are immutable", 0)
end

local function copy_json_value(value, active)
  local value_type = type(value)
  if value == nil or value_type == "boolean" or value_type == "number" or value_type == "string" then
    return value
  end
  if value_type ~= "table" then
    fail("validate_index", "semantic_index_invalid_source", "Semantic index value is not portable")
  end
  active = active or {}
  if active[value] then
    fail("validate_index", "semantic_index_invalid_source", "Semantic index value contains a cycle")
  end
  active[value] = true
  local result = json.kind(value) == "array" and json.array() or json.harray()
  for key, item in next, value do result[key] = copy_json_value(item, active) end
  active[value] = nil
  return result
end

local function copy_plain_fields(field_pairs)
  local result = json.harray()
  for index = 1, #field_pairs do
    local pair = field_pairs[index]
    result[pair[1]] = copy_json_value(pair[2])
  end
  return result
end

local function copy_plan_rows(rows)
  local result = json.array()
  for index, row in ipairs(rows) do
    result[index] = json.harray({ label = row.label, family = row.family })
  end
  return result
end

local function normalized_field_pairs(fields)
  local names = {}
  for name in next, fields do names[#names + 1] = name end
  table.sort(names)
  local result = {}
  for index = 1, #names do
    local name = names[index]
    result[index] = { name, fields[name] }
  end
  return result
end

local function error_index(value, key)
  local method = ERROR_METHODS[key]
  if method ~= nil then return method end
  local state = ERROR_STATE[value]
  if state == nil then return nil end
  if key == "fields" then return copy_plain_fields(state.field_pairs) end
  return state[key]
end

local ERROR_MT = {
  __index = error_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function(value)
    local state = ERROR_STATE[value]
    if state == nil then return "SemanticIndexError" end
    return state.code .. " at " .. state.stage .. ": " .. state.message
  end,
}

local function semantic_error(stage, code, message, fields)
  local result = setmetatable({}, ERROR_MT)
  ERROR_STATE[result] = {
    stage = stage,
    code = code,
    message = message,
    field_pairs = normalized_field_pairs(fields or {}),
  }
  return result
end

fail = function(stage, code, message, fields)
  error(semantic_error(stage, code, message, fields), 0)
end

function ERROR_METHODS.to_json(value)
  local state = ERROR_STATE[value]
  if state == nil then
    fail("validate_index", "semantic_index_invalid_source", "Invalid semantic index error value")
  end
  return json.harray({
    stage = state.stage,
    code = state.code,
    message = state.message,
    fields = copy_plain_fields(state.field_pairs),
  })
end

local function value_index(value, key)
  local method = VALUE_METHODS[key]
  if method ~= nil then return method end
  local state = VALUE_STATE[value]
  if state == nil then return nil end
  if state.kind == "SemanticCompilationDiagnostic" and key == "fields" then
    return copy_plain_fields(state.fields.field_pairs)
  end
  if state.kind == "SemanticGeneratedPlanInput" and key == "rows" then
    return copy_plan_rows(state.fields.rows)
  end
  return state.fields[key]
end

local VALUE_MT = {
  __index = value_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function(value)
    local state = VALUE_STATE[value]
    return state == nil and "SemanticIndexValue" or state.kind
  end,
}

local function semantic_value(kind, fields)
  local result = setmetatable({}, VALUE_MT)
  VALUE_STATE[result] = { kind = kind, fields = fields }
  return result
end

function VALUE_METHODS.to_json(value)
  local state = VALUE_STATE[value]
  if state == nil then
    fail("validate_index", "semantic_index_invalid_source", "Invalid semantic index value")
  end
  local fields = state.fields
  if state.kind == "SemanticSourceIdentity" then
    return json.harray({
      source_id = fields.source_id,
      logical_name = fields.logical_name,
      byte_length = fields.byte_length,
      scalar_length = fields.scalar_length,
      content_digest = fields.content_digest == nil and json.null or fields.content_digest,
    })
  elseif state.kind == "SemanticSourceSpan" then
    return json.harray({
      start_byte = fields.start_byte,
      end_byte = fields.end_byte,
      start_line = fields.start_line,
      start_column = fields.start_column,
      end_line = fields.end_line,
      end_column = fields.end_column,
    })
  elseif state.kind == "SemanticSnapshot" then
    return json.harray({
      id = fields.id,
      state = fields.state,
      has_execution = fields.has_execution,
      source_detail_ceiling = fields.source_detail_ceiling,
      content_digest_available = fields.content_digest_available,
    })
  elseif state.kind == "SemanticCompilationAuthority" then
    return json.harray({
      parsed = fields.parsed,
      validated = fields.validated,
      compiled = fields.compiled,
    })
  elseif state.kind == "SemanticCompilationDiagnostic" then
    return json.harray({
      code = fields.code,
      stage = fields.stage,
      message = fields.message,
      fields = copy_plain_fields(fields.field_pairs),
    })
  elseif state.kind == "SemanticEntrySelection" then
    return json.harray({ label = fields.label, basis = fields.basis })
  elseif state.kind == "SemanticGeneratedPlanInput" then
    return json.harray({
      contract_id = fields.contract_id,
      format_version = fields.format_version,
      source_identity = fields.source_identity,
      rows = copy_plan_rows(fields.rows),
    })
  end
  fail("validate_index", "semantic_index_invalid_source", "Unknown semantic index value kind")
end

local function index_index(value, key)
  if INDEX_STATE[value] == nil then return nil end
  return INDEX_METHODS[key]
end

local INDEX_MT = {
  __index = index_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function(value)
    local state = INDEX_STATE[value]
    if state == nil then return "SemanticIndex" end
    local snapshot_state = state.outcome.compiled == nil and "failed_compilation" or "compiled"
    return "SemanticIndex(source_id=\"" .. SOURCE_ID ..
      "\", snapshot_state=\"" .. snapshot_state ..
      "\", source_detail_ceiling=\"" .. state.source_detail_ceiling ..
      "\", has_execution=" .. tostring(state.has_execution) .. ")"
  end,
}

local function index_state(value)
  local state = INDEX_STATE[value]
  if state == nil then
    fail("validate_index", "semantic_index_invalid_source", "Invalid semantic index value")
  end
  return state
end

local function decode_scalar(value, position)
  local first = value:byte(position)
  if first <= 0x7F then return first, position + 1 end
  if first <= 0xDF then
    return (first - 0xC0) * 0x40 + (value:byte(position + 1) - 0x80), position + 2
  end
  if first <= 0xEF then
    return (first - 0xE0) * 0x1000 +
      (value:byte(position + 1) - 0x80) * 0x40 +
      (value:byte(position + 2) - 0x80), position + 3
  end
  return (first - 0xF0) * 0x40000 +
    (value:byte(position + 1) - 0x80) * 0x1000 +
    (value:byte(position + 2) - 0x80) * 0x40 +
    (value:byte(position + 3) - 0x80), position + 4
end

local function strict_utf8(value, stage, code, message, fields)
  local valid, invalid_position = json.validate_utf8(value)
  if not valid then
    local failure_fields = {}
    for name, item in next, fields or {} do failure_fields[name] = item end
    failure_fields.offset = invalid_position - 1
    fail(stage, code, message, failure_fields)
  end
end

local function strict_scalars(value, stage, code, message, fields)
  strict_utf8(value, stage, code, message, fields)
  local scalars = {}
  local position = 1
  while position <= #value do
    local scalar
    scalar, position = decode_scalar(value, position)
    scalars[#scalars + 1] = scalar
  end
  return scalars
end

local function build_source_map(source)
  strict_utf8(
    source,
    "decode_source",
    "semantic_index_invalid_utf8",
    "Semantic index source is not valid UTF-8"
  )

  local byte_at_scalar = { 0 }
  local line_at_scalar = { 1 }
  local column_at_scalar = { 1 }
  local scalar_at_byte = { [0] = 0 }
  local position = 1
  local scalar_count = 0
  local line = 1
  local column = 1

  while position <= #source do
    local scalar, next_position = decode_scalar(source, position)
    scalar_count = scalar_count + 1
    if scalar == 0x0A then
      line = line + 1
      column = 1
    else
      column = column + 1
    end
    local byte_offset = next_position - 1
    byte_at_scalar[scalar_count + 1] = byte_offset
    line_at_scalar[scalar_count + 1] = line
    column_at_scalar[scalar_count + 1] = column
    scalar_at_byte[byte_offset] = scalar_count
    position = next_position
  end

  return {
    byte_at_scalar = byte_at_scalar,
    line_at_scalar = line_at_scalar,
    column_at_scalar = column_at_scalar,
    scalar_at_byte = scalar_at_byte,
    scalar_length = scalar_count,
    byte_length = #source,
  }
end

local function validate_options(options)
  if type(options) ~= "table" or getmetatable(options) ~= nil then
    fail(
      "validate_options",
      "semantic_index_invalid_option",
      "Semantic index options must be a plain table",
      { option = "options" }
    )
  end

  local names = {}
  for name in next, options do
    if type(name) ~= "string" then
      fail(
        "validate_options",
        "semantic_index_invalid_option",
        "Semantic index option names must be strings",
        { option = "options" }
      )
    end
    names[#names + 1] = name
  end
  table.sort(names)
  local allowed = { logical_name = true, source_detail_ceiling = true, entry_rule = true }
  for index = 1, #names do
    local name = names[index]
    if not allowed[name] then
      fail(
        "validate_options",
        "semantic_index_invalid_option",
        "Unsupported semantic index option",
        { option = name }
      )
    end
  end

  local logical_name = rawget(options, "logical_name")
  if type(logical_name) ~= "string" then
    fail(
      "validate_options",
      "semantic_index_invalid_option",
      "Semantic index logical name must be strict UTF-8 text",
      { option = "logical_name" }
    )
  end
  local logical_scalars = strict_scalars(
    logical_name,
    "validate_options",
    "semantic_index_invalid_option",
    "Semantic index logical name must be strict UTF-8 text",
    { option = "logical_name" }
  )
  if #logical_scalars == 0 then
    fail(
      "validate_options",
      "semantic_index_invalid_option",
      "Semantic index logical name must be nonempty and contain no control characters",
      { option = "logical_name" }
    )
  end
  for index = 1, #logical_scalars do
    local scalar = logical_scalars[index]
    if scalar <= 0x1F or (scalar >= 0x7F and scalar <= 0x9F) then
      fail(
        "validate_options",
        "semantic_index_invalid_option",
        "Semantic index logical name must be nonempty and contain no control characters",
        { option = "logical_name" }
      )
    end
  end

  local source_detail_ceiling = rawget(options, "source_detail_ceiling")
  if type(source_detail_ceiling) ~= "string" or SOURCE_DETAIL_RANK[source_detail_ceiling] == nil then
    fail(
      "validate_options",
      "semantic_index_invalid_option",
      "Semantic index source detail ceiling must be none, identity, span, or text",
      { option = "source_detail_ceiling" }
    )
  end

  local entry_rule = rawget(options, "entry_rule")
  if entry_rule ~= nil and (type(entry_rule) ~= "string" or not unicode_rule_label.is_rule_label(entry_rule)) then
    fail(
      "validate_options",
      "semantic_index_invalid_option",
      "Semantic index entry rule must be a valid Unicode rule label",
      { option = "entry_rule" }
    )
  end

  return {
    logical_name = logical_name,
    source_detail_ceiling = source_detail_ceiling,
    entry_rule = entry_rule,
  }
end

local function require_detail(state, required)
  if SOURCE_DETAIL_RANK[state.source_detail_ceiling] >= SOURCE_DETAIL_RANK[required] then return end
  fail(
    "apply_source_ceiling",
    "semantic_source_detail_forbidden",
    "Requested source detail exceeds the semantic index ceiling",
    { ceiling = state.source_detail_ceiling, required = required }
  )
end

local function build_compilation_outcome(source, options)
  if outcome_builder == nil then
    outcome_builder = require("linkedspec.semantic_compilation_outcome")
  end
  return outcome_builder.build(source, options)
end

local function load_static_projector()
  if static_projector == nil then
    static_projector = require("linkedspec.semantic_static_projection")
  end
  return static_projector
end

local function load_semantic_query()
  if semantic_query == nil then semantic_query = require("linkedspec.semantic_query") end
  return semantic_query
end

local function load_runtime_projector()
  if runtime_projector == nil then
    runtime_projector = require("linkedspec.semantic_runtime_projection")
  end
  return runtime_projector
end

local function build_static_projection(source, source_map, options, content_digest, outcome)
  return load_static_projector().build({
    source = source,
    source_map = source_map,
    logical_name = options.logical_name,
    source_detail_ceiling = options.source_detail_ceiling,
    content_digest = content_digest,
    outcome = outcome,
    fail = fail,
  })
end

local function source_integer(value, coordinate)
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge or
      value ~= math.floor(value) then
    fail(
      "map_source",
      "semantic_source_range_invalid",
      "Source range coordinates must be finite integers",
      { coordinate = coordinate }
    )
  end
  return value
end

local function span_for_scalar_boundaries(state, start_scalar, end_scalar)
  local map = state.source_map
  return semantic_value("SemanticSourceSpan", {
    start_byte = map.byte_at_scalar[start_scalar + 1],
    end_byte = map.byte_at_scalar[end_scalar + 1],
    start_line = map.line_at_scalar[start_scalar + 1],
    start_column = map.column_at_scalar[start_scalar + 1],
    end_line = map.line_at_scalar[end_scalar + 1],
    end_column = map.column_at_scalar[end_scalar + 1],
  })
end

local function scalar_range_for_bytes(state, start_byte, end_byte)
  start_byte = source_integer(start_byte, "start_byte")
  end_byte = source_integer(end_byte, "end_byte")
  local map = state.source_map
  if start_byte < 0 or start_byte > end_byte or end_byte > map.byte_length then
    fail(
      "map_source",
      "semantic_source_range_invalid",
      "Source byte range is outside the captured source",
      { start_byte = start_byte, end_byte = end_byte }
    )
  end
  local start_scalar = map.scalar_at_byte[start_byte]
  if start_scalar == nil then
    fail(
      "map_source",
      "semantic_source_boundary_invalid",
      "Source byte range starts inside a UTF-8 scalar",
      { start_byte = start_byte }
    )
  end
  local end_scalar = map.scalar_at_byte[end_byte]
  if end_scalar == nil then
    fail(
      "map_source",
      "semantic_source_boundary_invalid",
      "Source byte range ends inside a UTF-8 scalar",
      { end_byte = end_byte }
    )
  end
  return start_scalar, end_scalar
end

function M.create(source, options)
  if type(source) ~= "string" then
    fail(
      "validate_source",
      "semantic_index_invalid_source",
      "Semantic index source must be a Lua string"
    )
  end
  local copied_options = validate_options(options)
  local source_map = build_source_map(source)
  local content_digest = "sha256:" .. sha256.hex(source)
  local outcome = build_compilation_outcome(source, copied_options)
  local static_projection = build_static_projection(
    source,
    source_map,
    copied_options,
    content_digest,
    outcome
  )
  local result = setmetatable({}, INDEX_MT)
  INDEX_STATE[result] = {
    source = source,
    source_map = source_map,
    logical_name = copied_options.logical_name,
    source_detail_ceiling = copied_options.source_detail_ceiling,
    entry_rule = copied_options.entry_rule,
    content_digest = content_digest,
    outcome = outcome,
    static_projection = static_projection,
    has_execution = false,
  }
  return result
end

function INDEX_METHODS.semantic_snapshot(value)
  local state = index_state(value)
  return semantic_value("SemanticSnapshot", {
    id = SNAPSHOT_ID,
    state = state.outcome.compiled == nil and "failed_compilation" or "compiled",
    has_execution = state.has_execution,
    source_detail_ceiling = state.source_detail_ceiling,
    content_digest_available = state.source_detail_ceiling == "text",
  })
end

function INDEX_METHODS.compilation_authority(value)
  local outcome = index_state(value).outcome
  return semantic_value("SemanticCompilationAuthority", {
    parsed = outcome.parsed ~= nil,
    validated = outcome.validated,
    compiled = outcome.compiled ~= nil,
  })
end

function INDEX_METHODS.compilation_diagnostic(value)
  local diagnostic = index_state(value).outcome.diagnostic
  if diagnostic == nil then return nil end
  return semantic_value("SemanticCompilationDiagnostic", {
    code = diagnostic.code,
    stage = diagnostic.stage,
    message = diagnostic.message,
    field_pairs = normalized_field_pairs(diagnostic.fields),
  })
end

function INDEX_METHODS.entry_selection(value)
  local entry = index_state(value).outcome.entry
  if entry == nil then return nil end
  return semantic_value("SemanticEntrySelection", {
    label = entry.label,
    basis = entry.basis,
  })
end

function INDEX_METHODS.generated_plan_input(value)
  local state = index_state(value)
  require_detail(state, "identity")
  local plan = state.outcome.generated_plan
  if plan == nil then return nil end
  return semantic_value("SemanticGeneratedPlanInput", {
    contract_id = plan.contract_id,
    format_version = plan.format_version,
    source_identity = plan.source_identity,
    rows = plan.rows,
  })
end

function INDEX_METHODS.source_identity(value)
  local state = index_state(value)
  require_detail(state, "identity")
  return semantic_value("SemanticSourceIdentity", {
    source_id = SOURCE_ID,
    logical_name = state.logical_name,
    byte_length = state.source_map.byte_length,
    scalar_length = state.source_map.scalar_length,
    content_digest = state.source_detail_ceiling == "text" and state.content_digest or nil,
  })
end

function INDEX_METHODS.source_span_for_bytes(value, start_byte, end_byte)
  local state = index_state(value)
  require_detail(state, "span")
  local start_scalar, end_scalar = scalar_range_for_bytes(state, start_byte, end_byte)
  return span_for_scalar_boundaries(state, start_scalar, end_scalar)
end

function INDEX_METHODS.source_span_for_scalars(value, start_scalar, end_scalar)
  local state = index_state(value)
  require_detail(state, "span")
  start_scalar = source_integer(start_scalar, "start_scalar")
  end_scalar = source_integer(end_scalar, "end_scalar")
  if start_scalar < 0 or start_scalar > end_scalar or end_scalar > state.source_map.scalar_length then
    fail(
      "map_source",
      "semantic_source_range_invalid",
      "Source scalar range is outside the captured source",
      { start_scalar = start_scalar, end_scalar = end_scalar }
    )
  end
  return span_for_scalar_boundaries(state, start_scalar, end_scalar)
end

function INDEX_METHODS.source_excerpt_for_bytes(value, start_byte, end_byte)
  local state = index_state(value)
  require_detail(state, "text")
  scalar_range_for_bytes(state, start_byte, end_byte)
  return state.source:sub(start_byte + 1, end_byte)
end

function INDEX_METHODS.locate_exact(value, needle, after_byte)
  local state = index_state(value)
  require_detail(state, "span")
  if type(needle) ~= "string" or needle == "" then
    fail(
      "map_source",
      "semantic_source_needle_invalid",
      "Source lookup needle must be nonempty strict UTF-8 text"
    )
  end
  strict_utf8(
    needle,
    "map_source",
    "semantic_source_needle_invalid",
    "Source lookup needle must be nonempty strict UTF-8 text"
  )
  if after_byte == nil then after_byte = 0 end
  scalar_range_for_bytes(state, after_byte, after_byte)
  local start_position = state.source:find(needle, after_byte + 1, true)
  if start_position == nil then return nil end
  local start_byte = start_position - 1
  local end_byte = start_byte + #needle
  return INDEX_METHODS.source_span_for_bytes(value, start_byte, end_byte)
end

local function materialize_static_projection(state)
  return load_static_projector().materialize(state.static_projection, fail)
end

function INDEX_METHODS.with_execution_observation(value, events)
  local state = index_state(value)
  local projection = materialize_static_projection(state)
  local derived_projection = load_runtime_projector().derive(projection, events, fail)
  local result = setmetatable({}, INDEX_MT)
  INDEX_STATE[result] = {
    source = state.source,
    source_map = state.source_map,
    logical_name = state.logical_name,
    source_detail_ceiling = state.source_detail_ceiling,
    entry_rule = state.entry_rule,
    content_digest = state.content_digest,
    outcome = state.outcome,
    static_projection = derived_projection,
    has_execution = true,
  }
  return result
end

function INDEX_METHODS.capabilities(value)
  return M._semantic_query_kernel(value, load_semantic_query().request("capabilities"))
end

function INDEX_METHODS.query(value, request)
  return M._semantic_query_kernel(value, request)
end

function INDEX_METHODS.query_neutral(value, request)
  local projection = materialize_static_projection(index_state(value))
  return load_semantic_query().evaluate_neutral(projection, request)
end

-- Shared typed immutable query seam. It supplies exactly one fresh static
-- projection clone and no retained index authority to the evaluator. The
-- package-private name remains available to the focused kernel proof.
function M._semantic_query_kernel(value, request)
  local projection = materialize_static_projection(index_state(value))
  return load_semantic_query().evaluate(projection, request)
end

-- Package-internal exact-oracle seam. The root linkedspec module deliberately
-- exports neither this function nor any static record/query accessor.
function M._static_projection_for_testing(value)
  return materialize_static_projection(index_state(value))
end

return M
