const ACTION_IR_BODY_SPEC_ID = "actionir-body.spec"
const ACTION_IR_BODY_TOP_RULE = "action_block"
const ACTION_IR_BODY_RESOLVED_SPEC_ID = "builtin:actionir-body.spec"
const ACTION_IR_BODY_ADAPTER_DIGEST =
    "sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c"

const _ACTION_IR_BODY_ADAPTER_SOURCE = "linkedspec:staged-parser/actionir-body:v1"
const _SPEC_LANGUAGE_VERSION = "spec-language-v1"
const _HELPER_ACTION_CONTRACT_VERSION = "actionir-v1"
const _STAGED_PARSING_CONTRACT_VERSION = "staged-parsing-v1"
const _DEFAULT_STAGED_CAPABILITIES = ["actionir_ast_v1"]

struct StagedParserRegistryException <: Exception
    message::String
end

Base.showerror(io::IO, error::StagedParserRegistryException) = print(io, error.message)

struct StagedParseResult
    queue_index::Int
    job::StagedParseJob
    resolved_spec_id::String
    registry_provider::String
    cache_key::Dict{String,Any}
    compiled_parser::Dict{String,Any}
    result::Any
end

struct StagedFunctionBodyDispatchResult
    spec::SpecFile
    results::Vector{StagedParseResult}
end

struct _ResolvedStagedParser
    parser_spec_id::String
    resolved_spec_id::String
    provider::String
end

struct _LoadedStagedParser
    parser_spec_id::String
    resolved_spec_id::String
    source_kind::String
    adapter_contract::String
    content_digest::String
    import_graph_fingerprint::String
end

struct _CompiledStagedParser
    parser_spec_id::String
    resolved_spec_id::String
    top_rule::String
    source_kind::String
    capabilities::Vector{String}
    cache_key::Dict{String,Any}
end

function to_json(result::StagedParseResult)
    return Dict{String,Any}(
        "kind" => "staged_parse_result",
        "version" => 1,
        "stage_depth" => 1,
        "queue_index" => result.queue_index,
        "phases" => ["resolve", "load", "compile", "execute"],
        "job_id" => result.job.job_id,
        "parent_ast_path" => result.job.parent_ast_path,
        "parser_spec_id" => result.job.parser_spec_id,
        "resolved_spec_id" => result.resolved_spec_id,
        "registry_provider" => result.registry_provider,
        "top_rule" => result.job.top_rule,
        "node_kind" => result.job.node_kind,
        "payload_kind" => result.job.payload_kind,
        "source_span" => to_json(result.job.source_span),
        "result_policy" => result.job.result_policy,
        "result_field" => result.job.result_field,
        "failure_policy" => result.job.failure_policy,
        "cache_key" => result.cache_key,
        "compiled_parser" => result.compiled_parser,
        "result" => result.result,
    )
end

function to_json(dispatch::StagedFunctionBodyDispatchResult)
    return Dict{String,Any}(
        "kind" => "staged_function_body_dispatch",
        "spec" => to_json(dispatch.spec),
        "results" => [to_json(result) for result in dispatch.results],
    )
end

function execute_staged_parse_job(job::StagedParseJob)
    results = execute_staged_parse_jobs([job])
    if isempty(results)
        throw(StagedParserRegistryException("staged parse dispatch produced no result"))
    end
    return only(results).result
end

function execute_staged_parse_jobs(jobs)
    queue = StagedParseJob[_normalize_staged_parse_job(job) for job in jobs]
    sort!(queue; lt = _staged_parse_job_lt)

    results = StagedParseResult[]
    for (index, job) in enumerate(queue)
        resolved = _resolve_staged_parser(job)
        loaded = _load_staged_parser(resolved)
        compiled = _compile_staged_parser(loaded, job)
        result = _execute_staged_parser(compiled, job)
        push!(results, StagedParseResult(
            index - 1,
            job,
            resolved.resolved_spec_id,
            resolved.provider,
            compiled.cache_key,
            _compiled_staged_parser_json(compiled),
            result,
        ))
    end
    return results
end

function dispatch_function_body_parse_jobs(spec::SpecFile)
    jobs = StagedParseJob[]
    for (index, definition) in enumerate(spec.functions)
        job = definition.body_parse_job
        if job === nothing
            continue
        end
        _validate_function_body_parse_job(definition, index - 1, job)
        push!(jobs, job)
    end

    results = execute_staged_parse_jobs(jobs)
    body_ast_by_index = Dict{Int,Any}()
    for result in results
        index = _staged_function_index(result.job)
        if haskey(body_ast_by_index, index)
            throw(StagedParserRegistryException(
                "duplicate staged function-body result for functions.$index.body_source",
            ))
        end
        body_ast_by_index[index] = result.result
    end

    functions = FunctionDefinition[]
    for (index, definition) in enumerate(spec.functions)
        zero_index = index - 1
        if haskey(body_ast_by_index, zero_index)
            push!(functions, function_definition_with_body_ast(
                definition,
                body_ast_by_index[zero_index],
            ))
        else
            push!(functions, definition)
        end
    end
    return StagedFunctionBodyDispatchResult(
        SpecFile(functions = functions, rules = spec.rules),
        results,
    )
