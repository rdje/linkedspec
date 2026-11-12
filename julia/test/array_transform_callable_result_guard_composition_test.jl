module JuliaCallableTransformComposition
using LinkedSpecJulia, JSON3, Test
include(joinpath(@__DIR__, "callable_array_transform_observation.jl"))
using .JuliaCallableTransformObservation

function observe_case(row, grammar, capture)
    identifier = row["id"]
    parsed = parse_spec_with_staged_user_function_definitions(row["source"]; parser_spec_source=grammar)
    serialized = JSON3.write(to_json(parsed))
    if !isempty(capture)
        path = joinpath(capture, "parsed", "$identifier.json")
        write(path, serialized)
        retained = read(path, String)
        retained == serialized || error("normal parsed input readback drift")
        serialized = retained
    end
    restored = from_json(SpecFile, JSON3.read(serialized))
    compiled = compile_spec(parsed)
    identity = "callable-array-transform/$identifier.spec"
    emitted = emit_julia_source_v2(compiled, identity)
    if !isempty(capture)
        path = joinpath(capture, "emitted", "$identifier.jl")
        write(path, emitted)
        retained = read(path, String)
        retained == emitted || error("normal emitted input readback drift")
        emitted = retained
    end
    fresh = () -> begin
        host = Module(gensym(:CallableTransformGenerated))
        Base.include_string(host, emitted)
        parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
        Base.invokelatest(Base.invokelatest(getfield, parser, :execute), row["input"])
    end
    Dict(
        "native" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), row["input"]).value),
        "restored" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), row["input"]).value),
        "plan" => observe(() -> execute_generated_parser_v2(compiled,
            build_generated_rule_plan(compiled), row["input"], identity)),
        "fresh" => observe(fresh),
    )
end

root = normpath(joinpath(@__DIR__, "..", ".."))
cases = JSON3.read(read(joinpath(root, "tests", "fixtures", "array_transform_callable_result_guard_julia_cases.json"), String), Any)
profiles = JSON3.read(read(joinpath(root, "tests", "fixtures", "array_transform_callable_result_guard_julia_profiles.json"), String), Any)
expected = Dict(row["id"] => row["expected"] for row in profiles)
@assert length(cases) == length(expected) == length(profiles)
grammar_path = "specs/user_function_definition.spec"
grammar = read(joinpath(root, grammar_path), String)
println("CALLABLE_TRANSFORM_JULIA_NORMAL_GRAMMAR ", JSON3.write(Dict("path" => grammar_path, "source" => grammar)))
capture = get(ENV, "LINKEDSPEC_CALLABLE_TRANSFORM_JULIA_CAPTURE", "")
if !isempty(capture)
    (isabspath(capture) || !startswith(capture, "docs/checkpoints/array-transform-callable-julia-2026-11-12/") ||
        any(part -> part in ("", ".", ".."), split(capture, '/'; keepempty=true)) ||
        islink(capture)) && error("unsafe callable transform capture path")
    mkpath(joinpath(capture, "parsed"))
    mkpath(joinpath(capture, "emitted"))
end
@testset "Julia callable Array-transform result guards" begin
    for row in cases
        identifier = row["id"]
        actual = observe_case(row, grammar, capture)
        println("CALLABLE_TRANSFORM_JULIA_NORMAL ", identifier, " ", JSON3.write(actual))
        @testset "$identifier" begin
            for route in ("native", "restored", "plan", "fresh")
                @test strict_equal(actual[route], expected[identifier][route])
            end
        end
    end
end
end # module
