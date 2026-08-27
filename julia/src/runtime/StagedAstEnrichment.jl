"""
Private caller-frozen authority for one-depth staged-AST enrichment.

The trusted caller supplies a completed immutable resolution snapshot and
already-compiled callbacks. Dispatch performs no loading, compilation,
provider query, filesystem access, or registry mutation. Returned values are
detached before they are stitched into a detached parent-AST copy.
"""

const _STAGED_AST_ENRICHMENT_ERROR_PREFIX =
    "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:"
const _STAGED_MARKER_KIND = "STAGED_PARSE_JOB_MARKER"
const _STAGED_SIDECAR_KIND = "staged_parse_job_v2"
const _STAGED_SOURCE_DETAILS = ("none", "identity", "span", "text")
const _STAGED_LIVE_RESULT_KEYS = (
    raw"$ref",
    "parser",
    "parser_handle",
    "registry",
    "source_authority",
    "frame",
    "transaction",
    "cancellation",
    "callback",
    "host",
    "path",
    "live_handle",
)

struct StagedAstEnrichmentException <: Exception
    _record::Tuple{Vararg{Pair{String,Any}}}
end

function _staged_enrichment_exception(
    code::AbstractString,
    phase::AbstractString;
    fields::AbstractVector{<:Pair} = Pair{String,Any}[],
)
    record = Pair{String,Any}[
        "code" => String(code),
        "phase" => String(phase),
    ]
    for field in fields
        push!(record, String(field.first) => _staged_copy_plain(field.second))
    end
    return StagedAstEnrichmentException(Tuple(record))
end

_staged_snapshot_exception(component::AbstractString) =
    _staged_enrichment_exception(
        "staged_registry_snapshot_invalid",
        "prepare";
        fields = ["snapshot_component" => String(component)],
    )

function Base.showerror(io::IO, error::StagedAstEnrichmentException)
    print(io, _STAGED_AST_ENRICHMENT_ERROR_PREFIX, first(error._record).second)
end

to_json(error::StagedAstEnrichmentException) =
    Dict{String,Any}(key => _staged_copy_plain(value) for (key, value) in error._record)

struct _StagedChildExecution
    succeeded::Bool
    value::Any
end

_staged_child_success(value) = _StagedChildExecution(true, value)
_staged_child_failure(diagnostic) = _StagedChildExecution(false, diagnostic)

mutable struct _StagedRuntimeContext
    cursor::Int
    marks::Dict{String,Any}
    captures::Dict{String,Any}
    variables::Dict{String,Any}
end

_StagedRuntimeContext() = _StagedRuntimeContext(
    0,
    Dict{String,Any}(),
    Dict{String,Any}(),
    Dict{String,Any}(),
)

function _staged_runtime_context_record(context::_StagedRuntimeContext)
    return Dict{String,Any}(
        "cursor" => context.cursor,
        "marks" => _staged_copy_plain(context.marks),
        "captures" => _staged_copy_plain(context.captures),
        "variables" => _staged_copy_plain(context.variables),
    )
end

struct _StagedDirectCandidate
    declaring_spec_id::String
    authored_id::String
    resolved_spec_id::String
end

struct _StagedCandidate
    authored_id::String
    resolved_spec_id::String
end

struct _StagedOrderedCandidates
    identity::String
    order::Int
    candidates::Tuple{Vararg{_StagedCandidate}}
end

struct _StagedCeilings
    source_detail::String
    max_steps::Int
    max_result_nodes::Int
    max_diagnostic_bytes::Int
end

struct _StagedVersions
    spec_language_version::Int
    helper_contract_version::String
    staged_contract_version::Int
end

struct _StagedRegistryEntry
    resolved_spec_id::String
    compiled_authority::Function
    content_digest::String
    import_graph_fingerprint::String
    default_top_rule::String
    allowed_top_rules::Tuple{Vararg{String}}
    versions::_StagedVersions
    capabilities::Tuple{Vararg{String}}
    policy_modes::Tuple{Vararg{String}}
    ceilings::_StagedCeilings
end

struct _StagedCachedPlan
    compiled_authority::Function
    resolved_spec_id::String
    top_rule::String
    effective_capabilities::Tuple{Vararg{String}}
end

mutable struct _StagedPlanCache
    entries::Dict{String,_StagedCachedPlan}
    hits::Int
    misses::Int
end

struct _FrozenStagedRegistry
    aliases::Tuple{Vararg{_StagedDirectCandidate}}
    declaring_relative::Tuple{Vararg{_StagedDirectCandidate}}
    search_roots::Tuple{Vararg{_StagedOrderedCandidates}}
    providers::Tuple{Vararg{_StagedOrderedCandidates}}
    entries::Tuple{Vararg{_StagedRegistryEntry}}
    snapshot_id::String
    cache::_StagedPlanCache
end

struct _StagedEnrichmentOptions
    declaring_spec_id::String
    caller_capabilities::Set{String}
    caller_policy_modes::Set{String}
    caller_ceilings::_StagedCeilings
    required_source_detail::String
    required_versions::_StagedVersions
end

struct _StagedDiscoveredMarker
    path::Vector{Any}
    marker::Dict{String,Any}
end

mutable struct _StagedPreparedPlan
    path::Vector{Any}
    marker::Dict{String,Any}
    sidecar::Dict{String,Any}
    resolved_spec_id::String
    top_rule::String
    cache_key::String
    effective::Dict{String,Any}
    provenance_order::Vector{Any}
end

struct _StagedEnrichmentOutcome
    ast::Any
    sidecars::Vector{Dict{String,Any}}
    diagnostics::Vector{Dict{String,Any}}
    cache::Dict{String,Any}
end

function to_json(outcome::_StagedEnrichmentOutcome)
    return Dict{String,Any}(
        "ast" => _staged_copy_plain(outcome.ast),
        "sidecars" => Any[_staged_copy_plain(value) for value in outcome.sidecars],
        "diagnostics" => Any[
            _staged_copy_plain(value) for value in outcome.diagnostics
        ],
        "cache" => _staged_copy_plain(outcome.cache),
    )
end

function _staged_snapshot_object(value, component::AbstractString)
    value isa AbstractDict || throw(_staged_snapshot_exception(component))
    result = Dict{String,Any}()
    for (key, child) in pairs(value)
        key isa AbstractString || throw(_staged_snapshot_exception(component))
        result[String(key)] = child
    end
    return result
end

function _staged_snapshot_list(value, component::AbstractString)
    value isa AbstractVector || throw(_staged_snapshot_exception(component))
    return Any[value...]
end

function _staged_required_string(object::AbstractDict, field::AbstractString)
    value = get(object, field, nothing)
    value isa AbstractString && !isempty(value) ||
        throw(_staged_snapshot_exception(field))
    return String(value)
end

function _staged_positive_int(object::AbstractDict, field::AbstractString)
    value = get(object, field, nothing)
    value isa Integer && !(value isa Bool) && value > 0 ||
        throw(_staged_snapshot_exception(field))
    return try
        Int(value)
    catch
        throw(_staged_snapshot_exception(field))
    end
end

