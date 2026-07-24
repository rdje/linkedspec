const _SEMANTIC_MODEL_ID = "linkedspec-semantic-model-v1"
const _SEMANTIC_QUERY_ID = "linkedspec-semantic-query-v1"
const _SEMANTIC_QUERY_PAGE_DEFAULT = 100
const _SEMANTIC_QUERY_PAGE_MAX = 1_000
const _SEMANTIC_QUERY_RECORD_BUDGET_DEFAULT = 1_000
const _SEMANTIC_QUERY_RELATION_BUDGET_DEFAULT = 2_000
const _SEMANTIC_QUERY_DEPTH_BUDGET_DEFAULT = 4
const _SEMANTIC_QUERY_RECORD_BUDGET_MAX = 10_000
const _SEMANTIC_QUERY_RELATION_BUDGET_MAX = 20_000
const _SEMANTIC_QUERY_DEPTH_BUDGET_MAX = 8

"""One immutable semantic-query-v1 operation; private until the complete evaluator lands."""
@enum SemanticQueryOperation begin
    SemanticQueryCapabilitiesOperation = 0
    SemanticQueryListOperation = 1
    SemanticQueryGetOperation = 2
    SemanticQueryRelationsOperation = 3
    SemanticQueryExplainOperation = 4
end

"""One immutable relation direction; private until the complete evaluator lands."""
@enum SemanticQueryDirection begin
    SemanticQueryOutgoingDirection = 0
    SemanticQueryIncomingDirection = 1
    SemanticQueryBothDirection = 2
end

const _SEMANTIC_QUERY_OPERATION_NAMES = Dict(
    SemanticQueryCapabilitiesOperation => "capabilities",
    SemanticQueryListOperation => "list",
    SemanticQueryGetOperation => "get",
    SemanticQueryRelationsOperation => "relations",
    SemanticQueryExplainOperation => "explain",
)

const _SEMANTIC_QUERY_DIRECTION_NAMES = Dict(
    SemanticQueryOutgoingDirection => "outgoing",
    SemanticQueryIncomingDirection => "incoming",
    SemanticQueryBothDirection => "both",
)

struct _SemanticQueryObject
    values::Tuple
end

struct _SemanticQueryArray
    values::Tuple
end

Base.:(==)(left::_SemanticQueryObject, right::_SemanticQueryObject) = left.values == right.values
Base.:(==)(left::_SemanticQueryArray, right::_SemanticQueryArray) = left.values == right.values
Base.hash(value::_SemanticQueryObject, seed::UInt) = hash(value.values, seed)
Base.hash(value::_SemanticQueryArray, seed::UInt) = hash(value.values, seed)

"""Canonical after-id page request."""
struct SemanticQueryPage
    after_id::Union{Nothing,String}
    limit::Int

    function SemanticQueryPage(after_id::Union{Nothing,String}, limit::Int)
        validated_limit = _semantic_query_integer(
            limit,
            "limit";
            minimum = 1,
            maximum = _SEMANTIC_QUERY_PAGE_MAX,
        )
        return new(after_id === nothing ? nothing : String(after_id), validated_limit)
    end
end

function SemanticQueryPage(; after_id = nothing, limit = _SEMANTIC_QUERY_PAGE_DEFAULT)
    if !(after_id === nothing || after_id isa AbstractString)
        throw(ArgumentError("Semantic query after_id must be text when present"))
    end
    return SemanticQueryPage(
        after_id === nothing ? nothing : String(after_id),
        _semantic_query_integer(
            limit,
            "limit";
            minimum = 1,
            maximum = _SEMANTIC_QUERY_PAGE_MAX,
        ),
    )
end

"""Logical query budgets, independent of host resource accounting."""
struct SemanticQueryBudget
    max_records::Int
    max_relations::Int
    max_depth::Int

    function SemanticQueryBudget(max_records::Int, max_relations::Int, max_depth::Int)
        return new(
            _semantic_query_integer(
                max_records,
                "max_records";
                minimum = 1,
                maximum = _SEMANTIC_QUERY_RECORD_BUDGET_MAX,
            ),
            _semantic_query_integer(
                max_relations,
                "max_relations";
                minimum = 1,
                maximum = _SEMANTIC_QUERY_RELATION_BUDGET_MAX,
            ),
            _semantic_query_integer(
                max_depth,
                "max_depth";
                minimum = 0,
                maximum = _SEMANTIC_QUERY_DEPTH_BUDGET_MAX,
            ),
        )
    end
end

function SemanticQueryBudget(;
    max_records = _SEMANTIC_QUERY_RECORD_BUDGET_DEFAULT,
    max_relations = _SEMANTIC_QUERY_RELATION_BUDGET_DEFAULT,
    max_depth = _SEMANTIC_QUERY_DEPTH_BUDGET_DEFAULT,
)
    return SemanticQueryBudget(
        _semantic_query_integer(
            max_records,
            "max_records";
            minimum = 1,
            maximum = _SEMANTIC_QUERY_RECORD_BUDGET_MAX,
        ),
        _semantic_query_integer(
            max_relations,
            "max_relations";
            minimum = 1,
            maximum = _SEMANTIC_QUERY_RELATION_BUDGET_MAX,
        ),
        _semantic_query_integer(
            max_depth,
            "max_depth";
            minimum = 0,
            maximum = _SEMANTIC_QUERY_DEPTH_BUDGET_MAX,
        ),
    )
