local action_call_names = require("linkedspec.action_call_names")
local ast = require("linkedspec.spec_ast")
local json = require("linkedspec.json")
local trace = require("linkedspec.trace")
local trace_support = require("linkedspec.trace_support")

local M = {}

local VALIDATION_ERROR_MT = {
  __tostring = function(value)
    return "SpecValidationException: " .. value.message
  end,
}

local RESERVED_RUNTIME_SYMBOLS = {
  STRING = true,
  descr = true,
  minfo = true,
  LSPOS = true,
  LEPOS = true,
  LMATCH = true,
  LSMATCH = true,
  IMATCH = true,
  IMATCH_LIST = true,
  LMATCH_LIST = true,
  IMATCH_HASH = true,
  LMATCH_HASH = true,
  SELF = true,
  this = true,
  ctx = true,
  runtime_ctx = true,
}

local LIFECYCLE_NAMES = {
  I = true,
  LS = true,
  LE = true,
  E = true,
  EX = true,
  IT = true,
  LX = true,
}

local function validation_fail(message, code, stage, fields)
  error(setmetatable({
    message = message,
    code = code,
    stage = stage,
    fields = fields or json.harray(),
  }, VALIDATION_ERROR_MT), 0)
end

function M.is_validation_error(value)
  return getmetatable(value) == VALIDATION_ERROR_MT
end

function M.validation_error_to_json(value)
  if not M.is_validation_error(value) then
    validation_fail("validation_error_to_json expects SpecValidationException")
  end
  local result = json.harray({ message = value.message, fields = value.fields or json.harray() })
  if value.code ~= nil then result.code = value.code end
  if value.stage ~= nil then result.stage = value.stage end
  return result
end

local function is_identifier(value)
  return type(value) == "string" and value:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function string_lists_equal(left, right)
  if #left ~= #right then return false end
  for index, value in ipairs(left) do
    if value ~= right[index] then return false end
  end
  return true
end

local function check_at_least_one_rule(spec)
  if #spec.rules == 0 then
    validation_fail("spec does not define any rules", "no_rules_defined", "validate_spec")
  end
end

local function check_duplicate_rule_labels(spec)
  local seen = {}
  for _, rule in ipairs(spec.rules) do
    local label = rule.header.label
    if seen[label] then
      validation_fail("duplicate rule label '" .. label .. "'")
    end
    seen[label] = true
  end
end

local function check_duplicate_function_names(spec)
  local seen = {}
  for _, definition in ipairs(spec.functions) do
    if seen[definition.name] then
      validation_fail("duplicate user function definition '" .. definition.name .. "'")
    end
    seen[definition.name] = true
  end
end

