struct CompiledSpecException <: Exception
    message::String
end

Base.showerror(io::IO, error::CompiledSpecException) = print(io, error.message)

const ENTRY_RULE_CONTRACT_ID = "linkedspec-root-rule-selection-v1"
const RULE_LOCAL_CURSOR_CONTRACT_ID = "linkedspec-rule-local-cursor-v1"
const REGEX_SLOT_IDENTITY_CONTRACT_ID = "linkedspec-duplicate-regex-slot-identity-v1"

@enum EntryRuleSelectionBasis begin
    ExplicitSelectorBasis
    FirstAuthoredMarkerBasis
    FirstAuthoredRuleBasis
end

function entry_rule_selection_basis_name(basis::EntryRuleSelectionBasis)
    if basis == ExplicitSelectorBasis
        return "explicit_selector"
    elseif basis == FirstAuthoredMarkerBasis
        return "first_authored_marker"
    end
    return "first_authored_rule"
end

struct EntryRuleSelectionException <: Exception
    code::String
    stage::String
    message::String
    entry_rule::Union{Nothing,String}
end

function EntryRuleSelectionException(; code, stage, message, entry_rule = nothing)
    return EntryRuleSelectionException(
        String(code),
        String(stage),
        String(message),
        entry_rule === nothing ? nothing : String(entry_rule),
    )
end

Base.showerror(io::IO, error::EntryRuleSelectionException) = print(io, error.message)

function to_json(error::EntryRuleSelectionException)
    fields = Dict{String,Any}()
    if error.entry_rule !== nothing
        fields["entry_rule"] = error.entry_rule
    end
    return Dict{String,Any}(
        "code" => error.code,
        "stage" => error.stage,
        "message" => error.message,
        "fields" => fields,
    )
end

struct DependencyRef
    label::String
    index::Int
end

DependencyRef(; label, index = 0) = DependencyRef(String(label), index)

struct CompiledRuleModeMetadata
    name::String
    is_top::Bool
    is_and::Bool
    is_repetition::Bool
    rep_min::Union{Nothing,Int}
    rep_max::Union{Nothing,Int}
end

function CompiledRuleModeMetadata(header::RuleHeader)
    return CompiledRuleModeMetadata(
        header.mode.name,
        header.is_top,
        is_and(header.mode),
        is_repetition(header.mode),
        rep_min(header.mode),
        rep_max(header.mode),
    )
end

rule_family(metadata::CompiledRuleModeMetadata) = metadata.is_and ? "and" : "or_default"
cursor_policy(metadata::CompiledRuleModeMetadata) = metadata.is_and ? "consume" : "seek"

struct CompiledActionPayload
    role::String
    line::Int
    source::String
    code::String
    lifecycle::Union{Nothing,String}
    action_ast::ActionBlock
    contracts::ActionContractResolution
end

function CompiledActionPayload(; role, line, source, code, action_ast, contracts, lifecycle = nothing)
    return CompiledActionPayload(
        String(role),
        line,
        String(source),
        String(code),
        lifecycle === nothing ? nothing : String(lifecycle),
        action_ast,
        contracts,
    )
end

struct CompiledActionEdge
    line::Int
    source::String
    targets::Vector{DependencyRef}
    regex_index::Int
    child_regex_index::Int
    has_parent_regex::Bool
    selector_kind::String
    authored_selector::Union{Nothing,Int,String}
    target_slot_id::Union{Nothing,String}
    source_id::String
    code::Union{Nothing,String}
    fluent_chain::Vector{FluentCall}
    action_payload::Union{Nothing,CompiledActionPayload}
end

function CompiledActionEdge(;
    line,
    source,
    targets,
    regex_index,
    child_regex_index,
    has_parent_regex,
    selector_kind = "unindexed",
    authored_selector = nothing,
    target_slot_id = nothing,
    source_id = "inline",
    code = nothing,
    fluent_chain = FluentCall[],
    action_payload = nothing,
)
    return CompiledActionEdge(
        line,
        String(source),
        DependencyRef[targets...],
        regex_index,
        child_regex_index,
        has_parent_regex,
        String(selector_kind),
        authored_selector === nothing ? nothing : authored_selector,
        target_slot_id === nothing ? nothing : String(target_slot_id),
        String(source_id),
        code === nothing ? nothing : String(code),
        FluentCall[fluent_chain...],
        action_payload,
    )
end

function compiled_action_edge_with(edge::CompiledActionEdge; regex_index = edge.regex_index)
    return CompiledActionEdge(
        line = edge.line,
        source = edge.source,
        targets = edge.targets,
        regex_index = regex_index,
        child_regex_index = edge.child_regex_index,
        has_parent_regex = edge.has_parent_regex,
        selector_kind = edge.selector_kind,
        authored_selector = edge.authored_selector,
        target_slot_id = edge.target_slot_id,
        source_id = edge.source_id,
        code = edge.code,
        fluent_chain = edge.fluent_chain,
        action_payload = edge.action_payload,
    )
end

struct CompiledRegexSlotMetadata
    regex_index::Int
    slot_id::Union{Nothing,String}
    source_id::String
    line::Int
end

function CompiledRegexSlotMetadata(; regex_index, slot_id = nothing, source_id, line)
    return CompiledRegexSlotMetadata(
        regex_index,
        slot_id === nothing ? nothing : String(slot_id),
        String(source_id),
        line,
    )
end

struct CompiledCaptureGapsMetadata
    directive::String
    source_id::String
    line::Int
end

function CompiledCaptureGapsMetadata(; directive = "@capture_gaps", source_id, line)
    return CompiledCaptureGapsMetadata(String(directive), String(source_id), line)
end

struct CompiledBlindEdge
    line::Int
    source::String
    target::DependencyRef
    code::Union{Nothing,String}
    fluent_chain::Vector{FluentCall}
    action_payload::Union{Nothing,CompiledActionPayload}
end

function CompiledBlindEdge(; line, source, target, code = nothing, fluent_chain = FluentCall[], action_payload = nothing)
    return CompiledBlindEdge(
        line,
        String(source),
        target,
        code === nothing ? nothing : String(code),
        FluentCall[fluent_chain...],
        action_payload,
    )
end

struct CompiledRule
    label::String
    header::RuleHeader
    mode_metadata::CompiledRuleModeMetadata
    regex_patterns::Vector{String}
    regex_slots::Vector{CompiledRegexSlotMetadata}
    capture_gaps::Union{Nothing,CompiledCaptureGapsMetadata}
    dependency_refs::Vector{DependencyRef}
    action_edges::Vector{CompiledActionEdge}
    blind_edges::Vector{CompiledBlindEdge}
    lifecycle_action_payloads::Vector{CompiledActionPayload}
    plain_action_payloads::Vector{CompiledActionPayload}
    body_elements::Vector{BodyElement}
end

function CompiledRule(;
    label,
    header,
    mode_metadata,
    regex_patterns,
    regex_slots = CompiledRegexSlotMetadata[],
    capture_gaps = nothing,
    dependency_refs,
    action_edges,
    blind_edges,
    lifecycle_action_payloads,
    plain_action_payloads,
    body_elements,
)
    return CompiledRule(
        String(label),
        header,
        mode_metadata,
        String[regex_patterns...],
        CompiledRegexSlotMetadata[regex_slots...],
        capture_gaps,
        DependencyRef[dependency_refs...],
        CompiledActionEdge[action_edges...],
        CompiledBlindEdge[blind_edges...],
        CompiledActionPayload[lifecycle_action_payloads...],
        CompiledActionPayload[plain_action_payloads...],
        BodyElement[body_elements...],
    )
