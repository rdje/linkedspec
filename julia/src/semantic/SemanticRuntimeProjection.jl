# FUTURE-PARITY-BACKLOG.10.6.6.2 — immutable observed runtime projection.

const _SEMANTIC_EXECUTION_ID = "execution:0"

"""Validate one caller-retained observation and derive a fresh execution snapshot."""
function with_execution_observation(index::SemanticIndex, observation)
    if !(observation isa AbstractVector)
        throw(_invalid_semantic_observation(
            "Execution observation must be a vector of typed events",
        ))
    end
    events = RuntimeSemanticObservationEvent[]
    for event in observation
        if !(event isa RuntimeSemanticObservationEvent)
            throw(_invalid_semantic_observation(
                "Execution observation contains a non-event value",
            ))
        end
        push!(events, event)
    end
    projection = _build_semantic_runtime_projection(
        getfield(index, :_static_projection),
        events,
    )
    return SemanticIndex(
        _SEMANTIC_INDEX_CONSTRUCTION_TOKEN,
        getfield(index, :_source_text),
        getfield(index, :_source_map),
        getfield(index, :_logical_name),
        getfield(index, :_source_detail_ceiling),
        getfield(index, :_content_digest),
        getfield(index, :_entry_rule),
        getfield(index, :_compilation_outcome),
        projection,
    )
end

function _build_semantic_runtime_projection(
    static_projection::_SemanticStaticProjection,
    observation::Vector{RuntimeSemanticObservationEvent},
)
    isempty(observation) && throw(_invalid_semantic_observation(
        "Execution observation must contain at least one event",
    ))
    snapshot = static_projection.snapshot
    if snapshot.state != SemanticCompiledSnapshotState || snapshot.has_execution
        throw(_invalid_semantic_observation(
            "Execution observations require a compiled static semantic snapshot",
        ))
    end
    for event in observation
        _validate_semantic_observation_event(event)
    end

    result_events = [
        event for event in observation if
        event.event_kind == RuntimeSemanticRuleResult
    ]
    if length(result_events) != 1 ||
            last(observation).event_kind != RuntimeSemanticRuleResult
        throw(_invalid_semantic_observation(
            "Completed execution observation must contain exactly one final rule result",
        ))
    end
    result_event = only(result_events)
    if result_event.status != "succeeded"
        throw(_invalid_semantic_observation(
            "Final rule-result observation must report succeeded status",
        ))
    end
    input_identity = result_event.input_identity
    if input_identity === nothing || !_is_semantic_input_identity(input_identity)
        throw(_invalid_semantic_observation(
            "Final rule-result observation must carry a stable input identity",
        ))
    end

    source_refs = _semantic_static_thaw(static_projection.source_refs)
    records = Dict{String,Any}[
        record for record in _semantic_static_thaw(static_projection.records)
    ]
    relations = Dict{String,Any}[
        relation for relation in _semantic_static_thaw(static_projection.relations)
    ]
    record_by_id = Dict{String,Dict{String,Any}}(
        record["id"] => record for record in records
    )
    rule_by_name = Dict{String,Dict{String,Any}}(
        record["name"] => record for record in records if
        record["kind"] == "rule" && record["name"] isa String
    )
    slot_by_key = Dict{Tuple{String,Int},Dict{String,Any}}()
    for record in records
        record["kind"] == "regex_slot" || continue
        owner_id = record["owner_id"]
        owner = owner_id isa String ? get(record_by_id, owner_id, nothing) : nothing
        owner_name = owner === nothing ? nothing : owner["name"]
        order = record["order"]
        if owner_name isa String && order isa Int
            slot_by_key[(owner_name, order)] = record
        end
    end
    edge_for_selection = Dict{Tuple{String,String},Dict{String,Any}}()
    for selection in relations
        selection["kind"] == "selects_regex" || continue
        from_id = selection["from_id"]
        to_id = selection["to_id"]
        if !(from_id isa String && to_id isa String)
            continue
        end
        edge = get(record_by_id, from_id, nothing)
        if edge === nothing || edge["kind"] != "edge"
            continue
        end
        owner_id = edge["owner_id"]
        if owner_id isa String
            get!(edge_for_selection, (owner_id, to_id), edge)
        end
    end

    result_rule = get(rule_by_name, result_event.rule_label, nothing)
    if result_rule === nothing
        throw(_invalid_semantic_observation(
            string(
                "Observed result rule '",
                result_event.rule_label,
                "' does not exist in the semantic index",
            ),
        ))
    end
    spec = get(record_by_id, _SEMANTIC_SPEC_ID, nothing)
    spec === nothing && throw(_invalid_semantic_observation(
        "Static semantic projection has no spec record",
    ))
    spec_facts = spec["facts"]
    if spec_facts["entry_rule_id"] != result_rule["id"]
        throw(_invalid_semantic_observation(
            "Observed final result does not belong to the selected entry rule",
        ))
    end
    result_shape = _required_semantic_observation_shape(
        result_rule,
        "Final result rule has no value shape",
    )

    push!(records, _semantic_static_record(
        id = _SEMANTIC_EXECUTION_ID,
        kind = "execution",
        name = "caller observation",
        owner_id = _SEMANTIC_SPEC_ID,
        order = 0,
        source = nothing,
        facts = Dict{String,Any}(
            "input_identity" => input_identity,
            "status" => "succeeded",
            "result_shape" => result_shape,
        ),
    ))

    for (offset, event) in enumerate(observation)
        order = offset - 1
        name::String = ""
        source::Union{Nothing,String} = nothing
        value_shape::Dict{String,Any} = Dict{String,Any}()
        evidence_id::String = ""
        if event.event_kind == RuntimeSemanticRegexSlotSelected
            rule = get(rule_by_name, event.rule_label, nothing)
            rule === nothing && throw(_invalid_semantic_observation(
                string(
                    "Observed selecting rule '",
                    event.rule_label,
                    "' does not exist in the semantic index",
                ),
            ))
            target_rule = event.target_rule::String
            regex_index = event.regex_index::Int
            slot = get(slot_by_key, (target_rule, regex_index), nothing)
            slot === nothing && throw(_invalid_semantic_observation(
                string(
                    "Observed regex slot '",
                    target_rule,
                    "[",
                    regex_index,
                    "]' does not exist in the semantic index",
                ),
            ))
            edge = get(
                edge_for_selection,
                (rule["id"]::String, slot["id"]::String),
                nothing,
            )
            edge === nothing && throw(_invalid_semantic_observation(
                string(
                    "Observed selecting rule '",
                    event.rule_label,
                    "' does not select regex slot '",
                    target_rule,
                    "[",
                    regex_index,
                    "]'",
                ),
            ))
            name = "slot selected"
            source = slot["source"]
            value_shape = _required_semantic_observation_shape(
                edge,
                "Observed selection edge has no value shape",
            )
            evidence_id = slot["id"]
        else
            if offset != length(observation)
                throw(_invalid_semantic_observation(
                    "Rule-result event must be the final observation event",
                ))
            end
            name = "rule result"
            source = result_rule["source"]
            value_shape = result_shape
            evidence_id = result_rule["id"]
        end
        event_id = "event:$_SEMANTIC_EXECUTION_ID:$order"
        push!(records, _semantic_static_record(
            id = event_id,
            kind = "event",
            name = name,
            owner_id = _SEMANTIC_EXECUTION_ID,
            order = order,
            source = source,
            facts = Dict{String,Any}(
                "event_kind" => runtime_semantic_observation_event_kind_name(
                    event.event_kind,
                ),
                "position" => event.position,
                "value_shape" => value_shape,
            ),
        ))
        push!(relations, _semantic_static_relation(
            kind = "observed_as",
            from_id = _SEMANTIC_EXECUTION_ID,
            to_id = event_id,
            order = order,
            source = source,
            evidence_ids = Any[evidence_id],
        ))
    end

    _semantic_static_canonicalize!(records, relations)
    return _semantic_static_projection(
        SemanticSnapshot(
            snapshot.id,
            snapshot.state,
            true,
            snapshot.source_detail_ceiling,
            snapshot.content_digest_available,
        ),
        source_refs,
        records,
        relations,
    )