end

stitch_function_body_parse_jobs(spec::SpecFile) = dispatch_function_body_parse_jobs(spec).spec

function parse_spec_with_staged_user_function_definition_asts(source::AbstractString, definition_nodes)
    spec = parse_spec_with_user_function_definition_asts(source, definition_nodes)
    return stitch_function_body_parse_jobs(spec)
end

function _normalize_staged_parse_job(job::StagedParseJob)
    if isempty(job.job_id)
        throw(StagedParserRegistryException("staged parse job job_id must be non-empty"))
    end
    span = job.source_span
    if span.start > span.stop ||
            span.line_start <= 0 ||
            span.line_end <= 0 ||
            span.line_start > span.line_end
        throw(StagedParserRegistryException("staged parse job source_span has invalid range"))
    end
    return job
end

function _staged_parse_job_lt(left::StagedParseJob, right::StagedParseJob)
    path_order = _compare_staged_string_lists(left.parent_ast_path, right.parent_ast_path)
    if path_order != 0
        return path_order < 0
    elseif left.source_span.start != right.source_span.start
        return left.source_span.start < right.source_span.start
    elseif left.source_span.stop != right.source_span.stop
        return left.source_span.stop < right.source_span.stop
    end
    return left.job_id < right.job_id
end

function _compare_staged_string_lists(left::Vector{String}, right::Vector{String})
    for index in 1:min(length(left), length(right))
        if left[index] < right[index]
            return -1
        elseif left[index] > right[index]
            return 1
        end
    end
    if length(left) < length(right)
        return -1
    elseif length(left) > length(right)
        return 1
    end
    return 0
end

function _resolve_staged_parser(job::StagedParseJob)
    if job.parser_spec_id != ACTION_IR_BODY_SPEC_ID
        throw(StagedParserRegistryException(_staged_dispatch_error(
            "resolve",
            job,
            "unsupported parser spec id '$(job.parser_spec_id)'",
        )))
    end
    return _ResolvedStagedParser(
        ACTION_IR_BODY_SPEC_ID,
        ACTION_IR_BODY_RESOLVED_SPEC_ID,
        "builtin",
    )
end

function _load_staged_parser(resolved::_ResolvedStagedParser)
    if resolved.resolved_spec_id != ACTION_IR_BODY_RESOLVED_SPEC_ID
        throw(StagedParserRegistryException(
            "unsupported resolved spec id '$(resolved.resolved_spec_id)'",
        ))
    end
    return _LoadedStagedParser(
        resolved.parser_spec_id,
        resolved.resolved_spec_id,
        "builtin_adapter",
        _ACTION_IR_BODY_ADAPTER_SOURCE,
        ACTION_IR_BODY_ADAPTER_DIGEST,
        "none",
    )
end

function _compile_staged_parser(loaded::_LoadedStagedParser, job::StagedParseJob)
    if loaded.resolved_spec_id != ACTION_IR_BODY_RESOLVED_SPEC_ID
        throw(StagedParserRegistryException(_staged_dispatch_error(
            "compile",
            job,
            "unsupported resolved spec id '$(loaded.resolved_spec_id)'";
            resolved_spec_id = loaded.resolved_spec_id,
        )))
    elseif job.top_rule != ACTION_IR_BODY_TOP_RULE
        throw(StagedParserRegistryException(_staged_dispatch_error(
            "compile",
            job,
            "unsupported top rule '$(job.top_rule)'";
            resolved_spec_id = loaded.resolved_spec_id,
        )))
    end
    capabilities = String[_DEFAULT_STAGED_CAPABILITIES...]
    return _CompiledStagedParser(
        loaded.parser_spec_id,
        loaded.resolved_spec_id,
        job.top_rule,
        loaded.source_kind,
        capabilities,
        _staged_parser_cache_key(loaded, job.top_rule, capabilities),
    )
end

function _execute_staged_parser(compiled::_CompiledStagedParser, job::StagedParseJob)
    if compiled.resolved_spec_id != ACTION_IR_BODY_RESOLVED_SPEC_ID ||
            compiled.top_rule != ACTION_IR_BODY_TOP_RULE
        throw(StagedParserRegistryException(_staged_dispatch_error(
            "execute",
            job,
            "compiled parser identity is unsupported";
            resolved_spec_id = compiled.resolved_spec_id,
        )))
    end
    try
        return to_json(parse_action_block(job.text))
    catch error
        throw(StagedParserRegistryException(_staged_dispatch_error(
            "execute",
            job,
            "action block parse failed: $(sprint(showerror, error))";
            resolved_spec_id = compiled.resolved_spec_id,
        )))
    end
