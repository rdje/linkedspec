module JuliaBoundaryCaptureFluentResults
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
    host = Module(gensym(:BoundaryCaptureFluentGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "boundary-capture-fluent.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "boundary-capture-fluent.spec",
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
    println("BOUNDARY_CAPTURE ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("BOUNDARY_CAPTURE_FENCE ", JSON3.write(actual))
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

boundary_source(body,endpattern="END") = """Top::
 I {$body}
End:OR{1,1}
 /$endpattern/
Far:OR{1,1}
 /TAIL/
"""

@testset "Julia structural boundary result methods" begin
    @testset "Frozen shared boundary target" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","boundary_capture_fluent_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","boundary_capture_fluent_values.json"),String),Any)
        check(source,"αβ:ENDTAIL",expected)
    end
    @testset "Primitive bound direct and Number keep live versus origin effects" begin
        for (body,expected) in (
            (raw"""return([capture_until_boundary(End),cursor_pos(),capture_slice_pos()])""",Any["αβ:",3,0]),
            (raw"""part=capture_until_boundary(End);return([part.coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",Any["αβ:!",3,0]),
            (raw"""return([capture_until_boundary(End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""",Any["αβ:!",3,0]),
            (raw"""return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])""",Any[4,3,0]),
        )
            check(boundary_source(body),"αβ:ENDTAIL",expected)
        end
    end
    @testset "Empty missing and EOF keep distinct native policies" begin
        check(boundary_source(raw"""first=capture_until_boundary(End);order="";empty=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");return([first,empty,cursor_pos(),capture_slice_pos(),order])"""),
            "αβ:ENDTAIL",Any["αβ:","!",3,0,""])
        check(boundary_source(raw"""return([capture_until_boundary(Missing).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"""),
            "αβ:ENDTAIL",Any["M!",0,0])
        check(boundary_source(raw"""return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])""","ZZZ"),
            "αβ:ENDTAIL",Any[11,10,0])
    end
    @testset "Quoted comma and multiple labels keep atoms and earliest boundary" begin
        quoted=boundary_source(raw"""return([capture_until_boundary("a,b,c",End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])""")*"\nb:OR{1,1}\n /αβ/\n"
        check(quoted,"αβ:ENDTAIL",Any["αβ:!",3,0])
        check(boundary_source(raw"""return([capture_until_boundary(Far,End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"""),
            "αβ:ENDTAIL",Any["αβ:!",3,0])
    end
    @testset "Boundary source keeps specific pure function state error" begin
        function_fence("fn forbidden(){return(capture_until_boundary(End).coalesce(\"M\").cat(\"!\"))} "*boundary_source("return(forbidden())"),"capture_until_boundary")
    end
    @testset "Callbacks retain caller cursor effects and function invocation fence" begin
        check(boundary_source(raw"""cb={||return(capture_until_boundary(End).coalesce("M").cat("!"))};out=cb();return([out,cursor_pos(),capture_slice_pos()])"""),
            "αβ:ENDTAIL",Any["αβ:!",3,0])
        function_fence("fn apply(callback: codeblock){return(callback())} "*boundary_source(raw"""return(apply(){return(capture_until_boundary(End).coalesce("M").cat("!"))})"""),"capture_until_boundary")
    end
end
end
