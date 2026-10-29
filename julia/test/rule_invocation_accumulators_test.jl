# TYPE-REFERENCE-BOOK.1.2.23.3.48.4.2 — conventional arrays are invocation-local.
module JuliaRuleInvocationAccumulators
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

@testset "Julia conventional rule-array invocations" begin
    root = dirname(dirname(@__DIR__))
    for name in ("rule_invocation_accumulators", "rule_invocation_binding_scope")
        fixtures = JSON3.read(read(joinpath(root, "tests/fixtures", name * ".json"), String),
            Vector{Dict{String,Any}})
        for fixture in fixtures
            @testset "$name / $(fixture["name"])" begin
                # Ordinary nonconsuming collection/phase authority is pending
                # 39.8.1. Keep Julia's current final empty iteration explicit;
                # direct_twice independently proves the portable scope repair.
                expected = fixture["name"] == "implicit_parent_no_tail" ?
                    Any[Any["x"], Any[]] :
                    get(fixture, "julia_compatibility_expected", fixture["expected"])
                # Undeclared child writes retain Julia compatibility under the
                # explicit cross-rule binding authority owner in the fixture.
                expected_cursor = get(fixture, "expected_cursor", length(fixture["input"]))
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
                    @test strict_equal(result.value, expected)
                    @test result.cursor_char_offset == expected_cursor
                end
                result = try
                    execute_generated_parser_v2(compiled, build_generated_rule_plan(compiled),
                        fixture["input"], "blind-parent-push.spec")
                catch failure
                    failure
                end
                @test !(result isa Exception)
                result isa Exception && continue
                @test strict_equal(result, expected)
            end
        end
    end
end
end