end

function compiled_rule_with(rule::CompiledRule; regex_patterns = rule.regex_patterns, action_edges = rule.action_edges)
    return CompiledRule(
        label = rule.label,
        header = rule.header,
        mode_metadata = rule.mode_metadata,
        regex_patterns = regex_patterns,
        regex_slots = rule.regex_slots,
        capture_gaps = rule.capture_gaps,
        dependency_refs = rule.dependency_refs,
        action_edges = action_edges,
        blind_edges = rule.blind_edges,
        lifecycle_action_payloads = rule.lifecycle_action_payloads,
        plain_action_payloads = rule.plain_action_payloads,
        body_elements = rule.body_elements,
    )
end

function action_payloads(rule::CompiledRule)
    payloads = CompiledActionPayload[]
    for edge in rule.action_edges
        if edge.action_payload !== nothing
            push!(payloads, edge.action_payload)
        end
    end
    for edge in rule.blind_edges
        if edge.action_payload !== nothing
            push!(payloads, edge.action_payload)
        end
    end
    append!(payloads, rule.lifecycle_action_payloads)
    append!(payloads, rule.plain_action_payloads)
    return payloads
end

struct CompiledDependencyRegexEntry
    owner_label::String
    dependency_refs::Vector{DependencyRef}
    patterns::Vector{String}
end

function CompiledDependencyRegexEntry(; owner_label, dependency_refs, patterns)
    return CompiledDependencyRegexEntry(String(owner_label), DependencyRef[dependency_refs...], String[patterns...])
end

combined_pattern(entry::CompiledDependencyRegexEntry) = join(["(?:$pattern)" for pattern in entry.patterns], "|")

struct CompiledDependencyRegexState
    dependency_regex_map::Dict{String,CompiledDependencyRegexEntry}
end

struct CompiledSpec
    definition_order::Vector{String}
    compiled_rule_order::Vector{String}
    rules_by_label::Dict{String,CompiledRule}
    redefined_rule_labels::Vector{String}
    function_registry::UserFunctionRegistry
    dependency_regex_state::CompiledDependencyRegexState
end

struct ResolvedEntryRule
    rule::CompiledRule
    basis::EntryRuleSelectionBasis
end

function CompiledSpec(;
    definition_order,
    compiled_rule_order,
    rules_by_label,
    redefined_rule_labels,
    function_registry,
    dependency_regex_state,
)
    return CompiledSpec(
        String[definition_order...],
        String[compiled_rule_order...],
        Dict{String,CompiledRule}(String(label) => rule for (label, rule) in rules_by_label),
        String[redefined_rule_labels...],
        function_registry,
        dependency_regex_state,
    )
end

function resolve_entry_rule(compiled::CompiledSpec, explicit_selector = nothing)
    if isempty(compiled.compiled_rule_order)
        throw(EntryRuleSelectionException(
            code = "no_rules_defined",
            stage = "validate_spec",
            message = "compiled spec does not contain any rules",
        ))
    end

    if explicit_selector !== nothing
        selector = String(explicit_selector)
        selected = compiled_rule(compiled, selector)
        if selected === nothing
            throw(EntryRuleSelectionException(
                code = "entry_rule_not_found",
                stage = "select_entry_rule",
                message = "entry rule '$selector' is not defined",
                entry_rule = selector,
            ))
        end
        return ResolvedEntryRule(selected, ExplicitSelectorBasis)
    end

    for label in compiled.compiled_rule_order
        candidate = _ordered_compiled_rule(compiled, label)
        if candidate.header.is_top
            return ResolvedEntryRule(candidate, FirstAuthoredMarkerBasis)
        end
    end
    return ResolvedEntryRule(
        _ordered_compiled_rule(compiled, first(compiled.compiled_rule_order)),
        FirstAuthoredRuleBasis,
    )
end

function _ordered_compiled_rule(compiled::CompiledSpec, label::AbstractString)
    rule = compiled_rule(compiled, label)
    if rule === nothing
        throw(CompiledSpecException("compiled rule order refers to missing rule '$label'"))
    end
    return rule
end

struct CompiledDescriptorState
    compiled_spec_state::CompiledSpec
    dependency_regex_state::CompiledDependencyRegexState
end

"""Reject removed aggregate selectors in every executable compiled surface."""
function validate_no_removed_aggregate_selectors(compiled::CompiledSpec)
    function validate_block(block::ActionBlock, context::String)
        selector = find_removed_aggregate_selector(block)
        if selector !== nothing
            throw(CompiledSpecException(
                "$context: $(removed_aggregate_selector_diagnostic(selector))",
            ))
        end
        return nothing
    end

    function validate_fluent_calls(calls, context::String)
        for (index, call) in enumerate(calls)
            args = strip(call.args)
            source = isempty(args) ? "$(call.method)()" : "$(call.method)($args)"
            try
                block = parse_action_block(source)
                normalize_action_block_final_codeblocks!(block, compiled.function_registry)
                validate_block(block, "$context fluent call $(index - 1)")
            catch error
                if error isa CompiledSpecException
                    rethrow()
                elseif error isa CallableContractException
                    throw(CompiledSpecException(error.message))
                end
                # Deferred fluent syntax historically remains runtime-parsed.
                # Preserve unrelated parse-failure timing.
            end
        end
        return nothing
    end

    for entry in compiled.function_registry.entries
        definition = entry.definition
        try
            block = parse_action_block(definition.body_source)
            normalize_action_block_final_codeblocks!(block, compiled.function_registry)
            validate_block(block, "function '$(definition.name)' body")
        catch error
            if error isa CompiledSpecException
                rethrow()
            elseif error isa CallableContractException
                throw(CompiledSpecException(error.message))
            end
            # Preserve unrelated user-function body parse-failure timing while
            # rejecting structurally valid removed selectors.
        end
    end

    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        for payload in action_payloads(rule)
            validate_block(
                payload.action_ast,
                "rule '$label' $(payload.role) line $(payload.line)",
            )
        end
        for (index, edge) in enumerate(rule.action_edges)
            validate_fluent_calls(edge.fluent_chain, "rule '$label' action edge $(index - 1)")
        end
        for (index, edge) in enumerate(rule.blind_edges)
            validate_fluent_calls(edge.fluent_chain, "rule '$label' blind edge $(index - 1)")
        end
    end
    return nothing
end

"""Reject a caller-constructed nested-write node with a malformed typed path."""
function validate_nested_write_serialized_state(compiled::CompiledSpec)
    function visit(value, context::String)
        if value isa AbstractVector
            for (index, item) in enumerate(value)
                visit(item, "$context[$(index - 1)]")
            end
            return nothing
        elseif !(value isa AbstractDict)
            return nothing
        end
        if get(value, "kind", nothing) == "assign_nested_access"
            segments = get(value, "segments", nothing)
            if !(segments isa AbstractVector) || isempty(segments)
                throw(CompiledSpecException(
                    "nested_write_serialized_state_invalid: $context must " *
                    "contain at least one typed path_segment",
                ))
            end
            for (index, segment) in enumerate(segments)
                if !(segment isa AbstractDict) ||
                        get(segment, "kind", nothing) != "path_segment" ||
                        !(get(segment, "expression", nothing) isa AbstractDict)
                    throw(CompiledSpecException(
                        "nested_write_serialized_state_invalid: " *
                        "$context.segments[$(index - 1)] must be one typed " *
                        "path_segment",
                    ))
                end
            end
        end
        for (key, item) in pairs(value)
            visit(item, "$context.$(String(key))")
        end
        return nothing
    end

    for label in compiled.compiled_rule_order
        rule = get(compiled.rules_by_label, label, nothing)
        rule === nothing && continue
        for (index, payload) in enumerate(action_payloads(rule))
            visit(to_json(payload.action_ast), "$label.action_payloads[$(index - 1)]")
        end
    end
    return nothing
