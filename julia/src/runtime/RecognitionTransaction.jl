module RecognitionTransaction

import ..SourceLocation

const _TOKEN_EXPECTED_CODE = "recognition_token_expected"
const _TOKEN_ESCAPE_CODE = "recognition_token_escape"
const _TOKEN_REUSED_CODE = "recognition_token_reused"
const _NESTING_FORBIDDEN_CODE = "recognition_nesting_forbidden"
const _CROSS_INVOCATION_CODE = "recognition_cross_invocation"
const _CROSS_SOURCE_CODE = "recognition_cross_source"
const _ATTEMPT_COUNT_CODE = "recognition_attempt_count"
const _TERMINAL_REQUIRED_CODE = "recognition_terminal_required"
const _EFFECT_FORBIDDEN_CODE = "recognition_effect_forbidden"
const _UNKNOWN_EFFECT_CODE = "recognition_unknown_effect"
const _ZERO_PROGRESS_REPETITION_CODE = "recognition_zero_progress_repetition"
const _ZERO_PROGRESS_RECURSIVE_CYCLE_CODE =
    "recognition_zero_progress_recursive_cycle"
const _MARK_GENERATION_INVALID_CODE = "recognition_mark_generation_invalid"
const _NEXT_AUTHORITY_ID = Base.Threads.Atomic{UInt64}(0)

const _ALLOWED_EFFECTS = Set{String}([
    "pure_value",
    "source_read",
    "structured_control",
    "rule_recognition",
    "transaction_state",
    "cursor_advance",
    "capture_boundary_write",
    "invocation_mark_write",
    "staged_return",
])

const _REJECTED_EFFECTS = Set{String}([
    "binding_write",
    "aggregate_write",
    "ast_or_object_write",
    "compatibility_cursor_control",
    "output",
    "authored_diagnostic",
    "exit_or_unbounded_control",
    "dynamic_callable",
    "parser_registry_or_staged_dispatch",
    "external_or_host",
    "unknown_or_raw",
])

"""Detached cursor, anonymous-boundary, and invocation-local mark state."""
struct RecognitionFrameState
    _cursor::Int
    _boundary::Union{Nothing,Int}
    _marks::Tuple{Vararg{Pair{String,Int}}}

    function RecognitionFrameState(
        ::Val{:internal},
        cursor::Int,
        boundary::Union{Nothing,Int},
        marks::Tuple{Vararg{Pair{String,Int}}},
    )
        return new(cursor, boundary, marks)
    end
end

function RecognitionFrameState(;
    cursor::Int,
    boundary::Union{Nothing,Int},
    marks::AbstractDict,
)
    owned_marks = Pair{String,Int}[
        String(name) => Int(offset) for (name, offset) in pairs(marks)
    ]
    sort!(owned_marks; by = first)
    return RecognitionFrameState(
        Val(:internal),
        cursor,
        boundary,
        Tuple(owned_marks),
    )
end

function _copy_state(state::RecognitionFrameState)
    return RecognitionFrameState(
        Val(:internal),
        state._cursor,
        state._boundary,
        Tuple(String(mark.first) => Int(mark.second) for mark in state._marks),
    )
end

function _state_to_json(state::RecognitionFrameState)
    return Dict{String,Any}(
        "cursor" => state._cursor,
        "boundary" => state._boundary,
        "marks" => Dict{String,Int}(
            mark.first => mark.second for mark in state._marks
        ),
    )
end

"""Detached observation of one live recognition invocation."""
struct RecognitionFrameSnapshot
    _source::String
    _rule::String
    _invocation::UInt64
    _generation::UInt64
    _state::RecognitionFrameState

    function RecognitionFrameSnapshot(
        ::Val{:internal},
        source::String,
        rule::String,
        invocation::UInt64,
        generation::UInt64,
        state::RecognitionFrameState,
    )
        return new(
            source,
            rule,
            invocation,
            generation,
            _copy_state(state),
        )
    end
end

