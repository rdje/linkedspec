struct RuntimeInterpreterException <: Exception
    message::String
end

Base.showerror(io::IO, error::RuntimeInterpreterException) = print(io, error.message)

struct RuntimeLifecycleEvent
    rule_label::String
    lifecycle::String
    line::Int
end

struct RuntimeParseResult
    matched::Bool
    value::Any
    output::Vector{Any}
    cursor_codeunit::Int
    cursor_char_offset::Int
    lifecycle_events::Vector{RuntimeLifecycleEvent}
end

struct LinkedSpecRuntimeEngine
    compiled_spec::CompiledSpec
    parse_mode::LinkedSpecParseMode
    max_iterations::Int
end

function LinkedSpecRuntimeEngine(
    compiled_spec::CompiledSpec;
    parse_mode = SeekParseMode,
    max_iterations::Int = 10_000,
)
    if max_iterations <= 0
        throw(ArgumentError("max_iterations must be positive"))
    end
    return LinkedSpecRuntimeEngine(
        compiled_spec,
        _normalize_parse_mode(parse_mode),
        max_iterations,
    )
end

mutable struct _RuntimeExecutionContext
    input::String
    cursor_codeunit::Int
    registers::RuntimeMatchRegisters
    retv::Any
    arrays::Dict{String,Vector{Any}}
    active_rule_entries::Set{Tuple{String,Int,Int}}
    lifecycle_events::Vector{RuntimeLifecycleEvent}
end

function _RuntimeExecutionContext(input::AbstractString)
    input_text = String(input)
    return _RuntimeExecutionContext(
        input_text,
        0,
        RuntimeMatchRegisters(input_text),
        nothing,
        Dict{String,Vector{Any}}(),
        Set{Tuple{String,Int,Int}}(),
        RuntimeLifecycleEvent[],
    )
end

struct _RuntimeRuleResult
    matched::Bool
    value::Any
end

struct _RuntimeActionReturn <: Exception
    value::Any
end

struct _RuntimeActionNext <: Exception end

struct _RuntimeNextableBool
    value::Bool
    nexted::Bool
end

mutable struct _CurrentRuntimeActionEdge
    rule_label::String
    edge::CompiledActionEdge
    target::DependencyRef
    child_dispatched::Bool
    child_result::Union{Nothing,_RuntimeRuleResult}
end

function runtime_parse(
    engine::LinkedSpecRuntimeEngine,
    input::AbstractString;
    top_rule = nothing,
)
    context = _RuntimeExecutionContext(input)
    label = top_rule === nothing ? _default_runtime_top_rule(engine.compiled_spec) : String(top_rule)
    result = _execute_runtime_rule!(engine, label, 0, context)
    return RuntimeParseResult(
        result.matched,
        _runtime_copy(result.value),
        # Backend-neutral parser output wraps the top-rule value exactly once.
        Any[_runtime_copy(result.value)],
        context.cursor_codeunit,
        codeunit_offset_to_char_offset(context.input, context.cursor_codeunit),
        RuntimeLifecycleEvent[context.lifecycle_events...],
    )
end

runtime_execute(engine::LinkedSpecRuntimeEngine, input::AbstractString; top_rule = nothing) =
    runtime_parse(engine, input; top_rule = top_rule)

function _default_runtime_top_rule(compiled::CompiledSpec)
    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        if rule.header.is_top
            return label
        end
    end
    if isempty(compiled.compiled_rule_order)
        throw(RuntimeInterpreterException("compiled spec does not contain any rules"))
    end
    return first(compiled.compiled_rule_order)
end

