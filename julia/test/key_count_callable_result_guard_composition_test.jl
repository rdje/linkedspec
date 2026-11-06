module JuliaKeyCountCallableComposition
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
    error("unexpected CountKeys fixture kind $(typeof(expected))")
end

function observe(operation)
    try
        Dict{String,Any}("value" => operation())
    catch failure
        row = Dict{String,Any}(
            "error" => sprint(showerror, failure),
            "class" => string(nameof(typeof(failure))),
        )
        if failure isa RuntimeInterpreterException && failure.diagnostic !== nothing
            diagnostic = failure.diagnostic
            row["diagnostic"] = Dict(
                "code" => diagnostic.code, "stage" => diagnostic.stage,
                "helper_name" => diagnostic.helper_name,
                "actual_arity" => diagnostic.actual_arity,
                "expected_arity" => diagnostic.expected_arity,
            )
        end
        row
    end
end

function observe_case(row, grammar)
    identifier = row["id"]
    parsed = parse_spec_with_staged_user_function_definitions(row["source"]; parser_spec_source = grammar)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    emitted = emit_julia_source_v2(compiled, "key-count-callable/$identifier.spec")
    capture = get(ENV, "LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE", "")
    if !isempty(capture)
        mkpath(joinpath(capture, "emitted"))
        mkpath(joinpath(capture, "parsed"))
        write(joinpath(capture, "emitted", "$identifier.jl"), emitted)
        write(joinpath(capture, "parsed", "$identifier.json"), JSON3.write(to_json(parsed)))
    end
    fresh = () -> begin
        host = Module(gensym(:KeyCountGuardGenerated))
        Base.include_string(host, emitted)
        parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
        Base.invokelatest(Base.invokelatest(getfield, parser, :execute), row["input"])
    end
    Dict(
        "native" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), row["input"]).value),
        "restored" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), row["input"]).value),
        "plan" => observe(() -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), row["input"], "key-count-callable-assessment.spec")),
        "fresh" => observe(fresh),
    )
end

@testset "Julia callable CountKeys preservation" begin
    fixture_root = joinpath(dirname(dirname(@__DIR__)), "tests", "fixtures")
    grammar_path = joinpath(dirname(dirname(@__DIR__)), "specs", "user_function_definition.spec")
    grammar = read(grammar_path, String)
    println("CALLABLE_KEY_COUNT_JULIA_NORMAL_GRAMMAR ", JSON3.write(Dict(
        "path" => "specs/user_function_definition.spec", "source" => grammar)))
    profiles = JSON3.read(read(joinpath(fixture_root, "key_count_callable_julia_profiles.json"), String), Any)
    cases = JSON3.read(read(joinpath(fixture_root, "key_count_callable_result_cases.json"), String), Any)
    for row in cases
        actual = observe_case(row, grammar)
        println("CALLABLE_KEY_COUNT_JULIA_NORMAL ", row["id"], " ", JSON3.write(actual))
        @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
        if haskey(profiles, row["id"])
            profile = profiles[row["id"]]
            @test profile["source"] == row["source"]
            for route in keys(actual)
                @test strict_equal(actual[route], profile[route])
            end
        else
            for value in values(actual)
                @test haskey(value, "value") && strict_equal(value["value"], row["expected"])
            end
        end
    end
end
end # module