"""Portable private recognition-transaction diagnostic."""
struct RecognitionTransactionException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}

    function RecognitionTransactionException(
        ::Val{:internal},
        record::Tuple{Vararg{Pair{String,Any}}},
    )
        return new(record)
    end
end

Base.showerror(io::IO, error::RecognitionTransactionException) = print(
    io,
    "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:",
    first(error._record).second,
)

function _error(code::AbstractString, fields::Pair...)
    record = Pair{String,Any}["code" => String(code)]
    for field in fields
        push!(record, String(field.first) => field.second)
    end
    return RecognitionTransactionException(Val(:internal), Tuple(record))
end

@enum _TransactionStatus begin
    _ActiveUnattempted
    _ActiveStagedMatch
    _ActiveStagedMiss
    _Invalidated
end

"""Detached structural identity carried into one selected action-edge child."""
struct RecognitionGapEntrySlot
    owner_invocation_id::UInt64
    target_rule::String
    regex_index::Int
    slot_id::Union{Nothing,String}
    selector_kind::String
    authored_selector::Any
end

"""Code-unit-rooted private gap candidate projected through SourceAuthority."""
struct RecognitionGapContext
    source_id::String
    rule_label::String
    invocation_id::UInt64
    edge_ordinal::Int
    kind::String
    start_codeunit::Int
    end_codeunit::Int
end

"""Private typed diagnostic for a gap read without a live candidate or tail."""
struct InterMatchGapException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}
end

Base.showerror(io::IO, error::InterMatchGapException) = print(
    io,
    "LINKEDSPEC_INTER_MATCH_GAP_ERROR:",
    first(error._record).second,
)

"""Private typed diagnostic for a cursor that regresses before gap commit."""
struct GapCursorRegressionException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}
end

Base.showerror(io::IO, error::GapCursorRegressionException) = print(
    io,
    "LINKEDSPEC_SOURCE_LOCATION_ERROR:",
    first(error._record).second,
)

mutable struct _GapMutableState
    committed_gap_cursor::Int
    accepted_edge_count::Int
    current_gap::Union{Nothing,RecognitionGapContext}
end

_copy_gap_state(state::_GapMutableState) = _GapMutableState(
    state.committed_gap_cursor,
    state.accepted_edge_count,
    state.current_gap,
)

mutable struct _InvocationState
    authority_id::UInt64
    source_authority::SourceLocation.SourceAuthority
    source_identity::String
    rule::String
    origin::String
    invocation::UInt64
    parent_invocation::Union{Nothing,UInt64}
    generation::UInt64
    active::Bool
    frame_state::RecognitionFrameState
    gap_state::Union{Nothing,_GapMutableState}
    gap_phase::String
    entry_slot::Union{Nothing,RecognitionGapEntrySlot}
    active_token::Any
end

mutable struct _TransactionState
    authority_id::UInt64
    source_authority::SourceLocation.SourceAuthority
    source_identity::String
    rule::String
    origin::String
    invocation::UInt64
    generation::UInt64
    transaction::UInt64
    snapshot::RecognitionFrameState
    gap_snapshot::Union{Nothing,_GapMutableState}
    frame::_InvocationState
    status::_TransactionStatus
    attempt_count::Int
    matched::Bool
    payload::Any
end

struct _RecognitionInvocationFrame
    _state::_InvocationState
end

struct _RecognitionTransactionToken
    _state::_TransactionState
end

"""Detached lineage for one entered or pre-entry-rejected invocation."""
struct RecognitionInvocationIdentity
    rule::String
    invocation_id::UInt64
    parent_invocation_id::Union{Nothing,UInt64}
end

Base.show(io::IO, ::_RecognitionInvocationFrame) =
    print(io, "RecognitionInvocationFrame(<opaque>)")
Base.show(io::IO, ::_RecognitionTransactionToken) =
    print(io, "RecognitionTransactionToken(<opaque>)")

