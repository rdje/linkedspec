local action_ast = require("linkedspec.action_ast")
local action_contracts = require("linkedspec.action_contracts")
local action_parser = require("linkedspec.action_parser")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")
local spec_validator = require("linkedspec.spec_validator")
local trace = require("linkedspec.trace")
local trace_support = require("linkedspec.trace_support")
local user_function_registry = require("linkedspec.user_function_registry")

local M = {}

M.ENTRY_RULE_CONTRACT_ID = "linkedspec-root-rule-selection-v1"
M.RULE_LOCAL_CURSOR_CONTRACT_ID = "linkedspec-rule-local-cursor-v1"
M.REGEX_SLOT_IDENTITY_CONTRACT_ID = "linkedspec-duplicate-regex-slot-identity-v1"

local ENTRY_RULE_SELECTION_BASES = {
  explicit_selector = true,
  first_authored_marker = true,
  first_authored_rule = true,
}

local ERROR_MT = {
  __tostring = function(value)
    return "CompiledSpecException: " .. value.message
  end,
}

local ENTRY_RULE_SELECTION_ERROR_MT = {
  __compiled_spec_type = "EntryRuleSelectionException",
  __tostring = function(value)
    return "EntryRuleSelectionException: " .. value.message
  end,
}

local TYPE_MTS = {}

local function type_metatable(name, methods)
  local metatable = { __compiled_spec_type = name, __index = methods }
  TYPE_MTS[name] = metatable
  return metatable
end

local CompiledSpecMethods = {}
local COMPILED_SPEC_MT = type_metatable("CompiledSpec", CompiledSpecMethods)
local COMPILED_RULE_MT = type_metatable("CompiledRule")
local MODE_METADATA_MT = type_metatable("CompiledRuleModeMetadata")
local DEPENDENCY_REF_MT = type_metatable("DependencyRef")
local ACTION_EDGE_MT = type_metatable("CompiledActionEdge")
local BLIND_EDGE_MT = type_metatable("CompiledBlindEdge")
local ACTION_PAYLOAD_MT = type_metatable("CompiledActionPayload")
local RULE_SLOT_EVENT_MT = type_metatable("CompiledRuleSlotEvent")
local REGEX_SLOT_MT = type_metatable("CompiledRegexSlot")
local CAPTURE_GAPS_MT = type_metatable("CompiledCaptureGaps")
local DEPENDENCY_ENTRY_MT = type_metatable("CompiledDependencyRegexEntry")
local DEPENDENCY_STATE_MT = type_metatable("CompiledDependencyRegexState")
local DESCRIPTOR_STATE_MT = type_metatable("CompiledDescriptorState")
local RESOLVED_ENTRY_RULE_MT = type_metatable("ResolvedEntryRule")

local function fail(message, fields)
  fields = fields or {}
  fields.message = message
  error(setmetatable(fields, ERROR_MT), 0)
end

function M.is_compiled_spec_error(value)
  return getmetatable(value) == ERROR_MT
end

function M.is_entry_rule_selection_error(value)
  return getmetatable(value) == ENTRY_RULE_SELECTION_ERROR_MT
end

function M.node_type(value)
  if type(value) ~= "table" then return nil end
  local metatable = getmetatable(value)
  return metatable and metatable.__compiled_spec_type or nil
end