end

"""Query-selected source projection beneath the construction ceiling."""
struct SemanticQuerySource
    detail::SemanticSourceDetail
    include_content_digest::Bool
end

function SemanticQuerySource(;
    detail = SemanticSourceNoneDetail,
    include_content_digest = false,
)
    if !(detail isa SemanticSourceDetail)
        throw(ArgumentError("Semantic query source detail must be none, identity, span, or text"))
    end
    if !(include_content_digest isa Bool)
        throw(ArgumentError("Semantic query include_content_digest must be Boolean"))
    end
    return SemanticQuerySource(detail, include_content_digest)
end

"""Strongly typed immutable semantic-query-v1 request."""
struct _SemanticQueryConstructionToken end
const _SEMANTIC_QUERY_CONSTRUCTION_TOKEN = _SemanticQueryConstructionToken()

struct SemanticQuery
    contract::String
    operation::SemanticQueryOperation
    subjects::Tuple
    record_kinds::Tuple
    relation_kinds::Tuple
    direction::SemanticQueryDirection
    page::SemanticQueryPage
    budget::SemanticQueryBudget
    source::SemanticQuerySource

    function SemanticQuery(
        ::_SemanticQueryConstructionToken,
        contract::String,
        operation::SemanticQueryOperation,
        subjects::Tuple,
        record_kinds::Tuple,
        relation_kinds::Tuple,
        direction::SemanticQueryDirection,
        page::SemanticQueryPage,
        budget::SemanticQueryBudget,
        source::SemanticQuerySource,
    )
        return new(
            contract,
            operation,
            subjects,
            record_kinds,
            relation_kinds,
            direction,
            page,
            budget,
            source,
        )
    end
end

function SemanticQuery(
    operation::SemanticQueryOperation;
    contract = _SEMANTIC_QUERY_ID,
    subjects = (),
    record_kinds = (),
    relation_kinds = (),
    direction = SemanticQueryOutgoingDirection,
    page = SemanticQueryPage(),
    budget = SemanticQueryBudget(),
    source = SemanticQuerySource(),
)
    if !(contract isa AbstractString)
        throw(ArgumentError("Semantic query contract must be text"))
    end
    if !(direction isa SemanticQueryDirection)
        throw(ArgumentError("Semantic query direction is invalid"))
    end
    if !(page isa SemanticQueryPage)
        throw(ArgumentError("Semantic query page must be SemanticQueryPage"))
    end
    if !(budget isa SemanticQueryBudget)
        throw(ArgumentError("Semantic query budget must be SemanticQueryBudget"))
    end
    if !(source isa SemanticQuerySource)
        throw(ArgumentError("Semantic query source must be SemanticQuerySource"))
    end
    return SemanticQuery(
        _SEMANTIC_QUERY_CONSTRUCTION_TOKEN,
        String(contract),
        operation,
        _semantic_query_string_tuple(subjects, "subjects"),
        _semantic_query_string_tuple(record_kinds, "record_kinds"),
        _semantic_query_string_tuple(relation_kinds, "relation_kinds"),
        direction,
        page,
        budget,
        source,
    )
end

SemanticQuery(; operation, kwargs...) = SemanticQuery(operation; kwargs...)

"""Source reference after query-time privacy projection."""
struct SemanticQuerySourceReference
    source_id::String
    logical_name::String
    span::Union{Nothing,SemanticSourceSpan}
    excerpt::Union{Nothing,String}
    content_digest::Union{Nothing,String}
    provenance_ids::Tuple
end

"""One immutable semantic model record."""
struct SemanticQueryRecord
    id::String
    kind::String
    name::Union{Nothing,String}
    owner_id::Union{Nothing,String}
    order::Int
    source::Union{Nothing,SemanticQuerySourceReference}
    facts::_SemanticQueryObject
    redactions::Tuple
end

"""One immutable semantic model relation."""
struct SemanticQueryRelation
    id::String
    kind::String
    from_id::String
    to_id::String
    order::Int
    source::Union{Nothing,SemanticQuerySourceReference}
    facts::_SemanticQueryObject
    evidence_ids::Tuple
end

"""Portable query diagnostic, distinct from compilation/runtime records."""
struct SemanticQueryDiagnostic
    code::String
    severity::String
    message::String
    fields::_SemanticQueryObject
end

"""Canonical response paging state."""
struct SemanticQueryPageState
    after_id::Any
    next_after_id::Union{Nothing,String}
    complete::Bool
end

"""Logical model cost reported by one query."""
struct SemanticQueryCost
    records_examined::Int
    relations_examined::Int
    depth_reached::Int
end

"""Exact immutable semantic-query-v1 response envelope."""
struct SemanticQueryResponse
    contract::String
    model::String
    ok::Bool
    snapshot::SemanticSnapshot
    records::Tuple
    relations::Tuple
    page::SemanticQueryPageState
    cost::SemanticQueryCost
    diagnostics::Tuple
end

struct _SemanticQueryPageResult
    selected::Tuple
    page::SemanticQueryPageState
    limited_by_budget::Bool
end

struct _SemanticQueryTraversal
    relations::Tuple
    depth_by_id::Dict{String,Int}
    depth_limited::Bool
end

