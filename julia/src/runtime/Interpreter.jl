struct RuntimeDiagnostic
    type::String
    stage::String
    owner_stage::Union{Nothing,String}
    summary::String
    detail::String
    spec_name::Union{Nothing,String}
    spec_path::Union{Nothing,String}
    top_rule::Union{Nothing,String}
    entry_rule::Union{Nothing,String}
    rule_label::Union{Nothing,String}
    handler_source_label::Union{Nothing,String}
    code::Union{Nothing,String}
    option_name::Union{Nothing,String}
    helper_name::Union{Nothing,String}
    actual_arity::Union{Nothing,Int}
    expected_arity::Union{Nothing,String}
    callable_name::Union{Nothing,String}
    expected::Union{Nothing,String}
    got::Union{Nothing,Int}
    value_kind::Union{Nothing,String}
    name::Union{Nothing,String}
    cycle::Union{Nothing,Vector{String}}
    target_rule::Union{Nothing,String}
    regex_index::Union{Nothing,Int}
    expected_regex_index::Union{Nothing,Int}
    actual_regex_index::Union{Nothing,Int}
end

function RuntimeDiagnostic(;
    type,
    stage,
    summary,
    detail,
    owner_stage = nothing,
    spec_name = nothing,
    spec_path = nothing,
    top_rule = nothing,
    entry_rule = nothing,
    rule_label = nothing,
    handler_source_label = nothing,
    code = nothing,
    option_name = nothing,
    helper_name = nothing,
    actual_arity = nothing,
    expected_arity = nothing,
    callable_name = nothing,
    expected = nothing,
    got = nothing,
    value_kind = nothing,
    name = nothing,
    cycle = nothing,
    target_rule = nothing,
    regex_index = nothing,
    expected_regex_index = nothing,
    actual_regex_index = nothing,
)
    optional_string(value) = value === nothing ? nothing : String(value)
    return RuntimeDiagnostic(
        String(type),
        String(stage),
        optional_string(owner_stage),
        String(summary),
        String(detail),
        optional_string(spec_name),
        optional_string(spec_path),
        optional_string(top_rule),
        optional_string(entry_rule),
        optional_string(rule_label),
        optional_string(handler_source_label),
        optional_string(code),
        optional_string(option_name),
        optional_string(helper_name),
        actual_arity === nothing ? nothing : Int(actual_arity),
        optional_string(expected_arity),
        optional_string(callable_name),
        optional_string(expected),
        got === nothing ? nothing : Int(got),
        optional_string(value_kind),
        optional_string(name),
        cycle === nothing ? nothing : String[String(item) for item in cycle],
        optional_string(target_rule),
        regex_index === nothing ? nothing : Int(regex_index),
        expected_regex_index === nothing ? nothing : Int(expected_regex_index),
        actual_regex_index === nothing ? nothing : Int(actual_regex_index),
    )
end

struct RuntimeInterpreterException <: Exception
    message::String
    diagnostic::Union{Nothing,RuntimeDiagnostic}
end

RuntimeInterpreterException(message::AbstractString; diagnostic = nothing) =
    RuntimeInterpreterException(String(message), diagnostic)

Base.showerror(io::IO, error::RuntimeInterpreterException) = print(io, error.message)

struct OrderedRegexSlotIdentityException <: Exception
    diagnostic::SpecPortableDiagnostic
end

Base.showerror(io::IO, error::OrderedRegexSlotIdentityException) =
    print(io, error.diagnostic.message)

function assert_ordered_regex_slot_identity(;
    rule_label,
    expected_target_rule,
    expected_regex_index,
    actual_target_rule,
    actual_regex_index,
)
    if expected_target_rule == actual_target_rule &&
            expected_regex_index == actual_regex_index
        return nothing
    end
    diagnostic = SpecPortableDiagnostic(
        code = "ordered_regex_slot_identity_lost",
        stage = "execute_rule",
        message = "ordered_regex_slot_identity_lost stage=execute_rule rule_label=$rule_label target_rule=$expected_target_rule expected_regex_index=$expected_regex_index actual_regex_index=$actual_regex_index",
        fields = Dict{String,Any}(
            "rule_label" => String(rule_label),
            "target_rule" => String(expected_target_rule),
            "expected_regex_index" => Int(expected_regex_index),
            "actual_regex_index" => Int(actual_regex_index),
        ),
    )
    throw(OrderedRegexSlotIdentityException(diagnostic))
end

struct RuntimeDiagnosticOutputEvent
    helper_name::String
    rule_label::String
    message::String
end

const RuntimeDiagnosticOutputSink = Function

struct RuntimeExitNow <: Exception
    status::Int
end

Base.showerror(io::IO, error::RuntimeExitNow) = print(io, "RuntimeExitNow($(error.status))")

struct _RuntimeDiagnosticOutputSinkFailure <: Exception
    error::Any
end

mutable struct _RuntimeSemanticObservationFailure
    raised::Bool
    error::Any
end

_RuntimeSemanticObservationFailure() =
    _RuntimeSemanticObservationFailure(false, nothing)

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
    max_iterations::Int
    spec_name::Union{Nothing,String}
    spec_path::Union{Nothing,String}
end

const _PARSE_MODE_OVERRIDE_REMOVED_DETAIL =
    "cursor policy is derived from each rule (OR/default=seek, AND=consume)"

function _removed_parse_mode_override_error(; spec_name = nothing, spec_path = nothing)
    summary = "Global parse mode option has been removed"
    return RuntimeInterpreterException(
        "$summary; $(_PARSE_MODE_OVERRIDE_REMOVED_DETAIL)";
        diagnostic = RuntimeDiagnostic(
            type = "runtime_parser",
            stage = "prepare_options",
            owner_stage = "julia_runtime",
            summary = summary,
            detail = _PARSE_MODE_OVERRIDE_REMOVED_DETAIL,
            spec_name = spec_name,
            spec_path = spec_path,
            handler_source_label = "julia_runtime",
            code = "parse_mode_override_removed",
            option_name = "parse_mode",
        ),
    )
end

function _reject_removed_runtime_options(options; spec_name = nothing, spec_path = nothing)
    if haskey(options, :parse_mode) || haskey(options, :parseMode)
        throw(_removed_parse_mode_override_error(
            spec_name = spec_name,
            spec_path = spec_path,
        ))
    end
    if !isempty(options)
        option = first(keys(options))
        throw(ArgumentError("unsupported runtime option '$(String(option))'"))
    end
    return nothing
end

function LinkedSpecRuntimeEngine(
    compiled_spec::CompiledSpec;
    max_iterations::Int = 10_000,
    spec_name = nothing,
    spec_path = nothing,
    kwargs...,
)
    _reject_removed_runtime_options(kwargs; spec_name = spec_name, spec_path = spec_path)
    if max_iterations <= 0
        throw(ArgumentError("max_iterations must be positive"))
    end
    try
        validate_compiled_regex_slot_identities(compiled_spec)
    catch error
        if error isa SpecValidationException && error.diagnostic !== nothing &&
                error.diagnostic.code == "regex_slot_identity_invalid"
            fields = error.diagnostic.fields
            throw(RuntimeInterpreterException(
                error.diagnostic.message;
                diagnostic = RuntimeDiagnostic(
                    type = "runtime_parser",
                    stage = error.diagnostic.stage,
                    owner_stage = "julia_runtime",
                    summary = "Compiled regex slot identity is invalid",
                    detail = error.diagnostic.message,
                    rule_label = fields["rule_label"],
                    handler_source_label = "julia_runtime:rule:$(fields["rule_label"])",
                    code = error.diagnostic.code,
                    target_rule = fields["target_rule"],
                    regex_index = fields["regex_index"],
                ),
            ))
        end
        rethrow()
    end
    return LinkedSpecRuntimeEngine(
        compiled_spec,
        max_iterations,
        spec_name === nothing ? nothing : String(spec_name),
        spec_path === nothing ? nothing : String(spec_path),
    )
end

struct _RuntimeRuleLocalBinding
    variable_present::Bool
    variable::Any
    array_present::Bool
    array::Any
    hash_present::Bool
    hash::Any
end

mutable struct _RuntimeExecutionContext
    input::String
    cursor_codeunit::Int
    registers::RuntimeMatchRegisters
    retv::Any
    variables::Dict{String,Any}
    arrays::Dict{String,Vector{Any}}
    hashes::Dict{String,Dict{String,Any}}
    mark_buckets::Dict{String,Dict{String,Int}}
    cursor_stack::Vector{Int}
    active_rule_entries::Set{Tuple{String,Int,Int}}
    rule_local_binding_scopes::Vector{Dict{String,_RuntimeRuleLocalBinding}}
    active_user_functions::Vector{String}
    user_function_body_cache::Dict{Int,ActionBlock}
    active_codeblocks::Vector{String}
    codeblock_body_cache::Dict{String,ActionBlock}
    lifecycle_events::Vector{RuntimeLifecycleEvent}
    top_rule::String
    trace::Union{Nothing,LinkedSpecTraceEmitter}
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink}
    semantic_observation_sink::Union{Nothing,RuntimeSemanticObservationSink}
    semantic_observation_failure::Union{Nothing,_RuntimeSemanticObservationFailure}
    generated_families::Union{Nothing,Dict{String,String}}
    generated_source_identity::Union{Nothing,String}
end

function _RuntimeExecutionContext(
    input::AbstractString,
    top_rule::AbstractString,
    trace::Union{Nothing,LinkedSpecTraceEmitter},
    ;
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
    semantic_observation_sink::Union{Nothing,RuntimeSemanticObservationSink} = nothing,
    semantic_observation_failure::Union{Nothing,_RuntimeSemanticObservationFailure} = nothing,
    generated_families = nothing,
    generated_source_identity = nothing,
)
    input_text = String(input)
    return _RuntimeExecutionContext(
        input_text,
        0,
        RuntimeMatchRegisters(input_text),
        nothing,
        Dict{String,Any}(),
        Dict{String,Vector{Any}}(),
        Dict{String,Dict{String,Any}}(),
        Dict{String,Dict{String,Int}}(),
        Int[],
        Set{Tuple{String,Int,Int}}(),
        Dict{String,_RuntimeRuleLocalBinding}[],
        String[],
        Dict{Int,ActionBlock}(),
        String[],
        Dict{String,ActionBlock}(),
        RuntimeLifecycleEvent[],
        String(top_rule),
        trace,
        diagnostic_output_sink,
        semantic_observation_sink,
        semantic_observation_failure,
        generated_families === nothing ?
            nothing : Dict{String,String}(generated_families),
        generated_source_identity === nothing ?
            nothing : String(generated_source_identity),
    )
end

struct _RuntimeEvaluatedAccessSegment
    kind::Symbol
    value::Any
end

struct _RuntimeRegexValue
    pattern::String
    flags::String
end

struct _RuntimeCodeblockValue
    positional_params::Vector{String}
    rest_param::Union{Nothing,String}
    min_arity::Int
    max_arity::Union{Nothing,Int}
    source_text::String
    body_source::String
end

struct _RuntimeRuleResult
    matched::Bool
    value::Any
end

struct _RuntimeRuleExecutionPolicy
    family::String
    cursor_policy::LinkedSpecParseMode
    uses_and_execution::Bool
end

function _enter_runtime_trace_scope!(
    context::_RuntimeExecutionContext,
    topic::AbstractString,
    details::AbstractString,
    level::LinkedSpecTraceLevel,
)
    if context.trace === nothing
        return nothing
    end
    return enter_trace_scope!(context.trace, topic, details, level)
end

function _exit_runtime_trace_scope!(
    context::_RuntimeExecutionContext,
    scope,
    details::AbstractString,
)
    if context.trace !== nothing && scope !== nothing
        exit_trace_scope!(context.trace, scope, details)
    end
    return nothing
end

function _emit_runtime_trace_event!(
    context::_RuntimeExecutionContext,
    kind::LinkedSpecTraceEventKind,
    topic::AbstractString,
    details::AbstractString,
    level::LinkedSpecTraceLevel,
)
    if context.trace !== nothing
        emit_trace_event!(context.trace, kind, topic, details, level)
    end
    return nothing
end

function _trace_runtime_decision!(
    context::_RuntimeExecutionContext,
    topic::AbstractString,
    taken::Bool,
    reason::AbstractString,
    level::LinkedSpecTraceLevel,
)
    if context.trace !== nothing
        trace_decision!(context.trace, topic, taken, reason, level)
    end
    return taken
end

struct _RuntimeActionReturn <: Exception
    value::Any
end

struct _RuntimeActionNext <: Exception end

struct _RuntimeNextableBool
    value::Bool
    nexted::Bool
end

struct _RuntimeValueBlockFlow
    returned::Bool
    value::Any
end

function _runtime_public_parser_start_codeunit(input::String)
    cursor = firstindex(input)
    while cursor <= lastindex(input)
        first_nonspace = cursor
        while first_nonspace <= lastindex(input) && input[first_nonspace] in (' ', '\t')
            first_nonspace = nextind(input, first_nonspace)
        end

        if first_nonspace <= lastindex(input) && input[first_nonspace] == '\n'
            cursor = nextind(input, first_nonspace)
            continue
        elseif first_nonspace <= lastindex(input) && input[first_nonspace] == '#'
            newline = findnext('\n', input, first_nonspace)
            if newline === nothing
                return ncodeunits(input)
            end
            cursor = nextind(input, newline)
            continue
        end
        break
    end
    return cursor - 1
end

struct _RuntimeScopedBinding
    name::String
    variable_present::Bool
    variable::Any
    array_present::Bool
    array::Any
    hash_present::Bool
    hash::Any
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
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
    semantic_observation_sink::Union{Nothing,RuntimeSemanticObservationSink} = nothing,
    _generated_families = nothing,
    _generated_source_identity = nothing,
    _semantic_observation_failure::Union{Nothing,_RuntimeSemanticObservationFailure} = nothing,
)
    selection = try
        resolve_entry_rule(engine.compiled_spec, top_rule)
    catch error
        if error isa EntryRuleSelectionException
            _trace_entry_rule_selection_failure!(trace, top_rule, error)
            throw(RuntimeInterpreterException(
                error.message;
                diagnostic = _runtime_diagnostic(
                    engine;
                    stage = error.stage,
                    summary = "Julia runtime entry-rule selection failed",
                    detail = error.message,
                    top_rule = error.entry_rule,
                    entry_rule = error.entry_rule,
                    rule_label = error.entry_rule,
                    code = error.code,
                ),
            ))
        end
        rethrow()
    end
    label = selection.rule.label
    _trace_entry_rule_selection_success!(trace, top_rule, selection)
    semantic_observation_failure = if semantic_observation_sink === nothing
        nothing
    elseif _semantic_observation_failure === nothing
        _RuntimeSemanticObservationFailure()
    else
        _semantic_observation_failure
    end
    context = _RuntimeExecutionContext(
        input,
        label,
        trace;
        diagnostic_output_sink = diagnostic_output_sink,
        semantic_observation_sink = semantic_observation_sink,
        semantic_observation_failure = semantic_observation_failure,
        generated_families = _generated_families,
        generated_source_identity = _generated_source_identity,
    )
    _set_runtime_cursor!(context, _runtime_public_parser_start_codeunit(context.input))
    trace_scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_runtime:parse",
        "top_rule=$label",
        LinkedSpecTraceHigh,
    )
    trace_exit_details = "error=unknown"
    try
        result = _execute_runtime_rule!(engine, label, 0, context)
        parse_result = RuntimeParseResult(
            result.matched,
            _runtime_copy(result.value),
            # Backend-neutral parser output wraps the top-rule value exactly once.
            Any[_runtime_copy(result.value)],
            context.cursor_codeunit,
            codeunit_offset_to_char_offset(context.input, context.cursor_codeunit),
            RuntimeLifecycleEvent[context.lifecycle_events...],
        )
        _emit_runtime_semantic_rule_result!(context, label, parse_result.cursor_char_offset)
        trace_exit_details =
            "matched=$(parse_result.matched) cursor=$(parse_result.cursor_codeunit)"
        return parse_result
    catch error
        if semantic_observation_failure !== nothing &&
                semantic_observation_failure.raised &&
                semantic_observation_failure.error === error
            trace_exit_details = "error=semantic_observation_sink"
            rethrow()
        elseif error isa _RuntimeDiagnosticOutputSinkFailure
            trace_exit_details = "error=diagnostic_output_sink"
            throw(error.error)
        elseif error isa RuntimeExitNow
            trace_exit_details = "error=exit_now($(error.status))"
            rethrow()
        elseif error isa RuntimeInterpreterException
            wrapped = _with_runtime_diagnostic(
                error,
                _runtime_diagnostic(
                    engine;
                    stage = "runtime_execution",
                    summary = "Julia runtime interpreter failed",
                    detail = error.message,
                    top_rule = label,
                    rule_label = label,
                ),
            )
            trace_exit_details = "error=$(wrapped.message)"
            throw(wrapped)
        end
        trace_exit_details = "error=$(sprint(showerror, error))"
        rethrow()
    finally
        if trace !== nothing && trace_scope !== nothing
            exit_trace_scope!(trace, trace_scope, trace_exit_details)
        end
    end
end

function _trace_entry_rule_selection_success!(
    trace::Union{Nothing,LinkedSpecTraceEmitter},
    explicit_selector,
    selection::ResolvedEntryRule,
)
    trace === nothing && return nothing
    requested = explicit_selector === nothing ? "<default>" : String(explicit_selector)
    trace_decision!(
        trace,
        "julia_runtime:entry_rule_selection",
        true,
        "requested=$requested effective=$(selection.rule.label) " *
            "basis=$(entry_rule_selection_basis_name(selection.basis))",
        LinkedSpecTraceLow,
    )
    return nothing
end

function _trace_entry_rule_selection_failure!(
    trace::Union{Nothing,LinkedSpecTraceEmitter},
    explicit_selector,
    error::EntryRuleSelectionException,
)
    trace === nothing && return nothing
    requested = explicit_selector === nothing ? "<default>" : String(explicit_selector)
    trace_decision!(
        trace,
        "julia_runtime:entry_rule_selection",
        false,
        "requested=$requested effective=<none> basis=<none> " *
            "stage=$(error.stage) code=$(error.code)",
        LinkedSpecTraceLow,
    )
    return nothing
end

runtime_execute(
    engine::LinkedSpecRuntimeEngine,
    input::AbstractString;
    top_rule = nothing,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
    semantic_observation_sink::Union{Nothing,RuntimeSemanticObservationSink} = nothing,
) = runtime_parse(
    engine,
    input;
    top_rule = top_rule,
    trace = trace,
    diagnostic_output_sink = diagnostic_output_sink,
    semantic_observation_sink = semantic_observation_sink,
)

function runtime_parse_with_trace(
    engine::LinkedSpecRuntimeEngine,
    input::AbstractString,
    config::LinkedSpecTraceConfig;
    top_rule = nothing,
    stdout_io::IO = stdout,
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
    semantic_observation_sink::Union{Nothing,RuntimeSemanticObservationSink} = nothing,
)
    trace = LinkedSpecTraceEmitter(config; stdout_io = stdout_io)
    return runtime_parse(
        engine,
        input;
        top_rule = top_rule,
        trace = trace,
        diagnostic_output_sink = diagnostic_output_sink,
        semantic_observation_sink = semantic_observation_sink,
    )
end

function runtime_execute_with_trace(
    engine::LinkedSpecRuntimeEngine,
    input::AbstractString,
    config::LinkedSpecTraceConfig;
    top_rule = nothing,
    stdout_io::IO = stdout,
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
    semantic_observation_sink::Union{Nothing,RuntimeSemanticObservationSink} = nothing,
)
    return runtime_parse_with_trace(
        engine,
        input,
        config;
        top_rule = top_rule,
        stdout_io = stdout_io,
        diagnostic_output_sink = diagnostic_output_sink,
        semantic_observation_sink = semantic_observation_sink,
    )
end