local function copy_list(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function entry_rule_selection_fail(code, stage, message, entry_rule)
  error(setmetatable({
    code = code,
    stage = stage,
    message = message,
    entry_rule = entry_rule,
  }, ENTRY_RULE_SELECTION_ERROR_MT), 0)
end

function M.entry_rule_selection_basis_name(basis)
  if type(basis) ~= "string" or not ENTRY_RULE_SELECTION_BASES[basis] then
    fail("unknown entry-rule selection basis")
  end
  return basis
end

function M.entry_rule_selection_error_to_json(value)
  if not M.is_entry_rule_selection_error(value) then
    fail("entry_rule_selection_error_to_json expects EntryRuleSelectionException")
  end
  local fields = json.harray()
  if value.entry_rule ~= nil then fields.entry_rule = value.entry_rule end
  return json.harray({
    code = value.code,
    stage = value.stage,
    message = value.message,
    fields = fields,
  })
end

local function typed_array(values, project)
  local result = json.array()
  for index, value in ipairs(values) do
    result[index] = project and project(value) or value
  end
  return result
end

local function dependency_ref(label, index)
  return setmetatable({ label = label, index = index }, DEPENDENCY_REF_MT)
end

local function mode_metadata(header)
  return setmetatable({
    name = header.mode.name,
    is_top = header.is_top,
    is_and = spec_ast.rule_mode_is_and(header.mode),
    is_repetition = spec_ast.rule_mode_is_repetition(header.mode),
    rep_min = spec_ast.rule_mode_rep_min(header.mode),
    rep_max = spec_ast.rule_mode_rep_max(header.mode),
  }, MODE_METADATA_MT)
end

local function action_payload(role, element, code, registry, lifecycle)
  local ast = action_parser.parse_action_block(code)
  return setmetatable({
    role = role,
    line = element.line,
    source = element.source,
    code = code,
    lifecycle = lifecycle,
    action_ast = ast,
    contracts = action_contracts.resolve_action_block_contracts(ast, { function_registry = registry }),
  }, ACTION_PAYLOAD_MT)
end

local function fluent_chain_action_code(fluent_chain)
  if #fluent_chain == 0 then return nil end
  local statements = {}
  for index, call in ipairs(fluent_chain) do
    local args = call.args:match("^%s*(.-)%s*$")
    statements[index] = args == "" and (call.method .. "()") or (call.method .. "(" .. args .. ")")
  end
  return table.concat(statements, "; ")
end

local function optional_action_payload(role, element, source_code, fluent_chain, registry)
  local code = source_code or fluent_chain_action_code(fluent_chain)
  if code == nil or code:match("^%s*$") then return nil end
  return action_payload(role, element, code, registry)
end

local function rule_slot_event(rule_label, element, regex_index)
  local marker = element.kind.marker
  local capture_marker = marker:match("^@[ \t]*(capture_slice)[ \t]*$") or
    marker:match("^@[ \t]*(capture_from_here)[ \t]*$") or
    marker:match("^@[ \t]*(move_pos)[ \t]*$")
  local mark_name = marker:match(
    "^@[ \t]*mark[ \t]*%([ \t]*([A-Za-z_][A-Za-z0-9_]*)[ \t]*%)[ \t]*$"
  )
  if capture_marker == nil and mark_name == nil then
    fail("rule '" .. rule_label .. "' has malformed split marker '" .. marker .. "'", {
      code = "malformed_rule_slot_marker",
      rule_label = rule_label,
      line = element.line,
      marker = marker,
    })
  end
  return setmetatable({
    kind = mark_name == nil and "capture_boundary" or "named_mark",
    marker = marker,
    mark_name = mark_name,
    regex_index = regex_index,
    line = element.line,
    source = element.source,
  }, RULE_SLOT_EVENT_MT)
end

local function target_slot_id(rules_by_label, label, index)
  local target_rule = rules_by_label[label]
  if target_rule == nil then return nil end
  local regex_index = 0
  for _, element in ipairs(target_rule.body) do
    if spec_ast.node_type(element.kind) == "RegexBodyElementKind" then
      if regex_index == index then return element.kind.slot_id end
      regex_index = regex_index + 1
    end
  end
  return nil
end

local function compile_rule(rule, registry, rules_by_label, source_id)
  local regex_patterns = {}
  local regex_slots = {}
  local dependency_refs = {}
  local action_edges = {}
  local blind_edges = {}
  local lifecycle_action_payloads = {}
  local plain_action_payloads = {}
  local rule_slot_events = {}
  local capture_gaps = nil
  local last_regex_line = nil

  for _, element in ipairs(rule.body) do
    local kind = element.kind
    local node_type = spec_ast.node_type(kind)
    if node_type == "RegexBodyElementKind" then
      regex_patterns[#regex_patterns + 1] = kind.pattern
      regex_slots[#regex_slots + 1] = setmetatable({
        regex_index = #regex_slots,
        slot_id = kind.slot_id,
        source_id = source_id,
        line = element.line,
      }, REGEX_SLOT_MT)
      last_regex_line = element.line
    elseif node_type == "CaptureGapsDirectiveBodyElementKind" then
      capture_gaps = setmetatable({
        enabled = true,
        directive = kind.directive,
        source_id = source_id,
        line = element.line,
      }, CAPTURE_GAPS_MT)
    elseif node_type == "ActionEdgeBodyElementKind" then
      local has_parent_regex = last_regex_line == element.line and #regex_patterns > 0
      local regex_index = has_parent_regex and (#regex_patterns - 1) or 0
      local payload = optional_action_payload("action_edge", element, kind.code, kind.fluent_chain, registry)
      for _, target in ipairs(kind.targets) do
        local ref = dependency_ref(target.label, target.index)
        dependency_refs[#dependency_refs + 1] = ref
        action_edges[#action_edges + 1] = setmetatable({
          line = element.line,
          source = element.source,
          targets = { ref },
          regex_index = regex_index,
          child_regex_index = target.index,
          selector_kind = target.selector_kind,
          authored_selector = target.authored_selector,
          target_slot_id = target_slot_id(rules_by_label, target.label, target.index),
          has_parent_regex = has_parent_regex,
          code = kind.code,
          fluent_chain = copy_list(kind.fluent_chain),
          action_payload = payload,
        }, ACTION_EDGE_MT)
      end
      last_regex_line = nil
    elseif node_type == "BlindEdgeBodyElementKind" then
      local ref = dependency_ref(kind.target, kind.index or 0)
      dependency_refs[#dependency_refs + 1] = ref
      blind_edges[#blind_edges + 1] = setmetatable({
        line = element.line,
        source = element.source,
        target = ref,
        code = kind.code,
        fluent_chain = copy_list(kind.fluent_chain),
        action_payload = optional_action_payload("blind_edge", element, kind.code, kind.fluent_chain, registry),
      }, BLIND_EDGE_MT)
      last_regex_line = nil
    elseif node_type == "BareEdgeBodyElementKind" then
      local payload_role = spec_ast.rule_mode_is_and(rule.header.mode) and "blind_edge" or "action_edge"
      local payload = optional_action_payload(payload_role, element, kind.code, kind.fluent_chain, registry)
      if spec_ast.rule_mode_is_and(rule.header.mode) then
        for _, target in ipairs(kind.targets) do
          local ref = dependency_ref(target.label, target.index or 0)
          dependency_refs[#dependency_refs + 1] = ref
          blind_edges[#blind_edges + 1] = setmetatable({
            line = element.line,
            source = element.source,
            target = ref,
            code = kind.code,
            fluent_chain = copy_list(kind.fluent_chain),
            action_payload = payload,
          }, BLIND_EDGE_MT)
        end
      else
        local has_parent_regex = last_regex_line == element.line and #regex_patterns > 0
        local regex_index = has_parent_regex and (#regex_patterns - 1) or 0
        for _, target in ipairs(kind.targets) do
          local child_regex_index = target.index or 0
          local ref = dependency_ref(target.label, child_regex_index)
          dependency_refs[#dependency_refs + 1] = ref
          action_edges[#action_edges + 1] = setmetatable({
            line = element.line,
            source = element.source,
            targets = { ref },
            regex_index = regex_index,
            child_regex_index = child_regex_index,
            selector_kind = target.selector_kind,
            authored_selector = target.authored_selector,
            target_slot_id = target_slot_id(rules_by_label, target.label, child_regex_index),
            has_parent_regex = has_parent_regex,
            code = kind.code,
            fluent_chain = copy_list(kind.fluent_chain),
            action_payload = payload,
          }, ACTION_EDGE_MT)
        end
      end
      last_regex_line = nil
    elseif node_type == "CodeBlockBodyElementKind" then
      lifecycle_action_payloads[#lifecycle_action_payloads + 1] = action_payload(
        "lifecycle",
        element,
        kind.code,
        registry,
        kind.lifecycle
      )
      last_regex_line = nil
    elseif node_type == "PlainBlockBodyElementKind" then
      plain_action_payloads[#plain_action_payloads + 1] = action_payload(
        "plain_block",
        element,
        kind.code,
        registry
      )
      last_regex_line = nil
    elseif node_type == "SplitMarkerBodyElementKind" then
      rule_slot_events[#rule_slot_events + 1] = rule_slot_event(
        rule.header.label,
        element,
        math.max(#regex_patterns - 1, 0)
      )
    else
      last_regex_line = nil
    end
  end

  return setmetatable({
    label = rule.header.label,
    header = rule.header,
    mode_metadata = mode_metadata(rule.header),
    regex_patterns = regex_patterns,
    regex_slots = regex_slots,
    capture_gaps = capture_gaps,
    dependency_refs = dependency_refs,
    action_edges = action_edges,
    blind_edges = blind_edges,
    lifecycle_action_payloads = lifecycle_action_payloads,
    plain_action_payloads = plain_action_payloads,
    rule_slot_events = rule_slot_events,
    body_elements = copy_list(rule.body),
  }, COMPILED_RULE_MT)
end

local function copy_action_edge(edge, regex_index)
  return setmetatable({
    line = edge.line,
    source = edge.source,
    targets = copy_list(edge.targets),
    regex_index = regex_index,
    child_regex_index = edge.child_regex_index,
    selector_kind = edge.selector_kind,
    authored_selector = edge.authored_selector,
    target_slot_id = edge.target_slot_id,
    has_parent_regex = edge.has_parent_regex,
    code = edge.code,
    fluent_chain = copy_list(edge.fluent_chain),
    action_payload = edge.action_payload,
  }, ACTION_EDGE_MT)
end

local function copy_compiled_rule(rule, regex_patterns, action_edges)
  return setmetatable({
    label = rule.label,
    header = rule.header,
    mode_metadata = rule.mode_metadata,
    regex_patterns = regex_patterns or copy_list(rule.regex_patterns),
    regex_slots = copy_list(rule.regex_slots),
    capture_gaps = rule.capture_gaps,
    dependency_refs = copy_list(rule.dependency_refs),
    action_edges = action_edges or copy_list(rule.action_edges),
    blind_edges = copy_list(rule.blind_edges),
    lifecycle_action_payloads = copy_list(rule.lifecycle_action_payloads),
    plain_action_payloads = copy_list(rule.plain_action_payloads),
    rule_slot_events = copy_list(rule.rule_slot_events),
    body_elements = copy_list(rule.body_elements),
  }, COMPILED_RULE_MT)
end

local function last_definition_order(definition_order)
  local seen = {}
  local reversed = {}
  for index = #definition_order, 1, -1 do
    local label = definition_order[index]
    if not seen[label] then
      seen[label] = true
      reversed[#reversed + 1] = label
    end
  end
  local result = {}
  for index = #reversed, 1, -1 do result[#result + 1] = reversed[index] end
  return result
end

local function resolve_action_edge_dependency_regexes(order, rules_by_label)
  local resolved = {}
  for label, rule in pairs(rules_by_label) do resolved[label] = rule end
  for _, label in ipairs(order) do
    local rule = resolved[label]
    local patterns = copy_list(rule.regex_patterns)
    local action_edges = {}
    for _, edge in ipairs(rule.action_edges) do
      if edge.has_parent_regex then
        action_edges[#action_edges + 1] = edge
      else
        local target = edge.targets[1]
        if target.label == label then
          if target.index < 0 or target.index >= #patterns then
            fail(
              "rule '" .. label .. "' references its own regex slot " .. target.index ..
                ", but the rule has " .. #patterns .. " parent regex slot(s)",
              { rule_label = label, target_label = target.label, regex_index = target.index }
            )
          end
          action_edges[#action_edges + 1] = copy_action_edge(edge, target.index)
        else
          local child = resolved[target.label] or rules_by_label[target.label]
          if not child then
            fail(
              "rule '" .. label .. "' references undefined rule '" .. target.label .. "'",
              { rule_label = label, target_label = target.label }
            )
          end
          if target.index < 0 or target.index >= #child.regex_patterns then
            fail(
              "rule '" .. label .. "' references rule '" .. target.label .. "' regex slot " .. target.index ..
                ", but that rule has " .. #child.regex_patterns .. " regex slot(s)",
              { rule_label = label, target_label = target.label, regex_index = target.index }
            )
          end
          local regex_index = #patterns
          patterns[#patterns + 1] = child.regex_patterns[target.index + 1]
          action_edges[#action_edges + 1] = copy_action_edge(edge, regex_index)
        end
      end
    end
    resolved[label] = copy_compiled_rule(rule, patterns, action_edges)
  end
  return resolved
end

local function dependency_pattern_for(owner_label, ref, rules_by_label)
  local target = rules_by_label[ref.label]
  if not target then
    fail(
      "rule '" .. owner_label .. "' references undefined rule '" .. ref.label .. "'",
      { rule_label = owner_label, target_label = ref.label }
    )
  end
  if ref.index < 0 or ref.index >= #target.regex_patterns then
    fail(
      "rule '" .. owner_label .. "' references rule '" .. ref.label .. "' regex slot " .. ref.index ..
        ", but that rule has " .. #target.regex_patterns .. " regex slot(s)",
      { rule_label = owner_label, target_label = ref.label, regex_index = ref.index }
    )
  end
  return target.regex_patterns[ref.index + 1]
end

local function build_dependency_regex_state(order, rules_by_label)
  local dependency_regex_map = {}
  for _, label in ipairs(order) do
    local rule = rules_by_label[label]
    if #rule.dependency_refs > 0 then
      local patterns = {}
      for index, ref in ipairs(rule.dependency_refs) do
        patterns[index] = dependency_pattern_for(label, ref, rules_by_label)
      end
      dependency_regex_map[label] = setmetatable({
        owner_label = label,
        dependency_refs = copy_list(rule.dependency_refs),
        patterns = patterns,
      }, DEPENDENCY_ENTRY_MT)
    end
  end
  return setmetatable({ dependency_regex_map = dependency_regex_map }, DEPENDENCY_STATE_MT)
end

local function validate_selector_block(block, context)
  local selector = action_ast.find_removed_aggregate_selector(block)
  if not selector then return end
  local diagnostic = action_ast.removed_aggregate_selector_diagnostic(selector)
  fail(context .. ": " .. diagnostic, {
    code = "aggregate_selector_removed",
    surface = selector.surface,
    identifier = selector.identifier,
    replacement = selector.identifier,
  })
end

local function validate_deferred_selector_source(source, context)
  local ok, block = pcall(action_parser.parse_action_block, source)
  if ok then validate_selector_block(block, context) end
end

local function validate_fluent_selectors(calls, context)
  for index, call in ipairs(calls) do
    local args = call.args:match("^%s*(.-)%s*$")
    local source = args == "" and (call.method .. "()") or (call.method .. "(" .. args .. ")")
    validate_deferred_selector_source(source, context .. " fluent call " .. (index - 1))
  end
end

local function validate_no_removed_aggregate_selectors(compiled)
  for _, entry in ipairs(compiled.function_registry.entries) do
    validate_deferred_selector_source(
      entry.definition.body_source,
      "function '" .. entry.definition.name .. "' body"
    )
  end
  for _, label in ipairs(compiled.compiled_rule_order) do
    local rule = compiled.rules_by_label[label]
    for _, payload in ipairs(M.action_payloads(rule)) do
      validate_selector_block(
        payload.action_ast,
        "rule '" .. label .. "' " .. payload.role .. " line " .. payload.line
      )
    end
    for index, edge in ipairs(rule.action_edges) do
      validate_fluent_selectors(edge.fluent_chain, "rule '" .. label .. "' action edge " .. (index - 1))
    end
    for index, edge in ipairs(rule.blind_edges) do
      validate_fluent_selectors(edge.fluent_chain, "rule '" .. label .. "' blind edge " .. (index - 1))
    end
  end
end

local function validate_nested_write_serialized_state(compiled)
  local function invalid(context, reason)
    fail("nested_write_serialized_state_invalid: " .. context .. " " .. reason, {
      code = "nested_write_serialized_state_invalid",
    })
  end

  local function visit(value, context)
    if type(value) ~= "table" then return end
    if value.kind == "assign_nested_access" then
      if action_ast.node_type(value) ~= "ActionExpr" then
        invalid(context, "must be one typed assign_nested_access expression")
      end
      if type(value.base) ~= "string" or not value.base:match("^[A-Za-z_][A-Za-z0-9_]*$") then
        invalid(context .. ".base", "must be one bare identifier")
      end
      if action_parser.is_nested_write_reserved_root(value.base) then
        invalid(context .. ".base", "must not be a reserved binding")
      end
      if type(value.segments) ~= "table" or #value.segments == 0 then
        invalid(context, "must contain at least one typed path_segment")
      end
      for index, segment in ipairs(value.segments) do
        local segment_context = context .. ".segments[" .. (index - 1) .. "]"
        if action_ast.node_type(segment) ~= "ActionWritePathSegment" or
            segment.kind ~= "path_segment" or
            type(segment.source) ~= "string" or segment.source == "" or
            action_ast.node_type(segment.source_span) ~= "ActionSourceSpan" or
            action_ast.node_type(segment.expression) ~= "ActionExpr" then
          invalid(segment_context, "must be one typed path_segment")
        end
      end
      if action_ast.node_type(value.value) ~= "ActionExpr" then
        invalid(context .. ".value", "must be one typed ActionExpr")
      end
    end
    for key, child in pairs(value) do
      if key ~= "source_span" then visit(child, context .. "." .. tostring(key)) end
    end
  end

  for _, label in ipairs(compiled.compiled_rule_order) do
    local rule = compiled.rules_by_label[label]
    for index, payload in ipairs(M.action_payloads(rule)) do
      visit(payload.action_ast, label .. ".action_payloads[" .. (index - 1) .. "]")
    end
  end
end

local function validate_receiver_mutation_serialized_state(compiled)
  local function invalid(context, reason)
    fail("receiver_mutation_serialized_state_invalid: " .. context .. " " .. reason, {
      code = "receiver_mutation_serialized_state_invalid",
    })
  end

  local function typed_span(value)
    return action_ast.node_type(value) == "ActionSourceSpan" and
      type(value.start) == "number" and type(value["end"]) == "number" and
      value.start % 1 == 0 and value["end"] % 1 == 0 and
      value.start >= 0 and value["end"] >= value.start
  end

  local function visit(value, context)
    if type(value) ~= "table" then return end
    local receiver_mutation_shape = value.kind == "receiver_mutation_chain" or
      action_ast.node_type(value.receiver) == "ActionReceiverMutationBindingReference" or
      action_ast.node_type(value.mutation) == "ActionReceiverMutationCall"
    if receiver_mutation_shape then
      if action_ast.node_type(value) ~= "ActionExpr" then
        invalid(context, "must be one typed receiver_mutation_chain expression")
      end
      if value.kind ~= "receiver_mutation_chain" then
        invalid(context, "must retain receiver_mutation_chain kind")
      end
      if type(value.source) ~= "string" or value.source == "" or not typed_span(value.source_span) then
        invalid(context, "must retain authored source and one typed source span")
      end

      local receiver = value.receiver
      if action_ast.node_type(receiver) ~= "ActionReceiverMutationBindingReference" or
          receiver.kind ~= "binding_reference" or type(receiver.name) ~= "string" or
          not receiver.name:match("^[A-Za-z_][A-Za-z0-9_]*$") or
          action_parser.is_nested_write_reserved_root(receiver.name) or
          receiver.source ~= receiver.name or not typed_span(receiver.source_span) then
        invalid(context .. ".receiver", "must be one typed non-reserved bare binding_reference")
      end

      local mutation = value.mutation
      if action_ast.node_type(mutation) ~= "ActionReceiverMutationCall" or
          mutation.kind ~= "receiver_mutation_call" or mutation.method ~= "map_leaves" or
          mutation.source_method ~= "map_leaves!" or type(mutation.source) ~= "string" or
          mutation.source == "" or not typed_span(mutation.source_span) or
          not typed_span(mutation.method_span) or not typed_span(mutation.args_span) then
        invalid(context .. ".mutation", "must be the typed map_leaves! receiver_mutation_call")
      end

      local callback = mutation.callback
      if action_ast.node_type(callback) ~= "ActionReceiverMutationCallback" or
          callback.kind ~= "block_value" or type(callback.source) ~= "string" or
          callback.source == "" or not typed_span(callback.source_span) or
          action_ast.node_type(callback.body) ~= "ActionBlock" then
        invalid(context .. ".mutation.callback", "must retain one typed callback block")
      end

      if type(value.continuation) ~= "table" then
        invalid(context .. ".continuation", "must be a typed continuation list")
      end
      for index, call in ipairs(value.continuation) do
        local call_context = context .. ".continuation[" .. (index - 1) .. "]"
        if action_ast.node_type(call) ~= "ActionReceiverMutationContinuationCall" or
            call.kind ~= "fluent_call" or type(call.method) ~= "string" or
            not call.method:match("^[A-Za-z_][A-Za-z0-9_]*$") or
            call.source_method ~= call.method or type(call.source) ~= "string" or
            type(call.args_source) ~= "string" or type(call.args) ~= "table" or
            not typed_span(call.source_span) or not typed_span(call.args_span) then
          invalid(call_context, "must be one typed non-bang fluent continuation")
        end
      end
    end
    for key, child in pairs(value) do
      if key ~= "source_span" and key ~= "method_span" and key ~= "args_span" then
        visit(child, context .. "." .. tostring(key))
      end
    end
  end

  for _, label in ipairs(compiled.compiled_rule_order) do
    local rule = compiled.rules_by_label[label]
    for index, payload in ipairs(M.action_payloads(rule)) do
      visit(payload.action_ast, label .. ".action_payloads[" .. (index - 1) .. "]")
    end
  end
end

local function recursive_observation_effects(value, function_names)
  local effects = {
    writes_observation = false,
    rule_calls = {},
    function_calls = {},
    recognition_attempts = {},
    observed_rules = {},
  }

  local function visit(node)
    if type(node) ~= "table" then return end
    local kind = node.kind
    if kind == "observe_recognition" then
      effects.writes_observation = true
      if type(node.rule) == "string" then effects.observed_rules[node.rule] = true end
    elseif kind == "recognize_once" then
      if type(node.rule) == "string" then effects.recognition_attempts[node.rule] = true end
    elseif kind == "call" then
      if node.name == "call" and type(node.args) == "table" and #node.args == 1 then
        local argument = node.args[1]
        if type(argument) == "table" and argument.kind == "variable" and
            type(argument.name) == "string" then
          effects.rule_calls[argument.name] = true
        end
      elseif type(node.name) == "string" and function_names[node.name] then
        effects.function_calls[node.name] = true
      end
    end
    for _, child in pairs(node) do visit(child) end
  end

  visit(value)
  return effects
end

local function action_payloads_for_recursive_observation(rule)
  local payloads = {}
  for _, edge in ipairs(rule.action_edges) do
    if edge.action_payload then payloads[#payloads + 1] = edge.action_payload end
  end
  for _, edge in ipairs(rule.blind_edges) do
    if edge.action_payload then payloads[#payloads + 1] = edge.action_payload end
  end
  for _, payload in ipairs(rule.lifecycle_action_payloads) do payloads[#payloads + 1] = payload end
  for _, payload in ipairs(rule.plain_action_payloads) do payloads[#payloads + 1] = payload end
  return payloads
end

local function recursive_observation_inherits(effects, rule_writes, function_writes)
  for callee in pairs(effects.rule_calls) do
    if rule_writes[callee] then return true end
  end
  for callee in pairs(effects.function_calls) do
    if function_writes[callee] then return true end
  end
  return false
end

local function validate_recursive_observation_policy(compiled)
  local function_names = {}
  for _, entry in ipairs(compiled.function_registry.entries) do
    function_names[entry.definition.name] = true
  end

  local rule_effects = {}
  for _, label in ipairs(compiled.compiled_rule_order) do
    local projected = json.array()
    for index, payload in ipairs(
        action_payloads_for_recursive_observation(compiled.rules_by_label[label])
      ) do
      projected[index] = action_ast.to_json(payload.action_ast)
    end
    rule_effects[label] = recursive_observation_effects(projected, function_names)
  end

  local function_effects = {}
  for _, entry in ipairs(compiled.function_registry.entries) do
    local definition = entry.definition
    function_effects[definition.name] = recursive_observation_effects(
      action_ast.to_json(action_parser.parse_action_block(definition.body_source)),
      function_names
    )
  end

  for _, effect_map in ipairs({ rule_effects, function_effects }) do
    for _, effects in pairs(effect_map) do
      for observed_rule in pairs(effects.observed_rules) do
        if compiled.rules_by_label[observed_rule] == nil then
          fail(
            "source_location_recursive_observation_operand missing static rule '" ..
              observed_rule .. "'",
            { code = "source_location_recursive_observation_operand", target_label = observed_rule }
          )
        end
      end
    end
  end

  local rule_writes = {}
  local function_writes = {}
  for owner, effects in pairs(rule_effects) do rule_writes[owner] = effects.writes_observation end
  for owner, effects in pairs(function_effects) do
    function_writes[owner] = effects.writes_observation
  end

  local changed = true
  while changed do
    changed = false
    for owner, effects in pairs(rule_effects) do
      if not rule_writes[owner] and
          recursive_observation_inherits(effects, rule_writes, function_writes) then
        rule_writes[owner] = true
        changed = true
      end
    end
    for owner, effects in pairs(function_effects) do
      if not function_writes[owner] and
          recursive_observation_inherits(effects, rule_writes, function_writes) then
        function_writes[owner] = true
        changed = true
      end
    end
  end

  for _, effect_map in ipairs({ rule_effects, function_effects }) do
    for owner, effects in pairs(effect_map) do
      for target in pairs(effects.recognition_attempts) do
        if rule_writes[target] then
          fail(
            "recognition_effect_forbidden:binding_write owner=" .. owner ..
              " target=" .. target,
            { code = "recognition_effect_forbidden", effect = "binding_write", owner = owner, target = target }
          )
        end
      end
    end
  end
end

local function progressive_dispatch_effects(value, function_names)
  local effects = {
    dispatches = false,
    rule_calls = {},
    function_calls = {},
    recognition_attempts = {},
  }

  local function visit(node)
    if type(node) ~= "table" then return end
    local kind = node.kind
    if kind == "progressive_dispatch_span" or kind == "staged_parse_job_marker" then
      effects.dispatches = true
    elseif kind == "recognize_once" then
      if type(node.rule) == "string" then effects.recognition_attempts[node.rule] = true end
    elseif kind == "call" then
      if node.name == "dispatch_span" then
        fail("progressive_span_binding_required", {
          code = "progressive_span_binding_required",
        })
      elseif node.name == "call" and type(node.args) == "table" and #node.args == 1 then
        local argument = node.args[1]
        if type(argument) == "table" and argument.kind == "variable" and
            type(argument.name) == "string" then
          effects.rule_calls[argument.name] = true
        end
      elseif type(node.name) == "string" and function_names[node.name] then
        effects.function_calls[node.name] = true
      end
    end
    for _, child in pairs(node) do visit(child) end
  end

  visit(value)
  return effects
end

local function validate_staged_parse_job_contract(compiled)
  local function reject_residual_calls(value)
    local function visit(node)
      if type(node) ~= "table" then return end
      if (node.kind == "call" and node.name == "parse_job") or node.method == "parse_job" then
        fail(
          "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:staged_parse_job_options_required",
          { code = "staged_parse_job_options_required" }
        )
      end
      for _, child in pairs(node) do visit(child) end
    end
    visit(value)
  end

  for _, label in ipairs(compiled.compiled_rule_order) do
    local projected = json.array()
    for index, payload in ipairs(action_payloads_for_recursive_observation(compiled.rules_by_label[label])) do
      projected[index] = action_ast.to_json(payload.action_ast)
    end
    reject_residual_calls(projected)
  end
  for _, entry in ipairs(compiled.function_registry.entries) do
    reject_residual_calls(action_ast.to_json(
      action_parser.parse_action_block(entry.definition.body_source)
    ))
  end
end

local function progressive_dispatch_inherits(effects, rule_dispatches, function_dispatches)
  for callee in pairs(effects.rule_calls) do
    if rule_dispatches[callee] then return true end
  end
  for callee in pairs(effects.function_calls) do
    if function_dispatches[callee] then return true end
  end
  return false
end

local function validate_progressive_dispatch_policy(compiled)
  local function_names = {}
  for _, entry in ipairs(compiled.function_registry.entries) do
    function_names[entry.definition.name] = true
  end

  local rule_effects = {}
  for _, label in ipairs(compiled.compiled_rule_order) do
    local projected = json.array()
    for index, payload in ipairs(action_payloads_for_recursive_observation(compiled.rules_by_label[label])) do
      projected[index] = action_ast.to_json(payload.action_ast)
    end
    rule_effects[label] = progressive_dispatch_effects(projected, function_names)
  end

  local function_effects = {}
  for _, entry in ipairs(compiled.function_registry.entries) do
    local definition = entry.definition
    function_effects[definition.name] = progressive_dispatch_effects(
      action_ast.to_json(action_parser.parse_action_block(definition.body_source)),
      function_names
    )
  end

  local rule_dispatches = {}
  local function_dispatches = {}
  for owner, effects in pairs(rule_effects) do rule_dispatches[owner] = effects.dispatches end
  for owner, effects in pairs(function_effects) do
    function_dispatches[owner] = effects.dispatches
  end

  local changed = true
  while changed do
    changed = false
    for owner, effects in pairs(rule_effects) do
      if not rule_dispatches[owner] and
          progressive_dispatch_inherits(effects, rule_dispatches, function_dispatches) then
        rule_dispatches[owner] = true
        changed = true
      end
    end
    for owner, effects in pairs(function_effects) do
      if not function_dispatches[owner] and
          progressive_dispatch_inherits(effects, rule_dispatches, function_dispatches) then
        function_dispatches[owner] = true
        changed = true
      end
    end
  end

  for _, effect_map in ipairs({ rule_effects, function_effects }) do
    for owner, effects in pairs(effect_map) do
      for target in pairs(effects.recognition_attempts) do
        if rule_dispatches[target] then
          fail(
            "recognition_effect_forbidden:parser_registry_or_staged_dispatch owner=" .. owner ..
              " target=" .. target,
            {
              code = "recognition_effect_forbidden",
              effect = "parser_registry_or_staged_dispatch",
              owner = owner,
              target = target,
            }
          )
        end
      end
    end
  end
end

local function authored_regex_count(rule)
  local count = 0
  for _, element in ipairs(rule.body_elements) do
    if spec_ast.node_type(element.kind) == "RegexBodyElementKind" then count = count + 1 end
  end
  return count
end

function M.validate_compiled_regex_slot_identities(compiled)
  if M.node_type(compiled) ~= "CompiledSpec" then
    fail("validate_compiled_regex_slot_identities expects CompiledSpec")
  end
  for _, label in ipairs(compiled.compiled_rule_order) do
    local rule = compiled.rules_by_label[label]
    if rule == nil then fail("compiled rule order refers to missing rule '" .. label .. "'") end
    for _, edge in ipairs(rule.action_edges) do
      local target = #edge.targets == 1 and edge.targets[1] or nil
      local target_label = target and target.label or label
      local identity_index = type(edge.child_regex_index) == "number" and edge.child_regex_index or -1
      local target_rule = compiled.rules_by_label[target_label]
      local target_regex_count = target_rule and authored_regex_count(target_rule) or 0
      local identity_is_valid = target ~= nil and type(target_label) == "string" and
        identity_index % 1 == 0 and identity_index >= 0 and identity_index < target_regex_count and
        target.index == identity_index and type(edge.regex_index) == "number" and edge.regex_index % 1 == 0 and
        edge.regex_index >= 0 and edge.regex_index < #rule.regex_patterns
      if not identity_is_valid then
        spec_validator.regex_slot_identity_invalid(label, tostring(target_label), identity_index)
      end
    end
  end
end

function M.compiled_regex_slot_identities_for(rule, regex_index)
  if M.node_type(rule) ~= "CompiledRule" then
    fail("compiled_regex_slot_identities_for expects CompiledRule")
  end
  if type(regex_index) ~= "number" or regex_index % 1 ~= 0 or regex_index < 0 or
      regex_index >= #rule.regex_patterns then
    fail("compiled regex slot index is out of range")
  end
  local identities = {}
  for _, edge in ipairs(rule.action_edges) do
    if edge.regex_index == regex_index and #edge.targets == 1 then
      identities[#identities + 1] = {
        target_rule = edge.targets[1].label,
        regex_index = edge.child_regex_index,
      }
    end
  end
  if #identities == 0 then
    identities[1] = { target_rule = rule.label, regex_index = regex_index }
  end
  return identities
end

function M.compile_spec(spec, options)
  if spec_ast.node_type(spec) ~= "SpecFile" then fail("compile_spec expects SpecFile") end
  options = options or {}
  if type(options) ~= "table" then fail("compile_spec options must be a table") end
  if options.validate_source ~= nil and type(options.validate_source) ~= "boolean" then
    fail("validate_source must be a boolean when present")
  end
  if options.strict_syntax ~= nil and type(options.strict_syntax) ~= "boolean" then
    fail("strict_syntax must be a boolean when present")
  end
  if options.trace ~= nil and not trace.is_trace_emitter(options.trace) then
    fail("trace must be a LinkedSpecTraceEmitter")
  end
  return trace_support.run(
    options.trace,
    "lua_compiler:compile_spec",
    "rules=" .. #spec.rules .. " functions=" .. #spec.functions ..
      " validate=" .. (options.validate_source == false and "0" or "1") ..
      " strict=" .. (options.strict_syntax == true and "1" or "0"),
    function()
      local source = spec_ast.from_json("SpecFile", spec_ast.to_json(spec))
      if options.validate_source ~= false then
        spec_validator.validate_spec(source, {
          strict_syntax = options.strict_syntax == true,
          trace = options.trace,
        })
      else
        trace_support.decision(
          options.trace,
          "lua_compiler:compile_spec:validation",
          false,
          "validate_source=0"
        )
      end

      local registry = user_function_registry.from_spec(source, { trace = options.trace })
      local definition_order = {}
      local source_rules_by_label = {}
      for _, rule in ipairs(source.rules) do source_rules_by_label[rule.header.label] = rule end
      local rules_by_label = {}
      local redefined_rule_labels = {}
      local redefined_seen = {}
      for _, rule in ipairs(source.rules) do
        local label = rule.header.label
        definition_order[#definition_order + 1] = label
        if rules_by_label[label] and not redefined_seen[label] then
          redefined_seen[label] = true
          redefined_rule_labels[#redefined_rule_labels + 1] = label
        end
        rules_by_label[label] = compile_rule(rule, registry, source_rules_by_label, source.source_id)
        trace_support.decision(
          options.trace,
          "lua_compiler:compile_spec:rule",
          true,
          "label=" .. label .. " definition_index=" .. (#definition_order - 1)
        )
      end

      local compiled_rule_order = last_definition_order(definition_order)
      local resolved = resolve_action_edge_dependency_regexes(compiled_rule_order, rules_by_label)
      local dependency_state = build_dependency_regex_state(compiled_rule_order, resolved)
      trace_support.decision(
        options.trace,
        "lua_compiler:compile_spec:dependency_regex",
        true,
        "rule_count=" .. #compiled_rule_order
      )
      local compiled = setmetatable({
        source_id = source.source_id,
        definition_order = definition_order,
        compiled_rule_order = compiled_rule_order,
        rules_by_label = resolved,
        redefined_rule_labels = redefined_rule_labels,
        function_registry = registry,
        dependency_regex_state = dependency_state,
      }, COMPILED_SPEC_MT)
      M.validate_compiled_regex_slot_identities(compiled)
      validate_no_removed_aggregate_selectors(compiled)
      validate_nested_write_serialized_state(compiled)
      validate_receiver_mutation_serialized_state(compiled)
      validate_staged_parse_job_contract(compiled)
      validate_recursive_observation_policy(compiled)
      validate_progressive_dispatch_policy(compiled)
      return compiled
    end,
    function(compiled)
      return "ok rules=" .. #compiled.compiled_rule_order ..
        " functions=" .. #compiled.function_registry.entries
    end
  )
end

function CompiledSpecMethods:rule(label)
  if type(label) ~= "string" then fail("compiled rule label must be a string") end
  return self.rules_by_label[label]
end

function M.resolve_entry_rule(compiled, explicit_selector)
  if M.node_type(compiled) ~= "CompiledSpec" then
    fail("resolve_entry_rule expects CompiledSpec")
  end
  if explicit_selector ~= nil and type(explicit_selector) ~= "string" then
    fail("explicit entry-rule selector must be a string when present")
  end
  if #compiled.compiled_rule_order == 0 then
    entry_rule_selection_fail(
      "no_rules_defined",
      "validate_spec",
      "compiled spec does not contain any rules"
    )
  end
  if explicit_selector ~= nil then
    local selected = compiled.rules_by_label[explicit_selector]
    if selected == nil then
      entry_rule_selection_fail(
        "entry_rule_not_found",
        "select_entry_rule",
        "entry rule '" .. explicit_selector .. "' is not defined",
        explicit_selector
      )
    end
    return setmetatable({ rule = selected, basis = "explicit_selector" }, RESOLVED_ENTRY_RULE_MT)
  end
  for _, label in ipairs(compiled.compiled_rule_order) do
    local candidate = compiled.rules_by_label[label]
    if candidate.header.is_top then
      return setmetatable({ rule = candidate, basis = "first_authored_marker" }, RESOLVED_ENTRY_RULE_MT)
    end
  end
  return setmetatable({
    rule = compiled.rules_by_label[compiled.compiled_rule_order[1]],
    basis = "first_authored_rule",
  }, RESOLVED_ENTRY_RULE_MT)
end

function CompiledSpecMethods:resolve_entry_rule(explicit_selector)
  return M.resolve_entry_rule(self, explicit_selector)
end

function CompiledSpecMethods:functions()
  return copy_list(self.function_registry.entries)
end

function CompiledSpecMethods:descriptor_state()
  return setmetatable({
    compiled_spec_state = self,
    dependency_regex_state = self.dependency_regex_state,
  }, DESCRIPTOR_STATE_MT)
end

function CompiledSpecMethods:to_json()
  return M.to_json(self)
end

function CompiledSpecMethods:to_descriptor_json()
  return M.to_descriptor_json(self)
end

function M.action_payloads(rule)
  if M.node_type(rule) ~= "CompiledRule" then fail("action_payloads expects CompiledRule") end
  local result = {}
  for _, edge in ipairs(rule.action_edges) do
    if edge.action_payload then result[#result + 1] = edge.action_payload end
  end
  for _, edge in ipairs(rule.blind_edges) do
    if edge.action_payload then result[#result + 1] = edge.action_payload end
  end
  for _, payload in ipairs(rule.lifecycle_action_payloads) do result[#result + 1] = payload end
  for _, payload in ipairs(rule.plain_action_payloads) do result[#result + 1] = payload end
  return result
end

function M.validate_no_removed_aggregate_selectors(compiled)
  if M.node_type(compiled) ~= "CompiledSpec" then
    fail("validate_no_removed_aggregate_selectors expects CompiledSpec")
  end
  validate_no_removed_aggregate_selectors(compiled)
end

function M.validate_nested_write_serialized_state(compiled)
  if M.node_type(compiled) ~= "CompiledSpec" then
    fail("validate_nested_write_serialized_state expects CompiledSpec")
  end
  validate_nested_write_serialized_state(compiled)
end

function M.validate_receiver_mutation_serialized_state(compiled)
  if M.node_type(compiled) ~= "CompiledSpec" then
    fail("validate_receiver_mutation_serialized_state expects CompiledSpec")
  end
  validate_receiver_mutation_serialized_state(compiled)
end

function M.validate_progressive_dispatch_policy(compiled)
  if M.node_type(compiled) ~= "CompiledSpec" then
    fail("validate_progressive_dispatch_policy expects CompiledSpec")
  end
  validate_staged_parse_job_contract(compiled)
  validate_progressive_dispatch_policy(compiled)
end

local function dependency_ref_to_json(ref)
  return json.harray({ label = ref.label, idx = ref.index })
end

local function mode_metadata_to_json(metadata)
  local result = json.harray({
    name = metadata.name,
    is_top = metadata.is_top,
    is_and = metadata.is_and,
    is_repetition = metadata.is_repetition,
  })
  if metadata.rep_min ~= nil then result.rep_min = metadata.rep_min end
  if metadata.rep_max ~= nil then result.rep_max = metadata.rep_max end
  return result
end

local function payload_to_json(payload)
  local result = json.harray({
    role = payload.role,
    line = payload.line,
    source = payload.source,
    code = payload.code,
    action_ast = action_ast.to_json(payload.action_ast),
    contracts = action_contracts.to_json(payload.contracts),
  })
  if payload.lifecycle then result.lifecycle = payload.lifecycle end
  return result
end

local function action_edge_to_json(edge, include_slot_identity)
  local result = json.harray({
    line = edge.line,
    source = edge.source,
    targets = typed_array(edge.targets, dependency_ref_to_json),
    regex_index = edge.regex_index,
    child_regex_index = edge.child_regex_index,
    has_parent_regex = edge.has_parent_regex,
    fluent_chain = typed_array(edge.fluent_chain, spec_ast.to_json),
  })
  if include_slot_identity then
    result.selector_kind = edge.selector_kind
    result.authored_selector = edge.authored_selector == nil and json.null or edge.authored_selector
    result.target_rule = edge.targets[1].label
    result.target_slot_id = edge.target_slot_id == nil and json.null or edge.target_slot_id
  end
  if edge.code then result.code = edge.code end
  if edge.action_payload then result.action_payload = payload_to_json(edge.action_payload) end
  return result
end

local function regex_slot_to_json(slot)
  return json.harray({
    regex_index = slot.regex_index,
    slot_id = slot.slot_id == nil and json.null or slot.slot_id,
    source_id = slot.source_id,
    line = slot.line,
  })
end

local function capture_gaps_to_json(capture_gaps)
  return json.harray({
    enabled = capture_gaps.enabled,
    directive = capture_gaps.directive,
    source_id = capture_gaps.source_id,
    line = capture_gaps.line,
  })
end

local function blind_edge_to_json(edge)
  local result = json.harray({
    line = edge.line,
    source = edge.source,
    target = dependency_ref_to_json(edge.target),
    fluent_chain = typed_array(edge.fluent_chain, spec_ast.to_json),
  })
  if edge.code then result.code = edge.code end
  if edge.action_payload then result.action_payload = payload_to_json(edge.action_payload) end
  return result
end

local function rule_slot_event_to_json(event)
  local result = json.harray({
    kind = event.kind,
    marker = event.marker,
    regex_index = event.regex_index,
    line = event.line,
    source = event.source,
  })
  if event.mark_name ~= nil then result.mark_name = event.mark_name end
  return result
end

local function rule_to_json(rule)
  return json.harray({
    label = rule.label,
    header = spec_ast.to_json(rule.header),
    re = typed_array(rule.regex_patterns),
    dependency_refs = typed_array(rule.dependency_refs, dependency_ref_to_json),
    mode_metadata = mode_metadata_to_json(rule.mode_metadata),
    action_edges = typed_array(rule.action_edges, function(edge)
      return action_edge_to_json(edge, true)
    end),
    blind_edges = typed_array(rule.blind_edges, blind_edge_to_json),
    lifecycle_action_payloads = typed_array(rule.lifecycle_action_payloads, payload_to_json),
    plain_action_payloads = typed_array(rule.plain_action_payloads, payload_to_json),
    rule_slot_events = typed_array(rule.rule_slot_events, rule_slot_event_to_json),
    regex_slots = typed_array(rule.regex_slots, regex_slot_to_json),
    capture_gaps = rule.capture_gaps == nil and json.null or capture_gaps_to_json(rule.capture_gaps),
    body = typed_array(rule.body_elements, spec_ast.to_json),
  })
end

local function descriptor_rule_family(rule)
  return rule.mode_metadata.is_and and "and" or "or_default"
end

local function descriptor_cursor_policy(rule)
  return rule.mode_metadata.is_and and "consume" or "seek"
end

local function descriptor_edge_ownership(rule)
  local has_action = #rule.action_edges > 0
  local has_blind = #rule.blind_edges > 0
  if has_action and has_blind then return "mixed" end
  if has_action then return "action" end
  if has_blind then return "blind" end
  return "none"
end

local function descriptor_fluent_text(fluent_chain)
  if #fluent_chain == 0 then return json.null end
  local calls = {}
  for index, call in ipairs(fluent_chain) do
    calls[index] = call.args == "" and call.method or (call.method .. "(" .. call.args .. ")")
  end
  return table.concat(calls, ".")
end

local function resolved_edge_descriptors(rule)
  local result = json.array()
  for _, edge in ipairs(rule.action_edges) do
    for _, target in ipairs(edge.targets) do
      result[#result + 1] = json.harray({
        ownership = "action",
        target = target.label,
        regex_index = edge.child_regex_index,
        block = edge.code ~= nil,
        fluent = descriptor_fluent_text(edge.fluent_chain),
      })
    end
  end
  for _, edge in ipairs(rule.blind_edges) do
    result[#result + 1] = json.harray({
      ownership = "blind",
      target = edge.target.label,
      regex_index = json.null,
      block = edge.code ~= nil,
      fluent = descriptor_fluent_text(edge.fluent_chain),
    })
  end
  return result
end

local function resolved_slot_edge_descriptors(rule)
  local result = json.array()
  for _, edge in ipairs(rule.action_edges) do
    for _, target in ipairs(edge.targets) do
      result[#result + 1] = json.harray({
        selector_kind = edge.selector_kind,
        authored_selector = edge.authored_selector == nil and json.null or edge.authored_selector,
        target_rule = target.label,
        regex_index = edge.child_regex_index,
        target_slot_id = edge.target_slot_id == nil and json.null or edge.target_slot_id,
      })
    end
  end
  return result
end

local function descriptor_rule_to_json(rule)
  return json.harray({
    handler = json.harray({ kind = "lua_interpreter_rule", label = rule.label, status = "compiled_state_only" }),
    re = typed_array(rule.regex_patterns),
    dependency_refs = typed_array(rule.dependency_refs, dependency_ref_to_json),
    action_edges = typed_array(rule.action_edges, function(edge)
      return action_edge_to_json(edge, false)
    end),
    blind_edges = typed_array(rule.blind_edges, blind_edge_to_json),
    lifecycle_action_payloads = typed_array(rule.lifecycle_action_payloads, payload_to_json),
    plain_action_payloads = typed_array(rule.plain_action_payloads, payload_to_json),
    rule_slot_events = typed_array(rule.rule_slot_events, rule_slot_event_to_json),
    meta = json.harray({
      label = rule.label,
      line = rule.header.line,
      is_top = rule.header.is_top,
      family = descriptor_rule_family(rule),
      cursor_policy = descriptor_cursor_policy(rule),
      edge_ownership = descriptor_edge_ownership(rule),
      resolved_edges = resolved_edge_descriptors(rule),
      regex_slots = typed_array(rule.regex_slots, regex_slot_to_json),
      capture_gaps = rule.capture_gaps == nil and json.null or capture_gaps_to_json(rule.capture_gaps),
      resolved_slot_edges = resolved_slot_edge_descriptors(rule),
      mode = mode_metadata_to_json(rule.mode_metadata),
    }),
  })
end

local function dependency_entry_to_json(entry)
  local wrapped = {}
  for index, pattern in ipairs(entry.patterns) do wrapped[index] = "(?:" .. pattern .. ")" end
  return json.harray({
    owner_label = entry.owner_label,
    dependency_refs = typed_array(entry.dependency_refs, dependency_ref_to_json),
    patterns = typed_array(entry.patterns),
    combined_pattern = table.concat(wrapped, "|"),
  })
end

local function dependency_descriptor_json(state)
  local result = json.harray()
  for label, entry in pairs(state.dependency_regex_map) do
    result[label] = dependency_entry_to_json(entry)
  end
  return result
end

local function compiled_spec_to_json(compiled)
  local rules = json.harray()
  for _, label in ipairs(compiled.compiled_rule_order) do
    rules[label] = rule_to_json(compiled.rules_by_label[label])
  end
  local function_order = compiled.function_registry:names()
  local functions = json.harray()
  for _, entry in ipairs(compiled.function_registry.entries) do
    functions[entry.definition.name] = user_function_registry.to_json(entry)
  end
  return json.harray({
    kind = "compiled_spec_state",
    source_id = compiled.source_id,
    definition_order = typed_array(compiled.definition_order),
    compiled_rule_order = typed_array(compiled.compiled_rule_order),
    rules_by_label = rules,
    redefined_rule_labels = typed_array(compiled.redefined_rule_labels),
    function_order = typed_array(function_order),
    functions_by_name = functions,
  })
end

local function descriptor_state_to_json(state)
  local compiled = state.compiled_spec_state
  local spec = json.harray()
  for _, label in ipairs(compiled.compiled_rule_order) do
    spec[label] = descriptor_rule_to_json(compiled.rules_by_label[label])
  end
  local functions = json.harray()
  for _, entry in ipairs(compiled.function_registry.entries) do
    functions[entry.definition.name] = user_function_registry.to_descriptor_json(entry)
  end
  local names = compiled.function_registry:names()
  return json.harray({
    spec = spec,
    functions = functions,
    dependency_regex_map = dependency_descriptor_json(state.dependency_regex_state),
    meta = json.harray({
      descriptor_model = "compiled_descriptor_state",
      compiled_spec_model = "compiled_spec_state",
      compiled_dependency_regex_model = "compiled_dependency_regex_state",
      entry_rule_contract = M.ENTRY_RULE_CONTRACT_ID,
      cursor_contract = M.RULE_LOCAL_CURSOR_CONTRACT_ID,
      regex_slot_identity_contract = M.REGEX_SLOT_IDENTITY_CONTRACT_ID,
      definition_order = typed_array(compiled.definition_order),
      compiled_rule_order = typed_array(compiled.compiled_rule_order),
      redefined_rule_labels = typed_array(compiled.redefined_rule_labels),
      function_order = typed_array(names),
      function_count = #names,
    }),
  })
end

function M.to_json(value)
  if M.is_entry_rule_selection_error(value) then return M.entry_rule_selection_error_to_json(value) end
  local node_type = M.node_type(value)
  if node_type == "CompiledSpec" then return compiled_spec_to_json(value) end
  if node_type == "CompiledRule" then return rule_to_json(value) end
  if node_type == "CompiledRuleModeMetadata" then return mode_metadata_to_json(value) end
  if node_type == "DependencyRef" then return dependency_ref_to_json(value) end
  if node_type == "CompiledActionEdge" then return action_edge_to_json(value, true) end
  if node_type == "CompiledBlindEdge" then return blind_edge_to_json(value) end
  if node_type == "CompiledActionPayload" then return payload_to_json(value) end
  if node_type == "CompiledRuleSlotEvent" then return rule_slot_event_to_json(value) end
  if node_type == "CompiledRegexSlot" then return regex_slot_to_json(value) end
  if node_type == "CompiledCaptureGaps" then return capture_gaps_to_json(value) end
  if node_type == "CompiledDependencyRegexEntry" then return dependency_entry_to_json(value) end
  if node_type == "CompiledDependencyRegexState" then
    return json.harray({
      kind = "compiled_dependency_regex_state",
      dependency_regex_map = dependency_descriptor_json(value),
    })
  end
  if node_type == "CompiledDescriptorState" then return descriptor_state_to_json(value) end
  fail("to_json expects a compiled-spec value")
end

function M.to_descriptor_json(value)
  local node_type = M.node_type(value)
  if node_type == "CompiledSpec" then return descriptor_state_to_json(value:descriptor_state()) end
  if node_type == "CompiledDescriptorState" then return descriptor_state_to_json(value) end
  if node_type == "CompiledRule" then return descriptor_rule_to_json(value) end
  if node_type == "CompiledDependencyRegexState" then return dependency_descriptor_json(value) end
  fail("to_descriptor_json expects compiled spec, rule, descriptor, or dependency state")
end

return M