function _staged_string_set(
    value,
    component::AbstractString;
    allow_empty::Bool = false,
)
    rows = _staged_snapshot_list(value, component)
    (!isempty(rows) || allow_empty) || throw(_staged_snapshot_exception(component))
    result = Set{String}()
    for row in rows
        row isa AbstractString && !isempty(row) ||
            throw(_staged_snapshot_exception(component))
        text = String(row)
        text in result && throw(_staged_snapshot_exception(component))
        push!(result, text)
    end
    return result
end

function _staged_parse_ceilings(value, component::AbstractString)
    object = _staged_snapshot_object(value, component)
    source_detail = _staged_required_string(object, "source_detail")
    _staged_source_detail_rank(source_detail)
    return _StagedCeilings(
        source_detail,
        _staged_positive_int(object, "max_steps"),
        _staged_positive_int(object, "max_result_nodes"),
        _staged_positive_int(object, "max_diagnostic_bytes"),
    )
end

function _staged_parse_versions(value, component::AbstractString)
    object = _staged_snapshot_object(value, component)
    return _StagedVersions(
        _staged_positive_int(object, "spec_language_version"),
        _staged_required_string(object, "helper_contract_version"),
        _staged_positive_int(object, "staged_contract_version"),
    )
end

_staged_valid_parser_identity(value::AbstractString) =
    occursin(r"^[a-z][a-z0-9]*(?:[._:/-][a-z][a-z0-9]*)*$", value)

_staged_valid_top_rule(value::AbstractString) =
    occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", value)

_staged_valid_digest(value::AbstractString) =
    occursin(r"^sha256:[0-9a-f]{64}$", value)

function _staged_source_detail_rank(value::AbstractString)
    rank = findfirst(==(value), _STAGED_SOURCE_DETAILS)
    rank === nothing && throw(_staged_snapshot_exception("source_detail"))
    return rank - 1
end

function _staged_copy_plain(value)
    active = IdDict{Any,Nothing}()
    function walk(current)
        if current === nothing || current isa Bool || current isa AbstractString
            return current isa AbstractString ? String(current) : current
        elseif current isa Integer && !(current isa Bool)
            return try
                Int(current)
            catch
                throw(_staged_snapshot_exception("plain_data"))
            end
        elseif current isa AbstractFloat && isfinite(current)
            return current
        elseif current isa AbstractVector
            haskey(active, current) &&
                throw(_staged_snapshot_exception("plain_data"))
            active[current] = nothing
            try
                return Any[walk(child) for child in current]
            finally
                delete!(active, current)
            end
        elseif current isa AbstractDict
            haskey(active, current) &&
                throw(_staged_snapshot_exception("plain_data"))
            active[current] = nothing
            try
                result = Dict{String,Any}()
                for (key, child) in pairs(current)
                    key isa AbstractString ||
                        throw(_staged_snapshot_exception("plain_data"))
                    result[String(key)] = walk(child)
                end
                return result
            finally
                delete!(active, current)
            end
        end
        throw(_staged_snapshot_exception("plain_data"))
    end
    return walk(value)
end

function _staged_canonical_json(value)
    active = IdDict{Any,Nothing}()
    function encode(current)
        if current === nothing || current isa Bool || current isa AbstractString ||
                (current isa Number && !(current isa Bool) && isfinite(current))
            return JSON3.write(current)
        elseif current isa AbstractVector
            haskey(active, current) &&
                throw(_staged_snapshot_exception("canonical_json"))
            active[current] = nothing
            try
                return "[" * join((encode(child) for child in current), ",") * "]"
            finally
                delete!(active, current)
            end
        elseif current isa AbstractDict
            haskey(active, current) &&
                throw(_staged_snapshot_exception("canonical_json"))
            active[current] = nothing
            try
                sorted_keys = String[]
                for key in Base.keys(current)
                    key isa AbstractString ||
                        throw(_staged_snapshot_exception("canonical_json"))
                    push!(sorted_keys, String(key))
                end
                sort!(sorted_keys)
                fields = String[
                    JSON3.write(key) * ":" * encode(current[key]) for key in sorted_keys
                ]
                return "{" * join(fields, ",") * "}"
            finally
                delete!(active, current)
            end
        end
        throw(_staged_snapshot_exception("canonical_json"))
    end
    return encode(value)
end

function _staged_digest(value)
    encoded = _staged_canonical_json(value)
    return "sha256:$(bytes2hex(SHA.sha256(codeunits(encoded))))"
end

_staged_payload_digest(text::AbstractString) =
    "sha256:$(bytes2hex(SHA.sha256(codeunits(text))))"

function _staged_direct_candidates(value, entries, component::AbstractString)
    rows = _StagedDirectCandidate[]
    for raw in _staged_snapshot_list(value, component)
        row = _staged_snapshot_object(raw, component)
        declaring_spec_id = _staged_required_string(row, "declaring_spec_id")
        authored_id = _staged_required_string(row, "authored_id")
        resolved_spec_id = _staged_required_string(row, "resolved_spec_id")
        if !_staged_valid_parser_identity(declaring_spec_id) ||
                !_staged_valid_parser_identity(authored_id) ||
                !haskey(entries, resolved_spec_id)
            throw(_staged_snapshot_exception(component))
        end
        push!(rows, _StagedDirectCandidate(
            declaring_spec_id,
            authored_id,
            resolved_spec_id,
        ))
    end
    return Tuple(rows)
end

function _staged_ordered_candidates(
    value,
    entries;
    identity_field::AbstractString,
    component::AbstractString,
)
    rows = _StagedOrderedCandidates[]
    orders = Set{Int}()
    for raw in _staged_snapshot_list(value, component)
        row = _staged_snapshot_object(raw, component)
        identity = _staged_required_string(row, identity_field)
        order = _staged_positive_int(row, "order")
        order in orders && throw(_staged_snapshot_exception(component))
        push!(orders, order)
        candidates = _StagedCandidate[]
        for raw_candidate in _staged_snapshot_list(row["candidates"], "candidates")
            candidate = _staged_snapshot_object(raw_candidate, "candidates")
            authored_id = _staged_required_string(candidate, "authored_id")
            resolved_spec_id = _staged_required_string(candidate, "resolved_spec_id")
            if !_staged_valid_parser_identity(authored_id) ||
                    !haskey(entries, resolved_spec_id)
                throw(_staged_snapshot_exception(component))
            end
            push!(candidates, _StagedCandidate(authored_id, resolved_spec_id))
        end
        push!(rows, _StagedOrderedCandidates(identity, order, Tuple(candidates)))
    end
    sort!(rows; by = row -> row.order)
    return Tuple(rows)
end

