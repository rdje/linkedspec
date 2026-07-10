struct SpecAstException <: Exception
    message::String
end

Base.showerror(io::IO, error::SpecAstException) = print(io, error.message)

struct SourceSpan
    line_start::Int
    line_end::Int
end

struct StagedSourceSpan
    start::Int
    stop::Int
    line_start::Int
    line_end::Int
end

struct StagedParseJob
    version::Union{Nothing,Int}
    job_id::String
    parent_ast_path::Vector{String}
    node_kind::String
    payload_kind::String
    function_name::Union{Nothing,String}
    params::Union{Nothing,Vector{String}}
    arity::Union{Nothing,Int}
    text::String
    source_span::StagedSourceSpan
    parser_spec_id::String
    top_rule::String
    result_policy::String
    result_field::String
    failure_policy::String
    diagnostic_owner::Union{Nothing,String}
end

function StagedParseJob(;
    version = nothing,
    job_id,
    parent_ast_path,
    node_kind,
    payload_kind,
    function_name = nothing,
    params = nothing,
    arity = nothing,
    text,
    source_span,
    parser_spec_id,
    top_rule,
    result_policy,
    result_field,
    failure_policy,
    diagnostic_owner = nothing,
)
    return StagedParseJob(
        version,
        job_id,
        String[parent_ast_path...],
        node_kind,
        payload_kind,
        function_name,
        params === nothing ? nothing : String[params...],
        arity,
        text,
        source_span,
        parser_spec_id,
        top_rule,
        result_policy,
        result_field,
        failure_policy,
        diagnostic_owner,
    )
end

struct FunctionDefinition
    name::String
    params::Vector{String}
    arity::Int
    body_source::String
    body_payload::Any
    body_parse_job::Union{Nothing,StagedParseJob}
    body_ast::Any
    source::String
    source_span::SourceSpan
    body_span::SourceSpan
end

function FunctionDefinition(;
    name,
    params,
    arity,
    body_source,
    body_payload = nothing,
    body_parse_job = nothing,
    body_ast = nothing,
    source,
    source_span,
    body_span,
)
    return FunctionDefinition(
        name,
        String[params...],
        arity,
        body_source,
        body_payload,
        body_parse_job,
        body_ast,
        source,
        source_span,
        body_span,
    )
end

struct RuleMode
    name::String
    min::Union{Nothing,Int}
    max::Union{Nothing,Int}
end

RuleMode(name::AbstractString) = RuleMode(String(name), nothing, nothing)
default_rule_mode() = RuleMode("Default")
and_bounded_rule_mode(; min::Int, max = nothing) = RuleMode("AndBounded", min, max)
or_bounded_rule_mode(; min::Int, max = nothing) = RuleMode("OrBounded", min, max)

Base.:(==)(left::RuleMode, right::RuleMode) = left.name == right.name && left.min == right.min && left.max == right.max
Base.hash(mode::RuleMode, h::UInt) = hash((mode.name, mode.min, mode.max), h)

function is_and(mode::RuleMode)
    return mode.name in ("And", "AndPlus", "AndBounded", "Pipe", "Single")
end

function is_repetition(mode::RuleMode)
    return mode.name in ("Default", "Star", "Plus", "OrPlus", "AndPlus", "Optional", "OrBounded", "AndBounded")
end

function rep_min(mode::RuleMode)
    if mode.name in ("Default", "Star", "Optional")
        return 0
    elseif mode.name in ("Plus", "OrPlus", "AndPlus")
        return 1
    elseif mode.name in ("OrBounded", "AndBounded")
        return mode.min
    end
    return nothing
end

function rep_max(mode::RuleMode)
    if mode.name == "Optional"
        return 1
    elseif mode.name in ("OrBounded", "AndBounded")
        return mode.max
    end
    return nothing
end

struct RuleHeader
    label::String
    is_top::Bool
    mode::RuleMode
    rest::String
    line::Int
end

abstract type AbstractBodyElementKind end

struct RegexBodyElementKind <: AbstractBodyElementKind
    pattern::String
end

struct EdgeTarget
    label::String
    index::Int
