-- Private adapter between the Lua interpreter's live registers and the
-- recognition-transaction authority. This module is intentionally absent
-- from linkedspec/init.lua.

local json = require("linkedspec.json")
local matching = require("linkedspec.matching")
local transaction = require("linkedspec.recognition_transaction")
local source_location = require("linkedspec.source_location")
local typed_source = require("linkedspec.source_location_runtime")

local M = {}

local GAP_ERROR_MT = {
  __tostring = function(value) return value.prefix .. value.code end,
}

local function gap_error(prefix, code, fields)
  fields = fields or {}
  fields.prefix = prefix
  fields.code = code
  error(setmetatable(fields, GAP_ERROR_MT), 0)
end

local function copy_gap_context(value)
  if value == nil then return nil end
  return {
    source_id = value.source_id,
    rule_label = value.rule_label,
    invocation_id = value.invocation_id,
    edge_ordinal = value.edge_ordinal,
    kind = value.kind,
    start_byte = value.start_byte,
    end_byte = value.end_byte,
  }
end

local function copy_gap_state(value)
  if value == nil then return nil end
  return {
    committed_gap_cursor = value.committed_gap_cursor,
    accepted_edge_count = value.accepted_edge_count,
    current_gap = copy_gap_context(value.current_gap),
  }
end

local function copy_entry_slot(value)
  if value == nil then return nil end
  return {
    owner_invocation_id = value.owner_invocation_id,
    target_rule = value.target_rule,
    regex_index = value.regex_index,
    slot_id = value.slot_id,
    selector_kind = value.selector_kind,
    authored_selector = value.authored_selector,
  }
end

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

function M.enter_invocation(ctx, rule_label, options)
  options = options or {}
  if type(options) ~= "table" then error("recognition invocation options must be a table", 0) end
  local capture_gaps = options.capture_gaps == true
  local parent = ctx.recognition_frames[#ctx.recognition_frames]
  local supplied_entry_slot = options.entry_slot
  local accepted_entry_slot = nil
  if supplied_entry_slot ~= nil and parent ~= nil and
      parent.identity.invocation_id == supplied_entry_slot.owner_invocation_id and
      parent.gap_state ~= nil and parent.gap_state.current_gap ~= nil and
      supplied_entry_slot.target_rule == rule_label then
    accepted_entry_slot = copy_entry_slot(supplied_entry_slot)
  end
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
  local identity = transaction.invocation_identity(ctx.recognition_authority, authority_frame)
  ctx.recognition_frames[#ctx.recognition_frames + 1] = {
    rule = rule_label,
    authority_frame = authority_frame,
    prior_marks = prior_marks,
    tokens = {},
    identity = identity,
    entry_byte = ctx.cursor_byte,
    selected_match = nil,
    observation_scope = nil,
    gap_state = capture_gaps and {
      committed_gap_cursor = ctx.cursor_byte,
      accepted_edge_count = 0,
      current_gap = nil,
    } or nil,
    gap_phase = "I",
    entry_slot = accepted_entry_slot,
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

function M.is_gap_error(value)
  return type(value) == "table" and getmetatable(value) == GAP_ERROR_MT
end

function M.set_gap_phase(ctx, rule_label, phase)
  active_frame(ctx, rule_label).gap_phase = phase
end

function M.install_gap_candidate(ctx, rule_label, match_start_byte)
  local frame = active_frame(ctx, rule_label)
  local gap = frame.gap_state
  if gap == nil then return end
  gap.current_gap = {
    source_id = "input",
    rule_label = rule_label,
    invocation_id = frame.identity.invocation_id,
    edge_ordinal = gap.accepted_edge_count,
    kind = gap.accepted_edge_count == 0 and "prefix" or "interstitial",
    start_byte = gap.committed_gap_cursor,
    end_byte = match_start_byte,
  }
  frame.gap_phase = "selection"
end

function M.commit_gap_candidate(ctx, rule_label)
  local frame = active_frame(ctx, rule_label)
  local gap = frame.gap_state
  local current = gap and gap.current_gap or nil
  local selected = frame.selected_match
  if current == nil or selected == nil then return end
  if ctx.cursor_byte < selected.byte_end then
    gap_error("LINKEDSPEC_SOURCE_LOCATION_ERROR:", "source_location_cursor_regression", {
      phase = "advance",
      rule_label = rule_label,
      source_id = current.source_id,
      start_offset = selected.byte_end,
      end_offset = ctx.cursor_byte,
      originating_edge_or_job = rule_label .. ":capture_gaps_commit",
    })
  end
  gap.committed_gap_cursor = ctx.cursor_byte
  gap.accepted_edge_count = gap.accepted_edge_count + 1
  gap.current_gap = nil
  frame.gap_phase = "post_commit"
end

function M.install_gap_tail(ctx, rule_label, phase)
  local frame = active_frame(ctx, rule_label)
  local gap = frame.gap_state
  if gap == nil then return end
  gap.current_gap = {
    source_id = "input",
    rule_label = rule_label,
    invocation_id = frame.identity.invocation_id,
    edge_ordinal = gap.accepted_edge_count,
    kind = "tail",
    start_byte = gap.committed_gap_cursor,
    end_byte = #ctx.input,
  }
  frame.gap_phase = phase
end

function M.current_gap(ctx, rule_label, accessor)
  local frame = active_frame(ctx, rule_label)
  local current = frame.gap_state and frame.gap_state.current_gap or nil
  if current ~= nil then return copy_gap_context(current) end
  gap_error("LINKEDSPEC_INTER_MATCH_GAP_ERROR:", "gap_capture_context_unavailable", {
    rule_label = rule_label,
    source_id = "input",
    invocation_id = frame.identity.invocation_id,
    phase = frame.gap_phase,
    accessor = accessor,
  })
end

function M.entry_slot(ctx, rule_label)
  local slot = active_frame(ctx, rule_label).entry_slot
  if slot == nil then return json.null end
  return json.harray({
    target_rule = slot.target_rule,
    regex_index = slot.regex_index,
    slot_id = slot.slot_id == nil and json.null or slot.slot_id,
    selector_kind = slot.selector_kind,
    authored_selector = slot.authored_selector == nil and json.null or slot.authored_selector,
  })
end

function M.gap_entry_slot(ctx, rule_label, edge)
  local frame = active_frame(ctx, rule_label)
  if frame.gap_state == nil or frame.gap_state.current_gap == nil then return nil end
  return {
    owner_invocation_id = frame.identity.invocation_id,
    target_rule = edge.targets[1].label,
    regex_index = edge.child_regex_index,
    slot_id = edge.target_slot_id,
    selector_kind = edge.selector_kind,
    authored_selector = edge.authored_selector,
  }
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
    gap_snapshot = copy_gap_state(frame.gap_state),
    gap_phase_snapshot = frame.gap_phase,
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
  frame.gap_state = copy_gap_state(token.gap_snapshot)
  frame.gap_phase = token.gap_phase_snapshot
  frame.tokens[slot] = nil
end

return M
