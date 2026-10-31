module JuliaEmptinessResultGuardComposition
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
    error("unexpected emptiness source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:EmptinessGuardGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "emptiness-result-guard-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "emptiness-result-guard-composition.spec",
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
    println("EMPTINESS_GUARD_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia emptiness source and prefix guards" begin
    check("primitive_emptiness","Value:: I {return([[is_empty([]),is_empty([1]),is_nonempty([1]),is_nonempty([])],[[].is_empty(),[1].is_empty(),[1].is_nonempty(),[].is_nonempty()]])}","x",JSON3.read("[[true,false,true,false],[true,false,true,false]]",Any))
    check("empty_domains","Value:: I {return([is_empty(undef),is_empty(\"\"),is_empty([]),is_empty({}),is_empty(0),is_empty(false),is_empty(\"0\"),is_empty([0]),is_empty({\"k\":0}),is_nonempty(undef),is_nonempty(\"\"),is_nonempty([]),is_nonempty({}),is_nonempty(0),is_nonempty(false),is_nonempty(\"0\"),is_nonempty([0]),is_nonempty({\"k\":0})])}","x",JSON3.read("[true,true,true,true,false,false,false,false,false,false,false,false,false,true,true,true,true,true]",Any))
    check("compatible_values","Value:: I {return([is_empty([1]).cat(\"!\"),is_empty([1]).coalesce_nonempty(\"late\").cat(\"!\"),is_nonempty([]).cat(\"!\"),is_nonempty([]).coalesce(\"late\").cat(\"!\")])}","x",JSON3.read("[\"0!\",\"0!\",\"0!\",\"0!\"]",Any))
    check("value_kinds","Value:: I {return([is_empty([1]).copy(),[1].is_empty().copy(),is_empty([1]).add(1),is_empty([]).add(1)])}","x",JSON3.read("[false,false,null,null]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=is_empty([1]).take({order=cat(order,\"A\");1});right=is_empty([]).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=[1].is_empty().take({order=cat(order,\"A\");1});right=[].is_empty().set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=is_empty({order=cat(order,\"S\");[1]}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");[1]}.is_empty().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"S\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=is_empty([1]).cat(\"x\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out=[1].is_empty().cat(\"x\").split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_array_bridges","Value:: I {return([is_empty([1]).cat(\",x\").split(\",\").last().uppercase(),[].is_empty().cat(\",x\").split(\",\").last().uppercase()])}","x",JSON3.read("[\"X\",\"X\"]",Any))
    check("source_snapshot","Value:: I {order=\"\";value=[];out=is_empty({order=cat(order,\"S\");value}).cat({value=[1];order=cat(order,\"C\");\"!\"});return([out,value.is_empty().cat(\"!\"),order])}","x",JSON3.read("[\"1!\",\"0!\",\"SC\"]",Any))
    check("valid_false_and_true_with","Value:: I {order=\"\";left=is_empty([1]).with(){order=cat(order,\"F\");return([value,value.copy()])};right=[].is_empty().with(){order=cat(order,\"R\");return(value)};return([left,right,order])}","x",JSON3.read("[[false,false],true,\"FR\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=is_empty([1]).add(\"bad\").with(){order=cat(order,\"F\");return(\"free\")};right=[1].is_empty().add(\"bad\").with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=is_empty([1]).add(\"bad\").coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("with_result_array","Value:: I {order=\"\";out=is_empty([1]).with(){order=cat(order,\"W\");return([\"ok\"])}.first().uppercase();return([out,order])}","x",JSON3.read("[\"OK\",\"W\"]",Any))
    check("all_canonical_free_with_guards","Value:: I {order=\"\";out=[is_empty([]).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},is_empty([1]).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},is_nonempty([1]).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},is_nonempty([]).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[[].is_empty().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},[1].is_empty().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},[1].is_nonempty().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},[].is_nonempty().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";left=is_empty([1]).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right=[].is_empty().take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    check("all_canonical_free_guards","Value:: I {order=\"\";out=[is_empty([]).take({order=cat(order,\"A\");1}),is_empty([1]).take({order=cat(order,\"A\");1}),is_nonempty([1]).take({order=cat(order,\"A\");1}),is_nonempty([]).take({order=cat(order,\"A\");1})];return([out,order])}","x",JSON3.read("[[null,null,null,null],\"\"]",Any))
    check("repeated_predicates","Value:: I {return([is_empty([1]).is_empty().cat(\"!\"),is_empty([1]).is_nonempty().cat(\"!\"),[1].is_empty().is_empty().cat(\"!\"),[].is_empty().is_nonempty().cat(\"!\")])}","x",JSON3.read("[\"0!\",\"1!\",\"0!\",\"1!\"]",Any))
    actual=observe("Value:: I {return(is_empty({items=\"text\";push(items,\"x\")}).coalesce(\"masked\"))}","x")
    println("EMPTINESS_GUARD_ERROR needed_source_error ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    shapes=Any[]
    for source in (
        "is_empty().take(1).with(){return(\"x\")}",
        "is_empty([],[]).take(1).with(){return(\"x\")}",
        "is_empty(value:[]).take(1)",
        "is_nonempty().take(1)",
        "is_nonempty([1],[2]).take(1)",
        "is_nonempty(value:[1]).take(1)",
        "[].is_empty(1).with(){return(\"x\")}",
        "[1].is_nonempty(1).with(){return(\"x\")}",
        "[].is_empty(value:1).with(){return(\"x\")}",
        "is_empty([]){return(\"x\")}",
        "[].is_empty(){return(\"x\")}",
        "is_empty([]).map_leaves(){return(value)}",
        "[].is_empty().map_leaves(){return(value)}",
        "{|| return(is_empty([]).take(1).with(){return(\"x\")}) }",
        "is_empty([]).custom_empty().with(){return(\"x\")}",
        "[].is_empty().custom_empty().with(){return(\"x\")}",
        "is_defined(undef).take(1).with(){return(\"x\")}",
        "str_eq(\"a\",\"b\").take(1).with(){return(\"x\")}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==18
    println("EMPTINESS_GUARD_SHAPES ",JSON3.write(shapes))
end
end # module
