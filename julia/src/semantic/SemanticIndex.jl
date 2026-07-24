const _SEMANTIC_SOURCE_ID = "source:0"

"""Maximum caller-selected source detail that one semantic index may disclose."""
@enum SemanticSourceDetail begin
    SemanticSourceNoneDetail = 0
    SemanticSourceIdentityDetail = 1
    SemanticSourceSpanDetail = 2
    SemanticSourceTextDetail = 3
end

const _SEMANTIC_SOURCE_DETAIL_NAMES = Dict(
    SemanticSourceNoneDetail => "none",
    SemanticSourceIdentityDetail => "identity",
    SemanticSourceSpanDetail => "span",
    SemanticSourceTextDetail => "text",
)

"""Stable constructor or source-map failure before semantic projection."""
struct SemanticIndexError <: Exception
    stage::String
    code::String
    message::String
    fields::Tuple

    function SemanticIndexError(; stage, code, message, fields = ())
        return new(
            String(stage),
            String(code),
            String(message),
            _semantic_error_fields(fields),
        )
    end
end

Base.showerror(io::IO, error::SemanticIndexError) =
    print(io, error.code, " at ", error.stage, ": ", error.message)

"""Required caller-owned policy for one opaque semantic index."""
struct SemanticIndexOptions
    logical_name::String
    source_detail_ceiling::SemanticSourceDetail
    entry_rule::Union{Nothing,String}

    function SemanticIndexOptions(logical_name, source_detail_ceiling; entry_rule = nothing)
        if !(logical_name isa AbstractString)
            throw(_semantic_invalid_option(
                "Semantic index logical name must be text",
                "logical_name",
            ))
        end
        if !(source_detail_ceiling isa SemanticSourceDetail)
            throw(_semantic_invalid_option(
                "Semantic index source detail ceiling must be none, identity, span, or text",
                "source_detail_ceiling",
            ))
        end
        if !(entry_rule === nothing || entry_rule isa AbstractString)
            throw(_semantic_invalid_option(
                "Semantic index entry rule must be text when present",
                "entry_rule",
            ))
        end
        return new(
            String(logical_name),
            source_detail_ceiling,
            entry_rule === nothing ? nothing : String(entry_rule),
        )
    end
end

SemanticIndexOptions(; logical_name, source_detail_ceiling, entry_rule = nothing) =
    SemanticIndexOptions(logical_name, source_detail_ceiling; entry_rule = entry_rule)

"""Caller-registered source identity with no implicit filesystem path."""
struct SemanticSourceIdentity
    source_id::String
    logical_name::String
    byte_length::Int
    scalar_length::Int
    content_digest::Union{Nothing,String}
end

Base.:(==)(left::SemanticSourceIdentity, right::SemanticSourceIdentity) =
    left.source_id == right.source_id &&
    left.logical_name == right.logical_name &&
    left.byte_length == right.byte_length &&
    left.scalar_length == right.scalar_length &&
    left.content_digest == right.content_digest

Base.hash(identity::SemanticSourceIdentity, seed::UInt) = hash(
    (
        identity.source_id,
        identity.logical_name,
        identity.byte_length,
        identity.scalar_length,
        identity.content_digest,
    ),
    seed,
)

"""Exact zero-based byte and one-based line/Unicode-scalar-column span."""
struct SemanticSourceSpan
    start_byte::Int
    end_byte::Int
    start_line::Int
    start_column::Int
    end_line::Int
    end_column::Int
end

Base.:(==)(left::SemanticSourceSpan, right::SemanticSourceSpan) =
    left.start_byte == right.start_byte &&
    left.end_byte == right.end_byte &&
    left.start_line == right.start_line &&
    left.start_column == right.start_column &&
    left.end_line == right.end_line &&
    left.end_column == right.end_column

Base.hash(span::SemanticSourceSpan, seed::UInt) = hash(
    (
        span.start_byte,
        span.end_byte,
        span.start_line,
        span.start_column,
        span.end_line,
        span.end_column,
    ),
    seed,
)

struct _SemanticSourceMap
    byte_at_scalar::Tuple
    line_at_scalar::Tuple
    column_at_scalar::Tuple
end

struct _SemanticIndexConstructionToken end

