module JuliaConstructorResultComposition
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
    error("unexpected constructor fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:ConstructorGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "constructor-result-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "constructor-result-composition.spec",
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
    println("CONSTRUCTOR_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia retained constructor result guards" begin
    check("primitive_array",raw"""Value::
 I {return(array("tail",0,false,undef,["nested"],{"k":1}))}
""","x",JSON3.read(raw"""["tail",0,false,null,["nested"],{"k":1}]""",Any))
    check("primitive_hash",raw"""Value::
 I {return(hash("k",["head","tail"],"flag",false,"zero",0,"missing",undef))}
""","x",JSON3.read(raw"""{"flag":false,"k":["head","tail"],"missing":null,"zero":0}""",Any))
    check("empty_and_compatible",raw"""Value::
 I {a=array(3,1).sorted().last().add(4);b=hash("k","tail").sorted_keys().last().uppercase();return([array().count(),hash().count_keys(),a,b])}
""","x",JSON3.read(raw"""[0,0,7,"K"]""",Any))
    check("direct_reads",raw"""Value::
 I {a=array("head","tail")[-1].uppercase();b=hash("k",["head","tail"])["k"][-1].uppercase();return([a,b])}
""","x",JSON3.read(raw"""["TAIL","TAIL"]""",Any))
    check("array_hash_guard",raw"""Value::
 I {order="";out=array("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,order])}
""","x",JSON3.read(raw"""[null,""]""",Any))
    check("hash_array_guard",raw"""Value::
 I {order="";out=hash("k","tail").take({order=cat(order,"A");1});return([out,order])}
""","x",JSON3.read(raw"""[null,""]""",Any))
    check("selected_guards",raw"""Value::
 I {order="";a=array(false,"tail")[0].take({order=cat(order,"A");1});b=hash("k","tail")["k"].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}
""","x",JSON3.read(raw"""[null,null,""]""",Any))
    check("completed_bound_guards",raw"""Value::
 I {order="";items=array("tail");meta=hash("k","tail");a=items.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce(undef).take({order=cat(order,"A");1});return([a,b,items,meta,order])}
""","x",JSON3.read(raw"""[null,null,["tail"],{"k":"tail"},""]""",Any))
    check("source_order_snapshot",raw"""Value::
 I {order="";items=["head","tail"];out=array({order=cat(order,"S");return(items)},["old"])[{items=["new"];order=cat(order,"I");0}][{order=cat(order,"J");-1}].cat({order=cat(order,"C");"!"}).uppercase();return([out,items,order])}
""","x",JSON3.read(raw"""["TAIL!",["new"],"SIJC"]""",Any))
    check("with_kinds",raw"""Value::
 I {value="outer";order="";a=array("head","tail").with(){return(hash("k",[value,"tail"]))}["k"][-1].uppercase();bad=hash("k","tail").with(){return(false)}.take({order=cat(order,"A");1});return([a,bad,value,order])}
""","x",JSON3.read(raw"""["TAIL",null,"outer",""]""",Any))
    check("function_scope",raw"""fn pick(){items=["tail"];return(array(items,"other")[0][-1].uppercase())}
Value::
 I {items=["caller"];return([pick(),items])}
""","x",JSON3.read(raw"""["TAIL",["caller"]]""",Any))
    check("array_payload_order",raw"""Value::
 I {order="";out=array({order=cat(order,"A");"first"},{order=cat(order,"B");"tail"}).last().uppercase();return([out,order])}
""","x",JSON3.read(raw"""["TAIL","AB"]""",Any))
    check("guard_before_with",raw"""Value::
 I {order="";out=array("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}
""","x",JSON3.read(raw"""[null,""]""",Any))
    check("valid_empty_with",raw"""Value::
 I {order="";out=hash().with(){order=cat(order,"W");return([value.count_keys(),"tail"])};return([out,order])}
""","x",JSON3.read(raw"""[[0,"tail"],"W"]""",Any))
    check("hash_rejection_source_once_with",raw"""Value:: I {order="";out=hash({order=cat(order,"S");return("k")},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}""","x",JSON3.read(raw"""[null,"S"]""",Any))
    check("array_prefix_rejection_skips_with",raw"""Value:: I {order="";out=array("head","tail").take(1).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}""","x",JSON3.read(raw"""[null,""]""",Any))
    check("valid_empty_array_prefix_with",raw"""Value:: I {order="";out=array("tail").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}""","x",JSON3.read(raw"""[[0,"tail"],"W"]""",Any))
    check("valid_null_result_with",raw"""Value:: I {order="";out=array("tail").with(){order=cat(order,"N");return(undef)}.with(){order=cat(order,"W");return("recovered")};return([out,order])}""","x",JSON3.read(raw"""["recovered","NW"]""",Any))
    check("computed_key_forms",raw"""Value:: I {names=["idx"];meta={"key":"field"};return([hash("k".cat("x"),1),hash(names[0],2),hash(meta["key"],3),hash({return("block")},4),hash(cat("c","all"),5)])}""","x",JSON3.read(raw"""[{"kx":1},{"idx":2},{"field":3},{"block":4},{"call":5}]""",Any))
    check("hash_block_key_value_order_snapshot",raw"""Value:: I {name="old";order="";out=hash({order=cat(order,"K");return(name)},{name="new";order=cat(order,"V");return([false,0,"tail"])});return([out,name,order])}""","x",JSON3.read(raw"""[{"old":[false,0,"tail"]},"new","KV"]""",Any))
    check("hash_block_key_function_scope",raw"""fn build(key){return(hash({return(key)},array("tail",false)))} Value:: I {key="caller";return([build("inside"),key])}""","x",JSON3.read(raw"""[{"inside":["tail",false]},"caller"]""",Any))
    actual=observe(raw"""Value:: I {return(array({items="text";push(items,"x")},"tail").last().coalesce("masked"))}""","x")
    println("CONSTRUCTOR_ARGUMENT_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    actual=observe(raw"""Value:: I {return(hash({items="text";push(items,"x")},"tail").take(1))}""","x")
    println("CONSTRUCTOR_KEY_ERROR ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for row in values(actual)
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "array(items).take(1)",
        "hash(meta).take(1)",
        "hash(\"odd\").take(1)",
        "hash(flat_array([\"k\",1])).take(1)",
        "array(flat_array([1,2])).set_key(\"k\",1)",
        "array(flat_hash({\"k\":1})).set_key(\"k\",1)",
        "flat_array([1,2]).set_key(\"k\",1)",
        "custom_constructor(\"tail\").set_key(\"k\",1)",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==8
    println("CONSTRUCTOR_SHAPES ",JSON3.write(shapes))
end
end # module
