const _SEMANTIC_SPEC_ID = "spec:0"

const _SEMANTIC_STATIC_RECORD_KINDS = (
    "capabilities",
    "spec",
    "source",
    "rule",
    "regex_slot",
    "edge",
    "lifecycle",
    "function",
    "helper",
    "binding",
    "call",
    "staged_artifact",
    "generated_artifact",
    "diagnostic",
    "decision",
    "execution",
    "event",
    "explanation_step",
)

const _SEMANTIC_STATIC_RELATION_KINDS = (
    "declares",
    "contains",
    "depends_on",
    "dispatches_to",
    "selects_regex",
    "calls",
    "resolves_to",
    "reads",
    "writes",
    "consumes",
    "produces",
    "lowered_from",
    "staged_by",
    "generated_as",
    "diagnoses",
    "observed_as",
    "explained_by",
)

struct _SemanticStaticObject
    values::Tuple
end

struct _SemanticStaticArray
    values::Tuple
end

"""Recursively immutable private semantic records, relations, and source references."""
struct _SemanticStaticProjection <: _AbstractSemanticStaticProjection
    snapshot::SemanticSnapshot
    source_refs::_SemanticStaticObject
    records::_SemanticStaticArray
    relations::_SemanticStaticArray
end

struct _SemanticStaticSourceRange
    start::Int
    stop::Int
end

struct _SemanticStaticScannedEdge
    ownership::String
    target::String
    target_index::Union{Nothing,Int}
end

struct _SemanticStaticScannedMember
    range::_SemanticStaticSourceRange
    regex::Union{Nothing,String}
    regex_flags::String
    edges::Tuple
    lifecycle::Union{Nothing,String}
    lifecycle_has_payload::Bool
end

struct _SemanticStaticScannedRule
    label::String
    header::_SemanticStaticSourceRange
    members::Tuple
end

struct _SemanticStaticProjectedEdge
    source::_SemanticStaticSourceRange
    ownership::String
    target::String
    target_index::Union{Nothing,Int}
    has_block::Bool
    value_shape::Dict{String,Any}
end

struct _SemanticStaticProjectedLifecycle
    member::_SemanticStaticScannedMember
    marker::String
    value_shape::Dict{String,Any}
end

function _build_semantic_static_projection(
    source_text::String,
    source_map::_SemanticSourceMap,
    logical_name::String,
    content_digest::String,
    snapshot::SemanticSnapshot,
    outcome::_SemanticCompilationOutcome,
)
    if outcome.parsed !== nothing && outcome.compiled !== nothing
        return _build_compiled_semantic_static_projection(
            source_text,
            source_map,
            logical_name,
            content_digest,
            snapshot,
            outcome.parsed,
            outcome.compiled,
            outcome.entry,
            outcome.generated_plan,
        )
    end
    return _build_failed_semantic_static_projection(
        source_text,
        source_map,
        logical_name,
        content_digest,
        snapshot,
        outcome.parsed,
        outcome.diagnostic,
    )
end

