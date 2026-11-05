module JuliaCountCopyAssessment
using LinkedSpecJulia, JSON3
const OUTPUT_ROOT = @__DIR__
@assert !isdir(joinpath(OUTPUT_ROOT, "julia-emitted")) "refusing historical overwrite"
mkdir(joinpath(OUTPUT_ROOT, "julia-emitted"))
function observe(label, source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    emitted = emit_julia_source_v2(compiled, "count-copy-source-assessment.spec")
    capture = true
    write(joinpath(@__DIR__, "julia-emitted", label * ".jl"), emitted)
    if capture
        println("COUNT_COPY_JULIA_INPUT ", label, " ", JSON3.write(Dict(
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
            compiled, build_generated_rule_plan(compiled), input, "count-copy-source-assessment.spec",
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
        println("COUNT_COPY_JULIA_TRACE ", label, " ", JSON3.write(String(take!(trace_buffer))))
    end
    return result
end


for row in JSON3.read(read(joinpath(OUTPUT_ROOT,"cases.json"),String),Any)
    actual = try
        observe(row["id"],row["source"],row["input"])
    catch failure
        Dict("preparation_error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
    end
    println("COUNT_COPY_JULIA ",row["id"]," ",JSON3.write(actual))
end
end
