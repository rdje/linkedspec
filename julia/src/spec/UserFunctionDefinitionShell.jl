struct UserFunctionDefinitionException <: Exception
    message::String
end

Base.showerror(io::IO, error::UserFunctionDefinitionException) = print(io, error.message)

struct UserFunctionDefinitionProjection
    functions::Vector{FunctionDefinition}
    stripped_source::String
end

struct _UserFunctionAstSpan
    start::Int
    stop::Int
    line_start::Int
    line_end::Int
end

function Base.:(==)(left::_UserFunctionAstSpan, right::_UserFunctionAstSpan)
    return left.start == right.start &&
        left.stop == right.stop &&
        left.line_start == right.line_start &&
        left.line_end == right.line_end
end

struct _ProjectedUserFunction
    function_definition::FunctionDefinition
    source_span::_UserFunctionAstSpan
end

function parse_spec_with_user_function_definition_asts(
    source::AbstractString,
    definition_nodes;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    source_text = String(source)
    nodes = collect(definition_nodes)
    scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_frontend:function_shell:parse_spec",
        "bytes=$(ncodeunits(source_text)) definition_nodes=$(length(nodes))",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    try
        projection = project_user_function_definition_asts(
            source_text,
            nodes;
            trace = trace,
        )
        rule_spec = parse_spec(projection.stripped_source; trace = trace)
        spec = SpecFile(functions = projection.functions, rules = rule_spec.rules)
        exit_details =
            "status=ok functions=$(length(spec.functions)) rules=$(length(spec.rules))"
        return spec
    catch error
        exit_details = "status=error error=$(sprint(showerror, error))"
        if error isa SpecParseException
            throw(SpecParseException(
                error.line,
                "rule parse after function extraction failed: $(error.message)",
            ))
        end
        rethrow()
    finally
        if trace !== nothing && scope !== nothing
            exit_trace_scope!(trace, scope, exit_details)
        end
    end
end

function project_user_function_definition_asts(
    source::AbstractString,
    definition_nodes;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    source_text = String(source)
    nodes = collect(definition_nodes)
    scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_frontend:function_shell:project",
        "bytes=$(ncodeunits(source_text)) definition_nodes=$(length(nodes))",
        LinkedSpecTraceMedium,
    )
    exit_details = "status=error error=unknown"
    functions = FunctionDefinition[]
    spans = _UserFunctionAstSpan[]

    try
        for (index, node) in enumerate(nodes)
            zero_index = index - 1
            object = _ufd_object(node, "definition node $zero_index")
            node_type = _ufd_string_field(object, "type", "definition node")
            if node_type == "function_definition"
                projected = _function_from_definition_ast(object, source_text, zero_index)
                push!(functions, projected.function_definition)
                push!(spans, projected.source_span)
                if trace !== nothing
                    trace_decision!(
                        trace,
                        "julia_frontend:function_shell:project:definition",
                        true,
                        "index=$zero_index name=$(projected.function_definition.name) arity=$(projected.function_definition.arity)",
                        LinkedSpecTraceMedium,
                    )
                end
            elseif node_type == "function_definition_error"
                throw(_function_definition_error(object, zero_index))
            else
                throw(UserFunctionDefinitionException(
                    "user_function_definition.spec returned unsupported node type '$node_type' at index $zero_index",
                ))
            end
        end

        projection = UserFunctionDefinitionProjection(
            functions,
            _strip_function_definition_spans(source_text, spans),
        )
        exit_details = "status=ok functions=$(length(functions))"
        return projection
    catch error
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_frontend:function_shell:project:definition",
                false,
                "error=$(sprint(showerror, error))",
                LinkedSpecTraceMedium,
            )
        end
        exit_details = "status=error error=$(sprint(showerror, error))"
        rethrow()
    finally
        if trace !== nothing && scope !== nothing
            exit_trace_scope!(trace, scope, exit_details)
        end
    end
end

