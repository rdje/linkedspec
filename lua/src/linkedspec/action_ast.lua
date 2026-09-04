local json = require("linkedspec.json")

local M = {}

local NODE_MTS = {}

local function metatable_for(node_type)
  local metatable = NODE_MTS[node_type]
  if not metatable then
    metatable = { __action_ast_type = node_type }
    NODE_MTS[node_type] = metatable
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
  return metatable and metatable.__action_ast_type or nil
end

function M.source_span(start_position, end_position)
  return node("ActionSourceSpan", { start = start_position, ["end"] = end_position })
end

function M.block(source, source_span, statements)
  return node("ActionBlock", {
    kind = "action_block",
    source = source,
    source_span = source_span,
    statements = statements,
  })
end

function M.statement(source, source_span, expr, drops_value)
  return node("ActionStatement", {
    kind = "action_stmt",
    source = source,
    source_span = source_span,
    expr = expr,
    drops_value = drops_value ~= false,
  })
end

function M.expr(kind, source, source_span, fields)
  fields = fields or {}
  fields.kind = kind
  fields.source = source
  fields.source_span = source_span
  return node("ActionExpr", fields)
end

function M.staged_parse_job_options(fields)
  return node("ActionStagedParseJobOptions", fields)
end

function M.staged_parse_job_direct_text_plan(source, index)
  local fields = { kind = "direct_span", source = source }
  if index ~= nil then fields.index = index end
  return node("ActionStagedParseJobDirectTextPlan", fields)
end

function M.staged_parse_job_derived_text_plan(segments)
  return node("ActionStagedParseJobDerivedTextPlan", {
    kind = "derived_text",
    policy = "concatenate_in_order",
    segments = segments,
  })
end

function M.positional_argument(value)
  return node("ActionArgument", { argument_kind = "positional", value = value })
end

function M.keyword_argument(name, value)
  return node("ActionArgument", { argument_kind = "keyword", name = name, value = value })
end

function M.access_segment(kind, source, source_span, fields)
  fields = fields or {}
  fields.kind = kind
  fields.source = source
  fields.source_span = source_span
  return node("ActionAccessSegment", fields)
end

function M.write_path_segment(source, source_span, expression)
  return node("ActionWritePathSegment", {
    kind = "path_segment",
    source = source,
    source_span = source_span,
    expression = expression,
  })
end

function M.receiver_mutation_binding_reference(name, source, source_span)
  return node("ActionReceiverMutationBindingReference", {
    kind = "binding_reference",
    name = name,
    source = source,
    source_span = source_span,
  })
end

function M.receiver_mutation_callback(source, source_span, body)
  return node("ActionReceiverMutationCallback", {
    kind = "block_value",
    source = source,
    source_span = source_span,
    body = body,
  })
end

function M.receiver_mutation_call(fields)
  fields.kind = "receiver_mutation_call"
  return node("ActionReceiverMutationCall", fields)
end

function M.receiver_mutation_continuation_call(fields)
  fields.kind = "fluent_call"
  return node("ActionReceiverMutationContinuationCall", fields)
end

function M.hash_entry(key, value)
  return node("ActionHashEntry", { key = key, value = value })
end

function M.callable_signature(positional_params, rest_param)
  local positional = json.array()
  for index, name in ipairs(positional_params or {}) do positional[index] = name end
  local rest = rest_param or json.null
  return node("ActionCallableSignature", {
    kind = "callable_signature",
    version = 1,
    positional_params = positional,
    rest_param = rest,
    min_arity = #positional,
    max_arity = rest == json.null and #positional or json.null,
  })
end

function M.contextual_callable_signature()
  return M.callable_signature({}, nil)
end

function M.codeblock_literal(source, source_span, signature, body_source, body_ast, body_span)
  return M.expr("codeblock_literal", source, source_span, {
    version = 1,
    signature = signature,
    body_source = body_source,
    body_ast = body_ast,
    source_text = source,
    body_span = body_span,
  })
end

function M.codeblock_literal_error(source, source_span, code)
  return M.expr("codeblock_literal_error", source, source_span, { code = code })
end

function M.contextual_codeblock_argument(block_value)
  if M.node_type(block_value) ~= "ActionExpr" or block_value.kind ~= "block_value" or
      M.node_type(block_value.block) ~= "ActionBlock" then
    error("action AST contextual codeblock argument requires a block_value expression", 0)
  end
  return M.expr("codeblock_argument", block_value.source, block_value.source_span, {
    version = 1,
    signature = M.contextual_callable_signature(),
    body_source = block_value.block.source,
    body_ast = block_value.block,
    source_text = block_value.source,
    body_span = block_value.block.source_span,
    block = block_value.block,
  })
end

function M.fluent_call(method, args, source, source_span, fields)
  fields = fields or {}
  fields.method = method
  fields.args = args
  fields.source = source
  fields.source_span = source_span
  return node("ActionFluentCall", fields)
end

function M.removed_aggregate_selector_diagnostic(selector)
  return "aggregate_selector_removed surface=" .. selector.surface ..
    " identifier=" .. selector.identifier .. " replacement=" .. selector.identifier
end

local find_removed_aggregate_selector

local function find_in_args(args)
  for _, argument in ipairs(args or {}) do
    local selector = find_removed_aggregate_selector(argument.value)
    if selector then return selector end
  end
  return nil
end

