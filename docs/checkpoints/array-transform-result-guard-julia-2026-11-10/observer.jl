module JuliaArrayTransformProbe
using LinkedSpecJulia, JSON3

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

function main()
    length(ARGS) == 2 || error("cases and repository-relative output paths required")
    output = ARGS[2]
    (isempty(output) || isabspath(output) ||
        any(part -> part in ("", ".", ".."), split(output, '/'; keepempty=true)) ||
        !startswith(output, "docs/checkpoints/array-transform-result-guard-julia-2026-11-10/") ||
        !isdir(output) || islink(output)) && error("output must be an existing owned repository-relative phase")
    grammar_path = "specs/user_function_definition.spec"
    grammar = read(grammar_path, String)
    println("ARRAY_TRANSFORM_JULIA_GRAMMAR ", JSON3.write(Dict("path" => grammar_path, "source" => grammar)))
    cases = JSON3.read(read(ARGS[1], String), Any)
    mkpath(joinpath(output, "emitted"))
    mkpath(joinpath(output, "parsed"))
    for row in cases
        identifier = row["id"]
        occursin(r"^[a-z][a-z0-9_]*$", identifier) || error("unsafe authored case id")
        actual = try
            source, input = row["source"], row["input"]
            parsed = parse_spec_with_staged_user_function_definitions(source; parser_spec_source = grammar)
            compiled = compile_spec(parsed)
            restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
            emitted = emit_julia_source_v2(compiled, "array-transform-result-guard/$identifier.spec")
            write(joinpath(output, "emitted", "$identifier.jl"), emitted)
            write(joinpath(output, "parsed", "$identifier.json"), JSON3.write(to_json(parsed)))
            println("ARRAY_TRANSFORM_JULIA_INPUT ", identifier, " ", JSON3.write(to_json(parsed)))
            fresh = () -> begin
                host = Module(gensym(:ArrayTransformGenerated))
                Base.include_string(host, emitted)
                parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
                Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input)
            end
            Dict(
                "native" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value),
                "restored" => observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value),
                "plan" => observe(() -> execute_generated_parser_v2(
                    compiled, build_generated_rule_plan(compiled), input, "array-transform-result-guard-assessment.spec")),
                "fresh" => observe(fresh),
            )
        catch failure
            Dict("preparation_error" => sprint(showerror, failure),
                 "class" => string(nameof(typeof(failure))))
        end
        println("ARRAY_TRANSFORM_JULIA ", identifier, " ", JSON3.write(actual))
    end
end
main()
end # module
