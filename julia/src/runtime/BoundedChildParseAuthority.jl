"""
Private authority for synchronous child parsing over one bounded source span.

Trusted host code seeds immutable logical entries containing already-compiled
callbacks, then starts a fresh invocation over copied decoded sources. Authored
execution can select only an entry identity, one allowed top rule, and an exact
direct same-source span. This module deliberately owns no syntax, ActionIR node,
interpreter carrier, generated format, or rollout route.
"""
module BoundedChildParseAuthority

import JSON3
import ..SourceLocation

const _DEFAULT_ORIGIN = "dispatch_span"
const _DISPATCH_EFFECT = "parser_registry_or_staged_dispatch"
const _LIVE_RESULT_FIELD_TOKENS = (
    "authority",
    "handle",
    "parser",
    "registry",
    "transaction",
    "cancellation",
    "path",
    "source_text",
    "host",
)

"""Maximum diagnostic source detail granted to one child parser."""
@enum ProgressiveSourceDetail begin
    ProgressiveNone = 0
    ProgressiveIdentity = 1
    ProgressiveSpan = 2
    ProgressiveText = 3
end

const _SOURCE_DETAIL_NAMES = (
    "none",
    "identity",
    "span",
    "text",
)

function parse_source_detail(value::AbstractString)
    index = findfirst(==(String(value)), _SOURCE_DETAIL_NAMES)
    index === nothing && throw(
        ProgressiveConfigurationException(
            "invalid progressive source detail $(repr(String(value)))",
        ),
    )
    return ProgressiveSourceDetail(index - 1)
end

source_detail_name(value::ProgressiveSourceDetail) =
    _SOURCE_DETAIL_NAMES[Int(value) + 1]

"""Capability-independent policy and resource ceilings."""
struct ProgressiveCeilings
    source_detail::ProgressiveSourceDetail
    policy_modes::Tuple{Vararg{String}}
    max_steps::Int
    max_result_nodes::Int
    max_diagnostic_bytes::Int

    function ProgressiveCeilings(
        ::Val{:internal},
        source_detail::ProgressiveSourceDetail,
        policy_modes::Tuple{Vararg{String}},
        max_steps::Int,
        max_result_nodes::Int,
        max_diagnostic_bytes::Int,
    )
        return new(
            source_detail,
            policy_modes,
            max_steps,
            max_result_nodes,
            max_diagnostic_bytes,
        )
    end
end

function ProgressiveCeilings(;
    source_detail::ProgressiveSourceDetail,
    policy_modes,
    max_steps::Int,
    max_result_nodes::Int,
    max_diagnostic_bytes::Int,
)
    max_steps > 0 && max_result_nodes > 0 && max_diagnostic_bytes > 0 ||
        throw(
            ProgressiveConfigurationException(
                "progressive numeric ceilings must be positive",
            ),
        )
    return ProgressiveCeilings(
        Val(:internal),
        source_detail,
        _validated_strings(policy_modes, "progressive policy modes"),
        max_steps,
        max_result_nodes,
        max_diagnostic_bytes,
    )
end

"""One deeply owned immutable logical-registry entry."""
struct ProgressiveRegistryEntry
    parser_id::String
    compiled_authority::Any
    fingerprint::String
    allowed_top_rules::Tuple{Vararg{String}}
    capabilities::Tuple{Vararg{String}}
    ceilings::ProgressiveCeilings

    function ProgressiveRegistryEntry(
        ::Val{:internal},
        parser_id::String,
        compiled_authority,
        fingerprint::String,
        allowed_top_rules::Tuple{Vararg{String}},
        capabilities::Tuple{Vararg{String}},
        ceilings::ProgressiveCeilings,
    )
        return new(
            parser_id,
            compiled_authority,
            fingerprint,
            allowed_top_rules,
            capabilities,
            ceilings,
        )
    end
end

function ProgressiveRegistryEntry(;
    parser_id::AbstractString,
    compiled_authority,
    fingerprint::AbstractString,
    allowed_top_rules,
    capabilities,
    ceilings::ProgressiveCeilings,
)
    owned_id = String(parser_id)
    _valid_parser_id(owned_id) || throw(
        ProgressiveConfigurationException(
            "invalid progressive parser identity $(repr(owned_id))",
        ),
    )
    owned_fingerprint = String(fingerprint)
    _valid_fingerprint(owned_fingerprint) || throw(
        ProgressiveConfigurationException(
            "invalid progressive fingerprint for $(repr(owned_id))",
        ),
    )
    owned_rules = _validated_strings(
        allowed_top_rules,
        "allowed progressive top rules",
    )
    all(_valid_top_rule, owned_rules) || throw(
        ProgressiveConfigurationException(
            "invalid allowed top rule for $(repr(owned_id))",
        ),
    )
    return ProgressiveRegistryEntry(
        Val(:internal),
        owned_id,
        compiled_authority,
        owned_fingerprint,
        owned_rules,
        _validated_strings(capabilities, "progressive capabilities"),
        ceilings,
    )
