struct ActionSourceSpan
    start::Int
    stop::Int
end

abstract type ActionNode end
abstract type ActionExpr <: ActionNode end
abstract type ActionArgument end
abstract type ActionAccessSegment end

struct ActionStatement <: ActionNode
    kind::String
    source::String
    source_span::ActionSourceSpan
    expr::ActionExpr
    drops_value::Bool
end

function ActionStatement(; source, source_span, expr, drops_value = true)
    return ActionStatement("action_stmt", String(source), source_span, expr, drops_value)
end

struct ActionBlock <: ActionNode
    kind::String
    source::String
    source_span::ActionSourceSpan
    statements::Vector{ActionStatement}
end

function ActionBlock(; source, source_span, statements)
    return ActionBlock("action_block", String(source), source_span, ActionStatement[statements...])
end

struct ActionPositionalArgument <: ActionArgument
    value::ActionExpr
end

struct ActionKeywordArgument <: ActionArgument
    name::String
    value::ActionExpr
end

function ActionKeywordArgument(; name, value)
    return ActionKeywordArgument(String(name), value)
end

struct ActionCallExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    name::String
    args::Vector{ActionArgument}
    source_method::Union{Nothing,String}
    trailing_block_arg::Bool
    trailing_block_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionCallExpr(;
    source,
    source_span,
    name,
    args,
    source_method = nothing,
    trailing_block_arg = false,
    trailing_block_source_span = nothing,
)
    return ActionCallExpr(
        "call",
        String(source),
        source_span,
        String(name),
        ActionArgument[args...],
        source_method === nothing ? nothing : String(source_method),
        trailing_block_arg,
        trailing_block_source_span,
    )
end

struct ActionVariableExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    name::String
end

function ActionVariableExpr(; source, source_span, name)
    return ActionVariableExpr("variable", String(source), source_span, String(name))
end

struct ActionIndexedVarExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    name::String
    index::ActionExpr
end

function ActionIndexedVarExpr(; source, source_span, name, index)
    return ActionIndexedVarExpr("indexed_var", String(source), source_span, String(name), index)
end

struct ActionKeyAccessSegment <: ActionAccessSegment
    kind::String
    value::String
    source::String
    source_span::ActionSourceSpan
end

function ActionKeyAccessSegment(; value, source, source_span)
    return ActionKeyAccessSegment("key", String(value), String(source), source_span)
end

struct ActionIndexAccessSegment <: ActionAccessSegment
    kind::String
    expr::ActionExpr
    source::String
    source_span::ActionSourceSpan
end

function ActionIndexAccessSegment(; expr, source, source_span)
    return ActionIndexAccessSegment("index", expr, String(source), source_span)
end

struct ActionNestedAccessExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    base::String
    segments::Vector{ActionAccessSegment}
end

function ActionNestedAccessExpr(; source, source_span, base, segments)
    return ActionNestedAccessExpr(
        "nested_access",
        String(source),
        source_span,
        String(base),
        ActionAccessSegment[segments...],
    )
end

struct ActionArrayLiteralExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    items::Vector{ActionExpr}
end

function ActionArrayLiteralExpr(; source, source_span, items)
    return ActionArrayLiteralExpr("array_literal", String(source), source_span, ActionExpr[items...])
end

struct ActionHashLiteralEntry
    key::ActionExpr
    value::ActionExpr
end

function ActionHashLiteralEntry(; key, value)
    return ActionHashLiteralEntry(key, value)
end

struct ActionHashLiteralExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    entries::Vector{ActionHashLiteralEntry}
end

function ActionHashLiteralExpr(; source, source_span, entries)
    return ActionHashLiteralExpr(
        "hash_literal",
        String(source),
        source_span,
        ActionHashLiteralEntry[entries...],
    )
end

struct ActionBlockValueExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    block::ActionBlock
end

function ActionBlockValueExpr(; source, source_span, block)
    return ActionBlockValueExpr("block_value", String(source), source_span, block)
end

struct ActionStringLiteralExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    value::String
    quote_char::String
end

function ActionStringLiteralExpr(; source, source_span, value, quote_char)
    return ActionStringLiteralExpr("string", String(source), source_span, String(value), String(quote_char))
end

struct ActionNumberLiteralExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    value::Union{Int,Float64}
end

function ActionNumberLiteralExpr(; source, source_span, value)
    return ActionNumberLiteralExpr("number", String(source), source_span, value)
end

struct ActionBooleanLiteralExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    value::Bool
end

function ActionBooleanLiteralExpr(; source, source_span, value)
    return ActionBooleanLiteralExpr("boolean", String(source), source_span, value)
end

