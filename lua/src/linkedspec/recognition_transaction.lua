-- Private invocation frames and linear recognition-transaction tokens.
--
-- This module is required directly by the exact conformance tests and will be
-- consumed by the runtime integration leaf.
-- lua/src/linkedspec/init.lua deliberately does not export these authority,
-- frame, snapshot, or token handles.

local json = require("linkedspec.json")
local source_location = require("linkedspec.source_location")

local M = {}

local TOKEN_EXPECTED_CODE = "recognition_token_expected"
local TOKEN_ESCAPE_CODE = "recognition_token_escape"
local TOKEN_REUSED_CODE = "recognition_token_reused"
local NESTING_FORBIDDEN_CODE = "recognition_nesting_forbidden"
local CROSS_INVOCATION_CODE = "recognition_cross_invocation"
local CROSS_SOURCE_CODE = "recognition_cross_source"
local ATTEMPT_COUNT_CODE = "recognition_attempt_count"
local TERMINAL_REQUIRED_CODE = "recognition_terminal_required"
local EFFECT_FORBIDDEN_CODE = "recognition_effect_forbidden"
local UNKNOWN_EFFECT_CODE = "recognition_unknown_effect"
local ZERO_PROGRESS_REPETITION_CODE = "recognition_zero_progress_repetition"
local ZERO_PROGRESS_RECURSIVE_CYCLE_CODE =
  "recognition_zero_progress_recursive_cycle"
local MARK_GENERATION_INVALID_CODE = "recognition_mark_generation_invalid"
local MAX_EXACT_INTEGER = 9007199254740991

local ALLOWED_EFFECTS = {
  pure_value = true,
  source_read = true,
  structured_control = true,
  rule_recognition = true,
  transaction_state = true,
  cursor_advance = true,
  capture_boundary_write = true,
  invocation_mark_write = true,
  staged_return = true,
}

local REJECTED_EFFECTS = {
  binding_write = true,
  aggregate_write = true,
  ast_or_object_write = true,
  compatibility_cursor_control = true,
  output = true,
  authored_diagnostic = true,
  exit_or_unbounded_control = true,
  dynamic_callable = true,
  parser_registry_or_staged_dispatch = true,
  external_or_host = true,
  unknown_or_raw = true,
}

local next_authority_id = 0
local private_state = setmetatable({}, { __mode = "k" })
local token_metatables = {}

local function fail(message)
  error("recognition transaction: " .. message, 0)
end

local function is_integer(value)
  return type(value) == "number" and value == math.floor(value)
end

local function token_metatable(node_type)
  local metatable = token_metatables[node_type]
  if metatable ~= nil then return metatable end

  metatable = {
    __metatable = "private " .. node_type,
    __newindex = function()
      error(node_type .. " is opaque", 2)
    end,
    __tostring = function(value)
      local state = private_state[value]
      if state ~= nil and state.node_type == "RecognitionTransactionException" then
        return "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:" .. state.record.code
      end
      return node_type .. "(<opaque>)"
    end,
  }
  token_metatables[node_type] = metatable
  return metatable
end

local function new_token(node_type, state)
  state.node_type = node_type
  local value = setmetatable({}, token_metatable(node_type))
  private_state[value] = state
  return value
end

local function state_of(value, expected_type)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil or state.node_type ~= expected_type then
    fail("expected " .. expected_type)
  end
  return state
end

local function options_table(options, operation)
  if type(options) ~= "table" then fail(operation .. " options must be a table") end
  return options
end

local function copied_harray(values)
  local result = json.harray()
  for key, value in pairs(values) do result[key] = value end
  return result
end

local function copy_marks(values, operation)
  if type(values) ~= "table" then fail(operation .. " marks must be a table") end
  local result = {}
  for name, offset in pairs(values) do
    if type(name) ~= "string" then fail(operation .. " mark names must be strings") end
    if not is_integer(offset) then fail(operation .. " mark offsets must be integers") end
    result[name] = offset
  end
  return result
end

local function copy_frame_state(state)
  local marks = {}
  for name, offset in pairs(state.marks) do marks[name] = offset end
  return {
    cursor = state.cursor,
    boundary = state.boundary,
    marks = marks,
  }
