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

function M.hash_entry(key, value)
  return node("ActionHashEntry", { key = key, value = value })
end

function M.fluent_call(method, args, source, source_span, fields)
  fields = fields or {}
  fields.method = method
  fields.args = args
  fields.source = source
  fields.source_span = source_span
  return node("ActionFluentCall", fields)
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