function _build_compiled_semantic_static_projection(
    source_text::String,
    source_map::_SemanticSourceMap,
    logical_name::String,
    content_digest::String,
    snapshot::SemanticSnapshot,
    parsed::SpecFile,
    compiled::CompiledSpec,
    entry::Union{Nothing,SemanticEntrySelection},
    generated_plan::Union{Nothing,SemanticGeneratedPlanInput},
)
    scans = _semantic_static_scan_rules(source_text, parsed)
    scans_by_label = Dict(scan.label => scan for scan in scans)
    parsed_by_label = Dict(rule.header.label => rule for rule in parsed.rules)
    source_refs = Dict{String,Any}()
    records = Dict{String,Any}[]
    relations = Dict{String,Any}[]
    record_sources = Dict{String,Union{Nothing,String}}()
    definition_order = [
        _semantic_static_rule_id(label) for label in compiled.definition_order
    ]
    compiled_order = [
        _semantic_static_rule_id(label) for label in compiled.compiled_rule_order
    ]
    entry_rule_id = entry === nothing ? nothing : _semantic_static_rule_id(entry.label)
    entry_basis = entry === nothing ? nothing : _semantic_static_entry_basis(entry.basis)

    push!(records, _semantic_static_record(
        id = _SEMANTIC_SPEC_ID,
        kind = "spec",
        name = _semantic_static_spec_name(logical_name),
        owner_id = nothing,
        order = 0,
        source = nothing,
        facts = Dict{String,Any}(
            "definition_order" => definition_order,
            "compiled_rule_order" => compiled_order,
            "entry_rule_id" => entry_rule_id,
            "entry_selection_basis" => entry_basis,
        ),
    ))
    push!(records, _semantic_static_source_record())

    for (rule_offset, label) in enumerate(compiled.compiled_rule_order)
        parsed_rule = get(parsed_by_label, label, nothing)
        compiled_rule = get(compiled.rules_by_label, label, nothing)
        scan = get(scans_by_label, label, nothing)
        if parsed_rule === nothing || compiled_rule === nothing || scan === nothing
            throw(_semantic_static_correlation_error(
                "Compiled rule has no matching parsed source owner",
                label,
            ))
        end
        rule_order = rule_offset - 1
        rule_id = _semantic_static_rule_id(label)
        rule_source = _semantic_static_register_source!(
            source_refs,
            rule_id,
            scan.header,
            source_text,
            source_map,
            logical_name,
            content_digest,
        )
        record_sources[rule_id] = rule_source
        projected_edges = _semantic_static_project_edges(scan, compiled_rule)
        regex_slots = _semantic_static_project_regex_slots(scan, compiled_rule)
        lifecycles = _semantic_static_project_lifecycles(scan, compiled_rule)
        repetition = _semantic_static_neutral_repetition(parsed_rule.header.mode)
        rep_minimum, rep_maximum = _semantic_static_neutral_bounds(parsed_rule.header.mode)

        push!(records, _semantic_static_record(
            id = rule_id,
            kind = "rule",
            name = label,
            owner_id = _SEMANTIC_SPEC_ID,
            order = rule_order,
            source = rule_source,
            facts = Dict{String,Any}(
                "family" => is_and(parsed_rule.header.mode) ? "and" : "or",
                "cursor_policy" => is_and(parsed_rule.header.mode) ? "contiguous" : "seek",
                "is_entry_marker" => parsed_rule.header.is_top,
                "is_repetition" => repetition,
                "rep_min" => rep_minimum,
                "rep_max" => rep_maximum,
                "edge_ownership" => _semantic_static_edge_ownership(projected_edges),
                "value_shape" => _semantic_static_rule_value_shape(
                    repetition,
                    projected_edges,
                    lifecycles,
                ),
            ),
        ))

        for (slot_offset, slot) in enumerate(regex_slots)
            slot_order = slot_offset - 1
            slot_id = "regex:$rule_id:$slot_order"
            source = _semantic_static_register_source!(
                source_refs,
                slot_id,
                slot.range,
                source_text,
                source_map,
                logical_name,
                content_digest,
            )
            record_sources[slot_id] = source
            push!(records, _semantic_static_record(
                id = slot_id,
                kind = "regex_slot",
                name = nothing,
                owner_id = rule_id,
                order = slot_order,
                source = source,
                facts = Dict{String,Any}(
                    "authored_index" => slot_order,
                    "pattern" => slot.regex,
                    "flags" => slot.regex_flags,
                    "combined_owner_ids" => Any[rule_id],
                    "target_shape" => _semantic_static_value_shape("regex_slot"),
                ),
            ))
        end

        for (edge_offset, edge) in enumerate(projected_edges)
            edge_order = edge_offset - 1
            edge_id = "edge:$rule_id:$edge_order"
            source = _semantic_static_register_source!(
                source_refs,
                edge_id,
                edge.source,
                source_text,
                source_map,
                logical_name,
                content_digest,
            )
            record_sources[edge_id] = source
            push!(records, _semantic_static_record(
                id = edge_id,
                kind = "edge",
                name = nothing,
                owner_id = rule_id,
                order = edge_order,
                source = source,
                facts = Dict{String,Any}(
                    "ownership" => edge.ownership,
                    "source_form" => edge.target_index === nothing ? "direct" : "indexed",
                    "has_block" => edge.has_block,
                    "fluent_call_ids" => Any[],
                    "value_shape" => edge.value_shape,
                    "target_shape" => _semantic_static_value_shape(
                        edge.target_index === nothing ? "rule" : "regex_slot",
                    ),
                ),
            ))
        end

        marker_counts = Dict{String,Int}()
        for lifecycle in lifecycles
            marker_order = get(marker_counts, lifecycle.marker, 0)
            marker_counts[lifecycle.marker] = marker_order + 1
            lifecycle_id = "lifecycle:$rule_id:$(lifecycle.marker):$marker_order"
            source = _semantic_static_register_source!(
                source_refs,
                lifecycle_id,
                lifecycle.member.range,
                source_text,
                source_map,
                logical_name,
                content_digest,
            )
            record_sources[lifecycle_id] = source
            push!(records, _semantic_static_record(
                id = lifecycle_id,
                kind = "lifecycle",
                name = lifecycle.marker,
                owner_id = rule_id,
                order = marker_order,
                source = source,
                facts = Dict{String,Any}(
                    "marker" => lifecycle.marker,
                    "whole_rule_return" => lifecycle.marker == "E",
                    "value_shape" => lifecycle.value_shape,
                ),
            ))
        end

        push!(relations, _semantic_static_relation(
            kind = "declares",
            from_id = _SEMANTIC_SPEC_ID,
            to_id = rule_id,
            order = rule_order,
            source = nothing,
        ))
        contains_order = 0
        for slot_offset in eachindex(regex_slots)
            slot_order = slot_offset - 1
            slot_id = "regex:$rule_id:$slot_order"
            push!(relations, _semantic_static_relation(
                kind = "contains",
                from_id = rule_id,
                to_id = slot_id,
                order = contains_order,
                source = record_sources[slot_id],
            ))
            contains_order += 1
        end
        for edge_offset in eachindex(projected_edges)
            edge_order = edge_offset - 1
            edge_id = "edge:$rule_id:$edge_order"
            push!(relations, _semantic_static_relation(
                kind = "contains",
                from_id = rule_id,
                to_id = edge_id,
                order = contains_order,
                source = record_sources[edge_id],
            ))
            contains_order += 1
        end
        empty!(marker_counts)
        for lifecycle in lifecycles
            marker_order = get(marker_counts, lifecycle.marker, 0)
            marker_counts[lifecycle.marker] = marker_order + 1
            lifecycle_id = "lifecycle:$rule_id:$(lifecycle.marker):$marker_order"
            push!(relations, _semantic_static_relation(
                kind = "contains",
                from_id = rule_id,
                to_id = lifecycle_id,
                order = contains_order,
                source = record_sources[lifecycle_id],
            ))
            contains_order += 1
        end
        for (edge_offset, edge) in enumerate(projected_edges)
            edge_order = edge_offset - 1
            edge_id = "edge:$rule_id:$edge_order"
            target_rule_id = _semantic_static_rule_id(edge.target)
            source = record_sources[edge_id]
            if !(target_rule_id == rule_id && edge.target_index !== nothing)
                push!(relations, _semantic_static_relation(
                    kind = "dispatches_to",
                    from_id = edge_id,
                    to_id = target_rule_id,
                    order = edge_order,
                    source = source,
                ))
            end
            if edge.target_index !== nothing
                push!(relations, _semantic_static_relation(
                    kind = "selects_regex",
                    from_id = edge_id,
                    to_id = "regex:$target_rule_id:$(edge.target_index)",
                    order = edge_order,
                    source = source,
                ))
            end
        end
    end

    push!(relations, _semantic_static_relation(
        kind = "contains",
        from_id = _SEMANTIC_SPEC_ID,
        to_id = _SEMANTIC_SOURCE_ID,
        order = 0,
        source = nothing,
    ))
    if isempty(parsed.functions) && length(compiled.compiled_rule_order) > 1 && entry !== nothing
        _semantic_static_add_entry_explanation!(
            records,
            relations,
            entry,
            get(record_sources, _semantic_static_rule_id(entry.label), nothing),
        )
    end

    _semantic_call_extend_core!(
        source_text = source_text,
        source_map = source_map,
        logical_name = logical_name,
        content_digest = content_digest,
        scans_by_label = scans_by_label,
        compiled = compiled,
        entry_selection = entry,
        generated_plan = generated_plan,
        source_refs = source_refs,
        records = records,
        relations = relations,
    )

    _semantic_static_canonicalize!(records, relations)
    return _semantic_static_projection(snapshot, source_refs, records, relations)