const _SEMANTIC_INDEX_CONSTRUCTION_TOKEN = _SemanticIndexConstructionToken()

abstract type _AbstractSemanticCompilationOutcome end
abstract type _AbstractSemanticStaticProjection end

"""Opaque copied semantic source and compilation authority. Use exported accessors."""
struct SemanticIndex
    _source_text::String
    _source_map::_SemanticSourceMap
    _logical_name::String
    _source_detail_ceiling::SemanticSourceDetail
    _content_digest::String
    _entry_rule::Union{Nothing,String}
    _compilation_outcome::_AbstractSemanticCompilationOutcome
    _static_projection::_AbstractSemanticStaticProjection

    function SemanticIndex(
        ::_SemanticIndexConstructionToken,
        source_text,
        source_map,
        logical_name,
        source_detail_ceiling,
        content_digest,
        entry_rule,
        compilation_outcome,
        static_projection,
    )
        return new(
            source_text,
            source_map,
            logical_name,
            source_detail_ceiling,
            content_digest,
            entry_rule,
            compilation_outcome,
            static_projection,
        )
    end
end

function Base.show(io::IO, index::SemanticIndex)
    ceiling = _semantic_source_detail_name(getfield(index, :_source_detail_ceiling))
    snapshot = semantic_snapshot(index)
    state = _semantic_snapshot_state_name(snapshot.state)
    print(
        io,
        "SemanticIndex(source_id=\"",
        _SEMANTIC_SOURCE_ID,
        "\", snapshot_state=\"",
        state,
        "\", source_detail_ceiling=\"",
        ceiling,
        "\", has_execution=",
        snapshot.has_execution,
        ")",
    )
end

Base.propertynames(::SemanticIndex, private::Bool = false) =
    private ? fieldnames(SemanticIndex) : ()

function Base.getproperty(::SemanticIndex, name::Symbol)
    throw(ArgumentError(
        "SemanticIndex is opaque; use the exported semantic accessors",
    ))
end

"""Construct one compiled-or-failed index from copied valid text."""
function semantic_index(source::AbstractString, options::SemanticIndexOptions)
    validated_options = _validate_semantic_index_options(options)
    source_text, source_bytes = _copy_semantic_text(source)
    return _build_semantic_index(source_text, source_bytes, validated_options)
end

"""Construct one compiled-or-failed index from copied strict UTF-8 bytes."""
function semantic_index(source::AbstractVector{UInt8}, options::SemanticIndexOptions)
    validated_options = _validate_semantic_index_options(options)
    source_text, source_bytes = _copy_semantic_utf8(source)
    return _build_semantic_index(source_text, source_bytes, validated_options)
end

"""Keyword convenience for `semantic_index(source, SemanticIndexOptions(...))`."""
function semantic_index(
    source;
    logical_name,
    source_detail_ceiling,
    entry_rule = nothing,
)
    options = SemanticIndexOptions(
        logical_name,
        source_detail_ceiling;
        entry_rule = entry_rule,
    )
    return semantic_index(source, options)
end

"""Return copied caller identity and exact source sizes without a host path."""
function source_identity(index::SemanticIndex)
    _require_semantic_source_detail(index, SemanticSourceIdentityDetail)
    source_map = getfield(index, :_source_map)
    ceiling = getfield(index, :_source_detail_ceiling)
    return SemanticSourceIdentity(
        _SEMANTIC_SOURCE_ID,
        String(getfield(index, :_logical_name)),
        last(source_map.byte_at_scalar),
        length(source_map.byte_at_scalar) - 1,
        ceiling == SemanticSourceTextDetail ?
            String(getfield(index, :_content_digest)) : nothing,
    )
end

"""Map one exact strict-UTF-8 byte range."""
function source_span_for_bytes(index::SemanticIndex, start_byte, end_byte)
    _require_semantic_source_detail(index, SemanticSourceSpanDetail)
    start = _semantic_source_integer(start_byte, "start_byte")
    stop = _semantic_source_integer(end_byte, "end_byte")
    return _span_for_byte_range(getfield(index, :_source_map), start, stop)
end

