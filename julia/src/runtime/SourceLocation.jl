module SourceLocation

const _VALIDATE_VALUE_PHASE = "validate_value"
const _SOURCE_MISMATCH_CODE = "source_location_source_mismatch"
const _POSITION_OUT_OF_RANGE_CODE = "source_location_position_out_of_range"
const _REVERSED_SPAN_CODE = "source_location_reversed_span"
const _INVALID_DERIVED_PROVENANCE_CODE =
    "source_location_invalid_derived_provenance"
const _NEXT_AUTHORITY_ID = Base.Threads.Atomic{UInt64}(0)

"""Rule and invocation roles attached to private source-location diagnostics."""
struct SourceLocationContext
    rule_role::String
    invocation_role::String

    function SourceLocationContext(
        ::Val{:internal},
        rule_role::String,
        invocation_role::String,
    )
        return new(rule_role, invocation_role)
    end
end

function SourceLocationContext(;
    rule_role::AbstractString,
    invocation_role::AbstractString,
)
    return SourceLocationContext(
        Val(:internal),
        String(rule_role),
        String(invocation_role),
    )
end

"""Materialization policies for explicitly derived text."""
@enum DerivedTextPolicy begin
    ConcatenateInOrder
end

"""Immutable source identity plus a zero-based Unicode-scalar offset."""
struct Position
    _authority_id::UInt64
    _source_id::String
    _offset::Int

    function Position(
        ::Val{:internal},
        authority_id::UInt64,
        source_id::String,
        offset::Int,
    )
        return new(authority_id, source_id, offset)
    end
end

"""Immutable same-source half-open interval plus explicit provenance."""
struct Span
    _authority_id::UInt64
    _source_id::String
    _start::Int
    _stop::Int
    _provenance::String

    function Span(
        ::Val{:internal},
        authority_id::UInt64,
        source_id::String,
        start::Int,
        stop::Int,
        provenance::String,
    )
        return new(authority_id, source_id, start, stop, provenance)
    end
end

"""Immutable ordered direct-span provenance for explicitly derived text."""
struct DerivedText
    _authority_id::UInt64
    _policy::DerivedTextPolicy
    _spans::Tuple{Vararg{Span}}

    function DerivedText(
        ::Val{:internal},
        authority_id::UInt64,
        policy::DerivedTextPolicy,
        spans::Tuple{Vararg{Span}},
    )
        return new(authority_id, policy, spans)
    end
end

"""Detached line, column, and UTF-8 byte evidence for one position."""
struct SourceCoordinates
    _source_id::String
    _offset::Int
    _line::Int
    _column::Int
    _utf8_byte_offset::Int

    function SourceCoordinates(
        ::Val{:internal},
        source_id::String,
        offset::Int,
        line::Int,
        column::Int,
        utf8_byte_offset::Int,
    )
        return new(source_id, offset, line, column, utf8_byte_offset)
    end
end

"""One of the four private immutable-value contract failures."""
struct SourceLocationException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}

    function SourceLocationException(
        ::Val{:internal},
        record::Tuple{Vararg{Pair{String,Any}}},
    )
        return new(record)
    end
end

Base.showerror(io::IO, error::SourceLocationException) =
    print(io, first(error._record).second)

struct _DecodedSource
    source_id::String
    text::String
    codeunit_at_scalar::Tuple{Vararg{Int}}
    line_at_scalar::Tuple{Vararg{Int}}
    column_at_scalar::Tuple{Vararg{Int}}
    utf8_byte_at_scalar::Tuple{Vararg{Int}}
end

"""Authority that owns immutable decoded-source snapshots and validates values."""
struct SourceAuthority
    _authority_id::UInt64
    _sources::Tuple{Vararg{_DecodedSource}}

    function SourceAuthority(
        ::Val{:internal},
        authority_id::UInt64,
        sources::Tuple{Vararg{_DecodedSource}},
    )
        return new(authority_id, sources)
    end
end

function SourceAuthority(;
    sources::AbstractDict{<:AbstractString,<:AbstractString},
)
    owned_sources = _DecodedSource[
        _decoded_source(source_id, decoded_text)
        for (source_id, decoded_text) in pairs(sources)
    ]
    sort!(owned_sources; by = source -> source.source_id)
    return SourceAuthority(
        Val(:internal),
        _claim_authority_id(),
        Tuple(owned_sources),
    )