function _execute_runtime_rule!(
    engine::LinkedSpecRuntimeEngine,
    label::String,
    entry_regex_index::Int,
    context::_RuntimeExecutionContext,
)
    rule = compiled_rule(engine.compiled_spec, label)
    if rule === nothing
        detail = "rule '$label' is not compiled"
        throw(RuntimeInterpreterException(
            detail;
            diagnostic = _runtime_context_diagnostic(
                engine,
                context;
                stage = "rule_lookup",
                summary = "Julia runtime rule lookup failed",
                detail = detail,
                rule_label = label,
            ),
        ))
    end

    generated_family = context.generated_families === nothing ?
        nothing : get(context.generated_families, label, nothing)
    if context.generated_families !== nothing && generated_family === nothing
        throw(RuntimeInterpreterException(
            "generated rule plan does not contain '$label'",
        ))
    end
    execution_policy = _runtime_rule_execution_policy(rule, generated_family)

    recursion_key = (label, entry_regex_index, context.cursor_codeunit)
    if recursion_key in context.active_rule_entries
        _trace_runtime_decision!(
            context,
            "julia_runtime:recursion_guard",
            true,
            "rule=$label entry_regex=$entry_regex_index cursor=$(context.cursor_codeunit)",
            LinkedSpecTraceDebug,
        )
        return _RuntimeRuleResult(false, nothing)
    end

    push!(context.active_rule_entries, recursion_key)
    push!(context.rule_local_binding_scopes, Dict{String,_RuntimeRuleLocalBinding}())
    saved_registers = context.registers
    context.registers = enter_child(saved_registers)
    trace_scope = _enter_runtime_trace_scope!(
        context,
        "julia_runtime:rule",
        "rule=$label entry_regex=$entry_regex_index mode=$(rule.mode_metadata.name) " *
        "family=$(execution_policy.family) " *
        "cursor_policy=$(parse_mode_name(execution_policy.cursor_policy)) " *
        "cursor=$(context.cursor_codeunit)",
        LinkedSpecTraceHigh,
    )
    if generated_family !== nothing && context.generated_source_identity !== nothing
        identity = context.generated_source_identity
        _emit_runtime_trace_event!(
            context,
            LinkedSpecTraceMark,
            "generated_rule_enter",
            "source_identity=$identity rule=$label entry_regex_idx=$entry_regex_index cursor=$(context.cursor_codeunit)",
            LinkedSpecTraceLow,
        )
        _emit_runtime_trace_event!(
            context,
            LinkedSpecTraceMark,
            "generated_family_decision",
            "source_identity=$identity rule=$label family=$generated_family",
            LinkedSpecTraceLow,
        )
    end

    try
        init_return = _execute_runtime_lifecycle!(engine, rule, "I", context)
        if init_return !== nothing
            return _runtime_returned(init_return.value)
        end

        try
            uses_blind_dispatch = generated_family === nothing ?
                !isempty(rule.blind_edges) : _generated_family_uses_blind_dispatch(generated_family)
            if uses_blind_dispatch
                return _execute_runtime_blind_rule!(
                    engine,
                    rule,
                    context;
                    uses_and_execution = execution_policy.uses_and_execution,
                )
            end
            return _execute_runtime_regex_rule!(
                engine,
                rule,
                entry_regex_index,
                context;
                cursor_policy = execution_policy.cursor_policy,
                uses_and_execution = execution_policy.uses_and_execution,
            )
        catch error
            if error isa _RuntimeActionReturn
                return _runtime_returned(error.value)
            end
            rethrow()
        end
    catch error
        if error isa RuntimeInterpreterException
            throw(_with_runtime_diagnostic(
                error,
                _runtime_context_diagnostic(
                    engine,
                    context;
                    stage = "runtime_execution",
                    summary = "Julia runtime interpreter failed",
                    detail = error.message,
                    rule_label = label,
                ),
            ))
        end
        rethrow()
    finally
        if generated_family !== nothing && context.generated_source_identity !== nothing
            _emit_runtime_trace_event!(
                context,
                LinkedSpecTraceMark,
                "generated_rule_exit",
                "source_identity=$(context.generated_source_identity) rule=$label family=$generated_family cursor=$(context.cursor_codeunit)",
                LinkedSpecTraceLow,
            )
        end
        _exit_runtime_trace_scope!(
            context,
            trace_scope,
            "rule=$label cursor=$(context.cursor_codeunit)",
        )
        _restore_runtime_rule_local_bindings!(context)
        context.registers = saved_registers
        delete!(context.active_rule_entries, recursion_key)
    end
end

function _runtime_rule_execution_policy(
    rule::CompiledRule,
    generated_family,
)
    family = rule_family(rule.mode_metadata)
    if generated_family !== nothing
        return _RuntimeRuleExecutionPolicy(
            family,
            _generated_family_cursor_policy(generated_family),
            _generated_family_uses_and_execution(generated_family),
        )
    end
    return _RuntimeRuleExecutionPolicy(
        family,
        rule.mode_metadata.is_and ? ConsumeParseMode : SeekParseMode,
        rule.mode_metadata.is_and,
    )
end

function _collects_explicit_action_iteration_values(rule::CompiledRule)
    return !isempty(rule.action_edges) && rule.mode_metadata.name in (
        "Star",
        "Plus",
        "Optional",
        "Or",
        "OrPlus",
        "OrBounded",
    )
end

function _execute_runtime_blind_rule!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    context::_RuntimeExecutionContext,
    ;
    uses_and_execution::Bool,
)
    minimum = rule.mode_metadata.rep_min
    if minimum === nothing
        implicit_and_result = Any[]
        matched_any = false
        for _ in 1:engine.max_iterations
            before = context.cursor_codeunit
            matched = _runtime_nextable_bool(() -> _execute_runtime_blind_once!(
                engine,
                rule,
                context;
                uses_and_execution = uses_and_execution,
                implicit_and_result = implicit_and_result,
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
            value = uses_and_execution && !isempty(implicit_and_result) ?
                Any[implicit_and_result...] : nothing
            return _RuntimeRuleResult(matched.value || matched_any, value)
        end
        loop_exit = _execute_runtime_lifecycle!(engine, rule, "LX", context)
        if loop_exit !== nothing
            return _runtime_returned(loop_exit.value)
        end
        exit_return = _execute_runtime_lifecycle!(engine, rule, "E", context)
        if exit_return !== nothing
            return _runtime_returned(exit_return.value)
        end
        value = uses_and_execution && !isempty(implicit_and_result) ?
            Any[implicit_and_result...] : nothing
        return _RuntimeRuleResult(matched_any, value)
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

        matched = _runtime_nextable_bool(() -> _execute_runtime_blind_once!(
            engine,
            rule,
            context;
            uses_and_execution = uses_and_execution,
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
    context::_RuntimeExecutionContext;
    uses_and_execution::Bool,
    implicit_and_result = nothing,
)
    if uses_and_execution
        for (edge_index, edge) in enumerate(rule.blind_edges)
            cursor_before = context.cursor_codeunit
            child = _execute_runtime_rule!(
                engine,
                edge.target.label,
                edge.target.index,
                context,
            )
            _trace_runtime_decision!(
                context,
                "julia_runtime:child_dispatch",
                child.matched,
                "edge_family=blind mode=AND rule=$(rule.label) index=$(edge_index - 1) " *
                "target=$(edge.target.label)[$(edge.target.index)] cursor_before=$cursor_before " *
                "cursor_after=$(context.cursor_codeunit)",
                LinkedSpecTraceDebug,
            )
            context.retv = child.value
            if child.matched && implicit_and_result !== nothing
                push!(implicit_and_result, _runtime_copy(child.value))
            end
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

    for (edge_index, edge) in enumerate(rule.blind_edges)
        cursor_before = context.cursor_codeunit
        child = _execute_runtime_rule!(engine, edge.target.label, edge.target.index, context)
        _trace_runtime_decision!(
            context,
            "julia_runtime:child_dispatch",
            child.matched,
            "edge_family=blind mode=OR rule=$(rule.label) index=$(edge_index - 1) " *
            "target=$(edge.target.label)[$(edge.target.index)] cursor_before=$cursor_before " *
            "cursor_after=$(context.cursor_codeunit)",
            LinkedSpecTraceDebug,
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
    ;
    cursor_policy::LinkedSpecParseMode,
    uses_and_execution::Bool,
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
                cursor_policy = cursor_policy,
                and_sequence = uses_and_execution && length(rule.regex_patterns) > 1,
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

    action_iteration_values = _collects_explicit_action_iteration_values(rule) ? Any[] : nothing
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
            cursor_policy = cursor_policy,
            and_sequence = uses_and_execution && length(rule.regex_patterns) > 1,
            action_iteration_values = action_iteration_values,
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
        if action_iteration_values !== nothing
            return _RuntimeRuleResult(false, nothing)
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
    value = action_iteration_values === nothing ?
        nothing : Any[action_iteration_values...]
    return _RuntimeRuleResult(matches > 0, value)
end

function _execute_runtime_regex_once!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    context::_RuntimeExecutionContext;
    entry_regex_index::Int = 0,
    cursor_policy::LinkedSpecParseMode,
    and_sequence::Bool = false,
    action_iteration_values = nothing,
)
    cursor_before = context.cursor_codeunit
    if isempty(rule.regex_patterns)
        _trace_runtime_regex_decision!(
            context,
            rule,
            nothing,
            cursor_before,
            "cursor_policy=$(parse_mode_name(cursor_policy)) patterns=0",
        )
        return false
    end

    alternation = RuntimeRegexAlternation(rule)

    if and_sequence
        for expected_index in eachindex(rule.regex_patterns)
            zero_based_index = expected_index - 1
            one_match = _match_runtime_specific(
                alternation,
                zero_based_index,
                context,
                cursor_policy,
            )
            _trace_runtime_regex_decision!(
                context,
                rule,
                one_match,
                context.cursor_codeunit,
                "cursor_policy=$(parse_mode_name(cursor_policy)) mode=AND " *
                "expected_index=$zero_based_index",
            )
            if one_match === nothing
                return false
            end
            expected_target, expected_regex_index =
                _runtime_regex_slot_identity(rule, zero_based_index)
            actual_target, actual_regex_index =
                _runtime_regex_slot_identity(rule, one_match.alternative_index)
            assert_ordered_regex_slot_identity(
                rule_label = rule.label,
                expected_target_rule = expected_target,
                expected_regex_index = expected_regex_index,
                actual_target_rule = actual_target,
                actual_regex_index = actual_regex_index,
            )
            _record_runtime_regex_slot_selected!(
                context,
                rule.label,
                "ordered_required",
                expected_target,
                expected_regex_index,
                one_match.codeunit_end,
            )
            _accept_runtime_regex_match!(
                engine,
                rule,
                one_match,
                context;
                action_iteration_values = action_iteration_values,
            )
            loop_end = _execute_runtime_lifecycle!(engine, rule, "LE", context)
            if loop_end !== nothing
                throw(loop_end)
            end
        end
        return true
    end

    one_match = if entry_regex_index > 0 && entry_regex_index < length(rule.regex_patterns)
        _match_runtime_specific(
            alternation,
            entry_regex_index,
            context,
            cursor_policy,
        )
    else
        runtime_match(
            alternation,
            context.input,
            context.cursor_codeunit;
            parse_mode = cursor_policy,
        )
    end
    _trace_runtime_regex_decision!(
        context,
        rule,
        one_match,
        cursor_before,
        "cursor_policy=$(parse_mode_name(cursor_policy)) entry_regex=$entry_regex_index",
    )
    if one_match === nothing
        return false
    end

    target_rule, regex_index =
        _runtime_regex_slot_identity(rule, one_match.alternative_index)
    selection_role = rule.mode_metadata.is_and ? "ordered_required" : "choice"
    _record_runtime_regex_slot_selected!(
        context,
        rule.label,
        selection_role,
        target_rule,
        regex_index,
        one_match.codeunit_end,
    )

    _accept_runtime_regex_match!(
        engine,
        rule,
        one_match,
        context;
        action_iteration_values = action_iteration_values,
    )
    loop_end = _execute_runtime_lifecycle!(engine, rule, "LE", context)
    if loop_end !== nothing
        throw(loop_end)
    end
    return true
end

function _trace_runtime_regex_decision!(
    context::_RuntimeExecutionContext,
    rule::CompiledRule,
    one_match,
    cursor_before::Int,
    reason::AbstractString,
)
    matched = one_match !== nothing
    alternative = matched ? one_match.alternative_index : -1
    match_start = matched ? one_match.codeunit_start : -1
    match_end = matched ? one_match.codeunit_end : -1
    _trace_runtime_decision!(
        context,
        "julia_runtime:regex_match",
        matched,
        "rule=$(rule.label) $reason alternative=$alternative match_start=$match_start " *
        "match_end=$match_end cursor_before=$cursor_before",
        LinkedSpecTraceDebug,
    )
    return nothing
end

function _match_runtime_specific(
    alternation::RuntimeRegexAlternation,
    zero_based_index::Int,
    context::_RuntimeExecutionContext,
    cursor_policy::LinkedSpecParseMode,
)
    return match_runtime_regex_slot(
        alternation,
        zero_based_index,
        context.input,
        context.cursor_codeunit;
        parse_mode = cursor_policy,
    )
end

function _runtime_regex_slot_identity(rule::CompiledRule, alternative_index::Int)
    for edge in rule.action_edges
        if edge.regex_index == alternative_index
            target = only(edge.targets)
            return (target.label, edge.child_regex_index)
        end
    end
    return (rule.label, alternative_index)
end

function _record_runtime_regex_slot_selected!(
    context::_RuntimeExecutionContext,
    rule_label::AbstractString,
    selection_role::AbstractString,
    target_rule::AbstractString,
    regex_index::Int,
    position_codeunit::Int,
)
    _emit_runtime_semantic_regex_slot_selected!(
        context,
        rule_label,
        target_rule,
        regex_index,
        position_codeunit,
    )
    _emit_runtime_trace_event!(
        context,
        LinkedSpecTraceMark,
        "julia_runtime:regex_slot_selected",
        "rule_label=$rule_label selection_role=$selection_role target_rule=$target_rule regex_index=$regex_index",
        LinkedSpecTraceHigh,
    )
    return nothing
end

function _emit_runtime_semantic_regex_slot_selected!(
    context::_RuntimeExecutionContext,
    rule_label::AbstractString,
    target_rule::AbstractString,
    regex_index::Int,
    position_codeunit::Int,
)
    context.semantic_observation_sink === nothing && return nothing
    position = codeunit_offset_to_char_offset(context.input, position_codeunit)
    event = _runtime_semantic_regex_slot_selected_event(
        rule_label,
        target_rule,
        regex_index,
        position,
    )
    return _invoke_runtime_semantic_observation_sink!(context, event)
end

function _emit_runtime_semantic_rule_result!(
    context::_RuntimeExecutionContext,
    rule_label::AbstractString,
    position::Int,
)
    context.semantic_observation_sink === nothing && return nothing
    event = _runtime_semantic_rule_result_event(
        rule_label,
        position,
        context.input,
    )
    return _invoke_runtime_semantic_observation_sink!(context, event)
end

function _invoke_runtime_semantic_observation_sink!(
    context::_RuntimeExecutionContext,
    event::RuntimeSemanticObservationEvent,
)
    sink = context.semantic_observation_sink
    sink === nothing && return nothing
    try
        sink(event)
    catch error
        failure = context.semantic_observation_failure
        if failure !== nothing
            failure.raised = true
            failure.error = error
        end
        rethrow()
    end
    return nothing
end

function _accept_runtime_regex_match!(
    engine::LinkedSpecRuntimeEngine,
    rule::CompiledRule,
    one_match::RuntimeRegexMatch,
    context::_RuntimeExecutionContext,
    ;
    action_iteration_values = nothing,
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
            if action_iteration_values === nothing
                throw(action_return)
            end
            push!(action_iteration_values, _runtime_copy(action_return.value))
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
        _emit_runtime_trace_event!(
            context,
            LinkedSpecTraceMark,
            "julia_runtime:lifecycle_block",
            "rule=$(rule.label) lifecycle=$lifecycle line=$(payload.line) cursor=$(context.cursor_codeunit)",
            LinkedSpecTraceHigh,
        )
        if lifecycle == "I"
            for statement in payload.action_ast.statements
                if statement.expr isa ActionAssignScalarExpr
                    _record_runtime_rule_local_binding!(context, statement.expr.name)
                elseif statement.expr isa ActionCallExpr &&
                        statement.expr.name == "set" &&
                        !isempty(statement.expr.args)
                    target = _runtime_variable_name(first(statement.expr.args).value)
                    if target !== nothing
                        _record_runtime_rule_local_binding!(context, target)
                    end
                end
            end
        end
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
        index = 1
        stop = length(block.statements) + 1
        while index < stop
            index = _execute_runtime_action_statement_at!(
                engine,
                block.statements,
                index,
                stop,
                context,
                rule_label,
                current_edge,
            ) + 1
        end
        return nothing
    catch error
        if error isa _RuntimeActionReturn
            return error
        elseif error isa _RuntimeActionNext || error isa RuntimeInterpreterException ||
               error isa RuntimeExitNow || error isa _RuntimeDiagnosticOutputSinkFailure
            rethrow()
        end
        throw(RuntimeInterpreterException(
            "action block failed in rule $rule_label: $(sprint(showerror, error))",
        ))
    end
end

function _execute_runtime_action_statement_at!(
    engine,
    statements,
    index,
    stop,
    context,
    rule_label,
    current_edge,
)
    statement = statements[index]
    expr = statement.expr
    if expr isa ActionControlIfExpr && expr.branch_role == "if" && expr.body !== nothing
        return _execute_runtime_attached_if_chain!(
            engine,
            statements,
            index,
            stop,
            context,
            rule_label,
            current_edge,
        )
    elseif expr isa ActionControlIfExpr && expr.branch_role == "if" && expr.body === nothing
        selection = _select_runtime_marker_if_chain(
            engine,
            statements,
            index,
            stop,
            context,
            rule_label,
            current_edge,
        )
        if selection.start !== nothing && selection.stop !== nothing
            _execute_runtime_action_statement_range!(
                engine,
                statements,
                selection.start,
                selection.stop,
                context,
                rule_label,
                current_edge,
            )
        end
        return selection.next_index
    elseif expr isa ActionControlWhileExpr && expr.body !== nothing
        _execute_runtime_attached_while!(
            engine,
            expr,
            context,
            rule_label,
            current_edge,
        )
        return index
    elseif _runtime_is_marker_switch_start(expr)
        selection = _select_runtime_marker_switch_chain(
            engine,
            statements,
            index,
            stop,
            context,
            rule_label,
            current_edge,
        )
        if selection.start !== nothing && selection.stop !== nothing
            _execute_runtime_action_statement_range!(
                engine,
                statements,
                selection.start,
                selection.stop,
                context,
                rule_label,
                current_edge,
            )
        end
        return selection.next_index
    elseif expr isa ActionControlSwitchExpr && (!isempty(expr.cases) || expr.default_case !== nothing)
        body = _select_runtime_switch_body(
            engine,
            expr,
            context,
            rule_label,
            current_edge,
        )
        if body !== nothing
            result = _execute_runtime_action_block!(
                engine,
                body,
                context,
                rule_label,
                current_edge,
            )
            if result !== nothing
                throw(result)
            end
        end
        return index
    elseif (expr isa ActionControlIfExpr && expr.branch_role == "elseif") ||
           expr isa ActionControlElseExpr || expr isa ActionControlCaseExpr ||
           expr isa ActionControlDefaultExpr || expr isa ActionControlMarkerExpr
        return index
    end

    _evaluate_runtime_action_expr!(
        engine,
        expr,
        context,
        rule_label,
        current_edge,
        statement.drops_value,
    )
    return index
end

function _execute_runtime_action_statement_range!(
    engine,
    statements,
    start,
    stop,
    context,
    rule_label,
    current_edge,
)
    index = start
    while index < stop
        index = _execute_runtime_action_statement_at!(
            engine,
            statements,
            index,
            stop,
            context,
            rule_label,
            current_edge,
        ) + 1
    end
    return nothing
end

function _execute_runtime_attached_if_chain!(
    engine,
    statements,
    index,
    stop,
    context,
    rule_label,
    current_edge,
)
    selected_body = nothing
    next_index = index
    cursor = index
    while cursor < stop
        expr = statements[cursor].expr
        if cursor == index
            if _runtime_truthy(_evaluate_runtime_action_expr!(
                    engine,
                    expr.condition,
                    context,
                    rule_label,
                    current_edge,
                ))
                selected_body = expr.body
            end
        elseif expr isa ActionControlIfExpr && expr.branch_role == "elseif"
            if selected_body === nothing && _runtime_truthy(_evaluate_runtime_action_expr!(
                    engine,
                    expr.condition,
                    context,
                    rule_label,
                    current_edge,
                ))
                selected_body = expr.body
            end
        elseif expr isa ActionControlElseExpr
            if selected_body === nothing
                selected_body = expr.body
            end
        else
            break
        end
        next_index = cursor
        if expr isa ActionControlElseExpr
            break
        end
        cursor += 1
    end
    if selected_body !== nothing
        result = _execute_runtime_action_block!(
            engine,
            selected_body,
            context,
            rule_label,
            current_edge,
        )
        if result !== nothing
            throw(result)
        end
    end
    return next_index
end

function _execute_runtime_attached_while!(engine, expr, context, rule_label, current_edge)
    for _ in 1:engine.max_iterations
        if !_runtime_truthy(_evaluate_runtime_action_expr!(
                engine,
                expr.condition,
                context,
                rule_label,
                current_edge,
            ))
            return nothing
        end
        result = _execute_runtime_action_block!(
            engine,
            expr.body,
            context,
            rule_label,
            current_edge,
        )
        if result !== nothing
            throw(result)
        end
    end
    throw(RuntimeInterpreterException(
        "LinkedSpec while iteration safety limit exceeded after $(engine.max_iterations) iterations",
    ))
end

function _select_runtime_switch_body(engine, expr, context, rule_label, current_edge)
    selector = _evaluate_runtime_action_expr!(
        engine,
        expr.source_expr,
        context,
        rule_label,
        current_edge,
    )
    for item in expr.cases
        if !(item isa ActionControlCaseExpr)
            continue
        end
        candidate = item.match isa ActionVariableExpr ? item.match.name :
            _evaluate_runtime_action_expr!(
                engine,
                item.match,
                context,
                rule_label,
                current_edge,
            )
        if _runtime_string(candidate) == _runtime_string(selector)
            return item.body
        end
    end
    return expr.default_case isa ActionControlDefaultExpr ? expr.default_case.body : nothing
end

function _select_runtime_marker_if_chain(
    engine,
    statements,
    index,
    stop,
    context,
    rule_label,
    current_edge,
)
    first_expr = statements[index].expr
    selected_start = nothing
    selected_stop = nothing
    selected = _runtime_truthy(_evaluate_runtime_action_expr!(
        engine,
        first_expr.condition,
        context,
        rule_label,
        current_edge,
    ))
    if selected
        selected_start = index + 1
    end
    depth = 0
    next_index = stop - 1
    cursor = index + 1
    while cursor < stop
        expr = statements[cursor].expr
        if _runtime_is_marker_if_start(expr)
            depth += 1
            cursor += 1
            continue
        elseif _runtime_is_marker_if_end(expr)
            if depth > 0
                depth -= 1
                cursor += 1
                continue
            end
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            next_index = cursor
            break
        elseif depth == 0 && expr isa ActionControlIfExpr &&
               expr.branch_role == "elseif" && expr.body === nothing
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            if !selected && _runtime_truthy(_evaluate_runtime_action_expr!(
                    engine,
                    expr.condition,
                    context,
                    rule_label,
                    current_edge,
                ))
                selected_start = cursor + 1
                selected = true
            end
        elseif depth == 0 && expr isa ActionControlElseExpr && expr.body === nothing
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            if !selected
                selected_start = cursor + 1
                selected = true
            end
        end
        cursor += 1
    end
    if selected && selected_stop === nothing
        selected_stop = stop
    end
    return (start = selected_start, stop = selected_stop, next_index = next_index)
end

_runtime_is_marker_if_start(expr) = expr isa ActionControlIfExpr &&
    expr.branch_role == "if" && expr.body === nothing

_runtime_is_marker_if_end(expr) = expr isa ActionControlMarkerExpr &&
    expr.canonical_keyword == "endif"

function _select_runtime_marker_switch_chain(
    engine,
    statements,
    index,
    stop,
    context,
    rule_label,
    current_edge,
)
    first_expr = statements[index].expr
    selector = _evaluate_runtime_action_expr!(
        engine,
        first_expr.source_expr,
        context,
        rule_label,
        current_edge,
    )
    selected_start = nothing
    selected_stop = nothing
    selected = false
    branch_matched = false
    depth = 0
    next_index = stop - 1
    cursor = index + 1
    while cursor < stop
        expr = statements[cursor].expr
        if _runtime_is_marker_switch_start(expr)
            depth += 1
            cursor += 1
            continue
        elseif _runtime_is_marker_switch_end(expr)
            if depth > 0
                depth -= 1
                cursor += 1
                continue
            end
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            next_index = cursor
            break
        elseif depth == 0 && expr isa ActionControlCaseExpr && expr.body === nothing
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            selected = false
            if !branch_matched
                candidate = expr.match isa ActionVariableExpr ? expr.match.name :
                    _evaluate_runtime_action_expr!(
                        engine,
                        expr.match,
                        context,
                        rule_label,
                        current_edge,
                    )
                if _runtime_string(candidate) == _runtime_string(selector)
                    selected_start = cursor + 1
                    selected = true
                    branch_matched = true
                end
            end
        elseif depth == 0 && expr isa ActionControlDefaultExpr && expr.body === nothing
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            selected = false
            if !branch_matched
                selected_start = cursor + 1
                selected = true
                branch_matched = true
            end
        elseif depth == 0 && _runtime_is_marker_case_end(expr)
            if selected && selected_stop === nothing
                selected_stop = cursor
            end
            selected = false
        end
        cursor += 1
    end
    if selected && selected_stop === nothing
        selected_stop = stop
    end
    return (start = selected_start, stop = selected_stop, next_index = next_index)
end

_runtime_is_marker_switch_start(expr) = expr isa ActionControlSwitchExpr &&
    expr.body === nothing && isempty(expr.cases) && expr.default_case === nothing

_runtime_is_marker_switch_end(expr) = expr isa ActionControlMarkerExpr &&
    expr.canonical_keyword == "endswitch"

_runtime_is_marker_case_end(expr) = expr isa ActionControlMarkerExpr &&
    expr.canonical_keyword == "endcase"

function _evaluate_runtime_block_value!(engine, block, context, rule_label, current_edge)
    flow = _execute_runtime_value_statements!(
        engine,
        block.statements,
        1,
        length(block.statements) + 1,
        context,
        rule_label,
        current_edge;
        final_expression_yields = true,
    )
    return flow.returned ? flow.value : nothing
end

function _execute_runtime_value_statements!(
    engine,
    statements,
    start,
    stop,
    context,
    rule_label,
    current_edge;
    final_expression_yields::Bool,
)
    index = start
    while index < stop
        statement = statements[index]
        expr = statement.expr
        is_last = index == stop - 1

        if expr isa ActionControlIfExpr && expr.branch_role == "if" && expr.body !== nothing
            step = _execute_runtime_value_attached_if_chain!(
                engine,
                statements,
                index,
                stop,
                context,
                rule_label,
                current_edge,
            )
            if step.flow.returned
                return step.flow
            elseif is_last && final_expression_yields
                return _RuntimeValueBlockFlow(true, nothing)
            end
            index = step.next_index + 1
            continue
        elseif expr isa ActionControlIfExpr && expr.branch_role == "if" && expr.body === nothing
            selection = _select_runtime_marker_if_chain(
                engine,
                statements,
                index,
                stop,
                context,
                rule_label,
                current_edge,
            )
            if selection.start !== nothing && selection.stop !== nothing
                flow = _execute_runtime_value_statements!(
                    engine,
                    statements,
                    selection.start,
                    selection.stop,
                    context,
                    rule_label,
                    current_edge;
                    final_expression_yields = false,
                )
                if flow.returned
                    return flow
                end
            end
            if is_last && final_expression_yields
                return _RuntimeValueBlockFlow(true, nothing)
            end
            index = selection.next_index + 1
            continue
        elseif expr isa ActionControlWhileExpr && expr.body !== nothing
            flow = _execute_runtime_value_while!(
                engine,
                expr,
                context,
                rule_label,
                current_edge,
            )
            if flow.returned
                return flow
            elseif is_last && final_expression_yields
                return _RuntimeValueBlockFlow(true, nothing)
            end
            index += 1
            continue
        elseif _runtime_is_marker_switch_start(expr)
            selection = _select_runtime_marker_switch_chain(
                engine,
                statements,
                index,
                stop,
                context,
                rule_label,
                current_edge,
            )
            if selection.start !== nothing && selection.stop !== nothing
                flow = _execute_runtime_value_statements!(
                    engine,
                    statements,
                    selection.start,
                    selection.stop,
                    context,
                    rule_label,
                    current_edge;
                    final_expression_yields = false,
                )
                if flow.returned
                    return flow
                end
            end
            if is_last && final_expression_yields
                return _RuntimeValueBlockFlow(true, nothing)
            end
            index = selection.next_index + 1
            continue
        elseif expr isa ActionControlSwitchExpr && (!isempty(expr.cases) || expr.default_case !== nothing)
            body = _select_runtime_switch_body(
                engine,
                expr,
                context,
                rule_label,
                current_edge,
            )
            if body !== nothing
                flow = _execute_runtime_value_statements!(
                    engine,
                    body.statements,
                    1,
                    length(body.statements) + 1,
                    context,
                    rule_label,
                    current_edge;
                    final_expression_yields = false,
                )
                if flow.returned
                    return flow
                end
            end
            if is_last && final_expression_yields
                return _RuntimeValueBlockFlow(true, nothing)
            end
            index += 1
            continue
        elseif (expr isa ActionControlIfExpr && expr.branch_role == "elseif") ||
               expr isa ActionControlElseExpr || expr isa ActionControlCaseExpr ||
               expr isa ActionControlDefaultExpr || expr isa ActionControlMarkerExpr
            if is_last && final_expression_yields
                return _RuntimeValueBlockFlow(true, nothing)
            end
            index += 1
            continue
        end

        local_return = _runtime_local_return_payload(expr)
        if local_return !== nothing
            value = local_return.has_value ? _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                local_return.value,
                context,
                rule_label,
                current_edge,
            )) : nothing
            return _RuntimeValueBlockFlow(true, value)
        elseif is_last && final_expression_yields
            return _RuntimeValueBlockFlow(true, _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                expr,
                context,
                rule_label,
                current_edge,
            )))
        end

        _evaluate_runtime_action_expr!(
            engine,
            expr,
            context,
            rule_label,
            current_edge,
            true,
        )
        index += 1
    end
    return _RuntimeValueBlockFlow(false, nothing)
