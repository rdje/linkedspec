module JuliaCursorRewindResult
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
    error("unexpected cursor rewind fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:CursorRewindGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "cursor-rewind-result.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "cursor-rewind-result.spec",
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

function check(label, source, input, expected)
    actual = observe(source, input)
    println("CURSOR_REWIND ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

function function_fence(source, helper)
    actual = observe(source, "zzab:cd")
    println("CURSOR_REWIND_FENCE ", helper, " ", JSON3.write(actual))
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


function carrier(body, definitions="")
    return "$definitions\nTop::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {$body}\n"
end
const primitive_body="save_cursor();p0=cursor_pos();v0=rewind_entry_start();p1=cursor_pos();v1=rewind_match_start();p2=cursor_pos();v2=restore_cursor();p3=cursor_pos();return([p0,v0,p1,v1,p2,v2,p3]);"
@testset "Julia cursor rewind Number results" begin
    @testset "Frozen qualified target" begin
        root=dirname(dirname(@__DIR__))
        source=read(joinpath(root,"tests","fixtures","cursor_rewind_result_values.spec"),String)
        expected=JSON3.read(read(joinpath(root,"tests","fixtures","cursor_rewind_result_values.json"),String),Any)
        check("shared",source,"zzab:cd",expected)
    end
    @testset "Primitive live entry and local anchors" begin
        check("primitive_ascii",carrier(primitive_body),"zzab:cd",Any[5,2,2,4,4,nothing,5])
    end
    @testset "Primitive character Unicode positions" begin
        check("primitive_unicode",carrier(primitive_body),"🙂ab:cd",Any[4,1,1,3,3,nothing,4])
    end
    @testset "Bound and direct numeric text methods" begin
        check("numeric",carrier(raw"""entry_value=rewind_entry_start();p1=cursor_pos();local_value=rewind_match_start();p2=cursor_pos();return([entry_value.add(1).cat("!"),local_value.add(1),p1,p2,rewind_entry_start().add(1),rewind_match_start().add(1),cursor_pos()]);"""),"zzab:cd",Any["3!",5,2,4,3,5,4])
    end
    @testset "Zero and incompatible operand skips" begin
        check("zero_and_guards",carrier(raw"""order="";a=rewind_entry_start().coalesce({order=cat(order,"F");99}).add(1);b=rewind_entry_start().take({order=cat(order,"A");1});c=rewind_match_start().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");7});return([a,b,c,order,cursor_pos()]);"""),"ab:cd",Any[1,nothing,nothing,"",2])
    end
    @testset "Pure function fences and explicit Number" begin
        for helper in ("rewind_entry_start","rewind_match_start")
            function_fence(carrier("return(forbidden())","fn forbidden(){return($helper().coalesce(99).add(1))}"),helper)
        end
        check("explicit_number",carrier("return(inc(2))","fn inc(value){return(value.add(1))}"),"zzab:cd",3)
    end
    @testset "Physical rewinds and null save restore" begin
        check("physical",carrier("saved=save_cursor();rewind_entry_start();p1=cursor_pos();rewind_match_start();p2=cursor_pos();restored=restore_cursor();return([saved,p1,p2,restored,cursor_pos()]);"),"zzab:cd",Any[nothing,2,4,nothing,5])
    end
    @testset "With Array and absent read bridges" begin
        check("bridges",carrier(raw"""return([rewind_entry_start().with(){return([value,"tail"])}[-1].uppercase(),rewind_match_start()[0].coalesce(["a","tail"])[-1].uppercase(),cursor_pos()]);"""),"zzab:cd",Any["TAIL","TAIL",4])
    end
    @testset "Absent anchors retain null without movement" begin
        check("absent","Top:: I {return([rewind_entry_start(),rewind_match_start(),cursor_pos(),restore_cursor(),cursor_pos()])}","x",Any[nothing,nothing,0,nothing,0])
    end
    @testset "Legacy malformed rewind preservation pending arity repair" begin
        # Known defect preservation, no healthy arity or supported-shape credit.
        for (helper,position) in (("rewind_entry_start",2),("rewind_match_start",4))
            for argument in ("1","extra:1")
                check("legacy_$(helper)_$argument",carrier("return([$helper($argument),cursor_pos()])"),"zzab:cd",Any[nothing,position])
            end
        end
    end
end
end