Base.:(==)(left::SemanticQueryPage, right::SemanticQueryPage) =
    left.after_id == right.after_id && left.limit == right.limit
Base.:(==)(left::SemanticQueryBudget, right::SemanticQueryBudget) =
    left.max_records == right.max_records &&
    left.max_relations == right.max_relations &&
    left.max_depth == right.max_depth
Base.:(==)(left::SemanticQuerySource, right::SemanticQuerySource) =
    left.detail == right.detail &&
    left.include_content_digest == right.include_content_digest
Base.:(==)(left::SemanticQuery, right::SemanticQuery) =
    left.contract == right.contract &&
    left.operation == right.operation &&
    left.subjects == right.subjects &&
    left.record_kinds == right.record_kinds &&
    left.relation_kinds == right.relation_kinds &&
    left.direction == right.direction &&
    left.page == right.page &&
    left.budget == right.budget &&
    left.source == right.source
Base.:(==)(left::SemanticQuerySourceReference, right::SemanticQuerySourceReference) =
    left.source_id == right.source_id &&
    left.logical_name == right.logical_name &&
    left.span == right.span &&
    left.excerpt == right.excerpt &&
    left.content_digest == right.content_digest &&
    left.provenance_ids == right.provenance_ids
Base.:(==)(left::SemanticQueryRecord, right::SemanticQueryRecord) =
    left.id == right.id &&
    left.kind == right.kind &&
    left.name == right.name &&
    left.owner_id == right.owner_id &&
    left.order == right.order &&
    left.source == right.source &&
    left.facts == right.facts &&
    left.redactions == right.redactions
Base.:(==)(left::SemanticQueryRelation, right::SemanticQueryRelation) =
    left.id == right.id &&
    left.kind == right.kind &&
    left.from_id == right.from_id &&
    left.to_id == right.to_id &&
    left.order == right.order &&
    left.source == right.source &&
    left.facts == right.facts &&
    left.evidence_ids == right.evidence_ids
Base.:(==)(left::SemanticQueryDiagnostic, right::SemanticQueryDiagnostic) =
    left.code == right.code &&
    left.severity == right.severity &&
    left.message == right.message &&
    left.fields == right.fields
Base.:(==)(left::SemanticQueryPageState, right::SemanticQueryPageState) =
    left.after_id == right.after_id &&
    left.next_after_id == right.next_after_id &&
    left.complete == right.complete
Base.:(==)(left::SemanticQueryCost, right::SemanticQueryCost) =
    left.records_examined == right.records_examined &&
    left.relations_examined == right.relations_examined &&
    left.depth_reached == right.depth_reached
Base.:(==)(left::SemanticQueryResponse, right::SemanticQueryResponse) =
    left.contract == right.contract &&
    left.model == right.model &&
    left.ok == right.ok &&
    left.snapshot == right.snapshot &&
    left.records == right.records &&
    left.relations == right.relations &&
    left.page == right.page &&
    left.cost == right.cost &&
    left.diagnostics == right.diagnostics

Base.hash(value::SemanticQueryPage, seed::UInt) = hash((value.after_id, value.limit), seed)
Base.hash(value::SemanticQueryBudget, seed::UInt) =
    hash((value.max_records, value.max_relations, value.max_depth), seed)
Base.hash(value::SemanticQuerySource, seed::UInt) =
    hash((value.detail, value.include_content_digest), seed)
Base.hash(value::SemanticQuery, seed::UInt) = hash(
    (
        value.contract,
        value.operation,
        value.subjects,
        value.record_kinds,
        value.relation_kinds,
        value.direction,
        value.page,
        value.budget,
        value.source,
    ),
    seed,
)
Base.hash(value::SemanticQuerySourceReference, seed::UInt) = hash(
    (
        value.source_id,
        value.logical_name,
        value.span,
        value.excerpt,
        value.content_digest,
        value.provenance_ids,
    ),
    seed,
)
Base.hash(value::SemanticQueryRecord, seed::UInt) = hash(
    (
        value.id,
        value.kind,
        value.name,
        value.owner_id,
        value.order,
        value.source,
        value.facts,
        value.redactions,
    ),
    seed,
)
Base.hash(value::SemanticQueryRelation, seed::UInt) = hash(
    (
        value.id,
        value.kind,
        value.from_id,
        value.to_id,
        value.order,
        value.source,
        value.facts,
        value.evidence_ids,
    ),
    seed,
)
Base.hash(value::SemanticQueryDiagnostic, seed::UInt) =
    hash((value.code, value.severity, value.message, value.fields), seed)
Base.hash(value::SemanticQueryPageState, seed::UInt) =
    hash((value.after_id, value.next_after_id, value.complete), seed)
Base.hash(value::SemanticQueryCost, seed::UInt) =
    hash((value.records_examined, value.relations_examined, value.depth_reached), seed)
Base.hash(value::SemanticQueryResponse, seed::UInt) = hash(
    (
        value.contract,
        value.model,
        value.ok,
        value.snapshot,
        value.records,
        value.relations,
        value.page,
        value.cost,
        value.diagnostics,
    ),
    seed,
)

function to_json(page::SemanticQueryPage)
    return Dict{String,Any}("after_id" => page.after_id, "limit" => page.limit)
end

function to_json(budget::SemanticQueryBudget)
    return Dict{String,Any}(
        "max_records" => budget.max_records,
        "max_relations" => budget.max_relations,
        "max_depth" => budget.max_depth,
    )
