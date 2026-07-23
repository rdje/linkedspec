const _SEMANTIC_SNAPSHOT_ID = "snapshot:0"

"""Compilation state retained by one opaque semantic snapshot."""
@enum SemanticSnapshotState begin
    SemanticCompiledSnapshotState = 0
    SemanticFailedCompilationSnapshotState = 1
end

const _SEMANTIC_SNAPSHOT_STATE_NAMES = Dict(
    SemanticCompiledSnapshotState => "compiled",
    SemanticFailedCompilationSnapshotState => "failed_compilation",
)

"""Clone-safe foundation metadata; this is not a semantic query response."""
struct SemanticSnapshot
    id::String
    state::SemanticSnapshotState
    has_execution::Bool
    source_detail_ceiling::SemanticSourceDetail
    content_digest_available::Bool
end

Base.:(==)(left::SemanticSnapshot, right::SemanticSnapshot) =
    left.id == right.id &&
    left.state == right.state &&
    left.has_execution == right.has_execution &&
    left.source_detail_ceiling == right.source_detail_ceiling &&
    left.content_digest_available == right.content_digest_available

Base.hash(snapshot::SemanticSnapshot, seed::UInt) = Base.hash(
    (
        snapshot.id,
        snapshot.state,
        snapshot.has_execution,
        snapshot.source_detail_ceiling,
        snapshot.content_digest_available,
    ),
    seed,
)

"""Presence-only view of private staged parser and compiler authority."""
struct SemanticCompilationAuthority
    parsed::Bool
    validated::Bool
    compiled::Bool
end

Base.:(==)(left::SemanticCompilationAuthority, right::SemanticCompilationAuthority) =
    left.parsed == right.parsed &&
    left.validated == right.validated &&
    left.compiled == right.compiled

Base.hash(authority::SemanticCompilationAuthority, seed::UInt) = Base.hash(
    (authority.parsed, authority.validated, authority.compiled),
    seed,
)

"""Detached portable language failure retained by a failed snapshot."""
struct SemanticCompilationDiagnostic
    code::String
    stage::String
    message::String
    fields::Tuple

    function SemanticCompilationDiagnostic(; code, stage, message, fields = ())
        return new(
            String(code),
            String(stage),
            String(message),
            _semantic_error_fields(fields),
        )
    end
end

Base.:(==)(left::SemanticCompilationDiagnostic, right::SemanticCompilationDiagnostic) =
    left.code == right.code &&
    left.stage == right.stage &&
    left.message == right.message &&
    left.fields == right.fields

Base.hash(diagnostic::SemanticCompilationDiagnostic, seed::UInt) = Base.hash(
    (diagnostic.code, diagnostic.stage, diagnostic.message, diagnostic.fields),
    seed,
)

"""Effective entry identity detached from its compiled rule."""
struct SemanticEntrySelection
    label::String
    basis::String
end

Base.:(==)(left::SemanticEntrySelection, right::SemanticEntrySelection) =
    left.label == right.label && left.basis == right.basis

Base.hash(selection::SemanticEntrySelection, seed::UInt) =
    Base.hash((selection.label, selection.basis), seed)

"""One immutable generated-source-v2 plan row."""
struct SemanticGeneratedPlanRow
    label::String
    family::String
end

Base.:(==)(left::SemanticGeneratedPlanRow, right::SemanticGeneratedPlanRow) =
    left.label == right.label && left.family == right.family

Base.hash(row::SemanticGeneratedPlanRow, seed::UInt) =
    Base.hash((row.label, row.family), seed)

"""Shared generated-v2 input detached from compiled and emitted host state."""
struct SemanticGeneratedPlanInput
    contract_id::String
    format_version::Int
    source_identity::String
    rows::Tuple

    function SemanticGeneratedPlanInput(; contract_id, format_version, source_identity, rows)
        copied_rows = Tuple(
            SemanticGeneratedPlanRow(String(row.label), String(row.family)) for row in rows
        )
        return new(
            String(contract_id),
            Int(format_version),
            String(source_identity),
            copied_rows,
        )
    end
end

Base.:(==)(left::SemanticGeneratedPlanInput, right::SemanticGeneratedPlanInput) =
    left.contract_id == right.contract_id &&
    left.format_version == right.format_version &&
    left.source_identity == right.source_identity &&
    left.rows == right.rows

Base.hash(plan::SemanticGeneratedPlanInput, seed::UInt) = Base.hash(
    (plan.contract_id, plan.format_version, plan.source_identity, plan.rows),
    seed,
)

struct _SemanticAuthoredDefinition
    kind::String
    name::String
    line::Int
end