end

"""Reject malformed caller-constructed receiver-mutation typed carriers."""
function validate_receiver_mutation_serialized_state(compiled::CompiledSpec)
    invalid(context, reason) = throw(CompiledSpecException(
        "receiver_mutation_serialized_state_invalid: $context $reason",
    ))

    function object(value, context)
        value isa AbstractDict || invalid(context, "must be an object")
        return value
    end

    function span(value, context)
        encoded = object(value, context)
        start = get(encoded, "start", nothing)
        stop = get(encoded, "end", nothing)
        if length(encoded) != 2 || !(start isa Integer) || !(stop isa Integer) ||
                start < 0 || stop < start
            invalid(context, "must be one valid half-open span")
        end
        return (start = Int(start), stop = Int(stop))
    end

    function projection(source::String, source_span, child_span)
        relative_start = child_span.start - source_span.start
        relative_stop = child_span.stop - source_span.start
        chars = collect(source)
        if relative_start < 0 || relative_stop < relative_start ||
                relative_stop > length(chars)
            return nothing
        end
        return String(chars[(relative_start + 1):relative_stop])
    end

    function validate_node(node::AbstractDict, context::String)
        get(node, "kind", nothing) == "receiver_mutation_chain" ||
            invalid(context, "kind must be receiver_mutation_chain")
        source = get(node, "source", nothing)
        source isa AbstractString || invalid(context, "source must be a string")
        source = String(source)
        source_span = span(get(node, "source_span", nothing), "$context.source_span")

        receiver = object(get(node, "receiver", nothing), "$context.receiver")
        receiver_name = get(receiver, "name", nothing)
        receiver_source = get(receiver, "source", nothing)
        receiver_span = span(
            get(receiver, "source_span", nothing),
            "$context.receiver.source_span",
        )
        if get(receiver, "kind", nothing) != "binding_reference" ||
                !(receiver_name isa AbstractString) ||
                !_action_is_identifier(receiver_name) ||
                receiver_source != receiver_name ||
                projection(source, source_span, receiver_span) != receiver_source
            invalid(context, "receiver binding reference is invalid")
        end

        mutation = object(get(node, "mutation", nothing), "$context.mutation")
        mutation_source = get(mutation, "source", nothing)
        mutation_span = span(
            get(mutation, "source_span", nothing),
            "$context.mutation.source_span",
        )
        method_span = span(
            get(mutation, "method_span", nothing),
            "$context.mutation.method_span",
        )
        args_span = span(
            get(mutation, "args_span", nothing),
            "$context.mutation.args_span",
        )
        projected_args = projection(source, source_span, args_span)
        if get(mutation, "kind", nothing) != "receiver_mutation_call" ||
                get(mutation, "method", nothing) != "map_leaves" ||
                get(mutation, "source_method", nothing) != "map_leaves!" ||
                !(mutation_source isa AbstractString) ||
                projection(source, source_span, mutation_span) != mutation_source ||
                projection(source, source_span, method_span) != "map_leaves!" ||
                !(projected_args isa AbstractString) ||
                !occursin(r"^\(\s*\)$", projected_args)
            invalid(context, "mutation call is invalid")
        end

        callback = object(
            get(mutation, "callback", nothing),
            "$context.mutation.callback",
        )
        callback_source = get(callback, "source", nothing)
        callback_span = span(
            get(callback, "source_span", nothing),
            "$context.mutation.callback.source_span",
        )
        body = object(
            get(callback, "body", nothing),
            "$context.mutation.callback.body",
        )
        body_source = get(body, "source", nothing)
        body_span = span(
            get(body, "source_span", nothing),
            "$context.mutation.callback.body.source_span",
        )
        if get(callback, "kind", nothing) != "block_value" ||
                !(callback_source isa AbstractString) ||
                projection(source, source_span, callback_span) != callback_source ||
                get(body, "kind", nothing) != "action_block" ||
                !(body_source isa AbstractString) ||
                !(get(body, "statements", nothing) isa AbstractVector) ||
                projection(source, source_span, body_span) != body_source ||
                callback_span.start + 1 != body_span.start ||
                body_span.stop + 1 != callback_span.stop
            invalid(context, "callback block is invalid")
        end

        continuation = get(node, "continuation", nothing)
        continuation isa AbstractVector || invalid(context, "continuation must be a list")
        prior_stop = mutation_span.stop
        for (index, raw_call) in enumerate(continuation)
            call_context = "$context.continuation[$(index - 1)]"
            call = object(raw_call, call_context)
            call_source = get(call, "source", nothing)
            call_method = get(call, "method", nothing)
            call_source_method = get(call, "source_method", nothing)
            call_args_source = get(call, "args_source", nothing)
            call_span = span(get(call, "source_span", nothing), "$call_context.source_span")
            call_args_span = span(get(call, "args_span", nothing), "$call_context.args_span")
            if get(call, "kind", nothing) != "fluent_call" ||
                    !(call_method isa AbstractString) || occursin('!', call_method) ||
                    call_source_method != call_method ||
                    !(call_source isa AbstractString) ||
                    !(call_args_source isa AbstractString) ||
                    !(get(call, "args", nothing) isa AbstractVector) ||
                    call_span.start <= prior_stop ||
                    projection(source, source_span, call_span) != call_source ||
                    projection(source, source_span, call_args_span) != call_args_source ||
                    !startswith(call_source, call_method)
                invalid(context, "continuation call $(index - 1) is invalid")
            end
            prior_stop = call_span.stop
        end
        if (isempty(continuation) && mutation_span.stop != source_span.stop) ||
                (!isempty(continuation) && prior_stop != source_span.stop)
            invalid(context, "terminal source span is invalid")
        end
        return nothing
    end

    function visit(value, context::String)
        if value isa AbstractVector
            for (index, item) in enumerate(value)
                visit(item, "$context[$(index - 1)]")
            end
            return nothing
        elseif !(value isa AbstractDict)
            return nothing
        end
        if get(value, "kind", nothing) == "receiver_mutation_chain" ||
                all(key -> haskey(value, key), ("receiver", "mutation", "continuation"))
            validate_node(value, context)
        end
        for (key, item) in pairs(value)
            visit(item, "$context.$(String(key))")
        end
        return nothing
    end

    for label in compiled.compiled_rule_order
        rule = get(compiled.rules_by_label, label, nothing)
        rule === nothing && continue
        for (index, payload) in enumerate(action_payloads(rule))
            visit(to_json(payload.action_ast), "$label.action_payloads[$(index - 1)]")
        end
    end
    return nothing
end

mutable struct _RecursiveObservationEffects
    writes_observation::Bool
    rule_calls::Set{String}
    function_calls::Set{String}
    recognition_attempts::Set{String}
    observed_rules::Set{String}
end

_RecursiveObservationEffects() = _RecursiveObservationEffects(
    false,
    Set{String}(),
    Set{String}(),
    Set{String}(),
    Set{String}(),
)