end

function to_json(source::SemanticQuerySource)
    return Dict{String,Any}(
        "detail" => _semantic_source_detail_name(source.detail),
        "include_content_digest" => source.include_content_digest,
    )
end

function to_json(request::SemanticQuery)
    return Dict{String,Any}(
        "contract" => request.contract,
        "operation" => _SEMANTIC_QUERY_OPERATION_NAMES[request.operation],
        "subjects" => Any[String(value) for value in request.subjects],
        "record_kinds" => Any[String(value) for value in request.record_kinds],
        "relation_kinds" => Any[String(value) for value in request.relation_kinds],
        "direction" => _SEMANTIC_QUERY_DIRECTION_NAMES[request.direction],
        "page" => to_json(request.page),
        "budget" => to_json(request.budget),
        "source" => to_json(request.source),
    )
end

function to_json(source::SemanticQuerySourceReference)
    return Dict{String,Any}(
        "source_id" => source.source_id,
        "logical_name" => source.logical_name,
        "span" => source.span === nothing ? nothing : to_json(source.span),
        "excerpt" => source.excerpt,
        "content_digest" => source.content_digest,
        "provenance_ids" => Any[String(value) for value in source.provenance_ids],
    )
end

function to_json(record::SemanticQueryRecord)
    return Dict{String,Any}(
        "id" => record.id,
        "kind" => record.kind,
        "name" => record.name,
        "owner_id" => record.owner_id,
        "order" => record.order,
        "source" => record.source === nothing ? nothing : to_json(record.source),
        "facts" => _semantic_query_thaw(record.facts),
        "redactions" => Any[String(value) for value in record.redactions],
    )
end

function to_json(relation::SemanticQueryRelation)
    return Dict{String,Any}(
        "id" => relation.id,
        "kind" => relation.kind,
        "from_id" => relation.from_id,
        "to_id" => relation.to_id,
        "order" => relation.order,
        "source" => relation.source === nothing ? nothing : to_json(relation.source),
        "facts" => _semantic_query_thaw(relation.facts),
        "evidence_ids" => Any[String(value) for value in relation.evidence_ids],
    )
end

function to_json(diagnostic::SemanticQueryDiagnostic)
    return Dict{String,Any}(
        "code" => diagnostic.code,
        "severity" => diagnostic.severity,
        "message" => diagnostic.message,
        "fields" => _semantic_query_thaw(diagnostic.fields),
    )
end

function to_json(page::SemanticQueryPageState)
    return Dict{String,Any}(
        "after_id" => _semantic_query_thaw(page.after_id),
        "next_after_id" => page.next_after_id,
        "complete" => page.complete,
    )
end

function to_json(cost::SemanticQueryCost)
    return Dict{String,Any}(
        "records_examined" => cost.records_examined,
        "relations_examined" => cost.relations_examined,
        "depth_reached" => cost.depth_reached,
    )
end

function to_json(response::SemanticQueryResponse)
    return Dict{String,Any}(
        "contract" => response.contract,
        "model" => response.model,
        "ok" => response.ok,
        "snapshot" => to_json(response.snapshot),
        "records" => Any[to_json(record) for record in response.records],
        "relations" => Any[to_json(relation) for relation in response.relations],
        "page" => to_json(response.page),
        "cost" => to_json(response.cost),
        "diagnostics" => Any[to_json(diagnostic) for diagnostic in response.diagnostics],
    )
end

"""Private projection-only evaluator; public query names remain absent until completion."""
function _semantic_query_kernel(index::SemanticIndex, request::SemanticQuery)
    projection = _semantic_static_projection_materialize(index)
    return _semantic_query_kernel_evaluate(projection, request)
end