"""Map one exact Unicode-scalar range."""
function source_span_for_scalars(index::SemanticIndex, start_scalar, end_scalar)
    _require_semantic_source_detail(index, SemanticSourceSpanDetail)
    start = _semantic_source_integer(start_scalar, "start_scalar")
    stop = _semantic_source_integer(end_scalar, "end_scalar")
    return _span_for_scalar_range(getfield(index, :_source_map), start, stop)
end

"""Return exact decoded source text for one strict byte range."""
function source_excerpt_for_bytes(index::SemanticIndex, start_byte, end_byte)
    _require_semantic_source_detail(index, SemanticSourceTextDetail)
    start = _semantic_source_integer(start_byte, "start_byte")
    stop = _semantic_source_integer(end_byte, "end_byte")
    _span_for_byte_range(getfield(index, :_source_map), start, stop)
    source_bytes = codeunits(getfield(index, :_source_text))
    return String(Vector{UInt8}(source_bytes[(start + 1):stop]))
end

"""Locate one exact decoded occurrence at or after an exact byte boundary."""
function locate_exact(index::SemanticIndex, needle::AbstractString; after_byte = 0)
    _require_semantic_source_detail(index, SemanticSourceSpanDetail)
    after = _semantic_source_integer(after_byte, "after_byte")
    source_map = getfield(index, :_source_map)
    _span_for_byte_range(source_map, after, after)
    needle_text, needle_bytes = _copy_semantic_needle(needle)
    isempty(needle_bytes) && throw(SemanticIndexError(
        stage = "map_source",
        code = "semantic_source_needle_invalid",
        message = "Source lookup needle must not be empty",
    ))
    start = _find_semantic_bytes(
        codeunits(getfield(index, :_source_text)),
        needle_bytes,
        after,
    )
    start === nothing && return nothing
    return _span_for_byte_range(source_map, start, start + ncodeunits(needle_text))
end

function locate_exact(index::SemanticIndex, needle; after_byte = 0)
    throw(SemanticIndexError(
        stage = "map_source",
        code = "semantic_source_needle_invalid",
        message = "Source lookup needle must be valid Unicode scalar text",
    ))
end

function to_json(error::SemanticIndexError)
    return Dict{String,Any}(
        "stage" => error.stage,
        "code" => error.code,
        "message" => error.message,
        "fields" => Dict{String,Any}(
            key => _semantic_json_value(value) for (key, value) in error.fields
        ),
    )
end

function to_json(identity::SemanticSourceIdentity)
    return Dict{String,Any}(
        "source_id" => identity.source_id,
        "logical_name" => identity.logical_name,
        "byte_length" => identity.byte_length,
        "scalar_length" => identity.scalar_length,
        "content_digest" => identity.content_digest,
    )
end

function to_json(span::SemanticSourceSpan)
    return Dict{String,Any}(
        "start_byte" => span.start_byte,
        "end_byte" => span.end_byte,
        "start_line" => span.start_line,
        "start_column" => span.start_column,
        "end_line" => span.end_line,
        "end_column" => span.end_column,
    )
end

function _build_semantic_index(source_text, source_bytes, options)
    compilation_outcome = _build_semantic_compilation_outcome(source_text, options)
    source_map = _SemanticSourceMap(source_text)
    content_digest = "sha256:$(bytes2hex(SHA.sha256(source_bytes)))"
    snapshot = _semantic_snapshot(
        compilation_outcome,
        options.source_detail_ceiling,
    )
    static_projection = _build_semantic_static_projection(
        source_text,
        source_map,
        String(options.logical_name),
        content_digest,
        snapshot,
        compilation_outcome,
    )
    return SemanticIndex(
        _SEMANTIC_INDEX_CONSTRUCTION_TOKEN,
        source_text,
        source_map,
        String(options.logical_name),
        options.source_detail_ceiling,
        content_digest,
        options.entry_rule === nothing ? nothing : String(options.entry_rule),
        compilation_outcome,
        static_projection,
    )
end

