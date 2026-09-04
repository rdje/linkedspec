-- Package-private immutable static semantic projection.
--
-- This module consumes only the source map and the parsed/compiled/entry
-- authorities already retained by semantic_index. It reparses only an exact
-- retained staged function-body payload to recover typed ActionIR after proving
-- sidecar equality; it never reparses the .spec, compiles, selects, plans,
-- emits, loads, executes, traces, or observes anything.

local action_ast = require("linkedspec.action_ast")
local action_contracts = require("linkedspec.action_contracts")
local action_parser = require("linkedspec.action_parser")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")

local M = {}

local SPEC_ID = "spec:0"
local SOURCE_ID = "source:0"

local CALL_HELPERS = {
  trim = {
    parameters = { { "value", "value" } },
    effects = {},
    return_kind = "string",
  },
  match_text = {
    parameters = {},
    effects = { "reads_runtime_match" },
    return_kind = "string",
  },
  ["return"] = {
    parameters = { { "value", "value" } },
    effects = { "returns_owner" },
    return_kind = "unknown",
  },
}

local RECORD_KIND_RANK = {
  capabilities = 1,
  spec = 2,
  source = 3,
  rule = 4,
  regex_slot = 5,
  edge = 6,
  lifecycle = 7,
  ["function"] = 8,
  helper = 9,
  binding = 10,
  call = 11,
  staged_artifact = 12,
  generated_artifact = 13,
  diagnostic = 14,
  decision = 15,
  execution = 16,
  event = 17,
  explanation_step = 18,
}

local RELATION_KIND_RANK = {
  declares = 1,
  contains = 2,
  depends_on = 3,
  dispatches_to = 4,
  selects_regex = 5,
  calls = 6,
  resolves_to = 7,
  reads = 8,
  writes = 9,
  consumes = 10,
  produces = 11,
  lowered_from = 12,
  staged_by = 13,
  generated_as = 14,
  diagnoses = 15,
  observed_as = 16,
  explained_by = 17,
}

local FROZEN_STATE = setmetatable({}, { __mode = "k" })
local FROZEN_NULL = {}

local function empty_pairs()
  return function() return nil end, nil, nil
end

local FROZEN_MT = {
  __newindex = function()
    error("Semantic static projection values are immutable", 0)
  end,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function() return "SemanticStaticProjectionValue" end,
}

local function correlation_fail(fail, message, identity, fields)
  fields = fields or {}
  fields.identity = identity
  fail(
    "project_static_semantics",
    "semantic_static_correlation_failed",
    message,
    fields
  )
end