end

"""Immutable logical registry over already-compiled child parsers."""
struct ProgressiveRegistry
    _entries::Tuple{Vararg{ProgressiveRegistryEntry}}

    function ProgressiveRegistry(
        ::Val{:internal},
        entries::Tuple{Vararg{ProgressiveRegistryEntry}},
    )
        return new(entries)
    end
end

function ProgressiveRegistry(; entries)
    owned = Tuple(ProgressiveRegistryEntry[entry for entry in entries])
    isempty(owned) && throw(
        ProgressiveConfigurationException("progressive registry must be nonempty"),
    )
    identities = String[entry.parser_id for entry in owned]
    length(unique(identities)) == length(identities) || throw(
        ProgressiveConfigurationException(
            "duplicate progressive parser identity",
        ),
    )
    return ProgressiveRegistry(Val(:internal), owned)
end

"""Runtime registration is never an authored capability."""
function register!(registry::ProgressiveRegistry, parser_id)
    registry
    _throw_dispatch(
        "progressive_registry_mutation_forbidden",
        "origin" => "registry:register",
        "parser_id" => _diagnostic_operand(parser_id),
    )
end

"""Runtime path/provider loading is never an authored capability."""
function load(registry::ProgressiveRegistry, parser_id)
    registry
    _throw_dispatch(
        "progressive_implicit_load_forbidden",
        "origin" => "registry:load",
        "parser_id" => _diagnostic_operand(parser_id),
    )
end

"""Identity-bearing cancellation authority shared by parent and children."""
mutable struct ProgressiveCancellationToken
    _cancelled::Bool
end

ProgressiveCancellationToken() = ProgressiveCancellationToken(false)
cancel!(token::ProgressiveCancellationToken) = (token._cancelled = true; nothing)

"""Caller-owned monotonic clock observed only at dispatch safe points."""
struct ProgressiveClock
    _now::Any
end

clock_now(clock::ProgressiveClock) = Int(clock._now())

"""One parser/top/source/global-span row already active in an invocation."""
struct ProgressiveChainFrame
    parser_id::String
    top_rule::String
    source_id::String
    start::Int
    stop::Int
end

function ProgressiveChainFrame(;
    parser_id::AbstractString,
    top_rule::AbstractString,
    source_id::AbstractString,
    start::Int,
    stop::Int,
)
    owned_id = String(parser_id)
    owned_rule = String(top_rule)
    owned_source = String(source_id)
    _valid_parser_id(owned_id) &&
        _valid_top_rule(owned_rule) &&
        !isempty(owned_source) &&
        start >= 0 &&
        stop >= 0 || throw(
            ProgressiveConfigurationException(
                "invalid progressive active-chain identity",
            ),
        )
    return ProgressiveChainFrame(owned_id, owned_rule, owned_source, start, stop)
end

"""Complete fresh-invocation authority supplied by a trusted host."""
struct ProgressiveInvocationConfig
    sources::Tuple{Vararg{Pair{String,String}}}
    source_id::String
    cancellation_token::ProgressiveCancellationToken
    clock::ProgressiveClock
    deadline_tick::Int
    remaining_steps::Int
    max_depth::Int
    max_calls::Int
    active_chain::Tuple{Vararg{ProgressiveChainFrame}}
    total_calls::Int
end

function ProgressiveInvocationConfig(;
    sources::AbstractDict,
    source_id::AbstractString,
    cancellation_token::ProgressiveCancellationToken,
    clock::ProgressiveClock,
    deadline_tick::Int,
    remaining_steps::Int,
    max_depth::Int,
    max_calls::Int,
    active_chain = ProgressiveChainFrame[],
    total_calls::Int = 0,
)
    owned_sources = Pair{String,String}[
        String(source) => _copy_string(text)
        for (source, text) in pairs(sources)
    ]
    sort!(owned_sources; by = first)
    return ProgressiveInvocationConfig(
        Tuple(owned_sources),
        String(source_id),
        cancellation_token,
        clock,
        deadline_tick,
        remaining_steps,
        max_depth,
        max_calls,
        Tuple(ProgressiveChainFrame[frame for frame in active_chain]),
        total_calls,
    )