function _recursive_observation_effects(value, function_names::Set{String})
    effects = _RecursiveObservationEffects()

    function visit(node)
        if node isa AbstractVector
            foreach(visit, node)
            return nothing
        elseif !(node isa AbstractDict)
            return nothing
        end

        kind = get(node, "kind", nothing)
        if kind == "observe_recognition"
            effects.writes_observation = true
            rule = get(node, "rule", nothing)
            rule isa AbstractString && push!(effects.observed_rules, String(rule))
        elseif kind == "recognize_once"
            rule = get(node, "rule", nothing)
            rule isa AbstractString && push!(effects.recognition_attempts, String(rule))
        elseif kind == "call"
            name = get(node, "name", nothing)
            if name == "call"
                args = get(node, "args", nothing)
                if args isa AbstractVector && length(args) == 1
                    argument = only(args)
                    if argument isa AbstractDict &&
                            get(argument, "kind", nothing) == "variable"
                        rule = get(argument, "name", nothing)
                        rule isa AbstractString && push!(effects.rule_calls, String(rule))
                    end
                end
            elseif name isa AbstractString && String(name) in function_names
                push!(effects.function_calls, String(name))
            end
        end
        foreach(visit, values(node))
        return nothing
    end

    visit(value)
    return effects
end

"""Close recursive-observation binding writes through rules and functions."""
function validate_recursive_observation_policy(compiled::CompiledSpec)
    function_names = Set{String}(
        entry.definition.name for entry in compiled.function_registry.entries
    )
    rule_effects = Dict{String,_RecursiveObservationEffects}()
    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        rule_effects[label] = _recursive_observation_effects(
            Any[to_json(payload.action_ast) for payload in action_payloads(rule)],
            function_names,
        )
    end

    function_effects = Dict{String,_RecursiveObservationEffects}()
    for entry in compiled.function_registry.entries
        definition = entry.definition
        block = parse_action_block(definition.body_source)
        normalize_action_block_final_codeblocks!(block, compiled.function_registry)
        function_effects[definition.name] = _recursive_observation_effects(
            to_json(block),
            function_names,
        )
    end

    for effects in Iterators.flatten((values(rule_effects), values(function_effects)))
        for observed_rule in effects.observed_rules
            haskey(compiled.rules_by_label, observed_rule) && continue
            throw(CompiledSpecException(
                "source_location_recursive_observation_operand " *
                "missing static rule '$observed_rule'",
            ))
        end
    end

    rule_writes = Dict(label => effects.writes_observation for
        (label, effects) in pairs(rule_effects))
    function_writes = Dict(name => effects.writes_observation for
        (name, effects) in pairs(function_effects))
    changed = true
    while changed
        changed = false
        for (owner, effects) in pairs(rule_effects)
            inherited = any(get(rule_writes, callee, false) for callee in effects.rule_calls) ||
                any(get(function_writes, callee, false) for callee in effects.function_calls)
            if inherited && !rule_writes[owner]
                rule_writes[owner] = true
                changed = true
            end
        end
        for (owner, effects) in pairs(function_effects)
            inherited = any(get(rule_writes, callee, false) for callee in effects.rule_calls) ||
                any(get(function_writes, callee, false) for callee in effects.function_calls)
            if inherited && !function_writes[owner]
                function_writes[owner] = true
                changed = true
            end
        end
    end

    for (owner, effects) in Iterators.flatten((pairs(rule_effects), pairs(function_effects)))
        for target in effects.recognition_attempts
            get(rule_writes, target, false) || continue
            throw(CompiledSpecException(
                "recognition_effect_forbidden:binding_write " *
                "owner=$owner target=$target",
            ))
        end
    end
    return nothing
end

mutable struct _ProgressiveDispatchEffects
    dispatches::Bool
    rule_calls::Set{String}
    function_calls::Set{String}
    recognition_attempts::Set{String}
end

"""Reject generic `parse_job` spellings outside the exclusive scalar assignment."""
function validate_staged_parse_job_contract(compiled::CompiledSpec)
    function validate(value)
        if value isa AbstractVector
            foreach(validate, value)
            return nothing
        elseif !(value isa AbstractDict)
            return nothing
        end
        generic_call = get(value, "kind", nothing) == "call" &&
            get(value, "name", nothing) == "parse_job"
        receiver_call = get(value, "method", nothing) == "parse_job"
        if generic_call || receiver_call
            throw(CompiledSpecException(
                "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:" *
                "staged_parse_job_options_required",
            ))
        end
        foreach(validate, values(value))
        return nothing
    end

    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        for payload in action_payloads(rule)
            validate(to_json(payload.action_ast))
        end
    end
    for entry in compiled.function_registry.entries
        block = parse_action_block(entry.definition.body_source)
        normalize_action_block_final_codeblocks!(block, compiled.function_registry)
        validate(to_json(block))
    end
    return nothing
end

_ProgressiveDispatchEffects() = _ProgressiveDispatchEffects(
    false,
    Set{String}(),
    Set{String}(),
    Set{String}(),
)

function _progressive_dispatch_effects(value, function_names::Set{String})
    effects = _ProgressiveDispatchEffects()

    function visit(node)
        if node isa AbstractVector
            foreach(visit, node)
            return nothing
        elseif !(node isa AbstractDict)
            return nothing
        end
        kind = get(node, "kind", nothing)
        if kind == "progressive_dispatch_span" ||
                kind == "staged_parse_job_marker"
            effects.dispatches = true
        elseif kind == "recognize_once"
            rule = get(node, "rule", nothing)
            rule isa AbstractString && push!(
                effects.recognition_attempts,
                String(rule),
            )
        elseif kind == "call"
            name = get(node, "name", nothing)
            name == "dispatch_span" && throw(
                CompiledSpecException("progressive_span_binding_required"),
            )
            if name == "call"
                args = get(node, "args", nothing)
                if args isa AbstractVector && length(args) == 1
                    argument = only(args)
                    if argument isa AbstractDict &&
                            get(argument, "kind", nothing) == "variable"
                        rule = get(argument, "name", nothing)
                        rule isa AbstractString && push!(
                            effects.rule_calls,
                            String(rule),
                        )
                    end
                end
            elseif name isa AbstractString && String(name) in function_names
                push!(effects.function_calls, String(name))
            end
        end
        foreach(visit, values(node))
        return nothing
    end

    visit(value)
    return effects
end

"""Reject generic residual calls and progressive effects under recognition."""
function validate_progressive_dispatch_policy(compiled::CompiledSpec)
    function_names = Set{String}(
        entry.definition.name for entry in compiled.function_registry.entries
    )
    rule_effects = Dict{String,_ProgressiveDispatchEffects}()
    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        rule_effects[label] = _progressive_dispatch_effects(
            Any[to_json(payload.action_ast) for payload in action_payloads(rule)],
            function_names,
        )
    end
    function_effects = Dict{String,_ProgressiveDispatchEffects}()
    for entry in compiled.function_registry.entries
        definition = entry.definition
        block = parse_action_block(definition.body_source)
        normalize_action_block_final_codeblocks!(block, compiled.function_registry)
        function_effects[definition.name] = _progressive_dispatch_effects(
            to_json(block),
            function_names,
        )
    end

    rule_dispatches = Dict(
        name => effects.dispatches for (name, effects) in pairs(rule_effects)
    )
    function_dispatches = Dict(
        name => effects.dispatches for (name, effects) in pairs(function_effects)
    )
    changed = true
    while changed
        changed = false
        for (owner, effects) in pairs(rule_effects)
            inherited = any(
                get(rule_dispatches, callee, false)
                for callee in effects.rule_calls
            ) || any(
                get(function_dispatches, callee, false)
                for callee in effects.function_calls
            )
            if inherited && !rule_dispatches[owner]
                rule_dispatches[owner] = true
                changed = true
            end
        end
        for (owner, effects) in pairs(function_effects)
            inherited = any(
                get(rule_dispatches, callee, false)
                for callee in effects.rule_calls
            ) || any(
                get(function_dispatches, callee, false)
                for callee in effects.function_calls
            )
            if inherited && !function_dispatches[owner]
                function_dispatches[owner] = true
                changed = true
            end
        end
    end

    for (owner, effects) in Iterators.flatten((
        pairs(rule_effects),
        pairs(function_effects),
    ))
        for target in effects.recognition_attempts
            get(rule_dispatches, target, false) || continue
            throw(CompiledSpecException(
                "recognition_effect_forbidden:" *
                "parser_registry_or_staged_dispatch owner=$owner target=$target",
            ))
        end
    end
    return nothing