"""Source-local owner of monotonic invocation, mark, and token generations."""
mutable struct RecognitionTransactionAuthority
    _authority_id::UInt64
    _source_authority::SourceLocation.SourceAuthority
    _source_identity::String
    _next_invocation::UInt64
    _next_generation::UInt64
    _next_transaction::UInt64
    _invocation_stack::Vector{_InvocationState}

    function RecognitionTransactionAuthority(
        ::Val{:internal},
        authority_id::UInt64,
        source_authority::SourceLocation.SourceAuthority,
        source_identity::String,
    )
        return new(
            authority_id,
            source_authority,
            source_identity,
            UInt64(1),
            UInt64(1),
            UInt64(1),
            _InvocationState[],
        )
    end
end

function RecognitionTransactionAuthority(;
    source_authority::SourceLocation.SourceAuthority,
    source_identity::AbstractString,
)
    return RecognitionTransactionAuthority(
        Val(:internal),
        _claim_authority_id(),
        source_authority,
        String(source_identity),
    )
end

function _claim_authority_id()
    while true
        previous = _NEXT_AUTHORITY_ID[]
        previous == typemax(UInt64) &&
            error("recognition authority identity space exhausted")
        next_id = previous + UInt64(1)
        Base.Threads.atomic_cas!(_NEXT_AUTHORITY_ID, previous, next_id) == previous &&
            return next_id
    end
end

function _claim_generation!(authority::RecognitionTransactionAuthority, field::Symbol)
    value = getfield(authority, field)
    value == typemax(UInt64) &&
        error("recognition transaction generation space exhausted")
    setfield!(authority, field, value + UInt64(1))
    return value
end

"""Enter one independent rule invocation with fresh opaque generations."""
function enter_invocation(
    authority::RecognitionTransactionAuthority;
    rule::AbstractString,
    origin::AbstractString,
    state::RecognitionFrameState,
    capture_gaps::Bool = false,
    entry_slot::Union{Nothing,RecognitionGapEntrySlot} = nothing,
)
    parent_invocation = isempty(authority._invocation_stack) ?
        nothing : authority._invocation_stack[end].invocation
    invocation = _claim_generation!(authority, :_next_invocation)
    generation = _claim_generation!(authority, :_next_generation)
    parent = isempty(authority._invocation_stack) ? nothing : authority._invocation_stack[end]
    accepted_entry_slot = if entry_slot !== nothing &&
            parent !== nothing &&
            parent.invocation == entry_slot.owner_invocation_id &&
            parent.gap_state !== nothing &&
            parent.gap_state.current_gap !== nothing &&
            entry_slot.target_rule == String(rule)
        entry_slot
    else
        nothing
    end
    frame = _InvocationState(
        authority._authority_id,
        authority._source_authority,
        authority._source_identity,
        String(rule),
        String(origin),
        invocation,
        parent_invocation,
        generation,
        true,
        _copy_state(state),
        capture_gaps ? _GapMutableState(state._cursor, 0, nothing) : nothing,
        "I",
        accepted_entry_slot,
        nothing,
    )
    push!(authority._invocation_stack, frame)
    return _RecognitionInvocationFrame(frame)
end

"""Return detached lineage for one live invocation frame."""
function invocation_identity(authority::RecognitionTransactionAuthority, frame)
    state = _frame_for_authority(authority, frame)
    return RecognitionInvocationIdentity(
        state.rule,
        state.invocation,
        state.parent_invocation,
    )
end

"""Reserve monotonic lineage for a recursion rejected before frame entry."""
function reserve_rejected_invocation!(
    authority::RecognitionTransactionAuthority,
    rule::AbstractString,
)
    parent_invocation = isempty(authority._invocation_stack) ?
        nothing : authority._invocation_stack[end].invocation
    return RecognitionInvocationIdentity(
        String(rule),
        _claim_generation!(authority, :_next_invocation),
        parent_invocation,
    )
end

function _frame_for_authority(
    authority::RecognitionTransactionAuthority,
    frame,
)
    frame isa _RecognitionInvocationFrame ||
        throw(ArgumentError("frame must be an opaque recognition invocation frame"))
    state = frame._state
    if state.authority_id != authority._authority_id || !state.active
        throw(
            _error(
                _MARK_GENERATION_INVALID_CODE,
                "rule" => state.rule,
                "origin" => state.origin,
                "generation" => state.generation,
            ),
        )
    end
    return state