"""Freeze one caller-completed snapshot and its exact compiled callbacks."""
function _freeze_staged_registry(snapshot, compiled_authorities::AbstractDict)
    object = _staged_snapshot_object(snapshot, "shape")
    if get(object, "immutable", nothing) !== true ||
            get(object, "prepared_before_authored_execution", nothing) !== true ||
            get(object, "filesystem_access_during_dispatch", nothing) !== false
        throw(_staged_snapshot_exception("authority_boundary"))
    end

    callbacks = Dict{String,Function}()
    for (key, callback) in pairs(compiled_authorities)
        key isa AbstractString && callback isa Function ||
            throw(_staged_snapshot_exception("compiled_authority"))
        callbacks[String(key)] = callback
    end
    entries = Dict{String,_StagedRegistryEntry}()
    entry_values = _StagedRegistryEntry[]
    logical_snapshot = _staged_copy_plain(snapshot)
    logical_entries = _staged_snapshot_list(
        _staged_snapshot_object(logical_snapshot, "shape")["entries"],
        "entries",
    )
    entry_rows = _staged_snapshot_list(get(object, "entries", nothing), "entries")
    isempty(entry_rows) && throw(_staged_snapshot_exception("entries"))
    length(logical_entries) == length(entry_rows) ||
        throw(_staged_snapshot_exception("entries"))

    for (index, raw) in enumerate(entry_rows)
        row = _staged_snapshot_object(raw, "entries")
        resolved_spec_id = _staged_required_string(row, "resolved_spec_id")
        if !_staged_valid_parser_identity(resolved_spec_id) ||
                haskey(entries, resolved_spec_id)
            throw(_staged_snapshot_exception("resolved_spec_id"))
        end
        authority_name = _staged_required_string(row, "compiled_authority")
        callback = pop!(callbacks, authority_name, nothing)
        callback isa Function ||
            throw(_staged_snapshot_exception("compiled_authority"))
        content_digest = _staged_required_string(row, "content_digest")
        graph_fingerprint = _staged_required_string(
            row,
            "import_graph_fingerprint",
        )
        _staged_valid_digest(content_digest) ||
            throw(_staged_snapshot_exception("content_digest"))
        _staged_valid_digest(graph_fingerprint) ||
            throw(_staged_snapshot_exception("import_graph_fingerprint"))
        default_top_rule = _staged_required_string(row, "default_top_rule")
        _staged_valid_top_rule(default_top_rule) ||
            throw(_staged_snapshot_exception("default_top_rule"))
        allowed_top_rules = _staged_string_set(
            row["allowed_top_rules"],
            "allowed_top_rules",
        )
        default_top_rule in allowed_top_rules ||
            throw(_staged_snapshot_exception("default_top_rule"))
        entries[resolved_spec_id] = _StagedRegistryEntry(
            resolved_spec_id,
            callback,
            content_digest,
            graph_fingerprint,
            default_top_rule,
            Tuple(sort!(collect(allowed_top_rules))),
            _StagedVersions(
                _staged_positive_int(row, "spec_language_version"),
                _staged_required_string(row, "helper_contract_version"),
                _staged_positive_int(row, "staged_contract_version"),
            ),
            Tuple(sort!(collect(_staged_string_set(
                row["capabilities"],
                "capabilities",
            )))),
            Tuple(sort!(collect(_staged_string_set(
                row["policy_modes"],
                "policy_modes",
            )))),
            _staged_parse_ceilings(row["ceilings"], "ceilings"),
        )
        push!(entry_values, entries[resolved_spec_id])
        logical_row = logical_entries[index]
        logical_row isa AbstractDict && haskey(logical_row, "compiled_authority") ||
            throw(_staged_snapshot_exception("compiled_authority"))
        logical_row["compiled_authority"] = "opaque:compiled:callback"
    end
    isempty(callbacks) || throw(_staged_snapshot_exception("compiled_authority"))

    return _FrozenStagedRegistry(
        _staged_direct_candidates(get(object, "aliases", nothing), entries, "aliases"),
        _staged_direct_candidates(
            get(object, "declaring_relative", nothing),
            entries,
            "declaring_relative",
        ),
        _staged_ordered_candidates(
            get(object, "search_roots", nothing),
            entries;
            identity_field = "root_id",
            component = "search_roots",
        ),
        _staged_ordered_candidates(
            get(object, "providers", nothing),
            entries;
            identity_field = "provider_id",
            component = "providers",
        ),
        Tuple(entry_values),
        "registry-snapshot:$(_staged_digest(logical_snapshot))",
        _StagedPlanCache(Dict{String,_StagedCachedPlan}(), 0, 0),
    )
end

function _staged_direct_matches(
    candidates,
    declaring_spec_id::AbstractString,
    parser_spec_id::AbstractString,
)
    return String[
        candidate.resolved_spec_id for candidate in candidates
        if candidate.declaring_spec_id == declaring_spec_id &&
            candidate.authored_id == parser_spec_id
    ]
end

"""Resolve only among caller-completed candidates in the neutral priority order."""
function _resolve_staged_pre_registered(
    registry::_FrozenStagedRegistry;
    declaring_spec_id::AbstractString,
    parser_spec_id::AbstractString,
    job_id::AbstractString,
)
    if !_staged_valid_parser_identity(parser_spec_id)
        throw(_staged_enrichment_exception(
            "staged_parser_identity_invalid",
            "resolve";
            fields = [
                "origin" => "post_ast",
                "parser_spec_id" => String(parser_spec_id),
            ],
        ))
    end
    aliases = _staged_direct_matches(
        registry.aliases,
        declaring_spec_id,
        parser_spec_id,
    )
    relatives = _staged_direct_matches(
        registry.declaring_relative,
        declaring_spec_id,
        parser_spec_id,
    )
    if !isempty(aliases) && !isempty(relatives)
        throw(_staged_enrichment_exception(
            "staged_registry_collision",
            "resolve";
            fields = [
                "job_id" => String(job_id),
                "parser_spec_id" => String(parser_spec_id),
                "aliases" => aliases,
                "relative_candidates" => relatives,
            ],
        ))
    end
    if length(aliases) > 1 || length(relatives) > 1
        matches = length(aliases) > 1 ? aliases : relatives
        priority = length(aliases) > 1 ? "alias" : "declaring_relative"
        throw(_staged_enrichment_exception(
            "staged_registry_ambiguous",
            "resolve";
            fields = [
                "job_id" => String(job_id),
                "parser_spec_id" => String(parser_spec_id),
                "priority" => priority,
                "candidates" => matches,
            ],
        ))
    end
    !isempty(aliases) && return only(aliases)
    !isempty(relatives) && return only(relatives)

    for group in (registry.search_roots..., registry.providers...)
        matches = String[
            candidate.resolved_spec_id for candidate in group.candidates
            if candidate.authored_id == parser_spec_id
        ]
        if length(matches) > 1
            throw(_staged_enrichment_exception(
                "staged_registry_ambiguous",
                "resolve";
                fields = [
                    "job_id" => String(job_id),
                    "parser_spec_id" => String(parser_spec_id),
                    "priority" => group.identity,
                    "candidates" => matches,
                ],
            ))
        end
        !isempty(matches) && return only(matches)
    end
    throw(_staged_enrichment_exception(
        "staged_registry_missing",
        "resolve";
        fields = [
            "job_id" => String(job_id),
            "parser_spec_id" => String(parser_spec_id),
            "declaring_spec_id" => String(declaring_spec_id),
        ],
    ))
end

function _staged_registry_entry(
    registry::_FrozenStagedRegistry,
    resolved_spec_id::AbstractString,
)
    for entry in registry.entries
        entry.resolved_spec_id == resolved_spec_id && return entry
    end
    return nothing
end