end

function _compiled_regex_slot_identity_exception(
    rule_label::AbstractString,
    target_rule::AbstractString,
    regex_index::Int,
)
    diagnostic = SpecPortableDiagnostic(
        code = "regex_slot_identity_invalid",
        stage = "validate_compiled_rule",
        message = "rule '$rule_label' references rule '$target_rule' regex slot $regex_index, but that structural slot does not exist",
        fields = Dict{String,Any}(
            "rule_label" => String(rule_label),
            "target_rule" => String(target_rule),
            "regex_index" => regex_index,
        ),
    )
    return SpecValidationException(diagnostic.message; diagnostic = diagnostic)
end

"""Validate typed action-edge slot identities before any executable route uses them."""
function validate_compiled_regex_slot_identities(compiled::CompiledSpec)
    for label in compiled.compiled_rule_order
        rule = get(compiled.rules_by_label, label, nothing)
        rule === nothing && throw(CompiledSpecException(
            "compiled rule order refers to missing rule '$label'",
        ))
        for edge in rule.action_edges
            target = isempty(edge.targets) ? nothing : first(edge.targets)
            target_label = target === nothing ? label : target.label
            identity_index = edge.child_regex_index
            target_rule = get(compiled.rules_by_label, target_label, nothing)
            authored_regex_count = target_rule === nothing ? 0 : count(
                element -> element.kind isa RegexBodyElementKind,
                target_rule.body_elements,
            )
            identity_is_valid = length(edge.targets) == 1 &&
                                target_rule !== nothing &&
                                identity_index >= 0 &&
                                identity_index < authored_regex_count &&
                                target.index == identity_index &&
                                edge.regex_index >= 0 &&
                                edge.regex_index < length(rule.regex_patterns)
            if !identity_is_valid
                throw(_compiled_regex_slot_identity_exception(
                    label,
                    target_label,
                    identity_index,
                ))
            end
        end
    end
    return nothing
end

function compile_spec(
    spec::SpecFile;
    validate_source::Bool = true,
    strict_syntax::Bool = false,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    if trace === nothing
        return _compile_spec(
            spec;
            validate_source = validate_source,
            strict_syntax = strict_syntax,
        )
    end

    scope = enter_trace_scope!(
        trace,
        "julia_compiler:compile_spec",
        "rules=$(length(spec.rules)) functions=$(length(spec.functions)) validate_source=$(validate_source ? 1 : 0) strict_syntax=$(strict_syntax ? 1 : 0)",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    try
        compiled = _compile_spec(
            spec;
            validate_source = validate_source,
            strict_syntax = strict_syntax,
            trace = trace,
        )
        exit_details =
            "status=ok rules=$(length(compiled.compiled_rule_order)) functions=$(length(compiled.function_registry.entries))"
        return compiled
    catch error
        exit_details = "status=error error=$(sprint(showerror, error))"
        rethrow()
    finally
        exit_trace_scope!(trace, scope, exit_details)
    end
end

function _compile_spec(
    spec::SpecFile;
    validate_source::Bool,
    strict_syntax::Bool,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    if validate_source
        validate_spec(spec; strict_syntax = strict_syntax, trace = trace)
    elseif trace !== nothing
        trace_decision!(
            trace,
            "julia_compiler:compile_spec:validate_source",
            false,
            "validate_source=0 skipped",
            LinkedSpecTraceMedium,
        )
    end

    function_registry = try
        declared_registry = user_function_registry_from_spec(spec)
        normalized_functions = FunctionDefinition[
            normalize_function_final_codeblocks(definition, declared_registry) for
            definition in spec.functions
        ]
        registry = user_function_registry_from_functions(normalized_functions)
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_compiler:compile_spec:function_registry",
                true,
                "functions=$(length(registry.entries))",
                LinkedSpecTraceMedium,
            )
        end
        registry
    catch error
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_compiler:compile_spec:function_registry",
                false,
                "error=$(sprint(showerror, error))",
                LinkedSpecTraceMedium,
            )
        end
        if error isa CallableContractException
            throw(CompiledSpecException(error.message))
        end
        rethrow()
    end
    definition_order = String[]
    rules_by_label = Dict{String,CompiledRule}()
    source_rules_by_label = Dict(rule.header.label => rule for rule in spec.rules)
    redefined_rule_labels = String[]
    redefined_seen = Set{String}()

    for (index, rule) in enumerate(spec.rules)
        label = rule.header.label
        push!(definition_order, label)
        if haskey(rules_by_label, label) && !(label in redefined_seen)
            push!(redefined_rule_labels, label)
            push!(redefined_seen, label)
        end
        try
            compiled_rule_value = _compile_rule(
                rule,
                function_registry;
                source_id = spec.source_id,
                source_rules_by_label = source_rules_by_label,
            )
            rules_by_label[label] = compiled_rule_value
            if trace !== nothing
                trace_decision!(
                    trace,
                    "julia_compiler:compile_spec:rule",
                    true,
                    "index=$(index - 1) label=$label mode=$(rule.header.mode.name) regexes=$(length(compiled_rule_value.regex_patterns)) action_edges=$(length(compiled_rule_value.action_edges)) blind_edges=$(length(compiled_rule_value.blind_edges))",
                    LinkedSpecTraceMedium,
                )
            end
        catch error
            if trace !== nothing
                trace_decision!(
                    trace,
                    "julia_compiler:compile_spec:rule",
                    false,
                    "index=$(index - 1) label=$label mode=$(rule.header.mode.name) error=$(sprint(showerror, error))",
                    LinkedSpecTraceMedium,
                )
            end
            rethrow()
        end
    end

    compiled_rule_order = _last_definition_order(definition_order)
    resolved_rules, dependency_regex_state = try
        resolved_rules = _resolve_action_edge_dependency_regexes(
            compiled_rule_order = compiled_rule_order,
            rules_by_label = rules_by_label,
        )
        dependency_regex_state = _build_dependency_regex_state(
            compiled_rule_order = compiled_rule_order,
            rules_by_label = resolved_rules,
        )
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_compiler:compile_spec:dependency_regex_map",
                true,
                "rules=$(length(compiled_rule_order)) entries=$(length(dependency_regex_state.dependency_regex_map))",
                LinkedSpecTraceMedium,
            )
        end
        (resolved_rules, dependency_regex_state)
    catch error
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_compiler:compile_spec:dependency_regex_map",
                false,
                "rules=$(length(compiled_rule_order)) error=$(sprint(showerror, error))",
                LinkedSpecTraceMedium,
            )
        end
        rethrow()
    end

    compiled = CompiledSpec(
        definition_order = definition_order,
        compiled_rule_order = compiled_rule_order,
        rules_by_label = resolved_rules,
        redefined_rule_labels = redefined_rule_labels,
        function_registry = function_registry,
        dependency_regex_state = dependency_regex_state,
    )
    validate_compiled_regex_slot_identities(compiled)
    validate_no_removed_aggregate_selectors(compiled)
    validate_nested_write_serialized_state(compiled)
    validate_receiver_mutation_serialized_state(compiled)
    validate_staged_parse_job_contract(compiled)
    validate_recursive_observation_policy(compiled)
    validate_progressive_dispatch_policy(compiled)
    return compiled