end

"""Return a detached neutral observation of one live frame."""
function frame_snapshot(authority::RecognitionTransactionAuthority, frame)
    state = _frame_for_authority(authority, frame)
    return RecognitionFrameSnapshot(
        Val(:internal),
        state.source_identity,
        state.rule,
        state.invocation,
        state.generation,
        state.frame_state,
    )
end

"""Return a detached copy of one live backend frame state."""
function frame_state(authority::RecognitionTransactionAuthority, frame)
    return _copy_state(_frame_for_authority(authority, frame).frame_state)
end

state_cursor(state::RecognitionFrameState) = state._cursor
state_boundary(state::RecognitionFrameState) = state._boundary
state_marks(state::RecognitionFrameState) =
    Dict{String,Int}(mark.first => mark.second for mark in state._marks)

"""Synchronize one live frame from the backend's native registers."""
function set_frame_state!(
    authority::RecognitionTransactionAuthority,
    frame,
    state::RecognitionFrameState,
)
    _frame_for_authority(authority, frame).frame_state = _copy_state(state)
    return nothing
end

"""Report that a dedicated transaction node did not resolve its token slot."""
function reject_missing_token(
    authority::RecognitionTransactionAuthority,
    frame,
    origin::AbstractString,
)
    state = _frame_for_authority(authority, frame)
    throw(
        _error(
            _TOKEN_EXPECTED_CODE,
            "rule" => state.rule,
            "origin" => String(origin),
        ),
    )
end

"""Write one invocation-local named mark."""
function write_mark!(
    authority::RecognitionTransactionAuthority,
    frame,
    name::AbstractString,
    offset::Int,
)
    state = _frame_for_authority(authority, frame)
    marks = Dict{String,Int}(mark.first => mark.second for mark in state.frame_state._marks)
    marks[String(name)] = offset
    state.frame_state = RecognitionFrameState(
        cursor = state.frame_state._cursor,
        boundary = state.frame_state._boundary,
        marks = marks,
    )
    return offset
end

"""Read one invocation-local named mark."""
function read_mark(
    authority::RecognitionTransactionAuthority,
    frame,
    name::AbstractString,
)
    state = _frame_for_authority(authority, frame)
    name_string = String(name)
    for mark in state.frame_state._marks
        mark.first == name_string && return mark.second
    end
    return nothing
end

"""Record the exact private lifecycle phase for typed gap diagnostics."""
function set_gap_phase!(authority::RecognitionTransactionAuthority, frame, phase::AbstractString)
    _frame_for_authority(authority, frame).gap_phase = String(phase)
    return nothing
end

"""Install one prefix/interstitial candidate before capture-enabled LS."""
function install_gap_candidate!(
    authority::RecognitionTransactionAuthority,
    frame,
    match_start_codeunit::Int,
)
    state = _frame_for_authority(authority, frame)
    gap = state.gap_state
    gap === nothing && return nothing
    gap.current_gap = RecognitionGapContext(
        state.source_identity,
        state.rule,
        state.invocation,
        gap.accepted_edge_count,
        gap.accepted_edge_count == 0 ? "prefix" : "interstitial",
        gap.committed_gap_cursor,
        match_start_codeunit,
    )
    state.gap_phase = "selection"
    return nothing
end

"""Commit one accepted edge after LE and clear its candidate before IT."""
function commit_gap_candidate!(
    authority::RecognitionTransactionAuthority,
    frame;
    cursor_codeunit::Int,
    selected_end_codeunit::Int,
)
    state = _frame_for_authority(authority, frame)
    gap = state.gap_state
    current = gap === nothing ? nothing : gap.current_gap
    (gap === nothing || current === nothing) && return nothing
    if cursor_codeunit < selected_end_codeunit
        throw(GapCursorRegressionException((
            "code" => "source_location_cursor_regression",
            "phase" => "advance",
            "rule_role" => state.rule,
            "invocation_role" => "gap_owner",
            "source_id" => current.source_id,
            "start_offset" => selected_end_codeunit,
            "end_offset" => cursor_codeunit,
            "originating_edge_or_job" => "$(state.rule):capture_gaps_commit",
        )))
    end
    gap.committed_gap_cursor = cursor_codeunit
    gap.accepted_edge_count += 1
    gap.current_gap = nothing
    state.gap_phase = "post_commit"
    return nothing