function _SemanticSourceMap(source::String)
    byte_at_scalar = Int[0]
    line_at_scalar = Int[1]
    column_at_scalar = Int[1]
    byte_offset = 0
    line = 1
    column = 1
    for character in source
        byte_offset += ncodeunits(character)
        if character == '\n'
            line += 1
            column = 1
        else
            column += 1
        end
        push!(byte_at_scalar, byte_offset)
        push!(line_at_scalar, line)
        push!(column_at_scalar, column)
    end
    return _SemanticSourceMap(
        Tuple(byte_at_scalar),
        Tuple(line_at_scalar),
        Tuple(column_at_scalar),
    )
end

function _span_for_scalar_range(source_map::_SemanticSourceMap, start::Int, stop::Int)
    scalar_length = length(source_map.byte_at_scalar) - 1
    if start < 0 || start > stop || stop > scalar_length
        throw(SemanticIndexError(
            stage = "map_source",
            code = "semantic_source_range_invalid",
            message = "Source scalar range is outside the captured source",
            fields = ("start_scalar" => start, "end_scalar" => stop),
        ))
    end
    return _semantic_source_span(source_map, start, stop)
end

function _span_for_byte_range(source_map::_SemanticSourceMap, start::Int, stop::Int)
    byte_length = last(source_map.byte_at_scalar)
    if start < 0 || start > stop || stop > byte_length
        throw(SemanticIndexError(
            stage = "map_source",
            code = "semantic_source_range_invalid",
            message = "Source byte range is outside the captured source",
            fields = ("start_byte" => start, "end_byte" => stop),
        ))
    end
    start_scalar = _semantic_boundary_index(source_map.byte_at_scalar, start)
    if start_scalar === nothing
        throw(SemanticIndexError(
            stage = "map_source",
            code = "semantic_source_boundary_invalid",
            message = "Source byte range starts inside a UTF-8 scalar",
            fields = ("start_byte" => start,),
        ))
    end
    stop_scalar = _semantic_boundary_index(source_map.byte_at_scalar, stop)
    if stop_scalar === nothing
        throw(SemanticIndexError(
            stage = "map_source",
            code = "semantic_source_boundary_invalid",
            message = "Source byte range ends inside a UTF-8 scalar",
            fields = ("end_byte" => stop,),
        ))
    end
    return _semantic_source_span(source_map, start_scalar, stop_scalar)
end

function _semantic_source_span(source_map, start_scalar, stop_scalar)
    return SemanticSourceSpan(
        source_map.byte_at_scalar[start_scalar + 1],
        source_map.byte_at_scalar[stop_scalar + 1],
        source_map.line_at_scalar[start_scalar + 1],
        source_map.column_at_scalar[start_scalar + 1],
        source_map.line_at_scalar[stop_scalar + 1],
        source_map.column_at_scalar[stop_scalar + 1],
    )
end

function _semantic_boundary_index(boundaries::Tuple, value::Int)
    low = 1
    high = length(boundaries)
    while low <= high
        middle = (low + high) >>> 1
        boundary = boundaries[middle]
        if boundary < value
            low = middle + 1
        elseif boundary > value
            high = middle - 1
        else
            return middle - 1
        end
    end
    return nothing
end

function _copy_semantic_text(source::AbstractString)
    if !isvalid(source)
        throw(SemanticIndexError(
            stage = "decode_source",
            code = "semantic_index_invalid_unicode",
            message = "Semantic index source is not valid Unicode scalar text",
        ))
    end
    source_bytes = Vector{UInt8}(codeunits(source))
    return String(copy(source_bytes)), source_bytes
end

function _copy_semantic_utf8(source::AbstractVector{UInt8})
    source_bytes = Vector{UInt8}(source)
    source_text = String(copy(source_bytes))
    if !isvalid(source_text)
        throw(SemanticIndexError(
            stage = "decode_source",
            code = "semantic_index_invalid_utf8",
            message = "Semantic index source is not valid UTF-8",
        ))
    end
    return source_text, source_bytes
end

function _copy_semantic_needle(needle::AbstractString)
    if !isvalid(needle)
        throw(SemanticIndexError(
            stage = "map_source",
            code = "semantic_source_needle_invalid",
            message = "Source lookup needle must be valid Unicode scalar text",
        ))
    end
    needle_bytes = Vector{UInt8}(codeunits(needle))
    return String(copy(needle_bytes)), needle_bytes
end