function _execute_runtime_rule!(
    engine::LinkedSpecRuntimeEngine,
    label::String,
    entry_regex_index::Int,
    context::_RuntimeExecutionContext,
)
    rule = compiled_rule(engine.compiled_spec, label)
    if rule === nothing
        throw(RuntimeInterpreterException("rule '$label' is not compiled"))
    end

    recursion_key = (label, entry_regex_index, context.cursor_codeunit)
    if recursion_key in context.active_rule_entries
        return _RuntimeRuleResult(false, nothing)
    end

    push!(context.active_rule_entries, recursion_key)
    saved_registers = context.registers
    context.registers = enter_child(saved_registers)

    try
        init_return = _execute_runtime_lifecycle!(engine, rule, "I", context)
        if init_return !== nothing
            return _runtime_returned(init_return.value)
        end

        try
            if !isempty(rule.blind_edges)
                return _execute_runtime_blind_rule!(engine, rule, context)
            end
            return _execute_runtime_regex_rule!(engine, rule, entry_regex_index, context)
        catch error
            if error isa _RuntimeActionReturn
                return _runtime_returned(error.value)
            end
            rethrow()
        end
    finally
        context.registers = saved_registers
        delete!(context.active_rule_entries, recursion_key)
    end
end

function _execute_runtime_blind_rule!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    context::_RuntimeExecutionContext,
)
    minimum = rule.mode_metadata.rep_min
    if minimum === nothing
        matched_any = false
        for _ in 1:engine.max_iterations
            before = context.cursor_codeunit
            matched = _runtime_nextable_bool(() -> _execute_runtime_blind_once!(engine, rule, context))
            if matched.nexted
                matched_any = true
                if context.cursor_codeunit == before
                    break
                end
                continue
            end
            if !matched.value
                loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
                if loop_exit !== nothing
                    return _runtime_returned(loop_exit.value)
                end
            end
            exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
            if exit_return !== nothing
                return _runtime_returned(exit_return.value)
            end
            return _RuntimeRuleResult(matched.value || matched_any, nothing)
        end
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
        exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
        if exit_return !== nothing
            return _runtime_returned(exit_return.value)
        end
        return _RuntimeRuleResult(matched_any, nothing)
    end

    matches = 0
    made_failed_attempt = false
    for _ in 1:engine.max_iterations
        maximum = rule.mode_metadata.rep_max
        if maximum !== nothing && matches >= maximum
            break
        end
        before = context.cursor_codeunit
        loop_start = _execute_runtime_lifecycle!(engine, rule, "LS", context)
        if loop_start !== nothing
            return _runtime_returned(loop_start.value)
        end

        matched = _runtime_nextable_bool(() -> _execute_runtime_blind_once!(engine, rule, context))
        if matched.nexted
            matches += 1
            if context.cursor_codeunit == before
                break
            end
            continue
        end
        if !matched.value
            made_failed_attempt = true
            break
        end

        matches += 1
        loop_end = _execute_runtime_lifecycle!(engine, rule, "LE", context)
        if loop_end !== nothing
            return _runtime_returned(loop_end.value)
        end
        iteration_return = _execute_runtime_lifecycle!(engine, rule, "IT", context)
        if iteration_return !== nothing
            return _runtime_returned(iteration_return.value)
        end
        if context.cursor_codeunit == before
            break
        end
    end

    if matches < minimum
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
        throw(RuntimeInterpreterException(
            "rule '$(rule.label)' expected at least $minimum matches, got $matches",
        ))
    end

    extended_exit = _execute_runtime_lifecycle!(engine, rule, "EX", context)
    if extended_exit !== nothing
        return _runtime_returned(extended_exit.value)
    end
    if made_failed_attempt || matches > 0
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
    end
    exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
    if exit_return !== nothing
        return _runtime_returned(exit_return.value)
    end
    return _RuntimeRuleResult(matches > 0, nothing)
end

function _execute_runtime_blind_once!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    context::_RuntimeExecutionContext,
)
    if rule.mode_metadata.is_and
        for edge in rule.blind_edges
            child = _execute_runtime_rule!(
                engine,
                edge.target.label,
                edge.target.index,
                context,
            )
            context.retv = child.value
            edge_return = _execute_runtime_optional_payload!(
                engine,
                edge.action_payload,
                context,
                rule.label,
                nothing,
            )
            if edge_return !== nothing
                throw(edge_return)
            end
            if !child.matched
                return false
            end
        end
        return true
    end

    for edge in rule.blind_edges
        child = _execute_runtime_rule!(engine, edge.target.label, edge.target.index, context)
        context.retv = child.value
        edge_return = _execute_runtime_optional_payload!(
            engine,
            edge.action_payload,
            context,
            rule.label,
            nothing,
        )
        if edge_return !== nothing
            throw(edge_return)
        end
        if child.matched
            return true
        end
    end
    return false
