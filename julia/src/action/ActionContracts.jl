struct ActionResolvedContract
    source_name::String
    canonical_name::String
    family::String
    surface::String
    source::String
    source_span::ActionSourceSpan
    positional_arg_count::Int
    keyword_arg_count::Int
end

function ActionResolvedContract(;
    source_name,
    canonical_name,
    family,
    surface,
    source,
    source_span,
    positional_arg_count,
    keyword_arg_count = 0,
)
    return ActionResolvedContract(
        String(source_name),
        String(canonical_name),
        String(family),
        String(surface),
        String(source),
        source_span,
        positional_arg_count,
        keyword_arg_count,
    )
end

struct ActionContractDiagnostic
    code::String
    message::String
    source::String
    source_span::ActionSourceSpan
    helper_name::Union{Nothing,String}
end

function ActionContractDiagnostic(; code, message, source, source_span, helper_name = nothing)
    return ActionContractDiagnostic(
        String(code),
        String(message),
        String(source),
        source_span,
        helper_name === nothing ? nothing : String(helper_name),
    )
end

struct ActionContractResolution
    contracts::Vector{ActionResolvedContract}
    diagnostics::Vector{ActionContractDiagnostic}
    ok::Bool
end

function ActionContractResolution(; contracts, diagnostics)
    diagnostic_vec = ActionContractDiagnostic[diagnostics...]
    return ActionContractResolution(
        ActionResolvedContract[contracts...],
        diagnostic_vec,
        isempty(diagnostic_vec),
    )
end

canonicalized(contract::ActionResolvedContract) = contract.source_name != contract.canonical_name

function to_json(resolution::ActionContractResolution)
    return Dict{String,Any}(
        "ok" => resolution.ok,
        "contracts" => [to_json(contract) for contract in resolution.contracts],
        "diagnostics" => [to_json(diagnostic) for diagnostic in resolution.diagnostics],
    )
end

function to_json(contract::ActionResolvedContract)
    result = Dict{String,Any}(
        "source_name" => contract.source_name,
        "canonical_name" => contract.canonical_name,
        "family" => contract.family,
        "surface" => contract.surface,
        "source" => contract.source,
        "source_span" => to_json(contract.source_span),
        "positional_arg_count" => contract.positional_arg_count,
        "keyword_arg_count" => contract.keyword_arg_count,
    )
    if canonicalized(contract)
        result["canonicalized"] = true
    end
    return result
end

function to_json(diagnostic::ActionContractDiagnostic)
    result = Dict{String,Any}(
        "code" => diagnostic.code,
        "message" => diagnostic.message,
        "source" => diagnostic.source,
        "source_span" => to_json(diagnostic.source_span),
    )
    if diagnostic.helper_name !== nothing
        result["helper_name"] = diagnostic.helper_name
    end
    return result
end

function resolve_action_block_contracts(
    block::ActionBlock;
    function_registry = nothing,
    callable_bindings = Set{String}(),
)
    resolver = _ActionContractResolver(function_registry, callable_bindings)
    _visit_block!(resolver, block)
    return _finish(resolver)
end

function resolve_action_statement_contracts(
    statement::ActionStatement;
    function_registry = nothing,
    callable_bindings = Set{String}(),
)
    resolver = _ActionContractResolver(function_registry, callable_bindings)
    _visit_statement!(resolver, statement)
    return _finish(resolver)
end

function resolve_action_expression_contracts(
    expr::ActionExpr;
    function_registry = nothing,
    callable_bindings = Set{String}(),
)
    resolver = _ActionContractResolver(function_registry, callable_bindings)
    _visit_expr!(resolver, expr)
    return _finish(resolver)
end

function canonical_action_helper_name(name::AbstractString)
    value = String(name)
    return get(
        _SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES,
        value,
        get(_NUMERIC_ALIAS_CANONICAL_NAMES, value, get(_CURRENT_ALIAS_CANONICAL_NAMES, value, value)),
    )
end

is_known_action_ir_call_name(name::AbstractString) = String(name) in _KNOWN_ACTION_IR_CALL_NAMES

const COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES = Set{String}([
    "clear_mark",
    "mark_col",
    "mark_entry_end",
    "mark_entry_start",
    "mark_line",
    "mark_match_end",
    "mark_match_start",
])

const _SUPPORTED_ACTION_IR_CALL_NAMES = Set{String}([
    "and",
    "array",
    "call",
    "capture_between",
    "capture_from",
    "capture_len_between",
    "capture_len_from",
    "capture_rest",
    "capture_rest_from",
    "capture_rest_len",
    "capture_rest_len_from",
    "capture_slice",
    "capture_slice_col",
    "capture_slice_len",
    "capture_slice_line",
    "capture_slice_pos",
    "capture_slice_until_cursor",
    "capture_slice_until_cursor_len",
    "capture_until_boundary",
    "capture_take",
    "capture_take_between",
    "capture_take_between_len",
    "capture_take_len",
    "capture_take_len_from",
    "capture_take_rest",
    "capture_take_rest_from",
    "capture_take_rest_len",
    "capture_take_rest_len_from",
    "capture_take_until_cursor",
    "capture_take_until_cursor_from",
    "capture_take_until_cursor_len",
    "capture_take_until_cursor_len_from",
    "capture_until_cursor_from",
    "capture_until_cursor_len_from",
    "case",
    "cat",
    "clear_mark",
    "coalesce",
    "coalesce_nonempty",
    "concat_arrays",
    "contains",
    "contains_substr",
    "copy",
    "count",
    "count_keys",
    "cursor_col",
    "cursor_line",
    "cursor_pos",
    "cursor_rest",
    "cursor_rest_len",
    "default",
    "drop_back",
    "drop_front",
    "drop_keys",
    "else",
    "elseif",
    "endcase",
    "endif",
    "ends_with",
    "endswitch",
    "entry_col",
    "entry_end_col",
    "entry_end_line",
    "entry_end_pos",
    "entry_group",
    "entry_groups",
    "entry_has",
    "entry_len",
    "entry_line",
    "entry_map",
    "entry_named",
    "entry_start_col",
    "entry_start_line",
    "entry_start_pos",
    "entry_text",
    "exit_now",
    "filter_match",
    "filter_nonempty",
    "first",
    "flat",
    "flat_array",
    "flat_hash",
    "has_key",
    "hash",
    "if",
    "index_of",
    "input_end_col",
    "input_end_line",
    "input_end_pos",
    "input_len",
    "input_slice",
    "input_text",
    "is_defined",
    "is_empty",
    "is_nonempty",
    "is_undefined",
    "join_values",
    "last",
    "length",
    "lowercase",
    "lowercase_each",
    "map_leaves",
    "mark_capture_slice",
    "mark_col",
    "mark_copy",
    "mark_entry_end",
    "mark_entry_start",
    "mark_exists",
    "mark_here",
    "mark_input_end",
    "mark_input_start",
    "mark_line",
    "mark_match_end",
    "mark_match_start",
    "mark_pos",
    "match_col",
    "match_end_col",
    "match_end_line",
    "match_end_pos",
    "match_group",
    "match_groups",
    "match_has",
    "match_len",
    "match_line",
    "match_map",
    "match_named",
    "match_start_col",
    "match_start_line",
    "match_start_pos",
    "match_text",
    "matches",
    "merge_hash",
    "next",
    "not",
    "num_abs",
    "num_add",
    "num_avg",
    "num_ceil",
    "num_clamp",
    "num_div",
    "num_eq",
    "num_floor",
    "num_ge",
    "num_gt",
    "num_le",
    "num_lt",
    "num_max",
    "num_median",
    "num_min",
    "num_mod",
    "num_mul",
    "num_ne",
    "num_range",
    "num_round",
    "num_sub",
    "num_sum",
    "or",
    "pick_keys",
    "pop_back",
    "pop_front",
    "print",
    "print_each",
    "push",
    "push_back",
    "push_front",
    "reduce_leaves",
    "rename_key",
    "replace_substr",
    "return",
    "return_undef",
    "restore_cursor",
    "rewind_entry_start",
    "rewind_match_start",
    "reversed",
    "rm_prefix",
    "rm_suffix",
    "say",
    "save_cursor",
    "set",
    "set_key",
    "slice",
    "sorted",
    "sorted_keys",
    "sorted_values",
    "split",
    "split_each",
    "split_tagged_records",
    "start_capture_slice",
    "start_capture_slice_from",
    "starts_with",
    "str_eq",
    "str_ge",
    "str_gt",
    "str_le",
    "str_lt",
    "str_ne",
    "substr",
    "switch",
    "take",
    "take_last",
    "trim",
    "trim_each",
    "uniq",
    "uppercase",
    "uppercase_each",
    "walk_leaves",
    "while",
    "with",
])