function definition_nodes_from_user_function_definition_output(output)
    if output === nothing
        return Any[]
    end
    if output isa AbstractDict
        return Any[output]
    end
    if output isa AbstractVector
        if isempty(output)
            return Any[]
        end
        if all(item -> item isa AbstractDict, output)
            return Any[item for item in output]
        end
        if length(output) == 1
            return definition_nodes_from_user_function_definition_output(output[begin])
        end
        if all(item -> item isa AbstractVector, output)
            flattened = Any[]
            for item in output
                append!(flattened, definition_nodes_from_user_function_definition_output(item))
            end
            return flattened
        end
    end
    throw(UserFunctionDefinitionException(
        "user_function_definition.spec returned unsupported output shape: $(repr(output))",
    ))
end

function _function_from_definition_ast(object::Dict{String,Any}, source::String, index::Int)
    _ufd_assert_string_field(object, "kind", "user_function_definition", index)
    version = _ufd_int_field(object, "version", index)

    name = _ufd_string_field(object, "name", "function_definition")
    if !_is_identifier(name)
        throw(UserFunctionDefinitionException("function_definition node $index has invalid name '$name'"))
    end

    params = String[]
    arity = 0
    signature = nothing
    if version == 1
        if haskey(object, "signature")
            throw(UserFunctionDefinitionException(
                "function_definition node $index version 1 must not contain signature",
            ))
        end
        params = _ufd_string_list_field(object, "params", index)
        arity = _ufd_int_field(object, "arity", index)
    elseif version == 2
        if haskey(object, "params") || haskey(object, "arity")
            throw(UserFunctionDefinitionException(
                "function_definition node $index version 2 must store arity only in signature",
            ))
        end
        signature = _ufd_callable_signature_field(object, "signature", index)
        params = copy(signature.positional_params)
        arity = signature.min_arity
    else
        throw(UserFunctionDefinitionException(
            "function_definition node $index has unsupported version $version",
        ))
    end
    for param in params
        if !_is_identifier(param)
            throw(UserFunctionDefinitionException("function_definition node $index has invalid parameter '$param'"))
        end
    end

    if arity != length(params)
        throw(UserFunctionDefinitionException(
            "function_definition node $index arity $arity does not match $(length(params)) params",
        ))
    end

    source_text = _ufd_string_field(object, "source_text", "function_definition")
    source_span = _ufd_span_field(object, "source_span", index)
    _validate_span_text(source, source_span, source_text, "source_text", index)

    body_source = _ufd_string_field(object, "body_source", "function_definition")
    body_span = _ufd_span_field(object, "body_span", index)
    _validate_span_text(source, body_span, body_source, "body_source", index)
    if source_span.start > body_span.start || body_span.start > body_span.stop || body_span.stop > source_span.stop
        throw(UserFunctionDefinitionException("function_definition node $index body span is outside source span"))
    end

    body_payload = _copy_json(_ufd_required_value(object, "body_payload", index))
    _validate_body_payload(body_payload, name, params, arity, signature, body_source, body_span, index)
    _normalize_parent_ast_path!(body_payload, index, "body_payload")

    body_parse_job = _copy_json(_ufd_required_value(object, "body_parse_job", index))
    _validate_body_parse_job(body_parse_job, name, params, arity, signature, body_source, body_span, index)
    _normalize_body_parse_job!(body_parse_job, index, body_span)

    return _ProjectedUserFunction(
        FunctionDefinition(
            name = name,
            params = params,
            arity = arity,
            signature = signature,
            body_source = body_source,
            body_payload = body_payload,
            body_parse_job = from_json(StagedParseJob, _ufd_object(body_parse_job, "body_parse_job")),
            source = source_text,
            source_span = SourceSpan(source_span.line_start, source_span.line_end),
            body_span = SourceSpan(body_span.line_start, body_span.line_end),
        ),
        source_span,
    )
end