function _semantic_query_kernel_evaluate(
    projection::Dict{String,Any},
    request::SemanticQuery,
)
    snapshot = _semantic_query_snapshot(projection["snapshot"])
    request_error = _semantic_query_kernel_request_error(snapshot, request)
    request_error === nothing || return request_error

    records = projection["records"]
    relations = projection["relations"]
    if !(records isa AbstractVector && relations isa AbstractVector)
        throw(AssertionError("Semantic query projection streams must be arrays"))
    end
    record_by_id = Dict{String,Dict{String,Any}}(
        String(record["id"]) => record for record in records
    )
    if (request.operation == SemanticQueryGetOperation ||
        request.operation == SemanticQueryRelationsOperation) &&
       any(subject -> !haskey(record_by_id, subject), request.subjects)
        return _semantic_query_rejected_response(
            snapshot,
            request,
            _semantic_query_diagnostic(
                "semantic_query_invalid";
                reason = "unknown_subject",
            ),
        )
    end

    selected_records = SemanticQueryRecord[]
    selected_relations = SemanticQueryRelation[]
    record_cost = 0
    relation_cost = 0
    depth_reached = 0
    page = SemanticQueryPageState(request.page.after_id, nothing, true)
    budget_reason = nothing

    if request.operation == SemanticQueryCapabilitiesOperation
        paged = _semantic_query_page_stream(
            [_semantic_query_capabilities_record(snapshot)],
            request,
            request.budget.max_records,
            record -> record.id,
        )
        paged === nothing && return _semantic_query_invalid_after_id(snapshot, request)
        append!(selected_records, paged.selected)
        page = paged.page
        record_cost = length(selected_records)
        paged.limited_by_budget && (budget_reason = "max_records")
    elseif request.operation == SemanticQueryListOperation
        wanted = Set(request.record_kinds)
        candidates = Any[
            record for record in records if isempty(wanted) || record["kind"] in wanted
        ]
        paged = _semantic_query_page_stream(
            candidates,
            request,
            request.budget.max_records,
            record -> String(record["id"]),
        )
        paged === nothing && return _semantic_query_invalid_after_id(snapshot, request)
        append!(
            selected_records,
            (
                _semantic_query_project_record(record, projection, request.source) for
                record in paged.selected
            ),
        )
        page = paged.page
        record_cost = length(selected_records)
        paged.limited_by_budget && (budget_reason = "max_records")
    elseif request.operation == SemanticQueryGetOperation
        wanted = Set(request.subjects)
        candidates = Any[record for record in records if record["id"] in wanted]
        paged = _semantic_query_page_stream(
            candidates,
            request,
            request.budget.max_records,
            record -> String(record["id"]),
        )
        paged === nothing && return _semantic_query_invalid_after_id(snapshot, request)
        append!(
            selected_records,
            (
                _semantic_query_project_record(record, projection, request.source) for
                record in paged.selected
            ),
        )
        page = paged.page
        record_cost = length(selected_records)
        paged.limited_by_budget && (budget_reason = "max_records")
    elseif request.operation == SemanticQueryRelationsOperation
        traversal = _semantic_query_traverse_relations(relations, request)
        paged = _semantic_query_page_stream(
            traversal.relations,
            request,
            request.budget.max_relations,
            relation -> String(relation["id"]),
        )
        paged === nothing && return _semantic_query_invalid_after_id(snapshot, request)
        append!(
            selected_relations,
            (
                _semantic_query_project_relation(relation, projection, request.source) for
                relation in paged.selected
            ),
        )
        page = paged.page
        relation_cost = length(selected_relations)
        for relation in paged.selected
            relation_depth = traversal.depth_by_id[String(relation["id"])]
            depth_reached = max(depth_reached, relation_depth)
        end
        if paged.limited_by_budget
            budget_reason = "max_relations"
        elseif traversal.depth_limited
            budget_reason = "max_depth"
        end
    elseif request.operation == SemanticQueryExplainOperation
        decision = _semantic_query_explain_decision(records, record_by_id, only(request.subjects))
        if decision === nothing
            return _semantic_query_rejected_response(
                snapshot,
                request,
                _semantic_query_diagnostic(
                    "semantic_query_invalid";
                    reason = "not_explainable",
                ),
            )
        end
        decision_id = String(decision["id"])
        steps = Dict{String,Any}[
            record for record in records if
            record["kind"] == "explanation_step" && record["owner_id"] == decision_id
        ]
        paged = _semantic_query_page_stream(
            steps,
            request,
            request.budget.max_records - 1,
            record -> String(record["id"]),
        )
        paged === nothing && return _semantic_query_invalid_after_id(snapshot, request)
        push!(
            selected_records,
            _semantic_query_project_record(decision, projection, request.source),
        )
        append!(
            selected_records,
            (
                _semantic_query_project_record(step, projection, request.source) for
                step in paged.selected
            ),
        )
        step_ids = Set(String(step["id"]) for step in paged.selected)
        for relation in relations
            if relation["kind"] == "explained_by" &&
               relation["from_id"] == decision_id &&
               relation["to_id"] in step_ids
                push!(
                    selected_relations,
                    _semantic_query_project_relation(relation, projection, request.source),
                )
            end
        end
        page = paged.page
        record_cost = length(selected_records)
        relation_cost = length(selected_relations)
        depth_reached = isempty(paged.selected) ? 0 : 1
        paged.limited_by_budget && (budget_reason = "max_records")
    end

    diagnostics = SemanticQueryDiagnostic[]
    if budget_reason !== nothing
        page = SemanticQueryPageState(page.after_id, page.next_after_id, false)
        push!(
            diagnostics,
            _semantic_query_diagnostic(
                "semantic_query_budget_exceeded";
                reason = budget_reason,
            ),
        )
    end

    return SemanticQueryResponse(
        _SEMANTIC_QUERY_ID,
        _SEMANTIC_MODEL_ID,
        true,
        snapshot,
        Tuple(selected_records),
        Tuple(selected_relations),
        page,
        SemanticQueryCost(record_cost, relation_cost, depth_reached),
        Tuple(diagnostics),
    )
end

