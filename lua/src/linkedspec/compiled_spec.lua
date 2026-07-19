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

local function compile_rule(rule, registry)
  local regex_patterns = {}
  local dependency_refs = {}
  local action_edges = {}
  local blind_edges = {}
  local lifecycle_action_payloads = {}
  local plain_action_payloads = {}
  local rule_slot_events = {}
  local last_regex_line = nil

  for _, element in ipairs(rule.body) do
    local kind = element.kind
    local node_type = spec_ast.node_type(kind)
    if node_type == "RegexBodyElementKind" then
      regex_patterns[#regex_patterns + 1] = kind.pattern
      last_regex_line = element.line
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
          has_parent_regex = has_parent_regex,
          code = kind.code,
          fluent_chain = copy_list(kind.fluent_chain),
          action_payload = payload,
        }, ACTION_EDGE_MT)
      end
      last_regex_line = nil
    elseif node_type == "BlindEdgeBodyElementKind" then
      local ref = dependency_ref(kind.target, 0)
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
        rules_by_label[label] = compile_rule(rule, registry)
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
        definition_order = definition_order,
        compiled_rule_order = compiled_rule_order,
        rules_by_label = resolved,
        redefined_rule_labels = redefined_rule_labels,
        function_registry = registry,
        dependency_regex_state = dependency_state,
      }, COMPILED_SPEC_MT)
      validate_no_removed_aggregate_selectors(compiled)
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

local function action_edge_to_json(edge)
  local result = json.harray({
    line = edge.line,
    source = edge.source,
    targets = typed_array(edge.targets, dependency_ref_to_json),
    regex_index = edge.regex_index,
    child_regex_index = edge.child_regex_index,
    has_parent_regex = edge.has_parent_regex,
    fluent_chain = typed_array(edge.fluent_chain, spec_ast.to_json),
  })
  if edge.code then result.code = edge.code end
  if edge.action_payload then result.action_payload = payload_to_json(edge.action_payload) end
  return result
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
    action_edges = typed_array(rule.action_edges, action_edge_to_json),
    blind_edges = typed_array(rule.blind_edges, blind_edge_to_json),
    lifecycle_action_payloads = typed_array(rule.lifecycle_action_payloads, payload_to_json),
    plain_action_payloads = typed_array(rule.plain_action_payloads, payload_to_json),
    rule_slot_events = typed_array(rule.rule_slot_events, rule_slot_event_to_json),
    body = typed_array(rule.body_elements, spec_ast.to_json),
  })
end

local function descriptor_rule_to_json(rule)
  return json.harray({
    handler = json.harray({ kind = "lua_interpreter_rule", label = rule.label, status = "compiled_state_only" }),
    re = typed_array(rule.regex_patterns),
    dependency_refs = typed_array(rule.dependency_refs, dependency_ref_to_json),
    action_edges = typed_array(rule.action_edges, action_edge_to_json),
    blind_edges = typed_array(rule.blind_edges, blind_edge_to_json),
    lifecycle_action_payloads = typed_array(rule.lifecycle_action_payloads, payload_to_json),
    plain_action_payloads = typed_array(rule.plain_action_payloads, payload_to_json),
    rule_slot_events = typed_array(rule.rule_slot_events, rule_slot_event_to_json),
    meta = json.harray({
      label = rule.label,
      line = rule.header.line,
      is_top = rule.header.is_top,
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
      parse_mode = "seek",
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
  if node_type == "CompiledActionEdge" then return action_edge_to_json(value) end
  if node_type == "CompiledBlindEdge" then return blind_edge_to_json(value) end
  if node_type == "CompiledActionPayload" then return payload_to_json(value) end
  if node_type == "CompiledRuleSlotEvent" then return rule_slot_event_to_json(value) end
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