end

function _claim_authority_id()
    while true
        previous = _NEXT_AUTHORITY_ID[]
        previous == typemax(UInt64) && error("source authority identity space exhausted")
        next_id = previous + UInt64(1)
        Base.Threads.atomic_cas!(_NEXT_AUTHORITY_ID, previous, next_id) == previous &&
            return next_id
    end
end

function _decoded_source(source_id::AbstractString, decoded_text::AbstractString)
    owned_text = String(Vector{UInt8}(codeunits(String(decoded_text))))
    codeunit_at_scalar = Int[0]
    line_at_scalar = Int[1]
    column_at_scalar = Int[1]
    utf8_byte_at_scalar = Int[0]
    codeunit_offset = 0
    utf8_byte_offset = 0
    line = 1
    column = 1

    for scalar in owned_text
        width = ncodeunits(string(scalar))
        codeunit_offset += width
        utf8_byte_offset += width
        if scalar == '\n'
            line += 1
            column = 1
        else
            column += 1
        end
        push!(codeunit_at_scalar, codeunit_offset)
        push!(line_at_scalar, line)
        push!(column_at_scalar, column)
        push!(utf8_byte_at_scalar, utf8_byte_offset)
    end

    return _DecodedSource(
        String(source_id),
        owned_text,
        Tuple(codeunit_at_scalar),
        Tuple(line_at_scalar),
        Tuple(column_at_scalar),
        Tuple(utf8_byte_at_scalar),
    )
end

function _source(authority::SourceAuthority, source_id::AbstractString)
    source_id_string = String(source_id)
    for source in authority._sources
        source.source_id == source_id_string && return source
    end
    return nothing
end

_scalar_length(source::_DecodedSource) = length(source.codeunit_at_scalar) - 1

function _boundary_index(source::_DecodedSource, offset::Int)
    0 <= offset <= _scalar_length(source) || return nothing
    return offset + 1
end

function _throw_value_error(
    code::AbstractString,
    context::SourceLocationContext,
    fields::Pair...,
)
    record = Pair{String,Any}[
        "code" => String(code),
        "phase" => _VALIDATE_VALUE_PHASE,
        "rule_role" => context.rule_role,
        "invocation_role" => context.invocation_role,
    ]
    for field in fields
        push!(record, String(field.first) => field.second)
    end
    throw(SourceLocationException(Val(:internal), Tuple(record)))
end

"""Construct and validate one Unicode-scalar-offset position."""
function position(
    authority::SourceAuthority;
    source_id::AbstractString,
    offset::Int,
    context::SourceLocationContext,
)
    source_id_string = String(source_id)
    source = _source(authority, source_id_string)
    if source === nothing || _boundary_index(source, offset) === nothing
        _throw_value_error(
            _POSITION_OUT_OF_RANGE_CODE,
            context,
            "source_id" => source_id_string,
            "position_offset" => offset,
            "source_length" => (source === nothing ? 0 : _scalar_length(source)),
        )
    end
    return Position(
        Val(:internal),
        authority._authority_id,
        source_id_string,
        offset,
    )
end

"""Construct and validate one direct half-open span."""
function direct_span(
    authority::SourceAuthority;
    start::Position,
    stop::Position,
    provenance::AbstractString,
    context::SourceLocationContext,
)
    if start._source_id != stop._source_id ||
            start._authority_id != stop._authority_id ||
            start._authority_id != authority._authority_id
        _throw_value_error(
            _SOURCE_MISMATCH_CODE,
            context,
            "source_id" => start._source_id,
            "other_source_id" => stop._source_id,
        )
    end
    if start._offset > stop._offset
        _throw_value_error(
            _REVERSED_SPAN_CODE,
            context,
            "source_id" => start._source_id,
            "start_offset" => start._offset,
            "end_offset" => stop._offset,
        )
    end
    provenance_string = String(provenance)
    isempty(provenance_string) && throw(ArgumentError("span provenance must not be empty"))
    return Span(
        Val(:internal),
        authority._authority_id,
        start._source_id,
        start._offset,
        stop._offset,
        provenance_string,
    )
end

