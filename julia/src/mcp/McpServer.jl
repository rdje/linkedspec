const _MCP_SERVER_NAME = "linkedspec-semantic-julia"
const _MCP_AUTHORIZATION_MAXIMUM_BYTES = 4096
const _MCP_ENTROPY_BYTES = 32
const _MCP_HANDLE_CHARACTERS = 43
const _MCP_MAXIMUM_HANDLE_ATTEMPTS = 16
const _MCP_DEFAULT_LIFETIME_MS = 900_000
const _MCP_MAXIMUM_LIFETIME_MS = 86_400_000
const _MCP_DEFAULT_MAXIMUM_HANDLES = 1_024
const _MCP_DUMMY_AUTHORIZATION_DIGEST = zeros(UInt8, 32)

"""Optional lower-only semantic query budgets for one registered handle."""
struct McpBudgetLimits
    max_records::Int
    max_relations::Int
    max_depth::Int
end

function McpBudgetLimits(; max_records, max_relations, max_depth)
    for (name, value) in (
        ("max_records", max_records),
        ("max_relations", max_relations),
        ("max_depth", max_depth),
    )
        value isa Integer && !(value isa Bool) ||
            throw(ArgumentError("MCP budget $name must be an integer"))
    end
    return McpBudgetLimits(Int(max_records), Int(max_relations), Int(max_depth))
end

"""Optional deployment ceilings applied below one index's native capabilities."""
struct McpDeploymentPolicy
    source_detail_ceiling::Union{Nothing,SemanticSourceDetail}
    page_max::Union{Nothing,Int}
    budget_maxima::Union{Nothing,McpBudgetLimits}
end

McpDeploymentPolicy(;
    source_detail_ceiling = nothing,
    page_max = nothing,
    budget_maxima = nothing,
) = McpDeploymentPolicy(source_detail_ceiling, page_max, budget_maxima)

"""Registration policy for one caller-owned semantic index."""
struct McpRegistrationOptions
    lifetime_ms::Union{Nothing,Int}
    policy::Union{Nothing,McpDeploymentPolicy}
end

McpRegistrationOptions(; lifetime_ms = nothing, policy = nothing) =
    McpRegistrationOptions(lifetime_ms, policy)

"""Sanitized typed host-API failure; protocol failures are JSON-RPC values."""
struct McpServerError <: Exception
    code::String
    message::String
end

Base.showerror(io::IO, error::McpServerError) = print(io, error.code, ": ", error.message)

struct _McpNativeLimits
    source_detail_ceiling::SemanticSourceDetail
    content_digest_available::Bool
    page_default::Int
    page_max::Int
    budget_defaults::McpBudgetLimits
    budget_maxima::McpBudgetLimits
end

struct _McpEffectivePolicy
    limits::_McpNativeLimits
    project::Bool
    explicit::NamedTuple{
        (:source_detail, :content_digest, :page, :budget),
        NTuple{4,Bool},
    }
end

struct _McpRegistryEntry
    index::SemanticIndex
    authorization_digest::Vector{UInt8}
    expires_ms::Int
    policy::_McpEffectivePolicy
end

mutable struct _McpActiveRequest
    cancelled::Bool
    prepared::Bool
end

"""Native Julia MCP server for caller-registered immutable semantic indexes."""
mutable struct McpServer
    entries::Dict{String,_McpRegistryEntry}
    active::Dict{String,_McpActiveRequest}
    entropy::Function
    now_ms::Function
    maximum_handles::Int
    handle_attempts::Int
    default_lifetime_ms::Int
    maximum_lifetime_ms::Int
    capabilities_of::Function
    query_index::Function
    before_wire_emit::Union{Nothing,Function}
    stopped::Bool
end

Base.propertynames(::McpServer, private::Bool = false) =
    private ? fieldnames(McpServer) : ()

function Base.getproperty(::McpServer, ::Symbol)
    throw(ArgumentError("McpServer is opaque; use the exported MCP operations"))
end

Base.show(io::IO, server::McpServer) =
    print(io, "McpServer(stopped=", getfield(server, :stopped), ")")