end

function _execute_runtime_value_attached_if_chain!(
    engine,
    statements,
    index,
    stop,
    context,
    rule_label,
    current_edge,
)
    selected_body = nothing
    next_index = index
    cursor = index
    while cursor < stop
        expr = statements[cursor].expr
        if cursor == index
            if _runtime_truthy(_evaluate_runtime_action_expr!(
                    engine,
                    expr.condition,
                    context,
                    rule_label,
                    current_edge,
                ))
                selected_body = expr.body
            end
        elseif expr isa ActionControlIfExpr && expr.branch_role == "elseif"
            if selected_body === nothing && _runtime_truthy(_evaluate_runtime_action_expr!(
                    engine,
                    expr.condition,
                    context,
                    rule_label,
                    current_edge,
                ))
                selected_body = expr.body
            end
        elseif expr isa ActionControlElseExpr
            if selected_body === nothing
                selected_body = expr.body
            end
        else
            break
        end
        next_index = cursor
        if expr isa ActionControlElseExpr
            break
        end
        cursor += 1
    end

    flow = selected_body === nothing ? _RuntimeValueBlockFlow(false, nothing) :
        _execute_runtime_value_statements!(
            engine,
            selected_body.statements,
            1,
            length(selected_body.statements) + 1,
            context,
            rule_label,
            current_edge;
            final_expression_yields = false,
        )
    return (next_index = next_index, flow = flow)
end

function _execute_runtime_value_while!(engine, expr, context, rule_label, current_edge)
    for _ in 1:engine.max_iterations
        if !_runtime_truthy(_evaluate_runtime_action_expr!(
                engine,
                expr.condition,
                context,
                rule_label,
                current_edge,
            ))
            return _RuntimeValueBlockFlow(false, nothing)
        end
        flow = _execute_runtime_value_statements!(
            engine,
            expr.body.statements,
            1,
            length(expr.body.statements) + 1,
            context,
            rule_label,
            current_edge;
            final_expression_yields = false,
        )
        if flow.returned
            return flow
        end
    end
    throw(RuntimeInterpreterException(
        "LinkedSpec while iteration safety limit exceeded after $(engine.max_iterations) iterations",
    ))
end

function _runtime_local_return_payload(expr)
    if !(expr isa ActionCallExpr)
        return nothing
    end
    helper_name = canonical_action_helper_name(expr.name)
    if helper_name == "return_undef" && isempty(expr.args)
        return (has_value = false, value = nothing)
    elseif helper_name != "return"
        return nothing
    end
    return isempty(expr.args) ? (has_value = false, value = nothing) :
        (has_value = true, value = first(expr.args).value)
end

