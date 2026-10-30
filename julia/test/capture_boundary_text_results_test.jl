module JuliaCaptureBoundaryTextResults
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
    error("unexpected capture String fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:CaptureTextGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "capture-boundary-text.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "capture-boundary-text.spec",
        ),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        result[route] = try
            Dict("ok" => operation())
        catch failure
            Dict("error"=>sprint(showerror, failure), "class"=>string(nameof(typeof(failure))))
        end
    end
    return result
end

function check(source, input, expected)
    actual = observe(source, input)
    println("CAPTURE_TEXT ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("CAPTURE_TEXT_FENCE ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        row = actual[route]
        expected_class = route in ("native", "restored") ?
            "RuntimeInterpreterException" : "GeneratedSourceException"
        @test get(row, "class", "") == expected_class &&
            all(occursin(part, get(row, "error", "")) for part in
                ("parser-state helper", "'$helper'", "not supported in user functions"))
    end
end

action(body, tail="cat") = """Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /$tail/
 -> Value[2] {$body}
"""

@testset "Julia readonly capture String results" begin
    @testset "Frozen shared target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root, "tests", "fixtures", "capture_boundary_text_values.spec"), String)
        expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "capture_boundary_text_values.json"), String), Any)
        check(source, "αβ:cat", expected)
    end
    @testset "Native readers aliases and String zero selection" begin
        check(action(raw"""return([capture_slice().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!"),capture_rest().coalesce("bad").cat("!"),capture_from_rule_start().coalesce("bad").cat("!"),[capture_slice(),capture_slice_until_cursor(),capture_rest(),capture_from_rule_start()]])"""),
            "αβ:cat", Any[Any[":!",":cat!",":cat!",":!",Any[":",":cat",":cat",":"]]])
        check(action(raw"""tail=capture_rest();return([tail.split(":")[-1].uppercase(),capture_rest().coalesce("bad").split(":")[-1].coalesce("bad")])""", "0"),
            "αβ:0", Any[Any["0","0"]])
    end
    @testset "Initial missing empty and reversed source spans" begin
        check(raw"""Top:: I {return([capture_slice().coalesce("missing").cat("!"),capture_from_rule_start().coalesce("alias").uppercase(),capture_rest().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!")])}""",
            "x", Any["missing!","ALIAS","x!","!"])
        check(action(raw"""start_capture_slice();return([capture_slice().coalesce("reversed").cat("!"),capture_slice_pos()])"""),
            "αβ:cat", Any[Any["reversed!",6]])
    end
    @testset "Existing direct first consumer and with result" begin
        check(action(raw"""order="";a=capture_rest().take({order=cat(order,"T");1});b=capture_rest().with() {return(["ok"])}.first().uppercase();return([a,b,order]);"""),
            "αβ:cat", Any[Any[Any[],"OK","T"]])
    end
    @testset "All four sources preserve specific pure function errors" begin
        for helper in ("capture_slice","capture_slice_until_cursor","capture_rest","capture_from_rule_start")
            function_fence("fn forbidden(){return($helper().coalesce(\"M\").cat(\"!\"))} Top:: I {return(forbidden())}", helper)
        end
    end
    @testset "Caller callback and pure function invocation contexts" begin
        check(raw"""Top:: I {cb={||return(capture_rest().coalesce("bad").cat("!"))};return(cb())}""", "x", "x!")
        function_fence(raw"""fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_rest().coalesce("bad").cat("!"))})}""", "capture_rest")
    end
end
end
