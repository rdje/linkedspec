module JuliaFreeDefaultResultComposition
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
    error("unexpected free-default fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:FreeDefaultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "free-default-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "free-default-result-composition.spec",
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
    println("FREE_DEFAULT_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia canonical free-default result guards" begin
    check("scalar_primitives",raw"""Value::
 I {return([coalesce(undef,"tail"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce_nonempty("",0,"late"),coalesce_nonempty(undef,false,"late"),coalesce_nonempty(undef,"")])}
""","x",JSON3.read(raw"""["tail","",0,false,null,0,false,null]""",Any))
    check("scalar_compatible",raw"""Value::
 I {return([coalesce(undef," tail ").trim().uppercase(),coalesce_nonempty("",0).add(1),coalesce(false,true).not(),coalesce_nonempty(undef,"tail").cat("!")])}
""","x",JSON3.read(raw"""["TAIL",1,true,"tail!"]""",Any))
    check("scalar_string_guards",raw"""Value::
 I {order="";a=coalesce(undef,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=coalesce_nonempty("","tail").take({order=cat(order,"A");1});return([a,b,order])}
""","x",JSON3.read(raw"""[null,null,""]""",Any))
    check("scalar_number_bool_guards",raw"""Value::
 I {order="";a=coalesce(undef,0).take({order=cat(order,"A");1});b=coalesce_nonempty(undef,false).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}
""","x",JSON3.read(raw"""[null,null,""]""",Any))
    check("container_compatible",raw"""Value::
 I {return([coalesce(undef,["head","tail"])[-1].uppercase(),coalesce_nonempty(undef,{"k":"tail"}).sorted_keys().last().uppercase(),coalesce([],"late").count(),coalesce_nonempty({},"late").count_keys()])}
""","x",JSON3.read(raw"""["TAIL","K",0,0]""",Any))
    check("container_guards",raw"""Value::
 I {order="";a=coalesce(["tail"],undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=coalesce_nonempty({"k":"tail"},undef).take({order=cat(order,"A");1});return([a,b,order])}
""","x",JSON3.read(raw"""[null,null,""]""",Any))
    check("completed_bound_guards",raw"""Value::
 I {order="";saved=coalesce(undef,["tail"]);meta=coalesce_nonempty("",{"k":"tail"});a=saved.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce(undef).take({order=cat(order,"A");1});return([a,b,saved,meta,order])}
""","x",JSON3.read(raw"""[null,null,["tail"],{"k":"tail"},""]""",Any))
    check("selected_guard",raw"""Value::
 I {order="";a=coalesce(undef,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,order])}
""","x",JSON3.read(raw"""[null,""]""",Any))
    check("lazy_order_and_snapshot",raw"""Value::
 I {order="";items=["head","tail"];out=coalesce({order=cat(order,"S");undef},{order=cat(order,"D");items},{order=cat(order,"L");"late"})[{items=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
""","x",JSON3.read(raw"""["TAIL!",["new"],"SDIC"]""",Any))
    check("skip_unused_failure",raw"""Value::
 I {order="";a=coalesce("",{items="text";push(items,"x")}).cat("!");b=coalesce_nonempty(0,{items="text";push(items,"x")}).add(1);return([a,b,order])}
""","x",JSON3.read(raw"""["!",1,""]""",Any))
    check("with_kinds_and_outer_scope",raw"""Value::
 I {value="outer";order="";a=coalesce(undef,"tail").with(){return({"k":[value,"tail"]})}["k"][-1].uppercase();bad=coalesce_nonempty("","tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([a,bad,value,order])}
""","x",JSON3.read(raw"""["TAIL",null,"outer",""]""",Any))
    check("function_scope",raw"""fn pick(){order="";items=["head","tail"];out=coalesce({order=cat(order,"S");undef},{order=cat(order,"D");items},{order=cat(order,"L");"late"})[{items=["new"];order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
Value::
 I {items=["caller"];order="outer";return([pick(),items,order])}
""","x",JSON3.read(raw"""[["TAIL!",["new"],"SDIC"],["caller"],"outer"]""",Any))
    check("valid_null_with_runs",raw"""Value:: I {order="";out=coalesce(undef,undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}""","x",JSON3.read(raw"""["recovered","W"]""",Any))
    check("valid_empty_array_with_runs",raw"""Value:: I {order="";out=coalesce(["tail"],undef).take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}""","x",JSON3.read(raw"""[[0,"tail"],"W"]""",Any))
    check("rejection_skips_with_after_source_once",raw"""Value:: I {order="";out=coalesce_nonempty({order=cat(order,"S");""},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}""","x",JSON3.read(raw"""[null,"S"]""",Any))
    check("valid_with_preserves_outer_value",raw"""Value:: I {value="outer";out=coalesce(undef,"tail").with(){return(value.cat("!"))};return([out,value])}""","x",JSON3.read(raw"""["tail!","outer"]""",Any))
    check("named_nonempty_container_guards",raw"""Value:: I {order="";items=["tail"];meta={"k":"tail"};a=items.coalesce_nonempty({order=cat(order,"F");"late"}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce_nonempty({order=cat(order,"F");"late"}).take({order=cat(order,"A");1});return([a,b,items,meta,order])}""","x",JSON3.read(raw"""[null,null,["tail"],{"k":"tail"},""]""",Any))
    actual=observe(raw"""Value:: I {return(coalesce(undef,{items="text";push(items,"x")}).coalesce("masked"))}""","x")
    println("FREE_DEFAULT_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "coalesce().take(1)",
        "coalesce(\"tail\").take(1)",
        "coalesce(first:\"tail\",second:undef).take(1)",
        "coalesce_nonempty(\"\",\"tail\"){return(\"x\")}.take(1)",
        "(coalesce(undef,\"tail\")).take(1)",
        "thunk().take(1)",
        "coalesce(undef,[\"tail\"])[-1]=\"x\"",
        "{|| return(coalesce(undef,\"tail\").take(1)) }",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==8
    println("FREE_DEFAULT_SHAPES ",JSON3.write(shapes))
end
end # module