function _evaluate_runtime_action_expr!(
    engine::LinkedSpecRuntimeEngine,
    expr::ActionExpr,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
    statement_context::Bool = false,
)
    if expr isa ActionStringLiteralExpr || expr isa ActionNumberLiteralExpr || expr isa ActionBooleanLiteralExpr
        return expr.value
    elseif expr isa ActionRegexLiteralExpr
        return _RuntimeRegexValue(expr.pattern, expr.flags)
    elseif expr isa ActionUndefExpr
        return nothing
    elseif expr isa ActionVariableExpr
        if expr.name == "retv"
            return _read_runtime_retv!(engine, context, current_edge)
        end
        value = _read_runtime_store(context, expr.name)
        if value === nothing && !_runtime_binding_present(context, expr.name) &&
                compiled_rule(engine.compiled_spec, expr.name) !== nothing
            return Any[]
        end
        return _runtime_copy(value)
    elseif expr isa ActionArrayLiteralExpr
        result = Any[]
        for item in expr.items
            value = _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                item,
                context,
                rule_label,
                current_edge,
            ))
            _append_runtime_array_argument!(result, item, value)
        end
        return result
    elseif expr isa ActionHashLiteralExpr
        result = Dict{String,Any}()
        for entry in expr.entries
            key = _runtime_string(_evaluate_runtime_action_expr!(
                engine,
                entry.key,
                context,
                rule_label,
                current_edge,
            ))
            result[key] = _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                entry.value,
                context,
                rule_label,
                current_edge,
            ))
        end
        return result
    elseif expr isa ActionAssignScalarExpr
        value = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            expr.value,
            context,
            rule_label,
            current_edge,
        ))
        return _store_runtime_bare_binding!(context, expr.name, value)
    elseif expr isa ActionAssignArrayAppendExpr
        value = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            expr.value,
            context,
            rule_label,
            current_edge,
        ))
        return _append_runtime_array_value!(context, expr.name, value)
    elseif expr isa ActionAssignHashIndexExpr
        return _assign_runtime_index!(
            engine,
            context,
            expr.name,
            expr.key,
            expr.value,
            rule_label,
            current_edge,
        )
    elseif expr isa ActionAssignNestedAccessExpr
        return _assign_runtime_nested!(
            engine,
            context,
            expr.base,
            expr.segments,
            expr.value,
            rule_label,
            current_edge,
        )
    elseif expr isa ActionIndexedVarExpr
        collection = _read_runtime_store(context, expr.name)
        index = _evaluate_runtime_action_expr!(
            engine,
            expr.index,
            context,
            rule_label,
            current_edge,
        )
        return _runtime_copy(_runtime_index_value(collection, index))
    elseif expr isa ActionNestedAccessExpr
        root = expr.base == "retv" ?
            _read_runtime_retv!(engine, context, current_edge) :
            _read_runtime_store(context, expr.base)
        return _runtime_copy(_read_runtime_nested(
            engine,
            root,
            expr.segments,
            context,
            rule_label,
            current_edge,
        ))
    elseif expr isa ActionValueAccessExpr
        root = _evaluate_runtime_action_expr!(
            engine,
            expr.receiver,
            context,
            rule_label,
            current_edge,
        )
        return _runtime_copy(_read_runtime_nested(
            engine,
            root,
            expr.segments,
            context,
            rule_label,
            current_edge,
        ))
    elseif expr isa ActionControlIfExpr || expr isa ActionControlWhileExpr ||
           expr isa ActionControlSwitchExpr
        return _evaluate_runtime_structured_control!(
            engine,
            expr,
            context,
            rule_label,
            current_edge,
        )
    elseif expr isa ActionControlElseExpr || expr isa ActionControlCaseExpr ||
           expr isa ActionControlDefaultExpr || expr isa ActionControlMarkerExpr
        return nothing
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
        return _evaluate_runtime_fluent_chain!(
            engine,
            expr,
            context,
            rule_label,
            current_edge,
            statement_context,
        )
    elseif expr isa ActionBlockValueExpr
        return _evaluate_runtime_block_value!(
            engine,
            expr.block,
            context,
            rule_label,
            current_edge,
        )
    elseif expr isa ActionCodeblockLiteralExpr
        context.codeblock_body_cache[expr.source] = expr.body_ast
        return _runtime_copy(to_json(expr))
    elseif expr isa ActionCodeblockLiteralErrorExpr
        throw(RuntimeInterpreterException(
            "invalid callable-codeblock literal in rule $rule_label: $(expr.code)",
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

function _evaluate_runtime_structured_control!(engine, expr, context, rule_label, current_edge)
    if expr isa ActionControlIfExpr
        if expr.body !== nothing && _runtime_truthy(_evaluate_runtime_action_expr!(
                engine,
                expr.condition,
                context,
                rule_label,
                current_edge,
            ))
            result = _execute_runtime_action_block!(
                engine,
                expr.body,
                context,
                rule_label,
                current_edge,
            )
            if result !== nothing
                throw(result)
            end
        end
    elseif expr isa ActionControlWhileExpr && expr.body !== nothing
        _execute_runtime_attached_while!(engine, expr, context, rule_label, current_edge)
    elseif expr isa ActionControlSwitchExpr
        body = _select_runtime_switch_body(engine, expr, context, rule_label, current_edge)
        if body !== nothing
            result = _execute_runtime_action_block!(
                engine,
                body,
                context,
                rule_label,
                current_edge,
            )
            if result !== nothing
                throw(result)
            end
        end
    end
    return nothing
end

function _evaluate_runtime_call!(
    engine::LinkedSpecRuntimeEngine,
    call::ActionCallExpr,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
    statement_context::Bool,
)
    keyword_arg_count = count(arg -> arg isa ActionKeywordArgument, call.args)
    args = ActionExpr[getfield(arg, :value) for arg in call.args if arg isa ActionPositionalArgument]
    helper_name = canonical_action_helper_name(call.name)

    if helper_name in _RUNTIME_DIAGNOSTIC_OUTPUT_HELPER_NAMES
        _validate_runtime_diagnostic_output_arity!(
            engine,
            call,
            helper_name,
            args,
            keyword_arg_count,
            context,
            rule_label,
        )
    end

    if has_user_function_name(engine.compiled_spec.function_registry, call.name) && keyword_arg_count > 0
        throw(RuntimeInterpreterException(
            "user function '$(call.name)' accepts positional arguments only, " *
            "got $keyword_arg_count keyword argument(s) in rule $rule_label",
        ))
    end

    if helper_name == "with" && call.trailing_block_arg
        return _call_runtime_with_trailing_block!(
            engine,
            call,
            context,
            rule_label,
            current_edge,
        )
    elseif call.trailing_block_arg
        throw(RuntimeInterpreterException(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:$helper_name: trailing block arguments " *
            "are not supported for helper '$(call.name)' in rule '$rule_label'",
        ))
    elseif helper_name == "if"
        return _call_runtime_inline_if!(
            engine,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name == "switch"
        return _call_runtime_inline_switch!(
            engine,
            args,
            context,
            rule_label,
            current_edge,
        )
    end

    function_resolution = resolve_user_function_call(
        engine.compiled_spec.function_registry,
        call.name,
        length(args),
    )
    if function_resolution.matched
        return _execute_runtime_user_function!(
            engine,
            function_resolution.entry,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif function_resolution.arity_mismatch
        entry = lookup_user_function(engine.compiled_spec.function_registry, call.name)
        expected = user_function_arity_expectation(entry)
        throw(RuntimeInterpreterException(
            "user function '$(call.name)' expects $expected argument(s), " *
            "got $(length(args)) in rule $rule_label",
        ))
    end

    if helper_name in _RUNTIME_LOGICAL_HELPER_NAMES
        _validate_runtime_logical_helper_arity!(
            engine,
            helper_name,
            length(args),
            context,
            rule_label,
        )
    end

    if statement_context && helper_name == "set_key" && _execute_runtime_set_key_statement!(
            engine,
            args,
            context,
            rule_label,
            current_edge,
        )
        return nothing
    end
    if statement_context && helper_name in ("substr", "regex_subst") &&
            _execute_runtime_regex_substitution_statement!(
                engine,
                args,
                context,
                rule_label,
                current_edge,
            )
        return nothing
    end
    if statement_context && _execute_runtime_array_transform_statement!(
            engine,
            helper_name,
            args,
            context,
            rule_label,
            current_edge,
        )
        return nothing
    end

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
    elseif helper_name == "hash"
        return _call_runtime_hash(engine, args, context, rule_label, current_edge)
    elseif helper_name == "copy"
        return isempty(args) ? nothing : _copy_runtime_argument(
            engine,
            first(args),
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name == "coalesce" || helper_name == "coalesce_nonempty"
        return _call_runtime_coalesce(
            engine,
            args,
            context,
            rule_label,
            current_edge;
            require_nonempty = helper_name == "coalesce_nonempty",
        )
    elseif helper_name == "split"
        return _call_runtime_split_from_expressions!(
            engine,
            args,
            context,
            rule_label,
            current_edge,
        )
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
    elseif helper_name == "entry_has"
        return _runtime_has_named_capture(
            engine,
            context.registers.entry_match,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name == "match_has"
        return _runtime_has_named_capture(
            engine,
            context.registers.local_match,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name == "entry_map"
        return context.registers.entry_match === nothing ?
            Dict{String,Any}() :
            Dict{String,Any}(context.registers.entry_match.named)
    elseif helper_name == "match_map"
        return context.registers.local_match === nothing ?
            Dict{String,Any}() :
            Dict{String,Any}(context.registers.local_match.named)
    elseif helper_name == "entry_len"
        return _runtime_match_length(context.registers.entry_match)
    elseif helper_name == "match_len"
        return _runtime_match_length(context.registers.local_match)
    elseif helper_name == "entry_line" || helper_name == "entry_start_line"
        return _runtime_match_line(context.registers.entry_match, false)
    elseif helper_name == "entry_col" || helper_name == "entry_start_col"
        return _runtime_match_column(context.registers.entry_match, false)
    elseif helper_name == "entry_end_line"
        return _runtime_match_line(context.registers.entry_match, true)
    elseif helper_name == "entry_end_col"
        return _runtime_match_column(context.registers.entry_match, true)
    elseif helper_name == "match_line" || helper_name == "match_start_line"
        return _runtime_match_line(context.registers.local_match, false)
    elseif helper_name == "match_col" || helper_name == "match_start_col"
        return _runtime_match_column(context.registers.local_match, false)
    elseif helper_name == "match_end_line"
        return _runtime_match_line(context.registers.local_match, true)
    elseif helper_name == "match_end_col"
        return _runtime_match_column(context.registers.local_match, true)
    elseif helper_name == "entry_start_pos"
        return context.registers.entry_match === nothing ? nothing : char_start(context.registers.entry_match)
    elseif helper_name == "entry_end_pos"
        return context.registers.entry_match === nothing ? nothing : char_end(context.registers.entry_match)
    elseif helper_name == "match_start_pos"
        return context.registers.local_match === nothing ? nothing : char_start(context.registers.local_match)
    elseif helper_name == "match_end_pos"
        return context.registers.local_match === nothing ? nothing : char_end(context.registers.local_match)
    elseif helper_name == "cursor_pos"
        return codeunit_offset_to_char_offset(context.input, context.cursor_codeunit)
    elseif helper_name == "cursor_line"
        return line_column_at_codeunit_offset(context.input, context.cursor_codeunit).line
    elseif helper_name == "cursor_col"
        return line_column_at_codeunit_offset(context.input, context.cursor_codeunit).column
    elseif helper_name == "cursor_rest"
        return _runtime_codeunit_slice(
            context.input,
            context.cursor_codeunit,
            ncodeunits(context.input),
        )
    elseif helper_name == "cursor_rest_len"
        return length(_runtime_codeunit_slice(
            context.input,
            context.cursor_codeunit,
            ncodeunits(context.input),
        ))
    elseif helper_name == "input_text"
        return context.input
    elseif helper_name == "input_len" || helper_name == "input_end_pos"
        return length(context.input)
    elseif helper_name == "input_slice"
        return _call_runtime_input_slice!(
            engine,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name == "input_end_line"
        return line_column_at_codeunit_offset(context.input, ncodeunits(context.input)).line
    elseif helper_name == "input_end_col"
        return line_column_at_codeunit_offset(context.input, ncodeunits(context.input)).column
    elseif helper_name in _RUNTIME_ANONYMOUS_CAPTURE_HELPER_NAMES
        return _call_runtime_anonymous_capture_helper!(helper_name, context)
    elseif helper_name in _RUNTIME_NAMED_CAPTURE_HELPER_NAMES
        return _call_runtime_named_capture_helper!(
            engine,
            helper_name,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name == "capture_until_boundary"
        return _call_runtime_capture_until_boundary!(
            engine,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif helper_name in _RUNTIME_DIAGNOSTIC_OUTPUT_HELPER_NAMES
        values = Any[
            _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                arg,
                context,
                rule_label,
                current_edge,
            )) for arg in args
        ]
        return _call_runtime_diagnostic_output_helper!(helper_name, values, context, rule_label)
    elseif helper_name == "exit_now"
        return _call_runtime_exit_now!(engine, args, context, rule_label, current_edge)
    elseif helper_name == "save_cursor"
        cursor_before = context.cursor_codeunit
        stack_before = length(context.cursor_stack)
        push!(context.cursor_stack, context.cursor_codeunit)
        _trace_runtime_cursor_control!(
            context,
            rule_label,
            helper_name,
            cursor_before,
            stack_before,
        )
        return nothing
    elseif helper_name == "restore_cursor"
        cursor_before = context.cursor_codeunit
        stack_before = length(context.cursor_stack)
        if !isempty(context.cursor_stack)
            _set_runtime_cursor!(context, pop!(context.cursor_stack))
        end
        _trace_runtime_cursor_control!(
            context,
            rule_label,
            helper_name,
            cursor_before,
            stack_before,
        )
        return nothing
    elseif helper_name == "rewind_match_start"
        cursor_before = context.cursor_codeunit
        stack_before = length(context.cursor_stack)
        if context.registers.local_match !== nothing
            _set_runtime_cursor!(context, context.registers.local_match.codeunit_start)
        end
        _trace_runtime_cursor_control!(
            context,
            rule_label,
            helper_name,
            cursor_before,
            stack_before,
        )
        return nothing
    elseif helper_name == "rewind_entry_start"
        cursor_before = context.cursor_codeunit
        stack_before = length(context.cursor_stack)
        if context.registers.entry_match !== nothing
            _set_runtime_cursor!(context, context.registers.entry_match.codeunit_start)
        end
        _trace_runtime_cursor_control!(
            context,
            rule_label,
            helper_name,
            cursor_before,
            stack_before,
        )
        return nothing
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

    if helper_name in _RUNTIME_HASH_HELPER_NAMES
        values = _evaluate_runtime_hash_helper_values(
            engine,
            helper_name,
            args,
            context,
            rule_label,
            current_edge,
        )
        return _call_runtime_hash_helper(helper_name, values)
    elseif helper_name in _RUNTIME_ARRAY_HELPER_NAMES
        values = Any[
            _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                arg,
                context,
                rule_label,
                current_edge,
            )) for arg in args
        ]
        return _call_runtime_array_helper(helper_name, values)
    elseif helper_name in _RUNTIME_PURE_HELPER_NAMES
        values = Any[
            _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                arg,
                context,
                rule_label,
                current_edge,
            )) for arg in args
        ]
        return _call_runtime_pure_helper(helper_name, values)
    end

    if !is_known_action_ir_call_name(call.name) &&
            _runtime_binding_present(context, call.name)
        value = _runtime_copy(_read_runtime_store(context, call.name))
        codeblock = _decode_runtime_codeblock(value)
        if codeblock === nothing
            value_kind = _runtime_binding_kind(value)
            detail = "value_not_callable callable_name=$(repr(call.name)) " *
                     "value_kind=$(repr(value_kind)) rule_label=$(repr(rule_label))"
            throw(RuntimeInterpreterException(
                detail;
                diagnostic = _runtime_context_diagnostic(
                    engine,
                    context;
                    stage = "callable_codeblock_invocation",
                    summary = "Julia callable codeblock invocation failed",
                    detail = detail,
                    code = "value_not_callable",
                    callable_name = call.name,
                    value_kind = value_kind,
                    rule_label = rule_label,
                    handler_source_label = "julia_runtime:codeblock:$(call.name)",
                ),
            ))
        end
        if keyword_arg_count > 0
            expected = "positional arguments"
            detail = "codeblock_keyword_arguments_unsupported " *
                     "callable_name=$(repr(call.name)) expected=$(repr(expected)) " *
                     "got=$keyword_arg_count rule_label=$(repr(rule_label))"
            throw(RuntimeInterpreterException(
                detail;
                diagnostic = _runtime_context_diagnostic(
                    engine,
                    context;
                    stage = "callable_codeblock_invocation",
                    summary = "Julia callable codeblock invocation failed",
                    detail = detail,
                    code = "codeblock_keyword_arguments_unsupported",
                    callable_name = call.name,
                    expected = expected,
                    got = keyword_arg_count,
                    rule_label = rule_label,
                    handler_source_label = "julia_runtime:codeblock:$(call.name)",
                ),
            ))
        end
        return _execute_runtime_codeblock_value!(
            engine,
            call.name,
            codeblock,
            args,
            context,
            rule_label,
            current_edge,
        )
    elseif !is_known_action_ir_call_name(call.name) && !isempty(context.active_codeblocks)
        detail = "unknown_helper name=$(repr(call.name)) rule_label=$(repr(rule_label))"
        throw(RuntimeInterpreterException(
            detail;
            diagnostic = _runtime_context_diagnostic(
                engine,
                context;
                stage = "callable_codeblock_invocation",
                summary = "Julia callable codeblock invocation failed",
                detail = detail,
                code = "unknown_helper",
                name = call.name,
                rule_label = rule_label,
            ),
        ))
    end

    throw(RuntimeInterpreterException(
        "unsupported runtime helper '$(call.name)' in rule $rule_label",
    ))
end

function _execute_runtime_codeblock_value!(
    engine::LinkedSpecRuntimeEngine,
    name::String,
    codeblock::_RuntimeCodeblockValue,
    arg_exprs::Vector{ActionExpr},
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
)
    values = Any[]
    for arg in arg_exprs
        push!(values, _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )))
    end

    arity_matches = length(values) >= codeblock.min_arity &&
                    (codeblock.max_arity === nothing || length(values) <= codeblock.max_arity)
    if !arity_matches
        expected = codeblock.max_arity == codeblock.min_arity ?
                   "exactly $(codeblock.min_arity)" : "at least $(codeblock.min_arity)"
        detail = "codeblock_arity_mismatch callable_name=$(repr(name)) " *
                 "expected=$(repr(expected)) got=$(length(values)) " *
                 "rule_label=$(repr(rule_label))"
        throw(RuntimeInterpreterException(
            detail;
            diagnostic = _runtime_context_diagnostic(
                engine,
                context;
                stage = "callable_codeblock_invocation",
                summary = "Julia callable codeblock invocation failed",
                detail = detail,
                code = "codeblock_arity_mismatch",
                callable_name = name,
                expected = expected,
                got = length(values),
                rule_label = rule_label,
                handler_source_label = "julia_runtime:codeblock:$name",
            ),
        ))
    end

    active_index = findfirst(==(name), context.active_codeblocks)
    if active_index !== nothing
        cycle = String[context.active_codeblocks[active_index:end]..., name]
        detail = "codeblock_recursion_unsupported callable_name=$(repr(name)) " *
                 "cycle=$(repr(cycle)) rule_label=$(repr(rule_label))"
        throw(RuntimeInterpreterException(
            detail;
            diagnostic = _runtime_context_diagnostic(
                engine,
                context;
                stage = "callable_codeblock_invocation",
                summary = "Julia callable codeblock invocation failed",
                detail = detail,
                code = "codeblock_recursion_unsupported",
                callable_name = name,
                cycle = cycle,
                rule_label = rule_label,
                handler_source_label = "julia_runtime:codeblock:$name",
            ),
        ))
    end

    body = get!(context.codeblock_body_cache, codeblock.source_text) do
        parse_action_block(codeblock.body_source)
    end
    bindings = _RuntimeScopedBinding[]
    push!(context.active_codeblocks, name)
    try
        for (index, parameter) in enumerate(codeblock.positional_params)
            push!(bindings, _enter_runtime_scoped_scalar!(
                context,
                parameter,
                values[index],
            ))
        end
        if codeblock.rest_param !== nothing
            rest_values = Any[
                _runtime_copy(value) for value in values[(codeblock.min_arity + 1):end]
            ]
            push!(bindings, _enter_runtime_scoped_scalar!(
                context,
                codeblock.rest_param,
                rest_values,
            ))
        end
        try
            flow = _execute_runtime_value_statements!(
                engine,
                body.statements,
                1,
                length(body.statements) + 1,
                context,
                rule_label,
                current_edge;
                final_expression_yields = true,
            )
            return flow.returned ? _runtime_copy(flow.value) : nothing
        catch error
            if error isa _RuntimeActionReturn
                return _runtime_copy(error.value)
            end
            rethrow()
        end
    finally
        for binding in Iterators.reverse(bindings)
            _exit_runtime_scoped_binding!(context, binding)
        end
        pop!(context.active_codeblocks)
    end
end

function _execute_runtime_user_function!(
    engine::LinkedSpecRuntimeEngine,
    entry::UserFunctionEntry,
    arg_exprs::Vector{ActionExpr},
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
)
    values = Any[
        _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )) for arg in arg_exprs
    ]
    definition = entry.definition
    if !user_function_accepts_arity(entry, length(values))
        expected = user_function_arity_expectation(entry)
        throw(RuntimeInterpreterException(
            "user function '$(definition.name)' expects $expected argument(s), " *
            "got $(length(values)) in rule $rule_label",
        ))
    end

    active_index = findfirst(==(definition.name), context.active_user_functions)
    if active_index !== nothing
        cycle = join(Any[context.active_user_functions[active_index:end]..., definition.name], " -> ")
        detail = "user function recursion is not supported: $cycle in rule $rule_label"
        throw(RuntimeInterpreterException(
            detail;
            diagnostic = _runtime_context_diagnostic(
                engine,
                context;
                stage = "user_function_call",
                summary = "Julia user function recursion failed",
                detail = detail,
                rule_label = rule_label,
                handler_source_label = "julia_runtime:function:$(definition.name)",
            ),
        ))
    end

    block = _runtime_user_function_body!(engine, entry, context, rule_label)
    saved_variables = context.variables
    saved_arrays = context.arrays
    saved_hashes = context.hashes
    context.variables = Dict{String,Any}()
    context.arrays = Dict{String,Vector{Any}}()
    context.hashes = Dict{String,Dict{String,Any}}()
    push!(context.active_user_functions, definition.name)

    try
        for (name, value) in zip(definition.params, values)
            context.variables[name] = _runtime_copy(value)
            if value isa AbstractVector
                context.arrays[name] = _runtime_as_array(value)
            elseif value isa AbstractDict
                context.hashes[name] = _runtime_as_hash(value)
            end
        end
        if definition.signature !== nothing
            rest_values = Any[_runtime_copy(value) for value in values[(definition.arity + 1):end]]
            rest_name = definition.signature.rest_param
            rest_name === nothing && throw(RuntimeInterpreterException(
                "user function '$(definition.name)' has no variadic rest parameter",
            ))
            context.variables[rest_name] = _runtime_copy(rest_values)
            context.arrays[rest_name] = _runtime_as_array(rest_values)
        end
        flow = _execute_runtime_value_statements!(
            engine,
            block.statements,
            1,
            length(block.statements) + 1,
            context,
            rule_label,
            current_edge;
            final_expression_yields = true,
        )
        return flow.returned ? _runtime_copy(flow.value) : nothing
    finally
        context.variables = saved_variables
        context.arrays = saved_arrays
        context.hashes = saved_hashes
        pop!(context.active_user_functions)
    end
end

function _runtime_user_function_body!(
    engine::LinkedSpecRuntimeEngine,
    entry::UserFunctionEntry,
    context::_RuntimeExecutionContext,
    rule_label::String,
)
    cached = get(context.user_function_body_cache, entry.index, nothing)
    if cached !== nothing
        return cached
    end
    try
        block = parse_action_block(entry.definition.body_source)
        context.user_function_body_cache[entry.index] = block
        return block
    catch error
        detail = "user function '$(entry.definition.name)' body parse failed in rule " *
            "$rule_label: $(sprint(showerror, error))"
        throw(RuntimeInterpreterException(
            detail;
            diagnostic = _runtime_context_diagnostic(
                engine,
                context;
                stage = "user_function_body_parse",
                summary = "Julia user function body parse failed",
                detail = detail,
                rule_label = rule_label,
                handler_source_label = "julia_runtime:function:$(entry.definition.name)",
            ),
        ))
    end
end

function _evaluate_runtime_hash_helper_values(
    engine,
    helper_name,
    args,
    context,
    rule_label,
    current_edge,
)
    values = Any[]
    for (index, arg) in enumerate(args)
        if helper_name == "merge_hash" && index == 1
            name = _runtime_variable_name(arg)
            if name !== nothing
                push!(values, _runtime_copy(get(context.variables, name, nothing)))
                continue
            end
        end
        push!(values, _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )))
    end
    return values
end

function _call_runtime_inline_if!(engine, args, context, rule_label, current_edge)
    if isempty(args)
        return nothing
    end
    if _runtime_truthy(_evaluate_runtime_action_expr!(
            engine,
            first(args),
            context,
            rule_label,
            current_edge,
        ))
        return length(args) >= 2 ? _evaluate_runtime_action_expr!(
            engine,
            args[2],
            context,
            rule_label,
            current_edge,
        ) : true
    end
    for arg in Iterators.drop(args, 2)
        if !(arg isa ActionCallExpr)
            return _evaluate_runtime_action_expr!(
                engine,
                arg,
                context,
                rule_label,
                current_edge,
            )
        end
        branch_name = canonical_action_helper_name(arg.name)
        branch_args = ActionExpr[getfield(item, :value) for item in arg.args]
        if branch_name == "elseif"
            if length(branch_args) >= 2 && _runtime_truthy(_evaluate_runtime_action_expr!(
                    engine,
                    branch_args[1],
                    context,
                    rule_label,
                    current_edge,
                ))
                return _evaluate_runtime_action_expr!(
                    engine,
                    branch_args[2],
                    context,
                    rule_label,
                    current_edge,
                )
            end
        elseif branch_name == "else"
            return isempty(branch_args) ? nothing : _evaluate_runtime_action_expr!(
                engine,
                first(branch_args),
                context,
                rule_label,
                current_edge,
            )
        else
            return _evaluate_runtime_action_expr!(
                engine,
                arg,
                context,
                rule_label,
                current_edge,
            )
        end
    end
    return nothing
end

function _call_runtime_inline_switch!(engine, args, context, rule_label, current_edge)
    if isempty(args)
        return nothing
    end
    selector = _evaluate_runtime_action_expr!(
        engine,
        first(args),
        context,
        rule_label,
        current_edge,
    )
    default_expr = nothing
    has_default = false
    for branch in Iterators.drop(args, 1)
        if !(branch isa ActionCallExpr)
            continue
        end
        branch_name = canonical_action_helper_name(branch.name)
        branch_args = ActionExpr[getfield(item, :value) for item in branch.args]
        if branch_name == "case" && length(branch_args) >= 2
            candidate = branch_args[1] isa ActionVariableExpr ? branch_args[1].name :
                _evaluate_runtime_action_expr!(
                    engine,
                    branch_args[1],
                    context,
                    rule_label,
                    current_edge,
                )
            if _runtime_string(candidate) == _runtime_string(selector)
                return _evaluate_runtime_action_expr!(
                    engine,
                    branch_args[2],
                    context,
                    rule_label,
                    current_edge,
                )
            end
        elseif branch_name == "default" && !isempty(branch_args) && !has_default
            default_expr = first(branch_args)
            has_default = true
        end
    end
    return has_default ? _evaluate_runtime_action_expr!(
        engine,
        default_expr,
        context,
        rule_label,
        current_edge,
    ) : nothing
end

function _call_runtime_with_trailing_block!(engine, call, context, rule_label, current_edge)
    if !call.trailing_block_arg || isempty(call.args) || length(call.args) > 2
        throw(RuntimeInterpreterException(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: helper `with(...) { ... }` " *
            "expects zero or one value argument plus a trailing block in rule '$rule_label'",
        ))
    end
    block_expr = last(call.args).value
    if !(block_expr isa ActionBlockValueExpr)
        throw(RuntimeInterpreterException(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: helper `with(...)` " *
            "requires a trailing block argument in rule '$rule_label'",
        ))
    end
    scoped_value = length(call.args) == 2 ? _evaluate_runtime_action_expr!(
        engine,
        first(call.args).value,
        context,
        rule_label,
        current_edge,
    ) : nothing
    binding = _enter_runtime_scoped_scalar!(context, "value", scoped_value)
    try
        return _evaluate_runtime_block_value!(
            engine,
            block_expr.block,
            context,
            rule_label,
            current_edge,
        )
    finally
        _exit_runtime_scoped_binding!(context, binding)
    end
end

function _enter_runtime_scoped_scalar!(context, name::String, value)
    binding = _RuntimeScopedBinding(
        name,
        haskey(context.variables, name),
        _runtime_copy(get(context.variables, name, nothing)),
        haskey(context.arrays, name),
        _runtime_copy(get(context.arrays, name, nothing)),
        haskey(context.hashes, name),
        _runtime_copy(get(context.hashes, name, nothing)),
    )
    delete!(context.variables, name)
    delete!(context.arrays, name)
    delete!(context.hashes, name)
    context.variables[name] = _runtime_copy(value)
    return binding
end

function _exit_runtime_scoped_binding!(context, binding::_RuntimeScopedBinding)
    delete!(context.variables, binding.name)
    delete!(context.arrays, binding.name)
    delete!(context.hashes, binding.name)
    if binding.variable_present
        context.variables[binding.name] = _runtime_copy(binding.variable)
    end
    if binding.array_present
        context.arrays[binding.name] = _runtime_as_array(binding.array)
    end
    if binding.hash_present
        context.hashes[binding.name] = _runtime_as_hash(binding.hash)
    end
    return nothing
end

function _record_runtime_rule_local_binding!(context, name::String)
    if !isempty(context.active_user_functions) || isempty(context.rule_local_binding_scopes)
        return nothing
    end
    scope = last(context.rule_local_binding_scopes)
    if haskey(scope, name)
        return nothing
    end
    scope[name] = _RuntimeRuleLocalBinding(
        haskey(context.variables, name),
        _runtime_copy(get(context.variables, name, nothing)),
        haskey(context.arrays, name),
        _runtime_copy(get(context.arrays, name, nothing)),
        haskey(context.hashes, name),
        _runtime_copy(get(context.hashes, name, nothing)),
    )
    return nothing
