"""
Private inert staged parse-job declarations and typed provenance.

This unit owns no parser registry, cache, scheduler, callback, source path, or
stitching behavior. Live match boundaries are converted through the existing
typed source authority before a detached marker is returned.
"""

const _STAGED_PARSE_JOB_ERROR_PREFIX =
    "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:"
const _STAGED_PROVENANCE_CODE = "staged_source_provenance_invalid"
const _STAGED_SOURCE_ID = "input"

struct StagedParseJobDeclarationException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}
end

function _staged_parse_job_provenance_exception(;
    origin::AbstractString,
    source_id::AbstractString,
    provenance::AbstractString,
)
    return StagedParseJobDeclarationException((
        "code" => _STAGED_PROVENANCE_CODE,
        "phase" => "declare",
        "origin" => String(origin),
        "source_id" => String(source_id),
        "provenance" => String(provenance),
    ))
end

function Base.showerror(io::IO, error::StagedParseJobDeclarationException)
    code = first(error._record).second
    print(io, _STAGED_PARSE_JOB_ERROR_PREFIX, code)
end

to_json(error::StagedParseJobDeclarationException) =
    Dict{String,Any}(error._record)

function _staged_parse_job_fail_provenance(;
    origin::AbstractString,
    source_id::AbstractString,
    provenance::AbstractString,
)
    throw(_staged_parse_job_provenance_exception(
        origin = origin,
        source_id = source_id,
        provenance = provenance,
    ))
end

function _staged_has_exact_keys(record::AbstractDict, expected::Tuple)
    return length(record) == length(expected) &&
        all(key -> haskey(record, key), expected)
end

function _staged_source_context(origin::AbstractString)
    return SourceLocation.SourceLocationContext(
        rule_role = origin,
        invocation_role = "staged_parse_job_declaration",
    )
end

function _staged_typed_direct_span(
    authority::SourceLocation.SourceAuthority,
    record,
    origin::AbstractString,
)
    object = record isa AbstractDict ? record : Dict{String,Any}()
    source_id = get(object, "source_id", nothing)
    source_id = source_id isa AbstractString ? String(source_id) : "<runtime>"
    provenance = get(object, "provenance", nothing)
    provenance = provenance isa AbstractString ? String(provenance) : "<invalid>"
    expected = ("kind", "source_id", "start", "end", "provenance")
    if !_staged_has_exact_keys(object, expected) ||
            get(object, "kind", nothing) != "direct_span" ||
            isempty(provenance) ||
            !(get(object, "start", nothing) isa Int) ||
            !(get(object, "end", nothing) isa Int)
        _staged_parse_job_fail_provenance(
            origin = origin,
            source_id = source_id,
            provenance = provenance,
        )
    end

    try
        context = _staged_source_context(origin)
        start = SourceLocation.position(
            authority;
            source_id = source_id,
            offset = object["start"],
            context = context,
        )
        stop = SourceLocation.position(
            authority;
            source_id = source_id,
            offset = object["end"],
            context = context,
        )
        span = SourceLocation.direct_span(
            authority;
            start = start,
            stop = stop,
            provenance = provenance,
            context = context,
        )
        detached = SourceLocation.to_json(span)
        detached["kind"] = "direct_span"
        return (
            span = span,
            detached = detached,
            source_id = source_id,
            provenance = provenance,
        )
    catch error
        if error isa SourceLocation.SourceLocationException || error isa ArgumentError
            _staged_parse_job_fail_provenance(
                origin = origin,
                source_id = source_id,
                provenance = provenance,
            )
        end
        rethrow()
    end
end

"""Validate and materialize one detached direct or ordered-derived record."""
function validate_and_materialize_staged_provenance(;
    authority::SourceLocation.SourceAuthority,
    record,
    origin::AbstractString,
)
    if record isa AbstractDict && get(record, "kind", nothing) == "direct_span"
        typed = _staged_typed_direct_span(authority, record, origin)
        try
            return Dict{String,Any}(
                "text" => SourceLocation.materialize(
                    authority,
                    typed.span;
                    context = _staged_source_context(origin),
                ),
                "provenance" => typed.detached,
            )
        catch error
            if error isa SourceLocation.SourceLocationException
                _staged_parse_job_fail_provenance(
                    origin = origin,
                    source_id = typed.source_id,
                    provenance = typed.provenance,
                )
            end
            rethrow()
        end
    end

    expected = ("kind", "policy", "segments")
    if !(record isa AbstractDict) ||
            !_staged_has_exact_keys(record, expected) ||
            get(record, "kind", nothing) != "derived_text" ||
            get(record, "policy", nothing) != "concatenate_in_order" ||
            !(get(record, "segments", nothing) isa AbstractVector) ||
            isempty(record["segments"])
        _staged_parse_job_fail_provenance(
            origin = origin,
            source_id = "<derived>",
            provenance = "derived_text",
        )
    end

    spans = SourceLocation.Span[]
    detached_segments = Dict{String,Any}[]
    for segment in record["segments"]
        typed = _staged_typed_direct_span(authority, segment, origin)
        push!(spans, typed.span)
        push!(detached_segments, typed.detached)
    end
    try
        context = _staged_source_context(origin)
        derived = SourceLocation.derived_text(
            authority;
            policy = SourceLocation.ConcatenateInOrder,
            spans = spans,
            context = context,
        )
        return Dict{String,Any}(
            "text" => SourceLocation.materialize(
                authority,
                derived;
                context = context,
            ),
            "provenance" => Dict{String,Any}(
                "kind" => "derived_text",
                "policy" => "concatenate_in_order",
                "segments" => Any[segment for segment in detached_segments],
            ),
        )
    catch error
        if error isa SourceLocation.SourceLocationException || error isa ArgumentError
            _staged_parse_job_fail_provenance(
                origin = origin,
                source_id = "<derived>",
                provenance = "derived_text",
            )
        end
        rethrow()
    end
