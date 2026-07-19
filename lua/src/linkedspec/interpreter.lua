local action_ast = require("linkedspec.action_ast")
local action_contracts = require("linkedspec.action_contracts")
local action_parser = require("linkedspec.action_parser")
local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local matching = require("linkedspec.matching")
local runtime_scoped_binding = require("linkedspec.runtime_scoped_binding")
local scalar_numeric = require("linkedspec.scalar_numeric")
local trace = require("linkedspec.trace")
local trace_support = require("linkedspec.trace_support")
local unicode_case = require("linkedspec.unicode_case_mapping")
local user_function_registry = require("linkedspec.user_function_registry")

local M = {}

local ERROR_MT = {
  __runtime_interpreter_type = "RuntimeInterpreterException",
  __tostring = function(value) return "RuntimeInterpreterException: " .. value.message end,
  exit_now = {
    __runtime_interpreter_type = "RuntimeExitNow",
    __tostring = function(value) return "RuntimeExitNow: " .. value.message end,
  },
  diagnostic_output_sink_failure = {
    __tostring = function() return "RuntimeDiagnosticOutputSinkFailure" end,
  },
}
local FLOW_MT = { __tostring = function(value) return "RuntimeActionFlow: " .. value.kind end }
local ENGINE_MT = { __runtime_interpreter_type = "LinkedSpecRuntimeEngine" }
local RESULT_MT = { __runtime_interpreter_type = "RuntimeParseResult" }
local EVENT_MT = { __runtime_interpreter_type = "RuntimeLifecycleEvent" }
local DIAGNOSTIC_OUTPUT_EVENT_MT = { __runtime_interpreter_type = "RuntimeDiagnosticOutputEvent" }
local DIAGNOSTIC_MT = { __runtime_interpreter_type = "RuntimeDiagnostic" }
local HELPER_REGEX_MT = { __runtime_interpreter_type = "RuntimeHelperRegex" }

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
function M.is_runtime_exit_now(value) return getmetatable(value) == ERROR_MT.exit_now end
function M.is_runtime_diagnostic(value) return getmetatable(value) == DIAGNOSTIC_MT end

function M.node_type(value)
  if type(value) ~= "table" then return nil end
  local metatable = getmetatable(value)
  return metatable and metatable.__runtime_interpreter_type or nil
end

local function copy_value(value, active)
  if value == nil or value == json.null or type(value) ~= "table" then return value end
  if action_ast.node_type(value) == "ActionExpr" and
      (value.kind == "block_value" or value.kind == "codeblock_argument") then
    local copied = action_parser.parse_action_expression(value.source)
    if copied.kind ~= "block_value" then fail("runtime codeblock source no longer parses as a codeblock") end
    return value.kind == "codeblock_argument" and action_ast.contextual_codeblock_argument(copied) or copied
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
  if action_ast.node_type(value) == "ActionExpr" and
      (value.kind == "block_value" or value.kind == "codeblock_argument") then
    return "codeblock"
  end
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
  if options.spec_name ~= nil and type(options.spec_name) ~= "string" then
    fail("spec_name must be a string when present")
  end
  if options.spec_path ~= nil and type(options.spec_path) ~= "string" then
    fail("spec_path must be a string when present")
  end
  if options.trace ~= nil and not trace.is_trace_emitter(options.trace) then
    fail("trace must be a LinkedSpecTraceEmitter")
  end
  return trace_support.run(
    options.trace,
    "lua_runtime:create_engine",
    "rules=" .. #compiled.compiled_rule_order ..
      " functions=" .. #compiled.function_registry.entries,
    function()
      compiled_spec.validate_no_removed_aggregate_selectors(compiled)
      return setmetatable({
        compiled_spec = compiled,
        parse_mode = matching.parse_mode_from_name(options.parse_mode or "seek"),
        max_iterations = max_iterations,
        spec_name = options.spec_name,
        spec_path = options.spec_path,
        regex_cache = {},
        boundary_regex_cache = {},
        helper_regex_cache = {},
        user_function_body_cache = {},
      }, ENGINE_MT)
    end,
    "ok"
  )
end

local function runtime_diagnostic(engine, fields)
  local effective_rule = fields.rule_label or fields.top_rule
  local diagnostic = {
    type = "runtime_parser",
    stage = fields.stage,
    owner_stage = "lua_runtime",
    summary = fields.summary,
    detail = fields.detail,
    spec_name = engine.spec_name,
    spec_path = engine.spec_path,
    top_rule = fields.top_rule,
    rule_label = fields.rule_label,
    handler_source_label = fields.handler_source_label or
      (effective_rule and ("lua_runtime:rule:" .. effective_rule) or "lua_runtime"),
  }
  for _, name in ipairs({ "code", "entry_rule", "helper_name", "actual_arity", "expected_arity" }) do
    if fields[name] ~= nil then diagnostic[name] = fields[name] end
  end
  return setmetatable(diagnostic, DIAGNOSTIC_MT)
end

local function with_runtime_diagnostic(value, diagnostic)
  if getmetatable(value) ~= ERROR_MT or value.diagnostic ~= nil then return value end
  local wrapped = {}
  for key, field_value in pairs(value) do wrapped[key] = field_value end
  wrapped.diagnostic = diagnostic
  return setmetatable(wrapped, ERROR_MT)
end

local function public_parser_start_byte(input)
  local cursor_byte = 0
  while cursor_byte < #input do
    local remaining = input:sub(cursor_byte + 1)
    local after_line = remaining:match("^[ \t]*\n()") or remaining:match("^[ \t]*#[^\n]*\n()")
    if after_line ~= nil then
      cursor_byte = cursor_byte + after_line - 1
    elseif remaining:match("^[ \t]*#[^\n]*$") then
      return #input
    else
      break
    end
  end
  return cursor_byte
end

local function context(
    engine,
    input,
    top_rule,
    compiled_rules,
    diagnostic_sink,
    trace_emitter,
    generated_families,
    generated_source_identity
  )
  local valid, position = json.validate_utf8(input)
  if not valid then
    local detail = "runtime input is not valid UTF-8 at byte " .. (position - 1)
    fail(detail, {
      diagnostic = runtime_diagnostic(engine, {
        stage = "runtime_input",
        summary = "Lua runtime input validation failed",
        detail = detail,
        top_rule = top_rule,
        rule_label = top_rule,
      }),
    })
  end
  return {
    input = input,
    cursor_byte = 0,
    registers = matching.runtime_match_registers(input),
    retv = json.null,
    variables = {},
    arrays = {},
    harrays = {},
    active_user_functions = {},
    user_function_parameter_kinds = nil,
    active_contextual_codeblocks = {},
    mark_buckets = {},
    active = {},
    lifecycle_events = {},
    diagnostic_sink = diagnostic_sink,
    trace = trace_emitter,
    rule_stack = {},
    accumulator_stack = {},
    cursor_stack = {},
    compiled_rules = compiled_rules,
    top_rule = top_rule,
    generated_families = generated_families,
    generated_source_identity = generated_source_identity,
  }
end

local function runtime_trace_event(ctx, kind, topic, details, level)
  if ctx.trace == nil then return nil end
  return trace.emit_trace_event(ctx.trace, kind, topic, details, level)
end

local function runtime_trace_decision(ctx, topic, taken, reason, level)
  if ctx.trace == nil then return taken end
  return trace.trace_decision(ctx.trace, topic, taken, reason, level)
end

local function runtime_trace_scope(ctx, topic, details, level)
  if ctx.trace == nil then return nil end
  return trace.enter_trace_scope(ctx.trace, topic, details, level)
end

local function runtime_trace_scope_exit(ctx, scope, details)
  if ctx.trace ~= nil and scope ~= nil then trace.exit_trace_scope(ctx.trace, scope, details) end
end

