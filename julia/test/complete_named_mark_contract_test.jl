const COMPLETE_NAMED_MARK_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "complete_named_mark_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _compile_complete_named_mark_source(source::AbstractString)
    spec = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _complete_named_mark_fixture()
    fixture = COMPLETE_NAMED_MARK_CONTRACT["fixture"]
    expected = JSON3.read(JSON3.write(fixture["expected"]), Dict{String,Any})
    return fixture, expected
end

@testset "Julia complete named-mark contract" begin
    @test COMPLETE_NAMED_MARK_CONTRACT["contract_id"] ==
          "linkedspec-complete-named-mark-v1"

    @testset "admits exactly seven complete named-mark inventory names" begin
        names = Set{String}(
            String(helper["name"])
            for helper in COMPLETE_NAMED_MARK_CONTRACT["helpers"]
        )
        @test COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES == names
        @test length(COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES) == 7
        @test all(is_known_action_ir_call_name, COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES)
        @test intersect(
            COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES,
            LinkedSpecJulia._SUPPORTED_ACTION_IR_CALL_NAMES,
        ) == names
    end

    @testset "matches native, generated-plan, and emitted-state routes" begin
        fixture, expected = _complete_named_mark_fixture()
        compiled = _compile_complete_named_mark_source(fixture["spec_source"])

        @test runtime_execute(
            LinkedSpecRuntimeEngine(compiled),
            fixture["input"],
        ).value == expected

        plan = build_generated_rule_plan(compiled)
        @test execute_generated_parser_v2(
            compiled,
            plan,
            fixture["input"],
            "complete-named-mark.spec",
        ) == expected

        generated = emit_julia_source_v2(compiled, "complete-named-mark.spec")
        @test occursin("linkedspec-generated-source-v2", generated)
        matched = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", generated)
        @test matched !== nothing
        normalized = JSON3.read(
            String(hex2bytes(matched.captures[1])),
            Dict{String,Any},
        )
        reconstructed = compile_spec(from_json(SpecFile, normalized))
        @test runtime_execute(
            LinkedSpecRuntimeEngine(reconstructed),
            fixture["input"],
        ).value == expected
    end

    @testset "matches the primary Julia CLI" begin
        fixture, expected = _complete_named_mark_fixture()
        output = IOBuffer()
        errors = IOBuffer()
        status = LinkedSpecJulia.run_cli(
            [
                "--inline-spec",
                fixture["spec_source"],
                "--input",
                fixture["input"],
            ];
            io = output,
            err = errors,
        )

        @test status == 0
        @test isempty(take!(errors))
        @test JSON3.read(String(take!(output)), Dict{String,Any}) == expected
    end
end