const _NUMERIC_ALIAS_ACTION_IR_CALL_NAMES = Set{String}([
    "+",
    "-",
    "*",
    "/",
    "%",
    "==",
    "!=",
    ">",
    ">=",
    "<",
    "<=",
    "abs",
    "add",
    "avg",
    "ceil",
    "clamp",
    "div",
    "eq",
    "floor",
    "ge",
    "gt",
    "le",
    "lt",
    "max",
    "median",
    "min",
    "mod",
    "mul",
    "ne",
    "range",
    "round",
    "sub",
    "sum",
])

const _CURRENT_ALIAS_ACTION_IR_CALL_NAMES = Set{String}([
    "=",
    "elif",
    "i",
    "otherwise",
    "when",
])

const _SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES = Dict{String,String}(
    "capture_from_rule_start" => "capture_slice",
    "capture_len_from_rule_start" => "capture_slice_len",
    "capture_rest_length" => "capture_rest_len",
    "capture_slice_here" => "start_capture_slice",
    "capture_slice_length" => "capture_slice_len",
    "entry_named_map" => "entry_map",
    "match_named_map" => "match_map",
)

const _KNOWN_ACTION_IR_CALL_NAMES = union(
    _SUPPORTED_ACTION_IR_CALL_NAMES,
    COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES,
    _NUMERIC_ALIAS_ACTION_IR_CALL_NAMES,
    _CURRENT_ALIAS_ACTION_IR_CALL_NAMES,
    Set(keys(_SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES)),
)

const _NUMERIC_ALIAS_CANONICAL_NAMES = Dict{String,String}(
    "+" => "num_add",
    "-" => "num_sub",
    "*" => "num_mul",
    "/" => "num_div",
    "%" => "num_mod",
    "==" => "num_eq",
    "!=" => "num_ne",
    ">" => "num_gt",
    ">=" => "num_ge",
    "<" => "num_lt",
    "<=" => "num_le",
    "abs" => "num_abs",
    "add" => "num_add",
    "avg" => "num_avg",
    "ceil" => "num_ceil",
    "clamp" => "num_clamp",
    "div" => "num_div",
    "eq" => "num_eq",
    "floor" => "num_floor",
    "ge" => "num_ge",
    "gt" => "num_gt",
    "le" => "num_le",
    "lt" => "num_lt",
    "max" => "num_max",
    "median" => "num_median",
    "min" => "num_min",
    "mod" => "num_mod",
    "mul" => "num_mul",
    "ne" => "num_ne",
    "range" => "num_range",
    "round" => "num_round",
    "sub" => "num_sub",
    "sum" => "num_sum",
)

const _CURRENT_ALIAS_CANONICAL_NAMES = Dict{String,String}(
    "=" => "set",
    "elif" => "elseif",
    "i" => "if",
    "otherwise" => "else",
    "when" => "if",
)

const _STRING_HELPERS = Set{String}([
    "cat",
    "coalesce",
    "coalesce_nonempty",
    "contains_substr",
    "ends_with",
    "length",
    "lowercase",
    "matches",
    "replace_substr",
    "rm_prefix",
    "rm_suffix",
    "starts_with",
    "substr",
    "trim",
    "uppercase",
])