end

function _restore_runtime_rule_local_bindings!(context)
    if isempty(context.rule_local_binding_scopes)
        return nothing
    end
    scope = pop!(context.rule_local_binding_scopes)
    for (name, binding) in scope
        delete!(context.variables, name)
        delete!(context.arrays, name)
        delete!(context.hashes, name)
        if binding.variable_present
            context.variables[name] = _runtime_copy(binding.variable)
        end
        if binding.array_present
            context.arrays[name] = _runtime_as_array(binding.array)
        end
        if binding.hash_present
            context.hashes[name] = _runtime_as_hash(binding.hash)
        end
    end
    return nothing
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
    variable_target = _runtime_variable_name(args[1])
    if variable_target !== nothing
        return _store_runtime_bare_binding!(context, variable_target, value)
    end
    throw(RuntimeInterpreterException(
        "set target in rule $rule_label must be a variable",
    ))
end

function _call_runtime_push!(engine, args, context, rule_label, current_edge)
    child_rule = isempty(args) ? nothing : _runtime_variable_name(first(args))
    if child_rule !== nothing &&
            compiled_rule(engine.compiled_spec, child_rule) !== nothing &&
            length(args) <= 3
        index = if length(args) == 2
            _runtime_literal_nonnegative_int(args[2])
        elseif length(args) == 3
            _runtime_literal_nonnegative_int(args[3])
        else
            nothing
        end
        target = if length(args) == 1 || (length(args) == 2 && index !== nothing)
            rule_label
        else
            _runtime_variable_name(args[2])
        end
        valid_shape = target !== nothing && (length(args) < 3 || index !== nothing)
        if valid_shape
            child = current_edge !== nothing && child_rule == current_edge.target.label ?
                _execute_runtime_action_edge_child!(engine, current_edge, context) :
                _execute_runtime_rule!(engine, child_rule, 0, context)
            context.retv = child.value
            value = index === nothing ? child.value : _runtime_index_value(child.value, index)
            return _append_runtime_array_value!(context, target, value)
        end
    end

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
        target = _runtime_variable_name(first(args))
        if target === nothing
            throw(RuntimeInterpreterException(
                "push target in rule $rule_label must be a variable",
            ))
        end
        child = _execute_runtime_action_edge_child!(engine, current_edge, context)
        context.retv = child.value
        return _append_runtime_array_value!(context, target, child.value)
    end

    if length(args) >= 2
        target = _runtime_variable_name(args[1])
        if target === nothing
            throw(RuntimeInterpreterException(
                "push target in rule $rule_label must be a variable",
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

function _runtime_literal_nonnegative_int(expr)
    if !(expr isa ActionNumberLiteralExpr)
        return nothing
    end
    return _runtime_nonnegative_int(expr.value)
end

function _call_runtime_array(engine, args, context, rule_label, current_edge)
    result = Any[]
    for arg in args
        value = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        ))
        _append_runtime_array_argument!(result, arg, value)
    end
    return result
end

function _append_runtime_array_argument!(result, expr, value)
    if _runtime_is_array_splice_argument(expr) && value isa AbstractVector
        append!(result, _runtime_as_array(value))
    elseif _runtime_is_array_splice_argument(expr) && value isa AbstractDict
        for (key, item) in pairs(value)
            push!(result, _runtime_string(key))
            push!(result, _runtime_copy(item))
        end
    else
        push!(result, value)
    end
    return nothing
end

function _call_runtime_hash(engine, args, context, rule_label, current_edge)
    values = Any[]
    for arg in args
        push!(values, _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )))
    end

    result = Dict{String,Any}()
    index = 1
    while index + 1 <= length(values)
        result[_runtime_string(values[index])] = _runtime_copy(values[index + 1])
        index += 2
    end
    for (arg, value) in zip(args, values)
        if _runtime_is_hash_splice_argument(arg) && value isa AbstractDict
            merge!(result, _runtime_as_hash(value))
        end
    end
    return result
end

const _RUNTIME_PURE_HELPER_NAMES = Set{String}([
    "and",
    "cat",
    "contains_substr",
    "ends_with",
    "is_defined",
    "is_empty",
    "is_nonempty",
    "is_undefined",
    "length",
    "lowercase",
    "matches",
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
    "not",
    "or",
    "replace_substr",
    "rm_prefix",
    "rm_suffix",
    "split",
    "starts_with",
    "str_eq",
    "str_ge",
    "str_gt",
    "str_le",
    "str_lt",
    "str_ne",
    "substr",
    "trim",
    "uppercase",
])

const _RUNTIME_LOGICAL_HELPER_NAMES = Set{String}(["and", "or", "not"])

function _validate_runtime_logical_helper_arity!(
    engine,
    helper_name::String,
    actual_arity::Int,
    context,
    rule_label::String,
)
    expected_arity = helper_name == "not" ?
        "exactly 1 positional argument" : "at least 1 positional argument"
    valid = helper_name == "not" ? actual_arity == 1 : actual_arity >= 1
    valid && return nothing

    detail = "helper_arity_mismatch: helper_name=$helper_name " *
             "actual_arity=$actual_arity expected_arity=$expected_arity " *
             "in rule $rule_label"
    throw(RuntimeInterpreterException(
        detail;
        diagnostic = _runtime_context_diagnostic(
            engine,
            context;
            stage = "helper_arity_mismatch",
            summary = "Julia logical helper arity failed",
            detail = detail,
            rule_label = rule_label,
            code = "helper_arity_mismatch",
            helper_name = helper_name,
            actual_arity = actual_arity,
            expected_arity = expected_arity,
        ),
    ))
end

const _RUNTIME_ARRAY_HELPER_NAMES = Set{String}([
    "concat_arrays",
    "contains",
    "count",
    "drop_back",
    "drop_front",
    "filter_match",
    "filter_nonempty",
    "first",
    "flat",
    "flat_array",
    "index_of",
    "join_values",
    "last",
    "lowercase_each",
    "reversed",
    "slice",
    "sorted",
    "split_each",
    "split_tagged_records",
    "take",
    "take_last",
    "trim_each",
    "uniq",
    "uppercase_each",
])

const _RUNTIME_HASH_HELPER_NAMES = Set{String}([
    "count_keys",
    "drop_keys",
    "flat_hash",
    "has_key",
    "merge_hash",
    "pick_keys",
    "rename_key",
    "set_key",
    "sorted_keys",
    "sorted_values",
])

const _RUNTIME_ANONYMOUS_CAPTURE_HELPER_NAMES = Set{String}([
    "capture_rest",
    "capture_rest_len",
    "capture_slice",
    "capture_slice_col",
    "capture_slice_len",
    "capture_slice_line",
    "capture_slice_pos",
    "capture_slice_until_cursor",
    "capture_slice_until_cursor_len",
    "capture_take",
    "capture_take_len",
    "capture_take_rest",
    "capture_take_rest_len",
    "capture_take_until_cursor",
    "capture_take_until_cursor_len",
    "start_capture_slice",
])

const _RUNTIME_NAMED_CAPTURE_HELPER_NAMES = Set{String}([
    "capture_between",
    "capture_from",
    "capture_len_between",
    "capture_len_from",
    "capture_rest_from",
    "capture_rest_len_from",
    "capture_take_between",
    "capture_take_between_len",
    "capture_take_len_from",
    "capture_take_rest_from",
    "capture_take_rest_len_from",
    "capture_take_until_cursor_from",
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
    "start_capture_slice_from",
])

const _RUNTIME_DIAGNOSTIC_OUTPUT_HELPER_NAMES = Set{String}([
    "print",
    "print_each",
    "say",
])

const _RUNTIME_ARRAY_END_MUTATION_NAMES = Set{String}([
    "pop_back",
    "pop_front",
    "push_back",
    "push_front",
])

const _RUNTIME_TREE_TRAVERSAL_NAMES = Set{String}([
    "map_leaves",
    "reduce_leaves",
    "walk_leaves",
])

function _evaluate_runtime_fluent_chain!(
    engine,
    chain,
    context,
    rule_label,
    current_edge,
    statement_context::Bool,
)
    value = _evaluate_runtime_action_expr!(
        engine,
        chain.receiver,
        context,
        rule_label,
        current_edge,
    )
    for (call_index, call) in enumerate(chain.calls)
        helper_name = canonical_action_helper_name(call.method)
        if helper_name in _RUNTIME_ARRAY_END_MUTATION_NAMES
            if call_index != 1
                return nothing
            end
            value = _execute_runtime_array_end_mutation!(
                engine,
                chain.receiver,
                call,
                context,
                rule_label,
                current_edge,
            )
            if value === nothing
                return nothing
            end
            continue
        end
        if helper_name == "with" && call.receiver_trailing_block_arg
            value = _call_runtime_receiver_with_trailing_block!(
                engine,
                value,
                call,
                context,
                rule_label,
                current_edge,
            )
            continue
        elseif helper_name in _RUNTIME_TREE_TRAVERSAL_NAMES
            value = _call_runtime_tree_traversal_block!(
                engine,
                value,
                call,
                context,
                rule_label,
                current_edge,
            )
            continue
        elseif helper_name == "copy"
            value = _runtime_copy(value)
            continue
        elseif helper_name == "coalesce" || helper_name == "coalesce_nonempty"
            if _runtime_coalesce_accepts(value, helper_name == "coalesce_nonempty")
                value = _runtime_copy(value)
                continue
            end
            args = ActionExpr[getfield(arg, :value) for arg in call.args]
            value = _call_runtime_coalesce(
                engine,
                args,
                context,
                rule_label,
                current_edge;
                require_nonempty = helper_name == "coalesce_nonempty",
            )
            continue
        elseif helper_name in _RUNTIME_HASH_HELPER_NAMES
            values = Any[_runtime_copy(value)]
            for arg in call.args
                push!(values, _runtime_copy(_evaluate_runtime_action_expr!(
                    engine,
                    getfield(arg, :value),
                    context,
                    rule_label,
                    current_edge,
                )))
            end
            value = _call_runtime_hash_helper(helper_name, values)
            continue
        elseif helper_name in _RUNTIME_ARRAY_HELPER_NAMES
            values = Any[_runtime_copy(value)]
            for arg in call.args
                push!(values, _runtime_copy(_evaluate_runtime_action_expr!(
                    engine,
                    getfield(arg, :value),
                    context,
                    rule_label,
                    current_edge,
                )))
            end
            if helper_name == "join_values"
                delimiter = length(values) >= 2 ? values[2] : ""
                values = Any[delimiter, values[1]]
            end
            value = _call_runtime_array_helper(helper_name, values)
            continue
        elseif !(helper_name in _RUNTIME_PURE_HELPER_NAMES)
            throw(RuntimeInterpreterException(
                "unsupported runtime fluent method '.$(call.method)' in rule $rule_label",
            ))
        end

        values = Any[_runtime_copy(value)]
        for arg in call.args
            push!(values, _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                getfield(arg, :value),
                context,
                rule_label,
                current_edge,
            )))
        end
        value = _call_runtime_pure_helper(helper_name, values)
    end
    return value
end

function _call_runtime_receiver_with_trailing_block!(
    engine,
    receiver,
    call,
    context,
    rule_label,
    current_edge,
)
    if !call.receiver_trailing_block_arg || length(call.args) != 1
        throw(RuntimeInterpreterException(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: receiver `.with() { ... }` " *
            "expects no parenthesized arguments in rule '$rule_label'",
        ))
    end
    block_expr = first(call.args).value
    if !(block_expr isa ActionBlockValueExpr)
        throw(RuntimeInterpreterException(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: receiver `.with()` " *
            "requires a trailing block argument in rule '$rule_label'",
        ))
    end
    binding = _enter_runtime_scoped_scalar!(context, "value", receiver)
    try
        return _evaluate_runtime_block_value!(
            engine,
            block_expr.block,
            context,
            rule_label,
            current_edge,
        )
    finally
        _exit_runtime_scoped_binding!(context, binding)
    end
end

function _call_runtime_tree_traversal_block!(
    engine,
    receiver,
    call,
    context,
    rule_label,
    current_edge,
)
    method = canonical_action_helper_name(call.method)
    if isempty(call.args) || !(last(call.args).value isa ActionBlockValueExpr) ||
       (method in ("walk_leaves", "map_leaves") && length(call.args) != 1) ||
       (method == "reduce_leaves" && length(call.args) != 2)
        signature = method == "reduce_leaves" ? ".reduce_leaves(initial) { ... }" :
            ".$method() { ... }"
        throw(RuntimeInterpreterException(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:$method: receiver `$signature` " *
            "requires the accepted tree traversal trailing-block arity in rule '$rule_label'",
        ))
    end
    block = last(call.args).value.block

    if receiver isa AbstractDict
        hash = _runtime_as_hash(receiver)
        if method == "walk_leaves"
            _walk_runtime_hash_tree!(engine, hash, block, context, rule_label, current_edge)
            return _runtime_copy(hash)
        elseif method == "map_leaves"
            return _map_runtime_hash_tree(engine, hash, block, context, rule_label, current_edge)
        end
        initial = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            first(call.args).value,
            context,
            rule_label,
            current_edge,
        ))
        return _reduce_runtime_hash_tree(
            engine,
            hash,
            initial,
            block,
            context,
            rule_label,
            current_edge,
        )
    elseif receiver isa AbstractVector
        items = _runtime_as_array(receiver)
        if method == "walk_leaves"
            _walk_runtime_array_tree!(engine, items, block, context, rule_label, current_edge)
            return _runtime_copy(items)
        elseif method == "map_leaves"
            return _map_runtime_array_tree(engine, items, block, context, rule_label, current_edge)
        end
        initial = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            first(call.args).value,
            context,
            rule_label,
            current_edge,
        ))
        return _reduce_runtime_array_tree(
            engine,
            items,
            initial,
            block,
            context,
            rule_label,
            current_edge,
        )
    end
    return nothing
end

function _walk_runtime_hash_tree!(engine, hash, block, context, rule_label, current_edge)
    function walk(node, path)
        for key in sort!(collect(keys(node)))
            value = node[key]
            next_path = Any[path..., key]
            if value isa AbstractDict
                walk(_runtime_as_hash(value), next_path)
            else
                _evaluate_runtime_tree_leaf!(
                    engine,
                    block,
                    value,
                    next_path,
                    context,
                    rule_label,
                    current_edge;
                    key = key,
                )
            end
        end
    end
    walk(hash, Any[])
    return nothing
end

function _map_runtime_hash_tree(engine, hash, block, context, rule_label, current_edge)
    function map_node(node, path)
        result = Dict{String,Any}()
        for key in sort!(collect(keys(node)))
            value = node[key]
            next_path = Any[path..., key]
            result[key] = value isa AbstractDict ? map_node(_runtime_as_hash(value), next_path) :
                _evaluate_runtime_tree_leaf!(
                    engine,
                    block,
                    value,
                    next_path,
                    context,
                    rule_label,
                    current_edge;
                    key = key,
                )
        end
        return result
    end
    return map_node(hash, Any[])
end

function _reduce_runtime_hash_tree(
    engine,
    hash,
    initial,
    block,
    context,
    rule_label,
    current_edge,
)
    acc = _runtime_copy(initial)
    function reduce_node(node, path)
        for key in sort!(collect(keys(node)))
            value = node[key]
            next_path = Any[path..., key]
            if value isa AbstractDict
                reduce_node(_runtime_as_hash(value), next_path)
            else
                acc = _evaluate_runtime_tree_leaf!(
                    engine,
                    block,
                    value,
                    next_path,
                    context,
                    rule_label,
                    current_edge;
                    key = key,
                    acc = acc,
                    bind_acc = true,
                )
            end
        end
    end
    reduce_node(hash, Any[])
    return acc
end

function _walk_runtime_array_tree!(engine, items, block, context, rule_label, current_edge)
    function walk(node, path)
        for (offset, value) in enumerate(node)
            index = offset - 1
            next_path = Any[path..., index]
            if value isa AbstractVector
                walk(_runtime_as_array(value), next_path)
            else
                _evaluate_runtime_tree_leaf!(
                    engine,
                    block,
                    value,
                    next_path,
                    context,
                    rule_label,
                    current_edge;
                    index = index,
                )
            end
        end
    end
    walk(items, Any[])
    return nothing
end

function _map_runtime_array_tree(engine, items, block, context, rule_label, current_edge)
    function map_node(node, path)
        result = Any[]
        for (offset, value) in enumerate(node)
            index = offset - 1
            next_path = Any[path..., index]
            push!(result, value isa AbstractVector ? map_node(_runtime_as_array(value), next_path) :
                _evaluate_runtime_tree_leaf!(
                    engine,
                    block,
                    value,
                    next_path,
                    context,
                    rule_label,
                    current_edge;
                    index = index,
                ))
        end
        return result
    end
    return map_node(items, Any[])
end

function _reduce_runtime_array_tree(
    engine,
    items,
    initial,
    block,
    context,
    rule_label,
    current_edge,
)
    acc = _runtime_copy(initial)
    function reduce_node(node, path)
        for (offset, value) in enumerate(node)
            index = offset - 1
            next_path = Any[path..., index]
            if value isa AbstractVector
                reduce_node(_runtime_as_array(value), next_path)
            else
                acc = _evaluate_runtime_tree_leaf!(
                    engine,
                    block,
                    value,
                    next_path,
                    context,
                    rule_label,
                    current_edge;
                    index = index,
                    acc = acc,
                    bind_acc = true,
                )
            end
        end
    end
    reduce_node(items, Any[])
    return acc
end

function _evaluate_runtime_tree_leaf!(
    engine,
    block,
    value,
    path,
    context,
    rule_label,
    current_edge;
    key = nothing,
    index = nothing,
    acc = nothing,
    bind_acc::Bool = false,
)
    bindings = _RuntimeScopedBinding[]
    try
        if bind_acc
            push!(bindings, _enter_runtime_scoped_scalar!(context, "acc", acc))
        end
        push!(bindings, _enter_runtime_scoped_scalar!(context, "value", value))
        if key !== nothing
            push!(bindings, _enter_runtime_scoped_scalar!(context, "key", key))
        end
        if index !== nothing
            push!(bindings, _enter_runtime_scoped_scalar!(context, "index", index))
        end
        push!(bindings, _enter_runtime_scoped_scalar!(context, "path", path))
        push!(bindings, _enter_runtime_scoped_scalar!(context, "depth", length(path)))
        return _evaluate_runtime_block_value!(
            engine,
            block,
            context,
            rule_label,
            current_edge,
        )
    finally
        for binding in Iterators.reverse(bindings)
            _exit_runtime_scoped_binding!(context, binding)
        end
    end
end

function _call_runtime_coalesce(
    engine,
    args,
    context,
    rule_label,
    current_edge;
    require_nonempty::Bool,
)
    for arg in args
        value = _evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )
        if _runtime_coalesce_accepts(value, require_nonempty)
            return _runtime_copy(value)
        end
    end
    return nothing
end

function _execute_runtime_array_end_mutation!(
    engine,
    receiver,
    call,
    context,
    rule_label,
    current_edge,
)
    helper_name = canonical_action_helper_name(call.method)
    if !(helper_name in _RUNTIME_ARRAY_END_MUTATION_NAMES)
        return nothing
    end
    target = _runtime_array_receiver_target_name(receiver)
    if target === nothing
        return nothing
    end

    if helper_name == "push_back" || helper_name == "push_front"
        if length(call.args) != 1
            return nothing
        end
        value = _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            getfield(only(call.args), :value),
            context,
            rule_label,
            current_edge,
        ))
        return _mutate_runtime_array_storage!(context, target) do items
            if helper_name == "push_back"
                push!(items, value)
            else
                pushfirst!(items, value)
            end
        end
    end

    if !isempty(call.args)
        return nothing
    end
    return _mutate_runtime_array_storage!(context, target) do items
        if !isempty(items)
            helper_name == "pop_back" ? pop!(items) : popfirst!(items)
        end
    end
end

function _runtime_array_receiver_target_name(expr)
    return _runtime_variable_name(expr)
end

function _execute_runtime_set_key_statement!(
    engine,
    args,
    context,
    rule_label,
    current_edge,
)
    effective_args = args
    if length(effective_args) == 4 && _runtime_variable_name(first(effective_args)) !== nothing
        effective_args = effective_args[2:end]
    end
    if length(effective_args) != 3
        return false
    end
    target = _runtime_hash_receiver_target_name(first(effective_args))
    if target === nothing || isempty(target)
        return false
    end
    key = _runtime_string(_evaluate_runtime_action_expr!(
        engine,
        effective_args[2],
        context,
        rule_label,
        current_edge,
    ))
    value = _runtime_copy(_evaluate_runtime_action_expr!(
        engine,
        effective_args[3],
        context,
        rule_label,
        current_edge,
    ))
    updated = _runtime_hash_binding_for_mutation(context, target)
    updated[key] = value
    _store_runtime_bare_binding!(context, target, updated)
    return true
