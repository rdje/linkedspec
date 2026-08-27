-- Private inert staged parse-job declarations and typed provenance.
--
-- This module owns no parser registry, cache, scheduler, callback, source
-- path, or stitching behavior. Live match boundaries are converted through
-- the existing typed source authority before a detached marker is returned.

local json = require("linkedspec.json")
local source_location = require("linkedspec.source_location")
local source_runtime = require("linkedspec.source_location_runtime")
local staged_capture_provenance = require("linkedspec.staged_capture_provenance")

local M = {}

local ERROR_PREFIX = "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:"
local PROVENANCE_CODE = "staged_source_provenance_invalid"
local SOURCE_ID = "input"

local ERROR_MT = {
  __staged_parse_job_type = "StagedParseJobDeclarationException",
  __tostring = function(value) return ERROR_PREFIX .. value.code end,
}

local function is_integer(value)
  return type(value) == "number" and value == math.floor(value)
end

local function exact_keys(value, expected)
  if type(value) ~= "table" then return false end
  local count = 0
  for key in pairs(value) do
    count = count + 1
    if not expected[key] then return false end
  end
  local expected_count = 0
  for _ in pairs(expected) do expected_count = expected_count + 1 end
  return count == expected_count
end

local function raise_provenance(origin, source_id, provenance)
  error(setmetatable(json.harray({
    code = PROVENANCE_CODE,
    phase = "declare",
    origin = origin,
    source_id = source_id,
    provenance = provenance,
  }), ERROR_MT), 0)
end

local function context(origin)
  return source_location.source_location_context({
    rule_role = origin,
    invocation_role = "staged_parse_job_declaration",
  })
end

local function translate_source_error(operation, origin, source_id, provenance)
  local ok, value = pcall(operation)
  if ok then return value end
  if source_location.is_error(value) then
    raise_provenance(origin, source_id, provenance)
  end
  error(value, 0)
end

local function typed_direct_span(authority, record, origin)
  local object = type(record) == "table" and record or {}
  local source_id = type(object.source_id) == "string" and object.source_id or "<runtime>"
  local provenance = type(object.provenance) == "string" and object.provenance or "<invalid>"
  if not exact_keys(object, {
        kind = true,
        source_id = true,
        start = true,
        ["end"] = true,
        provenance = true,
      }) or object.kind ~= "direct_span" or provenance == "" or
      not is_integer(object.start) or not is_integer(object["end"]) then
    raise_provenance(origin, source_id, provenance)
  end

  return translate_source_error(function()
    local one_context = context(origin)
    local start_position = source_location.position(authority, {
      source_id = source_id,
      offset = object.start,
      context = one_context,
    })
    local end_position = source_location.position(authority, {
      source_id = source_id,
      offset = object["end"],
      context = one_context,
    })
    local span = source_location.direct_span(authority, {
      start = start_position,
      ["end"] = end_position,
      provenance = provenance,
      context = one_context,
    })
    local detached = source_location.to_json(span)
    detached.kind = "direct_span"
    return {
      span = span,
      detached = detached,
      source_id = source_id,
      provenance = provenance,
    }
  end, origin, source_id, provenance)
end

function M.is_error(value)
  return type(value) == "table" and getmetatable(value) == ERROR_MT
end

function M.to_json(value)
  if not M.is_error(value) then error("staged parse-job to_json expects a typed error", 0) end
  return json.harray({
    code = value.code,
    phase = value.phase,
    origin = value.origin,
    source_id = value.source_id,
    provenance = value.provenance,
  })
end

