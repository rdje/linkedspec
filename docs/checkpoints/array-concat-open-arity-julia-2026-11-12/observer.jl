module JuliaOpenArityConcatProbe
using LinkedSpecJulia, JSON3
include(joinpath(@__DIR__, "..", "..", "..", "julia", "test", "callable_array_transform_observation.jl"))
using .JuliaCallableTransformObservation

function main()
    length(ARGS) == 2 || error("cases and owned repository-relative output paths required")
    output = ARGS[2]
    (isempty(output) || isabspath(output) ||
        any(part -> part in ("", ".", ".."), split(output, '/'; keepempty=true)) ||
        !startswith(output, "docs/checkpoints/array-concat-open-arity-julia-2026-11-12/") ||
        !isdir(output) || islink(output)) && error("output must be an existing owned relative phase")
    println("ARRAY_CONCAT_JULIA_OWNER ", relpath(pathof(LinkedSpecJulia), pwd()))
    grammar_path = "specs/user_function_definition.spec"
    grammar = read(grammar_path, String)
    println("ARRAY_CONCAT_JULIA_GRAMMAR ", JSON3.write(Dict("path" => grammar_path, "source" => grammar)))
    cases = JSON3.read(read(ARGS[1], String), Any)
    mkpath(joinpath(output, "emitted"))
    mkpath(joinpath(output, "parsed"))
    for row in cases
        identifier = row["id"]
        occursin(r"^[a-z][a-z0-9_]*$", identifier) || error("unsafe authored case id")
        actual = try
            parsed = parse_spec_with_staged_user_function_definitions(row["source"]; parser_spec_source=grammar)
            parsed_path = joinpath(output, "parsed", "$identifier.json")
            serialized = JSON3.write(to_json(parsed))
            write(parsed_path, serialized)
            retained = read(parsed_path, String)
            retained == serialized || error("parsed input readback drift")
            println("ARRAY_CONCAT_JULIA_INPUT ", identifier, " ", retained)
            restored = from_json(SpecFile, JSON3.read(retained))
            compiled = compile_spec(parsed)
            prefix = get(row, "origin", "") == "legacy312" ? "callable-array-transform" :
                get(row, "origin", "") == "ordinary4" ? "array-transform-result-guard" : "array-concat-open-arity-result-guard"
            identity = "$prefix/$identifier.spec"
            emitted = emit_julia_source_v2(compiled, identity)
            emitted_path = joinpath(output, "emitted", "$identifier.jl")
            write(emitted_path, emitted)
            retained_emitted = read(emitted_path, String)
            retained_emitted == emitted || error("emitted input readback drift")
            fresh = () -> begin
                host = Module(gensym(:CallableTransformGenerated))
                Base.include_string(host, retained_emitted)
                parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
                Base.invokelatest(Base.invokelatest(getfield, parser, :execute), row["input"])
            end
            Dict(
                "native" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), row["input"]).value),
                "restored" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), row["input"]).value),
                "plan" => observe(() -> execute_generated_parser_v2(compiled,
                    build_generated_rule_plan(compiled), row["input"],
                    get(row, "origin", "") == "ordinary4" ? "array-transform-result-guard-assessment.spec" : identity)),
                "fresh" => observe(fresh),
            )
        catch failure
            Dict("preparation_error" => sprint(showerror, failure), "class" => string(nameof(typeof(failure))))
        end
        println("ARRAY_CONCAT_JULIA ", identifier, " ", JSON3.write(actual))
    end
end
main()
end # module