const _ARRAY_HELPERS = Set{String}([
    "array",
    "concat_arrays",
    "contains",
    "copy",
    "count",
    "drop_back",
    "drop_front",
    "filter_match",
    "filter_nonempty",
    "first",
    "flat",
    "flat_array",
    "index_of",
    "is_empty",
    "is_nonempty",
    "join_values",
    "last",
    "lowercase_each",
    "pop_back",
    "pop_front",
    "push",
    "push_back",
    "push_front",
    "reversed",
    "slice",
    "sorted",
    "split",
    "split_each",
    "split_tagged_records",
    "take",
    "take_last",
    "trim_each",
    "uniq",
    "uppercase_each",
    "walk_leaves",
    "map_leaves",
    "reduce_leaves",
])

const _HASH_HELPERS = Set{String}([
    "copy",
    "count_keys",
    "drop_keys",
    "flat",
    "flat_hash",
    "has_key",
    "hash",
    "merge_hash",
    "pick_keys",
    "rename_key",
    "set_key",
    "sorted_keys",
    "sorted_values",
    "walk_leaves",
    "map_leaves",
    "reduce_leaves",
])

const _CONTROL_HELPERS = Set{String}([
    "and",
    "case",
    "call",
    "default",
    "else",
    "elseif",
    "endcase",
    "endif",
    "endswitch",
    "exit_now",
    "if",
    "next",
    "not",
    "or",
    "return",
    "return_undef",
    "switch",
    "while",
    "with",
])

const _CAPTURE_MARK_HELPERS = Set{String}([
    "capture_between",
    "capture_from",
    "capture_len_between",
    "capture_len_from",
    "capture_rest",
    "capture_rest_from",
    "capture_rest_len",
    "capture_rest_len_from",
    "capture_slice",
    "capture_slice_col",
    "capture_slice_len",
    "capture_slice_line",
    "capture_slice_pos",
    "capture_slice_until_cursor",
    "capture_slice_until_cursor_len",
    "capture_until_boundary",
    "capture_take",
    "capture_take_between",
    "capture_take_between_len",
    "capture_take_len",
    "capture_take_len_from",
    "capture_take_rest",
    "capture_take_rest_from",
    "capture_take_rest_len",
    "capture_take_rest_len_from",
    "capture_take_until_cursor",
    "capture_take_until_cursor_from",
    "capture_take_until_cursor_len",
    "capture_take_until_cursor_len_from",
    "capture_until_cursor_from",
    "capture_until_cursor_len_from",
    "clear_mark",
    "mark_capture_slice",
    "mark_col",
    "mark_copy",
    "mark_entry_end",
    "mark_entry_start",
    "mark_exists",
    "mark_here",
    "mark_input_end",
    "mark_input_start",
    "mark_line",
    "mark_match_end",
    "mark_match_start",
    "mark_pos",
    "start_capture_slice",
    "start_capture_slice_from",
])

const _ENTRY_MATCH_HELPERS = Set{String}([
    "entry_col",
    "entry_end_col",
    "entry_end_line",
    "entry_end_pos",
    "entry_group",
    "entry_groups",
    "entry_has",
    "entry_len",
    "entry_line",
    "entry_map",
    "entry_named",
    "entry_start_col",
    "entry_start_line",
    "entry_start_pos",
    "entry_text",
    "match_col",
    "match_end_col",
    "match_end_line",
    "match_end_pos",
    "match_group",
    "match_groups",
    "match_has",
    "match_len",
    "match_line",
    "match_map",
    "match_named",
    "match_start_col",
    "match_start_line",
    "match_start_pos",
    "match_text",
])

const _INPUT_HELPERS = Set{String}([
    "cursor_col",
    "cursor_line",
    "cursor_pos",
    "cursor_rest",
    "cursor_rest_len",
    "input_end_col",
    "input_end_line",
    "input_end_pos",
    "input_len",
    "input_slice",
    "input_text",
])

const _RUNTIME_HELPERS = Set{String}([
    "restore_cursor",
    "rewind_entry_start",
    "rewind_match_start",
    "save_cursor",
])

const _OUTPUT_HELPERS = Set{String}(["print", "print_each", "say"])