"""Construct a production server using OS entropy and monotonic elapsed time."""
function McpServer()
    registry = try
        _mcp_required_object(_mcp_contract()["handle_registry"])
    catch
        throw(_mcp_contract_failure())
    end
    maximum_handles = _mcp_positive_int(
        get(registry, "default_maximum_live_handles", nothing),
    )
    default_lifetime_ms = _mcp_positive_int(get(registry, "default_lifetime_ms", nothing))
    maximum_lifetime_ms = _mcp_positive_int(get(registry, "maximum_lifetime_ms", nothing))
    if maximum_handles === nothing || default_lifetime_ms === nothing ||
       maximum_lifetime_ms === nothing || maximum_lifetime_ms < default_lifetime_ms
        throw(_mcp_contract_failure())
    end
    random_device = try
        Random.RandomDevice()
    catch
        throw(_mcp_entropy_failure())
    end
    started = time_ns()
    return _mcp_server(
        entropy = () -> rand(random_device, UInt8, _MCP_ENTROPY_BYTES),
        now_ms = () -> _mcp_elapsed_milliseconds(started),
        maximum_handles = maximum_handles,
        handle_attempts = _MCP_MAXIMUM_HANDLE_ATTEMPTS,
        default_lifetime_ms = default_lifetime_ms,
        maximum_lifetime_ms = maximum_lifetime_ms,
        capabilities_of = _mcp_native_capabilities,
        query_index = _mcp_native_query,
        before_wire_emit = nothing,
    )
end

function _mcp_server(;
    entropy,
    now_ms,
    maximum_handles,
    handle_attempts,
    default_lifetime_ms,
    maximum_lifetime_ms,
    capabilities_of,
    query_index,
    before_wire_emit,
)
    return McpServer(
        Dict{String,_McpRegistryEntry}(),
        Dict{String,_McpActiveRequest}(),
        entropy,
        now_ms,
        maximum_handles,
        handle_attempts,
        default_lifetime_ms,
        maximum_lifetime_ms,
        capabilities_of,
        query_index,
        before_wire_emit,
        false,
    )
end

"""Register one existing native index and return a fresh opaque handle."""
function register_index!(
    server::McpServer,
    index::SemanticIndex,
    authorization_context;
    options = McpRegistrationOptions(),
)
    getfield(server, :stopped) && throw(_mcp_server_shutdown())
    options isa McpRegistrationOptions || throw(ArgumentError("Invalid MCP registration options"))
    authorization = _mcp_authorization_bytes(authorization_context)
    lifetime_ms = options.lifetime_ms === nothing ? getfield(server, :default_lifetime_ms) :
                  options.lifetime_ms
    1 <= lifetime_ms <= getfield(server, :maximum_lifetime_ms) || throw(McpServerError(
        "linkedspec_mcp_invalid_registration",
        "Registration lifetime is outside the contract bounds.",
    ))
    now = _mcp_read_clock(server)
    _mcp_prune_expired!(server, now)
    length(getfield(server, :entries)) < getfield(server, :maximum_handles) || throw(McpServerError(
        "linkedspec_mcp_registry_full",
        "The MCP handle registry is at capacity.",
    ))

    capabilities = try
        _mcp_required_json_object(getfield(server, :capabilities_of)(index))
    catch
        throw(_mcp_invalid_index())
    end
    _mcp_validate_named("semanticQueryResponse", capabilities) ||
        throw(_mcp_invalid_index())
    native = _mcp_native_limits(capabilities)
    policy = _mcp_effective_policy(options.policy, native)
    now <= typemax(Int) - lifetime_ms || throw(_mcp_clock_failure())
    handle = _mcp_unique_handle(server)
    getfield(server, :entries)[handle] = _McpRegistryEntry(
        index,
        _mcp_authorization_digest(authorization),
        now + lifetime_ms,
        policy,
    )
    return handle
end

"""Revoke a syntactically valid handle without disclosing its prior state."""
function revoke_handle!(server::McpServer, handle::AbstractString)
    _mcp_valid_handle(handle) || throw(McpServerError(
        "linkedspec_mcp_invalid_handle",
        "MCP handle syntax is invalid.",
    ))
    delete!(getfield(server, :entries), String(handle))
    return nothing
end

"""Dispatch one already-decoded JSON request; notifications return `nothing`."""
function dispatch_mcp(server::McpServer, request, authorization_context)
    return _mcp_dispatch_with_preparation!(
        server,
        request,
        authorization_context;
        retain_prepared = false,
    )
end