end

compiled_rule(compiled::CompiledSpec, label::AbstractString) = get(compiled.rules_by_label, String(label), nothing)
compiled_functions(compiled::CompiledSpec) = compiled.function_registry.entries
descriptor_state(compiled::CompiledSpec) = CompiledDescriptorState(compiled, compiled.dependency_regex_state)
to_descriptor_json(compiled::CompiledSpec) = to_json(descriptor_state(compiled))
to_descriptor_json(state::CompiledDependencyRegexState) = Dict(label => to_json(entry) for (label, entry) in state.dependency_regex_map)

function to_json(ref::DependencyRef)
    return Dict{String,Any}("label" => ref.label, "idx" => ref.index)
end

function to_json(metadata::CompiledRuleModeMetadata)
    result = Dict{String,Any}(
        "name" => metadata.name,
        "is_top" => metadata.is_top,
        "is_and" => metadata.is_and,
        "is_repetition" => metadata.is_repetition,
    )
    _put_if_present!(result, "rep_min", metadata.rep_min)
    _put_if_present!(result, "rep_max", metadata.rep_max)
    return result
end

function to_json(payload::CompiledActionPayload)
    result = Dict{String,Any}(
        "role" => payload.role,
        "line" => payload.line,
        "source" => payload.source,
        "code" => payload.code,
        "action_ast" => to_json(payload.action_ast),
        "contracts" => to_json(payload.contracts),
    )
    _put_if_present!(result, "lifecycle", payload.lifecycle)
    return result
end

function to_json(edge::CompiledActionEdge)
    result = Dict{String,Any}(
        "line" => edge.line,
        "source" => edge.source,
        "targets" => [to_json(target) for target in edge.targets],
        "regex_index" => edge.regex_index,
        "child_regex_index" => edge.child_regex_index,
        "selector_kind" => edge.selector_kind,
        "authored_selector" => edge.authored_selector,
        "target_rule" => only(edge.targets).label,
        "target_slot_id" => edge.target_slot_id,
        "source_id" => edge.source_id,
        "has_parent_regex" => edge.has_parent_regex,
        "fluent_chain" => [to_json(call) for call in edge.fluent_chain],
    )
    _put_if_present!(result, "code", edge.code)
    if edge.action_payload !== nothing
        result["action_payload"] = to_json(edge.action_payload)
    end
    return result
end

function to_descriptor_json(edge::CompiledActionEdge)
    result = Dict{String,Any}(
        "line" => edge.line,
        "source" => edge.source,
        "targets" => [to_json(target) for target in edge.targets],
        "regex_index" => edge.regex_index,
        "child_regex_index" => edge.child_regex_index,
        "has_parent_regex" => edge.has_parent_regex,
        "fluent_chain" => [to_json(call) for call in edge.fluent_chain],
    )
    _put_if_present!(result, "code", edge.code)
    if edge.action_payload !== nothing
        result["action_payload"] = to_json(edge.action_payload)
    end
    return result
end

function to_json(metadata::CompiledRegexSlotMetadata)
    return Dict{String,Any}(
        "regex_index" => metadata.regex_index,
        "slot_id" => metadata.slot_id,
        "source_id" => metadata.source_id,
        "line" => metadata.line,
    )
end

function to_json(metadata::CompiledCaptureGapsMetadata)
    return Dict{String,Any}(
        "enabled" => true,
        "directive" => metadata.directive,
        "source_id" => metadata.source_id,
        "line" => metadata.line,
    )
end

function to_json(edge::CompiledBlindEdge)
    result = Dict{String,Any}(
        "line" => edge.line,
        "source" => edge.source,
        "target" => to_json(edge.target),
        "fluent_chain" => [to_json(call) for call in edge.fluent_chain],
    )
    _put_if_present!(result, "code", edge.code)
    if edge.action_payload !== nothing
        result["action_payload"] = to_json(edge.action_payload)
    end
    return result
end

function to_json(rule::CompiledRule)
    return Dict{String,Any}(
        "label" => rule.label,
        "header" => to_json(rule.header),
        "re" => rule.regex_patterns,
        "regex_slots" => [to_json(slot) for slot in rule.regex_slots],
        "capture_gaps" => rule.capture_gaps === nothing ? nothing : to_json(rule.capture_gaps),
        "dependency_refs" => [to_json(ref) for ref in rule.dependency_refs],
        "mode_metadata" => to_json(rule.mode_metadata),
        "action_edges" => [to_json(edge) for edge in rule.action_edges],
        "blind_edges" => [to_json(edge) for edge in rule.blind_edges],
        "lifecycle_action_payloads" => [to_json(payload) for payload in rule.lifecycle_action_payloads],
        "plain_action_payloads" => [to_json(payload) for payload in rule.plain_action_payloads],
        "body" => [to_json(element) for element in rule.body_elements],
    )
end

function to_descriptor_json(rule::CompiledRule)
    return Dict{String,Any}(
        "handler" => Dict{String,Any}(
            "kind" => "julia_interpreter_rule",
            "label" => rule.label,
            "status" => "compiled_state_only",
        ),
        "re" => rule.regex_patterns,
        "dependency_refs" => [to_json(ref) for ref in rule.dependency_refs],
        "action_edges" => [to_descriptor_json(edge) for edge in rule.action_edges],
        "blind_edges" => [to_json(edge) for edge in rule.blind_edges],
        "lifecycle_action_payloads" => [to_json(payload) for payload in rule.lifecycle_action_payloads],
        "plain_action_payloads" => [to_json(payload) for payload in rule.plain_action_payloads],
        "meta" => Dict{String,Any}(
            "label" => rule.label,
            "line" => rule.header.line,
            "is_top" => rule.header.is_top,
            "family" => rule_family(rule.mode_metadata),
            "cursor_policy" => cursor_policy(rule.mode_metadata),
            "edge_ownership" => _descriptor_edge_ownership(rule),
            "regex_slots" => [to_json(slot) for slot in rule.regex_slots],
            "capture_gaps" => rule.capture_gaps === nothing ?
                nothing : to_json(rule.capture_gaps),
            "resolved_slot_edges" => _resolved_slot_edge_descriptor_json(rule),
            "resolved_edges" => _resolved_edge_descriptor_json(rule),
            "mode" => to_json(rule.mode_metadata),
        ),
    )
end

function _descriptor_edge_ownership(rule::CompiledRule)
    has_action = !isempty(rule.action_edges)
    has_blind = !isempty(rule.blind_edges)
    if has_action && has_blind
        return "mixed"
    elseif has_action
        return "action"
    elseif has_blind
        return "blind"
    end
    return "none"
end