function _strip_function_definition_spans(source::String, spans::Vector{_UserFunctionAstSpan})
    if isempty(spans)
        return source
    end

    chars = collect(source)
    char_length = length(chars)
    sorted = sort(spans; by = span -> span.start)
    previous_end = 0
    for span in sorted
        if span.start > span.stop || span.stop > char_length
            throw(UserFunctionDefinitionException(
                "function definition span $(span.start)..$(span.stop) is outside source length $char_length",
            ))
        end
        if span.start < previous_end
            throw(UserFunctionDefinitionException(
                "function definition spans overlap at $(span.start)..$(span.stop)",
            ))
        end
        previous_end = span.stop
    end

    output = IOBuffer()
    span_index = 1
    for (char_index, char) in enumerate(chars)
        zero_index = char_index - 1
        while span_index <= length(sorted) && zero_index >= sorted[span_index].stop
            span_index += 1
        end
        inside_span = span_index <= length(sorted) &&
            zero_index >= sorted[span_index].start &&
            zero_index < sorted[span_index].stop
        if inside_span && char != '\n' && char != '\r'
            write(output, ' ')
        else
            write(output, char)
        end
    end
    return String(take!(output))
end

function _validate_body_payload(payload, name::String, params::Vector{String}, arity::Int, signature, body_source::String, body_span::_UserFunctionAstSpan, index::Int)
    object = _ufd_object(payload, "function_definition node $index body_payload")
    _ufd_assert_string_field(object, "kind", "staged_payload", index)
    _ufd_assert_string_field(object, "node_kind", "function_definition", index)
    _ufd_assert_string_field(object, "payload_kind", "function_body", index)
    _validate_function_body_parent_path(object, "body_payload", index)
    if _ufd_string_field(object, "function_name", "body_payload") != name
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_payload function_name does not match name",
        ))
    end
    _validate_staged_signature(object, "body_payload", params, arity, signature, index)
    if _ufd_string_field(object, "text", "body_payload") != body_source
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_payload text does not match body_source",
        ))
    end
    if _ufd_span_field(object, "source_span", index) != body_span
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_payload source_span does not match body_span",
        ))
    end
    return nothing
end

function _validate_body_parse_job(job, name::String, params::Vector{String}, arity::Int, signature, body_source::String, body_span::_UserFunctionAstSpan, index::Int)
    object = _ufd_object(job, "function_definition node $index body_parse_job")
    _ufd_assert_string_field(object, "kind", "parse_job", index)
    _ufd_assert_string_field(object, "node_kind", "function_definition", index)
    _ufd_assert_string_field(object, "payload_kind", "function_body", index)
    _validate_function_body_parent_path(object, "body_parse_job", index)
    if isempty(_ufd_string_field(object, "job_id", "body_parse_job"))
        throw(UserFunctionDefinitionException("function_definition node $index body_parse_job job_id must be non-empty"))
    end
    if _ufd_string_field(object, "function_name", "body_parse_job") != name
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_parse_job function_name does not match name",
        ))
    end
    _validate_staged_signature(object, "body_parse_job", params, arity, signature, index)
    if _ufd_string_field(object, "text", "body_parse_job") != body_source
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_parse_job text does not match body_source",
        ))
    end
    if _ufd_span_field(object, "source_span", index) != body_span
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_parse_job source_span does not match body_span",
        ))
    end
    if _ufd_string_field(object, "parser_spec_id", "body_parse_job") != "actionir-body.spec"
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_parse_job parser_spec_id must be actionir-body.spec",
        ))
    end
    if _ufd_string_field(object, "top_rule", "body_parse_job") != "action_block"
        throw(UserFunctionDefinitionException("function_definition node $index body_parse_job top_rule must be action_block"))
    end
    if _ufd_string_field(object, "result_policy", "body_parse_job") != "replace_field"
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_parse_job result_policy must be replace_field",
        ))
    end
    if _ufd_string_field(object, "result_field", "body_parse_job") != "body_ast"
        throw(UserFunctionDefinitionException("function_definition node $index body_parse_job result_field must be body_ast"))
    end
    if _ufd_string_field(object, "failure_policy", "body_parse_job") != "fail"
        throw(UserFunctionDefinitionException("function_definition node $index body_parse_job failure_policy must be fail"))
    end
    if _ufd_string_field(object, "diagnostic_owner", "body_parse_job") != "function_body"
        throw(UserFunctionDefinitionException(
            "function_definition node $index body_parse_job diagnostic_owner must be function_body",
        ))
    end
    return nothing
end

