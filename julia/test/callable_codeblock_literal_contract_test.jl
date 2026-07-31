# FUTURE-PARITY-BACKLOG.11.6.1 — Julia callable-codeblock construction/state.

const CALLABLE_CODEBLOCK_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "callable_codeblock_contract.json"),
        String,
    ),
    Dict{String,Any},
)

function _callable_codeblock_assignment_value(source::AbstractString)
    block = parse_action_block("value = $source")
    assignment = only(block.statements).expr
    @test assignment isa ActionAssignScalarExpr
    return assignment.value
end

function _callable_codeblock_brace_kind(expression)
    if expression isa ActionHashLiteralExpr
        return "harray_literal"
    elseif expression isa ActionBlockValueExpr
        return "block_value"
    end
    return expression.kind
end

function _callable_codeblock_compile(source::AbstractString)
    spec = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _callable_codeblock_attempt(call)
    try
        return call()
    catch error
        return error
    end
end

function _callable_codeblock_construction_source(literal::AbstractString)
    return """Top::
 /x/ -> Done {
   state = \"before\";
   cb = $literal;
   alias = copy(cb);
   return({ \"state\" : state, \"cb\" : alias })
 }

Done::
 /x/
"""
end

@testset "Julia callable-codeblock construction contract" begin
    @testset "neutral brace classes and literal records are exact" begin
        for row in CALLABLE_CODEBLOCK_CONTRACT["brace_classification"]
            expression = _callable_codeblock_assignment_value(row["source"])
            @test _callable_codeblock_brace_kind(expression) == row["expected_kind"]
        end

        expected_fields = Set{String}(CALLABLE_CODEBLOCK_CONTRACT["ast_schema"]["fields"])
        for row in CALLABLE_CODEBLOCK_CONTRACT["literals"]
            source = row["source"]
            prefix = "value = "
            expression = _callable_codeblock_assignment_value(source)
            @test expression isa ActionCodeblockLiteralExpr
            record = to_json(expression)
            @test Set{String}(keys(record)) == expected_fields
            @test get(record, "kind", nothing) == "codeblock_literal"
            @test get(record, "version", nothing) == 1
            @test get(record, "source_text", nothing) == source
            @test get(record, "body_source", nothing) == row["body_source"]
            body = get(record, "body_ast", nothing)
            @test body isa AbstractDict
            if body isa AbstractDict
                @test body["kind"] == "action_block"
                @test body["source"] == row["body_source"]
                @test !isempty(body["statements"])
            end
            source_span = get(record, "source_span", Dict{String,Any}())
            @test get(source_span, "start", nothing) == length(prefix)
            @test get(source_span, "end", nothing) == length(prefix * source)

            body_start = findnext('|', source, 3)
            @test body_start !== nothing
            if body_start !== nothing
                body_span = get(record, "body_span", Dict{String,Any}())
                @test get(body_span, "start", nothing) ==
                      length(prefix * first(source, body_start))
                @test get(body_span, "end", nothing) ==
                      length(prefix * chop(source; tail = 1))
            end

            signature = get(record, "signature", Dict{String,Any}())
            signature_source = row["signature_source"]
            parts = isempty(signature_source) ? String[] :
                    [strip(part) for part in split(signature_source, ',')]
            rest = [part[4:end] for part in parts if startswith(part, "...")]
            positional = [part for part in parts if !startswith(part, "...")]
            @test get(signature, "kind", nothing) == "callable_signature"
            @test get(signature, "version", nothing) == 1
            @test get(signature, "positional_params", nothing) == positional
            @test get(signature, "rest_param", nothing) ==
                  (isempty(rest) ? nothing : only(rest))
            @test get(signature, "min_arity", nothing) == length(positional)
            @test get(signature, "max_arity", nothing) ==
                  (isempty(rest) ? length(positional) : nothing)
        end

        nested_source =
            "{|value| return({ \"marker\" : \"|}\", \"nested\" : { \"value\" : value } }) }"
        nested = parse_action_expression(nested_source)
        @test nested isa ActionCodeblockLiteralExpr
        @test nested.source == nested_source
        @test only(nested.body_ast.statements).expr isa ActionCallExpr
    end

    @testset "literal spans use containing Unicode-character coordinates" begin
        source = "note = \"😀\"; cb = {|value| return(value) }"
        block = parse_action_block(source)
        assignment = block.statements[2].expr
        @test assignment isa ActionAssignScalarExpr
        record = to_json(assignment.value)
        literal_start = findfirst("{|", source)
        @test literal_start !== nothing
        if literal_start !== nothing
            prefix_end = prevind(source, first(literal_start))
            expected_start = length(source[firstindex(source):prefix_end])
            @test get(record, "source_span", Dict())["start"] == expected_start
            @test get(record, "source_span", Dict())["end"] == length(source)
        end

        nested_source = "prefix = \"😀\"; cb = {|| nested = {|value| return(value) } }"
        nested_block = parse_action_block(nested_source)
        outer = to_json(nested_block.statements[2].expr.value)
        inner = _callable_codeblock_attempt() do
            outer["body_ast"]["statements"][1]["expr"]["value"]
        end
        @test inner isa AbstractDict
        if inner isa AbstractDict
            inner_start = findlast("{|", nested_source)
            @test inner_start !== nothing
            if inner_start !== nothing
                prefix_end = prevind(nested_source, first(inner_start))
                @test inner["source_span"]["start"] ==
                      length(nested_source[firstindex(nested_source):prefix_end])
            end
        end
    end

    @testset "all malformed literals retain neutral diagnostic codes" begin
        for row in CALLABLE_CODEBLOCK_CONTRACT["invalid_literal_cases"]
            expression = parse_action_expression(row["source"])
            @test expression isa ActionCodeblockLiteralErrorExpr
            record = to_json(expression)
            @test get(record, "code", nothing) == row["expected_code"]
            resolution = resolve_action_expression_contracts(expression)
            @test length(resolution.diagnostics) == 1
            if length(resolution.diagnostics) == 1
                @test only(resolution.diagnostics).code == row["expected_code"]
            end
        end
    end

    @testset "construction compiled state and generated plan remain inert" begin
        literal = only(
            row for row in CALLABLE_CODEBLOCK_CONTRACT["literals"] if
            row["id"] == "mutate_dynamic"
        )
        source = _callable_codeblock_construction_source(literal["source"])
        compiled = _callable_codeblock_attempt(() -> _callable_codeblock_compile(source))
        @test compiled isa CompiledSpec
        if compiled isa CompiledSpec
            direct = runtime_execute(LinkedSpecRuntimeEngine(compiled), "xx").value
            @test direct["state"] == "before"
            @test direct["cb"]["kind"] == "codeblock_literal"
            @test direct["cb"]["source_text"] == literal["source"]
            @test direct["cb"]["body_source"] == literal["body_source"]
            @test direct["cb"]["signature"]["positional_params"] == Any["value"]
            @test occursin("codeblock_literal", JSON3.write(to_json(compiled)))
            @test execute_generated_parser_v2(
                compiled,
                build_generated_rule_plan(compiled),
                "xx",
                "callable-codeblock-construction.spec",
            ) == direct

            generated = emit_julia_source_v2(
                compiled,
                "callable-codeblock-construction.spec",
            )
            matched = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", generated)
            @test matched !== nothing
            if matched !== nothing
                normalized = JSON3.read(
                    String(hex2bytes(matched.captures[1])),
                    Dict{String,Any},
                )
                reconstructed = compile_spec(from_json(SpecFile, normalized))
                @test runtime_execute(
                    LinkedSpecRuntimeEngine(reconstructed),
                    "xx",
                ).value == direct

                mktempdir() do scratch
                    generated_path = joinpath(scratch, "callable_codeblock_generated.jl")
                    write(generated_path, generated)
                    host = Module(gensym(:JuliaCallableCodeblockConstructionHost))
                    Base.include(host, generated_path)
                    parser = Base.invokelatest(
                        () -> getfield(host, :LinkedSpecGeneratedParser),
                    )
                    execute = Base.invokelatest(() -> getfield(parser, :execute))
                    @test Base.invokelatest(execute, "xx") == direct
                end
            end
        end
    end

    @testset "user functions transport literals and nullable signatures stay isolated" begin
        source = """fn identity(value) { return(value) }
fn make() { return({|| return(\"never\") }) }

Top::
 /x/ -> Done {
   state = \"before\";
   from_arg = identity({|value| state = \"wrong\"; return(value) });
   from_result = make();
   return({
     \"state\" : state,
     \"from_arg\" : from_arg,
     \"from_result\" : from_result
   })
 }

Done::
 /x/
"""
        result = runtime_execute(
            LinkedSpecRuntimeEngine(_callable_codeblock_compile(source)),
            "xx",
        ).value
        @test result["state"] == "before"
        @test result["from_arg"]["kind"] == "codeblock_literal"
        @test result["from_result"]["kind"] == "codeblock_literal"
        @test result["from_arg"]["signature"]["positional_params"] == Any["value"]
        @test result["from_result"]["signature"]["max_arity"] == 0

        variadic = parse_spec_with_staged_user_function_definitions(
            """fn gather(...items) { return(items) }

Top::
 /x/
""",
        )
        normalized = JSON3.read(JSON3.write(to_json(variadic)), Dict{String,Any})
        only(normalized["functions"])["signature"]["rest_param"] = nothing
        reconstructed = from_json(SpecFile, normalized)
        error = _callable_codeblock_attempt(() -> validate_spec(reconstructed))
        @test error isa SpecValidationException
        @test occursin("invalid rest parameter", sprint(showerror, error))
    end

    @testset "deferred bodies and semantic signatures remain typed" begin
        literal = parse_action_expression(
            "{|| state = \"wrong\"; missing(); call(Done); return(retv) }",
        )
        @test literal.kind == "codeblock_literal"
        @test isempty(resolve_action_expression_contracts(literal).diagnostics)
        @test only(resolve_action_expression_contracts(parse_action_expression("cb()")).diagnostics).code ==
              "unknown_helper"

        source = """fn identity(value) { return(value) }

Top::
 /x/ -> Done {
   cb = {|left, ...items| return(items) };
   return(cb)
 }

Done::
 /x/
"""
        index = _callable_codeblock_attempt() do
            semantic_index(
                source;
                logical_name = "callable-codeblock-semantic.spec",
                source_detail_ceiling = SemanticSourceNoneDetail,
            )
        end
        @test index isa SemanticIndex
        if index isa SemanticIndex
            projection = LinkedSpecJulia._semantic_static_projection_for_testing(index)
            bindings = [
                record for record in projection["records"] if
                record["kind"] == "binding" && record["name"] == "cb"
            ]
            @test length(bindings) == 1
            if length(bindings) == 1
                shape = only(bindings)["facts"]["value_shape"]
                @test shape["kind"] == "codeblock"
                @test shape["signature"] == Dict{String,Any}(
                    "parameters" => Any[
                        Dict{String,Any}(
                            "name" => "left",
                            "kind" => "value",
                            "required" => true,
                        ),
                    ],
                    "arity_min" => 1,
                    "arity_max" => nothing,
                    "rest_parameter" => "items",
                    "final_codeblock" => false,
                )
            end
        end
    end
end
