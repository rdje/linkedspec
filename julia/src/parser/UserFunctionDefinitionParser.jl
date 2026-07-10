struct UserFunctionDefinitionParserException <: Exception
    message::String
end

Base.showerror(io::IO, error::UserFunctionDefinitionParserException) =
    print(io, error.message)

struct UserFunctionDefinitionAstParser
    compiled_spec::CompiledSpec
end

function UserFunctionDefinitionAstParser(
    parser_spec_source::AbstractString;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    source_text = String(parser_spec_source)
    scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_frontend:function_shell:compile_parser_spec",
        "bytes=$(ncodeunits(source_text))",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    stage = "parse"
    try
        parser_spec = try
            parse_spec(source_text; trace = trace)
        catch error
            if error isa SpecParseException
                throw(UserFunctionDefinitionParserException(
                    "failed to parse user_function_definition.spec: $(error.message)",
                ))
            end
            rethrow()
        end

        stage = "compile"
        compiled_spec = try
            compile_spec(parser_spec; trace = trace)
        catch error
            if error isa CompiledSpecException
                throw(UserFunctionDefinitionParserException(
                    "failed to compile user_function_definition.spec: $(error.message)",
                ))
            end
            throw(UserFunctionDefinitionParserException(
                "failed to compile user_function_definition.spec: $(sprint(showerror, error))",
            ))
        end

        exit_details = "status=ok rules=$(length(compiled_spec.compiled_rule_order))"
        return UserFunctionDefinitionAstParser(compiled_spec)
    catch error
        exit_details = "status=error stage=$stage error=$(sprint(showerror, error))"
        rethrow()
    finally
        if trace !== nothing && scope !== nothing
            exit_trace_scope!(trace, scope, exit_details)
        end
    end
end

function parse_user_function_definition_asts(
    parser::UserFunctionDefinitionAstParser,
    source::AbstractString,
    ;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    source_text = String(source)
    scope = trace === nothing ? nothing : enter_trace_scope!(
        trace,
        "julia_frontend:function_shell:parse_definitions",
        "bytes=$(ncodeunits(source_text))",
        LinkedSpecTraceLow,
    )
    exit_details = "status=error error=unknown"
    stage = "execute"
    try
        result = try
            runtime_execute(
                LinkedSpecRuntimeEngine(
                    parser.compiled_spec;
                    spec_name = "user_function_definition.spec",
                ),
                source_text;
                trace = trace,
            )
        catch error
            if error isa RuntimeInterpreterException
                throw(UserFunctionDefinitionParserException(
                    "user_function_definition.spec execution failed: $(error.message)",
                ))
            end
            rethrow()
        end

        stage = "match"
        if !result.matched && !_has_only_ignorable_user_function_remainder(source_text, result)
            throw(UserFunctionDefinitionParserException(
                "user_function_definition.spec did not match input; " *
                "cursor_codeunit=$(result.cursor_codeunit)",
            ))
        end

        stage = "project"
        nodes = definition_nodes_from_user_function_definition_output(result.value)
        if trace !== nothing && scope !== nothing
            trace_decision!(
                trace,
                "julia_frontend:function_shell:parse_definitions:result",
                true,
                "matched=$(result.matched ? 1 : 0) nodes=$(length(nodes))",
                LinkedSpecTraceMedium,
            )
        end
        exit_details = "status=ok nodes=$(length(nodes))"
        return nodes
    catch error
        message = sprint(showerror, error)
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_frontend:function_shell:parse_definitions:result",
                false,
                "stage=$stage error=$message",
                LinkedSpecTraceMedium,
            )
        end
        exit_details = "status=error stage=$stage error=$message"
        rethrow()
    finally
        if trace !== nothing && scope !== nothing
            exit_trace_scope!(trace, scope, exit_details)
        end
    end
end

function parse_user_function_definition_asts(
    source::AbstractString;
    parser_spec_source = nothing,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    parser = parser_spec_source === nothing ?
        _default_user_function_definition_ast_parser(trace = trace) :
        UserFunctionDefinitionAstParser(String(parser_spec_source); trace = trace)
    if trace !== nothing
        trace_decision!(
            trace,
            "julia_frontend:function_shell:parser_source",
            true,
            parser_spec_source === nothing ? "source=default" : "source=explicit",
            LinkedSpecTraceMedium,
        )
    end
    return parse_user_function_definition_asts(parser, source; trace = trace)
end

function parse_spec_with_staged_user_function_definitions(
    source::AbstractString;
    parser_spec_source = nothing,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    nodes = parse_user_function_definition_asts(
        source;
        parser_spec_source = parser_spec_source,
        trace = trace,
    )
    return parse_spec_with_staged_user_function_definition_asts(source, nodes; trace = trace)
end

const _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER =
    Ref{Union{Nothing,UserFunctionDefinitionAstParser}}(nothing)
const _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER_LOCK = ReentrantLock()

function _default_user_function_definition_ast_parser(;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    return lock(_DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER_LOCK) do
        cached = _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER[]
        cache_hit = cached !== nothing
        if cached === nothing
            cached = UserFunctionDefinitionAstParser(
                read(_user_function_definition_spec_path(), String),
                trace = trace,
            )
            _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER[] = cached
        end
        if trace !== nothing
            trace_decision!(
                trace,
                "julia_frontend:function_shell:parser_cache",
                true,
                cache_hit ? "state=hit" : "state=miss compiled=1",
                LinkedSpecTraceMedium,
            )
        end
        return cached
    end
end

function _user_function_definition_spec_path()
    relative_path = joinpath("specs", "user_function_definition.spec")
    for anchor in (@__DIR__, pwd())
        path = _find_user_function_definition_repo_file(anchor, relative_path)
        if path !== nothing
            return path
        end
    end
    throw(UserFunctionDefinitionParserException(
        "cannot locate specs/user_function_definition.spec from the current " *
        "working directory or Julia package path",
    ))
end

function _find_user_function_definition_repo_file(
    anchor::AbstractString,
    relative_path::AbstractString,
)
    directory = abspath(anchor)
    while true
        candidate = joinpath(directory, relative_path)
        if isfile(candidate)
            return candidate
        end
        parent = dirname(directory)
        if parent == directory
            return nothing
        end
        directory = parent
    end
end

function _has_only_ignorable_user_function_remainder(
    source::String,
    result::RuntimeParseResult,
)
    chars = collect(source)
    if result.cursor_char_offset >= length(chars)
        return true
    end
    remainder = String(chars[(result.cursor_char_offset + 1):end])
    return isempty(strip(remainder))
end
