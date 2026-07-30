# Strict synchronous stdio transport for the native Julia MCP server.

const _MCP_WIRE_UTF8_BOM = UInt8[0xef, 0xbb, 0xbf]
const _MCP_WIRE_IO_LOG_RECORD = UInt8[codeunits("linkedspec_mcp_io_failure\n")...]
const _MCP_WIRE_SAFE_INTEGER_ID = "9007199254740991"
const _MCP_WIRE_READ_BYTES = 65_536

@enum _McpWireRejection::UInt8 begin
    _McpWireParse
    _McpWireInvalidRequest
end

@enum _McpWireTokenKind::UInt8 begin
    _McpWireStringToken
    _McpWireNumberTokenKind
    _McpWireOtherToken
end

@enum _McpWireContainerKind::UInt8 begin
    _McpWireObject
    _McpWireArray
end

@enum _McpWirePhase::UInt8 begin
    _McpWireObjectKeyOrEnd
    _McpWireObjectKey
    _McpWireObjectColon
    _McpWireObjectValue
    _McpWireObjectCommaOrEnd
    _McpWireArrayValueOrEnd
    _McpWireArrayValue
    _McpWireArrayCommaOrEnd
end

struct _McpWireFailure <: Exception
    rejection::_McpWireRejection
end

struct _McpWireIdToken
    kind::_McpWireTokenKind
    raw::String
end

struct _McpWireNumber
    raw::String
    fractional::Bool
end

mutable struct _McpWireContainer
    kind::_McpWireContainerKind
    root::Bool
    phase::_McpWirePhase
    keys::Union{Nothing,Set{String}}
    key::Union{Nothing,String}
end

_mcp_wire_object(root::Bool) = _McpWireContainer(
    _McpWireObject,
    root,
    _McpWireObjectKeyOrEnd,
    Set{String}(),
    nothing,
)

_mcp_wire_array() = _McpWireContainer(
    _McpWireArray,
    false,
    _McpWireArrayValueOrEnd,
    nothing,
    nothing,
)

mutable struct _McpWireScanner
    bytes::Vector{UInt8}
    maximum_depth::Int
    containers::Vector{_McpWireContainer}
    numbers::Vector{_McpWireNumber}
    offset::Int
    id_token::Union{Nothing,_McpWireIdToken}
end

_McpWireScanner(bytes::Vector{UInt8}, maximum_depth::Int) = _McpWireScanner(
    bytes,
    maximum_depth,
    _McpWireContainer[],
    _McpWireNumber[],
    1,
    nothing,
)

function _mcp_wire_scan!(scanner::_McpWireScanner)
    _mcp_wire_skip_whitespace!(scanner)
    _mcp_wire_parse_value!(scanner; root_container = true, capture_root_id = false)
    while !isempty(scanner.containers)
        container = last(scanner.containers)
        if container.phase == _McpWireObjectKeyOrEnd
            _mcp_wire_skip_whitespace!(scanner)
            if _mcp_wire_take!(scanner, UInt8('}'))
                pop!(scanner.containers)
            else
                container.phase = _McpWireObjectKey
            end
        elseif container.phase == _McpWireObjectKey
            _mcp_wire_skip_whitespace!(scanner)
            _mcp_wire_peek(scanner) == UInt8('"') || _mcp_wire_parse_failure()
            key = _mcp_wire_parse_string!(scanner)
            keys = container.keys
            keys === nothing && _mcp_wire_parse_failure()
            key in keys && _mcp_wire_parse_failure()
            push!(keys, key)
            container.key = key
            container.phase = _McpWireObjectColon
        elseif container.phase == _McpWireObjectColon
            _mcp_wire_skip_whitespace!(scanner)
            _mcp_wire_take!(scanner, UInt8(':')) || _mcp_wire_parse_failure()
            container.phase = _McpWireObjectValue
        elseif container.phase == _McpWireObjectValue
            _mcp_wire_skip_whitespace!(scanner)
            capture_id = container.root && container.key == "id"
            container.phase = _McpWireObjectCommaOrEnd
            _mcp_wire_parse_value!(
                scanner;
                root_container = false,
                capture_root_id = capture_id,
            )
        elseif container.phase == _McpWireObjectCommaOrEnd
            _mcp_wire_skip_whitespace!(scanner)
            if _mcp_wire_take!(scanner, UInt8('}'))
                pop!(scanner.containers)
            else
                _mcp_wire_take!(scanner, UInt8(',')) || _mcp_wire_parse_failure()
                container.phase = _McpWireObjectKey
            end
        elseif container.phase == _McpWireArrayValueOrEnd
            _mcp_wire_skip_whitespace!(scanner)
            if _mcp_wire_take!(scanner, UInt8(']'))
                pop!(scanner.containers)
            else
                container.phase = _McpWireArrayValue
            end
        elseif container.phase == _McpWireArrayValue
            _mcp_wire_skip_whitespace!(scanner)
            container.phase = _McpWireArrayCommaOrEnd
            _mcp_wire_parse_value!(
                scanner;
                root_container = false,
                capture_root_id = false,
            )
        else
            _mcp_wire_skip_whitespace!(scanner)
            if _mcp_wire_take!(scanner, UInt8(']'))
                pop!(scanner.containers)
            else
                _mcp_wire_take!(scanner, UInt8(',')) || _mcp_wire_parse_failure()
                container.phase = _McpWireArrayValue
            end
        end
    end
    _mcp_wire_skip_whitespace!(scanner)
    scanner.offset == length(scanner.bytes) + 1 || _mcp_wire_parse_failure()
    return nothing