end

function _validate_semantic_observation_event(
    event::RuntimeSemanticObservationEvent,
)
    if event.contract_id != RUNTIME_SEMANTIC_OBSERVATION_CONTRACT
        throw(_invalid_semantic_observation(
            "Execution observation event contract is unsupported",
        ))
    end
    if isempty(event.rule_label) || !isvalid(event.rule_label)
        throw(_invalid_semantic_observation(
            "Execution observation rule label is missing",
        ))
    end
    event.position < 0 && throw(_invalid_semantic_observation(
        "Execution observation position must be nonnegative",
    ))
    if event.event_kind == RuntimeSemanticRegexSlotSelected
        target_rule = event.target_rule
        if target_rule === nothing || isempty(target_rule) || !isvalid(target_rule)
            throw(_invalid_semantic_observation(
                "Regex-slot observation target rule is missing",
            ))
        end
        event.regex_index === nothing && throw(_invalid_semantic_observation(
            "Regex-slot observation index is missing",
        ))
        event.regex_index < 0 && throw(_invalid_semantic_observation(
            "Regex-slot observation index must be nonnegative",
        ))
        if event.input_identity !== nothing || event.status !== nothing
            throw(_invalid_semantic_observation(
                "Regex-slot observation cannot carry result identity or status",
            ))
        end
    elseif event.target_rule !== nothing || event.regex_index !== nothing
        throw(_invalid_semantic_observation(
            "Rule-result observation cannot carry regex-slot identity",
        ))
    end
    return nothing
end

function _required_semantic_observation_shape(record, message::String)
    facts = record["facts"]
    shape = get(facts, "value_shape", nothing)
    if !(shape isa Dict{String,Any})
        throw(_invalid_semantic_observation(message))
    end
    return shape
end

function _is_semantic_input_identity(value::String)
    prefix = "input:sha256:"
    startswith(value, prefix) || return false
    bytes = codeunits(value)
    length(bytes) == ncodeunits(prefix) + 64 || return false
    return all(
        byte -> (UInt8('0') <= byte <= UInt8('9')) ||
                (UInt8('a') <= byte <= UInt8('f')),
        bytes[(ncodeunits(prefix) + 1):end],
    )
end

_invalid_semantic_observation(message::String) = SemanticIndexError(
    stage = "execution_observation",
    code = "semantic_index_invalid_observation",
    message = message,
)
