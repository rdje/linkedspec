# Frozen runtime over the generated, filesystem-free MCP contract binding.

struct _McpContractError <: Exception end

const _MCP_REF_PREFIX = "#/\$defs/"
const _MCP_HANDLE_PATTERN = r"^[A-Za-z0-9_-]{43}$"
const _MCP_DIGEST_PATTERN = r"^sha256:[0-9a-f]{64}$"
const _MCP_URI_PATTERN = r"^[A-Za-z][A-Za-z0-9+.-]*:"

function _mcp_initialize_bundle()
    raw = try
        Base64.base64decode(_MCP_BUNDLE_BASE64)
    catch
        throw(_McpContractError())
    end
    bytes2hex(SHA.sha256(raw)) == _MCP_BUNDLE_SHA256 || throw(_McpContractError())
    text = String(raw)
    isvalid(text) || throw(_McpContractError())
    root = try
        JSON3.read(text, Dict{String,Any})
    catch
        throw(_McpContractError())
    end
    get(root, "binding_format", nothing) == _MCP_BINDING_FORMAT ||
        throw(_McpContractError())
    semantic = _mcp_as_object(get(root, "semantic_payloads", nothing))
    payloads = semantic === nothing ? nothing : get(semantic, "payloads", nothing)
    payloads isa AbstractVector || throw(_McpContractError())
    ids = Set{String}()
    for payload in payloads
        row = _mcp_as_object(payload)
        id = row === nothing ? nothing : get(row, "id", nothing)
        id isa AbstractString || throw(_McpContractError())
        normalized = String(id)
        normalized in ids && throw(_McpContractError())
        push!(ids, normalized)
    end
    return root
end

function _mcp_contract()
    contract = _mcp_copy_json(get(_MCP_BUNDLE, "contract", nothing))
    contract isa Dict{String,Any} || throw(_McpContractError())
    return contract
end

function _mcp_protocol_version()
    contract = _mcp_as_object(get(_MCP_BUNDLE, "contract", nothing))
    version = contract === nothing ? nothing : get(contract, "protocol_version", nothing)
    version isa AbstractString || throw(_McpContractError())
    return String(version)
end

function _mcp_frame(name::AbstractString)
    frames = _mcp_as_object(get(_MCP_BUNDLE, "canonical_frames", nothing))
    frames === nothing && throw(_McpContractError())
    haskey(frames, name) || return nothing
    value = _mcp_copy_json(frames[name])
    value isa Dict{String,Any} || throw(_McpContractError())
    return value
end

function _mcp_canonical_json(value)
    copied = _mcp_copy_json(value)
    io = IOBuffer()
    _mcp_write_canonical(io, copied)
    return String(take!(io))
end

function _mcp_write_canonical(io::IO, value)
    if value isa AbstractDict
        keys_sorted = sort!(collect(keys(value)))
        write(io, UInt8('{'))
        for (index, key) in enumerate(keys_sorted)
            index == 1 || write(io, UInt8(','))
            write(io, JSON3.write(String(key)))
            write(io, UInt8(':'))
            _mcp_write_canonical(io, value[key])
        end
        write(io, UInt8('}'))
    elseif value isa AbstractVector
        write(io, UInt8('['))
        for (index, child) in enumerate(value)
            index == 1 || write(io, UInt8(','))
            _mcp_write_canonical(io, child)
        end
        write(io, UInt8(']'))
    else
        write(io, JSON3.write(value))
    end
    return nothing
end

function _mcp_validate_named(name::AbstractString, value)
    schema = _mcp_as_object(get(_MCP_BUNDLE, "schema", nothing))
    definitions = schema === nothing ? nothing : _mcp_as_object(get(schema, "\$defs", nothing))
    definition = definitions === nothing ? nothing : get(definitions, name, nothing)
    definition === nothing && return false
    return _mcp_matches(value, definition, schema, 0)
end

function _mcp_validate_frame(value)
    schema = _mcp_as_object(get(_MCP_BUNDLE, "schema", nothing))
    schema === nothing && return false
    return _mcp_matches(value, schema, schema, 0)
end

function _mcp_matches(value, schema, root::AbstractDict, depth::Int)
    try
        _mcp_validate(value, schema, root, depth)
        return true
    catch
        return false
    end
end

