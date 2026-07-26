-- Package-private immutable static semantic projection.
--
-- This module consumes only the source map and the parsed/compiled/entry
-- authorities already retained by semantic_index. It does not parse, compile,
-- select, plan, load, execute, trace, or observe anything.

local action_ast = require("linkedspec.action_ast")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")

local M = {}

local SPEC_ID = "spec:0"
local SOURCE_ID = "source:0"

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

function M.build(options)
  if options.outcome.compiled == nil then return nil end
  return build_compiled(options)
end

function M.materialize(projection, fail)
  if FROZEN_STATE[projection] == nil then
    correlation_fail(fail, "Semantic index has no valid static projection", "projection")
  end
  return thaw(projection)
end

return M