local function freeze(value, fail, active)
  if value == json.null then return FROZEN_NULL end
  local value_type = type(value)
  if value_type == "string" or value_type == "number" or value_type == "boolean" then
    return value
  end
  local kind = json.kind(value)
  if kind ~= "array" and kind ~= "harray" then
    correlation_fail(fail, "Static projection contains a non-plain host value", value_type)
  end
  active = active or {}
  if active[value] then
    correlation_fail(fail, "Static projection contains a cycle", kind)
  end
  active[value] = true
  local handle = setmetatable({}, FROZEN_MT)
  local state = { kind = kind, values = {} }
  FROZEN_STATE[handle] = state
  if kind == "array" then
    for index = 1, #value do
      state.values[index] = freeze(value[index], fail, active)
    end
  else
    local keys = {}
    for key in pairs(value) do
      if type(key) ~= "string" then
        correlation_fail(fail, "Static projection object key is not text", tostring(key))
      end
      keys[#keys + 1] = key
    end
    table.sort(keys)
    for index, key in ipairs(keys) do
      state.values[index] = { key, freeze(value[key], fail, active) }
    end
  end
  active[value] = nil
  return handle
end

local function thaw(value)
  if value == FROZEN_NULL then return json.null end
  local state = FROZEN_STATE[value]
  if state == nil then return value end
  if state.kind == "array" then
    local result = json.array()
    for index, item in ipairs(state.values) do result[index] = thaw(item) end
    return result
  end
  local result = json.harray()
  for _, pair in ipairs(state.values) do result[pair[1]] = thaw(pair[2]) end
  return result
end

local function portable(value)
  return value == nil and json.null or value
end

local function value_shape(kind)
  return json.harray({
    kind = kind,
    element = json.null,
    key = json.null,
    value = json.null,
    signature = json.null,
    members = json.array(),
  })
end

local function array_shape(element)
  local result = value_shape("array")
  result.element = element
  return result
end

local function harray_shape(key, value)
  local result = value_shape("harray")
  result.key = key
  result.value = value
  return result
end

local function codeblock_shape(signature)
  local result = value_shape("codeblock")
  local parameters = json.array()
  for index, name in ipairs(signature.positional_params or {}) do
    parameters[index] = json.harray({ name = name, kind = "value", required = true })
  end
  result.signature = json.harray({
    parameters = parameters,
    arity_min = signature.min_arity,
    arity_max = signature.max_arity,
    rest_parameter = signature.rest_param,
    final_codeblock = false,
  })
  return result
end

local function common_shape(shapes)
  if #shapes == 0 then return value_shape("unknown") end
  local expected = json.encode(shapes[1])
  for index = 2, #shapes do
    if json.encode(shapes[index]) ~= expected then return value_shape("unknown") end
  end
  return shapes[1]
end

local expression_shape

local function return_shape(expression)
  if type(expression) ~= "table" then return nil end
  if expression.kind == "call" and expression.name == "return" then
    local argument = expression.args and expression.args[1]
    return argument == nil and value_shape("unknown") or expression_shape(argument.value)
  elseif expression.kind == "block_value" then
    for _, statement in ipairs(expression.block and expression.block.statements or {}) do
      local shape = return_shape(statement.expr)
      if shape ~= nil then return shape end
    end
  elseif expression.kind == "fluent_chain" then
    local receiver = return_shape(expression.receiver)
    if receiver ~= nil then return receiver end
    for _, call in ipairs(expression.calls or {}) do
      if call.method == "return" then
        local argument = call.args and call.args[1]
        return argument == nil and value_shape("unknown") or expression_shape(argument.value)
      end
    end
  end
  return nil
end

expression_shape = function(expression)
  if type(expression) ~= "table" then return value_shape("unknown") end
  if expression.kind == "string" then
    return value_shape("string")
  elseif expression.kind == "number" then
    return value_shape("number")
  elseif expression.kind == "boolean" then
    return value_shape("boolean")
  elseif expression.kind == "undef" then
    return value_shape("null")
  elseif expression.kind == "codeblock_literal" then
    return codeblock_shape(expression.signature)
  elseif expression.kind == "array_literal" then
    local shapes = {}
    for index, item in ipairs(expression.items or {}) do shapes[index] = expression_shape(item) end
    return array_shape(common_shape(shapes))
  elseif expression.kind == "hash_literal" then
    local keys = {}
    local values = {}
    for index, entry in ipairs(expression.entries or {}) do
      keys[index] = expression_shape(entry.key)
      values[index] = expression_shape(entry.value)
    end
    return harray_shape(common_shape(keys), common_shape(values))
  elseif expression.kind == "call" and expression.name == "return" then
    local argument = expression.args and expression.args[1]
    return argument == nil and value_shape("unknown") or expression_shape(argument.value)
  end
  return value_shape("unknown")
end

local function action_block_shape(block)
  if block == nil or action_ast.node_type(block) ~= "ActionBlock" then
    return value_shape("unknown")
  end
  for _, statement in ipairs(block.statements) do
    local shape = return_shape(statement.expr)
    if shape ~= nil then return shape end
  end
  return value_shape("unknown")
end

local function is_whitespace(byte)
  return byte == 0x09 or byte == 0x0A or byte == 0x0B or byte == 0x0C or
    byte == 0x0D or byte == 0x20
end

local function line_ranges(source)
  local result = {}
  local start = 0
  while true do
    local ending = source:find("\n", start + 1, true)
    if ending == nil then break end
    result[#result + 1] = { start = start, stop = ending - 1 }
    start = ending
  end
  if start < #source or #source == 0 then
    result[#result + 1] = { start = start, stop = #source }
  end
  return result
end

local function trimmed_line_range(source, lines, line, fail)
  if line <= 0 or line > #lines then
    correlation_fail(fail, "Parsed line is outside the captured source", tostring(line))
  end
  local raw = lines[line]
  local start = raw.start
  local stop = raw.stop
  while start < stop and is_whitespace(source:byte(start + 1)) do start = start + 1 end
  while stop > start and is_whitespace(source:byte(stop)) do stop = stop - 1 end
  return { start = start, stop = stop }
end

local function member_range(source, lines, line, fail)
  local first = trimmed_line_range(source, lines, line, fail)
  local depth = 0
  local quote_byte = nil
  local escaped = false
  local in_regex = first.start < #source and source:byte(first.start + 1) == 0x2F
  local last_non_whitespace = first.start
  for offset = first.start, #source - 1 do
    local byte = source:byte(offset + 1)
    if byte == 0x0A and quote_byte == nil and not in_regex and depth == 0 then
      return { start = first.start, stop = last_non_whitespace }
    end
    if not is_whitespace(byte) then last_non_whitespace = offset + 1 end
    if in_regex then
      if escaped then
        escaped = false
      elseif byte == 0x5C then
        escaped = true
      elseif byte == 0x2F and offset ~= first.start then
        in_regex = false
      end
    elseif quote_byte ~= nil then
      if escaped then
        escaped = false
      elseif byte == 0x5C then
        escaped = true
      elseif byte == quote_byte then
        quote_byte = nil
      end
    elseif byte == 0x22 or byte == 0x27 then
      quote_byte = byte
    elseif byte == 0x28 or byte == 0x5B or byte == 0x7B then
      depth = depth + 1
    elseif byte == 0x29 or byte == 0x5D or byte == 0x7D then
      depth = depth - 1
    end
  end
  return { start = first.start, stop = last_non_whitespace }
end

local function source_slice(source, range)
  if range.start == range.stop then return "" end
  return source:sub(range.start + 1, range.stop)
end

local function leading_regex_flags(text)
  if text:byte(1) ~= 0x2F then return "" end
  local escaped = false
  for index = 2, #text do
    local byte = text:byte(index)
    if escaped then
      escaped = false
    elseif byte == 0x5C then
      escaped = true
    elseif byte == 0x2F then
      local stop = index + 1
      while stop <= #text and text:sub(stop, stop):match("[A-Za-z]") do stop = stop + 1 end
      return text:sub(index + 1, stop - 1)
    end
  end
  return ""
end

local function explicit_target_index(text, label, expected)
  local cursor = 1
  while true do
    local position = text:find(label, cursor, true)
    if position == nil then return nil end
    local suffix = text:sub(position + #label)
    local observed = suffix:match("^%s*%[%s*(%d+)%s*%]")
    if observed ~= nil and tonumber(observed) == expected then return expected end
    cursor = position + #label
  end
end

local function scan_member(source, range, elements, mode)
  local text = source_slice(source, range)
  local result = {
    range = range,
    regex = nil,
    regex_flags = "",
    edges = {},
    lifecycle = nil,
    lifecycle_has_payload = false,
  }
  for _, element in ipairs(elements) do
    local kind = element.kind
    local node_type = spec_ast.node_type(kind)
    if node_type == "RegexBodyElementKind" then
      if result.regex == nil then result.regex = kind.pattern end
      result.regex_flags = leading_regex_flags(text)
    elseif node_type == "ActionEdgeBodyElementKind" then
      for _, target in ipairs(kind.targets) do
        result.edges[#result.edges + 1] = {
          ownership = "action",
          target = target.label,
          target_index = explicit_target_index(text, target.label, target.index),
        }
      end
    elseif node_type == "BlindEdgeBodyElementKind" then
      result.edges[#result.edges + 1] = {
        ownership = "blind",
        target = kind.target,
        target_index = nil,
      }
    elseif node_type == "BareEdgeBodyElementKind" then
      for _, target in ipairs(kind.targets) do
        result.edges[#result.edges + 1] = {
          ownership = spec_ast.rule_mode_is_and(mode) and "blind" or "action",
          target = target.label,
          target_index = spec_ast.rule_mode_is_and(mode) and nil or
            explicit_target_index(text, target.label, target.index or 0),
        }
      end
    elseif node_type == "CodeBlockBodyElementKind" then
      result.lifecycle = kind.lifecycle
      result.lifecycle_has_payload = true
    elseif node_type == "LifecycleMarkerBodyElementKind" then
      result.lifecycle = kind.marker
    end
  end
  return result
end

local function scan_rules(source, parsed, fail)
  local lines = line_ranges(source)
  local result = {}
  for _, rule in ipairs(parsed.rules) do
    local grouped = {}
    local ordered_lines = {}
    for _, element in ipairs(rule.body) do
      if grouped[element.line] == nil then
        grouped[element.line] = {}
        ordered_lines[#ordered_lines + 1] = element.line
      end
      grouped[element.line][#grouped[element.line] + 1] = element
    end
    local members = {}
    for _, line in ipairs(ordered_lines) do
      members[#members + 1] = scan_member(
        source,
        member_range(source, lines, line, fail),
        grouped[line],
        rule.header.mode
      )
    end
    result[#result + 1] = {
      label = rule.header.label,
      header = trimmed_line_range(source, lines, rule.header.line, fail),
      members = members,
    }
  end
  return result
end

local function project_edges(scan, compiled, fail)
  local scanned = {}
  for _, member in ipairs(scan.members) do
    for _, edge in ipairs(member.edges) do
      scanned[#scanned + 1] = { range = member.range, edge = edge }
    end
  end
  if #scanned ~= #compiled.action_edges + #compiled.blind_edges then
    correlation_fail(fail, "Authored and compiled edge counts differ", compiled.label, {
      authored_edges = #scanned,
      compiled_edges = #compiled.action_edges + #compiled.blind_edges,
    })
  end
  local result = {}
  local action_index = 1
  local blind_index = 1
  for _, pair in ipairs(scanned) do
    local source_edge = pair.edge
    if source_edge.ownership == "action" then
      local edge = compiled.action_edges[action_index]
      if edge == nil then
        correlation_fail(fail, "Authored action edge has no compiled owner", compiled.label)
      end
      action_index = action_index + 1
      local target = edge.targets[1]
      local expected_index = source_edge.target_index or 0
      if #edge.targets ~= 1 or target.label ~= source_edge.target or
          edge.child_regex_index ~= expected_index then
        correlation_fail(fail, "Authored and compiled action-edge identities differ", compiled.label)
      end
      result[#result + 1] = {
        source = pair.range,
        ownership = "action",
        target = source_edge.target,
        target_index = source_edge.target_index,
        has_block = edge.code ~= nil,
        value_shape = action_block_shape(edge.action_payload and edge.action_payload.action_ast),
      }
    else
      local edge = compiled.blind_edges[blind_index]
      if edge == nil then
        correlation_fail(fail, "Authored blind edge has no compiled owner", compiled.label)
      end
      blind_index = blind_index + 1
      if edge.target.label ~= source_edge.target then
        correlation_fail(fail, "Authored and compiled blind-edge identities differ", compiled.label)
      end
      result[#result + 1] = {
        source = pair.range,
        ownership = "blind",
        target = source_edge.target,
        target_index = nil,
        has_block = edge.code ~= nil,
        value_shape = action_block_shape(edge.action_payload and edge.action_payload.action_ast),
      }
    end
  end
  return result
end

local function project_regex_slots(scan, compiled, fail)
  local result = {}
  for _, member in ipairs(scan.members) do
    if member.regex ~= nil then
      local retained = #member.edges == 0
      for _, edge in ipairs(member.edges) do
        if edge.target == compiled.label and edge.target_index ~= nil then retained = true end
      end
      if retained then result[#result + 1] = member end
    end
  end
  for index, slot in ipairs(result) do
    if compiled.regex_patterns[index] ~= slot.regex then
      correlation_fail(fail, "Authored and compiled regex-slot identities differ", compiled.label, {
        slot = index - 1,
      })
    end
  end
  return result
end

local function project_lifecycles(scan, compiled, fail)
  local result = {}
  local payload_index = 1
  for _, member in ipairs(scan.members) do
    if member.lifecycle ~= nil then
      local shape = value_shape("unknown")
      if member.lifecycle_has_payload then
        local payload = compiled.lifecycle_action_payloads[payload_index]
        if payload == nil then
          correlation_fail(fail, "Authored lifecycle block has no compiled payload", compiled.label, {
            marker = member.lifecycle,
          })
        end
        payload_index = payload_index + 1
        if payload.lifecycle ~= member.lifecycle then
          correlation_fail(fail, "Authored and compiled lifecycle identities differ", compiled.label, {
            authored_marker = member.lifecycle,
            compiled_marker = payload.lifecycle,
          })
        end
        shape = action_block_shape(payload.action_ast)
      end
      result[#result + 1] = { member = member, marker = member.lifecycle, value_shape = shape }
    end
  end
  if payload_index - 1 ~= #compiled.lifecycle_action_payloads then
    correlation_fail(fail, "Compiled lifecycle payload has no authored source owner", compiled.label, {
      authored_payloads = payload_index - 1,
      compiled_payloads = #compiled.lifecycle_action_payloads,
    })
  end
  return result
end

local function neutral_repetition(mode)
  return mode.name ~= "Default" and mode.name ~= "And" and
    mode.name ~= "Single" and mode.name ~= "Pipe"
end

local function neutral_bounds(mode)
  if not neutral_repetition(mode) then return nil, nil end
  return spec_ast.rule_mode_rep_min(mode), spec_ast.rule_mode_rep_max(mode)
end

local function edge_ownership(edges)
  local action = false
  local blind = false
  for _, edge in ipairs(edges) do
    if edge.ownership == "action" then action = true end
    if edge.ownership == "blind" then blind = true end
  end
  if action and blind then return "mixed" end
  if action then return "action" end
  if blind then return "blind" end
  return "none"
end

local function rule_value_shape(repetition, edges, lifecycles)
  for _, lifecycle in ipairs(lifecycles) do
    if lifecycle.marker == "E" and lifecycle.value_shape.kind ~= "unknown" then
      return lifecycle.value_shape
    end
  end
  local element = value_shape("unknown")
  for _, edge in ipairs(edges) do
    if edge.value_shape.kind ~= "unknown" then
      element = edge.value_shape
      break
    end
  end
  return repetition and array_shape(element) or element
end

local function escape_name(name)
  local result = {}
  for index = 1, #name do
    local byte = name:byte(index)
    local safe = (byte >= 0x41 and byte <= 0x5A) or
      (byte >= 0x61 and byte <= 0x7A) or
      (byte >= 0x30 and byte <= 0x39) or
      byte == 0x2E or byte == 0x5F or byte == 0x7E or byte == 0x2D
    result[index] = safe and string.char(byte) or string.format("%%%02X", byte)
  end
  return table.concat(result)
end

local function rule_id(label)
  return "rule:" .. escape_name(label)
end

local function spec_name(logical_name)
  return logical_name:sub(-5) == ".spec" and logical_name:sub(1, -6) or logical_name
end

local function entry_basis(basis)
  if basis == "first_authored_marker" then return "first_marker" end
  if basis == "first_authored_rule" then return "first_rule" end
  if basis == "explicit_selector" then return "explicit_selector" end
  return "first_rule"
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

local function relation(kind, from_id, to_id, order, source, evidence_ids)
  return json.harray({
    id = "relation:" .. kind .. ":" .. from_id .. ":" .. to_id .. ":" .. order,
    kind = kind,
    from_id = from_id,
    to_id = to_id,
    order = order,
    source = portable(source),
    facts = json.harray(),
    evidence_ids = evidence_ids or json.array(),
  })
end

local function source_record()
  return record(
    SOURCE_ID,
    "source",
    nil,
    SPEC_ID,
    0,
    nil,
    json.harray({ logical_kind = "spec", origin_kind = "authored" })
  )
end

local function span_for_range(source_map, range, fail)
  local start_scalar = source_map.scalar_at_byte[range.start]
  local end_scalar = source_map.scalar_at_byte[range.stop]
  if start_scalar == nil or end_scalar == nil then
    correlation_fail(fail, "Static source range is not aligned to UTF-8 scalar boundaries",
      range.start .. ":" .. range.stop)
  end
  return json.harray({
    start_byte = range.start,
    end_byte = range.stop,
    start_line = source_map.line_at_scalar[start_scalar + 1],
    start_column = source_map.column_at_scalar[start_scalar + 1],
    end_line = source_map.line_at_scalar[end_scalar + 1],
    end_column = source_map.column_at_scalar[end_scalar + 1],
  })
end

local function register_source(source_refs, record_id, range, context)
  local key = "source_ref:" .. record_id
  source_refs[key] = json.harray({
    source_id = SOURCE_ID,
    logical_name = context.logical_name,
    span = span_for_range(context.source_map, range, context.fail),
    excerpt = source_slice(context.source, range),
    content_digest = context.content_digest,
    provenance_ids = json.array(),
  })
  return key
end

local function add_entry_explanation(records, relations, selected, source)
  local selected_rule_id = rule_id(selected.label)
  local basis = entry_basis(selected.basis)
  local decision_id = "decision:entry:spec:0"
  records[#records + 1] = record(
    decision_id,
    "decision",
    "entry selection",
    SPEC_ID,
    0,
    source,
    json.harray({ decision_kind = "entry_selection", outcome = selected_rule_id })
  )
  local explicit = selected.basis == "explicit_selector"
  local first_id = "explanation:decision:entry:spec:0:0"
  records[#records + 1] = record(
    first_id,
    "explanation_step",
    nil,
    decision_id,
    0,
    source,
    json.harray({
      rule_code = explicit and "entry_explicit_selector" or "entry_explicit_selector_absent",
      summary = explicit and ("The caller selected " .. selected.label .. ".") or
        "No caller selector was supplied.",
      input_ids = json.array({ SPEC_ID }),
      output_fact = json.harray({
        record_id = SPEC_ID,
        path = "/facts/entry_selection_basis",
        value = basis,
      }),
    })
  )
  local second_id = "explanation:decision:entry:spec:0:1"
  local rule_code = basis == "first_marker" and "entry_first_marker" or
    (basis == "first_rule" and "entry_first_rule" or "entry_explicit_rule")
  local summary = basis == "first_marker" and
    ("The first authored entry marker selects " .. selected.label .. ".") or
    (basis == "first_rule" and
      ("The first authored rule selects " .. selected.label .. ".") or
      ("The explicit selector resolves to " .. selected.label .. "."))
  records[#records + 1] = record(
    second_id,
    "explanation_step",
    nil,
    decision_id,
    1,
    source,
    json.harray({
      rule_code = rule_code,
      summary = summary,
      input_ids = json.array({ selected_rule_id }),
      output_fact = json.harray({
        record_id = SPEC_ID,
        path = "/facts/entry_rule_id",
        value = selected_rule_id,
      }),
    })
  )
  relations[#relations + 1] = relation(
    "explained_by", decision_id, first_id, 0, source, json.array({ selected_rule_id })
  )
  relations[#relations + 1] = relation(
    "explained_by", decision_id, second_id, 1, source, json.array({ selected_rule_id })
  )
end

local function call_fail(context, message, identity, fields)
  fields = fields or {}
  fields.identity = identity
  context.fail(
    "project_call_semantics",
    "semantic_call_correlation_failed",
    message,
    fields
  )
end

local function plain_equal(left, right, active)
  local left_kind = json.kind(left)
  local right_kind = json.kind(right)
  if left_kind ~= right_kind then return false end
  if left_kind ~= "array" and left_kind ~= "harray" then return left == right end
  active = active or {}
  if active[left] or active[right] then return false end
  active[left] = true
  active[right] = true
  if left_kind == "array" then
    if #left ~= #right then
      active[left] = nil
      active[right] = nil
      return false
    end
    for index = 1, #left do
      if not plain_equal(left[index], right[index], active) then
        active[left] = nil
        active[right] = nil
        return false
      end
    end
  else
    local count = 0
    for key, value in pairs(left) do
      count = count + 1
      if right[key] == nil or not plain_equal(value, right[key], active) then
        active[left] = nil
        active[right] = nil
        return false
      end
    end
    local right_count = 0
    for _ in pairs(right) do right_count = right_count + 1 end
    if count ~= right_count then
      active[left] = nil
      active[right] = nil
      return false
    end
  end
  active[left] = nil
  active[right] = nil
  return true
end

local function function_id(name)
  return "function:" .. escape_name(name)
end

local function function_body_range(entry, context)
  local definition = entry.definition
  local job = definition.body_parse_job
  if spec_ast.node_type(job) ~= "StagedParseJob" then
    call_fail(context, "Function has no staged body parse-job authority", definition.name)
  end
  if job.text ~= definition.body_source or job.function_name ~= definition.name then
    call_fail(context, "Function staged body metadata does not match its typed owner", definition.name)
  end
  if job.result_policy ~= "replace_field" or job.result_field ~= "body_ast" or
      job.failure_policy ~= "fail" then
    call_fail(context, "Function staged body policy does not match its accepted owner", definition.name)
  end
  local span = job.source_span
  local start_byte = context.source_map.byte_at_scalar[span.start + 1]
  local end_byte = context.source_map.byte_at_scalar[span["end"] + 1]
  if start_byte == nil or end_byte == nil then
    call_fail(context, "Function staged body span is outside the accepted source", definition.name)
  end
  local range = { start = start_byte, stop = end_byte }
  if source_slice(context.source, range) ~= definition.body_source then
    call_fail(context, "Staged body span does not match function body source", definition.name)
  end
  return range
end

local function function_range(entry, body, context)
  local definition = entry.definition
  if definition.source == "" then
    call_fail(context, "Function shell source is empty", definition.name)
  end
  local candidates = {}
  local cursor = 1
  while cursor <= #context.source + 1 do
    local start_position = context.source:find(definition.source, cursor, true)
    if start_position == nil then break end
    local candidate = {
      start = start_position - 1,
      stop = start_position - 1 + #definition.source,
    }
    if candidate.start <= body.start and body.stop <= candidate.stop then
      candidates[#candidates + 1] = candidate
    end
    cursor = start_position + 1
  end
  if #candidates ~= 1 then
    call_fail(
      context,
      "Function shell occurrence is not uniquely owned by its staged body",
      definition.name,
      { candidate_count = #candidates }
    )
  end
  return candidates[1]
end

local function parameter_kind(definition, name)
  return definition.parameter_kinds and definition.parameter_kinds[name] or "value"
end

local function call_signature(parameters)
  local projected = json.array()
  for index, parameter in ipairs(parameters) do
    projected[index] = json.harray({
      name = parameter[1],
      kind = parameter[2],
      required = true,
    })
  end
  return json.harray({
    parameters = projected,
    arity_min = #parameters,
    arity_max = #parameters,
    rest_parameter = json.null,
    final_codeblock = false,
  })
end

local function function_signature(definition)
  local signature = definition.signature
  local names = signature and signature.positional_params or definition.params
  local parameters = json.array()
  local kinds = json.array()
  for index, name in ipairs(names) do
    local kind = signature and "value" or parameter_kind(definition, name)
    parameters[index] = json.harray({ name = name, kind = kind, required = true })
    kinds[index] = kind
  end
  local final_codeblock = #names > 0 and kinds[#names] == "codeblock"
  return json.harray({
    parameters = parameters,
    arity_min = signature and signature.min_arity or definition.arity,
    arity_max = signature and portable(signature.max_arity) or definition.arity,
    rest_parameter = signature and signature.rest_param or json.null,
    final_codeblock = final_codeblock,
  }), kinds
end

local function typed_function_body(entry, registry, context)
  local definition = entry.definition
  local ok, block = pcall(action_parser.parse_action_block, definition.body_source)
  if not ok or action_ast.node_type(block) ~= "ActionBlock" then
    call_fail(context, "Accepted function body cannot be reconstructed as typed ActionIR", definition.name, {
      error = tostring(block),
    })
  end
  if definition.body_ast == nil or
      not plain_equal(definition.body_ast, action_ast.to_json(block)) then
    call_fail(context, "Staged function body result differs from typed ActionIR", definition.name)
  end
  local resolution = action_contracts.resolve_action_block_contracts(
    block,
    { function_registry = registry }
  )
  if not resolution.ok then
    call_fail(context, "Typed function body has unresolved contracts", definition.name)
  end
  return block
end

local call_expression_shape

local function function_variables(entry)
  local definition = entry.definition
  local signature = definition.signature
  local names = signature and signature.positional_params or definition.params
  local variables = {}
  for _, name in ipairs(names) do
    local kind = signature and "value" or parameter_kind(definition, name)
    variables[name] = value_shape(kind == "codeblock" and "codeblock" or "unknown")
  end
  if signature ~= nil then
    variables[signature.rest_param] = array_shape(value_shape("unknown"))
  end
  return variables
end

call_expression_shape = function(expression, variables, function_shapes)
  if type(expression) ~= "table" then return value_shape("unknown") end
  local kind = expression.kind
  if kind == "string" then
    return value_shape("string")
  elseif kind == "number" then
    return value_shape("number")
  elseif kind == "boolean" then
    return value_shape("boolean")
  elseif kind == "undef" then
    return value_shape("null")
  elseif kind == "codeblock_literal" then
    return codeblock_shape(expression.signature)
  elseif kind == "variable" then
    return variables[expression.name] or value_shape("unknown")
  elseif kind == "assign_scalar" then
    return call_expression_shape(expression.value, variables, function_shapes)
  elseif kind == "array_literal" then
    local shapes = {}
    for index, item in ipairs(expression.items or {}) do
      shapes[index] = call_expression_shape(item, variables, function_shapes)
    end
    return array_shape(common_shape(shapes))
  elseif kind == "hash_literal" then
    local keys = {}
    local values = {}
    for index, item in ipairs(expression.entries or {}) do
      keys[index] = call_expression_shape(item.key, variables, function_shapes)
      values[index] = call_expression_shape(item.value, variables, function_shapes)
    end
    return harray_shape(common_shape(keys), common_shape(values))
  elseif kind == "call" then
    if function_shapes[expression.name] ~= nil then return function_shapes[expression.name] end
    if expression.name == "return" and expression.args and expression.args[1] then
      return call_expression_shape(expression.args[1].value, variables, function_shapes)
    end
    local helper = CALL_HELPERS[expression.name]
    return helper and value_shape(helper.return_kind) or value_shape("unknown")
  end
  return value_shape("unknown")
end

local function infer_function_shapes(functions, typed_blocks)
  local shapes = {}
  for _, entry in ipairs(functions) do
    shapes[entry.definition.name] = value_shape("unknown")
  end
  for _ = 0, #functions do
    local changed = false
    for _, entry in ipairs(functions) do
      local definition = entry.definition
      local variables = function_variables(entry)
      local shape = value_shape("unknown")
      for _, statement in ipairs(typed_blocks[definition.name].statements) do
        local expression = statement.expr
        if expression.kind == "call" and expression.name == "return" then
          if expression.args and expression.args[1] then
            shape = call_expression_shape(expression.args[1].value, variables, shapes)
          end
          break
        elseif expression.kind == "assign_scalar" then
          variables[expression.name] = call_expression_shape(expression.value, variables, shapes)
        end
      end
      if json.encode(shapes[definition.name]) ~= json.encode(shape) then
        shapes[definition.name] = shape
        changed = true
      end
    end
    if not changed then break end
  end
  return shapes
end

local function identifier_start(byte)
  return byte ~= nil and ((byte >= 0x41 and byte <= 0x5A) or
    (byte >= 0x61 and byte <= 0x7A) or byte == 0x5F)
end

local function identifier_continue(byte)
  return identifier_start(byte) or (byte ~= nil and byte >= 0x30 and byte <= 0x39)
end

local function regex_start(source, index, start, stop)
  local next_index = index + 1
  local next_byte = source:byte(next_index + 1)
  if next_index >= stop or next_byte == 0x28 or is_whitespace(next_byte) then return false end
  local previous = index - 1
  while previous >= start and is_whitespace(source:byte(previous + 1)) do previous = previous - 1 end
  if previous < start then return true end
  local previous_byte = source:byte(previous + 1)
  return previous_byte == 0x28 or previous_byte == 0x5B or previous_byte == 0x7B or
    previous_byte == 0x2C or previous_byte == 0x3D or previous_byte == 0x3A
end

local function line_comment_start(source, index, stop)
  local byte = source:byte(index + 1)
  local next_byte = index + 1 < stop and source:byte(index + 2) or nil
  return byte == 0x23 or (byte == 0x2D and next_byte == 0x2D) or
    (byte == 0x2F and next_byte == 0x2F)
end

local function skip_line_comment(source, index, stop)
  local newline = source:find("\n", index + 1, true)
  return newline == nil and stop or math.min(stop, newline)
end

local function matching_parenthesis(source, open, stop)
  local depth = 0
  local quote_byte = nil
  local in_regex = false
  local escaped = false
  local index = open
  while index < stop do
    local byte = source:byte(index + 1)
    if quote_byte ~= nil or in_regex then
      if escaped then
        escaped = false
      elseif byte == 0x5C then
        escaped = true
      elseif quote_byte ~= nil and byte == quote_byte then
        quote_byte = nil
      elseif in_regex and byte == 0x2F then
        in_regex = false
      end
    elseif line_comment_start(source, index, stop) then
      index = skip_line_comment(source, index, stop) - 1
    elseif byte == 0x22 or byte == 0x27 then
      quote_byte = byte
    elseif byte == 0x2F and regex_start(source, index, open, stop) then
      in_regex = true
    elseif byte == 0x28 then
      depth = depth + 1
    elseif byte == 0x29 then
      depth = depth - 1
      if depth == 0 then return index + 1 end
      if depth < 0 then return nil end
    end
    index = index + 1
  end
  return nil
end

local function scan_call_sites(source, range, context)
  local sites = {}
  local index = range.start
  local quote_byte = nil
  local in_regex = false
  local escaped = false
  while index < range.stop do
    local byte = source:byte(index + 1)
    if quote_byte ~= nil or in_regex then
      if escaped then
        escaped = false
      elseif byte == 0x5C then
        escaped = true
      elseif quote_byte ~= nil and byte == quote_byte then
        quote_byte = nil
      elseif in_regex and byte == 0x2F then
        in_regex = false
      end
      index = index + 1
    elseif line_comment_start(source, index, range.stop) then
      index = skip_line_comment(source, index, range.stop)
    elseif byte == 0x22 or byte == 0x27 then
      quote_byte = byte
      index = index + 1
    elseif byte == 0x2F and regex_start(source, index, range.start, range.stop) then
      in_regex = true
      index = index + 1
    elseif not identifier_start(byte) then
      index = index + 1
    else
      local name_start = index
      index = index + 1
      while index < range.stop and identifier_continue(source:byte(index + 1)) do
        index = index + 1
      end
      local name_stop = index
      while index < range.stop and is_whitespace(source:byte(index + 1)) do index = index + 1 end
      if index < range.stop and source:byte(index + 1) == 0x28 then
        local stop = matching_parenthesis(source, index, range.stop)
        local name = source:sub(name_start + 1, name_stop)
        if stop == nil then
          call_fail(context, "Authored call has no balanced closing parenthesis", name)
        end
        sites[#sites + 1] = {
          name = name,
          range = { start = name_start, stop = stop },
        }
      end
      index = name_stop
    end
  end
  return { sites = sites, next = 1 }
end

local function take_call_site(cursor, name, owner_id, context)
  for index = cursor.next, #cursor.sites do
    local site = cursor.sites[index]
    if site.name == name then
      cursor.next = index + 1
      return site.range
    end
  end
  call_fail(context, "Typed call has no authored source occurrence", owner_id, {
    call_name = name,
  })
end

local function call_action_owners(scans_by_label, compiled, context)
  local owners = {}
  for _, label in ipairs(compiled.compiled_rule_order) do
    local rule = compiled.rules_by_label[label]
    local scan = scans_by_label[label]
    if scan == nil then
      call_fail(context, "Compiled action owner has no authored source scan", label)
    end
    local action_index = 1
    local blind_index = 1
    local edge_order = 0
    for _, member in ipairs(scan.members) do
      for _, edge in ipairs(member.edges) do
        local payload
        if edge.ownership == "action" then
          local compiled_edge = rule.action_edges[action_index]
          if compiled_edge == nil then
            call_fail(context, "Authored action owner has no compiled edge", label)
          end
          payload = compiled_edge.action_payload
          action_index = action_index + 1
        else
          local compiled_edge = rule.blind_edges[blind_index]
          if compiled_edge == nil then
            call_fail(context, "Authored blind owner has no compiled edge", label)
          end
          payload = compiled_edge.action_payload
          blind_index = blind_index + 1
        end
        local owner_id = "edge:" .. rule_id(label) .. ":" .. edge_order
        edge_order = edge_order + 1
        if payload ~= nil then
          if payload.contracts == nil or not payload.contracts.ok or
              action_ast.node_type(payload.action_ast) ~= "ActionBlock" then
            call_fail(context, "Compiled action owner has unresolved typed contracts", owner_id)
          end
          owners[#owners + 1] = {
            owner_id = owner_id,
            rule_label = label,
            block = payload.action_ast,
            source = member.range,
          }
        end
      end
    end
    if action_index - 1 ~= #rule.action_edges or blind_index - 1 ~= #rule.blind_edges then
      call_fail(context, "Authored and compiled action owner counts differ", label, {
        authored_action_edges = action_index - 1,
        compiled_action_edges = #rule.action_edges,
        authored_blind_edges = blind_index - 1,
        compiled_blind_edges = #rule.blind_edges,
      })
    end
  end
  return owners
end

local function ensure_helper(builder, name, contract)
  if builder.helper_ids[name] ~= nil then return builder.helper_ids[name] end
  local id = "helper:" .. escape_name(name)
  local parameters = {}
  for index, item in ipairs(contract.parameters) do parameters[index] = item end
  builder.helper_ids[name] = id
  builder.records[#builder.records + 1] = record(
    id,
    "helper",
    name,
    nil,
    builder.helper_count,
    nil,
    json.harray({
      signature = call_signature(parameters),
      effects = json.array(contract.effects),
      return_shape = value_shape(contract.return_kind),
    })
  )
  builder.helper_count = builder.helper_count + 1
  return id
end

local function signature_names(definition)
  local signature = definition.signature
  local names = {}
  for index, name in ipairs(signature and signature.positional_params or definition.params) do
    names[index] = name
  end
  if signature ~= nil then names[#names + 1] = "..." .. signature.rest_param end
  return names
end

local function shape_kind(shape)
  return type(shape) == "table" and shape.kind or "unknown"
end

local function add_function_resolution(builder, call_id, source, entry, argument_shapes, result_shape)
  local definition = entry.definition
  local target_id = function_id(definition.name)
  local decision_id = "decision:call:" .. call_id
  local exact_id = "explanation:" .. decision_id .. ":0"
  local signature_id = "explanation:" .. decision_id .. ":1"
  builder.records[#builder.records + 1] = record(
    decision_id,
    "decision",
    definition.name .. " call resolution",
    call_id,
    0,
    source,
    json.harray({ decision_kind = "call_resolution", outcome = target_id })
  )
  builder.records[#builder.records + 1] = record(
    exact_id,
    "explanation_step",
    nil,
    decision_id,
    0,
    source,
    json.harray({
      rule_code = "call_exact_user_function",
      summary = "The exact user-function name " .. definition.name .. " is registered.",
      input_ids = json.array({ call_id, target_id }),
      output_fact = json.harray({
        record_id = call_id,
        path = "/facts/resolution_kind",
        value = "user_function",
      }),
    })
  )
  local count = #argument_shapes
  local count_words = count == 1 and "one" or tostring(count)
  local shape_words = count == 1 and (shape_kind(argument_shapes[1]) .. " argument") or "arguments"
  builder.records[#builder.records + 1] = record(
    signature_id,
    "explanation_step",
    nil,
    decision_id,
    1,
    source,
    json.harray({
      rule_code = "call_signature_accepts",
      summary = "The " .. count_words .. " supplied " .. shape_words .. " satisfies " ..
        definition.name .. "(" .. table.concat(signature_names(definition), ", ") .. ").",
      input_ids = json.array({ call_id, target_id }),
      output_fact = json.harray({
        record_id = call_id,
        path = "/facts/return_shape/kind",
        value = shape_kind(result_shape),
      }),
    })
  )
  builder.relations[#builder.relations + 1] = relation(
    "calls", call_id, target_id, 0, source
  )
  builder.relations[#builder.relations + 1] = relation(
    "resolves_to", call_id, target_id, 0, source, json.array({ decision_id })
  )
  builder.relations[#builder.relations + 1] = relation(
    "explained_by", decision_id, exact_id, 0, source, json.array({ target_id })
  )
  builder.relations[#builder.relations + 1] = relation(
    "explained_by", decision_id, signature_id, 1, source, json.array({ target_id })
  )
end

local call_emit_expression
local call_emit_call
local call_visit_children

call_visit_children = function(builder, expression, owner_id, cursor, local_order, variables, function_surface)
  local function visit(value)
    return call_emit_expression(
      builder,
      value,
      owner_id,
      cursor,
      local_order,
      variables,
      function_surface
    )
  end
  local function visit_args(arguments)
    for _, argument in ipairs(arguments or {}) do visit(argument.value) end
  end
  local function visit_block(block)
    for _, statement in ipairs(block and block.statements or {}) do visit(statement.expr) end
  end
  local kind = expression.kind
  if kind == "array_literal" then
    for _, item in ipairs(expression.items or {}) do visit(item) end
  elseif kind == "hash_literal" then
    for _, item in ipairs(expression.entries or {}) do
      visit(item.key)
      visit(item.value)
    end
  elseif kind == "block_value" or kind == "codeblock_argument" then
    visit_block(expression.block)
  elseif kind == "indexed_var" then
    visit(expression.index)
  elseif kind == "assign_array_append" then
    visit(expression.value)
  elseif kind == "assign_hash_index" then
    visit(expression.key)
    visit(expression.value)
  elseif kind == "assign_nested_access" then
    for _, segment in ipairs(expression.segments or {}) do
      if segment.kind == "path_segment" then visit(segment.expression) end
    end
    visit(expression.value)
  elseif kind == "fluent_chain" then
    visit(expression.receiver)
    for _, call in ipairs(expression.calls or {}) do visit_args(call.args) end
  elseif kind == "receiver_mutation_chain" then
    visit_block(expression.mutation and expression.mutation.callback and expression.mutation.callback.body)
    for _, call in ipairs(expression.continuation or {}) do visit_args(call.args) end
  elseif kind == "nested_access" then
    for _, segment in ipairs(expression.segments or {}) do
      if segment.kind == "index" then visit(segment.expr) end
    end
  elseif kind == "value_access" then
    visit(expression.receiver)
    for _, segment in ipairs(expression.segments or {}) do
      if segment.kind == "index" then visit(segment.expr) end
    end
  elseif kind == "control_switch" then
    visit(expression.source_expr)
    visit_args(expression.args)
    visit_block(expression.body)
    for _, case_expression in ipairs(expression.cases or {}) do visit(case_expression) end
    visit(expression.default)
  elseif type(kind) == "string" and kind:sub(1, 8) == "control_" then
    visit(expression.condition)
    visit(expression.match)
    visit_args(expression.args)
    visit_block(expression.body)
  end
end

call_emit_call = function(builder, expression, owner_id, cursor, local_order, variables, function_surface)
  local range = take_call_site(cursor, expression.name, owner_id, builder.context)
  local order = local_order.value
  local_order.value = order + 1
  local call_id = "call:" .. owner_id .. ":" .. order
  local source = register_source(builder.source_refs, call_id, range, builder.context)
  local argument_shapes = json.array()
  for index, argument in ipairs(expression.args or {}) do
    argument_shapes[index] = call_expression_shape(
      argument.value,
      variables,
      builder.function_shapes
    )
  end
  local resolution = builder.registry:resolve_call(expression.name, #(expression.args or {}))
  local function_entry = resolution and resolution.entry or nil
  local helper = CALL_HELPERS[expression.name]
  local resolution_kind = function_entry and "user_function" or (helper and "helper" or "unresolved")
  local result_shape
  if function_entry ~= nil then
    result_shape = builder.function_shapes[expression.name]
  elseif expression.name == "return" and argument_shapes[1] ~= nil then
    result_shape = argument_shapes[1]
  elseif helper ~= nil then
    result_shape = value_shape(helper.return_kind)
  else
    result_shape = value_shape("unknown")
  end
  builder.records[#builder.records + 1] = record(
    call_id,
    "call",
    expression.name,
    owner_id,
    builder.global_call_order,
    source,
    json.harray({
      call_form = "function",
      resolution_kind = resolution_kind,
      argument_shapes = argument_shapes,
      return_shape = result_shape,
      target_shape = value_shape(resolution_kind == "unresolved" and "unknown" or resolution_kind),
    })
  )
  builder.global_call_order = builder.global_call_order + 1

  if function_entry ~= nil then
    add_function_resolution(builder, call_id, source, function_entry, argument_shapes, result_shape)
  elseif helper ~= nil then
    local helper_id = ensure_helper(builder, expression.name, helper)
    builder.relations[#builder.relations + 1] = relation(
      "resolves_to",
      call_id,
      helper_id,
      0,
      source,
      function_surface and json.array({ owner_id }) or json.array()
    )
  end

  for _, argument in ipairs(expression.args or {}) do
    local value = argument.value
    if type(value) == "table" and value.kind == "variable" then
      local binding_id = builder.binding_by_owner_name[owner_id .. "\0" .. value.name]
      if binding_id ~= nil then
        builder.relations[#builder.relations + 1] = relation(
          "reads", call_id, binding_id, 0, source
        )
      end
    end
  end
  for _, argument in ipairs(expression.args or {}) do
    call_emit_expression(
      builder,
      argument.value,
      owner_id,
      cursor,
      local_order,
      variables,
      function_surface
    )
  end
  return { id = call_id, source = source, range = range }
end

call_emit_expression = function(builder, expression, owner_id, cursor, local_order, variables, function_surface)
  if type(expression) ~= "table" then return nil end
  if expression.kind == "assign_scalar" then
    return call_emit_expression(
      builder,
      expression.value,
      owner_id,
      cursor,
      local_order,
      variables,
      function_surface
    )
  elseif expression.kind == "call" then
    if function_surface and expression.name == "return" then
      for _, argument in ipairs(expression.args or {}) do
        call_emit_expression(
          builder,
          argument.value,
          owner_id,
          cursor,
          local_order,
          variables,
          function_surface
        )
      end
      return nil
    end
    return call_emit_call(
      builder,
      expression,
      owner_id,
      cursor,
      local_order,
      variables,
      function_surface
    )
  end
  call_visit_children(
    builder,
    expression,
    owner_id,
    cursor,
    local_order,
    variables,
    function_surface
  )
  return nil
end

local function call_emit_statement(builder, expression, owner_id, cursor, local_order, variables, function_surface)
  if expression.kind == "assign_scalar" then
    local shape = call_expression_shape(expression.value, variables, builder.function_shapes)
    local emitted = call_emit_expression(
      builder,
      expression.value,
      owner_id,
      cursor,
      local_order,
      variables,
      function_surface
    )
    variables[expression.name] = shape
    local key = owner_id .. "\0" .. expression.name
    local binding_order = builder.binding_counts[key] or 0
    builder.binding_counts[key] = binding_order + 1
    local binding_id = "binding:" .. owner_id .. ":" .. escape_name(expression.name) .. ":" .. binding_order
    local source = emitted and register_source(
      builder.source_refs,
      binding_id,
      emitted.range,
      builder.context
    ) or nil
    builder.records[#builder.records + 1] = record(
      binding_id,
      "binding",
      expression.name,
      owner_id,
      binding_order,
      source,
      json.harray({ scope = "action", value_shape = shape, mutable = true })
    )
    builder.binding_by_owner_name[key] = binding_id
    if emitted ~= nil then
      builder.relations[#builder.relations + 1] = relation(
        "writes", emitted.id, binding_id, 0, emitted.source
      )
    end
    return
  end
  if not function_surface and expression.kind == "call" and expression.name == "return" then
    builder.edge_value_shapes[owner_id] = call_expression_shape(
      expression,
      variables,
      builder.function_shapes
    )
  end
  call_emit_expression(
    builder,
    expression,
    owner_id,
    cursor,
    local_order,
    variables,
    function_surface
  )
end

local function apply_edge_shapes(builder)
  local rule_shapes = {}
  for _, item in ipairs(builder.records) do
    if item.kind == "edge" and builder.edge_value_shapes[item.id] ~= nil then
      local shape = builder.edge_value_shapes[item.id]
      item.facts.value_shape = shape
      if shape_kind(shape) ~= "unknown" and rule_shapes[item.owner_id] == nil then
        rule_shapes[item.owner_id] = shape
      end
    end
  end
  for _, item in ipairs(builder.records) do
    if item.kind == "rule" and rule_shapes[item.id] ~= nil then
      item.facts.value_shape = item.facts.is_repetition and
        array_shape(rule_shapes[item.id]) or rule_shapes[item.id]
    end
  end
end

local function string_lists_equal(left, right)
  if type(left) ~= "table" or type(right) ~= "table" or #left ~= #right then return false end
  for index = 1, #left do
    if left[index] ~= right[index] then return false end
  end
  return true
end

local function validate_staged_authority(entry, context)
  local definition = entry.definition
  local payload = definition.body_payload
  local job = definition.body_parse_job
  local expected_path = { "functions", tostring(entry.index), "body_source" }
  if type(payload) ~= "table" or spec_ast.node_type(job) ~= "StagedParseJob" or
      type(definition.body_ast) ~= "table" then
    call_fail(context, "Compiled function has no complete staged authority", definition.name)
  end

  local expected_version = definition.signature and definition.signature.version or 1
  if payload.kind ~= "staged_payload" or payload.version ~= expected_version or
      payload.node_kind ~= "function_definition" or payload.payload_kind ~= "function_body" or
      not string_lists_equal(payload.parent_ast_path, expected_path) or
      payload.function_name ~= definition.name or payload.text ~= definition.body_source or
      not plain_equal(payload.source_span, spec_ast.to_json(job.source_span)) or
      job.version ~= expected_version or job.node_kind ~= "function_definition" or
      job.payload_kind ~= "function_body" or
      not string_lists_equal(job.parent_ast_path, expected_path) or job.job_id == "" or
      job.function_name ~= definition.name or job.text ~= definition.body_source or
      job.parser_spec_id ~= "actionir-body.spec" or job.top_rule ~= "action_block" or
      job.result_policy ~= "replace_field" or job.result_field ~= "body_ast" or
      job.failure_policy ~= "fail" or job.diagnostic_owner ~= "function_body" then
    call_fail(context, "Native staged function metadata does not match its typed owner", definition.name)
  end

  local signature_matches
  if definition.signature == nil then
    signature_matches = payload.signature == nil and job.signature == nil and
      string_lists_equal(payload.params, definition.params) and
      string_lists_equal(job.params, definition.params) and
      payload.arity == definition.arity and job.arity == definition.arity and
      plain_equal(payload.parameter_kinds, definition.parameter_kinds) and
      spec_ast.parameter_kinds_equal(job.parameter_kinds, definition.parameter_kinds)
  else
    signature_matches = payload.params == nil and payload.arity == nil and
      payload.parameter_kinds == nil and job.params == nil and job.arity == nil and
      job.parameter_kinds == nil and
      plain_equal(payload.signature, spec_ast.to_json(definition.signature)) and
      spec_ast.callable_signatures_equal(job.signature, definition.signature)
  end
  if not signature_matches then
    call_fail(context, "Native staged function signature does not match its typed owner", definition.name)
  end
end

local function add_staged_artifacts(entry, function_source, records, relations, context)
  validate_staged_authority(entry, context)
  local definition = entry.definition
  local owner_id = function_id(definition.name)
  local rows = {
    { "payload", "action_source", "string" },
    { "parse_job", "action_program", "unknown" },
    { "result", "action_program", "unknown" },
  }
  local ids = {}
  for index, row in ipairs(rows) do
    local order = index - 1
    local artifact_kind = row[1]
    local id = "staged:" .. artifact_kind .. ":" .. owner_id .. ":" .. order
    ids[artifact_kind] = id
    records[#records + 1] = record(
      id,
      "staged_artifact",
      definition.name .. " body " .. (artifact_kind == "parse_job" and "parse job" or artifact_kind),
      owner_id,
      order,
      function_source,
      json.harray({
        artifact_kind = artifact_kind,
        payload_kind = "function_body",
        node_kind = row[2],
        parent_path = json.array({ owner_id }),
        parser_spec_id = "linkedspec-action-v1",
        top_rule = "FunctionBody",
        result_policy = "typed_action_program",
        failure_policy = "compile_diagnostic",
        status = "succeeded",
        value_shape = value_shape(row[3]),
      })
    )
    relations[#relations + 1] = relation(
      "contains", owner_id, id, order, function_source
    )
  end
  relations[#relations + 1] = relation(
    "lowered_from", ids.payload, SOURCE_ID, 0, function_source
  )
  relations[#relations + 1] = relation(
    "consumes", ids.parse_job, ids.payload, 0, function_source
  )
  relations[#relations + 1] = relation(
    "produces", ids.parse_job, ids.result, 0, function_source
  )
  relations[#relations + 1] = relation(
    "lowered_from", ids.result, ids.payload, 0, function_source
  )
  relations[#relations + 1] = relation(
    "staged_by", ids.result, ids.parse_job, 0, function_source
  )
end

local function validate_generated_plan(context)
  local compiled = context.outcome.compiled
  local selected = context.outcome.entry
  local plan = context.outcome.generated_plan
  if selected == nil or type(plan) ~= "table" or type(plan.rows) ~= "table" then
    call_fail(context, "Compiled call projection has no entry/generated-plan authority", SPEC_ID)
  end
  if plan.contract_id ~= "linkedspec-generated-source-v2" or plan.format_version ~= 2 or
      plan.source_identity ~= context.logical_name or #plan.rows ~= #compiled.compiled_rule_order then
    call_fail(context, "Retained generated plan does not match compiled semantic authority", SPEC_ID)
  end

  local selected_row = nil
  local selected_count = 0
  for index, label in ipairs(compiled.compiled_rule_order) do
    local row = plan.rows[index]
    if type(row) ~= "table" or row.label ~= label or
        type(row.family) ~= "string" or row.family == "" then
      call_fail(context, "Retained generated plan does not match compiled semantic authority", SPEC_ID)
    end
    if row.label == selected.label then
      selected_count = selected_count + 1
      selected_row = row
    end
  end
  if selected_count ~= 1 then
    call_fail(context, "Generated plan has no unique selected entry row", selected.label, {
      selected_rows = selected_count,
    })
  end
  return selected_row
end

local function add_generated_artifact(records, relations, context)
  local plan = context.outcome.generated_plan
  local selected_row = validate_generated_plan(context)
  local id = "generated:handler_plan:0"
  records[#records + 1] = record(
    id,
    "generated_artifact",
    "handler plan",
    SPEC_ID,
    0,
    nil,
    json.harray({
      artifact_kind = "handler_plan",
      contract_id = plan.contract_id,
      format_version = plan.format_version,
      plan_family = selected_row.family,
    })
  )
  relations[#relations + 1] = relation("generated_as", SPEC_ID, id, 0, nil)
end

local function add_function_record(entry, range, function_shapes, source_refs, records, relations, context, rule_count)
  local definition = entry.definition
  local id = function_id(definition.name)
  local source = register_source(source_refs, id, range, context)
  local signature, parameter_kinds = function_signature(definition)
  records[#records + 1] = record(
    id,
    "function",
    definition.name,
    SPEC_ID,
    entry.index,
    source,
    json.harray({
      signature = signature,
      parameter_kinds = parameter_kinds,
      return_shape = function_shapes[definition.name],
    })
  )
  relations[#relations + 1] = relation(
    "declares", SPEC_ID, id, rule_count + entry.index, source
  )
  return source
end

local function extend_call_core(context, scans_by_label, source_refs, records, relations)
  local compiled = context.outcome.compiled
  local functions = compiled.function_registry.entries
  if #functions == 0 then return end

  local typed_blocks = {}
  local body_ranges = {}
  local function_ranges = {}
  local functions_by_name = {}
  for _, entry in ipairs(functions) do
    local name = entry.definition.name
    typed_blocks[name] = typed_function_body(entry, compiled.function_registry, context)
    body_ranges[name] = function_body_range(entry, context)
    function_ranges[name] = function_range(entry, body_ranges[name], context)
    functions_by_name[name] = entry
  end
  local function_shapes = infer_function_shapes(functions, typed_blocks)
  for _, entry in ipairs(functions) do
    local function_source = add_function_record(
      entry,
      function_ranges[entry.definition.name],
      function_shapes,
      source_refs,
      records,
      relations,
      context,
      #compiled.compiled_rule_order
    )
    add_staged_artifacts(entry, function_source, records, relations, context)
  end

  local observed = {}
  for _, entry in ipairs(functions) do
    observed[#observed + 1] = {
      kind = "function",
      name = entry.definition.name,
      start = function_ranges[entry.definition.name].start,
    }
  end
  for _, scan in pairs(scans_by_label) do
    observed[#observed + 1] = {
      kind = "rule",
      name = scan.label,
      start = scan.header.start,
    }
  end
  table.sort(observed, function(left, right)
    if left.start ~= right.start then return left.start < right.start end
    if left.kind ~= right.kind then return left.kind == "function" end
    return left.name < right.name
  end)
  local authored = context.outcome.authored_definitions
  if type(authored) ~= "table" or #authored ~= #observed then
    call_fail(context, "Merged authored definition authority is incomplete", SPEC_ID)
  end
  local definition_order = json.array()
  for index, item in ipairs(authored) do
    local actual = observed[index]
    if item.kind ~= actual.kind or item.name ~= actual.name then
      call_fail(context, "Merged authored definition order differs from source ownership", SPEC_ID, {
        definition_index = index - 1,
      })
    end
    definition_order[index] = item.kind == "function" and function_id(item.name) or rule_id(item.name)
  end
  for _, item in ipairs(records) do
    if item.id == SPEC_ID then
      item.facts.definition_order = definition_order
      break
    end
  end

  local builder = {
    context = context,
    source_refs = source_refs,
    records = records,
    relations = relations,
    registry = compiled.function_registry,
    function_shapes = function_shapes,
    helper_ids = {},
    helper_count = 0,
    binding_by_owner_name = {},
    binding_counts = {},
    edge_value_shapes = {},
    global_call_order = 0,
  }
  local owners = call_action_owners(scans_by_label, compiled, context)
  local owners_by_rule = {}
  for _, owner in ipairs(owners) do
    owners_by_rule[owner.rule_label] = owners_by_rule[owner.rule_label] or {}
    owners_by_rule[owner.rule_label][#owners_by_rule[owner.rule_label] + 1] = owner
  end

  for _, item in ipairs(authored) do
    if item.kind == "function" then
      local entry = functions_by_name[item.name]
      if entry == nil then call_fail(context, "Authored function has no accepted registry owner", item.name) end
      local cursor = scan_call_sites(context.source, body_ranges[item.name], context)
      local local_order = { value = 0 }
      local variables = function_variables(entry)
      local owner_id = function_id(item.name)
      for _, statement in ipairs(typed_blocks[item.name].statements) do
        call_emit_statement(
          builder,
          statement.expr,
          owner_id,
          cursor,
          local_order,
          variables,
          true
        )
      end
    else
      for _, owner in ipairs(owners_by_rule[item.name] or {}) do
        local cursor = scan_call_sites(context.source, owner.source, context)
        local local_order = { value = 0 }
        local variables = {}
        for _, statement in ipairs(owner.block.statements) do
          call_emit_statement(
            builder,
            statement.expr,
            owner.owner_id,
            cursor,
            local_order,
            variables,
            false
          )
        end
      end
    end
  end
  apply_edge_shapes(builder)
  add_generated_artifact(records, relations, context)
end

local function canonicalize(records, relations)
  table.sort(records, function(left, right)
    local left_rank = RECORD_KIND_RANK[left.kind] or math.huge
    local right_rank = RECORD_KIND_RANK[right.kind] or math.huge
    if left_rank ~= right_rank then return left_rank < right_rank end
    if left.order ~= right.order then return left.order < right.order end
    return left.id < right.id
  end)
  local record_rank = {}
  for index, item in ipairs(records) do record_rank[item.id] = index end
  table.sort(relations, function(left, right)
    local left_from = record_rank[left.from_id] or math.huge
    local right_from = record_rank[right.from_id] or math.huge
    if left_from ~= right_from then return left_from < right_from end
    local left_kind = RELATION_KIND_RANK[left.kind] or math.huge
    local right_kind = RELATION_KIND_RANK[right.kind] or math.huge
    if left_kind ~= right_kind then return left_kind < right_kind end
    local left_to = record_rank[left.to_id] or math.huge
    local right_to = record_rank[right.to_id] or math.huge
    if left_to ~= right_to then return left_to < right_to end
    return left.id < right.id
  end)
end

local function build_compiled(context)
  local parsed = context.outcome.parsed
  local compiled = context.outcome.compiled
  local scans = scan_rules(context.source, parsed, context.fail)
  local scans_by_label = {}
  local parsed_by_label = {}
  for _, scan in ipairs(scans) do scans_by_label[scan.label] = scan end
  for _, rule in ipairs(parsed.rules) do parsed_by_label[rule.header.label] = rule end

  local source_refs = json.harray()
  local records = json.array()
  local relations = json.array()
  local record_sources = {}
  local definition_order = json.array()
  local compiled_order = json.array()
  for index, label in ipairs(compiled.definition_order) do definition_order[index] = rule_id(label) end
  for index, label in ipairs(compiled.compiled_rule_order) do compiled_order[index] = rule_id(label) end
  local selected = context.outcome.entry
  local selected_rule_id = selected and rule_id(selected.label) or nil

  records[#records + 1] = record(
    SPEC_ID,
    "spec",
    spec_name(context.logical_name),
    nil,
    0,
    nil,
    json.harray({
      definition_order = definition_order,
      compiled_rule_order = compiled_order,
      entry_rule_id = portable(selected_rule_id),
      entry_selection_basis = portable(selected and entry_basis(selected.basis) or nil),
    })
  )
  records[#records + 1] = source_record()

  for rule_offset, label in ipairs(compiled.compiled_rule_order) do
    local parsed_rule = parsed_by_label[label]
    local compiled_rule = compiled.rules_by_label[label]
    local scan = scans_by_label[label]
    if parsed_rule == nil or compiled_rule == nil or scan == nil then
      correlation_fail(context.fail, "Compiled rule has no matching parsed source owner", label)
    end
    local rule_order = rule_offset - 1
    local id = rule_id(label)
    local rule_source = register_source(source_refs, id, scan.header, context)
    record_sources[id] = rule_source
    local edges = project_edges(scan, compiled_rule, context.fail)
    local slots = project_regex_slots(scan, compiled_rule, context.fail)
    local lifecycles = project_lifecycles(scan, compiled_rule, context.fail)
    local repetition = neutral_repetition(parsed_rule.header.mode)
    local rep_min, rep_max = neutral_bounds(parsed_rule.header.mode)

    records[#records + 1] = record(
      id,
      "rule",
      label,
      SPEC_ID,
      rule_order,
      rule_source,
      json.harray({
        family = spec_ast.rule_mode_is_and(parsed_rule.header.mode) and "and" or "or",
        cursor_policy = spec_ast.rule_mode_is_and(parsed_rule.header.mode) and "contiguous" or "seek",
        is_entry_marker = parsed_rule.header.is_top,
        is_repetition = repetition,
        rep_min = portable(rep_min),
        rep_max = portable(rep_max),
        edge_ownership = edge_ownership(edges),
        value_shape = rule_value_shape(repetition, edges, lifecycles),
      })
    )

    for slot_offset, slot in ipairs(slots) do
      local slot_order = slot_offset - 1
      local slot_id = "regex:" .. id .. ":" .. slot_order
      local slot_source = register_source(source_refs, slot_id, slot.range, context)
      record_sources[slot_id] = slot_source
      records[#records + 1] = record(
        slot_id,
        "regex_slot",
        nil,
        id,
        slot_order,
        slot_source,
        json.harray({
          authored_index = slot_order,
          pattern = slot.regex,
          flags = slot.regex_flags,
          combined_owner_ids = json.array({ id }),
          target_shape = value_shape("regex_slot"),
        })
      )
    end

    for edge_offset, edge in ipairs(edges) do
      local edge_order = edge_offset - 1
      local edge_id = "edge:" .. id .. ":" .. edge_order
      local edge_source = register_source(source_refs, edge_id, edge.source, context)
      record_sources[edge_id] = edge_source
      records[#records + 1] = record(
        edge_id,
        "edge",
        nil,
        id,
        edge_order,
        edge_source,
        json.harray({
          ownership = edge.ownership,
          source_form = edge.target_index == nil and "direct" or "indexed",
          has_block = edge.has_block,
          fluent_call_ids = json.array(),
          value_shape = edge.value_shape,
          target_shape = value_shape(edge.target_index == nil and "rule" or "regex_slot"),
        })
      )
    end

    local marker_counts = {}
    for _, lifecycle in ipairs(lifecycles) do
      local marker_order = marker_counts[lifecycle.marker] or 0
      marker_counts[lifecycle.marker] = marker_order + 1
      local lifecycle_id = "lifecycle:" .. id .. ":" .. lifecycle.marker .. ":" .. marker_order
      local lifecycle_source = register_source(
        source_refs, lifecycle_id, lifecycle.member.range, context
      )
      record_sources[lifecycle_id] = lifecycle_source
      records[#records + 1] = record(
        lifecycle_id,
        "lifecycle",
        lifecycle.marker,
        id,
        marker_order,
        lifecycle_source,
        json.harray({
          marker = lifecycle.marker,
          whole_rule_return = lifecycle.marker == "E",
          value_shape = lifecycle.value_shape,
        })
      )
    end

    relations[#relations + 1] = relation("declares", SPEC_ID, id, rule_order, nil)
    local contains_order = 0
    for slot_offset = 1, #slots do
      local slot_id = "regex:" .. id .. ":" .. (slot_offset - 1)
      relations[#relations + 1] = relation(
        "contains", id, slot_id, contains_order, record_sources[slot_id]
      )
      contains_order = contains_order + 1
    end
    for edge_offset = 1, #edges do
      local edge_id = "edge:" .. id .. ":" .. (edge_offset - 1)
      relations[#relations + 1] = relation(
        "contains", id, edge_id, contains_order, record_sources[edge_id]
      )
      contains_order = contains_order + 1
    end
    marker_counts = {}
    for _, lifecycle in ipairs(lifecycles) do
      local marker_order = marker_counts[lifecycle.marker] or 0
      marker_counts[lifecycle.marker] = marker_order + 1
      local lifecycle_id = "lifecycle:" .. id .. ":" .. lifecycle.marker .. ":" .. marker_order
      relations[#relations + 1] = relation(
        "contains", id, lifecycle_id, contains_order, record_sources[lifecycle_id]
      )
      contains_order = contains_order + 1
    end
    for edge_offset, edge in ipairs(edges) do
      local edge_order = edge_offset - 1
      local edge_id = "edge:" .. id .. ":" .. edge_order
      local target_rule_id = rule_id(edge.target)
      local edge_source = record_sources[edge_id]
      if not (target_rule_id == id and edge.target_index ~= nil) then
        relations[#relations + 1] = relation(
          "dispatches_to", edge_id, target_rule_id, edge_order, edge_source
        )
      end
      if edge.target_index ~= nil then
        relations[#relations + 1] = relation(
          "selects_regex",
          edge_id,
          "regex:" .. target_rule_id .. ":" .. edge.target_index,
          edge_order,
          edge_source
        )
      end
    end
  end

  relations[#relations + 1] = relation("contains", SPEC_ID, SOURCE_ID, 0, nil)
  extend_call_core(context, scans_by_label, source_refs, records, relations)
  if #parsed.functions == 0 and #compiled.compiled_rule_order > 1 and selected ~= nil then
    add_entry_explanation(records, relations, selected, record_sources[rule_id(selected.label)])
  end
  canonicalize(records, relations)
  local snapshot = json.harray({
    id = "snapshot:0",
    state = "compiled",
    has_execution = false,
    source_detail_ceiling = context.source_detail_ceiling,
    content_digest_available = context.source_detail_ceiling == "text",
  })
  return freeze(json.harray({
    snapshot = snapshot,
    source_refs = source_refs,
    records = records,
    relations = relations,
  }), context.fail)
end

local function scan_edge_ownership(scan)
  if scan == nil then return "none" end
  local edges = {}
  for _, member in ipairs(scan.members) do
    for _, edge in ipairs(member.edges) do edges[#edges + 1] = edge end
  end
  return edge_ownership(edges)
end

local function member_for_target(scan, target)
  if scan == nil then return nil end
  for _, member in ipairs(scan.members) do
    for _, edge in ipairs(member.edges) do
      if edge.target == target then return member end
    end
  end
  return nil
end

local function normalize_failure(diagnostic)
  local actual = diagnostic or {
    code = "semantic_index_compilation_failed",
    stage = "compile_source",
    message = "Spec compilation failed.",
    fields = json.harray(),
  }
  local fields = actual.fields or json.harray()
  local rule_label = type(fields.rule_label) == "string" and fields.rule_label or nil
  local target = fields.target
  if type(target) ~= "string" then target = fields.target_rule end
  if type(target) ~= "string" then target = nil end
  if (actual.code == "bare_edge_target_undefined" or
      actual.code == "regex_slot_identity_invalid") and
      rule_label ~= nil and target ~= nil then
    return {
      code = "unknown_rule_reference",
      stage = "compile",
      message = "Rule " .. rule_label .. " references unknown rule " .. target .. ".",
      fields = json.harray({
        rule_id = rule_id(rule_label),
        missing_rule_id = rule_id(target),
      }),
      rule_label = rule_label,
      target = target,
    }
  end
  return {
    code = actual.code,
    stage = actual.stage,
    message = actual.message,
    fields = fields,
    rule_label = rule_label,
    target = target,
  }
end

local function build_failed(context)
  local parsed = context.outcome.parsed
  local rules = parsed and parsed.rules or {}
  local scans = parsed and scan_rules(context.source, parsed, context.fail) or {}
  local scans_by_label = {}
  for _, scan in ipairs(scans) do scans_by_label[scan.label] = scan end

  local normalized = normalize_failure(context.outcome.diagnostic)
  local failed_label = normalized.rule_label
  if failed_label == nil and rules[1] ~= nil then failed_label = rules[1].header.label end
  local failed_rule_id = failed_label and rule_id(failed_label) or nil
  local failed_scan = failed_label and scans_by_label[failed_label] or nil
  local source_refs = json.harray()
  local records = json.array()
  local relations = json.array()
  local definition_order = json.array()
  for index, rule in ipairs(rules) do definition_order[index] = rule_id(rule.header.label) end

  records[#records + 1] = record(
    SPEC_ID,
    "spec",
    spec_name(context.logical_name),
    nil,
    0,
    nil,
    json.harray({
      definition_order = definition_order,
      compiled_rule_order = json.array(),
      entry_rule_id = json.null,
      entry_selection_basis = json.null,
    })
  )
  records[#records + 1] = source_record()

  for rule_offset, rule in ipairs(rules) do
    local rule_order = rule_offset - 1
    local id = rule_id(rule.header.label)
    local scan = scans_by_label[rule.header.label]
    local source = scan and register_source(source_refs, id, scan.header, context) or nil
    local repetition = neutral_repetition(rule.header.mode)
    local rep_min, rep_max = neutral_bounds(rule.header.mode)
    records[#records + 1] = record(
      id,
      "rule",
      rule.header.label,
      SPEC_ID,
      rule_order,
      source,
      json.harray({
        family = spec_ast.rule_mode_is_and(rule.header.mode) and "and" or "or",
        cursor_policy = spec_ast.rule_mode_is_and(rule.header.mode) and "contiguous" or "seek",
        is_entry_marker = rule.header.is_top,
        is_repetition = repetition,
        rep_min = portable(rep_min),
        rep_max = portable(rep_max),
        edge_ownership = scan_edge_ownership(scan),
        value_shape = value_shape("unknown"),
      })
    )
  end

  local diagnostic_id = "diagnostic:compile:0"
  local diagnostic_member = member_for_target(failed_scan, normalized.target)
  local diagnostic_source = diagnostic_member and register_source(
    source_refs, diagnostic_id, diagnostic_member.range, context
  ) or nil
  records[#records + 1] = record(
    diagnostic_id,
    "diagnostic",
    normalized.code,
    SPEC_ID,
    0,
    diagnostic_source,
    json.harray({
      code = normalized.code,
      stage = normalized.stage,
      severity = "error",
      message = normalized.message,
      fields = normalized.fields,
    })
  )
  relations[#relations + 1] = relation("contains", SPEC_ID, SOURCE_ID, 0, nil)
  relations[#relations + 1] = relation(
    "contains", SPEC_ID, diagnostic_id, 1, diagnostic_source
  )

  if normalized.code == "unknown_rule_reference" and failed_label ~= nil and
      failed_rule_id ~= nil and normalized.target ~= nil then
    local decision_id = "decision:compile:" .. failed_rule_id
    local explanation_id = "explanation:" .. decision_id .. ":0"
    records[#records + 1] = record(
      decision_id,
      "decision",
      "compile rule " .. failed_label,
      failed_rule_id,
      0,
      diagnostic_source,
      json.harray({
        decision_kind = "dependency_resolution",
        outcome = diagnostic_id,
      })
    )
    records[#records + 1] = record(
      explanation_id,
      "explanation_step",
      nil,
      decision_id,
      0,
      diagnostic_source,
      json.harray({
        rule_code = "dependency_target_missing",
        summary = "The authored dependency " .. normalized.target .. " has no declared rule.",
        input_ids = json.array({ failed_rule_id }),
        output_fact = json.harray({
          record_id = decision_id,
          path = "/facts/outcome",
          value = diagnostic_id,
        }),
      })
    )
    relations[#relations + 1] = relation(
      "diagnoses", diagnostic_id, failed_rule_id, 0, diagnostic_source
    )
    relations[#relations + 1] = relation(
      "explained_by",
      decision_id,
      explanation_id,
      0,
      diagnostic_source,
      json.array({ diagnostic_id })
    )
  end

  canonicalize(records, relations)
  local snapshot = json.harray({
    id = "snapshot:0",
    state = "failed_compilation",
    has_execution = false,
    source_detail_ceiling = context.source_detail_ceiling,
    content_digest_available = context.source_detail_ceiling == "text",
  })
  return freeze(json.harray({
    snapshot = snapshot,
    source_refs = source_refs,
    records = records,
    relations = relations,
  }), context.fail)
end

function M.build(options)
  if options.outcome.compiled ~= nil then return build_compiled(options) end
  return build_failed(options)
end

function M.materialize(projection, fail)
  if FROZEN_STATE[projection] == nil then
    correlation_fail(fail, "Semantic index has no valid static projection", "projection")
  end
  return thaw(projection)
end

-- Package-private finalizer for projections derived from one detached static
-- materialization. Runtime derivation owns validation and new records; this
-- static owner remains the single authority for canonical ordering and the
-- recursively immutable projection representation.
function M._freeze_derived_projection(projection, fail)
  if type(projection) ~= "table" or type(projection.records) ~= "table" or
      type(projection.relations) ~= "table" then
    correlation_fail(fail, "Derived semantic projection is malformed", "projection")
  end
  canonicalize(projection.records, projection.relations)
  return freeze(projection, fail)
end

-- Package-private corruption probes used by the exact staged/generated suite.
function M._validate_staged_authority_for_testing(entry, fail)
  validate_staged_authority(entry, { fail = fail })
  return true
end

function M._validate_generated_plan_for_testing(logical_name, compiled, entry, plan, fail)
  return validate_generated_plan({
    logical_name = logical_name,
    outcome = { compiled = compiled, entry = entry, generated_plan = plan },
    fail = fail,
  })
end

return M