function _staged_effective_authority(
    registry::_FrozenStagedRegistry;
    entry_id::AbstractString,
    top_rule::AbstractString,
    job_id::AbstractString,
    caller_capabilities::Set{String},
    required_capabilities::Set{String},
    caller_policy_modes::Set{String},
    required_policy_modes::Set{String},
    caller_ceilings::_StagedCeilings,
    required_source_detail::AbstractString,
    required_versions::_StagedVersions,
)
    entry = _staged_registry_entry(registry, entry_id)
    entry isa _StagedRegistryEntry || throw(_staged_enrichment_exception(
        "staged_registry_missing",
        "resolve";
        fields = [
            "job_id" => String(job_id),
            "parser_spec_id" => String(entry_id),
            "declaring_spec_id" => "<prepared-snapshot>",
        ],
    ))
    versions = (
        (
            "spec_language_version",
            required_versions.spec_language_version,
            entry.versions.spec_language_version,
        ),
        (
            "helper_contract_version",
            required_versions.helper_contract_version,
            entry.versions.helper_contract_version,
        ),
        (
            "staged_contract_version",
            required_versions.staged_contract_version,
            entry.versions.staged_contract_version,
        ),
    )
    for (kind, required, actual) in versions
        required == actual && continue
        throw(_staged_enrichment_exception(
            "staged_version_mismatch",
            "compile";
            fields = [
                "job_id" => String(job_id),
                "resolved_spec_id" => String(entry_id),
                "version_kind" => kind,
                "required" => required,
                "actual" => actual,
            ],
        ))
    end
    top_rule in entry.allowed_top_rules || throw(_staged_enrichment_exception(
        "staged_top_rule_forbidden",
        "compile";
        fields = [
            "job_id" => String(job_id),
            "resolved_spec_id" => String(entry_id),
            "top_rule" => String(top_rule),
        ],
    ))

    capabilities = sort!(String[
        capability for capability in entry.capabilities
        if capability in caller_capabilities
    ])
    for capability in required_capabilities
        capability in capabilities && continue
        throw(_staged_enrichment_exception(
            "staged_capability_denied",
            "compile";
            fields = [
                "job_id" => String(job_id),
                "resolved_spec_id" => String(entry_id),
                "capability" => capability,
            ],
        ))
    end
    policy_modes = sort!(String[
        policy for policy in entry.policy_modes if policy in caller_policy_modes
    ])
    for policy in required_policy_modes
        policy in policy_modes && continue
        throw(_staged_enrichment_exception(
            "staged_policy_denied",
            "compile";
            fields = [
                "job_id" => String(job_id),
                "resolved_spec_id" => String(entry_id),
                "policy" => policy,
            ],
        ))
    end
    source_rank = min(
        _staged_source_detail_rank(caller_ceilings.source_detail),
        _staged_source_detail_rank(entry.ceilings.source_detail),
    )
    required_rank = _staged_source_detail_rank(required_source_detail)
    source_rank >= required_rank || throw(_staged_enrichment_exception(
        "staged_source_detail_denied",
        "compile";
        fields = [
            "job_id" => String(job_id),
            "resolved_spec_id" => String(entry_id),
            "required" => String(required_source_detail),
            "effective" => _STAGED_SOURCE_DETAILS[source_rank + 1],
        ],
    ))
    return Dict{String,Any}(
        "capabilities" => Any[capabilities...],
        "policy_modes" => Any[policy_modes...],
        "source_detail" => _STAGED_SOURCE_DETAILS[source_rank + 1],
        "max_steps" => min(caller_ceilings.max_steps, entry.ceilings.max_steps),
        "max_result_nodes" => min(
            caller_ceilings.max_result_nodes,
            entry.ceilings.max_result_nodes,
        ),
        "max_diagnostic_bytes" => min(
            caller_ceilings.max_diagnostic_bytes,
            entry.ceilings.max_diagnostic_bytes,
        ),
    )
end

function _evaluate_staged_authority_case(
    registry::_FrozenStagedRegistry,
    authority_case;
    job_id::AbstractString,
)
    object = _staged_snapshot_object(authority_case, "authority_case")
    return _staged_effective_authority(
        registry;
        entry_id = _staged_required_string(object, "entry_id"),
        top_rule = _staged_required_string(object, "top_rule"),
        job_id = job_id,
        caller_capabilities = _staged_string_set(
            object["caller_capabilities"],
            "caller_capabilities",
        ),
        required_capabilities = _staged_string_set(
            object["required_capabilities"],
            "required_capabilities";
            allow_empty = true,
        ),
        caller_policy_modes = _staged_string_set(
            object["caller_policy_modes"],
            "caller_policy_modes",
        ),
        required_policy_modes = _staged_string_set(
            object["required_policy_modes"],
            "required_policy_modes";
            allow_empty = true,
        ),
        caller_ceilings = _staged_parse_ceilings(
            object["caller_ceilings"],
            "caller_ceilings",
        ),
        required_source_detail = _staged_required_string(
            object,
            "required_source_detail",
        ),
        required_versions = _staged_parse_versions(
            object["required_versions"],
            "required_versions",
        ),
    )
end

function _staged_exact_object(value, expected, component::AbstractString)
    object = _staged_snapshot_object(value, component)
    length(object) == length(expected) && all(haskey(object, key) for key in expected) ||
        throw(_staged_snapshot_exception(component))
    return object
end

function _staged_job_identity(fields)
    expected = (
        "declaring_spec_id",
        "parent_ast_path",
        "node_kind",
        "payload_kind",
        "parser_spec_id",
        "top_rule",
        "provenance",
    )
    object = _staged_exact_object(fields, expected, "job_identity")
    identity = Dict{String,Any}(
        "contract_version" => 2,
        "declaring_spec_id" => object["declaring_spec_id"],
        "parent_ast_path" => object["parent_ast_path"],
        "node_kind" => object["node_kind"],
        "payload_kind" => object["payload_kind"],
        "parser_spec_id" => object["parser_spec_id"],
        "top_rule" => object["top_rule"],
        "provenance" => object["provenance"],
    )
    return "parse_job:v2:$(_staged_digest(identity))"
end

function _staged_cache_identity(fields)
    expected = (
        "normalized_spec_id",
        "content_digest",
        "import_graph_fingerprint",
        "top_rule",
        "spec_language_version",
        "helper_contract_version",
        "staged_contract_version",
        "backend_capabilities",
    )
    object = try
        _staged_exact_object(fields, expected, "cache_identity")
    catch error
        error isa StagedAstEnrichmentException || rethrow()
        throw(_staged_cache_identity_error(fields, "<shape>"))
    end
    normalized_spec_id = get(object, "normalized_spec_id", nothing)
    normalized_spec_id isa AbstractString &&
        _staged_valid_parser_identity(normalized_spec_id) ||
        throw(_staged_cache_identity_error(object, "normalized_spec_id"))
    for field in ("content_digest", "import_graph_fingerprint")
        value = get(object, field, nothing)
        value isa AbstractString && _staged_valid_digest(value) ||
            throw(_staged_cache_identity_error(object, field))
    end
    top_rule = get(object, "top_rule", nothing)
    top_rule isa AbstractString && _staged_valid_top_rule(top_rule) ||
        throw(_staged_cache_identity_error(object, "top_rule"))
    for field in ("spec_language_version", "staged_contract_version")
        value = get(object, field, nothing)
        value isa Integer && !(value isa Bool) && value > 0 ||
            throw(_staged_cache_identity_error(object, field))
    end
    helper_version = get(object, "helper_contract_version", nothing)
    helper_version isa AbstractString && !isempty(helper_version) ||
        throw(_staged_cache_identity_error(object, "helper_contract_version"))
    capabilities = try
        sort!(collect(_staged_string_set(
            object["backend_capabilities"],
            "backend_capabilities",
        )))
    catch error
        error isa StagedAstEnrichmentException || rethrow()
        throw(_staged_cache_identity_error(object, "backend_capabilities"))
    end
    normalized = _staged_copy_plain(object)
    normalized["backend_capabilities"] = Any[capabilities...]
    return _staged_digest(normalized)