end

"""Dynamic defensive arguments accepted by the private authority boundary."""
struct ProgressiveDispatchArguments
    origin::String
    parser_id::Any
    top_rule::Any
    span::Any
    caller_capabilities::Tuple{Vararg{String}}
    required_capabilities::Tuple{Vararg{String}}
    caller_ceilings::ProgressiveCeilings
    required_source_detail::ProgressiveSourceDetail
    child_token::ProgressiveCancellationToken
    cost::Int
    transaction_active::Bool
end

function ProgressiveDispatchArguments(;
    origin::AbstractString,
    parser_id,
    top_rule,
    span,
    caller_capabilities,
    required_capabilities = String[],
    caller_ceilings::ProgressiveCeilings,
    required_source_detail::ProgressiveSourceDetail = ProgressiveNone,
    child_token::ProgressiveCancellationToken,
    cost::Int,
    transaction_active::Bool = false,
)
    return ProgressiveDispatchArguments(
        String(origin),
        parser_id,
        top_rule,
        span,
        _validated_strings(caller_capabilities, "progressive caller capabilities"),
        _validated_strings(
            required_capabilities,
            "progressive required capabilities";
            allow_empty = true,
        ),
        caller_ceilings,
        required_source_detail,
        child_token,
        cost,
        transaction_active,
    )
end

"""Exact capability and policy intersection delivered to a child callback."""
struct ProgressiveEffectiveAuthority
    capabilities::Tuple{Vararg{String}}
    source_detail::ProgressiveSourceDetail
    policy_modes::Tuple{Vararg{String}}
    max_steps::Int
    max_result_nodes::Int
    max_diagnostic_bytes::Int
end

function to_json(value::ProgressiveEffectiveAuthority)
    return Dict{String,Any}(
        "capabilities" => collect(value.capabilities),
        "source_detail" => source_detail_name(value.source_detail),
        "policy_modes" => collect(value.policy_modes),
        "max_steps" => value.max_steps,
        "max_result_nodes" => value.max_result_nodes,
        "max_diagnostic_bytes" => value.max_diagnostic_bytes,
    )
end

mutable struct _ProgressiveSourceViewState
    active::Bool
    authority::SourceLocation.SourceAuthority
    source_id::String
    text::String
    start::Int
    stop::Int
    provenance::String
    origin::String
    diagnostic_ceiling::Int
end

"""One callback-scoped bounded view over the invocation's original source."""
struct ProgressiveSourceView
    _state::_ProgressiveSourceViewState
end

"""Child request containing no path, loader, compiler, or parent parser state."""
struct ProgressiveDispatchRequest
    parser_id::String
    top_rule::String
    fingerprint::String
    source_view::ProgressiveSourceView
    effective::ProgressiveEffectiveAuthority
    cancellation_token::ProgressiveCancellationToken
    deadline_tick::Int
    remaining_steps::Int
    _nested_dispatch::Any
end

function dispatch_nested(
    request::ProgressiveDispatchRequest,
    arguments::ProgressiveDispatchArguments,
)
    _ensure_active(request.source_view)
    return request._nested_dispatch(arguments)
end

view_text(view::ProgressiveSourceView) = (_ensure_active(view); view._state.text)
view_source_id(view::ProgressiveSourceView) =
    (_ensure_active(view); view._state.source_id)
view_provenance(view::ProgressiveSourceView) =
    (_ensure_active(view); view._state.provenance)

function local_to_global(view::ProgressiveSourceView, offset::Int)
    _ensure_local_offset(view, offset)
    return view._state.start + offset
end

function rebase_position(view::ProgressiveSourceView, offset::Int)
    global_offset = local_to_global(view, offset)
    context = _location_context(view)
    return SourceLocation.to_json(
        SourceLocation.position(
            view._state.authority;
            source_id = view._state.source_id,
            offset = global_offset,
            context,
        ),
    )
end

function rebase_span(view::ProgressiveSourceView, value)
    _ensure_active(view)
    span = _parse_span(value, view._state.origin)
    span.source_id == view._state.source_id || _throw_source_mismatch(
        view._state.origin,
        view._state.source_id,
        span.source_id,
    )
    _ensure_local_offset(view, span.start)
    _ensure_local_offset(view, span.stop)
    span.start <= span.stop || _throw_reversed(view._state.origin, span)
    context = _location_context(view)
    start = SourceLocation.position(
        view._state.authority;
        source_id = span.source_id,
        offset = view._state.start + span.start,
        context,
    )
    stop = SourceLocation.position(
        view._state.authority;
        source_id = span.source_id,
        offset = view._state.start + span.stop,
        context,
    )
    return SourceLocation.to_json(
        SourceLocation.direct_span(
            view._state.authority;
            start,
            stop,
            provenance = span.provenance,
            context,
        ),
    )