end

function _runtime_hash_receiver_target_name(expr)
    return _runtime_variable_name(expr)
end

function _mutate_runtime_array_storage!(mutator, context::_RuntimeExecutionContext, name::String)
    updated = _runtime_array_binding_for_mutation(context, name)
    mutator(updated)
    return _store_runtime_bare_binding!(context, name, updated)
end

function _call_runtime_split_from_expressions!(engine, args, context, rule_label, current_edge)
    target = length(args) == 3 ? _runtime_variable_name(first(args)) : nothing
    if target !== nothing
        source = _evaluate_runtime_action_expr!(
            engine,
            args[2],
            context,
            rule_label,
            current_edge,
        )
        delimiter = length(args) >= 3 ? _evaluate_runtime_action_expr!(
            engine,
            args[3],
            context,
            rule_label,
            current_edge,
        ) : ""
        parts = _call_runtime_split(Any[source, delimiter])
        _runtime_array_binding_for_mutation(context, target)
        _record_runtime_rule_local_binding!(context, target)
        return _store_runtime_bare_binding!(context, target, parts)
    end

    values = Any[
        _runtime_copy(_evaluate_runtime_action_expr!(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )) for arg in args
    ]
    return _call_runtime_split(values)
end

function _execute_runtime_array_transform_statement!(
    engine,
    helper_name,
    args,
    context,
    rule_label,
    current_edge,
)
    if !(helper_name in ("trim_each", "filter_nonempty", "lowercase_each", "uppercase_each")) ||
            length(args) != 1
        return false
    end
    target = _runtime_variable_name(only(args))
    if target === nothing
        return false
    end
    value = _runtime_copy(_evaluate_runtime_action_expr!(
        engine,
        only(args),
        context,
        rule_label,
        current_edge,
    ))
    transformed = _call_runtime_array_helper(helper_name, Any[value])
    _runtime_array_binding_for_mutation(context, target)
    _record_runtime_rule_local_binding!(context, target)
    _store_runtime_bare_binding!(context, target, transformed)
    return true
end

function _runtime_is_array_splice_argument(expr)
    if expr isa ActionCallExpr
        return canonical_action_helper_name(expr.name) in ("flat", "flat_array", "flat_hash")
    elseif expr isa ActionFluentChainExpr && !isempty(expr.calls)
        return canonical_action_helper_name(last(expr.calls).method) in ("flat", "flat_array", "flat_hash")
    end
    return false
end

function _runtime_is_hash_splice_argument(expr)
    if expr isa ActionCallExpr
        return canonical_action_helper_name(expr.name) in ("flat", "flat_hash")
    elseif expr isa ActionFluentChainExpr && !isempty(expr.calls)
        return canonical_action_helper_name(last(expr.calls).method) in ("flat", "flat_hash")
    end
    return false
end

function _runtime_coalesce_accepts(value, require_nonempty::Bool)
    if value === nothing
        return false
    end
    return !require_nonempty || !(value isa AbstractString) || !isempty(value)
end

function _call_runtime_pure_helper(helper_name::String, values::Vector{Any})
    if helper_name == "and"
        return !isempty(values) && all(_runtime_truthy, values)
    elseif helper_name == "or"
        return any(_runtime_truthy, values)
    elseif helper_name == "not"
        return isempty(values) || !_runtime_truthy(first(values))
    elseif startswith(helper_name, "num_")
        return _call_runtime_numeric_helper(helper_name, values)
    elseif startswith(helper_name, "str_")
        return _call_runtime_string_comparison(helper_name, values)
    elseif helper_name == "cat"
        parts = String[]
        for value in values
            part = _runtime_scalar_string(value)
            if part === nothing
                return nothing
            end
            push!(parts, part)
        end
        return join(parts)
    elseif helper_name == "contains_substr"
        return _runtime_string_predicate(values, (value, needle) -> occursin(needle, value))
    elseif helper_name == "ends_with"
        return _runtime_string_predicate(values, endswith)
    elseif helper_name == "is_defined"
        return !isempty(values) && first(values) !== nothing
    elseif helper_name == "is_empty"
        return _runtime_is_empty(isempty(values) ? nothing : first(values))
    elseif helper_name == "is_nonempty"
        return !_runtime_is_empty(isempty(values) ? nothing : first(values))
    elseif helper_name == "is_undefined"
        return isempty(values) || first(values) === nothing
    elseif helper_name == "length"
        return _runtime_value_length(isempty(values) ? nothing : first(values))
    elseif helper_name == "lowercase"
        return _runtime_string_transform(values, unicode_lowercase)
    elseif helper_name == "matches"
        return _call_runtime_matches(values)
    elseif helper_name == "replace_substr"
        return _call_runtime_replace_substr(values)
    elseif helper_name == "rm_prefix"
        return _call_runtime_remove_edge(values, true)
    elseif helper_name == "rm_suffix"
        return _call_runtime_remove_edge(values, false)
    elseif helper_name == "split"
        return _call_runtime_split(values)
    elseif helper_name == "starts_with"
        return _runtime_string_predicate(values, startswith)
    elseif helper_name == "substr"
        return _call_runtime_substr(values)
    elseif helper_name == "trim"
        return _runtime_string_transform(values, strip)
    elseif helper_name == "uppercase"
        return _runtime_string_transform(values, unicode_uppercase)
    end
    throw(RuntimeInterpreterException("unsupported pure runtime helper '$helper_name'"))
end

function _call_runtime_array_helper(helper_name::String, values::Vector{Any})
    if helper_name == "concat_arrays" || helper_name == "flat_array"
        return _call_runtime_flat_array(values)
    elseif helper_name == "contains"
        return _call_runtime_array_contains(values)
    elseif helper_name == "count"
        return something(_runtime_value_length(isempty(values) ? nothing : first(values)), 0)
    elseif helper_name == "drop_back"
        return _call_runtime_array_drop(values, false)
    elseif helper_name == "drop_front"
        return _call_runtime_array_drop(values, true)
    elseif helper_name == "filter_match"
        return _call_runtime_array_filter_match(values)
    elseif helper_name == "filter_nonempty"
        return Any[
            _runtime_copy(item) for item in _runtime_array_items(values)
            if !_runtime_is_empty(item)
        ]
    elseif helper_name == "first"
        items = _runtime_array_items(values)
        return isempty(items) ? nothing : _runtime_copy(first(items))
    elseif helper_name == "flat"
        if isempty(values)
            return Any[nothing]
        elseif first(values) isa AbstractDict
            return _runtime_as_hash(first(values))
        elseif first(values) isa AbstractVector
            return _runtime_as_array(first(values))
        end
        return Any[_runtime_copy(first(values))]
    elseif helper_name == "index_of"
        return _call_runtime_array_index_of(values)
    elseif helper_name == "join_values"
        return _call_runtime_join_values(values)
    elseif helper_name == "last"
        items = _runtime_array_items(values)
        return isempty(items) ? nothing : _runtime_copy(last(items))
    elseif helper_name == "lowercase_each"
        return _map_runtime_array_strings(values, unicode_lowercase)
    elseif helper_name == "reversed"
        return Any[_runtime_copy(item) for item in reverse(_runtime_array_items(values))]
    elseif helper_name == "slice"
        return _call_runtime_array_slice(values)
    elseif helper_name == "sorted"
        items = _runtime_array_items(values)
        sort!(items; by = item -> something(_runtime_scalar_string(item; null_as_empty = true), ""))
        return items
    elseif helper_name == "split_each"
        return _call_runtime_array_split_each(values)
    elseif helper_name == "split_tagged_records"
        return _call_runtime_split_tagged_records(values)
    elseif helper_name == "take"
        return _call_runtime_array_take(values, true)
    elseif helper_name == "take_last"
        return _call_runtime_array_take(values, false)
    elseif helper_name == "trim_each"
        return _map_runtime_array_strings(values, strip)
    elseif helper_name == "uniq"
        return _call_runtime_array_uniq(values)
    elseif helper_name == "uppercase_each"
        return _map_runtime_array_strings(values, unicode_uppercase)
    end
    throw(RuntimeInterpreterException("unsupported array runtime helper '$helper_name'"))
end

function _call_runtime_hash_helper(helper_name::String, values::Vector{Any})
    if helper_name == "count_keys"
        hash = _runtime_hash_items(values)
        return hash === nothing ? 0 : length(hash)
    elseif helper_name == "drop_keys"
        hash = _runtime_hash_items(values)
        if hash === nothing
            return isempty(values) ? nothing : _runtime_copy(first(values))
        end
        dropped = Set(_runtime_string(value) for value in Iterators.drop(values, 1))
        return Dict{String,Any}(
            key => _runtime_copy(value) for (key, value) in pairs(hash) if !(key in dropped)
        )
    elseif helper_name == "flat_hash" || helper_name == "merge_hash"
        merged = Dict{String,Any}()
        for value in values
            if value isa AbstractDict
                merge!(merged, _runtime_as_hash(value))
            end
        end
        return merged
    elseif helper_name == "has_key"
        hash = _runtime_hash_items(values)
        present = hash !== nothing &&
            length(values) >= 2 &&
            haskey(hash, _runtime_string(values[2]))
        return present ? 1 : 0
    elseif helper_name == "pick_keys"
        hash = _runtime_hash_items(values)
        if hash === nothing
            return nothing
        end
        picked = Set(_runtime_string(value) for value in Iterators.drop(values, 1))
        return Dict{String,Any}(
            key => _runtime_copy(value) for (key, value) in pairs(hash) if key in picked
        )
    elseif helper_name == "rename_key"
        if length(values) < 3
            return nothing
        end
        hash = _runtime_hash_items(values)
        if hash === nothing
            return _runtime_copy(first(values))
        end
        old_key = _runtime_string(values[2])
        new_key = _runtime_string(values[3])
        result = Dict{String,Any}()
        for (key, value) in pairs(hash)
            result[key == old_key ? new_key : key] = _runtime_copy(value)
        end
        return result
    elseif helper_name == "set_key"
        if length(values) < 3
            return nothing
        end
        hash = _runtime_hash_items(values)
        if hash === nothing
            return _runtime_copy(first(values))
        end
        hash[_runtime_string(values[2])] = _runtime_copy(values[3])
        return hash
    elseif helper_name == "sorted_keys"
        hash = _runtime_hash_items(values)
        return hash === nothing ? Any[] : Any[sort!(collect(keys(hash)))...]
    elseif helper_name == "sorted_values"
        hash = _runtime_hash_items(values)
        if hash === nothing
            return Any[]
        end
        return Any[_runtime_copy(hash[key]) for key in sort!(collect(keys(hash)))]
    end
    throw(RuntimeInterpreterException("unsupported hash runtime helper '$helper_name'"))
end

function _runtime_hash_items(values)
    if isempty(values) || !(first(values) isa AbstractDict)
        return nothing
    end
    return _runtime_as_hash(first(values))
end

function _runtime_array_items(values)
    if isempty(values) || !(first(values) isa AbstractVector)
        return Any[]
    end
    return _runtime_as_array(first(values))
end

function _call_runtime_array_take(values, front::Bool)
    items = _runtime_array_items(values)
    count = _runtime_nonnegative_int(length(values) >= 2 ? values[2] : nothing)
    count = count === nothing ? 1 : count
    if front
        return items[1:min(count, length(items))]
    end
    start = max(1, length(items) - count + 1)
    return items[start:end]
end

function _call_runtime_array_drop(values, front::Bool)
    items = _runtime_array_items(values)
    count = _runtime_nonnegative_int(length(values) >= 2 ? values[2] : nothing)
    count = count === nothing ? 1 : count
    if front
        start = min(length(items) + 1, count + 1)
        return items[start:end]
    end
    stop = max(0, length(items) - count)
    return items[1:stop]
end

function _call_runtime_array_slice(values)
    items = _runtime_array_items(values)
    start = _runtime_nonnegative_int(length(values) >= 2 ? values[2] : nothing)
    start = start === nothing ? 0 : start
    width = _runtime_nonnegative_int(length(values) >= 3 ? values[3] : nothing)
    width = width === nothing ? length(items) : width
    if start >= length(items)
        return Any[]
    end
    stop = min(length(items), start + width)
    return items[start + 1:stop]
end

function _call_runtime_array_contains(values)
    if length(values) < 2
        return 0
    end
    needle = _runtime_scalar_string(values[2]; null_as_empty = true)
    present = any(
        item -> _runtime_scalar_string(item; null_as_empty = true) == needle,
        _runtime_array_items(values),
    )
    return present ? 1 : 0
end

function _call_runtime_array_index_of(values)
    if length(values) < 2
        return nothing
    end
    needle = _runtime_scalar_string(values[2]; null_as_empty = true)
    for (index, item) in enumerate(_runtime_array_items(values))
        if _runtime_scalar_string(item; null_as_empty = true) == needle
            return index - 1
        end
    end
    return nothing
end

function _call_runtime_join_values(values)
    delimiter = _runtime_scalar_string(isempty(values) ? "" : values[1]; null_as_empty = true)
    delimiter = delimiter === nothing ? "" : delimiter
    raw_items = length(values) >= 2 ? values[2] : Any[]
    items = raw_items isa AbstractVector ? raw_items : Any[raw_items]
    return join(
        [something(_runtime_scalar_string(item; null_as_empty = true), "") for item in items],
        delimiter,
    )
end

function _map_runtime_array_strings(values, transform)
    return Any[
        transform(something(_runtime_scalar_string(item; null_as_empty = true), ""))
        for item in _runtime_array_items(values)
    ]
end

function _call_runtime_array_split_each(values)
    items = _runtime_array_items(values)
    delimiter = length(values) >= 2 ? values[2] : ""
    result = Any[]
    for item in items
        append!(result, _call_runtime_split(Any[item, delimiter]))
    end
    return result
end

function _call_runtime_array_filter_match(values)
    if length(values) < 2
        return Any[]
    end
    pattern = values[2]
    result = Any[]
    for item in _runtime_array_items(values)
        text = something(_runtime_scalar_string(item; null_as_empty = true), "")
        if _call_runtime_matches(Any[text, pattern])
            push!(result, _runtime_copy(item))
        end
    end
    return result
end

function _call_runtime_array_uniq(values)
    seen = Set{String}()
    result = Any[]
    for item in _runtime_array_items(values)
        key = something(_runtime_scalar_string(item; null_as_empty = true), "")
        if !(key in seen)
            push!(seen, key)
            push!(result, _runtime_copy(item))
        end
    end
    return result
end

function _call_runtime_flat_array(values)
    result = Any[]
    for value in values
        if value isa AbstractVector
            append!(result, _runtime_as_array(value))
        else
            push!(result, _runtime_copy(value))
        end
    end
    return result
end

function _call_runtime_split_tagged_records(values)
    if length(values) < 3
        return Any[]
    end
    tag = something(_runtime_scalar_string(values[3]; null_as_empty = true), "")
    fields = Any[_runtime_copy(value) for value in Iterators.drop(values, 3)]
    return Any[
        Any[tag, item, (_runtime_copy(field) for field in fields)...]
        for item in _call_runtime_split(Any[values[1], values[2]])
    ]
end

function _runtime_scalar_string(value; null_as_empty::Bool = false)
    if value === nothing
        return null_as_empty ? "" : nothing
    elseif value isa AbstractVector || value isa AbstractDict
        return null_as_empty ? "" : nothing
    elseif value isa _RuntimeRegexValue
        return value.pattern
    elseif value isa Bool
        return value ? "1" : "0"
    elseif value isa Number
        if !isfinite(value)
            return nothing
        elseif iszero(value)
            return "0"
        elseif value isa Integer
            return string(value)
        elseif isinteger(value)
            return string(trunc(BigInt, value))
        end
        return string(value)
    end
    return string(value)
end

function _runtime_string_transform(values, transform)
    value = isempty(values) ? nothing : _runtime_scalar_string(first(values))
    return value === nothing ? nothing : transform(value)
end

function _runtime_string_predicate(values, predicate)
    if length(values) < 2
        return 0
    end
    value = _runtime_scalar_string(values[1])
    needle = _runtime_scalar_string(values[2]; null_as_empty = true)
    if value === nothing || needle === nothing
        return 0
    end
    return predicate(value, needle) ? 1 : 0
end

function _runtime_compile_helper_regex(pattern::String, flags::String)
    compile_flags = Char[]
    for flag in flags
        if flag in ('i', 'm', 's', 'x')
            push!(compile_flags, flag)
        elseif flag == 'g' || flag == 'o'
            continue
        else
            return nothing
        end
    end
    return try
        Regex(pattern, String(compile_flags))
    catch
        nothing
    end
end

function _call_runtime_matches(values)
    if length(values) < 2
        return false
    end
    value = _runtime_scalar_string(values[1])
    if value === nothing
        return false
    end
    regex_value = values[2]
    pattern = regex_value isa _RuntimeRegexValue ? regex_value.pattern : _runtime_scalar_string(regex_value)
    if pattern === nothing
        return false
    end
    flags = regex_value isa _RuntimeRegexValue ? regex_value.flags : ""
    regex = _runtime_compile_helper_regex(pattern, flags)
    if regex === nothing
        return false
    end
    return match(regex, value) !== nothing
end

function _call_runtime_replace_substr(values)
    if length(values) < 3
        return nothing
    end
    value = _runtime_scalar_string(values[1])
    old_value = _runtime_scalar_string(values[2]; null_as_empty = true)
    new_value = _runtime_scalar_string(values[3]; null_as_empty = true)
    if value === nothing || old_value === nothing || new_value === nothing
        return nothing
    elseif isempty(old_value)
        return value
    end
    return replace(value, old_value => new_value)
end

function _call_runtime_remove_edge(values, prefix::Bool)
    if length(values) < 2
        return nothing
    end
    value = _runtime_scalar_string(values[1])
    edge = _runtime_scalar_string(values[2]; null_as_empty = true)
    if value === nothing || edge === nothing
        return nothing
    elseif prefix && startswith(value, edge)
        return chop(value; head = length(edge), tail = 0)
    elseif !prefix && endswith(value, edge)
        return chop(value; head = 0, tail = length(edge))
    end
    return value
end

function _call_runtime_substr(values)
    if length(values) < 2 || values[1] === nothing || values[2] === nothing
        return nothing
    end
    value = _runtime_scalar_string(values[1])
    if value === nothing
        return nothing
    end
    start = max(0, something(_runtime_int(values[2]), 0))
    width = length(values) >= 3 && values[3] !== nothing ?
        max(0, something(_runtime_int(values[3]), 0)) : nothing
    chars = collect(value)
    if start >= length(chars)
        return ""
    end
    stop = width === nothing ? length(chars) : min(length(chars), start + width)
    return String(chars[start + 1:stop])
end

function _execute_runtime_regex_substitution_statement!(
    engine,
    args,
    context,
    rule_label,
    current_edge,
)
    if length(args) < 4
        return false
    end
    target = _runtime_variable_name(args[1])
    if target === nothing
        return false
    end

    pattern_value = _evaluate_runtime_action_expr!(
        engine,
        args[2],
        context,
        rule_label,
        current_edge,
    )
    pattern = pattern_value isa _RuntimeRegexValue ?
        pattern_value.pattern : _runtime_scalar_string(pattern_value)
    if pattern === nothing
        return false
    end
    pattern_flags = pattern_value isa _RuntimeRegexValue ? pattern_value.flags : ""
    explicit_flags = _runtime_regex_substitution_flags!(
        engine,
        args[4],
        context,
        rule_label,
        current_edge,
    )
    flags = join(unique(collect(pattern_flags * explicit_flags)))
    regex = _runtime_compile_helper_regex(pattern, flags)
    if regex === nothing
        throw(RuntimeInterpreterException(
            "regex substitution for '$target' in rule $rule_label has invalid pattern or flags",
        ))
    end

    replacement_value = _evaluate_runtime_action_expr!(
        engine,
        args[3],
        context,
        rule_label,
        current_edge,
    )
    replacement = something(_runtime_scalar_string(replacement_value; null_as_empty = true), "")
    source = something(
        _runtime_scalar_string(get(context.variables, target, nothing); null_as_empty = true),
        "",
    )
    updated = _runtime_replace_regex(
        source,
        regex,
        replacement;
        replace_all = 'g' in flags,
    )
    delete!(context.arrays, target)
    delete!(context.hashes, target)
    context.variables[target] = updated
    return true
end

function _runtime_regex_substitution_flags!(engine, expr, context, rule_label, current_edge)
    if expr isa ActionVariableExpr
        return expr.name
    end
    value = _evaluate_runtime_action_expr!(
        engine,
        expr,
        context,
        rule_label,
        current_edge,
    )
    if value isa _RuntimeRegexValue
        return value.pattern
    end
    return something(_runtime_scalar_string(value; null_as_empty = true), "")
end