end

EdgeTarget(; label, index = 0) = EdgeTarget(label, index)

struct FluentCall
    method::String
    args::String
end

struct ActionEdgeBodyElementKind <: AbstractBodyElementKind
    targets::Vector{EdgeTarget}
    code::Union{Nothing,String}
    fluent_chain::Vector{FluentCall}
end

function ActionEdgeBodyElementKind(; targets, code = nothing, fluent_chain = Any[])
    return ActionEdgeBodyElementKind(EdgeTarget[targets...], code, FluentCall[fluent_chain...])
end

struct BlindEdgeBodyElementKind <: AbstractBodyElementKind
    target::String
    code::Union{Nothing,String}
    fluent_chain::Vector{FluentCall}
end

function BlindEdgeBodyElementKind(; target, code = nothing, fluent_chain = Any[])
    return BlindEdgeBodyElementKind(target, code, FluentCall[fluent_chain...])
end

struct CodeBlockBodyElementKind <: AbstractBodyElementKind
    lifecycle::String
    code::String
end

struct PlainBlockBodyElementKind <: AbstractBodyElementKind
    code::String
end

struct SplitMarkerBodyElementKind <: AbstractBodyElementKind
    marker::String
end

struct LifecycleMarkerBodyElementKind <: AbstractBodyElementKind
    marker::String
end

struct FluentChainBodyElementKind <: AbstractBodyElementKind
    calls::Vector{FluentCall}
end

function FluentChainBodyElementKind(; calls)
    return FluentChainBodyElementKind(FluentCall[calls...])
end

struct ConditionalBodyElementKind <: AbstractBodyElementKind
    word::String
end

struct RawBodyElementKind <: AbstractBodyElementKind
    text::String
end

struct BodyElement
    kind::AbstractBodyElementKind
    source::String
    line::Int
end

struct Rule
    header::RuleHeader
    body::Vector{BodyElement}
end

function Rule(; header, body)
    return Rule(header, BodyElement[body...])
end

struct SpecFile
    functions::Vector{FunctionDefinition}
    rules::Vector{Rule}
end

function SpecFile(; functions = FunctionDefinition[], rules)
    return SpecFile(FunctionDefinition[functions...], Rule[rules...])
end

function top_rule(spec::SpecFile)
    for rule in spec.rules
        if rule.header.is_top
            return rule
        end
    end
    return nothing
end

function find_rule(spec::SpecFile, label::AbstractString)
    for rule in spec.rules
        if rule.header.label == label
            return rule
        end
    end
    return nothing
end

to_json(span::SourceSpan) = Dict("line_start" => span.line_start, "line_end" => span.line_end)

function to_json(span::StagedSourceSpan)
    return Dict(
        "start" => span.start,
        "end" => span.stop,
        "line_start" => span.line_start,
        "line_end" => span.line_end,
    )
end

function to_json(job::StagedParseJob)
    result = Dict{String,Any}(
        "kind" => "parse_job",
        "job_id" => job.job_id,
        "parent_ast_path" => job.parent_ast_path,
        "node_kind" => job.node_kind,
        "payload_kind" => job.payload_kind,
        "text" => job.text,
        "source_span" => to_json(job.source_span),
        "parser_spec_id" => job.parser_spec_id,
        "top_rule" => job.top_rule,
        "result_policy" => job.result_policy,
        "result_field" => job.result_field,
        "failure_policy" => job.failure_policy,
    )
    _put_if_present!(result, "version", job.version)
    _put_if_present!(result, "function_name", job.function_name)
    _put_if_present!(result, "params", job.params)
    _put_if_present!(result, "arity", job.arity)
    _put_if_present!(result, "diagnostic_owner", job.diagnostic_owner)
    return result
end

function to_json(function_definition::FunctionDefinition)
    result = Dict{String,Any}(
        "name" => function_definition.name,
        "params" => function_definition.params,
        "arity" => function_definition.arity,
        "body_source" => function_definition.body_source,
        "source" => function_definition.source,
        "source_span" => to_json(function_definition.source_span),
        "body_span" => to_json(function_definition.body_span),
    )
    _put_if_present!(result, "body_payload", function_definition.body_payload)
    if function_definition.body_parse_job !== nothing
        result["body_parse_job"] = to_json(function_definition.body_parse_job)
    end
    _put_if_present!(result, "body_ast", function_definition.body_ast)
    return result
