local action_ast = require("linkedspec.action_ast")
local action_contracts = require("linkedspec.action_contracts")
local action_parser = require("linkedspec.action_parser")
local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local matching = require("linkedspec.matching")
local scalar_numeric = require("linkedspec.scalar_numeric")
local unicode_case = require("linkedspec.unicode_case_mapping")

local M = {}

local ERROR_MT = { __tostring = function(value) return "RuntimeInterpreterException: " .. value.message end }
local FLOW_MT = { __tostring = function(value) return "RuntimeActionFlow: " .. value.kind end }
local ENGINE_MT = { __runtime_interpreter_type = "LinkedSpecRuntimeEngine" }
local RESULT_MT = { __runtime_interpreter_type = "RuntimeParseResult" }
local EVENT_MT = { __runtime_interpreter_type = "RuntimeLifecycleEvent" }
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
  compiled_spec.validate_no_removed_aggregate_selectors(compiled)
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
    helper_regex_cache = {},
  }, ENGINE_MT)
end

local function default_top(engine)
  for _, label in ipairs(engine.compiled_spec.compiled_rule_order) do
    if engine.compiled_spec.rules_by_label[label].header.is_top then return label end
  end
  return engine.compiled_spec.compiled_rule_order[1]
end

local function context(input, top_rule, compiled_rules)
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
    accumulator_stack = {},
    compiled_rules = compiled_rules,
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

local function append_array_binding(ctx, target, value)
  local values, storage = array_binding_for_mutation(ctx, target.name)
  values[#values + 1] = copy_value(value)
  return store_array_mutation(ctx, target, storage, values)
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
  if action_ast.node_type(value) == "ActionExpr" and value.kind == "block_value" then return nil end
  local kind = json.kind(value)
  if kind == "array" or kind == "harray" or type(value) == "table" then
    return null_as_empty and "" or nil
  end
  if type(value) == "boolean" then return value and "1" or "0" end
  if type(value) == "number" then return stable_number_string(value) end
  if type(value) == "string" then return value end
  return nil
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

local function evaluate_call(engine, expr, ctx, accumulator, edge_state)
  local name = action_contracts.canonical_action_helper_name(expr.name)
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
    return copy_value(expr)
  end
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
    elseif storage == nil then
      root = json.harray()
      storage = "harray"
    else
      binding_kind_mismatch(expr.name, "harray", current)
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
    for index, call in ipairs(expr.calls) do
      local call_expr = { kind = "call", name = call.method, args = call.args }
      local canonical_name = action_contracts.canonical_action_helper_name(call.method)
      if ARRAY_END_MUTATIONS[canonical_name] then
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

local function execute_block(engine, block, ctx, accumulator, edge_state)
  for _, statement in ipairs(block.statements) do
    local handled = statement.drops_value and (
      execute_regex_substitution_statement(engine, statement.expr, ctx, accumulator, edge_state) or
      execute_array_split_statement(engine, statement.expr, ctx, accumulator, edge_state) or
      execute_array_transform_statement(engine, statement.expr, ctx, accumulator, edge_state)
    )
    if not handled then
      evaluate_expr(engine, statement.expr, ctx, accumulator, edge_state)
    end
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
  local accumulator = json.array()
  ctx.accumulator_stack[#ctx.accumulator_stack + 1] = { label = label, values = accumulator }
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
  local top = options.top_rule or default_top(engine)
  if not top then fail("compiled spec does not contain any rules") end
  local ctx = context(input, top, engine.compiled_spec.rules_by_label)
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
