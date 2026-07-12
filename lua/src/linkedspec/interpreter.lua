local action_ast = require("linkedspec.action_ast")
local action_parser = require("linkedspec.action_parser")
local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local matching = require("linkedspec.matching")

local M = {}

local ERROR_MT = { __tostring = function(value) return "RuntimeInterpreterException: " .. value.message end }
local FLOW_MT = { __tostring = function(value) return "RuntimeActionFlow: " .. value.kind end }
local ENGINE_MT = { __runtime_interpreter_type = "LinkedSpecRuntimeEngine" }
local RESULT_MT = { __runtime_interpreter_type = "RuntimeParseResult" }
local EVENT_MT = { __runtime_interpreter_type = "RuntimeLifecycleEvent" }

local function fail(message, fields)
  fields = fields or {}
  fields.message = message
  error(setmetatable(fields, ERROR_MT), 0)
end

local function flow(kind, value)
  error(setmetatable({ kind = kind, value = value }, FLOW_MT), 0)
end

local function nextable(callback)
  local ok, result = pcall(callback)
  if ok then return { value = result, nexted = false } end
  if getmetatable(result) == FLOW_MT and result.kind == "next" then
    return { value = false, nexted = true }
  end
  error(result, 0)
end

function M.is_runtime_interpreter_error(value) return getmetatable(value) == ERROR_MT end

function M.node_type(value)
  if type(value) ~= "table" then return nil end
  local metatable = getmetatable(value)
  return metatable and metatable.__runtime_interpreter_type or nil
end

local function copy_value(value, active)
  if value == nil or value == json.null or type(value) ~= "table" then return value end
  if action_ast.node_type(value) == "ActionExpr" and value.kind == "block_value" then
    local copied = action_parser.parse_action_expression(value.source)
    if copied.kind ~= "block_value" then fail("runtime codeblock source no longer parses as a codeblock") end
    return copied
  end
  local kind = json.kind(value)
  if kind ~= "array" and kind ~= "harray" then return value end
  active = active or {}
  if active[value] then fail("runtime values must not be cyclic") end
  active[value] = true
  local result = kind == "array" and json.array() or json.harray()
  for key, item in pairs(value) do result[key] = copy_value(item, active) end
  active[value] = nil
  return result
end

function M.runtime_value_kind(value)
  if action_ast.node_type(value) == "ActionExpr" and value.kind == "block_value" then return "codeblock" end
  local kind = json.kind(value)
  if kind == "array" or kind == "harray" then return kind end
  if value == json.null or type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
    return "scalar"
  end
  fail("runtime value is not scalar, array, harray, or codeblock")
end

local function rule_result(matched, value)
  return { matched = matched, value = value }
end

function M.runtime_engine(compiled, options)
  if compiled_spec.node_type(compiled) ~= "CompiledSpec" then fail("runtime engine expects CompiledSpec") end
  options = options or {}
  if type(options) ~= "table" then fail("runtime engine options must be a table") end
  local max_iterations = options.max_iterations or 10000
  if type(max_iterations) ~= "number" or max_iterations % 1 ~= 0 or max_iterations <= 0 then
    fail("max_iterations must be a positive integer")
  end
  return setmetatable({
    compiled_spec = compiled,
    parse_mode = matching.parse_mode_from_name(options.parse_mode or "seek"),
    max_iterations = max_iterations,
    regex_cache = {},
  }, ENGINE_MT)
end

local function default_top(engine)
  for _, label in ipairs(engine.compiled_spec.compiled_rule_order) do
    if engine.compiled_spec.rules_by_label[label].header.is_top then return label end
  end
  return engine.compiled_spec.compiled_rule_order[1]
end

local function context(input, top_rule)
  local valid, position = json.validate_utf8(input)
  if not valid then fail("runtime input is not valid UTF-8 at byte " .. (position - 1)) end
  return {
    input = input,
    cursor_byte = 0,
    registers = matching.runtime_match_registers(input),
    retv = json.null,
    variables = {},
    arrays = {},
    harrays = {},
    active = {},
    lifecycle_events = {},
    rule_stack = {},
    top_rule = top_rule,
  }
