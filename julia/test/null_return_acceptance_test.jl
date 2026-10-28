# TYPE-REFERENCE-BOOK.1.2.23.3.39.3.7.1 — accepted-null return provenance.
module JuliaNullReturnAcceptance
using LinkedSpecJulia, JSON3, Test

function strict_equal(actual, expected)
    if expected isa Bool
        return actual === expected
    elseif expected isa Number
        return actual isa Number && !(actual isa Bool) && actual == expected
    elseif expected === nothing
        return actual === nothing
    elseif expected isa AbstractVector
        return actual isa AbstractVector && length(actual) == length(expected) &&
            all(strict_equal(a, e) for (a, e) in zip(actual, expected))
    end
    return actual == expected
end

function observe(operation)
    try
        value = operation()
        return value isa RuntimeParseResult ? Dict{String,Any}("result" => to_json(value)) :
            Dict{String,Any}("value" => value)
    catch failure
        return Dict{String,Any}(
            "error" => sprint(showerror, failure),
            "class" => string(nameof(typeof(failure))),
        )
    end
end

@testset "Julia accepted-null return contexts" begin
    fixtures = JSON3.read(
        read(joinpath(@__DIR__, "null_return_acceptance_cases.json"), String),
        Vector{Dict{String,Any}},
    )
    for fixture in fixtures
        name = fixture["name"]
        @testset "$name" begin
            source = fixture["source"]
            println("JULIA_NULL_RETURNS_AUTHORED ", name, " ", JSON3.write(fixture))
            parsed = parse_spec_with_staged_user_function_definitions(source)
            normalized = JSON3.write(to_json(parsed))
            restored = from_json(SpecFile, JSON3.read(normalized))
            compiled = compile_spec(parsed)
            plan = build_generated_rule_plan(compiled)
            emitted = emit_julia_source_v2(compiled, "julia-null-returns.spec")
            println("JULIA_NULL_RETURNS_INPUT ", name, " ", JSON3.write(Dict(
                "source" => source, "normalized" => normalized,
                "compiled" => to_json(compiled),
                "plan" => [Dict("label" => row.label, "family" => row.family) for row in plan],
                "emitted" => emitted,
            )))
            destination = get(ENV, "LINKEDSPEC_JULIA_NULL_RETURNS_EMIT_DIR", "")
            if !isempty(destination)
                (isabspath(destination) || ".." in splitpath(destination)) &&
                    error("intake module directory must be repository-relative")
                mkpath(destination)
                write(joinpath(destination, name * ".jl"), emitted)
            end
            observations = Any[]
            for row in fixture["cases"]
                input = row["input"]
                trace = LinkedSpecTraceEmitter(
                    trace_config_enabled(LinkedSpecTraceHigh); stdout_io = IOBuffer(),
                )
                native = observe(() -> runtime_parse(
                    LinkedSpecRuntimeEngine(compiled), input; trace = trace,
                ))
                routes = Dict(
                    "native" => native,
                    "restored" => observe(() -> runtime_parse(
                        LinkedSpecRuntimeEngine(compile_spec(restored)), input,
                    )),
                    "plan" => observe(() -> execute_generated_parser_v2(
                        compiled, plan, input, "julia-null-returns.spec",
                    )),
                )
                selected = [
                    event.details for event in trace_events(trace)
                    if event.topic == "julia_runtime:regex_slot_selected"
                ]
                observation = Dict(
                    "input" => input, "expected" => row["expected"],
                    "routes" => routes, "selected" => selected,
                    "expected_match" => row["expected_match"],
                    "expected_cursor" => row["expected_cursor"],
                )
                println("JULIA_NULL_RETURNS_ACTUAL ", name, " ", JSON3.write(observation))
                push!(observations, observation)
            end
            for row in observations
                expected = row["expected"]
                for (route, actual) in row["routes"]
                    if expected isa AbstractDict && haskey(expected, "error_contains")
                        @test occursin(expected["error_contains"], get(actual, "error", ""))
                    else
                        @test !haskey(actual, "error")
                        if !haskey(actual, "error")
                            if route != "plan"
                                @test actual["result"]["matched"] == row["expected_match"]
                                @test actual["result"]["cursor_code_unit"] == row["expected_cursor"]
                            end
                            @test strict_equal(
                                route == "plan" ? actual["value"] : actual["result"]["value"],
                                expected,
                            )
                        end
                    end
                end
            end
        end
    end
end
end