end

function _execute_runtime_regex_rule!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    entry_regex_index::Int,
    context::_RuntimeExecutionContext,
)
    minimum = rule.mode_metadata.rep_min
    if minimum === nothing
        matched_any = false
        for _ in 1:engine.max_iterations
            before = context.cursor_codeunit
            matched = _runtime_nextable_bool(() -> _execute_runtime_regex_once!(
                engine,
                rule,
                context;
                entry_regex_index = entry_regex_index,
                and_sequence = rule.mode_metadata.is_and && length(rule.regex_patterns) > 1,
            ))
            if matched.nexted
                matched_any = true
                if context.cursor_codeunit == before
                    break
                end
                continue
            end
            if !matched.value
                loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
                if loop_exit !== nothing
                    return _runtime_returned(loop_exit.value)
                end
            end
            exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
            if exit_return !== nothing
                return _runtime_returned(exit_return.value)
            end
            return _RuntimeRuleResult(matched.value || matched_any, nothing)
        end
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
        exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
        if exit_return !== nothing
            return _runtime_returned(exit_return.value)
        end
        return _RuntimeRuleResult(matched_any, nothing)
    end

    matches = 0
    made_failed_attempt = false
    for _ in 1:engine.max_iterations
        maximum = rule.mode_metadata.rep_max
        if maximum !== nothing && matches >= maximum
            break
        end
        before = context.cursor_codeunit
        loop_start = _execute_runtime_lifecycle!(engine, rule, "LS", context)
        if loop_start !== nothing
            return _runtime_returned(loop_start.value)
        end

        matched = _runtime_nextable_bool(() -> _execute_runtime_regex_once!(
            engine,
            rule,
            context;
            and_sequence = rule.mode_metadata.is_and && length(rule.regex_patterns) > 1,
        ))
        if matched.nexted
            matches += 1
            if context.cursor_codeunit == before
                break
            end
            continue
        end
        if !matched.value
            made_failed_attempt = true
            break
        end

        matches += 1
        iteration_return = _execute_runtime_lifecycle!(engine, rule, "IT", context)
        if iteration_return !== nothing
            return _runtime_returned(iteration_return.value)
        end
        if context.cursor_codeunit == before
            break
        end
    end

    if matches < minimum
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
        throw(RuntimeInterpreterException(
            "rule '$(rule.label)' expected at least $minimum matches, got $matches",
        ))
    end

    extended_exit = _execute_runtime_lifecycle!(engine, rule, "EX", context)
    if extended_exit !== nothing
        return _runtime_returned(extended_exit.value)
    end
    if made_failed_attempt || matches > 0
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
    end
    exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
    if exit_return !== nothing
        return _runtime_returned(exit_return.value)
    end
    return _RuntimeRuleResult(matches > 0, nothing)
end

function _execute_runtime_regex_once!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    context::_RuntimeExecutionContext;
    entry_regex_index::Int = 0,
    and_sequence::Bool = false,
)
    if isempty(rule.regex_patterns)
        return false
    end

    if and_sequence
        for expected_index in eachindex(rule.regex_patterns)
            zero_based_index = expected_index - 1
            one_match = _match_runtime_specific(
                engine,
                rule.regex_patterns,
                zero_based_index,
                context,
            )
            if one_match === nothing
                return false
            end
            _accept_runtime_regex_match!(engine, rule, one_match, context)
            loop_end = _execute_runtime_lifecycle!(engine, rule, "LE", context)
            if loop_end !== nothing
                throw(loop_end)
            end
        end
        return true
    end

    one_match = if entry_regex_index > 0 && entry_regex_index < length(rule.regex_patterns)
        _match_runtime_specific(engine, rule.regex_patterns, entry_regex_index, context)
    else
        runtime_match(
            RuntimeRegexAlternation(rule),
            context.input,
            context.cursor_codeunit;
            parse_mode = engine.parse_mode,
        )
    end
    if one_match === nothing
        return false
    end

    _accept_runtime_regex_match!(engine, rule, one_match, context)
    loop_end = _execute_runtime_lifecycle!(engine, rule, "LE", context)
    if loop_end !== nothing
        throw(loop_end)
    end
    return true
