# TYPE-REFERENCE-BOOK.1.2.23.3.49.4 — unavailable named capture endpoints.
module JuliaNamedWriterEndpointAbsence
using LinkedSpecJulia, JSON3, Test

function strict_equal(actual, expected)
    if expected isa Bool
        return actual === expected
    elseif expected isa Number
        return actual isa Number && !(actual isa Bool) && actual == expected
    elseif expected === nothing
        return actual === nothing
    elseif expected isa AbstractString
        return actual isa AbstractString && actual == expected
    elseif expected isa AbstractVector
        return actual isa AbstractVector && length(actual) == length(expected) &&
            all(strict_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected endpoint fixture kind $(typeof(expected))")
end

@testset "Julia local-match writer endpoint presence" begin
    root = dirname(dirname(@__DIR__))
    fixtures = JSON3.read(
        read(joinpath(root, "tests", "fixtures", "named_writer_endpoint_absence.json"), String),
        Vector{Dict{String,Any}},
    )
    for fixture in fixtures
        name = fixture["name"]
        @testset "$name" begin
            parsed = parse_spec_with_staged_user_function_definitions(fixture["source"])
            restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
            compiled = compile_spec(parsed)
            input = fixture["input"]
            for spec in (compiled, compile_spec(restored))
                result = runtime_parse(LinkedSpecRuntimeEngine(spec), input)
                @test result.matched
                @test strict_equal(result.value, fixture["expected"])
                @test result.cursor_char_offset == fixture["expected_cursor"]
            end
            @test strict_equal(
                execute_generated_parser_v2(
                    compiled, build_generated_rule_plan(compiled), input,
                    "named-writer-endpoint-absence.spec",
                ),
                fixture["expected"],
            )
        end
    end
end
end