end

function _staged_parser_cache_key(
    loaded::_LoadedStagedParser,
    top_rule::String,
    capabilities::Vector{String},
)
    fingerprint = join([
        loaded.resolved_spec_id,
        loaded.content_digest,
        loaded.import_graph_fingerprint,
        top_rule,
        _SPEC_LANGUAGE_VERSION,
        _HELPER_ACTION_CONTRACT_VERSION,
        _STAGED_PARSING_CONTRACT_VERSION,
        join(capabilities, ","),
    ], "|")
    return Dict{String,Any}(
        "kind" => "staged_parser_cache_key",
        "version" => 1,
        "normalized_spec_identity" => loaded.resolved_spec_id,
        "content_digest" => loaded.content_digest,
        "import_graph_fingerprint" => loaded.import_graph_fingerprint,
        "top_rule" => top_rule,
        "spec_language_version" => _SPEC_LANGUAGE_VERSION,
        "helper_action_contract_version" => _HELPER_ACTION_CONTRACT_VERSION,
        "staged_parsing_contract_version" => _STAGED_PARSING_CONTRACT_VERSION,
        "backend_capabilities" => capabilities,
        "fingerprint" => fingerprint,
        "source_kind" => loaded.source_kind,
        "adapter_contract" => loaded.adapter_contract,
    )
end

function _compiled_staged_parser_json(compiled::_CompiledStagedParser)
    return Dict{String,Any}(
        "kind" => "staged_compiled_parser",
        "version" => 1,
        "parser_spec_id" => compiled.parser_spec_id,
        "resolved_spec_id" => compiled.resolved_spec_id,
        "top_rule" => compiled.top_rule,
        "source_kind" => compiled.source_kind,
        "capabilities" => compiled.capabilities,
    )
end

function _validate_function_body_parse_job(
    definition::FunctionDefinition,
    index::Int,
    job::StagedParseJob,
)
    _normalize_staged_parse_job(job)
    expected_path = ["functions", string(index), "body_source"]
    if job.parent_ast_path != expected_path
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job parent_ast_path must target " *
            "functions.$index.body_source",
        ))
    elseif job.node_kind != "function_definition"
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job node_kind must be 'function_definition'",
        ))
    elseif job.payload_kind != "function_body"
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job payload_kind must be 'function_body'",
        ))
    elseif job.function_name !== nothing && job.function_name != definition.name
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job function_name does not match",
        ))
    elseif job.params !== nothing && job.params != definition.params
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job params do not match",
        ))
    elseif job.arity !== nothing && job.arity != definition.arity
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job arity does not match",
        ))
    elseif job.text != definition.body_source
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job text does not match body_source",
        ))
    elseif job.parser_spec_id != ACTION_IR_BODY_SPEC_ID
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job parser_spec_id must be '$ACTION_IR_BODY_SPEC_ID'",
        ))
    elseif job.top_rule != ACTION_IR_BODY_TOP_RULE
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job top_rule must be '$ACTION_IR_BODY_TOP_RULE'",
        ))
    elseif job.result_policy != "replace_field"
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job result_policy must be 'replace_field'",
        ))
    elseif job.result_field != "body_ast"
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job result_field must be 'body_ast'",
        ))
    elseif job.failure_policy != "fail"
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job failure_policy must be 'fail'",
        ))
    end
    return nothing
end

function _staged_function_index(job::StagedParseJob)
    path = job.parent_ast_path
    if length(path) != 3 || path[1] != "functions" || path[3] != "body_source"
        throw(StagedParserRegistryException(
            "staged parse result parent_ast_path must target functions[*].body_source",
        ))
    end
    index = tryparse(Int, path[2])
    if index === nothing
        throw(StagedParserRegistryException(
            "staged parse result parent_ast_path has non-numeric function index '$(path[2])'",
        ))
    end
    return index
end

function _staged_dispatch_error(
    phase::String,
    job::StagedParseJob,
    detail::String;
    resolved_spec_id = nothing,
)
    resolved = resolved_spec_id === nothing ? "" : " resolved_spec_id=$resolved_spec_id"
    return "staged parse dispatch failed: phase=$phase job_id=$(job.job_id) " *
        "parent_ast_path=$(join(job.parent_ast_path, '.')) " *
        "parser_spec_id=$(job.parser_spec_id)$resolved top_rule=$(job.top_rule) " *
        "source_span=$(job.source_span.start)-$(job.source_span.stop) " *
        "failure_policy=$(job.failure_policy) detail=$detail"
end
