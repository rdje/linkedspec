module JuliaLengthGuardComposition
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
    error("unexpected Length fixture kind $(typeof(expected))")
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

function observe_case(row)
    identifier = row["id"]
    parsed = parse_spec_with_staged_user_function_definitions(row["source"])
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    emitted = emit_julia_source_v2(compiled, "length-source/$identifier.spec")
    capture = get(ENV, "LINKEDSPEC_LENGTH_CAPTURE", "")
    if !isempty(capture)
        mkpath(joinpath(capture, "emitted"))
        mkpath(joinpath(capture, "parsed"))
        write(joinpath(capture, "emitted", "$identifier.jl"), emitted)
        write(joinpath(capture, "parsed", "$identifier.json"), JSON3.write(to_json(parsed)))
    end
    fresh = () -> begin
        host = Module(gensym(:LengthGuardGenerated))
        Base.include_string(host, emitted)
        parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
        Base.invokelatest(Base.invokelatest(getfield, parser, :execute), row["input"])
    end
    Dict(
        "native" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), row["input"]).value),
        "restored" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), row["input"]).value),
        "plan" => observe(() -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), row["input"], "length-source-assessment.spec")),
        "fresh" => observe(fresh),
    )
end

@testset "Julia Length source and continuation guards" begin
    fixture_root = joinpath(dirname(dirname(@__DIR__)), "tests", "fixtures")
    domain = JSON3.read(read(joinpath(fixture_root, "length_result_guard_julia_domain.json"), String), Any)
    errors = JSON3.read(read(joinpath(fixture_root, "length_result_guard_julia_errors.json"), String), Any)
    cases = Any[]
    for name in ("length_result_guard_cases.json", "length_count_source_ownership_cases.json")
        append!(cases, JSON3.read(read(joinpath(fixture_root, name), String), Any))
    end
    for row in cases
        actual = observe_case(row)
        println("LENGTH_GUARD_JULIA ", row["id"], " ", JSON3.write(actual))
        @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
        if haskey(row, "expected_error")
            for value in values(actual)
                @test occursin(row["expected_error"], get(value, "error", ""))
            end
            @test strict_equal(actual, errors[row["id"]])
        else
            expected = haskey(row, "expected") ? row["expected"] : domain["expected"]
            for value in values(actual)
                @test haskey(value, "value") && strict_equal(value["value"], expected)
            end
        end
    end
end
end # module