function _mcp_validate(value, schema_value, root::AbstractDict, depth::Int)
    depth <= 256 || throw(_McpContractError())
    if schema_value isa Bool
        schema_value || throw(_McpContractError())
        return nothing
    end
    schema = _mcp_as_object(schema_value)
    schema === nothing && throw(_McpContractError())

    reference = get(schema, "\$ref", nothing)
    if reference !== nothing
        reference isa AbstractString || throw(_McpContractError())
        startswith(reference, _MCP_REF_PREFIX) || throw(_McpContractError())
        reference_text = String(reference)
        length(reference_text) > length(_MCP_REF_PREFIX) || throw(_McpContractError())
        name = reference_text[(length(_MCP_REF_PREFIX) + 1):end]
        occursin('/', name) && throw(_McpContractError())
        definitions = _mcp_as_object(get(root, "\$defs", nothing))
        definition = definitions === nothing ? nothing : get(definitions, name, nothing)
        definition === nothing && throw(_McpContractError())
        _mcp_validate(value, definition, root, depth + 1)
    end

    type_value = get(schema, "type", nothing)
    if type_value !== nothing
        matches = if type_value isa AbstractString
            _mcp_has_type(value, type_value)
        elseif type_value isa AbstractVector
            any(kind -> kind isa AbstractString && _mcp_has_type(value, kind), type_value)
        else
            false
        end
        matches || throw(_McpContractError())
    end
    if haskey(schema, "const") && !_mcp_json_equal(value, schema["const"])
        throw(_McpContractError())
    end
    allowed = get(schema, "enum", nothing)
    if allowed !== nothing
        allowed isa AbstractVector || throw(_McpContractError())
        any(expected -> _mcp_json_equal(value, expected), allowed) ||
            throw(_McpContractError())
    end
    one_of = get(schema, "oneOf", nothing)
    if one_of !== nothing
        one_of isa AbstractVector || throw(_McpContractError())
        count(branch -> _mcp_matches(value, branch, root, depth + 1), one_of) == 1 ||
            throw(_McpContractError())
    end
    all_of = get(schema, "allOf", nothing)
    if all_of !== nothing
        all_of isa AbstractVector || throw(_McpContractError())
        for branch in all_of
            _mcp_validate(value, branch, root, depth + 1)
        end
    end

    object = _mcp_as_object(value)
    object === nothing || _mcp_validate_object(object, schema, root, depth)
    value isa AbstractVector && _mcp_validate_array(value, schema, root, depth)
    value isa AbstractString && _mcp_validate_string(value, schema)
    _mcp_is_integer(value) && _mcp_validate_integer(value, schema)
    return nothing
end

function _mcp_validate_object(value::AbstractDict, schema::AbstractDict, root, depth)
    maximum = get(schema, "maxProperties", nothing)
    maximum isa Integer && length(value) > maximum && throw(_McpContractError())
    required = get(schema, "required", nothing)
    if required !== nothing
        required isa AbstractVector || throw(_McpContractError())
        all(name -> name isa AbstractString && haskey(value, name), required) ||
            throw(_McpContractError())
    end
    properties = _mcp_as_object(get(schema, "properties", nothing))
    for (name, child) in value
        property_names = get(schema, "propertyNames", nothing)
        property_names === nothing || _mcp_validate(name, property_names, root, depth + 1)
        if properties !== nothing && haskey(properties, name)
            _mcp_validate(child, properties[name], root, depth + 1)
            continue
        end
        additional = get(schema, "additionalProperties", nothing)
        additional === false && throw(_McpContractError())
        if additional isa AbstractDict || additional isa Bool
            _mcp_validate(child, additional, root, depth + 1)
        end
    end
    return nothing
end

function _mcp_validate_array(value::AbstractVector, schema::AbstractDict, root, depth)
    prefix_value = get(schema, "prefixItems", nothing)
    prefix = prefix_value isa AbstractVector ? prefix_value : ()
    for index in 1:min(length(value), length(prefix))
        _mcp_validate(value[index], prefix[index], root, depth + 1)
    end
    items = get(schema, "items", nothing)
    if items !== nothing
        for index in (length(prefix) + 1):length(value)
            _mcp_validate(value[index], items, root, depth + 1)
        end
    end
    minimum = get(schema, "minItems", nothing)
    maximum = get(schema, "maxItems", nothing)
    minimum isa Integer && length(value) < minimum && throw(_McpContractError())
    maximum isa Integer && length(value) > maximum && throw(_McpContractError())
    return nothing
end

