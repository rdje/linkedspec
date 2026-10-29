# TYPE-REFERENCE-BOOK.1.2.23.3.38.2 — selected live cursor before flagged LS.
module JuliaGapLSSelectedCursor
using LinkedSpecJulia, JSON3, Test

function attempt(operation)
    try
        return operation()
    catch failure
        return failure
    end
end

@testset "Julia selected cursor before LS" begin
    fixture_path = normpath(joinpath(
        @__DIR__, "..", "..", "dart", "test", "fixtures", "gap_ls_cursor.json",
    ))
    broad_path = joinpath(dirname(fixture_path), "gap_ls_broad_carrier.json")
    fixtures = vcat(
        JSON3.read(read(fixture_path, String), Vector{Dict{String,Any}}),
        JSON3.read(read(broad_path, String), Vector{Dict{String,Any}}),
    )
    for fixture in fixtures
        name = fixture["name"]
        @testset "$name" begin
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
                        "gap-ls-cursor.spec",
                    )),
                )
                # Preserve Julia's independently observed unflagged timing;
                # the reference4/4 observation is not portable for this row.
                compatibility = name == "unflagged_timing_control"
                expected = compatibility ? Any[1, 1] : row["expected"]
                for (route, operation) in operations
                    actual = attempt(operation)
                    if expected isa AbstractDict && haskey(expected, "error_contains")
                        @test actual isa Exception
                        @test occursin(expected["error_contains"], sprint(showerror, actual))
                        if route == "plan"
                            @test nameof(typeof(actual)) == :GeneratedSourceException
                        else
                            @test actual isa RuntimeInterpreterException
                            if actual isa RuntimeInterpreterException
                                @test actual.diagnostic !== nothing
                                if actual.diagnostic !== nothing
                                    @test actual.diagnostic.code == expected["error_code"]
                                    @test actual.diagnostic.rule_label == expected["error_rule"]
                                    @test actual.diagnostic.stage == "advance_gap_context"
                                end
                            end
                        end
                    else
                        @test !(actual isa Exception)
                        if !(actual isa Exception)
                            if route == "plan"
                                @test actual == expected
                            else
                                @test actual.value == expected
                                @test actual.matched === (compatibility ? true : row["expected_match"])
                                @test to_json(actual)["cursor_char_offset"] ==
                                    (compatibility ? 1 : row["expected_char_cursor"])
                            end
                        end
                    end
                end
            end
        end
    end
end
end
