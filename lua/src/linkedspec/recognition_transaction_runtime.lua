-- Private adapter between the Lua interpreter's live registers and the
-- recognition-transaction authority. This module is intentionally absent
-- from linkedspec/init.lua.

local json = require("linkedspec.json")
local matching = require("linkedspec.matching")
local transaction = require("linkedspec.recognition_transaction")
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
  }
end

function M.leave_invocation(ctx, rule_label)
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
  apply_frame_state(ctx, rule_label, restored)
  ctx.recognition_frames[#ctx.recognition_frames] = nil
  ctx.mark_buckets[rule_label] = frame.prior_marks
  if not ok then error(failure, 0) end
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