end

function _build_failed_semantic_static_projection(
    source_text::String,
    source_map::_SemanticSourceMap,
    logical_name::String,
    content_digest::String,
    snapshot::SemanticSnapshot,
    parsed::Union{Nothing,SpecFile},
    diagnostic::Union{Nothing,SemanticCompilationDiagnostic},
)
    rules = parsed === nothing ? Rule[] : parsed.rules
    scans = parsed === nothing ? () : _semantic_static_scan_rules(source_text, parsed)
    scans_by_label = Dict(scan.label => scan for scan in scans)
    normalized = _semantic_static_normalize_failure(diagnostic)
    failed_label = normalized.rule_label
    if failed_label === nothing && !isempty(rules)
        failed_label = rules[1].header.label
    end
    failed_rule_id = failed_label === nothing ? nothing : _semantic_static_rule_id(failed_label)
    failed_scan = failed_label === nothing ? nothing : get(scans_by_label, failed_label, nothing)
    source_refs = Dict{String,Any}()
    records = Dict{String,Any}[]
    relations = Dict{String,Any}[]

    push!(records, _semantic_static_record(
        id = _SEMANTIC_SPEC_ID,
        kind = "spec",
        name = _semantic_static_spec_name(logical_name),
        owner_id = nothing,
        order = 0,
        source = nothing,
        facts = Dict{String,Any}(
            "definition_order" => [
                _semantic_static_rule_id(rule.header.label) for rule in rules
            ],
            "compiled_rule_order" => Any[],
            "entry_rule_id" => nothing,
            "entry_selection_basis" => nothing,
        ),
    ))
    push!(records, _semantic_static_source_record())

    for (rule_offset, rule) in enumerate(rules)
        rule_order = rule_offset - 1
        rule_id = _semantic_static_rule_id(rule.header.label)
        scan = get(scans_by_label, rule.header.label, nothing)
        source = scan === nothing ? nothing : _semantic_static_register_source!(
            source_refs,
            rule_id,
            scan.header,
            source_text,
            source_map,
            logical_name,
            content_digest,
        )
        repetition = _semantic_static_neutral_repetition(rule.header.mode)
        rep_minimum, rep_maximum = _semantic_static_neutral_bounds(rule.header.mode)
        push!(records, _semantic_static_record(
            id = rule_id,
            kind = "rule",
            name = rule.header.label,
            owner_id = _SEMANTIC_SPEC_ID,
            order = rule_order,
            source = source,
            facts = Dict{String,Any}(
                "family" => is_and(rule.header.mode) ? "and" : "or",
                "cursor_policy" => is_and(rule.header.mode) ? "contiguous" : "seek",
                "is_entry_marker" => rule.header.is_top,
                "is_repetition" => repetition,
                "rep_min" => rep_minimum,
                "rep_max" => rep_maximum,
                "edge_ownership" => _semantic_static_scan_edge_ownership(scan),
                "value_shape" => _semantic_static_value_shape("unknown"),
            ),
        ))
    end

    diagnostic_id = "diagnostic:compile:0"
    diagnostic_member = if normalized.target === nothing || failed_scan === nothing
        nothing
    else
        _semantic_static_member_for_target(failed_scan, normalized.target)
    end
    diagnostic_source = diagnostic_member === nothing ? nothing :
                        _semantic_static_register_source!(
        source_refs,
        diagnostic_id,
        diagnostic_member.range,
        source_text,
        source_map,
        logical_name,
        content_digest,
    )
    push!(records, _semantic_static_record(
        id = diagnostic_id,
        kind = "diagnostic",
        name = normalized.code,
        owner_id = _SEMANTIC_SPEC_ID,
        order = 0,
        source = diagnostic_source,
        facts = Dict{String,Any}(
            "code" => normalized.code,
            "stage" => normalized.stage,
            "severity" => "error",
            "message" => normalized.message,
            "fields" => normalized.fields,
        ),
    ))
    push!(relations, _semantic_static_relation(
        kind = "contains",
        from_id = _SEMANTIC_SPEC_ID,
        to_id = _SEMANTIC_SOURCE_ID,
        order = 0,
        source = nothing,
    ))
    push!(relations, _semantic_static_relation(
        kind = "contains",
        from_id = _SEMANTIC_SPEC_ID,
        to_id = diagnostic_id,
        order = 1,
        source = diagnostic_source,
    ))

    if normalized.code == "unknown_rule_reference" &&
       failed_label !== nothing && failed_rule_id !== nothing && normalized.target !== nothing
        target = normalized.target
        decision_id = "decision:compile:$failed_rule_id"
        explanation_id = "explanation:$decision_id:0"
        push!(records, _semantic_static_record(
            id = decision_id,
            kind = "decision",
            name = "compile rule $failed_label",
            owner_id = failed_rule_id,
            order = 0,
            source = diagnostic_source,
            facts = Dict{String,Any}(
                "decision_kind" => "dependency_resolution",
                "outcome" => diagnostic_id,
            ),
        ))
        push!(records, _semantic_static_record(
            id = explanation_id,
            kind = "explanation_step",
            name = nothing,
            owner_id = decision_id,
            order = 0,
            source = diagnostic_source,
            facts = Dict{String,Any}(
                "rule_code" => "dependency_target_missing",
                "summary" => "The authored dependency $target has no declared rule.",
                "input_ids" => Any[failed_rule_id],
                "output_fact" => Dict{String,Any}(
                    "record_id" => decision_id,
                    "path" => "/facts/outcome",
                    "value" => diagnostic_id,
                ),
            ),
        ))
        push!(relations, _semantic_static_relation(
            kind = "diagnoses",
            from_id = diagnostic_id,
            to_id = failed_rule_id,
            order = 0,
            source = diagnostic_source,
        ))
        push!(relations, _semantic_static_relation(
            kind = "explained_by",
            from_id = decision_id,
            to_id = explanation_id,
            order = 0,
            source = diagnostic_source,
            evidence_ids = Any[diagnostic_id],
        ))
    end

    _semantic_static_canonicalize!(records, relations)
    return _semantic_static_projection(snapshot, source_refs, records, relations)