end

local function frame_state_token(state)
  return new_token("RecognitionFrameState", copy_frame_state(state))
end

local function frame_state_record(state)
  local marks = json.harray()
  for name, offset in pairs(state.marks) do marks[name] = offset end
  return json.harray({
    cursor = state.cursor,
    boundary = state.boundary == nil and json.null or state.boundary,
    marks = marks,
  })
end

local function raise_transaction_error(code, fields)
  local record = json.harray({ code = code })
  for key, value in pairs(fields or {}) do record[key] = value end
  error(new_token("RecognitionTransactionException", { record = record }), 0)
end

local function claim_authority_id()
  if next_authority_id >= MAX_EXACT_INTEGER then
    fail("authority identity space exhausted")
  end
  next_authority_id = next_authority_id + 1
  return next_authority_id
end

local function claim_generation(authority, field)
  local value = authority[field]
  if value >= MAX_EXACT_INTEGER then fail("generation space exhausted") end
  authority[field] = value + 1
  return value
end

local function authority_state(value)
  return state_of(value, "RecognitionTransactionAuthority")
end

local function invocation_state(value)
  return state_of(value, "RecognitionInvocationFrame").frame
end

local function frame_for_authority(authority, frame_value)
  local frame = invocation_state(frame_value)
  if frame.authority_id ~= authority.authority_id or not frame.active then
    raise_transaction_error(MARK_GENERATION_INVALID_CODE, {
      rule = frame.rule,
      origin = frame.origin,
      generation = frame.generation,
    })
  end
  return frame
end

local function transaction_state(value)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil or state.node_type ~= "RecognitionTransactionToken" then return nil end
  return state.transaction
end

local function token_is_active(token)
  return token.status ~= "invalidated"
end

local function restore_and_invalidate(token)
  if not token_is_active(token) then return end
  local frame = token.frame
  if frame.active then frame.frame_state = copy_frame_state(token.snapshot) end
  if frame.active_token == token then frame.active_token = nil end
  token.status = "invalidated"
  token.matched = false
  token.payload = nil
end

local function invalidate(token)
  if not token_is_active(token) then return end
  local frame = token.frame
  if frame.active_token == token then frame.active_token = nil end
  token.status = "invalidated"
  token.matched = false
  token.payload = nil
end

local function token_for_operation(authority, frame, token_value, operation)
  local token = transaction_state(token_value)
  if token == nil then
    raise_transaction_error(TOKEN_EXPECTED_CODE, {
      rule = frame.rule,
      origin = frame.origin,
    })
  end

  if frame.source_authority ~= token.source_authority then
    restore_and_invalidate(token)
    raise_transaction_error(CROSS_SOURCE_CODE, {
      rule = frame.rule,
      origin = frame.origin,
      expected_source = frame.source_identity,
      actual_source = token.source_identity,
    })
  end

  if frame.authority_id ~= token.authority_id or frame.invocation ~= token.invocation then
    restore_and_invalidate(token)
    raise_transaction_error(CROSS_INVOCATION_CODE, {
      rule = frame.rule,
      origin = frame.origin,
      expected_invocation = frame.invocation,
      actual_invocation = token.invocation,
    })
  end

  if not frame.active or frame.generation ~= token.generation then
    restore_and_invalidate(token)
    raise_transaction_error(MARK_GENERATION_INVALID_CODE, {
      rule = frame.rule,
      origin = frame.origin,
      generation = token.generation,
    })
  end

  if not token_is_active(token) then
    raise_transaction_error(TOKEN_REUSED_CODE, {
      rule = token.rule,
      origin = token.origin,
      operation = operation,
    })
  end
  return token
end

local function require_attempted(token)
  if token.status == "active_staged_match" or token.status == "active_staged_miss" then
    return
  end
  local count = token.attempt_count
  local rule = token.rule
  local origin = token.origin
  restore_and_invalidate(token)
  raise_transaction_error(ATTEMPT_COUNT_CODE, {
    rule = rule,
    origin = origin,
    count = count,
  })