end

local execute_rule
local evaluate_expr

local function argument_expr(arg) return arg.value end

local function target_name(expr)
  if expr.kind == "variable" then return expr.name end
  if expr.kind == "string" then return expr.value end
  return nil
end

local function lookup_binding(ctx, name)
  if ctx.variables[name] ~= nil then return ctx.variables[name], "variable" end
  if ctx.arrays[name] ~= nil then return ctx.arrays[name], "array" end
  if ctx.harrays[name] ~= nil then return ctx.harrays[name], "harray" end
  return json.null, nil
end

local function bind_scalar(ctx, name, value)
  ctx.variables[name] = copy_value(value)
  ctx.arrays[name] = nil
  ctx.harrays[name] = nil
  return copy_value(ctx.variables[name])
end

local function bind_array(ctx, name, value)
  local stored = json.kind(value) == "array" and copy_value(value) or json.array()
  ctx.variables[name] = nil
  ctx.harrays[name] = nil
  ctx.arrays[name] = stored
  return copy_value(stored)
end

local function bind_harray(ctx, name, value)
  local stored = json.kind(value) == "harray" and copy_value(value) or json.harray()
  ctx.variables[name] = nil
  ctx.arrays[name] = nil
  ctx.harrays[name] = stored
  return copy_value(stored)
end

local function store_binding(ctx, name, storage, value)
  if storage == "array" then return bind_array(ctx, name, value) end
  if storage == "harray" then return bind_harray(ctx, name, value) end
  return bind_scalar(ctx, name, value)
end

local function target_descriptor(expr)
  local name = target_name(expr)
  if name then return { kind = "scalar", name = name } end
  if expr.kind == "call" and (expr.name == "array" or expr.name == "hash" or expr.name == "harray") and
      #expr.args == 1 then
    name = target_name(argument_expr(expr.args[1]))
    if name then
      return { kind = expr.name == "array" and "array" or "harray", name = name }
    end
  end
  return nil
end

local function read_index(root, key)
  local kind = json.kind(root)
  if kind == "array" then
    if type(key) ~= "number" or key % 1 ~= 0 or key < 0 then return json.null end
    local value = root[key + 1]
    return value == nil and json.null or copy_value(value)
  elseif kind == "harray" then
    local value = root[tostring(key)]
    return value == nil and json.null or copy_value(value)
  end
  return json.null
end

local function write_index(root, key, value)
  local kind = json.kind(root)
  local stored = copy_value(value)
  if kind == "array" then
    if type(key) ~= "number" or key % 1 ~= 0 or key < 0 or key > #root then return false end
    root[key + 1] = stored
    return true, stored
  elseif kind == "harray" then
    root[tostring(key)] = stored
    return true, stored
  end
  return false
end

local function dispatch_edge_child(engine, edge_state, ctx)
  if edge_state.child_dispatched then return edge_state.child_result end
  edge_state.child_dispatched = true
  edge_state.child_result = execute_rule(engine, edge_state.target.label, edge_state.target.index, ctx)
  ctx.retv = copy_value(edge_state.child_result.value)
  return edge_state.child_result
end

local function match_capture(one, index)
  if not one or type(index) ~= "number" or index % 1 ~= 0 or index < 0 then return json.null end
  local value = one.captures[index + 1]
  return value == nil and json.null or value
end

local function match_captures(one)
  local result = json.array()
  if one then
    for index, value in ipairs(one.captures) do result[index] = value end
  end
  return result
end

local function match_named_map(one)
  local result = json.harray()
  if one then
    for key, value in pairs(one.named) do result[key] = value end
  end
  return result
end

