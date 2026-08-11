struct CallableContractException <: Exception
    message::String
end

Base.showerror(io::IO, error::CallableContractException) = print(io, error.message)

@enum CallableSurface begin
    CallableHelperSurface
    CallableReceiverSurface
end

struct FinalCodeblockContract
    min_before_codeblock::Int
    max_before_codeblock::Int
end

function _builtin_final_codeblock_contract(surface::CallableSurface, name::AbstractString)
    canonical = canonical_action_helper_name(name)
    bounds = if surface == CallableHelperSurface && canonical == "with"
        (0, 1)
    elseif surface == CallableReceiverSurface &&
            canonical in ("with", "walk_leaves", "map_leaves")
        (0, 0)
    elseif surface == CallableReceiverSurface && canonical == "reduce_leaves"
        (1, 1)
    else
        nothing
    end
    bounds === nothing && return nothing
    return FinalCodeblockContract(first(bounds), last(bounds))
end

function _user_function_final_codeblock_contract(entry::UserFunctionEntry)
    definition = entry.definition
    isempty(definition.params) && return nothing
    final_name = last(definition.params)
    definition.parameter_kinds == Dict(final_name => "codeblock") || return nothing
    before = length(definition.params) - 1
    return FinalCodeblockContract(before, before)
end

function _registered_user_final_codeblock_contract(
    registry::UserFunctionRegistry,
    name::AbstractString,
)
    entry = lookup_user_function(registry, name)
    return entry === nothing ? nothing : _user_function_final_codeblock_contract(entry)
end

function normalize_function_final_codeblocks(
    definition::FunctionDefinition,
    registry::UserFunctionRegistry,
)
    body = parse_action_block(definition.body_source)
    normalize_action_block_final_codeblocks!(body, registry)
    return FunctionDefinition(
        name = definition.name,
        params = definition.params,
        arity = definition.arity,
        signature = definition.signature,
        parameter_kinds = definition.parameter_kinds,
        body_source = definition.body_source,
        body_payload = definition.body_payload,
        body_parse_job = definition.body_parse_job,
        body_ast = to_json(body),
        source = definition.source,
        source_span = definition.source_span,
        body_span = definition.body_span,
    )
end

function normalize_action_block_final_codeblocks!(
    block::ActionBlock,
    registry::UserFunctionRegistry,
)
    for statement in block.statements
        _normalize_final_codeblock_expr!(statement.expr, registry)
    end
    return block
end

function _normalize_final_codeblock_args!(
    surface::CallableSurface,
    name::String,
    args::Vector{ActionArgument},
    attached::Bool,
    registry::UserFunctionRegistry,
)
    for argument in args
        _normalize_final_codeblock_expr!(argument.value, registry)
    end
    isempty(args) && return nothing
    last_argument = last(args)
    if !(last_argument isa ActionPositionalArgument) ||
            !(last_argument.value isa ActionBlockValueExpr)
        return nothing
    end

    candidate = last_argument.value
    contract = _builtin_final_codeblock_contract(surface, name)
    if contract === nothing && surface == CallableHelperSurface
        contract = _registered_user_final_codeblock_contract(registry, name)
    end
    if contract === nothing
        if attached
            surface_name = surface == CallableHelperSurface ? "helper" : "receiver"
            throw(CallableContractException(
                "callable_contract_rejected: $surface_name '$name' does not " *
                "declare a final codeblock parameter",
            ))
        end
        return nothing
    end

    before_count = length(args) - 1
    if before_count < contract.min_before_codeblock ||
            before_count > contract.max_before_codeblock
        surface_name = surface == CallableHelperSurface ? "helper" : "receiver"
        throw(CallableContractException(
            "callable_contract_arity_mismatch: $surface_name '$name' expects " *
            "$(contract.min_before_codeblock)..=$(contract.max_before_codeblock) " *
            "value argument(s) before final codeblock, got $before_count",
        ))
    end

    args[end] = ActionPositionalArgument(ActionCodeblockArgumentExpr(
        signature = CallableSignature(
            positional_params = String[],
            rest_param = nothing,
            min_arity = 0,
            max_arity = 0,
        ),
        body_source = candidate.block.source,
        body_ast = candidate.block,
        source = candidate.source,
        source_span = candidate.source_span,
        body_span = candidate.block.source_span,
    ))
    return nothing
end