function _semantic_query_kernel_request_error(
    snapshot::SemanticSnapshot,
    request::SemanticQuery,
)
    if request.contract != _SEMANTIC_QUERY_ID
        return _semantic_query_rejected_response(
            snapshot,
            request,
            _semantic_query_diagnostic(
                "semantic_query_contract_unsupported";
                requested = request.contract,
            ),
        )
    end
    if request.source.include_content_digest && request.source.detail != SemanticSourceTextDetail
        return _semantic_query_rejected_response(
            snapshot,
            request,
            _semantic_query_diagnostic(
                "semantic_query_invalid";
                reason = "digest_requires_text",
            ),
        )
    end
    ceiling_error = _semantic_query_source_ceiling_error(snapshot, request)
    ceiling_error === nothing || return ceiling_error

    valid_combination = if request.operation == SemanticQueryCapabilitiesOperation ||
                           request.operation == SemanticQueryListOperation
        isempty(request.subjects) && isempty(request.relation_kinds)
    elseif request.operation == SemanticQueryGetOperation
        !isempty(request.subjects) &&
        isempty(request.record_kinds) &&
        isempty(request.relation_kinds)
    elseif request.operation == SemanticQueryRelationsOperation
        !isempty(request.subjects) && isempty(request.record_kinds)
    else
        length(request.subjects) == 1 &&
        isempty(request.record_kinds) &&
        isempty(request.relation_kinds)
    end
    if !valid_combination
        return _semantic_query_rejected_response(
            snapshot,
            request,
            _semantic_query_diagnostic(
                "semantic_query_invalid";
                reason = "operation_combination",
            ),
        )
    end
    if request.operation == SemanticQueryCapabilitiesOperation &&
       !isempty(request.record_kinds)
        return _semantic_query_rejected_response(
            snapshot,
            request,
            _semantic_query_diagnostic(
                "semantic_query_invalid";
                reason = "capability_filter",
            ),
        )
    end
    return nothing
end

function _semantic_query_page_stream(items, request::SemanticQuery, budget_limit::Int, id)
    start = 1
    if request.page.after_id !== nothing
        cursor = findfirst(item -> id(item) == request.page.after_id, items)
        cursor === nothing && return nothing
        start = cursor + 1
    end
    remaining = start > length(items) ? Any[] : Any[items[index] for index in start:length(items)]
    limited_by_budget = length(remaining) > budget_limit
    selected_count = min(length(remaining), min(request.page.limit, budget_limit))
    selected = selected_count == 0 ? () : Tuple(remaining[1:selected_count])
    complete = selected_count == length(remaining) && !limited_by_budget
    next_after_id = !isempty(selected) && !complete ? String(id(last(selected))) : nothing
    return _SemanticQueryPageResult(
        selected,
        SemanticQueryPageState(request.page.after_id, next_after_id, complete),
        limited_by_budget,
    )
end

function _semantic_query_traverse_relations(relations, request::SemanticQuery)
    wanted_kinds = Set(request.relation_kinds)
    frontier = Set(request.subjects)
    visited = copy(frontier)
    depth_by_id = Dict{String,Int}()

    for depth in 1:request.budget.max_depth
        layer = _semantic_query_relation_layer(
            relations,
            frontier,
            wanted_kinds,
            request.direction,
            Set(keys(depth_by_id)),
        )
        isempty(layer) && break
        next_frontier = Set{String}()
        for relation in layer
            relation_id = String(relation["id"])
            from_id = String(relation["from_id"])
            to_id = String(relation["to_id"])
            depth_by_id[relation_id] = depth
            if (request.direction == SemanticQueryOutgoingDirection ||
                request.direction == SemanticQueryBothDirection) && from_id in frontier
                push!(next_frontier, to_id)
            end
            if (request.direction == SemanticQueryIncomingDirection ||
                request.direction == SemanticQueryBothDirection) && to_id in frontier
                push!(next_frontier, from_id)
            end
        end
        setdiff!(next_frontier, visited)
        union!(visited, next_frontier)
        frontier = next_frontier
        isempty(frontier) && break
    end

    depth_limited = !isempty(frontier) && !isempty(_semantic_query_relation_layer(
        relations,
        frontier,
        wanted_kinds,
        request.direction,
        Set(keys(depth_by_id)),
    ))
    selected = Tuple(
        relation for relation in relations if haskey(depth_by_id, String(relation["id"]))
    )
    return _SemanticQueryTraversal(selected, depth_by_id, depth_limited)
end

function _semantic_query_relation_layer(
    relations,
    frontier,
    wanted_kinds,
    direction::SemanticQueryDirection,
    selected_ids,
)
    return Any[
        relation for relation in relations if begin
            id = String(relation["id"])
            kind = String(relation["kind"])
            from_id = String(relation["from_id"])
            to_id = String(relation["to_id"])
            kind_matches = isempty(wanted_kinds) || kind in wanted_kinds
            outgoing = (direction == SemanticQueryOutgoingDirection ||
                        direction == SemanticQueryBothDirection) && from_id in frontier
            incoming = (direction == SemanticQueryIncomingDirection ||
                        direction == SemanticQueryBothDirection) && to_id in frontier
            kind_matches && (outgoing || incoming) && !(id in selected_ids)
        end
    ]
end

function _semantic_query_invalid_after_id(
    snapshot::SemanticSnapshot,
    request::SemanticQuery,
)
    return _semantic_query_rejected_response(
        snapshot,
        request,
        _semantic_query_diagnostic(
            "semantic_query_invalid";
            reason = "after_id_not_in_primary_stream",
        ),
    )
end

function _semantic_query_snapshot(value)
    if !(value isa AbstractDict)
        throw(AssertionError("Semantic query projection snapshot must be an object"))
    end
    state = if value["state"] == "compiled"
        SemanticCompiledSnapshotState
    elseif value["state"] == "failed_compilation"
        SemanticFailedCompilationSnapshotState
    else
        throw(AssertionError("Semantic query projection snapshot state is invalid"))
    end
    return SemanticSnapshot(
        String(value["id"]),
        state,
        Bool(value["has_execution"]),
        _semantic_query_source_detail(value["source_detail_ceiling"]),
        Bool(value["content_digest_available"]),
    )
