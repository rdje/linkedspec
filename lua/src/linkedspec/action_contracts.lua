local action_ast = require("linkedspec.action_ast")
local action_call_names = require("linkedspec.action_call_names")
local json = require("linkedspec.json")

local M = {}

local NODE_MTS = {}

local function node(node_type, fields)
  local metatable = NODE_MTS[node_type]
  if not metatable then
    metatable = { __action_contract_type = node_type }
    NODE_MTS[node_type] = metatable
  end
  return setmetatable(fields, metatable)
end

function M.node_type(value)
  if type(value) ~= "table" then
    return nil
  end
  local metatable = getmetatable(value)
  return metatable and metatable.__action_contract_type or nil
end

local function make_set(values)
  local result = {}
  for _, value in ipairs(values) do
    result[value] = true
  end
  return result
end

local ALIAS_CANONICAL_NAMES = {
  ["+"] = "num_add",
  ["-"] = "num_sub",
  ["*"] = "num_mul",
  ["/"] = "num_div",
  ["%"] = "num_mod",
  ["="] = "set",
  ["=="] = "num_eq",
  ["!="] = "num_ne",
  [">"] = "num_gt",
  [">="] = "num_ge",
  ["<"] = "num_lt",
  ["<="] = "num_le",
  abs = "num_abs",
  add = "num_add",
  avg = "num_avg",
  ceil = "num_ceil",
  clamp = "num_clamp",
  div = "num_div",
  eq = "num_eq",
  floor = "num_floor",
  ge = "num_ge",
  gt = "num_gt",
  le = "num_le",
  lt = "num_lt",
  max = "num_max",
  median = "num_median",
  min = "num_min",
  mod = "num_mod",
  mul = "num_mul",
  ne = "num_ne",
  range = "num_range",
  round = "num_round",
  sub = "num_sub",
  sum = "num_sum",
  elif = "elseif",
  i = "if",
  otherwise = "else",
  when = "if",
}

local SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES = {
  ["capture_from_rule_start"] = "capture_slice",
  ["capture_len_from_rule_start"] = "capture_slice_len",
  ["capture_rest_length"] = "capture_rest_len",
  ["capture_slice_here"] = "start_capture_slice",
  ["capture_slice_length"] = "capture_slice_len",
  ["entry_named_map"] = "entry_map",
  ["match_named_map"] = "match_map",
}

local STRING_HELPERS = make_set({
  "cat", "coalesce", "coalesce_nonempty", "contains_substr", "ends_with", "length", "lowercase",
  "matches", "replace_substr", "rm_prefix", "rm_suffix", "starts_with", "substr", "trim", "uppercase",
})

local ARRAY_HELPERS = make_set({
  "array", "concat_arrays", "contains", "copy", "count", "drop_back", "drop_front", "filter_match",
  "filter_nonempty", "first", "flat", "flat_array", "index_of", "is_empty", "is_nonempty", "join_values",
  "last", "lowercase_each", "pop_back", "pop_front", "push", "push_back", "push_front", "reversed", "slice",
  "sorted", "split", "split_each", "split_tagged_records", "take", "take_last", "trim_each", "uniq",
  "uppercase_each", "walk_leaves", "map_leaves", "reduce_leaves",
})

local HASH_HELPERS = make_set({
  "copy", "count_keys", "drop_keys", "flat", "flat_hash", "has_key", "hash", "merge_hash", "pick_keys",
  "rename_key", "set_key", "sorted_keys", "sorted_values", "walk_leaves", "map_leaves", "reduce_leaves",
})

local CONTROL_HELPERS = make_set({
  "and", "call", "case", "default", "else", "elseif", "endcase", "endif", "endswitch", "exit_now", "if",
  "next", "not", "or", "return", "return_undef", "switch", "while", "with",
})

