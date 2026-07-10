struct CompiledSpecException <: Exception
    message::String
end

Base.showerror(io::IO, error::CompiledSpecException) = print(io, error.message)

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
        code = edge.code,
        fluent_chain = edge.fluent_chain,
        action_payload = edge.action_payload,
    )
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

struct CompiledDescriptorState
    compiled_spec_state::CompiledSpec
    dependency_regex_state::CompiledDependencyRegexState
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
        registry = user_function_registry_from_spec(spec)
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
        rethrow()
    end
    definition_order = String[]
    rules_by_label = Dict{String,CompiledRule}()
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
            compiled_rule_value = _compile_rule(rule, function_registry)
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

    return CompiledSpec(
        definition_order = definition_order,
        compiled_rule_order = compiled_rule_order,
        rules_by_label = resolved_rules,
        redefined_rule_labels = redefined_rule_labels,
        function_registry = function_registry,
        dependency_regex_state = dependency_regex_state,
    )
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
        "has_parent_regex" => edge.has_parent_regex,
        "fluent_chain" => [to_json(call) for call in edge.fluent_chain],
    )
    _put_if_present!(result, "code", edge.code)
    if edge.action_payload !== nothing
        result["action_payload"] = to_json(edge.action_payload)
    end
    return result
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
        "action_edges" => [to_json(edge) for edge in rule.action_edges],
        "blind_edges" => [to_json(edge) for edge in rule.blind_edges],
        "lifecycle_action_payloads" => [to_json(payload) for payload in rule.lifecycle_action_payloads],
        "plain_action_payloads" => [to_json(payload) for payload in rule.plain_action_payloads],
        "meta" => Dict{String,Any}(
            "label" => rule.label,
            "line" => rule.header.line,
            "is_top" => rule.header.is_top,
            "mode" => to_json(rule.mode_metadata),
        ),
    )
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
            entry.definition.name => to_json(entry) for entry in compiled.function_registry.entries
        ),
        "dependency_regex_map" => to_descriptor_json(state.dependency_regex_state),
        "meta" => Dict{String,Any}(
            "descriptor_model" => "compiled_descriptor_state",
            "compiled_spec_model" => "compiled_spec_state",
            "compiled_dependency_regex_model" => "compiled_dependency_regex_state",
            "parse_mode" => "seek",
            "definition_order" => compiled.definition_order,
            "compiled_rule_order" => compiled.compiled_rule_order,
            "redefined_rule_labels" => compiled.redefined_rule_labels,
            "function_order" => user_function_names(compiled.function_registry),
            "function_count" => length(compiled.function_registry.entries),
        ),
    )
end

function _compile_rule(rule::Rule, function_registry::UserFunctionRegistry)
    regex_patterns = String[]
    dependency_refs = DependencyRef[]
    action_edges = CompiledActionEdge[]
    blind_edges = CompiledBlindEdge[]
    lifecycle_action_payloads = CompiledActionPayload[]
    plain_action_payloads = CompiledActionPayload[]
    current_regex_index = 0
    last_regex_line = nothing

    for element in rule.body
        kind = element.kind
        if kind isa RegexBodyElementKind
            push!(regex_patterns, kind.pattern)
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
                ref = DependencyRef(label = target.label, index = target.index)
                push!(dependency_refs, ref)
                push!(
                    action_edges,
                    CompiledActionEdge(
                        line = element.line,
                        source = element.source,
                        targets = [ref],
                        regex_index = regex_index,
                        child_regex_index = target.index,
                        has_parent_regex = has_parent_regex,
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
        else
            last_regex_line = nothing
        end
    end

    return CompiledRule(
        label = rule.header.label,
        header = rule.header,
        mode_metadata = CompiledRuleModeMetadata(rule.header),
        regex_patterns = regex_patterns,
        dependency_refs = dependency_refs,
        action_edges = action_edges,
        blind_edges = blind_edges,
        lifecycle_action_payloads = lifecycle_action_payloads,
        plain_action_payloads = plain_action_payloads,
        body_elements = rule.body,
    )
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