struct ActionRegexLiteralExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    pattern::String
    flags::String
end

function ActionRegexLiteralExpr(; source, source_span, pattern, flags = "")
    return ActionRegexLiteralExpr("regex", String(source), source_span, String(pattern), String(flags))
end

struct ActionUndefExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
end

function ActionUndefExpr(; source, source_span)
    return ActionUndefExpr("undef", String(source), source_span)
end

struct ActionAssignScalarExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    name::String
    value::ActionExpr
end

function ActionAssignScalarExpr(; source, source_span, name, value)
    return ActionAssignScalarExpr("assign_scalar", String(source), source_span, String(name), value)
end

struct ActionAssignArrayAppendExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    name::String
    value::ActionExpr
end

function ActionAssignArrayAppendExpr(; source, source_span, name, value)
    return ActionAssignArrayAppendExpr("assign_array_append", String(source), source_span, String(name), value)
end

struct ActionAssignHashIndexExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    name::String
    key::ActionExpr
    value::ActionExpr
end

function ActionAssignHashIndexExpr(; source, source_span, name, key, value)
    return ActionAssignHashIndexExpr("assign_hash_index", String(source), source_span, String(name), key, value)
end

struct ActionAssignNestedAccessExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    base::String
    segments::Vector{ActionAccessSegment}
    value::ActionExpr
end

function ActionAssignNestedAccessExpr(; source, source_span, base, segments, value)
    return ActionAssignNestedAccessExpr(
        "assign_nested_access",
        String(source),
        source_span,
        String(base),
        ActionAccessSegment[segments...],
        value,
    )
end

struct ActionFluentCall
    method::String
    args::Vector{ActionArgument}
    source::String
    source_span::ActionSourceSpan
    source_method::Union{Nothing,String}
    trailing_block_arg::Bool
    receiver_trailing_block_arg::Bool
    trailing_block_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionFluentCall(;
    method,
    args,
    source,
    source_span,
    source_method = nothing,
    trailing_block_arg = false,
    receiver_trailing_block_arg = false,
    trailing_block_source_span = nothing,
)
    return ActionFluentCall(
        String(method),
        ActionArgument[args...],
        String(source),
        source_span,
        source_method === nothing ? nothing : String(source_method),
        trailing_block_arg,
        receiver_trailing_block_arg,
        trailing_block_source_span,
    )
end

struct ActionFluentChainExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    receiver::ActionExpr
    calls::Vector{ActionFluentCall}
end

function ActionFluentChainExpr(; source, source_span, receiver, calls)
    return ActionFluentChainExpr(
        "fluent_chain",
        String(source),
        source_span,
        receiver,
        ActionFluentCall[calls...],
    )
end

struct ActionControlIfExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    branch_role::String
    condition::ActionExpr
    args::Vector{ActionArgument}
    body::Union{Nothing,ActionBlock}
    body_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionControlIfExpr(;
    source,
    source_span,
    keyword,
    canonical_keyword,
    branch_role,
    condition,
    args,
    body = nothing,
    body_source_span = nothing,
)
    return ActionControlIfExpr(
        "control_if",
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        String(branch_role),
        condition,
        ActionArgument[args...],
        body,
        body_source_span,
    )
end

struct ActionControlElseExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    args::Vector{ActionArgument}
    body::Union{Nothing,ActionBlock}
    body_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionControlElseExpr(;
    source,
    source_span,
    keyword,
    canonical_keyword,
    args,
    body = nothing,
    body_source_span = nothing,
)
    return ActionControlElseExpr(
        "control_else",
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        ActionArgument[args...],
        body,
        body_source_span,
    )
end

struct ActionControlMarkerExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    args::Vector{ActionArgument}
end

function ActionControlMarkerExpr(; kind, source, source_span, keyword, canonical_keyword, args)
    return ActionControlMarkerExpr(
        String(kind),
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        ActionArgument[args...],
    )
end

struct ActionControlWhileExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    condition::ActionExpr
    args::Vector{ActionArgument}
    body::Union{Nothing,ActionBlock}
    body_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionControlWhileExpr(;
    source,
    source_span,
    keyword,
    canonical_keyword,
    condition,
    args,
    body = nothing,
    body_source_span = nothing,
)
    return ActionControlWhileExpr(
        "control_while",
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        condition,
        ActionArgument[args...],
        body,
        body_source_span,
    )
end

struct ActionControlSwitchExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    source_expr::ActionExpr
    args::Vector{ActionArgument}
    body::Union{Nothing,ActionBlock}
    body_source_span::Union{Nothing,ActionSourceSpan}
    cases::Vector{ActionExpr}
    default_case::Union{Nothing,ActionExpr}