mutable struct _ActionContractResolver
    contracts::Vector{ActionResolvedContract}
    diagnostics::Vector{ActionContractDiagnostic}
    function_registry::Union{Nothing,UserFunctionRegistry}
    callable_bindings::Set{String}
end

_ActionContractResolver(function_registry = nothing, callable_bindings = Set{String}()) = _ActionContractResolver(
    ActionResolvedContract[],
    ActionContractDiagnostic[],
    function_registry,
    Set{String}(String(name) for name in callable_bindings),
)

function _finish(resolver::_ActionContractResolver)
    return ActionContractResolution(contracts = resolver.contracts, diagnostics = resolver.diagnostics)
end

function _visit_block!(resolver::_ActionContractResolver, block::ActionBlock)
    for statement in block.statements
        _visit_statement!(resolver, statement)
    end
    return nothing
end

function _visit_statement!(resolver::_ActionContractResolver, statement::ActionStatement)
    _visit_expr!(resolver, statement.expr)
    return nothing
end

function _visit_expr!(resolver::_ActionContractResolver, expr::ActionExpr)
    if expr isa ActionCallExpr
        _resolve_helper_call!(
            resolver;
            name = expr.name,
            source = expr.source,
            source_span = expr.source_span,
            surface = "function",
            args = expr.args,
        )
        _visit_args!(resolver, expr.args)
    elseif expr isa ActionRecognitionCheckpointExpr ||
           expr isa ActionRecognizeOnceExpr ||
           expr isa ActionObserveRecognitionExpr ||
           expr isa ActionRecognitionCommitExpr ||
           expr isa ActionRecognitionRollbackExpr
        # Grammar-owned recognition intrinsics are dedicated ActionIR nodes,
        # not entries in the ordinary callable-helper registry.
        return nothing
    elseif expr isa ActionFluentChainExpr
        _visit_expr!(resolver, expr.receiver)
        for call in expr.calls
            _resolve_helper_call!(
                resolver;
                name = call.method,
                source = call.source,
                source_span = call.source_span,
                surface = "receiver_method",
                args = call.args,
            )
            _visit_args!(resolver, call.args)
        end
    elseif expr isa ActionAssignScalarExpr
        _record_structural_contract!(
            resolver;
            source_name = "=",
            canonical_name = "set",
            family = "assignment",
            surface = "assignment",
            source = expr.source,
            source_span = expr.source_span,
            positional_arg_count = 2,
        )
        _visit_expr!(resolver, expr.value)
    elseif expr isa ActionAssignArrayAppendExpr
        _record_structural_contract!(
            resolver;
            source_name = "+=",
            canonical_name = "push",
            family = "array",
            surface = "assignment",
            source = expr.source,
            source_span = expr.source_span,
            positional_arg_count = 2,
        )
        _visit_expr!(resolver, expr.value)
    elseif expr isa ActionAssignHashIndexExpr
        _record_structural_contract!(
            resolver;
            source_name = "[]=",
            canonical_name = "set_key",
            family = "hash",
            surface = "assignment",
            source = expr.source,
            source_span = expr.source_span,
            positional_arg_count = 3,
        )
        _visit_expr!(resolver, expr.key)
        _visit_expr!(resolver, expr.value)
    elseif expr isa ActionAssignNestedAccessExpr
        _record_structural_contract!(
            resolver;
            source_name = "nested_access=",
            canonical_name = "nested_access_assignment",
            family = "assignment",
            surface = "assignment",
            source = expr.source,
            source_span = expr.source_span,
            positional_arg_count = 2,
        )
        _visit_access_segments!(resolver, expr.segments)
        _visit_expr!(resolver, expr.value)
    elseif expr isa ActionBlockValueExpr
        _visit_block!(resolver, expr.block)
    elseif expr isa ActionCodeblockLiteralExpr || expr isa ActionCodeblockArgumentExpr
        # A callable body is deferred state and has no eager dependencies.
        nothing
    elseif expr isa ActionCodeblockLiteralErrorExpr
        push!(
            resolver.diagnostics,
            ActionContractDiagnostic(
                code = expr.code,
                message = "invalid callable-codeblock literal: $(expr.code)",
                source = expr.source,
                source_span = expr.source_span,
            ),
        )
    elseif expr isa ActionArrayLiteralExpr
        for item in expr.items
            _visit_expr!(resolver, item)
        end
    elseif expr isa ActionHashLiteralExpr
        for entry in expr.entries
            _visit_expr!(resolver, entry.key)
            _visit_expr!(resolver, entry.value)
        end
    elseif expr isa ActionIndexedVarExpr
        _visit_expr!(resolver, expr.index)
    elseif expr isa ActionNestedAccessExpr
        _visit_access_segments!(resolver, expr.segments)
    elseif expr isa ActionValueAccessExpr
        _visit_expr!(resolver, expr.receiver)
        _visit_access_segments!(resolver, expr.segments)
    elseif expr isa ActionControlIfExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
        if expr.body !== nothing
            _visit_block!(resolver, expr.body)
        end
    elseif expr isa ActionControlElseExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
        if expr.body !== nothing
            _visit_block!(resolver, expr.body)
        end
    elseif expr isa ActionControlMarkerExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
    elseif expr isa ActionControlWhileExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
        if expr.body !== nothing
            _visit_block!(resolver, expr.body)
        end
    elseif expr isa ActionControlSwitchExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
        if !isempty(expr.cases) || expr.default_case !== nothing
            for item in expr.cases
                _visit_expr!(resolver, item)
            end
            if expr.default_case !== nothing
                _visit_expr!(resolver, expr.default_case)
            end
        elseif expr.body !== nothing
            _visit_block!(resolver, expr.body)
        end
    elseif expr isa ActionControlCaseExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
        if expr.body !== nothing
            _visit_block!(resolver, expr.body)
        end
    elseif expr isa ActionControlDefaultExpr
        _record_control_contract!(resolver, expr.keyword, expr.canonical_keyword, expr.source, expr.source_span, expr.args)
        _visit_args!(resolver, expr.args)
        if expr.body !== nothing
            _visit_block!(resolver, expr.body)
        end
    elseif expr isa ActionRawExpr
        push!(
            resolver.diagnostics,
            ActionContractDiagnostic(
                code = "raw_perl",
                message = "unsupported ActionIR expression remains raw_perl: $(expr.reason)",
                source = expr.source,
                source_span = expr.source_span,
            ),
        )
    end
    return nothing