end

function _semantic_static_normalize_failure(
    diagnostic::Union{Nothing,SemanticCompilationDiagnostic},
)
    actual = diagnostic === nothing ? SemanticCompilationDiagnostic(
        code = "semantic_index_compilation_failed",
        stage = "compile_source",
        message = "Spec compilation failed.",
    ) : diagnostic
    fields = _semantic_json_value(actual.fields)
    rule_label = get(fields, "rule_label", nothing)
    target = get(fields, "target", get(fields, "target_rule", nothing))
    rule_label = rule_label isa AbstractString ? String(rule_label) : nothing
    target = target isa AbstractString ? String(target) : nothing
    if actual.code in ("bare_edge_target_undefined", "regex_slot_identity_invalid") &&
       rule_label !== nothing && target !== nothing
        return (
            code = "unknown_rule_reference",
            stage = "compile",
            message = "Rule $rule_label references unknown rule $target.",
            fields = Dict{String,Any}(
                "rule_id" => _semantic_static_rule_id(rule_label),
                "missing_rule_id" => _semantic_static_rule_id(target),
            ),
            rule_label = rule_label,
            target = target,
        )
    end
    return (
        code = actual.code,
        stage = actual.stage,
        message = actual.message,
        fields = fields,
        rule_label = rule_label,
        target = target,
    )
end

function _semantic_static_scan_edge_ownership(
    scan::Union{Nothing,_SemanticStaticScannedRule},
)
    scan === nothing && return "none"
    edges = Tuple(edge for member in scan.members for edge in member.edges)
    return _semantic_static_edge_ownership(edges)
end

function _semantic_static_member_for_target(
    scan::_SemanticStaticScannedRule,
    target::String,
)
    for member in scan.members
        any(edge -> edge.target == target, member.edges) && return member
    end
    return nothing
end

function _semantic_static_project_edges(
    scan::_SemanticStaticScannedRule,
    compiled::CompiledRule,
)
    scanned = Tuple(
        (member.range, edge) for member in scan.members for edge in member.edges
    )
    compiled_count = length(compiled.action_edges) + length(compiled.blind_edges)
    if length(scanned) != compiled_count
        throw(_semantic_static_correlation_error(
            "Authored and compiled edge counts differ",
            compiled.label;
            fields = Dict{String,Any}(
                "authored_edges" => length(scanned),
                "compiled_edges" => compiled_count,
            ),
        ))
    end
    projected = _SemanticStaticProjectedEdge[]
    action_index = 1
    blind_index = 1
    for (range, source_edge) in scanned
        if source_edge.ownership == "action"
            if action_index > length(compiled.action_edges)
                throw(_semantic_static_correlation_error(
                    "Authored action edge has no compiled owner",
                    compiled.label,
                ))
            end
            edge = compiled.action_edges[action_index]
            action_index += 1
            _semantic_static_require_action_edge(compiled.label, source_edge, edge)
            push!(projected, _SemanticStaticProjectedEdge(
                range,
                "action",
                source_edge.target,
                source_edge.target_index,
                edge.code !== nothing,
                _semantic_static_action_block_shape(
                    edge.action_payload === nothing ? nothing : edge.action_payload.action_ast,
                ),
            ))
        else
            if blind_index > length(compiled.blind_edges)
                throw(_semantic_static_correlation_error(
                    "Authored blind edge has no compiled owner",
                    compiled.label,
                ))
            end
            edge = compiled.blind_edges[blind_index]
            blind_index += 1
            if edge.target.label != source_edge.target
                throw(_semantic_static_correlation_error(
                    "Authored and compiled blind-edge identities differ",
                    compiled.label,
                ))
            end
            push!(projected, _SemanticStaticProjectedEdge(
                range,
                "blind",
                source_edge.target,
                nothing,
                edge.code !== nothing,
                _semantic_static_action_block_shape(
                    edge.action_payload === nothing ? nothing : edge.action_payload.action_ast,
                ),
            ))
        end
    end
    return Tuple(projected)
end

function _semantic_static_require_action_edge(
    owner::String,
    source::_SemanticStaticScannedEdge,
    edge::CompiledActionEdge,
)
    expected_index = something(source.target_index, 0)
    if length(edge.targets) == 1 &&
       only(edge.targets).label == source.target &&
       edge.child_regex_index == expected_index
        return nothing
    end
    throw(_semantic_static_correlation_error(
        "Authored and compiled action-edge identities differ",
        owner,
    ))
