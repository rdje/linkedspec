module JuliaRuleCallResultSelection
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
    error("unexpected rule-call selection fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:RuleCallSelectionGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "rule-call-selection.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "rule-call-selection.spec",
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
    println("RULE_CALL_SELECTION ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "x")
    println("RULE_CALL_SELECTION_FENCE ", JSON3.write(actual))
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

@testset "Julia static rule-call result selection" begin
    @testset "Frozen shared rule-call target" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","rule_call_selection_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","rule_call_selection_values.json"),String),Any)
        check(source,"αβ:ENDTAIL",expected)
    end
    @testset "Selected child values preserve every ordinary kind" begin
        check(raw"""
Top:: I {return([call(Child)[0],call(Child)[1],call(Child)[2],call(Child)[3],call(Child)[4],call(Child)[5]])}
Child: I {return([false,0,"0",undef,["a"],hash("name","b")])}
""","x",Any[false,0,"0",nothing,Any["a"],Dict("name"=>"b")])
    end
    @testset "Scalar null empty and missing child results retain typed null reads" begin
        check(raw"""
Top:: I {return([call(Text)[-1].coalesce("M"),call(Nothing)[0].coalesce("N"),call(Empty)[-1].coalesce("E"),call(Object)["missing"].coalesce("K")])}
Text: I {return("red:tail")}
Nothing: I {return(undef)}
Empty: I {return([])}
Object: I {return(hash())}
""","x",Any["M","N","E","K"])
    end
    @testset "Existing bound and method rule-call controls remain healthy" begin
        check(raw"""
Top:: I {part=call(Child);return([part[-1].uppercase(),call(Child).last().uppercase()])}
Child: I {return(["red","tail"])}
""","x",Any["TAIL","TAIL"])
    end
    @testset "Bare child label keeps static lookup and signed read" begin
        check(raw"""
Top:: I {Child="Wrong";return(call(Child)[-1].uppercase())}
Child: I {return(["red","tail"])}
Wrong: I {return(["wrong"])}
""","x","TAIL")
    end
    @testset "Pure function call fence and explicit value arguments stay distinct" begin
        function_fence(raw"""
fn forbidden(){return(call(Child)[-1].uppercase())}
Top:: I {return(forbidden())}
Child: I {return(["tail"])}
""","call")
        check(raw"""
fn upper(text){return(text.uppercase())}
Top:: I {return(upper(call(Child)[-1]))}
Child: I {return(["red","tail"])}
""","x","TAIL")
    end
end
end