end

function _match_runtime_specific(
    engine::LinkedSpecRuntimeEngine,
    patterns::Vector{String},
    zero_based_index::Int,
    context::_RuntimeExecutionContext,
)
    one_match = runtime_match(
        RuntimeRegexAlternation([patterns[zero_based_index + 1]]),
        context.input,
        context.cursor_codeunit;
        parse_mode = engine.parse_mode,
    )
    return one_match === nothing ? nothing : reindex_runtime_regex_match(one_match, zero_based_index)
end

function _accept_runtime_regex_match!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    one_match::RuntimeRegexMatch,
    context::_RuntimeExecutionContext,
)
    context.cursor_codeunit = one_match.codeunit_end
    context.registers = with_local_match(context.registers, one_match)

    for edge in rule.action_edges
        if edge.regex_index != one_match.alternative_index
            continue
        end
        target = only(edge.targets)
        current_edge = _CurrentRuntimeActionEdge(rule.label, edge, target, false, nothing)
        if edge.action_payload === nothing
            child = _execute_runtime_action_edge_child!(engine, current_edge, context)
            context.retv = child.value
            continue
        end

        action_return = _execute_runtime_action_block!(
            engine,
            edge.action_payload.action_ast,
            context,
            rule.label,
            current_edge,
        )
        if action_return !== nothing
            throw(action_return)
        end
        if !current_edge.child_dispatched && target.label != rule.label
            child = _execute_runtime_action_edge_child!(engine, current_edge, context)
            context.retv = child.value
        end
    end
end

function _execute_runtime_lifecycle!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    lifecycle::String,
    context::_RuntimeExecutionContext,
)
    for payload in rule.lifecycle_action_payloads
        if payload.lifecycle != lifecycle
            continue
        end
        push!(
            context.lifecycle_events,
            RuntimeLifecycleEvent(rule.label, lifecycle, payload.line),
        )
        action_return = _execute_runtime_action_block!(
            engine,
            payload.action_ast,
            context,
            rule.label,
            nothing,
        )
        if action_return !== nothing
            return action_return
        end
    end
    return nothing
end

function _execute_runtime_optional_payload!(
    engine::LinkedSpecRuntimeEngine,
    payload,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
)
    if payload === nothing
        return nothing
    end
    return _execute_runtime_action_block!(
        engine,
        payload.action_ast,
        context,
        rule_label,
        current_edge,
    )
end

function _execute_runtime_action_block!(
    engine::LinkedSpecRuntimeEngine,
    block::ActionBlock,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
)
    try
        for statement in block.statements
            _evaluate_runtime_action_expr!(
                engine,
                statement.expr,
                context,
                rule_label,
                current_edge,
                statement.drops_value,
            )
        end
        return nothing
    catch error
        if error isa _RuntimeActionReturn
            return error
        elseif error isa _RuntimeActionNext || error isa RuntimeInterpreterException
            rethrow()
        end
        throw(RuntimeInterpreterException(
            "action block failed in rule $rule_label: $(sprint(showerror, error))",
        ))
    end
end

