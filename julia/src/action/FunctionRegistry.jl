struct UserFunctionRegistryException <: Exception
    message::String
end

Base.showerror(io::IO, error::UserFunctionRegistryException) = print(io, error.message)

struct UserFunctionEntry
    index::Int
    definition::FunctionDefinition
end

struct UserFunctionCallResolution
    name::String
    requested_arity::Int
    expected_arities::Vector{Int}
    entry::Union{Nothing,UserFunctionEntry}
    name_known::Bool
    matched::Bool
    arity_mismatch::Bool
end

function UserFunctionCallResolution(; name, requested_arity, expected_arities, entry = nothing)
    expected_vec = Int[expected_arities...]
    matched = entry !== nothing
    name_known = !isempty(expected_vec)
    return UserFunctionCallResolution(
        String(name),
        requested_arity,
        expected_vec,
        entry,
        name_known,
        matched,
        name_known && !matched,
    )
end

struct UserFunctionRegistry
    entries::Vector{UserFunctionEntry}
    by_name::Dict{String,Vector{UserFunctionEntry}}
end

function user_function_registry_from_spec(spec::SpecFile)
    return user_function_registry_from_functions(spec.functions)
end

function user_function_registry_from_functions(functions)
    entries = UserFunctionEntry[]
    by_name = Dict{String,Vector{UserFunctionEntry}}()

    for (index, definition) in enumerate(functions)
        name = definition.name
        if haskey(by_name, name)
            throw(UserFunctionRegistryException("duplicate user function '$name'"))
        end
        entry = UserFunctionEntry(index - 1, definition)
        push!(entries, entry)
        by_name[name] = UserFunctionEntry[entry]
    end

    return UserFunctionRegistry(entries, by_name)
end

empty_user_function_registry() = UserFunctionRegistry(UserFunctionEntry[], Dict{String,Vector{UserFunctionEntry}}())

function user_function_names(registry::UserFunctionRegistry)
    return [entry.definition.name for entry in registry.entries]
end

function body_parse_jobs(registry::UserFunctionRegistry)
    jobs = StagedParseJob[]
    for entry in registry.entries
        job = entry.definition.body_parse_job
        if job !== nothing
            push!(jobs, job)
        end
    end
    return jobs
end

has_user_function_name(registry::UserFunctionRegistry, name::AbstractString) = haskey(registry.by_name, String(name))

function expected_arities_for(registry::UserFunctionRegistry, name::AbstractString)
    entries = get(registry.by_name, String(name), nothing)
    if entries === nothing
        return Int[]
    end
    return [entry.definition.arity for entry in entries]
end

function lookup_user_function(registry::UserFunctionRegistry, name::AbstractString)
    entries = get(registry.by_name, String(name), nothing)
    if entries === nothing || isempty(entries)
        return nothing
    end
    return only(entries)
end

function resolve_exact_user_function(registry::UserFunctionRegistry, name::AbstractString, arity::Int)
    entries = get(registry.by_name, String(name), nothing)
    if entries === nothing
        return nothing
    end
    for entry in entries
        if user_function_accepts_arity(entry, arity)
            return entry
        end
    end
    return nothing
end

function user_function_accepts_arity(entry::UserFunctionEntry, arity::Int)
    signature = entry.definition.signature
    return signature === nothing ? arity == entry.definition.arity : arity >= signature.min_arity
end

function user_function_arity_expectation(entry::UserFunctionEntry)
    signature = entry.definition.signature
    return signature === nothing ? string(entry.definition.arity) : "at least $(signature.min_arity)"
end

function resolve_user_function_call(registry::UserFunctionRegistry, name::AbstractString, arity::Int)
    expected = expected_arities_for(registry, name)
    if isempty(expected)
        return UserFunctionCallResolution(name = name, requested_arity = arity, expected_arities = Int[])
    end
    entry = resolve_exact_user_function(registry, name, arity)
    return UserFunctionCallResolution(
        name = name,
        requested_arity = arity,
        expected_arities = expected,
        entry = entry,
    )
end

function function_definition_with_body_ast(definition::FunctionDefinition, body_ast)
    return FunctionDefinition(
        name = definition.name,
        params = definition.params,
        arity = definition.arity,
        signature = definition.signature,
        body_source = definition.body_source,
        body_payload = definition.body_payload,
        body_parse_job = definition.body_parse_job,
        body_ast = body_ast,
        source = definition.source,
        source_span = definition.source_span,
        body_span = definition.body_span,
    )
end

function stitch_function_body_ast(spec::SpecFile, job_id::AbstractString, body_ast)
    functions = FunctionDefinition[]
    found = false
    for definition in spec.functions
        job = definition.body_parse_job
        if job !== nothing && job.job_id == job_id
            if job.result_policy != "replace_field" || job.result_field != "body_ast"
                throw(UserFunctionRegistryException(
                    "function body parse job '$job_id' cannot stitch into body_ast",
                ))
            end
            push!(functions, function_definition_with_body_ast(definition, body_ast))
            found = true
        else
            push!(functions, definition)
        end
    end
    if !found
        throw(UserFunctionRegistryException("function body parse job '$job_id' not found"))
    end
    return SpecFile(functions = functions, rules = spec.rules)
end

function to_json(registry::UserFunctionRegistry)
    return Dict{String,Any}(
        "functions" => [to_json(entry) for entry in registry.entries],
        "body_parse_jobs" => [to_json(job) for job in body_parse_jobs(registry)],
    )
end

function to_json(entry::UserFunctionEntry)
    result = to_json(entry.definition)
    result["index"] = entry.index
    return result
end

function to_descriptor_json(entry::UserFunctionEntry)
    definition = entry.definition
    result = Dict{String,Any}(
        "index" => entry.index,
        "kind" => "user_function_definition",
        "version" => definition.signature === nothing ? 1 : 2,
        "name" => definition.name,
        "source_text" => definition.source,
        "source_span" => to_json(definition.source_span),
        "body_span" => to_json(definition.body_span),
        "body_source" => definition.body_source,
    )
    if definition.signature === nothing
        result["params"] = definition.params
        result["arity"] = definition.arity
    else
        result["signature"] = to_json(definition.signature)
    end
    _put_if_present!(result, "body_payload", definition.body_payload)
    if definition.body_parse_job !== nothing
        result["body_parse_job"] = to_json(definition.body_parse_job)
    end
    _put_if_present!(result, "body_ast", definition.body_ast)
    return result
end

function to_json(resolution::UserFunctionCallResolution)
    result = Dict{String,Any}(
        "name" => resolution.name,
        "requested_arity" => resolution.requested_arity,
        "expected_arities" => resolution.expected_arities,
        "name_known" => resolution.name_known,
        "matched" => resolution.matched,
        "arity_mismatch" => resolution.arity_mismatch,
    )
    if resolution.entry !== nothing
        result["entry"] = to_json(resolution.entry)
    end
    return result
end