function _runtime_replace_regex(source::String, regex::Regex, replacement::String; replace_all::Bool)
    output = IOBuffer()
    cursor = firstindex(source)
    replaced = false
    for matched in eachmatch(regex, source)
        if cursor < matched.offset
            print(output, SubString(source, cursor, prevind(source, matched.offset)))
        end
        print(output, _runtime_expand_regex_replacement(replacement, matched))
        cursor = matched.offset + ncodeunits(matched.match)
        replaced = true
        if !replace_all
            break
        end
    end
    if !replaced
        return source
    elseif cursor <= lastindex(source)
        print(output, SubString(source, cursor, lastindex(source)))
    end
    return String(take!(output))
end

function _runtime_expand_regex_replacement(replacement::String, matched::RegexMatch)
    return replace(replacement, r"\$(\d+)" => placeholder -> begin
        text = String(placeholder)
        index = something(tryparse(Int, text[2:end]), -1)
        if index == 0
            return matched.match
        elseif 1 <= index <= length(matched.captures)
            return something(matched.captures[index], "")
        end
        return ""
    end)
end

function _call_runtime_split(values)
    if length(values) < 2
        return nothing
    end
    value = _runtime_scalar_string(values[1])
    if value === nothing
        return Any[]
    end
    delimiter = values[2]
    if delimiter isa _RuntimeRegexValue
        regex = _runtime_compile_helper_regex(delimiter.pattern, delimiter.flags)
        if regex === nothing
            return Any[]
        end
        return Any[String(item) for item in split(value, regex; keepempty = true)]
    end
    literal = _runtime_scalar_string(delimiter; null_as_empty = true)
    if literal === nothing
        return Any[]
    elseif isempty(literal)
        return Any[string(char) for char in value]
    end
    return Any[String(item) for item in split(value, literal; keepempty = true)]
end

function _runtime_value_length(value)
    if value === nothing
        return nothing
    elseif value isa AbstractString || value isa AbstractVector || value isa AbstractDict
        return length(value)
    end
    text = _runtime_scalar_string(value)
    return text === nothing ? nothing : length(text)
end

function _runtime_is_empty(value)
    return value === nothing ||
        ((value isa AbstractString || value isa AbstractVector || value isa AbstractDict) && isempty(value))
end

function _call_runtime_string_comparison(helper_name, values)
    if length(values) < 2
        return nothing
    end
    left = _runtime_scalar_string(values[1])
    right = _runtime_scalar_string(values[2])
    if left === nothing || right === nothing
        return nothing
    elseif helper_name == "str_eq"
        return left == right
    elseif helper_name == "str_ne"
        return left != right
    elseif helper_name == "str_gt"
        return left > right
    elseif helper_name == "str_ge"
        return left >= right
    elseif helper_name == "str_lt"
        return left < right
    elseif helper_name == "str_le"
        return left <= right
    end
    throw(RuntimeInterpreterException("unsupported string comparison helper '$helper_name'"))
end

function _call_runtime_numeric_helper(helper_name, values)
    if helper_name == "num_add"
        length(values) >= 2 || return nothing
        return _runtime_numeric_fold(values, +)
    elseif helper_name == "num_sub"
        length(values) == 2 || return nothing
        return _runtime_numeric_fold(values, -)
    elseif helper_name == "num_mul"
        length(values) >= 2 || return nothing
        return _runtime_numeric_fold(values, *)
    elseif helper_name == "num_div"
        length(values) == 2 || return nothing
        return _runtime_numeric_fold(values, (left, right) -> right == 0 ? nothing : left / right)
    elseif helper_name == "num_mod"
        if length(values) != 2
            return nothing
        end
        left = _runtime_number(values[1])
        right = _runtime_number(values[2])
        if left === nothing || right === nothing || right == 0 || !isinteger(left) || !isinteger(right)
            return nothing
        end
        return try
            _runtime_json_number(mod(left, right))
        catch
            nothing
        end
    elseif helper_name == "num_abs"
        length(values) == 1 || return nothing
        return _runtime_unary_number(values, abs)
    elseif helper_name == "num_floor"
        length(values) == 1 || return nothing
        return _runtime_unary_number(values, value -> floor(Int, value))
    elseif helper_name == "num_ceil"
        length(values) == 1 || return nothing
        return _runtime_unary_number(values, value -> ceil(Int, value))
    elseif helper_name == "num_round"
        length(values) == 1 || return nothing
        return _runtime_unary_number(
            values,
            value -> value >= 0 ? floor(Int, value + 0.5) : ceil(Int, value - 0.5),
        )
    elseif helper_name == "num_min"
        return _runtime_min_max(values, min)
    elseif helper_name == "num_max"
        return _runtime_min_max(values, max)
    elseif helper_name == "num_clamp"
        if length(values) != 3
            return nothing
        end
        value = _runtime_number(values[1])
        lower = _runtime_number(values[2])
        upper = _runtime_number(values[3])
        if value === nothing || lower === nothing || upper === nothing || lower > upper
            return nothing
        end
        return _runtime_json_number(clamp(value, lower, upper))
    elseif helper_name == "num_sum"
        numbers = _runtime_numeric_list(isempty(values) ? nothing : first(values))
        return numbers === nothing ? nothing : _runtime_json_number(sum(numbers; init = 0))
    elseif helper_name == "num_avg"
        numbers = _runtime_numeric_list(isempty(values) ? nothing : first(values))
        return numbers === nothing || isempty(numbers) ? nothing :
            _runtime_json_number(sum(numbers) / length(numbers))
    elseif helper_name == "num_median"
        numbers = _runtime_numeric_list(isempty(values) ? nothing : first(values))
        if numbers === nothing || isempty(numbers)
            return nothing
        end
        sort!(numbers)
        middle = length(numbers) ÷ 2
        value = isodd(length(numbers)) ? numbers[middle + 1] :
            (numbers[middle] + numbers[middle + 1]) / 2
        return _runtime_json_number(value)
    elseif helper_name == "num_range"
        numbers = _runtime_numeric_list(isempty(values) ? nothing : first(values))
        return numbers === nothing || isempty(numbers) ? nothing :
            _runtime_json_number(maximum(numbers) - minimum(numbers))
    elseif helper_name in ("num_eq", "num_ne", "num_gt", "num_ge", "num_lt", "num_le")
        return _runtime_numeric_comparison(helper_name, values)
    end
    throw(RuntimeInterpreterException("unsupported numeric helper '$helper_name'"))
end

function _runtime_numeric_fold(values, combine)
    if isempty(values)
        return nothing
    end
    current = _runtime_number(first(values))
    if current === nothing
        return nothing
    end
    for value in Iterators.drop(values, 1)
        next = _runtime_number(value)
        if next === nothing
            return nothing
        end
        current = try
            combine(current, next)
        catch
            return nothing
        end
        if current === nothing || !(current isa Real) || !isfinite(current)
            return nothing
        end
    end
    return _runtime_json_number(current)
end

function _runtime_unary_number(values, transform)
    if isempty(values)
        return nothing
    end
    value = _runtime_number(first(values))
    if value === nothing
        return nothing
    end
    return try
        _runtime_json_number(transform(value))
    catch
        nothing
    end
end

function _runtime_min_max(values, select)
    numbers = if length(values) == 1 && first(values) isa AbstractVector
        _runtime_numeric_list(first(values))
    elseif length(values) >= 2
        parsed = Real[]
        for value in values
            number = _runtime_number(value)
            if number === nothing
                return nothing
            end
            push!(parsed, number)
        end
        parsed
    else
        return nothing
    end
    if numbers === nothing || isempty(numbers)
        return nothing
    end
    current = first(numbers)
    for number in Iterators.drop(numbers, 1)
        current = select(current, number)
    end
    return _runtime_json_number(current)
end

function _runtime_numeric_comparison(helper_name, values)
    if length(values) != 2
        return nothing
    end
    left = _runtime_number(values[1])
    right = _runtime_number(values[2])
    if left === nothing || right === nothing
        return nothing
    end
    result = if helper_name == "num_eq"
        left == right
    elseif helper_name == "num_ne"
        left != right
    elseif helper_name == "num_gt"
        left > right
    elseif helper_name == "num_ge"
        left >= right
    elseif helper_name == "num_lt"
        left < right
    else
        left <= right
    end
    return result ? 1 : 0
end

function _runtime_numeric_list(value)
    if !(value isa AbstractVector)
        return nothing
    end
    result = Real[]
    for item in value
        number = _runtime_number(item)
        if number === nothing
            return nothing
        end
        push!(result, number)
    end
    return result
end

function _runtime_number(value)
    if value === nothing || value isa Bool || value isa AbstractVector || value isa AbstractDict
        return nothing
    elseif value isa Integer
        return value
    elseif value isa AbstractFloat
        return isfinite(value) ? value : nothing
    elseif value isa AbstractString
        if !occursin(r"\A-?(?:\d+(?:\.\d+)?|\.\d+)\z", value)
            return nothing
        end
        integer = tryparse(Int, value)
        if integer !== nothing
            return integer
        end
        number = tryparse(Float64, value)
        return number !== nothing && isfinite(number) ? number : nothing
    end
    return nothing
end

function _runtime_json_number(value::Real)
    if !isfinite(value)
        return nothing
    elseif isinteger(value)
        return try
            Int(value)
        catch
            nothing
        end
    end
    return Float64(value)
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
    cursor_before = context.cursor_codeunit
    child_rule = compiled_rule(engine.compiled_spec, current_edge.target.label)
    if child_rule === nothing
        throw(RuntimeInterpreterException(
            "action edge references undefined child '$(current_edge.target.label)'",
        ))
    end
    if _runtime_passive_terminal_rule(child_rule)
        current_edge.child_result = _RuntimeRuleResult(false, nothing)
        _trace_runtime_decision!(
            context,
            "julia_runtime:child_dispatch",
            false,
            "edge_family=action rule=$(current_edge.rule_label) " *
            "target=$(current_edge.target.label)[$(current_edge.target.index)] passive=1 " *
            "cursor_before=$cursor_before cursor_after=$(context.cursor_codeunit)",
            LinkedSpecTraceDebug,
        )
        return current_edge.child_result::_RuntimeRuleResult
    end
    current_edge.child_result = _execute_runtime_rule!(
        engine,
        current_edge.target.label,
        current_edge.target.index,
        context,
    )
    _trace_runtime_decision!(
        context,
        "julia_runtime:child_dispatch",
        current_edge.child_result.matched,
        "edge_family=action rule=$(current_edge.rule_label) " *
        "target=$(current_edge.target.label)[$(current_edge.target.index)] " *
        "cursor_before=$cursor_before cursor_after=$(context.cursor_codeunit)",
        LinkedSpecTraceDebug,
    )
    return current_edge.child_result::_RuntimeRuleResult
end

function _trace_runtime_cursor_control!(
    context::_RuntimeExecutionContext,
    rule_label::String,
    helper_name::String,
    cursor_before::Int,
    stack_before::Int,
)
    _emit_runtime_trace_event!(
        context,
        LinkedSpecTraceMark,
        "julia_runtime:cursor_control",
        "helper=$helper_name rule=$rule_label before=$cursor_before " *
        "after=$(context.cursor_codeunit) stack_before=$stack_before " *
        "stack_after=$(length(context.cursor_stack))",
        LinkedSpecTraceDebug,
    )
    return nothing
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
    name = _runtime_capture_name(engine, first(args), context, rule_label, current_edge)
    return named_capture(one_match, name)
end

function _runtime_has_named_capture(engine, one_match, args, context, rule_label, current_edge)
    if one_match === nothing || isempty(args)
        return 0
    end
    name = _runtime_capture_name(engine, first(args), context, rule_label, current_edge)
    return haskey(one_match.named, name) ? 1 : 0
end

function _runtime_capture_name(engine, expr, context, rule_label, current_edge)
    name = _runtime_variable_name(expr)
    if name !== nothing
        return name
    end
    return _runtime_string(_evaluate_runtime_action_expr!(
        engine,
        expr,
        context,
        rule_label,
        current_edge,
    ))
end

_runtime_match_length(one_match) = one_match === nothing ? nothing : char_length(one_match)

function _runtime_match_line(one_match, at_end::Bool)
    if one_match === nothing
        return 1
    end
    offset = at_end ? one_match.codeunit_end : one_match.codeunit_start
    return line_column_at_codeunit_offset(one_match.input, offset).line
end

function _runtime_match_column(one_match, at_end::Bool)
    if one_match === nothing
        return 1
    end
    offset = at_end ? one_match.codeunit_end : one_match.codeunit_start
    return line_column_at_codeunit_offset(one_match.input, offset).column
end

function _set_runtime_cursor!(context::_RuntimeExecutionContext, codeunit_cursor::Int)
    cursor = clamp(codeunit_cursor, 0, ncodeunits(context.input))
    context.registers = with_cursor_codeunit(context.registers, cursor)
    context.cursor_codeunit = cursor
    return nothing
end

function _set_runtime_capture_start!(context::_RuntimeExecutionContext, codeunit_cursor::Int)
    capture_start = clamp(codeunit_cursor, 0, ncodeunits(context.input))
    context.registers = with_capture_start_codeunit(context.registers, capture_start)
    return nothing
end

function _call_runtime_anonymous_capture_helper!(
    helper_name::String,
    context::_RuntimeExecutionContext,
)
    if helper_name == "start_capture_slice"
        _set_runtime_capture_start!(context, context.cursor_codeunit)
        return nothing
    end

    capture_start = context.registers.capture_start_codeunit
    if capture_start === nothing
        return nothing
    elseif helper_name == "capture_slice_pos"
        return codeunit_offset_to_char_offset(context.input, capture_start)
    elseif helper_name == "capture_slice_line"
        return line_column_at_codeunit_offset(context.input, capture_start).line
    elseif helper_name == "capture_slice_col"
        return line_column_at_codeunit_offset(context.input, capture_start).column
    end

    endpoint = if helper_name in (
            "capture_rest",
            "capture_rest_len",
            "capture_take_rest",
            "capture_take_rest_len",
        )
        ncodeunits(context.input)
    elseif helper_name in (
            "capture_slice_until_cursor",
            "capture_slice_until_cursor_len",
            "capture_take_until_cursor",
            "capture_take_until_cursor_len",
        )
        context.cursor_codeunit
    else
        context.registers.local_match === nothing ? nothing : context.registers.local_match.codeunit_start
    end
    if endpoint === nothing || endpoint < capture_start
        return nothing
    end

    captured = _runtime_codeunit_slice(context.input, capture_start, endpoint)
    result = endswith(helper_name, "_len") ? length(captured) : captured
    if helper_name in (
            "capture_take",
            "capture_take_len",
            "capture_take_until_cursor",
            "capture_take_until_cursor_len",
        )
        _set_runtime_capture_start!(context, context.cursor_codeunit)
    elseif helper_name in ("capture_take_rest", "capture_take_rest_len")
        _set_runtime_capture_start!(context, ncodeunits(context.input))
    end
    return result
end

function _call_runtime_named_capture_helper!(
    engine::LinkedSpecRuntimeEngine,
    helper_name::String,
    args,
    context::_RuntimeExecutionContext,
    rule_label::String,
    current_edge,
)
    mark_name(index) = index <= length(args) ?
        _runtime_capture_name(engine, args[index], context, rule_label, current_edge) : nothing
    span_text(start, endpoint) =
        start < 0 || endpoint < start || endpoint > ncodeunits(context.input) ? nothing :
        _runtime_codeunit_slice(context.input, start, endpoint)
    span_length(start, endpoint) = begin
        text = span_text(start, endpoint)
        text === nothing ? nothing : length(text)
    end

    marks = get!(context.mark_buckets, rule_label, Dict{String,Int}())
    capture_start = context.registers.capture_start_codeunit
    match_start = context.registers.local_match === nothing ? nothing :
        context.registers.local_match.codeunit_start
    cursor = context.cursor_codeunit
    input_end = ncodeunits(context.input)

    if helper_name == "start_capture_slice_from"
        name = mark_name(1)
        offset = name === nothing ? nothing : get(marks, name, nothing)
        if offset !== nothing
            _set_runtime_capture_start!(context, offset)
        end
        return nothing
    elseif helper_name == "mark_here"
        name = mark_name(1)
        if name !== nothing
            marks[name] = cursor
        end
        return nothing
    elseif helper_name == "mark_input_start"
        name = mark_name(1)
        if name !== nothing
            marks[name] = 0
        end
        return nothing
    elseif helper_name == "mark_input_end"
        name = mark_name(1)
        if name !== nothing
            marks[name] = input_end
        end
        return nothing
    elseif helper_name == "mark_entry_start"
        name = mark_name(1)
        one_match = context.registers.entry_match
        if name !== nothing && one_match !== nothing
            marks[name] = one_match.codeunit_start
        end
        return nothing
    elseif helper_name == "mark_entry_end"
        name = mark_name(1)
        one_match = context.registers.entry_match
        if name !== nothing && one_match !== nothing
            marks[name] = one_match.codeunit_end
        end
        return nothing
    elseif helper_name == "mark_match_start"
        name = mark_name(1)
        one_match = context.registers.local_match
        if name !== nothing && one_match !== nothing
            marks[name] = one_match.codeunit_start
        end
        return nothing
    elseif helper_name == "mark_match_end"
        name = mark_name(1)
        one_match = context.registers.local_match
        if name !== nothing && one_match !== nothing
            marks[name] = one_match.codeunit_end
        end
        return nothing
    elseif helper_name == "mark_copy"
        target = mark_name(1)
        source = mark_name(2)
        if target !== nothing
            offset = source === nothing ? nothing : get(marks, source, nothing)
            if offset === nothing
                delete!(marks, target)
            else
                marks[target] = offset
            end
        end
        return nothing
    elseif helper_name == "mark_capture_slice"
        name = mark_name(1)
        if name !== nothing && capture_start !== nothing
            marks[name] = capture_start
        end
        return nothing
    elseif helper_name == "mark_exists"
        name = mark_name(1)
        return name !== nothing && haskey(marks, name) ? 1 : 0
    elseif helper_name == "mark_pos"
        name = mark_name(1)
        offset = name === nothing ? nothing : get(marks, name, nothing)
        return offset === nothing ? nothing :
            codeunit_offset_to_char_offset(context.input, offset)
    elseif helper_name == "mark_line"
        name = mark_name(1)
        offset = name === nothing ? nothing : get(marks, name, nothing)
        return offset === nothing ? nothing :
            line_column_at_codeunit_offset(context.input, offset).line
    elseif helper_name == "mark_col"
        name = mark_name(1)
        offset = name === nothing ? nothing : get(marks, name, nothing)
        return offset === nothing ? nothing :
            line_column_at_codeunit_offset(context.input, offset).column
    elseif helper_name == "clear_mark"
        name = mark_name(1)
        if name !== nothing
            delete!(marks, name)
        end
        return nothing
    elseif helper_name in (
            "capture_from",
            "capture_len_from",
            "capture_until_cursor_from",
            "capture_until_cursor_len_from",
            "capture_rest_from",
            "capture_rest_len_from",
            "capture_take_len_from",
            "capture_take_until_cursor_from",
            "capture_take_until_cursor_len_from",
            "capture_take_rest_from",
            "capture_take_rest_len_from",
        )
        name = mark_name(1)
        start = name === nothing ? nothing : get(marks, name, nothing)
        if name === nothing || start === nothing
            return nothing
        end
        endpoint = if helper_name in (
                "capture_from",
                "capture_len_from",
                "capture_take_len_from",
            )
            match_start
        elseif helper_name in (
                "capture_until_cursor_from",
                "capture_until_cursor_len_from",
                "capture_take_until_cursor_from",
                "capture_take_until_cursor_len_from",
            )
            cursor
        else
            input_end
        end
        if endpoint === nothing
            return nothing
        end
        length_result = occursin("_len_", helper_name) || helper_name == "capture_len_from"
        result = length_result ? span_length(start, endpoint) : span_text(start, endpoint)
        if result !== nothing && startswith(helper_name, "capture_take_")
            marks[name] = occursin("_rest_", helper_name) ? input_end : cursor
        end
        return result
    elseif helper_name in (
            "capture_between",
            "capture_len_between",
            "capture_take_between",
            "capture_take_between_len",
        )
        start_name = mark_name(1)
        end_name = mark_name(2)
        start = start_name === nothing ? nothing : get(marks, start_name, nothing)
        endpoint = end_name === nothing ? nothing : get(marks, end_name, nothing)
        if start_name === nothing || start === nothing || endpoint === nothing
            return nothing
        end
        result = occursin("len", helper_name) ?
            span_length(start, endpoint) : span_text(start, endpoint)
        if result !== nothing && startswith(helper_name, "capture_take_")
            marks[start_name] = endpoint
        end
        return result
    end
    return nothing
end

function _runtime_diagnostic_string(value)
    scalar = _runtime_scalar_string(value; null_as_empty = true)
    return scalar === nothing ? "" : scalar
end