end

function to_json(mode::RuleMode)
    if mode.name in ("AndBounded", "OrBounded")
        return Dict(mode.name => Dict("min" => mode.min, "max" => mode.max))
    end
    return mode.name
end

function to_json(header::RuleHeader)
    return Dict(
        "label" => header.label,
        "is_top" => header.is_top,
        "mode" => to_json(header.mode),
        "rest" => header.rest,
        "line" => header.line,
    )
end

to_json(kind::RegexBodyElementKind) = Dict("kind" => "regex", "pattern" => kind.pattern)

function to_json(kind::ActionEdgeBodyElementKind)
    return Dict(
        "kind" => "action_edge",
        "targets" => [to_json(target) for target in kind.targets],
        "code" => kind.code,
        "fluent_chain" => [to_json(call) for call in kind.fluent_chain],
    )
end

function to_json(kind::BlindEdgeBodyElementKind)
    return Dict(
        "kind" => "blind_edge",
        "target" => kind.target,
        "code" => kind.code,
        "fluent_chain" => [to_json(call) for call in kind.fluent_chain],
    )
end

to_json(kind::CodeBlockBodyElementKind) = Dict("kind" => "code_block", "lifecycle" => kind.lifecycle, "code" => kind.code)
to_json(kind::PlainBlockBodyElementKind) = Dict("kind" => "plain_block", "code" => kind.code)
to_json(kind::SplitMarkerBodyElementKind) = Dict("kind" => "split_marker", "marker" => kind.marker)
to_json(kind::LifecycleMarkerBodyElementKind) = Dict("kind" => "lifecycle_marker", "marker" => kind.marker)
to_json(kind::FluentChainBodyElementKind) = Dict("kind" => "fluent_chain", "calls" => [to_json(call) for call in kind.calls])
to_json(kind::ConditionalBodyElementKind) = Dict("kind" => "conditional", "word" => kind.word)
to_json(kind::RawBodyElementKind) = Dict("kind" => "raw", "text" => kind.text)
to_json(target::EdgeTarget) = Dict("label" => target.label, "index" => target.index)
to_json(call::FluentCall) = Dict("method" => call.method, "args" => call.args)
to_json(element::BodyElement) = Dict("kind" => to_json(element.kind), "source" => element.source, "line" => element.line)
to_json(rule::Rule) = Dict("header" => to_json(rule.header), "body" => [to_json(element) for element in rule.body])
to_json(spec::SpecFile) = Dict("functions" => [to_json(function_definition) for function_definition in spec.functions], "rules" => [to_json(rule) for rule in spec.rules])

function from_json(::Type{SourceSpan}, json)
    object = _ast_object(json, "source_span")
    return SourceSpan(_ast_int(object, "line_start"), _ast_int(object, "line_end"))
end

function from_json(::Type{StagedSourceSpan}, json)
    object = _ast_object(json, "source_span")
    return StagedSourceSpan(
        _ast_int(object, "start"),
        _ast_int(object, "end"),
        _ast_int(object, "line_start"),
        _ast_int(object, "line_end"),
    )
end

function from_json(::Type{StagedParseJob}, json)
    object = _ast_object(json, "body_parse_job")
    kind = _ast_string(object, "kind")
    if kind != "parse_job"
        throw(SpecAstException("staged parse job kind must be parse_job, got $kind"))
    end
    return StagedParseJob(
        version = _ast_optional_int(object, "version"),
        job_id = _ast_string(object, "job_id"),
        parent_ast_path = _ast_string_list(object, "parent_ast_path"),
        node_kind = _ast_string(object, "node_kind"),
        payload_kind = _ast_string(object, "payload_kind"),
        function_name = _ast_optional_string(object, "function_name"),
        params = _ast_optional_string_list(object, "params"),
        arity = _ast_optional_int(object, "arity"),
        text = _ast_string(object, "text"),
        source_span = from_json(StagedSourceSpan, _ast_object_field(object, "source_span")),
        parser_spec_id = _ast_string(object, "parser_spec_id"),
        top_rule = _ast_string(object, "top_rule"),
        result_policy = _ast_string(object, "result_policy"),
        result_field = _ast_string(object, "result_field"),
        failure_policy = _ast_string(object, "failure_policy"),
        diagnostic_owner = _ast_optional_string(object, "diagnostic_owner"),
    )