function _mcp_dispatch_with_preparation!(
    server::McpServer,
    request,
    authorization_context;
    retain_prepared::Bool,
)
    _mcp_authorization_bytes(authorization_context)
    copied = try
        _mcp_copy_json(request)
    catch
        return _mcp_protocol_error(nothing, "invalid_request")
    end
    object = _mcp_as_object(copied)
    candidate_id = object === nothing ? nothing : get(object, "id", nothing)
    id = _mcp_valid_request_id(candidate_id) ? _mcp_copy_json(candidate_id) : nothing
    getfield(server, :stopped) && return _mcp_protocol_error(id, "internal_error")
    if object === nothing || get(object, "jsonrpc", nothing) != "2.0" ||
       !(get(object, "method", nothing) isa AbstractString)
        return _mcp_protocol_error(nothing, "invalid_request")
    end
    method = String(object["method"])
    if !haskey(object, "id")
        if method == "notifications/cancelled" &&
           _mcp_validate_named("cancelledNotification", object)
            params = _mcp_as_object(get(object, "params", nothing))
            request_id = params === nothing ? nothing : get(params, "requestId", nothing)
            try
                key = _mcp_canonical_json(request_id)
                active = get(getfield(server, :active), key, nothing)
                active === nothing || (active.cancelled = true)
            catch
                # The frozen schema above owns admissible cancellation ids.
            end
        end
        return nothing
    end
    id === nothing && return _mcp_protocol_error(nothing, "invalid_request")
    method == "initialize" && return _mcp_protocol_error(id, "legacy_initialize")
    method == "notifications/cancelled" &&
        return _mcp_protocol_error(id, "invalid_request")
    method in ("server/discover", "tools/list", "tools/call") ||
        return _mcp_protocol_error(id, "method_not_found")
    requested = _mcp_requested_protocol(object)
    if requested !== nothing && requested != _mcp_protocol_version()
        return _mcp_protocol_error(id, "unsupported_version"; requested = requested)
    end

    if method == "server/discover"
        _mcp_validate_named("discoverRequest", object) ||
            return _mcp_protocol_error(id, "invalid_params")
        return _mcp_prepare_response!(server, id; retain_prepared) do
            _mcp_discover_response(id)
        end
    elseif method == "tools/list"
        _mcp_validate_named("toolsListRequest", object) ||
            return _mcp_protocol_error(id, "invalid_params")
        return _mcp_prepare_response!(server, id; retain_prepared) do
            _mcp_tools_list_response(id)
        end
    end
    return _mcp_dispatch_tool_call!(
        server,
        object,
        id,
        authorization_context;
        retain_prepared,
    )
end

function _mcp_dispatch_for_wire!(server::McpServer, request, authorization_context)
    object = _mcp_as_object(request)
    id = object === nothing ? nothing : get(object, "id", nothing)
    prepared = try
        id === nothing ? nothing : _mcp_canonical_json(id)
    catch
        nothing
    end
    response = _mcp_dispatch_with_preparation!(
        server,
        request,
        authorization_context;
        retain_prepared = true,
    )
    if response === nothing || prepared === nothing
        return response, nothing
    end
    active = get(getfield(server, :active), prepared, nothing)
    return response, active !== nothing && active.prepared ? prepared : nothing
end

function _mcp_wire_response_ready!(server::McpServer, prepared::String)
    active_requests = getfield(server, :active)
    active = get(active_requests, prepared, nothing)
    active === nothing && return false
    if active.cancelled
        delete!(active_requests, prepared)
        return false
    end
    return active.prepared
end

function _mcp_wire_response_emitted!(server::McpServer, prepared::String)
    delete!(getfield(server, :active), prepared)
    return nothing
end

"""Idempotently clear all registered indexes and active request state."""
function shutdown_mcp!(server::McpServer)
    setfield!(server, :stopped, true)
    empty!(getfield(server, :entries))
    empty!(getfield(server, :active))
    return nothing
end

function _mcp_dispatch_tool_call!(
    server::McpServer,
    request::Dict{String,Any},
    id,
    authorization_context;
    retain_prepared::Bool,
)
    params = _mcp_as_object(get(request, "params", nothing))
    name = params === nothing ? nothing : get(params, "name", nothing)
    definition, operation = if name == "linkedspec_semantic_capabilities"
        ("capabilitiesCallRequest", :capabilities)
    elseif name == "linkedspec_semantic_query"
        ("semanticQueryCallRequest", :query)
    else
        ("", :query)
    end
    isempty(definition) && return _mcp_protocol_error(id, "invalid_params")
    _mcp_validate_named(definition, request) ||
        return _mcp_protocol_error(id, "invalid_params")
    authorization_digest = _mcp_authorization_digest(
        _mcp_authorization_bytes(authorization_context),
    )
    return _mcp_prepare_response!(server, id; retain_prepared) do
        _mcp_build_tool_response(server, request, id, operation, authorization_digest)
    end