end

function rebase_diagnostic(view::ProgressiveSourceView, value)
    _ensure_active(view)
    value isa AbstractDict || throw(
        ProgressiveSourceViewException("diagnostic must be an object"),
    )
    copy = Dict{String,Any}()
    for (key, field_value) in pairs(value)
        key isa AbstractString || throw(
            ProgressiveSourceViewException("diagnostic keys must be strings"),
        )
        owned_key = String(key)
        if owned_key == "span" && field_value isa AbstractDict
            copy[owned_key] = rebase_span(view, field_value)
        elseif _is_offset_field(owned_key) && field_value isa Integer
            copy[owned_key] = local_to_global(view, Int(field_value))
        else
            copy[owned_key] = _detach_diagnostic_value(field_value)
        end
    end
    copy["source_id"] = view._state.source_id
    ncodeunits(JSON3.write(copy)) <= view._state.diagnostic_ceiling || throw(
        ProgressiveSourceViewException(
            "rebased diagnostic exceeds its effective byte ceiling",
        ),
    )
    return copy
end

function _ensure_active(view::ProgressiveSourceView)
    view._state.active || throw(
        ProgressiveSourceViewException(
            "progressive source view is outside child execution",
        ),
    )
    return nothing
end

function _ensure_local_offset(view::ProgressiveSourceView, offset::Int)
    _ensure_active(view)
    length = view._state.stop - view._state.start
    0 <= offset <= length || _throw_out_of_bounds(
        view._state.origin,
        view._state.source_id,
        offset,
        offset,
        length,
    )
    return nothing
end

_location_context(view::ProgressiveSourceView) =
    SourceLocation.SourceLocationContext(
        rule_role = "progressive_child",
        invocation_role = view._state.origin,
    )

"""Misuse of a callback-scoped source view."""
struct ProgressiveSourceViewException <: Exception
    message::String
end

Base.showerror(io::IO, error::ProgressiveSourceViewException) =
    print(io, error.message)

"""Portable progressive-dispatch diagnostic."""
struct ProgressiveDispatchException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}
end

diagnostic_code(error::ProgressiveDispatchException) =
    String(first(error._record).second)

function to_json(error::ProgressiveDispatchException)
    return Dict{String,Any}(
        field.first => _copy_plain_value(field.second)
        for field in error._record
    )
end

Base.showerror(io::IO, error::ProgressiveDispatchException) = print(
    io,
    "LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:",
    diagnostic_code(error),
)

"""Invalid trusted-host authority construction."""
struct ProgressiveConfigurationException <: Exception
    message::String
end

Base.showerror(io::IO, error::ProgressiveConfigurationException) =
    print(io, "progressive authority configuration: ", error.message)

struct _NeutralSpan
    source_id::String
    start::Int
    stop::Int
    provenance::String
end

"""One shared invocation authority containing no parent parser registers."""
mutable struct ProgressiveInvocation
    _registry::ProgressiveRegistry
    _source_authority::SourceLocation.SourceAuthority
    _source_id::String
    _cancellation_token::ProgressiveCancellationToken
    _clock::ProgressiveClock
    _deadline_tick::Int
    _remaining_steps::Int
    _max_depth::Int
    _max_calls::Int
    _total_calls::Int
    _active_chain::Vector{ProgressiveChainFrame}
end

function start_invocation(
    registry::ProgressiveRegistry,
    config::ProgressiveInvocationConfig,
)
    isempty(config.sources) && throw(
        ProgressiveConfigurationException(
            "progressive invocation requires decoded sources and one source id",
        ),
    )
    isempty(config.source_id) && throw(
        ProgressiveConfigurationException(
            "progressive invocation requires decoded sources and one source id",
        ),
    )
    sources = Dict{String,String}(config.sources)
    haskey(sources, config.source_id) || throw(
        ProgressiveConfigurationException(
            "progressive invocation source $(repr(config.source_id)) is unavailable",
        ),
    )
    config.deadline_tick >= 0 &&
        config.remaining_steps >= 0 &&
        config.max_depth > 0 &&
        config.max_calls > 0 &&
        config.total_calls >= 0 || throw(
            ProgressiveConfigurationException(
                "progressive invocation limits are invalid",
            ),
        )
    authority = SourceLocation.SourceAuthority(; sources)
    for frame in config.active_chain
        length = SourceLocation.source_scalar_length(authority, frame.source_id)
        length !== nothing &&
            frame.start <= frame.stop &&
            frame.stop <= length || throw(
                ProgressiveConfigurationException(
                    "progressive active-chain span is invalid",
                ),
            )
    end
    return ProgressiveInvocation(
        registry,
        authority,
        config.source_id,
        config.cancellation_token,
        config.clock,
        config.deadline_tick,
        config.remaining_steps,
        config.max_depth,
        config.max_calls,
        config.total_calls,
        collect(config.active_chain),
    )