end

function from_json(::Type{FunctionDefinition}, json)
    object = _ast_object(json, "function")
    parse_job = get(object, "body_parse_job", nothing)
    return FunctionDefinition(
        name = _ast_string(object, "name"),
        params = _ast_string_list(object, "params"),
        arity = _ast_int(object, "arity"),
        body_source = _ast_string(object, "body_source"),
        body_payload = _ast_optional_json(object, "body_payload"),
        body_parse_job = parse_job === nothing ? nothing : from_json(StagedParseJob, parse_job),
        body_ast = _ast_optional_json(object, "body_ast"),
        source = _ast_string(object, "source"),
        source_span = from_json(SourceSpan, _ast_object_field(object, "source_span")),
        body_span = from_json(SourceSpan, _ast_object_field(object, "body_span")),
    )
end

function from_json(::Type{RuleMode}, json)
    if json isa AbstractString
        name = String(json)
        if !(name in ("Default", "And", "AndPlus", "Or", "OrPlus", "Single", "Pipe", "Plus", "Star", "Optional"))
            throw(SpecAstException("unsupported rule mode $name"))
        end
        return RuleMode(name)
    end
    object = _ast_object(json, "mode")
    if length(object) != 1
        throw(SpecAstException("bounded rule mode must have exactly one key"))
    end
    name = only(collect(keys(object)))
    bounds = _ast_object(object[name], name)
    min = _ast_int(bounds, "min")
    max = _ast_optional_int(bounds, "max")
    if name == "AndBounded"
        return and_bounded_rule_mode(min = min, max = max)
    elseif name == "OrBounded"
        return or_bounded_rule_mode(min = min, max = max)
    end
    throw(SpecAstException("unsupported bounded rule mode $name"))
end

function from_json(::Type{RuleHeader}, json)
    object = _ast_object(json, "header")
    return RuleHeader(
        _ast_string(object, "label"),
        _ast_bool(object, "is_top"),
        from_json(RuleMode, object["mode"]),
        _ast_string(object, "rest"),
        _ast_int(object, "line"),
    )
end

function from_json(::Type{AbstractBodyElementKind}, json)
    object = _ast_object(json, "kind")
    kind = _ast_string(object, "kind")
    if kind == "regex"
        return RegexBodyElementKind(_ast_string(object, "pattern"))
    elseif kind == "action_edge"
        return ActionEdgeBodyElementKind(
            targets = _ast_object_list(object, "targets", item -> from_json(EdgeTarget, item)),
            code = _ast_optional_string(object, "code"),
            fluent_chain = _ast_object_list(object, "fluent_chain", item -> from_json(FluentCall, item); default = Any[]),
        )
    elseif kind == "blind_edge"
        return BlindEdgeBodyElementKind(
            target = _ast_string(object, "target"),
            code = _ast_optional_string(object, "code"),
            fluent_chain = _ast_object_list(object, "fluent_chain", item -> from_json(FluentCall, item); default = Any[]),
        )
    elseif kind == "code_block"
        return CodeBlockBodyElementKind(_ast_string(object, "lifecycle"), _ast_string(object, "code"))
    elseif kind == "plain_block"
        return PlainBlockBodyElementKind(_ast_string(object, "code"))
    elseif kind == "split_marker"
        return SplitMarkerBodyElementKind(_ast_string(object, "marker"))
    elseif kind == "lifecycle_marker"
        return LifecycleMarkerBodyElementKind(_ast_string(object, "marker"))
    elseif kind == "fluent_chain"
        return FluentChainBodyElementKind(calls = _ast_object_list(object, "calls", item -> from_json(FluentCall, item)))
    elseif kind == "conditional"
        return ConditionalBodyElementKind(_ast_string(object, "word"))
    elseif kind == "raw"
        return RawBodyElementKind(_ast_string(object, "text"))
    end
    throw(SpecAstException("unsupported body element kind $kind"))