end

function _mcp_build_tool_response(
    server::McpServer,
    request::Dict{String,Any},
    id,
    operation::Symbol,
    authorization_digest::Vector{UInt8},
)
    params = _mcp_required_object(request["params"])
    arguments = _mcp_required_object(params["arguments"])
    handle = get(arguments, "handle", nothing)
    handle isa AbstractString || throw(_McpContractError())
    entry = _mcp_authorized_entry!(server, String(handle), authorization_digest)
    entry === nothing && return _mcp_tool_error_response(id; unavailable = true)
    if operation == :query &&
       !_mcp_request_within_policy(get(arguments, "request", nothing), entry.policy)
        return _mcp_tool_error_response(id; unavailable = false)
    end

    if operation == :capabilities
        payload = _mcp_required_json_object(getfield(server, :capabilities_of)(entry.index))
        return _mcp_tool_success_response(
            id,
            _mcp_project_capabilities(payload, entry.policy),
        )
    end
    payload = _mcp_required_json_object(
        getfield(server, :query_index)(entry.index, _mcp_copy_json(arguments["request"])),
    )
    return _mcp_tool_success_response(id, payload)
end

function _mcp_prepare_response!(
    builder::Function,
    server::McpServer,
    id;
    retain_prepared::Bool,
)
    key = try
        _mcp_canonical_json(id)
    catch
        return _mcp_protocol_error(id, "internal_error")
    end
    active_requests = getfield(server, :active)
    haskey(active_requests, key) && return _mcp_protocol_error(id, "internal_error")
    active = _McpActiveRequest(false, false)
    active_requests[key] = active
    response = try
        builder()
    catch
        _mcp_protocol_error(id, "internal_error")
    end
    if active.cancelled
        delete!(active_requests, key)
        return nothing
    end
    if retain_prepared
        active.prepared = true
    else
        delete!(active_requests, key)
    end
    return response
end

function _mcp_authorized_entry!(
    server::McpServer,
    handle::String,
    authorization_digest::Vector{UInt8},
)
    entries = getfield(server, :entries)
    existing = get(entries, handle, nothing)
    expected = existing === nothing ? _MCP_DUMMY_AUTHORIZATION_DIGEST :
               existing.authorization_digest
    authorized = _mcp_fixed_digest_equal(expected, authorization_digest)
    now = _mcp_read_clock(server)
    existing !== nothing && now >= existing.expires_ms && delete!(entries, handle)
    return authorized ? get(entries, handle, nothing) : nothing
end

function _mcp_unique_handle(server::McpServer)
    entries = getfield(server, :entries)
    for _ in 1:getfield(server, :handle_attempts)
        bytes = try
            collect(getfield(server, :entropy)())
        catch
            throw(_mcp_entropy_failure())
        end
        length(bytes) == _MCP_ENTROPY_BYTES && all(byte -> byte isa UInt8, bytes) ||
            throw(_mcp_entropy_failure())
        handle = rstrip(
            replace(Base64.base64encode(UInt8[bytes...]), '+' => '-', '/' => '_'),
            ('=',),
        )
        _mcp_valid_handle(handle) || throw(_mcp_entropy_failure())
        haskey(entries, handle) || return handle
    end
    throw(McpServerError(
        "linkedspec_mcp_entropy_failure",
        "A unique MCP handle could not be generated.",
    ))
end

function _mcp_read_clock(server::McpServer)
    value = try
        getfield(server, :now_ms)()
    catch
        throw(_mcp_clock_failure())
    end
    value isa Integer && !(value isa Bool) && 0 <= value <= typemax(Int) ||
        throw(_mcp_clock_failure())
    return Int(value)
end

function _mcp_prune_expired!(server::McpServer, now::Int)
    entries = getfield(server, :entries)
    for handle in collect(keys(entries))
        now >= entries[handle].expires_ms && delete!(entries, handle)
    end
    return nothing
end