end

function M.node_type(value)
  local state = type(value) == "table" and private_state[value] or nil
  return state and state.node_type or nil
end

function M.is_error(value)
  return M.node_type(value) == "RecognitionTransactionException"
end

-- Construct a detached frame state, or copy the live state of a frame when a
-- second argument is supplied. The dual form mirrors the typed backends while
-- retaining Lua's table-oriented private API.
function M.frame_state(first, second)
  if second ~= nil then
    local authority = authority_state(first)
    return frame_state_token(frame_for_authority(authority, second).frame_state)
  end

  local options = options_table(first, "frame_state")
  if not is_integer(options.cursor) then fail("frame_state cursor must be an integer") end
  if options.boundary ~= nil and not is_integer(options.boundary) then
    fail("frame_state boundary must be an integer or nil")
  end
  return frame_state_token({
    cursor = options.cursor,
    boundary = options.boundary,
    marks = copy_marks(options.marks, "frame_state"),
  })
end

function M.state_cursor(state_value)
  return state_of(state_value, "RecognitionFrameState").cursor
end

function M.state_boundary(state_value)
  return state_of(state_value, "RecognitionFrameState").boundary
end

function M.state_marks(state_value)
  return copied_harray(state_of(state_value, "RecognitionFrameState").marks)
end

function M.authority(options)
  options = options_table(options, "authority")
  if source_location.node_type(options.source_authority) ~= "SourceAuthority" then
    fail("authority source_authority must be a private SourceAuthority")
  end
  if type(options.source_identity) ~= "string" then
    fail("authority source_identity must be a string")
  end
  return new_token("RecognitionTransactionAuthority", {
    authority_id = claim_authority_id(),
    source_authority = options.source_authority,
    source_identity = options.source_identity,
    next_invocation = 1,
    next_generation = 1,
    next_transaction = 1,
    invocation_stack = {},
  })
end

