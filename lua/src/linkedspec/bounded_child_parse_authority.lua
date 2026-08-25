-- Private authority for synchronous child parsing over one bounded source span.
--
-- Trusted host code seeds immutable logical entries containing already-compiled
-- callbacks, then starts a fresh invocation over copied decoded sources.
-- Authored execution can select only a logical identity, an allowed top rule,
-- and one exact direct same-source span. This module deliberately owns no
-- syntax, ActionIR node, interpreter carrier, generated format, or rollout.

local json = require("linkedspec.json")
local source_location = require("linkedspec.source_location")

local M = {}

local DEFAULT_ORIGIN = "dispatch_span"
local DISPATCH_EFFECT = "parser_registry_or_staged_dispatch"
local MAX_EXACT_INTEGER = 9007199254740991
local SOURCE_DETAIL = { none = 0, identity = 1, span = 2, text = 3 }
local SOURCE_DETAIL_NAME = { [0] = "none", [1] = "identity", [2] = "span", [3] = "text" }
local LIVE_RESULT_FIELD_TOKENS = {
  "authority",
  "handle",
  "parser",
  "registry",
  "transaction",
  "cancellation",
  "path",
  "source_text",
  "host",
}

local private_state = setmetatable({}, { __mode = "k" })
local token_metatables = {}

local function token_metatable(node_type)
  local current = token_metatables[node_type]
  if current ~= nil then return current end
  current = {
    __metatable = "private " .. node_type,
    __newindex = function() error(node_type .. " is opaque", 2) end,
    __tostring = function(value)
      local state = private_state[value]
      if state ~= nil and state.node_type == "ProgressiveDispatchException" then
        return "LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:" .. state.record.code
      end
      if state ~= nil and state.node_type == "ProgressiveConfigurationException" then
        return "progressive authority configuration: " .. state.message
      end
      if state ~= nil and state.node_type == "ProgressiveSourceViewException" then
        return state.message
      end
      return node_type .. "(<opaque>)"
    end,
  }
  token_metatables[node_type] = current
  return current
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
    error("progressive authority: expected " .. expected_type, 0)
  end
  return state
end

local function raise_configuration(message)
  error(new_token("ProgressiveConfigurationException", { message = message }), 0)
end

local function raise_source_view(message)
  error(new_token("ProgressiveSourceViewException", { message = message }), 0)
end

local function copied_harray(values)
  local result = json.harray()
  for key, value in pairs(values) do result[key] = value end
  return result
end

local function copied_array(values)
  local result = json.array()
  for index = 1, #values do result[index] = values[index] end
  return result
end

local function copy_plain(value, active)
  local value_type = type(value)
  if value == json.null or value_type == "boolean" or value_type == "string" then return value end
  if value_type == "number" then return value end
  if value_type ~= "table" then return tostring(value) end
  active = active or {}
  if active[value] then return "<cycle>" end
  active[value] = true
  local kind = json.kind(value)
  local result
  if kind == "array" then
    result = json.array()
    for index = 1, #value do result[index] = copy_plain(value[index], active) end
  else
    result = json.harray()
    for key, item in pairs(value) do result[tostring(key)] = copy_plain(item, active) end
  end
  active[value] = nil
  return result
end

local function raise_dispatch(code, fields)
  local record = json.harray({ code = code })
  for key, value in pairs(fields or {}) do record[key] = value end
  error(new_token("ProgressiveDispatchException", { record = record }), 0)
end

local function diagnostic_operand(value)
  if value == nil then return "<missing>" end
  local value_type = type(value)
  if value_type == "string" or value_type == "number" or value_type == "boolean" then
    return tostring(value)
  end
  return "<aggregate>"
end

local function options_table(options, operation)
  if type(options) ~= "table" then
    raise_configuration(operation .. " options must be a table")
  end
  return options
end

local function exact_fields(options, allowed, operation)
  for key in pairs(options) do
    if type(key) ~= "string" or not allowed[key] then
      raise_configuration(operation .. " has unsupported field " .. tostring(key))
    end
  end
end

local function is_integer(value)
  return type(value) == "number" and value == math.floor(value) and
    value >= -MAX_EXACT_INTEGER and value <= MAX_EXACT_INTEGER
end

local function dense_array(values)
  if type(values) ~= "table" then return false end
  local count = 0
  for key in pairs(values) do
    if not is_integer(key) or key < 1 or key > #values then return false end
    count = count + 1
  end
  return count == #values
end