end

function _staged_cache_identity_error(fields, component::AbstractString)
    resolved = if fields isa AbstractDict
        value = get(fields, "normalized_spec_id", "<invalid>")
        value isa AbstractString ? String(value) : "<invalid>"
    else
        "<invalid>"
    end
    return _staged_enrichment_exception(
        "staged_cache_identity_invalid",
        "compile";
        fields = [
            "job_id" => "<cache-identity>",
            "resolved_spec_id" => resolved,
            "cache_component" => String(component),
        ],
    )
end

function _staged_compare_components(left, right)
    for index in 1:min(length(left), length(right))
        a = left[index]
        b = right[index]
        order = if a isa AbstractString && b isa AbstractString
            cmp(String(a), String(b))
        elseif a isa Integer && !(a isa Bool) && b isa Integer && !(b isa Bool)
            cmp(a, b)
        else
            a isa AbstractString ? -1 : 1
        end
        order == 0 || return order
    end
    return cmp(length(left), length(right))
end

function _staged_typed_order_components(values)
    result = Any[]
    for value in values
        if value isa AbstractString
            push!(result, String(value))
        elseif value isa Integer && !(value isa Bool) && value >= 0
            push!(result, Int(value))
        else
            throw(_staged_snapshot_exception("typed_order_component"))
        end
    end
    return result
end

function _staged_current_depth_order(jobs)
    rows = NamedTuple[]
    for raw in _staged_snapshot_list(jobs, "current_depth_jobs")
        object = _staged_snapshot_object(raw, "current_depth_job")
        push!(rows, (
            depth = _staged_positive_int(object, "stage_depth"),
            path = _staged_typed_order_components(
                _staged_snapshot_list(object["parent_ast_path"], "parent_ast_path"),
            ),
            provenance = _staged_typed_order_components(
                _staged_snapshot_list(object["provenance_order"], "provenance_order"),
            ),
            id = _staged_required_string(object, "job_id"),
        ))
    end
    sort!(rows; lt = (left, right) -> begin
        left.depth != right.depth && return left.depth < right.depth
        order = _staged_compare_components(left.path, right.path)
        order != 0 && return order < 0
        order = _staged_compare_components(left.provenance, right.provenance)
        order != 0 && return order < 0
        return left.id < right.id
    end)
    return String[row.id for row in rows]
end

function _parse_staged_enrichment_options(value)
    object = _staged_snapshot_object(value, "enrichment_options")
    declaring_spec_id = _staged_required_string(object, "declaring_spec_id")
    _staged_valid_parser_identity(declaring_spec_id) ||
        throw(_staged_snapshot_exception("declaring_spec_id"))
    required_source_detail = _staged_required_string(
        object,
        "required_source_detail",
    )
    _staged_source_detail_rank(required_source_detail)
    return _StagedEnrichmentOptions(
        declaring_spec_id,
        _staged_string_set(object["caller_capabilities"], "caller_capabilities"),
        _staged_string_set(object["caller_policy_modes"], "caller_policy_modes"),
        _staged_parse_ceilings(object["caller_ceilings"], "caller_ceilings"),
        required_source_detail,
        _staged_parse_versions(object["required_versions"], "required_versions"),
    )
end

function _staged_is_marker(value)
    return value isa AbstractDict &&
        get(value, "kind", nothing) == _STAGED_MARKER_KIND &&
        get(value, "version", nothing) == 2 &&
        get(value, "sidecar_kind", nothing) == _STAGED_SIDECAR_KIND &&
        get(value, _STAGED_SIDECAR_KIND, nothing) isa AbstractDict
end

function _staged_discover_markers!(value, path, found)
    if _staged_is_marker(value)
        push!(found, _StagedDiscoveredMarker(
            Any[path...],
            _staged_copy_plain(value),
        ))
        return nothing
    elseif value isa AbstractDict
        for (key, child) in pairs(value)
            key isa AbstractString || throw(_staged_snapshot_exception("parent_ast"))
            _staged_discover_markers!(child, Any[path..., String(key)], found)
        end
    elseif value isa AbstractVector
        for (index, child) in enumerate(value)
            _staged_discover_markers!(child, Any[path..., index - 1], found)
        end
    end
    return nothing
end

function _staged_marker_sidecar(marker::AbstractDict)
    _staged_is_marker(marker) || throw(_staged_snapshot_exception("marker"))
    sidecar = _staged_copy_plain(marker[_STAGED_SIDECAR_KIND])
    if get(sidecar, "kind", nothing) != _STAGED_SIDECAR_KIND ||
            get(sidecar, "version", nothing) != 2 ||
            get(sidecar, "state", nothing) != "declared"
        throw(_staged_snapshot_exception("sidecar"))
    end
    return sidecar
end

function _staged_required_sidecar_string(sidecar, field::AbstractString)
    value = get(sidecar, field, nothing)
    value isa AbstractString && !isempty(value) ||
        throw(_staged_marker_error("staged_registry_snapshot_invalid", sidecar))
    return String(value)
end

function _staged_job_fields(declaring_spec_id, path, sidecar, top_rule)
    node_kind = _staged_required_sidecar_string(sidecar, "node_kind")
    payload_kind = _staged_required_sidecar_string(sidecar, "payload_kind")
    parser_spec_id = _staged_required_sidecar_string(sidecar, "parser_spec_id")
    if top_rule != "<unresolved-default>" && !_staged_valid_top_rule(top_rule)
        throw(_staged_marker_error("staged_top_rule_invalid", sidecar))
    end
    return Dict{String,Any}(
        "declaring_spec_id" => declaring_spec_id,
        "parent_ast_path" => Any[path...],
        "node_kind" => node_kind,
        "payload_kind" => payload_kind,
        "parser_spec_id" => parser_spec_id,
        "top_rule" => top_rule,
        "provenance" => _staged_copy_plain(get(sidecar, "provenance", nothing)),
    )
end