end

function _mcp_wire_parse_value!(
    scanner::_McpWireScanner;
    root_container::Bool,
    capture_root_id::Bool,
)
    _mcp_wire_skip_whitespace!(scanner)
    token_kind = _mcp_wire_token_kind(scanner)
    byte = _mcp_wire_peek(scanner)
    start = scanner.offset
    if byte == UInt8('{')
        scanner.offset += 1
        _mcp_wire_push!(scanner, _mcp_wire_object(root_container))
        return nothing
    elseif byte == UInt8('[')
        scanner.offset += 1
        _mcp_wire_push!(scanner, _mcp_wire_array())
        return nothing
    elseif byte == UInt8('"')
        _mcp_wire_parse_string!(scanner)
    elseif byte == UInt8('t')
        _mcp_wire_parse_literal!(scanner, "true")
    elseif byte == UInt8('f')
        _mcp_wire_parse_literal!(scanner, "false")
    elseif byte == UInt8('n')
        _mcp_wire_parse_literal!(scanner, "null")
    elseif byte == UInt8('-') || _mcp_wire_is_digit(byte)
        fractional = _mcp_wire_parse_number!(scanner)
        raw = String(copy(scanner.bytes[start:(scanner.offset - 1)]))
        push!(scanner.numbers, _McpWireNumber(raw, fractional))
    else
        _mcp_wire_parse_failure()
    end
    if capture_root_id
        raw = token_kind == _McpWireNumberTokenKind ?
              String(copy(scanner.bytes[start:(scanner.offset - 1)])) : ""
        scanner.id_token = _McpWireIdToken(token_kind, raw)
    end
    return nothing
end

function _mcp_wire_push!(scanner::_McpWireScanner, container::_McpWireContainer)
    length(scanner.containers) < scanner.maximum_depth || _mcp_wire_parse_failure()
    push!(scanner.containers, container)
    return nothing
end