function _mcp_elapsed_milliseconds(started::UInt64)
    elapsed = time_ns() - started
    milliseconds = elapsed ÷ UInt64(1_000_000)
    milliseconds <= UInt64(typemax(Int)) || throw(_mcp_clock_failure())
    return Int(milliseconds)
end

function _mcp_test_server(;
    entropy,
    now_ms,
    maximum_handles = 4,
    handle_attempts = _MCP_MAXIMUM_HANDLE_ATTEMPTS,
    capabilities_of = _mcp_native_capabilities,
    query_index = _mcp_native_query,
    before_wire_emit = nothing,
)
    1 <= maximum_handles <= _MCP_DEFAULT_MAXIMUM_HANDLES ||
        throw(ArgumentError("maximum_handles is outside the test seam"))
    1 <= handle_attempts <= _MCP_MAXIMUM_HANDLE_ATTEMPTS ||
        throw(ArgumentError("handle_attempts is outside the test seam"))
    return _mcp_server(
        entropy = entropy,
        now_ms = now_ms,
        maximum_handles = maximum_handles,
        handle_attempts = handle_attempts,
        default_lifetime_ms = _MCP_DEFAULT_LIFETIME_MS,
        maximum_lifetime_ms = _MCP_MAXIMUM_LIFETIME_MS,
        capabilities_of = capabilities_of,
        query_index = query_index,
        before_wire_emit = before_wire_emit,
    )
end

_mcp_registered_handles(server::McpServer) = length(getfield(server, :entries))
_mcp_active_requests(server::McpServer) = length(getfield(server, :active))

_mcp_native_capabilities(index::SemanticIndex) = to_json(semantic_capabilities(index))
_mcp_native_query(index::SemanticIndex, request) = to_json(semantic_query_neutral(index, request))

function _mcp_authorization_bytes(value)
    if !(value isa AbstractVector{UInt8}) || isempty(value) ||
       length(value) > _MCP_AUTHORIZATION_MAXIMUM_BYTES
        throw(McpServerError(
            "linkedspec_mcp_invalid_authorization",
            "Authorization context must be 1 through 4096 opaque bytes.",
        ))
    end
    return collect(UInt8, value)
end

_mcp_authorization_digest(value::Vector{UInt8}) = collect(UInt8, SHA.sha256(value))

function _mcp_fixed_digest_equal(left::AbstractVector{UInt8}, right::AbstractVector{UInt8})
    difference = length(left) ⊻ length(right)
    for index in 1:32
        left_byte = index <= length(left) ? left[index] : UInt8(0)
        right_byte = index <= length(right) ? right[index] : UInt8(0)
        difference |= Int(left_byte ⊻ right_byte)
    end
    return difference == 0
end

_mcp_valid_handle(value::AbstractString) =
    length(value) == _MCP_HANDLE_CHARACTERS && occursin(_MCP_HANDLE_PATTERN, value)

_mcp_valid_request_id(value) = value !== nothing && _mcp_validate_named("requestId", value)

function _mcp_requested_protocol(request::Dict{String,Any})
    params = _mcp_as_object(get(request, "params", nothing))
    metadata = params === nothing ? nothing : _mcp_as_object(get(params, "_meta", nothing))
    value = metadata === nothing ? nothing :
            get(metadata, "io.modelcontextprotocol/protocolVersion", nothing)
    return value isa AbstractString ? String(value) : nothing
end

function _mcp_native_limits(response::Dict{String,Any})
    records = get(response, "records", nothing)
    records isa AbstractVector || throw(_mcp_invalid_index())
    capabilities = [
        record for record in records if begin
            row = _mcp_as_object(record)
            row !== nothing && get(row, "kind", nothing) == "capabilities"
        end
    ]
    length(capabilities) == 1 || throw(_mcp_invalid_index())
    record = _mcp_required_object(only(capabilities))
    facts = _mcp_required_object(record["facts"])
    snapshot = _mcp_required_object(response["snapshot"])
    source = _mcp_source_detail(get(facts, "source_detail_ceiling", nothing))
    snapshot_source = _mcp_source_detail(get(snapshot, "source_detail_ceiling", nothing))
    page_default = _mcp_positive_int(get(facts, "page_default", nothing))
    page_max = _mcp_positive_int(get(facts, "page_max", nothing))
    defaults = _mcp_budget_limits(get(facts, "budget_defaults", nothing))
    maxima = _mcp_budget_limits(get(facts, "budget_maxima", nothing))
    content_digest = get(snapshot, "content_digest_available", nothing)
    if source === nothing || snapshot_source === nothing || page_default === nothing ||
       page_max === nothing || defaults === nothing || maxima === nothing ||
       !(content_digest isa Bool) || page_default > page_max ||
       !_mcp_budget_within(defaults, maxima)
        throw(_mcp_invalid_index())
    end
    return _McpNativeLimits(
        source,
        content_digest,
        page_default,
        page_max,
        defaults,
        maxima,
    )
