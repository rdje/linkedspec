module JuliaCaptureBoundaryNumberResults
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
    error("unexpected capture Number fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:CaptureNumberGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "capture-boundary-number.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "capture-boundary-number.spec",
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
    println("CAPTURE_NUMBER ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("CAPTURE_NUMBER_FENCE ", JSON3.write(actual))
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

action(body) = """Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {$body}
"""

@testset "Julia readonly capture Number results" begin
    @testset "Frozen shared target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root, "tests", "fixtures", "capture_boundary_number_values.spec"), String)
        expected = JSON3.read(read(joinpath(
            root, "tests", "fixtures", "capture_boundary_number_values.json",
        ), String), Any)
        check(source, "αβ:cat", expected)
    end
    @testset "Original six getters, three aliases and later reset snapshot" begin
        check(action(raw"""order="";
original=[capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len(),capture_slice_length(),capture_len_from_rule_start(),capture_rest_length()];
width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();
return([original,snapshot,capture_slice_pos(),order]);"""), "αβ:cat", Any[
            Any[Any[1,2,1,3,4,4,1,1,4], "4!", 6, "S"],
        ])
    end
    @testset "Defined position zero skips lazy fallback" begin
        # Missing current-match endpoints are separately owned by40. This case
        # uses the defined entry boundary and live cursor, not that width policy.
        check(raw"""Top:: I {
order="";
primitive=[capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len()];
zero=capture_slice_pos().coalesce({order=cat(order,"F");7}).add(1);
return([primitive,zero,order]);
}""", "x", Any[Any[0,1,1,0,1], 1, ""])
    end
    @testset "Actual legacy direct first consumers" begin
        check(action(raw"""order="";
a=capture_rest_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
b=capture_rest_len().take({order=cat(order,"T");1});
return([a,b,order]);"""), "αβ:cat", Any[Any[4, Any[], "KVT"]])
    end
    @testset "Specific function fences for every source and alias" begin
        for helper in (
            "capture_slice_len", "capture_slice_pos", "capture_slice_line", "capture_slice_col",
            "capture_slice_until_cursor_len", "capture_rest_len", "capture_slice_length",
            "capture_len_from_rule_start", "capture_rest_length",
        )
            function_fence(
                "fn forbidden(){return($helper().coalesce(0).cat(\"!\").split(\"!\")[0].uppercase())}\nTop:: I {return(forbidden())}",
                helper,
            )
        end
    end
    @testset "Callback parser context and pure invocation context" begin
        check(raw"""Top:: I {cb={||return(capture_rest_len().coalesce(0).cat("!"))};return(cb())}""", "x", "1!")
        function_fence(raw"""fn apply(callback: codeblock){return(callback())}
Top:: I {return(apply(){return(capture_rest_len().coalesce(0).cat("!"))})}""", "capture_rest_len")
    end
end
end