end

function _semantic_query_source_ceiling_error(
    snapshot::SemanticSnapshot,
    request::SemanticQuery,
)
    requested = request.source.detail
    if Int(requested) <= Int(snapshot.source_detail_ceiling) &&
       (!request.source.include_content_digest || snapshot.content_digest_available)
        return nothing
    end
    return _semantic_query_rejected_response(
        snapshot,
        request,
        _semantic_query_diagnostic(
            "semantic_query_source_detail_forbidden";
            reason = _semantic_source_detail_name(snapshot.source_detail_ceiling),
            requested = _semantic_source_detail_name(requested),
        ),
    )
end

function _semantic_query_capabilities_record(snapshot::SemanticSnapshot)
    return _semantic_query_record(
        id = "capabilities:0",
        kind = "capabilities",
        name = "semantic introspection v1",
        owner_id = nothing,
        order = 0,
        source = nothing,
        facts = Dict{String,Any}(
            "model_ids" => Any[_SEMANTIC_MODEL_ID],
            "query_ids" => Any[_SEMANTIC_QUERY_ID],
            "record_kinds" => Any[_SEMANTIC_STATIC_RECORD_KINDS...],
            "relation_kinds" => Any[_SEMANTIC_STATIC_RELATION_KINDS...],
            "source_detail_ceiling" => _semantic_source_detail_name(
                snapshot.source_detail_ceiling,
            ),
            "page_default" => _SEMANTIC_QUERY_PAGE_DEFAULT,
            "page_max" => _SEMANTIC_QUERY_PAGE_MAX,
            "budget_defaults" => Dict{String,Any}(
                "max_records" => _SEMANTIC_QUERY_RECORD_BUDGET_DEFAULT,
                "max_relations" => _SEMANTIC_QUERY_RELATION_BUDGET_DEFAULT,
                "max_depth" => _SEMANTIC_QUERY_DEPTH_BUDGET_DEFAULT,
            ),
            "budget_maxima" => Dict{String,Any}(
                "max_records" => _SEMANTIC_QUERY_RECORD_BUDGET_MAX,
                "max_relations" => _SEMANTIC_QUERY_RELATION_BUDGET_MAX,
                "max_depth" => _SEMANTIC_QUERY_DEPTH_BUDGET_MAX,
            ),
            "execution_observation" => snapshot.has_execution,
            "features" => Any[],
        ),
        redactions = (),
    )
end

function _semantic_query_project_record(record, projection, policy::SemanticQuerySource)
    facts = Dict{String,Any}(String(key) => value for (key, value) in record["facts"])
    sensitive = if record["kind"] == "regex_slot"
        ("pattern", "/facts/pattern")
    elseif record["kind"] == "diagnostic"
        ("message", "/facts/message")
    elseif record["kind"] == "explanation_step"
        ("summary", "/facts/summary")
    else
        nothing
    end
    redactions = _semantic_query_string_tuple(record["redactions"], "redactions")
    if policy.detail != SemanticSourceTextDetail && sensitive !== nothing
        facts[first(sensitive)] = nothing
        redactions = (last(sensitive),)
    end
    return _semantic_query_record(
        id = record["id"],
        kind = record["kind"],
        name = record["name"],
        owner_id = record["owner_id"],
        order = record["order"],
        source = _semantic_query_project_source(record["source"], projection, policy),
        facts = facts,
        redactions = redactions,
    )
end

function _semantic_query_project_relation(relation, projection, policy::SemanticQuerySource)
    return SemanticQueryRelation(
        String(relation["id"]),
        String(relation["kind"]),
        String(relation["from_id"]),
        String(relation["to_id"]),
        Int(relation["order"]),
        _semantic_query_project_source(relation["source"], projection, policy),
        _semantic_query_object(relation["facts"]),
        _semantic_query_string_tuple(relation["evidence_ids"], "evidence_ids"),
    )
end

function _semantic_query_project_source(source_key, projection, policy::SemanticQuerySource)
    if source_key === nothing || policy.detail == SemanticSourceNoneDetail
        return nothing
    end
    source_refs = projection["source_refs"]
    source = get(source_refs, String(source_key), nothing)
    source === nothing && throw(AssertionError(
        "Semantic query record references an unknown source",
    ))
    span = if Int(policy.detail) >= Int(SemanticSourceSpanDetail)
        _semantic_query_span(source["span"])
    else
        nothing
    end
    excerpt = policy.detail == SemanticSourceTextDetail ? String(source["excerpt"]) : nothing
    content_digest = if policy.detail == SemanticSourceTextDetail &&
                        policy.include_content_digest
        String(source["content_digest"])
    else
        nothing
    end
    return SemanticQuerySourceReference(
        String(source["source_id"]),
        String(source["logical_name"]),
        span,
        excerpt,
        content_digest,
        _semantic_query_string_tuple(source["provenance_ids"], "provenance_ids"),
    )
end

function _semantic_query_explain_decision(records, record_by_id, subject::String)
    direct = get(record_by_id, subject, nothing)
    if direct !== nothing && direct["kind"] == "decision"
        return direct
    end
    owned = [
        record for record in records if
        record["kind"] == "decision" && record["owner_id"] == subject
    ]
    return length(owned) == 1 ? only(owned) : nothing