function _mcp_wire_parse_string!(scanner::_McpWireScanner)
    _mcp_wire_take!(scanner, UInt8('"')) || _mcp_wire_parse_failure()
    decoded = IOBuffer()
    while scanner.offset <= length(scanner.bytes)
        byte = scanner.bytes[scanner.offset]
        if byte == UInt8('"')
            scanner.offset += 1
            value = String(take!(decoded))
            isvalid(value) || _mcp_wire_parse_failure()
            return value
        elseif byte < 0x20
            _mcp_wire_parse_failure()
        elseif byte != UInt8('\\')
            write(decoded, byte)
            scanner.offset += 1
            continue
        end

        scanner.offset += 1
        escape = _mcp_wire_peek(scanner)
        escape === nothing && _mcp_wire_parse_failure()
        scanner.offset += 1
        if escape in (UInt8('"'), UInt8('/'), UInt8('\\'))
            write(decoded, escape)
        elseif escape == UInt8('b')
            write(decoded, UInt8(0x08))
        elseif escape == UInt8('f')
            write(decoded, UInt8(0x0c))
        elseif escape == UInt8('n')
            write(decoded, UInt8(0x0a))
        elseif escape == UInt8('r')
            write(decoded, UInt8(0x0d))
        elseif escape == UInt8('t')
            write(decoded, UInt8(0x09))
        elseif escape == UInt8('u')
            _mcp_wire_append_escaped_scalar!(scanner, decoded)
        else
            _mcp_wire_parse_failure()
        end
    end
    _mcp_wire_parse_failure()
end

function _mcp_wire_append_escaped_scalar!(scanner::_McpWireScanner, decoded::IO)
    high = _mcp_wire_take_hex_quad!(scanner)
    scalar = high
    if _mcp_wire_high_surrogate(high)
        _mcp_wire_take!(scanner, UInt8('\\')) || _mcp_wire_parse_failure()
        _mcp_wire_take!(scanner, UInt8('u')) || _mcp_wire_parse_failure()
        low = _mcp_wire_take_hex_quad!(scanner)
        _mcp_wire_low_surrogate(low) || _mcp_wire_parse_failure()
        scalar = 0x10000 + ((high - 0xd800) << 10) + (low - 0xdc00)
    elseif _mcp_wire_low_surrogate(high)
        _mcp_wire_parse_failure()
    end
    print(decoded, Char(scalar))
    return nothing
end

function _mcp_wire_take_hex_quad!(scanner::_McpWireScanner)
    scanner.offset + 3 <= length(scanner.bytes) || _mcp_wire_parse_failure()
    value = 0
    for index in scanner.offset:(scanner.offset + 3)
        digit = _mcp_wire_hex_value(scanner.bytes[index])
        digit >= 0 || _mcp_wire_parse_failure()
        value = value * 16 + digit
    end
    scanner.offset += 4
    return value
end

function _mcp_wire_parse_literal!(scanner::_McpWireScanner, literal::String)
    bytes = codeunits(literal)
    finish = scanner.offset + length(bytes) - 1
    finish <= length(scanner.bytes) || _mcp_wire_parse_failure()
    scanner.bytes[scanner.offset:finish] == bytes || _mcp_wire_parse_failure()
    scanner.offset = finish + 1
    return nothing
end

function _mcp_wire_parse_number!(scanner::_McpWireScanner)
    fractional = false
    if _mcp_wire_take!(scanner, UInt8('-'))
        _mcp_wire_peek(scanner) === nothing && _mcp_wire_parse_failure()
    end
    first = _mcp_wire_peek(scanner)
    if first == UInt8('0')
        scanner.offset += 1
    elseif first !== nothing && UInt8('1') <= first <= UInt8('9')
        scanner.offset += 1
        while _mcp_wire_is_digit(_mcp_wire_peek(scanner))
            scanner.offset += 1
        end
    else
        _mcp_wire_parse_failure()
    end
    if _mcp_wire_take!(scanner, UInt8('.'))
        fractional = true
        _mcp_wire_is_digit(_mcp_wire_peek(scanner)) || _mcp_wire_parse_failure()
        while _mcp_wire_is_digit(_mcp_wire_peek(scanner))
            scanner.offset += 1
        end
    end
    if _mcp_wire_peek(scanner) in (UInt8('e'), UInt8('E'))
        fractional = true
        scanner.offset += 1
        _mcp_wire_peek(scanner) in (UInt8('+'), UInt8('-')) && (scanner.offset += 1)
        _mcp_wire_is_digit(_mcp_wire_peek(scanner)) || _mcp_wire_parse_failure()
        while _mcp_wire_is_digit(_mcp_wire_peek(scanner))
            scanner.offset += 1
        end
    end
    return fractional
end