end

function _staged_runtime_direct_record(;
    authority::SourceLocation.SourceAuthority,
    registers::RuntimeMatchRegisters,
    origin::AbstractString,
    source::AbstractString,
    index::Union{Nothing,Int},
)
    source_name = String(source)
    one_match = if source_name in ("entry_text", "entry_group")
        registers.entry_match
    elseif source_name in ("match_text", "match_group")
        registers.local_match
    else
        nothing
    end
    range = if one_match === nothing
        nothing
    elseif source_name in ("entry_text", "match_text") && index === nothing
        (one_match.codeunit_start, one_match.codeunit_end)
    elseif source_name in ("entry_group", "match_group") && index !== nothing
        staged_capture_codeunit_span(one_match, index)
    else
        nothing
    end
    range === nothing && _staged_parse_job_fail_provenance(
        origin = origin,
        source_id = _STAGED_SOURCE_ID,
        provenance = source_name,
    )

    try
        context = _staged_source_context(origin)
        start = SourceLocation.position_from_codeunit(
            authority;
            source_id = _STAGED_SOURCE_ID,
            codeunit_offset = range[1],
            context = context,
        )
        stop = SourceLocation.position_from_codeunit(
            authority;
            source_id = _STAGED_SOURCE_ID,
            codeunit_offset = range[2],
            context = context,
        )
        span = SourceLocation.direct_span(
            authority;
            start = start,
            stop = stop,
            provenance = source_name,
            context = context,
        )
        detached = SourceLocation.to_json(span)
        detached["kind"] = "direct_span"
        return detached
    catch error
        if error isa SourceLocation.SourceLocationException || error isa ArgumentError
            _staged_parse_job_fail_provenance(
                origin = origin,
                source_id = _STAGED_SOURCE_ID,
                provenance = source_name,
            )
        end
        rethrow()
    end
end

"""Construct one detached inert marker from live typed match provenance."""
function construct_staged_parse_job_marker(;
    authority::SourceLocation.SourceAuthority,
    registers::RuntimeMatchRegisters,
    origin::AbstractString,
    text_plan::ActionStagedParseJobTextPlan,
    options::ActionStagedParseJobOptions,
)
    provenance = if text_plan isa ActionStagedParseJobDirectSpanPlan
        _staged_runtime_direct_record(
            authority = authority,
            registers = registers,
            origin = origin,
            source = text_plan.source,
            index = text_plan.index,
        )
    else
        Dict{String,Any}(
            "kind" => "derived_text",
            "policy" => "concatenate_in_order",
            "segments" => Any[
                _staged_runtime_direct_record(
                    authority = authority,
                    registers = registers,
                    origin = origin,
                    source = segment.source,
                    index = segment.index,
                ) for segment in text_plan.segments
            ],
        )
    end
    materialized = validate_and_materialize_staged_provenance(
        authority = authority,
        record = provenance,
        origin = origin,
    )
    sidecar = Dict{String,Any}(
        "kind" => "staged_parse_job_v2",
        "version" => 2,
        "state" => "declared",
        "effect" => "staged_parse_job_declaration",
        "node_kind" => options.node_kind,
        "payload_kind" => options.payload_kind,
        "parser_spec_id" => options.spec,
        "result_policy" => options.result_policy,
        "failure_policy" => options.on_error,
        "required_capabilities" => Any[options.required_capabilities...],
        "text" => materialized["text"],
        "provenance" => materialized["provenance"],
        "origin" => String(origin),
    )
    _put_if_present!(sidecar, "top_rule", options.top)
    _put_if_present!(sidecar, "into", options.into)
    return Dict{String,Any}(
        "kind" => "STAGED_PARSE_JOB_MARKER",
        "version" => 2,
        "sidecar_kind" => "staged_parse_job_v2",
        "effect" => "staged_parse_job_declaration",
        "staged_parse_job_v2" => sidecar,
    )
end