local function check_function_registry(spec)
  local rule_labels = {}
  for _, rule in ipairs(spec.rules) do
    rule_labels[rule.header.label] = true
  end

  for _, definition in ipairs(spec.functions) do
    local name = definition.name
    if not is_identifier(name) then
      validation_fail("invalid user function name '" .. name .. "'")
    elseif rule_labels[name] then
      validation_fail("user function '" .. name .. "' collides with rule label '" .. name .. "'")
    elseif RESERVED_RUNTIME_SYMBOLS[name] then
      validation_fail("user function '" .. name .. "' uses a reserved runtime symbol")
    elseif LIFECYCLE_NAMES[name] then
      validation_fail("user function '" .. name .. "' collides with lifecycle marker '" .. name .. "'")
    elseif name == "fn" or action_call_names.is_known(name) then
      validation_fail("user function '" .. name .. "' collides with built-in helper/control name '" .. name .. "'")
    end
    if definition.arity ~= #definition.params then
      validation_fail(
        "user function '" .. name .. "' arity " .. definition.arity ..
        " does not match parameter count " .. #definition.params
      )
    end

    local signature = definition.signature
    if signature ~= nil and (
        ast.node_type(signature) ~= "CallableSignature" or
        signature.kind ~= "callable_signature" or
        signature.version ~= 1 or
        not string_lists_equal(signature.positional_params, definition.params) or
        signature.min_arity ~= definition.arity or
        signature.min_arity ~= #signature.positional_params or
        signature.max_arity ~= nil
      ) then
      validation_fail(
        "user function '" .. name .. "' has an invalid variadic callable signature",
        "invalid_callable_signature"
      )
    end

    local parameter_kinds = definition.parameter_kinds
    if parameter_kinds ~= nil then
      local final_param = definition.params[#definition.params]
      if signature ~= nil or json.kind(parameter_kinds) ~= "harray" then
        validation_fail(
          "user function '" .. name .. "' has invalid final codeblock parameter metadata",
          "invalid_parameter_kinds"
        )
      end
      local count = 0
      for param, kind in pairs(parameter_kinds) do
        count = count + 1
        if param ~= final_param or kind ~= "codeblock" then
          validation_fail(
            "user function '" .. name .. "' has invalid final codeblock parameter metadata",
            "invalid_parameter_kinds"
          )
        end
      end
      if count ~= 1 then
        validation_fail(
          "user function '" .. name .. "' has invalid final codeblock parameter metadata",
          "invalid_parameter_kinds"
        )
      end
    end

    local seen_params = {}
    for _, param in ipairs(definition.params) do
      if not is_identifier(param) then
        validation_fail(
          "user function '" .. name .. "' has invalid parameter '" .. param .. "'",
          "invalid_parameter"
        )
      elseif seen_params[param] then
        validation_fail(
          "duplicate parameter '" .. param .. "' in function '" .. name .. "'",
          "duplicate_parameter"
        )
      elseif RESERVED_RUNTIME_SYMBOLS[param] or LIFECYCLE_NAMES[param] or param == "fn" or param == "return" then
        validation_fail(
          "user function '" .. name .. "' parameter '" .. param .. "' is reserved",
          "reserved_parameter"
        )
      end
      seen_params[param] = true
    end
    if signature ~= nil then
      local rest_param = signature.rest_param
      if not is_identifier(rest_param) then
        validation_fail(
          "user function '" .. name .. "' has invalid rest parameter '" .. tostring(rest_param) .. "'",
          "invalid_rest_parameter"
        )
      elseif seen_params[rest_param] then
        validation_fail(
          "duplicate parameter '" .. rest_param .. "' in function '" .. name .. "'",
          "duplicate_parameter"
        )
      elseif RESERVED_RUNTIME_SYMBOLS[rest_param] or LIFECYCLE_NAMES[rest_param] or
          rest_param == "fn" or rest_param == "return" then
        validation_fail(
          "user function '" .. name .. "' parameter '" .. rest_param .. "' is reserved",
          "reserved_parameter"
        )
      end
    end
  end
end

local function check_raw_body_lines(spec)
  for _, rule in ipairs(spec.rules) do
    for _, element in ipairs(rule.body) do
      if ast.node_type(element.kind) == "RawBodyElementKind" then
        validation_fail(
          "rule '" .. rule.header.label .. "': unrecognized body syntax at line " ..
          element.line .. ": " .. element.kind.text
        )
      end
    end
  end
end

local function target_labels(targets)
  local result = json.array()
  for index, target in ipairs(targets) do result[index] = target.label end
  return result
end

local function check_edge_structure(spec)
  local declared_labels = {}
  for _, rule in ipairs(spec.rules) do declared_labels[rule.header.label] = true end

  for _, rule in ipairs(spec.rules) do
    local rule_label = rule.header.label
    for _, element in ipairs(rule.body) do
      local kind = element.kind
      local node_type = ast.node_type(kind)
      if node_type == "BareEdgeBodyElementKind" then
        for _, target in ipairs(kind.targets) do
          if not declared_labels[target.label] then
            validation_fail(
              "bare edge in rule '" .. rule_label .. "' targets undefined rule '" .. target.label .. "'",
              "bare_edge_target_undefined",
              "normalize_edges",
              json.harray({ rule_label = rule_label, target = target.label })
            )
          end
        end
        if ast.rule_mode_is_and(rule.header.mode) then
          for _, target in ipairs(kind.targets) do
            if target.index ~= nil then
              validation_fail(
                "indexed bare edge in AND rule '" .. rule_label .. "' requires explicit action ownership",
                "bare_edge_index_requires_action",
                "normalize_edges",
                json.harray({
                  rule_label = rule_label,
                  target = target.label,
                  regex_index = target.index,
                })
              )
            end
          end
          if #kind.targets > 1 then
            validation_fail(
              "grouped bare edge in AND rule '" .. rule_label .. "' requires explicit action ownership",
              "bare_edge_group_requires_action",
              "normalize_edges",
              json.harray({ rule_label = rule_label, targets = target_labels(kind.targets) })
            )
          end
        elseif #kind.targets > 1 and kind.code == nil then
          validation_fail(
            "rule '" .. rule_label .. "': grouped action-edge targets require a shared code block",
            "grouped_action_shared_block_required",
            "validate_rule",
            json.harray({ rule_label = rule_label, targets = target_labels(kind.targets) })
          )
        end
      elseif node_type == "ActionEdgeBodyElementKind" and #kind.targets > 1 and kind.code == nil then
        validation_fail(
          "rule '" .. rule_label .. "': grouped action-edge targets require a shared code block",
          "grouped_action_shared_block_required",
          "validate_rule",
          json.harray({ rule_label = rule_label, targets = target_labels(kind.targets) })
        )
      elseif node_type == "BlindEdgeBodyElementKind" and kind.index ~= nil then
        validation_fail(
          "blind-call target '" .. kind.target .. "' in rule '" .. rule_label ..
            "' cannot select a regex index",
          "blind_call_index_forbidden",
          "validate_rule",
          json.harray({
            rule_label = rule_label,
            target = kind.target,
            regex_index = kind.index,
          })
        )
      end
    end
  end
end

local function check_mixed_edges(spec)
  for _, rule in ipairs(spec.rules) do
    local has_action = false
    local has_blind = false
    for _, element in ipairs(rule.body) do
      local kind = ast.node_type(element.kind)
      if kind == "ActionEdgeBodyElementKind" then
        has_action = true
      elseif kind == "BlindEdgeBodyElementKind" then
        has_blind = true
      elseif kind == "BareEdgeBodyElementKind" then
        if ast.rule_mode_is_and(rule.header.mode) then
          has_blind = true
        else
          has_action = true
        end
      end
    end
    if has_action and has_blind then
      validation_fail(
        "rule '" .. rule.header.label .. "' mixes action and blind edge ownership",
        "mixed_edge_ownership",
        "validate_rule",
        json.harray({
          rule_label = rule.header.label,
          ownerships = json.array({ "action", "blind" }),
        })
      )
    end
  end
end

local function regex_count(rule)
  local count = 0
  for _, element in ipairs(rule.body) do
    if ast.node_type(element.kind) == "RegexBodyElementKind" then
      count = count + 1
    end
  end
  return count
end

local function check_target(owner, rules_by_label, target, index)
  local target_rule = rules_by_label[target]
  if not target_rule then
    validation_fail("rule '" .. owner.header.label .. "' references undefined rule '" .. target .. "'")
  end
  local count = regex_count(target_rule)
  if index < 0 or index >= count then
    validation_fail(
      "rule '" .. owner.header.label .. "' references rule '" .. target .. "' regex slot " .. index ..
      ", but that rule has " .. count .. " regex slot(s)"
    )
  end
end

local function check_edge_targets(spec)
  local rules_by_label = {}
  for _, rule in ipairs(spec.rules) do
    rules_by_label[rule.header.label] = rule
  end
  for _, rule in ipairs(spec.rules) do
    for _, element in ipairs(rule.body) do
      local kind = element.kind
      local node_type = ast.node_type(kind)
      if node_type == "ActionEdgeBodyElementKind" then
        for _, target in ipairs(kind.targets) do
          check_target(rule, rules_by_label, target.label, target.index)
        end
      elseif node_type == "BlindEdgeBodyElementKind" then
        check_target(rule, rules_by_label, kind.target, 0)
      elseif node_type == "BareEdgeBodyElementKind" then
        for _, target in ipairs(kind.targets) do
          check_target(rule, rules_by_label, target.label, target.index or 0)
        end
      end
    end
  end
end

local function regex_structural_problem(pattern)
  local escaped = false
  local in_class = false
  local paren_depth = 0
  for index = 1, #pattern do
    local byte = pattern:byte(index)
    if escaped then
      escaped = false
    elseif byte == 0x5C then
      escaped = true
    elseif in_class then
      if byte == 0x5D then
        in_class = false
      end
    elseif byte == 0x5B then
      in_class = true
    elseif byte == 0x28 then
      paren_depth = paren_depth + 1
    elseif byte == 0x29 then
      paren_depth = paren_depth - 1
      if paren_depth < 0 then
        return "unmatched closing parenthesis"
      end
    end
  end
  if escaped then
    return "dangling escape"
  elseif in_class then
    return "unclosed character class"
  elseif paren_depth ~= 0 then
    return "unbalanced parentheses"
  end
  return nil
end

local function check_regex_syntax(spec)
  for _, rule in ipairs(spec.rules) do
    for _, element in ipairs(rule.body) do
      local kind = element.kind
      if ast.node_type(kind) == "RegexBodyElementKind" then
        local problem = regex_structural_problem(kind.pattern)
        if problem then
          validation_fail(
            "rule '" .. rule.header.label .. "': invalid regex pattern '/" .. kind.pattern .. "/': " .. problem
          )
        end
      end
    end
  end
end

local function check_unused_rules(spec)
  local used = {}
  for _, rule in ipairs(spec.rules) do
    for _, element in ipairs(rule.body) do
      local kind = element.kind
      local node_type = ast.node_type(kind)
      if node_type == "ActionEdgeBodyElementKind" then
        for _, target in ipairs(kind.targets) do
          used[target.label] = true
        end
      elseif node_type == "BlindEdgeBodyElementKind" then
        used[kind.target] = true
      elseif node_type == "BareEdgeBodyElementKind" then
        for _, target in ipairs(kind.targets) do used[target.label] = true end
      end
    end
  end
  local unused = {}
  for _, rule in ipairs(spec.rules) do
    if not used[rule.header.label] then
      unused[#unused + 1] = rule.header.label
    end
  end
  if #unused > 0 then
    validation_fail("unused rule(s) in strict mode: " .. table.concat(unused, ", "))
  end
end

function M.validate_spec(spec, options)
  if ast.node_type(spec) ~= "SpecFile" then
    validation_fail("validate_spec expects a SpecFile node")
  end
  options = options or {}
  if type(options) ~= "table" then
    validation_fail("validation options must be a table")
  end
  if options.strict_syntax ~= nil and type(options.strict_syntax) ~= "boolean" then
    validation_fail("strict_syntax must be a boolean when present")
  end
  if options.trace ~= nil and not trace.is_trace_emitter(options.trace) then
    validation_fail("trace must be a LinkedSpecTraceEmitter")
  end
  return trace_support.run(
    options.trace,
    "lua_frontend:validate_spec",
    "rules=" .. #spec.rules .. " functions=" .. #spec.functions ..
      " strict=" .. (options.strict_syntax and "1" or "0"),
    function()
      check_at_least_one_rule(spec)
      check_duplicate_rule_labels(spec)
      check_duplicate_function_names(spec)
      check_function_registry(spec)
      check_raw_body_lines(spec)
      check_edge_structure(spec)
      check_mixed_edges(spec)
      check_edge_targets(spec)
      check_regex_syntax(spec)
      if options.strict_syntax then check_unused_rules(spec) end
      trace_support.decision(
        options.trace,
        "lua_frontend:validate_spec:checks",
        true,
        "strict=" .. (options.strict_syntax and "1" or "0")
      )
    end,
    "ok"
  )
end

return M
