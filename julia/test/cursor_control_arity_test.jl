module JuliaCursorControlArity
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
    host = Module(gensym(:CursorArityGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "cursor-control-arity.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "cursor-control-arity.spec",
        ),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        result[route] = try
            Dict("ok" => operation())
        catch failure
            row = Dict{String,Any}("error"=>sprint(showerror, failure), "class"=>string(nameof(typeof(failure))))
            if failure isa RuntimeInterpreterException && failure.diagnostic !== nothing
                diagnostic = failure.diagnostic
                row["diagnostic"] = Dict(
                    "code"=>diagnostic.code, "stage"=>diagnostic.stage,
                    "helper_name"=>diagnostic.helper_name, "actual_arity"=>diagnostic.actual_arity,
                    "expected_arity"=>diagnostic.expected_arity, "rule_label"=>diagnostic.rule_label,
                )
            end
            row
        end
    end
    return result
end


const helpers = ("save_cursor","restore_cursor","rewind_entry_start","rewind_match_start")
function carrier(body, definitions="")
    return "$definitions\nTop::\n -> Value[entry] {return(call(Value))}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {$body}\n"
end
function positive(label, source, input, expected)
    actual=observe(source,input)
    println("CURSOR_ARITY_POSITIVE ",label," ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test haskey(row,"ok") && strict_equal(row["ok"],expected)
    end
end
function require_arity(actual,helper,count)
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        expected_class=route in ("native","restored") ? "RuntimeInterpreterException" : "GeneratedSourceException"
        valid=get(row,"class","")==expected_class && all(occursin(part,get(row,"error","")) for part in
            ("helper_arity_mismatch","helper_name=$helper","actual_arity=$count"))
        if route in ("native","restored")
            d=get(row,"diagnostic",Dict())
            valid=valid && get(d,"code",nothing)=="helper_arity_mismatch" &&
                get(d,"stage",nothing)=="helper_arity_mismatch" &&
                get(d,"helper_name",nothing)==helper && get(d,"actual_arity",nothing)==count &&
                get(d,"expected_arity",nothing)=="exactly 0 arguments"
        end
        @test valid
    end
end
@testset "Julia cursor control zero arity" begin
    for helper in helpers
        @testset "Invalid $helper forms" begin
            forms=(("$helper(1)",1),("$helper(extra:1)",1),("$helper(1,2)",2),
                ("$helper(trap())",1),("$helper(1)[0].coalesce(\"M\")",1))
            # Collect every route and form before any RED/GREEN assertion.
            observed=Any[Dict("expression"=>expr,"count"=>count,
                "routes"=>observe(carrier("save_cursor();return([$expr,cursor_pos()])",
                    "fn trap(){return(entry_text())}"),"zzab:cd")) for (expr,count) in forms]
            push!(observed,Dict("expression"=>"absent-anchor $helper(1)","count"=>1,
                "routes"=>observe("Top:: I {return($helper(1))}","x")))
            println("CURSOR_ARITY_INVALID ",JSON3.write(Dict("helper"=>helper,"cases"=>observed)))
            for row in observed
                require_arity(row["routes"],helper,row["count"])
            end
        end
    end
    @testset "Valid0 null Number Unicode stack absence" begin
        body="saved=save_cursor();before=cursor_pos();entry=rewind_entry_start();ep=cursor_pos();local_value=rewind_match_start();lp=cursor_pos();restored=restore_cursor();return([saved,before,entry,ep,local_value,lp,restored,cursor_pos()]);"
        positive("ascii",carrier(body),"zzab:cd",Any[nothing,5,2,2,4,4,nothing,5])
        positive("unicode",carrier(body),"🙂ab:cd",Any[nothing,4,1,1,3,3,nothing,4])
        positive("absent","Top:: I {return([restore_cursor(),rewind_entry_start(),rewind_match_start(),cursor_pos(),save_cursor(),restore_cursor(),cursor_pos()])}","x",Any[nothing,nothing,nothing,0,nothing,nothing,0])
    end
    @testset "Pure function state before arity" begin
        rows=Any[Dict("helper"=>helper,"argument"=>arg,"routes"=>observe(
            carrier("return(denied())","fn trap(){return(entry_text())}\nfn denied(){return($helper($arg))}"),"zzab:cd"))
            for helper in helpers for arg in ("1","trap()")]
        println("CURSOR_ARITY_FUNCTION ",JSON3.write(rows))
        for item in rows
            @test Set(keys(item["routes"]))==Set(["native","restored","plan","fresh"])
            for row in values(item["routes"])
                @test all(occursin(part,get(row,"error","")) for part in ("parser-state helper","'$(item["helper"])'")) &&
                    !occursin("helper_arity_mismatch",get(row,"error",""))
            end
        end
    end
    @testset "Trailing bodies retain compilation rejection" begin
        rows=Any[]
        for helper in helpers
            source=carrier("return($helper(){return(1)})")
            parsed=parse_spec_with_staged_user_function_definitions(source)
            observation=try
                compile_spec(parsed)
                nothing
            catch error
                Dict("stage"=>"compile","error"=>sprint(showerror,error),"class"=>string(nameof(typeof(error))))
            end
            push!(rows,Dict("helper"=>helper,"compile"=>observation))
        end
        println("CURSOR_ARITY_TRAILING ",JSON3.write(rows))
        for item in rows
            compilation=item["compile"]
            @test compilation!==nothing && compilation["stage"]=="compile" && all(
                occursin(part,compilation["error"]) for part in
                ("callable_contract_rejected",item["helper"],"does not declare a final codeblock parameter"))
        end
    end
    @testset "Unrelated function prefix and logical arity" begin
        positive("prefix",carrier("return(rewind_entry_custom(2))","fn rewind_entry_custom(value){return(value.add(1))}"),"zzab:cd",3)
        actual=observe(carrier("return(and())"),"zzab:cd")
        println("CURSOR_ARITY_LOGICAL ",JSON3.write(actual))
        @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
        for row in values(actual)
            @test all(occursin(part,get(row,"error","")) for part in ("helper_arity_mismatch","helper_name=and","at least 1"))
        end
    end
end
end