struct _SemanticCompilationOutcome <: _AbstractSemanticCompilationOutcome
    parsed::Union{Nothing,SpecFile}
    validated::Bool
    compiled::Union{Nothing,CompiledSpec}
    diagnostic::Union{Nothing,SemanticCompilationDiagnostic}
    entry::Union{Nothing,SemanticEntrySelection}
    generated_plan::Union{Nothing,SemanticGeneratedPlanInput}
    authored_definitions::Tuple
end

"""Return fresh foundation metadata without exposing semantic records."""
function semantic_snapshot(index::SemanticIndex)
    outcome = _semantic_compilation_outcome(index)
    return _semantic_snapshot(outcome, getfield(index, :_source_detail_ceiling))
end

function _semantic_snapshot(outcome::_SemanticCompilationOutcome, ceiling::SemanticSourceDetail)
    state = outcome.compiled === nothing ?
            SemanticFailedCompilationSnapshotState : SemanticCompiledSnapshotState
    return SemanticSnapshot(
        _SEMANTIC_SNAPSHOT_ID,
        state,
        false,
        ceiling,
        ceiling == SemanticSourceTextDetail,
    )
end

"""Return only presence bits for retained private compilation authority."""
function compilation_authority(index::SemanticIndex)
    outcome = _semantic_compilation_outcome(index)
    return SemanticCompilationAuthority(
        outcome.parsed !== nothing,
        outcome.validated,
        outcome.compiled !== nothing,
    )
end

"""Return a detached portable language failure, if construction failed."""
function compilation_diagnostic(index::SemanticIndex)
    diagnostic = _semantic_compilation_outcome(index).diagnostic
    diagnostic === nothing && return nothing
    return SemanticCompilationDiagnostic(
        code = diagnostic.code,
        stage = diagnostic.stage,
        message = diagnostic.message,
        fields = diagnostic.fields,
    )
end

"""Return resolved entry identity without exposing a compiled rule."""
function entry_selection(index::SemanticIndex)
    selection = _semantic_compilation_outcome(index).entry
    selection === nothing && return nothing
    return SemanticEntrySelection(String(selection.label), String(selection.basis))
end

"""Return the shared generated-v2 plan without compiled or emitted host state."""
function generated_plan_input(index::SemanticIndex)
    _require_semantic_source_detail(index, SemanticSourceIdentityDetail)
    plan = _semantic_compilation_outcome(index).generated_plan
    plan === nothing && return nothing
    return SemanticGeneratedPlanInput(
        contract_id = plan.contract_id,
        format_version = plan.format_version,
        source_identity = plan.source_identity,
        rows = plan.rows,
    )
end

function to_json(snapshot::SemanticSnapshot)
    return Dict{String,Any}(
        "id" => snapshot.id,
        "state" => _semantic_snapshot_state_name(snapshot.state),
        "has_execution" => snapshot.has_execution,
        "source_detail_ceiling" => _semantic_source_detail_name(snapshot.source_detail_ceiling),
        "content_digest_available" => snapshot.content_digest_available,
    )
end

function to_json(authority::SemanticCompilationAuthority)
    return Dict{String,Any}(
        "parsed" => authority.parsed,
        "validated" => authority.validated,
        "compiled" => authority.compiled,
    )
end

function to_json(diagnostic::SemanticCompilationDiagnostic)
    return Dict{String,Any}(
        "code" => diagnostic.code,
        "stage" => diagnostic.stage,
        "message" => diagnostic.message,
        "fields" => _semantic_json_value(diagnostic.fields),
    )
end

to_json(selection::SemanticEntrySelection) = Dict{String,Any}(
    "label" => selection.label,
    "basis" => selection.basis,
)

to_json(row::SemanticGeneratedPlanRow) = Dict{String,Any}(
    "label" => row.label,
    "family" => row.family,
)

function to_json(plan::SemanticGeneratedPlanInput)
    return Dict{String,Any}(
        "contract_id" => plan.contract_id,
        "format_version" => plan.format_version,
        "source_identity" => plan.source_identity,
        "rows" => Any[to_json(row) for row in plan.rows],
    )
end