local CAPTURE_MARK_HELPERS = make_set({
  "capture_between", "capture_from", "capture_len_between", "capture_len_from", "capture_rest",
  "capture_rest_from", "capture_rest_len", "capture_rest_len_from", "capture_slice", "capture_slice_col",
  "capture_slice_len", "capture_slice_line", "capture_slice_pos", "capture_slice_until_cursor",
  "capture_slice_until_cursor_len", "capture_until_boundary", "capture_take", "capture_take_between",
  "capture_take_between_len", "capture_take_len", "capture_take_len_from", "capture_take_rest",
  "capture_take_rest_from", "capture_take_rest_len", "capture_take_rest_len_from", "capture_take_until_cursor",
  "capture_take_until_cursor_from", "capture_take_until_cursor_len", "capture_take_until_cursor_len_from",
  "capture_until_cursor_from", "capture_until_cursor_len_from", "mark_capture_slice", "mark_copy", "mark_exists",
  "mark_here", "mark_input_end", "mark_input_start", "mark_pos", "start_capture_slice",
  "start_capture_slice_from", "clear_mark", "mark_col", "mark_entry_end", "mark_entry_start", "mark_line",
  "mark_match_end", "mark_match_start",
})

local ENTRY_MATCH_HELPERS = make_set({
  "entry_col", "entry_end_col", "entry_end_line", "entry_end_pos", "entry_group", "entry_groups", "entry_has",
  "entry_len", "entry_line", "entry_map", "entry_named", "entry_start_col", "entry_start_line", "entry_start_pos",
  "entry_text", "match_col", "match_end_col", "match_end_line", "match_end_pos", "match_group", "match_groups",
  "match_has", "match_len", "match_line", "match_map", "match_named", "match_start_col", "match_start_line",
  "match_start_pos", "match_text",
})

local INPUT_HELPERS = make_set({
  "cursor_col", "cursor_line", "cursor_pos", "cursor_rest", "cursor_rest_len", "input_end_col", "input_end_line",
  "input_end_pos", "input_len", "input_slice", "input_text",
})

local RUNTIME_HELPERS = make_set({
  "restore_cursor", "rewind_entry_start", "rewind_match_start", "save_cursor",
})

local OUTPUT_HELPERS = make_set({ "print", "print_each", "say" })

local BUILTIN_FINAL_CODEBLOCK_CONTRACTS = {
  helper = {
    with = { min_before_codeblock = 0, max_before_codeblock = 1 },
  },
  receiver = {
    with = { min_before_codeblock = 0, max_before_codeblock = 0 },
    walk_leaves = { min_before_codeblock = 0, max_before_codeblock = 0 },
    map_leaves = { min_before_codeblock = 0, max_before_codeblock = 0 },
    reduce_leaves = { min_before_codeblock = 1, max_before_codeblock = 1 },
  },
}

local function clone_final_codeblock_contract(contract)
  if contract == nil then return nil end
  return {
    min_before_codeblock = contract.min_before_codeblock,
    max_before_codeblock = contract.max_before_codeblock,
    final_parameter = { name = "callback", kind = "codeblock" },
  }
end

function M.builtin_final_codeblock_contract(surface, name)
  local contracts = BUILTIN_FINAL_CODEBLOCK_CONTRACTS[surface]
  if contracts == nil then return nil end
  return clone_final_codeblock_contract(contracts[name])
end