end

function _semantic_static_project_regex_slots(
    scan::_SemanticStaticScannedRule,
    compiled::CompiledRule,
)
    slots = _SemanticStaticScannedMember[]
    for member in scan.members
        member.regex === nothing && continue
        retained = isempty(member.edges) || any(
            edge -> edge.target == compiled.label && edge.target_index !== nothing,
            member.edges,
        )
        retained && push!(slots, member)
    end
    for (index, slot) in enumerate(slots)
        if index > length(compiled.regex_patterns) || compiled.regex_patterns[index] != slot.regex
            throw(_semantic_static_correlation_error(
                "Authored and compiled regex-slot identities differ",
                compiled.label;
                fields = Dict{String,Any}("slot" => index - 1),
            ))
        end
    end
    return Tuple(slots)
end

function _semantic_static_project_lifecycles(
    scan::_SemanticStaticScannedRule,
    compiled::CompiledRule,
)
    result = _SemanticStaticProjectedLifecycle[]
    payload_index = 1
    for member in scan.members
        marker = member.lifecycle
        marker === nothing && continue
        if !member.lifecycle_has_payload
            push!(result, _SemanticStaticProjectedLifecycle(
                member,
                marker,
                _semantic_static_value_shape("unknown"),
            ))
            continue
        end
        if payload_index > length(compiled.lifecycle_action_payloads)
            throw(_semantic_static_correlation_error(
                "Authored lifecycle block has no compiled payload",
                compiled.label;
                fields = Dict{String,Any}("marker" => marker),
            ))
        end
        payload = compiled.lifecycle_action_payloads[payload_index]
        payload_index += 1
        if payload.lifecycle != marker
            throw(_semantic_static_correlation_error(
                "Authored and compiled lifecycle identities differ",
                compiled.label;
                fields = Dict{String,Any}(
                    "authored_marker" => marker,
                    "compiled_marker" => payload.lifecycle,
                ),
            ))
        end
        push!(result, _SemanticStaticProjectedLifecycle(
            member,
            marker,
            _semantic_static_action_block_shape(payload.action_ast),
        ))
    end
    if payload_index - 1 != length(compiled.lifecycle_action_payloads)
        throw(_semantic_static_correlation_error(
            "Compiled lifecycle payload has no authored source owner",
            compiled.label;
            fields = Dict{String,Any}(
                "authored_payloads" => payload_index - 1,
                "compiled_payloads" => length(compiled.lifecycle_action_payloads),
            ),
        ))
    end
    return Tuple(result)
end

function _semantic_static_scan_rules(source::String, parsed::SpecFile)
    lines = _semantic_static_line_ranges(source)
    return Tuple(
        _semantic_static_scan_rule(source, lines, rule) for rule in parsed.rules
    )
end

function _semantic_static_scan_rule(
    source::String,
    lines::Tuple,
    rule::Rule,
)
    grouped = Dict{Int,Vector{BodyElement}}()
    ordered_lines = Int[]
    for element in rule.body
        if !haskey(grouped, element.line)
            grouped[element.line] = BodyElement[]
            push!(ordered_lines, element.line)
        end
        push!(grouped[element.line], element)
    end
    members = Tuple(
        _semantic_static_scan_member(
            source,
            _semantic_static_member_range(source, lines, line),
            grouped[line],
            rule.header.mode,
        ) for line in ordered_lines
    )
    return _SemanticStaticScannedRule(
        String(rule.header.label),
        _semantic_static_trimmed_line_range(source, lines, rule.header.line),
        members,
    )
end

function _semantic_static_scan_member(
    source::String,
    range::_SemanticStaticSourceRange,
    elements::Vector{BodyElement},
    mode::RuleMode,
)
    text = _semantic_static_source_slice(source, range)
    regex = nothing
    flags = ""
    edges = _SemanticStaticScannedEdge[]
    lifecycle = nothing
    lifecycle_has_payload = false
    for element in elements
        kind = element.kind
        if kind isa RegexBodyElementKind
            regex === nothing && (regex = String(kind.pattern))
            flags = _semantic_static_leading_regex_flags(text)
        elseif kind isa ActionEdgeBodyElementKind
            for target in kind.targets
                push!(edges, _SemanticStaticScannedEdge(
                    "action",
                    String(target.label),
                    _semantic_static_explicit_target_index(
                        text,
                        target.label,
                        target.index,
                    ),
                ))
            end
        elseif kind isa BlindEdgeBodyElementKind
            push!(edges, _SemanticStaticScannedEdge(
                "blind",
                String(kind.target),
                nothing,
            ))
        elseif kind isa BareEdgeBodyElementKind
            for target in kind.targets
                push!(edges, _SemanticStaticScannedEdge(
                    is_and(mode) ? "blind" : "action",
                    String(target.label),
                    is_and(mode) ? nothing : target.index,
                ))
            end
        elseif kind isa CodeBlockBodyElementKind
            lifecycle = String(kind.lifecycle)
            lifecycle_has_payload = true
        elseif kind isa LifecycleMarkerBodyElementKind
            lifecycle = String(kind.marker)
        end
    end
    return _SemanticStaticScannedMember(
        range,
        regex,
        flags,
        Tuple(edges),
        lifecycle,
        lifecycle_has_payload,
    )
end

function _semantic_static_line_ranges(source::String)
    bytes = codeunits(source)
    ranges = _SemanticStaticSourceRange[]
    start = 0
    for (index, byte) in enumerate(bytes)
        if byte == 0x0a
            push!(ranges, _SemanticStaticSourceRange(start, index - 1))
            start = index
        end
    end
    if start < length(bytes) || isempty(bytes)
        push!(ranges, _SemanticStaticSourceRange(start, length(bytes)))
    end
    return Tuple(ranges)