function _evaluate_runtime_action_expr!(
    engine::LinkedSpecRuntimeEngine,
    expr::ActionExpr,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
    statement_context::Bool = false,
)
    # Keep this evaluator dispatch-facing. JULIA-BACKEND-PARITY.4.3 owns the
    # general store model and the broader helper/control/block families.
    if expr isa ActionStringLiteralExpr || expr isa ActionNumberLiteralExpr || expr isa ActionBooleanLiteralExpr
        return expr.value
    elseif expr isa ActionRegexLiteralExpr
        return expr.pattern
    elseif expr isa ActionUndefExpr
        return nothing
    elseif expr isa ActionVariableExpr
        if expr.name == "retv"
            return _read_runtime_retv!(engine, context, current_edge)
        end
        throw(RuntimeInterpreterException(
            "runtime variable reads are deferred beyond rule dispatch in rule $rule_label: $(expr.name)",
        ))
    elseif expr isa ActionArrayLiteralExpr
        return Any[
            _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                item,
                context,
                rule_label,
                current_edge,
            )) for item in expr.items
        ]
    elseif expr isa ActionCallExpr
        return _evaluate_runtime_call!(
            engine,
            expr,
            context,
            rule_label,
            current_edge,
            statement_context,
        )
    elseif expr isa ActionFluentChainExpr
        if isempty(expr.calls)
            return _evaluate_runtime_action_expr!(
                engine,
                expr.receiver,
                context,
                rule_label,
                current_edge,
            )
        end
        throw(RuntimeInterpreterException(
            "unsupported runtime fluent chain in rule $rule_label: $(expr.source)",
        ))
    elseif expr isa ActionRawExpr
        throw(RuntimeInterpreterException(
            "unsupported raw action expression in rule $rule_label: $(expr.source)",
        ))
    end
    throw(RuntimeInterpreterException(
        "unsupported action expression $(expr.kind) in rule $rule_label",
    ))
end

function _evaluate_runtime_call!(
    engine::LinkedSpecRuntimeEngine,
    call::ActionCallExpr,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
    statement_context::Bool,
)
    args = ActionExpr[getfield(arg, :value) for arg in call.args]
    helper_name = canonical_action_helper_name(call.name)

    if helper_name == "return"
        value = isempty(args) ? nothing : _evaluate_runtime_action_expr!(
            engine,
            first(args),
            context,
            rule_label,
            current_edge,
        )
        throw(_RuntimeActionReturn(_runtime_copy(value)))
    elseif helper_name == "return_undef"
        throw(_RuntimeActionReturn(nothing))
    elseif helper_name == "next"
        if statement_context
            throw(_RuntimeActionNext())
        end
        return nothing
    elseif helper_name == "set"
        return _call_runtime_set!(engine, args, context, rule_label, current_edge)
    elseif helper_name == "push"
        return _call_runtime_push!(engine, args, context, rule_label, current_edge)
    elseif helper_name == "array"
        return _call_runtime_array(engine, args, context, rule_label, current_edge)
    elseif helper_name == "copy"
        return isempty(args) ? nothing : _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            first(args),
            context,
            rule_label,
            current_edge,
        ))
    elseif helper_name == "entry_text"
        return context.registers.entry_match === nothing ? nothing : match_text(context.registers.entry_match)
    elseif helper_name == "match_text"
        return context.registers.local_match === nothing ? nothing : match_text(context.registers.local_match)
    elseif helper_name == "entry_group"
        return _runtime_capture_at(engine, context.registers.entry_match, args, context, rule_label, current_edge)
    elseif helper_name == "match_group"
        return _runtime_capture_at(engine, context.registers.local_match, args, context, rule_label, current_edge)
    elseif helper_name == "entry_groups"
        return context.registers.entry_match === nothing ? Any[] : Any[context.registers.entry_match.captures...]
    elseif helper_name == "match_groups"
        return context.registers.local_match === nothing ? Any[] : Any[context.registers.local_match.captures...]
    elseif helper_name == "entry_named"
        return _runtime_named_capture(engine, context.registers.entry_match, args, context, rule_label, current_edge)
    elseif helper_name == "match_named"
        return _runtime_named_capture(engine, context.registers.local_match, args, context, rule_label, current_edge)
    elseif helper_name == "call"
        if isempty(args)
            return nothing
        end
        target_label = _runtime_rule_name_from_expr(
            engine,
            first(args),
            context,
            rule_label,
            current_edge,
        )
        target_index = current_edge !== nothing && current_edge.target.label == target_label ?
            current_edge.target.index : 0
        child = current_edge !== nothing && current_edge.target.label == target_label ?
            _execute_runtime_action_edge_child!(engine, current_edge, context) :
            _execute_runtime_rule!(engine, target_label, target_index, context)
        context.retv = child.value
        return _runtime_copy(child.value)
    end

    throw(RuntimeInterpreterException(
        "unsupported runtime helper '$(call.name)' in rule $rule_label",
    ))