end

remaining_steps(invocation::ProgressiveInvocation) = invocation._remaining_steps
total_calls(invocation::ProgressiveInvocation) = invocation._total_calls

"""Execute one synchronous isolated child dispatch."""
function dispatch(
    invocation::ProgressiveInvocation,
    arguments::ProgressiveDispatchArguments,
)
    origin = isempty(arguments.origin) ? _DEFAULT_ORIGIN : arguments.origin
    parser_id = _literal_string(
        arguments.parser_id,
        origin,
        "progressive_parser_identity_literal_required",
    )
    _valid_parser_id(parser_id) || _throw_dispatch(
        "progressive_parser_identity_invalid",
        "origin" => origin,
        "parser_id" => parser_id,
    )
    top_rule = _literal_string(
        arguments.top_rule,
        origin,
        "progressive_top_rule_literal_required",
    )
    _valid_top_rule(top_rule) || _throw_dispatch(
        "progressive_top_rule_invalid",
        "origin" => origin,
        "top_rule" => top_rule,
    )
    arguments.span isa AbstractDict || _throw_dispatch(
        "progressive_span_binding_required",
        "origin" => origin,
        "operand" => _diagnostic_operand(arguments.span),
    )
    span = _parse_span(arguments.span, origin)
    span.source_id == invocation._source_id || _throw_source_mismatch(
        origin,
        invocation._source_id,
        span.source_id,
    )
    source_length = something(
        SourceLocation.source_scalar_length(
            invocation._source_authority,
            span.source_id,
        ),
        0,
    )
    span.stop <= source_length || _throw_out_of_bounds(
        origin,
        span.source_id,
        span.start,
        span.stop,
        source_length,
    )
    span.start <= span.stop || _throw_reversed(origin, span)
    arguments.transaction_active && _throw_dispatch(
        "progressive_transaction_forbidden",
        "origin" => origin,
        "effect" => _DISPATCH_EFFECT,
    )

    entry = _find_entry(invocation._registry, parser_id)
    entry === nothing && _throw_dispatch(
        "progressive_registry_missing",
        "origin" => origin,
        "parser_id" => parser_id,
    )
    top_rule in entry.allowed_top_rules || _throw_dispatch(
        "progressive_top_rule_forbidden",
        "origin" => origin,
        "parser_id" => parser_id,
        "top_rule" => top_rule,
    )
    effective = _effective_authority(entry, arguments, origin)
    _check_chain(invocation, parser_id, top_rule, span, origin)
    _check_safe_point(invocation, arguments, parser_id, effective, origin)

    invocation._total_calls += 1
    invocation._remaining_steps -= arguments.cost
    context = SourceLocation.SourceLocationContext(
        rule_role = "progressive_parent",
        invocation_role = origin,
    )
    start = SourceLocation.position(
        invocation._source_authority;
        source_id = span.source_id,
        offset = span.start,
        context,
    )
    stop = SourceLocation.position(
        invocation._source_authority;
        source_id = span.source_id,
        offset = span.stop,
        context,
    )
    typed_span = SourceLocation.direct_span(
        invocation._source_authority;
        start,
        stop,
        provenance = span.provenance,
        context,
    )
    source_view = ProgressiveSourceView(
        _ProgressiveSourceViewState(
            true,
            invocation._source_authority,
            span.source_id,
            SourceLocation.materialize(
                invocation._source_authority,
                typed_span;
                context,
            ),
            span.start,
            span.stop,
            span.provenance,
            origin,
            effective.max_diagnostic_bytes,
        ),
    )
    push!(
        invocation._active_chain,
        ProgressiveChainFrame(
            parser_id,
            top_rule,
            span.source_id,
            span.start,
            span.stop,
        ),
    )
    request = ProgressiveDispatchRequest(
        entry.parser_id,
        top_rule,
        entry.fingerprint,
        source_view,
        effective,
        invocation._cancellation_token,
        invocation._deadline_tick,
        min(
            invocation._remaining_steps,
            max(0, effective.max_steps - arguments.cost),
        ),
        nested_arguments -> dispatch(invocation, nested_arguments),
    )

    child_result = nothing
    child_failure = nothing
    try
        child_result = entry.compiled_authority(request)
    catch error
        child_failure = error
    finally
        pop!(invocation._active_chain)
        source_view._state.active = false
    end
    if child_failure !== nothing || child_result === nothing
        _throw_child_failed(
            origin,
            parser_id,
            top_rule,
            span,
            child_failure === nothing ? "<null child result>" :
                sprint(showerror, child_failure),
            effective.max_diagnostic_bytes,
        )
    end
    _check_cancellation_and_deadline(invocation, parser_id, origin)
    return _detach_result(
        child_result,
        parser_id,
        origin,
        effective.max_result_nodes,
    )
