const PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "punctuation_light_zero_arg_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

const _PUNCTUATION_SOURCE_FIELDS = Set([
    "source",
    "source_span",
    "source_method",
    "body_source_span",
    "trailing_block_source_span",
])

function _punctuation_semantic_ast(value)
    if value isa AbstractVector
        return [_punctuation_semantic_ast(item) for item in value]
    elseif value isa AbstractDict
        return Dict(
            String(key) => _punctuation_semantic_ast(item)
            for (key, item) in pairs(value)
            if !(String(key) in _PUNCTUATION_SOURCE_FIELDS)
        )
    end
    return value
end

function _compile_punctuation_source(source::AbstractString)
    spec = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _punctuation_action_source(action::AbstractString)
    return "Top::\n" *
           " /x/ -> Done { values = [\"a\", \"b\"]; $action }\n" *
           "Done::\n" *
           " /x/\n"
end

@testset "Julia punctuation-light zero-argument contract" begin
    @test PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT["contract_id"] ==
          "linkedspec-punctuation-light-zero-arg-v1"

    @testset "standalone aliases share parenthesized typed ActionIR" begin
        for case in PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT["standalone_cases"]
            bare = parse_action_statement(case["bare"]).expr
            parenthesized = parse_action_statement(case["parenthesized"]).expr
            @test _punctuation_semantic_ast(to_json(bare)) ==
                  _punctuation_semantic_ast(to_json(parenthesized))
            @test bare.kind == case["expected_ast"]["kind"]
        end

        value_position = parse_action_expression("return(next)")
        @test value_position isa ActionCallExpr
        @test only(value_position.args).value isa ActionVariableExpr
        @test only(value_position.args).value.name == "next"
        @test parse_action_expression("next") isa ActionVariableExpr
    end

    @testset "terminal receiver aliases share parenthesized typed ActionIR" begin
        for case in PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT["receiver_cases"]
            bare = parse_action_expression(case["bare"])
            parenthesized = parse_action_expression(case["parenthesized"])
            @test bare isa ActionFluentChainExpr
            @test _punctuation_semantic_ast(to_json(bare)) ==
                  _punctuation_semantic_ast(to_json(parenthesized))
            @test isempty(last(bare.calls).args)
        end
    end

    @testset "retained identifiers and excluded forms do not broaden" begin
        for case in PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT["retained_noncall_cases"]
            expr = parse_action_expression(case["source"])
            @test expr isa ActionVariableExpr
            @test expr.name == case["source"]
        end

        for case in PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT["invalid_syntax_cases"]
            expr = parse_action_expression(case["source"])
            @test expr isa ActionRawExpr
            @test expr.reason == if case["id"] in (
                "intermediate_generic_receiver",
                "receiver_trailing_block_without_call",
            )
                "invalid_fluent_chain"
            else
                "unsupported_expression"
            end
        end
    end

    @testset "terminal alias preserves existing Julia method resolution" begin
        count_result = runtime_execute(
            LinkedSpecRuntimeEngine(
                _compile_punctuation_source(
                    _punctuation_action_source("return(values.count)"),
                ),
            ),
            "xx",
        )
        @test count_result.value == 2

        bare_result = runtime_execute(
            LinkedSpecRuntimeEngine(
                _compile_punctuation_source(
                    _punctuation_action_source("return(values.contains)"),
                ),
            ),
            "xx",
        )
        parenthesized_result = runtime_execute(
            LinkedSpecRuntimeEngine(
                _compile_punctuation_source(
                    _punctuation_action_source("return(values.contains())"),
                ),
            ),
            "xx",
        )
        @test bare_result.value == parenthesized_result.value
        # Julia already returns 0 for the missing contains needle. Backlog .5
        # owns that helper-arity drift; this syntax leaf preserves the twin.
        @test bare_result.value == 0
    end

    @testset "neutral fixture matches native and generated Julia paths" begin
        fixture = PUNCTUATION_LIGHT_ZERO_ARG_CONTRACT["future_fixture"]
        compiled = _compile_punctuation_source(fixture["spec_source"])
        expected = JSON3.read(JSON3.write(fixture["expected"]), Dict{String,Any})

        @test runtime_execute(
            LinkedSpecRuntimeEngine(compiled),
            fixture["input"],
        ).value == expected

        plan = build_generated_rule_plan(compiled)
        @test execute_generated_parser_v2(
            compiled,
            plan,
            fixture["input"],
            "punctuation-light-zero-arg.spec",
        ) == expected

        generated = emit_julia_source_v2(
            compiled,
            "punctuation-light-zero-arg.spec",
        )
        @test occursin("linkedspec-generated-source-v2", generated)
        encoded = match(
            r"const _COMPILED_SPEC_JSON_HEX = \"([0-9a-f]+)\"",
            generated,
        )
        @test encoded !== nothing
        normalized = JSON3.read(String(hex2bytes(encoded.captures[1])))
        reconstructed = compile_spec(from_json(SpecFile, normalized))
        @test runtime_execute(
            LinkedSpecRuntimeEngine(reconstructed),
            fixture["input"],
        ).value == expected
    end
end