function M.validate_and_materialize_provenance(authority, record, origin)
  if source_location.node_type(authority) ~= "SourceAuthority" then
    error("staged provenance expects SourceAuthority", 0)
  end
  if type(origin) ~= "string" or origin == "" then
    error("staged provenance origin must be a nonempty string", 0)
  end

  if type(record) == "table" and record.kind == "direct_span" then
    local typed = typed_direct_span(authority, record, origin)
    local text = translate_source_error(function()
      return source_location.materialize(authority, typed.span, { context = context(origin) })
    end, origin, typed.source_id, typed.provenance)
    return json.harray({ text = text, provenance = typed.detached })
  end

  if not exact_keys(record, { kind = true, policy = true, segments = true }) or
      record.kind ~= "derived_text" or record.policy ~= "concatenate_in_order" or
      type(record.segments) ~= "table" or #record.segments == 0 then
    raise_provenance(origin, "<derived>", "derived_text")
  end

  local spans = {}
  local detached_segments = json.array()
  for index, segment in ipairs(record.segments) do
    local typed = typed_direct_span(authority, segment, origin)
    spans[index] = typed.span
    detached_segments[index] = typed.detached
  end
  return translate_source_error(function()
    local one_context = context(origin)
    local derived = source_location.derived_text(authority, {
      policy = "concatenate_in_order",
      spans = spans,
      context = one_context,
    })
    return json.harray({
      text = source_location.materialize(authority, derived, { context = one_context }),
      provenance = json.harray({
        kind = "derived_text",
        policy = "concatenate_in_order",
        segments = detached_segments,
      }),
    })
  end, origin, "<derived>", "derived_text")
end

local function runtime_direct_record(authority, registers, origin, plan)
  local one_match
  if plan.source == "entry_text" or plan.source == "entry_group" then
    one_match = registers.entry_match
  elseif plan.source == "match_text" or plan.source == "match_group" then
    one_match = registers.local_match
  end

  local start_byte
  local end_byte
  if one_match ~= nil and (plan.source == "entry_text" or plan.source == "match_text") and
      plan.index == nil then
    start_byte = one_match.byte_start
    end_byte = one_match.byte_end
  elseif one_match ~= nil and (plan.source == "entry_group" or plan.source == "match_group") and
      plan.index ~= nil then
    start_byte, end_byte = staged_capture_provenance.byte_span(one_match, plan.index)
  end
  if start_byte == nil or end_byte == nil then
    raise_provenance(origin, SOURCE_ID, plan.source)
  end

  return translate_source_error(function()
    local one_context = context(origin)
    local start_position = source_location.position_from_utf8_byte(authority, {
      source_id = SOURCE_ID,
      utf8_byte_offset = start_byte,
      context = one_context,
    })
    local end_position = source_location.position_from_utf8_byte(authority, {
      source_id = SOURCE_ID,
      utf8_byte_offset = end_byte,
      context = one_context,
    })
    local span = source_location.direct_span(authority, {
      start = start_position,
      ["end"] = end_position,
      provenance = plan.source,
      context = one_context,
    })
    local detached = source_location.to_json(span)
    detached.kind = "direct_span"
    return detached
  end, origin, SOURCE_ID, plan.source)
end

function M.construct_marker(runtime_source, registers, origin, text_plan, options)
  local authority = source_runtime.source_authority(runtime_source)
  local provenance
  if text_plan.kind == "direct_span" then
    provenance = runtime_direct_record(authority, registers, origin, text_plan)
  else
    local segments = json.array()
    for index, segment in ipairs(text_plan.segments) do
      segments[index] = runtime_direct_record(authority, registers, origin, segment)
    end
    provenance = json.harray({
      kind = "derived_text",
      policy = "concatenate_in_order",
      segments = segments,
    })
  end
  local materialized = M.validate_and_materialize_provenance(authority, provenance, origin)
  local capabilities = json.array()
  for index, capability in ipairs(options.required_capabilities) do
    capabilities[index] = capability
  end
  local sidecar = json.harray({
    kind = "staged_parse_job_v2",
    version = 2,
    state = "declared",
    effect = "staged_parse_job_declaration",
    node_kind = options.node_kind,
    payload_kind = options.payload_kind,
    parser_spec_id = options.spec,
    result_policy = options.result_policy,
    failure_policy = options.on_error,
    required_capabilities = capabilities,
    text = materialized.text,
    provenance = materialized.provenance,
    origin = origin,
  })
  if options.top ~= nil then sidecar.top_rule = options.top end
  if options.into ~= nil then sidecar.into = options.into end
  return json.harray({
    kind = "STAGED_PARSE_JOB_MARKER",
    version = 2,
    sidecar_kind = "staged_parse_job_v2",
    effect = "staged_parse_job_declaration",
    staged_parse_job_v2 = sidecar,
  })
end

return M