end

function _check_safe_point(
    invocation::ProgressiveInvocation,
    arguments::ProgressiveDispatchArguments,
    parser_id::String,
    effective::ProgressiveEffectiveAuthority,
    origin::String,
)
    arguments.child_token === invocation._cancellation_token || _throw_dispatch(
        "progressive_cancellation_authority_mismatch",
        "origin" => origin,
        "parser_id" => parser_id,
    )
    _check_cancellation_and_deadline(invocation, parser_id, origin)
    if arguments.cost < 0 ||
            invocation._remaining_steps == 0 ||
            arguments.cost > invocation._remaining_steps ||
            arguments.cost > effective.max_steps
        _throw_dispatch(
            "progressive_budget_exhausted",
            "origin" => origin,
            "parser_id" => parser_id,
            "remaining" => min(
                invocation._remaining_steps,
                effective.max_steps,
            ),
        )
    end
    return nothing
end

function _check_cancellation_and_deadline(
    invocation::ProgressiveInvocation,
    parser_id::String,
    origin::String,
)
    invocation._cancellation_token._cancelled && _throw_dispatch(
        "progressive_cancelled",
        "origin" => origin,
        "parser_id" => parser_id,
    )
    clock_now(invocation._clock) >= invocation._deadline_tick && _throw_dispatch(
        "progressive_deadline_exceeded",
        "origin" => origin,
        "parser_id" => parser_id,
        "deadline" => invocation._deadline_tick,
    )
    return nothing
end

function _check_chain(
    invocation::ProgressiveInvocation,
    parser_id::String,
    top_rule::String,
    span::_NeutralSpan,
    origin::String,
)
    length(invocation._active_chain) >= invocation._max_depth && _throw_dispatch(
        "progressive_depth_exceeded",
        "origin" => origin,
        "depth" => length(invocation._active_chain),
        "maximum" => invocation._max_depth,
    )
    invocation._total_calls >= invocation._max_calls && _throw_dispatch(
        "progressive_call_limit_exceeded",
        "origin" => origin,
        "calls" => invocation._total_calls,
        "maximum" => invocation._max_calls,
    )
    for active in invocation._active_chain
        active.parser_id == parser_id &&
            active.top_rule == top_rule &&
            active.source_id == span.source_id || continue
        contained = active.start <= span.start <= span.stop <= active.stop
        smaller = span.stop - span.start < active.stop - active.start
        contained && smaller && continue
        _throw_dispatch(
            "progressive_cycle_non_decreasing",
            "origin" => origin,
            "parser_id" => parser_id,
            "top_rule" => top_rule,
            "source_id" => span.source_id,
            "span" => "$(span.start):$(span.stop)",
            "active_span" => "$(active.start):$(active.stop)",
        )
    end
    return nothing
end

