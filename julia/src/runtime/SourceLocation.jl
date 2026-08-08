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

function _scalar_offset_at_codeunit(source::_DecodedSource, codeunit_offset::Int)
    low = 1
    high = length(source.codeunit_at_scalar)
    while low <= high
        middle = low + ((high - low) ÷ 2)
        candidate = source.codeunit_at_scalar[middle]
        if candidate == codeunit_offset
            return middle - 1
        elseif candidate < codeunit_offset
            low = middle + 1
        else
            high = middle - 1
        end
    end
    return nothing
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

"""Construct a position from an exact zero-based Julia UTF-8 code-unit boundary."""
function position_from_codeunit(
    authority::SourceAuthority;
    source_id::AbstractString,
    codeunit_offset::Int,
    context::SourceLocationContext,
)
    source_id_string = String(source_id)
    source = _source(authority, source_id_string)
    scalar_offset = source === nothing ? nothing :
        _scalar_offset_at_codeunit(source, codeunit_offset)
    if scalar_offset === nothing
        _throw_value_error(
            _POSITION_OUT_OF_RANGE_CODE,
            context,
            "source_id" => source_id_string,
            "position_offset" => codeunit_offset,
            "source_length" => (source === nothing ? 0 : _scalar_length(source)),
        )
    end
    return Position(
        Val(:internal),
        authority._authority_id,
        source_id_string,
        scalar_offset,
    )
end

"""Return the Unicode-scalar length of one authority-owned source."""
function source_scalar_length(authority::SourceAuthority, source_id::AbstractString)
    source = _source(authority, source_id)
    return source === nothing ? nothing : _scalar_length(source)
end

position_offset(value::Position) = value._offset
span_start_offset(value::Span) = value._start
span_scalar_length(value::Span) = value._stop - value._start
coordinate_line(value::SourceCoordinates) = value._line
coordinate_column(value::SourceCoordinates) = value._column

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

const _PROJECTION_ROWS = (
    capture_mark = (
        ("capture_between", "span_text"),
        ("capture_from", "span_text"),
        ("capture_len_between", "span_length"),
        ("capture_len_from", "span_length"),
        ("capture_rest", "span_text"),
        ("capture_rest_from", "span_text"),
        ("capture_rest_len", "span_length"),
        ("capture_rest_len_from", "span_length"),
        ("capture_slice", "span_text"),
        ("capture_slice_col", "span_start_column"),
        ("capture_slice_len", "span_length"),
        ("capture_slice_line", "span_start_line"),
        ("capture_slice_pos", "span_start_offset"),
        ("capture_slice_until_cursor", "span_text"),
        ("capture_slice_until_cursor_len", "span_length"),
        ("capture_until_boundary", "span_text"),
        ("capture_take", "span_text"),
        ("capture_take_between", "span_text"),
        ("capture_take_between_len", "span_length"),
        ("capture_take_len", "span_length"),
        ("capture_take_len_from", "span_length"),
        ("capture_take_rest", "span_text"),
        ("capture_take_rest_from", "span_text"),
        ("capture_take_rest_len", "span_length"),
        ("capture_take_rest_len_from", "span_length"),
        ("capture_take_until_cursor", "span_text"),
        ("capture_take_until_cursor_from", "span_text"),
        ("capture_take_until_cursor_len", "span_length"),
        ("capture_take_until_cursor_len_from", "span_length"),
        ("capture_until_cursor_from", "span_text"),
        ("capture_until_cursor_len_from", "span_length"),
        ("mark_capture_slice", "capture_boundary_write_position"),
        ("mark_copy", "mark_write_position"),
        ("mark_exists", "mark_exists"),
        ("mark_here", "mark_write_position"),
        ("mark_input_end", "mark_write_position"),
        ("mark_input_start", "mark_write_position"),
        ("mark_pos", "mark_read_offset"),
        ("start_capture_slice", "capture_boundary_write_position"),
        ("start_capture_slice_from", "capture_boundary_write_position"),
        ("clear_mark", "mark_delete"),
        ("mark_col", "mark_read_column"),
        ("mark_entry_end", "mark_write_position"),
        ("mark_entry_start", "mark_write_position"),
        ("mark_line", "mark_read_line"),
        ("mark_match_end", "mark_write_position"),
        ("mark_match_start", "mark_write_position"),
    ),
    entry_match = (
        ("entry_col", "span_start_column"),
        ("entry_end_col", "position_column"),
        ("entry_end_line", "position_line"),
        ("entry_end_pos", "position_offset"),
        ("entry_group", "capture_group_text"),
        ("entry_groups", "capture_group_list"),
        ("entry_has", "capture_group_exists"),
        ("entry_len", "span_length"),
        ("entry_line", "span_start_line"),
        ("entry_map", "capture_group_map"),
        ("entry_named", "capture_group_text"),
        ("entry_start_col", "span_start_column"),
        ("entry_start_line", "span_start_line"),
        ("entry_start_pos", "span_start_offset"),
        ("entry_text", "span_text"),
        ("match_col", "span_start_column"),
        ("match_end_col", "position_column"),
        ("match_end_line", "position_line"),
        ("match_end_pos", "position_offset"),
        ("match_group", "capture_group_text"),
        ("match_groups", "capture_group_list"),
        ("match_has", "capture_group_exists"),
        ("match_len", "span_length"),
        ("match_line", "span_start_line"),
        ("match_map", "capture_group_map"),
        ("match_named", "capture_group_text"),
        ("match_start_col", "span_start_column"),
        ("match_start_line", "span_start_line"),
        ("match_start_pos", "span_start_offset"),
        ("match_text", "span_text"),
    ),
    input_cursor = (
        ("cursor_col", "position_column"),
        ("cursor_line", "position_line"),
        ("cursor_pos", "cursor_position"),
        ("cursor_rest", "span_text"),
        ("cursor_rest_len", "span_length"),
        ("input_end_col", "position_column"),
        ("input_end_line", "position_line"),
        ("input_end_pos", "position_offset"),
        ("input_len", "source_length"),
        ("input_slice", "source_slice_text"),
        ("input_text", "source_text"),
    ),
    cursor_control = (
        ("restore_cursor", "cursor_state_write_compatibility"),
        ("rewind_entry_start", "cursor_state_write_compatibility"),
        ("rewind_match_start", "cursor_state_write_compatibility"),
        ("save_cursor", "cursor_checkpoint_compatibility"),
    ),
)

const _COMPATIBILITY_ALIASES = (
    ("capture_from_rule_start", "capture_slice"),
    ("capture_len_from_rule_start", "capture_slice_len"),
    ("capture_rest_length", "capture_rest_len"),
    ("capture_slice_here", "start_capture_slice"),
    ("capture_slice_length", "capture_slice_len"),
    ("entry_named_map", "entry_map"),
    ("match_named_map", "match_map"),
)

"""Return a fresh detached copy of all source-boundary projection rows."""
function projection_rows()
    return Dict{String,Any}(
        String(family) => Any[Any[row...] for row in rows]
        for (family, rows) in pairs(_PROJECTION_ROWS)
    )
end

"""Return a fresh detached copy of all compatibility alias rows."""
compatibility_aliases() = Any[Any[row...] for row in _COMPATIBILITY_ALIASES]

end
