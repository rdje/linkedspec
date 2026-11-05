module JuliaCountGuardComposition
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
    error("unexpected Count fixture kind $(typeof(expected))")
end

function observe(label, source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    emitted = emit_julia_source_v2(compiled, "count-result-guard-composition.spec")
    capture = get(ENV, "LINKEDSPEC_COUNT_GUARD_CAPTURE", "") == "1"
    if capture
        println("COUNT_GUARD_JULIA_INPUT ", label, " ", JSON3.write(Dict(
            "source" => source, "parsed" => to_json(parsed), "emitted" => emitted,
        )))
    end
    trace_buffer = IOBuffer()
    trace = capture && label == "free_guard_before_with" ? LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug); stdout_io = trace_buffer,
    ) : nothing
    result = Dict{String,Any}()
    fresh = () -> begin
        host = Module(gensym(:CountGuardGenerated))
        Base.include_string(host, emitted)
        parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
        Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input)
    end
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input; trace = trace).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "count-result-guard-composition.spec",
        ),
        "fresh" => fresh,
    )
        result[route] = try
            Dict("ok" => operation())
        catch failure
            row = Dict{String,Any}(
                "error" => sprint(showerror, failure), "class" => string(nameof(typeof(failure))),
            )
            if failure isa RuntimeInterpreterException && failure.diagnostic !== nothing
                diagnostic = failure.diagnostic
                row["diagnostic"] = Dict(
                    "code" => diagnostic.code, "stage" => diagnostic.stage,
                    "helper_name" => diagnostic.helper_name, "actual_arity" => diagnostic.actual_arity,
                    "expected_arity" => diagnostic.expected_arity,
                )
            end
            row
        end
    end
    if trace !== nothing
        println("COUNT_GUARD_JULIA_TRACE ", label, " ", JSON3.write(String(take!(trace_buffer))))
    end
    return result
end

function check(label, source, input, expected)
    actual = observe(label, source, input)
    println("COUNT_GUARD_JULIA_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia Count source and prefix guards" begin
    fixture_root = dirname(dirname(@__DIR__))
    error_fences = JSON3.read(read(joinpath(fixture_root, "tests", "fixtures", "count_result_guard_julia_errors.json"), String), Any)
    cases = Any[]
    for name in ("count_result_guard_cases.json", "count_result_guard_source_owner_cases.json")
        append!(cases, JSON3.read(read(joinpath(fixture_root, "tests", "fixtures", name), String), Any))
    end
    for row in cases
        if haskey(row, "expected_error")
            actual = observe(row["id"], row["source"], row["input"])
            println("COUNT_GUARD_JULIA_ERROR ", row["id"], " ", JSON3.write(actual))
            @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
            for value in values(actual)
                @test occursin(row["expected_error"], get(value, "error", ""))
            end
            @test strict_equal(actual, error_fences[row["id"]])
        else
            check(row["id"], row["source"], row["input"], get(row, "expected_nonperl", row["expected"]))
        end
    end
    domain = JSON3.read(read(joinpath(fixture_root, "tests", "fixtures", "count_result_guard_julia_domain.json"), String), Any)
    check("source_domain_diagnostic",
        "Value:: I {return([count(undef),count(\"text\"),count({}),{undef}.count(),\"text\".count(),{}.count(),{undef}.copy().count()])}",
        "x", domain)

    shapes = Any[]
    rows = JSON3.read(read(joinpath(fixture_root, "tests", "fixtures", "count_result_guard_excluded_ast.json"), String), Any)
    for input in rows
        source = input["source"]
        row = try
            Dict("source" => source, "ast" => to_json(parse_action_expression(source)))
        catch failure
            Dict("source" => source, "error" => sprint(showerror, failure), "class" => string(nameof(typeof(failure))))
        end
        push!(shapes, row)
    end
    println("COUNT_GUARD_JULIA_SHAPES ", JSON3.write(shapes))
    frozen = JSON3.read(read(joinpath(fixture_root, "tests", "fixtures", "count_result_guard_julia_ast.json"), String), Any)
    @test strict_equal(shapes, frozen)
end
end # module