function _effective_authority(
    entry::ProgressiveRegistryEntry,
    arguments::ProgressiveDispatchArguments,
    origin::String,
)
    caller = Set(arguments.caller_capabilities)
    capabilities = sort!(unique(String[
        capability for capability in entry.capabilities if capability in caller
    ]))
    for required in arguments.required_capabilities
        required in capabilities || _throw_dispatch(
            "progressive_capability_denied",
            "origin" => origin,
            "parser_id" => entry.parser_id,
            "capability" => required,
        )
    end
    entry_modes = Set(entry.ceilings.policy_modes)
    policy_modes = sort!(unique(String[
        mode for mode in arguments.caller_ceilings.policy_modes if mode in entry_modes
    ]))
    isempty(policy_modes) && _throw_dispatch(
        "progressive_policy_denied",
        "origin" => origin,
        "parser_id" => entry.parser_id,
        "policy" => join(arguments.caller_ceilings.policy_modes, ","),
    )
    source_detail = ProgressiveSourceDetail(
        min(
            Int(arguments.caller_ceilings.source_detail),
            Int(entry.ceilings.source_detail),
        ),
    )
    Int(source_detail) >= Int(arguments.required_source_detail) || _throw_dispatch(
        "progressive_source_detail_denied",
        "origin" => origin,
        "required" => source_detail_name(arguments.required_source_detail),
        "effective" => source_detail_name(source_detail),
    )
    return ProgressiveEffectiveAuthority(
        Tuple(capabilities),
        source_detail,
        Tuple(policy_modes),
        min(arguments.caller_ceilings.max_steps, entry.ceilings.max_steps),
        min(
            arguments.caller_ceilings.max_result_nodes,
            entry.ceilings.max_result_nodes,
        ),
        min(
            arguments.caller_ceilings.max_diagnostic_bytes,
            entry.ceilings.max_diagnostic_bytes,
        ),
    )
end

function _parse_span(value, origin::String)
    value isa AbstractDict || _throw_dispatch(
        "progressive_span_binding_required",
        "origin" => origin,
        "operand" => _diagnostic_operand(value),
    )
    fields = sort!(String[string(key) for key in keys(value)])
    expected = ["end", "provenance", "source_id", "start"]
    source_id = get(value, "source_id", nothing)
    start = get(value, "start", nothing)
    stop = get(value, "end", nothing)
    provenance = get(value, "provenance", nothing)
    valid = fields == expected &&
        source_id isa AbstractString &&
        !isempty(source_id) &&
        start isa Integer &&
        !(start isa Bool) &&
        start >= 0 &&
        stop isa Integer &&
        !(stop isa Bool) &&
        stop >= 0 &&
        provenance isa AbstractString &&
        !isempty(provenance)
    valid || _throw_dispatch(
        "progressive_span_shape_invalid",
        "origin" => origin,
        "fields" => join(fields, ","),
    )
    return _NeutralSpan(
        String(source_id),
        Int(start),
        Int(stop),
        String(provenance),
    )
end

function _detach_result(
    value,
    parser_id::String,
    origin::String,
    maximum::Int,
)
    nodes = Ref(0)
    active = IdDict{Any,Nothing}()

    function visit(current, path::String)
        nodes[] += 1
        nodes[] <= maximum || _throw_result_not_detached(origin, parser_id, path)
        if current === nothing ||
                current isa Bool ||
                _is_plain_number(current) ||
                current isa AbstractString
            return current isa AbstractString ? _copy_string(current) : current
        end
        if current isa AbstractVector
            haskey(active, current) && _throw_result_not_detached(
                origin,
                parser_id,
                path,
            )
            active[current] = nothing
            try
                return Any[
                    visit(item, "$(path)/$(index - 1)")
                    for (index, item) in enumerate(current)
                ]
            finally
                delete!(active, current)
            end
        end
        if current isa AbstractDict
            haskey(active, current) && _throw_result_not_detached(
                origin,
                parser_id,
                path,
            )
            active[current] = nothing
            try
                copy = Dict{String,Any}()
                for (key, item) in pairs(current)
                    key isa AbstractString || _throw_result_not_detached(
                        origin,
                        parser_id,
                        path,
                    )
                    owned_key = String(key)
                    lowered = lowercase(owned_key)
                    any(token -> occursin(token, lowered), _LIVE_RESULT_FIELD_TOKENS) &&
                        _throw_result_not_detached(
                            origin,
                            parser_id,
                            "$(path)/$(owned_key)",
                        )
                    copy[owned_key] = visit(item, "$(path)/$(owned_key)")
                end
                return copy
            finally
                delete!(active, current)
            end
        end
        _throw_result_not_detached(origin, parser_id, path)
    end

    return visit(value, "<result>")
end

function _detach_diagnostic_value(value)
    if value === nothing || value isa Bool || _is_plain_number(value)
        return value
    end
    value isa AbstractString && return _copy_string(value)
    value isa AbstractVector && return Any[
        _detach_diagnostic_value(item) for item in value
    ]
    if value isa AbstractDict
        copy = Dict{String,Any}()
        for (key, item) in pairs(value)
            key isa AbstractString || throw(
                ProgressiveSourceViewException(
                    "diagnostic keys must be strings",
                ),
            )
            copy[String(key)] = _detach_diagnostic_value(item)
        end
        return copy
    end
    throw(
        ProgressiveSourceViewException(
            "diagnostic contains non-detached data",
        ),
    )
end