local function valid_parser_id(value)
  if type(value) ~= "string" or not value:match("^[a-z]") then return false end
  local previous_separator = false
  for index = 2, #value do
    local byte = value:sub(index, index)
    local alphanumeric = byte:match("^[a-z0-9]$") ~= nil
    local separator = byte == "." or byte == "_" or byte == ":" or byte == "-"
    if not alphanumeric and not separator then return false end
    if separator and previous_separator then return false end
    previous_separator = separator
  end
  return #value > 0 and not previous_separator
end

local function valid_top_rule(value)
  return type(value) == "string" and value:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function valid_fingerprint(value)
  return type(value) == "string" and #value == 71 and
    value:match("^sha256:[0-9a-f]+$") ~= nil
end

local function source_detail_value(value)
  local detail = type(value) == "string" and SOURCE_DETAIL[value] or nil
  if detail == nil then
    raise_configuration("invalid progressive source detail " .. tostring(value))
  end
  return detail
end

local function copy_string_list(values, context, allow_empty)
  if type(values) ~= "table" then raise_configuration(context .. " must be an array") end
  local result = {}
  local seen = {}
  for index = 1, #values do
    local value = values[index]
    if type(value) ~= "string" or value == "" then
      raise_configuration(context .. " must contain nonempty strings")
    end
    if seen[value] then raise_configuration(context .. " must be duplicate-free") end
    seen[value] = true
    result[index] = value
  end
  local count = 0
  for key in pairs(values) do
    if not is_integer(key) or key < 1 or key > #values then
      raise_configuration(context .. " must be a dense array")
    end
    count = count + 1
  end
  if count ~= #values then raise_configuration(context .. " must be a dense array") end
  if #result == 0 and not allow_empty then raise_configuration(context .. " must be nonempty") end
  return result
end

