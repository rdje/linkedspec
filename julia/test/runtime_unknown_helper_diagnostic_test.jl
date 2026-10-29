# TYPE-REFERENCE-BOOK.1.2.23.3.39.3.8 — owning unknown-helper diagnostics.
module JuliaRuntimeUnknownHelperDiagnostics
using LinkedSpecJulia, JSON3, Test

function attempt(operation)
    try
        return operation()
    catch failure
        return failure
    end
end

@testset "Julia ordinary unknown-helper diagnostics" begin
    fixtures = JSON3.read(
        read(joinpath(@__DIR__, "runtime_unknown_helper_diagnostic_cases.json"), String),
        Vector{Dict{String,Any}},
    )
    for fixture in fixtures
        @testset "$(fixture["name"])" begin
            parsed = parse_spec_with_staged_user_function_definitions(fixture["source"])
            compiled = compile_spec(parsed)
            restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
            for row in fixture["cases"]
                operations = (
                    ("native", () -> runtime_parse(LinkedSpecRuntimeEngine(compiled), row["input"])),
                    ("restored", () -> runtime_parse(
                        LinkedSpecRuntimeEngine(compile_spec(restored)), row["input"],
                    )),
                    ("plan", () -> execute_generated_parser_v2(
                        compiled, build_generated_rule_plan(compiled), row["input"],
                        "julia-unknown-helper.spec",
                    )),
                )
                for (route, operation) in operations
                    actual = attempt(operation)
                    if haskey(row, "error_code")
                        @test actual isa Exception
                        @test occursin(row["error_contains"], sprint(showerror, actual))
                        if route == "plan"
                            @test nameof(typeof(actual)) == :GeneratedSourceException
                        else
                            @test actual isa RuntimeInterpreterException
                            if actual isa RuntimeInterpreterException
                                @test actual.diagnostic !== nothing
                                if actual.diagnostic !== nothing
                                    @test actual.diagnostic.code == row["error_code"]
                                    @test actual.diagnostic.stage == row["error_stage"]
                                    @test actual.diagnostic.rule_label == row["error_rule"]
                                end
                            end
                        end
                    else
                        @test !(actual isa Exception)
                        if !(actual isa Exception)
                            if route == "plan"
                                @test actual == row["expected"]
                            else
                                @test actual.value == row["expected"]
                                @test actual.matched === row["expected_match"]
                                @test to_json(actual)["cursor_code_unit"] == row["expected_cursor"]
                            end
                        end
                    end
                end
            end
        end
    end
end
end
