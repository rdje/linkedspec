module JuliaCallableTransformTrace
using LinkedSpecJulia, JSON3
include(joinpath(@__DIR__, "..", "..", "..", "julia", "test", "callable_array_transform_observation.jl"))
using .JuliaCallableTransformObservation

length(ARGS) == 2 || error("source questions and owned trace output required")
output = ARGS[2]
(isabspath(output) || !startswith(output, "docs/checkpoints/array-transform-callable-julia-2026-11-12/") ||
    any(part -> part in ("", ".", ".."), split(output, '/'; keepempty=true)) ||
    !isdir(output) || islink(output)) && error("unsafe trace output")
grammar = read("specs/user_function_definition.spec", String)
println("CALLABLE_TRANSFORM_JULIA_TRACE_GRAMMAR ", JSON3.write(grammar))
println("CALLABLE_TRANSFORM_JULIA_TRACE_OWNER ", relpath(pathof(LinkedSpecJulia), pwd()))
for row in JSON3.read(read(ARGS[1], String), Any)
    identifier = row["id"]
    occursin(r"^[a-z][a-z0-9_]*$", identifier) || error("unsafe trace id")
    config = with_trace_reset_file(with_trace_file(
        trace_config_enabled(LinkedSpecTraceDebug), joinpath(output, "$identifier.trace.log")))
    trace = LinkedSpecTraceEmitter(config)
    parsed = parse_spec_with_staged_user_function_definitions(row["source"]; parser_spec_source=grammar, trace=trace)
    path = joinpath(output, "$identifier.parsed.json")
    serialized = JSON3.write(to_json(parsed))
    write(path, serialized)
    read(path, String) == serialized || error("trace parsed input drift")
    compiled = compile_spec(parsed; trace=trace)
    actual = observe(() -> runtime_execute(LinkedSpecRuntimeEngine(compiled), row["input"]; trace=trace).value)
    println("CALLABLE_TRANSFORM_JULIA_TRACE ", identifier, " ", JSON3.write(actual))
end
end # module
