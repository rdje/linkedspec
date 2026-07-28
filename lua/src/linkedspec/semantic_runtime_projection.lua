-- Package-private immutable observed-runtime projection for Lua semantic
-- introspection. This module receives exactly one detached static projection
-- and exact protected event handles. It never receives source/compiler/runtime
-- authority and never parses, compiles, executes, hashes, traces, or reads IO.

local json = require("linkedspec.json")
local observation = require("linkedspec.semantic_observation")
local static_projection = require("linkedspec.semantic_static_projection")

local M = {}

local SPEC_ID = "spec:0"
local EXECUTION_ID = "execution:0"

local function invalid(fail, message)
  fail("execution_observation", "semantic_index_invalid_observation", message)
end

local function portable(value)
  return value == nil and json.null or value
end

local function record(id, kind, name, owner_id, order, source, facts)
  return json.harray({
    id = id,
    kind = kind,
    name = portable(name),
    owner_id = portable(owner_id),
    order = order,
    source = portable(source),
    facts = facts,
    redactions = json.array(),
  })
end

local function relation(kind, from_id, to_id, order, source, evidence_id)
  return json.harray({
    id = "relation:" .. kind .. ":" .. from_id .. ":" .. to_id .. ":" .. order,
    kind = kind,
    from_id = from_id,
    to_id = to_id,
    order = order,
    source = portable(source),
    facts = json.harray(),
    evidence_ids = json.array({ evidence_id }),
  })
end

local function finite_integer(value)
  return type(value) == "number" and value == value and value ~= math.huge and
    value ~= -math.huge and value == math.floor(value)
end

local function portable_label(value)
  if type(value) ~= "string" or value == "" then return false end
  return json.validate_utf8(value)
end

local function stable_input_identity(value)
  local prefix = "input:sha256:"
  return type(value) == "string" and #value == #prefix + 64 and
    value:match("^input:sha256:[0-9a-f]+$") ~= nil
end

local function dense_event_json(events, fail)
  if type(events) ~= "table" then
    invalid(fail, "Execution observation must be a dense sequence of typed events")
  end
  local kind = json.kind(events)
  if kind ~= "table" and kind ~= "array" then
    invalid(fail, "Execution observation must be a dense sequence of typed events")
  end
  if kind == "table" and getmetatable(events) ~= nil then
    invalid(fail, "Execution observation must not carry host metatable authority")
  end
  local count = 0
  local maximum = 0
  for key in next, events do
    if not finite_integer(key) or key < 1 then
      invalid(fail, "Execution observation sequence keys must be positive integers")
    end
    count = count + 1
    if key > maximum then maximum = key end
  end
  if count == 0 then
    invalid(fail, "Execution observation must contain at least one event")
  end
  if maximum ~= count then
    invalid(fail, "Execution observation sequence must not contain gaps")
  end
  local result = json.array()
  for index = 1, count do
    local event = events[index]
    if not observation.is_event(event) then
      invalid(fail, "Execution observation contains a non-event value")
    end
    result[index] = observation.to_json(event)
  end
  return result
end

local function validate_event(value, fail)
  if value.contract_id ~= observation.CONTRACT_ID then
    invalid(fail, "Execution observation event contract is unsupported")
  end
  if not portable_label(value.rule_label) then
    invalid(fail, "Execution observation rule label is missing or invalid")
  end
  if not finite_integer(value.position) or value.position < 0 then
    invalid(fail, "Execution observation position must be a nonnegative integer")
  end
  if value.event_kind == observation.REGEX_SLOT_SELECTED then
    if not portable_label(value.target_rule) then
      invalid(fail, "Regex-slot observation target rule is missing or invalid")
    end
    if not finite_integer(value.regex_index) or value.regex_index < 0 then
      invalid(fail, "Regex-slot observation index must be a nonnegative integer")
    end
    if value.input_identity ~= json.null or value.status ~= json.null then
      invalid(fail, "Regex-slot observation cannot carry result identity or status")
    end
  elseif value.event_kind == observation.RULE_RESULT then
    if value.target_rule ~= json.null or value.regex_index ~= json.null then
      invalid(fail, "Rule-result observation cannot carry regex-slot identity")
    end
    if value.status ~= "succeeded" then
      invalid(fail, "Final rule-result observation must report succeeded status")
    end
    if not stable_input_identity(value.input_identity) then
      invalid(fail, "Final rule-result observation must carry a stable input identity")
    end
  else
    invalid(fail, "Execution observation event kind is unsupported")
  end
end

local function required_shape(value, fail, message)
  local facts = type(value) == "table" and value.facts or nil
  local shape = type(facts) == "table" and facts.value_shape or nil
  if type(shape) ~= "table" or json.kind(shape) ~= "harray" then invalid(fail, message) end
  return shape
end

