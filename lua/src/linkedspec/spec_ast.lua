local json = require("linkedspec.json")

local M = {}

local NODE_METATABLES = {}
local SIMPLE_RULE_MODES = {
  Default = true,
  And = true,
  AndPlus = true,
  Or = true,
  OrPlus = true,
  Single = true,
  Pipe = true,
  Plus = true,
  Star = true,
  Optional = true,
}
local BODY_KIND_TYPES = {
  RegexBodyElementKind = true,
  ActionEdgeBodyElementKind = true,
  BlindEdgeBodyElementKind = true,
  CodeBlockBodyElementKind = true,
  PlainBlockBodyElementKind = true,
  SplitMarkerBodyElementKind = true,
  LifecycleMarkerBodyElementKind = true,
  FluentChainBodyElementKind = true,
  ConditionalBodyElementKind = true,
  RawBodyElementKind = true,
}

local function fail(message)
  error("spec AST error: " .. message, 0)
end

local function metatable_for(node_type)
  local metatable = NODE_METATABLES[node_type]
  if not metatable then
    metatable = { __spec_ast_type = node_type }
    NODE_METATABLES[node_type] = metatable
  end
  return metatable
end

local function node(node_type, fields)
  return setmetatable(fields, metatable_for(node_type))
end

function M.node_type(value)
  if type(value) ~= "table" then
    return nil
  end
  local metatable = getmetatable(value)
  return metatable and metatable.__spec_ast_type or nil
end

local function options_table(value, context)
  if type(value) ~= "table" then
    fail(context .. " options must be a table")
  end
  return value
end

local function required_string(options, field, context)
  local value = options[field]
  if type(value) ~= "string" then
    fail(context .. "." .. field .. " must be a string")
  end
  return value
end

local function optional_string(options, field, context)
  local value = options[field]
  if value == nil then
    return nil
  end
  if type(value) ~= "string" then
    fail(context .. "." .. field .. " must be a string when present")
  end
  return value
end

local function required_integer(options, field, context)
  local value = options[field]
  if type(value) ~= "number" or value % 1 ~= 0 then
    fail(context .. "." .. field .. " must be an integer")
  end
  return value
end

local function optional_integer(options, field, context)
  local value = options[field]
  if value == nil then
    return nil
  end
  if type(value) ~= "number" or value % 1 ~= 0 then
    fail(context .. "." .. field .. " must be an integer when present")
  end
  return value
end

local function required_boolean(options, field, context)
  local value = options[field]
  if type(value) ~= "boolean" then
    fail(context .. "." .. field .. " must be a boolean")
  end
  return value
end

local function dense_list_length(values, context)
  local length = #values
  local count = 0
  for key in pairs(values) do
    count = count + 1
    if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > length then
      fail(context .. " must use contiguous one-based integer indexes")
    end
  end
  if count ~= length then
    fail(context .. " must use contiguous one-based integer indexes")
  end
  return length
end

local function copy_string_list(values, context)
  if type(values) ~= "table" then
    fail(context .. " must be an array")
  end
  local result = {}
  for index = 1, dense_list_length(values, context) do
    if type(values[index]) ~= "string" then
      fail(context .. " must contain only strings")
    end
    result[index] = values[index]
  end
  return result
end