end

function ActionControlSwitchExpr(;
    source,
    source_span,
    keyword,
    canonical_keyword,
    source_expr,
    args,
    body = nothing,
    body_source_span = nothing,
    cases = Any[],
    default_case = nothing,
)
    return ActionControlSwitchExpr(
        "control_switch",
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        source_expr,
        ActionArgument[args...],
        body,
        body_source_span,
        ActionExpr[cases...],
        default_case,
    )
end

struct ActionControlCaseExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    match::ActionExpr
    args::Vector{ActionArgument}
    body::Union{Nothing,ActionBlock}
    body_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionControlCaseExpr(;
    source,
    source_span,
    keyword,
    canonical_keyword,
    match,
    args,
    body = nothing,
    body_source_span = nothing,
)
    return ActionControlCaseExpr(
        "control_case",
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        match,
        ActionArgument[args...],
        body,
        body_source_span,
    )
end

struct ActionControlDefaultExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    keyword::String
    canonical_keyword::String
    args::Vector{ActionArgument}
    body::Union{Nothing,ActionBlock}
    body_source_span::Union{Nothing,ActionSourceSpan}
end

function ActionControlDefaultExpr(;
    source,
    source_span,
    keyword,
    canonical_keyword,
    args,
    body = nothing,
    body_source_span = nothing,
)
    return ActionControlDefaultExpr(
        "control_default",
        String(source),
        source_span,
        String(keyword),
        String(canonical_keyword),
        ActionArgument[args...],
        body,
        body_source_span,
    )
end

struct ActionRawExpr <: ActionExpr
    kind::String
    source::String
    source_span::ActionSourceSpan
    reason::String
end

function ActionRawExpr(; source, source_span, reason)
    return ActionRawExpr("raw_perl", String(source), source_span, String(reason))
end

to_json(span::ActionSourceSpan) = Dict("start" => span.start, "end" => span.stop)

function _action_base_json(node)
    return Dict{String,Any}(
        "kind" => node.kind,
        "source" => node.source,
        "source_span" => to_json(node.source_span),
    )
end

function to_json(block::ActionBlock)
    result = _action_base_json(block)
    result["statements"] = [to_json(statement) for statement in block.statements]
    return result
end

function to_json(statement::ActionStatement)
    result = _action_base_json(statement)
    result["expr"] = to_json(statement.expr)
    result["drops_value"] = statement.drops_value
    return result
end

to_json(argument::ActionPositionalArgument) = to_json(argument.value)
to_json(argument::ActionKeywordArgument) = Dict("name" => argument.name, "value" => to_json(argument.value))

function to_json(expr::ActionCallExpr)
    result = _action_base_json(expr)
    result["name"] = expr.name
    _put_if_present!(result, "source_method", expr.source_method)
    result["args"] = [to_json(argument) for argument in expr.args]
    if expr.trailing_block_arg
        result["trailing_block_arg"] = true
    end
    if expr.trailing_block_source_span !== nothing
        result["trailing_block_source_span"] = to_json(expr.trailing_block_source_span)
    end
    return result
end

function to_json(expr::ActionVariableExpr)
    result = _action_base_json(expr)
    result["name"] = expr.name
    return result
end

function to_json(expr::ActionIndexedVarExpr)
    result = _action_base_json(expr)
    result["name"] = expr.name
    result["index"] = to_json(expr.index)
    return result
end

function to_json(segment::ActionKeyAccessSegment)
    return Dict(
        "kind" => segment.kind,
        "value" => segment.value,
        "source" => segment.source,
        "source_span" => to_json(segment.source_span),
    )
end

function to_json(segment::ActionIndexAccessSegment)
    return Dict(
        "kind" => segment.kind,
        "expr" => to_json(segment.expr),
        "source" => segment.source,
        "source_span" => to_json(segment.source_span),
    )
end

function to_json(expr::ActionNestedAccessExpr)
    result = _action_base_json(expr)
    result["base"] = expr.base
    result["segments"] = [to_json(segment) for segment in expr.segments]
    return result
end

function to_json(expr::ActionArrayLiteralExpr)
    result = _action_base_json(expr)
    result["items"] = [to_json(item) for item in expr.items]
    return result
end

to_json(entry::ActionHashLiteralEntry) = Dict("key" => to_json(entry.key), "value" => to_json(entry.value))

function to_json(expr::ActionHashLiteralExpr)
    result = _action_base_json(expr)
    result["entries"] = [to_json(entry) for entry in expr.entries]
    return result
end

function to_json(expr::ActionBlockValueExpr)
    result = _action_base_json(expr)
    result["block"] = to_json(expr.block)
    return result
end

