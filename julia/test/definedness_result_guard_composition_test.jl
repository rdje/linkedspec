module JuliaDefinednessResultGuardComposition
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
    error("unexpected definedness source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:DefinednessGuardGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "definedness-result-guard-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "definedness-result-guard-composition.spec",
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
    println("DEFINEDNESS_GUARD_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia definedness source and prefix guards" begin
    check("primitive_definedness","Value:: I {return([[is_defined(0),is_defined(undef),is_undefined(undef),is_undefined(0)],[0.is_defined(),undef.is_defined(),undef.is_undefined(),0.is_undefined()]])}","x",JSON3.read("[[true,false,true,false],[true,false,true,false]]",Any))
    check("defined_domains","Value:: I {return([is_defined(false),is_defined(0),is_defined(\"\"),is_defined([]),is_defined({}),is_undefined(false),is_undefined(0),is_undefined(\"\"),is_undefined([]),is_undefined({})])}","x",JSON3.read("[true,true,true,true,true,false,false,false,false,false]",Any))
    check("compatible_values","Value:: I {return([is_defined(0).cat(\"!\"),is_defined(undef).coalesce_nonempty(\"late\").cat(\"!\"),0.is_undefined().cat(\"!\"),is_defined(undef).coalesce(\"late\").cat(\"!\")])}","x",JSON3.read("[\"1!\",\"0!\",\"0!\",\"0!\"]",Any))
    check("value_kinds","Value:: I {return([is_defined(undef).copy(),undef.is_defined().copy(),is_defined(undef).add(1),is_defined(0).add(1)])}","x",JSON3.read("[false,false,null,null]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=is_defined(undef).take({order=cat(order,\"A\");1});right=is_undefined(undef).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=undef.is_defined().take({order=cat(order,\"A\");1});right=undef.is_undefined().set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=is_defined({order=cat(order,\"S\");return(false)}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");return(false)}.is_defined().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=is_defined(undef).cat(\"x\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out=undef.is_defined().cat(\"x\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_array_bridges","Value:: I {return([is_defined(undef).cat(\",x\").split(\",\").last().uppercase(),undef.is_undefined().cat(\",x\").split(\",\").last().uppercase()])}","x",JSON3.read("[\"X\",\"X\"]",Any))
    check("source_snapshot","Value:: I {value=0;order=\"\";out=is_defined({order=cat(order,\"S\");return(value)}).cat({value=undef;order=cat(order,\"C\");\"!\"});return([out,value,order])}","x",JSON3.read("[\"1!\",null,\"SC\"]",Any))
    check("valid_false_and_true_with","Value:: I {order=\"\";left=is_defined(undef).with(){order=cat(order,\"F\");return([value,value.copy()])};right=0.is_defined().with(){order=cat(order,\"R\");return(value)};return([left,right,order])}","x",JSON3.read("[[false,false],true,\"FR\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=is_defined(undef).add(\"bad\").with(){order=cat(order,\"F\");return(\"free\")};right=undef.is_defined().add(\"bad\").with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=is_defined(undef).add(\"bad\").coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("with_result_array","Value:: I {order=\"\";out=is_defined(undef).with(){order=cat(order,\"W\");return([\"ok\"])}.first().uppercase();return([out,order])}","x",JSON3.read("[\"OK\",\"W\"]",Any))
    check("all_canonical_free_with_guards","Value:: I {order=\"\";out=[is_defined(0).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},is_defined(undef).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},is_undefined(undef).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},is_undefined(0).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[0.is_defined().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},undef.is_defined().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},undef.is_undefined().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},0.is_undefined().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";left=is_defined(undef).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right=0.is_defined().take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    check("all_canonical_free_guards","Value:: I {order=\"\";out=[is_defined(0).take({order=cat(order,\"A\");1}),is_defined(undef).take({order=cat(order,\"A\");1}),is_undefined(undef).take({order=cat(order,\"A\");1}),is_undefined(0).take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    actual=observe("Value:: I {return(is_defined({items=\"text\";push(items,\"x\")}).coalesce(\"masked\"))}","x")
    println("DEFINEDNESS_GUARD_ERROR needed_source_error ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "is_defined().take(1).with(){return(\"x\")}",
        "is_defined(undef,0).take(1).with(){return(\"x\")}",
        "is_defined(value:undef).take(1)",
        "is_undefined().take(1)",
        "is_undefined(0,undef).take(1)",
        "is_undefined(value:0).take(1)",
        "undef.is_defined(1).with(){return(\"x\")}",
        "0.is_undefined(1).with(){return(\"x\")}",
        "undef.is_defined(value:1).with(){return(\"x\")}",
        "is_defined(undef){return(\"x\")}",
        "undef.is_defined(){return(\"x\")}",
        "is_defined(undef).map_leaves(){return(value)}",
        "undef.is_defined().map_leaves(){return(value)}",
        "{|| return(is_defined(undef).take(1).with(){return(\"x\")}) }",
        "is_defined(undef).custom_definedness().with(){return(\"x\")}",
        "undef.is_defined().custom_definedness().with(){return(\"x\")}",
        "str_eq(\"a\",\"a\").take(1).with(){return(\"x\")}",
        "and(false).take(1).with(){return(\"x\")}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==18
    println("DEFINEDNESS_GUARD_SHAPES ",JSON3.write(shapes))
end
end # module
