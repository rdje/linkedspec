@enum SpecRequestKind begin
    NamedSpecRequest
    PathSpecRequest
end

struct SpecRequest
    kind::SpecRequestKind
    requested::String
end


SpecRequest(kind::SpecRequestKind, requested::AbstractString) =
    SpecRequest(kind, String(requested))

named_spec_request(name::AbstractString) = SpecRequest(NamedSpecRequest, name)
path_spec_request(path::AbstractString) = SpecRequest(PathSpecRequest, path)

struct SpecLoadOptions
    cwd::String
    search_roots::Vector{String}
end


function SpecLoadOptions(cwd::AbstractString; search_roots = String[])
    return SpecLoadOptions(
        String(cwd),
        String[String(root) for root in search_roots],
    )
end

SpecLoadOptions(; cwd::AbstractString = pwd(), search_roots = String[]) =
    SpecLoadOptions(cwd; search_roots = search_roots)

@enum SpecPipelineStage begin
    ValidateSpecNameStage
    ValidateSpecPathStage
    ResolveSpecPathStage
    LoadSpecContentStage
    DecodeSpecContentStage
    ParseSpecStage
    ValidateSpecStage
    CompileSpecStage
end

@enum SpecPipelineCode begin
    InvalidSpecNameCode
    InvalidSpecPathCode
    SpecPathNotFoundCode
    SpecPathNotFileCode
    SpecReadFailedCode
    InvalidUtf8Code
    SpecParseFailedCode
    SpecNoRulesDefinedCode
    SpecValidationFailedCode
    SpecCompileFailedCode
end

const _SPEC_PIPELINE_STAGE_NAMES = Dict(
    ValidateSpecNameStage => "validate_spec_name",
    ValidateSpecPathStage => "validate_spec_path",
    ResolveSpecPathStage => "resolve_spec_path",
    LoadSpecContentStage => "load_spec_content",
    DecodeSpecContentStage => "decode_spec_content",
    ParseSpecStage => "parse_spec",
    ValidateSpecStage => "validate_spec",
    CompileSpecStage => "compile_spec",
)

const _SPEC_PIPELINE_CODE_NAMES = Dict(
    InvalidSpecNameCode => "invalid_spec_name",
    InvalidSpecPathCode => "invalid_spec_path",
    SpecPathNotFoundCode => "spec_path_not_found",
    SpecPathNotFileCode => "spec_path_not_file",
    SpecReadFailedCode => "spec_read_failed",
    InvalidUtf8Code => "invalid_utf8",
    SpecParseFailedCode => "spec_parse_failed",
    SpecNoRulesDefinedCode => "no_rules_defined",
    SpecValidationFailedCode => "spec_validation_failed",
    SpecCompileFailedCode => "spec_compile_failed",
)

spec_pipeline_stage_name(stage::SpecPipelineStage) = _SPEC_PIPELINE_STAGE_NAMES[stage]
spec_pipeline_code_name(code::SpecPipelineCode) = _SPEC_PIPELINE_CODE_NAMES[code]
spec_request_kind_name(kind::SpecRequestKind) =
    kind == NamedSpecRequest ? "name" : "path"

struct SpecPipelineException <: Exception
    stage::SpecPipelineStage
    code::SpecPipelineCode
    summary::String
    request_kind::SpecRequestKind
    requested::String
    resolved_path::Union{Nothing,String}
    detail::Union{Nothing,String}
end


Base.showerror(io::IO, error::SpecPipelineException) = print(io, error.summary)

function to_json(error::SpecPipelineException)
    value = Dict{String,Any}(
        "type" => "spec_pipeline_error",
        "stage" => spec_pipeline_stage_name(error.stage),
        "code" => spec_pipeline_code_name(error.code),
        "summary" => error.summary,
        "request_kind" => spec_request_kind_name(error.request_kind),
        "requested" => error.requested,
    )
    if error.resolved_path !== nothing
        value["resolved_path"] = error.resolved_path
    end
    if error.detail !== nothing
        value["detail"] = error.detail
    end
    return value
end

struct ResolvedSpec
    request::SpecRequest
    path::String
    origin::String
end

struct LoadedSpec
    resolved::ResolvedSpec
    source_text::String
end

struct LoadedCompiledSpec
    loaded::LoadedSpec
    compiled::CompiledSpec
end


function create_engine(
    loaded::LoadedCompiledSpec;
    max_iterations::Int = 10_000,
    kwargs...,
)
    request = loaded.loaded.resolved.request
    return LinkedSpecRuntimeEngine(
        loaded.compiled;
        max_iterations = max_iterations,
        spec_name = request.kind == NamedSpecRequest ? request.requested : nothing,
        spec_path = loaded.loaded.resolved.path,
        kwargs...,
    )
end

function validate_spec_request(request::SpecRequest)
    if request.kind == NamedSpecRequest
        _validate_named_spec_request(request)
    else
        _validate_path_spec_request(request)
    end
    return nothing
end

function resolve_spec(request::SpecRequest, options::SpecLoadOptions)
    validate_spec_request(request)
    first_non_regular = nothing
    for (path, origin) in _spec_candidates(request, options)
        try
            if isfile(path)
                return ResolvedSpec(request, path, origin)
            end
            if first_non_regular === nothing && ispath(path)
                first_non_regular = path
            end
        catch error
            _spec_pipeline_fatal_error(error) && rethrow()
            throw(_spec_pipeline_error(
                request,
                ResolveSpecPathStage,
                SpecReadFailedCode,
                "Unable to inspect spec path";
                resolved_path = path,
                detail = sprint(showerror, error),
            ))
        end
    end

    if first_non_regular !== nothing
        throw(_spec_pipeline_error(
            request,
            ResolveSpecPathStage,
            SpecPathNotFileCode,
            "Spec path is not a file";
            resolved_path = first_non_regular,
        ))
    end
    throw(_spec_pipeline_error(
        request,
        ResolveSpecPathStage,
        SpecPathNotFoundCode,
        "Spec path not found",
    ))