function M.enter_invocation(authority_value, options)
  local authority = authority_state(authority_value)
  options = options_table(options, "enter_invocation")
  if type(options.rule) ~= "string" then fail("enter_invocation rule must be a string") end
  if type(options.origin) ~= "string" then fail("enter_invocation origin must be a string") end
  local supplied_state = state_of(options.state, "RecognitionFrameState")
  local frame = {
    authority_id = authority.authority_id,
    source_authority = authority.source_authority,
    source_identity = authority.source_identity,
    rule = options.rule,
    origin = options.origin,
    invocation = claim_generation(authority, "next_invocation"),
    generation = claim_generation(authority, "next_generation"),
    active = true,
    frame_state = copy_frame_state(supplied_state),
    active_token = nil,
  }
  authority.invocation_stack[#authority.invocation_stack + 1] = frame
  return new_token("RecognitionInvocationFrame", { frame = frame })
end

function M.frame_snapshot(authority_value, frame_value)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  return new_token("RecognitionFrameSnapshot", {
    source = frame.source_identity,
    rule = frame.rule,
    invocation = frame.invocation,
    generation = frame.generation,
    frame_state = copy_frame_state(frame.frame_state),
  })
end

function M.set_frame_state(authority_value, frame_value, state_value)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  frame.frame_state = copy_frame_state(state_of(state_value, "RecognitionFrameState"))
end

function M.reject_missing_token(authority_value, frame_value, origin)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  if type(origin) ~= "string" then fail("reject_missing_token origin must be a string") end
  raise_transaction_error(TOKEN_EXPECTED_CODE, {
    rule = frame.rule,
    origin = origin,
  })
end

function M.write_mark(authority_value, frame_value, name, offset)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  if type(name) ~= "string" then fail("write_mark name must be a string") end
  if not is_integer(offset) then fail("write_mark offset must be an integer") end
  frame.frame_state.marks[name] = offset
  return offset
end

function M.read_mark(authority_value, frame_value, name)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  if type(name) ~= "string" then fail("read_mark name must be a string") end
  return frame.frame_state.marks[name]
end

function M.checkpoint(authority_value, frame_value, origin)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  if type(origin) ~= "string" then fail("checkpoint origin must be a string") end

  for _, stacked_frame in ipairs(authority.invocation_stack) do
    local active_token = stacked_frame.active_token
    if active_token ~= nil and token_is_active(active_token) then
      restore_and_invalidate(active_token)
      raise_transaction_error(NESTING_FORBIDDEN_CODE, {
        rule = frame.rule,
        origin = origin,
      })
    end
  end

  local token = {
    authority_id = authority.authority_id,
    source_authority = authority.source_authority,
    source_identity = authority.source_identity,
    rule = frame.rule,
    origin = origin,
    invocation = frame.invocation,
    generation = frame.generation,
    transaction = claim_generation(authority, "next_transaction"),
    snapshot = copy_frame_state(frame.frame_state),
    frame = frame,
    status = "active_unattempted",
    attempt_count = 0,
    matched = false,
    payload = nil,
  }
  frame.active_token = token
  return new_token("RecognitionTransactionToken", { transaction = token })
end

function M.attempt(authority_value, frame_value, token_value, options)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  local token = token_for_operation(authority, frame, token_value, "attempt")
  options = options_table(options, "attempt")
  if type(options.matched) ~= "boolean" then fail("attempt matched must be a boolean") end
  local staged_state = state_of(options.state, "RecognitionFrameState")

  if token.status ~= "active_unattempted" then
    local count = token.attempt_count + 1
    local rule = token.rule
    local origin = token.origin
    restore_and_invalidate(token)
    raise_transaction_error(ATTEMPT_COUNT_CODE, {
      rule = rule,
      origin = origin,
      count = count,
    })
  end

  frame.frame_state = copy_frame_state(staged_state)
  token.attempt_count = 1
  token.matched = options.matched
  if options.matched then
    token.payload = options.payload
    token.status = "active_staged_match"
  else
    token.payload = json.null
    token.status = "active_staged_miss"
  end
  return options.matched
end

function M.commit(authority_value, frame_value, token_value)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  local token = token_for_operation(authority, frame, token_value, "commit")
  require_attempted(token)
  local payload = token.payload
  invalidate(token)
  return payload
end

function M.rollback(authority_value, frame_value, token_value)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  local token = token_for_operation(authority, frame, token_value, "rollback")
  require_attempted(token)
  restore_and_invalidate(token)
end

function M.reject_escape(authority_value, frame_value, token_value, escape)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  local token = token_for_operation(authority, frame, token_value, "escape")
  if type(escape) ~= "string" then fail("reject_escape escape must be a string") end
  local rule = token.rule
  local origin = token.origin
  restore_and_invalidate(token)
  raise_transaction_error(TOKEN_ESCAPE_CODE, {
    rule = rule,
    origin = origin,
    escape = escape,
  })
end

function M.discard_token(authority_value, frame_value, token_value)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  local token = token_for_operation(authority, frame, token_value, "discard")
  restore_and_invalidate(token)
end

local function effect_error(code, rule, effect)
  raise_transaction_error(code, {
    rule = rule,
    origin = rule .. ":recognize_once",
    effect = effect,
  })
end

function M.classify_effects(authority_value, graph)
  authority_state(authority_value)
  local entry = type(graph) == "table" and graph.entry or nil
  if type(entry) ~= "string" then entry = "<entry>" end
  local raw_rules = type(graph) == "table" and graph.rules or nil
  if json.kind(raw_rules) ~= "harray" then
    effect_error(UNKNOWN_EFFECT_CODE, entry, "unknown_or_raw")
  end

  local effects = {}
  local calls = {}
  for raw_rule, row in pairs(raw_rules) do
    if type(raw_rule) ~= "string" or json.kind(row) ~= "harray" or
        json.kind(row.base) ~= "array" or json.kind(row.calls) ~= "array" then
      effect_error(UNKNOWN_EFFECT_CODE, type(raw_rule) == "string" and raw_rule or entry, "unknown_or_raw")
    end
    local rule_effects = {}
    for _, raw_effect in ipairs(row.base) do
      local effect = type(raw_effect) == "string" and raw_effect or "unknown_or_raw"
      if not ALLOWED_EFFECTS[effect] and not REJECTED_EFFECTS[effect] then
        effect_error(UNKNOWN_EFFECT_CODE, raw_rule, effect)
      end
      rule_effects[effect] = true
    end
    effects[raw_rule] = rule_effects
    local rule_calls = {}
    for index, raw_callee in ipairs(row.calls) do
      rule_calls[index] = type(raw_callee) == "string" and raw_callee or "<dynamic>"
    end
    calls[raw_rule] = rule_calls
  end

  local changed = true
  while changed do
    changed = false
    for rule, callees in pairs(calls) do
      local target = effects[rule]
      for _, callee in ipairs(callees) do
        local inherited = effects[callee] or { unknown_or_raw = true }
        for effect in pairs(inherited) do
          if not target[effect] then
            target[effect] = true
            changed = true
          end
        end
      end
    end
  end

  local entry_effects = effects[entry]
  if entry_effects == nil then
    effect_error(UNKNOWN_EFFECT_CODE, entry, "unknown_or_raw")
  end
  local forbidden = {}
  for effect in pairs(entry_effects) do
    if REJECTED_EFFECTS[effect] then forbidden[#forbidden + 1] = effect end
  end
  table.sort(forbidden)
  if #forbidden > 0 then
    local effect = forbidden[1]
    effect_error(
      effect == "unknown_or_raw" and UNKNOWN_EFFECT_CODE or EFFECT_FORBIDDEN_CODE,
      entry,
      effect
    )
  end
end

local function progress_offset(value)
  if not is_integer(value) then return 0 end
  return value
end

function M.validate_progress(authority_value, fixture)
  authority_state(authority_value)
  local context = type(fixture) == "table" and fixture.context or nil
  if type(context) ~= "string" then context = "unknown" end
  local start_offset = progress_offset(type(fixture) == "table" and fixture.start or nil)
  local end_offset = progress_offset(type(fixture) == "table" and fixture["end"] or nil)
  if end_offset > start_offset or context == "one_shot" then return end

  local rule = type(fixture) == "table" and fixture.id or nil
  if type(rule) ~= "string" then rule = "<rule>" end
  if context ~= "accepted_repetition_iteration" then
    raise_transaction_error(ZERO_PROGRESS_RECURSIVE_CYCLE_CODE, {
      rule = rule,
      origin = rule .. ":recognize_once",
      cycle = context,
      start_offset = start_offset,
      end_offset = end_offset,
    })
  end
  raise_transaction_error(ZERO_PROGRESS_REPETITION_CODE, {
    rule = rule,
    origin = rule .. ":recognize_once",
    start_offset = start_offset,
    end_offset = end_offset,
  })
end

function M.leave_invocation(authority_value, frame_value)
  local authority = authority_state(authority_value)
  local frame = frame_for_authority(authority, frame_value)
  local stack = authority.invocation_stack
  local expected = stack[#stack]
  if expected ~= frame then
    raise_transaction_error(CROSS_INVOCATION_CODE, {
      rule = frame.rule,
      origin = frame.origin,
      expected_invocation = expected and expected.invocation or frame.invocation,
      actual_invocation = frame.invocation,
    })
  end

  local active_token = frame.active_token
  if active_token ~= nil and token_is_active(active_token) then
    local rule = active_token.rule
    local origin = active_token.origin
    restore_and_invalidate(active_token)
    stack[#stack] = nil
    frame.active = false
    raise_transaction_error(TERMINAL_REQUIRED_CODE, {
      rule = rule,
      origin = origin,
    })
  end

  stack[#stack] = nil
  frame.active = false
end

function M.to_json(value)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil then fail("to_json expects a private recognition value") end
  if state.node_type == "RecognitionTransactionException" then
    return copied_harray(state.record)
  end
  if state.node_type == "RecognitionFrameSnapshot" then
    local result = json.harray({
      source = state.source,
      rule = state.rule,
      invocation = state.invocation,
      generation = state.generation,
    })
    for key, member in pairs(frame_state_record(state.frame_state)) do result[key] = member end
    return result
  end
  fail("to_json does not project " .. state.node_type)
end

return M
