struct UserFunctionDefinitionParserException <: Exception
    message::String
end

Base.showerror(io::IO, error::UserFunctionDefinitionParserException) =
    print(io, error.message)

struct UserFunctionDefinitionAstParser
    compiled_spec::CompiledSpec
end

function UserFunctionDefinitionAstParser(parser_spec_source::AbstractString)
    parser_spec = try
        parse_spec(parser_spec_source)
    catch error
        if error isa SpecParseException
            throw(UserFunctionDefinitionParserException(
                "failed to parse user_function_definition.spec: $(error.message)",
            ))
        end
        rethrow()
    end

    compiled_spec = try
        compile_spec(parser_spec)
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
    return UserFunctionDefinitionAstParser(compiled_spec)
end

function parse_user_function_definition_asts(
    parser::UserFunctionDefinitionAstParser,
    source::AbstractString,
)
    source_text = String(source)
    result = try
        runtime_execute(
            LinkedSpecRuntimeEngine(
                parser.compiled_spec;
                spec_name = "user_function_definition.spec",
            ),
            source_text,
        )
    catch error
        if error isa RuntimeInterpreterException
            throw(UserFunctionDefinitionParserException(
                "user_function_definition.spec execution failed: $(error.message)",
            ))
        end
        rethrow()
    end

    if !result.matched && !_has_only_ignorable_user_function_remainder(source_text, result)
        throw(UserFunctionDefinitionParserException(
            "user_function_definition.spec did not match input; " *
            "cursor_codeunit=$(result.cursor_codeunit)",
        ))
    end
    return definition_nodes_from_user_function_definition_output(result.value)
end

function parse_user_function_definition_asts(
    source::AbstractString;
    parser_spec_source = nothing,
)
    parser = parser_spec_source === nothing ?
        _default_user_function_definition_ast_parser() :
        UserFunctionDefinitionAstParser(String(parser_spec_source))
    return parse_user_function_definition_asts(parser, source)
end

function parse_spec_with_staged_user_function_definitions(
    source::AbstractString;
    parser_spec_source = nothing,
)
    nodes = parse_user_function_definition_asts(
        source;
        parser_spec_source = parser_spec_source,
    )
    return parse_spec_with_staged_user_function_definition_asts(source, nodes)
end

const _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER =
    Ref{Union{Nothing,UserFunctionDefinitionAstParser}}(nothing)
const _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER_LOCK = ReentrantLock()

function _default_user_function_definition_ast_parser()
    return lock(_DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER_LOCK) do
        cached = _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER[]
        if cached === nothing
            cached = UserFunctionDefinitionAstParser(
                read(_user_function_definition_spec_path(), String),
            )
            _DEFAULT_USER_FUNCTION_DEFINITION_AST_PARSER[] = cached
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