function _staged_provenance_order(value)
    object = _staged_snapshot_object(value, "provenance")
    segments = if get(object, "kind", nothing) == "direct_span"
        Any[object]
    elseif get(object, "kind", nothing) == "derived_text" &&
            get(object, "policy", nothing) == "concatenate_in_order"
        rows = _staged_snapshot_list(get(object, "segments", nothing), "provenance")
        isempty(rows) && throw(_staged_snapshot_exception("provenance"))
        rows
    else
        throw(_staged_snapshot_exception("provenance"))
    end
    order = Any[]
    for raw in segments
        segment = _staged_snapshot_object(raw, "provenance")
        source_id = get(segment, "source_id", nothing)
        start = get(segment, "start", nothing)
        stop = get(segment, "end", nothing)
        provenance = get(segment, "provenance", nothing)
        if !(source_id isa AbstractString) || isempty(source_id) ||
                !(start isa Integer) || start isa Bool || start < 0 ||
                !(stop isa Integer) || stop isa Bool || stop < start ||
                !(provenance isa AbstractString) || isempty(provenance)
            throw(_staged_snapshot_exception("provenance"))
        end
        append!(order, Any[String(source_id), Int(start), Int(stop), String(provenance)])
    end
    return order
end

function _staged_prepare_plan(
    registry::_FrozenStagedRegistry,
    discovered::_StagedDiscoveredMarker,
    options::_StagedEnrichmentOptions,
)
    sidecar = _staged_marker_sidecar(discovered.marker)
    parser_spec_id = _staged_required_sidecar_string(sidecar, "parser_spec_id")
    provisional_top = get(sidecar, "top_rule", nothing) isa AbstractString ?
        String(sidecar["top_rule"]) : "<unresolved-default>"
    provisional_job_id = _staged_job_identity(_staged_job_fields(
        options.declaring_spec_id,
        discovered.path,
        sidecar,
        provisional_top,
    ))
    resolved_spec_id = _resolve_staged_pre_registered(
        registry;
        declaring_spec_id = options.declaring_spec_id,
        parser_spec_id = parser_spec_id,
        job_id = provisional_job_id,
    )
    entry = _staged_registry_entry(registry, resolved_spec_id)
    entry isa _StagedRegistryEntry ||
        throw(_staged_snapshot_exception("resolved_spec_id"))
    top_rule = get(sidecar, "top_rule", nothing) isa AbstractString ?
        String(sidecar["top_rule"]) : entry.default_top_rule
    job_id = _staged_job_identity(_staged_job_fields(
        options.declaring_spec_id,
        discovered.path,
        sidecar,
        top_rule,
    ))
    result_policy = _staged_required_sidecar_string(sidecar, "result_policy")
    failure_policy = _staged_required_sidecar_string(sidecar, "failure_policy")
    required_policy_modes = Set([result_policy, failure_policy])
    effective = _staged_effective_authority(
        registry;
        entry_id = resolved_spec_id,
        top_rule = top_rule,
        job_id = job_id,
        caller_capabilities = options.caller_capabilities,
        required_capabilities = _staged_string_set(
            get(sidecar, "required_capabilities", nothing),
            "required_capabilities";
            allow_empty = true,
        ),
        caller_policy_modes = options.caller_policy_modes,
        required_policy_modes = required_policy_modes,
        caller_ceilings = options.caller_ceilings,
        required_source_detail = options.required_source_detail,
        required_versions = options.required_versions,
    )
    cache_key = _staged_cache_identity(Dict{String,Any}(
        "normalized_spec_id" => resolved_spec_id,
        "content_digest" => entry.content_digest,
        "import_graph_fingerprint" => entry.import_graph_fingerprint,
        "top_rule" => top_rule,
        "spec_language_version" => entry.versions.spec_language_version,
        "helper_contract_version" => entry.versions.helper_contract_version,
        "staged_contract_version" => entry.versions.staged_contract_version,
        "backend_capabilities" => effective["capabilities"],
    ))
    text = _staged_required_sidecar_string(sidecar, "text")
    provenance = _staged_snapshot_object(get(sidecar, "provenance", nothing), "provenance")
    prepared = _staged_copy_plain(sidecar)
    merge!(prepared, Dict{String,Any}(
        "state" => "prepared",
        "declaring_spec_id" => options.declaring_spec_id,
        "parent_ast_path" => Any[discovered.path...],
        "resolved_spec_id" => resolved_spec_id,
        "top_rule" => top_rule,
        "job_id" => job_id,
        "cache_key" => cache_key,
        "stage_depth" => 1,
        "stage_chain" => Any[],
        "payload_digest" => _staged_payload_digest(text),
        "effective" => _staged_copy_plain(effective),
    ))
    return _StagedPreparedPlan(
        Any[discovered.path...],
        _staged_copy_plain(discovered.marker),
        prepared,
        resolved_spec_id,
        top_rule,
        cache_key,
        effective,
        _staged_provenance_order(provenance),
    )
end

function _staged_plan_lt(left::_StagedPreparedPlan, right::_StagedPreparedPlan)
    order = _staged_compare_components(
        _staged_typed_order_components(left.path),
        _staged_typed_order_components(right.path),
    )
    order != 0 && return order < 0
    order = _staged_compare_components(left.provenance_order, right.provenance_order)
    order != 0 && return order < 0
    return left.sidecar["job_id"] < right.sidecar["job_id"]
end

function _staged_cache_stats(registry::_FrozenStagedRegistry)
    return Dict{String,Any}(
        "snapshot_id" => registry.snapshot_id,
        "entries" => length(registry.cache.entries),
        "hits" => registry.cache.hits,
        "misses" => registry.cache.misses,
    )
end

function _staged_cached_plan(
    registry::_FrozenStagedRegistry,
    plan::_StagedPreparedPlan,
)
    cached = get(registry.cache.entries, plan.cache_key, nothing)
    if cached isa _StagedCachedPlan
        registry.cache.hits += 1
        return cached
    end
    entry = _staged_registry_entry(registry, plan.resolved_spec_id)
    entry isa _StagedRegistryEntry ||
        throw(_staged_snapshot_exception("plan_cache"))
    created = _StagedCachedPlan(
        entry.compiled_authority,
        plan.resolved_spec_id,
        plan.top_rule,
        Tuple(String(value) for value in plan.effective["capabilities"]),
    )
    registry.cache.entries[plan.cache_key] = created
    registry.cache.misses += 1
    return created
end

function _staged_value_at(root, path)
    current = root
    for component in path
        if component isa AbstractString && current isa AbstractDict &&
                haskey(current, component)
            current = current[component]
        elseif component isa Integer && !(component isa Bool) && component >= 0 &&
                current isa AbstractVector && component < length(current)
            current = current[component + 1]
        else
            return (found = false, value = nothing)
        end
    end
    return (found = true, value = current)
end

function _staged_parent_at(root, path)
    isempty(path) && return (found = false, value = nothing)
    return _staged_value_at(root, path[1:(end - 1)])
end

function _staged_set_at(root, path, replacement)
    isempty(path) && return replacement
    parent = _staged_parent_at(root, path)
    parent.found || return root
    component = last(path)
    if component isa AbstractString && parent.value isa AbstractDict &&
            haskey(parent.value, component)
        parent.value[component] = replacement
    elseif component isa Integer && !(component isa Bool) && component >= 0 &&
            parent.value isa AbstractVector && component < length(parent.value)
        parent.value[component + 1] = replacement
    end
    return root
end