end

function _call_runtime_set!(engine, args, context, rule_label, current_edge)
    if length(args) < 2
        return nothing
    end
    value = _runtime_copy(_evaluate_runtime_action_expr!(
        engine,
        args[2],
        context,
        rule_label,
        current_edge,
    ))
    array_target = _runtime_array_target_name(args[1])
    if array_target !== nothing
        context.arrays[array_target] = _runtime_as_array(value)
        return _runtime_copy(context.arrays[array_target])
    end
    throw(RuntimeInterpreterException(
        "set target in rule $rule_label must be array(name) at the rule-dispatch boundary",
    ))
end

function _call_runtime_push!(engine, args, context, rule_label, current_edge)
    if isempty(args)
        child = _require_runtime_action_edge_child!(engine, current_edge, context, rule_label)
        return _append_runtime_array_value!(context, rule_label, child.value)
    end

    if length(args) == 1 && current_edge !== nothing
        child_rule = _runtime_variable_name(first(args))
        if child_rule !== nothing && compiled_rule(engine.compiled_spec, child_rule) !== nothing
            child = child_rule == current_edge.target.label ?
                _execute_runtime_action_edge_child!(engine, current_edge, context) :
                _execute_runtime_rule!(engine, child_rule, 0, context)
            context.retv = child.value
            return _append_runtime_array_value!(context, rule_label, child.value)
        end
        target = _runtime_array_target_name(first(args))
        if target === nothing
            target = _runtime_variable_name(first(args))
        end
        if target === nothing
            throw(RuntimeInterpreterException(
                "push target in rule $rule_label must be array(name) or a variable",
            ))
        end
        child = _execute_runtime_action_edge_child!(engine, current_edge, context)
        context.retv = child.value
        return _append_runtime_array_value!(context, target, child.value)
    end

    if length(args) >= 2
        target = _runtime_array_target_name(args[1])
        if target === nothing
            target = _runtime_variable_name(args[1])
        end
        if target === nothing
            throw(RuntimeInterpreterException(
                "push target in rule $rule_label must be array(name) or a variable",
            ))
        end
        value = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            args[2],
            context,
            rule_label,
            current_edge,
        ))
        return _append_runtime_array_value!(context, target, value)
    end
    return nothing
end

function _call_runtime_array(engine, args, context, rule_label, current_edge)
    if length(args) == 1
        name = _runtime_variable_name(first(args))
        if name !== nothing
            return _runtime_copy(get(context.arrays, name, Any[]))
        end
    end
    return Any[
        _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )) for arg in args
    ]
end

function _read_runtime_retv!(engine, context, current_edge)
    if current_edge === nothing
        return context.retv
    end
    child = _execute_runtime_action_edge_child!(engine, current_edge, context)
    context.retv = child.value
    return child.value
end

function _require_runtime_action_edge_child!(engine, current_edge, context, rule_label)
    if current_edge === nothing
        throw(RuntimeInterpreterException(
            "push() in rule $rule_label requires an action-edge child context",
        ))
    end
    child = _execute_runtime_action_edge_child!(engine, current_edge, context)
    context.retv = child.value
    return child
end

