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

local function dispatch_edge_child(engine, edge_state, ctx)
  if edge_state.child_dispatched then return edge_state.child_result end
  edge_state.child_dispatched = true
  edge_state.child_result = execute_rule(engine, edge_state.target.label, edge_state.target.index, ctx)
  ctx.retv = copy_value(edge_state.child_result.value)
  return edge_state.child_result
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
    local key = expr.args[1] and target_name(argument_expr(expr.args[1]))
    if not key or not expr.args[2] then fail("set expects target and value") end
    local value = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
    ctx.variables[key] = copy_value(value)
    return value
  elseif name == "array" then
    if not expr.args[1] then return json.array() end
    local key = target_name(argument_expr(expr.args[1]))
    return key and (ctx.arrays[key] or ctx.variables[key] or json.array()) or json.array()
  elseif name == "hash" or name == "harray" then
    if not expr.args[1] then return json.harray() end
    local key = target_name(argument_expr(expr.args[1]))
    return key and (ctx.harrays[key] or ctx.variables[key] or json.harray()) or json.harray()
  elseif name == "entry_text" then
    return ctx.registers.entry_match and ctx.registers.entry_match:text() or json.null
  elseif name == "match_text" then
    return ctx.registers.local_match and ctx.registers.local_match:text() or json.null
  end
  fail("unsupported runtime helper '" .. tostring(name) .. "'", { helper_name = name })
end

evaluate_expr = function(engine, expr, ctx, accumulator, edge_state)
  local kind = expr.kind
  if kind == "string" or kind == "number" or kind == "boolean" then return expr.value end
  if kind == "undef" then return json.null end
  if kind == "variable" then
    if expr.name == "retv" then return ctx.retv end
    if ctx.variables[expr.name] ~= nil then return ctx.variables[expr.name] end
    if ctx.arrays[expr.name] ~= nil then return ctx.arrays[expr.name] end
    if ctx.harrays[expr.name] ~= nil then return ctx.harrays[expr.name] end
    return json.null
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
    ctx.variables[expr.name] = copy_value(value)
    return value
  end
  if kind == "assign_array_append" then
    local values = ctx.arrays[expr.name]
    if not values then values = json.array(); ctx.arrays[expr.name] = values end
    local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
    values[#values + 1] = copy_value(value)
    return copy_value(values)
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