function _mcp_wire_skip_whitespace!(scanner::_McpWireScanner)
    while _mcp_wire_peek(scanner) in (UInt8(' '), UInt8('\t'), UInt8('\n'), UInt8('\r'))
        scanner.offset += 1
    end
    return nothing
end

function _mcp_wire_take!(scanner::_McpWireScanner, expected::UInt8)
    _mcp_wire_peek(scanner) == expected || return false
    scanner.offset += 1
    return true
end

_mcp_wire_peek(scanner::_McpWireScanner) =
    scanner.offset <= length(scanner.bytes) ? scanner.bytes[scanner.offset] : nothing

function _mcp_wire_token_kind(scanner::_McpWireScanner)
    byte = _mcp_wire_peek(scanner)
    byte == UInt8('"') && return _McpWireStringToken
    (byte == UInt8('-') || _mcp_wire_is_digit(byte)) && return _McpWireNumberTokenKind
    return _McpWireOtherToken
end

_mcp_wire_is_digit(value) = value !== nothing && UInt8('0') <= value <= UInt8('9')
_mcp_wire_high_surrogate(value::Int) = 0xd800 <= value <= 0xdbff
_mcp_wire_low_surrogate(value::Int) = 0xdc00 <= value <= 0xdfff

function _mcp_wire_hex_value(byte::UInt8)
    UInt8('0') <= byte <= UInt8('9') && return Int(byte - UInt8('0'))
    UInt8('A') <= byte <= UInt8('F') && return Int(byte - UInt8('A')) + 10
    UInt8('a') <= byte <= UInt8('f') && return Int(byte - UInt8('a')) + 10
    return -1
end

_mcp_wire_parse_failure() = throw(_McpWireFailure(_McpWireParse))

"""Serve modern MCP synchronously over caller-owned input, output, and optional log IO."""
function serve_mcp_stdio!(
    server::McpServer,
    input,
    output,
    authorization_context;
    log = nothing,
)
    getfield(server, :stopped) && throw(_mcp_server_shutdown())
    if !(input isa IO) || !(output isa IO) || !(log === nothing || log isa IO) ||
       output === log
        throw(McpServerError(
            "linkedspec_mcp_invalid_stdio",
            "MCP stdio requires caller-owned IO with a distinct optional log.",
        ))
    end
    authorization = _mcp_authorization_bytes(authorization_context)
    maximum_line_bytes, maximum_depth = _mcp_wire_request_limits()
    try
        _mcp_wire_stream_loop!(
            server,
            input,
            output,
            authorization,
            log,
            maximum_line_bytes,
            maximum_depth,
        )
    catch
        _mcp_wire_io_failure!(server, log)
    end
    return nothing
end

function _mcp_wire_stream_loop!(
    server::McpServer,
    input::IO,
    output::IO,
    authorization::Vector{UInt8},
    log,
    maximum_line_bytes::Int,
    maximum_depth::Int,
)
    buffer = UInt8[]
    sizehint!(buffer, min(maximum_line_bytes + 1, _MCP_WIRE_READ_BYTES))
    chunk = Vector{UInt8}(undef, _MCP_WIRE_READ_BYTES)
    remainder = Vector{UInt8}(undef, _MCP_WIRE_READ_BYTES - 1)
    overlong = false
    while true
        count = _mcp_wire_read_chunk!(input, chunk, remainder)
        count isa Integer && 0 <= count <= length(chunk) || error("invalid IO byte count")
        count == 0 && break
        offset = 1
        while offset <= count
            newline = findnext(==(UInt8('\n')), chunk, offset)
            finish = newline === nothing || newline > count ? count : newline - 1
            if !overlong
                piece_length = max(0, finish - offset + 1)
                if length(buffer) + piece_length > maximum_line_bytes + 1
                    empty!(buffer)
                    overlong = true
                elseif piece_length > 0
                    append!(buffer, @view chunk[offset:finish])
                end
            end
            if newline === nothing || newline > count
                break
            end
            if overlong
                _mcp_wire_emit!(
                    server,
                    output,
                    _mcp_protocol_error(nothing, "parse_error"),
                    nothing,
                )
            else
                payload = !isempty(buffer) && last(buffer) == UInt8('\r') ?
                          copy(@view buffer[1:(end - 1)]) : copy(buffer)
                if length(payload) > maximum_line_bytes
                    _mcp_wire_emit!(
                        server,
                        output,
                        _mcp_protocol_error(nothing, "parse_error"),
                        nothing,
                    )
                else
                    response, prepared = _mcp_wire_process_payload(
                        server,
                        payload,
                        authorization,
                        maximum_depth,
                    )
                    _mcp_wire_emit!(server, output, response, prepared)
                end
            end
            empty!(buffer)
            overlong = false
            offset = newline + 1
        end
    end

    if overlong
        _mcp_wire_emit!(
            server,
            output,
            _mcp_protocol_error(nothing, "parse_error"),
            nothing,
        )
    elseif !isempty(buffer)
        if length(buffer) > maximum_line_bytes
            _mcp_wire_emit!(
                server,
                output,
                _mcp_protocol_error(nothing, "parse_error"),
                nothing,
            )
        else
            response, prepared = _mcp_wire_process_payload(
                server,
                buffer,
                authorization,
                maximum_depth,
            )
            _mcp_wire_emit!(server, output, response, prepared)
        end
    end
    flush(output)
    shutdown_mcp!(server)
    return nothing