"""Construct and validate explicitly ordered derived text."""
function derived_text(
    authority::SourceAuthority;
    policy::DerivedTextPolicy,
    spans::AbstractVector,
    context::SourceLocationContext,
)
    policy == ConcatenateInOrder || throw(ArgumentError("unsupported derived-text policy"))
    owned_spans = Span[]
    for (one_based_index, value) in enumerate(spans)
        value isa Span || throw(ArgumentError("derived-text spans must contain only Span values"))
        if value._authority_id != authority._authority_id ||
                _source(authority, value._source_id) === nothing
            _throw_value_error(
                _INVALID_DERIVED_PROVENANCE_CODE,
                context,
                "provenance_index" => one_based_index - 1,
                "source_id" => value._source_id,
            )
        end
        push!(owned_spans, value)
    end
    return DerivedText(
        Val(:internal),
        authority._authority_id,
        policy,
        Tuple(owned_spans),
    )
end

"""Derive one-based line/column and UTF-8 byte evidence for a position."""
function coordinates(
    authority::SourceAuthority,
    value::Position;
    context::SourceLocationContext,
)
    source = _source(authority, value._source_id)
    index = source === nothing ? nothing : _boundary_index(source, value._offset)
    if value._authority_id != authority._authority_id || index === nothing
        _throw_value_error(
            _POSITION_OUT_OF_RANGE_CODE,
            context,
            "source_id" => value._source_id,
            "position_offset" => value._offset,
            "source_length" => (source === nothing ? 0 : _scalar_length(source)),
        )
    end
    return SourceCoordinates(
        Val(:internal),
        value._source_id,
        value._offset,
        source.line_at_scalar[index],
        source.column_at_scalar[index],
        source.utf8_byte_at_scalar[index],
    )
end

function _invalid_provenance(
    context::SourceLocationContext,
    provenance_index::Int,
    source_id::AbstractString,
)
    _throw_value_error(
        _INVALID_DERIVED_PROVENANCE_CODE,
        context,
        "provenance_index" => provenance_index,
        "source_id" => String(source_id),
    )
end

function _materialize_span(
    authority::SourceAuthority,
    value::Span,
    context::SourceLocationContext,
    provenance_index::Int,
)
    source = _source(authority, value._source_id)
    start_index = source === nothing ? nothing : _boundary_index(source, value._start)
    stop_index = source === nothing ? nothing : _boundary_index(source, value._stop)
    if value._authority_id != authority._authority_id ||
            source === nothing ||
            start_index === nothing ||
            stop_index === nothing ||
            value._start > value._stop
        _invalid_provenance(context, provenance_index, value._source_id)
    end
    value._start == value._stop && return ""
    first_codeunit = source.codeunit_at_scalar[start_index] + 1
    after_last_codeunit = source.codeunit_at_scalar[stop_index] + 1
    last_codeunit = prevind(source.text, after_last_codeunit)
    return String(SubString(source.text, first_codeunit, last_codeunit))
end

"""Materialize one direct span or explicitly derived text value."""
function materialize(
    authority::SourceAuthority,
    value::Span;
    context::SourceLocationContext,
)
    return _materialize_span(authority, value, context, 0)
end

function materialize(
    authority::SourceAuthority,
    value::DerivedText;
    context::SourceLocationContext,
)
    if value._authority_id != authority._authority_id
        source_id = isempty(value._spans) ? "" : first(value._spans)._source_id
        _invalid_provenance(context, 0, source_id)
    end
    return join(
        _materialize_span(authority, span, context, index - 1)
        for (index, span) in enumerate(value._spans)
    )
end

"""Return a fresh detached neutral record for a typed source value."""
function to_json(value::Position)
    return Dict{String,Any}(
        "source_id" => value._source_id,
        "offset" => value._offset,
    )
end

function to_json(value::Span)
    return Dict{String,Any}(
        "source_id" => value._source_id,
        "start" => value._start,
        "end" => value._stop,
        "provenance" => value._provenance,
    )
end

function to_json(value::DerivedText)
    return Dict{String,Any}(
        "policy" => "concatenate_in_order",
        "spans" => Any[to_json(span) for span in value._spans],
    )
end

function to_json(value::SourceCoordinates)
    return Dict{String,Any}(
        "source_id" => value._source_id,
        "offset" => value._offset,
        "line" => value._line,
        "column" => value._column,
        "utf8_byte_offset" => value._utf8_byte_offset,
    )
end

function to_json(error::SourceLocationException)
    return Dict{String,Any}(field.first => field.second for field in error._record)
end

end