function _build_semantic_compilation_outcome(source_text::String, options::SemanticIndexOptions)
    parsed = try
        parse_spec_with_staged_user_function_definitions(source_text)
    catch error
        _semantic_is_fatal_exception(error) && rethrow()
        return _failed_semantic_compilation_outcome(
            diagnostic = _semantic_language_diagnostic(
                error,
                "semantic_index_parse_failed",
                "parse_source",
            ),
        )
    end

    try
        validate_spec(parsed)
    catch error
        _semantic_is_fatal_exception(error) && rethrow()
        return _failed_semantic_compilation_outcome(
            parsed = parsed,
            diagnostic = _semantic_language_diagnostic(
                error,
                "semantic_index_validation_failed",
                "validate_source",
            ),
        )
    end

    candidate = try
        compile_spec(parsed; validate_source = false)
    catch error
        _semantic_is_fatal_exception(error) && rethrow()
        return _failed_semantic_compilation_outcome(
            parsed = parsed,
            validated = true,
            diagnostic = _semantic_language_diagnostic(
                error,
                "semantic_index_compilation_failed",
                "compile_source",
            ),
        )
    end

    authored_definitions = _semantic_authored_definitions(parsed)
    selected = try
        resolve_entry_rule(candidate, options.entry_rule)
    catch error
        _semantic_is_fatal_exception(error) && rethrow()
        return _failed_semantic_compilation_outcome(
            parsed = parsed,
            validated = true,
            authored_definitions = authored_definitions,
            diagnostic = _semantic_language_diagnostic(
                error,
                "semantic_index_entry_selection_failed",
                "select_entry_rule",
            ),
        )
    end
    entry = SemanticEntrySelection(
        String(selected.rule.label),
        entry_rule_selection_basis_name(selected.basis),
    )

    plan = try
        rows = build_generated_rule_plan(candidate)
        SemanticGeneratedPlanInput(
            contract_id = GENERATED_SOURCE_CONTRACT,
            format_version = GENERATED_SOURCE_FORMAT,
            source_identity = options.logical_name,
            rows = (
                SemanticGeneratedPlanRow(String(row.label), String(row.family)) for row in rows
            ),
        )
    catch error
        _semantic_is_fatal_exception(error) && rethrow()
        return _failed_semantic_compilation_outcome(
            parsed = parsed,
            validated = true,
            authored_definitions = authored_definitions,
            diagnostic = _semantic_language_diagnostic(
                error,
                "semantic_index_generated_plan_failed",
                "build_generated_plan",
            ),
        )
    end

    return _SemanticCompilationOutcome(
        parsed,
        true,
        candidate,
        nothing,
        entry,
        plan,
        authored_definitions,
    )
end

function _failed_semantic_compilation_outcome(;
    parsed = nothing,
    validated = false,
    diagnostic,
    authored_definitions = (),
)
    return _SemanticCompilationOutcome(
        parsed,
        validated,
        nothing,
        diagnostic,
        nothing,
        nothing,
        Tuple(authored_definitions),
    )
end

function _semantic_language_diagnostic(error, fallback_code, fallback_stage)
    if error isa SpecValidationException && error.diagnostic !== nothing
        diagnostic = error.diagnostic
        return SemanticCompilationDiagnostic(
            code = diagnostic.code,
            stage = diagnostic.stage,
            message = diagnostic.message,
            fields = diagnostic.fields,
        )
    elseif error isa EntryRuleSelectionException
        fields = error.entry_rule === nothing ? () : ("entry_rule" => error.entry_rule,)
        return SemanticCompilationDiagnostic(
            code = error.code,
            stage = error.stage,
            message = error.message,
            fields = fields,
        )
    end

    fields = error isa SpecParseException ? ("line" => error.line,) : ()
    message = if hasproperty(error, :message)
        String(getproperty(error, :message))
    else
        sprint(showerror, error)
    end
    return SemanticCompilationDiagnostic(
        code = fallback_code,
        stage = fallback_stage,
        message = message,
        fields = fields,
    )
end

function _semantic_authored_definitions(parsed::SpecFile)
    definitions = _SemanticAuthoredDefinition[]
    for definition in parsed.functions
        push!(definitions, _SemanticAuthoredDefinition(
            "function",
            String(definition.name),
            definition.source_span.line_start,
        ))
    end
    for rule in parsed.rules
        push!(definitions, _SemanticAuthoredDefinition(
            "rule",
            String(rule.header.label),
            rule.header.line,
        ))
    end
    sort!(definitions; by = definition -> (
        definition.line,
        definition.kind == "function" ? 0 : 1,
        definition.name,
    ))
    return Tuple(definitions)
end

function _semantic_authored_definition_order(index::SemanticIndex)
    return Tuple(
        (kind = definition.kind, name = definition.name, line = definition.line) for
        definition in _semantic_compilation_outcome(index).authored_definitions
    )
end

function _semantic_compilation_outcome(index::SemanticIndex)
    outcome = getfield(index, :_compilation_outcome)
    if !(outcome isa _SemanticCompilationOutcome)
        throw(AssertionError("SemanticIndex compilation outcome has an invalid internal type"))
    end
    return outcome
end

_semantic_snapshot_state_name(state::SemanticSnapshotState) =
    _SEMANTIC_SNAPSHOT_STATE_NAMES[state]

function _semantic_index_snapshot_state_name(index::SemanticIndex)
    return _semantic_snapshot_state_name(semantic_snapshot(index).state)
end

_semantic_is_fatal_exception(error) =
    error isa InterruptException || error isa OutOfMemoryError || error isa StackOverflowError