end

function _semantic_static_trimmed_line_range(
    source::String,
    lines::Tuple,
    line::Int,
)
    if line <= 0 || line > length(lines)
        throw(_semantic_static_correlation_error(
            "Parsed line is outside the captured source",
            string(line),
        ))
    end
    bytes = codeunits(source)
    raw = lines[line]
    start = raw.start
    stop = raw.stop
    while start < stop && _semantic_static_whitespace(bytes[start + 1])
        start += 1
    end
    while stop > start && _semantic_static_whitespace(bytes[stop])
        stop -= 1
    end
    return _SemanticStaticSourceRange(start, stop)
end

function _semantic_static_member_range(
    source::String,
    lines::Tuple,
    line::Int,
)
    first_range = _semantic_static_trimmed_line_range(source, lines, line)
    bytes = codeunits(source)
    depth = 0
    quote_byte = nothing
    escaped = false
    in_regex = first_range.start < length(bytes) && bytes[first_range.start + 1] == 0x2f
    last_non_whitespace = first_range.start
    for offset in first_range.start:(length(bytes) - 1)
        byte = bytes[offset + 1]
        if byte == 0x0a && quote_byte === nothing && !in_regex && depth == 0
            return _SemanticStaticSourceRange(first_range.start, last_non_whitespace)
        end
        !_semantic_static_whitespace(byte) && (last_non_whitespace = offset + 1)
        if in_regex
            if escaped
                escaped = false
            elseif byte == 0x5c
                escaped = true
            elseif byte == 0x2f && offset != first_range.start
                in_regex = false
            end
            continue
        end
        if quote_byte !== nothing
            if escaped
                escaped = false
            elseif byte == 0x5c
                escaped = true
            elseif byte == quote_byte
                quote_byte = nothing
            end
            continue
        end
        if byte == 0x22 || byte == 0x27
            quote_byte = byte
        elseif byte == 0x28 || byte == 0x5b || byte == 0x7b
            depth += 1
        elseif byte == 0x29 || byte == 0x5d || byte == 0x7d
            depth -= 1
        end
    end
    return _SemanticStaticSourceRange(first_range.start, last_non_whitespace)
end

_semantic_static_whitespace(byte::UInt8) = byte in (0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x20)

function _semantic_static_source_slice(
    source::String,
    range::_SemanticStaticSourceRange,
)
    range.start == range.stop && return ""
    return String(Vector{UInt8}(codeunits(source)[(range.start + 1):range.stop]))
end

function _semantic_static_leading_regex_flags(text::String)
    bytes = codeunits(text)
    isempty(bytes) && return ""
    bytes[1] == 0x2f || return ""
    escaped = false
    for index in 2:length(bytes)
        byte = bytes[index]
        if escaped
            escaped = false
        elseif byte == 0x5c
            escaped = true
        elseif byte == 0x2f
            stop = index + 1
            while stop <= length(bytes) &&
                  ((0x41 <= bytes[stop] <= 0x5a) || (0x61 <= bytes[stop] <= 0x7a))
                stop += 1
            end
            return stop == index + 1 ? "" : String(Vector{UInt8}(bytes[(index + 1):(stop - 1)]))
        end
    end
    return ""
end

function _semantic_static_explicit_target_index(
    text::String,
    label::String,
    expected::Int,
)
    escaped_label = replace(label, "\\E" => "\\E\\\\E\\Q")
    pattern = Regex("\\Q$escaped_label\\E\\s*\\[\\s*$expected\\s*\\]")
    return occursin(pattern, text) ? expected : nothing
end

function _semantic_static_add_entry_explanation!(
    records::Vector{Dict{String,Any}},
    relations::Vector{Dict{String,Any}},
    selected::SemanticEntrySelection,
    source::Union{Nothing,String},
)
    selected_rule_id = _semantic_static_rule_id(selected.label)
    basis = _semantic_static_entry_basis(selected.basis)
    decision_id = "decision:entry:spec:0"
    push!(records, _semantic_static_record(
        id = decision_id,
        kind = "decision",
        name = "entry selection",
        owner_id = _SEMANTIC_SPEC_ID,
        order = 0,
        source = source,
        facts = Dict{String,Any}(
            "decision_kind" => "entry_selection",
            "outcome" => selected_rule_id,
        ),
    ))
    first_id = "explanation:decision:entry:spec:0:0"
    explicit = selected.basis == "explicit_selector"
    push!(records, _semantic_static_record(
        id = first_id,
        kind = "explanation_step",
        name = nothing,
        owner_id = decision_id,
        order = 0,
        source = source,
        facts = Dict{String,Any}(
            "rule_code" => explicit ? "entry_explicit_selector" : "entry_explicit_selector_absent",
            "summary" => explicit ?
                         "The caller selected $(selected.label)." :
                         "No caller selector was supplied.",
            "input_ids" => Any[_SEMANTIC_SPEC_ID],
            "output_fact" => Dict{String,Any}(
                "record_id" => _SEMANTIC_SPEC_ID,
                "path" => "/facts/entry_selection_basis",
                "value" => basis,
            ),
        ),
    ))
    second_id = "explanation:decision:entry:spec:0:1"
    rule_code = basis == "first_marker" ?
                "entry_first_marker" :
                basis == "first_rule" ? "entry_first_rule" : "entry_explicit_rule"
    summary = basis == "first_marker" ?
              "The first authored entry marker selects $(selected.label)." :
              basis == "first_rule" ?
              "The first authored rule selects $(selected.label)." :
              "The explicit selector resolves to $(selected.label)."
    push!(records, _semantic_static_record(
        id = second_id,
        kind = "explanation_step",
        name = nothing,
        owner_id = decision_id,
        order = 1,
        source = source,
        facts = Dict{String,Any}(
            "rule_code" => rule_code,
            "summary" => summary,
            "input_ids" => Any[selected_rule_id],
            "output_fact" => Dict{String,Any}(
                "record_id" => _SEMANTIC_SPEC_ID,
                "path" => "/facts/entry_rule_id",
                "value" => selected_rule_id,
            ),
        ),
    ))
    push!(relations, _semantic_static_relation(
        kind = "explained_by",
        from_id = decision_id,
        to_id = first_id,
        order = 0,
        source = source,
        evidence_ids = Any[selected_rule_id],
    ))
    push!(relations, _semantic_static_relation(
        kind = "explained_by",
        from_id = decision_id,
        to_id = second_id,
        order = 1,
        source = source,
        evidence_ids = Any[selected_rule_id],
    ))
    return nothing