function M.user_function_final_codeblock_contract(definition)
  if type(definition) ~= "table" or type(definition.params) ~= "table" or
      type(definition.arity) ~= "number" or definition.arity ~= #definition.params or
      definition.arity == 0 or definition.signature ~= nil then
    return nil
  end
  local final_name = definition.params[#definition.params]
  local kinds = definition.parameter_kinds
  if json.kind(kinds) ~= "harray" or kinds[final_name] ~= "codeblock" then return nil end
  local count = 0
  for name, kind in pairs(kinds) do
    count = count + 1
    if name ~= final_name or kind ~= "codeblock" then return nil end
  end
  if count ~= 1 then return nil end
  return {
    min_before_codeblock = definition.arity - 1,
    max_before_codeblock = definition.arity - 1,
    final_parameter = { name = final_name, kind = "codeblock" },
  }
end

local function contextual_contract(surface, name, function_registry)
  local builtin_surface = surface == "function" and "helper" or surface
  local builtin = M.builtin_final_codeblock_contract(builtin_surface, name)
  if builtin ~= nil then return builtin end
  if surface ~= "function" or function_registry == nil then return nil end
  if type(function_registry) ~= "table" or type(function_registry.lookup) ~= "function" then return nil end
  local item = function_registry:lookup(name)
  return item and M.user_function_final_codeblock_contract(item.definition) or nil
end

local function copy_call_fields(call, excluded)
  local result = {}
  for key, value in pairs(call) do
    if not excluded[key] then result[key] = value end
  end
  return result
end

function M.normalize_contextual_codeblock_call(surface, call, function_registry)
  if surface ~= "function" and surface ~= "receiver" then
    error("ActionContractException: contextual codeblock surface must be function or receiver", 0)
  end
  local node_type = action_ast.node_type(call)
  local name
  if surface == "function" and node_type == "ActionExpr" and call.kind == "call" then
    name = call.name
  elseif surface == "receiver" and node_type == "ActionFluentCall" then
    name = call.method
  else
    error("ActionContractException: contextual codeblock normalization received the wrong call node", 0)
  end
  local contract = contextual_contract(surface, name, function_registry)
  if contract == nil or type(call.args) ~= "table" or #call.args == 0 then
    return call, contract
  end
  local final_argument = call.args[#call.args]
  local final_value = final_argument and final_argument.value
  if action_ast.node_type(final_value) ~= "ActionExpr" or final_value.kind ~= "block_value" then
    return call, contract
  end
  if not M.accepts_final_codeblock_argument_count(contract, #call.args - 1) then
    return call, contract
  end
  local args = {}
  for index, argument in ipairs(call.args) do args[index] = argument end
  args[#args] = action_ast.positional_argument(action_ast.contextual_codeblock_argument(final_value))
  local fields
  local normalized
  if surface == "function" then
    fields = copy_call_fields(call, { kind = true, source = true, source_span = true, name = true, args = true })
    fields.name = call.name
    fields.args = args
    fields.trailing_block_arg = true
    fields.contextual_codeblock_arg = true
    normalized = action_ast.expr("call", call.source, call.source_span, fields)
  else
    fields = copy_call_fields(call, { source = true, source_span = true, method = true, args = true })
    fields.trailing_block_arg = true
    fields.receiver_trailing_block_arg = true
    fields.contextual_codeblock_arg = true
    normalized = action_ast.fluent_call(call.method, args, call.source, call.source_span, fields)
  end
  return normalized, contract
end

function M.accepts_final_codeblock_argument_count(contract, before_count)
  return type(contract) == "table" and
    type(contract.final_parameter) == "table" and contract.final_parameter.kind == "codeblock" and
    type(contract.min_before_codeblock) == "number" and contract.min_before_codeblock % 1 == 0 and
    type(contract.max_before_codeblock) == "number" and contract.max_before_codeblock % 1 == 0 and
    type(before_count) == "number" and before_count % 1 == 0 and
    before_count >= contract.min_before_codeblock and before_count <= contract.max_before_codeblock
end

function M.canonical_action_helper_name(name)
  if type(name) ~= "string" then
    error("ActionContractException: helper name must be a string", 0)
  end
  return SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES[name] or
    ALIAS_CANONICAL_NAMES[name] or name
end

function M.is_known_action_ir_call_name(name)
  return type(name) == "string" and action_call_names.is_known(name)
end

local function family_for_canonical(name)
  if name:sub(1, 4) == "num_" then
    return "numeric"
  elseif name:sub(1, 4) == "str_" then
    return "string"
  elseif CONTROL_HELPERS[name] then
    return "control"
  elseif CAPTURE_MARK_HELPERS[name] then
    return "capture_mark"
  elseif ENTRY_MATCH_HELPERS[name] then
    return "entry_match"
  elseif INPUT_HELPERS[name] then
    return "input_cursor"
  elseif STRING_HELPERS[name] then
    return "string"
  elseif ARRAY_HELPERS[name] and HASH_HELPERS[name] then
    return "container"
  elseif ARRAY_HELPERS[name] then
    return "array"
  elseif HASH_HELPERS[name] then
    return "hash"
  elseif OUTPUT_HELPERS[name] then
    return "output"
  elseif RUNTIME_HELPERS[name] then
    return "runtime"
  elseif name == "set" then
    return "assignment"
  end
  return "helper"
end

local function resolved_contract(fields)
  fields.keyword_arg_count = fields.keyword_arg_count or 0
  return node("ActionResolvedContract", fields)
end

local function diagnostic(fields)
  return node("ActionContractDiagnostic", fields)
end

local function finish(contracts, diagnostics)
  return node("ActionContractResolution", {
    contracts = contracts,
    diagnostics = diagnostics,
    ok = #diagnostics == 0,
  })
end

function M.canonicalized(contract)
  if M.node_type(contract) ~= "ActionResolvedContract" then
    error("ActionContractException: canonicalized expects ActionResolvedContract", 0)
  end
  return contract.source_name ~= contract.canonical_name
end

local function positional_arg_count(args)
  local count = 0
  for _, arg in ipairs(args) do
    if arg.argument_kind == "positional" then
      count = count + 1
    end
  end
  return count
end

local function keyword_arg_count(args)
  local count = 0
  for _, arg in ipairs(args) do
    if arg.argument_kind == "keyword" then
      count = count + 1
    end
  end
  return count
end

local function resolver(function_registry)
  local contracts = {}
  local diagnostics = {}
  local visit_expr
  local visit_block

  local function record(fields)
    contracts[#contracts + 1] = resolved_contract(fields)
  end

  local function record_structural(expr, source_name, canonical_name, family, surface, positional_count, keyword_count)
    record({
      source_name = source_name,
      canonical_name = canonical_name,
      family = family,
      surface = surface,
      source = expr.source,
      source_span = expr.source_span,
      positional_arg_count = positional_count,
      keyword_arg_count = keyword_count or 0,
    })
  end

  local function visit_args(args)
    for _, arg in ipairs(args) do
      visit_expr(arg.value)
    end
  end

  local function visit_access_segments(segments)
    for _, segment in ipairs(segments) do
      if segment.kind == "index" then
        visit_expr(segment.expr)
      elseif segment.kind == "path_segment" then
        visit_expr(segment.expression)
      end
    end
  end

  local function resolve_user_call(name, arg_count)
    if not function_registry then
      return nil
    end
    if type(function_registry) ~= "table" or type(function_registry.resolve_call) ~= "function" then
      error("ActionContractException: function_registry must expose resolve_call(name, arity)", 0)
    end
    local result = function_registry:resolve_call(name, arg_count)
    if result ~= nil and type(result) ~= "table" then
      error("ActionContractException: function_registry resolve_call must return a table or nil", 0)
    end
    return result
  end

  local function resolve_call(name, source, source_span, surface, args)
    local positional_count = positional_arg_count(args)
    local keyword_count = keyword_arg_count(args)
    if surface == "function" then
      local user_resolution = resolve_user_call(name, positional_count)
      local user_name_known = user_resolution and (
        user_resolution.name_known or user_resolution.matched or user_resolution.arity_mismatch
      )
      if user_name_known and keyword_count > 0 then
        diagnostics[#diagnostics + 1] = diagnostic({
          code = "user_function_keyword_arguments_unsupported",
          message = "user function '" .. name .. "' accepts positional arguments only, got " ..
            keyword_count .. " keyword argument(s)",
          helper_name = name,
          source = source,
          source_span = source_span,
        })
        return
      elseif user_resolution and user_resolution.matched then
        record({
          source_name = name,
          canonical_name = name,
          family = "user_function",
          surface = surface,
          source = source,
          source_span = source_span,
          positional_arg_count = positional_count,
          keyword_arg_count = keyword_count,
        })
        return
      elseif user_resolution and user_resolution.arity_mismatch then
        local expected = user_resolution.expected_arity_descriptions or
          user_resolution.expected_arities or {}
        diagnostics[#diagnostics + 1] = diagnostic({
          code = "user_function_arity_mismatch",
          message = "user function '" .. name .. "' expects arity " .. table.concat(expected, " or ") ..
            ", got " .. positional_count,
          helper_name = name,
          source = source,
          source_span = source_span,
        })
        return
      end
    end

    if not M.is_known_action_ir_call_name(name) then
      diagnostics[#diagnostics + 1] = diagnostic({
        code = "unknown_helper",
        message = "unknown helper '" .. name .. "' is not part of the canonical ActionIR helper contract",
        helper_name = name,
        source = source,
        source_span = source_span,
      })
      return
    end

    local canonical_name = M.canonical_action_helper_name(name)
    record({
      source_name = name,
      canonical_name = canonical_name,
      family = family_for_canonical(canonical_name),
      surface = surface,
      source = source,
      source_span = source_span,
      positional_arg_count = positional_count,
      keyword_arg_count = keyword_count,
    })
  end

  local function visit_control(expr)
    local args = expr.args or {}
    record_structural(
      expr,
      expr.keyword,
      expr.canonical_keyword,
      "control",
      "control",
      positional_arg_count(args),
      keyword_arg_count(args)
    )
    visit_args(args)
  end

  visit_block = function(block)
    for _, statement in ipairs(block.statements) do
      visit_expr(statement.expr)
    end
  end

  visit_expr = function(expr)
    local kind = expr.kind
    if kind == "call" then
      local normalized = M.normalize_contextual_codeblock_call("function", expr, function_registry)
      resolve_call(normalized.name, normalized.source, normalized.source_span, "function", normalized.args)
      visit_args(normalized.args)
    elseif kind == "recognition_checkpoint" or kind == "recognize_once" or
        kind == "observe_recognition" or
        kind == "recognition_commit" or kind == "recognition_rollback" or
        kind == "progressive_dispatch_span" or kind == "staged_parse_job_marker" then
      -- Grammar-owned recognition intrinsics are dedicated ActionIR nodes,
      -- and staged/progressive dispatch declarations are dedicated logical
      -- nodes, not entries in the ordinary callable-helper registry.
      return
    elseif kind == "fluent_chain" then
      visit_expr(expr.receiver)
      for _, call in ipairs(expr.calls) do
        local normalized = M.normalize_contextual_codeblock_call("receiver", call, function_registry)
        resolve_call(normalized.method, normalized.source, normalized.source_span, "receiver_method", normalized.args)
        visit_args(normalized.args)
      end
    elseif kind == "receiver_mutation_chain" then
      local mutation = expr.mutation
      local mutation_args = { action_ast.positional_argument(mutation.callback) }
      resolve_call(
        mutation.method,
        mutation.source,
        mutation.source_span,
        "receiver_method",
        mutation_args
      )
      visit_expr(mutation.callback)
      for _, call in ipairs(expr.continuation or {}) do
        local ordinary_call = action_ast.fluent_call(
          call.method,
          call.args,
          call.source,
          call.source_span,
          {
            source_method = call.source_method,
            args_source = call.args_source,
            args_span = call.args_span,
          }
        )
        local normalized = M.normalize_contextual_codeblock_call("receiver", ordinary_call, function_registry)
        resolve_call(normalized.method, normalized.source, normalized.source_span, "receiver_method", normalized.args)
        visit_args(normalized.args)
      end
    elseif kind == "assign_scalar" then
      record_structural(expr, "=", "set", "assignment", "assignment", 2)
      visit_expr(expr.value)
    elseif kind == "assign_array_append" then
      record_structural(expr, "+=", "push", "array", "assignment", 2)
      visit_expr(expr.value)
    elseif kind == "assign_hash_index" then
      record_structural(expr, "[]=", "set_key", "hash", "assignment", 3)
      visit_expr(expr.key)
      visit_expr(expr.value)
    elseif kind == "assign_nested_access" then
      record_structural(expr, "nested_access=", "nested_access_assignment", "assignment", "assignment", 2)
      visit_access_segments(expr.segments)
      visit_expr(expr.value)
    elseif kind == "codeblock_literal" then
      return
    elseif kind == "codeblock_literal_error" then
      diagnostics[#diagnostics + 1] = diagnostic({
        code = expr.code,
        message = "invalid callable-codeblock literal: " .. expr.code,
        source = expr.source,
        source_span = expr.source_span,
      })
    elseif kind == "block_value" or kind == "codeblock_argument" then
      visit_block(expr.block or expr.body)
    elseif kind == "array_literal" then
      for _, item in ipairs(expr.items) do visit_expr(item) end
    elseif kind == "hash_literal" then
      for _, entry in ipairs(expr.entries) do
        visit_expr(entry.key)
        visit_expr(entry.value)
      end
    elseif kind == "indexed_var" then
      visit_expr(expr.index)
    elseif kind == "nested_access" then
      visit_access_segments(expr.segments)
    elseif kind == "value_access" then
      visit_expr(expr.receiver)
      visit_access_segments(expr.segments)
    elseif kind == "control_switch" then
      visit_control(expr)
      if #expr.cases > 0 or expr.default then
        for _, case_expr in ipairs(expr.cases) do visit_expr(case_expr) end
        if expr.default then visit_expr(expr.default) end
      elseif expr.body then
        visit_block(expr.body)
      end
    elseif kind:sub(1, 8) == "control_" then
      visit_control(expr)
      if expr.body then visit_block(expr.body) end
    elseif kind == "raw_perl" then
      diagnostics[#diagnostics + 1] = diagnostic({
        code = "raw_perl",
        message = "unsupported ActionIR expression remains raw_perl: " .. expr.reason,
        source = expr.source,
        source_span = expr.source_span,
      })
    end
  end

  return {
    visit_block = visit_block,
    visit_statement = function(statement) visit_expr(statement.expr) end,
    visit_expression = visit_expr,
    finish = function() return finish(contracts, diagnostics) end,
  }