end

function _mcp_effective_policy(supplied, native::_McpNativeLimits)
    empty_explicit = (
        source_detail = false,
        content_digest = false,
        page = false,
        budget = false,
    )
    supplied === nothing && return _McpEffectivePolicy(native, false, empty_explicit)
    supplied isa McpDeploymentPolicy || throw(_mcp_invalid_policy(
        "MCP deployment policy is invalid.",
    ))
    source = native.source_detail_ceiling
    content_digest = native.content_digest_available
    page_default = native.page_default
    page_max = native.page_max
    budget_defaults = native.budget_defaults
    budget_maxima = native.budget_maxima
    explicit_source = false
    explicit_content = false
    explicit_page = false
    explicit_budget = false
    if supplied.source_detail_ceiling !== nothing
        detail = supplied.source_detail_ceiling
        _mcp_source_rank(detail) <= _mcp_source_rank(native.source_detail_ceiling) ||
            throw(_mcp_invalid_policy("MCP source-detail policy is invalid or elevating."))
        source = detail
        if detail != SemanticSourceTextDetail
            content_digest = false
            explicit_content = true
        end
        explicit_source = true
    end
    if supplied.page_max !== nothing
        1 <= supplied.page_max <= native.page_max ||
            throw(_mcp_invalid_policy("MCP page policy is invalid or elevating."))
        page_max = supplied.page_max
        page_default = min(page_default, page_max)
        explicit_page = true
    end
    if supplied.budget_maxima !== nothing
        budget = supplied.budget_maxima
        _mcp_valid_budget(budget) && _mcp_budget_within(budget, native.budget_maxima) ||
            throw(_mcp_invalid_policy("MCP budget policy is invalid or elevating."))
        budget_maxima = budget
        budget_defaults = McpBudgetLimits(
            min(budget_defaults.max_records, budget.max_records),
            min(budget_defaults.max_relations, budget.max_relations),
            min(budget_defaults.max_depth, budget.max_depth),
        )
        explicit_budget = true
    end
    return _McpEffectivePolicy(
        _McpNativeLimits(
            source,
            content_digest,
            page_default,
            page_max,
            budget_defaults,
            budget_maxima,
        ),
        explicit_source || explicit_page || explicit_budget,
        (
            source_detail = explicit_source,
            content_digest = explicit_content,
            page = explicit_page,
            budget = explicit_budget,
        ),
    )
end

function _mcp_project_capabilities(
    response::Dict{String,Any},
    policy::_McpEffectivePolicy,
)
    projected = _mcp_required_json_object(response)
    policy.project || return projected
    records = get(projected, "records", nothing)
    records isa AbstractVector || throw(_mcp_invalid_index())
    capabilities = [
        record for record in records if begin
            row = _mcp_as_object(record)
            row !== nothing && get(row, "kind", nothing) == "capabilities"
        end
    ]
    length(capabilities) == 1 || throw(_mcp_invalid_index())
    record = _mcp_required_object(only(capabilities))
    facts = _mcp_required_object(record["facts"])
    facts["source_detail_ceiling"] = _mcp_source_detail_name(
        policy.limits.source_detail_ceiling,
    )
    facts["page_max"] = policy.limits.page_max
    facts["page_default"] = policy.limits.page_default
    facts["budget_maxima"] = _mcp_budget_value(policy.limits.budget_maxima)
    facts["budget_defaults"] = _mcp_budget_value(policy.limits.budget_defaults)
    snapshot = _mcp_required_object(projected["snapshot"])
    snapshot["source_detail_ceiling"] = _mcp_source_detail_name(
        policy.limits.source_detail_ceiling,
    )
    snapshot["content_digest_available"] =
        policy.limits.content_digest_available &&
        policy.limits.source_detail_ceiling == SemanticSourceTextDetail
    return projected
end