function _validate_semantic_index_options(options::SemanticIndexOptions)
    logical_name = options.logical_name
    if !isvalid(logical_name)
        throw(_semantic_invalid_option(
            "Semantic index logical name must be valid Unicode scalar text",
            "logical_name",
        ))
    end
    if isempty(logical_name) || any(iscntrl, logical_name)
        throw(_semantic_invalid_option(
            "Semantic index logical name must be nonempty and contain no control characters",
            "logical_name",
        ))
    end
    entry_rule = options.entry_rule
    if entry_rule !== nothing
        if !isvalid(entry_rule) || !is_rule_label(entry_rule)
            throw(_semantic_invalid_option(
                "Semantic index entry rule must be a valid rule label",
                "entry_rule",
            ))
        end
    end
    copied_logical_name = String(Vector{UInt8}(codeunits(logical_name)))
    copied_entry_rule = entry_rule === nothing ?
                        nothing : String(Vector{UInt8}(codeunits(entry_rule)))
    return SemanticIndexOptions(
        copied_logical_name,
        options.source_detail_ceiling;
        entry_rule = copied_entry_rule,
    )
end

function _semantic_invalid_option(message, option)
    return SemanticIndexError(
        stage = "validate_options",
        code = "semantic_index_invalid_option",
        message = message,
        fields = ("option" => option,),
    )
end

function _require_semantic_source_detail(index::SemanticIndex, required)
    ceiling = getfield(index, :_source_detail_ceiling)
    if Int(ceiling) < Int(required)
        throw(SemanticIndexError(
            stage = "apply_source_ceiling",
            code = "semantic_source_detail_forbidden",
            message = "Requested source detail exceeds the semantic index ceiling",
            fields = (
                "ceiling" => _semantic_source_detail_name(ceiling),
                "required" => _semantic_source_detail_name(required),
            ),
        ))
    end
    return nothing
end

_semantic_source_detail_name(detail::SemanticSourceDetail) =
    _SEMANTIC_SOURCE_DETAIL_NAMES[detail]

function _semantic_source_integer(value, field_name)
    if value isa Bool || !(value isa Integer)
        throw(SemanticIndexError(
            stage = "map_source",
            code = "semantic_source_range_invalid",
            message = "Source range coordinates must be integers and not Boolean",
            fields = ("coordinate" => field_name,),
        ))
    end
    try
        return Int(value)
    catch error
        if error isa InexactError || error isa OverflowError
            throw(SemanticIndexError(
                stage = "map_source",
                code = "semantic_source_range_invalid",
                message = "Source range coordinate is outside the supported integer range",
                fields = ("coordinate" => field_name,),
            ))
        end
        rethrow()
    end
end

function _find_semantic_bytes(source, needle::Vector{UInt8}, after::Int)
    final_start = length(source) - length(needle)
    after > final_start && return nothing
    for start in after:final_start
        matches = true
        for offset in eachindex(needle)
            if source[start + offset] != needle[offset]
                matches = false
                break
            end
        end
        matches && return start
    end
    return nothing
end

function _semantic_error_fields(fields)
    normalized = Pair{String,Any}[]
    for field in fields
        if !(field isa Pair)
            throw(ArgumentError("SemanticIndexError fields must be key/value pairs"))
        end
        push!(
            normalized,
            Pair{String,Any}(String(first(field)), _semantic_detached_value(last(field))),
        )
    end
    sort!(normalized; by = first)
    return Tuple(normalized)
end

function _semantic_detached_value(value)
    if value isa AbstractString
        return String(value)
    elseif value isa AbstractDict
        pairs = Pair{String,Any}[
            Pair{String,Any}(String(key), _semantic_detached_value(item)) for
            (key, item) in value
        ]
        sort!(pairs; by = first)
        return Tuple(pairs)
    elseif value isa AbstractVector || value isa Tuple
        return Tuple(_semantic_detached_value(item) for item in value)
    end
    return value
end

function _semantic_json_value(value)
    if value isa Tuple
        if all(item -> item isa Pair{String,Any}, value)
            return Dict{String,Any}(
                key => _semantic_json_value(item) for (key, item) in value
            )
        end
        return Any[_semantic_json_value(item) for item in value]
    end
    return value
end