end

function from_json(::Type{EdgeTarget}, json)
    object = _ast_object(json, "edge target")
    return EdgeTarget(label = _ast_string(object, "label"), index = _ast_int(object, "index"))
end

function from_json(::Type{FluentCall}, json)
    object = _ast_object(json, "fluent call")
    return FluentCall(_ast_string(object, "method"), _ast_string(object, "args"))
end

function from_json(::Type{BodyElement}, json)
    object = _ast_object(json, "body element")
    return BodyElement(
        from_json(AbstractBodyElementKind, _ast_object_field(object, "kind")),
        _ast_string(object, "source"),
        _ast_int(object, "line"),
    )
end

function from_json(::Type{Rule}, json)
    object = _ast_object(json, "rule")
    return Rule(
        header = from_json(RuleHeader, _ast_object_field(object, "header")),
        body = _ast_object_list(object, "body", item -> from_json(BodyElement, item)),
    )
end

function from_json(::Type{SpecFile}, json)
    object = _ast_object(json, "spec")
    return SpecFile(
        functions = _ast_object_list(object, "functions", item -> from_json(FunctionDefinition, item); default = Any[]),
        rules = _ast_object_list(object, "rules", item -> from_json(Rule, item)),
    )
end

function _put_if_present!(dict::Dict{String,Any}, key::String, value)
    if value !== nothing
        dict[key] = value
    end
    return dict
end

function _ast_object(value, context::AbstractString)
    if !(value isa AbstractDict)
        throw(SpecAstException("$context must be a JSON object"))
    end
    return Dict{String,Any}(String(key) => val for (key, val) in value)
end

function _ast_object_field(json::AbstractDict, field::AbstractString)
    return _ast_object(get(json, field, nothing), field)
end

function _ast_string(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if !(value isa AbstractString)
        throw(SpecAstException("$field must be a string"))
    end
    return String(value)
end

function _ast_optional_string(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if value === nothing
        return nothing
    end
    if !(value isa AbstractString)
        throw(SpecAstException("$field must be a string when present"))
    end
    return String(value)
end

function _ast_int(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if !(value isa Integer) || value isa Bool
        throw(SpecAstException("$field must be an integer"))
    end
    return Int(value)
end

function _ast_optional_int(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if value === nothing
        return nothing
    end
    if !(value isa Integer) || value isa Bool
        throw(SpecAstException("$field must be an integer when present"))
    end
    return Int(value)
end

function _ast_bool(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if !(value isa Bool)
        throw(SpecAstException("$field must be a boolean"))
    end
    return value
end

function _ast_optional_json(json::AbstractDict, field::AbstractString)
    if !haskey(json, field)
        return nothing
    end
    return _plain_json(json[field])
end

function _ast_string_list(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if !(value isa AbstractVector)
        throw(SpecAstException("$field must be an array"))
    end
    return [_ast_string_list_item(item, field) for item in value]
end

function _ast_optional_string_list(json::AbstractDict, field::AbstractString)
    value = get(json, field, nothing)
    if value === nothing
        return nothing
    end
    if !(value isa AbstractVector)
        throw(SpecAstException("$field must be an array when present"))
    end
    return [_ast_string_list_item(item, field) for item in value]
end

function _ast_string_list_item(value, field::AbstractString)
    if !(value isa AbstractString)
        throw(SpecAstException("$field must contain only strings"))
    end
    return String(value)
end

function _ast_object_list(json::AbstractDict, field::AbstractString, build; default = nothing)
    value = get(json, field, nothing)
    if value === nothing && default !== nothing
        return default
    end
    if !(value isa AbstractVector)
        throw(SpecAstException("$field must be an array"))
    end
    return [build(_ast_object(item, field)) for item in value]
end