function _resolved_edge_descriptor_json(rule::CompiledRule)
    rows = Dict{String,Any}[]
    for edge in rule.action_edges
        for target in edge.targets
            push!(rows, Dict{String,Any}(
                "ownership" => "action",
                "target" => target.label,
                "regex_index" => edge.child_regex_index,
                "block" => edge.code !== nothing,
                "fluent" => _descriptor_fluent_text(edge.fluent_chain),
            ))
        end
    end
    for edge in rule.blind_edges
        push!(rows, Dict{String,Any}(
            "ownership" => "blind",
            "target" => edge.target.label,
            "regex_index" => nothing,
            "block" => edge.code !== nothing,
            "fluent" => _descriptor_fluent_text(edge.fluent_chain),
        ))
    end
    return rows
end

function _resolved_slot_edge_descriptor_json(rule::CompiledRule)
    return Dict{String,Any}[
        Dict{String,Any}(
            "selector_kind" => edge.selector_kind,
            "authored_selector" => deepcopy(edge.authored_selector),
            "target_rule" => only(edge.targets).label,
            "regex_index" => edge.child_regex_index,
            "target_slot_id" => edge.target_slot_id,
        )
        for edge in rule.action_edges
    ]
end

function _descriptor_fluent_text(chain)
    if isempty(chain)
        return nothing
    end
    return join([
        isempty(call.args) ? call.method : "$(call.method)($(call.args))" for call in chain
    ], ".")
end

function to_json(entry::CompiledDependencyRegexEntry)
    return Dict{String,Any}(
        "owner_label" => entry.owner_label,
        "dependency_refs" => [to_json(ref) for ref in entry.dependency_refs],
        "patterns" => entry.patterns,
        "combined_pattern" => combined_pattern(entry),
    )
end

function to_json(state::CompiledDependencyRegexState)
    return Dict{String,Any}(
        "kind" => "compiled_dependency_regex_state",
        "dependency_regex_map" => to_descriptor_json(state),
    )
end

function to_json(compiled::CompiledSpec)
    return Dict{String,Any}(
        "kind" => "compiled_spec_state",
        "definition_order" => compiled.definition_order,
        "compiled_rule_order" => compiled.compiled_rule_order,
        "rules_by_label" => Dict{String,Any}(
            label => to_json(compiled.rules_by_label[label]) for label in compiled.compiled_rule_order
        ),
        "redefined_rule_labels" => compiled.redefined_rule_labels,
        "function_order" => user_function_names(compiled.function_registry),
        "functions_by_name" => Dict{String,Any}(
            entry.definition.name => to_json(entry) for entry in compiled.function_registry.entries
        ),
    )
end

function to_json(state::CompiledDescriptorState)
    compiled = state.compiled_spec_state
    return Dict{String,Any}(
        "spec" => Dict{String,Any}(
            label => to_descriptor_json(compiled.rules_by_label[label]) for label in compiled.compiled_rule_order
        ),
        "functions" => Dict{String,Any}(
            entry.definition.name => to_descriptor_json(entry) for entry in compiled.function_registry.entries
        ),
        "dependency_regex_map" => to_descriptor_json(state.dependency_regex_state),
        "meta" => Dict{String,Any}(
            "descriptor_model" => "compiled_descriptor_state",
            "compiled_spec_model" => "compiled_spec_state",
            "compiled_dependency_regex_model" => "compiled_dependency_regex_state",
            "cursor_contract" => RULE_LOCAL_CURSOR_CONTRACT_ID,
            "entry_rule_contract" => ENTRY_RULE_CONTRACT_ID,
            "regex_slot_identity_contract" => REGEX_SLOT_IDENTITY_CONTRACT_ID,
            "definition_order" => compiled.definition_order,
            "compiled_rule_order" => compiled.compiled_rule_order,
            "redefined_rule_labels" => compiled.redefined_rule_labels,
            "function_order" => user_function_names(compiled.function_registry),
            "function_count" => length(compiled.function_registry.entries),
        ),
    )
end

function _compile_rule(
    rule::Rule,
    function_registry::UserFunctionRegistry;
    source_id::String,
    source_rules_by_label::Dict{String,Rule},
)
    regex_patterns = String[]
    regex_slots = CompiledRegexSlotMetadata[]
    dependency_refs = DependencyRef[]
    action_edges = CompiledActionEdge[]
    blind_edges = CompiledBlindEdge[]
    lifecycle_action_payloads = CompiledActionPayload[]
    plain_action_payloads = CompiledActionPayload[]
    capture_gaps = nothing
    current_regex_index = 0
    last_regex_line = nothing

    for element in rule.body
        kind = element.kind
        if kind isa RegexBodyElementKind
            push!(regex_patterns, kind.pattern)
            push!(regex_slots, CompiledRegexSlotMetadata(
                regex_index = current_regex_index,
                slot_id = kind.slot_id,
                source_id = source_id,
                line = element.line,
            ))
            current_regex_index += 1
            last_regex_line = element.line
        elseif kind isa ActionEdgeBodyElementKind
            has_parent_regex = last_regex_line == element.line && current_regex_index > 0
            regex_index = has_parent_regex ? current_regex_index - 1 : 0
            payload = _compile_optional_action_payload(
                role = "action_edge",
                element = element,
                source_code = kind.code,
                fluent_chain = kind.fluent_chain,
                function_registry = function_registry,
            )
            for target in kind.targets
                resolved_target = _resolve_authored_target(target, source_rules_by_label)
                ref = DependencyRef(label = target.label, index = resolved_target.index)
                push!(dependency_refs, ref)
                push!(
                    action_edges,
                    CompiledActionEdge(
                        line = element.line,
                        source = element.source,
                        targets = [ref],
                        regex_index = regex_index,
                        child_regex_index = resolved_target.index,
                        has_parent_regex = has_parent_regex,
                        selector_kind = target.selector_kind,
                        authored_selector = target.authored_selector,
                        target_slot_id = resolved_target.slot_id,
                        source_id = source_id,
                        code = kind.code,
                        fluent_chain = kind.fluent_chain,
                        action_payload = payload,
                    ),
                )
            end
            last_regex_line = nothing
        elseif kind isa BlindEdgeBodyElementKind
            last_regex_line = nothing
            ref = DependencyRef(label = kind.target, index = 0)
            push!(dependency_refs, ref)
            payload = _compile_optional_action_payload(
                role = "blind_edge",
                element = element,
                source_code = kind.code,
                fluent_chain = kind.fluent_chain,
                function_registry = function_registry,
            )
            push!(
                blind_edges,
                CompiledBlindEdge(
                    line = element.line,
                    source = element.source,
                    target = ref,
                    code = kind.code,
                    fluent_chain = kind.fluent_chain,
                    action_payload = payload,
                ),
            )
        elseif kind isa BareEdgeBodyElementKind
            last_regex_line = nothing
            role = is_and(rule.header.mode) ? "blind_edge" : "action_edge"
            payload = _compile_optional_action_payload(
                role = role,
                element = element,
                source_code = kind.code,
                fluent_chain = kind.fluent_chain,
                function_registry = function_registry,
            )
            if is_and(rule.header.mode)
                target = only(kind.targets)
                ref = DependencyRef(label = target.label, index = 0)
                push!(dependency_refs, ref)
                push!(
                    blind_edges,
                    CompiledBlindEdge(
                        line = element.line,
                        source = element.source,
                        target = ref,
                        code = kind.code,
                        fluent_chain = kind.fluent_chain,
                        action_payload = payload,
                    ),
                )
            else
                for target in kind.targets
                    child_regex_index = something(target.index, 0)
                    ref = DependencyRef(label = target.label, index = child_regex_index)
                    push!(dependency_refs, ref)
                    push!(
                        action_edges,
                        CompiledActionEdge(
                            line = element.line,
                            source = element.source,
                            targets = [ref],
                            regex_index = 0,
                        child_regex_index = child_regex_index,
                        has_parent_regex = false,
                        selector_kind = target.index === nothing ? "unindexed" : "numeric",
                        authored_selector = target.index,
                        target_slot_id = _slot_id_at(
                            get(source_rules_by_label, target.label, nothing),
                            child_regex_index,
                        ),
                        source_id = source_id,
                        code = kind.code,
                            fluent_chain = kind.fluent_chain,
                            action_payload = payload,
                        ),
                    )
                end
            end
        elseif kind isa CodeBlockBodyElementKind
            last_regex_line = nothing
            push!(
                lifecycle_action_payloads,
                _compile_action_payload(
                    role = "lifecycle",
                    element = element,
                    code = kind.code,
                    lifecycle = kind.lifecycle,
                    function_registry = function_registry,
                ),
            )
        elseif kind isa PlainBlockBodyElementKind
            last_regex_line = nothing
            push!(
                plain_action_payloads,
                _compile_action_payload(
                    role = "plain_block",
                    element = element,
                    code = kind.code,
                    function_registry = function_registry,
                ),
            )
        elseif kind isa CaptureGapsDirectiveBodyElementKind
            last_regex_line = nothing
            capture_gaps = CompiledCaptureGapsMetadata(
                directive = kind.directive,
                source_id = source_id,
                line = element.line,
            )
        else
            last_regex_line = nothing
        end
    end

    return CompiledRule(
        label = rule.header.label,
        header = rule.header,
        mode_metadata = CompiledRuleModeMetadata(rule.header),
        regex_patterns = regex_patterns,
        regex_slots = regex_slots,
        capture_gaps = capture_gaps,
        dependency_refs = dependency_refs,
        action_edges = action_edges,
        blind_edges = blind_edges,
        lifecycle_action_payloads = lifecycle_action_payloads,
        plain_action_payloads = plain_action_payloads,
        body_elements = rule.body,
    )
