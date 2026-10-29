# TYPE-REFERENCE-BOOK.1.2.23.3.48.4 — blind declarations versus action slots.
module JuliaReferencedBlindTargets
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

@testset "Julia blind compiler strict bypass controls" begin
    for source in (
        "Top::AND\n -> Child\n => Child\nChild:\n I{return(\"C\")}\n",
        "Top::AND\n /x/ -> Child\n => Child\nChild:\n I{return(\"C\")}\n",
        "Top::AND\n => Missing\n",
    )
        @test_throws CompiledSpecException compile_spec(parse_spec(source); validate_source = false)
    end
    source = "Top::AND\n => Child {return(retv)}\nChild:|\n // -> Child[0] {return(\"E\")}\n"
    compiled = compile_spec(parse_spec(source))
    @test compiled.rules_by_label["Child"].regex_patterns == [""]
    @test compiled.dependency_regex_state.dependency_regex_map["Top"].patterns == [""]
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "x").value == "E"
end

@testset "Julia referenced and pure-code blind target compilation" begin
    root = dirname(dirname(@__DIR__))
    for file in ("referenced_blind_intermediate.json",
                 "referenced_blind_intermediate_qualified.json",
                 "pure_blind_targets.json",
                 "referenced_blind_intermediate_negatives.json")
        fixtures = JSON3.read(read(joinpath(root, "tests/fixtures", file), String),
            Vector{Dict{String,Any}})
        for fixture in fixtures
            @testset "$file / $(fixture["name"])" begin
                parsed = parse_spec_with_staged_user_function_definitions(fixture["source"])
                if !fixture["expected_builds"]
                    @test_throws SpecValidationException compile_spec(parsed)
                    continue
                end
                compiled = try
                    compile_spec(parsed)
                catch failure
                    failure
                end
                @test !(compiled isa Exception)
                compiled isa Exception && continue
                restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
                @test to_json(compile_spec(restored)) == to_json(compiled)
                @test !isempty(build_generated_rule_plan(compiled))
                if file == "pure_blind_targets.json"
                    child = compiled.rules_by_label["Child"]
                    @test isempty(child.regex_patterns)
                    @test isempty(child.regex_slots)
                    entry = get(compiled.dependency_regex_state.dependency_regex_map, "Top", nothing)
                    refs = get(fixture, "expected_regex_refs", Any[])
                    if isempty(refs)
                        @test entry === nothing
                    else
                        @test [ref.label for ref in entry.dependency_refs] == refs
                        @test entry.patterns == ["x"]
                    end
                    if fixture["name"] != "direct_control"
                        @test [ref.label for ref in compiled.rules_by_label["Top"].dependency_refs] ==
                            get(fixture, "expected_call_refs", ["Child"])
                    end
                end
                cases = file == "pure_blind_targets.json" ? [fixture] :
                    get(fixture, "cases", Any[])
                # Original sources retain compiler coverage. Original parent LX
                # is unqualified (48.2.2.1); qualified push is owned by 48.4.1.
                if file == "referenced_blind_intermediate.json" ||
                        fixture["name"] in ("blind_no_regex", "marked_blind_target", "markerless_blind")
                    continue
                end
                for case in cases
                    for state in (compiled, compile_spec(restored))
                        result = runtime_parse(LinkedSpecRuntimeEngine(state), case["input"])
                        @test strict_equal(result.value, case["expected"])
                        @test result.matched
                        @test result.cursor_char_offset == case["expected_cursor"]
                    end
                    @test strict_equal(execute_generated_parser_v2(compiled,
                        build_generated_rule_plan(compiled), case["input"],
                        "referenced-blind.spec"), case["expected"])
                end
            end
        end
    end
end

end
