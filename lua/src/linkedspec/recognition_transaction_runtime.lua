-- Private adapter between the Lua interpreter's live registers and the
-- recognition-transaction authority. This module is intentionally absent
-- from linkedspec/init.lua.

local json = require("linkedspec.json")
local matching = require("linkedspec.matching")
local transaction = require("linkedspec.recognition_transaction")
local source_location = require("linkedspec.source_location")
local typed_source = require("linkedspec.source_location_runtime")

local M = {}

local function frame_state(ctx, rule_label)
  local marks = ctx.mark_buckets[rule_label]
  if marks == nil then
    marks = {}
    ctx.mark_buckets[rule_label] = marks
  end
  return transaction.frame_state({
    cursor = ctx.cursor_byte,
    boundary = ctx.registers.capture_start_byte,
    marks = marks,
  })
end

local function apply_frame_state(ctx, rule_label, state)
  local cursor = transaction.state_cursor(state)
  cursor = math.max(0, math.min(#ctx.input, cursor))
  local boundary = transaction.state_boundary(state)
  ctx.registers = matching.runtime_match_registers(ctx.input, {
    cursor_byte = cursor,
    entry_match = ctx.registers.entry_match,
    local_match = ctx.registers.local_match,
    capture_start_byte = boundary == nil and json.null or boundary,
  })
  ctx.cursor_byte = ctx.registers.cursor_byte
  local marks = {}
  for name, offset in pairs(transaction.state_marks(state)) do marks[name] = offset end
  ctx.mark_buckets[rule_label] = marks
end

local function active_frame(ctx, rule_label)
  local frame = ctx.recognition_frames[#ctx.recognition_frames]
  if frame == nil or frame.rule ~= rule_label then
    error("recognition invocation is not active for rule '" .. rule_label .. "'", 0)
  end
  return frame
end

local function token_for(ctx, frame, slot, origin)
  local token = frame.tokens[slot]
  if token ~= nil then return token end
  return transaction.reject_missing_token(
    ctx.recognition_authority,
    frame.authority_frame,
    origin
  )
end

function M.context(source_runtime)
  return {
    recognition_authority = transaction.authority({
      source_authority = typed_source.source_authority(source_runtime),
      source_identity = "input",
    }),
    recognition_frames = {},
    recursive_observation_scopes = {},
  }
end

function M.enter_invocation(ctx, rule_label)
  local prior_marks = ctx.mark_buckets[rule_label]
  ctx.mark_buckets[rule_label] = {}
  local ok, authority_frame = pcall(
    transaction.enter_invocation,
    ctx.recognition_authority,
    {
      rule = rule_label,
      origin = rule_label .. ":handler_entry",
      state = frame_state(ctx, rule_label),
    }
  )
  if not ok then
    ctx.mark_buckets[rule_label] = prior_marks
    error(authority_frame, 0)
  end
  ctx.recognition_frames[#ctx.recognition_frames + 1] = {
    rule = rule_label,
    authority_frame = authority_frame,
    prior_marks = prior_marks,
    tokens = {},
    identity = transaction.invocation_identity(ctx.recognition_authority, authority_frame),
    entry_byte = ctx.cursor_byte,
    selected_match = nil,
    observation_scope = nil,
  }
end

local function leave_invocation_with_outcome(ctx, rule_label, result, terminal_error)
  local frame = active_frame(ctx, rule_label)
  local actual = frame_state(ctx, rule_label)
  local restored = actual
  for _, token in pairs(frame.tokens) do
    restored = token.snapshot
    break
  end
  local ok, failure = pcall(function()
    transaction.set_frame_state(ctx.recognition_authority, frame.authority_frame, actual)
    transaction.leave_invocation(ctx.recognition_authority, frame.authority_frame)
  end)
  if frame.observation_scope ~= nil then
    local completion_error = terminal_error or (not ok and failure or nil)
    local accepted = completion_error == nil and type(result) == "table" and result.matched == true
    frame.observation_scope.completion = {
      identity = frame.identity,
      entry_byte = frame.entry_byte,
      selected_match = frame.selected_match,
      accepted_exit_byte = accepted and transaction.state_cursor(actual) or nil,
      outcome = completion_error ~= nil and "aborted" or accepted and "accepted" or "failed",
      diagnostic = nil,
    }
  end
  apply_frame_state(ctx, rule_label, restored)
  ctx.recognition_frames[#ctx.recognition_frames] = nil
  ctx.mark_buckets[rule_label] = frame.prior_marks
  if not ok then error(failure, 0) end
end

function M.leave_invocation(ctx, rule_label)
  return leave_invocation_with_outcome(ctx, rule_label, nil, nil)
end

function M.leave_invocation_with_outcome(ctx, rule_label, result, terminal_error)
  return leave_invocation_with_outcome(ctx, rule_label, result, terminal_error)
end

function M.begin_observation(ctx, rule_label)
  local scope = { rule = rule_label, entered = false, completion = nil }
  ctx.recursive_observation_scopes[#ctx.recursive_observation_scopes + 1] = scope
  return scope
end

function M.expects_observation(ctx, rule_label)
  local scope = ctx.recursive_observation_scopes[#ctx.recursive_observation_scopes]
  return scope ~= nil and not scope.entered and scope.rule == rule_label
end

function M.note_observation_entry(ctx, rule_label, entry_byte)
  if not M.expects_observation(ctx, rule_label) then return end
  local scope = ctx.recursive_observation_scopes[#ctx.recursive_observation_scopes]
  scope.entered = true
  local frame = active_frame(ctx, rule_label)
  frame.entry_byte = entry_byte
  frame.observation_scope = scope
end

function M.reject_observation(ctx, rule_label, entry_byte)
  local scope = ctx.recursive_observation_scopes[#ctx.recursive_observation_scopes]
  if scope == nil or scope.entered or scope.rule ~= rule_label then
    error("recursive observation rejection scope is invalid", 0)
  end
  local frame = ctx.recognition_frames[#ctx.recognition_frames]
  local direct = frame ~= nil and frame.rule == rule_label
  local code = direct and
    "source_location_nonprogress_direct_recursion" or
    "source_location_nonprogress_mutual_recursion"
  scope.entered = true
  scope.completion = {
    identity = transaction.reserve_rejected_invocation(ctx.recognition_authority, rule_label),
    entry_byte = entry_byte,
    selected_match = nil,
    accepted_exit_byte = nil,
    outcome = "rejected",
    diagnostic = code,
  }
  return code
end

function M.note_match(ctx, one)
  local frame = ctx.recognition_frames[#ctx.recognition_frames]
  if frame ~= nil then frame.selected_match = one end
end

function M.observation_scope_is_active(ctx, scope)
  return ctx.recursive_observation_scopes[#ctx.recursive_observation_scopes] == scope
end

local function observation_position(ctx, byte_offset, rule_label)
  local value = ctx.source_location:position_from_byte(
    byte_offset,
    rule_label,
    "recursive_observation"
  )
  if value == nil then error("recursive observation position is invalid", 0) end
  return source_location.to_json(value)
end

local function observation_span(ctx, one, rule_label)
  local value = ctx.source_location:span_from_bytes(
    one.byte_start,
    one.byte_end,
    rule_label,
    "match"
  )
  if value == nil then error("recursive observation match span is invalid", 0) end
  return source_location.to_json(value)
end

function M.bind_observation(ctx, rule_label, target, scope)
  if not M.observation_scope_is_active(ctx, scope) then
    error("recursive observation scope order is invalid", 0)
  end
  local completion = scope.completion
  if completion == nil then
    error("recursive observation for '" .. scope.rule .. "' completed without a record", 0)
  end
  local record = json.harray({
    source_id = "input",
    rule_label = completion.identity.rule_label,
    invocation_id = completion.identity.invocation_id,
    parent_invocation_id = completion.identity.parent_invocation_id,
    entry_position = observation_position(ctx, completion.entry_byte, rule_label),
    selected_match = completion.selected_match and
      observation_span(ctx, completion.selected_match, rule_label) or json.null,
    accepted_exit = completion.accepted_exit_byte ~= nil and
      observation_position(ctx, completion.accepted_exit_byte, rule_label) or json.null,
    outcome = completion.outcome,
    diagnostic = completion.diagnostic or json.null,
  })
  ctx.variables[target] = nil
  ctx.arrays[target] = nil
  ctx.harrays[target] = record
  ctx.recursive_observation_scopes[#ctx.recursive_observation_scopes] = nil
end

function M.checkpoint(ctx, rule_label, slot)
  local frame = active_frame(ctx, rule_label)
  local actual = frame_state(ctx, rule_label)
  transaction.set_frame_state(ctx.recognition_authority, frame.authority_frame, actual)
  frame.tokens[slot] = {
    authority_token = transaction.checkpoint(
      ctx.recognition_authority,
      frame.authority_frame,
      rule_label .. ":" .. slot
    ),
    snapshot = actual,
  }
end

function M.attempt(ctx, rule_label, slot, matched, payload)
  local frame = active_frame(ctx, rule_label)
  local token = token_for(ctx, frame, slot, rule_label .. ":recognize_once")
  return transaction.attempt(
    ctx.recognition_authority,
    frame.authority_frame,
    token.authority_token,
    {
      matched = matched,
      payload = payload,
      state = frame_state(ctx, rule_label),
    }
  )
end

function M.commit(ctx, rule_label, slot)
  local frame = active_frame(ctx, rule_label)
  local token = token_for(ctx, frame, slot, rule_label .. ":recognition_commit")
  transaction.set_frame_state(
    ctx.recognition_authority,
    frame.authority_frame,
    frame_state(ctx, rule_label)
  )
  local payload = transaction.commit(
    ctx.recognition_authority,
    frame.authority_frame,
    token.authority_token
  )
  frame.tokens[slot] = nil
  return payload
end

function M.rollback(ctx, rule_label, slot)
  local frame = active_frame(ctx, rule_label)
  local token = token_for(ctx, frame, slot, rule_label .. ":recognition_rollback")
  transaction.set_frame_state(
    ctx.recognition_authority,
    frame.authority_frame,
    frame_state(ctx, rule_label)
  )
  transaction.rollback(
    ctx.recognition_authority,
    frame.authority_frame,
    token.authority_token
  )
  apply_frame_state(
    ctx,
    rule_label,
    transaction.frame_state(ctx.recognition_authority, frame.authority_frame)
  )
  frame.tokens[slot] = nil
end

return M