function _validate_staged_signature(object::Dict{String,Any}, context::String, params::Vector{String}, arity::Int, signature, index::Int)
    if signature !== nothing
        if haskey(object, "params") || haskey(object, "arity")
            throw(UserFunctionDefinitionException(
                "function_definition node $index $context version 2 must store arity only in signature",
            ))
        end
        actual = _ufd_callable_signature_field(object, "signature", index)
        if actual != signature
            throw(UserFunctionDefinitionException(
                "function_definition node $index $context signature does not match signature",
            ))
        end
        return nothing
    end
    if haskey(object, "signature")
        throw(UserFunctionDefinitionException(
            "function_definition node $index $context version 1 must not contain signature",
        ))
    end
    if _ufd_string_list_field(object, "params", index) != params
        throw(UserFunctionDefinitionException("function_definition node $index $context params do not match params"))
    end
    if _ufd_int_field(object, "arity", index) != arity
        throw(UserFunctionDefinitionException("function_definition node $index $context arity does not match arity"))
    end
    return nothing
end

function _validate_function_body_parent_path(object::Dict{String,Any}, context::String, index::Int)
    path = _ufd_string_list_field(object, "parent_ast_path", index)
    if length(path) != 3 || path[1] != "functions" || path[3] != "body_source"
        throw(UserFunctionDefinitionException(
            "function_definition node $index $context parent_ast_path must target functions[*].body_source",
        ))
    end
    return nothing
end

function _normalize_parent_ast_path!(value, index::Int, context::String)
    object = _ufd_mutable_object(value, "function_definition node $index $context")
    object["parent_ast_path"] = ["functions", string(index), "body_source"]
    return object
end

function _normalize_body_parse_job!(job, index::Int, body_span::_UserFunctionAstSpan)
    object = _normalize_parent_ast_path!(job, index, "body_parse_job")
    object["job_id"] = "parse_job:function_body:functions.$index.body_source:actionir-body.spec:action_block:$(body_span.start)-$(body_span.stop)"
    return object
end

function _validate_span_text(source::String, span::_UserFunctionAstSpan, expected::String, field::String, index::Int)
    actual = _char_slice(source, span.start, span.stop)
    if actual === nothing
        throw(UserFunctionDefinitionException(
            "function_definition node $index $field span $(span.start)..$(span.stop) is outside source",
        ))
    end
    if actual != expected
        throw(UserFunctionDefinitionException("function_definition node $index $field does not match its source span"))
    end
    return nothing
end

function _char_slice(source::String, start::Int, stop::Int)
    if start > stop
        return nothing
    end
    chars = collect(source)
    if stop > length(chars)
        return nothing
    end
    if start == stop
        return ""
    end
    return String(chars[(start + 1):stop])
end

function _ufd_span_field(object::Dict{String,Any}, field::String, index::Int)
    span = _ufd_object(_ufd_required_value(object, field, index), "function_definition node $index $field")
    start = _ufd_int_field(span, "start", index)
    stop = _ufd_int_field(span, "end", index)
    line_start = _ufd_int_field(span, "line_start", index)
    line_end = _ufd_int_field(span, "line_end", index)
    if line_start == 0 || line_end == 0 || line_start > line_end
        throw(UserFunctionDefinitionException(
            "function_definition node $index $field has invalid line span $line_start..$line_end",
        ))
    end
    if start > stop
        throw(UserFunctionDefinitionException(
            "function_definition node $index $field has invalid character span $start..$stop",
        ))
    end
    return _UserFunctionAstSpan(start, stop, line_start, line_end)
end

function _ufd_required_value(object::Dict{String,Any}, field::String, index::Int)
    if !haskey(object, field)
        throw(UserFunctionDefinitionException("function_definition node $index is missing field '$field'"))
    end
    return object[field]
end

function _ufd_object(value, context::AbstractString)
    if !(value isa AbstractDict)
        throw(UserFunctionDefinitionException("$context must be a JSON object"))
    end
    return Dict{String,Any}(String(key) => val for (key, val) in value)
end

function _ufd_mutable_object(value, context::AbstractString)
    if value isa Dict{String,Any}
        return value
    end
    return _ufd_object(value, context)
end