end

function _semantic_static_rule_value_shape(
    repetition::Bool,
    edges::Tuple,
    lifecycles::Tuple,
)
    for lifecycle in lifecycles
        if lifecycle.marker == "E" && lifecycle.value_shape["kind"] != "unknown"
            return lifecycle.value_shape
        end
    end
    element = _semantic_static_value_shape("unknown")
    for edge in edges
        if edge.value_shape["kind"] != "unknown"
            element = edge.value_shape
            break
        end
    end
    return repetition ? _semantic_static_array_shape(element) : element
end

function _semantic_static_action_block_shape(block::Union{Nothing,ActionBlock})
    block === nothing && return _semantic_static_value_shape("unknown")
    for statement in block.statements
        shape = _semantic_static_return_shape(statement.expr)
        shape !== nothing && return shape
    end
    return _semantic_static_value_shape("unknown")
end

function _semantic_static_return_shape(expression::ActionExpr)
    if expression isa ActionCallExpr && expression.name == "return"
        return isempty(expression.args) ?
               _semantic_static_value_shape("unknown") :
               _semantic_static_expression_shape(getfield(first(expression.args), :value))
    elseif expression isa ActionBlockValueExpr
        return _semantic_static_action_block_shape(expression.block)
    elseif expression isa ActionFluentChainExpr
        receiver_shape = _semantic_static_return_shape(expression.receiver)
        receiver_shape !== nothing && return receiver_shape
        for call in expression.calls
            if call.method == "return"
                return isempty(call.args) ?
                       _semantic_static_value_shape("unknown") :
                       _semantic_static_expression_shape(getfield(first(call.args), :value))
            end
        end
    end
    return nothing
end

function _semantic_static_expression_shape(expression::ActionExpr)
    if expression isa ActionStringLiteralExpr
        return _semantic_static_value_shape("string")
    elseif expression isa ActionNumberLiteralExpr
        return _semantic_static_value_shape("number")
    elseif expression isa ActionBooleanLiteralExpr
        return _semantic_static_value_shape("boolean")
    elseif expression isa ActionUndefExpr
        return _semantic_static_value_shape("null")
    elseif expression isa ActionArrayLiteralExpr
        return _semantic_static_array_shape(_semantic_static_common_shape(
            [_semantic_static_expression_shape(item) for item in expression.items],
        ))
    elseif expression isa ActionHashLiteralExpr
        return _semantic_static_harray_shape(
            _semantic_static_common_shape([
                _semantic_static_expression_shape(entry.key) for entry in expression.entries
            ]),
            _semantic_static_common_shape([
                _semantic_static_expression_shape(entry.value) for entry in expression.entries
            ]),
        )
    elseif expression isa ActionCallExpr && expression.name == "return"
        return isempty(expression.args) ?
               _semantic_static_value_shape("unknown") :
               _semantic_static_expression_shape(getfield(first(expression.args), :value))
    end
    return _semantic_static_value_shape("unknown")
end

function _semantic_static_common_shape(shapes::Vector{Dict{String,Any}})
    isempty(shapes) && return _semantic_static_value_shape("unknown")
    first_shape = first(shapes)
    return all(shape -> shape == first_shape, shapes) ?
           first_shape : _semantic_static_value_shape("unknown")
end

function _semantic_static_value_shape(kind::String)
    return Dict{String,Any}(
        "kind" => kind,
        "element" => nothing,
        "key" => nothing,
        "value" => nothing,
        "signature" => nothing,
        "members" => Any[],
    )
end

function _semantic_static_array_shape(element::Dict{String,Any})
    shape = _semantic_static_value_shape("array")
    shape["element"] = element
    return shape
end

function _semantic_static_harray_shape(
    key::Dict{String,Any},
    value::Dict{String,Any},
)
    shape = _semantic_static_value_shape("harray")
    shape["key"] = key
    shape["value"] = value
    return shape
end

_semantic_static_neutral_repetition(mode::RuleMode) =
    !(mode.name in ("Default", "And", "Single", "Pipe"))

function _semantic_static_neutral_bounds(mode::RuleMode)
    return _semantic_static_neutral_repetition(mode) ?
           (rep_min(mode), rep_max(mode)) : (nothing, nothing)
end

function _semantic_static_edge_ownership(edges::Tuple)
    action = any(edge -> edge.ownership == "action", edges)
    blind = any(edge -> edge.ownership == "blind", edges)
    action && blind && return "mixed"
    action && return "action"
    blind && return "blind"
    return "none"
end

function _semantic_static_register_source!(
    source_refs::Dict{String,Any},
    record_id::String,
    range::_SemanticStaticSourceRange,
    source_text::String,
    source_map::_SemanticSourceMap,
    logical_name::String,
    content_digest::String,
)
    key = "source_ref:$record_id"
    source_refs[key] = Dict{String,Any}(
        "source_id" => _SEMANTIC_SOURCE_ID,
        "logical_name" => logical_name,
        "span" => to_json(_span_for_byte_range(source_map, range.start, range.stop)),
        "excerpt" => _semantic_static_source_slice(source_text, range),
        "content_digest" => content_digest,
        "provenance_ids" => Any[],
    )
    return key