local function maps_for(projection)
  local record_by_id = {}
  local rule_by_name = {}
  for _, item in ipairs(projection.records) do
    record_by_id[item.id] = item
    if item.kind == "rule" and type(item.name) == "string" then
      rule_by_name[item.name] = item
    end
  end
  local slot_by_rule = {}
  for _, item in ipairs(projection.records) do
    if item.kind == "regex_slot" then
      local owner = record_by_id[item.owner_id]
      if owner ~= nil and type(owner.name) == "string" and finite_integer(item.order) then
        local slots = slot_by_rule[owner.name]
        if slots == nil then
          slots = {}
          slot_by_rule[owner.name] = slots
        end
        slots[item.order] = item
      end
    end
  end
  local edge_for_selection = {}
  for _, item in ipairs(projection.relations) do
    if item.kind == "selects_regex" then
      local edge = record_by_id[item.from_id]
      if edge ~= nil and edge.kind == "edge" and type(edge.owner_id) == "string" and
          type(item.to_id) == "string" then
        local selections = edge_for_selection[edge.owner_id]
        if selections == nil then
          selections = {}
          edge_for_selection[edge.owner_id] = selections
        end
        if selections[item.to_id] == nil then selections[item.to_id] = edge end
      end
    end
  end
  return record_by_id, rule_by_name, slot_by_rule, edge_for_selection
end

function M.derive(projection, events, fail)
  if type(projection) ~= "table" or type(projection.snapshot) ~= "table" or
      projection.snapshot.state ~= "compiled" or projection.snapshot.has_execution ~= false then
    invalid(fail, "Execution observations require a compiled static semantic snapshot")
  end
  local observed = dense_event_json(events, fail)
  local result_count = 0
  for _, event in ipairs(observed) do
    validate_event(event, fail)
    if event.event_kind == observation.RULE_RESULT then result_count = result_count + 1 end
  end
  if result_count ~= 1 or observed[#observed].event_kind ~= observation.RULE_RESULT then
    invalid(fail, "Completed execution observation must contain exactly one final rule result")
  end

  local record_by_id, rule_by_name, slot_by_rule, edge_for_selection = maps_for(projection)
  local final = observed[#observed]
  local result_rule = rule_by_name[final.rule_label]
  if result_rule == nil then
    invalid(fail, "Observed result rule '" .. final.rule_label .. "' does not exist in the semantic index")
  end
  local spec = record_by_id[SPEC_ID]
  if spec == nil or type(spec.facts) ~= "table" then
    invalid(fail, "Static semantic projection has no spec record")
  end
  if spec.facts.entry_rule_id ~= result_rule.id then
    invalid(fail, "Observed final result does not belong to the selected entry rule")
  end
  local result_shape = required_shape(result_rule, fail, "Final result rule has no value shape")

  projection.records[#projection.records + 1] = record(
    EXECUTION_ID,
    "execution",
    "caller observation",
    SPEC_ID,
    0,
    nil,
    json.harray({
      input_identity = final.input_identity,
      status = "succeeded",
      result_shape = result_shape,
    })
  )

  for index, event in ipairs(observed) do
    local order = index - 1
    local name
    local source
    local shape
    local evidence_id
    if event.event_kind == observation.REGEX_SLOT_SELECTED then
      local selecting_rule = rule_by_name[event.rule_label]
      if selecting_rule == nil then
        invalid(fail, "Observed selecting rule '" .. event.rule_label ..
          "' does not exist in the semantic index")
      end
      local slots = slot_by_rule[event.target_rule]
      local slot = slots ~= nil and slots[event.regex_index] or nil
      if slot == nil then
        invalid(fail, "Observed regex slot '" .. event.target_rule .. "[" .. event.regex_index ..
          "]' does not exist in the semantic index")
      end
      local selections = edge_for_selection[selecting_rule.id]
      local edge = selections ~= nil and selections[slot.id] or nil
      if edge == nil then
        invalid(fail, "Observed selecting rule '" .. event.rule_label ..
          "' does not select regex slot '" .. event.target_rule .. "[" .. event.regex_index .. "]'")
      end
      name = "slot selected"
      source = slot.source == json.null and nil or slot.source
      shape = required_shape(edge, fail, "Observed selection edge has no value shape")
      evidence_id = slot.id
    else
      if index ~= #observed then
        invalid(fail, "Rule-result event must be the final observation event")
      end
      name = "rule result"
      source = result_rule.source == json.null and nil or result_rule.source
      shape = result_shape
      evidence_id = result_rule.id
    end
    local event_id = "event:" .. EXECUTION_ID .. ":" .. order
    projection.records[#projection.records + 1] = record(
      event_id,
      "event",
      name,
      EXECUTION_ID,
      order,
      source,
      json.harray({
        event_kind = event.event_kind,
        position = event.position,
        value_shape = shape,
      })
    )
    projection.relations[#projection.relations + 1] = relation(
      "observed_as", EXECUTION_ID, event_id, order, source, evidence_id
    )
  end

  projection.snapshot.has_execution = true
  return static_projection._freeze_derived_projection(projection, fail)
end

return M