function _ufd_string_field(object::Dict{String,Any}, field::String, context::String)
    value = get(object, field, nothing)
    if !(value isa AbstractString)
        throw(UserFunctionDefinitionException("$context is missing string field '$field'"))
    end
    return String(value)
end

function _ufd_assert_string_field(object::Dict{String,Any}, field::String, expected::String, index::Int)
    actual = _ufd_string_field(object, field, "function_definition")
    if actual != expected
        throw(UserFunctionDefinitionException(
            "function_definition node $index expected $field='$expected', got '$actual'",
        ))
    end
    return nothing
end

function _ufd_string_list_field(object::Dict{String,Any}, field::String, index::Int)
    value = get(object, field, nothing)
    if !(value isa AbstractVector)
        throw(UserFunctionDefinitionException("function_definition node $index is missing array field '$field'"))
    end
    result = String[]
    for (item_index, item) in enumerate(value)
        if !(item isa AbstractString)
            throw(UserFunctionDefinitionException(
                "function_definition node $index field '$field' item $(item_index - 1) is not a string",
            ))
        end
        push!(result, String(item))
    end
    return result
end

function _ufd_callable_signature_field(object::Dict{String,Any}, field::String, index::Int)
    signature = _ufd_object(
        _ufd_required_value(object, field, index),
        "function_definition node $index $field",
    )
    expected_fields = Set([
        "kind",
        "version",
        "positional_params",
        "rest_param",
        "min_arity",
        "max_arity",
    ])
    if Set(keys(signature)) != expected_fields
        throw(UserFunctionDefinitionException(
            "function_definition node $index field '$field' has invalid callable signature fields",
        ))
    end
    _ufd_assert_string_field(signature, "kind", "callable_signature", index)
    version = _ufd_int_field(signature, "version", index)
    if version != 1
        throw(UserFunctionDefinitionException(
            "function_definition node $index field '$field' has unsupported signature version $version",
        ))
    end
    positional_params = _ufd_string_list_field(signature, "positional_params", index)
    for param in positional_params
        if !_is_identifier(param)
            throw(UserFunctionDefinitionException(
                "function_definition node $index has invalid positional parameter '$param'",
            ))
        end
    end
    rest_param = _ufd_string_field(signature, "rest_param", "callable_signature")
    if !_is_identifier(rest_param)
        throw(UserFunctionDefinitionException(
            "function_definition node $index has invalid rest parameter '$rest_param'",
        ))
    end
    min_arity = _ufd_int_field(signature, "min_arity", index)
    if min_arity != length(positional_params)
        throw(UserFunctionDefinitionException(
            "function_definition node $index min_arity $min_arity does not match " *
            "$(length(positional_params)) positional params",
        ))
    end
    if !haskey(signature, "max_arity") || signature["max_arity"] !== nothing
        throw(UserFunctionDefinitionException(
            "function_definition node $index field '$field' max_arity must be null",
        ))
    end
    return CallableSignature(
        positional_params = positional_params,
        rest_param = rest_param,
        min_arity = min_arity,
    )
end

function _ufd_int_field(object::Dict{String,Any}, field::String, index::Int)
    value = get(object, field, nothing)
    if value isa Integer && value >= 0
        return Int(value)
    end
    throw(UserFunctionDefinitionException(
        "function_definition node $index field '$field' must be a non-negative integer",
    ))
end

function _copy_json(value)
    if value isa AbstractDict
        return Dict{String,Any}(String(key) => _copy_json(val) for (key, val) in value)
    elseif value isa AbstractVector
        return Any[_copy_json(item) for item in value]
    end
    return value
end

function _function_definition_error(object::Dict{String,Any}, index::Int)
    line = 0
    span_value = get(object, "source_span", nothing)
    if span_value isa AbstractDict
        span = _ufd_object(span_value, "source_span")
        line_start = get(span, "line_start", nothing)
        if line_start isa Integer
            line = Int(line_start)
        end
    end
    message_value = get(object, "message", nothing)
    message = message_value isa AbstractString ? String(message_value) : "invalid user function definition"
    if line > 0
        return SpecParseException(line, "user function definition parse error at line $line: $message")
    end
    return SpecParseException(1, "user function definition parse error at node $index: $message")
end