end

"""Install a successful terminal tail without moving the parse cursor."""
function install_gap_tail!(
    authority::RecognitionTransactionAuthority,
    frame,
    input_end_codeunit::Int,
    phase::AbstractString,
)
    state = _frame_for_authority(authority, frame)
    gap = state.gap_state
    gap === nothing && return nothing
    gap.current_gap = RecognitionGapContext(
        state.source_identity,
        state.rule,
        state.invocation,
        gap.accepted_edge_count,
        "tail",
        gap.committed_gap_cursor,
        input_end_codeunit,
    )
    state.gap_phase = String(phase)
    return nothing
end

"""Return the live candidate/tail or the exact typed private diagnostic."""
function current_gap(
    authority::RecognitionTransactionAuthority,
    frame,
    accessor::AbstractString,
)
    state = _frame_for_authority(authority, frame)
    current = state.gap_state === nothing ? nothing : state.gap_state.current_gap
    current !== nothing && return current
    throw(InterMatchGapException((
        "code" => "gap_capture_context_unavailable",
        "rule_label" => state.rule,
        "source_id" => state.source_identity,
        "invocation_id" => state.invocation,
        "phase" => state.gap_phase,
        "accessor" => String(accessor),
    )))
end

"""Return a fresh detached action-edge entry identity, or nothing directly."""
function entry_slot(authority::RecognitionTransactionAuthority, frame)
    slot = _frame_for_authority(authority, frame).entry_slot
    slot === nothing && return nothing
    return Dict{String,Any}(
        "target_rule" => slot.target_rule,
        "regex_index" => slot.regex_index,
        "slot_id" => slot.slot_id,
        "selector_kind" => slot.selector_kind,
        "authored_selector" => deepcopy(slot.authored_selector),
    )
end

"""Create a child entry identity only while the owning candidate is live."""
function gap_entry_slot(
    authority::RecognitionTransactionAuthority,
    frame;
    target_rule::AbstractString,
    regex_index::Int,
    slot_id,
    selector_kind::AbstractString,
    authored_selector,
)
    state = _frame_for_authority(authority, frame)
    (state.gap_state === nothing || state.gap_state.current_gap === nothing) && return nothing
    return RecognitionGapEntrySlot(
        state.invocation,
        String(target_rule),
        regex_index,
        slot_id === nothing ? nothing : String(slot_id),
        String(selector_kind),
        deepcopy(authored_selector),
    )
end

_token_is_active(token::_TransactionState) = token.status != _Invalidated

function _restore_and_invalidate!(token::_TransactionState)
    _token_is_active(token) || return nothing
    frame = token.frame
    if frame.active
        frame.frame_state = _copy_state(token.snapshot)
        frame.gap_state = token.gap_snapshot === nothing ?
            nothing : _copy_gap_state(token.gap_snapshot)
    end
    frame.active_token === token && (frame.active_token = nothing)
    token.status = _Invalidated
    token.matched = false
    token.payload = nothing
    return nothing
end

function _invalidate!(token::_TransactionState)
    _token_is_active(token) || return nothing
    frame = token.frame
    frame.active_token === token && (frame.active_token = nothing)
    token.status = _Invalidated
    token.matched = false
    token.payload = nothing
    return nothing
end