function _mcp_validate_string(value::AbstractString, schema::AbstractDict)
    isvalid(value) || throw(_McpContractError())
    minimum = get(schema, "minLength", nothing)
    maximum = get(schema, "maxLength", nothing)
    maximum_bytes = get(schema, "x-linkedspec-maxUtf8Bytes", nothing)
    minimum isa Integer && length(value) < minimum && throw(_McpContractError())
    maximum isa Integer && length(value) > maximum && throw(_McpContractError())
    maximum_bytes isa Integer && ncodeunits(value) > maximum_bytes && throw(_McpContractError())
    pattern = get(schema, "pattern", nothing)
    if pattern !== nothing
        matches = if pattern == "^[A-Za-z0-9_-]{43}\$"
            occursin(_MCP_HANDLE_PATTERN, value)
        elseif pattern == "^sha256:[0-9a-f]{64}\$"
            occursin(_MCP_DIGEST_PATTERN, value)
        else
            false
        end
        matches || throw(_McpContractError())
    end
    get(schema, "format", nothing) == "uri" &&
        !occursin(_MCP_URI_PATTERN, value) && throw(_McpContractError())
    return nothing
end

function _mcp_validate_integer(value::Integer, schema::AbstractDict)
    minimum = get(schema, "minimum", nothing)
    maximum = get(schema, "maximum", nothing)
    minimum isa Integer && value < minimum && throw(_McpContractError())
    maximum isa Integer && value > maximum && throw(_McpContractError())
    return nothing
end

function _mcp_has_type(value, kind::AbstractString)
    kind == "null" && return value === nothing
    kind == "boolean" && return value isa Bool
    kind == "array" && return value isa AbstractVector
    kind == "object" && return _mcp_as_object(value) !== nothing
    kind == "string" && return value isa AbstractString && isvalid(value)
    kind == "integer" && return _mcp_is_integer(value)
    kind == "number" && return _mcp_is_number(value)
    return false
end

_mcp_is_integer(value) = value isa Integer && !(value isa Bool)
_mcp_is_number(value) =
    value isa Real && !(value isa Bool) && (!(value isa AbstractFloat) || isfinite(value))

function _mcp_json_equal(left, right)
    if _mcp_is_number(left) || _mcp_is_number(right)
        return _mcp_is_number(left) && _mcp_is_number(right) &&
               typeof(left) == typeof(right) && left == right
    end
    if left isa AbstractVector || right isa AbstractVector
        return left isa AbstractVector && right isa AbstractVector &&
               length(left) == length(right) &&
               all(index -> _mcp_json_equal(left[index], right[index]), eachindex(left))
    end
    left_object = _mcp_as_object(left)
    right_object = _mcp_as_object(right)
    if left_object !== nothing || right_object !== nothing
        return left_object !== nothing && right_object !== nothing &&
               length(left_object) == length(right_object) &&
               all(
            pair -> haskey(right_object, first(pair)) &&
                    _mcp_json_equal(last(pair), right_object[first(pair)]),
            left_object,
        )
    end
    return left == right
end

function _mcp_discover_response(id)
    response = _mcp_frame("discover_response_julia")
    response === nothing && throw(_McpContractError())
    response["id"] = _mcp_copy_json(id)
    return response
end

function _mcp_tools_list_response(id)
    response = _mcp_frame("tools_list_response_perl")
    response === nothing && throw(_McpContractError())
    _mcp_set_server_name!(response)
    response["id"] = _mcp_copy_json(id)
    return response
end

function _mcp_tool_success_response(id, payload::Dict{String,Any})
    _mcp_validate_named("semanticQueryResponse", payload) || throw(_McpContractError())
    response = _mcp_frame("capabilities_call_response")
    response === nothing && throw(_McpContractError())
    _mcp_set_server_name!(response)
    response["id"] = _mcp_copy_json(id)
    result = _mcp_required_object(response["result"])
    result["structuredContent"] = _mcp_copy_json(payload)
    content = get(result, "content", nothing)
    content isa AbstractVector && !isempty(content) || throw(_McpContractError())
    first = _mcp_required_object(content[1])
    first["text"] = _mcp_canonical_json(payload)
    return response
end

