"""Versioned identity carried by every runtime semantic observation event."""
const RUNTIME_SEMANTIC_OBSERVATION_CONTRACT =
    "linkedspec-semantic-execution-observation-v1"

"""Closed event vocabulary captured during one normal runtime invocation."""
@enum RuntimeSemanticObservationEventKind begin
    RuntimeSemanticRegexSlotSelected
    RuntimeSemanticRuleResult
end

"""Return the stable wire name for one runtime semantic event kind."""
function runtime_semantic_observation_event_kind_name(
    kind::RuntimeSemanticObservationEventKind,
)
    if kind == RuntimeSemanticRegexSlotSelected
        return "regex_slot_selected"
    end
    return "rule_result"
end

"""
One immutable typed fact delivered during normal parser execution.

The public keyword constructor copies scalar fields but deliberately does not
validate their cross-field topology. A later semantic-index derivation owns
that validation, so callers can retain and transport events without exposing
runtime context or compiled host objects.
"""
struct RuntimeSemanticObservationEvent
    contract_id::String
    event_kind::RuntimeSemanticObservationEventKind
    rule_label::String
    target_rule::Union{Nothing,String}
    regex_index::Union{Nothing,Int}
    position::Int
    input_identity::Union{Nothing,String}
    status::Union{Nothing,String}

    function RuntimeSemanticObservationEvent(;
        contract_id = RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
        event_kind,
        rule_label,
        target_rule = nothing,
        regex_index = nothing,
        position,
        input_identity = nothing,
        status = nothing,
    )
        return new(
            String(contract_id),
            event_kind,
            String(rule_label),
            target_rule === nothing ? nothing : String(target_rule),
            regex_index === nothing ? nothing : Int(regex_index),
            Int(position),
            input_identity === nothing ? nothing : String(input_identity),
            status === nothing ? nothing : String(status),
        )
    end
end

Base.:(==)(left::RuntimeSemanticObservationEvent, right::RuntimeSemanticObservationEvent) =
    left.contract_id == right.contract_id &&
    left.event_kind == right.event_kind &&
    left.rule_label == right.rule_label &&
    left.target_rule == right.target_rule &&
    left.regex_index == right.regex_index &&
    left.position == right.position &&
    left.input_identity == right.input_identity &&
    left.status == right.status

Base.hash(event::RuntimeSemanticObservationEvent, seed::UInt) = hash(
    (
        event.contract_id,
        event.event_kind,
        event.rule_label,
        event.target_rule,
        event.regex_index,
        event.position,
        event.input_identity,
        event.status,
    ),
    seed,
)

function to_json(event::RuntimeSemanticObservationEvent)
    return Dict{String,Any}(
        "contract_id" => event.contract_id,
        "event_kind" => runtime_semantic_observation_event_kind_name(event.event_kind),
        "rule_label" => event.rule_label,
        "target_rule" => event.target_rule,
        "regex_index" => event.regex_index,
        "position" => event.position,
        "input_identity" => event.input_identity,
        "status" => event.status,
    )
end

"""Optional caller-owned synchronous sink installed for one invocation."""
const RuntimeSemanticObservationSink = Function

function _runtime_semantic_regex_slot_selected_event(
    rule_label::AbstractString,
    target_rule::AbstractString,
    regex_index::Int,
    position::Int,
)
    return RuntimeSemanticObservationEvent(
        event_kind = RuntimeSemanticRegexSlotSelected,
        rule_label = rule_label,
        target_rule = target_rule,
        regex_index = regex_index,
        position = position,
    )
end

function _runtime_semantic_rule_result_event(
    rule_label::AbstractString,
    position::Int,
    input::AbstractString,
)
    input_identity = "input:sha256:$(bytes2hex(SHA.sha256(codeunits(input))))"
    return RuntimeSemanticObservationEvent(
        event_kind = RuntimeSemanticRuleResult,
        rule_label = rule_label,
        position = position,
        input_identity = input_identity,
        status = "succeeded",
    )
end