local function sorted_intersection(left, right)
  local present = {}
  for _, value in ipairs(right) do present[value] = true end
  local result = {}
  for _, value in ipairs(left) do
    if present[value] then result[#result + 1] = value end
  end
  table.sort(result)
  return result
end

local function contains(values, expected)
  for _, value in ipairs(values) do if value == expected then return true end end
  return false
end

local function min(left, right)
  if left < right then return left end
  return right
end

local function ceilings_state(value)
  return state_of(value, "ProgressiveCeilings")
end

function M.node_type(value)
  local state = type(value) == "table" and private_state[value] or nil
  return state and state.node_type or nil
end

function M.is_dispatch_error(value)
  return M.node_type(value) == "ProgressiveDispatchException"
end

function M.is_source_view_error(value)
  return M.node_type(value) == "ProgressiveSourceViewException"
end

function M.diagnostic_code(value)
  return state_of(value, "ProgressiveDispatchException").record.code
end

function M.to_json(value)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil then raise_configuration("to_json expects a progressive authority value") end
  if state.node_type == "ProgressiveDispatchException" then
    return copy_plain(state.record)
  end
  if state.node_type == "ProgressiveEffectiveAuthority" then
    return M.effective_to_json(value)
  end
  raise_configuration("to_json does not project " .. state.node_type)
end

function M.ceilings(options)
  options = options_table(options, "ceilings")
  exact_fields(options, {
    source_detail = true,
    policy_modes = true,
    max_steps = true,
    max_result_nodes = true,
    max_diagnostic_bytes = true,
  }, "ceilings")
  local numeric_fields = { "max_steps", "max_result_nodes", "max_diagnostic_bytes" }
  for _, field in ipairs(numeric_fields) do
    if not is_integer(options[field]) or options[field] <= 0 then
      raise_configuration("progressive numeric ceilings must be positive integers")
    end
  end
  return new_token("ProgressiveCeilings", {
    source_detail = source_detail_value(options.source_detail),
    policy_modes = copy_string_list(options.policy_modes, "progressive policy modes", false),
    max_steps = options.max_steps,
    max_result_nodes = options.max_result_nodes,
    max_diagnostic_bytes = options.max_diagnostic_bytes,
  })
end

function M.registry_entry(options)
  options = options_table(options, "registry_entry")
  exact_fields(options, {
    parser_id = true,
    compiled_authority = true,
    fingerprint = true,
    allowed_top_rules = true,
    capabilities = true,
    ceilings = true,
  }, "registry_entry")
  if not valid_parser_id(options.parser_id) then
    raise_configuration("invalid progressive parser identity " .. tostring(options.parser_id))
  end
  if type(options.compiled_authority) ~= "function" then
    raise_configuration("progressive compiled authority must be a callback")
  end
  if not valid_fingerprint(options.fingerprint) then
    raise_configuration("invalid progressive fingerprint for " .. options.parser_id)
  end
  local allowed_top_rules = copy_string_list(
    options.allowed_top_rules,
    "allowed progressive top rules",
    false
  )
  for _, top_rule in ipairs(allowed_top_rules) do
    if not valid_top_rule(top_rule) then
      raise_configuration("invalid allowed top rule for " .. options.parser_id)
    end
  end
  local ceiling = ceilings_state(options.ceilings)
  local policy_modes = {}
  for index, value in ipairs(ceiling.policy_modes) do policy_modes[index] = value end
  return new_token("ProgressiveRegistryEntry", {
    parser_id = options.parser_id,
    compiled_authority = options.compiled_authority,
    fingerprint = options.fingerprint,
    allowed_top_rules = allowed_top_rules,
    capabilities = copy_string_list(options.capabilities, "progressive capabilities", false),
    ceilings = {
      source_detail = ceiling.source_detail,
      policy_modes = policy_modes,
      max_steps = ceiling.max_steps,
      max_result_nodes = ceiling.max_result_nodes,
      max_diagnostic_bytes = ceiling.max_diagnostic_bytes,
    },
  })
end

function M.registry(options)
  options = options_table(options, "registry")
  exact_fields(options, { entries = true }, "registry")
  if not dense_array(options.entries) or #options.entries == 0 then
    raise_configuration("progressive registry must be nonempty")
  end
  local entries = {}
  local identities = {}
  for index = 1, #options.entries do
    local entry = state_of(options.entries[index], "ProgressiveRegistryEntry")
    if identities[entry.parser_id] then
      raise_configuration("duplicate progressive parser identity")
    end
    identities[entry.parser_id] = true
    entries[index] = entry
  end
  return new_token("ProgressiveRegistry", { entries = entries })
end

function M.register(registry, parser_id)
  state_of(registry, "ProgressiveRegistry")
  raise_dispatch("progressive_registry_mutation_forbidden", {
    origin = "registry:register",
    parser_id = diagnostic_operand(parser_id),
  })
end

function M.load(registry, parser_id)
  state_of(registry, "ProgressiveRegistry")
  raise_dispatch("progressive_implicit_load_forbidden", {
    origin = "registry:load",
    parser_id = diagnostic_operand(parser_id),
  })
end

function M.cancellation_token()
  return new_token("ProgressiveCancellationToken", { cancelled = false })
end

function M.cancel(token)
  state_of(token, "ProgressiveCancellationToken").cancelled = true
end

function M.chain_frame(options)
  options = options_table(options, "chain_frame")
  exact_fields(options, {
    parser_id = true,
    top_rule = true,
    source_id = true,
    start = true,
    ["end"] = true,
  }, "chain_frame")
  if not valid_parser_id(options.parser_id) or not valid_top_rule(options.top_rule) or
      type(options.source_id) ~= "string" or options.source_id == "" or
      not is_integer(options.start) or options.start < 0 or
      not is_integer(options["end"]) or options["end"] < 0 then
    raise_configuration("invalid progressive active-chain identity")
  end
  return new_token("ProgressiveChainFrame", {
    parser_id = options.parser_id,
    top_rule = options.top_rule,
    source_id = options.source_id,
    start = options.start,
    ["end"] = options["end"],
  })
end

local function copy_sources(values)
  if type(values) ~= "table" then raise_configuration("progressive sources must be an object") end
  local result = {}
  local count = 0
  for source_id, text in pairs(values) do
    if type(source_id) ~= "string" or source_id == "" or type(text) ~= "string" then
      raise_configuration("progressive decoded sources must map nonempty identities to strings")
    end
    result[source_id] = text
    count = count + 1
  end
  if count == 0 then raise_configuration("progressive invocation requires decoded sources") end
  return result
end

function M.start_invocation(registry_value, options)
  local registry = state_of(registry_value, "ProgressiveRegistry")
  options = options_table(options, "start_invocation")
  exact_fields(options, {
    sources = true,
    source_id = true,
    cancellation_token = true,
    now = true,
    deadline_tick = true,
    remaining_steps = true,
    max_depth = true,
    total_calls = true,
    max_calls = true,
    active_chain = true,
  }, "start_invocation")
  local sources = copy_sources(options.sources)
  if type(options.source_id) ~= "string" or options.source_id == "" or
      sources[options.source_id] == nil then
    raise_configuration("progressive invocation source is unavailable")
  end
  state_of(options.cancellation_token, "ProgressiveCancellationToken")
  if type(options.now) ~= "function" then raise_configuration("progressive clock must be a callback") end
  if not is_integer(options.deadline_tick) or options.deadline_tick < 0 or
      not is_integer(options.remaining_steps) or options.remaining_steps < 0 or
      not is_integer(options.max_depth) or options.max_depth <= 0 or
      not is_integer(options.total_calls) or options.total_calls < 0 or
      not is_integer(options.max_calls) or options.max_calls <= 0 then
    raise_configuration("progressive invocation limits are invalid")
  end
  local source_authority = source_location.source_authority({ sources = sources })
  local active_chain = {}
  if not dense_array(options.active_chain) then
    raise_configuration("progressive active chain must be an array")
  end
  for index = 1, #options.active_chain do
    local frame = state_of(options.active_chain[index], "ProgressiveChainFrame")
    local source_length = source_location.source_scalar_length(source_authority, frame.source_id)
    if source_length == nil or frame.start > frame["end"] or frame["end"] > source_length then
      raise_configuration("progressive active-chain span is invalid")
    end
    active_chain[index] = {
      parser_id = frame.parser_id,
      top_rule = frame.top_rule,
      source_id = frame.source_id,
      start = frame.start,
      ["end"] = frame["end"],
    }
  end
  return new_token("ProgressiveInvocation", {
    registry = registry,
    source_authority = source_authority,
    source_id = options.source_id,
    cancellation_token = options.cancellation_token,
    now = options.now,
    deadline_tick = options.deadline_tick,
    remaining_steps = options.remaining_steps,
    max_depth = options.max_depth,
    total_calls = options.total_calls,
    max_calls = options.max_calls,
    active_chain = active_chain,
  })
end

function M.remaining_steps(invocation)
  return state_of(invocation, "ProgressiveInvocation").remaining_steps
end

function M.total_calls(invocation)
  return state_of(invocation, "ProgressiveInvocation").total_calls
end

local function parse_span(value, origin)
  if type(value) ~= "table" then
    raise_dispatch("progressive_span_binding_required", {
      origin = origin,
      operand = diagnostic_operand(value),
    })
  end
  local fields = {}
  for key in pairs(value) do fields[#fields + 1] = tostring(key) end
  table.sort(fields)
  local field_text = table.concat(fields, ",")
  local valid = json.kind(value) == "harray" and field_text == "end,provenance,source_id,start" and
    type(value.source_id) == "string" and value.source_id ~= "" and
    is_integer(value.start) and value.start >= 0 and
    is_integer(value["end"]) and value["end"] >= 0 and
    type(value.provenance) == "string" and value.provenance ~= ""
  if not valid then
    raise_dispatch("progressive_span_shape_invalid", { origin = origin, fields = field_text })
  end
  return {
    source_id = value.source_id,
    start = value.start,
    ["end"] = value["end"],
    provenance = value.provenance,
  }
end

local function find_entry(registry, parser_id)
  for _, entry in ipairs(registry.entries) do
    if entry.parser_id == parser_id then return entry end
  end
  return nil
end

local function effective_authority(entry, options, origin)
  local caller_capabilities = copy_string_list(
    options.caller_capabilities,
    "progressive caller capabilities",
    false
  )
  local required_capabilities = copy_string_list(
    options.required_capabilities,
    "progressive required capabilities",
    true
  )
  local caller_ceilings = ceilings_state(options.caller_ceilings)
  local capabilities = sorted_intersection(entry.capabilities, caller_capabilities)
  for _, required in ipairs(required_capabilities) do
    if not contains(capabilities, required) then
      raise_dispatch("progressive_capability_denied", {
        origin = origin,
        parser_id = entry.parser_id,
        capability = required,
      })
    end
  end
  local policy_modes = sorted_intersection(caller_ceilings.policy_modes, entry.ceilings.policy_modes)
  if #policy_modes == 0 then
    raise_dispatch("progressive_policy_denied", {
      origin = origin,
      parser_id = entry.parser_id,
      policy = table.concat(caller_ceilings.policy_modes, ","),
    })
  end
  local source_detail = min(caller_ceilings.source_detail, entry.ceilings.source_detail)
  local required_source_detail = source_detail_value(options.required_source_detail)
  if source_detail < required_source_detail then
    raise_dispatch("progressive_source_detail_denied", {
      origin = origin,
      required = SOURCE_DETAIL_NAME[required_source_detail],
      effective = SOURCE_DETAIL_NAME[source_detail],
    })
  end
  return new_token("ProgressiveEffectiveAuthority", {
    capabilities = capabilities,
    source_detail = source_detail,
    policy_modes = policy_modes,
    max_steps = min(caller_ceilings.max_steps, entry.ceilings.max_steps),
    max_result_nodes = min(caller_ceilings.max_result_nodes, entry.ceilings.max_result_nodes),
    max_diagnostic_bytes = min(
      caller_ceilings.max_diagnostic_bytes,
      entry.ceilings.max_diagnostic_bytes
    ),
  })
end

function M.effective_to_json(value)
  local effective = state_of(value, "ProgressiveEffectiveAuthority")
  return json.harray({
    capabilities = copied_array(effective.capabilities),
    source_detail = SOURCE_DETAIL_NAME[effective.source_detail],
    policy_modes = copied_array(effective.policy_modes),
    max_steps = effective.max_steps,
    max_result_nodes = effective.max_result_nodes,
    max_diagnostic_bytes = effective.max_diagnostic_bytes,
  })
end

local function check_chain(invocation, parser_id, top_rule, span, origin)
  if #invocation.active_chain >= invocation.max_depth then
    raise_dispatch("progressive_depth_exceeded", {
      origin = origin,
      depth = #invocation.active_chain,
      maximum = invocation.max_depth,
    })
  end
  if invocation.total_calls >= invocation.max_calls then
    raise_dispatch("progressive_call_limit_exceeded", {
      origin = origin,
      calls = invocation.total_calls,
      maximum = invocation.max_calls,
    })
  end
  for _, active in ipairs(invocation.active_chain) do
    if active.parser_id == parser_id and active.top_rule == top_rule and
        active.source_id == span.source_id then
      local contained = active.start <= span.start and span.start <= span["end"] and
        span["end"] <= active["end"]
      local smaller = span["end"] - span.start < active["end"] - active.start
      if not contained or not smaller then
        raise_dispatch("progressive_cycle_non_decreasing", {
          origin = origin,
          parser_id = parser_id,
          top_rule = top_rule,
          source_id = span.source_id,
          span = tostring(span.start) .. ":" .. tostring(span["end"]),
          active_span = tostring(active.start) .. ":" .. tostring(active["end"]),
        })
      end
    end
  end
end

local function now_tick(invocation)
  local value = invocation.now()
  if not is_integer(value) then raise_configuration("progressive clock returned a noninteger tick") end
  return value
end

local function check_cancellation_and_deadline(invocation, parser_id, origin)
  if state_of(invocation.cancellation_token, "ProgressiveCancellationToken").cancelled then
    raise_dispatch("progressive_cancelled", { origin = origin, parser_id = parser_id })
  end
  if now_tick(invocation) >= invocation.deadline_tick then
    raise_dispatch("progressive_deadline_exceeded", {
      origin = origin,
      parser_id = parser_id,
      deadline = invocation.deadline_tick,
    })
  end
end

local function check_safe_point(invocation, options, parser_id, effective, origin)
  state_of(options.child_token, "ProgressiveCancellationToken")
  if options.child_token ~= invocation.cancellation_token then
    raise_dispatch("progressive_cancellation_authority_mismatch", {
      origin = origin,
      parser_id = parser_id,
    })
  end
  check_cancellation_and_deadline(invocation, parser_id, origin)
  if not is_integer(options.cost) then
    raise_configuration("progressive dispatch cost must be an integer")
  end
  local effective_state = state_of(effective, "ProgressiveEffectiveAuthority")
  if options.cost < 0 or invocation.remaining_steps == 0 or
      options.cost > invocation.remaining_steps or options.cost > effective_state.max_steps then
    raise_dispatch("progressive_budget_exhausted", {
      origin = origin,
      parser_id = parser_id,
      remaining = min(invocation.remaining_steps, effective_state.max_steps),
    })
  end
end

local function source_mismatch(origin, expected, actual)
  raise_dispatch("progressive_span_source_mismatch", {
    origin = origin,
    expected_source_id = expected,
    actual_source_id = actual,
  })
end

local function out_of_bounds(origin, source_id, start_offset, end_offset, source_length)
  raise_dispatch("progressive_span_out_of_bounds", {
    origin = origin,
    source_id = source_id,
    start = start_offset,
    ["end"] = end_offset,
    source_length = source_length,
  })
end

local function reversed(origin, span)
  raise_dispatch("progressive_span_reversed", {
    origin = origin,
    source_id = span.source_id,
    start = span.start,
    ["end"] = span["end"],
  })
end

local function ensure_view_active(view)
  local state = state_of(view, "ProgressiveSourceView")
  if not state.active then
    raise_source_view("progressive source view is outside child execution")
  end
  return state
end

local function ensure_local_offset(view, offset)
  local state = ensure_view_active(view)
  local length = state["end"] - state.start
  if not is_integer(offset) or offset < 0 or offset > length then
    out_of_bounds(state.origin, state.source_id, offset, offset, length)
  end
  return state
end

local function location_context(view_state)
  return source_location.source_location_context({
    rule_role = "progressive_child",
    invocation_role = view_state.origin,
  })
end

function M.request_source_view(request)
  return state_of(request, "ProgressiveDispatchRequest").source_view
end

function M.request_effective(request)
  return state_of(request, "ProgressiveDispatchRequest").effective
end

function M.request_parser_id(request)
  return state_of(request, "ProgressiveDispatchRequest").parser_id
end

function M.request_top_rule(request)
  return state_of(request, "ProgressiveDispatchRequest").top_rule
end

function M.request_fingerprint(request)
  return state_of(request, "ProgressiveDispatchRequest").fingerprint
end

function M.request_cancellation_token(request)
  return state_of(request, "ProgressiveDispatchRequest").cancellation_token
end

function M.request_deadline_tick(request)
  return state_of(request, "ProgressiveDispatchRequest").deadline_tick
end

function M.request_remaining_steps(request)
  return state_of(request, "ProgressiveDispatchRequest").remaining_steps
end

function M.dispatch_nested(request, options)
  local request_state = state_of(request, "ProgressiveDispatchRequest")
  ensure_view_active(request_state.source_view)
  return M.dispatch(request_state.invocation_token, options)
end

function M.view_text(view)
  return ensure_view_active(view).text
end

function M.view_source_id(view)
  return ensure_view_active(view).source_id
end

function M.view_provenance(view)
  return ensure_view_active(view).provenance
end

function M.view_scalar_length(view)
  local state = ensure_view_active(view)
  return state["end"] - state.start
end

function M.local_to_global(view, offset)
  local state = ensure_local_offset(view, offset)
  return state.start + offset
end

function M.rebase_position(view, offset)
  local state = ensure_local_offset(view, offset)
  local position = source_location.position(state.source_authority, {
    source_id = state.source_id,
    offset = state.start + offset,
    context = location_context(state),
  })
  return source_location.to_json(position)
end

function M.rebase_span(view, value)
  local state = ensure_view_active(view)
  local span = parse_span(value, state.origin)
  if span.source_id ~= state.source_id then
    source_mismatch(state.origin, state.source_id, span.source_id)
  end
  ensure_local_offset(view, span.start)
  ensure_local_offset(view, span["end"])
  if span.start > span["end"] then reversed(state.origin, span) end
  local context = location_context(state)
  local start_position = source_location.position(state.source_authority, {
    source_id = state.source_id,
    offset = state.start + span.start,
    context = context,
  })
  local end_position = source_location.position(state.source_authority, {
    source_id = state.source_id,
    offset = state.start + span["end"],
    context = context,
  })
  return source_location.to_json(source_location.direct_span(state.source_authority, {
    start = start_position,
    ["end"] = end_position,
    provenance = span.provenance,
    context = context,
  }))
end

local function is_offset_field(key)
  return key == "offset" or key == "start" or key == "end" or
    key:sub(-7) == "_offset" or key:sub(-6) == "_start" or key:sub(-4) == "_end"
end

local function detach_diagnostic(value, active)
  local value_type = type(value)
  if value == json.null or value_type == "boolean" or value_type == "string" then return value end
  if value_type == "number" and value == value and value ~= math.huge and value ~= -math.huge then return value end
  if value_type ~= "table" then raise_source_view("diagnostic contains non-detached data") end
  active = active or {}
  if active[value] then raise_source_view("diagnostic contains cyclic data") end
  active[value] = true
  local kind = json.kind(value)
  local result
  if kind == "array" then
    if not dense_array(value) then raise_source_view("diagnostic contains non-detached data") end
    result = json.array()
    for index = 1, #value do result[index] = detach_diagnostic(value[index], active) end
  elseif kind == "harray" then
    result = json.harray()
    for key, item in pairs(value) do
      if type(key) ~= "string" then raise_source_view("diagnostic keys must be strings") end
      result[key] = detach_diagnostic(item, active)
    end
  else
    raise_source_view("diagnostic contains non-detached data")
  end
  active[value] = nil
  return result
end

function M.rebase_diagnostic(view, value)
  local state = ensure_view_active(view)
  if json.kind(value) ~= "harray" then raise_source_view("diagnostic must be an object") end
  local result = json.harray()
  for key, item in pairs(value) do
    if key == "span" and json.kind(item) == "harray" then
      result[key] = M.rebase_span(view, item)
    elseif is_offset_field(key) and is_integer(item) then
      result[key] = M.local_to_global(view, item)
    else
      result[key] = detach_diagnostic(item)
    end
  end
  result.source_id = state.source_id
  if #json.encode(result) > state.diagnostic_ceiling then
    raise_source_view("rebased diagnostic exceeds its effective byte ceiling")
  end
  return result
end

local function utf8_width(first_byte)
  if first_byte <= 0x7F then return 1 end
  if first_byte <= 0xDF then return 2 end
  if first_byte <= 0xEF then return 3 end
  if first_byte <= 0xF4 then return 4 end
  return 1
end

local function truncate_utf8(value, maximum)
  if #value <= maximum then return value end
  local index = 1
  local last = 0
  while index <= #value do
    local width = utf8_width(value:byte(index))
    if index - 1 + width > maximum then break end
    last = index + width - 1
    index = index + width
  end
  return value:sub(1, last)
end

local function live_field(key)
  local lowered = key:lower()
  for _, token in ipairs(LIVE_RESULT_FIELD_TOKENS) do
    if lowered:find(token, 1, true) then return true end
  end
  return false
end

local function detach_result(value, parser_id, origin, maximum)
  local nodes = 0
  local active = {}
  local function reject(path)
    raise_dispatch("progressive_result_not_detached", {
      origin = origin,
      parser_id = parser_id,
      field = path,
    })
  end
  local function visit(current, path)
    nodes = nodes + 1
    if nodes > maximum then reject(path) end
    local current_type = type(current)
    if current == json.null or current_type == "boolean" or current_type == "string" then return current end
    if current_type == "number" then
      if current ~= current or current == math.huge or current == -math.huge then reject(path) end
      return current
    end
    if current_type ~= "table" or active[current] then reject(path) end
    active[current] = true
    local kind = json.kind(current)
    local result
    if kind == "array" then
      if not dense_array(current) then reject(path) end
      result = json.array()
      for index = 1, #current do
        result[index] = visit(current[index], path .. "/" .. tostring(index - 1))
      end
    elseif kind == "harray" then
      result = json.harray()
      for key, item in pairs(current) do
        if type(key) ~= "string" or live_field(key) then reject(path .. "/" .. tostring(key)) end
        result[key] = visit(item, path .. "/" .. key)
      end
    else
      reject(path)
    end
    active[current] = nil
    return result
  end
  return visit(value, "<result>")
end

local function parent_location_context(origin)
  return source_location.source_location_context({
    rule_role = "progressive_parent",
    invocation_role = origin,
  })
end

function M.dispatch(invocation_value, options)
  local invocation = state_of(invocation_value, "ProgressiveInvocation")
  options = options_table(options, "dispatch")
  exact_fields(options, {
    origin = true,
    parser_id = true,
    top_rule = true,
    span = true,
    caller_capabilities = true,
    required_capabilities = true,
    caller_ceilings = true,
    required_source_detail = true,
    child_token = true,
    cost = true,
    transaction_active = true,
  }, "dispatch")
  local origin = type(options.origin) == "string" and options.origin ~= "" and options.origin or DEFAULT_ORIGIN
  if type(options.parser_id) ~= "string" or options.parser_id == "" then
    raise_dispatch("progressive_parser_identity_literal_required", {
      origin = origin,
      operand = diagnostic_operand(options.parser_id),
    })
  end
  local parser_id = options.parser_id
  if not valid_parser_id(parser_id) then
    raise_dispatch("progressive_parser_identity_invalid", { origin = origin, parser_id = parser_id })
  end
  if type(options.top_rule) ~= "string" or options.top_rule == "" then
    raise_dispatch("progressive_top_rule_literal_required", {
      origin = origin,
      operand = diagnostic_operand(options.top_rule),
    })
  end
  local top_rule = options.top_rule
  if not valid_top_rule(top_rule) then
    raise_dispatch("progressive_top_rule_invalid", { origin = origin, top_rule = top_rule })
  end
  local span = parse_span(options.span, origin)
  if span.source_id ~= invocation.source_id then
    source_mismatch(origin, invocation.source_id, span.source_id)
  end
  local source_length = source_location.source_scalar_length(
    invocation.source_authority,
    span.source_id
  ) or 0
  if span["end"] > source_length then
    out_of_bounds(origin, span.source_id, span.start, span["end"], source_length)
  end
  if span.start > span["end"] then reversed(origin, span) end
  if options.transaction_active then
    raise_dispatch("progressive_transaction_forbidden", {
      origin = origin,
      effect = DISPATCH_EFFECT,
    })
  end
  local entry = find_entry(invocation.registry, parser_id)
  if entry == nil then
    raise_dispatch("progressive_registry_missing", { origin = origin, parser_id = parser_id })
  end
  if not contains(entry.allowed_top_rules, top_rule) then
    raise_dispatch("progressive_top_rule_forbidden", {
      origin = origin,
      parser_id = parser_id,
      top_rule = top_rule,
    })
  end
  local effective = effective_authority(entry, options, origin)
  check_chain(invocation, parser_id, top_rule, span, origin)
  check_safe_point(invocation, options, parser_id, effective, origin)

  invocation.total_calls = invocation.total_calls + 1
  invocation.remaining_steps = invocation.remaining_steps - options.cost
  local context = parent_location_context(origin)
  local start_position = source_location.position(invocation.source_authority, {
    source_id = span.source_id,
    offset = span.start,
    context = context,
  })
  local end_position = source_location.position(invocation.source_authority, {
    source_id = span.source_id,
    offset = span["end"],
    context = context,
  })
  local typed_span = source_location.direct_span(invocation.source_authority, {
    start = start_position,
    ["end"] = end_position,
    provenance = span.provenance,
    context = context,
  })
  local effective_state = state_of(effective, "ProgressiveEffectiveAuthority")
  local source_view = new_token("ProgressiveSourceView", {
    active = true,
    source_authority = invocation.source_authority,
    source_id = span.source_id,
    text = source_location.materialize(invocation.source_authority, typed_span, { context = context }),
    start = span.start,
    ["end"] = span["end"],
    provenance = span.provenance,
    origin = origin,
    diagnostic_ceiling = effective_state.max_diagnostic_bytes,
  })
  invocation.active_chain[#invocation.active_chain + 1] = {
    parser_id = parser_id,
    top_rule = top_rule,
    source_id = span.source_id,
    start = span.start,
    ["end"] = span["end"],
  }
  local request = new_token("ProgressiveDispatchRequest", {
    parser_id = parser_id,
    top_rule = top_rule,
    fingerprint = entry.fingerprint,
    source_view = source_view,
    effective = effective,
    cancellation_token = invocation.cancellation_token,
    deadline_tick = invocation.deadline_tick,
    remaining_steps = min(
      invocation.remaining_steps,
      math.max(0, effective_state.max_steps - options.cost)
    ),
    invocation_token = invocation_value,
  })

  local child_ok, child_result = pcall(entry.compiled_authority, request)
  invocation.active_chain[#invocation.active_chain] = nil
  state_of(source_view, "ProgressiveSourceView").active = false
  if not child_ok or child_result == nil then
    local diagnostic = child_ok and "<null child result>" or tostring(child_result)
    local bounded = truncate_utf8(diagnostic, effective_state.max_diagnostic_bytes)
    if bounded == "" then bounded = "?" end
    raise_dispatch("progressive_child_failed", {
      origin = origin,
      parser_id = parser_id,
      top_rule = top_rule,
      source_id = span.source_id,
      span = tostring(span.start) .. ":" .. tostring(span["end"]),
      child_diagnostic = bounded,
    })
  end
  check_cancellation_and_deadline(invocation, parser_id, origin)
  return detach_result(child_result, parser_id, origin, effective_state.max_result_nodes)
end

function M.missing_registry_exception(options)
  options = options_table(options, "missing_registry_exception")
  if type(options.origin) ~= "string" or type(options.parser_id) ~= "string" then
    raise_configuration("missing_registry_exception requires string origin and parser_id")
  end
  local record = json.harray({
    code = "progressive_registry_missing",
    origin = options.origin,
    parser_id = options.parser_id,
  })
  return new_token("ProgressiveDispatchException", { record = record })
end

return M
