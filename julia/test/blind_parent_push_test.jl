# TYPE-REFERENCE-BOOK.1.2.23.3.48.4.1 — blind fluent push calls its parent.
module JuliaBlindParentPush
using LinkedSpecJulia, JSON3, Test

function strict_equal(actual, expected)
    expected === nothing && return actual === nothing
    expected isa Bool && return actual === expected
    expected isa Number && return actual isa Number && !(actual isa Bool) && actual == expected
    if expected isa AbstractVector
        return actual isa AbstractVector && length(actual) == length(expected) &&
            all(strict_equal(a, e) for (a, e) in zip(actual, expected))
    end
    return actual == expected
end

@testset "Julia blind enclosing-parent push" begin
    root = dirname(dirname(@__DIR__))
    for name in ("blind_parent_push", "blind_parent_push_repeated")
        fixtures = JSON3.read(read(joinpath(root, "tests/fixtures", name * ".json"), String),
            Vector{Dict{String,Any}})
        for fixture in fixtures
            @testset "$name / $(fixture["name"])" begin
                parsed = parse_spec_with_staged_user_function_definitions(fixture["source"])
                compiled = compile_spec(parsed)
                restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
                for state in (compiled, compile_spec(restored))
                    result = try
                        runtime_parse(LinkedSpecRuntimeEngine(state), fixture["input"])
                    catch failure
                        failure
                    end
                    @test !(result isa Exception)
                    result isa Exception && continue
                    @test strict_equal(result.value, fixture["expected"])
                    @test result.cursor_char_offset == length(fixture["input"])
                end
                result = try
                    execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
                        fixture["input"], "blind-parent-push.spec")
                catch failure
                    failure
                end
                @test !(result isa Exception)
                result isa Exception && continue
                @test strict_equal(result, fixture["expected"])
            end
        end
    end
end
end