end

local function function_registry_from_options(options)
  if options == nil then
    return nil
  end
  if type(options) ~= "table" then
    error("ActionContractException: options must be a table", 0)
  end
  return options.function_registry
end

function M.resolve_action_block_contracts(block, options)
  if action_ast.node_type(block) ~= "ActionBlock" then
    error("ActionContractException: resolve_action_block_contracts expects ActionBlock", 0)
  end
  local visitor = resolver(function_registry_from_options(options))
  visitor.visit_block(block)
  return visitor.finish()
end

function M.resolve_action_statement_contracts(statement, options)
  if action_ast.node_type(statement) ~= "ActionStatement" then
    error("ActionContractException: resolve_action_statement_contracts expects ActionStatement", 0)
  end
  local visitor = resolver(function_registry_from_options(options))
  visitor.visit_statement(statement)
  return visitor.finish()
end

function M.resolve_action_expression_contracts(expr, options)
  if action_ast.node_type(expr) ~= "ActionExpr" then
    error("ActionContractException: resolve_action_expression_contracts expects ActionExpr", 0)
  end
  local visitor = resolver(function_registry_from_options(options))
  visitor.visit_expression(expr)
  return visitor.finish()
end

local function span_to_json(value)
  return action_ast.to_json(value)
end

local function contract_to_json(value)
  local result = json.harray({
    source_name = value.source_name,
    canonical_name = value.canonical_name,
    family = value.family,
    surface = value.surface,
    source = value.source,
    source_span = span_to_json(value.source_span),
    positional_arg_count = value.positional_arg_count,
    keyword_arg_count = value.keyword_arg_count,
  })
  if M.canonicalized(value) then
    result.canonicalized = true
  end
  return result
end

local function diagnostic_to_json(value)
  local result = json.harray({
    code = value.code,
    message = value.message,
    source = value.source,
    source_span = span_to_json(value.source_span),
  })
  if value.helper_name then
    result.helper_name = value.helper_name
  end
  return result
end

function M.to_json(value)
  local node_type = M.node_type(value)
  if node_type == "ActionContractResolution" then
    local contracts = json.array()
    for index, contract in ipairs(value.contracts) do
      contracts[index] = contract_to_json(contract)
    end
    local diagnostics = json.array()
    for index, item in ipairs(value.diagnostics) do
      diagnostics[index] = diagnostic_to_json(item)
    end
    return json.harray({ ok = value.ok, contracts = contracts, diagnostics = diagnostics })
  elseif node_type == "ActionResolvedContract" then
    return contract_to_json(value)
  elseif node_type == "ActionContractDiagnostic" then
    return diagnostic_to_json(value)
  end
  error("ActionContractException: to_json expects an action contract value", 0)
end

return M