function _mcp_tool_error_response(id; unavailable::Bool)
    response = _mcp_frame("policy_denied_response")
    response === nothing && throw(_McpContractError())
    _mcp_set_server_name!(response)
    if unavailable
        unavailable_response = _mcp_frame("handle_unavailable_response")
        unavailable_result = unavailable_response === nothing ? nothing :
                             _mcp_as_object(get(unavailable_response, "result", nothing))
        unavailable_result === nothing && throw(_McpContractError())
        result = _mcp_required_object(response["result"])
        result["content"] = _mcp_copy_json(unavailable_result["content"])
    end
    response["id"] = _mcp_copy_json(id)
    return response
end

function _mcp_json_rpc_error(id, kind::AbstractString; requested = nothing)
    contract = _mcp_as_object(get(_MCP_BUNDLE, "contract", nothing))
    contract === nothing && throw(_McpContractError())
    code = nothing
    message = nothing
    if kind == "legacy_initialize"
        legacy = _mcp_as_object(get(contract, "legacy_diagnostic", nothing))
        code = legacy === nothing ? nothing : get(legacy, "code", nothing)
        message = legacy === nothing ? nothing : get(legacy, "message", nothing)
    else
        owner = get(
            Dict(
                "parse_error" => "invalid_utf8",
                "invalid_request" => "invalid_envelope",
                "method_not_found" => "unknown_method",
                "invalid_params" => "method_params",
                "internal_error" => "sanitized_unexpected_failure",
                "unsupported_version" => "unsupported_protocol_version",
            ),
            String(kind),
            nothing,
        )
        rows = get(contract, "json_rpc_errors", nothing)
        owner === nothing || rows isa AbstractVector || throw(_McpContractError())
        for candidate in rows
            row = _mcp_as_object(candidate)
            owns = row === nothing ? nothing : get(row, "owns", nothing)
            if owns isa AbstractVector && owner in owns
                code = get(row, "code", nothing)
                message = get(row, "message", nothing)
                break
            end
        end
    end
    code isa Integer && message isa AbstractString || throw(_McpContractError())
    error = Dict{String,Any}("code" => Int(code), "message" => String(message))
    if kind == "unsupported_version"
        error["data"] = Dict{String,Any}(
            "requested" => requested === nothing ? "" : String(requested),
            "supported" => Any[_mcp_protocol_version()],
        )
    end
    return Dict{String,Any}(
        "jsonrpc" => "2.0",
        "id" => _mcp_copy_json(id),
        "error" => error,
    )
end

function _mcp_set_server_name!(response::Dict{String,Any})
    result = _mcp_required_object(response["result"])
    metadata = _mcp_required_object(result["_meta"])
    server = _mcp_required_object(metadata["io.modelcontextprotocol/serverInfo"])
    server["name"] = _MCP_SERVER_NAME
    return response
end

function _mcp_as_object(value)
    value isa Dict{String,Any} && return value
    value isa AbstractDict || return nothing
    result = Dict{String,Any}()
    for (key, child) in value
        key isa AbstractString || return nothing
        normalized = String(key)
        haskey(result, normalized) && return nothing
        result[normalized] = child
    end
    return result
end

function _mcp_required_object(value)
    result = _mcp_as_object(value)
    result === nothing && throw(_McpContractError())
    return result
end

function _mcp_copy_json(value, depth::Int = 0, active = IdDict{Any,Nothing}())
    depth <= 256 || throw(_McpContractError())
    if value === nothing || value isa Bool
        return value
    elseif value isa AbstractString
        isvalid(value) || throw(_McpContractError())
        return String(value)
    elseif _mcp_is_integer(value)
        return value
    elseif value isa AbstractFloat
        isfinite(value) || throw(_McpContractError())
        return value
    elseif value isa Tuple
        return Any[_mcp_copy_json(child, depth + 1, active) for child in value]
    elseif value isa AbstractVector
        haskey(active, value) && throw(_McpContractError())
        active[value] = nothing
        try
            return Any[_mcp_copy_json(child, depth + 1, active) for child in value]
        finally
            delete!(active, value)
        end
    elseif value isa AbstractDict
        haskey(active, value) && throw(_McpContractError())
        active[value] = nothing
        try
            result = Dict{String,Any}()
            for (key, child) in value
                key isa Union{AbstractString,Symbol} || throw(_McpContractError())
                name = String(key)
                isvalid(name) || throw(_McpContractError())
                haskey(result, name) && throw(_McpContractError())
                result[name] = _mcp_copy_json(child, depth + 1, active)
            end
            return result
        finally
            delete!(active, value)
        end
    end
    throw(_McpContractError())
end

const _MCP_BUNDLE = _mcp_initialize_bundle()
