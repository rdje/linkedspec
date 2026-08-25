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

function execute_staged_parse_job(
    job::StagedParseJob;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    results = execute_staged_parse_jobs([job]; trace = trace)
    if isempty(results)
        throw(StagedParserRegistryException("staged parse dispatch produced no result"))
    end
    return only(results).result
end

function execute_staged_parse_jobs(
    jobs;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    input_jobs = collect(jobs)
    if trace === nothing
        return _execute_staged_parse_jobs(input_jobs, nothing)
    end

    scope = enter_trace_scope!(
        trace,
        "julia_staged:execute_parse_jobs",
        "jobs=$(length(input_jobs))",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    try
        results = _execute_staged_parse_jobs(input_jobs, trace)
        exit_details = "status=ok results=$(length(results))"
        return results
    catch error
        exit_details = "status=error error=$(sprint(showerror, error))"
        rethrow()
    finally
        exit_trace_scope!(trace, scope, exit_details)
    end
end

function _execute_staged_parse_jobs(
    jobs,
    trace::Union{Nothing,LinkedSpecTraceEmitter},
)
    queue = StagedParseJob[]
    for (input_index, job) in enumerate(jobs)
        try
            normalized = _normalize_staged_parse_job(job)
            push!(queue, normalized)
            if trace !== nothing
                trace_decision!(
                    trace,
                    "julia_staged:execute_parse_jobs:normalize_job",
                    true,
                    "input_index=$(input_index - 1) job_id=$(normalized.job_id) parser_spec_id=$(normalized.parser_spec_id) top_rule=$(normalized.top_rule) payload_kind=$(normalized.payload_kind)",
                    LinkedSpecTraceMedium,
                )
            end
        catch error
            if trace !== nothing
                trace_decision!(
                    trace,
                    "julia_staged:execute_parse_jobs:normalize_job",
                    false,
                    "input_index=$(input_index - 1) error=$(sprint(showerror, error))",
                    LinkedSpecTraceMedium,
                )
            end
            rethrow()
        end
    end
    sort!(queue; lt = _staged_parse_job_lt)
    if trace !== nothing
        trace_decision!(
            trace,
            "julia_staged:execute_parse_jobs:queue_sorted",
            true,
            "jobs=$(length(queue))",
            LinkedSpecTraceMedium,
        )
    end

    results = StagedParseResult[]
    for (index, job) in enumerate(queue)
        push!(results, _execute_one_staged_parse_job(index - 1, job, trace))
    end
    return results
end

function _execute_one_staged_parse_job(
    queue_index::Int,
    job::StagedParseJob,
    trace::Union{Nothing,LinkedSpecTraceEmitter},
)
    scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_staged:execute_parse_jobs:job",
        "queue_index=$queue_index job_id=$(job.job_id) parent_ast_path=$(join(job.parent_ast_path, '.')) parser_spec_id=$(job.parser_spec_id) top_rule=$(job.top_rule)",
        LinkedSpecTraceMedium,
    )
    exit_details = "status=error job_id=$(job.job_id) error=unknown"
    try
        resolved = _trace_staged_phase!(trace, "resolve", job) do
            _resolve_staged_parser(job)
        end
        loaded = _trace_staged_phase!(trace, "load", job) do
            _load_staged_parser(resolved)
        end
        compiled = _trace_staged_phase!(trace, "compile", job) do
            _compile_staged_parser(loaded, job)
        end
        result = _trace_staged_phase!(trace, "execute", job) do
            _execute_staged_parser(compiled, job)
        end
        record = StagedParseResult(
            queue_index,
            job,
            resolved.resolved_spec_id,
            resolved.provider,
            compiled.cache_key,
            _compiled_staged_parser_json(compiled),
            result,
        )
        exit_details = "status=ok job_id=$(job.job_id)"
        return record
    catch error
        exit_details = "status=error job_id=$(job.job_id) error=$(sprint(showerror, error))"
        rethrow()
    finally
        if trace !== nothing && scope !== nothing
            exit_trace_scope!(trace, scope, exit_details)
        end
    end
end

function _trace_staged_phase!(
    operation::Function,
    trace::Union{Nothing,LinkedSpecTraceEmitter},
    phase::String,
    job::StagedParseJob,
)
    if trace === nothing
        return operation()
    end
    try
        result = operation()
        trace_decision!(
            trace,
            "julia_staged:execute_parse_jobs:$phase",
            true,
            "job_id=$(job.job_id) parser_spec_id=$(job.parser_spec_id) top_rule=$(job.top_rule)",
            LinkedSpecTraceMedium,
        )
        return result
    catch error
        trace_decision!(
            trace,
            "julia_staged:execute_parse_jobs:$phase",
            false,
            "job_id=$(job.job_id) error=$(sprint(showerror, error))",
            LinkedSpecTraceMedium,
        )
        rethrow()
    end
end

function dispatch_function_body_parse_jobs(
    spec::SpecFile;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_staged:dispatch_function_body_parse_jobs",
        "functions=$(length(spec.functions))",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    try
        dispatch = _dispatch_function_body_parse_jobs(spec, trace)
        exit_details = "status=ok jobs=$(length(dispatch.results))"
        return dispatch
    catch error
        exit_details = "status=error error=$(sprint(showerror, error))"
        rethrow()
    finally
        if trace !== nothing && scope !== nothing
            exit_trace_scope!(trace, scope, exit_details)
        end
    end
end

function _dispatch_function_body_parse_jobs(
    spec::SpecFile,
    trace::Union{Nothing,LinkedSpecTraceEmitter},
)
    jobs = StagedParseJob[]
    for (index, definition) in enumerate(spec.functions)
        job = definition.body_parse_job
        if job === nothing
            continue
        end
        _validate_function_body_parse_job(definition, index - 1, job)
        push!(jobs, job)
    end

    results = execute_staged_parse_jobs(jobs; trace = trace)
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
        SpecFile(
            source_id = spec.source_id,
            functions = functions,
            rules = spec.rules,
        ),
        results,
    )
end

function stitch_function_body_parse_jobs(
    spec::SpecFile;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    return dispatch_function_body_parse_jobs(spec; trace = trace).spec
end

function parse_spec_with_staged_user_function_definition_asts(
    source::AbstractString,
    definition_nodes;
    source_id::AbstractString = "inline",
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    spec = parse_spec_with_user_function_definition_asts(
        source,
        definition_nodes;
        source_id = source_id,
        trace = trace,
    )
    return stitch_function_body_parse_jobs(spec; trace = trace)
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
    payload = definition.body_payload
    if !isempty(definition.parameter_kinds)
        fixed_params = definition.params[1:(end - 1)]
        payload_matches = payload isa AbstractDict &&
            get(payload, "fixed_params", nothing) == fixed_params &&
            get(payload, "codeblock_param", nothing) == last(definition.params) &&
            get(payload, "parameter_kinds", nothing) == definition.parameter_kinds &&
            !haskey(payload, "params") && !haskey(payload, "arity") &&
            !haskey(payload, "signature")
        if !payload_matches
            throw(StagedParserRegistryException(
                "function $(definition.name) body_payload final-codeblock metadata does not match",
            ))
        end
    elseif payload isa AbstractDict &&
            (haskey(payload, "fixed_params") || haskey(payload, "codeblock_param") ||
             haskey(payload, "parameter_kinds"))
        throw(StagedParserRegistryException(
            "function $(definition.name) body_payload has unexpected final-codeblock metadata",
        ))
    end
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
    elseif !isempty(definition.parameter_kinds) &&
            (isempty(definition.params) ||
             job.fixed_params != definition.params[1:(end - 1)] ||
             job.codeblock_param != last(definition.params) ||
             job.parameter_kinds != definition.parameter_kinds ||
             job.params !== nothing || job.arity !== nothing || job.signature !== nothing)
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job final-codeblock metadata does not match",
        ))
    elseif isempty(definition.parameter_kinds) && !isempty(job.parameter_kinds)
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job has unexpected final-codeblock metadata",
        ))
    elseif definition.signature === nothing && job.signature !== nothing
        throw(StagedParserRegistryException(
            "function $(definition.name) version 1 body_parse_job must not contain signature",
        ))
    elseif definition.signature !== nothing && (job.params !== nothing || job.arity !== nothing)
        throw(StagedParserRegistryException(
            "function $(definition.name) version 2 body_parse_job must store arity only in signature",
        ))
    elseif definition.signature === nothing && job.params !== nothing && job.params != definition.params
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job params do not match",
        ))
    elseif definition.signature === nothing && job.arity !== nothing && job.arity != definition.arity
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job arity does not match",
        ))
    elseif definition.signature !== nothing && job.signature != definition.signature
        throw(StagedParserRegistryException(
            "function $(definition.name) body_parse_job signature does not match",
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
        "payload_kind=$(job.payload_kind) " *
        "source_span=$(job.source_span.start)-$(job.source_span.stop) " *
        "failure_policy=$(job.failure_policy) detail=$detail"
end