function _execute_runtime_action_edge_child!(
    engine::LinkedSpecRuntimeEngine,
    current_edge::_CurrentRuntimeActionEdge,
    context::_RuntimeExecutionContext,
)
    if current_edge.child_dispatched
        return current_edge.child_result::_RuntimeRuleResult
    end
    current_edge.child_dispatched = true
    child_rule = compiled_rule(engine.compiled_spec, current_edge.target.label)
    if child_rule === nothing
        throw(RuntimeInterpreterException(
            "action edge references undefined child '$(current_edge.target.label)'",
        ))
    end
    if _runtime_passive_terminal_rule(child_rule)
        current_edge.child_result = _RuntimeRuleResult(false, nothing)
        return current_edge.child_result::_RuntimeRuleResult
    end
    current_edge.child_result = _execute_runtime_rule!(
        engine,
        current_edge.target.label,
        current_edge.target.index,
        context,
    )
    return current_edge.child_result::_RuntimeRuleResult
end

function _runtime_passive_terminal_rule(rule::CompiledRule)
    return isempty(rule.lifecycle_action_payloads) &&
        isempty(rule.action_edges) &&
        isempty(rule.blind_edges) &&
        isempty(rule.plain_action_payloads)
end

function _runtime_capture_at(engine, one_match, args, context, rule_label, current_edge)
    if one_match === nothing || isempty(args)
        return nothing
    end
    index_value = _evaluate_runtime_action_expr!(
        engine,
        first(args),
        context,
        rule_label,
        current_edge,
    )
    index = _runtime_int(index_value)
    if index === nothing || index < 0 || index >= length(one_match.captures)
        return nothing
    end
    return one_match.captures[index + 1]
end

function _runtime_named_capture(engine, one_match, args, context, rule_label, current_edge)
    if one_match === nothing || isempty(args)
        return nothing
    end
    name = string(_evaluate_runtime_action_expr!(
        engine,
        first(args),
        context,
        rule_label,
        current_edge,
    ))
    return named_capture(one_match, name)
end

function _runtime_rule_name_from_expr(engine, expr, context, rule_label, current_edge)
    name = _runtime_variable_name(expr)
    if name !== nothing
        return name
    end
    return string(_evaluate_runtime_action_expr!(
        engine,
        expr,
        context,
        rule_label,
        current_edge,
    ))
end

function _runtime_array_target_name(expr)
    if !(expr isa ActionCallExpr) || expr.name != "array" || length(expr.args) != 1
        return nothing
    end
    return _runtime_variable_name(getfield(only(expr.args), :value))
end

_runtime_variable_name(expr) = expr isa ActionVariableExpr ? expr.name : nothing

function _append_runtime_array_value!(context::_RuntimeExecutionContext, name::String, value)
    stored = _runtime_copy(value)
    target = get!(context.arrays, name, Any[])
    push!(target, stored)
    return _runtime_copy(target)
end

function _runtime_int(value)
    if value isa Integer
        return Int(value)
    elseif value isa AbstractFloat && isinteger(value)
        return Int(value)
    elseif value isa AbstractString
        return tryparse(Int, value)
    end
    return nothing
end

_runtime_as_array(value) = value isa AbstractVector ? Any[_runtime_copy(item) for item in value] : Any[]

function _runtime_nextable_bool(callback)
    try
        return _RuntimeNextableBool(Bool(callback()), false)
    catch error
        if error isa _RuntimeActionNext
            return _RuntimeNextableBool(false, true)
        end
        rethrow()
    end
end

_runtime_returned(value) = _RuntimeRuleResult(value !== nothing, _runtime_copy(value))
_runtime_copy(value) = deepcopy(value)

to_json(event::RuntimeLifecycleEvent) = Dict{String,Any}(
    "rule_label" => event.rule_label,
    "lifecycle" => event.lifecycle,
    "line" => event.line,
)

function to_json(result::RuntimeParseResult)
    return Dict{String,Any}(
        "matched" => result.matched,
        "value" => result.value,
        "output" => result.output,
        "cursor_code_unit" => result.cursor_codeunit,
        "cursor_char_offset" => result.cursor_char_offset,
        "lifecycle_events" => [to_json(event) for event in result.lifecycle_events],
    )
end