function _normalize_final_codeblock_expr!(expr::ActionExpr, registry::UserFunctionRegistry)
    if expr isa ActionCallExpr
        _normalize_final_codeblock_args!(
            CallableHelperSurface,
            expr.name,
            expr.args,
            expr.trailing_block_arg,
            registry,
        )
    elseif expr isa ActionRecognitionCheckpointExpr ||
           expr isa ActionRecognizeOnceExpr ||
           expr isa ActionRecognitionCommitExpr ||
           expr isa ActionRecognitionRollbackExpr
        return nothing
    elseif expr isa ActionFluentChainExpr
        _normalize_final_codeblock_expr!(expr.receiver, registry)
        for call in expr.calls
            _normalize_final_codeblock_args!(
                CallableReceiverSurface,
                call.method,
                call.args,
                call.receiver_trailing_block_arg,
                registry,
            )
        end
    elseif expr isa ActionAssignScalarExpr || expr isa ActionAssignArrayAppendExpr
        _normalize_final_codeblock_expr!(expr.value, registry)
    elseif expr isa ActionAssignHashIndexExpr
        _normalize_final_codeblock_expr!(expr.key, registry)
        _normalize_final_codeblock_expr!(expr.value, registry)
    elseif expr isa ActionAssignNestedAccessExpr
        _normalize_final_codeblock_segments!(expr.segments, registry)
        _normalize_final_codeblock_expr!(expr.value, registry)
    elseif expr isa ActionIndexedVarExpr
        _normalize_final_codeblock_expr!(expr.index, registry)
    elseif expr isa ActionNestedAccessExpr
        _normalize_final_codeblock_segments!(expr.segments, registry)
    elseif expr isa ActionValueAccessExpr
        _normalize_final_codeblock_expr!(expr.receiver, registry)
        _normalize_final_codeblock_segments!(expr.segments, registry)
    elseif expr isa ActionArrayLiteralExpr
        for item in expr.items
            _normalize_final_codeblock_expr!(item, registry)
        end
    elseif expr isa ActionHashLiteralExpr
        for entry in expr.entries
            _normalize_final_codeblock_expr!(entry.key, registry)
            _normalize_final_codeblock_expr!(entry.value, registry)
        end
    elseif expr isa ActionBlockValueExpr || expr isa ActionCodeblockArgumentExpr ||
           expr isa ActionCodeblockLiteralExpr
        normalize_action_block_final_codeblocks!(
            expr isa ActionBlockValueExpr ? expr.block : expr.body_ast,
            registry,
        )
    elseif expr isa ActionControlIfExpr
        _normalize_final_codeblock_expr!(expr.condition, registry)
        _normalize_final_codeblock_argument_values!(expr.args, registry)
        _normalize_optional_final_codeblock_body!(expr.body, registry)
    elseif expr isa ActionControlWhileExpr
        _normalize_final_codeblock_expr!(expr.condition, registry)
        _normalize_final_codeblock_argument_values!(expr.args, registry)
        _normalize_optional_final_codeblock_body!(expr.body, registry)
    elseif expr isa ActionControlSwitchExpr
        _normalize_final_codeblock_expr!(expr.source_expr, registry)
        _normalize_final_codeblock_argument_values!(expr.args, registry)
        _normalize_optional_final_codeblock_body!(expr.body, registry)
        for branch in expr.cases
            _normalize_final_codeblock_expr!(branch, registry)
        end
        if expr.default_case !== nothing
            _normalize_final_codeblock_expr!(expr.default_case, registry)
        end
    elseif expr isa ActionControlCaseExpr
        _normalize_final_codeblock_expr!(expr.match, registry)
        _normalize_final_codeblock_argument_values!(expr.args, registry)
        _normalize_optional_final_codeblock_body!(expr.body, registry)
    elseif expr isa ActionControlElseExpr || expr isa ActionControlDefaultExpr
        _normalize_final_codeblock_argument_values!(expr.args, registry)
        _normalize_optional_final_codeblock_body!(expr.body, registry)
    elseif expr isa ActionControlMarkerExpr
        _normalize_final_codeblock_argument_values!(expr.args, registry)
    end
    return nothing
end

function _normalize_final_codeblock_argument_values!(args, registry)
    for argument in args
        _normalize_final_codeblock_expr!(argument.value, registry)
    end
    return nothing
end

function _normalize_final_codeblock_segments!(segments, registry)
    for segment in segments
        if segment isa ActionIndexAccessSegment
            _normalize_final_codeblock_expr!(segment.expr, registry)
        end
    end
    return nothing
end

function _normalize_optional_final_codeblock_body!(body, registry)
    body === nothing || normalize_action_block_final_codeblocks!(body, registry)
    return nothing
end
