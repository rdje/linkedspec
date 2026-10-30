module JuliaCaptureAdvanceNumberResults
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
    error("unexpected advancing capture String fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:CaptureAdvanceNumberGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "capture-advance-number.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "capture-advance-number.spec",
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
    println("CAPTURE_ADVANCE_NUMBER ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("CAPTURE_ADVANCE_NUMBER_FENCE ", JSON3.write(actual))
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

@testset "Julia advancing capture Number results" begin
    @testset "Frozen shared advancing Number target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root,"tests","fixtures","capture_advance_number_values.spec"),String)
        expected = JSON3.read(read(joinpath(root,"tests","fixtures","capture_advance_number_values.json"),String),Any)
        check(source,"αβ:catTAIL",expected)
    end
    @testset "Bound widths retain separate origin endpoints" begin
        for (helper,width,origin) in (("capture_take_len",1,6),("capture_take_until_cursor_len",4,6),("capture_take_rest_len",8,10))
            check(action("part=$helper();return([part.coalesce(99).add(1).cat(\"!\"),capture_slice_pos(),cursor_pos()])"),
                "αβ:catTAIL",Any[Any[string(width+1)*"!",origin,6]])
        end
    end
    @testset "Missing zero reversed and snapshots retain effect order" begin
        check(raw"""Top:: I {return([capture_take_len().coalesce(99).cat("!"),capture_slice_pos(),cursor_pos()])}""",
            "x",Any["99!",0,0])
        check(action(raw"""first=capture_take_until_cursor_len();order="";zero=capture_take_until_cursor_len().coalesce({order=cat(order,"F");99}).add(1);missing=capture_take_len().coalesce(99).cat("!");return([first,zero,missing,capture_slice_pos(),cursor_pos(),order])"""),
            "αβ:catTAIL",Any[Any[4,1,"99!",6,6,""]])
        check(action(raw"""width=capture_take_rest_len().coalesce(0);snapshot=width.cat({start_capture_slice();"!"});return([width,snapshot,capture_slice_pos(),cursor_pos()])"""),
            "αβ:catTAIL",Any[Any[8,"8!",6,6]])
    end
    @testset "Named width source retains separate mark effects" begin
        check(action(raw"""mark_capture_slice(begin);out=capture_take_len_from(begin).coalesce(99).add(1).cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])"""),
            "αβ:catTAIL",Any[Any["2!",6,2,6]])
    end
    @testset "All Number sources retain specific function state errors" begin
        for helper in ("capture_take_len","capture_take_until_cursor_len","capture_take_rest_len")
            function_fence("fn forbidden(){return($helper().coalesce(99).add(1))} Top:: I {return(forbidden())}",helper)
        end
    end
    @testset "Callbacks retain caller origin update and function invocation fence" begin
        check(raw"""Top:: I {cb={||return(capture_take_rest_len().coalesce(99).add(1))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}""",
            "abc",Any[4,3,0])
        function_fence(raw"""fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest_len().coalesce(99).add(1))})}""","capture_take_rest_len")
    end
end
end
