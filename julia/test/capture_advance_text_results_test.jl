module JuliaCaptureAdvanceTextResults
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
    host = Module(gensym(:CaptureAdvanceTextGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "capture-advance-text.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "capture-advance-text.spec",
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
    println("CAPTURE_ADVANCE_TEXT ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("CAPTURE_ADVANCE_TEXT_FENCE ", JSON3.write(actual))
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

@testset "Julia advancing capture String results" begin
    @testset "Frozen shared advancing target" begin
        root = dirname(dirname(@__DIR__))
        source = read(joinpath(root, "tests", "fixtures", "capture_advance_text_values.spec"), String)
        expected = JSON3.read(read(joinpath(root, "tests", "fixtures", "capture_advance_text_values.json"), String), Any)
        check(source, "αβ:catTAIL", expected)
    end
    @testset "Native bound sources retain distinct capture origin endpoints" begin
        for (helper, text, origin) in (("capture_take",":",6),("capture_take_until_cursor",":cat",6),("capture_take_rest",":catTAIL",10))
            check(action("part=$helper();return([part.coalesce(\"M\").cat(\"!\"),capture_slice_pos(),cursor_pos()])"),
                "αβ:catTAIL", Any[Any[text*"!",origin,6]])
        end
    end
    @testset "Missing empty String zero and Number links keep effects" begin
        check(raw"""Top:: I {return([capture_take().coalesce("M").cat("!"),capture_slice_pos(),cursor_pos()])}""",
            "x", Any["M!",0,0])
        check(action(raw"""first=capture_take_until_cursor();order="";empty=capture_take_until_cursor().coalesce({order=cat(order,"F");"fallback"}).cat("!");missing=capture_take().coalesce("M").cat("!");return([first,empty,missing,capture_slice_pos(),cursor_pos(),order])"""),
            "αβ:catTAIL", Any[Any[":cat","!","M!",6,6,""]])
        check(action(raw"""return([capture_take_until_cursor().coalesce("M").split(":")[-1].coalesce("bad"),capture_slice_pos(),cursor_pos()])""", "0"),
            "αβ:0TAIL", Any[Any["0",4,4]])
        check(action(raw"""return([capture_take_rest().coalesce("M").length().add(1),capture_slice_pos(),cursor_pos()])"""),
            "αβ:catTAIL", Any[Any[9,10,6]])
    end
    @testset "Named overload retains its separate mark effect" begin
        check(action(raw"""mark_capture_slice(begin);out=capture_take(begin).coalesce("M").cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])"""),
            "αβ:catTAIL", Any[Any[":!",6,2,6]])
    end
    @testset "All three sources retain specific function state errors" begin
        for helper in ("capture_take","capture_take_until_cursor","capture_take_rest")
            function_fence("fn forbidden(){return($helper().coalesce(\"M\").cat(\"!\"))} Top:: I {return(forbidden())}", helper)
        end
    end
    @testset "Callbacks retain caller effects and pure invocation fence" begin
        check(raw"""Top:: I {cb={||return(capture_take_rest().coalesce("M").cat("!"))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}""",
            "abc", Any["abc!",3,0])
        function_fence(raw"""fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest().coalesce("M").cat("!"))})}""", "capture_take_rest")
    end
end
end
