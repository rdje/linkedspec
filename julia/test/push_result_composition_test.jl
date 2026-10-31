module JuliaPushSnapshotResult
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
    error("unexpected push snapshot fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:PushSnapshotGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "push-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "push-result-composition.spec",
        ),
        "fresh" => () -> Base.invokelatest(Base.invokelatest(getfield, parser, :execute), input),
    )
        result[route] = try
            Dict("ok" => operation())
        catch failure
            row=Dict{String,Any}("error"=>sprint(showerror, failure), "class"=>string(nameof(typeof(failure))))
            if failure isa RuntimeInterpreterException && failure.diagnostic !== nothing
                diagnostic=failure.diagnostic
                row["diagnostic"]=Dict("code"=>diagnostic.code,"stage"=>diagnostic.stage,
                    "helper_name"=>diagnostic.helper_name,"actual_arity"=>diagnostic.actual_arity,
                    "expected_arity"=>diagnostic.expected_arity)
            end
            row
        end
    end
    return result
end

function check(label, source, input, expected)
    actual = observe(source, input)
    println("PUSH_SNAPSHOT_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia push snapshot result guards" begin
    root=dirname(dirname(@__DIR__))
    check("shared",read(joinpath(root,"tests","fixtures","push_result_selection_values.spec"),String),"x",
        JSON3.read(read(joinpath(root,"tests","fixtures","push_result_selection_values.json"),String),Any))
    check("primitive_saved",raw"""Value:: I {items=[];saved=push(items,"a");items.push_back("later");return([saved,items])}""","x",JSON3.read(raw"""[["a"],["a","later"]]""",Any))
    check("absent_empty",raw"""Value:: I {empty=push(created,"").last().coalesce("F").cat("!");missing=push(nulls,undef).last().coalesce(["a","tail"])[-1].uppercase();array=push(empties,[]).last().count().add(1);return([empty,missing,array,created,nulls,empties])}""","x",JSON3.read(raw"""["!","TAIL",1,[""],[null],[[]]]""",Any))
    check("transitions",raw"""Value:: I {items=[];number=push(items,[3,1]).last().sorted().last().add(4);hash=push(items,{"k":"tail"}).last().sorted_keys().last().uppercase();count=push(items,"tail").count().add(1);text=push(items,"tail").copy().last().uppercase();boolean=push(items,false).last().not();logical=push(items,"tail").is_nonempty().and(false);return([number,hash,count,text,boolean,logical,items])}""","x",JSON3.read(raw"""[7,"K",4,"TAIL",true,false,[[3,1],{"k":"tail"},"tail","tail",false,"tail"]]""",Any))
    check("direct_guard",raw"""Value:: I {items=[];order="";out=push(items,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}""","x",JSON3.read(raw"""[null,["tail"],""]""",Any))
    check("selected_recovery",raw"""Value:: I {items=[];order="";bad=push(items,false)[-1].take({order=cat(order,"A");1});out=push(items,"tail")[-1][0].coalesce(["a","tail"])[-1].uppercase();empty=push(items,"")[-1].coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,out,empty,items,order])}""","x",JSON3.read(raw"""[null,"TAIL","!",[false,"tail",""],""]""",Any))
    check("with_kinds",raw"""Value:: I {items=[];value="outer";order="";array=push(items,"a").with(){return([value,"tail"])}[-1].uppercase();hash=push(items,"b").with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=push(items,"c").with(){return(false)}.take({order=cat(order,"A");1});boolean=push(items,"d").with(){return(false)}.coalesce(true);return([array,hash,bad,boolean,value,order,items])}""","x",JSON3.read(raw"""["TAIL","TAIL",null,false,"outer","",["a","b","c","d"]]""",Any))
    check("source_once",raw"""Value:: I {items=[];order="";out=push(items,{order=cat(order,"S");return("tail")}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}""","x",JSON3.read(raw"""["TAIL!",["new"],"SC"]""",Any))
    check("function_local",raw"""fn pick(){items=[];out=push(items,"tail").last().uppercase();return([out,items])} Value:: I {items=["caller"];return([pick(),items])}""","x",JSON3.read(raw"""[["TAIL",["tail"]],["caller"]]""",Any))
    check("static_child",raw"""Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
""","x",JSON3.read(raw"""[["unchanged"],["child-result"],["child-result"]]""",Any))
    check("selected_string_guard",raw"""Value:: I {items=[];order="";out=push(items,"tail")[-1].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}""","x",JSON3.read(raw"""[null,["tail"],""]""",Any))
    for (label,source) in (
        "primitive" => raw"""Value:: I {items="text";return(push(items,"x"))}""",
        "fluent" => raw"""Value:: I {items="text";return(push(items,"x").last().coalesce("masked"))}""",
    )
        actual=observe(source,"x")
        println("PUSH_SNAPSHOT_ERROR ",label," ",JSON3.write(actual))
        @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
        for row in values(actual)
            @test occursin("binding_kind_mismatch",get(row,"error",""))
        end
    end
end
end # module
