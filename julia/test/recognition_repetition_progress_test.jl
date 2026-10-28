# TYPE-REFERENCE-BOOK.1.2.23.3.39.3.6 — actual recognition progress.
module JuliaRecognitionRepetitionProgress
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
        actual = Dict{String,Any}(
            "error" => sprint(showerror, failure),
            "class" => string(nameof(typeof(failure))),
        )
        if failure isa RuntimeInterpreterException
            actual["diagnostic"] = failure.diagnostic === nothing ? nothing :
                to_json(failure.diagnostic)
        end
        return actual
    end
end

@testset "Julia live recognition repetition progress" begin
    fixtures = JSON3.read(
        read(joinpath(@__DIR__, "recognition_repetition_progress_cases.json"), String),
        Vector{Dict{String,Any}},
    )
    for fixture in fixtures
        name = fixture["name"]
        @testset "$name" begin
            source = fixture["source"]
            println("JULIA_LIVE_PROGRESS_AUTHORED ", name, " ", JSON3.write(fixture))
            parsed = parse_spec_with_staged_user_function_definitions(source)
            normalized = JSON3.write(to_json(parsed))
            restored = from_json(SpecFile, JSON3.read(normalized))
            compiled = compile_spec(parsed)
            plan = build_generated_rule_plan(compiled)
            emitted = emit_julia_source_v2(compiled, "julia-live-progress.spec")
            println("JULIA_LIVE_PROGRESS_INPUT ", name, " ", JSON3.write(Dict(
                "source" => source, "normalized" => normalized,
                "compiled" => to_json(compiled),
                "plan" => [Dict("label" => row.label, "family" => row.family) for row in plan],
                "emitted" => emitted,
            )))
            destination = get(ENV, "LINKEDSPEC_JULIA_LIVE_PROGRESS_EMIT_DIR", "")
            if !isempty(destination)
                (isabspath(destination) || ".." in splitpath(destination)) &&
                    error("intake module directory must be repository-relative")
                mkpath(destination)
                write(joinpath(destination, name * ".jl"), emitted)
            end
            observations = Any[]
            for row in fixture["cases"]
                input = row["input"]
                expected = row["expected"]
                trace = LinkedSpecTraceEmitter(
                    trace_config_enabled(LinkedSpecTraceLow); stdout_io = IOBuffer(),
                )
                native = observe(() -> runtime_parse(
                    LinkedSpecRuntimeEngine(compiled), input; trace = trace,
                ))
                native["progress_trace"] = [
                    event.details for event in trace_events(trace)
                    if event.topic == "julia_runtime:recognition_repetition_progress_failure"
                ]
                routes = Dict(
                    "native" => native,
                    "restored" => observe(() -> runtime_parse(
                        LinkedSpecRuntimeEngine(compile_spec(restored)), input,
                    )),
                    "plan" => observe(() -> execute_generated_parser_v2(
                        compiled, plan, input, "julia-live-progress.spec",
                    )),
                )
                observation = Dict("input" => input, "expected" => expected, "routes" => routes)
                println("JULIA_LIVE_PROGRESS_ACTUAL ", name, " ", JSON3.write(observation))
                push!(observations, observation)
            end
            for row in observations, (route, actual) in row["routes"]
                expected = row["expected"]
                if expected isa AbstractDict && haskey(expected, "error_record")
                    record = expected["error_record"]
                    @test occursin(record["code"], get(actual, "error", ""))
                    if route != "plan"
                        diagnostic = get(actual, "diagnostic", nothing)
                        @test diagnostic !== nothing
                        if diagnostic !== nothing
                            @test diagnostic["code"] == record["code"]
                            @test diagnostic["rule_label"] == record["rule"]
                            @test diagnostic["stage"] == "runtime_execution"
                        end
                    end
                    if route == "native"
                        @test actual["progress_trace"] == [
                            "code=$(record["code"]) rule=$(record["rule"]) " *
                            "origin=$(record["origin"]) start_offset=$(record["start_offset"]) " *
                            "end_offset=$(record["end_offset"])",
                        ]
                    end
                else
                    @test !haskey(actual, "error")
                    if !haskey(actual, "error")
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
