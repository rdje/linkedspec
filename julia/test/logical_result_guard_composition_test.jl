module JuliaLogicalResultGuardComposition
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
    error("unexpected logical source fixture kind $(typeof(expected))")
end

function observe(source, input)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    compiled = compile_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    host = Module(gensym(:LogicalGuardGenerated))
    Base.include_string(host, emit_julia_source_v2(compiled, "logical-result-guard-composition.spec"))
    parser = Base.invokelatest(getfield, host, :LinkedSpecGeneratedParser)
    result = Dict{String,Any}()
    for (route, operation) in (
        "native" => () -> runtime_execute(LinkedSpecRuntimeEngine(compiled), input).value,
        "restored" => () -> runtime_execute(LinkedSpecRuntimeEngine(compile_spec(restored)), input).value,
        "plan" => () -> execute_generated_parser_v2(
            compiled, build_generated_rule_plan(compiled), input, "logical-result-guard-composition.spec",
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
    println("LOGICAL_GUARD_VALUE ", label, " ", JSON3.write(actual))
    @test Set(keys(actual)) == Set(["native", "restored", "plan", "fresh"])
    for route in ("native", "restored", "plan", "fresh")
        @test haskey(actual[route], "ok") && strict_equal(actual[route]["ok"], expected)
    end
end

@testset "Julia logical source and prefix guards" begin
    check("primitive_logical","Value:: I {return([[and(true),and(false),or(true),or(false),not(false),not(true)],[true.and(true),true.and(false),false.or(true),false.or(false),false.not(),true.not()]])}","x",JSON3.read("[[true,false,true,false,true,false],[true,false,true,false,true,false]]",Any))
    check("typed_truth_domains","Value:: I {return([and(\"0\"),and(\"false\"),and(\"\"),and(0),and(undef),and([]),and({}),and([false]),and({\"k\":false})])}","x",JSON3.read("[true,true,false,false,false,false,false,true,true]",Any))
    check("compatible_values","Value:: I {return([and(false).coalesce_nonempty(9).cat(\"!\"),not(false).cat(\"!\"),or(false).add(1).coalesce_nonempty([\"a\",\"b\"]).last().uppercase(),false.not().and(true).cat(\"!\")])}","x",JSON3.read("[\"0!\",\"1!\",\"B\",\"1!\"]",Any))
    check("free_container_guards","Value:: I {order=\"\";left=and(false).take({order=cat(order,\"A\");1});right=not(false).set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("receiver_container_guards","Value:: I {order=\"\";left=true.and(false).take({order=cat(order,\"A\");1});right=false.not().set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1});return([left,right,order])}","x",JSON3.read("[null,null,\"\"]",Any))
    check("free_guard_before_with","Value:: I {order=\"\";out=and({order=cat(order,\"S\");return(false)},{order=cat(order,\"O\");return(true)}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"SO\"]",Any))
    check("receiver_guard_before_with","Value:: I {order=\"\";out={order=cat(order,\"S\");return(false)}.and({order=cat(order,\"O\");return(true)}).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"SO\"]",Any))
    check("free_bridge_rejection","Value:: I {order=\"\";out=and(false).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("receiver_bridge_rejection","Value:: I {order=\"\";out=false.and(true).split(\",\").set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");1}).with(){order=cat(order,\"W\");return(\"ran\")};return([out,order])}","x",JSON3.read("[null,\"\"]",Any))
    check("valid_array_bridges","Value:: I {return([and(false).split(\",\").first().cat(\"!\"),false.or(true).split(\",\").first().cat(\"!\")])}","x",JSON3.read("[\"0!\",\"1!\"]",Any))
    check("source_operand_snapshot","Value:: I {value=false;order=\"\";out=and({order=cat(order,\"S\");return(value)},{value=true;order=cat(order,\"O\");return(true)}).cat({order=cat(order,\"C\");\"!\"});return([out,value,order])}","x",JSON3.read("[\"0!\",true,\"SOC\"]",Any))
    check("bool_value_copies","Value:: I {return([and(false).copy(),false.and(true).copy(),copy(false)])}","x",JSON3.read("[false,false,false]",Any))
    check("valid_false_and_true_with","Value:: I {order=\"\";left=and(false).with(){order=cat(order,\"F\");return([value,value.copy()])};right=true.or(false).with(){order=cat(order,\"R\");return(value)};return([left,right,order])}","x",JSON3.read("[[false,false],true,\"FR\"]",Any))
    check("valid_null_with","Value:: I {order=\"\";left=and(false).add(1).with(){order=cat(order,\"F\");return(\"free\")};right=false.and(true).add(1).with(){order=cat(order,\"R\");return(\"receiver\")};return([left,right,order])}","x",JSON3.read("[\"free\",\"receiver\",\"FR\"]",Any))
    check("valid_empty_with","Value:: I {order=\"\";out=and(false).add(1).coalesce([]).with(){order=cat(order,\"W\");return(value.count())};return([out,order])}","x",JSON3.read("[0,\"W\"]",Any))
    check("with_result_array","Value:: I {order=\"\";out=and(false).with(){order=cat(order,\"W\");return([\"ok\"])}.first().uppercase();return([out,order])}","x",JSON3.read("[\"OK\",\"W\"]",Any))
    check("all_canonical_free_with_guards","Value:: I {order=\"\";out=[and(true).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},and(false).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},or(true).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},or(false).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},not(false).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},not(true).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null],\"\"]",Any))
    check("all_short_receiver_with_guards","Value:: I {order=\"\";out=[true.and(true).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},true.and(false).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},false.or(true).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},false.or(false).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},false.not().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")},true.not().take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")}];return([out,order])}","x",JSON3.read("[[null,null,null,null,null,null],\"\"]",Any))
    check("function_scope","fn build(){order=\"\";left=and(false).take({order=cat(order,\"A\");1}).with(){order=cat(order,\"W\");return(\"ran\")};right=false.and(true).take({order=cat(order,\"B\");1}).with(){order=cat(order,\"X\");return(\"ran\")};return([left,right,order])}\nValue:: I {value=\"caller\";return([build(),value])}","x",JSON3.read("[[null,null,\"\"],\"caller\"]",Any))
    check("decisive_eager_args","Value:: I {order=\"\";left=and({order=cat(order,\"L\");return(false)},{order=cat(order,\"R\");return(true)}).cat({order=cat(order,\"C\");\"!\"});right=or({order=cat(order,\"A\");return(true)},{order=cat(order,\"B\");return(false)}).cat({order=cat(order,\"D\");\"!\"});return([left,right,order])}","x",JSON3.read("[\"0!\",\"1!\",\"LRCABD\"]",Any))
    actual=observe("Value:: I {return(and({items=\"text\";push(items,\"x\")},true).coalesce(\"masked\"))}","x")
    println("LOGICAL_GUARD_ERROR needed_source_error ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        @test occursin("binding_kind_mismatch",get(row,"error",""))
    end
    actual=observe("Value:: I {return(not({fail(\"must-not-run\")},false).cat(\"!\"))}","x")
    println("LOGICAL_GUARD_ERROR typed_arity_source_error ",JSON3.write(actual))
    @test Set(keys(actual))==Set(["native","restored","plan","fresh"])
    for (route,row) in actual
        @test occursin("helper_arity_mismatch",get(row,"error",""))
        @test !occursin("must-not-run",get(row,"error",""))
        if route in ("native","restored")
            diagnostic=row["diagnostic"]
            @test diagnostic["code"]=="helper_arity_mismatch"
            @test diagnostic["helper_name"]=="not"
            @test diagnostic["actual_arity"]===2
        else
            @test occursin("helper_name=not",row["error"])
            @test occursin("actual_arity=2",row["error"])
        end
    end
    shapes=Any[]
    for source in (
        "and().take(1).with(){return(\"x\")}",
        "or().take(1).with(){return(\"x\")}",
        "not().take(1)",
        "not(true,false).take(1)",
        "and(value:true).take(1).with(){return(\"x\")}",
        "false.and().with(){return(\"x\")}",
        "false.or().with(){return(\"x\")}",
        "false.not(true).with(){return(\"x\")}",
        "false.and(right:true).with(){return(\"x\")}",
        "and(true){return(\"x\")}",
        "false.and(true){return(\"x\")}",
        "and(true).map_leaves(){return(value)}",
        "false.and(true).map_leaves(){return(value)}",
        "{|| return(and(false).take(1).with(){return(\"x\")}) }",
        "and(false).custom_logical().with(){return(\"x\")}",
        "false.not().custom_logical().with(){return(\"x\")}",
    )
        row=try
            Dict("source"=>source,"ast"=>to_json(parse_action_expression(source)))
        catch failure
            Dict("source"=>source,"error"=>sprint(showerror,failure),"class"=>string(nameof(typeof(failure))))
        end
        push!(shapes,row)
    end
    @test length(shapes)==16
    println("LOGICAL_GUARD_SHAPES ",JSON3.write(shapes))
end
end # module