local function find_in_block(block)
  if not block then return nil end
  for _, statement in ipairs(block.statements or {}) do
    local selector = find_removed_aggregate_selector(statement.expr)
    if selector then return selector end
  end
  return nil
end

local function find_in_segments(segments)
  for _, segment in ipairs(segments or {}) do
    if segment.kind == "index" then
      local selector = find_removed_aggregate_selector(segment.expr)
      if selector then return selector end
    elseif segment.kind == "path_segment" then
      local selector = find_removed_aggregate_selector(segment.expression)
      if selector then return selector end
    end
  end
  return nil
end

find_removed_aggregate_selector = function(value)
  if type(value) ~= "table" then return nil end
  if value.kind == "action_block" then return find_in_block(value) end

  local kind = value.kind
  if kind == "call" then
    if (value.name == "array" or value.name == "hash") and #value.args == 1 then
      local argument = value.args[1]
      if argument.argument_kind == "positional" and argument.value and argument.value.kind == "variable" then
        return { surface = value.name, identifier = argument.value.name }
      end
    end
    return find_in_args(value.args)
  elseif kind == "recognition_checkpoint" or kind == "recognize_once" or
      kind == "observe_recognition" or
      kind == "recognition_commit" or kind == "recognition_rollback" or
      kind == "progressive_dispatch_span" or kind == "staged_parse_job_marker" then
    return nil
  elseif kind == "fluent_chain" then
    local selector = find_removed_aggregate_selector(value.receiver)
    if selector then return selector end
    for _, call in ipairs(value.calls or {}) do
      selector = find_in_args(call.args)
      if selector then return selector end
    end
    return nil
  elseif kind == "receiver_mutation_chain" then
    local selector = find_in_block(value.mutation and value.mutation.callback and value.mutation.callback.body)
    if selector then return selector end
    for _, call in ipairs(value.continuation or {}) do
      selector = find_in_args(call.args)
      if selector then return selector end
    end
    return nil
  elseif kind == "assign_scalar" or kind == "assign_array_append" then
    return find_removed_aggregate_selector(value.value)
  elseif kind == "assign_hash_index" then
    return find_removed_aggregate_selector(value.key) or find_removed_aggregate_selector(value.value)
  elseif kind == "assign_nested_access" then
    return find_in_segments(value.segments) or find_removed_aggregate_selector(value.value)
  elseif kind == "indexed_var" then
    return find_removed_aggregate_selector(value.index)
  elseif kind == "nested_access" then
    return find_in_segments(value.segments)
  elseif kind == "value_access" then
    return find_removed_aggregate_selector(value.receiver) or find_in_segments(value.segments)
  elseif kind == "array_literal" then
    for _, item in ipairs(value.items or {}) do
      local selector = find_removed_aggregate_selector(item)
      if selector then return selector end
    end
    return nil
  elseif kind == "hash_literal" then
    for _, entry in ipairs(value.entries or {}) do
      local selector = find_removed_aggregate_selector(entry.key) or
        find_removed_aggregate_selector(entry.value)
      if selector then return selector end
    end
    return nil
  elseif kind == "codeblock_literal" or kind == "codeblock_literal_error" then
    return nil
  elseif kind == "block_value" or kind == "codeblock_argument" then
    return find_in_block(value.block)
  elseif kind == "control_if" or kind == "control_while" then
    return find_removed_aggregate_selector(value.condition) or find_in_args(value.args) or find_in_block(value.body)
  elseif kind == "control_switch" then
    local selector = find_removed_aggregate_selector(value.source_expr) or find_in_args(value.args) or
      find_in_block(value.body)
    if selector then return selector end
    for _, case_expr in ipairs(value.cases or {}) do
      selector = find_removed_aggregate_selector(case_expr)
      if selector then return selector end
    end
    return find_removed_aggregate_selector(value.default)
  elseif kind == "control_case" then
    return find_removed_aggregate_selector(value.match) or find_in_args(value.args) or find_in_block(value.body)
  elseif kind == "control_else" or kind == "control_default" then
    return find_in_args(value.args) or find_in_block(value.body)
  elseif kind and kind:match("^control_") then
    return find_in_args(value.args)
  end
  return nil
end

function M.find_removed_aggregate_selector(value)
  return find_removed_aggregate_selector(value)
end

local project

local function project_list(values)
  local result = json.array()
  for index, value in ipairs(values) do
    result[index] = project(value)
  end
  return result
end

project = function(value)
  local node_type = M.node_type(value)
  if node_type == nil then
    local value_type = type(value)
    if value == json.null or value_type == "string" or value_type == "number" or value_type == "boolean" then
      return value
    elseif value_type == "table" then
      return project_list(value)
    end
    error("action AST projection cannot encode " .. value_type, 0)
  end
  if node_type == "ActionArgument" and value.argument_kind == "positional" then
    return project(value.value)
  end
  if node_type == "ActionExpr" and value.kind == "codeblock_literal" then
    return json.harray({
      kind = value.kind,
      version = value.version,
      signature = project(value.signature),
      body_source = value.body_source,
      body_ast = project(value.body_ast),
      source_text = value.source_text,
      source_span = project(value.source_span),
      body_span = project(value.body_span),
    })
  end

  local result = json.harray()
  for key, item in pairs(value) do
    if key ~= "argument_kind" and item ~= nil then
      result[key] = project(item)
    end
  end
  if node_type == "ActionArgument" then
    result.name = value.name
    result.value = project(value.value)
  end
  return result
end

function M.to_json(value)
  return project(value)
end

return M