end

function _semantic_query_record(;
    id,
    kind,
    name,
    owner_id,
    order,
    source,
    facts,
    redactions,
)
    return SemanticQueryRecord(
        String(id),
        String(kind),
        name === nothing ? nothing : String(name),
        owner_id === nothing ? nothing : String(owner_id),
        Int(order),
        source,
        _semantic_query_object(facts),
        _semantic_query_string_tuple(redactions, "redactions"),
    )
end

function _semantic_query_diagnostic(code; reason = nothing, requested = nothing)
    if code == "semantic_query_budget_exceeded"
        return SemanticQueryDiagnostic(
            String(code),
            "warning",
            "Semantic query budget was reached; returning the deterministic prefix.",
            _semantic_query_object(Dict{String,Any}("limit" => reason)),
        )
    elseif code == "semantic_query_contract_unsupported"
        return SemanticQueryDiagnostic(
            String(code),
            "error",
            "Unsupported semantic query contract.",
            _semantic_query_object(Dict{String,Any}(
                "requested" => requested,
                "supported" => Any[_SEMANTIC_QUERY_ID],
            )),
        )
    elseif code == "semantic_query_source_detail_forbidden"
        return SemanticQueryDiagnostic(
            String(code),
            "error",
            "Requested source detail exceeds the index ceiling.",
            _semantic_query_object(Dict{String,Any}(
                "requested" => requested,
                "ceiling" => reason,
            )),
        )
    end
    return SemanticQueryDiagnostic(
        "semantic_query_invalid",
        "error",
        "Invalid semantic query request.",
        _semantic_query_object(Dict{String,Any}("reason" => reason)),
    )
end

function _semantic_query_rejected_response(
    snapshot::SemanticSnapshot,
    request::SemanticQuery,
    diagnostic::SemanticQueryDiagnostic,
)
    return SemanticQueryResponse(
        _SEMANTIC_QUERY_ID,
        _SEMANTIC_MODEL_ID,
        false,
        snapshot,
        (),
        (),
        SemanticQueryPageState(request.page.after_id, nothing, true),
        SemanticQueryCost(0, 0, 0),
        (diagnostic,),
    )
end

function _semantic_query_span(value)
    if !(value isa AbstractDict)
        throw(AssertionError("Semantic query source span must be an object"))
    end
    return SemanticSourceSpan(
        Int(value["start_byte"]),
        Int(value["end_byte"]),
        Int(value["start_line"]),
        Int(value["start_column"]),
        Int(value["end_line"]),
        Int(value["end_column"]),
    )
end

function _semantic_query_source_detail(value)
    value == "none" && return SemanticSourceNoneDetail
    value == "identity" && return SemanticSourceIdentityDetail
    value == "span" && return SemanticSourceSpanDetail
    value == "text" && return SemanticSourceTextDetail
    throw(AssertionError("Semantic query source detail is invalid"))
end

function _semantic_query_integer(value, field; minimum, maximum)
    if value isa Bool || !(value isa Integer)
        throw(ArgumentError("Semantic query $field must be an integer and not Boolean"))
    end
    converted = try
        Int(value)
    catch error
        if error isa InexactError || error isa OverflowError
            throw(ArgumentError("Semantic query $field is outside the supported integer range"))
        end
        rethrow()
    end
    if converted < minimum || converted > maximum
        throw(ArgumentError("Semantic query $field is outside the supported range"))
    end
    return converted
end

function _semantic_query_string_tuple(values, field)
    if !(values isa AbstractVector || values isa Tuple)
        throw(ArgumentError("Semantic query $field must be an array of text"))
    end
    result = String[]
    for value in values
        value isa AbstractString || throw(ArgumentError(
            "Semantic query $field must contain only text",
        ))
        push!(result, String(value))
    end
    return Tuple(result)
end

function _semantic_query_object(value)
    frozen = _semantic_query_freeze(value)
    frozen isa _SemanticQueryObject || throw(ArgumentError(
        "Semantic query object value must be a string-keyed object",
    ))
    return frozen
end

function _semantic_query_freeze(value::AbstractDict)
    pairs = Pair{String,Any}[]
    for (key, item) in value
        key isa AbstractString || throw(ArgumentError(
            "Semantic query object keys must be text",
        ))
        push!(pairs, String(key) => _semantic_query_freeze(item))
    end
    sort!(pairs; by = first)
    return _SemanticQueryObject(Tuple(pairs))
end

function _semantic_query_freeze(value::Union{AbstractVector,Tuple})
    return _SemanticQueryArray(Tuple(_semantic_query_freeze(item) for item in value))
end

_semantic_query_freeze(value::AbstractString) = String(value)
_semantic_query_freeze(value::Union{Nothing,Bool,Integer,AbstractFloat}) = value

function _semantic_query_freeze(value)
    throw(ArgumentError("Semantic query value contains unsupported host type $(typeof(value))"))
end

function _semantic_query_thaw(value::_SemanticQueryObject)
    return Dict{String,Any}(
        key => _semantic_query_thaw(item) for (key, item) in value.values
    )
end

function _semantic_query_thaw(value::_SemanticQueryArray)
    return Any[_semantic_query_thaw(item) for item in value.values]
end

_semantic_query_thaw(value::AbstractString) = String(value)
_semantic_query_thaw(value) = value