local function copy_parameter_kinds(value, params, context)
  if value == nil then return nil end
  if json.kind(value) ~= "harray" then
    fail(context .. " must be a typed JSON object when present")
  elseif type(params) ~= "table" or #params == 0 then
    fail(context .. " requires a final positional parameter")
  end
  local expected_name = params[#params]
  local count = 0
  for name, kind in pairs(value) do
    count = count + 1
    if name ~= expected_name or kind ~= "codeblock" then
      fail(context .. " must declare only the final parameter as codeblock")
    end
  end
  if count ~= 1 then
    fail(context .. " must declare exactly one parameter kind")
  end
  local result = json.harray()
  result[expected_name] = "codeblock"
  return result
end

function M.parameter_kinds_equal(left, right)
  if left == nil or right == nil then return left == right end
  if json.kind(left) ~= "harray" or json.kind(right) ~= "harray" then return false end
  local left_count = 0
  local right_count = 0
  for name, kind in pairs(left) do
    left_count = left_count + 1
    if right[name] ~= kind then return false end
  end
  for _ in pairs(right) do right_count = right_count + 1 end
  return left_count == right_count
end

local function copy_node_list(values, expected_type, context)
  if type(values) ~= "table" then
    fail(context .. " must be an array")
  end
  local result = {}
  for index = 1, dense_list_length(values, context) do
    local actual_type = M.node_type(values[index])
    if actual_type ~= expected_type then
      fail(context .. " must contain only " .. expected_type .. " nodes")
    end
    result[index] = values[index]
  end
  return result
end

local function require_node(value, expected_type, context)
  if M.node_type(value) ~= expected_type then
    fail(context .. " must be a " .. expected_type .. " node")
  end
  return value
end

local function clone_json(value, context, active)
  local kind = json.kind(value)
  if kind == "null" then
    return json.null
  elseif kind == "string" or kind == "number" or kind == "boolean" then
    return value
  elseif kind ~= "array" and kind ~= "harray" then
    fail(context .. " must be a typed JSON value")
  end
  active = active or {}
  if active[value] then
    fail(context .. " must not be cyclic")
  end
  active[value] = true
  local result
  if kind == "array" then
    result = json.array()
    for index = 1, #value do
      result[index] = clone_json(value[index], context, active)
    end
  else
    result = json.harray()
    for key, item in pairs(value) do
      if type(key) ~= "string" then
        fail(context .. " harray keys must be strings")
      end
      result[key] = clone_json(item, context, active)
    end
  end
  active[value] = nil
  return result
end

function M.source_span(options)
  options = options_table(options, "SourceSpan")
  return node("SourceSpan", {
    line_start = required_integer(options, "line_start", "SourceSpan"),
    line_end = required_integer(options, "line_end", "SourceSpan"),
  })
end

function M.staged_source_span(options)
  options = options_table(options, "StagedSourceSpan")
  return node("StagedSourceSpan", {
    start = required_integer(options, "start", "StagedSourceSpan"),
    ["end"] = required_integer(options, "end", "StagedSourceSpan"),
    line_start = required_integer(options, "line_start", "StagedSourceSpan"),
    line_end = required_integer(options, "line_end", "StagedSourceSpan"),
  })
end

function M.callable_signature(options)
  options = options_table(options, "CallableSignature")
  return node("CallableSignature", {
    kind = required_string(options, "kind", "CallableSignature"),
    version = required_integer(options, "version", "CallableSignature"),
    positional_params = copy_string_list(
      options.positional_params,
      "CallableSignature.positional_params"
    ),
    rest_param = required_string(options, "rest_param", "CallableSignature"),
    min_arity = required_integer(options, "min_arity", "CallableSignature"),
    max_arity = optional_integer(options, "max_arity", "CallableSignature"),
  })
end

function M.callable_signatures_equal(left, right)
  if M.node_type(left) ~= "CallableSignature" or M.node_type(right) ~= "CallableSignature" then
    return false
  end
  if left.kind ~= right.kind or left.version ~= right.version or
      left.rest_param ~= right.rest_param or left.min_arity ~= right.min_arity or
      left.max_arity ~= right.max_arity or #left.positional_params ~= #right.positional_params then
    return false
  end
  for index, param in ipairs(left.positional_params) do
    if param ~= right.positional_params[index] then return false end
  end
  return true
end

function M.staged_parse_job(options)
  options = options_table(options, "StagedParseJob")
  local params = options.params
  local copied_params = nil
  if params ~= nil then
    copied_params = copy_string_list(params, "StagedParseJob.params")
  end
  local signature = options.signature
  if signature ~= nil then
    signature = require_node(signature, "CallableSignature", "StagedParseJob.signature")
  end
  local parameter_kinds = copy_parameter_kinds(
    options.parameter_kinds,
    copied_params,
    "StagedParseJob.parameter_kinds"
  )
  if signature ~= nil and parameter_kinds ~= nil then
    fail("StagedParseJob.parameter_kinds is unavailable for variadic signatures")
  end
  return node("StagedParseJob", {
    version = optional_integer(options, "version", "StagedParseJob"),
    job_id = required_string(options, "job_id", "StagedParseJob"),
    parent_ast_path = copy_string_list(options.parent_ast_path, "StagedParseJob.parent_ast_path"),
    node_kind = required_string(options, "node_kind", "StagedParseJob"),
    payload_kind = required_string(options, "payload_kind", "StagedParseJob"),
    function_name = optional_string(options, "function_name", "StagedParseJob"),
    params = copied_params,
    arity = optional_integer(options, "arity", "StagedParseJob"),
    signature = signature,
    parameter_kinds = parameter_kinds,
    text = required_string(options, "text", "StagedParseJob"),
    source_span = require_node(options.source_span, "StagedSourceSpan", "StagedParseJob.source_span"),
    parser_spec_id = required_string(options, "parser_spec_id", "StagedParseJob"),
    top_rule = required_string(options, "top_rule", "StagedParseJob"),
    result_policy = required_string(options, "result_policy", "StagedParseJob"),
    result_field = required_string(options, "result_field", "StagedParseJob"),
    failure_policy = required_string(options, "failure_policy", "StagedParseJob"),
    diagnostic_owner = optional_string(options, "diagnostic_owner", "StagedParseJob"),
  })
end

function M.function_definition(options)
  options = options_table(options, "FunctionDefinition")
  local body_payload = options.body_payload
  local body_ast = options.body_ast
  local body_parse_job = options.body_parse_job
  local copied_body_payload = nil
  local copied_body_ast = nil
  local checked_body_parse_job = nil
  local signature = options.signature
  if body_payload ~= nil then
    copied_body_payload = clone_json(body_payload, "FunctionDefinition.body_payload")
  end
  if body_ast ~= nil then
    copied_body_ast = clone_json(body_ast, "FunctionDefinition.body_ast")
  end
  if body_parse_job ~= nil then
    checked_body_parse_job = require_node(
      body_parse_job,
      "StagedParseJob",
      "FunctionDefinition.body_parse_job"
    )
  end
  if signature ~= nil then
    signature = require_node(signature, "CallableSignature", "FunctionDefinition.signature")
  end
  local params = copy_string_list(options.params, "FunctionDefinition.params")
  local parameter_kinds = copy_parameter_kinds(
    options.parameter_kinds,
    params,
    "FunctionDefinition.parameter_kinds"
  )
  if signature ~= nil and parameter_kinds ~= nil then
    fail("FunctionDefinition.parameter_kinds is unavailable for variadic signatures")
  end
  return node("FunctionDefinition", {
    name = required_string(options, "name", "FunctionDefinition"),
    params = params,
    arity = required_integer(options, "arity", "FunctionDefinition"),
    signature = signature,
    parameter_kinds = parameter_kinds,
    body_source = required_string(options, "body_source", "FunctionDefinition"),
    body_payload = copied_body_payload,
    body_parse_job = checked_body_parse_job,
    body_ast = copied_body_ast,
    source = required_string(options, "source", "FunctionDefinition"),
    source_span = require_node(options.source_span, "SourceSpan", "FunctionDefinition.source_span"),
    body_span = require_node(options.body_span, "SourceSpan", "FunctionDefinition.body_span"),
  })
end

function M.rule_mode(name, bounds)
  if type(name) ~= "string" then
    fail("RuleMode.name must be a string")
  end
  if SIMPLE_RULE_MODES[name] then
    if bounds ~= nil then
      fail("simple rule mode " .. name .. " cannot carry bounds")
    end
    return node("RuleMode", { name = name, min = nil, max = nil })
  end
  if name ~= "AndBounded" and name ~= "OrBounded" then
    fail("unsupported rule mode " .. name)
  end
  bounds = options_table(bounds, "RuleMode bounds")
  return node("RuleMode", {
    name = name,
    min = required_integer(bounds, "min", "RuleMode bounds"),
    max = optional_integer(bounds, "max", "RuleMode bounds"),
  })
end

function M.default_rule_mode()
  return M.rule_mode("Default")
end

function M.and_bounded_rule_mode(bounds)
  return M.rule_mode("AndBounded", bounds)
end

function M.or_bounded_rule_mode(bounds)
  return M.rule_mode("OrBounded", bounds)
end

function M.rule_mode_is_and(mode)
  require_node(mode, "RuleMode", "mode")
  return mode.name == "And" or mode.name == "AndPlus" or mode.name == "AndBounded" or
    mode.name == "Pipe" or mode.name == "Single"
end

function M.rule_mode_is_repetition(mode)
  require_node(mode, "RuleMode", "mode")
  return mode.name == "Default" or mode.name == "Star" or mode.name == "Plus" or
    mode.name == "OrPlus" or mode.name == "AndPlus" or mode.name == "Optional" or
    mode.name == "OrBounded" or mode.name == "AndBounded"
end

function M.rule_mode_rep_min(mode)
  require_node(mode, "RuleMode", "mode")
  if mode.name == "Default" or mode.name == "Star" or mode.name == "Optional" then
    return 0
  elseif mode.name == "Plus" or mode.name == "OrPlus" or mode.name == "AndPlus" then
    return 1
  elseif mode.name == "OrBounded" or mode.name == "AndBounded" then
    return mode.min
  end
  return nil
end

function M.rule_mode_rep_max(mode)
  require_node(mode, "RuleMode", "mode")
  if mode.name == "Optional" then
    return 1
  elseif mode.name == "OrBounded" or mode.name == "AndBounded" then
    return mode.max
  end
  return nil
end

function M.rule_header(options)
  options = options_table(options, "RuleHeader")
  return node("RuleHeader", {
    label = required_string(options, "label", "RuleHeader"),
    is_top = required_boolean(options, "is_top", "RuleHeader"),
    mode = require_node(options.mode, "RuleMode", "RuleHeader.mode"),
    rest = required_string(options, "rest", "RuleHeader"),
    line = required_integer(options, "line", "RuleHeader"),
  })
end

function M.edge_target(options)
  options = options_table(options, "EdgeTarget")
  return node("EdgeTarget", {
    label = required_string(options, "label", "EdgeTarget"),
    index = options.index == nil and 0 or required_integer(options, "index", "EdgeTarget"),
  })
end

function M.fluent_call(options)
  options = options_table(options, "FluentCall")
  return node("FluentCall", {
    method = required_string(options, "method", "FluentCall"),
    args = required_string(options, "args", "FluentCall"),
  })
end

function M.regex_body_kind(options)
  options = options_table(options, "RegexBodyElementKind")
  return node("RegexBodyElementKind", {
    pattern = required_string(options, "pattern", "RegexBodyElementKind"),
  })
end

function M.action_edge_body_kind(options)
  options = options_table(options, "ActionEdgeBodyElementKind")
  return node("ActionEdgeBodyElementKind", {
    targets = copy_node_list(options.targets, "EdgeTarget", "ActionEdgeBodyElementKind.targets"),
    code = optional_string(options, "code", "ActionEdgeBodyElementKind"),
    fluent_chain = copy_node_list(options.fluent_chain or {}, "FluentCall", "ActionEdgeBodyElementKind.fluent_chain"),
  })
end

function M.blind_edge_body_kind(options)
  options = options_table(options, "BlindEdgeBodyElementKind")
  return node("BlindEdgeBodyElementKind", {
    target = required_string(options, "target", "BlindEdgeBodyElementKind"),
    code = optional_string(options, "code", "BlindEdgeBodyElementKind"),
    fluent_chain = copy_node_list(options.fluent_chain or {}, "FluentCall", "BlindEdgeBodyElementKind.fluent_chain"),
  })
end

function M.code_block_body_kind(options)
  options = options_table(options, "CodeBlockBodyElementKind")
  return node("CodeBlockBodyElementKind", {
    lifecycle = required_string(options, "lifecycle", "CodeBlockBodyElementKind"),
    code = required_string(options, "code", "CodeBlockBodyElementKind"),
  })
end

function M.plain_block_body_kind(options)
  options = options_table(options, "PlainBlockBodyElementKind")
  return node("PlainBlockBodyElementKind", {
    code = required_string(options, "code", "PlainBlockBodyElementKind"),
  })
end

function M.split_marker_body_kind(options)
  options = options_table(options, "SplitMarkerBodyElementKind")
  return node("SplitMarkerBodyElementKind", {
    marker = required_string(options, "marker", "SplitMarkerBodyElementKind"),
  })
end

function M.lifecycle_marker_body_kind(options)
  options = options_table(options, "LifecycleMarkerBodyElementKind")
  return node("LifecycleMarkerBodyElementKind", {
    marker = required_string(options, "marker", "LifecycleMarkerBodyElementKind"),
  })
end

function M.fluent_chain_body_kind(options)
  options = options_table(options, "FluentChainBodyElementKind")
  return node("FluentChainBodyElementKind", {
    calls = copy_node_list(options.calls, "FluentCall", "FluentChainBodyElementKind.calls"),
  })
end

function M.conditional_body_kind(options)
  options = options_table(options, "ConditionalBodyElementKind")
  return node("ConditionalBodyElementKind", {
    word = required_string(options, "word", "ConditionalBodyElementKind"),
  })
end

function M.raw_body_kind(options)
  options = options_table(options, "RawBodyElementKind")
  return node("RawBodyElementKind", {
    text = required_string(options, "text", "RawBodyElementKind"),
  })
end

function M.body_element(options)
  options = options_table(options, "BodyElement")
  local kind = options.kind
  if not BODY_KIND_TYPES[M.node_type(kind)] then
    fail("BodyElement.kind must be a body-element kind node")
  end
  return node("BodyElement", {
    kind = kind,
    source = required_string(options, "source", "BodyElement"),
    line = required_integer(options, "line", "BodyElement"),
  })
end

function M.rule(options)
  options = options_table(options, "Rule")
  return node("Rule", {
    header = require_node(options.header, "RuleHeader", "Rule.header"),
    body = copy_node_list(options.body, "BodyElement", "Rule.body"),
  })
end

function M.spec_file(options)
  options = options_table(options, "SpecFile")
  return node("SpecFile", {
    functions = copy_node_list(options.functions or {}, "FunctionDefinition", "SpecFile.functions"),
    rules = copy_node_list(options.rules, "Rule", "SpecFile.rules"),
  })
end

function M.top_rule(spec)
  require_node(spec, "SpecFile", "spec")
  for _, rule in ipairs(spec.rules) do
    if rule.header.is_top then
      return rule
    end
  end
  return nil
end

function M.find_rule(spec, label)
  require_node(spec, "SpecFile", "spec")
  if type(label) ~= "string" then
    fail("rule label must be a string")
  end
  for _, rule in ipairs(spec.rules) do
    if rule.header.label == label then
      return rule
    end
  end
  return nil
end

local function json_array_of(values, project)
  local result = json.array()
  for index, value in ipairs(values) do
    result[index] = project(value)
  end
  return result
end

local function put_optional(object, key, value, project)
  if value ~= nil then
    object[key] = project and project(value) or value
  end
end

local project

local function project_body_kind(kind)
  local node_type = M.node_type(kind)
  local result = json.harray()
  if node_type == "RegexBodyElementKind" then
    result.kind = "regex"
    result.pattern = kind.pattern
  elseif node_type == "ActionEdgeBodyElementKind" then
    result.kind = "action_edge"
    result.targets = json_array_of(kind.targets, project)
    result.code = kind.code == nil and json.null or kind.code
    result.fluent_chain = json_array_of(kind.fluent_chain, project)
  elseif node_type == "BlindEdgeBodyElementKind" then
    result.kind = "blind_edge"
    result.target = kind.target
    result.code = kind.code == nil and json.null or kind.code
    result.fluent_chain = json_array_of(kind.fluent_chain, project)
  elseif node_type == "CodeBlockBodyElementKind" then
    result.kind = "code_block"
    result.lifecycle = kind.lifecycle
    result.code = kind.code
  elseif node_type == "PlainBlockBodyElementKind" then
    result.kind = "plain_block"
    result.code = kind.code
  elseif node_type == "SplitMarkerBodyElementKind" then
    result.kind = "split_marker"
    result.marker = kind.marker
  elseif node_type == "LifecycleMarkerBodyElementKind" then
    result.kind = "lifecycle_marker"
    result.marker = kind.marker
  elseif node_type == "FluentChainBodyElementKind" then
    result.kind = "fluent_chain"
    result.calls = json_array_of(kind.calls, project)
  elseif node_type == "ConditionalBodyElementKind" then
    result.kind = "conditional"
    result.word = kind.word
  elseif node_type == "RawBodyElementKind" then
    result.kind = "raw"
    result.text = kind.text
  else
    fail("cannot project unknown body-element kind")
  end
  return result
end

project = function(value)
  local node_type = M.node_type(value)
  local result = json.harray()
  if node_type == "SourceSpan" then
    result.line_start = value.line_start
    result.line_end = value.line_end
  elseif node_type == "StagedSourceSpan" then
    result.start = value.start
    result["end"] = value["end"]
    result.line_start = value.line_start
    result.line_end = value.line_end
  elseif node_type == "CallableSignature" then
    result.kind = value.kind
    result.version = value.version
    result.positional_params = json_array_of(value.positional_params, function(item) return item end)
    result.rest_param = value.rest_param
    result.min_arity = value.min_arity
    result.max_arity = value.max_arity == nil and json.null or value.max_arity
  elseif node_type == "StagedParseJob" then
    result.kind = "parse_job"
    put_optional(result, "version", value.version)
    result.job_id = value.job_id
    result.parent_ast_path = json_array_of(value.parent_ast_path, function(item) return item end)
    result.node_kind = value.node_kind
    result.payload_kind = value.payload_kind
    put_optional(result, "function_name", value.function_name)
    if value.signature == nil then
      put_optional(result, "params", value.params, function(items)
        return json_array_of(items, function(item) return item end)
      end)
      put_optional(result, "arity", value.arity)
    else
      result.signature = project(value.signature)
    end
    put_optional(result, "parameter_kinds", value.parameter_kinds, function(item)
      return clone_json(item, "StagedParseJob.parameter_kinds")
    end)
    result.text = value.text
    result.source_span = project(value.source_span)
    result.parser_spec_id = value.parser_spec_id
    result.top_rule = value.top_rule
    result.result_policy = value.result_policy
    result.result_field = value.result_field
    result.failure_policy = value.failure_policy
    put_optional(result, "diagnostic_owner", value.diagnostic_owner)
  elseif node_type == "FunctionDefinition" then
    result.name = value.name
    if value.signature == nil then
      result.params = json_array_of(value.params, function(item) return item end)
      result.arity = value.arity
    else
      result.signature = project(value.signature)
    end
    put_optional(result, "parameter_kinds", value.parameter_kinds, function(item)
      return clone_json(item, "FunctionDefinition.parameter_kinds")
    end)
    result.body_source = value.body_source
    put_optional(result, "body_payload", value.body_payload, function(item)
      return clone_json(item, "FunctionDefinition.body_payload")
    end)
    put_optional(result, "body_parse_job", value.body_parse_job, project)
    put_optional(result, "body_ast", value.body_ast, function(item)
      return clone_json(item, "FunctionDefinition.body_ast")
    end)
    result.source = value.source
    result.source_span = project(value.source_span)
    result.body_span = project(value.body_span)
  elseif node_type == "RuleMode" then
    if value.name == "AndBounded" or value.name == "OrBounded" then
      local bounds = json.harray({ min = value.min, max = value.max == nil and json.null or value.max })
      result[value.name] = bounds
    else
      return value.name
    end
  elseif node_type == "RuleHeader" then
    result.label = value.label
    result.is_top = value.is_top
    result.mode = project(value.mode)
    result.rest = value.rest
    result.line = value.line
  elseif BODY_KIND_TYPES[node_type] then
    return project_body_kind(value)
  elseif node_type == "EdgeTarget" then
    result.label = value.label
    result.index = value.index
  elseif node_type == "FluentCall" then
    result.method = value.method
    result.args = value.args
  elseif node_type == "BodyElement" then
    result.kind = project_body_kind(value.kind)
    result.source = value.source
    result.line = value.line
  elseif node_type == "Rule" then
    result.header = project(value.header)
    result.body = json_array_of(value.body, project)
  elseif node_type == "SpecFile" then
    result.functions = json_array_of(value.functions, project)
    result.rules = json_array_of(value.rules, project)
  else
    fail("cannot project value without a source AST type")
  end
  return result
end

function M.to_json(value)
  return project(value)
end

local function object_value(value, context)
  if json.kind(value) ~= "harray" then
    fail(context .. " must be a JSON object")
  end
  return value
end

local function array_value(value, context)
  if json.kind(value) ~= "array" then
    fail(context .. " must be a JSON array")
  end
  return value
end

local function json_string(object, field, context)
  local value = object[field]
  if type(value) ~= "string" then
    fail(context .. "." .. field .. " must be a string")
  end
  return value
end

local function json_optional_string(object, field, context)
  local value = object[field]
  if value == nil or value == json.null then
    return nil
  end
  if type(value) ~= "string" then
    fail(context .. "." .. field .. " must be a string when present")
  end
  return value
end

local function json_integer(object, field, context)
  local value = object[field]
  if type(value) ~= "number" or value % 1 ~= 0 then
    fail(context .. "." .. field .. " must be an integer")
  end
  return value
end

local function json_optional_integer(object, field, context)
  local value = object[field]
  if value == nil or value == json.null then
    return nil
  end
  if type(value) ~= "number" or value % 1 ~= 0 then
    fail(context .. "." .. field .. " must be an integer when present")
  end
  return value
end

local function json_boolean(object, field, context)
  local value = object[field]
  if type(value) ~= "boolean" then
    fail(context .. "." .. field .. " must be a boolean")
  end
  return value
end

local function json_string_list(object, field, context, optional)
  local value = object[field]
  if optional and (value == nil or value == json.null) then
    return nil
  end
  value = array_value(value, context .. "." .. field)
  local result = {}
  for index, item in ipairs(value) do
    if type(item) ~= "string" then
      fail(context .. "." .. field .. " must contain only strings")
    end
    result[index] = item
  end
  return result
end

local function json_object_list(object, field, context, build, optional)
  local value = object[field]
  if optional and value == nil then
    return {}
  end
  value = array_value(value, context .. "." .. field)
  local result = {}
  for index, item in ipairs(value) do
    result[index] = build(object_value(item, context .. "." .. field))
  end
  return result
end

local build

local function build_rule_mode(value)
  if type(value) == "string" then
    return M.rule_mode(value)
  end
  local object = object_value(value, "RuleMode")
  local count = 0
  local name
  local bounds
  for key, item in pairs(object) do
    count = count + 1
    name = key
    bounds = item
  end
  if count ~= 1 then
    fail("bounded RuleMode must have exactly one key")
  end
  bounds = object_value(bounds, "RuleMode." .. tostring(name))
  return M.rule_mode(name, {
    min = json_integer(bounds, "min", "RuleMode bounds"),
    max = json_optional_integer(bounds, "max", "RuleMode bounds"),
  })
end

local function build_body_kind(value)
  local object = object_value(value, "BodyElementKind")
  local kind = json_string(object, "kind", "BodyElementKind")
  if kind == "regex" then
    return M.regex_body_kind({ pattern = json_string(object, "pattern", "BodyElementKind") })
  elseif kind == "action_edge" then
    return M.action_edge_body_kind({
      targets = json_object_list(object, "targets", "BodyElementKind", function(item)
        return build("EdgeTarget", item)
      end),
      code = json_optional_string(object, "code", "BodyElementKind"),
      fluent_chain = json_object_list(object, "fluent_chain", "BodyElementKind", function(item)
        return build("FluentCall", item)
      end, true),
    })
  elseif kind == "blind_edge" then
    return M.blind_edge_body_kind({
      target = json_string(object, "target", "BodyElementKind"),
      code = json_optional_string(object, "code", "BodyElementKind"),
      fluent_chain = json_object_list(object, "fluent_chain", "BodyElementKind", function(item)
        return build("FluentCall", item)
      end, true),
    })
  elseif kind == "code_block" then
    return M.code_block_body_kind({
      lifecycle = json_string(object, "lifecycle", "BodyElementKind"),
      code = json_string(object, "code", "BodyElementKind"),
    })
  elseif kind == "plain_block" then
    return M.plain_block_body_kind({ code = json_string(object, "code", "BodyElementKind") })
  elseif kind == "split_marker" then
    return M.split_marker_body_kind({ marker = json_string(object, "marker", "BodyElementKind") })
  elseif kind == "lifecycle_marker" then
    return M.lifecycle_marker_body_kind({ marker = json_string(object, "marker", "BodyElementKind") })
  elseif kind == "fluent_chain" then
    return M.fluent_chain_body_kind({
      calls = json_object_list(object, "calls", "BodyElementKind", function(item)
        return build("FluentCall", item)
      end),
    })
  elseif kind == "conditional" then
    return M.conditional_body_kind({ word = json_string(object, "word", "BodyElementKind") })
  elseif kind == "raw" then
    return M.raw_body_kind({ text = json_string(object, "text", "BodyElementKind") })
  end
  fail("unsupported body element kind " .. kind)
end

build = function(node_type, value)
  if node_type == "RuleMode" then
    return build_rule_mode(value)
  elseif node_type == "BodyElementKind" then
    return build_body_kind(value)
  end
  local object = object_value(value, node_type)
  if node_type == "SourceSpan" then
    return M.source_span({
      line_start = json_integer(object, "line_start", node_type),
      line_end = json_integer(object, "line_end", node_type),
    })
  elseif node_type == "StagedSourceSpan" then
    return M.staged_source_span({
      start = json_integer(object, "start", node_type),
      ["end"] = json_integer(object, "end", node_type),
      line_start = json_integer(object, "line_start", node_type),
      line_end = json_integer(object, "line_end", node_type),
    })
  elseif node_type == "CallableSignature" then
    return M.callable_signature({
      kind = json_string(object, "kind", node_type),
      version = json_integer(object, "version", node_type),
      positional_params = json_string_list(object, "positional_params", node_type),
      rest_param = json_string(object, "rest_param", node_type),
      min_arity = json_integer(object, "min_arity", node_type),
      max_arity = json_optional_integer(object, "max_arity", node_type),
    })
  elseif node_type == "StagedParseJob" then
    local kind = json_string(object, "kind", node_type)
    if kind ~= "parse_job" then
      fail("staged parse job kind must be parse_job, got " .. kind)
    end
    local signature = nil
    if object.signature ~= nil and object.signature ~= json.null then
      signature = build("CallableSignature", object.signature)
    end
    local parameter_kinds = nil
    if object.parameter_kinds ~= nil and object.parameter_kinds ~= json.null then
      parameter_kinds = clone_json(object.parameter_kinds, "StagedParseJob.parameter_kinds")
    end
    return M.staged_parse_job({
      version = json_optional_integer(object, "version", node_type),
      job_id = json_string(object, "job_id", node_type),
      parent_ast_path = json_string_list(object, "parent_ast_path", node_type),
      node_kind = json_string(object, "node_kind", node_type),
      payload_kind = json_string(object, "payload_kind", node_type),
      function_name = json_optional_string(object, "function_name", node_type),
      params = json_string_list(object, "params", node_type, true),
      arity = json_optional_integer(object, "arity", node_type),
      signature = signature,
      parameter_kinds = parameter_kinds,
      text = json_string(object, "text", node_type),
      source_span = build("StagedSourceSpan", object_value(object.source_span, "StagedParseJob.source_span")),
      parser_spec_id = json_string(object, "parser_spec_id", node_type),
      top_rule = json_string(object, "top_rule", node_type),
      result_policy = json_string(object, "result_policy", node_type),
      result_field = json_string(object, "result_field", node_type),
      failure_policy = json_string(object, "failure_policy", node_type),
      diagnostic_owner = json_optional_string(object, "diagnostic_owner", node_type),
    })
  elseif node_type == "FunctionDefinition" then
    local body_parse_job = object.body_parse_job
    local parsed_body_parse_job = nil
    if body_parse_job ~= nil and body_parse_job ~= json.null then
      parsed_body_parse_job = build("StagedParseJob", body_parse_job)
    end
    local body_payload = nil
    if object.body_payload ~= nil and object.body_payload ~= json.null then
      body_payload = clone_json(object.body_payload, "FunctionDefinition.body_payload")
    end
    local body_ast = nil
    if object.body_ast ~= nil and object.body_ast ~= json.null then
      body_ast = clone_json(object.body_ast, "FunctionDefinition.body_ast")
    end
    local signature = nil
    local parameter_kinds = nil
    local params
    local arity
    if object.signature ~= nil and object.signature ~= json.null then
      signature = build("CallableSignature", object.signature)
      params = signature.positional_params
      arity = signature.min_arity
    else
      params = json_string_list(object, "params", node_type)
      arity = json_integer(object, "arity", node_type)
    end
    if object.parameter_kinds ~= nil and object.parameter_kinds ~= json.null then
      parameter_kinds = clone_json(object.parameter_kinds, "FunctionDefinition.parameter_kinds")
    end
    return M.function_definition({
      name = json_string(object, "name", node_type),
      params = params,
      arity = arity,
      signature = signature,
      parameter_kinds = parameter_kinds,
      body_source = json_string(object, "body_source", node_type),
      body_payload = body_payload,
      body_parse_job = parsed_body_parse_job,
      body_ast = body_ast,
      source = json_string(object, "source", node_type),
      source_span = build("SourceSpan", object_value(object.source_span, "FunctionDefinition.source_span")),
      body_span = build("SourceSpan", object_value(object.body_span, "FunctionDefinition.body_span")),
    })
  elseif node_type == "RuleHeader" then
    return M.rule_header({
      label = json_string(object, "label", node_type),
      is_top = json_boolean(object, "is_top", node_type),
      mode = build_rule_mode(object.mode),
      rest = json_string(object, "rest", node_type),
      line = json_integer(object, "line", node_type),
    })
  elseif node_type == "EdgeTarget" then
    return M.edge_target({
      label = json_string(object, "label", node_type),
      index = json_integer(object, "index", node_type),
    })
  elseif node_type == "FluentCall" then
    return M.fluent_call({
      method = json_string(object, "method", node_type),
      args = json_string(object, "args", node_type),
    })
  elseif node_type == "BodyElement" then
    return M.body_element({
      kind = build_body_kind(object.kind),
      source = json_string(object, "source", node_type),
      line = json_integer(object, "line", node_type),
    })
  elseif node_type == "Rule" then
    return M.rule({
      header = build("RuleHeader", object_value(object.header, "Rule.header")),
      body = json_object_list(object, "body", node_type, function(item)
        return build("BodyElement", item)
      end),
    })
  elseif node_type == "SpecFile" then
    return M.spec_file({
      functions = json_object_list(object, "functions", node_type, function(item)
        return build("FunctionDefinition", item)
      end, true),
      rules = json_object_list(object, "rules", node_type, function(item)
        return build("Rule", item)
      end),
    })
  end
  fail("unsupported source AST type " .. tostring(node_type))
end

function M.from_json(node_type, value)
  if type(node_type) ~= "string" then
    fail("from_json node type must be a string")
  end
  return build(node_type, value)
end

return M