end

function _resolve_authored_target(
    target::EdgeTarget,
    source_rules_by_label::Dict{String,Rule},
)
    target_rule = get(source_rules_by_label, target.label, nothing)
    if target.selector_kind == "named"
        index = 0
        if target_rule !== nothing
            for element in target_rule.body
                kind = element.kind
                if !(kind isa RegexBodyElementKind)
                    continue
                end
                if kind.slot_id == target.authored_selector
                    return (; index, slot_id = kind.slot_id)
                end
                index += 1
            end
        end
        return (; index = 0, slot_id = nothing)
    end
    return (;
        index = target.index,
        slot_id = _slot_id_at(target_rule, target.index),
    )
end

function _slot_id_at(rule::Union{Nothing,Rule}, index::Int)
    if rule === nothing || index < 0
        return nothing
    end
    regex_index = 0
    for element in rule.body
        kind = element.kind
        if !(kind isa RegexBodyElementKind)
            continue
        end
        regex_index == index && return kind.slot_id
        regex_index += 1
    end
    return nothing
end

function _compile_optional_action_payload(; role, element::BodyElement, source_code, fluent_chain, function_registry)
    code = source_code === nothing ? _fluent_chain_to_action_code(fluent_chain) : source_code
    if code === nothing || isempty(strip(code))
        return nothing
    end
    return _compile_action_payload(
        role = role,
        element = element,
        code = code,
        function_registry = function_registry,
    )
end

function _compile_action_payload(; role, element::BodyElement, code, function_registry, lifecycle = nothing)
    ast = parse_action_block(code)
    try
        normalize_action_block_final_codeblocks!(ast, function_registry)
    catch error
        if error isa CallableContractException
            throw(CompiledSpecException(error.message))
        end
        rethrow()
    end
    return CompiledActionPayload(
        role = role,
        line = element.line,
        source = element.source,
        code = code,
        lifecycle = lifecycle,
        action_ast = ast,
        contracts = resolve_action_block_contracts(ast; function_registry = function_registry),
    )
end

function _fluent_chain_to_action_code(fluent_chain)
    if isempty(fluent_chain)
        return nothing
    end
    return join([
        isempty(strip(call.args)) ? "$(call.method)()" : "$(call.method)($(strip(call.args)))"
        for call in fluent_chain
    ], "; ")
end

function _last_definition_order(definition_order)
    seen = Set{String}()
    reversed = String[]
    for label in reverse(definition_order)
        if !(label in seen)
            push!(seen, label)
            push!(reversed, label)
        end
    end
    return reverse(reversed)
end

function _resolve_action_edge_dependency_regexes(; compiled_rule_order, rules_by_label)
    resolved = Dict{String,CompiledRule}(label => rule for (label, rule) in rules_by_label)
    for label in compiled_rule_order
        rule = resolved[label]
        patterns = String[rule.regex_patterns...]
        action_edges = CompiledActionEdge[]
        for edge in rule.action_edges
            if edge.has_parent_regex
                push!(action_edges, edge)
                continue
            end

            target = only(edge.targets)
            if target.label == label
                if target.index < 0 || target.index >= length(patterns)
                    throw(CompiledSpecException(
                        "rule '$label' references its own regex slot $(target.index), but the rule has $(length(patterns)) parent regex slot(s)",
                    ))
                end
                push!(action_edges, compiled_action_edge_with(edge; regex_index = target.index))
                continue
            end

            child = get(resolved, target.label, get(rules_by_label, target.label, nothing))
            if child === nothing
                throw(CompiledSpecException("rule '$label' references undefined rule '$(target.label)'"))
            end
            if target.index < 0 || target.index >= length(child.regex_patterns)
                throw(CompiledSpecException(
                    "rule '$label' references rule '$(target.label)' regex slot $(target.index), but that rule has $(length(child.regex_patterns)) regex slot(s)",
                ))
            end
            regex_index = length(patterns)
            push!(patterns, child.regex_patterns[target.index + 1])
            push!(action_edges, compiled_action_edge_with(edge; regex_index = regex_index))
        end
        resolved[label] = compiled_rule_with(rule; regex_patterns = patterns, action_edges = action_edges)
    end
    return resolved
end

function _build_dependency_regex_state(; compiled_rule_order, rules_by_label)
    dependency_regex_map = Dict{String,CompiledDependencyRegexEntry}()
    for label in compiled_rule_order
        rule = rules_by_label[label]
        if isempty(rule.dependency_refs)
            continue
        end
        patterns = [
            _dependency_pattern_for(owner_label = label, ref = ref, rules_by_label = rules_by_label)
            for ref in rule.dependency_refs
        ]
        dependency_regex_map[label] = CompiledDependencyRegexEntry(
            owner_label = label,
            dependency_refs = rule.dependency_refs,
            patterns = patterns,
        )
    end
    return CompiledDependencyRegexState(dependency_regex_map)
end

function _dependency_pattern_for(; owner_label, ref::DependencyRef, rules_by_label)
    target = get(rules_by_label, ref.label, nothing)
    if target === nothing
        throw(CompiledSpecException("rule '$owner_label' references undefined rule '$(ref.label)'"))
    end
    if ref.index < 0 || ref.index >= length(target.regex_patterns)
        throw(CompiledSpecException(
            "rule '$owner_label' references rule '$(ref.label)' regex slot $(ref.index), but that rule has $(length(target.regex_patterns)) regex slot(s)",
        ))
    end
    return target.regex_patterns[ref.index + 1]
end