end

function _resolve_helper_call!(
    resolver::_ActionContractResolver;
    name,
    source,
    source_span,
    surface,
    args,
)
    positional_arg_count = _positional_arg_count(args)
    keyword_arg_count = _keyword_arg_count(args)
    arg_count = positional_arg_count + keyword_arg_count
    if surface == "function" && resolver.function_registry !== nothing
        if has_user_function_name(resolver.function_registry, name) && keyword_arg_count > 0
            push!(
                resolver.diagnostics,
                ActionContractDiagnostic(
                    code = "user_function_keyword_arguments_unsupported",
                    message = "user function '$name' accepts positional arguments only, got $keyword_arg_count keyword argument(s)",
                    helper_name = name,
                    source = source,
                    source_span = source_span,
                ),
            )
            return nothing
        end
        user_resolution = resolve_user_function_call(resolver.function_registry, name, positional_arg_count)
        if user_resolution.matched
            push!(
                resolver.contracts,
                ActionResolvedContract(
                    source_name = name,
                    canonical_name = name,
                    family = "user_function",
                    surface = surface,
                    source = source,
                    source_span = source_span,
                    positional_arg_count = positional_arg_count,
                    keyword_arg_count = keyword_arg_count,
                ),
            )
            return nothing
        elseif user_resolution.arity_mismatch
            entry = lookup_user_function(resolver.function_registry, name)
            expected = user_function_arity_expectation(entry)
            push!(
                resolver.diagnostics,
                ActionContractDiagnostic(
                    code = "user_function_arity_mismatch",
                    message = "user function '$name' expects arity $expected, got $positional_arg_count",
                    helper_name = name,
                    source = source,
                    source_span = source_span,
                ),
            )
            return nothing
        end
    end
    if surface == "function" && String(name) in resolver.callable_bindings
        push!(
            resolver.contracts,
            ActionResolvedContract(
                source_name = name,
                canonical_name = name,
                family = "codeblock",
                surface = surface,
                source = source,
                source_span = source_span,
                positional_arg_count = positional_arg_count,
                keyword_arg_count = keyword_arg_count,
            ),
        )
        return nothing
    end
    if !is_known_action_ir_call_name(name)
        push!(
            resolver.diagnostics,
            ActionContractDiagnostic(
                code = "unknown_helper",
                message = "unknown helper '$name' is not part of the canonical ActionIR helper contract",
                helper_name = name,
                source = source,
                source_span = source_span,
            ),
        )
        return nothing
    end
    canonical_name = canonical_action_helper_name(name)
    push!(
        resolver.contracts,
        ActionResolvedContract(
            source_name = name,
            canonical_name = canonical_name,
            family = _family_for_canonical(canonical_name),
            surface = surface,
            source = source,
            source_span = source_span,
            positional_arg_count = positional_arg_count,
            keyword_arg_count = keyword_arg_count,
        ),
    )
    return nothing