"""Create one linear token over the current frame state."""
function checkpoint(
    authority::RecognitionTransactionAuthority,
    frame,
    origin::AbstractString,
)
    frame_state = _frame_for_authority(authority, frame)
    for stacked_frame in authority._invocation_stack
        active_token = stacked_frame.active_token
        if active_token isa _TransactionState && _token_is_active(active_token)
            _restore_and_invalidate!(active_token)
            throw(
                _error(
                    _NESTING_FORBIDDEN_CODE,
                    "rule" => frame_state.rule,
                    "origin" => String(origin),
                ),
            )
        end
    end

    token = _TransactionState(
        authority._authority_id,
        authority._source_authority,
        authority._source_identity,
        frame_state.rule,
        String(origin),
        frame_state.invocation,
        frame_state.generation,
        _claim_generation!(authority, :_next_transaction),
        _copy_state(frame_state.frame_state),
        frame_state.gap_state === nothing ?
            nothing : _copy_gap_state(frame_state.gap_state),
        frame_state,
        _ActiveUnattempted,
        0,
        false,
        nothing,
    )
    frame_state.active_token = token
    return _RecognitionTransactionToken(token)
end

function _token_for_operation(
    authority::RecognitionTransactionAuthority,
    frame::_InvocationState,
    token,
    operation::AbstractString,
)
    if !(token isa _RecognitionTransactionToken)
        throw(
            _error(
                _TOKEN_EXPECTED_CODE,
                "rule" => frame.rule,
                "origin" => frame.origin,
            ),
        )
    end
    state = token._state

    if frame.source_authority !== state.source_authority
        _restore_and_invalidate!(state)
        throw(
            _error(
                _CROSS_SOURCE_CODE,
                "rule" => frame.rule,
                "origin" => frame.origin,
                "expected_source" => frame.source_identity,
                "actual_source" => state.source_identity,
            ),
        )
    end

    if frame.authority_id != state.authority_id ||
            frame.invocation != state.invocation
        _restore_and_invalidate!(state)
        throw(
            _error(
                _CROSS_INVOCATION_CODE,
                "rule" => frame.rule,
                "origin" => frame.origin,
                "expected_invocation" => frame.invocation,
                "actual_invocation" => state.invocation,
            ),
        )
    end

    if !frame.active || frame.generation != state.generation
        _restore_and_invalidate!(state)
        throw(
            _error(
                _MARK_GENERATION_INVALID_CODE,
                "rule" => frame.rule,
                "origin" => frame.origin,
                "generation" => state.generation,
            ),
        )
    end

    if !_token_is_active(state)
        throw(
            _error(
                _TOKEN_REUSED_CODE,
                "rule" => state.rule,
                "origin" => state.origin,
                "operation" => String(operation),
            ),
        )
    end
    return state
end

"""Perform the token's one allowed attempt and stage its frame state."""
function attempt!(
    authority::RecognitionTransactionAuthority,
    frame,
    token;
    matched::Bool,
    payload,
    state::RecognitionFrameState,
)
    frame_state = _frame_for_authority(authority, frame)
    token_state = _token_for_operation(authority, frame_state, token, "attempt")
    if token_state.status != _ActiveUnattempted
        count = token_state.attempt_count + 1
        rule = token_state.rule
        origin = token_state.origin
        _restore_and_invalidate!(token_state)
        throw(
            _error(
                _ATTEMPT_COUNT_CODE,
                "rule" => rule,
                "origin" => origin,
                "count" => count,
            ),
        )
    end

    frame_state.frame_state = _copy_state(state)
    token_state.attempt_count = 1
    token_state.matched = matched
    token_state.payload = matched ? payload : nothing
    token_state.status = matched ? _ActiveStagedMatch : _ActiveStagedMiss
    return matched
end

function _require_attempted!(token::_TransactionState)
    token.status in (_ActiveStagedMatch, _ActiveStagedMiss) && return nothing
    count = token.attempt_count
    rule = token.rule
    origin = token.origin
    _restore_and_invalidate!(token)
    throw(
        _error(
            _ATTEMPT_COUNT_CODE,
            "rule" => rule,
            "origin" => origin,
            "count" => count,
        ),
    )
end