function _staged_marker_error(code::AbstractString, sidecar)
    return _staged_enrichment_exception(
        code,
        "prepare";
        fields = ["origin" => get(sidecar, "origin", "<marker>")],
    )
end

function _staged_stitch_error(plan, code::AbstractString; fields = Pair{String,Any}[])
    return _staged_enrichment_exception(
        code,
        "stitch";
        fields = Pair{String,Any}[
            "stage_chain" => _staged_copy_plain(plan.sidecar["stage_chain"]),
            "job_id" => plan.sidecar["job_id"],
            "parent_ast_path" => Any[plan.path...],
            fields...,
        ],
    )
end

function _staged_marker_diagnostic(actual)
    actual.found || return "<missing>"
    value = actual.value
    if value isa AbstractDict
        return Dict{String,Any}(
            "kind" => get(value, "kind", nothing),
            "version" => get(value, "version", nothing),
        )
    end
    return value === nothing ? "nothing" : string(typeof(value))
end

function _staged_validate_stitch_target(ast, plan::_StagedPreparedPlan)
    actual = _staged_value_at(ast, plan.path)
    if !actual.found || !_staged_is_marker(actual.value) || actual.value != plan.marker
        throw(_staged_stitch_error(
            plan,
            "staged_marker_mismatch";
            fields = ["actual_marker" => _staged_marker_diagnostic(actual)],
        ))
    end
    policy = get(plan.sidecar, "result_policy", nothing)
    policy == "replace_marker" && return nothing
    into = get(plan.sidecar, "into", nothing)
    parent = _staged_parent_at(ast, plan.path)
    if !(into isa AbstractString) || isempty(into) || !parent.found ||
            !(parent.value isa AbstractDict)
        throw(_staged_stitch_error(
            plan,
            "staged_stitch_target_missing";
            fields = ["into" => (into === nothing ? "<missing>" : into)],
        ))
    end
    if policy == "replace_field" && !haskey(parent.value, into)
        throw(_staged_stitch_error(
            plan,
            "staged_stitch_target_missing";
            fields = ["into" => into],
        ))
    elseif policy == "sibling_field" && haskey(parent.value, into)
        throw(_staged_stitch_error(
            plan,
            "staged_stitch_target_collision";
            fields = ["into" => into],
        ))
    elseif policy == "append_child" && !(get(parent.value, into, nothing) isa AbstractVector)
        throw(_staged_stitch_error(
            plan,
            "staged_append_target_invalid";
            fields = ["into" => into],
        ))
    elseif !(policy in ("replace_field", "sibling_field", "append_child"))
        throw(_staged_marker_error("staged_result_policy_invalid", plan.sidecar))
    end
    return nothing
end

function _staged_path_is_prefix(prefix, path)
    length(prefix) <= length(path) || return false
    return all(prefix[index] == path[index] for index in eachindex(prefix))
end

function _staged_validate_prepared_depth(ast, plans)
    seen_job_ids = Dict{String,Vector{Any}}()
    for plan in plans
        job_id = String(plan.sidecar["job_id"])
        haskey(seen_job_ids, job_id) && throw(_staged_enrichment_exception(
            "staged_duplicate_job_id",
            "prepare";
            fields = ["job_id" => job_id, "parent_ast_path" => plan.path],
        ))
        seen_job_ids[job_id] = plan.path
        _staged_validate_stitch_target(ast, plan)
    end

    claims = NamedTuple[]
    for plan in plans
        policy = plan.sidecar["result_policy"]
        policy == "replace_marker" && continue
        into = String(plan.sidecar["into"])
        target_path = Any[plan.path[1:(end - 1)]..., into]
        append = policy == "append_child"
        if !append
            for queued in plans
                queued === plan && continue
                if _staged_path_is_prefix(target_path, queued.path)
                    throw(_staged_stitch_error(
                        plan,
                        "staged_stitch_target_collision";
                        fields = ["into" => into],
                    ))
                end
            end
        end
        for prior in claims
            same_path = target_path == prior.path
            incompatible =
                (same_path && !(append && prior.append)) ||
                (!append && _staged_path_is_prefix(target_path, prior.path)) ||
                (!prior.append && _staged_path_is_prefix(prior.path, target_path))
            incompatible || continue
            throw(_staged_stitch_error(
                plan,
                "staged_stitch_target_collision";
                fields = ["into" => into],
            ))
        end
        push!(claims, (path = target_path, append = append))
    end
    return nothing
end

function _staged_stitch_value(ast, plan::_StagedPreparedPlan, result)
    _staged_validate_stitch_target(ast, plan)
    policy = String(plan.sidecar["result_policy"])
    policy == "replace_marker" && return _staged_set_at(ast, plan.path, result)
    working = _staged_set_at(ast, plan.path, plan.sidecar["text"])
    parent = _staged_parent_at(working, plan.path).value
    into = String(plan.sidecar["into"])
    if policy in ("replace_field", "sibling_field")
        parent[into] = result
    elseif policy == "append_child"
        push!(parent[into], result)
    end
    return working
end

function _staged_materialize_text(ast, plan::_StagedPreparedPlan)
    _staged_validate_stitch_target(ast, plan)
    return _staged_set_at(ast, plan.path, plan.sidecar["text"])
end

struct _StagedDetachFailure <: Exception
    nodes::Int
    reason::String
end

function _staged_detach_plain(value; maximum::Int)
    maximum >= 0 || throw(_staged_snapshot_exception("node_limit"))
    active = IdDict{Any,Nothing}()
    nodes = Ref(0)
    function walk(current, path::String)
        nodes[] += 1
        nodes[] <= maximum || throw(_StagedDetachFailure(nodes[], "node_limit"))
        if current === nothing || current isa Bool || current isa AbstractString
            return current isa AbstractString ? String(current) : current
        elseif current isa Integer && !(current isa Bool)
            return try
                Int(current)
            catch
                throw(_StagedDetachFailure(nodes[], path))
            end
        elseif current isa AbstractFloat
            isfinite(current) || throw(_StagedDetachFailure(nodes[], path))
            return current
        elseif current isa AbstractVector
            haskey(active, current) && throw(_StagedDetachFailure(nodes[], path))
            active[current] = nothing
            try
                return Any[
                    walk(child, "$path/$(index - 1)")
                    for (index, child) in enumerate(current)
                ]
            finally
                delete!(active, current)
            end
        elseif current isa AbstractDict
            haskey(active, current) && throw(_StagedDetachFailure(nodes[], path))
            active[current] = nothing
            try
                copy = Dict{String,Any}()
                for (key, child) in pairs(current)
                    key isa AbstractString || throw(_StagedDetachFailure(nodes[], path))
                    name = String(key)
                    if name in _STAGED_LIVE_RESULT_KEYS
                        throw(_StagedDetachFailure(nodes[], "$path/$name"))
                    end
                    copy[name] = walk(child, "$path/$name")
                end
                return copy
            finally
                delete!(active, current)
            end
        end
        throw(_StagedDetachFailure(nodes[], path))
    end
    return (value = walk(value, "<result>"), nodes = nodes[])
end