end

function load_spec(request::SpecRequest, options::SpecLoadOptions)
    resolved = resolve_spec(request, options)
    bytes = try
        read(resolved.path)
    catch error
        _spec_pipeline_fatal_error(error) && rethrow()
        throw(_spec_pipeline_error(
            request,
            LoadSpecContentStage,
            SpecReadFailedCode,
            "Unable to read spec file";
            resolved_path = resolved.path,
            detail = sprint(showerror, error),
        ))
    end
    source_text = String(bytes)
    if !isvalid(source_text)
        throw(_spec_pipeline_error(
            request,
            DecodeSpecContentStage,
            InvalidUtf8Code,
            "Spec file is not valid UTF-8";
            resolved_path = resolved.path,
        ))
    end
    return LoadedSpec(resolved, source_text)
end

function load_and_compile_spec(request::SpecRequest, options::SpecLoadOptions)
    loaded = load_spec(request, options)
    if startswith(loaded.source_text, '\ufeff')
        throw(_spec_pipeline_error(
            request,
            ParseSpecStage,
            SpecParseFailedCode,
            "Unable to parse spec";
            resolved_path = loaded.resolved.path,
            detail = "leading source BOM is preserved and not valid rule syntax",
        ))
    end

    spec = try
        parse_spec_with_staged_user_function_definitions(loaded.source_text)
    catch error
        _spec_pipeline_fatal_error(error) && rethrow()
        throw(_spec_pipeline_error(
            request,
            ParseSpecStage,
            SpecParseFailedCode,
            "Unable to parse spec";
            resolved_path = loaded.resolved.path,
            detail = sprint(showerror, error),
        ))
    end

    try
        validate_spec(spec)
    catch error
        _spec_pipeline_fatal_error(error) && rethrow()
        code = error isa SpecValidationException &&
            error.diagnostic !== nothing &&
            error.diagnostic.code == "no_rules_defined" ?
            SpecNoRulesDefinedCode : SpecValidationFailedCode
        throw(_spec_pipeline_error(
            request,
            ValidateSpecStage,
            code,
            "Spec validation failed";
            resolved_path = loaded.resolved.path,
            detail = sprint(showerror, error),
        ))
    end

    compiled = try
        compile_spec(spec; validate_source = false)
    catch error
        _spec_pipeline_fatal_error(error) && rethrow()
        throw(_spec_pipeline_error(
            request,
            CompileSpecStage,
            SpecCompileFailedCode,
            "Spec compilation failed";
            resolved_path = loaded.resolved.path,
            detail = sprint(showerror, error),
        ))
    end
    return LoadedCompiledSpec(loaded, compiled)
end

function _validate_named_spec_request(request::SpecRequest)
    name = request.requested
    components = split(name, '/'; keepempty = true)
    invalid = isempty(name) ||
        all(isspace, name) ||
        isspace(first(name)) ||
        isspace(last(name)) ||
        any(iscntrl, name) ||
        startswith(name, '/') ||
        occursin(r"^[A-Za-z]:/", name) ||
        occursin('\\', name) ||
        any(component -> isempty(component) || component == "." || component == "..", components)
    if invalid
        throw(_spec_pipeline_error(
            request,
            ValidateSpecNameStage,
            InvalidSpecNameCode,
            "Invalid spec name",
        ))
    end
end

function _validate_path_spec_request(request::SpecRequest)
    if isempty(request.requested) || occursin('\0', request.requested)
        throw(_spec_pipeline_error(
            request,
            ValidateSpecPathStage,
            InvalidSpecPathCode,
            "Invalid spec path",
        ))
    end
end

function _spec_candidates(request::SpecRequest, options::SpecLoadOptions)
    candidates = Tuple{String,String}[]
    if request.kind == PathSpecRequest
        path = isabspath(request.requested) ?
            normpath(request.requested) : normpath(joinpath(options.cwd, request.requested))
        push!(candidates, (path, "path_exact"))
    else
        filename = endswith(request.requested, ".spec") ?
            request.requested : "$(request.requested).spec"
        push!(candidates, (_spec_named_path(options.cwd, request.requested), "cwd_exact"))
        push!(candidates, (_spec_named_path(options.cwd, filename), "cwd_spec_suffix"))
        for (index, root) in enumerate(options.search_roots)
            push!(candidates, (_spec_named_path(root, filename), "search_root:$(index - 1)"))
        end
    end
    seen = Set{String}()
    return Tuple{String,String}[
        candidate for candidate in candidates if _remember_spec_candidate!(seen, candidate[1])
    ]
end

_spec_named_path(root::String, portable_relative_path::String) =
    normpath(joinpath(root, split(portable_relative_path, '/')...))

function _remember_spec_candidate!(seen::Set{String}, path::String)
    path in seen && return false
    push!(seen, path)
    return true
end

_spec_pipeline_fatal_error(error) =
    error isa InterruptException || error isa OutOfMemoryError || error isa StackOverflowError

function _spec_pipeline_error(
    request::SpecRequest,
    stage::SpecPipelineStage,
    code::SpecPipelineCode,
    summary::AbstractString;
    resolved_path = nothing,
    detail = nothing,
)
    return SpecPipelineException(
        stage,
        code,
        String(summary),
        request.kind,
        request.requested,
        resolved_path === nothing ? nothing : String(resolved_path),
        detail === nothing ? nothing : String(detail),
    )
end