function to_json(expr::ActionStringLiteralExpr)
    result = _action_base_json(expr)
    result["value"] = expr.value
    result["quote"] = expr.quote_char
    return result
end

function to_json(expr::ActionNumberLiteralExpr)
    result = _action_base_json(expr)
    result["value"] = expr.value
    return result
end

function to_json(expr::ActionBooleanLiteralExpr)
    result = _action_base_json(expr)
    result["value"] = expr.value
    return result
end

function to_json(expr::ActionRegexLiteralExpr)
    result = _action_base_json(expr)
    result["pattern"] = expr.pattern
    result["flags"] = expr.flags
    return result
end

to_json(expr::ActionUndefExpr) = _action_base_json(expr)

function to_json(expr::ActionAssignScalarExpr)
    result = _action_base_json(expr)
    result["name"] = expr.name
    result["value"] = to_json(expr.value)
    return result
end

function to_json(expr::ActionAssignArrayAppendExpr)
    result = _action_base_json(expr)
    result["name"] = expr.name
    result["value"] = to_json(expr.value)
    return result
end

function to_json(expr::ActionAssignHashIndexExpr)
    result = _action_base_json(expr)
    result["name"] = expr.name
    result["key"] = to_json(expr.key)
    result["value"] = to_json(expr.value)
    return result
end

function to_json(expr::ActionAssignNestedAccessExpr)
    result = _action_base_json(expr)
    result["base"] = expr.base
    result["segments"] = [to_json(segment) for segment in expr.segments]
    result["value"] = to_json(expr.value)
    return result
end

function to_json(call::ActionFluentCall)
    result = Dict{String,Any}(
        "method" => call.method,
        "args" => [to_json(argument) for argument in call.args],
        "source" => call.source,
        "source_span" => to_json(call.source_span),
    )
    _put_if_present!(result, "source_method", call.source_method)
    if call.trailing_block_arg
        result["trailing_block_arg"] = true
    end
    if call.receiver_trailing_block_arg
        result["receiver_trailing_block_arg"] = true
    end
    if call.trailing_block_source_span !== nothing
        result["trailing_block_source_span"] = to_json(call.trailing_block_source_span)
    end
    return result
end

function to_json(expr::ActionFluentChainExpr)
    result = _action_base_json(expr)
    result["receiver"] = to_json(expr.receiver)
    result["calls"] = [to_json(call) for call in expr.calls]
    return result
end

function to_json(expr::ActionControlIfExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["branch_role"] = expr.branch_role
    result["condition"] = to_json(expr.condition)
    result["args"] = [to_json(argument) for argument in expr.args]
    _put_action_block_fields!(result, expr.body, expr.body_source_span)
    return result
end

function to_json(expr::ActionControlElseExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["branch_role"] = "else"
    result["args"] = [to_json(argument) for argument in expr.args]
    _put_action_block_fields!(result, expr.body, expr.body_source_span)
    return result
end

function to_json(expr::ActionControlMarkerExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["args"] = [to_json(argument) for argument in expr.args]
    return result
end

function to_json(expr::ActionControlWhileExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["condition"] = to_json(expr.condition)
    result["args"] = [to_json(argument) for argument in expr.args]
    _put_action_block_fields!(result, expr.body, expr.body_source_span)
    return result
end

function to_json(expr::ActionControlSwitchExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["source_expr"] = to_json(expr.source_expr)
    result["args"] = [to_json(argument) for argument in expr.args]
    _put_action_block_fields!(result, expr.body, expr.body_source_span)
    if !isempty(expr.cases)
        result["cases"] = [to_json(item) for item in expr.cases]
    end
    if expr.default_case !== nothing
        result["default"] = to_json(expr.default_case)
    end
    return result
end

function to_json(expr::ActionControlCaseExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["match"] = to_json(expr.match)
    result["args"] = [to_json(argument) for argument in expr.args]
    _put_action_block_fields!(result, expr.body, expr.body_source_span)
    return result
end

function to_json(expr::ActionControlDefaultExpr)
    result = _action_base_json(expr)
    result["keyword"] = expr.keyword
    result["canonical_keyword"] = expr.canonical_keyword
    result["args"] = [to_json(argument) for argument in expr.args]
    _put_action_block_fields!(result, expr.body, expr.body_source_span)
    return result
end

function to_json(expr::ActionRawExpr)
    result = _action_base_json(expr)
    result["reason"] = expr.reason
    return result
end

function _put_action_block_fields!(result, body, body_source_span)
    if body !== nothing
        result["body"] = to_json(body)
    end
    if body_source_span !== nothing
        result["body_source_span"] = to_json(body_source_span)
    end
    return result
end