"""Invalidate one attempted token while retaining its staged frame state."""
function commit!(authority::RecognitionTransactionAuthority, frame, token)
    frame_state = _frame_for_authority(authority, frame)
    token_state = _token_for_operation(authority, frame_state, token, "commit")
    _require_attempted!(token_state)
    payload = token_state.matched ? token_state.payload : nothing
    _invalidate!(token_state)
    return payload
end

"""Restore one attempted token's snapshot, then invalidate it."""
function rollback!(authority::RecognitionTransactionAuthority, frame, token)
    frame_state = _frame_for_authority(authority, frame)
    token_state = _token_for_operation(authority, frame_state, token, "rollback")
    _require_attempted!(token_state)
    _restore_and_invalidate!(token_state)
    return nothing
end

"""Reject any attempt to make a token escape its authored linear slot."""
function reject_escape(
    authority::RecognitionTransactionAuthority,
    frame,
    token,
    escape::AbstractString,
)
    frame_state = _frame_for_authority(authority, frame)
    token_state = _token_for_operation(authority, frame_state, token, "escape")
    rule = token_state.rule
    origin = token_state.origin
    _restore_and_invalidate!(token_state)
    throw(
        _error(
            _TOKEN_ESCAPE_CODE,
            "rule" => rule,
            "origin" => origin,
            "escape" => String(escape),
        ),
    )
end

"""Explicitly restore and invalidate an abandoned opaque token."""
function discard_token!(authority::RecognitionTransactionAuthority, frame, token)
    frame_state = _frame_for_authority(authority, frame)
    token_state = _token_for_operation(authority, frame_state, token, "discard")
    _restore_and_invalidate!(token_state)
    return nothing
end

function _effect_error(code::String, rule::String, effect::String)
    return _error(
        code,
        "rule" => rule,
        "origin" => "$rule:recognize_once",
        "effect" => effect,
    )
end

"""Classify one neutral recognition-effect graph by recursive fixed point."""
function classify_effects(
    ::RecognitionTransactionAuthority,
    graph::AbstractDict,
)
    entry = get(graph, "entry", "<entry>")
    entry_name = entry isa AbstractString ? String(entry) : "<entry>"
    raw_rules = get(graph, "rules", nothing)
    raw_rules isa AbstractDict ||
        throw(_effect_error(_UNKNOWN_EFFECT_CODE, entry_name, "unknown_or_raw"))

    effects = Dict{String,Set{String}}()
    calls = Dict{String,Vector{String}}()
    for (raw_rule, raw_row) in pairs(raw_rules)
        raw_rule isa AbstractString ||
            throw(_effect_error(_UNKNOWN_EFFECT_CODE, entry_name, "unknown_or_raw"))
        rule = String(raw_rule)
        raw_row isa AbstractDict ||
            throw(_effect_error(_UNKNOWN_EFFECT_CODE, rule, "unknown_or_raw"))
        raw_base = get(raw_row, "base", nothing)
        raw_calls = get(raw_row, "calls", nothing)
        if !(raw_base isa AbstractVector) || !(raw_calls isa AbstractVector)
            throw(_effect_error(_UNKNOWN_EFFECT_CODE, rule, "unknown_or_raw"))
        end

        rule_effects = Set{String}()
        for raw_effect in raw_base
            effect = raw_effect isa AbstractString ? String(raw_effect) : "unknown_or_raw"
            if !(effect in _ALLOWED_EFFECTS) && !(effect in _REJECTED_EFFECTS)
                throw(_effect_error(_UNKNOWN_EFFECT_CODE, rule, effect))
            end
            push!(rule_effects, effect)
        end
        effects[rule] = rule_effects
        calls[rule] = String[
            raw_callee isa AbstractString ? String(raw_callee) : "<dynamic>"
            for raw_callee in raw_calls
        ]
    end

    changed = true
    while changed
        changed = false
        for (rule, callees) in pairs(calls)
            target = effects[rule]
            before = length(target)
            for callee in callees
                union!(target, get(effects, callee, Set(["unknown_or_raw"])))
            end
            changed |= length(target) != before
        end
    end

    entry_effects = get(effects, entry_name, nothing)
    entry_effects === nothing &&
        throw(_effect_error(_UNKNOWN_EFFECT_CODE, entry_name, "unknown_or_raw"))
    forbidden = sort!(collect(intersect(entry_effects, _REJECTED_EFFECTS)))
    if !isempty(forbidden)
        effect = first(forbidden)
        code = effect == "unknown_or_raw" ? _UNKNOWN_EFFECT_CODE : _EFFECT_FORBIDDEN_CODE
        throw(_effect_error(code, entry_name, effect))
    end
    return nothing