end

function _record_control_contract!(
    resolver::_ActionContractResolver,
    source_name::String,
    canonical_name::String,
    source::String,
    source_span::ActionSourceSpan,
    args::Vector{ActionArgument},
)
    _record_structural_contract!(
        resolver;
        source_name = source_name,
        canonical_name = canonical_name,
        family = "control",
        surface = "control",
        source = source,
        source_span = source_span,
        positional_arg_count = _positional_arg_count(args),
        keyword_arg_count = _keyword_arg_count(args),
    )
    return nothing
end

function _record_structural_contract!(
    resolver::_ActionContractResolver;
    source_name,
    canonical_name,
    family,
    surface,
    source,
    source_span,
    positional_arg_count,
    keyword_arg_count = 0,
)
    push!(
        resolver.contracts,
        ActionResolvedContract(
            source_name = source_name,
            canonical_name = canonical_name,
            family = family,
            surface = surface,
            source = source,
            source_span = source_span,
            positional_arg_count = positional_arg_count,
            keyword_arg_count = keyword_arg_count,
        ),
    )
    return nothing
end

function _visit_args!(resolver::_ActionContractResolver, args::Vector{ActionArgument})
    for arg in args
        _visit_expr!(resolver, arg.value)
    end
    return nothing
end

function _visit_access_segments!(resolver::_ActionContractResolver, segments::Vector{ActionAccessSegment})
    for segment in segments
        if segment isa ActionIndexAccessSegment
            _visit_expr!(resolver, segment.expr)
        end
    end
    return nothing
end

function _positional_arg_count(args::Vector{ActionArgument})
    return count(arg -> arg isa ActionPositionalArgument, args)
end

function _keyword_arg_count(args::Vector{ActionArgument})
    return count(arg -> arg isa ActionKeywordArgument, args)
end

function _family_for_canonical(canonical_name::AbstractString)
    value = String(canonical_name)
    if startswith(value, "num_")
        return "numeric"
    elseif startswith(value, "str_")
        return "string"
    elseif value in _CONTROL_HELPERS
        return "control"
    elseif value in _CAPTURE_MARK_HELPERS
        return "capture_mark"
    elseif value in _ENTRY_MATCH_HELPERS
        return "entry_match"
    elseif value in _INPUT_HELPERS
        return "input_cursor"
    elseif value in _STRING_HELPERS
        return "string"
    elseif value in _ARRAY_HELPERS && value in _HASH_HELPERS
        return "container"
    elseif value in _ARRAY_HELPERS
        return "array"
    elseif value in _HASH_HELPERS
        return "hash"
    elseif value in _OUTPUT_HELPERS
        return "output"
    elseif value in _RUNTIME_HELPERS
        return "runtime"
    elseif value == "set"
        return "assignment"
    end
    return "helper"
end