local execute_rule
local evaluate_expr
local evaluate_block_value
local execute_block
local invalid_helper_arity
local execute_user_function
local execute_contextual_codeblock

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
  local frame = ctx.accumulator_stack[#ctx.accumulator_stack]
  if frame and frame.label == name then return frame.values, "implicit_accumulator" end
  if ctx.compiled_rules[name] then return json.array(), "implicit_rule_accumulator" end
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
  return nil
end

local function binding_target_descriptor(expr)
  if expr.kind == "variable" then return { kind = "scalar", name = expr.name } end
  return nil
end

local function binding_kind_mismatch(name, expected_kind, value)
  fail("binding_kind_mismatch", {
    code = "binding_kind_mismatch",
    identifier = name,
    expected_kind = expected_kind,
    actual_kind = M.runtime_value_kind(value),
  })
end

local function array_binding_for_mutation(ctx, name)
  local value, storage = lookup_binding(ctx, name)
  if storage == nil then return json.array(), nil end
  if json.kind(value) ~= "array" then binding_kind_mismatch(name, "array", value) end
  return copy_value(value), storage
end

local function store_array_mutation(ctx, target, storage, value)
  if storage == "array" then return bind_array(ctx, target.name, value) end
  if storage == "implicit_accumulator" then
    local frame = ctx.accumulator_stack[#ctx.accumulator_stack]
    if not frame or frame.label ~= target.name then
      fail("implicit accumulator is not active", { identifier = target.name })
    end
    for index = #frame.values, 1, -1 do frame.values[index] = nil end
    for index, item in ipairs(value) do frame.values[index] = copy_value(item) end
    return copy_value(frame.values)
  end
  return bind_scalar(ctx, target.name, value)
end

local function harray_binding_for_mutation(ctx, name)
  local value, storage = lookup_binding(ctx, name)
  if storage == nil then return json.harray(), nil end
  if json.kind(value) ~= "harray" then binding_kind_mismatch(name, "harray", value) end
  return copy_value(value), storage
end

local function store_harray_mutation(ctx, target, storage, value)
  if storage == "harray" then return bind_harray(ctx, target.name, value) end
  return bind_scalar(ctx, target.name, value)
end

local function append_array_binding(ctx, target, value)
  local values, storage = array_binding_for_mutation(ctx, target.name)
  values[#values + 1] = copy_value(value)
  return store_array_mutation(ctx, target, storage, values)
end

local function runtime_access_index(value)
  local number
  if type(value) == "number" then
    number = value
  elseif type(value) == "string" then
    number = tonumber(value)
  elseif type(value) == "boolean" then
    number = value and 1 or 0
  end
  if number == nil or number ~= number or number == math.huge or number == -math.huge or number < 0 then
    return -1
  end
  return math.floor(number)
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

local function literal_nonnegative_index(expr)
  if expr.kind ~= "number" or type(expr.value) ~= "number" or expr.value % 1 ~= 0 or expr.value < 0 then
    return nil
  end
  return expr.value
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

local function access_segment_matches(root, segment)
  local kind = json.kind(root)
  return (segment.kind == "key" and kind == "harray") or
    (segment.kind == "index" and kind == "array")
end

local function is_passive_terminal_rule(rule)
  return #rule.lifecycle_action_payloads == 0 and
    #rule.action_edges == 0 and
    #rule.blind_edges == 0 and
    #rule.plain_action_payloads == 0
end

local function dispatch_edge_child(engine, edge_state, ctx)
  if edge_state.child_dispatched then return edge_state.child_result end
  edge_state.child_dispatched = true
  local cursor_before = ctx.cursor_byte
  local child_rule = engine.compiled_spec.rules_by_label[edge_state.target.label]
  if not child_rule then
    fail("action edge references undefined child '" .. edge_state.target.label .. "'", {
      rule_label = edge_state.rule_label,
    })
  end
  local passive = is_passive_terminal_rule(child_rule)
  if passive then
    edge_state.child_result = rule_result(false, json.null)
  else
    edge_state.child_result = execute_rule(engine, edge_state.target.label, edge_state.target.index, ctx)
  end
  runtime_trace_decision(
    ctx,
    "lua_runtime:child_dispatch",
    edge_state.child_result.matched,
    "edge_family=action rule=" .. edge_state.rule_label ..
      " target=" .. edge_state.target.label .. "[" .. tostring(edge_state.target.index) .. "]" ..
      (passive and " passive=1" or "") ..
      " cursor_before=" .. tostring(cursor_before) .. " cursor_after=" .. tostring(ctx.cursor_byte),
    trace.TRACE_DEBUG
  )
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

local PURE_STRING_HELPERS = {
  cat = true,
  contains_substr = true,
  ends_with = true,
  is_defined = true,
  is_empty = true,
  is_nonempty = true,
  is_undefined = true,
  length = true,
  lowercase = true,
  lowercase_each = true,
  matches = true,
  replace_substr = true,
  rm_prefix = true,
  rm_suffix = true,
  split = true,
  starts_with = true,
  substr = true,
  trim = true,
  uppercase = true,
  uppercase_each = true,
}

local TERMINAL_STRING_HELPERS = {
  contains_substr = true,
  ends_with = true,
  is_defined = true,
  is_empty = true,
  is_nonempty = true,
  is_undefined = true,
  length = true,
  matches = true,
  starts_with = true,
}

local function is_string_comparison(name)
  return name == "str_eq" or name == "str_ne" or name == "str_gt" or name == "str_ge" or
    name == "str_lt" or name == "str_le"
end

local function is_pure_string_helper(name)
  return PURE_STRING_HELPERS[name] or is_string_comparison(name)
end

local function stable_number_string(value)
  if value == 0 then return "0" end
  if value % 1 == 0 then return string.format("%.0f", value) end
  return tostring(value)
end

local function scalar_string(value, null_as_empty)
  if value == json.null then return null_as_empty and "" or nil end
  if action_ast.node_type(value) == "ActionExpr" and
      (value.kind == "block_value" or value.kind == "codeblock_argument") then return nil end
  local kind = json.kind(value)
  if kind == "array" or kind == "harray" or type(value) == "table" then
    return null_as_empty and "" or nil
  end
  if type(value) == "boolean" then return value and "1" or "0" end
  if type(value) == "number" then return stable_number_string(value) end
  if type(value) == "string" then return value end
  return nil
end

local DIAGNOSTIC_OUTPUT_HELPERS = {
  print = true,
  print_each = true,
  say = true,
}

local function runtime_diagnostic_string(value)
  return scalar_string(value, true) or ""
end

local function emit_runtime_diagnostic_output(ctx, helper_name, message)
  if ctx.diagnostic_sink == nil then return end
  local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
  local delivered, failure = pcall(ctx.diagnostic_sink, setmetatable({
    helper_name = helper_name,
    rule_label = rule_label,
    message = message,
  }, DIAGNOSTIC_OUTPUT_EVENT_MT))
  if not delivered then
    error(setmetatable({ failure = failure }, ERROR_MT.diagnostic_output_sink_failure), 0)
  end
end

local function evaluate_runtime_diagnostic_output(
  engine,
  name,
  expr,
  ctx,
  accumulator,
  edge_state
)
  if name == "print_each" then
    if #expr.args < 2 or #expr.args > 3 then
      invalid_helper_arity(name, "2 or 3 positional arguments", #expr.args)
    end
  elseif #expr.args == 0 then
    invalid_helper_arity(name, "at least 1 positional argument", 0)
  end

  local values = {}
  for _, arg in ipairs(expr.args) do
    values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
  end

  if name == "print_each" then
    local items = json.kind(values[1]) == "array" and values[1] or json.array()
    local prefix = runtime_diagnostic_string(values[2])
    local suffix = #values == 3 and runtime_diagnostic_string(values[3]) or ""
    for _, item in ipairs(items) do
      emit_runtime_diagnostic_output(ctx, name, prefix .. runtime_diagnostic_string(item) .. suffix)
    end
    return json.null
  end

  local parts = {}
  for index, value in ipairs(values) do parts[index] = runtime_diagnostic_string(value) end
  local message = table.concat(parts)
  if name == "say" then message = message .. "\n" end
  emit_runtime_diagnostic_output(ctx, name, message)
  return json.null
end

local function helper_regex(pattern, flags)
  return setmetatable({ pattern = pattern, flags = flags or "" }, HELPER_REGEX_MT)
end

local function compile_helper_regex(engine, value)
  if getmetatable(value) ~= HELPER_REGEX_MT then return nil end
  local enabled = {}
  for flag in value.flags:gmatch(".") do
    if flag == "i" or flag == "m" or flag == "s" or flag == "x" then
      enabled[flag] = true
    elseif flag ~= "g" and flag ~= "o" then
      return nil
    end
  end
  local compile_flags = ""
  for _, flag in ipairs({ "i", "m", "s", "x" }) do
    if enabled[flag] then compile_flags = compile_flags .. flag end
  end
  local key = compile_flags .. "\0" .. value.pattern
  local cached = engine.helper_regex_cache[key]
  if cached == false then return nil end
  if cached then return cached end
  local effective_pattern = compile_flags == "" and value.pattern or
    "(?" .. compile_flags .. ")" .. value.pattern
  local ok, compiled = pcall(matching.compile_runtime_regex_alternation, { effective_pattern })
  if not ok then
    engine.helper_regex_cache[key] = false
    return nil
  end
  engine.helper_regex_cache[key] = compiled
  return compiled
end

local function decode_codepoint(value, byte_index)
  local first = value:byte(byte_index)
  if first <= 0x7F then return first, 1 end
  local second = value:byte(byte_index + 1)
  if first <= 0xDF then return (first - 0xC0) * 0x40 + second - 0x80, 2 end
  local third = value:byte(byte_index + 2)
  if first <= 0xEF then
    return (first - 0xE0) * 0x1000 + (second - 0x80) * 0x40 + third - 0x80, 3
  end
  local fourth = value:byte(byte_index + 3)
  return (first - 0xF0) * 0x40000 + (second - 0x80) * 0x1000 +
    (third - 0x80) * 0x40 + fourth - 0x80, 4
end

local function is_unicode_whitespace(codepoint)
  return (codepoint >= 0x0009 and codepoint <= 0x000D) or codepoint == 0x0020 or codepoint == 0x0085 or
    codepoint == 0x00A0 or codepoint == 0x1680 or (codepoint >= 0x2000 and codepoint <= 0x200A) or
    codepoint == 0x2028 or codepoint == 0x2029 or codepoint == 0x202F or codepoint == 0x205F or
    codepoint == 0x3000
end

local function split_unicode_characters(value)
  local result = json.array()
  local byte_index = 1
  while byte_index <= #value do
    local _, width = decode_codepoint(value, byte_index)
    result[#result + 1] = value:sub(byte_index, byte_index + width - 1)
    byte_index = byte_index + width
  end
  return result
end

local function split_literal(value, delimiter)
  if delimiter == "" then return split_unicode_characters(value) end
  local result = json.array()
  local position = 1
  while true do
    local start_at, end_at = value:find(delimiter, position, true)
    if not start_at then
      result[#result + 1] = value:sub(position)
      return result
    end
    result[#result + 1] = value:sub(position, start_at - 1)
    position = end_at + 1
  end
end

local function split_regex(value, regex)
  local result = json.array()
  local segment_start = 0
  local search_cursor = 0
  while search_cursor <= #value do
    local one = regex:seek_match(value, search_cursor)
    if not one then break end
    if one.byte_end == one.byte_start then
      if one.byte_start > segment_start then
        result[#result + 1] = value:sub(segment_start + 1, one.byte_start)
        segment_start = one.byte_start
      end
      if one.byte_start == #value then break end
      local _, width = decode_codepoint(value, one.byte_start + 1)
      search_cursor = one.byte_start + width
    else
      result[#result + 1] = value:sub(segment_start + 1, one.byte_start)
      segment_start = one.byte_end
      search_cursor = one.byte_end
    end
  end
  result[#result + 1] = value:sub(segment_start + 1)
  return result
end

local function stable_helper_flags(flags)
  local enabled = {}
  for flag in flags:gmatch(".") do enabled[flag] = true end
  local result = ""
  for _, flag in ipairs({ "g", "i", "m", "o", "s", "x" }) do
    if enabled[flag] then result = result .. flag end
  end
  return result
end

local function expand_regex_replacement(replacement, one)
  return (replacement:gsub("%$(%d+)", function(raw_index)
    local index = tonumber(raw_index)
    if index == 0 then return one:text() end
    return one.groups[index + 1] or ""
  end))
end

local function replace_regex(source, regex, replacement, replace_all)
  local result = {}
  local output_cursor = 0
  local search_cursor = 0
  while search_cursor <= #source do
    local one = regex:seek_match(source, search_cursor)
    if not one then break end
    result[#result + 1] = source:sub(output_cursor + 1, one.byte_start)
    result[#result + 1] = expand_regex_replacement(replacement, one)
    output_cursor = one.byte_end
    if not replace_all then break end
    if one.byte_start == one.byte_end then
      if one.byte_start == #source then break end
      local _, width = decode_codepoint(source, one.byte_start + 1)
      search_cursor = one.byte_start + width
    else
      search_cursor = one.byte_end
    end
  end
  result[#result + 1] = source:sub(output_cursor + 1)
  return table.concat(result)
end

local function trim_unicode(value)
  local first_content
  local last_content_end = 0
  local byte_index = 1
  while byte_index <= #value do
    local codepoint, width = decode_codepoint(value, byte_index)
    if not is_unicode_whitespace(codepoint) then
      first_content = first_content or byte_index
      last_content_end = byte_index + width - 1
    end
    byte_index = byte_index + width
  end
  if not first_content then return "" end
  return value:sub(first_content, last_content_end)
end

local function runtime_integer(value)
  if type(value) == "number" and value % 1 == 0 then return value end
  if type(value) == "string" and value:match("^-?%d+$") then return tonumber(value) end
  return nil
end

local function value_length(value)
  if value == json.null then return json.null end
  local kind = json.kind(value)
  if kind == "array" then return #value end
  if kind == "harray" then
    local count = 0
    for _ in pairs(value) do count = count + 1 end
    return count
  end
  local text = scalar_string(value, false)
  if text == nil then return json.null end
  return matching.byte_offset_to_char_offset(text, #text)
end

local function is_empty_value(value)
  if value == json.null then return true end
  if type(value) == "string" then return value == "" end
  local kind = json.kind(value)
  if kind == "array" then return #value == 0 end
  if kind == "harray" then return next(value) == nil end
  return false
end

local function runtime_truthy(value)
  if value == json.null then return false end
  if type(value) == "boolean" then return value end
  if type(value) == "number" then return value ~= 0 end
  if type(value) == "string" then return value ~= "" end
  local kind = json.kind(value)
  if kind == "array" then return #value > 0 end
  if kind == "harray" then return next(value) ~= nil end
  return true
end

local LOGICAL_HELPERS = {
  ["and"] = true,
  ["not"] = true,
  ["or"] = true,
}

local function evaluate_runtime_logical(
  engine,
  name,
  expr,
  ctx,
  accumulator,
  edge_state
)
  local expected = name == "not" and
    "exactly 1 positional argument" or "at least 1 positional argument"
  local valid
  if name == "not" then
    valid = #expr.args == 1
  else
    valid = #expr.args >= 1
  end
  for _, argument in ipairs(expr.args) do
    if argument.argument_kind ~= "positional" then valid = false end
  end
  if not valid then
    local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
    local detail = "helper_arity_mismatch: helper_name=" .. name ..
      " actual_arity=" .. #expr.args .. " expected_arity=" .. expected ..
      " in rule " .. tostring(rule_label)
    fail(detail, {
      code = "helper_arity_mismatch",
      helper_name = name,
      actual_arity = #expr.args,
      expected_arity = expected,
      diagnostic = runtime_diagnostic(engine, {
        stage = "helper_arity_mismatch",
        summary = "Lua logical helper arity failed",
        detail = detail,
        top_rule = ctx.top_rule,
        rule_label = rule_label,
        code = "helper_arity_mismatch",
        helper_name = name,
        actual_arity = #expr.args,
        expected_arity = expected,
      }),
    })
  end

  local values = {}
  for _, arg in ipairs(expr.args) do
    values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
  end

  if name == "and" then
    for _, value in ipairs(values) do
      if not runtime_truthy(value) then return false end
    end
    return true
  elseif name == "or" then
    for _, value in ipairs(values) do
      if runtime_truthy(value) then return true end
    end
    return false
  end
  return not runtime_truthy(values[1])
end

invalid_helper_arity = function(name, expected, actual)
  fail("helper '" .. name .. "' expects " .. expected .. ", got " .. actual, {
    code = "helper_arity_mismatch",
    helper_name = name,
    expected_arity = expected,
    actual_arity = actual,
  })
end

local function inline_branch_call(expr, name)
  return expr.kind == "call" and expr.name == name
end

local function validate_positional_arguments(name, args)
  for _, arg in ipairs(args) do
    if arg.argument_kind ~= "positional" then
      invalid_helper_arity(name, "positional arguments only", #args)
    end
  end
end

local function authored_value_kind(expr)
  if expr.kind == "block_value" or expr.kind == "codeblock_argument" then return "codeblock" end
  if expr.kind == "array_literal" then return "array" end
  if expr.kind == "hash_literal" then return "harray" end
  if expr.kind == "string" or expr.kind == "number" or expr.kind == "boolean" or expr.kind == "undef" then
    return "scalar"
  end
  return "unknown"
end

local function final_codeblock_argument(name, surface, args)
  validate_positional_arguments(name, args)
  local contract = action_contracts.builtin_final_codeblock_contract(surface, name)
  if contract == nil then return nil end
  if #args == 0 then
    fail("helper '" .. name .. "' requires a final codeblock argument", {
      code = "final_argument_not_codeblock",
      helper_name = name,
      value_kind = "missing",
    })
  end
  local block_expr = argument_expr(args[#args])
  if action_ast.node_type(block_expr) ~= "ActionExpr" or block_expr.kind ~= "block_value" then
    fail("helper '" .. name .. "' final argument must be a codeblock", {
      code = "final_argument_not_codeblock",
      helper_name = name,
      value_kind = authored_value_kind(block_expr),
    })
  end
  local before_count = #args - 1
  if not action_contracts.accepts_final_codeblock_argument_count(contract, before_count) then
    local minimum = contract.min_before_codeblock
    local maximum = contract.max_before_codeblock
    local expected = minimum == maximum and
      ("exactly " .. minimum .. " argument(s) before the final codeblock") or
      (minimum .. " to " .. maximum .. " arguments before the final codeblock")
    invalid_helper_arity(name, expected, before_count)
  end
  return block_expr, before_count
end

local function evaluate_with_block(engine, block_expr, scoped_value, ctx, accumulator, edge_state)
  return runtime_scoped_binding.run(ctx, "value", scoped_value, copy_value, function()
    return evaluate_block_value(engine, block_expr.block, ctx, accumulator, edge_state)
  end)
end

local function validate_inline_if(expr)
  validate_positional_arguments("if", expr.args)
  if #expr.args < 2 then
    invalid_helper_arity("if", "at least 2 positional arguments", #expr.args)
  end
  for index = 3, #expr.args do
    local branch = argument_expr(expr.args[index])
    if inline_branch_call(branch, "elseif") then
      validate_positional_arguments("elseif", branch.args)
      if #branch.args ~= 2 then
        invalid_helper_arity("elseif", "exactly 2 positional arguments", #branch.args)
      end
    elseif inline_branch_call(branch, "else") then
      validate_positional_arguments("else", branch.args)
      if #branch.args ~= 1 then
        invalid_helper_arity("else", "exactly 1 positional argument", #branch.args)
      end
      if index ~= #expr.args then
        invalid_helper_arity("if", "no arguments after else(...)", #expr.args)
      end
    elseif index ~= #expr.args then
      invalid_helper_arity("if", "one final plain fallback argument", #expr.args)
    end
  end
end

local function evaluate_inline_if(engine, expr, ctx, accumulator, edge_state)
  validate_inline_if(expr)
  local condition = evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state)
  if runtime_truthy(condition) then
    return evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
  end
  for index = 3, #expr.args do
    local branch = argument_expr(expr.args[index])
    if inline_branch_call(branch, "elseif") then
      local branch_condition = evaluate_expr(
        engine,
        argument_expr(branch.args[1]),
        ctx,
        accumulator,
        edge_state
      )
      if runtime_truthy(branch_condition) then
        return evaluate_expr(engine, argument_expr(branch.args[2]), ctx, accumulator, edge_state)
      end
    elseif inline_branch_call(branch, "else") then
      return evaluate_expr(engine, argument_expr(branch.args[1]), ctx, accumulator, edge_state)
    else
      return evaluate_expr(engine, branch, ctx, accumulator, edge_state)
    end
  end
  return json.null
end

local function validate_inline_switch(expr)
  validate_positional_arguments("switch", expr.args)
  if #expr.args == 0 then
    invalid_helper_arity("switch", "at least 1 positional argument", 0)
  end
  local saw_default = false
  for index = 2, #expr.args do
    local branch = argument_expr(expr.args[index])
    if inline_branch_call(branch, "case") then
      validate_positional_arguments("case", branch.args)
      if saw_default then
        invalid_helper_arity("switch", "case(...) branches before default(...)", #expr.args)
      end
      if #branch.args ~= 2 then
        invalid_helper_arity("case", "exactly 2 positional arguments", #branch.args)
      end
    elseif inline_branch_call(branch, "default") then
      validate_positional_arguments("default", branch.args)
      if saw_default or index ~= #expr.args then
        invalid_helper_arity("switch", "one final default(...) branch", #expr.args)
      end
      if #branch.args ~= 1 then
        invalid_helper_arity("default", "exactly 1 positional argument", #branch.args)
      end
      saw_default = true
    else
      invalid_helper_arity("switch", "only case(...) and default(...) branches", #expr.args)
    end
  end
end

local function evaluate_switch_case_match(engine, expr, ctx, accumulator, edge_state)
  if expr.kind == "variable" then return expr.name end
  return evaluate_expr(engine, expr, ctx, accumulator, edge_state)
end

local function switch_scalar_text(value)
  local kind = json.kind(value)
  if kind == "array" or kind == "harray" or
      (action_ast.node_type(value) == "ActionExpr" and
        (value.kind == "block_value" or value.kind == "codeblock_argument")) then
    return nil
  end
  return scalar_string(value, true)
end

local function switch_values_equal(left, right)
  local left_text = switch_scalar_text(left)
  local right_text = switch_scalar_text(right)
  return left_text ~= nil and right_text ~= nil and left_text == right_text
end

local function evaluate_inline_switch(engine, expr, ctx, accumulator, edge_state)
  validate_inline_switch(expr)
  local subject = evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state)
  local default_expr
  for index = 2, #expr.args do
    local branch = argument_expr(expr.args[index])
    if branch.name == "case" then
      local case_expr = argument_expr(branch.args[1])
      local candidate = evaluate_switch_case_match(engine, case_expr, ctx, accumulator, edge_state)
      if switch_values_equal(candidate, subject) then
        return evaluate_expr(engine, argument_expr(branch.args[2]), ctx, accumulator, edge_state)
      end
    else
      default_expr = argument_expr(branch.args[1])
    end
  end
  if default_expr then
    return evaluate_expr(engine, default_expr, ctx, accumulator, edge_state)
  end
  return json.null
end

local function first_or_null(values)
  if #values == 0 then return json.null end
  return values[1]
end

local function string_predicate(values, predicate)
  if #values < 2 then return 0 end
  local value = scalar_string(values[1], false)
  local needle = scalar_string(values[2], true)
  if value == nil or needle == nil then return 0 end
  return predicate(value, needle) and 1 or 0
end

local function replace_literal(value, old_value, new_value)
  if old_value == "" then return value end
  local result = {}
  local position = 1
  while true do
    local start_at, end_at = value:find(old_value, position, true)
    if not start_at then
      result[#result + 1] = value:sub(position)
      break
    end
    result[#result + 1] = value:sub(position, start_at - 1)
    result[#result + 1] = new_value
    position = end_at + 1
  end
  return table.concat(result)
end

local function evaluate_pure_string_helper(engine, name, values)
  if name == "cat" then
    local parts = {}
    for index, value in ipairs(values) do
      local part = scalar_string(value, false)
      if part == nil then return json.null end
      parts[index] = part
    end
    return table.concat(parts)
  elseif name == "contains_substr" then
    return string_predicate(values, function(value, needle) return value:find(needle, 1, true) ~= nil end)
  elseif name == "ends_with" then
    return string_predicate(values, function(value, suffix)
      return suffix == "" or value:sub(-#suffix) == suffix
    end)
  elseif name == "is_defined" then
    return #values > 0 and values[1] ~= json.null
  elseif name == "is_empty" then
    return is_empty_value(first_or_null(values))
  elseif name == "is_nonempty" then
    return not is_empty_value(first_or_null(values))
  elseif name == "is_undefined" then
    return #values == 0 or values[1] == json.null
  elseif name == "length" then
    return value_length(first_or_null(values))
  elseif name == "lowercase" or name == "uppercase" then
    local value = scalar_string(first_or_null(values), false)
    if value == nil then return json.null end
    return name == "lowercase" and unicode_case.lowercase(value) or unicode_case.uppercase(value)
  elseif name == "lowercase_each" or name == "uppercase_each" then
    local source = first_or_null(values)
    local result = json.array()
    if json.kind(source) ~= "array" then return result end
    for index, item in ipairs(source) do
      local value = scalar_string(item, false)
      result[index] = value == nil and json.null or
        (name == "lowercase_each" and unicode_case.lowercase(value) or unicode_case.uppercase(value))
    end
    return result
  elseif name == "matches" then
    if #values < 2 then return false end
    local value = scalar_string(values[1], false)
    local regex = compile_helper_regex(engine, values[2])
    if value == nil or regex == nil then return false end
    return regex:seek_match(value, 0) ~= nil
  elseif name == "split" then
    if #values < 2 then return json.array() end
    local value = scalar_string(values[1], false)
    if value == nil then return json.array() end
    if getmetatable(values[2]) == HELPER_REGEX_MT then
      local regex = compile_helper_regex(engine, values[2])
      return regex == nil and json.array() or split_regex(value, regex)
    end
    local delimiter = scalar_string(values[2], true)
    return delimiter == nil and json.array() or split_literal(value, delimiter)
  elseif name == "replace_substr" then
    if #values < 3 then return json.null end
    local value = scalar_string(values[1], false)
    local old_value = scalar_string(values[2], true)
    local new_value = scalar_string(values[3], true)
    if value == nil or old_value == nil or new_value == nil then return json.null end
    return replace_literal(value, old_value, new_value)
  elseif name == "rm_prefix" or name == "rm_suffix" then
    if #values < 2 then return json.null end
    local value = scalar_string(values[1], false)
    local edge = scalar_string(values[2], true)
    if value == nil or edge == nil then return json.null end
    if name == "rm_prefix" and value:sub(1, #edge) == edge then return value:sub(#edge + 1) end
    if name == "rm_suffix" and (edge == "" or value:sub(-#edge) == edge) then
      return edge == "" and value or value:sub(1, #value - #edge)
    end
    return value
  elseif name == "starts_with" then
    return string_predicate(values, function(value, prefix) return value:sub(1, #prefix) == prefix end)
  elseif name == "substr" then
    if #values < 2 or values[1] == json.null or values[2] == json.null then return json.null end
    local value = scalar_string(values[1], false)
    if value == nil then return json.null end
    local start = math.max(0, runtime_integer(values[2]) or 0)
    local width
    if #values >= 3 and values[3] ~= json.null then width = math.max(0, runtime_integer(values[3]) or 0) end
    local start_byte = matching.char_offset_to_byte_offset(value, start)
    local end_byte = width and matching.char_offset_to_byte_offset(value, start + width) or #value
    return value:sub(start_byte + 1, end_byte)
  elseif name == "trim" then
    local value = scalar_string(first_or_null(values), false)
    return value == nil and json.null or trim_unicode(value)
  elseif is_string_comparison(name) then
    if #values < 2 then return json.null end
    local left = scalar_string(values[1], false)
    local right = scalar_string(values[2], false)
    if left == nil or right == nil then return json.null end
    if name == "str_eq" then return left == right end
    if name == "str_ne" then return left ~= right end
    if name == "str_gt" then return left > right end
    if name == "str_ge" then return left >= right end
    if name == "str_lt" then return left < right end
    return left <= right
  end
  fail("unsupported pure string helper '" .. tostring(name) .. "'", { helper_name = name })
end

local function coalesce_accepts(value, require_nonempty)
  return value ~= json.null and (not require_nonempty or type(value) ~= "string" or value ~= "")
end

local function evaluate_coalesce(engine, expr, ctx, accumulator, edge_state, receiver)
  local require_nonempty = action_contracts.canonical_action_helper_name(expr.name) == "coalesce_nonempty"
  if receiver ~= nil and coalesce_accepts(receiver, require_nonempty) then return copy_value(receiver) end
  for _, arg in ipairs(expr.args) do
    local value = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
    if coalesce_accepts(value, require_nonempty) then return copy_value(value) end
  end
  return json.null
end

local function evaluate_pure_string_values(engine, expr, ctx, accumulator, edge_state, receiver)
  local values = {}
  if receiver ~= nil then values[1] = receiver end
  for _, arg in ipairs(expr.args) do
    values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
  end
  return evaluate_pure_string_helper(engine, action_contracts.canonical_action_helper_name(expr.name), values)
end

local PURE_ARRAY_HELPERS = {
  concat_arrays = true,
  contains = true,
  count = true,
  drop_back = true,
  drop_front = true,
  filter_match = true,
  filter_nonempty = true,
  first = true,
  flat = true,
  flat_array = true,
  index_of = true,
  join_values = true,
  last = true,
  reversed = true,
  slice = true,
  sorted = true,
  split_each = true,
  split_tagged_records = true,
  take = true,
  take_last = true,
  trim_each = true,
  uniq = true,
}

local ARRAY_SPLICE_HELPERS = {
  flat = true,
  flat_array = true,
  flat_hash = true,
}

local HASH_SPLICE_HELPERS = {
  flat = true,
  flat_array = true,
  flat_hash = true,
}

local function is_array_splice_expr(expr)
  if expr.kind == "call" then
    return ARRAY_SPLICE_HELPERS[action_contracts.canonical_action_helper_name(expr.name)] == true
  end
  if expr.kind == "fluent_chain" and #expr.calls > 0 then
    local last = expr.calls[#expr.calls]
    return ARRAY_SPLICE_HELPERS[action_contracts.canonical_action_helper_name(last.method)] == true
  end
  return false
end

local function is_hash_splice_expr(expr)
  if expr.kind == "call" then
    return HASH_SPLICE_HELPERS[action_contracts.canonical_action_helper_name(expr.name)] == true
  end
  if expr.kind == "fluent_chain" and #expr.calls > 0 then
    local last = expr.calls[#expr.calls]
    return HASH_SPLICE_HELPERS[action_contracts.canonical_action_helper_name(last.method)] == true
  end
  return false
end

local function sorted_harray_keys(value)
  local keys = {}
  for key in pairs(value) do keys[#keys + 1] = key end
  table.sort(keys)
  return keys
end

local function append_array_value(result, value, splice)
  if splice and json.kind(value) == "array" then
    for _, item in ipairs(value) do result[#result + 1] = copy_value(item) end
  elseif splice and json.kind(value) == "harray" then
    for _, key in ipairs(sorted_harray_keys(value)) do
      result[#result + 1] = key
      result[#result + 1] = copy_value(value[key])
    end
  else
    result[#result + 1] = copy_value(value)
  end
end

local PURE_HASH_HELPERS = {
  count_keys = true,
  drop_keys = true,
  flat_hash = true,
  has_key = true,
  merge_hash = true,
  pick_keys = true,
  rename_key = true,
  set_key = true,
  sorted_keys = true,
  sorted_values = true,
}

local ARRAY_END_MUTATIONS = {
  pop_back = true,
  pop_front = true,
  push_back = true,
  push_front = true,
}

local function nonnegative_array_count(value, default)
  local number = value
  if type(number) == "string" and number:match("^-?%d+$") then number = tonumber(number) end
  if type(number) ~= "number" or number ~= number or number % 1 ~= 0 then return default end
  return math.max(0, number)
end

local function scalar_array_key(value)
  return scalar_string(value, true) or ""
end

local function evaluate_array_helper(engine, name, values)
  if name == "flat" then
    local value = values[1]
    if value == nil then return json.array({ json.null }) end
    if json.kind(value) == "harray" then return copy_value(value) end
    if json.kind(value) == "array" then return copy_value(value) end
    return json.array({ copy_value(value) })
  end
  if name == "flat_array" or name == "concat_arrays" then
    local result = json.array()
    for _, value in ipairs(values) do
      append_array_value(result, value, json.kind(value) == "array")
    end
    return result
  end
  local source = values[1]
  local items = json.kind(source) == "array" and copy_value(source) or json.array()
  if name == "count" then return #items end
  if name == "first" then return #items == 0 and json.null or copy_value(items[1]) end
  if name == "last" then return #items == 0 and json.null or copy_value(items[#items]) end
  if name == "take" or name == "take_last" or name == "drop_front" or name == "drop_back" then
    local count = nonnegative_array_count(values[2], 1)
    local first = 1
    local last = #items
    if name == "take" then
      last = math.min(last, count)
    elseif name == "take_last" then
      first = math.max(1, #items - count + 1)
      if count == 0 then first = #items + 1 end
    elseif name == "drop_front" then
      first = math.min(#items + 1, count + 1)
    else
      last = math.max(0, #items - count)
    end
    local result = json.array()
    for index = first, last do result[#result + 1] = copy_value(items[index]) end
    return result
  end
  if name == "slice" then
    local start = nonnegative_array_count(values[2], 0)
    local width = nonnegative_array_count(values[3], #items)
    local result = json.array()
    if start >= #items then return result end
    local last = math.min(#items, start + width)
    for index = start + 1, last do result[#result + 1] = copy_value(items[index]) end
    return result
  end
  if name == "sorted" then
    table.sort(items, function(left, right)
      return (scalar_string(left, true) or "") < (scalar_string(right, true) or "")
    end)
    return items
  end
  if name == "reversed" then
    local result = json.array()
    for index = #items, 1, -1 do result[#result + 1] = copy_value(items[index]) end
    return result
  end
  if name == "contains" or name == "index_of" then
    if values[2] == nil then return name == "contains" and 0 or json.null end
    local needle = scalar_array_key(values[2])
    for index, item in ipairs(items) do
      if scalar_array_key(item) == needle then return name == "contains" and 1 or index - 1 end
    end
    return name == "contains" and 0 or json.null
  end
  if name == "uniq" then
    local result = json.array()
    local seen = {}
    for _, item in ipairs(items) do
      local key = scalar_array_key(item)
      if not seen[key] then
        seen[key] = true
        result[#result + 1] = copy_value(item)
      end
    end
    return result
  end
  if name == "join_values" then
    local delimiter = scalar_string(values[1] == nil and "" or values[1], true) or ""
    local source = values[2]
    if source == nil or source == json.null then return json.null end
    if json.kind(source) ~= "array" then return "" end
    local parts = {}
    for index, item in ipairs(source) do parts[index] = scalar_string(item, true) or "" end
    return table.concat(parts, delimiter)
  end
  if name == "split_each" then
    local delimiter = values[2] == nil and "" or values[2]
    local result = json.array()
    for _, item in ipairs(items) do
      local parts = evaluate_pure_string_helper(engine, "split", { item, delimiter })
      for _, part in ipairs(parts) do result[#result + 1] = copy_value(part) end
    end
    return result
  end
  if name == "filter_match" then
    local regex = values[2] == nil and nil or compile_helper_regex(engine, values[2])
    local result = json.array()
    if regex == nil then return result end
    for _, item in ipairs(items) do
      local value = scalar_string(item, false)
      if value ~= nil and regex:seek_match(value, 0) ~= nil then
        result[#result + 1] = copy_value(item)
      end
    end
    return result
  end
  if name == "split_tagged_records" then
    local result = json.array()
    if #values < 3 then return result end
    local parts = evaluate_pure_string_helper(engine, "split", { values[1], values[2] })
    local tag = scalar_string(values[3], true) or ""
    for _, item in ipairs(parts) do
      local record = json.array({ tag, copy_value(item) })
      for index = 4, #values do record[#record + 1] = copy_value(values[index]) end
      result[#result + 1] = record
    end
    return result
  end
  local result = json.array()
  if name == "filter_nonempty" then
    for _, item in ipairs(items) do
      if not is_empty_value(item) then result[#result + 1] = copy_value(item) end
    end
    return result
  end
  if name == "trim_each" then
    for index, item in ipairs(items) do
      local value = scalar_string(item, false)
      result[index] = value == nil and json.null or trim_unicode(value)
    end
    return result
  end
  fail("unsupported array helper '" .. tostring(name) .. "'", { helper_name = name })
end

local function evaluate_array_values(engine, expr, ctx, accumulator, edge_state, receiver)
  local values = {}
  local name = action_contracts.canonical_action_helper_name(expr.name)
  if receiver ~= nil and name == "join_values" then
    values[1] = expr.args[1] and
      evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state) or ""
    values[2] = receiver
  else
    if receiver ~= nil then values[1] = receiver end
    for _, arg in ipairs(expr.args) do
      values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
    end
  end
  return evaluate_array_helper(engine, name, values)
end

local function evaluate_hash_helper(name, values)
  local source = values[1]
  local keys = json.kind(source) == "harray" and sorted_harray_keys(source) or {}
  if name == "count_keys" then return #keys end
  if name == "sorted_keys" then return json.array(keys) end
  if name == "sorted_values" then
    local result = json.array()
    for _, key in ipairs(keys) do result[#result + 1] = copy_value(source[key]) end
    return result
  end
  if name == "has_key" then
    if json.kind(source) ~= "harray" or values[2] == nil then return 0 end
    local key = scalar_string(values[2], true) or ""
    return source[key] ~= nil and 1 or 0
  end
  if name == "flat_hash" then
    local result = json.harray()
    for _, value in ipairs(values) do
      if json.kind(value) == "harray" then
        for _, key in ipairs(sorted_harray_keys(value)) do result[key] = copy_value(value[key]) end
      end
    end
    return result
  end
  if name == "merge_hash" then
    local result = json.harray()
    for _, value in ipairs(values) do
      if json.kind(value) == "harray" then
        for _, key in ipairs(sorted_harray_keys(value)) do result[key] = copy_value(value[key]) end
      end
    end
    return result
  end
  if name == "set_key" then
    if #values < 3 then return json.null end
    if json.kind(source) ~= "harray" then return copy_value(source) end
    local result = copy_value(source)
    local key = scalar_string(values[2], true) or ""
    result[key] = copy_value(values[3])
    return result
  end
  if name == "rename_key" then
    if #values < 3 then return json.null end
    if json.kind(source) ~= "harray" then return copy_value(source) end
    local result = copy_value(source)
    local old_key = scalar_string(values[2], true) or ""
    local new_key = scalar_string(values[3], true) or ""
    if old_key ~= new_key and result[old_key] ~= nil then
      local renamed = result[old_key]
      result[old_key] = nil
      result[new_key] = renamed
    end
    return result
  end
  if name == "drop_keys" then
    if source == nil then return json.null end
    if json.kind(source) ~= "harray" then return copy_value(source) end
    local result = copy_value(source)
    for index = 2, #values do
      local key = scalar_string(values[index], true) or ""
      result[key] = nil
    end
    return result
  end
  if name == "pick_keys" then
    if json.kind(source) ~= "harray" then return json.null end
    local selected = {}
    for index = 2, #values do selected[scalar_string(values[index], true) or ""] = true end
    local result = json.harray()
    for _, key in ipairs(sorted_harray_keys(source)) do
      if selected[key] then result[key] = copy_value(source[key]) end
    end
    return result
  end
  fail("unsupported harray helper '" .. tostring(name) .. "'", { helper_name = name })
end

local function evaluate_hash_values(engine, expr, ctx, accumulator, edge_state, receiver)
  local values = {}
  if receiver ~= nil then values[1] = receiver end
  for _, arg in ipairs(expr.args) do
    values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
  end
  return evaluate_hash_helper(action_contracts.canonical_action_helper_name(expr.name), values)
end

local function tree_child_path(path, part)
  local result = json.array()
  for index, existing in ipairs(path) do result[index] = existing end
  result[#result + 1] = part
  return result
end

local function tree_children(node, tree_kind)
  if tree_kind == "harray" then
    local keys = sorted_harray_keys(node)
    local offset = 0
    return function()
      offset = offset + 1
      local key = keys[offset]
      if key == nil then return nil end
      return key, node[key]
    end
  end

  local offset = 0
  return function()
    offset = offset + 1
    if offset > #node then return nil end
    return offset - 1, node[offset]
  end
end

local function new_tree_container(tree_kind)
  if tree_kind == "harray" then return json.harray() end
  return json.array()
end

local function set_tree_child(container, tree_kind, selector, value)
  if tree_kind == "harray" then
    container[selector] = value
  else
    container[selector + 1] = value
  end
end

local function evaluate_tree_leaf_block(
  engine,
  block_expr,
  value,
  selector_name,
  selector,
  path,
  acc,
  bind_acc,
  ctx,
  accumulator,
  edge_state
)
  local bindings = {}
  if bind_acc then bindings[#bindings + 1] = { name = "acc", value = acc } end
  bindings[#bindings + 1] = { name = "value", value = value }
  bindings[#bindings + 1] = { name = selector_name, value = selector }
  bindings[#bindings + 1] = { name = "path", value = path }
  bindings[#bindings + 1] = { name = "depth", value = #path }
  return runtime_scoped_binding.run_frame(ctx, bindings, copy_value, function()
    return evaluate_block_value(engine, block_expr.block, ctx, accumulator, edge_state)
  end)
end

local function evaluate_tree_receiver_block(
  engine,
  name,
  call_expr,
  block_expr,
  receiver,
  ctx,
  accumulator,
  edge_state
)
  local tree_kind = json.kind(receiver)
  if tree_kind ~= "harray" and tree_kind ~= "array" then return json.null end
  local selector_name = tree_kind == "harray" and "key" or "index"

  if name == "walk_leaves" then
    local walk
    walk = function(node, path)
      for selector, value in tree_children(node, tree_kind) do
        local next_path = tree_child_path(path, selector)
        if json.kind(value) == tree_kind then
          walk(value, next_path)
        else
          evaluate_tree_leaf_block(
            engine,
            block_expr,
            value,
            selector_name,
            selector,
            next_path,
            nil,
            false,
            ctx,
            accumulator,
            edge_state
          )
        end
      end
    end
    walk(receiver, json.array())
    return copy_value(receiver)
  end

  if name == "map_leaves" then
    local map
    map = function(node, path)
      local result = new_tree_container(tree_kind)
      for selector, value in tree_children(node, tree_kind) do
        local next_path = tree_child_path(path, selector)
        local mapped
        if json.kind(value) == tree_kind then
          mapped = map(value, next_path)
        else
          mapped = evaluate_tree_leaf_block(
            engine,
            block_expr,
            value,
            selector_name,
            selector,
            next_path,
            nil,
            false,
            ctx,
            accumulator,
            edge_state
          )
        end
        set_tree_child(result, tree_kind, selector, mapped)
      end
      return result
    end
    return map(receiver, json.array())
  end

  if name == "reduce_leaves" then
    local reduced = copy_value(evaluate_expr(
      engine,
      argument_expr(call_expr.args[1]),
      ctx,
      accumulator,
      edge_state
    ))
    local reduce
    reduce = function(node, path)
      for selector, value in tree_children(node, tree_kind) do
        local next_path = tree_child_path(path, selector)
        if json.kind(value) == tree_kind then
          reduce(value, next_path)
        else
          reduced = evaluate_tree_leaf_block(
            engine,
            block_expr,
            value,
            selector_name,
            selector,
            next_path,
            reduced,
            true,
            ctx,
            accumulator,
            edge_state
          )
        end
      end
    end
    reduce(receiver, json.array())
    return copy_value(reduced)
  end

  fail("unsupported tree traversal helper '" .. tostring(name) .. "'", { helper_name = name })
end

local function evaluate_scalar_numeric_values(engine, expr, ctx, accumulator, edge_state, name, receiver)
  local values = {}
  if receiver ~= nil then values[1] = receiver end
  for _, arg in ipairs(expr.args) do
    values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
  end
  return scalar_numeric.evaluate(name, values)
end

local function evaluate_numeric_reducer_values(engine, expr, ctx, accumulator, edge_state, name, receiver)
  local values = {}
  if receiver ~= nil then values[1] = receiver end
  for _, arg in ipairs(expr.args) do
    values[#values + 1] = evaluate_expr(engine, argument_expr(arg), ctx, accumulator, edge_state)
  end
  return scalar_numeric.evaluate_reducer(name, values)
end

local function evaluate_mutable_split(engine, expr, ctx, accumulator, edge_state, target)
  array_binding_for_mutation(ctx, target.name)
  local source = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
  local delimiter = expr.args[3] and
    evaluate_expr(engine, argument_expr(expr.args[3]), ctx, accumulator, edge_state) or ""
  local result = evaluate_pure_string_helper(engine, "split", { source, delimiter })
  local _, storage = lookup_binding(ctx, target.name)
  return store_array_mutation(ctx, target, storage, result)
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

local INPUT_CURSOR_HELPERS = {
  cursor_col = true,
  cursor_line = true,
  cursor_pos = true,
  cursor_rest = true,
  cursor_rest_len = true,
  input_end_col = true,
  input_end_line = true,
  input_end_pos = true,
  input_len = true,
  input_slice = true,
  input_text = true,
}

local CURSOR_CONTROL_HELPERS = {
  restore_cursor = true,
  rewind_entry_start = true,
  rewind_match_start = true,
  save_cursor = true,
}

local ANONYMOUS_CAPTURE_HELPERS = {
  capture_rest = true,
  capture_rest_len = true,
  capture_slice = true,
  capture_slice_col = true,
  capture_slice_len = true,
  capture_slice_line = true,
  capture_slice_pos = true,
  capture_slice_until_cursor = true,
  capture_slice_until_cursor_len = true,
  capture_take = true,
  capture_take_len = true,
  capture_take_rest = true,
  capture_take_rest_len = true,
  capture_take_until_cursor = true,
  capture_take_until_cursor_len = true,
  start_capture_slice = true,
}

local NAMED_MARK_HELPERS = {
  capture_between = true,
  capture_from = true,
  capture_len_between = true,
  capture_len_from = true,
  capture_rest_from = true,
  capture_rest_len_from = true,
  capture_take_between = true,
  capture_take_between_len = true,
  capture_take_len_from = true,
  capture_take_rest_from = true,
  capture_take_rest_len_from = true,
  capture_take_until_cursor_from = true,
  capture_take_until_cursor_len_from = true,
  capture_until_cursor_from = true,
  capture_until_cursor_len_from = true,
  clear_mark = true,
  mark_capture_slice = true,
  mark_col = true,
  mark_copy = true,
  mark_entry_end = true,
  mark_entry_start = true,
  mark_exists = true,
  mark_here = true,
  mark_input_end = true,
  mark_input_start = true,
  mark_line = true,
  mark_match_end = true,
  mark_match_start = true,
  mark_pos = true,
  start_capture_slice_from = true,
}

local function set_live_cursor(ctx, byte_cursor)
  ctx.registers = ctx.registers:with_cursor_byte(byte_cursor)
  ctx.cursor_byte = ctx.registers.cursor_byte
end

local function set_capture_start(ctx, byte_cursor)
  ctx.registers = ctx.registers:with_capture_start_byte(byte_cursor)
end

local function trace_mark_capture_helper(ctx, rule_label, helper_name, arity)
  local one = ctx.registers.local_match
  runtime_trace_event(
    ctx,
    trace.TRACE_MARK,
    "lua_runtime:mark_capture",
    "source=helper rule=" .. rule_label .. " helper=" .. helper_name ..
      " arity=" .. tostring(arity) .. " cursor=" .. tostring(ctx.cursor_byte) ..
      " match_start=" .. tostring(one and one.byte_start or -1) ..
      " match_end=" .. tostring(one and one.byte_end or -1) ..
      " capture_start=" .. tostring(ctx.registers.capture_start_byte or -1),
    trace.TRACE_DEBUG
  )
end

local function anonymous_capture_span(ctx, start_byte, end_byte, length_only)
  if start_byte == nil or end_byte == nil or start_byte < 0 or start_byte > #ctx.input or
      end_byte < start_byte or end_byte > #ctx.input then
    return json.null
  end
  if length_only then
    return matching.byte_offset_to_char_offset(ctx.input, end_byte) -
      matching.byte_offset_to_char_offset(ctx.input, start_byte)
  end
  return ctx.input:sub(start_byte + 1, end_byte)
end

local function evaluate_anonymous_capture_helper(name, expr, ctx)
  if #expr.args ~= 0 then invalid_helper_arity(name, "exactly 0 positional arguments", #expr.args) end
  trace_mark_capture_helper(ctx, ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule, name, #expr.args)
  if name == "start_capture_slice" then
    set_capture_start(ctx, ctx.cursor_byte)
    return json.null
  end

  local start_byte = ctx.registers.capture_start_byte
  if start_byte == nil then return json.null end
  if name == "capture_slice_pos" then
    return matching.byte_offset_to_char_offset(ctx.input, start_byte)
  end
  if name == "capture_slice_line" or name == "capture_slice_col" then
    local position = matching.line_column_at_byte_offset(ctx.input, start_byte)
    return name == "capture_slice_line" and position.line or position.column
  end

  local end_byte
  if name == "capture_rest" or name == "capture_rest_len" or
      name == "capture_take_rest" or name == "capture_take_rest_len" then
    end_byte = #ctx.input
  elseif name == "capture_slice_until_cursor" or name == "capture_slice_until_cursor_len" or
      name == "capture_take_until_cursor" or name == "capture_take_until_cursor_len" then
    end_byte = ctx.cursor_byte
  elseif ctx.registers.local_match ~= nil then
    end_byte = ctx.registers.local_match.byte_start
  end

  local result = anonymous_capture_span(ctx, start_byte, end_byte, name:sub(-4) == "_len")
  if result == json.null then return result end
  if name == "capture_take" or name == "capture_take_len" or
      name == "capture_take_until_cursor" or name == "capture_take_until_cursor_len" then
    set_capture_start(ctx, ctx.cursor_byte)
  elseif name == "capture_take_rest" or name == "capture_take_rest_len" then
    set_capture_start(ctx, #ctx.input)
  end
  return result
end

local function evaluate_named_mark_helper(engine, name, expr, ctx, accumulator, edge_state)
  validate_positional_arguments(name, expr.args)
  local two_mark_helper = name == "mark_copy" or name == "capture_between" or
    name == "capture_len_between" or name == "capture_take_between" or
    name == "capture_take_between_len"
  local expected_arity = two_mark_helper and 2 or 1
  if #expr.args ~= expected_arity then
    local expectation = expected_arity == 1 and
      "exactly 1 positional argument" or "exactly 2 positional arguments"
    invalid_helper_arity(name, expectation, #expr.args)
  end

  local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
  trace_mark_capture_helper(ctx, rule_label, name, #expr.args)

  local function mark_name(index)
    return capture_name(
      engine,
      argument_expr(expr.args[index]),
      ctx,
      accumulator,
      edge_state
    )
  end

  local marks = ctx.mark_buckets[rule_label]
  local first_mark_name = mark_name(1)

  if name == "clear_mark" then
    if marks ~= nil then marks[first_mark_name] = nil end
    return json.null
  end

  if marks == nil then
    marks = {}
    ctx.mark_buckets[rule_label] = marks
  end
  if name == "start_capture_slice_from" then
    local byte_offset = marks[first_mark_name]
    if byte_offset ~= nil then set_capture_start(ctx, byte_offset) end
    return json.null
  elseif name == "mark_here" then
    marks[first_mark_name] = ctx.cursor_byte
    return json.null
  elseif name == "mark_input_start" then
    marks[first_mark_name] = 0
    return json.null
  elseif name == "mark_input_end" then
    marks[first_mark_name] = #ctx.input
    return json.null
  elseif name == "mark_entry_start" or name == "mark_entry_end" then
    local one = ctx.registers.entry_match
    if one ~= nil then
      marks[first_mark_name] = name == "mark_entry_start" and one.byte_start or one.byte_end
    end
    return json.null
  elseif name == "mark_match_start" or name == "mark_match_end" then
    local one = ctx.registers.local_match
    if one ~= nil then
      marks[first_mark_name] = name == "mark_match_start" and one.byte_start or one.byte_end
    end
    return json.null
  elseif name == "mark_copy" then
    local source_name = mark_name(2)
    if marks[source_name] == nil then
      marks[first_mark_name] = nil
    else
      marks[first_mark_name] = marks[source_name]
    end
    return json.null
  elseif name == "mark_capture_slice" then
    local capture_start = ctx.registers.capture_start_byte
    if capture_start == nil then
      marks[first_mark_name] = nil
    else
      marks[first_mark_name] = capture_start
    end
    return json.null
  elseif name == "mark_exists" then
    return marks[first_mark_name] ~= nil and 1 or 0
  end

  local byte_offset = marks[first_mark_name]
  if name == "mark_pos" then
    if byte_offset == nil then return json.null end
    return matching.byte_offset_to_char_offset(ctx.input, byte_offset)
  elseif name == "mark_line" or name == "mark_col" then
    if byte_offset == nil then return json.null end
    local position = matching.line_column_at_byte_offset(ctx.input, byte_offset)
    return name == "mark_line" and position.line or position.column
  end

  if two_mark_helper then
    local end_byte = marks[mark_name(2)]
    local length_only = name == "capture_len_between" or name == "capture_take_between_len"
    local result = anonymous_capture_span(ctx, byte_offset, end_byte, length_only)
    if result ~= json.null and (name == "capture_take_between" or name == "capture_take_between_len") then
      marks[first_mark_name] = end_byte
    end
    return result
  end

  local end_byte
  if name == "capture_from" or name == "capture_len_from" or name == "capture_take" or
      name == "capture_take_len_from" then
    local one = ctx.registers.local_match
    end_byte = one and one.byte_start or nil
  elseif name == "capture_until_cursor_from" or name == "capture_until_cursor_len_from" or
      name == "capture_take_until_cursor_from" or name == "capture_take_until_cursor_len_from" then
    end_byte = ctx.cursor_byte
  else
    end_byte = #ctx.input
  end

  local length_only = name == "capture_len_from" or name == "capture_until_cursor_len_from" or
    name == "capture_rest_len_from" or name == "capture_take_len_from" or
    name == "capture_take_until_cursor_len_from" or name == "capture_take_rest_len_from"
  local result = anonymous_capture_span(ctx, byte_offset, end_byte, length_only)
  if result ~= json.null and name:sub(1, 12) == "capture_take" then
    if name == "capture_take_rest_from" or name == "capture_take_rest_len_from" then
      marks[first_mark_name] = #ctx.input
    else
      marks[first_mark_name] = ctx.cursor_byte
    end
  end
  return result
end

local function boundary_rule_name(engine, arg, ctx, accumulator, edge_state)
  local boundary_expr = argument_expr(arg)
  local symbolic_name = target_name(boundary_expr)
  if symbolic_name ~= nil then return symbolic_name end
  local value = evaluate_expr(engine, boundary_expr, ctx, accumulator, edge_state)
  return scalar_string(value, true) or ""
end

local function evaluate_capture_until_boundary(engine, expr, ctx, accumulator, edge_state)
  local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
  if #expr.args == 0 then
    runtime_trace_decision(
      ctx,
      "lua_runtime:source_boundary",
      false,
      "helper=capture_until_boundary rule=" .. rule_label ..
        " reason=arguments_empty cursor=" .. tostring(ctx.cursor_byte),
      trace.TRACE_DEBUG
    )
    return json.null
  end
  local saw_usable_boundary = false
  local boundary_start
  for _, arg in ipairs(expr.args) do
    local label = boundary_rule_name(engine, arg, ctx, accumulator, edge_state)
    local rule = engine.compiled_spec.rules_by_label[label]
    if rule ~= nil and #rule.regex_patterns > 0 then
      saw_usable_boundary = true
      local alternation = engine.boundary_regex_cache[label]
      if alternation == nil then
        alternation = matching.compile_runtime_regex_alternation(rule)
        engine.boundary_regex_cache[label] = alternation
      end
      local candidate = alternation:seek_match(ctx.input, ctx.cursor_byte)
      if candidate ~= nil and (boundary_start == nil or candidate.byte_start < boundary_start) then
        boundary_start = candidate.byte_start
      end
    end
  end
  if not saw_usable_boundary then
    runtime_trace_decision(
      ctx,
      "lua_runtime:source_boundary",
      false,
      "helper=capture_until_boundary rule=" .. rule_label ..
        " reason=no_usable_boundary cursor=" .. tostring(ctx.cursor_byte),
      trace.TRACE_DEBUG
    )
    return json.null
  end

  local capture_start = ctx.cursor_byte
  local capture_end = boundary_start or #ctx.input
  if capture_end < capture_start or capture_end > #ctx.input then
    runtime_trace_decision(
      ctx,
      "lua_runtime:source_boundary",
      false,
      "helper=capture_until_boundary rule=" .. rule_label ..
        " capture_start=" .. tostring(capture_start) .. " boundary=" .. tostring(capture_end),
      trace.TRACE_DEBUG
    )
    return json.null
  end
  local captured = ctx.input:sub(capture_start + 1, capture_end)
  set_live_cursor(ctx, capture_end)
  runtime_trace_event(
    ctx,
    trace.TRACE_MARK,
    "lua_runtime:source_boundary",
    "helper=capture_until_boundary rule=" .. rule_label ..
      " capture_start=" .. tostring(capture_start) .. " boundary=" .. tostring(capture_end) ..
      " length=" .. tostring(capture_end - capture_start) ..
      " found=" .. (boundary_start == nil and "0" or "1"),
    trace.TRACE_DEBUG
  )
  return captured
end

local function evaluate_input_cursor_helper(engine, name, expr, ctx, accumulator, edge_state)
  if name == "input_slice" then
    if #expr.args ~= 2 then invalid_helper_arity(name, "exactly 2 positional arguments", #expr.args) end
    local start_value = evaluate_expr(
      engine,
      argument_expr(expr.args[1]),
      ctx,
      accumulator,
      edge_state
    )
    local width_value = evaluate_expr(
      engine,
      argument_expr(expr.args[2]),
      ctx,
      accumulator,
      edge_state
    )
    local start = runtime_integer(start_value)
    local width = runtime_integer(width_value)
    if start == nil or width == nil then return json.null end
    start = math.max(0, start)
    width = math.max(0, width)
    local start_byte = matching.char_offset_to_byte_offset(ctx.input, start)
    local end_byte = matching.char_offset_to_byte_offset(ctx.input, start + width)
    return ctx.input:sub(start_byte + 1, end_byte)
  end

  if #expr.args ~= 0 then invalid_helper_arity(name, "exactly 0 positional arguments", #expr.args) end
  if name == "input_text" then return ctx.input end
  if name == "input_len" or name == "input_end_pos" then
    return matching.byte_offset_to_char_offset(ctx.input, #ctx.input)
  end
  if name == "input_end_line" or name == "input_end_col" then
    local position = matching.line_column_at_byte_offset(ctx.input, #ctx.input)
    return name == "input_end_line" and position.line or position.column
  end
  if name == "cursor_pos" then return matching.byte_offset_to_char_offset(ctx.input, ctx.cursor_byte) end
  if name == "cursor_line" or name == "cursor_col" then
    local position = matching.line_column_at_byte_offset(ctx.input, ctx.cursor_byte)
    return name == "cursor_line" and position.line or position.column
  end
  if name == "cursor_rest" then return ctx.input:sub(ctx.cursor_byte + 1) end
  if name == "cursor_rest_len" then
    return matching.byte_offset_to_char_offset(ctx.input, #ctx.input) -
      matching.byte_offset_to_char_offset(ctx.input, ctx.cursor_byte)
  end
  fail("unsupported input/cursor helper '" .. tostring(name) .. "'", { helper_name = name })
end

local function evaluate_cursor_control(name, expr, ctx)
  if #expr.args ~= 0 then invalid_helper_arity(name, "exactly 0 positional arguments", #expr.args) end
  local cursor_before = ctx.cursor_byte
  local stack_before = #ctx.cursor_stack
  if name == "save_cursor" then
    ctx.cursor_stack[#ctx.cursor_stack + 1] = ctx.cursor_byte
  elseif name == "restore_cursor" then
    local saved = ctx.cursor_stack[#ctx.cursor_stack]
    if saved ~= nil then
      ctx.cursor_stack[#ctx.cursor_stack] = nil
      set_live_cursor(ctx, saved)
    end
  elseif name == "rewind_match_start" then
    if ctx.registers.local_match then set_live_cursor(ctx, ctx.registers.local_match.byte_start) end
  elseif name == "rewind_entry_start" then
    if ctx.registers.entry_match then set_live_cursor(ctx, ctx.registers.entry_match.byte_start) end
  end
  runtime_trace_event(
    ctx,
    trace.TRACE_MARK,
    "lua_runtime:cursor_control",
    "helper=" .. name .. " rule=" .. (ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule) ..
      " before=" .. tostring(cursor_before) .. " after=" .. tostring(ctx.cursor_byte) ..
      " stack_before=" .. tostring(stack_before) .. " stack_after=" .. tostring(#ctx.cursor_stack),
    trace.TRACE_DEBUG
  )
  return json.null
end

local function evaluate_call(engine, expr, ctx, accumulator, edge_state)
  if engine.compiled_spec.function_registry:has_name(expr.name) then
    return execute_user_function(engine, expr, ctx, accumulator, edge_state)
  end
  if expr.name == "if" then
    return evaluate_inline_if(engine, expr, ctx, accumulator, edge_state)
  elseif expr.name == "switch" then
    return evaluate_inline_switch(engine, expr, ctx, accumulator, edge_state)
  elseif expr.name == "i" or expr.name == "elif" or expr.name == "when" or expr.name == "otherwise" then
    fail("unsupported runtime helper '" .. expr.name .. "'", { helper_name = expr.name })
  end
  local name = action_contracts.canonical_action_helper_name(expr.name)
  if name == "with" then
    local block_expr, before_count = final_codeblock_argument(name, "helper", expr.args)
    local scoped_value = json.null
    if before_count == 1 then
      scoped_value = evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state)
    end
    return evaluate_with_block(engine, block_expr, scoped_value, ctx, accumulator, edge_state)
  end
  local split_target = name == "split" and expr.args[1] and
    binding_target_descriptor(argument_expr(expr.args[1])) or nil
  if split_target and #expr.args == 3 then
    return evaluate_mutable_split(engine, expr, ctx, accumulator, edge_state, split_target)
  elseif name == "coalesce" or name == "coalesce_nonempty" then
    return evaluate_coalesce(engine, expr, ctx, accumulator, edge_state, nil)
  elseif is_pure_string_helper(name) then
    return evaluate_pure_string_values(engine, expr, ctx, accumulator, edge_state, nil)
  elseif PURE_ARRAY_HELPERS[name] then
    return evaluate_array_values(engine, expr, ctx, accumulator, edge_state, nil)
  elseif PURE_HASH_HELPERS[name] then
    return evaluate_hash_values(engine, expr, ctx, accumulator, edge_state, nil)
  elseif scalar_numeric.supports_reducer(name) and
      (not scalar_numeric.supports(name) or #expr.args == 1) then
    return evaluate_numeric_reducer_values(engine, expr, ctx, accumulator, edge_state, name, nil)
  elseif scalar_numeric.supports(name) then
    return evaluate_scalar_numeric_values(engine, expr, ctx, accumulator, edge_state, name, nil)
  elseif NAMED_MARK_HELPERS[name] or (name == "capture_take" and #expr.args > 0) then
    return evaluate_named_mark_helper(engine, name, expr, ctx, accumulator, edge_state)
  elseif DIAGNOSTIC_OUTPUT_HELPERS[name] then
    return evaluate_runtime_diagnostic_output(engine, name, expr, ctx, accumulator, edge_state)
  elseif LOGICAL_HELPERS[name] then
    return evaluate_runtime_logical(engine, name, expr, ctx, accumulator, edge_state)
  end
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
    error(setmetatable({
      message = "exit_now(" .. tostring(status) .. ") in rule " .. tostring(rule_label),
      rule_label = rule_label,
      status = status,
    }, ERROR_MT.exit_now), 0)
  elseif name == "call" then
    if not expr.args[1] then fail("call expects a rule name") end
    local label = target_name(argument_expr(expr.args[1]))
    if not label then fail("call rule name must be a variable or string") end
    local child
    if edge_state and label == edge_state.target.label then
      child = dispatch_edge_child(engine, edge_state, ctx)
    else
      child = execute_rule(engine, label, 0, ctx)
    end
    ctx.retv = copy_value(child.value)
    return child.value
  elseif name == "push" then
    local first_target = expr.args[1] and binding_target_descriptor(argument_expr(expr.args[1])) or nil
    local first_name = first_target and first_target.name or nil
    local child_rule = first_name and engine.compiled_spec.rules_by_label[first_name] or nil
    if child_rule and #expr.args >= 1 and #expr.args <= 3 then
      local output_target
      local child_index
      if #expr.args == 1 then
        output_target = { kind = "scalar", name = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule }
      elseif #expr.args == 2 then
        child_index = literal_nonnegative_index(argument_expr(expr.args[2]))
        if child_index ~= nil then
          output_target = { kind = "scalar", name = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule }
        else
          output_target = binding_target_descriptor(argument_expr(expr.args[2]))
        end
      else
        output_target = binding_target_descriptor(argument_expr(expr.args[2]))
        child_index = literal_nonnegative_index(argument_expr(expr.args[3]))
        if child_index == nil then output_target = nil end
      end
      if output_target then
        local child = edge_state and first_name == edge_state.target.label and
          dispatch_edge_child(engine, edge_state, ctx) or execute_rule(engine, first_name, 0, ctx)
        ctx.retv = copy_value(child.value)
        local value = child_index == nil and child.value or read_index(child.value, child_index)
        return append_array_binding(ctx, output_target, value)
      end
    end
    if child_rule then fail("push child form has invalid target or index", { helper_name = "push" }) end
    if #expr.args >= 2 and first_target then
      local value = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
      return append_array_binding(ctx, first_target, value)
    end
    if #expr.args == 0 and edge_state then
      local child = dispatch_edge_child(engine, edge_state, ctx)
      local output_target = { kind = "scalar", name = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule }
      return append_array_binding(ctx, output_target, child.value)
    end
    if #expr.args == 1 and edge_state then
      local output_target = binding_target_descriptor(argument_expr(expr.args[1]))
      if not output_target then fail("push output target must be a bare binding") end
      local child = dispatch_edge_child(engine, edge_state, ctx)
      return append_array_binding(ctx, output_target, child.value)
    end
    local value
    if #expr.args == 1 then
      local candidate = argument_expr(expr.args[1])
      value = evaluate_expr(engine, candidate, ctx, accumulator, edge_state)
    else
      value = ctx.retv
    end
    local output_target = { kind = "scalar", name = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule }
    return append_array_binding(ctx, output_target, value)
  elseif name == "set" or name == "=" then
    local target = expr.args[1] and target_descriptor(argument_expr(expr.args[1]))
    if not target or not expr.args[2] then fail("set expects target and value") end
    local value = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
    return bind_scalar(ctx, target.name, value)
  elseif name == "array" then
    if not expr.args[1] then return json.array() end
    local result = json.array()
    for _, arg in ipairs(expr.args) do
      local item_expr = argument_expr(arg)
      local value = evaluate_expr(engine, item_expr, ctx, accumulator, edge_state)
      append_array_value(result, value, is_array_splice_expr(item_expr))
    end
    return result
  elseif name == "hash" or name == "harray" then
    if not expr.args[1] then return json.harray() end
    local tokens = json.array()
    for _, arg in ipairs(expr.args) do
      local item_expr = argument_expr(arg)
      local value = evaluate_expr(engine, item_expr, ctx, accumulator, edge_state)
      append_array_value(tokens, value, is_hash_splice_expr(item_expr))
    end
    local result = json.harray()
    local index = 1
    while index + 1 <= #tokens do
      local key = tokens[index]
      result[tostring(key == json.null and "" or key)] = copy_value(tokens[index + 1])
      index = index + 2
    end
    if #tokens % 2 == 1 then
      local key = tokens[#tokens]
      result[tostring(key == json.null and "" or key)] = json.null
    end
    return result
  elseif name == "copy" then
    if not expr.args[1] then return json.null end
    return copy_value(evaluate_expr(engine, argument_expr(expr.args[1]), ctx, accumulator, edge_state))
  elseif INPUT_CURSOR_HELPERS[name] then
    return evaluate_input_cursor_helper(engine, name, expr, ctx, accumulator, edge_state)
  elseif CURSOR_CONTROL_HELPERS[name] then
    return evaluate_cursor_control(name, expr, ctx)
  elseif name == "capture_until_boundary" then
    return evaluate_capture_until_boundary(engine, expr, ctx, accumulator, edge_state)
  elseif ANONYMOUS_CAPTURE_HELPERS[name] then
    return evaluate_anonymous_capture_helper(name, expr, ctx)
  elseif name:match("^entry_") or name:match("^match_") then
    local value = evaluate_match_helper(engine, name, expr, ctx, accumulator, edge_state)
    if value ~= nil then return value end
  end
  if ctx.user_function_parameter_kinds ~= nil and
      ctx.user_function_parameter_kinds[expr.name] == "codeblock" then
    return execute_contextual_codeblock(engine, expr, ctx)
  end
  fail("unsupported runtime helper '" .. tostring(name) .. "'", { helper_name = name })
end

evaluate_expr = function(engine, expr, ctx, accumulator, edge_state)
  local kind = expr.kind
  if kind == "string" or kind == "number" or kind == "boolean" then return expr.value end
  if kind == "undef" then return json.null end
  if kind == "regex" then return helper_regex(expr.pattern, expr.flags) end
  if kind == "variable" then
    if expr.name == "retv" then
      if edge_state then return copy_value(dispatch_edge_child(engine, edge_state, ctx).value) end
      return copy_value(ctx.retv)
    end
    local value = lookup_binding(ctx, expr.name)
    return copy_value(value)
  end
  if kind == "block_value" then
    return evaluate_block_value(engine, expr.block, ctx, accumulator, edge_state)
  end
  if kind == "codeblock_argument" then return copy_value(expr) end
  if kind == "array_literal" then
    local result = json.array()
    for _, item in ipairs(expr.items) do
      local value = evaluate_expr(engine, item, ctx, accumulator, edge_state)
      append_array_value(result, value, is_array_splice_expr(item))
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
    return append_array_binding(ctx, { kind = "scalar", name = expr.name }, value)
  end
  if kind == "indexed_var" then
    local root = lookup_binding(ctx, expr.name)
    local key = evaluate_expr(engine, expr.index, ctx, accumulator, edge_state)
    return read_index(root, key)
  end
  if kind == "nested_access" then
    local value = lookup_binding(ctx, expr.base)
    for _, segment in ipairs(expr.segments) do
      local key
      if segment.kind == "key" then
        key = segment.value
      else
        key = runtime_access_index(evaluate_expr(engine, segment.expr, ctx, accumulator, edge_state))
      end
      if access_segment_matches(value, segment) then
        value = read_index(value, key)
      else
        value = json.null
      end
    end
    return copy_value(value)
  end
  if kind == "assign_hash_index" then
    local key = evaluate_expr(engine, expr.key, ctx, accumulator, edge_state)
    local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
    local current, storage = lookup_binding(ctx, expr.name)
    if json.kind(current) == "array" then
      local root = copy_value(current)
      if not write_index(root, key, value) then return json.null end
      return store_binding(ctx, expr.name, storage, root)
    end
    local root
    root, storage = harray_binding_for_mutation(ctx, expr.name)
    if not write_index(root, key, value) then return json.null end
    return store_harray_mutation(ctx, { kind = "scalar", name = expr.name }, storage, root)
  end
  if kind == "assign_nested_access" then
    local segments = {}
    for index, segment in ipairs(expr.segments) do
      local key
      if segment.kind == "key" then
        key = segment.value
      else
        key = runtime_access_index(evaluate_expr(engine, segment.expr, ctx, accumulator, edge_state))
      end
      segments[index] = { kind = segment.kind, key = key }
    end
    local value = evaluate_expr(engine, expr.value, ctx, accumulator, edge_state)
    local current, storage = lookup_binding(ctx, expr.base)
    if json.kind(current) ~= "array" and json.kind(current) ~= "harray" then return json.null end
    local root = copy_value(current)
    local target = root
    for index, segment in ipairs(segments) do
      if not access_segment_matches(target, segment) then return json.null end
      if index == #segments then
        if not write_index(target, segment.key, value) then return json.null end
      else
        local next_value = read_index(target, segment.key)
        if json.kind(next_value) ~= "array" and json.kind(next_value) ~= "harray" then return json.null end
        local written, copied = write_index(target, segment.key, next_value)
        if not written then return json.null end
        target = copied
      end
    end
    return store_binding(ctx, expr.base, storage, root)
  end
  if kind == "call" then return evaluate_call(engine, expr, ctx, accumulator, edge_state) end
  if kind == "fluent_chain" then
    local value = evaluate_expr(engine, expr.receiver, ctx, accumulator, edge_state)
    for index, call in ipairs(expr.calls) do
      local call_expr = { kind = "call", name = call.method, args = call.args }
      local canonical_name = action_contracts.canonical_action_helper_name(call.method)
      if action_contracts.builtin_final_codeblock_contract("receiver", canonical_name) ~= nil then
        local block_expr = final_codeblock_argument(canonical_name, "receiver", call.args)
        if canonical_name == "with" then
          value = evaluate_with_block(engine, block_expr, value, ctx, accumulator, edge_state)
        else
          value = evaluate_tree_receiver_block(
            engine,
            canonical_name,
            call_expr,
            block_expr,
            value,
            ctx,
            accumulator,
            edge_state
          )
          if canonical_name == "reduce_leaves" and index < #expr.calls then return json.null end
        end
      elseif ARRAY_END_MUTATIONS[canonical_name] then
        local target = index == 1 and binding_target_descriptor(expr.receiver) or nil
        if not target then return json.null end
        local items, storage = array_binding_for_mutation(ctx, target.name)
        if canonical_name == "push_back" or canonical_name == "push_front" then
          if #call.args ~= 1 then return json.null end
          local added = evaluate_expr(engine, argument_expr(call.args[1]), ctx, accumulator, edge_state)
          if canonical_name == "push_back" then
            items[#items + 1] = copy_value(added)
          else
            table.insert(items, 1, copy_value(added))
          end
        elseif #call.args ~= 0 then
          return json.null
        elseif #items > 0 then
          table.remove(items, canonical_name == "pop_back" and #items or 1)
        end
        value = store_array_mutation(ctx, target, storage, items)
      elseif canonical_name == "push" and #call.args == 0 then
        accumulator[#accumulator + 1] = copy_value(value)
      elseif canonical_name == "return" then
        local returned = value
        if #call.args > 0 then
          returned = evaluate_expr(engine, call.args[1].value, ctx, accumulator, edge_state)
        end
        flow("return", returned)
      elseif canonical_name == "coalesce" or canonical_name == "coalesce_nonempty" then
        value = evaluate_coalesce(engine, call_expr, ctx, accumulator, edge_state, value)
      elseif canonical_name == "copy" and #call.args == 0 then
        value = copy_value(value)
      elseif is_pure_string_helper(canonical_name) then
        value = evaluate_pure_string_values(engine, call_expr, ctx, accumulator, edge_state, value)
        if (TERMINAL_STRING_HELPERS[canonical_name] or is_string_comparison(canonical_name)) and
            index < #expr.calls then
          return json.null
        end
      elseif scalar_numeric.supports_reducer(canonical_name) and
          (json.kind(value) == "array" or not scalar_numeric.supports(canonical_name)) then
        value = evaluate_numeric_reducer_values(
          engine,
          call_expr,
          ctx,
          accumulator,
          edge_state,
          canonical_name,
          value
        )
        if index < #expr.calls then return json.null end
      elseif scalar_numeric.supports(canonical_name) then
        value = evaluate_scalar_numeric_values(
          engine,
          call_expr,
          ctx,
          accumulator,
          edge_state,
          canonical_name,
          value
        )
        if scalar_numeric.is_comparison(canonical_name) and index < #expr.calls then return json.null end
      elseif PURE_ARRAY_HELPERS[canonical_name] then
        value = evaluate_array_values(engine, call_expr, ctx, accumulator, edge_state, value)
        if canonical_name == "join_values" and index < #expr.calls then return json.null end
      elseif PURE_HASH_HELPERS[canonical_name] then
        value = evaluate_hash_values(engine, call_expr, ctx, accumulator, edge_state, value)
        if (canonical_name == "count_keys" or canonical_name == "has_key") and index < #expr.calls then
          return json.null
        end
      else
        value = evaluate_call(engine, call_expr, ctx, accumulator, edge_state)
      end
    end
    return value
  end
  fail("unsupported runtime ActionIR kind '" .. tostring(kind) .. "'", { action_kind = kind })
end

local function substitution_flag_text(engine, expr, ctx, accumulator, edge_state)
  if expr.kind == "variable" then return expr.name end
  local value = evaluate_expr(engine, expr, ctx, accumulator, edge_state)
  if getmetatable(value) == HELPER_REGEX_MT then return value.pattern end
  return scalar_string(value, true) or ""
end

local function execute_regex_substitution_statement(engine, expr, ctx, accumulator, edge_state)
  if expr.kind ~= "call" or #expr.args < 4 then return false end
  local name = action_contracts.canonical_action_helper_name(expr.name)
  if name ~= "substr" and name ~= "regex_subst" then return false end
  local target_expr = argument_expr(expr.args[1])
  if target_expr.kind ~= "variable" then return false end

  local pattern_value = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
  local pattern
  local pattern_flags = ""
  if getmetatable(pattern_value) == HELPER_REGEX_MT then
    pattern = pattern_value.pattern
    pattern_flags = pattern_value.flags
  else
    pattern = scalar_string(pattern_value, false)
  end
  if pattern == nil then return false end

  local explicit_flags = substitution_flag_text(
    engine,
    argument_expr(expr.args[4]),
    ctx,
    accumulator,
    edge_state
  )
  local flags = stable_helper_flags(pattern_flags .. explicit_flags)
  if (pattern_flags .. explicit_flags):find("[^gimosx]") then
    local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
    fail("regex substitution for '" .. target_expr.name .. "' in rule " .. rule_label ..
      " has invalid pattern or flags", { rule_label = rule_label, target = target_expr.name })
  end
  local regex = compile_helper_regex(engine, helper_regex(pattern, flags))
  if regex == nil then
    local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
    fail("regex substitution for '" .. target_expr.name .. "' in rule " .. rule_label ..
      " has invalid pattern or flags", { rule_label = rule_label, target = target_expr.name })
  end

  local replacement_value = evaluate_expr(
    engine,
    argument_expr(expr.args[3]),
    ctx,
    accumulator,
    edge_state
  )
  local replacement = scalar_string(replacement_value, true) or ""
  local source_value = ctx.variables[target_expr.name]
  if source_value == nil then source_value = json.null end
  local source = scalar_string(source_value, true) or ""
  bind_scalar(ctx, target_expr.name, replace_regex(source, regex, replacement, flags:find("g", 1, true) ~= nil))
  return true
end

local function execute_array_split_statement(engine, expr, ctx, accumulator, edge_state)
  if expr.kind ~= "call" or action_contracts.canonical_action_helper_name(expr.name) ~= "split" or
      #expr.args < 2 then
    return false
  end
  local target = binding_target_descriptor(argument_expr(expr.args[1]))
  if not target or #expr.args ~= 3 then
    return false
  end
  evaluate_mutable_split(engine, expr, ctx, accumulator, edge_state, target)
  return true
end

local function execute_array_transform_statement(engine, expr, ctx, accumulator, edge_state)
  if expr.kind ~= "call" then return false end
  local name = action_contracts.canonical_action_helper_name(expr.name)
  local unary = name == "trim_each" or name == "filter_nonempty" or name == "lowercase_each" or
    name == "uppercase_each" or name == "uniq"
  local binary = name == "split_each" or name == "filter_match"
  if (not unary and not binary) or (unary and #expr.args ~= 1) or (binary and #expr.args ~= 2) then
    return false
  end
  local target = binding_target_descriptor(argument_expr(expr.args[1]))
  if not target then return false end
  local current, storage = array_binding_for_mutation(ctx, target.name)
  local transformed
  if name == "lowercase_each" or name == "uppercase_each" then
    transformed = evaluate_pure_string_helper(engine, name, { current })
  else
    local values = { current }
    if expr.args[2] then
      values[2] = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
    end
    transformed = evaluate_array_helper(engine, name, values)
  end
  store_array_mutation(ctx, target, storage, transformed)
  return true
end

local function execute_hash_set_key_statement(engine, expr, ctx, accumulator, edge_state)
  if expr.kind ~= "call" or action_contracts.canonical_action_helper_name(expr.name) ~= "set_key" or
      #expr.args ~= 3 then
    return false
  end
  local target = binding_target_descriptor(argument_expr(expr.args[1]))
  if not target then return false end
  local key_value = evaluate_expr(engine, argument_expr(expr.args[2]), ctx, accumulator, edge_state)
  local value = evaluate_expr(engine, argument_expr(expr.args[3]), ctx, accumulator, edge_state)
  local updated, storage = harray_binding_for_mutation(ctx, target.name)
  updated[scalar_string(key_value, true) or ""] = copy_value(value)
  store_harray_mutation(ctx, target, storage, updated)
  return true
end

local function execute_dropped_statement(engine, statement, ctx, accumulator, edge_state)
  local handled = statement.drops_value and (
    execute_regex_substitution_statement(engine, statement.expr, ctx, accumulator, edge_state) or
    execute_array_split_statement(engine, statement.expr, ctx, accumulator, edge_state) or
    execute_array_transform_statement(engine, statement.expr, ctx, accumulator, edge_state) or
    execute_hash_set_key_statement(engine, statement.expr, ctx, accumulator, edge_state)
  )
  if handled then return json.null end
  return evaluate_expr(engine, statement.expr, ctx, accumulator, edge_state)
end

local function evaluate_block_step(callback)
  local ok, value = pcall(callback)
  if ok then return false, value end
  if getmetatable(value) == FLOW_MT and value.kind == "return" then
    return true, copy_value(value.value)
  end
  error(value, 0)
end

local ATTACHED_IF_START_KEYWORDS = { ["if"] = true, when = true }
local ATTACHED_ELSEIF_KEYWORDS = { ["elseif"] = true }
local ATTACHED_ELSE_KEYWORDS = { ["else"] = true, otherwise = true }
local MARKER_IF_START_KEYWORDS = { ["if"] = true, i = true }
local MARKER_ELSEIF_KEYWORDS = { ["elseif"] = true, elif = true }
local MARKER_ELSE_KEYWORDS = { ["else"] = true }

local function statement_control_failure(expr, ctx, reason)
  local keyword = expr.keyword or expr.canonical_keyword or expr.kind
  local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
  fail("malformed statement control '" .. tostring(keyword) .. "' in rule " .. tostring(rule_label) ..
    ": " .. reason, {
      code = "malformed_statement_control",
      control_keyword = keyword,
      reason = reason,
      action_kind = expr.kind,
      rule_label = rule_label,
    })
end

local function is_marker_if_start(expr)
  return expr.kind == "control_if" and expr.branch_role == "if" and expr.body == nil
end

local function is_marker_elseif(expr)
  return expr.kind == "control_if" and expr.branch_role == "elseif" and expr.body == nil
end

local function is_marker_else(expr)
  return expr.kind == "control_else" and expr.body == nil
end

local function is_marker_endif(expr)
  return expr.kind == "control_endif" and expr.body == nil
end

local function is_marker_switch_start(expr)
  return expr.kind == "control_switch" and expr.body == nil
end

local function is_marker_case(expr)
  return expr.kind == "control_case" and expr.body == nil
end

local function is_marker_default(expr)
  return expr.kind == "control_default" and expr.body == nil
end

local function is_marker_endcase(expr)
  return expr.kind == "control_endcase" and expr.body == nil
end

local function is_marker_endswitch(expr)
  return expr.kind == "control_endswitch" and expr.body == nil
end

local function validate_if_keyword(expr, ctx, expected, allowed)
  if allowed[expr.keyword] then return end
  statement_control_failure(expr, ctx, "expected " .. expected)
end

local function execute_attached_if_chain(engine, statements, start_index, stop_index, ctx, accumulator, edge_state)
  local first = statements[start_index].expr
  validate_if_keyword(first, ctx, "if/when", ATTACHED_IF_START_KEYWORDS)

  local branches = {}
  local next_index = start_index
  local cursor = start_index
  while cursor < stop_index do
    local expr = statements[cursor].expr
    if cursor == start_index then
      branches[#branches + 1] = { condition = expr.condition, body = expr.body }
    elseif expr.kind == "control_if" and expr.branch_role == "elseif" then
      if expr.body == nil then
        statement_control_failure(expr, ctx, "cannot mix attached and marker branches")
      end
      validate_if_keyword(expr, ctx, "elseif", ATTACHED_ELSEIF_KEYWORDS)
      branches[#branches + 1] = { condition = expr.condition, body = expr.body }
    elseif expr.kind == "control_else" then
      if expr.body == nil then
        statement_control_failure(expr, ctx, "cannot mix attached and marker branches")
      end
      validate_if_keyword(expr, ctx, "else/otherwise", ATTACHED_ELSE_KEYWORDS)
      branches[#branches + 1] = { body = expr.body }
    else
      break
    end
    next_index = cursor
    if expr.kind == "control_else" then
      local following = statements[cursor + 1]
      if following and following.expr.kind == "control_else" then
        statement_control_failure(following.expr, ctx, "duplicate else")
      end
      if following and following.expr.kind == "control_if" and following.expr.branch_role == "elseif" then
        statement_control_failure(following.expr, ctx, "elseif follows else")
      end
      break
    end
    cursor = cursor + 1
  end

  for _, branch in ipairs(branches) do
    if branch.condition == nil or
        runtime_truthy(evaluate_expr(engine, branch.condition, ctx, accumulator, edge_state)) then
      execute_block(engine, branch.body, ctx, accumulator, edge_state)
      break
    end
  end
  return next_index
end

local function select_marker_if_chain(engine, statements, start_index, stop_index, ctx, accumulator, edge_state)
  local first = statements[start_index].expr
  validate_if_keyword(first, ctx, "if/i", MARKER_IF_START_KEYWORDS)

  local branches = { { condition = first.condition, start_index = start_index + 1 } }
  local frames = { { saw_else = false } }
  local close_index
  local cursor = start_index + 1
  while cursor < stop_index do
    local expr = statements[cursor].expr
    if is_marker_if_start(expr) then
      validate_if_keyword(expr, ctx, "if/i", MARKER_IF_START_KEYWORDS)
      frames[#frames + 1] = { saw_else = false }
    elseif is_marker_elseif(expr) then
      validate_if_keyword(expr, ctx, "elseif/elif", MARKER_ELSEIF_KEYWORDS)
      local frame = frames[#frames]
      if frame.saw_else then statement_control_failure(expr, ctx, "elseif follows else") end
      if #frames == 1 then
        branches[#branches].stop_index = cursor
        branches[#branches + 1] = { condition = expr.condition, start_index = cursor + 1 }
      end
    elseif is_marker_else(expr) then
      validate_if_keyword(expr, ctx, "else", MARKER_ELSE_KEYWORDS)
      local frame = frames[#frames]
      if frame.saw_else then statement_control_failure(expr, ctx, "duplicate else") end
      frame.saw_else = true
      if #frames == 1 then
        branches[#branches].stop_index = cursor
        branches[#branches + 1] = { start_index = cursor + 1 }
      end
    elseif is_marker_endif(expr) then
      if #frames > 1 then
        frames[#frames] = nil
      else
        branches[#branches].stop_index = cursor
        close_index = cursor
        break
      end
    end
    cursor = cursor + 1
  end

  if close_index == nil then statement_control_failure(first, ctx, "missing endif") end

  for _, branch in ipairs(branches) do
    if branch.condition == nil or
        runtime_truthy(evaluate_expr(engine, branch.condition, ctx, accumulator, edge_state)) then
      return branch.start_index, branch.stop_index, close_index
    end
  end
  return nil, nil, close_index
end

local function execute_attached_switch(engine, expr, ctx, accumulator, edge_state)
  if expr.keyword ~= "switch" then statement_control_failure(expr, ctx, "expected switch") end

  local branches = {}
  local saw_default = false
  for _, statement in ipairs(expr.body.statements) do
    local branch = statement.expr
    if branch.kind == "control_case" then
      if branch.body == nil then
        statement_control_failure(branch, ctx, "cannot mix attached and marker branches")
      end
      if saw_default then statement_control_failure(branch, ctx, "case follows default") end
      branches[#branches + 1] = { match = branch.match, body = branch.body }
    elseif branch.kind == "control_default" then
      if branch.body == nil then
        statement_control_failure(branch, ctx, "cannot mix attached and marker branches")
      end
      if saw_default then statement_control_failure(branch, ctx, "duplicate default") end
      saw_default = true
      branches[#branches + 1] = { body = branch.body }
    else
      statement_control_failure(branch, ctx, "expected attached case/default branch")
    end
  end

  local subject = evaluate_expr(engine, expr.source_expr, ctx, accumulator, edge_state)
  for _, branch in ipairs(branches) do
    if branch.match == nil or switch_values_equal(
        evaluate_switch_case_match(engine, branch.match, ctx, accumulator, edge_state),
        subject
      ) then
      execute_block(engine, branch.body, ctx, accumulator, edge_state)
      break
    end
  end
end

local function while_iteration_limit_failure(engine, expr, ctx)
  local rule_label = ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
  fail("LinkedSpec while iteration safety limit exceeded after " .. engine.max_iterations .. " iterations", {
    code = "while_iteration_limit_exceeded",
    control_keyword = expr.keyword or "while",
    action_kind = expr.kind,
    max_iterations = engine.max_iterations,
    rule_label = rule_label,
  })
end

local function execute_while_body(engine, body, ctx, accumulator, edge_state)
  local ok, value = pcall(execute_block, engine, body, ctx, accumulator, edge_state)
  if ok then return end
  if getmetatable(value) == FLOW_MT and value.kind == "next" then return end
  error(value, 0)
end

local function execute_attached_while(engine, expr, ctx, accumulator, edge_state)
  if expr.keyword ~= "while" then statement_control_failure(expr, ctx, "expected while") end
  if expr.body == nil then statement_control_failure(expr, ctx, "attached while requires a body") end

  local iterations = 0
  while runtime_truthy(evaluate_expr(engine, expr.condition, ctx, accumulator, edge_state)) do
    if iterations >= engine.max_iterations then while_iteration_limit_failure(engine, expr, ctx) end
    iterations = iterations + 1
    execute_while_body(engine, expr.body, ctx, accumulator, edge_state)
  end
end

local function select_marker_switch_chain(engine, statements, start_index, stop_index, ctx, accumulator, edge_state)
  local first = statements[start_index].expr
  if first.keyword ~= "switch" then statement_control_failure(first, ctx, "expected switch") end
  if #first.cases ~= 0 or first.default ~= nil then
    statement_control_failure(first, ctx, "cannot mix attached and marker branches")
  end

  local branches = {}
  local frames = { { saw_default = false, branch_open = false } }
  local close_index
  local cursor = start_index + 1
  while cursor < stop_index do
    local expr = statements[cursor].expr
    if is_marker_switch_start(expr) then
      if #expr.cases ~= 0 or expr.default ~= nil then
        statement_control_failure(expr, ctx, "cannot mix attached and marker branches")
      end
      frames[#frames + 1] = { saw_default = false, branch_open = false }
    elseif is_marker_case(expr) then
      local frame = frames[#frames]
      if frame.saw_default then statement_control_failure(expr, ctx, "case follows default") end
      frame.branch_open = true
      if #frames == 1 then
        if branches[#branches] and branches[#branches].stop_index == nil then
          branches[#branches].stop_index = cursor
        end
        branches[#branches + 1] = { match = expr.match, start_index = cursor + 1 }
      end
    elseif is_marker_default(expr) then
      local frame = frames[#frames]
      if frame.saw_default then statement_control_failure(expr, ctx, "duplicate default") end
      frame.saw_default = true
      frame.branch_open = true
      if #frames == 1 then
        if branches[#branches] and branches[#branches].stop_index == nil then
          branches[#branches].stop_index = cursor
        end
        branches[#branches + 1] = { start_index = cursor + 1 }
      end
    elseif is_marker_endcase(expr) then
      local frame = frames[#frames]
      if not frame.branch_open then statement_control_failure(expr, ctx, "endcase without open branch") end
      frame.branch_open = false
      if #frames == 1 and branches[#branches] and branches[#branches].stop_index == nil then
        branches[#branches].stop_index = cursor
      end
    elseif is_marker_endswitch(expr) then
      if #frames > 1 then
        frames[#frames] = nil
      else
        if branches[#branches] and branches[#branches].stop_index == nil then
          branches[#branches].stop_index = cursor
        end
        close_index = cursor
        break
      end
    elseif (expr.kind == "control_case" or expr.kind == "control_default") and expr.body ~= nil then
      statement_control_failure(expr, ctx, "cannot mix attached and marker branches")
    end
    cursor = cursor + 1
  end

  if close_index == nil then statement_control_failure(first, ctx, "missing endswitch") end

  local subject = evaluate_expr(engine, first.source_expr, ctx, accumulator, edge_state)
  for _, branch in ipairs(branches) do
    if branch.match == nil or switch_values_equal(
        evaluate_switch_case_match(engine, branch.match, ctx, accumulator, edge_state),
        subject
      ) then
      return branch.start_index, branch.stop_index, close_index
    end
  end
  return nil, nil, close_index
end

local execute_statement_at
local execute_statement_range

execute_statement_at = function(engine, statements, index, stop_index, ctx, accumulator, edge_state)
  local expr = statements[index].expr
  if expr.kind == "control_if" and expr.branch_role == "if" then
    if expr.body ~= nil then
      return execute_attached_if_chain(
        engine,
        statements,
        index,
        stop_index,
        ctx,
        accumulator,
        edge_state
      )
    end
    local selected_start, selected_stop, close_index = select_marker_if_chain(
      engine,
      statements,
      index,
      stop_index,
      ctx,
      accumulator,
      edge_state
    )
    if selected_start ~= nil then
      execute_statement_range(
        engine,
        statements,
        selected_start,
        selected_stop,
        ctx,
        accumulator,
        edge_state
      )
    end
    return close_index
  end
  if expr.kind == "control_switch" then
    if expr.body ~= nil then
      execute_attached_switch(engine, expr, ctx, accumulator, edge_state)
      return index
    end
    local selected_start, selected_stop, close_index = select_marker_switch_chain(
      engine,
      statements,
      index,
      stop_index,
      ctx,
      accumulator,
      edge_state
    )
    if selected_start ~= nil then
      execute_statement_range(
        engine,
        statements,
        selected_start,
        selected_stop,
        ctx,
        accumulator,
        edge_state
      )
    end
    return close_index
  end
  if expr.kind == "control_while" then
    execute_attached_while(engine, expr, ctx, accumulator, edge_state)
    return index
  end
  if expr.kind == "control_if" or expr.kind == "control_else" or expr.kind == "control_endif" or
      expr.kind == "control_case" or expr.kind == "control_default" or expr.kind == "control_endcase" or
      expr.kind == "control_endswitch" then
    statement_control_failure(expr, ctx, "orphaned branch or marker")
  end
  execute_dropped_statement(engine, statements[index], ctx, accumulator, edge_state)
  return index
end

execute_statement_range = function(engine, statements, start_index, stop_index, ctx, accumulator, edge_state)
  local index = start_index
  while index < stop_index do
    index = execute_statement_at(engine, statements, index, stop_index, ctx, accumulator, edge_state) + 1
  end
end

evaluate_block_value = function(engine, block, ctx, accumulator, edge_state)
  if #block.statements == 0 then return json.null end
  local index = 1
  while index <= #block.statements do
    local statement = block.statements[index]
    local is_last = index == #block.statements
    local next_index = index
    local returned, value = evaluate_block_step(function()
      if statement.expr.kind == "control_if" or statement.expr.kind == "control_else" or
          statement.expr.kind == "control_endif" or statement.expr.kind == "control_while" or
          statement.expr.kind == "control_switch" or
          statement.expr.kind == "control_case" or statement.expr.kind == "control_default" or
          statement.expr.kind == "control_endcase" or statement.expr.kind == "control_endswitch" then
        next_index = execute_statement_at(
          engine,
          block.statements,
          index,
          #block.statements + 1,
          ctx,
          accumulator,
          edge_state
        )
        return json.null
      end
      if is_last then
        return evaluate_expr(engine, statement.expr, ctx, accumulator, edge_state)
      end
      return execute_dropped_statement(engine, statement, ctx, accumulator, edge_state)
    end)
    if returned or is_last then return copy_value(value) end
    index = next_index + 1
  end
  return json.null
end

local function current_rule_label(ctx)
  return ctx.rule_stack[#ctx.rule_stack] or ctx.top_rule
end

local function raise_user_function_error(engine, ctx, name, message, fields)
  fields = fields or {}
  local rule_label = fields.rule_label or current_rule_label(ctx)
  fields.stage = fields.stage or "user_function_call"
  fields.helper_name = fields.helper_name or name
  fields.rule_label = rule_label
  fields.handler_source_label = fields.handler_source_label or "lua_runtime:function:" .. name
  fields.diagnostic = fields.diagnostic or runtime_diagnostic(engine, {
    stage = fields.stage,
    summary = fields.summary or "Lua user function execution failed",
    detail = message,
    top_rule = ctx.top_rule,
    rule_label = rule_label,
    handler_source_label = fields.handler_source_label,
  })
  fail(message, fields)
end

local function staged_user_function_body(engine, entry, ctx)
  local definition = entry.definition
  local body_ast = definition.body_ast
  if json.kind(body_ast) ~= "harray" or body_ast.kind ~= "action_block" then
    raise_user_function_error(
      engine,
      ctx,
      definition.name,
      "user function '" .. definition.name .. "' does not have a staged action-block body_ast",
      {
        code = "user_function_body_ast_missing",
        stage = "user_function_body_parse",
        summary = "Lua user function staging failed",
      }
    )
  end

  local staged_json = json.encode(body_ast)
  local cached = engine.user_function_body_cache[definition.name]
  if cached ~= nil and cached.body_source == definition.body_source and cached.staged_json == staged_json then
    return cached.block
  end

  local ok, block_or_error = pcall(action_parser.parse_action_block, definition.body_source)
  if not ok then
    raise_user_function_error(
      engine,
      ctx,
      definition.name,
      "user function '" .. definition.name .. "' staged body source could not be reconstructed: " ..
        tostring(block_or_error),
      {
        code = "user_function_body_parse_failed",
        stage = "user_function_body_parse",
        summary = "Lua user function body parse failed",
      }
    )
  end

  local parsed_json = json.encode(action_ast.to_json(block_or_error))
  if parsed_json ~= staged_json then
    raise_user_function_error(
      engine,
      ctx,
      definition.name,
      "user function '" .. definition.name .. "' staged body_ast does not match its governed body source",
      {
        code = "user_function_body_ast_mismatch",
        stage = "user_function_body_parse",
        summary = "Lua user function staging failed",
      }
    )
  end

  engine.user_function_body_cache[definition.name] = {
    body_source = definition.body_source,
    staged_json = staged_json,
    block = block_or_error,
  }
  return block_or_error
end

execute_contextual_codeblock = function(engine, expr, ctx)
  local keyword_count = 0
  for _, argument in ipairs(expr.args) do
    if argument.argument_kind == "keyword" then keyword_count = keyword_count + 1 end
  end
  if keyword_count > 0 or #expr.args ~= 0 then
    fail(
      "contextual codeblock '" .. expr.name .. "' expects exactly 0 positional arguments, got " .. #expr.args,
      {
        code = "codeblock_arity_mismatch",
        stage = "user_function_body",
        expected = "exactly 0",
        got = #expr.args,
        helper_name = expr.name,
      }
    )
  end

  local value = ctx.variables[expr.name]
  if action_ast.node_type(value) ~= "ActionExpr" or
      (value.kind ~= "codeblock_argument" and value.kind ~= "block_value") then
    fail(
      "contextual codeblock parameter '" .. expr.name .. "' is not a codeblock",
      {
        code = "final_argument_not_codeblock",
        stage = "user_function_body",
        helper_name = expr.name,
        value_kind = value == nil and "missing" or M.runtime_value_kind(value),
      }
    )
  end
  for _, active_name in ipairs(ctx.active_contextual_codeblocks) do
    if active_name == expr.name then
      local cycle = expr.name .. " -> " .. expr.name
      fail(
        "contextual codeblock recursion is not supported: " .. cycle,
        {
          code = "codeblock_recursion_unsupported",
          stage = "user_function_body",
          helper_name = expr.name,
          cycle = cycle,
        }
      )
    end
  end

  ctx.active_contextual_codeblocks[#ctx.active_contextual_codeblocks + 1] = expr.name
  local executed, result = pcall(
    evaluate_block_value,
    engine,
    value.block,
    ctx,
    json.array(),
    nil
  )
  ctx.active_contextual_codeblocks[#ctx.active_contextual_codeblocks] = nil
  if not executed then error(result, 0) end
  return copy_value(result)
end

execute_user_function = function(engine, expr, ctx, accumulator, edge_state)
  expr = select(1, action_contracts.normalize_contextual_codeblock_call(
    "function",
    expr,
    engine.compiled_spec.function_registry
  ))
  local keyword_count = 0
  for _, argument in ipairs(expr.args) do
    if argument.argument_kind == "keyword" then keyword_count = keyword_count + 1 end
  end
  if keyword_count > 0 then
    raise_user_function_error(
      engine,
      ctx,
      expr.name,
      "user function '" .. expr.name .. "' accepts positional arguments only, got " ..
        keyword_count .. " keyword argument(s)",
      {
        code = "user_function_keyword_arguments_unsupported",
        expected = "positional arguments",
        got = keyword_count,
      }
    )
  end

  local evaluated_values = {}
  for _, argument in ipairs(expr.args) do
    evaluated_values[#evaluated_values + 1] = evaluate_expr(
      engine,
      argument_expr(argument),
      ctx,
      accumulator,
      edge_state
    )
  end

  local rule_label = current_rule_label(ctx)
  local prepared, frame_or_error = pcall(
    user_function_registry.prepare_invocation,
    engine.compiled_spec.function_registry,
    expr.name,
    evaluated_values,
    ctx.active_user_functions,
    { rule_label = rule_label }
  )
  if not prepared then
    if user_function_registry.is_registry_error(frame_or_error) then
      local fields = {}
      for key, value in pairs(frame_or_error) do
        if key ~= "message" then fields[key] = value end
      end
      raise_user_function_error(engine, ctx, expr.name, frame_or_error.message, fields)
    end
    error(frame_or_error, 0)
  end

  local block = staged_user_function_body(engine, frame_or_error.entry, ctx)
  local saved_variables = ctx.variables
  local saved_arrays = ctx.arrays
  local saved_harrays = ctx.harrays
  local saved_active_user_functions = ctx.active_user_functions
  local saved_parameter_kinds = ctx.user_function_parameter_kinds
  local saved_active_contextual_codeblocks = ctx.active_contextual_codeblocks
  ctx.variables = frame_or_error.variables
  ctx.arrays = frame_or_error.arrays
  ctx.harrays = frame_or_error.harrays
  ctx.active_user_functions = frame_or_error.active_path
  ctx.user_function_parameter_kinds = frame_or_error.parameter_kinds
  ctx.active_contextual_codeblocks = {}

  local executed, value_or_error = pcall(
    evaluate_block_value,
    engine,
    block,
    ctx,
    json.array(),
    nil
  )
  ctx.variables = saved_variables
  ctx.arrays = saved_arrays
  ctx.harrays = saved_harrays
  ctx.active_user_functions = saved_active_user_functions
  ctx.user_function_parameter_kinds = saved_parameter_kinds
  ctx.active_contextual_codeblocks = saved_active_contextual_codeblocks

  if not executed then
    if getmetatable(value_or_error) == ERROR_MT then
      value_or_error = with_runtime_diagnostic(value_or_error, runtime_diagnostic(engine, {
        stage = "user_function_body",
        summary = "Lua user function execution failed",
        detail = value_or_error.message,
        top_rule = ctx.top_rule,
        rule_label = rule_label,
        handler_source_label = "lua_runtime:function:" .. expr.name,
      }))
    end
    error(value_or_error, 0)
  end
  return copy_value(value_or_error)
end

execute_block = function(engine, block, ctx, accumulator, edge_state)
  execute_statement_range(engine, block.statements, 1, #block.statements + 1, ctx, accumulator, edge_state)
end

local function lifecycle(engine, rule, name, ctx, accumulator)
  for _, payload in ipairs(rule.lifecycle_action_payloads) do
    if payload.lifecycle == name then
      ctx.lifecycle_events[#ctx.lifecycle_events + 1] = setmetatable({
        rule_label = rule.label,
        lifecycle = name,
        line = payload.line,
      }, EVENT_MT)
      runtime_trace_event(
        ctx,
        trace.TRACE_MARK,
        "lua_runtime:lifecycle_block",
        "rule=" .. rule.label .. " lifecycle=" .. name .. " line=" .. tostring(payload.line) ..
          " cursor=" .. tostring(ctx.cursor_byte),
        trace.TRACE_HIGH
      )
      execute_block(engine, payload.action_ast, ctx, accumulator, nil)
    end
  end
end

local function execute_rule_slot_events(rule, regex_index, ctx)
  for _, event in ipairs(rule.rule_slot_events) do
    if event.regex_index == regex_index then
      if event.kind == "capture_boundary" then
        set_capture_start(ctx, ctx.cursor_byte)
      elseif event.kind == "named_mark" then
        local marks = ctx.mark_buckets[rule.label]
        if marks == nil then
          marks = {}
          ctx.mark_buckets[rule.label] = marks
        end
        marks[event.mark_name] = ctx.cursor_byte
      else
        fail("unsupported compiled rule-slot event '" .. tostring(event.kind) .. "'", {
          code = "unsupported_rule_slot_event",
          rule_label = rule.label,
          event_kind = event.kind,
        })
      end
      runtime_trace_event(
        ctx,
        trace.TRACE_MARK,
        "lua_runtime:mark_capture",
        "source=rule_slot rule=" .. rule.label .. " kind=" .. event.kind ..
          " regex_index=" .. tostring(regex_index) .. " cursor=" .. tostring(ctx.cursor_byte) ..
          (event.mark_name and (" mark_name=" .. event.mark_name) or ""),
        trace.TRACE_DEBUG
      )
    end
  end
end

local function trace_regex_decision(ctx, rule, one, cursor_before, reason)
  runtime_trace_decision(
    ctx,
    "lua_runtime:regex_match",
    one ~= nil,
    "rule=" .. rule.label .. " " .. reason ..
      " alternative=" .. tostring(one and one.alternative_index or -1) ..
      " match_start=" .. tostring(one and one.byte_start or -1) ..
      " match_end=" .. tostring(one and one.byte_end or -1) ..
      " cursor_before=" .. tostring(cursor_before),
    trace.TRACE_DEBUG
  )
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
      local edge_state = {
        edge = edge,
        target = edge.targets[1],
        rule_label = rule.label,
        child_dispatched = false,
      }
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
  execute_rule_slot_events(rule, one.alternative_index, ctx)
  lifecycle(engine, rule, "LE", ctx, accumulator)
end

local function regex_once(engine, rule, entry_index, ctx, accumulator)
  local cursor_before = ctx.cursor_byte
  if #rule.regex_patterns == 0 then
    trace_regex_decision(ctx, rule, nil, cursor_before, "patterns=0")
    return false
  end
  if rule.mode_metadata.is_and and #rule.regex_patterns > 1 then
    for index = 0, #rule.regex_patterns - 1 do
      cursor_before = ctx.cursor_byte
      local one = match_specific(engine, rule, index, ctx)
      trace_regex_decision(ctx, rule, one, cursor_before, "mode=AND expected_index=" .. tostring(index))
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
  trace_regex_decision(ctx, rule, one, cursor_before, "entry_regex=" .. tostring(entry_index))
  if not one then return false end
  accept_match(engine, rule, one, ctx, accumulator)
  return true
end

local function blind_once(engine, rule, ctx, accumulator)
  local any = false
  for edge_index, edge in ipairs(rule.blind_edges) do
    local cursor_before = ctx.cursor_byte
    local child = execute_rule(engine, edge.target.label, edge.target.index, ctx)
    runtime_trace_decision(
      ctx,
      "lua_runtime:child_dispatch",
      child.matched,
      "edge_family=blind mode=" .. (rule.mode_metadata.is_and and "AND" or "OR") ..
        " rule=" .. rule.label .. " index=" .. tostring(edge_index - 1) ..
        " target=" .. edge.target.label .. "[" .. tostring(edge.target.index) .. "]" ..
        " cursor_before=" .. tostring(cursor_before) .. " cursor_after=" .. tostring(ctx.cursor_byte),
      trace.TRACE_DEBUG
    )
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
  if not rule then
    local detail = "rule '" .. label .. "' is not compiled"
    fail(detail, {
      rule_label = label,
      diagnostic = runtime_diagnostic(engine, {
        stage = "rule_lookup",
        summary = "Lua runtime rule lookup failed",
        detail = detail,
        top_rule = ctx.top_rule,
        rule_label = label,
      }),
    })
  end
  local recursion_key = label .. ":" .. entry_index .. ":" .. ctx.cursor_byte
  if ctx.active[recursion_key] then
    runtime_trace_decision(
      ctx,
      "lua_runtime:recursion_guard",
      true,
      "rule=" .. label .. " entry_regex=" .. tostring(entry_index) ..
        " cursor=" .. tostring(ctx.cursor_byte),
      trace.TRACE_DEBUG
    )
    return rule_result(false, json.null)
  end
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
  local accumulator = json.array()
  ctx.accumulator_stack[#ctx.accumulator_stack + 1] = { label = label, values = accumulator }
  local trace_scope = runtime_trace_scope(
    ctx,
    "lua_runtime:rule",
    "rule=" .. label .. " entry_regex=" .. tostring(entry_index) ..
      " mode=" .. rule.mode_metadata.name .. " cursor=" .. tostring(ctx.cursor_byte),
    trace.TRACE_HIGH
  )
  local generated_family = ctx.generated_families and ctx.generated_families[label] or nil
  local generated_uses_blind_dispatch
  if generated_family == nil then
    generated_uses_blind_dispatch = #rule.blind_edges > 0
  else
    generated_uses_blind_dispatch = generated_family == "and_bcode" or
      generated_family == "or_bcode" or generated_family == "rep_bcode" or
      generated_family == "rep_and_bcode"
  end
  if generated_family ~= nil and ctx.generated_source_identity ~= nil then
    runtime_trace_event(
      ctx,
      trace.TRACE_MARK,
      "generated_rule_enter",
      "source_identity=" .. ctx.generated_source_identity .. " rule=" .. label ..
        " entry_regex=" .. tostring(entry_index) .. " cursor=" .. tostring(ctx.cursor_byte),
      trace.TRACE_LOW
    )
    runtime_trace_event(
      ctx,
      trace.TRACE_MARK,
      "generated_family_decision",
      "source_identity=" .. ctx.generated_source_identity .. " rule=" .. label ..
        " family=" .. generated_family,
      trace.TRACE_LOW
    )
  end
  local ok, result_or_flow = pcall(function()
    lifecycle(engine, rule, "I", ctx, accumulator)
    local minimum = rule.mode_metadata.rep_min
    local matched = false
    if minimum == nil then
      local matched_any = false
      for _ = 1, engine.max_iterations do
        local before = ctx.cursor_byte
        local attempt = nextable(function()
          if generated_uses_blind_dispatch then
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
        if generated_uses_blind_dispatch then
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
  if not ok and getmetatable(result_or_flow) == ERROR_MT then
    result_or_flow = with_runtime_diagnostic(result_or_flow, runtime_diagnostic(engine, {
      stage = "runtime_execution",
      summary = "Lua runtime interpreter failed",
      detail = result_or_flow.message,
      top_rule = ctx.top_rule,
      rule_label = label,
    }))
  end
  local trace_exit_details
  if ok then
    trace_exit_details = "matched=" .. tostring(result_or_flow.matched) .. " cursor=" .. tostring(ctx.cursor_byte)
  elseif getmetatable(result_or_flow) == FLOW_MT and
      (result_or_flow.kind == "return" or result_or_flow.kind == "next") then
    trace_exit_details = "matched=true cursor=" .. tostring(ctx.cursor_byte)
  else
    local message = getmetatable(result_or_flow) == ERROR_MT and result_or_flow.message or tostring(result_or_flow)
    trace_exit_details = "error=" .. message .. " cursor=" .. tostring(ctx.cursor_byte)
  end
  if generated_family ~= nil and ctx.generated_source_identity ~= nil then
    runtime_trace_event(
      ctx,
      trace.TRACE_MARK,
      "generated_rule_exit",
      "source_identity=" .. ctx.generated_source_identity .. " rule=" .. label ..
        " family=" .. generated_family .. " cursor=" .. tostring(ctx.cursor_byte),
      trace.TRACE_LOW
    )
  end
  runtime_trace_scope_exit(ctx, trace_scope, trace_exit_details)
  ctx.accumulator_stack[#ctx.accumulator_stack] = nil
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
  if type(options) ~= "table" then fail("runtime parse options must be a table") end
  if options.diagnostic_sink ~= nil and type(options.diagnostic_sink) ~= "function" then
    fail("diagnostic_sink must be a function")
  end
  if options.trace ~= nil and not trace.is_trace_emitter(options.trace) then
    fail("trace must be a LinkedSpecTraceEmitter")
  end
  if options._generated_families ~= nil and type(options._generated_families) ~= "table" then
    fail("internal generated families must be a table")
  end
  if options._generated_source_identity ~= nil and type(options._generated_source_identity) ~= "string" then
    fail("internal generated source identity must be a string")
  end
  if (options._generated_families == nil) ~= (options._generated_source_identity == nil) then
    fail("internal generated plan and source identity must be provided together")
  end
  local selection_ok, selection = pcall(
    compiled_spec.resolve_entry_rule,
    engine.compiled_spec,
    options.top_rule
  )
  if not selection_ok then
    if not compiled_spec.is_entry_rule_selection_error(selection) then error(selection, 0) end
    if options.trace ~= nil then
      trace.trace_decision(
        options.trace,
        "lua_runtime:entry_rule_selection",
        false,
        "requested=" .. (options.top_rule == nil and "<default>" or options.top_rule) ..
          " effective=<none> stage=" .. selection.stage .. " code=" .. selection.code,
        trace.TRACE_LOW
      )
    end
    fail(selection.message, {
      code = selection.code,
      stage = selection.stage,
      entry_rule = selection.entry_rule,
      diagnostic = runtime_diagnostic(engine, {
        stage = selection.stage,
        summary = "Lua runtime entry-rule selection failed",
        detail = selection.message,
        top_rule = selection.entry_rule,
        entry_rule = selection.entry_rule,
        rule_label = selection.entry_rule,
        code = selection.code,
      }),
    })
  end
  if options.trace ~= nil then
    trace.trace_decision(
      options.trace,
      "lua_runtime:entry_rule_selection",
      true,
      "requested=" .. (options.top_rule == nil and "<default>" or options.top_rule) ..
        " effective=" .. selection.rule.label ..
        " basis=" .. compiled_spec.entry_rule_selection_basis_name(selection.basis),
      trace.TRACE_LOW
    )
  end
  local top = selection.rule.label
  local ctx = context(
    engine,
    input,
    top,
    engine.compiled_spec.rules_by_label,
    options.diagnostic_sink,
    options.trace,
    options._generated_families,
    options._generated_source_identity
  )
  -- Mirror Perl's public parser wrapper; direct rule handlers bypass this boundary.
  set_live_cursor(ctx, public_parser_start_byte(input))
  local trace_scope
  if options.trace ~= nil then
    trace_scope = trace.enter_trace_scope(
      options.trace,
      "lua_runtime:parse",
      "top_rule=" .. top,
      trace.TRACE_HIGH
    )
  end
  local ok, result = pcall(execute_rule, engine, top, 0, ctx)
  if not ok then
    local sink_failed = getmetatable(result) == ERROR_MT.diagnostic_output_sink_failure
    if not sink_failed and getmetatable(result) == ERROR_MT then
      result = with_runtime_diagnostic(result, runtime_diagnostic(engine, {
        stage = "runtime_execution",
        summary = "Lua runtime interpreter failed",
        detail = result.message,
        top_rule = top,
        rule_label = ctx.rule_stack[#ctx.rule_stack] or top,
      }))
    end
    if trace_scope ~= nil then
      local message
      if sink_failed then
        message = "diagnostic_output_sink"
      elseif M.is_runtime_interpreter_error(result) or M.is_runtime_exit_now(result) then
        message = result.message
      else
        message = tostring(result)
      end
      trace.exit_trace_scope(options.trace, trace_scope, "error=" .. message)
    end
    if sink_failed then error(result.failure, 0) end
    error(result, 0)
  end
  local output = json.array({ copy_value(result.value) })
  local parse_result = setmetatable({
    matched = result.matched,
    value = copy_value(result.value),
    output = output,
    cursor_code_unit = ctx.cursor_byte,
    cursor_char_offset = matching.byte_offset_to_char_offset(input, ctx.cursor_byte),
    lifecycle_events = ctx.lifecycle_events,
  }, RESULT_MT)
  if trace_scope ~= nil then
    trace.exit_trace_scope(
      options.trace,
      trace_scope,
      "matched=" .. tostring(parse_result.matched) .. " cursor=" .. tostring(parse_result.cursor_code_unit)
    )
  end
  return parse_result
end

M.runtime_execute = M.runtime_parse

function M.runtime_parse_with_trace(engine, input, config, options)
  if not trace.is_trace_config(config) then
    fail("runtime_parse_with_trace expects LinkedSpecTraceConfig")
  end
  options = options or {}
  if type(options) ~= "table" then fail("runtime parse options must be a table") end
  local parse_options = {}
  for key, value in pairs(options) do parse_options[key] = value end
  parse_options.trace = trace.trace_emitter(config, { stdout_writer = options.stdout_writer })
  parse_options.stdout_writer = nil
  return M.runtime_parse(engine, input, parse_options)
end

M.runtime_execute_with_trace = M.runtime_parse_with_trace

function M.to_json(value)
  if getmetatable(value) == ERROR_MT then
    return json.harray({
      message = value.message,
      diagnostic = value.diagnostic and M.to_json(value.diagnostic) or nil,
    })
  elseif getmetatable(value) == ERROR_MT.exit_now then
    return json.harray({ status = value.status })
  end
  local node_type = M.node_type(value)
  if node_type == "RuntimeDiagnostic" then
    local diagnostic = json.harray({
      type = value.type,
      stage = value.stage,
      owner_stage = value.owner_stage,
      summary = value.summary,
      detail = value.detail,
      spec_name = value.spec_name,
      spec_path = value.spec_path,
      top_rule = value.top_rule,
      rule_label = value.rule_label,
      handler_source_label = value.handler_source_label,
    })
    for _, name in ipairs({ "code", "entry_rule", "helper_name", "actual_arity", "expected_arity" }) do
      if value[name] ~= nil then diagnostic[name] = value[name] end
    end
    return diagnostic
  elseif node_type == "RuntimeLifecycleEvent" then
    return json.harray({ rule_label = value.rule_label, lifecycle = value.lifecycle, line = value.line })
  elseif node_type == "RuntimeDiagnosticOutputEvent" then
    return json.harray({
      helper_name = value.helper_name,
      rule_label = value.rule_label,
      message = value.message,
    })
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
  fail(
    "runtime to_json expects a runtime error, exit, diagnostic, parse result, lifecycle event, or " ..
      "diagnostic output event"
  )
end

return M