local function capture_name(engine, expr, ctx, accumulator, edge_state)
  local name = target_name(expr)
  if name then return name end
  local value = evaluate_expr(engine, expr, ctx, accumulator, edge_state)
  return tostring(value == json.null and "" or value)
end

local function match_line_column(one, at_end)
  if not one then return { line = 1, column = 1 } end
  return matching.line_column_at_byte_offset(one.input, at_end and one.byte_end or one.byte_start)
end

local function evaluate_match_helper(engine, name, expr, ctx, accumulator, edge_state)
  local entry = name:sub(1, 6) == "entry_"
  local one
  if entry then one = ctx.registers.entry_match else one = ctx.registers.local_match end
  local suffix = name:sub(7)
  if suffix == "text" then return one and one:text() or json.null end
  if suffix == "group" then
    local index = expr.args[1] and evaluate_expr(
      engine,
      argument_expr(expr.args[1]),
      ctx,
      accumulator,
      edge_state
    ) or json.null
    return match_capture(one, index)
  end
  if suffix == "groups" then return match_captures(one) end
  if suffix == "named" or suffix == "has" then
    if not one or not expr.args[1] then return suffix == "has" and 0 or json.null end
    local key = capture_name(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state)
    if suffix == "has" then return one.named[key] ~= nil and 1 or 0 end
    return one.named[key] == nil and json.null or one.named[key]
  end
  if suffix == "map" then return match_named_map(one) end
  if suffix == "len" then return one and one:char_length() or json.null end
  if suffix == "start_pos" then return one and one:char_start() or json.null end
  if suffix == "end_pos" then return one and one:char_end() or json.null end
  local at_end = suffix:sub(1, 4) == "end_"
  local position = match_line_column(one, at_end)
  if suffix == "line" or suffix == "start_line" or suffix == "end_line" then return position.line end
  if suffix == "col" or suffix == "start_col" or suffix == "end_col" then return position.column end
  return nil
end

local function evaluate_call(engine, expr, ctx, accumulator, edge_state)
  local name = expr.name
  if name == "return" then
    local value = json.null
    if expr.args[1] then
      value = evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state)
    end
    flow("return", value)
  elseif name == "return_undef" then
    flow("return", json.null)
  elseif name == "next" then
    flow("next", json.null)
  elseif name == "exit_now" then
    local status = expr.args[1] and evaluate_expr(
      engine,
      argument_expr(expr.args[1]),
      ctx,
      accumulator,
      edge_state
    ) or 1
    if type(status) ~= "number" then status = 1 end
    local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
    fail("exit_now(" .. tostring(status) .. ") in rule " .. tostring(rule_label), {
      rule_label = rule_label,
      status = status,
    })
  elseif name == "call" then
    if not expr.args[1] then fail("call expects a rule name") end
    local label = target_name(argument_expr(expr.args[1]))
    if not label then fail("call rule name must be a variable or string") end
    local child = execute_rule(engine, label, 0, ctx)
    ctx.retv = copy_value(child.value)
    return child.value
  elseif name == "push" then
    local value
    if #expr.args == 0 and edge_state then
      value = dispatch_edge_child(engine, edge_state, ctx).value
    elseif #expr.args == 1 then
      local candidate = argument_expr(expr.args[1])
      local label = target_name(candidate)
      if label and engine.compiled_spec.rules_by_label[label] then
        local child = execute_rule(engine, label, 0, ctx)
        ctx.retv = copy_value(child.value)
        value = child.value
      else
        value = evaluate_expr(engine, candidate, ctx, accumulator, edge_state)
      end
    else
      value = ctx.retv
    end
    accumulator[#accumulator + 1] = copy_value(value)
    return value
  elseif name == "set" or name == "=" then
    local target = expr.args[1] and target_descriptor(argument_expr(expr.args[1]))
    if not target or not expr.args[2] then fail("set expects target and value") end
    local value = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
    if target.kind == "array" then return bind_array(ctx, target.name, value) end
    if target.kind == "harray" then return bind_harray(ctx, target.name, value) end
    return bind_scalar(ctx, target.name, value)
  elseif name == "array" then
    if not expr.args[1] then return json.array() end
    if #expr.args == 1 then
      local key = target_name(argument_expr(expr.args[1]))
      if key then
        local value = ctx.variables[key]
        if json.kind(value) == "array" then return copy_value(value) end
        return copy_value(ctx.arrays[key] or json.array())
      end
    end
    local result = json.array()
    for index, arg in ipairs(expr.args) do
      result[index] = copy_value(evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state))
    end
    return result
  elseif name == "hash" or name == "harray" then
    if not expr.args[1] then return json.harray() end
    if #expr.args == 1 then
      local key = target_name(argument_expr(expr.args[1]))
      if key then
        local value = ctx.variables[key]
        if json.kind(value) == "harray" then return copy_value(value) end
        return copy_value(ctx.harrays[key] or json.harray())
      end
    end
    local result = json.harray()
    local index = 1
    while index <= #expr.args do
      local key = evaluate_expr(engine, argument_expr(expr.args[index]), ctx, accumulator, edge_state)
      local value = json.null
      if expr.args[index + 1] then
        value = evaluate_expr(engine, argument_expr(expr.args[index + 1]), ctx, accumulator, edge_state)
      end
      result[tostring(key == json.null and "" or key)] = copy_value(value)
      index = index + 2
    end
    return result
  elseif name == "copy" then
    if not expr.args[1] then return json.null end
    return copy_value(evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state))
  elseif name:match("^entry_") or name:match("^match_") then
    local value = evaluate_match_helper(engine, name, expr, ctx, accumulator, edge_state)
    if value ~= nil then return value end
  end
  fail("unsupported runtime helper '" .. tostring(name) .. "'", { helper_name = name })