function _mcp_request_within_policy(value, policy::_McpEffectivePolicy)
    request = _mcp_as_object(value)
    source = request === nothing ? nothing : _mcp_as_object(get(request, "source", nothing))
    detail = source === nothing ? nothing : _mcp_source_detail(get(source, "detail", nothing))
    if detail === nothing ||
       (policy.explicit.source_detail && _mcp_source_rank(detail) >
                                         _mcp_source_rank(policy.limits.source_detail_ceiling))
        return false
    end
    if get(source, "include_content_digest", false) === true &&
       policy.explicit.content_digest &&
       (!policy.limits.content_digest_available ||
        policy.limits.source_detail_ceiling != SemanticSourceTextDetail)
        return false
    end
    page = request === nothing ? nothing : _mcp_as_object(get(request, "page", nothing))
    limit = page === nothing ? nothing : get(page, "limit", nothing)
    _mcp_is_integer(limit) &&
        (!policy.explicit.page || limit <= policy.limits.page_max) || return false
    budget = request === nothing ? nothing : _mcp_budget_limits(get(request, "budget", nothing))
    return budget !== nothing &&
           (!policy.explicit.budget || _mcp_budget_within(budget, policy.limits.budget_maxima))
end

function _mcp_budget_limits(value)
    map = _mcp_as_object(value)
    map === nothing || length(map) == 3 || return nothing
    records = get(map, "max_records", nothing)
    relations = get(map, "max_relations", nothing)
    depth = get(map, "max_depth", nothing)
    all(_mcp_is_integer, (records, relations, depth)) || return nothing
    return McpBudgetLimits(Int(records), Int(relations), Int(depth))
end

_mcp_valid_budget(value::McpBudgetLimits) =
    value.max_records >= 0 && value.max_relations >= 0 && value.max_depth >= 0

_mcp_budget_within(value::McpBudgetLimits, maximum::McpBudgetLimits) =
    _mcp_valid_budget(value) && value.max_records <= maximum.max_records &&
    value.max_relations <= maximum.max_relations && value.max_depth <= maximum.max_depth

_mcp_budget_value(value::McpBudgetLimits) = Dict{String,Any}(
    "max_records" => value.max_records,
    "max_relations" => value.max_relations,
    "max_depth" => value.max_depth,
)

function _mcp_source_detail(value)
    value == "none" && return SemanticSourceNoneDetail
    value == "identity" && return SemanticSourceIdentityDetail
    value == "span" && return SemanticSourceSpanDetail
    value == "text" && return SemanticSourceTextDetail
    return nothing
end

_mcp_source_detail_name(value::SemanticSourceDetail) =
    value == SemanticSourceNoneDetail ? "none" :
    value == SemanticSourceIdentityDetail ? "identity" :
    value == SemanticSourceSpanDetail ? "span" : "text"

_mcp_source_rank(value::SemanticSourceDetail) = Int(value)

_mcp_positive_int(value) =
    _mcp_is_integer(value) && value > 0 && value <= typemax(Int) ? Int(value) : nothing

function _mcp_protocol_error(id, kind::AbstractString; requested = nothing)
    try
        return _mcp_json_rpc_error(id, kind; requested)
    catch
        return Dict{String,Any}(
            "jsonrpc" => "2.0",
            "id" => _mcp_copy_json(id),
            "error" => Dict{String,Any}("code" => -32603, "message" => "Internal error"),
        )
    end
end

function _mcp_required_json_object(value)
    copied = _mcp_copy_json(value)
    copied isa Dict{String,Any} || throw(_McpContractError())
    return copied
end

_mcp_contract_failure() = McpServerError(
    "linkedspec_mcp_contract_failure",
    "The generated MCP contract is unavailable.",
)

_mcp_invalid_index() = McpServerError(
    "linkedspec_mcp_invalid_index",
    "The semantic index did not provide valid capabilities.",
)

_mcp_invalid_policy(message::AbstractString) =
    McpServerError("linkedspec_mcp_invalid_policy", String(message))

_mcp_server_shutdown() = McpServerError(
    "linkedspec_mcp_server_shutdown",
    "The MCP server has shut down.",
)

_mcp_entropy_failure() = McpServerError(
    "linkedspec_mcp_entropy_failure",
    "Operating-system entropy is unavailable.",
)

_mcp_clock_failure() = McpServerError(
    "linkedspec_mcp_clock_failure",
    "Monotonic time is unavailable.",
)