end

function _progress_offset(value)
    if !(value isa Integer) || value isa Bool
        return 0
    end
    return try
        Int(value)
    catch
        0
    end
end

"""Enforce cursor-only progress for accepted repetition and recursion edges."""
function validate_progress(
    ::RecognitionTransactionAuthority,
    fixture::AbstractDict,
)
    context_value = get(fixture, "context", "unknown")
    context = context_value isa AbstractString ? String(context_value) : "unknown"
    start_value = get(fixture, "start", 0)
    end_value = get(fixture, "end", 0)
    start_offset = _progress_offset(start_value)
    end_offset = _progress_offset(end_value)
    if end_offset > start_offset || context == "one_shot"
        return nothing
    end

    rule_value = get(fixture, "id", "<rule>")
    rule = rule_value isa AbstractString ? String(rule_value) : "<rule>"
    recursive = context != "accepted_repetition_iteration"
    if recursive
        throw(
            _error(
                _ZERO_PROGRESS_RECURSIVE_CYCLE_CODE,
                "rule" => rule,
                "origin" => "$rule:recognize_once",
                "cycle" => context,
                "start_offset" => start_offset,
                "end_offset" => end_offset,
            ),
        )
    end
    throw(
        _error(
            _ZERO_PROGRESS_REPETITION_CODE,
            "rule" => rule,
            "origin" => "$rule:recognize_once",
            "start_offset" => start_offset,
            "end_offset" => end_offset,
        ),
    )
end

"""Leave the most recently entered invocation."""
function leave_invocation!(authority::RecognitionTransactionAuthority, frame)
    frame_state = _frame_for_authority(authority, frame)
    if isempty(authority._invocation_stack) ||
            authority._invocation_stack[end] !== frame_state
        expected_invocation = isempty(authority._invocation_stack) ?
            frame_state.invocation : authority._invocation_stack[end].invocation
        throw(
            _error(
                _CROSS_INVOCATION_CODE,
                "rule" => frame_state.rule,
                "origin" => frame_state.origin,
                "expected_invocation" => expected_invocation,
                "actual_invocation" => frame_state.invocation,
            ),
        )
    end

    active_token = frame_state.active_token
    if active_token isa _TransactionState && _token_is_active(active_token)
        rule = active_token.rule
        origin = active_token.origin
        _restore_and_invalidate!(active_token)
        pop!(authority._invocation_stack)
        frame_state.active = false
        throw(
            _error(
                _TERMINAL_REQUIRED_CODE,
                "rule" => rule,
                "origin" => origin,
            ),
        )
    end

    pop!(authority._invocation_stack)
    frame_state.active = false
    return nothing
end

"""Return a fresh detached neutral frame-snapshot record."""
function to_json(snapshot::RecognitionFrameSnapshot)
    record = Dict{String,Any}(
        "source" => snapshot._source,
        "rule" => snapshot._rule,
        "invocation" => snapshot._invocation,
        "generation" => snapshot._generation,
    )
    merge!(record, _state_to_json(snapshot._state))
    return record
end

"""Return a fresh detached machine-readable diagnostic record."""
function to_json(error::RecognitionTransactionException)
    return Dict{String,Any}(field.first => field.second for field in error._record)
end

to_json(error::InterMatchGapException) =
    Dict{String,Any}(field.first => field.second for field in error._record)

to_json(error::GapCursorRegressionException) =
    Dict{String,Any}(field.first => field.second for field in error._record)

end