function _find_entry(registry::ProgressiveRegistry, parser_id::String)
    for entry in registry._entries
        entry.parser_id == parser_id && return entry
    end
    return nothing
end

function _literal_string(value, origin::String, code::String)
    value isa AbstractString && !isempty(value) && return String(value)
    _throw_dispatch(
        code,
        "origin" => origin,
        "operand" => _diagnostic_operand(value),
    )
end

function _throw_source_mismatch(origin::String, expected::String, actual::String)
    _throw_dispatch(
        "progressive_span_source_mismatch",
        "origin" => origin,
        "expected_source_id" => expected,
        "actual_source_id" => actual,
    )
end

function _throw_out_of_bounds(
    origin::String,
    source_id::String,
    start::Int,
    stop::Int,
    source_length::Int,
)
    _throw_dispatch(
        "progressive_span_out_of_bounds",
        "origin" => origin,
        "source_id" => source_id,
        "start" => start,
        "end" => stop,
        "source_length" => source_length,
    )
end

function _throw_reversed(origin::String, span::_NeutralSpan)
    _throw_dispatch(
        "progressive_span_reversed",
        "origin" => origin,
        "source_id" => span.source_id,
        "start" => span.start,
        "end" => span.stop,
    )
end

function _throw_child_failed(
    origin::String,
    parser_id::String,
    top_rule::String,
    span::_NeutralSpan,
    diagnostic::String,
    byte_ceiling::Int,
)
    bounded = _truncate_utf8(diagnostic, byte_ceiling)
    isempty(bounded) && (bounded = "?")
    _throw_dispatch(
        "progressive_child_failed",
        "origin" => origin,
        "parser_id" => parser_id,
        "top_rule" => top_rule,
        "source_id" => span.source_id,
        "span" => "$(span.start):$(span.stop)",
        "child_diagnostic" => bounded,
    )
end

function _throw_result_not_detached(
    origin::String,
    parser_id::String,
    field::String,
)
    _throw_dispatch(
        "progressive_result_not_detached",
        "origin" => origin,
        "parser_id" => parser_id,
        "field" => field,
    )
end

function _throw_dispatch(code::String, fields::Pair{String}...)
    record = Pair{String,Any}["code" => code]
    append!(record, Pair{String,Any}[field.first => field.second for field in fields])
    throw(ProgressiveDispatchException(Tuple(record)))
end

function _diagnostic_operand(value)
    value === nothing && return "<missing>"
    value isa AbstractString && return String(value)
    value isa Bool && return string(value)
    value isa Number && return string(value)
    return "<aggregate>"
end

function _truncate_utf8(value::String, maximum::Int)
    ncodeunits(value) <= maximum && return value
    buffer = IOBuffer()
    bytes = 0
    for scalar in value
        rendered = string(scalar)
        width = ncodeunits(rendered)
        bytes + width > maximum && break
        print(buffer, rendered)
        bytes += width
    end
    return String(take!(buffer))
end

function _validated_strings(values, context::String; allow_empty::Bool = false)
    owned = Tuple(String(value) for value in values)
    (!isempty(owned) || allow_empty) &&
        all(!isempty, owned) || throw(
            ProgressiveConfigurationException(
                "$(context) must be $(allow_empty ? "strings" : "nonempty strings")",
            ),
        )
    length(unique(owned)) == length(owned) || throw(
        ProgressiveConfigurationException("$(context) must be duplicate-free"),
    )
    return owned
end

_valid_parser_id(value::String) =
    occursin(r"^[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*$", value)
_valid_top_rule(value::String) =
    occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", value)
_valid_fingerprint(value::String) =
    occursin(r"^sha256:[0-9a-f]{64}$", value)

_is_offset_field(key::String) = key == "offset" ||
    key == "start" ||
    key == "end" ||
    endswith(key, "_offset") ||
    endswith(key, "_start") ||
    endswith(key, "_end")

_copy_string(value::AbstractString) =
    String(Vector{UInt8}(codeunits(String(value))))

_is_plain_number(value) = value isa Integer ||
    (value isa AbstractFloat && isfinite(value))

function _copy_plain_value(value)
    if value === nothing || value isa Bool || _is_plain_number(value)
        return value
    end
    value isa AbstractString && return _copy_string(value)
    value isa Tuple && return Any[_copy_plain_value(item) for item in value]
    value isa AbstractVector && return Any[_copy_plain_value(item) for item in value]
    value isa AbstractDict && return Dict{String,Any}(
        string(key) => _copy_plain_value(item) for (key, item) in pairs(value)
    )
    return string(value)
end

end