end

evaluate_expr = function(engine, expr, ctx, accumulator, edge_state)
  local kind = expr.kind
  if kind == "string" or kind == "number" or kind == "boolean" then return expr.value end
  if kind == "undef" then return json.null end
  if kind == "variable" then
    if expr.name == "retv" then
      if edge_state then return copy_value(dispatch_edge_child(engine, edge_state, ctx).value) end
      return copy_value(ctx.retv)
    end
    local value = lookup_binding(ctx, expr.name)
    return copy_value(value)
  end
  if kind == "block_value" then
    return copy_value(expr)
  end
  if kind == "array_literal" then
    local result = json.array()
    for index, item in ipairs(expr.items) do
      result[index] = copy_value(evaluate_expr(engine, item, ctx, accumulator, edge_state))
    end
    return result
  end
  if kind == "hash_literal" then
    local result = json.harray()
    for _, entry in ipairs(expr.entries) do
      local key = evaluate_expr(engine, entry.key, ctx, accumulator, edge_state)
      result[tostring(key)] = copy_value(evaluate_expr(engine, entry.value, ctx, accumulator, edge_state))
    end
    return result
  end
  if kind == "assign_scalar" then
    local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
    return bind_scalar(ctx, expr.name, value)
  end
  if kind == "assign_array_append" then
    local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
    local current, storage = lookup_binding(ctx, expr.name)
    local values = json.kind(current) == "array" and copy_value(current) or json.array()
    values[#values + 1] = copy_value(value)
    if storage == "variable" then return bind_scalar(ctx, expr.name, values) end
    return bind_array(ctx, expr.name, values)
  end
  if kind == "indexed_var" then
    local root = lookup_binding(ctx, expr.name)
    local key = evaluate_expr(engine, expr.index, ctx, accumulator, edge_state)
    return read_index(root, key)
  end
  if kind == "nested_access" then
    local value = lookup_binding(ctx, expr.base)
    for _, segment in ipairs(expr.segments) do
      local key = segment.kind == "key" and segment.value or evaluate_expr(
        engine,
        segment.expr,
        ctx,
        accumulator,
        edge_state
      )
      value = read_index(value, key)
      if value == json.null then break end
    end
    return copy_value(value)
  end
  if kind == "assign_hash_index" then
    local key = evaluate_expr(engine, expr.key, ctx, accumulator, edge_state)
    local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
    local current, storage = lookup_binding(ctx, expr.name)
    local root
    if json.kind(current) == "array" or json.kind(current) == "harray" then
      root = copy_value(current)
    else
      root = json.harray()
      storage = "harray"
    end
    if not write_index(root, key, value) then return json.null end
    return store_binding(ctx, expr.name, storage, root)
  end
  if kind == "assign_nested_access" then
    local current, storage = lookup_binding(ctx, expr.base)
    if json.kind(current) ~= "array" and json.kind(current) ~= "harray" then return json.null end
    local root = copy_value(current)
    local target = root
    for index, segment in ipairs(expr.segments) do
      local key = segment.kind == "key" and segment.value or evaluate_expr(
        engine,
        segment.expr,
        ctx,
        accumulator,
        edge_state
      )
      if index == #expr.segments then
        local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
        if not write_index(target, key, value) then return json.null end
      else
        local next_value = read_index(target, key)
        if json.kind(next_value) ~= "array" and json.kind(next_value) ~= "harray" then return json.null end
        local written, copied = write_index(target, key, next_value)
        if not written then return json.null end
        target = copied
      end
    end
    return store_binding(ctx, expr.base, storage, root)
  end
  if kind == "call" then return evaluate_call(engine, expr, ctx, accumulator, edge_state) end
  if kind == "fluent_chain" then
    local value = evaluate_expr(engine, expr.receiver, ctx, accumulator, edge_state)
    for _, call in ipairs(expr.calls) do
      local call_expr = { kind = "call", name = call.method, args = call.args }
      if call.method == "push" and #call.args == 0 then
        accumulator[#accumulator + 1] = copy_value(value)
      elseif call.method == "return" then
        local returned = value
        if #call.args > 0 then
          returned = evaluate_expr(engine, call.args[1].value, ctx, accumulator, edge_state)
        end
        flow("return", returned)
      else
        value = evaluate_call(engine, call_expr, ctx, accumulator, edge_state)
      end
    end
    return value
  end
  fail("unsupported runtime ActionIR kind '" .. tostring(kind) .. "'", { action_kind = kind })
end

local function execute_block(engine, block, ctx, accumulator, edge_state)
  for _, statement in ipairs(block.statements) do
    evaluate_expr(engine, statement.expr, ctx, accumulator, edge_state)
  end
end

local function lifecycle(engine, rule, name, ctx, accumulator)
  for _, payload in ipairs(rule.lifecycle_action_payloads) do
    if payload.lifecycle == name then
      ctx.lifecycle_events[#ctx.lifecycle_events + 1] = setmetatable({
        rule_label = rule.label,
        lifecycle = name,
        line = payload.line,
      }, EVENT_MT)
      execute_block(engine, payload.action_ast, ctx, accumulator, nil)
    end
  end
end

local function match_specific(engine, rule, index, ctx)
  local key = rule.label .. ":" .. index
  local alternation = engine.regex_cache[key]
  if not alternation then
    alternation = matching.compile_runtime_regex_alternation({ rule.regex_patterns[index + 1] })
    engine.regex_cache[key] = alternation
  end
  local one = alternation:match(ctx.input, ctx.cursor_byte, engine.parse_mode)
  return one and matching.reindex_runtime_regex_match(one, index) or nil
end

local function accept_match(engine, rule, one, ctx, accumulator)
  ctx.cursor_byte = one.byte_end
  ctx.registers = ctx.registers:with_local_match(one)
  for _, edge in ipairs(rule.action_edges) do
    if edge.regex_index == one.alternative_index then
      local edge_state = { edge = edge, target = edge.targets[1], child_dispatched = false }
      if edge.action_payload then
        execute_block(engine, edge.action_payload.action_ast, ctx, accumulator, edge_state)
        if not edge_state.child_dispatched and edge_state.target.label ~= rule.label then
          dispatch_edge_child(engine, edge_state, ctx)
        end
      else
        dispatch_edge_child(engine, edge_state, ctx)
      end
    end
  end
  lifecycle(engine, rule, "LE", ctx, accumulator)
end

local function regex_once(engine, rule, entry_index, ctx, accumulator)
  if #rule.regex_patterns == 0 then return false end
  if rule.mode_metadata.is_and and #rule.regex_patterns > 1 then
    for index = 0, #rule.regex_patterns - 1 do
      local one = match_specific(engine, rule, index, ctx)
      if not one then return false end
      accept_match(engine, rule, one, ctx, accumulator)
    end
    return true
  end
  local one
  if entry_index > 0 and entry_index < #rule.regex_patterns then
    one = match_specific(engine, rule, entry_index, ctx)
  else
    local alternation = engine.regex_cache[rule.label]
    if not alternation then
      alternation = matching.compile_runtime_regex_alternation(rule)
      engine.regex_cache[rule.label] = alternation
    end
    one = alternation:match(ctx.input, ctx.cursor_byte, engine.parse_mode)
  end
  if not one then return false end
  accept_match(engine, rule, one, ctx, accumulator)
  return true
end

local function blind_once(engine, rule, ctx, accumulator)
  local any = false
  for _, edge in ipairs(rule.blind_edges) do
    local child = execute_rule(engine, edge.target.label, edge.target.index, ctx)
    ctx.retv = copy_value(child.value)
    if edge.action_payload then execute_block(engine, edge.action_payload.action_ast, ctx, accumulator, nil) end
    if rule.mode_metadata.is_and and not child.matched then return false end
    if child.matched then
      any = true
      if rule.mode_metadata.is_and then accumulator[#accumulator + 1] = copy_value(child.value) else return true end
    end
  end
  return rule.mode_metadata.is_and and true or any
end

local function finish_value(accumulator, fallback)
  if #accumulator > 0 then
    local result = json.array()
    for index, value in ipairs(accumulator) do result[index] = copy_value(value) end
    return result
  end
  if fallback == nil then return json.null end
  return fallback
end

local function copy_store(source)
  local result = {}
  for key, value in pairs(source) do result[key] = copy_value(value) end
  return result
end

execute_rule = function(engine, label, entry_index, ctx)
  local rule = engine.compiled_spec.rules_by_label[label]
  if not rule then fail("rule '" .. label .. "' is not compiled", { rule_label = label }) end
  local recursion_key = label .. ":" .. entry_index .. ":" .. ctx.cursor_byte
  if ctx.active[recursion_key] then return rule_result(false, json.null) end
  ctx.active[recursion_key] = true
  local saved_registers = ctx.registers
  local saved_variables = ctx.variables
  local saved_arrays = ctx.arrays
  local saved_harrays = ctx.harrays
  ctx.registers = saved_registers:enter_child()
  ctx.variables = copy_store(saved_variables)
  ctx.arrays = copy_store(saved_arrays)
  ctx.harrays = copy_store(saved_harrays)
  ctx.rule_stack[#ctx.rule_stack + 1] = label
  local accumulator = {}
  local ok, result_or_flow = pcall(function()
    lifecycle(engine, rule, "I", ctx, accumulator)
    local minimum = rule.mode_metadata.rep_min
    local matched = false
    if minimum == nil then
      local matched_any = false
      for _ = 1, engine.max_iterations do
        local before = ctx.cursor_byte
        local attempt = nextable(function()
          if #rule.blind_edges > 0 then
            return blind_once(engine, rule, ctx, accumulator)
          end
          return regex_once(engine, rule, entry_index, ctx, accumulator)
        end)
        if not attempt.nexted then
          matched = attempt.value or matched_any
          break
        end
        matched_any = true
        if ctx.cursor_byte == before then matched = true; break end
      end
      if not matched then lifecycle(engine, rule, "LX", ctx, accumulator) end
      lifecycle(engine, rule, "E", ctx, accumulator)
      return rule_result(matched, finish_value(accumulator, ctx.retv))
    end

    local count = 0
    local failed = false
    for _ = 1, engine.max_iterations do
      if rule.mode_metadata.rep_max and count >= rule.mode_metadata.rep_max then break end
      local before = ctx.cursor_byte
      lifecycle(engine, rule, "LS", ctx, accumulator)
      local attempt = nextable(function()
        if #rule.blind_edges > 0 then
          return blind_once(engine, rule, ctx, accumulator)
        end
        return regex_once(engine, rule, entry_index, ctx, accumulator)
      end)
      if attempt.nexted then
        count = count + 1
        if ctx.cursor_byte == before then break end
      else
        if not attempt.value then failed = true; break end
        count = count + 1
        lifecycle(engine, rule, "IT", ctx, accumulator)
        if ctx.cursor_byte == before then break end
      end
    end
    if count < minimum then
      lifecycle(engine, rule, "LX", ctx, accumulator)
      fail("rule '" .. label .. "' expected at least " .. minimum .. " matches, got " .. count, {
        rule_label = label,
      })
    end
    lifecycle(engine, rule, "EX", ctx, accumulator)
    if failed or count > 0 then lifecycle(engine, rule, "LX", ctx, accumulator) end
    lifecycle(engine, rule, "E", ctx, accumulator)
    return rule_result(count > 0, finish_value(accumulator, ctx.retv))
  end)
  ctx.rule_stack[#ctx.rule_stack] = nil
  ctx.registers = saved_registers
  ctx.variables = saved_variables
  ctx.arrays = saved_arrays
  ctx.harrays = saved_harrays
  ctx.active[recursion_key] = nil
  if ok then return result_or_flow end
  if getmetatable(result_or_flow) == FLOW_MT then
    if result_or_flow.kind == "return" then return rule_result(true, copy_value(result_or_flow.value)) end
    if result_or_flow.kind == "next" then return rule_result(true, finish_value(accumulator, ctx.retv)) end
  end
  error(result_or_flow, 0)
end

function M.runtime_parse(engine, input, options)
  if M.node_type(engine) ~= "LinkedSpecRuntimeEngine" then fail("runtime_parse expects runtime engine") end
  if type(input) ~= "string" then fail("runtime input must be a string") end
  options = options or {}
  local top = options.top_rule or default_top(engine)
  if not top then fail("compiled spec does not contain any rules") end
  local ctx = context(input, top)
  local result = execute_rule(engine, top, 0, ctx)
  local output = json.array({ copy_value(result.value) })
  return setmetatable({
    matched = result.matched,
    value = copy_value(result.value),
    output = output,
    cursor_code_unit = ctx.cursor_byte,
    cursor_char_offset = matching.byte_offset_to_char_offset(input, ctx.cursor_byte),
    lifecycle_events = ctx.lifecycle_events,
  }, RESULT_MT)
end

M.runtime_execute = M.runtime_parse

function M.to_json(value)
  local node_type = M.node_type(value)
  if node_type == "RuntimeLifecycleEvent" then
    return json.harray({ rule_label = value.rule_label, lifecycle = value.lifecycle, line = value.line })
  elseif node_type == "RuntimeParseResult" then
    local events = json.array()
    for index, event in ipairs(value.lifecycle_events) do events[index] = M.to_json(event) end
    return json.harray({
      matched = value.matched,
      value = copy_value(value.value),
      output = copy_value(value.output),
      cursor_code_unit = value.cursor_code_unit,
      cursor_char_offset = value.cursor_char_offset,
      lifecycle_events = events,
    })
  end
  fail("runtime to_json expects parse result or lifecycle event")
end

return M