end

function _mcp_wire_read_chunk!(input::IO, chunk::Vector{UInt8}, remainder::Vector{UInt8})
    count = readbytes!(input, chunk, 1)
    count isa Integer && 0 <= count <= 1 || error("invalid IO byte count")
    count == 0 && return 0
    available = min(bytesavailable(input), length(remainder))
    available >= 0 || error("invalid IO byte availability")
    if available > 0
        extra = readbytes!(input, remainder, available)
        extra isa Integer && 0 <= extra <= available || error("invalid IO byte count")
        copyto!(chunk, 2, remainder, 1, extra)
        count += extra
    end
    return count
end

function _mcp_wire_process_payload(
    server::McpServer,
    payload::AbstractVector{UInt8},
    authorization::Vector{UInt8},
    maximum_depth::Int,
)
    request = try
        _mcp_wire_decode_payload(payload, maximum_depth)
    catch error
        if error isa _McpWireFailure
            kind = error.rejection == _McpWireParse ? "parse_error" : "invalid_request"
            return _mcp_protocol_error(nothing, kind), nothing
        end
        return _mcp_protocol_error(nothing, "parse_error"), nothing
    end
    id = _mcp_wire_validated_id(request)
    response, prepared = try
        _mcp_dispatch_for_wire!(server, request, authorization)
    catch
        return _mcp_protocol_error(id, "internal_error"), nothing
    end
    response === nothing && return nothing, nothing
    if !_mcp_validate_frame(response)
        prepared === nothing || _mcp_wire_response_emitted!(server, prepared)
        return _mcp_protocol_error(id, "internal_error"), nothing
    end
    return response, prepared
end

function _mcp_wire_decode_payload(payload::AbstractVector{UInt8}, maximum_depth::Int)
    bytes = collect(UInt8, payload)
    length(bytes) >= 3 && bytes[1:3] == _MCP_WIRE_UTF8_BOM &&
        throw(_McpWireFailure(_McpWireParse))
    text = String(copy(bytes))
    isvalid(text) || throw(_McpWireFailure(_McpWireParse))
    scanner = _McpWireScanner(bytes, maximum_depth)
    try
        _mcp_wire_scan!(scanner)
    catch error
        error isa _McpWireFailure && rethrow()
        throw(_McpWireFailure(_McpWireParse))
    end
    decoded = try
        JSON3.read(text; numbertype = Float64)
    catch
        throw(_McpWireFailure(_McpWireParse))
    end
    position = Ref(1)
    converted = try
        _mcp_wire_convert_json(decoded, scanner.numbers, position)
    catch
        throw(_McpWireFailure(_McpWireParse))
    end
    position[] == length(scanner.numbers) + 1 ||
        throw(_McpWireFailure(_McpWireParse))
    object = _mcp_as_object(converted)
    object === nothing && throw(_McpWireFailure(_McpWireInvalidRequest))
    if haskey(object, "id") &&
       !_mcp_wire_valid_id(object["id"], scanner.id_token)
        throw(_McpWireFailure(_McpWireInvalidRequest))
    end
    return object
