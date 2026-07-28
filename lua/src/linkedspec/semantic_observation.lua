-- Invocation-local typed runtime semantic observation for the Lua backend.
-- Event construction and sink-failure carriers stay package-internal; callers
-- receive protected immutable handles and detached JSON projections.

local json = require("linkedspec.json")
local sha256 = require("linkedspec.sha256")

local M = {}

M.CONTRACT_ID = "linkedspec-semantic-execution-observation-v1"
M.REGEX_SLOT_SELECTED = "regex_slot_selected"
M.RULE_RESULT = "rule_result"

local EVENT_STATE = setmetatable({}, { __mode = "k" })
local SINK_FAILURE_STATE = setmetatable({}, { __mode = "k" })

local function empty_pairs()
  return function() return nil end, nil, nil
end

local function immutable_newindex()
  error("Runtime semantic observation events are immutable", 0)
end

local EVENT_MT = {
  __index = function(value, key)
    local state = EVENT_STATE[value]
    return state == nil and nil or state[key]
  end,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function() return "RuntimeSemanticObservationEvent" end,
}

local SINK_FAILURE_MT = {
  __metatable = "protected",
  __tostring = function() return "RuntimeSemanticObservationSinkFailure" end,
}

local function event(fields, use_default_contract)
  local result = setmetatable({}, EVENT_MT)
  EVENT_STATE[result] = {
    contract_id = use_default_contract and M.CONTRACT_ID or fields.contract_id,
    event_kind = fields.event_kind,
    rule_label = fields.rule_label,
    target_rule = fields.target_rule,
    regex_index = fields.regex_index,
    position = fields.position,
    input_identity = fields.input_identity,
    status = fields.status,
  }
  return result
end

-- Package-private malformed-event constructor for derivation boundary tests.
-- The root module deliberately does not export this seam.
function M._event_for_testing(fields)
  if type(fields) ~= "table" then error("event fields must be a table", 0) end
  return event(fields, false)
end

function M.regex_slot_selected(rule_label, target_rule, regex_index, position)
  return event({
    event_kind = M.REGEX_SLOT_SELECTED,
    rule_label = rule_label,
    target_rule = target_rule,
    regex_index = regex_index,
    position = position,
  }, true)
end

function M.rule_result(rule_label, position, input)
  return event({
    event_kind = M.RULE_RESULT,
    rule_label = rule_label,
    position = position,
    input_identity = "input:sha256:" .. sha256.hex(input),
    status = "succeeded",
  }, true)
end

function M.is_event(value)
  return type(value) == "table" and EVENT_STATE[value] ~= nil
end

function M.to_json(value)
  local state = EVENT_STATE[value]
  if state == nil then error("expected RuntimeSemanticObservationEvent", 0) end
  return json.harray({
    contract_id = state.contract_id,
    event_kind = state.event_kind,
    rule_label = state.rule_label,
    target_rule = state.target_rule == nil and json.null or state.target_rule,
    regex_index = state.regex_index == nil and json.null or state.regex_index,
    position = state.position,
    input_identity = state.input_identity == nil and json.null or state.input_identity,
    status = state.status == nil and json.null or state.status,
  })
end

function M.deliver(sink, value)
  local delivered, failure = pcall(sink, value)
  if delivered then return end
  local carrier = setmetatable({}, SINK_FAILURE_MT)
  SINK_FAILURE_STATE[carrier] = { value = failure }
  error(carrier, 0)
end

function M.is_sink_failure(value)
  return type(value) == "table" and SINK_FAILURE_STATE[value] ~= nil
end

function M.sink_failure_value(value)
  local state = SINK_FAILURE_STATE[value]
  return state == nil and nil or state.value
end

return M