end

function _semantic_static_source_record()
    return _semantic_static_record(
        id = _SEMANTIC_SOURCE_ID,
        kind = "source",
        name = nothing,
        owner_id = _SEMANTIC_SPEC_ID,
        order = 0,
        source = nothing,
        facts = Dict{String,Any}(
            "logical_kind" => "spec",
            "origin_kind" => "authored",
        ),
    )
end

function _semantic_static_record(;
    id,
    kind,
    name,
    owner_id,
    order,
    source,
    facts,
)
    return Dict{String,Any}(
        "id" => id,
        "kind" => kind,
        "name" => name,
        "owner_id" => owner_id,
        "order" => order,
        "source" => source,
        "facts" => facts,
        "redactions" => Any[],
    )
end

function _semantic_static_relation(;
    kind,
    from_id,
    to_id,
    order,
    source,
    evidence_ids = Any[],
)
    return Dict{String,Any}(
        "id" => "relation:$kind:$from_id:$to_id:$order",
        "kind" => kind,
        "from_id" => from_id,
        "to_id" => to_id,
        "order" => order,
        "source" => source,
        "facts" => Dict{String,Any}(),
        "evidence_ids" => evidence_ids,
    )
end

function _semantic_static_canonicalize!(
    records::Vector{Dict{String,Any}},
    relations::Vector{Dict{String,Any}},
)
    sort!(records; by = record -> (
        _semantic_static_kind_rank(_SEMANTIC_STATIC_RECORD_KINDS, record["kind"]),
        record["order"],
        record["id"],
    ))
    record_rank = Dict(record["id"] => index for (index, record) in enumerate(records))
    sort!(relations; by = relation -> (
        get(record_rank, relation["from_id"], typemax(Int)),
        _semantic_static_kind_rank(_SEMANTIC_STATIC_RELATION_KINDS, relation["kind"]),
        get(record_rank, relation["to_id"], typemax(Int)),
        relation["id"],
    ))
    return nothing
end

function _semantic_static_kind_rank(kinds::Tuple, kind::String)
    rank = findfirst(==(kind), kinds)
    return rank === nothing ? typemax(Int) : rank
end

_semantic_static_rule_id(label::String) = "rule:$(_semantic_static_escape_name(label))"

function _semantic_static_escape_name(name::String)
    output = IOBuffer()
    for byte in codeunits(name)
        safe = (0x41 <= byte <= 0x5a) ||
               (0x61 <= byte <= 0x7a) ||
               (0x30 <= byte <= 0x39) ||
               byte in (0x2e, 0x5f, 0x7e, 0x2d)
        if safe
            write(output, byte)
        else
            print(output, '%', uppercase(string(byte; base = 16, pad = 2)))
        end
    end
    return String(take!(output))
end

function _semantic_static_spec_name(logical_name::String)
    return endswith(logical_name, ".spec") ? chop(logical_name; tail = 5) : logical_name
end

function _semantic_static_entry_basis(basis::String)
    basis == "first_authored_marker" && return "first_marker"
    basis == "first_authored_rule" && return "first_rule"
    basis == "explicit_selector" && return "explicit_selector"
    return "first_rule"
end

function _semantic_static_correlation_error(
    message::String,
    identity::String;
    fields = Dict{String,Any}(),
)
    merged = Dict{String,Any}("identity" => identity)
    merge!(merged, fields)
    return SemanticIndexError(
        stage = "project_static_semantics",
        code = "semantic_static_correlation_failed",
        message = message,
        fields = merged,
    )
end

function _semantic_static_projection(
    snapshot::SemanticSnapshot,
    source_refs::AbstractDict,
    records::AbstractVector,
    relations::AbstractVector,
)
    return _SemanticStaticProjection(
        snapshot,
        _semantic_static_freeze(source_refs),
        _semantic_static_freeze(records),
        _semantic_static_freeze(relations),
    )
end

function _semantic_static_freeze(value::AbstractDict)
    values = Pair{String,Any}[
        String(key) => _semantic_static_freeze(item) for (key, item) in value
    ]
    sort!(values; by = first)
    return _SemanticStaticObject(Tuple(values))
end

function _semantic_static_freeze(value::Union{AbstractVector,Tuple})
    return _SemanticStaticArray(Tuple(_semantic_static_freeze(item) for item in value))
end

_semantic_static_freeze(value::AbstractString) = String(value)
_semantic_static_freeze(value::Union{Nothing,Bool,Integer,AbstractFloat}) = value

function _semantic_static_freeze(value)
    throw(_semantic_static_correlation_error(
        "Static projection contains a non-plain host value",
        string(typeof(value)),
    ))
end

function _semantic_static_thaw(value::_SemanticStaticObject)
    return Dict{String,Any}(
        key => _semantic_static_thaw(item) for (key, item) in value.values
    )
end

function _semantic_static_thaw(value::_SemanticStaticArray)
    return Any[_semantic_static_thaw(item) for item in value.values]
end

_semantic_static_thaw(value::AbstractString) = String(value)
_semantic_static_thaw(value) = value

"""Private exact-oracle seam; deliberately omitted from the exported/public API."""
function _semantic_static_projection_for_testing(index::SemanticIndex)
    projection = getfield(index, :_static_projection)
    if !(projection isa _SemanticStaticProjection)
        throw(AssertionError("SemanticIndex static projection has an invalid internal type"))
    end
    return Dict{String,Any}(
        "snapshot" => to_json(projection.snapshot),
        "source_refs" => _semantic_static_thaw(projection.source_refs),
        "records" => _semantic_static_thaw(projection.records),
        "relations" => _semantic_static_thaw(projection.relations),
    )
end
