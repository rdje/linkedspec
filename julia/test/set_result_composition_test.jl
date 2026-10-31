module JuliaSetResultComposition
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
    host = Module(gensym(:SetResultGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "set-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "set-result-composition.spec",
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
    println("SET_RESULT_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia canonical set result guards" begin
    root=dirname(dirname(@__DIR__))
    check("shared",read(joinpath(root,"tests","fixtures","set_result_selection_values.spec"),String),"x",
        JSON3.read(read(joinpath(root,"tests","fixtures","set_result_selection_values.json"),String),Any))
    check("existing_primitives_and_compatible_methods",raw"""Value:: I {a=set(text," tail ").trim().uppercase();b=set(items,[3,1]).sorted().first();c=set(meta,{"k":"tail"});d=set(flag,false).not();e=set(number,0).add(1);f=set(absent,undef).coalesce("M");return([a,b,c,d,e,f,text,items,meta,flag,number,absent])}""","x",JSON3.read(raw"""["TAIL",1,{"k":"tail"},true,1,"M"," tail ",[3,1],{"k":"tail"},false,0,null]""",Any))
    check("existing_completed_value_read",raw"""Value:: I {saved=set(items,["tail"]);out=saved.coalesce(undef)[-1].uppercase();return([out,items])}""","x",JSON3.read(raw"""["TAIL",["tail"]]""",Any))
    check("direct_incompatible_consumers_skip_operands",raw"""Value:: I {order="";out=set(items,["tail"]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}""","x",JSON3.read(raw"""[null,["tail"],""]""",Any))
    check("selected_guards_empty_defaults_and_noncontainer_recovery",raw"""Value:: I {order="";bad=set(flag,false)[0].coalesce(false).take({order=cat(order,"A");1});text=set(word,"tail")[0].coalesce(["a","tail"])[-1].uppercase();empty=set(blank,"").coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,text,empty,flag,word,blank,order])}""","x",JSON3.read(raw"""[null,"TAIL","!",false,"tail","",""]""",Any))
    check("source_once_before_consumer_rebinding_and_local_returns",raw"""Value:: I {order="";out=set(items,{order=cat(order,"S");return(["tail"])}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}""","x",JSON3.read(raw"""["TAIL!",["new"],"SC"]""",Any))
    check("with_actual_kinds_preserves_outer_value",raw"""Value:: I {value="outer";order="";a=set(text,"source").with(){return([value,"tail"])}[-1].uppercase();b=set(meta,{}).with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=set(flag,false).with(){return(false)}.take({order=cat(order,"A");1});return([a,b,bad,value,order,text,meta,flag])}""","x",JSON3.read(raw"""["TAIL","TAIL",null,"outer","","source",{},false]""",Any))
    check("function_local_set_source_and_selectors_keep_caller_scope",raw"""fn pick(){items=["old"];order="";out=set(items,["a","tail"])[{order=cat(order,"I");-1}].uppercase();return([out,items,order])} Value:: I {items=["caller"];order="outer";return([pick(),items,order])}""","x",JSON3.read(raw"""[["TAIL",["a","tail"],"I"],["caller"],"outer"]""",Any))
    check("set_preserves_existing_first_class_codeblock_values",raw"""Value:: I {saved=set(thunk,{|| return("tail")});return([thunk(),saved()])}""","x",JSON3.read(raw"""["tail","tail"]""",Any))
    check("selected_bool_skips_array_operand",raw"""Value:: I {order="";out=set(items,[false])[0].take({order=cat(order,"A");1});return([out,items,order])}""","x",JSON3.read(raw"""[null,[false],""]""",Any))
    check("selected_string_skips_hash_operands",raw"""Value:: I {order="";out=set(items,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}""","x",JSON3.read(raw"""[null,["tail"],""]""",Any))
    actual=observe(raw"""Value:: I {return(set(target,{items="text";push(items,"x")}).coalesce("masked"))}""","x")
    println("SET_RESULT_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    alias=parse_action_expression(raw"""=(items,["tail"])""")
    @test alias isa ActionCallExpr && something(alias.source_method,alias.name)=="="
    shapes=Any[to_json(alias)]
    for source in (
        raw"""set()""",raw"""set(items)""",raw"""set(items,["tail"],99)""",
        raw"""set(["items"],"tail")""",raw"""set(items,"tail"){return("x")}[0]""",
        "set(items,[\"tail\"])[-1]=\"x\"",raw"""{|| return(set(items,["tail"])[-1])}""",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    println("SET_RESULT_SHAPES ",JSON3.write(shapes))
end
end # module