function _staged_copy_ast(value)
    try
        return _staged_detach_plain(
            value;
            maximum = typemax(Int),
        ).value
    catch error
        error isa _StagedDetachFailure || rethrow()
        throw(_staged_snapshot_exception("parent_ast"))
    end
end

function _staged_detach_result(value, plan::_StagedPreparedPlan)
    maximum = Int(plan.effective["max_result_nodes"])
    try
        detached = _staged_detach_plain(
            value;
            maximum = maximum,
        ).value
        return _staged_child_success(detached)
    catch error
        error isa _StagedDetachFailure || rethrow()
        if error.reason == "node_limit"
            return _staged_child_failure(Dict{String,Any}(
                "code" => "staged_result_node_limit_exceeded",
                "phase" => "execute",
                "stage_chain" => _staged_copy_plain(plan.sidecar["stage_chain"]),
                "job_id" => plan.sidecar["job_id"],
                "nodes" => error.nodes,
                "maximum" => maximum,
            ))
        end
        return _staged_child_failure(Dict{String,Any}(
            "code" => "staged_result_not_detached",
            "phase" => "execute",
            "stage_chain" => _staged_copy_plain(plan.sidecar["stage_chain"]),
            "job_id" => plan.sidecar["job_id"],
            "field" => error.reason,
        ))
    end
end

function _staged_portable_child_diagnostic(value)
    try
        detached = _staged_detach_plain(
            value;
            maximum = 256,
        ).value
        detached isa AbstractDict && return _staged_copy_plain(detached)
    catch error
        error isa _StagedDetachFailure || rethrow()
    end
    return Dict{String,Any}("code" => "staged_child_exception")
end

function _staged_child_failure_diagnostic(plan::_StagedPreparedPlan, child)
    return Dict{String,Any}(
        "code" => "staged_child_failed",
        "phase" => "execute",
        "stage_chain" => _staged_copy_plain(plan.sidecar["stage_chain"]),
        "job_id" => plan.sidecar["job_id"],
        "parent_ast_path" => _staged_copy_plain(plan.sidecar["parent_ast_path"]),
        "node_kind" => plan.sidecar["node_kind"],
        "payload_kind" => plan.sidecar["payload_kind"],
        "parser_spec_id" => plan.sidecar["parser_spec_id"],
        "resolved_spec_id" => plan.sidecar["resolved_spec_id"],
        "top_rule" => plan.sidecar["top_rule"],
        "cache_key" => plan.sidecar["cache_key"],
        "source_provenance" => _staged_copy_plain(plan.sidecar["provenance"]),
        "result_policy" => plan.sidecar["result_policy"],
        "failure_policy" => plan.sidecar["failure_policy"],
        "child_diagnostic" => _staged_portable_child_diagnostic(child),
    )
end

function _staged_exception_from_diagnostic(diagnostic)
    fields = Pair{String,Any}[
        String(key) => value for (key, value) in pairs(diagnostic)
        if key != "code" && key != "phase"
    ]
    return _staged_enrichment_exception(
        String(diagnostic["code"]),
        String(diagnostic["phase"]);
        fields = fields,
    )
end

function _staged_settle_failure!(working, plan, diagnostic, diagnostics)
    owned = _staged_copy_plain(diagnostic)
    push!(diagnostics, owned)
    plan.sidecar["diagnostic"] = _staged_copy_plain(owned)
    policy = plan.sidecar["failure_policy"]
    if policy == "fail"
        throw(_staged_exception_from_diagnostic(owned))
    elseif policy == "keep_text"
        plan.sidecar["state"] = "failed_keep_text"
        return _staged_materialize_text(working, plan)
    elseif policy == "diagnostic_node"
        plan.sidecar["state"] = "failed_diagnostic_node"
        return _staged_stitch_value(
            working,
            plan,
            Dict{String,Any}(
                "kind" => "staged_parse_diagnostic",
                "diagnostic" => _staged_copy_plain(owned),
            ),
        )
    end
    throw(_staged_marker_error("staged_failure_policy_invalid", plan.sidecar))
end

function _staged_child_request(plan::_StagedPreparedPlan)
    sidecar = plan.sidecar
    return _staged_copy_plain(Dict{String,Any}(
        "stage_depth" => sidecar["stage_depth"],
        "stage_chain" => sidecar["stage_chain"],
        "job_id" => sidecar["job_id"],
        "parent_ast_path" => sidecar["parent_ast_path"],
        "node_kind" => sidecar["node_kind"],
        "payload_kind" => sidecar["payload_kind"],
        "parser_spec_id" => sidecar["parser_spec_id"],
        "resolved_spec_id" => sidecar["resolved_spec_id"],
        "top_rule" => sidecar["top_rule"],
        "text" => sidecar["text"],
        "source_provenance" => sidecar["provenance"],
        "result_policy" => sidecar["result_policy"],
        "failure_policy" => sidecar["failure_policy"],
        "effective" => sidecar["effective"],
    ))
end

"""Execute exactly one complete marker depth through caller-frozen authority."""
function _enrich_staged_current_depth(
    registry::_FrozenStagedRegistry,
    ast,
    options,
)
    parsed_options = _parse_staged_enrichment_options(options)
    working = _staged_copy_ast(ast)
    discovered = _StagedDiscoveredMarker[]
    _staged_discover_markers!(working, Any[], discovered)
    plans = _StagedPreparedPlan[
        _staged_prepare_plan(registry, marker, parsed_options)
        for marker in discovered
    ]
    sort!(plans; lt = _staged_plan_lt)
    _staged_validate_prepared_depth(working, plans)

    diagnostics = Dict{String,Any}[]
    for plan in plans
        _staged_validate_stitch_target(working, plan)
        cached = _staged_cached_plan(registry, plan)
        expected_capabilities = Tuple(
            String(value) for value in plan.effective["capabilities"]
        )
        if cached.resolved_spec_id != plan.resolved_spec_id ||
                cached.top_rule != plan.top_rule ||
                cached.effective_capabilities != expected_capabilities
            throw(_staged_snapshot_exception("plan_cache"))
        end
        context = _StagedRuntimeContext()
        execution = try
            value = cached.compiled_authority(_staged_child_request(plan), context)
            value isa _StagedChildExecution ? value :
                _staged_child_failure(Dict{String,Any}(
                    "code" => "staged_child_exception",
                ))
        catch
            _staged_child_failure(Dict{String,Any}(
                "code" => "staged_child_exception",
            ))
        end
        if execution.succeeded
            detached = _staged_detach_result(execution.value, plan)
            if detached.succeeded
                working = _staged_stitch_value(working, plan, detached.value)
                plan.sidecar["state"] = "succeeded"
            else
                working = _staged_settle_failure!(
                    working,
                    plan,
                    detached.value,
                    diagnostics,
                )
            end
        else
            working = _staged_settle_failure!(
                working,
                plan,
                _staged_child_failure_diagnostic(plan, execution.value),
                diagnostics,
            )
        end
    end
    return _StagedEnrichmentOutcome(
        _staged_copy_plain(working),
        Dict{String,Any}[_staged_copy_plain(plan.sidecar) for plan in plans],
        Dict{String,Any}[_staged_copy_plain(value) for value in diagnostics],
        _staged_cache_stats(registry),
    )
end