end

function _mcp_wire_convert_json(value, numbers, position::Base.RefValue{Int})
    if value isa AbstractDict
        result = Dict{String,Any}()
        for (key, child) in pairs(value)
            result[String(key)] = _mcp_wire_convert_json(child, numbers, position)
        end
        return result
    elseif value isa AbstractVector
        return Any[_mcp_wire_convert_json(child, numbers, position) for child in value]
    elseif value === nothing || value isa Bool
        return value
    elseif value isa AbstractString
        string = String(value)
        isvalid(string) || _mcp_wire_parse_failure()
        return string
    elseif value isa Number
        position[] <= length(numbers) || _mcp_wire_parse_failure()
        token = numbers[position[]]
        position[] += 1
        if token.fractional
            converted = Float64(value)
            isfinite(converted) || _mcp_wire_parse_failure()
            return converted
        end
        converted = tryparse(Int, token.raw)
        converted === nothing && _mcp_wire_parse_failure()
        return converted
    end
    _mcp_wire_parse_failure()
end

function _mcp_wire_valid_id(value, token)
    token isa _McpWireIdToken || return false
    if token.kind == _McpWireNumberTokenKind
        occursin(r"[.eE]", token.raw) && return false
        _mcp_wire_safe_integer_id(token.raw) || return false
    elseif token.kind != _McpWireStringToken
        return false
    end
    return _mcp_validate_named("requestId", value)
end

function _mcp_wire_safe_integer_id(raw::String)
    digits = startswith(raw, "-") ? raw[2:end] : raw
    digits = lstrip(digits, '0')
    isempty(digits) && (digits = "0")
    return length(digits) < length(_MCP_WIRE_SAFE_INTEGER_ID) ||
           (length(digits) == length(_MCP_WIRE_SAFE_INTEGER_ID) &&
            digits <= _MCP_WIRE_SAFE_INTEGER_ID)
end

function _mcp_wire_validated_id(request::Dict{String,Any})
    value = get(request, "id", nothing)
    return _mcp_valid_request_id(value) ? _mcp_copy_json(value) : nothing
end

function _mcp_wire_emit!(server::McpServer, output::IO, response, prepared)
    response === nothing && return nothing
    hook = getfield(server, :before_wire_emit)
    hook === nothing || hook(server, prepared)
    if prepared isa String && !_mcp_wire_response_ready!(server, prepared)
        return nothing
    end
    _mcp_validate_frame(response) || error("invalid MCP response")
    bytes = UInt8[codeunits(_mcp_canonical_json(response))...]
    push!(bytes, UInt8('\n'))
    write(output, bytes)
    flush(output)
    prepared isa String && _mcp_wire_response_emitted!(server, prepared)
    return nothing
end

function _mcp_wire_request_limits()
    try
        limits = _mcp_required_object(_mcp_contract()["request_limits"])
        maximum_line_bytes = _mcp_positive_int(
            get(limits, "line_bytes_excluding_delimiter", nothing),
        )
        maximum_depth = _mcp_positive_int(get(limits, "json_nesting_depth", nothing))
        maximum_line_bytes === nothing && throw(_McpContractError())
        maximum_depth === nothing && throw(_McpContractError())
        return maximum_line_bytes, maximum_depth
    catch
        throw(_mcp_contract_failure())
    end
end

function _mcp_wire_io_failure!(server::McpServer, log)
    shutdown_mcp!(server)
    if log isa IO
        try
            write(log, _MCP_WIRE_IO_LOG_RECORD)
            flush(log)
        catch
            # The primary sanitized failure remains caller-visible.
        end
    end
    throw(McpServerError(
        "linkedspec_mcp_io_failure",
        "The MCP stdio stream failed.",
    ))
end