function _validate_runtime_diagnostic_output_arity!(
    engine,
    call,
    helper_name,
    args,
    keyword_arg_count,
    context,
    rule_label,
)
    positional_count = length(args)
    expected = helper_name == "print_each" ?
        "2 or 3 positional arguments" : "at least 1 positional argument"
    valid_count = helper_name == "print_each" ?
        positional_count in (2, 3) : positional_count >= 1
    if valid_count && keyword_arg_count == 0 && !call.trailing_block_arg
        return nothing
    end

    detail = "diagnostic helper '$helper_name' expects $expected, got " *
        "$positional_count positional and $keyword_arg_count keyword argument(s) " *
        "in rule $rule_label"
    throw(RuntimeInterpreterException(
        detail;
        diagnostic = _runtime_context_diagnostic(
            engine,
            context;
            stage = "helper_arity_mismatch",
            summary = "Julia runtime diagnostic helper arity mismatch",
            detail = detail,
            rule_label = rule_label,
        ),
    ))
end

function _emit_runtime_diagnostic_output!(context, helper_name, rule_label, message)
    if context.diagnostic_output_sink !== nothing
        event = RuntimeDiagnosticOutputEvent(helper_name, rule_label, message)
        try
            context.diagnostic_output_sink(event)
        catch error
            throw(_RuntimeDiagnosticOutputSinkFailure(error))
        end
    end
    return nothing
end

function _call_runtime_diagnostic_output_helper!(helper_name, values, context, rule_label)
    if helper_name == "print_each"
        items = !isempty(values) && first(values) isa AbstractVector ? first(values) : Any[]
        prefix = _runtime_diagnostic_string(values[2])
        suffix = length(values) == 3 ? _runtime_diagnostic_string(values[3]) : ""
        for item in items
            _emit_runtime_diagnostic_output!(
                context,
                helper_name,
                rule_label,
                prefix * _runtime_diagnostic_string(item) * suffix,
            )
        end
        return nothing
    end

    message = join(_runtime_diagnostic_string(value) for value in values)
    if helper_name == "say"
        message *= "\n"
    end
    _emit_runtime_diagnostic_output!(context, helper_name, rule_label, message)
    return nothing
end

function _call_runtime_exit_now!(engine, args, context, rule_label, current_edge)
    status = if isempty(args)
        1
    else
        value = _evaluate_runtime_action_expr!(
            engine,
            first(args),
            context,
            rule_label,
            current_edge,
        )
        something(_runtime_int(value), 1)
    end
    throw(RuntimeExitNow(status))
end

function _runtime_codeunit_slice(input::String, start_codeunit::Int, end_codeunit::Int)
    start_char = codeunit_offset_to_char_offset(input, start_codeunit)
    end_char = codeunit_offset_to_char_offset(input, end_codeunit)
    if end_char <= start_char
        return ""
    end
    chars = collect(input)
    return String(chars[start_char + 1:end_char])
end

function _call_runtime_input_slice!(engine, args, context, rule_label, current_edge)
    if isempty(args)
        return context.input
    end
    start_value = _evaluate_runtime_action_expr!(
        engine,
        args[1],
        context,
        rule_label,
        current_edge,
    )
    start_char = something(_runtime_nonnegative_int(start_value), 0)
    input_length = length(context.input)
    width = if length(args) >= 2
        width_value = _evaluate_runtime_action_expr!(
            engine,
            args[2],
            context,
            rule_label,
            current_edge,
        )
        something(_runtime_nonnegative_int(width_value), input_length)
    else
        input_length - start_char
    end
    bounded_start = min(start_char, input_length)
    if bounded_start == input_length || width == 0
        return ""
    end
    bounded_end = bounded_start + min(width, input_length - bounded_start)
    chars = collect(context.input)
    return String(chars[bounded_start + 1:bounded_end])
end

function _call_runtime_capture_until_boundary!(engine, args, context, rule_label, current_edge)
    if isempty(args)
        _trace_runtime_decision!(
            context,
            "julia_runtime:source_boundary",
            false,
            "helper=capture_until_boundary rule=$rule_label reason=arguments_empty " *
            "cursor=$(context.cursor_codeunit)",
            LinkedSpecTraceDebug,
        )
        return nothing
    end
    saw_usable_boundary = false
    boundary_start = nothing
    for arg in args
        target_label = _runtime_rule_name_from_expr(
            engine,
            arg,
            context,
            rule_label,
            current_edge,
        )
        target_rule = compiled_rule(engine.compiled_spec, target_label)
        if target_rule === nothing || isempty(target_rule.regex_patterns)
            continue
        end
        saw_usable_boundary = true
        boundary_match = seek_match(
            RuntimeRegexAlternation(target_rule),
            context.input,
            context.cursor_codeunit,
        )
        if boundary_match !== nothing &&
                (boundary_start === nothing || boundary_match.codeunit_start < boundary_start)
            boundary_start = boundary_match.codeunit_start
        end
    end
    if !saw_usable_boundary
        _trace_runtime_decision!(
            context,
            "julia_runtime:source_boundary",
            false,
            "helper=capture_until_boundary rule=$rule_label reason=no_usable_boundary " *
            "cursor=$(context.cursor_codeunit)",
            LinkedSpecTraceDebug,
        )
        return nothing
    end
    capture_start = context.cursor_codeunit
    capture_end = boundary_start === nothing ? ncodeunits(context.input) : boundary_start
    captured = _runtime_codeunit_slice(context.input, capture_start, capture_end)
    _set_runtime_cursor!(context, capture_end)
    _emit_runtime_trace_event!(
        context,
        LinkedSpecTraceMark,
        "julia_runtime:source_boundary",
        "helper=capture_until_boundary rule=$rule_label capture_start=$capture_start " *
        "boundary=$capture_end length=$(capture_end - capture_start) " *
        "found=$(boundary_start === nothing ? 0 : 1)",
        LinkedSpecTraceDebug,
    )
    return captured
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

_runtime_variable_name(expr) = expr isa ActionVariableExpr ? expr.name : nothing

function _append_runtime_array_value!(context::_RuntimeExecutionContext, name::String, value)
    stored = _runtime_copy(value)
    updated = _runtime_array_binding_for_mutation(context, name)
    push!(updated, stored)
    return _store_runtime_bare_binding!(context, name, updated)
end

function _runtime_binding_present(context::_RuntimeExecutionContext, name::String)
    return haskey(context.variables, name) || haskey(context.arrays, name) ||
           haskey(context.hashes, name)
end

function _runtime_binding_kind(value)
    if value isa AbstractVector
        return "array"
    elseif value isa AbstractDict
        return "harray"
    end
    return "scalar"
end

function _decode_runtime_codeblock(value)
    if !(value isa AbstractDict) ||
            !(get(value, "kind", nothing) in ("codeblock_literal", "codeblock_argument")) ||
            get(value, "version", nothing) != 1 ||
            !(get(value, "source_text", nothing) isa AbstractString) ||
            !(get(value, "body_source", nothing) isa AbstractString)
        return nothing
    end

    body_ast = get(value, "body_ast", nothing)
    if !(body_ast isa AbstractDict) || get(body_ast, "kind", nothing) != "action_block"
        return nothing
    end
    signature = get(value, "signature", nothing)
    if !(signature isa AbstractDict) ||
            get(signature, "kind", nothing) != "callable_signature" ||
            get(signature, "version", nothing) != 1
        return nothing
    end
    raw_params = get(signature, "positional_params", nothing)
    min_arity = get(signature, "min_arity", nothing)
    rest_param = get(signature, "rest_param", nothing)
    max_arity = get(signature, "max_arity", nothing)
    if !(raw_params isa AbstractVector) ||
            !all(parameter -> parameter isa AbstractString, raw_params) ||
            !(min_arity isa Integer) ||
            !(rest_param === nothing || rest_param isa AbstractString) ||
            !(max_arity === nothing || max_arity isa Integer)
        return nothing
    end
    positional_params = String[String(parameter) for parameter in raw_params]
    min_arity = Int(min_arity)
    max_arity = max_arity === nothing ? nothing : Int(max_arity)
    if min_arity != length(positional_params) ||
            (rest_param === nothing && max_arity != min_arity) ||
            (rest_param !== nothing && max_arity !== nothing)
        return nothing
    end
    return _RuntimeCodeblockValue(
        positional_params,
        rest_param === nothing ? nothing : String(rest_param),
        min_arity,
        max_arity,
        String(value["source_text"]),
        String(value["body_source"]),
    )
end

function _runtime_binding_kind_mismatch(name::String, expected_kind::String, value)
    actual_kind = _runtime_binding_kind(value)
    return RuntimeInterpreterException(
        "binding_kind_mismatch identifier=$name expected_kind=$expected_kind " *
        "actual_kind=$actual_kind",
    )
end

function _runtime_array_binding_for_mutation(
    context::_RuntimeExecutionContext,
    name::String,
)
    if !_runtime_binding_present(context, name)
        return Any[]
    end
    value = _read_runtime_store(context, name)
    if !(value isa AbstractVector)
        throw(_runtime_binding_kind_mismatch(name, "array", value))
    end
    return _runtime_as_array(value)
end

function _runtime_hash_binding_for_mutation(
    context::_RuntimeExecutionContext,
    name::String,
)
    if !_runtime_binding_present(context, name)
        return Dict{String,Any}()
    end
    value = _read_runtime_store(context, name)
    if !(value isa AbstractDict)
        throw(_runtime_binding_kind_mismatch(name, "harray", value))
    end
    return _runtime_as_hash(value)
end

function _store_runtime_bare_binding!(
    context::_RuntimeExecutionContext,
    name::String,
    value,
)
    stored = _runtime_copy(value)
    delete!(context.variables, name)
    delete!(context.arrays, name)
    delete!(context.hashes, name)
    context.variables[name] = stored
    return _runtime_copy(stored)
end

function _read_runtime_store(context::_RuntimeExecutionContext, name::String)
    if haskey(context.variables, name)
        return context.variables[name]
    elseif haskey(context.arrays, name)
        return context.arrays[name]
    elseif haskey(context.hashes, name)
        return context.hashes[name]
    end
    return nothing
end

function _copy_runtime_argument(engine, expr, context, rule_label, current_edge)
    name = _runtime_variable_name(expr)
    if name !== nothing
        value = _read_runtime_store(context, name)
        if value === nothing && !_runtime_binding_present(context, name) &&
                compiled_rule(engine.compiled_spec, name) !== nothing
            return Any[]
        end
        return _runtime_copy(value)
    end
    return _runtime_copy(_evaluate_runtime_action_expr!(
        engine,
        expr,
        context,
        rule_label,
        current_edge,
    ))
end

function _read_runtime_nested(engine, root, segments, context, rule_label, current_edge)
    value = root
    for segment in segments
        if segment isa ActionKeyAccessSegment
            if !(value isa AbstractDict)
                return nothing
            end
            value = get(value, segment.value, nothing)
        else
            index_value = _evaluate_runtime_action_expr!(
                engine,
                segment.expr,
                context,
                rule_label,
                current_edge,
            )
            value = _runtime_index_value(value, index_value)
        end
    end
    return value
end

function _runtime_index_value(collection, index_value)
    if collection isa AbstractDict
        return get(collection, _runtime_string(index_value), nothing)
    elseif collection isa AbstractVector
        index = _runtime_nonnegative_int(index_value)
        if index !== nothing && index < length(collection)
            return collection[index + 1]
        end
    end
    return nothing
end

function _assign_runtime_index!(
    engine,
    context,
    name,
    key_expr,
    value_expr,
    rule_label,
    current_edge,
)
    if haskey(context.variables, name)
        root = context.variables[name]
        if root isa AbstractDict
            key = _runtime_string(_evaluate_runtime_action_expr!(
                engine,
                key_expr,
                context,
                rule_label,
                current_edge,
            ))
            value = _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                value_expr,
                context,
                rule_label,
                current_edge,
            ))
            updated = _runtime_as_hash(root)
            updated[key] = value
            context.variables[name] = updated
            return _runtime_copy(updated)
        elseif root isa AbstractVector
            if key_expr isa ActionStringLiteralExpr
                return nothing
            end
            index_value = _evaluate_runtime_action_expr!(
                engine,
                key_expr,
                context,
                rule_label,
                current_edge,
            )
            index = _runtime_nonnegative_int(index_value)
            if index === nothing || index > length(root)
                return nothing
            end
            value = _runtime_copy(_evaluate_runtime_action_expr!(
                engine,
                value_expr,
                context,
                rule_label,
                current_edge,
            ))
            updated = _runtime_as_array(root)
            if index == length(updated)
                push!(updated, value)
            else
                updated[index + 1] = value
            end
            context.variables[name] = updated
            return _runtime_copy(updated)
        end
        throw(_runtime_binding_kind_mismatch(name, "harray", root))
    end

    key = _runtime_string(_evaluate_runtime_action_expr!(
        engine,
        key_expr,
        context,
        rule_label,
        current_edge,
    ))
    value = _runtime_copy(_evaluate_runtime_action_expr!(
        engine,
        value_expr,
        context,
        rule_label,
        current_edge,
    ))
    target = _runtime_hash_binding_for_mutation(context, name)
    target[key] = value
    return _store_runtime_bare_binding!(context, name, target)
end

function _assign_runtime_nested!(
    engine,
    context,
    base,
    segments,
    value_expr,
    rule_label,
    current_edge,
)
    evaluated_segments = _RuntimeEvaluatedAccessSegment[]
    for segment in segments
        if segment isa ActionKeyAccessSegment
            push!(evaluated_segments, _RuntimeEvaluatedAccessSegment(:key, segment.value))
        else
            value = _evaluate_runtime_action_expr!(
                engine,
                segment.expr,
                context,
                rule_label,
                current_edge,
            )
            push!(evaluated_segments, _RuntimeEvaluatedAccessSegment(:index, value))
        end
    end
    stored_value = _runtime_copy(_evaluate_runtime_action_expr!(
        engine,
        value_expr,
        context,
        rule_label,
        current_edge,
    ))

    storage_kind, root = _runtime_store_for_write(context, base)
    if storage_kind === nothing || isempty(evaluated_segments) ||
            !(root isa AbstractDict || root isa AbstractVector)
        return nothing
    end

    updated_root = _runtime_copy(root)
    if !_assign_runtime_nested_value!(updated_root, evaluated_segments, stored_value)
        return nothing
    end
    _store_runtime_updated_root!(context, storage_kind, base, updated_root)
    return _runtime_copy(updated_root)
end

function _runtime_store_for_write(context::_RuntimeExecutionContext, name::String)
    if haskey(context.variables, name)
        return (:variable, context.variables[name])
    elseif haskey(context.arrays, name)
        return (:array, context.arrays[name])
    elseif haskey(context.hashes, name)
        return (:hash, context.hashes[name])
    end
    return (nothing, nothing)
end

function _store_runtime_updated_root!(context, storage_kind, name, value)
    if storage_kind == :variable
        context.variables[name] = _runtime_copy(value)
    elseif storage_kind == :array
        context.arrays[name] = _runtime_as_array(value)
    else
        context.hashes[name] = _runtime_as_hash(value)
    end
    return nothing
end

function _assign_runtime_nested_value!(root, segments, stored_value)
    node = root
    for (position, segment) in enumerate(segments)
        is_last = position == length(segments)
        if segment.kind == :key
            if !(node isa AbstractDict)
                return false
            end
            key = _runtime_string(segment.value)
            if is_last
                node[key] = _runtime_copy(stored_value)
            else
                if !haskey(node, key) || node[key] === nothing
                    return false
                end
                node = node[key]
            end
            continue
        end

        if !(node isa AbstractVector)
            return false
        end
        index = _runtime_nonnegative_int(segment.value)
        if index === nothing
            return false
        end
        if is_last
            if index > length(node)
                return false
            elseif index == length(node)
                push!(node, _runtime_copy(stored_value))
            else
                node[index + 1] = _runtime_copy(stored_value)
            end
        else
            if index >= length(node) || node[index + 1] === nothing
                return false
            end
            node = node[index + 1]
        end
    end
    return true
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

function _runtime_nonnegative_int(value)
    integer = _runtime_int(value)
    return integer !== nothing && integer >= 0 ? integer : nothing
end

_runtime_string(value) = value === nothing ? "" : string(value)

function _runtime_truthy(value)
    if value === nothing
        return false
    elseif value isa Bool
        return value
    elseif value isa Number
        return value != 0
    elseif value isa AbstractString || value isa AbstractVector || value isa AbstractDict
        return !isempty(value)
    end
    return true
end

_runtime_as_array(value) = value isa AbstractVector ? Any[_runtime_copy(item) for item in value] : Any[]

function _runtime_as_hash(value)
    if !(value isa AbstractDict)
        return Dict{String,Any}()
    end
    return Dict{String,Any}(
        _runtime_string(key) => _runtime_copy(item) for (key, item) in pairs(value)
    )
end

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

_with_runtime_diagnostic(error::RuntimeInterpreterException, diagnostic::RuntimeDiagnostic) =
    error.diagnostic === nothing ? RuntimeInterpreterException(error.message; diagnostic = diagnostic) : error

function _runtime_diagnostic(
    engine::LinkedSpecRuntimeEngine;
    stage,
    summary,
    detail,
    top_rule = nothing,
    entry_rule = nothing,
    rule_label = nothing,
    handler_source_label = nothing,
    code = nothing,
    helper_name = nothing,
    actual_arity = nothing,
    expected_arity = nothing,
    callable_name = nothing,
    expected = nothing,
    got = nothing,
    value_kind = nothing,
    name = nothing,
    cycle = nothing,
    target_rule = nothing,
    regex_index = nothing,
    expected_regex_index = nothing,
    actual_regex_index = nothing,
)
    effective_rule = rule_label === nothing ? top_rule : rule_label
    return RuntimeDiagnostic(
        type = "runtime_parser",
        stage = stage,
        owner_stage = "julia_runtime",
        summary = summary,
        detail = detail,
        spec_name = engine.spec_name,
        spec_path = engine.spec_path,
        top_rule = top_rule,
        entry_rule = entry_rule,
        rule_label = rule_label,
        handler_source_label = handler_source_label === nothing ?
            (effective_rule === nothing ? "julia_runtime" : "julia_runtime:rule:$effective_rule") :
            handler_source_label,
        code = code,
        option_name = nothing,
        helper_name = helper_name,
        actual_arity = actual_arity,
        expected_arity = expected_arity,
        callable_name = callable_name,
        expected = expected,
        got = got,
        value_kind = value_kind,
        name = name,
        cycle = cycle,
        target_rule = target_rule,
        regex_index = regex_index,
        expected_regex_index = expected_regex_index,
        actual_regex_index = actual_regex_index,
    )
end

function _runtime_context_diagnostic(
    engine::LinkedSpecRuntimeEngine,
    context::_RuntimeExecutionContext;
    stage,
    summary,
    detail,
    rule_label = nothing,
    handler_source_label = nothing,
    code = nothing,
    helper_name = nothing,
    actual_arity = nothing,
    expected_arity = nothing,
    callable_name = nothing,
    expected = nothing,
    got = nothing,
    value_kind = nothing,
    name = nothing,
    cycle = nothing,
)
    return _runtime_diagnostic(
        engine;
        stage = stage,
        summary = summary,
        detail = detail,
        top_rule = context.top_rule,
        rule_label = rule_label,
        handler_source_label = handler_source_label,
        code = code,
        helper_name = helper_name,
        actual_arity = actual_arity,
        expected_arity = expected_arity,
        callable_name = callable_name,
        expected = expected,
        got = got,
        value_kind = value_kind,
        name = name,
        cycle = cycle,
    )
end

function to_json(diagnostic::RuntimeDiagnostic)
    value = Dict{String,Any}(
        "type" => diagnostic.type,
        "stage" => diagnostic.stage,
        "summary" => diagnostic.summary,
        "detail" => diagnostic.detail,
    )
    optional_fields = (
        "owner_stage" => diagnostic.owner_stage,
        "spec_name" => diagnostic.spec_name,
        "spec_path" => diagnostic.spec_path,
        "top_rule" => diagnostic.top_rule,
        "entry_rule" => diagnostic.entry_rule,
        "rule_label" => diagnostic.rule_label,
        "handler_source_label" => diagnostic.handler_source_label,
        "code" => diagnostic.code,
        "option_name" => diagnostic.option_name,
        "helper_name" => diagnostic.helper_name,
        "actual_arity" => diagnostic.actual_arity,
        "expected_arity" => diagnostic.expected_arity,
        "callable_name" => diagnostic.callable_name,
        "expected" => diagnostic.expected,
        "got" => diagnostic.got,
        "value_kind" => diagnostic.value_kind,
        "name" => diagnostic.name,
        "cycle" => diagnostic.cycle,
        "target_rule" => diagnostic.target_rule,
        "regex_index" => diagnostic.regex_index,
        "expected_regex_index" => diagnostic.expected_regex_index,
        "actual_regex_index" => diagnostic.actual_regex_index,
    )
    for (key, field_value) in optional_fields
        if field_value !== nothing
            value[key] = field_value
        end
    end
    return value
end

to_json(event::RuntimeDiagnosticOutputEvent) = Dict{String,Any}(
    "helper_name" => event.helper_name,
    "rule_label" => event.rule_label,
    "message" => event.message,
)

function to_json(error::RuntimeInterpreterException)
    value = Dict{String,Any}("message" => error.message)
    if error.diagnostic !== nothing
        value["diagnostic"] = to_json(error.diagnostic)
    end
    return value
end

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
